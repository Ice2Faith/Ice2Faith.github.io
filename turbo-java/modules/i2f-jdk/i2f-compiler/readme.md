# i2f-compiler

> **内存 Java 编译器 / 表达式求值器**——全模块仅 1 个静态门面类 `MemoryCompiler`（551 行、~27 个 `public` 方法），基于 `javax.tools.JavaCompiler`（JDK 编译 API）实现**运行时编译 → 类加载 → 反射调用**的全链路，无需 tools.jar 独立部署（当前 `JAVA_HOME/lib/tools.jar` 对 `ToolProvider.getSystemJavaCompiler()` 决定成败）。核心能力分三级递进：① **文件级**`compileAsFile` 把源码写为 `.class` 文件到磁盘；② **类级**`compileAsClass`/`compileClass`/`findCompileClass` 编译到临时目录→类加载→自动清理，叠加 4 个 `LruMap`（各 2048 容量）缓存编译结果、类查找、随机类名与源码包装产物；③ **求值级**`evaluateExpression(expression, root)` 将用户用 `###import`/`###method` 标签分隔的表达式包装为 `public RCxxx { public Object _call(Object $root) throws Throwable { ... } }`，编译后反射调用，并自动注入默认 import（`java.lang.*`/`java.util.*`/`java.util.concurrent.*` 等 13 条）与智能补全缺失的 `return` 语句。`compileCall` 支持编译后直接调指定类的指定方法（静态/无参构造实例）；`compileCallRandomClass` 把源码中的 `###class` 占位符替换为随机类名后自动调用。依赖 `i2f-io-file`（`FileUtil.delete` 清理临时目录）+ `i2f-reflect`（`ReflectResolver.matchExecMethod/execMethod`）+ `i2f-lru-map`（四级 LRU 缓存）+ `i2f-std-const`（`RUNTIME_TMP_DIR` 路径常量），四个内部依赖**均真实使用**；lombok **声明未用**。下游 `i2f-extension-xproc4j`（`LangEvalJavaNode` 用 `compileCall`/`findCompileClass` 实现 Java 脚本节点）、`i2f-jdbc-proxy-xml`（`MybatisMapperInflater` 用 `evaluateExpression` 做 MyBatis 表达式求值）、`i2f-extension-agent-javassist`（`LocalFileExpressionEvaluator` 用 `evaluateExpression` 做运行期 REPL）广泛消费；`i2f-jdbc-procedure` POM 声明依赖但无 direct import（被 xproc4j 作为父模块传递消费）。

## 模块路径

- `i2f-jdk/i2f-compiler`

## 模块依赖

| 坐标 | scope | optional | 说明 |
|---|---|---|---|
| i2f.turbo:i2f-io-file | compile | false | `FileUtil.delete` 清理临时编译输出目录 |
| i2f.turbo:i2f-reflect | compile | false | `ReflectResolver.matchExecMethod/execMethod` 做编译后方法匹配与反射调用 |
| i2f.turbo:i2f-lru-map | compile | false | 四级 LRU 缓存（`CACHE_COMPILE_CLASS`/`CACHE_FIND_COMPILE_CLASS`/`CACHE_RANDOM_CLASS_NAME`/`CACHE_WRAP_EXPRESSION_AS_JAVA_SOURCE_CODE`，各 2048 容量） |
| i2f.turbo:i2f-std-const | compile | false | `StdConst.RUNTIME_TMP_DIR`（默认 `./_tmp/`）作为临时 class 输出的根路径 |
| org.projectlombok:lombok | provided | - | **声明未用**——两源文件均无 lombok 注解 |

> 注意：`javax.tools.JavaCompiler` 来自 JDK 而非 Maven 坐标，运行期依赖 `JAVA_HOME` 指向完整 JDK（含 `tools.jar`），JRE-only 环境将因 `ToolProvider.getSystemJavaCompiler()` 返回 `null` 而失败。

## 模块设计

### 三级递进方法体系

```
文件级:      compileAsFile(source, fileName, outputDir) → Map<className, File>
  ↑
类级:        compileAsClass(source, fileName, outputDir) → Map<Class<?>, File>
              compileClass(source, fileName) → Set<Class<?>>            (自动临时目录 + 清理 + 缓存)
                findCompileClass(source, fileName, fullClassName) → Class<?>
  ↑
求值级:      evaluateExpression(expression, root, [imports], [methods]) → Object
              compileCallRandomClass(source, methodName, args) → Object
                compileCall(source, fileName, className, methodName, args) → Object
```

### 表达式包装 DSL

以三个 `###` 前缀标签分隔用户表达式：

```
[import 语句...]
###import
[自定义方法...]
###method
[表达式主体（入参为 $root，应含 return 语句）]
```

