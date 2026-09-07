# Funic 脚本引擎 Wiki

## 概述

Funic（全称：Functional Logic）是一个基于 ANTLR4 构建的函数逻辑驱动的嵌入式脚本引擎，**是 TinyScript 的增强版本和未来替代方案
**。Funic 在 TinyScript 的基础上提供了更丰富的语言特性，包括 Lambda 表达式、异步并发（go/await）、用户自定义函数、import
导入、synchronized 同步块、沙箱执行等高级能力。

> **演进关系**: Funic 是 TinyScript 的增强超集，两者同属 `i2f-extension-antlr4` 模块。在 XProc4J 框架中，Funic 将逐渐演变并最终完全替代
> TinyScript。新项目建议直接使用 Funic。

- **引擎名称**: Funic（Functional Logic）
- **定位**: TinyScript 的增强版本与未来替代
- **实现模块**: `i2f-extension/i2f-extension-antlr4`
- **核心包名**: `i2f.extension.antlr4.script.funic`
- **语法定义**: ANTLR4 文法文件 `Funic.g4`（575 行）
- **文件扩展名**: `.fic`
- **IDE 支持**: IDEA 插件（`i2f-jdbc-procedure-idea-plugin`），提供语法高亮和代码补全
- **官方文档**: `i2f-extension-antlr4/.../funic/rule/Funic.md`（1771 行）及 `i2f-jdbc-procedure/.../assets/std/Funic.md`

## 核心设计

- 基于 ANTLR4 生成词法分析器（Lexer）和语法分析器（Parser）
- 使用 Visitor 模式遍历语法树执行脚本
- 暴露 `Funic.script()` 静态方法作为入口
- 基于根上下文（context）进行变量读写（通过 `变量路径` 语法直接访问，无需 `${}` 包裹）
- 支持 LRU 缓存语法树（`TREE_MAP`，容量 4096），提升重复脚本执行性能
- 支持全局方法注册（`GLOBAL_METHODS`）、导入包列表（`IMPORT_PACKAGES`）
- 提供 `FunicResolver` 扩展点，支持沙箱模式（`SandboxFunicResolver`）

### 核心 API

```java
// 基础调用
public static Object script(String formula, Object context);

// 带自定义解析器
public static Object script(String formula, Object context, FunicResolver resolver);

// 从文件执行
public static Object script(File scriptFile, Object context);

// 完整参数（含文件名、行偏移、解析器）
public static Object script(String formula, Object context,
                            String scriptFileName, int scriptLineOffset,
                            FunicResolver resolver);

// 使用预解析的语法树
public static Object script(FunicParser.RootContext tree, Object context,
                            String scriptFileName, int scriptLineOffset,
                            FunicResolver resolver);
```

- `formula` — 脚本表达式内容
- `context` — 根上下文，通常是 Map 或普通 Java 对象
- 返回最后一条语句的执行结果

### 与 TinyScript 的主要区别

Funic 是 TinyScript 的增强超集，下表展示了两者的差异。在 XProc4J 中，Funic 将逐渐替代 TinyScript。

| 特性           | TinyScript（旧） | Funic（新/替代）               |
|--------------|---------------|---------------------------|
| 变量访问语法       | `${变量路径}`     | `变量路径`（直接访问）              |
| 文件扩展名        | `.tis`        | `.fic`                    |
| Lambda 表达式   | 不支持           | 支持 `(参数) -> { 函数体 }`      |
| 异步并发         | 不支持           | `go`/`await` 语句           |
| 用户自定义函数      | 不支持           | `func`/`def` 声明           |
| import 导入    | 不支持           | `import 包名`               |
| synchronized | 不支持           | `synchronized(锁) { ... }` |
| 沙箱模式         | 不支持           | `SandboxFunicResolver`    |
| for-range 循环 | 不支持           | `for(i 0...10)`           |
| 类型转换运算符      | 不支持           | `值 as 类型`                 |
| 严格相等         | 不支持           | `===`/`!==`/`teq`/`tneq`  |
| in/not in    | 不支持           | `值 in 集合`/`值 not in 集合`   |
| 解包语法         | `#{}`         | `#{}` + 展开运算符 `...`       |
| 全局方法注册       | 通过 Mixin      | `Funic.registryMethods()` |

