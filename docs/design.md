# jdbc-procedure 框架设计思想

> 本文档是对 `procedure.xml` 文件开头设计理念部分的总结，详见 [procedure.xml](./procedure.xml)

## 一、框架核心概念

### 1.1 框架目标

jdbc-procedure 框架定义了一个顺序处理流程系统，具备以下核心特点：

- **逻辑控制能力**：支持流程控制（if/for/while等）
- **SQL执行能力**：直接执行SQL语句
- **脚本定义方式**：使用XML格式定义存储过程逻辑，达到与数据库存储过程相似的能力
- **变量管理**：使用Map构成的执行栈维护执行的变量
- **双重灵活性**：既具有编程语言的控制灵活度，也具有数据库语句的直接可识别度

### 1.2 核心设计目标

该框架的核心目标是**避免在Java等编程语言中进行SQL语句的拼接操作**，将SQL与控制逻辑统一在XML中进行定义，提供更加直观和可维护的编程体验。

---

## 二、实现方案

### 2.1 整体架构

框架采用 **XML格式** 编写控制脚本，语言控制与SQL语句都在XML中直接书写。

### 2.2 标签分类

框架将XML标签分为三大类别：

#### 2.2.1 script-开头标签
- **用途**：提供复用性片段
- **含义**：可复用的代码片段，通过 `script-include` 引用

#### 2.2.2 lang-开头标签
- **用途**：提供流程控制能力
- **实现技术**：基于 OGNL/SpEL + Velocity 实现
- **功能**：支持条件判断、循环、变量赋值等编程语言控制结构

#### 2.2.3 sql-开头标签
- **用途**：提供JDBC操作能力
- **实现技术**：采用Mybatis的XML格式进行处理
- **功能**：支持查询、更新、事务管理等SQL操作

---

## 三、核心技术体系

### 3.1 XML 解析技术

| 技术 | 实现 | 用途 |
|------|------|------|
| XML | `org.w3c.dom.Document` | 解析xml文件格式为XmlNode树节点 |

### 3.2 表达式引擎

#### 3.2.1 OGNL（对象图导航语言）

- **实现**：`ognl.Ognl`
- **用途**：用于 `eval`、`visit`、`test` 等场景
- **兼容性**：用法与Mybatis中的OGNL用法基本一致
- **取值规则**：
  - 常规场景中不需要任何包含符
  - SQL场景中使用 `${}` 或 `#{}` 取值，用法与Mybatis一致
- **参考官网**：https://commons.apache.org/dormant/commons-ognl/language-guide.html

#### 3.2.2 Velocity（文本模板引擎）

- **实现**：`org.apache.velocity.app.VelocityEngine`
- **用途**：用于 `render` 场景，提供字符串模板渲染能力
- **应用场景**：字符串动态拼接等
- **取值规则**：
  - 变量取值：`${}` 包含
  - 表达式：`#()` 包含
- **参考官网**：https://velocity.apache.org/engine/devel/user-guide.html

### 3.3 额外支持的脚本语言

#### 3.3.1 Groovy

- **实现**：`groovy.lang.GroovyShell`
- **特点**：JVM平台的脚本语言，可理解为简化版的Java
- **用途**：支持习惯使用Groovy作为脚本语言的用户实现脚本嵌入
- **参考官网**：https://www.groovy-lang.org/syntax.html

#### 3.3.2 TinyScript

- **实现**：`TinyScript.script`
- **特点**：为了适配jdbc-procedure方案而诞生的轻量级脚本引擎
- **设计**：偏向函数式过程语言，基于ANTLR4技术实现
- **用途**：提供轻量级脚本执行能力，适配特定使用场景

---

## 四、属性修饰符系统

### 4.1 修饰符的三重含义

属性修饰符是框架的一个重要机制，具有三种应用场景：

| 场景 | 含义 | 说明 |
|------|------|------|
| **输入时** | 表示值怎么取 | 从何处获取属性值 |
| **输出时** | 表示输出的目标类型 | 输出值的类型转换 |
| **声明时** | 表示期待的输入类型 | 参数声明时的类型标注 |

