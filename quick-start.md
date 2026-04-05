# jdbc-procedure 快速入门手册

## 一、概述

### 1.1 框架简介

jdbc-procedure（也称 XProc4J，即 Xml Procedure for Java）是一个用于实现"去数据库存储过程"的 Java 框架。

**设计目标：**

- 取代数据库过程的依赖性，将存储过程转换为 Java 代码实现
- 采用 XML 为主体，参考 Mybatis 的 XML 标签写法
- 构建以 XML + JDBC + 脚本引擎 + 模板引擎为基础技术支持的存储过程方案
- 用来替换数据库中的一切过程体，包括存储过程（procedure）和函数（function）

**技术特点：**

- 以解析 XML 文件为主，内部使用 SAX 解析
- 参考 Mybatis 的 XML 语法特点进行顺序化的语句调用
- 引入 TinyScript、OGNL、Velocity 作为表达式引擎
- 支持 JavaScript、Groovy、Java 等脚本语言

### 1.2 适用场景

- 数据库存储过程迁移到 Java 应用
- 复杂业务逻辑的 XML 可视化配置
- 跨数据源的 ETL 操作
- 多步骤批处理任务
- 动态 SQL 拼接和执行

---

## 二、快速开始

### 2.1 添加 Maven 依赖

```xml

<dependency>
    <groupId>...</groupId>
    <artifactId>jdbc-procedure-starter</artifactId>
    <version>${version}</version>
</dependency>
```

### 2.2 Spring Boot 配置

在 `application.yml` 中添加以下配置：

```yaml
xproc4j:
  enable: true
  debug: false
  # XML文件扫描位置
  xml-locations: "classpath*:procedure/**/*.xml;classpath*:com/**/procedure/*.xml"
  # 监听目录（热加载）
  watching-directories: "classpath*:procedure/;classpath*:com/"
  # 刷新间隔（秒），-1表示不刷新
  refresh-xml-interval-seconds: 60
  # 慢查询阈值（毫秒）
  slow-sql-min-mills-seconds: 5000
  slow-node-mills-seconds: 15000
  slow-procedure-mills-seconds: 30000
```

### 2.3 编写第一个存储过程

在 `resources/procedure/` 目录下创建 XML 文件：

**文件路径：** `resources/procedure/HelloWorld.xml`

```xml
<!DOCTYPE procedure SYSTEM "procedure.dtd">
<procedure id="HelloWorld"
           IN_NAME.string=""
           RTN_CODE.int.out=""
           RTN_MSG.string.out=""
>
    <!-- 变量定义区域 -->
    <lang-eval-ts>
        V_TIME = now();
    </lang-eval-ts>

    <!-- 条件判断 -->
    <lang-if test="IN_NAME==null or IN_NAME==''">
        <lang-set result="RTN_CODE" value.int="-1"/>
        <lang-set result="RTN_MSG" value.string="姓名不能为空"/>
        <lang-return/>
    </lang-if>

    <!-- 执行处理 -->
    <lang-set result="RTN_CODE" value.int="0"/>
    <lang-set result="RTN_MSG" value.string="OK"/>
</procedure>
```

### 2.4 Java 代码调用

```java
import ....springboot.jdbc.bql.procedure.JdbcProcedureHelper;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Component
public class DemoRunner {

    public void callProcedure() {
        Map<String, Object> result = JdbcProcedureHelper.call("HelloWorld", map -> {
            map.put("IN_NAME", "张三");
            return map;
        });

        Integer code = (Integer) result.get("RTN_CODE");
        String msg = (String) result.get("RTN_MSG");
        System.out.println("返回码: " + code + ", 消息: " + msg);
    }
}
```

---

## 三、核心概念

### 3.1 过程定义

**存储过程结构：**

```xml
<!DOCTYPE procedure SYSTEM "procedure.dtd">
<procedure id="过程名称"
           参数1.类型=""
           参数2.类型=""
           返回参数.out=""
>
    <!-- 过程体 -->
</procedure>
```

**参数类型修饰符：**

| 修饰符        | 说明   | 示例                 |
|------------|------|--------------------|
| `.int`     | 整型   | `param.int=""`     |
| `.long`    | 长整型  | `param.long=""`    |
| `.string`  | 字符串  | `param.string=""`  |
| `.double`  | 浮点数  | `param.double=""`  |
| `.boolean` | 布尔型  | `param.boolean=""` |
| `.date`    | 日期型  | `param.date=""`    |
| `.out`     | 输出参数 | `param.out=""`     |

**函数定义：**

```xml

<procedure id="F_GET_NAME"
           IN_ID.int=""
           return.string="">
    <!-- 函数体 -->
</procedure>
```

### 3.2 执行上下文

执行上下文是一个 Map 对象，包含以下固定变量：

| 变量名        | 类型                    | 说明         |
|------------|-----------------------|------------|
| `global`   | Map                   | 全局变量，跨过程共享 |
| `trace`    | Map                   | 执行跟踪信息     |
| `executor` | JdbcProcedureExecutor | 执行器引用      |
| `params`   | Map                   | 过程参数       |
| `lru`      | LruMap                | LRU缓存      |

**常用 trace 变量：**

- `trace.location` - 当前XML文件名
- `trace.line` - 当前行号
- `trace.errmsg` - 最后一次异常信息

---

## 四、XML节点参考

### 4.1 语言控制节点 (lang-*)

#### 4.1.1 变量赋值 `<lang-set>`

```xml
<!-- 直接赋值 -->
<lang-set result="V_NAME" value.string="张三"/>

        <!-- 使用修饰符 -->
<lang-set result="V_COUNT" value.int="0"/>
<lang-set result="V_FLAG" value.boolean="true"/>
<lang-set result="V_TIME" value.date-now=""/>

        <!-- 从上下文取值 -->
<lang-set result="V_NAME" value="IN_NAME"/>

        <!-- 渲染赋值 -->
<lang-set result="V_SQL" value.render="SELECT * FROM $!{TABLE_NAME}"/>
```

#### 4.1.2 条件判断 `<lang-if>`