## 模块依赖

### i2f-extension-antlr4 模块

| 依赖               | 说明                            |
|------------------|-------------------------------|
| `i2f-reflect`    | 反射工具，用于动态类加载和方法调用             |
| `i2f-convert`    | 类型转换工具（ObjectConvertor）       |
| `i2f-typeof`     | 类型判断工具（TypeOf）                |
| `i2f-match`      | 正则匹配工具（RegexUtil）             |
| `i2f-invokable`  | 方法调用抽象（IMethod）               |
| `i2f-mixins`     | Mixin 扩展（AllMixins，默认注册为全局函数） |
| `i2f-iterator`   | 迭代器工具                         |
| `i2f-lru-map`    | LRU 缓存（TREE_MAP）              |
| `i2f-reference`  | 引用封装（Reference）               |
| `i2f-io-stream`  | 流工具（读取脚本文件）                   |
| `antlr4-runtime` | 4.13.2（provided/optional）     |

### 在 XProc4J 中的集成

Funic 作为 XProc4J 框架的 6 种脚本语言之一，通过以下类集成。**Funic 是未来推荐的脚本引擎，将逐渐替代 TinyScript。**

| 类                                   | 说明                                   |
|-------------------------------------|--------------------------------------|
| `LangEvalFunicNode`                 | Funic 语言执行节点（`<lang-eval-funic>` 标签） |
| `ProcedureFunicResolver`            | 面向存储过程的 FunicResolver 实现             |
| `ProcedureFunicFunctionCallContext` | 过程函数调用上下文                            |
| `FunicJdbcProcedureExecutor`        | Funic 增强的 JDBC 过程执行器                 |

#### SpringBoot 自动配置切换

在 `i2f-springboot-xproc4j-starter` 中，通过 `xproc4j.enable-funic` 配置项一键切换执行器：

```yaml
# application.yml
xproc4j:
  enable-funic: true   # 启用 Funic 执行器，完全替代默认的 OGNL 引擎
```

```java
// SpringContextJdbcProcedureExecutorAutoConfiguration 核心逻辑
if(jdbcProcedureProperties.isEnableFunic()){
ret =new

FunicJdbcProcedureExecutor(context, iEnvironment, namingContext);
}else{
ret =new

DefaultJdbcProcedureExecutor(context, iEnvironment, namingContext);
}
```

- `enableFunic = false`（默认）：使用 `DefaultJdbcProcedureExecutor`，基于 OGNL 表达式引擎
- `enableFunic = true`：使用 `FunicJdbcProcedureExecutor`，将 OGNL 引擎整体替换为 Funic 脚本引擎
- **这代表当前阶段 Funic 已具备完全替代默认执行器的能力**，无需修改任何业务代码，仅通过配置即可完成切换

## 源文件结构

### 运行时引擎（i2f-extension-antlr4）