### 4.2 修饰符组合规则

多个修饰符可以连接使用，使用英文 **句点（.）** 作为分隔符，修饰符 **按照从左到右的顺序依次执行**。

**示例**：`value.string.long.int="1"`
- 从表达式 `1` 开始
- 先转为 `string` 字符串
- 再转为 `long` 数值型
- 最终转为 `int` 整型

### 4.3 数据类型修饰符

#### 基础数据类型（8种）

| 修饰符 | 含义 | 对应Java类型 |
|--------|------|-------------|
| `.int` | 整型 | `int` |
| `.long` | 长整型 | `long` |
| `.short` | 短整型 | `short` |
| `.byte` | 字节型 | `byte` |
| `.float` | 短浮点型 | `float` |
| `.double` | 浮点型 | `double` |
| `.char` | 字符型 | `char` |
| `.boolean` | 布尔型 | `boolean` |

#### 复杂数据类型

| 修饰符 | 含义 | 说明 |
|--------|------|------|
| `.string` | 字符串 | 字符串类型转换 |
| `.date` | 日期时间型 | 需要标签指定pattern属性；无pattern时尝试可行的解析 |
| `.class` | Class对象 | 转换为 `Class<?>` 对象 |
| `.null` | 空值 | 表示null值 |

### 4.4 取值修饰符

| 修饰符 | 含义 | 说明 |
|--------|------|------|
| `.visit` | 访问属性 | 从params参数Map中取属性值 |
| `.eval` | 计算表达式 | 使用默认方式（OGNL）计算表达式的值 |
| `.test` | 测试表达式 | 使用默认方式（OGNL）测试表达式的真假 |
| `.render` | 渲染字符串 | 使用模板引擎（Velocity）方式渲染字符串 |

### 4.5 脚本引擎修饰符

| 修饰符 | 引擎 | 说明 |
|--------|------|------|
| `.eval-java` | JDK内存编译 | 以Java表达式解析 |
| `.eval-js` | Java JavaScript引擎 | 以JavaScript表达式解析 |
| `.eval-tinyscript` 或 `.eval-ts` | TinyScript | 以TinyScript表达式解析 |
| `.eval-groovy` | Groovy | 以Groovy脚本运行 |

### 4.6 字符串处理修饰符

| 修饰符 | 含义 | 说明 |
|--------|------|------|
| `.trim` | 截断空白 | 在字符型变量时进行先trim后使用；输出时先trim后输出 |
| `.align` | 左对齐 | 对左边多余的空白符号予以去除；需要以`\|`引导字符串行 |
| `.body-text` | 获取文本内容 | 从标签内部获取纯文本 |
| `.body-xml` | 获取XML内容 | 从标签内部获取XML节点 |
| `.spacing-left` | 左填充空格 | 在左边填充空格 |
| `.spacing-right` | 右填充空格 | 在右边填充空格 |
| `.spacing` | 两边填充空格 | 在两边都填充空格 |

### 4.7 逻辑运算修饰符

| 修饰符 | 含义 | 说明 |
|--------|------|------|
| `.not` | 取反 | 对boolean值取反 |
| `.is-null` | 判断为null | 判断是否为null |
| `.is-not-null` | 判断不为null | 判断是否不为null |
| `.is-empty` | 判断为空 | 判断是否为空，适用于string类型 |
| `.is-not-empty` | 判断不为空 | 判断是否不为空，适用于string类型 |

### 4.8 系统值修饰符

| 修饰符 | 含义 | 说明 |
|--------|------|------|
| `.date-now` | 当前时间 | 相当于 `new Date()` |
| `.uuid` | 随机UUID | 相当于 `UUID.randomUUID().toString()` |
| `.current-time-millis` | 当前毫秒值 | 相当于 `System.currentTimeMillis()` |
| `.snow-uid` | 雪花ID | 相当于 `SnowflakeLongUid.getId()` |