```xml

<lang-if test="V_COUNT > 0">
    <lang-set result="V_FLAG" value.int="1"/>
</lang-if>

        <!-- 使用OGNL表达式 -->
<lang-if test="V_NAME == 'admin'">
<!-- 处理逻辑 -->
</lang-if>

        <!-- 使用TinyScript -->
<lang-if test.eval-ts="${V_NAME} == 'admin'">
<!-- 处理逻辑 -->
</lang-if>
```

#### 4.1.3 多分支选择 `<lang-choose>`

```xml

<lang-choose>
    <lang-when test="V_STATUS == 1">
        <lang-set result="V_DESC" value.string="正常"/>
    </lang-when>
    <lang-when test="V_STATUS == 0">
        <lang-set result="V_DESC" value.string="禁用"/>
    </lang-when>
    <lang-otherwise>
        <lang-set result="V_DESC" value.string="未知"/>
    </lang-otherwise>
</lang-choose>
```

#### 4.1.4 循环 `<lang-foreach>`

```xml

<lang-foreach collection="userList" item="item" index="i">
    <lang-set result="v_user_name" value="item.userName"/>
    <sql-update>
        update sys_user set status=1 where user_name=#{v_user_name}
    </sql-update>
</lang-foreach>
```

#### 4.1.5 计数循环 `<lang-fori>`

```xml

<lang-set result="V_SUM" value.int="0"/>
<lang-fori item="i" begin.int="1" end.int="100" incr.int="1">
<lang-set result="V_SUM" value.eval="V_SUM + i"/>
</lang-fori>
```

#### 4.1.6 条件循环 `<lang-while>`

```xml

<lang-set result="V_I" value.int="0"/>
<lang-while test="V_I < 10">
<lang-set result="V_SUM" value.eval="V_SUM + V_I"/>
<lang-set result="V_I" value.eval="V_I + 1"/>
</lang-while>
```

#### 4.1.7 返回 `<lang-return>`

```xml

<lang-return/>
<lang-return value.int="0"/>
<lang-return value="V_RESULT"/>
```

#### 4.1.8 异常处理 `<lang-try>`

```xml

<lang-try>
    <lang-body>
        <sql-update script="V_SQL"/>
    </lang-body>
    <lang-catch e="e">
        <lang-set result="V_ERROR" value.string="执行失败"/>
    </lang-catch>
    <lang-finally>
        <sql-trans-commit/>
    </lang-finally>
</lang-try>
```

#### 4.1.9 TinyScript脚本 `<lang-eval-ts>`

```xml

<lang-eval-ts>
    V_COUNT = 0;
    V_COUNT = ${V_COUNT} + 1;
    V_MSG = 'Hello ' + $!{V_NAME};

    // 条件判断
    if(${V_STATUS} == 1) {
        V_RESULT = '正常';
    } else {
        V_RESULT = '异常';
    };
</lang-eval-ts>
```

#### 4.1.10 字符串渲染 `<lang-render>`

```xml

<lang-render result="V_SQL" _lang="sql">
    SELECT * FROM $!{TABLE_NAME}
    WHERE STATUS = $!{V_STATUS}
</lang-render>

        <!-- 使用trim修饰符 -->
<lang-render result.trim="V_SQL">
    AND STATUS = $!{V_STATUS}
</lang-render>
```

### 4.2 SQL操作节点 (sql-*)

#### 4.2.1 查询单行 `<sql-query-row>`

```xml

<sql-query-row result="userInfo">
    SELECT * FROM sys_user WHERE id = #{V_ID}
</sql-query-row>

        <!-- 从变量获取SQL -->
<sql-query-row result="userInfo" script="V_SQL"/>
```

#### 4.2.2 查询多行 `<sql-query-list>`

```xml

<sql-query-list result="userList">
    SELECT * FROM sys_user WHERE status = #{V_STATUS}
</sql-query-list>

        <!-- 分页查询 -->
<sql-query-list result="userList" script="V_SQL" offset="0" limit="10"/>
```

#### 4.2.3 查询单个值 `<sql-query-object>`

```xml

<sql-query-object result="V_COUNT" result-type="long">
    SELECT COUNT(1) FROM sys_user
</sql-query-object>
```

#### 4.2.4 更新操作 `<sql-update>`

```xml

<sql-update>
    UPDATE sys_user SET status = #{V_STATUS} WHERE id = #{V_ID}
</sql-update>

        <!-- 获取影响行数 -->
<sql-update result="EFFECT_ROWS">
    DELETE FROM sys_user WHERE id = #{V_ID}
</sql-update>
```

#### 4.2.5 游标循环 `<sql-cursor>`

```xml

<sql-cursor item="rowData">
    <sql-query-list>
        SELECT * FROM sys_user WHERE status = 1
    </sql-query-list>
    <lang-body>
        <lang-set result="V_NAME" value="rowData.userName"/>
        <sql-update>
            UPDATE sys_user SET status = 0 WHERE user_name = #{V_NAME}
        </sql-update>
    </lang-body>
</sql-cursor>
```

#### 4.2.6 事务控制

```xml
<!-- 开始事务 -->
<sql-trans-begin/>

<!-- 提交事务 -->
<sql-trans-commit/>

<!-- 回滚事务 -->
<sql-trans-rollback/>
```

### 4.3 过程调用节点

#### 4.3.1 调用存储过程 `<procedure-call>`

```xml

<procedure-call refid="SP_OTHER_PROC"
                result="callParams"
                IN_PARAM1="V_VALUE1"
                IN_PARAM2.int="123"
/>
<!-- 从返回结果中，取出输出参数值 -->
<lang-set result="V_RESULT" value="callParams.OUT_PARAM"/>
```

#### 4.3.2 调用函数 `<function-call>`

```xml

<function-call refid="F_GET_NAME"
               result="V_NAME"
               IN_ID="V_ID"
/>
```

### 4.4 日志节点

```xml

<log-debug value="调试信息"/>
<log-info value="普通信息"/>
<log-warn value="警告信息"/>
<log-error value="错误信息" e="e"/>
```

---

## 五、表达式引擎

### 5.1 OGNL表达式

OGNL 主要用于 `test` 属性和 `visit` 访问。

**常用语法：**