- 缺失 `return` 时：自动定位最后一行非空/非花括号代码，在最后一个 `;` 后插入 ` return ` 前缀。
- 类名占位符 `###class`：`compileCallRandomClass` 替换为 `RC` + UUID 随机串，避免同名冲突。
- 自动注入 `DEFAULT_IMPORTS`（`java.lang.*`/`java.util.*`/`java.util.concurrent.*`/`java.io.*`/`java.time.*`/`java.math.*`/`java.text.*`/`java.net.*`/`java.security.*`/`java.util.stream.*`/`java.util.function.*`/`java.lang.reflect.*`/`java.util.concurrent.atomic.*` 共 13 条）。

### 四级 LRU 缓存策略

| 缓存 | key | value | 用途 |
|---|---|---|---|
| `CACHE_COMPILE_CLASS` | `文件名##源码全文` | `Set<Class<?>>` | 缓存完整编译结果 |
| `CACHE_FIND_COMPILE_CLASS` | `全类名##文件名##源码` | `Class<?>` | 缓存特定类的查找 |
| `CACHE_RANDOM_CLASS_NAME` | `源码全文` | `String` | 缓存随机类名（UUID 生成） |
| `CACHE_WRAP_EXPRESSION_AS_JAVA_SOURCE_CODE` | `类名##表达式##附加导入##附加方法` | `String` | 缓存包装后的完整 Java 源码 |

所有缓存方法为「check → 命中直接返回」+「未命中 `synchronized` 加锁计算」，**非 computeIfAbsent 模式**。

## 模块目的

- 在 JDK 标准编译 API 之上提供**开箱即用的运行时 Java 编译与执行**能力，消除 `javax.tools.JavaCompiler` 的手动文件管理器/编译单元/输出流/类加载器等繁琐步骤。
- 通过 **DSL 标签系统** 把任意表达式映射为完整 Java 类——用户只需写 `return $root + "/" + new Date();` 即可求值，无需关心包名、import 声明、类封装与异常签名。
- 通过 **四级 LRU 缓存** 为重复表达式消除反复编译开销（首次编译后直接命中缓存）。
- 作为 `i2f-extension-xproc4j`（业务流 Java 脚本节点）、`i2f-jdbc-proxy-xml`（MyBatis 表达式）、`i2f-extension-agent-javassist`（运行期 REPL）的「嵌入式 Java 运行时」底座。

## 模块功能

1. **内存编译到文件**：`compileAsFile` 把 Java 源码编译为 `.class` 文件写到指定输出目录
2. **内存编译到类加载**：`compileAsClass`/`compileClass` 编译后立即用 `URLClassLoader` 加载为 `Class<?>`，自动清理临时文件
3. **按全限定名查找编译类**：`findCompileClass` 在编译结果集中按名检索
4. **编译并调用方法**：`compileCall` 编译后自动匹配并反射执行指定方法（静态方法直接调，实例方法无参构造后调）
5. **随机类名编译调用**：`compileCallRandomClass` 用 `###class` 占位符自动生成唯一类名后编译调用
6. **表达式快速求值**：`evaluateExpression(expression, root)` 包装 → 编译 → 调用 `_call($root)` 三步合一
7. **表达式源码包装**：`wrapExpressionAsJavaSourceCode` 将表达式 + import + 自定义方法按模板拼装为完整 `.java` 文件内容
8. **自动 return 补全**：当表达式主体不含 `return` 时自动在最后语句末尾注入 `return` 前缀
9. **四级 LRU 缓存**：对编译结果、类查找、随机类名、源码包装四大环节各设 2048 容量缓存

## 模块主要使用方法

### 编译并调用任意方法

```java
String sourceCode = "public class ###class { public Object call(Object arg) { return \"Hello, \" + arg; } }";
Object ret = MemoryCompiler.compileCallRandomClass(sourceCode, "call", "World");
// ret = "Hello, World"
```

### 表达式快速求值

```java
// 简单表达式
Object ret = MemoryCompiler.evaluateExpression("return $root + \"/\" + new Date();", "hello");

// 带额外 import + 自定义方法的表达式
String expr = 
    "import java.util.Date;\n" +
    "###import\n" +
    "public String format(Date date){ return new java.text.SimpleDateFormat(\"yyyy-MM-dd\").format(date); }\n" +
    "###method\n" +
    "return $root + \"/\" + format(new Date());";
Object ret = MemoryCompiler.evaluateExpression(expr, "hello", "import java.text.*;", null);
```

### 获取包装后的完整源码（调试用）

```java
String expression = "return $root + \"/\" + new Date();";
String javaSource = MemoryCompiler.wrapExpressionAsJavaSourceCode(expression, "TestExpr");
// 输出为可查看的完整 Java 文件
```

### 编译并加载自定义类

```java
String source = "package com.example;\npublic class Calc { public static int add(int a, int b) { return a + b; } }";
Class<?> clazz = MemoryCompiler.findCompileClass(source, "Calc.java", "com.example.Calc");
Method m = clazz.getMethod("add", int.class, int.class);
int result = (int) m.invoke(null, 1, 2);
```