### 4.9 数据库方言修饰符

| 修饰符 | 说明 | 用途 |
|--------|------|------|
| `.dialect` | 数据库方言 | 主要用于test属性上，表示指定datasource支持哪些数据库类型 |

**用法示例**：
```xml
<lang-if test.dialect="mysql,oracle" datasource="primary">
    <!-- 当datasource为primary的数据库类型在mysql、oracle中任意一个满足时执行 -->
</lang-if>
```

### 4.10 异常处理修饰符

这些修饰符用于异常类型的捕获或判定场景，主要在 `lang-catch` 的 `type` 属性上使用。

#### 异常修饰符汇总

| 修饰符 | 含义 | 用法 |
|--------|------|------|
| `.cause-first` | 第一个匹配异常 | 在cause链中取第一个匹配的异常类型 |
| `.cause-last` | 最后一个匹配异常 | 在cause链中取最后一个匹配的异常类型 |
| `.cause-root` | 根异常 | 在cause链中取最后一个根异常 |
| `.cause-raw` | 原始异常 | 取框架层面得到的原始异常（不进行任何cause过滤） |

#### 异常处理背景说明

由于框架内部的异常之间会进行一些re-throw重新抛出操作，会导致最原始的异常类型丢失，到catch的时候异常类型匹配不上的情况。因此需要配合异常修饰符对异常进行cause链的获取，作为异常进行判定，才能满足实际的使用需要。

#### 异常cause链示例

假设框架层面捕获到异常的cause链如下：

```
ThrowSignalException 
  → IllegalStateException 
    → SQLException 
      → SQLDataException 
        → IllegalArgumentException
```

**各修饰符的行为**：

- **默认情况**（无修饰符）：
  - 去除SignalException及其子类，保留最原始的异常类型
  - 最终使用：`IllegalStateException` 进行判定

- **使用 `.cause-first`**：
  - 在cause链中查找第一个匹配的异常
  - 示例：`type.cause-first="SQLException"` 会找到：
    ```
    SQLException 
      → SQLDataException 
        → IllegalArgumentException
    ```

- **使用 `.cause-last`**：
  - 在cause链中查找最后一个匹配的异常
  - 示例：`type.cause-last="SQLException"` 会找到：
    ```
    SQLDataException 
      → IllegalArgumentException
    ```

- **使用 `.cause-root`**：
  - 获取最终的异常（最根本造成的异常）
  - 最终得到：`IllegalArgumentException`

- **使用 `.cause-raw`**：
  - 不经过任何cause过滤，获取框架层面的原始异常
  - 最终得到：`ThrowSignalException`

### 4.11 修饰符的扩展性

#### 未标明的修饰符处理规则

- 框架中 **未标明的修饰符不会被处理**，会被跳过处理
- 这意味着请务必 **检查修饰符的拼写**

#### 自定义标识符的支持

框架允许您使用一些自己喜欢的标识符来说明事情。这些自定义标识符会被忽略，但可用于文档注解或团队约定。

**常见自定义标识符示例**：
- `.in` - 表示入参
- `.out` - 表述出参
- `.inout` - 表示入出参

### 4.12 属性默认修饰符

在一些场景中，某些属性具有默认的属性修饰符（也就是默认行为），可以通过添加自己的属性修饰符来改变默认行为的目的。

#### 示例

**示例1：tag属性**
- 默认修饰符：`.string`（字面字符串）
- 修改：`tag.visit` 会改变行为为从params参数取一个字符串

**示例2：lang-set中的value属性**
- 默认修饰符：`.visit`（从params中取值）
- 修改1：`value.string` 直接输入字符串
- 修改2：`value.eval` 或 `value.eval-java` 改变行为为获取eval的结果

---

## 五、脚本引擎实现详解

### 5.1 eval-java 的执行原理

**实现方式**：使用JDK的内存编译技术实现

**函数原型**：
```java
public Object exec(JdbcProcedureExecutor executor, Map<String,Object> params) throws Throwable {
    // 这里就是脚本内容
}
```