```
i2f-extension-antlr4/src/main/java/i2f/extension/antlr4/script/funic/
├── rule/
│   ├── Funic.g4                 -- ANTLR4 文法定义（575行）
│   ├── Funic.md                 -- 完整语法文档（1771行）
│   ├── FunicLexer.java          -- 生成的词法分析器
│   ├── FunicParser.java         -- 生成的语法分析器（6238行）
│   ├── FunicVisitor.java        -- 生成的 Visitor 接口（477行）
│   ├── FunicBaseVisitor.java    -- Visitor 基类
│   ├── FunicListener.java       -- Listener 接口
│   ├── FunicBaseListener.java   -- Listener 基类
│   ├── Funic.tokens             -- 词法符号定义
│   └── Funic.interp             -- 解释器数据
├── lang/
│   ├── Funic.java               -- 核心入口类（185行）
│   ├── annotations/
│   │   └── FunicFunction.java   -- 函数注解（用于别名映射）
│   ├── context/
│   │   └── FunicFunctionCallContext.java -- 函数调用上下文接口
│   ├── debugger/
│   │   └── FunicDebugBridgeReporter.java -- 调试桥接报告器
│   ├── errors/
│   │   ├── DefaultAntlrErrorListener.java -- ANTLR 错误监听器
│   │   └── DefaultErrorStrategy.java      -- 错误处理策略
│   ├── exception/
│   │   ├── FunicException.java            -- 基础异常
│   │   ├── FunicControlException.java     -- 控制流异常基类
│   │   ├── FunicThrowException.java       -- throw 语句异常
│   │   ├── control/
│   │   │   ├── FunicBreakException.java   -- break 控制
│   │   │   ├── FunicContinueException.java-- continue 控制
│   │   │   └── FunicReturnException.java  -- return 控制
│   │   └── throwable/
│   │       ├── FunicEvaluateException.java -- 求值异常
│   │       ├── FunicParseException.java    -- 解析异常
│   │       ├── FunicRejectException.java   -- 沙箱拒绝异常
│   │       └── FunicThrowDataException.java-- throw 数据异常
│   ├── functions/
│   │   ├── FunicBuiltinFunctions.java -- 内建函数（16个方法）
│   │   └── FunicFunctionHelper.java   -- 函数注册工具类
│   ├── impl/
│   │   └── DefaultFunicVisitor.java   -- 语法树执行 Visitor（3170行）
│   ├── lambda/
│   │   └── FunicLambda.java           -- Lambda 表达式封装
│   ├── method/
│   │   ├── FunicMethod.java           -- 方法封装
│   │   ├── Global2InstanceMethod.java -- 全局函数转实例方法适配
│   │   └── Instance2GlobalMethod.java -- 实例方法转全局函数适配
│   ├── operator/
│   │   ├── DoubleOperatorFunction.java  -- 双目运算符函数接口
│   │   ├── PrefixOperatorFunction.java  -- 前缀运算符函数接口
│   │   └── SuffixOperatorFunction.java  -- 后缀运算符函数接口
│   ├── resolver/
│   │   ├── FunicResolver.java           -- 解析器接口（30个方法）
│   │   ├── FunicSupplier.java           -- Supplier 接口
│   │   └── impl/
│   │       ├── DefaultFunicResolver.java -- 默认解析器实现（1412行）
│   │       ├── SafeFunicResolverProxy.java -- 安全代理（875行）
│   │       └── SandboxFunicResolver.java -- 沙箱解析器（84行）
│   └── value/
│       ├── FunicValue.java              -- 值接口
│       └── impl/                        -- 各种值实现（Boolean/String/Number/...）
```

### IDEA 插件（i2f-jdbc-procedure-idea-plugin）

```
funic/
├── FunicLanguage.java       -- 语言定义（ID: "Funic"）
├── FunicFileType.java       -- 文件类型（.fic）
├── FunicConsts.java         -- 常量（语言ID、图标、关键字集）
├── grammar/
│   ├── parser/
│   │   ├── FunicParser.java       -- 插件用语法分析器（2262行）
│   │   ├── _FunicLexer.java       -- 插件用词法分析器（1612行）
│   │   └── psi/
│   │       ├── FunicTypes.java    -- PSI 元素类型（377行）
│   │       └── elements/          -- 80+ PSI 元素类
│   └── (BNF/Flex 定义)
└── (资源) assets/funic/funic.svg  -- 语言图标
```

## 数据类型

### 基础类型

| 类型      | 写法示例                                                 | 说明                             |
|---------|------------------------------------------------------|--------------------------------|
| int     | `1`, `123`, `1_000_000`, `0xabc`, `0o754`, `0b10110` | 默认整型，支持 16/8/2 进制，支持下划线分隔      |
| long    | `1L`, `0xabcL`, `0o754L`, `0b10110L`                 | 后缀 L/l                         |
| double  | `1.1`, `1.1e6`                                       | 默认浮点，支持科学计数法                   |
| float   | `1.1F`, `1.1e6F`                                     | 后缀 F/f                         |
| boolean | `true`, `false`                                      | 区分大小写                          |
| null    | `null`                                               | 区分大小写                          |
| string  | `"abc"`, `'abc'`                                     | 支持单/双引号，支持转义（\r \n \t \\ 及边界符） |
| class   | `int.class`, `java.util.Map.class`                   | 类型字面值，支持短类名                    |

### 特殊字符串