```xml
<!-- 比较运算 -->
<lang-if test="V_COUNT == 0"></lang-if>
<lang-if test="V_NAME != null"></lang-if>
<lang-if test="V_COUNT > 10"></lang-if>

<!-- 字符串比较 -->
<lang-if test='V_NAME == "admin"'></lang-if>
<lang-if test='V_NAME.startsWith("test")'></lang-if>

<!-- IN操作 -->
<lang-if test="V_STATUS in {1,2,3}"></lang-if>

<!-- 逻辑运算 -->
<lang-if test="V_A > 0 and V_B < 10"></lang-if>
<lang-if test="V_A == null or V_B != ''"></lang-if>
```

### 5.2 Velocity模板

Velocity 用于字符串渲染，`render` 修饰符场景。

**语法：**

```xml
<!-- ${} 变量替换，null时原样显示 -->
${V_NAME}

<!-- $!{} 变量替换，null时显示空字符串 -->
$!{V_NAME}

        <!-- 模板示例 -->
<lang-render result="V_SQL">
    SELECT * FROM $!{TABLE_NAME} WHERE $!{WHERE_COND}
</lang-render>
```

### 5.3 TinyScript脚本

TinyScript 是专门为存储过程转换设计的脚本语言。

**基础语法：**

```xml

<lang-eval-ts>
    // 变量赋值
    V_NAME = '张三';
    V_AGE = 25;

    // 变量引用（使用${}）
    V_MSG = '姓名: ' + ${V_NAME};

    // 空安全引用（null时返回空字符串）
    V_SAFE = 'Hello ' + $!{V_NULL};

    // 算术运算
    V_RESULT = ${V_A} + ${V_B};

    // 条件判断
    if(${V_STATUS} == 1) {
        V_DESC = '正常';
    } else {
        V_DESC = '异常';
    };

    // 循环
    for(i = 0; ${i} lt 10; i = ${i} + 1) {
        V_SUM = ${V_SUM} + ${i};
    };

    // 内建函数
    V_LEN = length(${V_NAME});
    V_UPPER = upper('test');
    V_TRIM = trim(' abc ');
</lang-eval-ts>
```

**常用内建函数：**

```xml
<!-- 字符串函数 -->
<lang-eval-ts>
    V_UPPER = upper('abc'); // 转大写
    V_LOWER = lower('ABC'); // 转小写
    V_TRIM = trim(' abc '); // 去空格
    V_LEN = length('abc'); // 长度
    V_SUB = substr('abcdef', 0, 3); // 截取
    V_REP = replace('abc', 'a', 'x'); // 替换
</lang-eval-ts>

        <!-- 空值处理 -->
<lang-eval-ts>
    V_VAL = nvl(${V_NULL}, 'default');
    V_EMP = is_empty(${V_STR});
</lang-eval-ts>

        <!-- 日期函数 -->
<lang-eval-ts>
    V_NOW = now();
    V_DATE = date_format(${V_NOW}, 'yyyy-MM-dd');
    V_ADD = add_days(${V_NOW}, 7);
</lang-eval-ts>
```

---

## 六、TinyScript语法速查

### 6.1 基础数据类型

```xml

<lang-eval-ts>
    V_INT = 123; // 整型
    V_LONG = 123L; // 长整型
    V_DOUBLE = 1.5; // 浮点型
    V_STR = 'hello'; // 字符串（单引号）
    V_STR2 = "world"; // 字符串（双引号）
    V_BOOL = true; // 布尔型
    V_NULL = null; // 空值
</lang-eval-ts>
```

### 6.2 变量引用

```xml

<lang-eval-ts>
    V_VAL = ${VAR_NAME}; // 普通引用
    V_SAFE = $!{VAR_NAME}; // 空安全引用，null返回''
    V_NEST = ${obj.nested.value}; // 嵌套属性
    V_LIST = ${list[0]}; // 列表索引
</lang-eval-ts>
```

### 6.3 运算符

```xml

<lang-eval-ts>
    // 算术运算
    V_ADD = ${A} + ${B};
    V_SUB = ${A} - ${B};
    V_MUL = ${A} * ${B};
    V_DIV = ${A} / ${B};

    // 比较运算
    V_EQ = ${A} == ${B};
    V_NE = ${A} != ${B};
    V_GT = ${A} > ${B};
    V_LT = ${A} lt ${B};

    // 逻辑运算
    V_AND = ${A} and ${B};
    V_OR = ${A} or ${B};
    V_NOT = !${A};

    // IN运算
    V_IN = ${A} in [1, 2, 3];
    V_NOTIN = ${A} notin ['a', 'b'];
</lang-eval-ts>
```

### 6.4 控制结构

```xml

<lang-eval-ts>
    // if-else
    if(${A} > 10) {
        V_RESULT = '大';
    } else if(${A} > 5) {
        V_RESULT = '中';
    } else {
        V_RESULT = '小';
    };

    // for循环
    for(i = 0; ${i} lt 10; i = ${i} + 1) {
        V_SUM = ${V_SUM} + ${i};
    };

    // foreach循环
    foreach(item : ${itemList}) {
        V_TOTAL = ${V_TOTAL} + ${item.value};
    };

    // while循环
    while(${i} lt 10) {
        i = ${i} + 1;
    };
</lang-eval-ts>
```

### 6.5 常用函数

```xml

<lang-eval-ts>
    // 字符串函数
    V_LEN = length('hello');
    V_TRIM = trim(' abc ');
    V_UPPER = upper('abc');
    V_LOWER = lower('ABC');
    V_SUB = substr('abcdef', 0, 3);
    V_REP = replace('abc', 'a', 'x');
    V_LIKE = like('abc', 'a');

    // 空值处理
    V_NVL = nvl(${V_NULL}, 'default');
    V_EMP = is_empty(${V_STR});
    V_NULL2 = isnull(${V_VAL});

    // 日期函数
    V_NOW = now();
    V_ADD = add_days(${V_NOW}, 7);
    V_FMT = date_format(${V_NOW}, 'yyyy-MM-dd');

    // 类型转换
    V_INT = to_int('123');
    V_LONG = to_long('123');
    V_NUM = to_number('123.45');
</lang-eval-ts>
```

