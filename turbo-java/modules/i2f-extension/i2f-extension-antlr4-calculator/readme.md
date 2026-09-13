# i2f-extension-antlr4-calculator

> **基于 ANTLR4 的计算器表达式解析与求值模块 / 将 ANTLR4 文法解析能力装配为公式字符串到 BigDecimal 计算结果的一步式求值门面**（仅 1 测试源文件共 37 行、主源码和 ANTLR 文法文件缺失、`antlr4-runtime:4.13.2` provided + optional，内部依赖 `i2f-reflect`/`i2f-convert`/`i2f-typeof`/`i2f-match`/`i2f-invokable`/`i2f-mutator`/`i2f-mixins`/`i2f-jvm`/`i2f-bindsql` 共 9 个）。

## 模块路径

- `i2f-extension/i2f-extension-antlr4-calculator/pom.xml`
- 相对于仓库根目录：`i2f-extension/i2f-extension-antlr4-calculator`

## 模块依赖

### 内部模块（compile 依赖）

| Maven 坐标 | scope | optional | 说明 |
|-----------|-------|----------|------|
| `i2f.turbo:i2f-reflect:1.0-jdk8` | compile | false | 反射工具（用于运行时类型判断与方法调用） |
| `i2f.turbo:i2f-convert:1.0-jdk8` | compile | false | 类型转换工具（表达式求值中的数值类型转换） |
| `i2f.turbo:i2f-typeof:1.0-jdk8` | compile | false | 类型判定工具（运行时类型检查） |
| `i2f.turbo:i2f-match:1.0-jdk8` | compile | false | 字符串匹配工具（表达式文本模式匹配） |
| `i2f.turbo:i2f-invokable:1.0-jdk8` | compile | false | 可调用方法抽象（函数调用的反射执行） |
| `i2f.turbo:i2f-mutator:1.0-jdk8` | compile | false | 流式对象修改器（求值上下文变量赋值） |
| `i2f.turbo:i2f-mixins:1.0-jdk8` | compile | false | 混入工具集（表达式功能扩展） |
| `i2f.turbo:i2f-jvm:1.0-jdk8` | compile | false | JVM 工具（表达式安全性检查） |
| `i2f.turbo:i2f-bindsql:1.0-jdk8` | compile | false | 参数化 SQL 构建器（表达式变量绑定） |

### 三方依赖（provided + optional）

| Maven 坐标 | 版本 | scope | optional | 说明 |
|-----------|------|-------|----------|------|
| `org.antlr:antlr4-runtime` | 4.13.2 | provided | true | ANTLR4 运行时库（词法/语法解析器骨架 + 树遍历 API + TokenStream 等） |
| `org.projectlombok:lombok` | 父 POM 管理 | provided | true | 编译期代码生成（注解处理） |

## 模块设计

### 包结构

```
i2f.extension.antlr4.calculator          -- 主包（ANTLR 生成的解析器类）
  ├── CalculatorParser                    -- ANTLR 自动生成的语法解析器（解析 Formula.g4 文法）
  └── CalculatorLexer                     -- ANTLR 自动生成的词法分析器
i2f.extension.antlr4.calculator.impl      -- 实现包
  └── Calculator                          -- 静态求值门面（eval/parseTokens）
```

### 架构设计

本模块设计为 ANTLR4 文法定向求值的**编译器-解释器两层架构**：

```
公式字符串 "avg(4+3,5,6)"
        │
        ▼
┌─────────────────────────────┐
│   Calculator.parseTokens()  │  ← 词法分析 + 语法分析
│   ┌─────────┐  ┌─────────┐ │
│   │ Lexer   │→│ Parser  │ │     ANTLR4 自动生成
│   └─────────┘  └─────────┘ │
└──────────┬──────────────────┘
           │  ParseTree
           ▼
┌─────────────────────────────┐
│ Calculator.eval(ParseTree)  │  ← 树遍历求值
│   Listener/Visitor 模式     │     手工编写
│   ┌─────────────────────┐   │
│   │ 数值字面量求值       │   │
│   │ 算术运算符求值       │   │
│   │ 函数调用求值(avg等)  │   │
│   │ BigDecimal 精度计算   │   │
│   └─────────────────────┘   │
└─────────────────────────────┘
           │
           ▼
       BigDecimal 结果
```

### 设计要点

1. **ANTLR4 文法定向求值**：通过 `.g4` 文法文件定义表达式语法（算术运算 + 函数调用），ANTLR 自动生成 `CalculatorParser`/`CalculatorLexer`，树遍历求值逻辑手工实现
2. **静态门面模式**：`Calculator.eval(String)` 为静态方法入口，隐藏 Lexer/Parser/Visitor 的实例化与组装细节
3. **BigDecimal 精度**：所有数值运算使用 `BigDecimal` 保证精度，避免浮点误差
4. **函数调用支持**：文法支持 `avg(4+3,5,6)` 等多参数函数调用，函数名解析通过 `i2f-invokable`/`i2f-reflect` 实现
5. **语法与语义分离**：`.g4` 文法定义语法结构，`Calculator` 实现语义求值，文法变更无需修改求值逻辑
6. **9 个内部依赖**：本模块依赖 9 个 i2f-jdk 内部模块，涵盖表达式求值所需的反射/类型转换/匹配/调用/变量绑定等能力