| 类型        | 语法                                       | 说明                            |
|-----------|------------------------------------------|-------------------------------|
| 模板字符串     | `R"abc ${count} def"`                    | R 前缀，支持 `${}` 变量插值，`$${}` 转义  |
| 多行字符串     | `` ```trim.align.render `` ... `` ``` `` | 三反引号，支持特性链（trim/align/render） |
| 多行字符串(引号) | `"""trim.align"""` ... `"""`             | 三双引号形式                        |

### 复杂数据类型（JSON）

支持 JSON 风格的对象和数组构建，内部转换为 `LinkedHashMap` 和 `ArrayList`。与 TinyScript 不同，Funic 中变量访问不需要 `${}`
包裹：

```shell
[
  {
    name: "xxx",
    "age": 12,
    roles: ["admin","logger",3,true],
    image: images?.defaultImage,
    status: decode(user?.status,1,"正常",0,"禁用"),
    'platform.prefer': "windows"
  }
];
```

## 语法参考

### 语句与分隔

- 语句之间使用分号 `;` 分隔
- 脚本返回最后一条语句的执行结果

### 取值语句

```shell
user.name;                  // 直接路径访问
user.roles[0].name;         // 嵌套路径
user?.name;                 // 安全访问（null 安全运算符 ?.）
$!{user.nickName}          // null 安全取值（null 返回空字符串）
```

### 赋值语句

| 操作符   | 说明                  | 等价写法                |
|-------|---------------------|---------------------|
| `=`   | 直接赋值                | —                   |
| `+=`  | 加后赋值                | `a = a + b`         |
| `-=`  | 减后赋值                | `a = a - b`         |
| `*=`  | 乘后赋值                | `a = a * b`         |
| `/=`  | 除后赋值                | `a = a / b`         |
| `%=`  | 取模后赋值               | `a = a % b`         |
| `?=`  | 空赋值（左侧为 null 时才赋值）  | `if(a==null){a=b;}` |
| `.= ` | 替换赋值（左侧非 null 时才赋值） | `if(a!=null){a=b;}` |

### def 变量声明

```shell
def name = "zhang";
def count = 0;
def result = calculate(x, y);
```

### 解包语句

```shell
#{name:userName, age:detail.age, status} = user;
// 等价于:
// name = user.userName;
// age = user.detail.age;
// status = user.status;
```

### 展开运算符

```shell
// 列表展开
base = [1, 2, 3];
extended = [...base, 4, 5];   // [1, 2, 3, 4, 5]

// 映射展开
base = {a: 1, b: 2};
ext = {...base, c: 3};        // {a:1, b:2, c:3}

// 变量名直接作为键名
x = 10; y = 20;
{x, y};                       // {x: 10, y: 20}
```

### 运算符

#### 前置运算符

| 操作符         | 说明   |
|-------------|------|
| `!` / `not` | 逻辑非  |
| `-`         | 取负   |
| `~`         | 按位取反 |
| `++`        | 前置自增 |
| `--`        | 前置自减 |

#### 后置运算符

| 操作符  | 说明         |
|------|------------|
| `!`  | 阶乘         |
| `%`  | 百分数（除以100） |
| `++` | 后置自增       |
| `--` | 后置自减       |

#### 双目运算符（按优先级从高到低）

| 分类   | 操作符                                     | 说明                |
|------|-----------------------------------------|-------------------|
| 乘除   | `*` `/` `//` `%`                        | 乘、除、整除、取模         |
| 加减   | `+` `-`                                 | 加（支持字符串拼接和日期加减）、减 |
| 移位   | `<<` `>>` `>>>`                         | 左移、有符号右移、无符号右移    |
| 位运算  | `^` `&` `                               | `                 | 按位异或、与、或 |
| 比较   | `>` `gt` `>=` `gte` `<` `lt` `<=` `lte` | 大小比较              |
| 相等   | `==` `eq` `!=` `neq` `<>`               | 宽泛相等（数值类型可互比）     |
| 严格相等 | `teq`(`===`) `tneq`(`!==`)              | 严格相等（类型必须相同）      |
| 包含   | `in` `not in`                           | 元素是否在集合中          |
| 类型   | `instanceof` / `is`                     | 类型判断              |
| 转换   | `as`                                    | 类型转换（`值 as 类型`）   |
| 逻辑   | `&&` / `and` `\|\|` / `or`              | 逻辑与/或（短路求值）       |