---

## 七、Spring Boot集成详解

### 7.1 配置属性说明

| 属性                                  | 说明        | 默认值                             |
|-------------------------------------|-----------|---------------------------------|
| `xproc4j.enable`                    | 是否启用框架    | `true`                          |
| `xproc4j.debug`                     | 调试模式      | `false`                         |
| `xproc4j.reportOnBoot`              | 启动时生成报告   | `true`                          |
| `xproc4j.xmlLocations`              | XML文件扫描路径 | `classpath*:procedure/**/*.xml` |
| `xproc4j.watchingDirectories`       | 热加载监听目录   | `classpath*:procedure/`         |
| `xproc4j.refreshXmlIntervalSeconds` | XML刷新间隔   | `-1`（不刷新）                       |
| `xproc4j.slowSqlMinMillsSeconds`    | 慢SQL阈值    | `5000ms`                        |
| `xproc4j.slowNodeMillsSeconds`      | 慢节点阈值     | `15000ms`                       |
| `xproc4j.slowProcedureMillsSeconds` | 慢过程阈值     | `30000ms`                       |

### 7.2 Java调用方式

**方式一：使用静态Helper**

```java
import ....springboot.jdbc.bql.procedure.JdbcProcedureHelper;

// 函数调用
int result = JdbcProcedureHelper.invoke("F_GET_NAME", map -> {
    map.put("IN_ID", 123);
    return map;
});

// 过程调用
Map<String, Object> result = JdbcProcedureHelper.call("SP_PROCESS", map -> {
    map.put("IN_PARAM", "value");
    return map;
});
```

**方式二：注入Executor**

```java
import ....jdbc.procedure.executor.JdbcProcedureExecutor;
import org.springframework.beans.factory.annotation.Autowired;

@Autowired
private JdbcProcedureExecutor executor;

// 函数调用
int result = executor.invoke("F_GET_NAME", map -> {
    map.put("IN_ID", 123);
    return map;
});

// 过程调用
Map<String, Object> result = executor.call("SP_PROCESS", map -> {
    map.put("IN_PARAM", "value");
    return map;
});
```

**方式三：获取静态Executor**

```java
JdbcProcedureExecutor executor = JdbcProcedureHelper.getExecutor();
Map<String, Object> result = executor.call("SP_PROCESS", new HashMap<>());
```

### 7.3 数据源映射

```java
Map<String, Object> result = JdbcProcedureHelper.call("SP_PROCESS", map -> {
    map.put("IN_PARAM", "value");
    // 设置数据源映射
    map.put("datasourcesMapping", new HashMap<String, String>() {{
        put("primary", "ods");  // 默认数据源指向ods
    }});
    return map;
});
```

---

## 八、调试与日志

### 8.1 开启调试模式

```yaml
xproc4j:
  debug: true
```

### 8.2 断点调试

在IDE中对以下位置设置断点：

1. `AbstractExecutorNode.exec()` - 通用节点执行断点
2. `DefaultTinyScriptResolver.openDebugger()` - TinyScript脚本断点

条件断点示例：

```java
location.startsWith("test.xml:10") 
    && context. get("V_STATUS") ==null
```

### 8.3 日志节点使用

```xml

<log-debug value.render="调试信息: $!{V_VALUE}"/>
<log-info value.string="处理中..."/>
<log-error value.render="错误: $!{trace.errmsg}" e="e"/>
```

---

## 九、常见问题

### 9.1 NULL值处理

在Oracle等数据库中，NULL拼接会变为空字符串：

```xml
<!-- 错误示例，因为 render 是使用 Velocity,如果值为null，则最终显示结果会显示  ${TABLE_NAME} 原样，不进行渲染-->
<lang-set result="V_SQL" value.render="SELECT * FROM ${TABLE_NAME}"/>

<!-- 正确示例，使用 $!{} 处理，如果null则显示空字符串 -->
<lang-set result="V_SQL" value.render="SELECT * FROM $!{TABLE_NAME}"/>
```

### 9.2 变量大小写

Java环境中变量区分大小写，建议统一使用大写或小写。

### 9.3 SQL注入防护

尽量使用 `#{}` 占位符而非 `${}` 字符串替换：
但是注意，`#{}` 只能在 `sql-*` 标签中

```xml
<!-- 安全 -->
<sql-query-row>
    SELECT * FROM user WHERE id = #{V_ID}
</sql-query-row>

<!-- 存在SQL注入风险 -->
<sql-query-row>
    SELECT * FROM user WHERE name = '${V_NAME}'
</sql-query-row>
```

---

## 十一、内建函数

### 11.1 概述

框架在内建函数方面采用了分层架构设计，通过多个接口和提供器类来组织和管理内建函数。这些内建函数在 `<lang-eval-ts>`
节点对应的TinyScript执行环境中可用，允许在脚本中直接调用。

**核心组件：**

| 组件                          | 文件位置                                                                                                                                                       | 说明                 |
|-----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------|
| ContextFunctions            | [ContextFunctions.java](/src/main/java/.../jdbc/procedure/context/ContextFunctions.java)                                    | 基础内建函数接口，提供通用函数实现  |
| TinyScriptFunctions         | [TinyScriptFunctions.java](/src/main/java/.../extension/antlr4/script/tiny/impl/context/TinyScriptFunctions.java)           | TinyScript环境独有函数   |
| ExecutorMethodProvider      | [ExecutorMethodProvider.java](/src/main/java/.../jdbc/procedure/node/impl/tinyscript/ExecutorMethodProvider.java)           | 执行器方法提供器           |
| ExecContextMethodProvider   | [ExecContextMethodProvider.java](/src/main/java/.../jdbc/procedure/node/impl/tinyscript/ExecContextMethodProvider.java)     | 执行上下文方法提供器         |
| ProcedureTinyScriptResolver | [ProcedureTinyScriptResolver.java](/src/main/java/.../jdbc/procedure/node/impl/tinyscript/ProcedureTinyScriptResolver.java) | 框架集成TinyScript的解析器 |

**执行流程：**