## 模块特性总结

- **全模块单一门面**：仅 1 个 `MemoryCompiler` 类（551 行）、1 个 `TestCompiler` demo（38 行），零子包、零接口、零抽象
- **三级递进 API**：文件编译 → 类加载 → 表达式求值，覆盖从「编译到磁盘」到「一行字符串求值」全谱段
- **表达式 DSL 标签系统**：`###import` / `###class` / `###method` 三标签实现「import 分离 + 自定义方法 + 自动类名」的声明式表达式编写
- **智能 return 补全**：自动检测表达式末尾是否含 `return` 语句，无则自动注入
- **自动 import 注入**：预设 13 条常用 JDK 包 `import`，用户无需自行声明常见类型
- **四级 LRU 缓存**：消除重复编译开销
- **四个内部依赖均真实使用**：区别于 std 家族常见的冗余 lombok 声明
- **需要完整 JDK**：依赖 `javax.tools.JavaCompiler`（`tools.jar`），JRE-only 环境不可用

## 已知实现瑕疵

### 1. 运行时必须完整 JDK（非 JRE）

`ToolProvider.getSystemJavaCompiler()` 仅在完整的 JDK（含 `tools.jar` / `java.compiler` 模块）可用。在瘦 JRE 或 `jlink` 定制镜像中返回 `null`，`compileAsFile` 会在第 54 行抛出 NPE——但无向外的友好提示。

### 2. 临时目录崩溃残留

`compileClass0` L176 创建的临时目录（`./_tmp/memory-compiler/classes/{uuid}/`）在 finally 块中由 `FileUtil.delete` 清理。若 JVM 被 `kill -9`、断电或 `FileUtil.delete` 内部权限/锁冲突异常被吞，残留目录累积不清理。无守护线程或 JVM shutdown hook 保障。

### 3. 缓存 key 膨胀风险

四级缓存的 key 包含「完整源码全文」或「完整表达式」。大量不同的长表达式持续涌入时，即便 LRU 驱逐（2048 容量），每项 key 的字符串拷贝+哈希计算仍有高 CPU 与堆外内存（字符串 intern）开销。

### 4. `synchronized` + 双重检查非原子

缓存模式为「`get` → 命中返回 / 未命中 → `synchronized` → 再次 `get` → 计算 → `put`」。非 `ConcurrentHashMap` 的 `computeIfAbsent` 原子模式，多线程竞争时最后写入者覆盖而非首个计算者保留，可能对**不同 key** 重复计算。

### 5. 每次求值编译全量类

`evaluateExpression` 每次调用生成一个包含完整 `_call` 方法的 Java 类（即便命中缓存类加载，也是加载预编译好的 Class），相比解释型 EL 引擎（OGNL/SpEL/MVEL）仍有数百毫秒级首次延迟与 PermGen/Metaspace 类加载开销（LRU 缓存缓解但未消除）。

### 6. 方法匹配限于无参构造实例

`compileCall` L235 用 `ReflectResolver.matchExecMethod` 匹配方法，对实例方法假定存在无参构造器（`clazz.newInstance()` 在 Java 9+ 被标记 `deprecated`），不含参构造的类将报 `InstantiationException`。

### 7. `lombok` 冗余声明

`pom.xml` 声明了 `lombok` provided 依赖，但 `MemoryCompiler.java` 与 `TestCompiler.java` 均无任何 `@Data`/`@Slf4j` 等 lombok 注解。属纯冗余的 pom 配置。

## 下游与关联

### 直接消费方（经 `import i2f.compiler.*` 确认）

| 模块 | 消费类 | 使用方式 |
|---|---|---|
| `i2f-extension-xproc4j` | `LangEvalJavaNode` | `compileCall`/`findCompileClass` 执行 Java 脚本节点（流程引擎中注入 import + 自定义方法） |
| `i2f-extension-xproc4j` | `ScriptPreloadEventListener` | 事件监听器中预编译/预加载脚本 |
| `i2f-extension-xproc4j` | `DefaultGrammarReporter` | 语法报告器中使用编译能力 |
| `i2f-jdbc-proxy-xml` | `MybatisMapperInflater` | `evaluateExpression` 实现 MyBatis 映射 XML 中的表达式求值 |
| `i2f-extension-agent-javassist` | `LocalFileExpressionEvaluator` | 运行期轮询 `expression.java` 文件，`evaluateExpression` 求值并注入结果到 `AgentContextHolder`（活体 REPL） |

### POM 声明依赖但无 direct import

| 模块 | 说明 |
|---|---|
| `i2f-jdbc-procedure` | 作为 `i2f-extension-xproc4j` 的父模块/依赖基础，pom 声明了 `i2f-compiler` 但无源文件直接 import |
| `i2f-jdk-all` | 聚合模块，仅做坐标汇总 |