### 管道函数调用链

```shell
// 嵌套调用
substr(trim(a.user().name()), 0, 2);

// 管道形式
a |> ::user() |> ::name() |> trim() |> substr(0, 2);

// 无参可省略括号
a |> ::user |> ::name |> trim |> substr(0, 2);

// 结合静态函数
'123' |> ::trim |> int |> String::valueOf |> ::trim |> ::length;

// 动态函数名
v_name = 'int';
'123' |> <v_name> |> String::valueOf;
```

### 控制流

#### if-else

```shell
if(num > 0) {
    ok = 1;
} elif(num > -5) {
    ok = 2;
} else {
    ok = 3;
};
```

#### 循环

```shell
// foreach
for(item : [1,2,3,4,5]) { sum = sum + item; };

// for-i
for(i = 0; i < 10; i = i + 1) { sum = sum + i; };

// for-range（左闭右开）
for(i 0...10) { sum = sum + i; };

// while
while(i < 10) { i = i + 1; };

// do-while
do { i = i + 1; } while(i < 10);
```

#### try-catch-finally

```shell
try {
    risky();
} catch(NullPointerException | SQLException e) {
    println("error:", e);
} finally {
    cleanup();
};

// 省略异常类型，捕获所有
try { risky(); } catch(e) { println(e); };
```

#### return / break / continue / throw

```shell
return;           // 返回 null
return result;    // 返回值
break;            // 跳出循环
continue;         // 跳过本次
throw new RuntimeException("error");
```

### import 导入语句

```shell
import java.util;
import org.apache.commons.lang3.*;
```

默认已导入包：`java.lang`、`java.util`、`java.util.concurrent`、`java.util.concurrent.atomic`、`java.time`、`java.math`、`java.text`、`java.sql`、`javax.sql`、`java.lang.reflect`

### 函数调用

```shell
// 全局函数
string(1);
compare("xxx", 'yyy');

// 静态函数（多种限定方式）
String::valueOf(1);
@org.apache.Test.run("xxx", true);
org.apache.Test@run("xxx", true);    // 推荐
Integer.class.parseInt('123');

// 实例方法链式调用
String.valueOf(1).repeat(2).length();

// 动态函数名
v_name = 'valueOf';
String::<v_name>(1);
String::<(v_name)>(1);              // 推荐，结合 IDEA 插件

// 具名参数
render(str: "123", regex: "\\d+", replacement: "true");
```

### 创建对象与数组

```shell
// 创建对象
new Date();
new User(1L, "xxx")->  {name: 'zhang', age: 12};  // 带属性初始化

// 创建数组
new int[10];
new String[5];
new int[]->[1, 2, 3];          // 自动推断长度
new String[5]->['1','2','3'];  // 指定长度，部分填充
```

### Lambda 表达式

```shell
// 定义 Lambda
add = (a, b) -> { a + b };

// 无参 Lambda
task = () -> { println("hello"); };

// 结合 go 异步执行
go () -> { println("async task"); };
```

### go 异步执行

```shell
// 异步执行语句块
f1 = go { longTask1(); };
f2 = go { longTask2(); };

// 异步执行函数
func task() { println("running"); };
f = go task;

// 等待异步结果
result1 = <- f1;
result = <- f1 <- f2;   // 等待多个，返回 List
```

### synchronized 同步语句

```shell
lock = new Object();
synchronized(lock) {
    counter = counter + 1;
};
```

### 用户自定义函数

```shell
func factor(int in_num, in_level : int) : int {
    println('level=' + in_level);
    if(in_num <= 1) {
        println('v_num=' + global.v_num);
        return 1;
    };
    return in_num * factor(in_num - 1, in_level + 1);
};
v_ret = factor(v_num, 0);
```

- 使用 `func` 或 `def` 关键字定义
- 函数有独立的作用域，通过 `global` 变量访问全局上下文
- 支持声明参数类型和返回类型
- `global` 变量无论递归多少层，始终指向最外层全局上下文