```
<lang-eval-ts>节点
       ↓
LangEvalTinyScriptNode.evalTinyScript()
       ↓
ProcedureTinyScriptResolver(集成了Executor和ExecContextMethods)
       ↓
TinyScript解析并执行
       ↓
findMethod()方法按优先级查找:
  1. ContextHolder.INVOKE_METHOD_MAP (用户注册的方法)
  2. ExecutorMethodProvider中的方法
  3. ExecContextMethodProvider中的方法
  4. TinyScriptFunctions中的方法
  5. TinyScript内置方法(String, Math, System等)
```

### 11.2 ContextFunctions 基础内建函数

`ContextFunctions` 是框架最核心的内建函数接口，提供约200+个函数，涵盖字符串处理、日期计算、数值运算、正则表达式、空值判断等常见操作。

**空值处理函数：**

| 函数名                     | 说明                 | 示例                           |
|-------------------------|--------------------|------------------------------|
| `isnull(obj)`           | 判断是否为空             | `isnull(${V_NAME})`          |
| `is_empty(obj)`         | 判断是否为空(包含空字符串、空集合) | `is_empty(${V_LIST})`        |
| `is_blank(obj)`         | 判断是否为空白(包含空格、制表符)  | `is_blank(${V_STR})`         |
| `nvl(v1, v2)`           | 如果v1为空返回v2         | `nvl(${V_NULL}, 'default')`  |
| `ifnull(v1, v2)`        | 同nvl               | `ifnull(${V_VAL}, 0)`        |
| `nullif(v1, v2)`        | 如果v1等于v2返回null     | `nullif(${A}, ${B})`         |
| `if_empty(v1, v2)`      | 如果v1为空返回v2         | `if_empty(${V_STR}, '')`     |
| `if_blank(v1, v2)`      | 如果v1为空白返回v2        | `if_blank(${V_STR}, 'N/A')`  |
| `coalesce(v1, v2, ...)` | 返回第一个非空值           | `coalesce(${A}, ${B}, ${C})` |

**字符串函数：**

| 函数名                        | 说明     | 示例                           |
|----------------------------|--------|------------------------------|
| `trim(str)`                | 去除首尾空白 | `trim(${V_NAME})`            |
| `upper(str)`               | 转大写    | `upper('abc')`               |
| `lower(str)`               | 转小写    | `lower('ABC')`               |
| `left(obj, len)`           | 取左边字符串 | `left('hello', 2)`           |
| `right(obj, len)`          | 取右边字符串 | `right('hello', 2)`          |
| `substr(obj, index)`       | 截取字符串  | `substr('abcdef', 0, 3)`     |
| `replace(str, target)`     | 字符串替换  | `replace('abc', 'a', 'x')`   |
| `concat(args...)`          | 字符串连接  | `concat('a', 'b', 'c')`      |
| `join(separator, args...)` | 分隔符连接  | `join(',', 'a', 'b', 'c')`   |
| `split(str, literal)`      | 字符串分割  | `split('a,b,c', ',')`        |
| `length(obj)`              | 获取长度   | `length('hello')`            |
| `lengthb(obj)`             | 获取字节长度 | `lengthb('你好')`              |
| `instr(obj, sub)`          | 子串位置   | `instr('hello', 'll')`       |
| `index_of(str, substr)`    | 子串位置   | `index_of(${V_STR}, 'test')` |

**正则表达式函数：**

| 函数名                                      | 说明   | 示例                                    |
|------------------------------------------|------|---------------------------------------|
| `regex_replace(str, regex, replacement)` | 正则替换 | `regex_replace('a1b2', '[0-9]', '#')` |
| `regex_match(str, regex)`                | 正则匹配 | `regex_match('abc123', '[0-9]+')`     |
| `regex_find(str, regex)`                 | 正则查找 | `regex_find('a1b2', '[0-9]')`         |
| `regex_contains(str, regex)`             | 正则包含 | `regex_contains(${V_STR}, 'pattern')` |
| `regex_split(str, regex)`                | 正则分割 | `regex_split('a1b2', '[0-9]')`        |
| `regexp_like(str, regex)`                | 正则相似 | `regexp_like(${V_STR}, '^[a-z]+$')`   |

**日期函数：**

| 函数名                          | 说明      | 示例                                                |
|------------------------------|---------|---------------------------------------------------|
| `now()`                      | 当前时间    | `now()`                                           |
| `sysdate()`                  | 系统时间    | `sysdate()`                                       |
| `to_date(obj)`               | 字符串转日期  | `to_date('2025-01-01')`                           |
| `to_date(obj, pattern)`      | 指定格式转日期 | `to_date('2025-01-01 10:30', 'yyyy-MM-dd HH:mm')` |
| `date_format(date, pattern)` | 日期格式化   | `date_format(${V_DATE}, 'yyyy-MM-dd')`            |
| `add_days(date, interval)`   | 日期加减天数  | `add_days(${V_DATE}, 7)`                          |
| `add_months(date, interval)` | 日期加减月数  | `add_months(${V_DATE}, 1)`                        |
| `trunc(date, format)`        | 日期截断    | `trunc(${V_DATE}, 'dd')`                          |
| `last_day(date)`             | 月末日期    | `last_day(${V_DATE})`                             |
| `first_day(date)`            | 月初日期    | `first_day(${V_DATE})`                            |
| `year(date)`                 | 获取年份    | `year(${V_DATE})`                                 |
| `month(date)`                | 获取月份    | `month(${V_DATE})`                                |
| `day(date)`                  | 获取日     | `day(${V_DATE})`                                  |

**数值函数：**

| 函数名                          | 说明       | 示例                    |
|------------------------------|----------|-----------------------|
| `to_number(obj)`             | 转数值      | `to_number('123.45')` |
| `to_int(obj)`                | 转整数      | `to_int('123')`       |
| `to_long(obj)`               | 转长整数     | `to_long('123456')`   |
| `round(number)`              | 四舍五入     | `round(3.14159)`      |
| `round(number, precision)`   | 指定精度四舍五入 | `round(3.14159, 2)`   |
| `trunc(number)`              | 数值截断     | `trunc(3.14159)`      |
| `abs(number)`                | 绝对值      | `abs(-5)`             |
| `add(n1, n2)`                | 加法       | `add(${A}, ${B})`     |
| `sub(n1, n2)`                | 减法       | `sub(${A}, ${B})`     |
| `mul(n1, n2)`                | 乘法       | `mul(${A}, ${B})`     |
| `div(n1, n2)`                | 除法       | `div(${A}, ${B})`     |
| `mod(n1, n2)`                | 取模       | `mod(${A}, ${B})`     |
| `pow(n1, n2)`                | 幂运算      | `pow(2, 3)`           |
| `sqrt(number)`               | 平方根      | `sqrt(16)`            |
| `sin(n)`, `cos(n)`, `tan(n)` | 三角函数     | `sin(0)`              |

