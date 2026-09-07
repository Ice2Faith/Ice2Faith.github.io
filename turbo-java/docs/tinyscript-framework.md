# TinyScript 表达式引擎 Wiki

> **演进提示**: TinyScript 已被 Funic 完全超越。Funic 是 TinyScript
> 的增强版本和未来替代方案，语法更简洁（变量直接访问无需 `${}`）、特性更丰富（Lambda、go/await 异步、import、沙箱等）。在 XProc4J
> 中，Funic 将逐渐演变并最终完全替代 TinyScript。**新项目建议直接使用 [Funic](funic-framework.md)**。

## 概述

TinyScript 是一个基于 ANTLR4 构建的轻量级嵌入式脚本引擎，主要用于提供嵌套函数调用和多语句执行能力。它作为 XProc4J
框架的核心脚本语言之一，广泛应用于 JDBC 存储过程编排中的表达式计算。

**Funic 是 TinyScript 的增强超集和未来替代**
，提供了更简洁的语法和更丰富的语言特性。详见 [Funic 引擎 Wiki](funic-framework.md)
和 [演进指南](funic-framework.md#tinyscript--funic-演进指南)。

- **引擎名称**: TinyScript
- **实现模块**: `i2f-extension/i2f-extension-antlr4`
- **核心包名**: `i2f.extension.antlr4.script.tiny`
- **语法定义**: ANTLR4 文法文件 `TinyScript.g4`（397 行）
- **文件扩展名**: `.tis`
- **IDE 支持**: IDEA 插件（`i2f-jdbc-procedure-idea-plugin`），提供语法高亮和代码补全

## 核心设计

- 基于 ANTLR4 生成词法分析器（Lexer）和语法分析器（Parser）
- 使用 Visitor 模式遍历语法树执行脚本
- 暴露 `TinyScript.script()` 静态方法作为入口
- 基于根上下文（context）进行变量读写
- 支持 LRU 缓存语法树，提升重复脚本执行性能

### 核心 API

```java
// 基础调用
public static Object script(String formula, Object context);

// 带自定义解析器
public static Object script(String formula, Object context, TinyScriptResolver resolver);

// 从文件执行
public static Object script(File scriptFile, Object context);

// 完整参数（含文件名、行偏移、解析器）
public static Object script(String formula, Object context,
                            String scriptFileName, int scriptLineOffset,
                            TinyScriptResolver resolver);
```

- `formula` — 脚本表达式内容
- `context` — 根上下文，通常是 Map 或普通 Java 对象，脚本通过 `${}` 读写其属性
- 返回最后一条语句的执行结果

## 模块依赖

### i2f-extension-antlr4 模块

| 依赖               | 说明                                         |
|------------------|--------------------------------------------|
| `i2f-reflect`    | 反射工具，用于动态类加载和方法调用                          |
| `i2f-convert`    | 类型转换工具                                     |
| `i2f-typeof`     | 类型判断工具                                     |
| `i2f-match`      | 正则匹配工具                                     |
| `i2f-invokable`  | 方法调用抽象（IMethod）                            |
| `i2f-mixins`     | Mixin 扩展（TinyScriptFunctions 继承 AllMixins） |
| `i2f-jvm`        | JVM 工具（调试状态检测）                             |
| `antlr4-runtime` | 4.13.2（provided/optional）                  |

### 在 XProc4J 中的使用

TinyScript 作为 XProc4J 框架的 6 种脚本语言之一，通过以下类集成。**注意：Funic 将逐渐替代
TinyScript，新存储过程推荐使用 `<lang-eval-funic>` 标签。**

| 类                              | 说明                            |
|--------------------------------|-------------------------------|
| `LangEvalTinyScriptNode`       | TinyScript 语言执行节点             |
| `ProcedureTinyScriptResolver`  | 面向存储过程的 TinyScriptResolver 实现 |
| `ExecContextMethodProvider`    | 执行上下文方法提供者（18 个方法）            |
| `ExecutorMethodProvider`       | 执行器方法提供者（14 个方法）              |
| `ProcedureFunctionCallContext` | 过程函数调用上下文                     |

## 源文件结构

### 运行时引擎（i2f-extension-antlr4）

```
i2f-extension-antlr4/src/main/java/i2f/extension/antlr4/script/tiny/
├── rule/
│   ├── TinyScript.g4              -- ANTLR4 文法定义（397行）
│   ├── TinyScriptLexer.java       -- 生成的词法分析器
│   ├── TinyScriptParser.java      -- 生成的语法分析器
│   ├── TinyScriptVisitor.java     -- 生成的 Visitor 接口
│   ├── TinyScriptBaseVisitor.java -- Visitor 基类
│   ├── TinyScriptListener.java    -- Listener 接口
│   └── TinyScriptBaseListener.java-- Listener 基类
├── impl/
│   ├── TinyScript.java            -- 核心入口类（250行）
│   ├── TinyScriptResolver.java    -- 解析器接口（44行）
│   ├── DefaultTinyScriptResolver.java -- 默认解析器实现（705行）
│   ├── TinyScriptVisitorImpl.java -- 语法树执行 Visitor（3147行）
│   ├── TinyScriptErrorStrategy.java -- 错误处理策略
│   ├── DefaultAntlrErrorListener.java -- 默认错误监听器
│   ├── context/
│   │   ├── DefaultFunctionCallContext.java -- 函数调用上下文
│   │   ├── TinyScriptFunctions.java       -- 内建函数接口（继承 AllMixins）
│   │   └── TinyScriptMethod.java          -- 方法封装
│   ├── debugger/
│   │   └── TinyScriptDebugBridgeReporter.java -- 调试桥接报告器
│   └── exception/
│       ├── TinyScriptException.java       -- 基础异常
│       ├── TinyScriptControlException.java -- 控制流异常基类
│       ├── TinyScriptEvaluateException.java -- 求值异常
│       ├── TinyScriptParseException.java    -- 解析异常
│       ├── TinyScriptThrowException.java    -- throw 语句异常
│       └── impl/
│           ├── TinyScriptBreakException.java     -- break 控制
│           ├── TinyScriptContinueException.java  -- continue 控制
│           └── TinyScriptReturnException.java    -- return 控制
```

### IDEA 插件（i2f-jdbc-procedure-idea-plugin）

```
tinyscript/
├── TinyScriptLanguage.java    -- 语言定义
├── TinyScriptFileType.java    -- 文件类型（.tis）
├── TinyScriptConsts.java      -- 常量（语言ID、图标、关键字集）
├── grammar/
│   ├── parser/
│   │   ├── TinyScriptParser.java    -- 插件用语法分析器
│   │   ├── _TinyScriptLexer.java    -- 插件用词法分析器
│   │   └── psi/
│   │       ├── TinyScriptTypes.java -- PSI 元素类型
│   │       └── elements/            -- 30+ PSI 元素类
│   └── _TinyScriptLexer.flex       -- JFlex 词法定义
└── (资源) assets/tinyscript/tinyscript.svg -- 语言图标
```

## 数据类型

### 基础类型

| 类型      | 写法示例                                    | 说明                |
|---------|-----------------------------------------|-------------------|
| int     | `1`, `123`, `0xabc`, `0t754`, `0b10110` | 默认整型，支持 16/8/2 进制 |
| long    | `1L`, `0xabcL`                          | 后缀 L/l            |
| double  | `1.1`, `1.1e6`                          | 默认浮点，支持科学计数法      |
| float   | `1.1F`                                  | 后缀 F/f            |
| boolean | `true`, `false`                         | 区分大小写             |
| null    | `null`                                  | 区分大小写             |
| string  | `"abc"`, `'abc'`                        | 支持单/双引号，支持转义      |
| class   | `int.class`, `java.util.Map.class`      | 类型字面值             |

### 特殊字符串

| 类型        | 语法                                       | 说明                 |
|-----------|------------------------------------------|--------------------|
| 模板字符串     | `R"abc ${count} def"`                    | R 前缀，支持 `${}` 变量插值 |
| 多行字符串     | `` ```trim.align.render `` ... `` ``` `` | 三反引号/三双引号，支持特性链    |
| 多行字符串(引号) | `"""trim.align"""` ... `"""`             | 三双引号形式             |

多行字符串特性：

- `trim` — 去除首尾空白
- `align` — 只保留每行第一个 `|` 之后的内容
- `render` — 进行模板变量渲染
- 特性通过 `.` 连接，从左至右依次执行

### 复杂数据类型（JSON）

支持 JSON 风格的对象和数组构建，内部转换为 `LinkedHashMap` 和 `ArrayList`：

```shell
[
  {
    name: "xxx",
    "age": 12,
    roles: ["admin","logger",3,true],
    image: ${images.defaultImage},
    status: decode(${user.status},1,"正常",0,"禁用"),
    platform.prefer: "windows"
  }
];
```

## 语法参考

### 语句与分隔

- 语句之间使用分号 `;` 分隔
- 脚本返回最后一条语句的执行结果

### 取值语句

```shell
${user.name}              // 标准取值
${user.roles[0].name}     // 嵌套路径
$!{user.nickName}         // null 安全取值（null 返回空字符串）
```

### 赋值语句

| 操作符  | 说明                  | 等价写法                |
|------|---------------------|---------------------|
| `=`  | 直接赋值                | —                   |
| `+=` | 加后赋值                | `a = a + b`         |
| `-=` | 减后赋值                | `a = a - b`         |
| `*=` | 乘后赋值                | `a = a * b`         |
| `/=` | 除后赋值                | `a = a / b`         |
| `%=` | 取模后赋值               | `a = a % b`         |
| `?=` | 空赋值（左侧为 null 时才赋值）  | `if(a==null){a=b;}` |
| `.=` | 替换赋值（左侧非 null 时才赋值） | `if(a!=null){a=b;}` |

### 解包语句

```shell
#{name:userName, age:userInfo.age, status} = getUserInfo();
// 等价于：
// tmp = getUserInfo();
// name = ${tmp.userName};
// age = ${tmp.userInfo.age};
// status = ${tmp.status};
```

### 运算符

#### 前置操作符

| 操作符         | 说明   |
|-------------|------|
| `!` / `not` | 逻辑取反 |
| `-`         | 取负数  |

#### 后置操作符

| 操作符 | 说明          |
|-----|-------------|
| `%` | 百分数（除以 100） |

#### 双目运算符

| 操作符                            | 说明     | 别名                |
|--------------------------------|--------|-------------------|
| `>=`                           | 大于等于   | `gte`             |
| `<=`                           | 小于等于   | `lte`             |
| `>`                            | 大于     | `gt`              |
| `<`                            | 小于     | `lt`              |
| `==`                           | 相等     | `eq`              |
| `!=`                           | 不等于    | `ne`, `neq`, `<>` |
| `&&`                           | 逻辑与    | `and`             |
| `\|\|`                         | 逻辑或    | `or`              |
| `in`                           | 元素在其中  | —                 |
| `notin`                        | 元素不在其中 | —                 |
| `as` / `cast`                  | 类型转换   | —                 |
| `is` / `instanceof` / `typeof` | 类型判断   | —                 |
| `+` `-` `*` `/` `%`            | 算术运算   | —                 |

#### 三元运算符

```shell
${cnt} > 1 ? "ok" : null;
```

### 管道函数调用链

使用 `|>` 管道操作符，将前一个值作为函数的第一个参数：

```shell
// 嵌套调用
substr(trim(a.user().name()), 0, 2);

// 管道链式调用
${a} |> ::user() |> ::name() |> trim() |> substr(0, 2);
```

管道函数形式：

- `函数名(参数列表)` — 普通管道函数
- `类名.函数名(参数列表)` — 静态管道函数
- `::函数名(参数列表)` — 自身调用形式（调用前一个值的方法）

### 中括号取值表达式

```shell
${user}["name"]       // 对象属性访问
${map}['age']         // Map 取值
${list}[1]            // List/数组下标
${iter}[${v_index}]   // 变量下标
```

### 控制流语句

#### if-else

```shell
if(${num} > 0){
    ok = 1;
} elif(${role}){
    ok = 2;
} else {
    ok = 3;
};
```

> 注意：`else if` 可用别名 `elif`；条件值宽泛（null/空字符串/空Map/空Collection 均为 false）

#### foreach

```shell
foreach(item : [1,2,3,4,5]){
  sum = ${sum} + ${item};
};
```

#### for

```shell
for(i = 0; ${i} < 10; i = ${i} + 1){
  sum = ${sum} + ${i};
};
```

#### while / do-while

```shell
while(${i} < 10){ i = ${i} + 1; };
do { i = ${i} + 1; } while(${i} < 10);
```

#### return / break / continue

```shell
return;          // 返回 null
return ${sum};   // 返回值
break;           // 跳出循环
continue;        // 继续下一次循环
```

#### try-catch-finally

```shell
try {
  null;
} catch(NullPointerException | SQLException e) {
  null;
} finally {
  null;
};
```

#### throw

```shell
throw new RuntimeException("msg", ${e});
```

### debugger 调试语法

```shell
debugger;                              // 无条件断点
debugger entry1;                       // 带标签断点
debugger (${count} == null);           // 带条件断点
debugger user.loop (${item} == null);  // 带标签和条件
```

断点标签：由字母数字下划线组成，可分多段用 `.` 分隔。

### 静态变量/枚举访问

```shell
@java.sql.Types.VARCHAR           // 访问静态变量
java.sql.Types@VARCHAR            // 等价写法
@java.sql.JDBCType.VARCHAR        // 访问枚举值
```

### 创建对象

```shell
new String("xxx");
new Date();
new org.apache.User(1L, "xxx", ${status});
```

> 常用包（java.lang/java.util/java.time 等）可使用简短类名

### 函数调用

```shell
String.valueOf(1);                           // 静态方法
org.apache.Test.run("xxx", true);            // 全限定调用
${user}.getName().length();                  // 链式调用
render(str: "123", regex: "\\d+", replacement: "true")  // 具名参数
```

### 用户自定义函数

```shell
func factor(in_num, in_level){
    if(${in_num} <= 1){
        return 1;
    };
    return ${in_num} * factor(${in_num} - 1, ${in_level} + 1);
};
v_ret = factor(${v_num}, 0);
```

- 函数有独立作用域，通过 `global` 变量访问外层上下文
- `global` 无论递归多少层，始终指向最外层全局上下文

### 内建函数

- `eval(script)` — 将字符串作为 TinyScript 脚本执行，共享上下文
- `String.join()` / `String.format()` — String 静态方法
- `Integer.parseInt()` / `Long.parseLong()` 等 — 数值解析方法
- `Math.*` — 数学函数（排除 copy*/next*）
- `Thread.*` — 线程方法（排除 sleep*/yield*）
- `System.*` — 系统方法
- `println()` / `print()` — 输出方法（System.out）
- `Runtime.*` — 运行时方法（exec/load/gc/available/memory 等）

## 扩展点

### TinyScriptResolver 接口

核心扩展接口，允许自定义脚本执行行为：

| 方法                                                  | 说明               |
|-----------------------------------------------------|------------------|
| `debug(boolean)`                                    | 开关调试模式           |
| `debugLog(Supplier)`                                | 调试日志输出           |
| `debugBridge(String, int, Supplier)`                | 调试桥接（文件名、行号、变量）  |
| `openDebugger(Object, String, String)`              | 打开调试器（上下文、标签、条件） |
| `setValue(Object, String, Object)`                  | 设置上下文变量值         |
| `getValue(Object, String)`                          | 获取上下文变量值         |
| `toBoolean(Object, Object)`                         | 值转 boolean       |
| `resolveDoubleOperator(...)`                        | 双目运算符处理          |
| `resolvePrefixOperator(...)`                        | 前置运算符处理          |
| `resolveSuffixOperator(...)`                        | 后置运算符处理          |
| `resolveFunctionCall(...)`                          | 函数调用处理           |
| `renderString(Object, String)`                      | 字符串模板渲染          |
| `multilineString(Object, String, List)`             | 多行字符串处理          |
| `loadClass(Object, String)`                         | 类加载              |
| `getValueBySquareBracketExpression(Object, Object)` | 中括号取值处理          |

### DefaultTinyScriptResolver

默认实现类，继承此类可只修改特定逻辑：

- 支持所有标准运算符
- 数值运算使用 `BigDecimal`（精度 20 位，HALF_UP 舍入）
- 支持日期类型与数值的加减运算
- 支持自定义内建函数注册（`beforeFunctionCall` 钩子）
- 支持自定义多行字符串特性（`dispatchMultilineFeature` 钩子）

### 自定义处理器示例

```java
// 与 Spring 集成的示例
public static Object evalTinyScript(String script, Object context,
                                     ApplicationContext applicationContext) {
    TinyScriptResolver resolver = new SpringApplicationContextTinyScriptResolver(applicationContext);
    return TinyScript.script(script, context, resolver);
}
```

### 注册内建函数

```java
// 注册自定义方法
TinyScript.registryBuiltinMethod(Method method);

// 按类批量注册静态方法
TinyScript.

registryBuiltMethodByStaticMethod(Class<?> clazz, Predicate<Method> filter);

// 按实例批量注册方法
TinyScript.

registryBuiltMethodByInstanceMethod(Object object, Predicate<Method> filter);
```

## 特别注意

- **不支持自然数学运算优先级**（先乘除后加减），涉及混合运算请使用括号
- 所有控制语句（if/foreach/for/while/try 等）都需要以分号 `;` 结尾
- 条件判断为宽泛值：null、空字符串、空 Map、空 Collection 均视为 false
- 数值运算统一使用 BigDecimal 保证精度
- 脚本解析结果（语法树）会被 LRU 缓存（容量 4096）

## IDEA 插件支持

TinyScript 在 `i2f-jdbc-procedure-idea-plugin` 中拥有完整的 IDE 支持：

| 特性     | 说明                                     |
|--------|----------------------------------------|
| 语言注册   | `TinyScriptLanguage`（ID: "TinyScript"） |
| 文件类型   | `.tis` 扩展名                             |
| 语法高亮   | 基于 JFlex + BNF 的完整词法/语法分析              |
| 代码补全   | 关键字自动补全（从 PSI 类型动态提取）                  |
| PSI 元素 | 30+ 种 PSI 元素类型（表达式、语句、常量等）             |
| 图标     | `tinyscript.svg`                       |

## 官方文档

TinyScript 的完整语法文档位于：

| 文档               | 路径                                                                                                                    |
|------------------|-----------------------------------------------------------------------------------------------------------------------|
| TinyScript 语法白皮书 | `i2f-jdk/i2f-jdbc-procedure/src/main/resources/assets/std/TinyScript.md`                                              |
| ANTLR4 文法文件      | `i2f-extension/i2f-extension-antlr4/src/main/java/.../rule/TinyScript.g4`                                             |
| IDEA 插件 BNF      | `i2f-tools/i2f-jdbc-procedure-idea-plugin/src/main/resources/assets/tinyscript/TinyScript.bnf`                        |
| IDEA 插件 Flex     | `i2f-tools/i2f-jdbc-procedure-idea-plugin/src/main/java/.../tinyscript/grammar/_TinyScriptLexer.flex`                 |
| Funic 引擎 Wiki    | [funic-framework.md](funic-framework.md) — 增强替代引擎 Funic 的完整 Wiki（含 [演进指南](funic-framework.md#tinyscript--funic-演进指南)） |