### debugger 调试语法

```shell
debugger;
debugger entry1;
debugger (${count} == null);
debugger user.loop (${item} == null);
```

### 静态变量/枚举访问

```shell
// 访问静态变量/枚举
@java.sql.Types.VARCHAR;
java.sql.Types@VARCHAR;        // 推荐
java.sql.JDBCType::VARCHAR;

// 赋值静态变量
@DatabaseTypeHolder.TYPE = @DatabaseType.MYSQL;
```

### 语句块（逗号表达式）

```shell
m = { a + 1; b - 1; a + b };  // 返回最后一条语句的值
```

## 内建函数

### FunicBuiltinFunctions

| 函数签名                                               | 说明                                           |
|----------------------------------------------------|----------------------------------------------|
| `eval(String script)`                              | 将字符串作为 Funic 脚本在当前上下文中执行                     |
| `render(String text)`                              | 对字符串进行模板渲染（处理 `${...}` 占位符）                  |
| `assign(Object target, Object... sources)`         | 将 sources 合并到 target（支持 Collection/Map/Bean） |
| `compare(Object v1, Object v2)`                    | 比较两个值                                        |
| `compare(Object v1, Object v2, boolean forceType)` | 强制类型匹配比较                                     |
| `cast(Object value, Class clazz)`                  | 类型转换                                         |
| `assert(Object condition)`                         | 断言（假值抛 AssertionError）                       |
| `assert(Object condition, Object message)`         | 带消息断言                                        |
| `int(Object value)`                                | 转换为 Integer                                  |
| `string(Object value)`                             | 转换为 String                                   |
| `double(Object value)`                             | 转换为 Double                                   |
| `boolean(Object value)`                            | 转换为 boolean                                  |
| `decimal(Object value)`                            | 转换为 BigDecimal                               |
| `println(Object... args)`                          | 打印到标准输出（空格分隔，末尾换行）                           |
| `printf(String format, Object... args)`            | 格式化打印                                        |

### 默认注册的全局函数

引擎初始化时自动注册：

- `i2f.mixin.all.AllMixins` 的全部方法（通过 MixinProxyFactory）
- `System.out` 的所有 `print` 相关方法
- `java.lang.Math` 的全部静态方法（`sin`、`cos`、`abs`、`max`、`min`、`pow`、`sqrt` 等）

### 注册自定义全局函数

```java
// 注册类的所有方法
Funic.registryMethods(MyFunctions .class);

// 带过滤条件
Funic.

registryMethods(MyFunctions .class, m ->m.

getName().

startsWith("my"));

// 注册实例方法
        Funic.

registryMethods(myInstance);

// 手动添加
List<IMethod> methods = FunicFunctionHelper.ofMethods(MyFunctions.class);
Funic.

registryMethods(methods);
```

## 扩展点

### FunicResolver 接口

`FunicResolver` 是 Funic 的核心扩展接口，定义了 30 个方法，涵盖：

| 分类    | 方法                                                                      | 说明           |
|-------|-------------------------------------------------------------------------|--------------|
| 字符串   | `multilineString`, `renderString`                                       | 多行字符串处理、模板渲染 |
| 字段访问  | `getFieldValue`, `setFieldValue`                                        | 对象字段读写       |
| 中括号访问 | `getSquareFieldValue`, `setSquareFieldValue`                            | 中括号取值/赋值     |
| 静态访问  | `getStaticFieldOrEnum`, `setStaticField`                                | 静态字段/枚举读写    |
| 方法调用  | `invokeInstanceMethod`, `invokeGlobalMethod`, `invokeStaticMethod`      | 实例/全局/静态方法调用 |
| 对象创建  | `newInstance`, `newArray`                                               | 新建对象/数组      |
| 运算符   | `prefixOperator`, `suffixOperator`, `doubleOperator`                    | 前缀/后缀/双目运算符  |
| 解包    | `unpackList`, `unpackMap`, `assign`                                     | 列表/映射解包      |
| 类型    | `findClass`, `compare`, `toBoolean`, `convertType`, `wrapAsIterator`    | 类查找、比较、转换    |
| 调试    | `onDebugger`, `debug`, `debugLog`, `debugBridge`                        | 调试相关         |
| 生命周期  | `onPreRegistryContextImportPackage`, `onPreRegisterContextGlobalMethod` | 预注册回调        |