**编解码函数：**

| 函数名                  | 说明       | 示例                            |
|----------------------|----------|-------------------------------|
| `encode_base64(obj)` | Base64编码 | `encode_base64('hello')`      |
| `decode_base64(obj)` | Base64解码 | `decode_base64('aGVsbG8=')`   |
| `encode_url(obj)`    | URL编码    | `encode_url('hello world')`   |
| `decode_url(obj)`    | URL解码    | `decode_url('hello%20world')` |
| `md5(data)`          | MD5哈希    | `md5('hello')`                |
| `sha256(data)`       | SHA256哈希 | `sha256('hello')`             |

**其他工具函数：**

| 函数名                       | 说明                    | 示例                                            |
|---------------------------|-----------------------|-----------------------------------------------|
| `uuid()`                  | 生成UUID                | `uuid()`                                      |
| `snowflake_id()`          | 生成雪花ID                | `snowflake_id()`                              |
| `decode(target, args...)` | 解码函数(类似Oracle decode) | `decode(${V_STATUS}, 1, '正常', 0, '禁用', '未知')` |
| `cast(val, type)`         | 类型转换                  | `cast(${V_STR}, 'java.util.Date')`            |
| `sleep(seconds)`          | 线程睡眠                  | `sleep(1)`                                    |
| `println(obj...)`         | 打印并换行                 | `println('result:', ${V_RESULT})`             |

### 11.3 TinyScriptFunctions TinyScript独有函数

`TinyScriptFunctions` 提供TinyScript环境独有的函数，定义在 `TinyScript.java` 的静态初始化块中注册。

**随机函数：**

| 函数名              | 说明               | 示例            |
|------------------|------------------|---------------|
| `rand()`         | 返回随机整数           | `rand()`      |
| `rand(bound)`    | 返回0到bound之间的随机整数 | `rand(100)`   |
| `rand(min, max)` | 返回min到max之间的随机整数 | `rand(1, 10)` |
| `random()`       | 返回0到1之间的随机小数     | `random()`    |

**集合操作函数：**

| 函数名                           | 说明     | 示例                                  |
|-------------------------------|--------|-------------------------------------|
| `new_list()`                  | 创建新列表  | `new_list()`                        |
| `new_map()`                   | 创建新映射  | `new_map()`                         |
| `new_set()`                   | 创建新集合  | `new_set()`                         |
| `append(collection, objs...)` | 添加元素   | `append(${V_LIST}, 'a', 'b')`       |
| `list_get(list, index)`       | 获取列表元素 | `list_get(${V_LIST}, 0)`            |
| `list_remove(list, index)`    | 移除列表元素 | `list_remove(${V_LIST}, 0)`         |
| `map_get(map, key)`           | 获取Map值 | `map_get(${V_MAP}, 'key')`          |
| `map_put(map, key, value)`    | 设置Map值 | `map_put(${V_MAP}, 'key', 'value')` |

**线程本地存储函数：**

| 函数名                     | 说明        | 示例                         |
|-------------------------|-----------|----------------------------|
| `local_map()`           | 获取线程本地Map | `local_map()`              |
| `local_get(key)`        | 获取线程本地值   | `local_get('userId')`      |
| `local_set(key, value)` | 设置线程本地值   | `local_set('userId', 123)` |
| `local_remove(key)`     | 移除线程本地值   | `local_remove('userId')`   |
| `local_contains(key)`   | 判断是否包含    | `local_contains('userId')` |
| `local_reset()`         | 重置线程本地Map | `local_reset()`            |

**数组操作函数：**

| 函数名                          | 说明      | 示例                                  |
|------------------------------|---------|-------------------------------------|
| `new_array(elemType, len)`   | 创建数组    | `new_array('java.lang.String', 10)` |
| `is_array(arr)`              | 判断是否为数组 | `is_array(${V_ARR})`                |
| `arr_len(arr)`               | 获取数组长度  | `arr_len(${V_ARR})`                 |
| `arr_get(arr, index)`        | 获取数组元素  | `arr_get(${V_ARR}, 0)`              |
| `arr_set(arr, index, value)` | 设置数组元素  | `arr_set(${V_ARR}, 0, 'newValue')`  |
| `arr_to_list(arr)`           | 数组转列表   | `arr_to_list(${V_ARR})`             |
| `list_to_array(list)`        | 列表转数组   | `list_to_array(${V_LIST})`          |

**比较函数：**

| 函数名               | 说明   | 示例                    |
|-------------------|------|-----------------------|
| `compare(v1, v2)` | 比较大小 | `compare(${A}, ${B})` |
| `cmp_eq(v1, v2)`  | 判断相等 | `cmp_eq(${A}, ${B})`  |
| `cmp_neq(v1, v2)` | 判断不等 | `cmp_neq(${A}, ${B})` |
| `cmp_gt(v1, v2)`  | 大于   | `cmp_gt(${A}, ${B})`  |
| `cmp_lt(v1, v2)`  | 小于   | `cmp_lt(${A}, ${B})`  |
| `cmp_gte(v1, v2)` | 大于等于 | `cmp_gte(${A}, ${B})` |
| `cmp_lte(v1, v2)` | 小于等于 | `cmp_lte(${A}, ${B})` |

**文件操作函数：**

| 函数名                 | 说明       | 示例                             |
|---------------------|----------|--------------------------------|
| `file(path)`        | 创建File对象 | `file('/tmp/test.txt')`        |
| `file_exists(path)` | 判断文件是否存在 | `file_exists('/tmp/test.txt')` |
| `is_file(path)`     | 判断是否为文件  | `is_file('/tmp/test.txt')`     |
| `is_dir(path)`      | 判断是否为目录  | `is_dir('/tmp')`               |
| `list_file(path)`   | 列出目录文件   | `list_file('/tmp')`            |