**参考接口**：`JdbcProcedureJavaCaller`

**使用说明**：
- 脚本内容需要补全函数体内部的内容
- 单行或多行脚本：会自动检测最后的return关键字和分号进行补全
- 简单表达式：例如 `new Date()` 即可，不用写 `return new Date();`
- 复杂逻辑：建议自己完善语法

### 5.2 eval-js 的执行原理

**实现方式**：使用Java中的JavaScript引擎进行处理

**执行作用域**：以局部作用域的方式运行

**注入变量**：
- `context` - 执行上下文
- `executor` - 执行器实例
- `params` - 参数Map

**返回值**：js引擎执行完毕之后，会返回最后一次执行的结果

### 5.3 eval-groovy 的执行原理

**实现方式**：使用groovy引擎进行处理

**函数原型**：
```groovy
def exec(JdbcProcedureExecutor executor, Map<String,Object> params) throws Throwable {
    // 这里就是脚本内容
}
```

**参考接口**：`JdbcProcedureJavaCaller`

**使用说明**：脚本内容需要补全函数体内部的内容

### 5.4 eval-ts (TinyScript) 的执行原理

**实现方式**：使用TinyScript引擎进行处理

**注入变量**：
- 仅注入 `params` 进行执行
- 由于 `params.executor` 也注入了executor变量
- 因此也可以直接使用 `executor` 进行访问

**特点**：提供轻量级脚本执行能力

### 5.5 OGNL 在eval中的应用

**实现方式**：使用OGNL进行实现

**上下文设置**：
- OGNL以上下文的Map对象为根对象
- 同时会添加名为 `$root` 的变量，也是这个上下文Map

**参考实现**：`DefaultJdbcProcedureExecutor.innerEval`

---

## 六、框架设计要点总结

### 6.1 核心设计原则

1. **XML驱动**：所有流程控制和SQL操作都在XML中定义
2. **标签分类清晰**：script-、lang-、sql- 三大类别划分明确
3. **修饰符灵活**：通过修饰符组合实现复杂的类型转换和取值逻辑
4. **技术集成**：整合OGNL、Velocity、多种脚本语言等成熟技术
5. **可扩展性**：支持自定义标签、自定义修饰符等扩展机制

### 6.2 关键设计亮点

1. **属性修饰符系统**：
   - 提供了统一的属性处理机制
   - 支持修饰符链式组合
   - 具有高度的灵活性和可扩展性

2. **异常处理机制**：
   - 通过cause链修饰符精确控制异常类型匹配
   - 解决了框架层异常包装导致的类型丢失问题

3. **表达式引擎多样性**：
   - 支持OGNL、Velocity等标准引擎
   - 支持Java、JavaScript、Groovy等多种脚本语言
   - 内置TinyScript轻量级引擎

4. **向后兼容性**：
   - 未标明的修饰符会被跳过，允许自定义标识符
   - 支持默认修饰符，同时允许覆盖

### 6.3 与相关框架的对标

| 方面 | jdbc-procedure | Mybatis | 存储过程 |
|------|----------------|---------|---------|
| 编程语言 | XML | XML | T-SQL/PL-SQL |
| 流程控制 | lang-开头 | 有限支持 | 原生支持 |
| SQL编写 | 原生XML | 原生XML | 原生SQL |
| 可维护性 | 很好 | 很好 | 较差 |
| 版本管理 | 很好 | 很好 | 较差 |
| 数据库无关性 | 很好 | 很好 | 数据库相关 |

---

## 七、参考资源

- **详细语法参考**：[procedure.xml](./procedure.xml)
- **框架架构**：[framework.md](./framework.md)
- **快速入门**：[quick-start.md](./quick-start.md)
- **转换对照指南**：[convert-sample.md](./convert-guide)
- **TinyScript语法**：[TinyScript.md](./TinyScript.md)

---

**文档版本：** 1.0  
**最后更新：** 2026-04-02  
**维护者：** Ice2Faith