### DefaultFunicResolver

默认实现类（1412 行），提供完整的运算符实现、类型转换、方法调用等逻辑。继承此类只需覆盖需要修改的方法。

### SandboxFunicResolver

沙箱模式解析器，通过 Predicate 过滤器控制：

- `multilineFeatureFilter` — 多行字符串特性过滤
- `renderPlaceholderExpressFilter` — 模板占位符表达式过滤
- `execMethodFilter` — 方法执行过滤
- `newInstanceFilter` — 对象创建过滤
- `findClassFilter` — 类查找过滤

不通过过滤的操作将抛出 `FunicRejectException`。

### SafeFunicResolverProxy

安全代理（875 行），包装另一个 Resolver 提供额外的安全检查。

### XProc4J 集成：ProcedureFunicResolver

面向存储过程的 FunicResolver 实现，关键增强：

- `findClass` — 通过 `executor.loadClass()` 优先加载
- `beforeInvokeGlobalMethod` — 优先匹配存储过程元数据（`executor.getMeta()`），支持在 Funic 脚本中直接调用其他过程
- `searchGlobalMethod` — 搜索范围扩展：上下文方法映射 + ExecutorMethodProvider + ExecContextMethodProvider
- `renderString` — 委托 `executor.render()` 进行模板渲染
- `onDebugger` — 委托 `executor.openDebugger()` 进行调试
- `debugBridge` — 委托 `JdbcProcedureDebugBridgeReporter` 进行断点调试

## IDEA 插件支持

| 组件              | 说明                                          |
|-----------------|---------------------------------------------|
| `FunicLanguage` | 语言注册（ID: "Funic"）                           |
| `FunicFileType` | 文件类型（扩展名: `.fic`）                           |
| `FunicConsts`   | 常量定义（图标: `funic.svg`，关键字集自动从 FunicTypes 提取） |
| Parser/PSI      | 80+ PSI 元素类，完整语法支持                          |
| 语法高亮            | 关键字、字符串、数值、注释等待遇高亮                          |
| 代码补全            | 关键字自动补全                                     |

## 注意事项

1. **运算优先级**: 本脚本不完全支持自然意义上的数学运算优先级，某些情况下可能与预期不一致，涉及复杂运算请使用括号明确
2. **函数作用域**: 自定义函数有独立上下文，需通过 `global` 访问全局变量
3. **语句结尾**: if/for/while/try 等控制语句也需要以分号 `;` 结尾
4. **条件判断**: 条件不要求严格 boolean，null/空字符串/空Map/空Collection 均为 false

## 官方文档索引

| 文档                 | 路径                                                 | 说明                                |
|--------------------|----------------------------------------------------|-----------------------------------|
| Funic 语法白皮书        | `i2f-extension-antlr4/.../funic/rule/Funic.md`     | 完整语法文档（1771行）                     |
| Funic 语法白皮书(副本)    | `i2f-jdbc-procedure/.../assets/std/Funic.md`       | 同上，存储于官方文档目录                      |
| ANTLR4 文法文件        | `i2f-extension-antlr4/.../funic/rule/Funic.g4`     | 575 行 ANTLR4 文法定义                 |
| XProc4J 框架 Wiki    | [xproc4j-framework.md](xproc4j-framework.md)       | XProc4J 框架完整 Wiki                 |
| TinyScript 引擎 Wiki | [tinyscript-framework.md](tinyscript-framework.md) | 前身引擎 TinyScript Wiki（将被 Funic 替代） |

## TinyScript → Funic 演进指南

Funic 是 TinyScript 的增强版本和未来替代方案。在 XProc4J 框架中，Funic 将逐渐演变并最终完全替代 TinyScript。

### 演进背景

- TinyScript 是最初的嵌入式脚本引擎，在 XProc4J 中广泛使用
- Funic 在 TinyScript 基础上重新设计，语法更简洁、特性更丰富
- 两者共享相同的 ANTLR4 技术栈和相似的架构设计（Visitor 模式、Resolver 扩展点、LRU 缓存等）
- 未来 XProc4J 将统一使用 Funic，TinyScript 将逐步退出