### 11.4 ExecutorMethodProvider 执行器方法

`ExecutorMethodProvider` 提供访问执行器功能的方法，在 `ProcedureTinyScriptResolver.findMethod()` 中注册。

**执行器操作函数：**

| 函数名                           | 说明           | 示例                                 |
|-------------------------------|--------------|------------------------------------|
| `load_class(className)`       | 加载类          | `load_class('java.util.Date')`     |
| `is_debug()`                  | 是否调试模式       | `is_debug()`                       |
| `get_bean(name)`              | 获取Bean       | `get_bean('userService')`          |
| `get_bean(type)`              | 按类型获取Bean    | `get_bean('com.demo.UserService')` |
| `get_meta(procedureId)`       | 获取过程元数据      | `get_meta('SP_TEST')`              |
| `env(property)`               | 获取环境变量       | `env('JAVA_HOME')`                 |
| `env(property, defaultValue)` | 获取环境变量(带默认值) | `env('MODE', 'prod')`              |
| `env_int(property)`           | 获取整型环境变量     | `env_int('MAX_SIZE')`              |
| `env_long(property)`          | 获取长整型环境变量    | `env_long('TIMEOUT')`              |

**跟踪日志函数：**

| 函数名                  | 说明      | 示例                            |
|----------------------|---------|-------------------------------|
| `trace_location()`   | 获取跟踪位置  | `trace_location()`            |
| `trace_file()`       | 获取跟踪文件  | `trace_file()`                |
| `trace_line()`       | 获取跟踪行号  | `trace_line()`                |
| `trace_node()`       | 获取跟踪节点  | `trace_node()`                |
| `trace_error()`      | 获取跟踪错误  | `trace_error()`               |
| `trace_errmsg()`     | 获取错误消息  | `trace_errmsg()`              |
| `tracking_comment()` | 获取跟踪注释  | `tracking_comment()`          |
| `log_debug(obj)`     | Debug日志 | `log_debug('debug message')`  |
| `log_info(obj)`      | Info日志  | `log_info('info message')`    |
| `log_warn(obj)`      | Warn日志  | `log_warn('warning message')` |
| `log_error(obj)`     | Error日志 | `log_error('error message')`  |

### 11.5 ExecContextMethodProvider 执行上下文方法

`ExecContextMethodProvider` 提供执行上下文相关的方法，绑定到当前执行上下文。

**表达式执行函数：**

| 函数名                            | 说明             | 示例                                  |
|--------------------------------|----------------|-------------------------------------|
| `eval(script)`                 | 执行TinyScript脚本 | `eval('${A} + ${B}')`               |
| `eval_script(lang, script)`    | 执行指定语言脚本       | `eval_script('javascript', '1+1')`  |
| `render(template)`             | 渲染Velocity模板   | `render('SELECT * FROM $!{TABLE}')` |
| `visit(expression)`            | 访问上下文值         | `visit('user.name')`                |
| `visit_set(expression, value)` | 设置上下文值         | `visit_set('user.name', '张三')`      |
| `visit_delete(expression)`     | 删除上下文值         | `visit_delete('user.name')`         |
| `test(expression)`             | 测试布尔表达式        | `test('A > 0 and B < 10')`          |

**事务控制函数：**

| 函数名                                | 说明         | 示例                              |
|------------------------------------|------------|---------------------------------|
| `sql_trans_begin(datasource)`      | 开启事务       | `sql_trans_begin('primary')`    |
| `sql_trans_commit(datasource)`     | 提交事务       | `sql_trans_commit('primary')`   |
| `sql_trans_rollback(datasource)`   | 回滚事务       | `sql_trans_rollback('primary')` |
| `sql_trans_none(datasource)`       | 关闭事务(自动提交) | `sql_trans_none('primary')`     |
| `get_connection(datasource)`       | 获取数据库连接    | `get_connection('ods')`         |
| `sql_adapt(datasource, databases)` | SQL方言适配    | `sql_adapt('primary', 'mysql')` |

**SQL查询函数：**

| 函数名                                                      | 说明        | 示例                                                                                 |
|----------------------------------------------------------|-----------|------------------------------------------------------------------------------------|
| `sql_query_object(datasource, sql, args...)`             | 查询单个对象    | `sql_query_object('primary', 'SELECT COUNT(*) FROM user')`                         |
| `sql_query_row(datasource, sql, args...)`                | 查询单行      | `sql_query_row('primary', 'SELECT * FROM user WHERE id=?', 1)`                     |
| `sql_query_list(datasource, sql, args...)`               | 查询列表      | `sql_query_list('ods', 'SELECT * FROM order WHERE status=?', 1)`                   |
| `sql_query_page(datasource, offset, size, sql, args...)` | 分页查询      | `sql_query_page('primary', 0, 10, 'SELECT * FROM user')`                           |
| `sql_query_columns(datasource, sql, args...)`            | 查询列信息     | `sql_query_columns('primary', 'SELECT * FROM user where 1!=1')`                    |
| `sql_update(datasource, sql, args...)`                   | 更新操作      | `sql_update('primary', 'UPDATE user SET name=? WHERE id=?', '张三', 1)`              |
| `sql_script_query_object(datasource, sql)`               | XML脚本查询对象 | `sql_script_query_object('primary', 'SELECT name FROM user where id=#{V_USER}', )` |
| `sql_script_query_row(datasource, sql)`                  | XML脚本查询单行 | `sql_script_query_row('primary', 'SELECT * FROM user WHERE id=#{V_USER}')`         |
| `sql_script_query_list(datasource, sql)`                 | XML脚本查询列表 | `sql_script_query_list('ods', 'SELECT * FROM order')`                              |
| `sql_script_update(datasource, sql)`                     | XML脚本更新   | `sql_script_update('primary', 'DELETE FROM user WHERE id=#{V_USER}')`              |

### 11.6 内建函数注册流程