## 模块目的

- 将 ANTLR4 的表达式解析能力封装为**一行代码完成公式求值**的简易门面
- 提供 `BigDecimal` 精度的算术表达式计算，支持函数调用、运算符优先级与括号分组
- 作为 `i2f-extension-antlr4` 聚合模块的组成部分，与其他 ANTLR 子模块（funic/tinyscript）共享 ANTLR 生态基建

## 模块功能

1. **公式字符串求值**：`Calculator.eval("avg(4+3,5,6)")` 返回 `BigDecimal` 结果
2. **语法树解析**：`Calculator.parseTokens(String)` 返回 `CommonTokenStream`，支持分步调试
3. **算术运算符**：加减乘除四则运算 + 括号分组
4. **函数调用**：多参数函数调用（如 `avg(4+3,5,6)` - 求平均值）
5. **BigDecimal 精度**：全程高精度计算
6. **两步式 API**：`eval(String)` 快捷求值 + `parseTokens → new Parser → eval(ParseTree)` 分步装配

## 模块主要使用方法

### 1. 快捷求值

```java
BigDecimal ret = Calculator.eval("avg(4+3,5,6)");
System.out.println(ret); // 6.0
```

### 2. 分步解析与求值

```java
CommonTokenStream tokens = Calculator.parseTokens(formula);
CalculatorParser parser = new CalculatorParser(tokens);
CalculatorParser.EvalContext tree = parser.eval();
System.out.println(tree.toStringTree(parser));

Object ret = Calculator.eval(tree);
System.out.println(ret);
```

### 3. Maven 依赖引入

```xml
<dependency>
    <groupId>i2f.turbo</groupId>
    <artifactId>i2f-extension-antlr4-calculator</artifactId>
    <version>1.0-jdk8</version>
</dependency>
```

运行期需额外提供 `antlr4-runtime:4.13.2`：

```xml
<dependency>
    <groupId>org.antlr</groupId>
    <artifactId>antlr4-runtime</artifactId>
    <version>4.13.2</version>
</dependency>
```

### 4. 配合 i2f-extension-antlr4 聚合使用

```xml
<!-- 引入 antlr4 聚合模块，自动引入 calculator + funic + tinyscript -->
<dependency>
    <groupId>i2f.turbo</groupId>
    <artifactId>i2f-extension-antlr4</artifactId>
    <version>1.0-jdk8</version>
</dependency>
```

## 模块特性总结

- **ANTLR4 文法定向**：基于 .g4 文法定义，自动生成词法/语法解析器，文法可维护可扩展
- **一行求值**：`Calculator.eval(String)` 静态门面，零配置启动
- **BigDecimal 高精度**：全程 BigDecimal 运算，无浮点精度损失
- **两步式 API**：快捷求值与分步解析双入口，满足调试与自定义扩展需求
- **9 内聚依赖**：利用 i2f-jdk 内部模块提供反射/类型转换/匹配等能力，模块高度内聚

## 模块瑕疵或错误

1. **主源码缺失**：`src/main/java/` 下仅存空目录结构，无 `.g4` 文法文件、无 ANTLR 生成的 `CalculatorParser`/`CalculatorLexer`、无 `Calculator` 实现类。编译该模块将产生不包含任何 calculator 类的空 JAR（`target/classes` 为空），`TestCalculator` 运行将因类缺失而报 `NoClassDefFoundError`
2. **POM 缺少 ANTLR 代码生成插件**：POM 未配置 `antlr4-maven-plugin`（或 `antlr4:antlr4` 插件），即使存在 `.g4` 文件也无法自动生成 Java 源码
3. **文法文件丢失**：无 `Formula.g4` 或等同的文法定义文件，无法复原支持的运算符、函数和语法规则
4. **API 范围不可知**：`avg` 为测试中唯一使用的函数，其他支持函数（如 `min`/`max`/`sum` 等）未知，文法文件缺失导致合约不可查阅
5. **fat-jar 空转**：`maven-assembly-plugin` 配置的 `jar-with-dependencies` 打包模式将 9 个内部依赖模块的类打包，但本模块自身的 calculator 类不存在，最终 JAR 不包含任何求值逻辑

## 消费方情况

| 消费方 | 依赖方式 | 说明 |
|-------|---------|------|
| `i2f-extension-antlr4` | POM 依赖 | ANTLR 子模块聚合门面 |
| `i2f-extension-all` | POM 依赖 | extension 域全量聚合分发包 |
| `i2f-extension` 父 POM | module 声明 | 多模块子模块注册 |
| 根 POM `i2f-turbo-java` | dependencyManagement | 版本统一管理 |