### 语法迁移对照

| 场景        | TinyScript 写法                 | Funic 写法                                  |
|-----------|-------------------------------|-------------------------------------------|
| 变量取值      | `${user.name}`                | `user.name`                               |
| 变量赋值      | `name = ${user.name}`         | `name = user.name`                        |
| null 安全取值 | `$!{user.nickName}`           | `user?.nickName`                          |
| 条件判断      | `if(${num} > 0)`              | `if(num > 0)`                             |
| 循环        | `foreach(item : list)`        | `for(item : list)`                        |
| for 循环    | `for(i=0; ${i}<10; i=${i}+1)` | `for(i=0; i<10; i=i+1)` 或 `for(i 0...10)` |
| 字符串模板     | `R"hello ${name}"`            | `R"hello ${name}"`（相同）                    |
| 解包        | `#{name:userName} = obj`      | `#{name:userName} = obj`（相同）              |
| 管道调用      | `${a} \|> ::trim()`           | `a \|> ::trim()`                          |
| JSON 构建   | `image: ${images.default}`    | `image: images?.default`                  |

### Funic 新增能力（TinyScript 不具备）

| 特性           | 说明                                 |
|--------------|------------------------------------|
| Lambda 表达式   | `(a, b) -> { a + b }`              |
| go/await 异步  | `f = go { task() }; result = <- f` |
| 用户自定义函数      | `func factor(n) { ... }`           |
| import 导入    | `import java.util.*`               |
| synchronized | `synchronized(lock) { ... }`       |
| 沙箱模式         | `SandboxFunicResolver`             |
| for-range 循环 | `for(i 0...10)`                    |
| 类型转换运算符      | `value as int`                     |
| 严格相等         | `===` / `!==`                      |
| 展开运算符        | `[...base, 4, 5]`                  |
| 变量直接访问       | 无需 `${}` 包裹                        |

### XProc4J 中的演进

| 阶段   | 说明                                                                                    |
|------|---------------------------------------------------------------------------------------|
| 当前阶段 | TinyScript 和 Funic 并存。通过 `xproc4j.enable-funic=true` 可一键切换为 Funic 执行器，**已具备完全替代能力**   |
| 演进中  | 新编写的存储过程推荐使用 Funic（`<lang-eval-funic>`），新项目建议直接开启 `enable-funic`                      |
| 未来   | Funic 完全替代 TinyScript，`FunicJdbcProcedureExecutor` 成为默认执行器，`enableFunic` 默认值改为 `true` |

## 综合案例

### 基础使用

```shell
num = 1 + 1.125;
num2 = num + 10L;
tmp = new String("@@@");
sadd = str;
svl = String::valueOf(1L);
slen = str.length();
srptlen = str.repeat(2).length();

complex = [{
    username: "123",
    roles: ["admin","log"],
    status: true,
    age: 12,
    image: str,
    len: str.length(),
    token: null
}];

if(num > 4) {
    ok = 3;
} elif(num > 3) {
    ok = 2;
} else {
    ok = 1;
};
```

```java
Map<String, Object> context = new HashMap<>();
context.

put("str","1,2,3 4-5-6  7  8  9");

Object ret = Funic.script(formula, context);
```

### 并发异步

```shell
results = [];
f1 = go { 1 + 1 };
f2 = go { 2 + 2 };
results = <- f1 <- f2;
```

### 位运算

```shell
flags = 0b1010;
mask  = 0b1100;
and_result  = flags & mask;    // 0b1000
or_result   = flags | mask;    // 0b1110
xor_result  = flags ^ mask;    // 0b0110
not_result  = ~flags;          // 按位取反
lsh_result  = flags << 1;      // 0b10100
rsh_result  = flags >> 1;      // 0b0101
```

### 管道链 + Lambda

```shell
// 管道处理
result = '  Hello World  '
    |> ::trim()
    |> ::toLowerCase()
    |> replace(" ", "_");

// Lambda + 异步
task = (msg) -> { println("received: " + msg); };
go task;
```