框架的内建函数注册采用多层架构，通过 `ContextHolder` 和 `TinyScript` 类的静态初始化块完成。

**ContextFunctions 注册流程：**

```
1. ContextHolder 静态初始化块 (第50行)
   └─→ registryInvokeMethodByInstanceMethod(ContextFunctions.INSTANCE)

2. registryInvokeMethodByInstanceMethod() 遍历所有public方法
   └─→ 对每个方法检查 JdbcProcedureFunction 注解
       └─→ 注册到 INVOKE_METHOD_MAP (方法名 → IMethod列表)

3. 在 TinyScript 静态块 (第69行)
   └─→ registryBuiltMethodByInstanceMethod(TinyScriptFunctions.INSTANCE)
```

**ProcedureTinyScriptResolver 方法查找流程：**

```
findMethod(naming, args)
    │
    ├─→ 1. 查找 ContextHolder.INVOKE_METHOD_MAP
    │       └─→ ReflectResolver.matchExecMethod()
    │
    ├─→ 2. 查找 ExecutorMethodProvider (executorMethods缓存)
    │       └─→ ReflectResolver.matchExecutable()
    │       └─→ 包装为 JdkInstanceStaticMethod
    │
    ├─→ 3. 查找 ExecContextMethodProvider (execContextMethods缓存)
    │       └─→ ReflectResolver.matchExecutable()
    │       └─→ 包装为 JdkInstanceStaticMethod
    │
    └─→ 4. 调用父类 DefaultTinyScriptResolver.findMethod()
            └─→ 查找 TinyScript.BUILTIN_METHOD
```

**TinyScript 内置方法注册：**

```
TinyScript 静态初始化块注册:
├─→ String类: join, format
├─→ Integer类: to*, parse*
├─→ Long类: to*, parse*
├─→ Double类: to*, parse*
├─→ Float类: to*, parse*
├─→ Boolean类: to*, parse*
├─→ Math类: 所有非copy/next开头的方法
├─→ Thread类: sleep, yield
├─→ System类: 所有静态方法
├─→ TinyScriptFunctions.INSTANCE: 所有实例方法
└─→ System.out: print开头的方法
```

### 11.7 使用示例

**基本函数调用：**

```xml

<lang-eval-ts>
    // 字符串函数
    V_UPPER = upper('hello');
    V_TRIM = trim(' abc ');
    V_LEN = length('hello');

    // 空值处理
    V_DEFAULT = nvl(${V_NULL}, 'default');
    V_COALESCE = coalesce(${A}, ${B}, ${C}, 'none');

    // 日期函数
    V_TODAY = now();
    V_FUTURE = add_days(${V_TODAY}, 7);
    V_MONTH_END = last_day(${V_DATE});

    // 数值函数
    V_ROUND = round(3.14159, 2);
    V_ABS = abs(-5);
</lang-eval-ts>
```

**执行上下文操作：**

```xml

<lang-eval-ts>
    // 访问上下文变量
    V_USER_NAME = visit('user.name');

    // 设置上下文变量
    visit_set('result.status', 'success');

    // 执行SQL查询
    V_USER = sql_query_row('primary', 'SELECT * FROM user WHERE id=?', userId);
    V_LIST = sql_query_list('ods', 'SELECT * FROM order WHERE status=?', 1);

    // 模板渲染
    V_SQL = render('SELECT * FROM $!{TABLE_NAME} WHERE status=$!{STATUS}');
</lang-eval-ts>
```

**执行器方法调用：**

```xml

<lang-eval-ts>
    // 获取Bean
    V_SERVICE = get_bean('userService');

    // 环境变量
    V_MODE = env('APP_MODE', 'prod');

    // 获取过程元数据
    V_META = get_meta('SP_TEST_PROC');

    // 日志记录
    log_info('Processing: ' + ${V_NAME});

    // 跟踪信息
    log_debug('Current location: ' + trace_location() + ':' + trace_line());
</lang-eval-ts>
```

**集合与数组操作：**

```xml

<lang-eval-ts>
    // 创建并操作列表
    V_LIST = new_list();
    append(${V_LIST}, 'a', 'b', 'c');
    V_ITEM = list_get(${V_LIST}, 0);

    // 创建并操作Map
    V_MAP = new_map();
    map_put(${V_MAP}, 'key1', 'value1');
    V_VAL = map_get(${V_MAP}, 'key1');

    // 线程本地存储
    local_set('cache', 'data');
    V_CACHE = local_get('cache');
</lang-eval-ts>
```

### 11.8 验证依据

本章内容严格基于以下源代码文件：

| 文件                                                                                                                                                         | 验证内容                      |
|------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------|
| [ContextFunctions.java](/src/main/java/.../jdbc/procedure/context/ContextFunctions.java)                                    | 第43-2440行定义的所有内建函数        |
| [TinyScriptFunctions.java](/src/main/java/.../extension/antlr4/script/tiny/impl/context/TinyScriptFunctions.java)           | 第18-509行定义的所有TinyScript函数 |
| [ExecutorMethodProvider.java](/src/main/java/.../jdbc/procedure/node/impl/tinyscript/ExecutorMethodProvider.java)           | 第18-146行定义的所有执行器方法        |
| [ExecContextMethodProvider.java](/src/main/java/.../jdbc/procedure/node/impl/tinyscript/ExecContextMethodProvider.java)     | 第19-134行定义的所有执行上下文方法      |
| [ProcedureTinyScriptResolver.java](/src/main/java/.../jdbc/procedure/node/impl/tinyscript/ProcedureTinyScriptResolver.java) | 第42-199行定义的方法查找和注册流程      |
| [ContextHolder.java](/src/main/java/.../jdbc/procedure/context/ContextHolder.java)                                          | 第49-63行静态初始化和注册方法         |
| [TinyScript.java](/src/main/java/.../extension/antlr4/script/tiny/impl/TinyScript.java)                                     | 第34-87行静态初始化和内置方法注册       |
| [LangEvalTinyScriptNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangEvalTinyScriptNode.java)                      | 第41-60行TinyScript执行入口     |

---

**文档版本：** 1.0  
**最后更新：** 2026-04-02  
**维护者：** Ice2Faith