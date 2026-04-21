# jdbc-procedure XML节点定义白皮书

## 一、概述

### 1.1 文档目的

本文档提供 jdbc-procedure (XProc4J) 框架中所有 XML 节点的完整定义说明，包括节点功能、属性定义、属性修饰符、默认值及使用示例。本文档严格基于
`procedure.xml` 配置文件和 node 源码实现编写，确保信息准确完整。

### 1.2 节点分类

框架中的 XML 节点按功能分为以下几类：

| 分类      | 前缀                               | 说明             |
|---------|----------------------------------|----------------|
| 日志节点    | log-*                            | 日志输出           |
| 调试节点    | debugger                         | 断点调试           |
| 语言控制节点  | lang-*                           | 流程控制、变量操作、脚本执行 |
| SQL操作节点 | sql-*                            | 数据库查询、更新、事务控制  |
| 过程调用节点  | procedure-*/function-*/java-call | 存储过程/函数调用      |
| 脚本片段节点  | script-*                         | 代码复用           |
| 事件节点    | event-*                          | 事件发送发布         |
| 上下文节点   | context-*                        | 上下文管理          |
| ETL节点   | sql-etl/etl-*                    | 数据抽取加载         |

---

## 二、属性修饰符详解

### 2.1 修饰符概念

- 属性修饰符（Feature）用于描述属性值的获取方式和类型转换规则。用在输入时表示值怎么取，用在输出时表示输出的目标类型。
- 多个修饰符可以顺序执行，用 `.` 小数点隔开。
- 属性修饰符使用在XML的属性上，第一个修饰符表示了怎么看待属性值的含义
- 例如 `value.int="1"` 第一个属性修饰符是 `int` ，此时的属性值是 "1" ，那么就是把属性值转换成 int 类型的数字 1
- 同样的，有的功能节点具有默认修饰符，就表示在没有明确写修饰符的时候，第一个修饰符就是按照默认修饰符来运行的
- 例如 `<lang-set value="V_NAME"/>"` , `lang-set` 的 `value` 默认以 `visit` 访问（默认修饰符）
- 就表示 `value` 属性默认行为是 `visit` ，也就是第一个修饰符，也就是把属性值 `V_NAME` 当做变量名，而不是一个普通的字符串
- 而 `<lang-set value.string="V_NAME"/>"` ，这里明确了修饰符 `string` ，因此第一个修饰符就是 `string` ，覆盖了默认行为，就把属性值
  `V_NAME` 当做一个普通字符串，而不是一个变量

**语法格式：**

```xml
属性名.修饰符1.修饰符2="值"
```

### 2.2 基础类型修饰符

| 修饰符        | 说明   | 示例                     |
|------------|------|------------------------|
| `.int`     | 整型   | `value.int="1"`        |
| `.long`    | 长整型  | `value.long="123456"`  |
| `.double`  | 浮点型  | `value.double="3.14"`  |
| `.float`   | 短浮点型 | `value.float="1.5"`    |
| `.short`   | 短整型  | `value.short="100"`    |
| `.byte`    | 字节型  | `value.byte="255"`     |
| `.char`    | 字符型  | `value.char="a"`       |
| `.boolean` | 布尔型  | `value.boolean="true"` |
| `.string`  | 字符串型 | `value.string="text"`  |

### 2.3 值获取方式修饰符

| 修饰符       | 说明             | 属性值含义                                |
|-----------|----------------|--------------------------------------|
| `.visit`  | 从上下文访问值（OGNL）  | 表示变量名                                |
| `.eval`   | 计算表达式值（OGNL）   | 表示OGNL表达式                            |
| `.render` | 模板渲染（Velocity） | 表示Velocity表达式                        |
| `.test`   | 布尔表达式测试（OGNL）  | 表示ONGL表达式，且运算结果会隐式转换为boolean类型进行条件判断 |
| `.null`   | 空值             | 表示null常量，此时的属性值将会被忽略，也就是不管属性值是什么     |
| `.string` | 字符串字面值         | 将属性值看做普通字符串                          |

### 2.4 特殊值修饰符

| 修饰符                    | 说明               | 示例                             |
|------------------------|------------------|--------------------------------|
| `.date-now`            | 当前时间（new Date()） | `value.date-now=""`            |
| `.uuid`                | 随机UUID           | `value.uuid=""`                |
| `.current-time-millis` | 当前毫秒值            | `value.current-time-millis=""` |
| `.snow-uid`            | 雪花ID             | `value.snow-uid=""`            |

### 2.5 内容获取修饰符

| 修饰符          | 说明            | 示例                                 |
|--------------|---------------|------------------------------------|
| `.body-text` | 从标签内部获取文本     | `<tag value.body-text="">文本</tag>` |
| `.body-xml`  | 从标签内部获取XML    | `<tag value.body-xml="">内容</tag>`  |
| `.trim`      | 去除首尾空白        | `value.trim=" text "`              |
| `.align`     | 对齐格式（需`\|`引导） | `value.align="\| text"`            |

### 2.6 布尔判断修饰符

| 修饰符             | 说明         | 示例                         |
|-----------------|------------|----------------------------|
| `.is-null`      | 判断是否为null  | `value.is-null="var"`      |
| `.is-not-null`  | 判断是否不为null | `value.is-not-null="var"`  |
| `.is-empty`     | 判断是否为空     | `value.is-empty="var"`     |
| `.is-not-empty` | 判断是否不为空    | `value.is-not-empty="var"` |
| `.not`          | boolean值取反 | `value.not="true"`         |

### 2.7 脚本执行修饰符

| 修饰符                             | 说明                                     | 示例                                 |
|---------------------------------|----------------------------------------|------------------------------------|
| `.eval`                         | Ognl表达式执行，属性内就需要是符合Ognl的表达式            | `value.eval="cnt+1"`               |
| `.eval-java`                    | Java表达式执行，属性内就需要是符合Java的表达式            | `value.eval-java="new Date()"`     |
| `.eval-js`                      | JavaScript脚本执行，属性内就需要是符合JavaScript的表达式 | `value.eval-js="1+1"`              |
| `.eval-tinyscript` / `.eval-ts` | TinyScript脚本执行，属性内就需要是符合TinyScript的表达式 | `value.eval-ts="${a}+1"`           |
| `.eval-groovy`                  | Groovy脚本执行，属性内就需要是符合Groovy的表达式         | `value.eval-groovy="println 'hi'"` |

### 2.8 异常Cause链修饰符

| 修饰符            | 说明                 | 示例                                |
|----------------|--------------------|-----------------------------------|
| `.cause-first` | 获取cause链中第一个匹配的异常  | `type.cause-first="SQLException"` |
| `.cause-last`  | 获取cause链中最后一个匹配的异常 | `type.cause-last="SQLException"`  |
| `.cause-raw`   | 获取框架层面原始异常         | `type.cause-raw=""`               |
| `.cause-root`  | 获取cause链最后一个根异常    | `type.cause-root=""`              |

### 2.9 数据库方言修饰符

| 修饰符        | 说明                                  | 示例                            |
|------------|-------------------------------------|-------------------------------|
| `.dialect` | 指定数据库类型，一般需要搭配 `datasource` 属性指定数据源 | `test.dialect="mysql,oracle"` |

### 2.10 修饰符使用示例

**修饰符链示例：**

```xml

<lang-set result="v_val" value.string.long.int="1"/>
```

- 解释：先获取属性值字符串 "1"，第一个修饰符是string，表示将属性值看做string，后续的修饰符依次转为long再转为int，最终结果为整型1。
- 修饰符链，其实是一个处理管道：属性值 "1" > `string` 转换 > `long` 转换 > `int` 转换 > 结果存入 `result` 属性指定的变量名
  `v_val` 中。

**覆盖默认修饰符：**

```xml
<!-- value默认是visit修饰符，也就是属性值表示的是一个变量名，使用value.string将行为改为直接输入字符串，此时的属性值旧表示一个字符串 -->
<lang-set result="v_name" value.string="张三"/>

        <!-- test默认是test修饰符，使用test.eval-ts使用TinyScript表达式 -->
<lang-if test.eval-ts="${V_STATUS} == 1">
```

---

## 三、日志节点 (log-*)

### 3.1 log-debug

**功能说明：**
输出Debug级别日志信息。

**DTD定义：**

```xml

<!ELEMENT log-debug (ANY|EMPTY)>
<!ATTLIST log-debug value CDATA #IMPLIED>
<!ATTLIST log-debug e CDATA #IMPLIED>
```

**属性定义：**

| 属性名   | 类型        | 默认修饰符  | 说明      |
|-------|-----------|--------|---------|
| value | String    | string | 日志内容    |
| e     | Throwable | visit  | 可选的异常对象 |

**使用示例：**

```xml
<!-- 这里使用 render 修饰符进行字符串渲染，否则默认修饰符是 string，是不会处理 $!{trace.location} 变量的，只会认为这是一个普通字符串 -->
<log-debug value.render="调试信息: $!{trace.location}"/>

<log-debug value="开始执行..."/>
```

**验证依据：
** [LogDebugNode.java](/src/main/java/.../jdbc/procedure/node/impl/LogDebugNode.java)

---

### 3.2 log-info

**功能说明：**
输出Info级别日志信息。

**DTD定义：**

```xml

<!ELEMENT log-info (ANY|EMPTY)>
<!ATTLIST log-info value CDATA #IMPLIED>
<!ATTLIST log-info e CDATA #IMPLIED>
```

**属性定义：**

| 属性名   | 类型        | 默认修饰符  | 说明      |
|-------|-----------|--------|---------|
| value | String    | string | 日志内容    |
| e     | Throwable | visit  | 可选的异常对象 |

**使用示例：**

```xml

<log-info value.render="开始执行存储过程: $!{trace.location}"/>

        <!-- 当不记得默认修饰符的时候，可以自己指定修饰符覆盖默认行为 -->
<log-info value.string="处理开始"/>
```

**验证依据：
** [LogInfoNode.java](/src/main/java/.../jdbc/procedure/node/impl/LogInfoNode.java)

---

### 3.3 log-warn

**功能说明：**
输出Warn级别日志信息。

**DTD定义：**

```xml

<!ELEMENT log-warn (ANY|EMPTY)>
<!ATTLIST log-warn value CDATA #IMPLIED>
<!ATTLIST log-warn e CDATA #IMPLIED>
```

**属性定义：**

| 属性名   | 类型        | 默认修饰符  | 说明      |
|-------|-----------|--------|---------|
| value | String    | string | 日志内容    |
| e     | Throwable | visit  | 可选的异常对象 |

**使用示例：**

```xml

<log-warn value.render="警告: $!{trace.errmsg}" e="e"/>
```

**验证依据：
** [LogWarnNode.java](/src/main/java/.../jdbc/procedure/node/impl/LogWarnNode.java)

---

### 3.4 log-error

**功能说明：**
输出Error级别日志信息。

**DTD定义：**

```xml

<!ELEMENT log-error (ANY|EMPTY)>
<!ATTLIST log-error value CDATA #IMPLIED>
<!ATTLIST log-error e CDATA #IMPLIED>
```

**属性定义：**

| 属性名   | 类型        | 默认修饰符  | 说明      |
|-------|-----------|--------|---------|
| value | String    | string | 日志内容    |
| e     | Throwable | visit  | 可选的异常对象 |

**使用示例：**

```xml

<log-error value.render="错误: $!{trace.errmsg}" e="e"/>
```

**验证依据：
** [LogErrorNode.java](/src/main/java/.../jdbc/procedure/node/impl/LogErrorNode.java)

---

## 四、调试节点

### 4.1 debugger

**功能说明：**
调试器节点，在此处中断执行等待继续，可用于查看上下文变量。支持条件断点。

**DTD定义：**

```xml

<!ELEMENT debugger (ANY|EMPTY)>
<!ATTLIST debugger test CDATA #IMPLIED>
<!ATTLIST debugger tag CDATA #IMPLIED>
```

**属性定义：**

| 属性名  | 类型     | 默认修饰符  | 说明      |
|------|--------|--------|---------|
| tag  | String | string | 断点标识标签  |
| test | String | eval   | 条件断点表达式 |

**使用示例：**

```xml
<!-- 无条件断点 -->
<debugger tag="execSql"/>

        <!-- 条件断点，记住 test 属性，默认都是使用 test 修饰符的，默认都是使用OGNL语法 -->
<debugger tag="getUserInfo" test="user==null"/>
```

**注意事项：**

- 推荐对 `BasicJdbcProcedureExecutor.openDebugger` 方法添加断点
- 或直接在 `DebuggerNode` 节点上添加断点

**验证依据：
** [DebuggerNode.java](/src/main/java/.../jdbc/procedure/node/impl/DebuggerNode.java)

---

## 五、语言控制节点 (lang-*)

### 5.1 lang-println

**功能说明：**
使用系统输出行打印信息，以tag开头，其余变量附加在其他属性上。

**DTD定义：**

```xml

<!ELEMENT lang-println (ANY|EMPTY)>
<!ATTLIST lang-println tag CDATA #IMPLIED>
<!ATTLIST lang-println tag.string CDATA #IMPLIED>
```

**属性定义：**

| 属性名 | 类型     | 默认修饰符  | 说明     |
|-----|--------|--------|--------|
| tag | String | string | 输出标签前缀 |

**使用示例：**

```xml
<!-- 允许添加其他属性，其他添加的属性都会在控制台输出时，追加到 tag 之后，其他属性默认都是以 visit 修饰符访问的 -->
<lang-println tag="userInfo" userName="user.name" age="user.age"/>
```

**验证依据：
** [LangPrintlnNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangPrintlnNode.java)

---

### 5.2 lang-printf

**功能说明：**
使用模板进行格式化输出，支持tag属性标签。

**DTD定义：**

```xml

<!ELEMENT lang-printf (ANY|EMPTY)>
<!ATTLIST lang-printf tag CDATA #IMPLIED>
<!ATTLIST lang-printf value CDATA #IMPLIED>
```

**属性定义：**

| 属性名   | 类型     | 默认修饰符  | 说明     |
|-------|--------|--------|--------|
| tag   | String | string | 输出标签前缀 |
| value | String | string | 格式化模板  |

**使用示例：**

```xml

<lang-printf tag="userInfo" value="username:${user.name}"/>

<lang-printf tag="userInfo">
username: ${user.name}
</lang-printf>

<lang-printf tag="userInfo" value.body-text.trim="">
username: ${user.name}
</lang-printf>
```

**验证依据：
** [LangPrintfNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangPrintfNode.java)

---

### 5.3 lang-set

**功能说明：**
将value指定的值赋值到result指定的变量中。

**DTD定义：**

```xml

<!ELEMENT lang-set (ANY|EMPTY)>
<!ATTLIST lang-set value CDATA #IMPLIED>
<!ATTLIST lang-set radix CDATA #IMPLIED>
<!ATTLIST lang-set pattern CDATA #IMPLIED>
<!ATTLIST lang-set result CDATA #IMPLIED>
```

**属性定义：**

| 属性名     | 类型     | 默认修饰符  | 说明           |
|---------|--------|--------|--------------|
| value   | Object | visit  | 输入值          |
| radix   | int    | int    | 数值进制（默认10进制） |
| pattern | String | string | 日期格式化模式      |
| result  | String | -      | 结果变量名（必需）    |

**使用示例：**

```xml
<!-- 直接赋值 -->
<lang-set result="v_val" value.int="1"/>
<lang-set result="v_val" value.boolean="true"/>

        <!-- 渲染赋值 -->
<lang-set result.trim="v_val" value.render="welcome ${userName}! "/>

        <!-- 表达式计算 -->
<lang-set result="v_i" value.eval="v_i+1"/>

        <!-- 特殊值 -->
<lang-set result="v_now" value.date-now=""/>
<lang-set result="v_null" value.null=""/>
<lang-set result="v_uuid" value.uuid=""/>

        <!-- 类型转换 -->
<lang-set result="v_year" value.date="2025-01-02" pattern="yyyy-MM-dd"/>
<lang-set result="v_hex" value.string="6fd" radix="16"/>

        <!-- 嵌套属性赋值 -->
<lang-set result="user.nickName" value="user.userName"/>

        <!-- Java表达式 -->
<lang-set result="v_now" value.eval-java="new Date()"/>

        <!-- TinyScript表达式 -->
<lang-set result="v_now" value.eval-ts="new Date()"/>

        <!-- 标签内部文本 -->
<lang-set result.body-text.trim="">
text
</lang-set>
```

**验证依据：
** [LangSetNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangSetNode.java)

---

### 5.4 lang-format-date

**功能说明：**
格式化日期值为字符串。

**DTD定义：**

```xml

<!ELEMENT lang-format-date (ANY|EMPTY)>
<!ATTLIST lang-format-date value CDATA #IMPLIED>
<!ATTLIST lang-format-date pattern CDATA #IMPLIED>
<!ATTLIST lang-format-date result CDATA #REQUIRED>
```

**属性定义：**

| 属性名     | 类型     | 默认修饰符  | 说明                 |
|---------|--------|--------|--------------------|
| value   | Object | visit  | 日期值或表达式            |
| pattern | String | string | 格式化模式（如yyyy-MM-dd） |
| result  | String | -      | 结果变量名（必需）          |

**使用示例：**

```xml

<lang-format-date result="v_str" value.eval-ts="new Date()" pattern="yyyy-MM-dd"/>
<lang-format-date result="v_str" value="v_begin_time" pattern="yyyyMMdd"/>
```

**验证依据：
** [LangFormatDateNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangFormatDateNode.java)

---

### 5.5 lang-format

**功能说明：**
格式化字符串，使用Java的Formatter风格。

**DTD定义：**

```xml

<!ELEMENT lang-format (ANY|EMPTY)>
<!ATTLIST lang-format value CDATA #IMPLIED>
<!ATTLIST lang-format pattern CDATA #IMPLIED>
<!ATTLIST lang-format result CDATA #REQUIRED>
```

**属性定义：**

| 属性名     | 类型     | 默认修饰符  | 说明           |
|---------|--------|--------|--------------|
| value   | Object | visit  | 要格式化的值       |
| pattern | String | string | 格式化模式（如%.2f） |
| result  | String | -      | 结果变量名（必需）    |

**使用示例：**

```xml

<lang-format result="v_str" value.string="12.125" pattern="%.2f"/>
<lang-format result="v_str" value="v_money" pattern="your account has %.2f$"/>
<lang-format result="v_str" value.date-now="" pattern="yyyy-MM-dd"/>
```

**验证依据：
** [LangFormatNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangFormatNode.java)

---

### 5.6 lang-string-join

**功能说明：**
字符串拼接，将多个参数用分隔符连接。

**DTD定义：**

```xml

<!ELEMENT lang-string-join (ANY|EMPTY)>
<!ATTLIST lang-string-join separator CDATA #IMPLIED>
<!ATTLIST lang-string-join result CDATA #IMPLIED>
<!ATTLIST lang-string-join arg0 CDATA #IMPLIED>
<!ATTLIST lang-string-join arg1 CDATA #IMPLIED>
        <!-- ... arg2-arg9 ... -->
```

**属性定义：**

| 属性名       | 类型     | 默认修饰符  | 说明     |
|-----------|--------|--------|--------|
| separator | String | string | 分隔符    |
| result    | String | -      | 结果变量名  |
| arg0-arg9 | Object | visit  | 要拼接的参数 |

**使用示例：**

```xml

<lang-string-join result="v_vals" separator="," arg0.string="a.username" arg1.int="2" arg2="v_now"/>
<lang-string-join result="v_str" arg0.string="[" arg1.int="0" arg2.string="]"/>
```

**验证依据：
** [LangStringJoinNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangStringJoinNode.java)

---

### 5.7 lang-new-params

**功能说明：**
创建一个新的参数上下文，用于为内部调用其他过程提供干净的上下文参数。

**DTD定义：**

```xml

<!ELEMENT lang-new-params (ANY|EMPTY)>
<!ATTLIST lang-new-params result CDATA #REQUIRED>
```

**属性定义：**

| 属性名    | 类型     | 默认修饰符 | 说明        |
|--------|--------|-------|-----------|
| result | String | -     | 结果变量名（必需） |

**使用示例：**

```xml

<lang-new-params result="callParams" IN_SUM_MONTH="V_SUM_MONTH" IN_CITY_CODE.int="10010"/>
<lang-new-params result="callParams"/>
```

**验证依据：
** [LangNewParamsNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangNewParamsNode.java)

---

### 5.8 lang-if

**功能说明：**
条件判断，对应Java的if语句。

**DTD定义：**

```xml

<!ELEMENT lang-if (ANY|EMPTY)>
<!ATTLIST lang-if test CDATA #IMPLIED>
<!ATTLIST lang-if datasource CDATA #IMPLIED>
```

**属性定义：**

| 属性名        | 类型      | 默认修饰符  | 说明                                |
|------------|---------|--------|-----------------------------------|
| test       | boolean | test   | 条件表达式(OGNL表达式)                    |
| datasource | String  | string | 数据源（用于test属性使用dialect修饰符判断数据库方言时） |

**使用示例：**

```xml

<lang-if test="v_cnt==0">
    <lang-set result="O_FLAG" value.int="-1"/>
    <lang-return/>
</lang-if>

<lang-if test="v_grade in {'A','B','C'}">
<sql-update>
    update sys_user set score =score+10 where grade=#{v_grade}
</sql-update>
</lang-if>

<lang-if test.visit="v_fail">
<lang-return/>
</lang-if>

<lang-if test='v_str.startsWith("DIM")'>
<lang-return value.int="-1"/>
</lang-if>

<lang-if test='v_str.contains("VAR")'>
<lang-return value.int="-1"/>
</lang-if>

<lang-if test.dialect="mysql,gbase" datasource="primary">
<lang-return/>
</lang-if>
```

**注意事项：**

- 支持 `.dialect` 修饰符用于判断数据源类型
- 支持 OGNL 表达式语法

**验证依据：
** [LangIfNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangIfNode.java)

---

### 5.9 lang-choose / lang-when / lang-otherwise

**功能说明：**
多分支选择，对应 if-else-if 或 switch-case 语句。

**DTD定义：**

```xml

<!ELEMENT lang-choose (lang-when*|lang-otherwise?)>
<!ELEMENT lang-when (ANY|EMPTY)>
<!ATTLIST lang-when test CDATA #IMPLIED>
<!ATTLIST lang-when datasource CDATA #IMPLIED>
<!ELEMENT lang-otherwise (ANY)>
```

**属性定义：**

| 节点         | 属性名    | 类型      | 默认修饰符                             | 说明             |
|------------|--------|---------|-----------------------------------|----------------|
| lang-when  | test   | boolean | test                              | 条件表达式(OGNL表达式) |
| datasource | String | string  | 数据源（用于test属性使用dialect修饰符判断数据库方言时） |

**使用示例：**

```xml

<lang-choose>
    <lang-when test="v_grade in {1,2,3}">
        <lang-set result="v_grade_color" value.string="blue"/>
    </lang-when>
    <lang-when test="v_grade==0">
        <lang-set result="v_grade_color" value.string="skyblue"/>
    </lang-when>
    <lang-when test.dialect="mysql,gbase" datasource="slave">
        <lang-set result="v_grade_color" value.string="green"/>
    </lang-when>
    <lang-otherwise>
        <lang-set result="v_grade_color" value.string="red"/>
    </lang-otherwise>
</lang-choose>
```

**验证依据：
** [LangChooseNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangChooseNode.java)

---

### 5.10 lang-foreach

**功能说明：**
对集合进行迭代遍历。

**DTD定义：**

```xml

<!ELEMENT lang-foreach (ANY|EMPTY)>
<!ATTLIST lang-foreach collection CDATA #REQUIRED>
<!ATTLIST lang-foreach item CDATA #IMPLIED>
<!ATTLIST lang-foreach first CDATA #IMPLIED>
<!ATTLIST lang-foreach index CDATA #IMPLIED>
```

**属性定义：**

| 属性名        | 类型         | 默认修饰符  | 默认值   | 说明         |
|------------|------------|--------|-------|------------|
| collection | Collection | visit  | -     | 被迭代的集合（必需） |
| item       | String     | string | item  | 迭代变量名      |
| first      | String     | string | first | 是否首次迭代的变量名 |
| index      | String     | string | index | 迭代索引的变量名   |

**使用示例：**

```xml

<lang-foreach collection="v_user_list" item="item" first="isFirst" index="i">
    <lang-if test="!isFirst">
        <lang-set result="v_str" value.render="${v_str},"/>
    </lang-if>
    <lang-set result="v_str" value.render="${v_str}${i}:${item.userName}"/>
</lang-foreach>
```

**验证依据：
** [LangForeachNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangForeachNode.java)

---

### 5.11 lang-fori

**功能说明：**
计数循环，从begin数开始每次增加incr的步长直到end结束。

**DTD定义：**

```xml

<!ELEMENT lang-fori (ANY|EMPTY)>
<!ATTLIST lang-fori begin CDATA #IMPLIED>
<!ATTLIST lang-fori end CDATA #IMPLIED>
<!ATTLIST lang-fori incr CDATA #IMPLIED>
<!ATTLIST lang-fori item CDATA #IMPLIED>
<!ATTLIST lang-fori first CDATA #IMPLIED>
<!ATTLIST lang-fori index CDATA #IMPLIED>
<!ATTLIST lang-fori enclose CDATA #IMPLIED>
```

**属性定义：**

| 属性名     | 类型      | 默认修饰符   | 默认值   | 说明                                     |
|---------|---------|---------|-------|----------------------------------------|
| begin   | int     | int     | 0     | 起始值                                    |
| end     | int     | int     | -     | 结束值                                    |
| incr    | int     | int     | 1     | 步长增量                                   |
| item    | String  | string  | item  | 迭代变量名                                  |
| first   | String  | string  | first | 是否首次迭代的变量名                             |
| index   | String  | string  | index | 迭代索引的变量名                               |
| enclose | Boolean | boolean | false | 是否需要闭区间[begin,end]，默认左闭右开区间[begin,end) |

**使用示例：**

```xml

<lang-fori begin.int="2" end.int="100" incr.int="3">
    <lang-set result="v_count" value.eval="v_count+1"/>
</lang-fori>

<lang-fori begin="v_index" end.int="100">
<lang-set result="v_count" value.eval="v_count+1"/>
<lang-if test="v_index>= v_str.length()">
    <lang-break/>
</lang-if>
</lang-fori>

<lang-fori end.int="100">
<lang-set result="v_count" value.eval="v_count+1"/>
</lang-fori>

<lang-fori begin.int="0" end.int="10" incr.int="1" enclose="true">
<lang-set result="v_count" value.eval="v_count+1"/>
</lang-fori>
```

**注意事项：**

- 默认是左闭右开区间 `[begin, end)`
- 如需包含右边界，可使用 `enclose="true"` 技巧

**验证依据：
** [LangForiNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangForiNode.java)

---

### 5.12 lang-while

**功能说明：**
条件循环，先判断条件再执行循环体。

**DTD定义：**

```xml

<!ELEMENT lang-while (ANY|EMPTY)>
<!ATTLIST lang-while first CDATA #IMPLIED>
<!ATTLIST lang-while index CDATA #IMPLIED>
<!ATTLIST lang-while test CDATA #IMPLIED>
<!ATTLIST lang-while datasource CDATA #IMPLIED>
```

**属性定义：**

| 属性名        | 类型      | 默认修饰符  | 默认值   | 说明                        |
|------------|---------|--------|-------|---------------------------|
| test       | boolean | test   | -     | 循环条件（必需）                  |
| first      | String  | string | first | 是否首次迭代的变量名                |
| index      | String  | string | index | 迭代索引的变量名                  |
| datasource | String  | string | -     | 数据源（用于dialect判断，实际不会这么使用） |

**使用示例：**

```xml

<lang-while test="v_i>0">
    <lang-if test="v_i==10">
        <lang-continue/>
    </lang-if>
    <lang-if test="v_i &lt; v_cnt">
        <lang-break/>
    </lang-if>
    <lang-set result="v_i" value.eval="v_i-1"/>
</lang-while>
```

**验证依据：
** [LangWhileNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangWhileNode.java)

---

### 5.13 lang-do-while

**功能说明：**
先执行后判断循环，至少执行一次循环体。

**DTD定义：**

```xml

<!ELEMENT lang-do-while (ANY|EMPTY)>
<!ATTLIST lang-do-while first CDATA #IMPLIED>
<!ATTLIST lang-do-while index CDATA #IMPLIED>
<!ATTLIST lang-do-while test CDATA #IMPLIED>
```

**属性定义：**

| 属性名   | 类型      | 默认修饰符  | 默认值   | 说明         |
|-------|---------|--------|-------|------------|
| test  | boolean | test   | -     | 循环条件（必需）   |
| first | String  | string | first | 是否首次迭代的变量名 |
| index | String  | string | index | 迭代索引的变量名   |

**使用示例：**

```xml

<lang-do-while test="v_i>0">
    <lang-if test="v_i==10">
        <lang-continue/>
    </lang-if>
    <lang-if test="v_i &lt; v_cnt">
        <lang-break/>
    </lang-if>
    <lang-set result="v_i" value.eval="v_i-1"/>
</lang-do-while>
```

**验证依据：
** [LangDoWhileNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangDoWhileNode.java)

---

### 5.14 lang-break

**功能说明：**
跳出当前循环，对应Java的break语句。

**DTD定义：**

```xml

<!ELEMENT lang-break (EMPTY)>
```

**使用示例：**

```xml

<lang-while test="v_i>0">
    <lang-if test="v_i &lt; v_cnt">
        <lang-break/>
    </lang-if>
    <lang-set result="v_i" value.eval="v_i-1"/>
</lang-while>
```

**验证依据：
** [LangBreakNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangBreakNode.java)

---

### 5.15 lang-continue

**功能说明：**
跳过本次迭代继续下一次循环，对应Java的continue语句。

**DTD定义：**

```xml

<!ELEMENT lang-continue (EMPTY)>
```

**使用示例：**

```xml

<lang-while test="v_i>0">
    <lang-if test="v_i==10">
        <lang-continue/>
    </lang-if>
    <lang-set result="v_sum" value.eval="v_sum+v_i"/>
</lang-while>
```

**验证依据：
** [LangContinueNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangContinueNode.java)

---

### 5.16 lang-return

**功能说明：**
返回并结束当前过程执行。

**DTD定义：**

```xml

<!ELEMENT lang-return (EMPTY)>
<!ATTLIST lang-return value CDATA #IMPLIED>
<!ATTLIST lang-return radix CDATA #IMPLIED>
<!ATTLIST lang-return pattern CDATA #IMPLIED>
```

**属性定义：**

| 属性名     | 类型     | 默认修饰符  | 说明      |
|---------|--------|--------|---------|
| value   | Object | visit  | 返回值     |
| radix   | int    | int    | 数值进制    |
| pattern | String | string | 日期格式化模式 |

**使用示例：**

```xml

<lang-return/>
<lang-return value.int="0"/>
<lang-return value="V_IS_OK"/>
```

**验证依据：
** [LangReturnNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangReturnNode.java)

---

### 5.17 lang-throw

**功能说明：**
抛出异常。

**DTD定义：**

```xml

<!ELEMENT lang-throw (ANY|EMPTY)>
<!ATTLIST lang-throw value CDATA #IMPLIED>
<!ATTLIST lang-throw type CDATA #REQUIRED>
<!ATTLIST lang-throw cause CDATA #IMPLIED>
```

**属性定义：**

| 属性名   | 类型        | 默认修饰符  | 说明                             |
|-------|-----------|--------|--------------------------------|
| value | String    | string | 异常消息                           |
| type  | String    | string | 异常类型（全限定类名，java.lang包下面的可以短类名） |
| cause | Throwable | visit  | 导致当前异常的异常对象                    |

**使用示例：**

```xml

<lang-throw type="RuntimeException" value="bad parameter"/>

<lang-try>
<lang-body>
    <!-- 业务逻辑 -->
</lang-body>
<lang-catch e="e">
    <lang-throw type="RuntimeException" value="bad parameter" cause="e"/>
</lang-catch>
</lang-try>
```

**验证依据：
** [LangThrowNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangThrowNode.java)

---

### 5.18 lang-try / lang-body / lang-catch / lang-finally

**功能说明：**
异常处理结构，对应Java的try-catch-finally语句。

**DTD定义：**

```xml

<!ELEMENT lang-try (lang-body|lang-catch*|lang-finally?)>
<!ELEMENT lang-body (ANY|EMPTY)>
<!ELEMENT lang-catch (ANY|EMPTY)>
<!ATTLIST lang-catch type CDATA #IMPLIED>
<!ATTLIST lang-catch e CDATA #IMPLIED>
<!ATTLIST lang-catch test CDATA #IMPLIED>
<!ELEMENT lang-finally (ANY|EMPTY)>
```

**lang-catch属性定义：**

| 属性名  | 类型      | 默认修饰符  | 说明                                                 |
|------|---------|--------|----------------------------------------------------|
| type | String  | string | 要捕获的异常类型（支持`.cause-*`修饰符，全限定类名，java.lang包下面的可以短类名） |
| e    | String  | string | 异常变量名                                              |
| test | boolean | test   | 额外的条件判断（OGNL表达式）                                   |

**使用示例：**

```xml
<!-- 基本用法 -->
<lang-try>
    <lang-body>
        <sql-update script="v_sql"/>
    </lang-body>
    <!-- 捕获多种异常 -->
    <lang-catch type="ArithmeticException|IllegalArgumentException" e="e">
        <lang-println tag="execError" SQL="v_sql" EXCEPTION="e"/>
    </lang-catch>
    <!-- 按SQLState条件捕获 -->
    <lang-catch type="java.sql.SQLException" e="e" test='e.getSQLState()=="22012"'>
        <!-- 处理除零错误 -->
    </lang-catch>
    <!-- 使用TinyScript判断 -->
    <lang-catch type="java.sql.SQLException" e="e" test.eval-ts='${e}.getSQLState()=="22011"'>
        <!-- 处理其他SQL错误 -->
    </lang-catch>
    <!-- 最终捕获 -->
    <lang-catch type="RuntimeException" e="e">
        <lang-println tag="runError" SQL="v_sql" EXCEPTION="e"/>
    </lang-catch>
</lang-try>

        <!-- 简化形式 -->
<lang-try>
<lang-body>
    <sql-update script="v_sql"/>
</lang-body>
<lang-catch e="e">
    <lang-println tag="execError" SQL="v_sql" EXCEPTION="e"/>
</lang-catch>
</lang-try>

        <!-- 带finally -->
<lang-try>
<lang-body>
    <sql-update script="v_sql"/>
</lang-body>
<lang-finally>
    <sql-update script="v_log_sql"/>
</lang-finally>
</lang-try>
```

**Cause修饰符使用说明：**

```xml
<!-- 获取cause链中第一个SQLException -->
<lang-catch type.cause-first="java.sql.SQLException" e="e">
  
</lang-catch>

<!-- 获取cause链中最后一个SQLDataException -->
<lang-catch type.cause-last="java.sql.SQLDataException" e="e">

</lang-catch>
<!-- 获取根异常 -->
<lang-catch type.cause-root="" e="e">

</lang-catch>
<!-- 获取原始异常（框架层面） -->
<lang-catch type.cause-raw="" e="e">

</lang-catch>
```

**验证依据：
** [LangTryNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangTryNode.java)

---

### 5.19 lang-eval

**功能说明：**
使用OGNL表达式计算并设置变量值。

**DTD定义：**

```xml

<!ELEMENT lang-eval (ANY|EMPTY)>
<!ATTLIST lang-eval value CDATA #IMPLIED>
<!ATTLIST lang-eval result CDATA #IMPLIED>
```

**属性定义：**

| 属性名    | 类型     | 默认修饰符  | 说明                                               |
|--------|--------|--------|--------------------------------------------------|
| value  | String | string | 表达式内容(表达式实际是OGNL表达式)，如果没有value属性，将会使用标签内部为本作为表达式 |
| result | String | -      | 结果变量名                                            |

**使用示例：**

```xml

<lang-eval result="v_ok" value="v_cnt > 0"/>
<lang-eval result="v_len" value="v_str.length()"/>
<lang-eval result="v_i">
v_i+1
</lang-eval>
```

**验证依据：
** [LangEvalNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangEvalNode.java)

---

### 5.20 lang-string

**功能说明：**
定义一段字符串内容到结果变量中。

**DTD定义：**

```xml

<!ELEMENT lang-string (ANY|EMPTY)>
<!ATTLIST lang-string result CDATA #IMPLIED>
<!ATTLIST lang-string result.trim CDATA #IMPLIED>
<!ATTLIST lang-string _lang CDATA #IMPLIED>
```

**属性定义：**

| 属性名    | 类型     | 默认修饰符 | 说明                  |
|--------|--------|-------|---------------------|
| result | String | -     | 结果变量名               |
| _lang  | String | -     | 语法高亮语言标识（如java,sql） |

**使用示例：**

```xml

<lang-string result.trim="v_str">
    123
    456
</lang-string>
<lang-string result.trim.align="v_str">
| 123
|456
</lang-string>
```

**验证依据：
** [LangStringNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangStringNode.java)

---

### 5.21 lang-render

**功能说明：**
使用Velocity模板引擎渲染字符串到结果变量。

**DTD定义：**

```xml

<!ELEMENT lang-render (ANY|EMPTY)>
<!ATTLIST lang-render result CDATA #IMPLIED>
<!ATTLIST lang-render result.trim CDATA #IMPLIED>
<!ATTLIST lang-render _lang CDATA #IMPLIED>
```

**属性定义：**

| 属性名    | 类型     | 默认修饰符 | 说明       |
|--------|--------|-------|----------|
| result | String | -     | 结果变量名    |
| _lang  | String | -     | 语法高亮语言标识 |

**使用示例：**

```xml

<lang-render result="v_sql" _lang="sql">
    select * from ${tableName}
    where ${colName} = ${colEqValue}
</lang-render>
```

**Velocity语法：**

- `${var}` - 变量替换，null时显示"${var}"
- `$!{var}` - 变量替换，null时显示空字符串

**验证依据：
** [LangRenderNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangRenderNode.java)

---

### 5.22 lang-invoke

**功能说明：**
在指定对象上调用方法。

**DTD定义：**

```xml

<!ELEMENT lang-invoke (ANY|EMPTY)>
<!ATTLIST lang-invoke method CDATA #REQUIRED>
<!ATTLIST lang-invoke target CDATA #IMPLIED>
<!ATTLIST lang-invoke arg0 CDATA #IMPLIED>
        <!-- ... arg1-arg9 ... -->
<!ATTLIST lang-invoke result CDATA #IMPLIED>
```

**属性定义：**

| 属性名       | 类型     | 默认修饰符  | 说明                       |
|-----------|--------|--------|--------------------------|
| method    | String | string | 方法名或全限定方法名（如Math.random） |
| target    | Object | visit  | 调用方法的目标对象                |
| arg0-arg9 | Object | visit  | 方法参数                     |
| result    | String | -      | 结果变量名                    |

**使用示例：**

```xml

<lang-invoke result="v_str" target="v_str" method="replaceAll" arg0.string="\s+" arg1.string=""/>
<lang-invoke result="v_num" method="parseInteger" arg0.string="11"/>
```

**验证依据：
** [LangInvokeNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangInvokeNode.java)

---

### 5.23 lang-shell

**功能说明：**
执行Shell命令。

**DTD定义：**

```xml

<!ELEMENT lang-shell (ANY|EMPTY)>
<!ATTLIST lang-shell result CDATA #IMPLIED>
<!ATTLIST lang-shell await CDATA #IMPLIED>
<!ATTLIST lang-shell timeout CDATA #IMPLIED>
<!ATTLIST lang-shell time-unit CDATA #IMPLIED>
<!ATTLIST lang-shell script CDATA #IMPLIED>
<!ATTLIST lang-shell run-as-file CDATA #IMPLIED>
<!ATTLIST lang-shell workdir CDATA #IMPLIED>
<!ATTLIST lang-shell envp CDATA #IMPLIED>
```

**属性定义：**

| 属性名         | 类型      | 默认修饰符   | 默认值          | 说明         |
|-------------|---------|---------|--------------|------------|
| result      | String  | -       | -            | 结果变量名      |
| await       | boolean | boolean | true         | 是否等待执行结果   |
| timeout     | long    | long    | -1           | 超时时间       |
| time-unit   | String  | string  | MILLISECONDS | 时间单位       |
| script      | String  | visit   | -            | 命令脚本（优先使用） |
| run-as-file | boolean | boolean | false        | 是否作为文件运行   |
| workdir     | String  | string  | 程序运行路径       | 工作目录       |
| envp        | String  | string  | -            | 环境变量（分号分隔） |

**使用示例：**

```xml

<lang-shell result="v_ping" script.string="ping www.baidu.com"/>

<lang-shell result="v_dir" script.string="dir" workdir="../"/>

<lang-shell result="v_log">
cd ..
dir
echo done.
</lang-shell>

<lang-shell result="v_log" script.body-text.render.trim="">
cd ${path}
nohup java -jar ${jarName} ${jarParams} &amp;
</lang-shell>
```

**验证依据：
** [LangShellNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangShellNode.java)

---

### 5.24 lang-file-exists

**功能说明：**
判断文件是否存在。

**DTD定义：**

```xml

<!ELEMENT lang-file-exists (ANY|EMPTY)>
<!ATTLIST lang-file-exists result CDATA #IMPLIED>
<!ATTLIST lang-file-exists file CDATA #IMPLIED>
```

**属性定义：**

| 属性名    | 类型          | 默认修饰符 | 说明    |
|--------|-------------|-------|-------|
| result | String      | -     | 结果变量名 |
| file   | String/File | visit | 文件路径  |

**使用示例：**

```xml

<lang-file-exists result="v_ext" file.string="./config.txt"/>

<lang-set result="v_file" value.string="./resources/config.txt"/>
<lang-file-exists result="v_ext" file="v_file"/>
```

**验证依据：
** [LangFileExistsNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangFileExistsNode.java)

---

### 5.25 lang-file-mkdirs

**功能说明：**
创建目录（不存在则创建）。

**DTD定义：**

```xml

<!ELEMENT lang-file-mkdirs (ANY|EMPTY)>
<!ATTLIST lang-file-mkdirs file CDATA #IMPLIED>
```

**属性定义：**

| 属性名  | 类型          | 默认修饰符 | 说明   |
|------|-------------|-------|------|
| file | String/File | visit | 目录路径 |

**使用示例：**

```xml

<lang-file-mkdirs file.string="./config"/>

<lang-set result="v_file" value.string="./resources/config"/>
<lang-file-mkdirs file="v_file"/>
```

**验证依据：
** [LangFileMkdirsNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangFileMkdirsNode.java)

---

### 5.26 lang-file-delete

**功能说明：**
删除文件或目录（如果是目录则递归删除）。

**DTD定义：**

```xml

<!ELEMENT lang-file-delete (ANY|EMPTY)>
<!ATTLIST lang-file-delete file CDATA #IMPLIED>
```

**属性定义：**

| 属性名  | 类型          | 默认修饰符 | 说明      |
|------|-------------|-------|---------|
| file | String/File | visit | 文件/目录路径 |

**使用示例：**

```xml

<lang-file-delete file.string="./config.txt"/>

<lang-set result="v_file" value.string="./resources/config"/>
<lang-file-delete file="v_file"/>
```

**验证依据：
** [LangFileDeleteNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangFileDeleteNode.java)

---

### 5.27 lang-file-list

**功能说明：**
列出目录下的子文件列表。

**DTD定义：**

```xml

<!ELEMENT lang-file-list (ANY|EMPTY)>
<!ATTLIST lang-file-list result CDATA #IMPLIED>
<!ATTLIST lang-file-list file CDATA #IMPLIED>
```

**属性定义：**

| 属性名    | 类型          | 默认修饰符 | 说明                     |
|--------|-------------|-------|------------------------|
| result | String      | -     | 结果变量名（ArrayList<File>） |
| file   | String/File | visit | 目录路径                   |

**使用示例：**

```xml

<lang-file-list result="v_list" file.string="./config"/>

<lang-set result="v_file" value.string="./resources/config"/>
<lang-file-list result="v_list" file="v_file"/>
```

**验证依据：
** [LangFileListNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangFileListNode.java)

---

### 5.28 lang-file-tree

**功能说明：**
列出目录下的文件树（递归）。

**DTD定义：**

```xml

<!ELEMENT lang-file-tree (ANY|EMPTY)>
<!ATTLIST lang-file-tree result CDATA #IMPLIED>
<!ATTLIST lang-file-tree file CDATA #IMPLIED>
```

**属性定义：**

| 属性名    | 类型          | 默认修饰符 | 说明                     |
|--------|-------------|-------|------------------------|
| result | String      | -     | 结果变量名（ArrayList<File>） |
| file   | String/File | visit | 目录路径                   |

**使用示例：**

```xml

<lang-file-tree result="v_list" file.string="./config"/>

<lang-set result="v_file" value.string="./resources/config"/>
<lang-file-tree result="v_list" file="v_file"/>
```

**注意事项：**

- 如果路径不存在或不是目录，将抛出异常

**验证依据：
** [LangFileTreeNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangFileTreeNode.java)

---

### 5.29 lang-file-read-text

**功能说明：**
读取文本文件内容。

**DTD定义：**

```xml

<!ELEMENT lang-file-read-text (ANY|EMPTY)>
<!ATTLIST lang-file-read-text result CDATA #IMPLIED>
<!ATTLIST lang-file-read-text file CDATA #IMPLIED>
<!ATTLIST lang-file-read-text charset CDATA #IMPLIED>
```

**属性定义：**

| 属性名     | 类型              | 默认修饰符  | 默认值   | 说明                        |
|---------|-----------------|--------|-------|---------------------------|
| result  | String          | -      | -     | 结果变量名                     |
| file    | String/File/URL | visit  | -     | 文件路径（支持classpath/http等协议） |
| charset | String          | string | UTF-8 | 字符编码                      |

**使用示例：**

```xml

<lang-file-read-text result="v_text" file.string="./config.txt" charset="UTF-8"/>

<lang-set result="v_file" value.string="./resources/config.txt"/>
<lang-file-read-text result="v_text" file="v_file"/>
```

**验证依据：
** [LangFileReadTextNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangFileReadTextNode.java)

---

### 5.30 lang-file-write-text

**功能说明：**
写入文本文件内容。

**DTD定义：**

```xml

<!ELEMENT lang-file-write-text (ANY|EMPTY)>
<!ATTLIST lang-file-write-text content CDATA #IMPLIED>
<!ATTLIST lang-file-write-text file CDATA #IMPLIED>
<!ATTLIST lang-file-write-text charset CDATA #IMPLIED>
```

**属性定义：**

| 属性名     | 类型          | 默认修饰符  | 默认值    | 说明   |
|---------|-------------|--------|--------|------|
| content | String      | visit  | 标签内部文本 | 写入内容 |
| file    | String/File | visit  | -      | 文件路径 |
| charset | String      | string | UTF-8  | 字符编码 |

**使用示例：**

```xml

<lang-file-write-text content.string="123456" file.string="./config.txt"/>

<lang-file-write-text file.string="./config.txt">
123
456
</lang-file-write-text>


<lang-render result="v_text">
username: ${username}
</lang-render>
<lang-set result="v_file" value.string="./resources/config"/>
<lang-file-write-text content="v_text" file="v_file"/>
```

**验证依据：
** [LangFileWriteTextNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangFileWriteTextNode.java)

---

### 5.31 lang-synchronized

**功能说明：**
同步代码块，对应Java的synchronized关键字。

**DTD定义：**

```xml

<!ELEMENT lang-synchronized (ANY|EMPTY)>
<!ATTLIST lang-synchronized target CDATA #IMPLIED>
```

**属性定义：**

| 属性名    | 类型     | 默认修饰符 | 说明                                                                              |
|--------|--------|-------|---------------------------------------------------------------------------------|
| target | Object | visit | 同步对象（默认使用lock对本次执行链进行同步，如果要对执行器级别进行同步使用executor/executorLock,对jvm级别同步使用jvmLock） |

**使用示例：**

```xml

<lang-synchronized>
  <sql-update script="v_sql"/>
</lang-synchronized>

<lang-synchronized target="lock">
<sql-update script="v_sql"/>
</lang-synchronized>

<lang-synchronized target="executorLock">
<sql-update script="v_sql"/>
</lang-synchronized>

<lang-synchronized target="jvmLock">
<sql-update script="v_sql"/>
</lang-synchronized>
```

**验证依据：
** [LangSynchronizedNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangSynchronizedNode.java)

---

### 5.32 lang-retry

**功能说明：**
重试机制，对内部内容进行指定次数的重试。

**DTD定义：**

```xml

<!ELEMENT lang-retry (ANY|EMPTY)>
<!ATTLIST lang-retry result CDATA #IMPLIED>
<!ATTLIST lang-retry count CDATA #IMPLIED>
<!ATTLIST lang-retry type CDATA #IMPLIED>
<!ATTLIST lang-retry delay CDATA #IMPLIED>
<!ATTLIST lang-retry time-unit CDATA #IMPLIED>
<!ATTLIST lang-retry incr CDATA #IMPLIED>
<!ATTLIST lang-retry max-delay CDATA #IMPLIED>
```

**属性定义：**

| 属性名       | 类型     | 默认修饰符  | 默认值          | 说明                       |
|-----------|--------|--------|--------------|--------------------------|
| result    | String | -      | -            | 结果变量名（总执行次数）             |
| count     | int    | int    | 1            | 最大尝试次数                   |
| type      | Class  | class  | Exception    | 可重试的异常类型（可用`             |`分割多个） |
| delay     | long   | long   | 30           | 重试前等待时间                  |
| time-unit | String | string | MILLISECONDS | 时间单位                     |
| incr      | double | double | 1            | 延迟增长倍率                   |
| max-delay | long   | long   | -            | 重试前单次最大等待时间（防止指数递增过大时使用） |

**使用示例：**

```xml

<lang-retry count="3" type="java.sql.SQLException" delay="300" incr="1.3">
    <sql-update script="v_sql"/>
</lang-retry>

        <!-- 根据状态决定是否继续重试 -->
<lang-retry count="3" delay="300" incr="1.3" time-unit="SECONDS">
<sql-update script="v_sql" result="V_CNT"/>
<lang-if test="V_CNT == 0">
    <lang-continue/>
</lang-if>
<lang-break/>
</lang-retry>
```

**重试间隔计算示例：**
delay=30, incr=1.3 时，重试等待序列为：30, 39, 50.7, 65.91, ...
假如 max-delay=50，重试等待序列为：30, 39, 50, 50, 50, ...

**验证依据：
** [LangRetryNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangRetryNode.java)

---

### 5.33 lang-lock

**功能说明：**
应用级别的键锁，内部维护Map<String,Lock>来管理锁。

**DTD定义：**

```xml

<!ELEMENT lang-lock (ANY|EMPTY)>
<!ATTLIST lang-lock result CDATA #IMPLIED>
<!ATTLIST lang-lock value CDATA #IMPLIED>
<!ATTLIST lang-lock type CDATA #IMPLIED>
<!ATTLIST lang-lock test CDATA #IMPLIED>
```

**属性定义：**

| 属性名    | 类型      | 默认修饰符  | 说明            |
|--------|---------|--------|---------------|
| result | String  | -      | 获取锁对象         |
| value  | String  | string | 锁键标识          |
| type   | String  | string | 锁类型实现（默认JDK锁） |
| test   | boolean | eval   | 是否开启锁（默认true） |

**使用示例：**

```xml

<lang-lock value="user">
  <sql-update script="v_sql"/>
</lang-lock>

<lang-lock value.visit="v_lock_key">
<sql-update script="v_sql"/>
</lang-lock>

<lang-lock value.render="redis:lock:$!{v_biz_id}" type="redis">
<sql-update script="v_sql"/>
</lang-lock>
```

**验证依据：
** [LangLockNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangLockNode.java)

---

### 5.34 lang-ai

**功能说明：**
调用AI工具进行对话。

**DTD定义：**

```xml

<!ELEMENT lang-ai (ANY|EMPTY)>
<!ATTLIST lang-ai value CDATA #IMPLIED>
<!ATTLIST lang-ai result CDATA #IMPLIED>
<!ATTLIST lang-ai type CDATA #IMPLIED>
<!ATTLIST lang-ai role CDATA #IMPLIED>
```

**属性定义：**

| 属性名    | 类型     | 默认修饰符  | 说明                                                 |
|--------|--------|--------|----------------------------------------------------|
| value  | String | visit  | 提示词内容（UserMessage），不使用value属性，则value属性就是标签内部文本     |
| result | String | -      | 结果变量名                                              |
| type   | String | string | AI Provider名称（根据注册到执行器中有哪些provider而定，不写的话自动取一个默认的） |
| role   | String | string | 系统角色设定(SystemMessage)                              |

**使用示例：**

```xml

<lang-ai result="v_answer" type="spring">
  你是一个熟悉SQL的数据库DBA，熟悉Oracle数据库。如何重建序列以设置起始值？
</lang-ai>

<lang-ai result="v_answer" type="lanchain4j" value.string="怎么删除Oracle的表">
</lang-ai>

<lang-render result="v_question">
你是一个熟悉SQL的数据库DBA，熟悉Oracle数据库。请专业的回答以下问题：$!{v_user_msg}
</lang-render>
<lang-ai result="v_answer" value="v_question" type="spring"/>

<lang-ai result="v_answer" type="dashscope"
         value.string="怎么删除Oracle的表"
         role.string="你是一个数据库专家，根据用户提问回答问题，给出对应的SQL语句并且给出语句的解释">
</lang-ai>
```

**注意事项：**

- type对应Context中的ChatAiProvider Bean的name()
- 有role时对应RoleChatAiProvider

**验证依据：
** [LangAiNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangAiNode.java)

---

### 5.35 lang-listener

**功能说明：**
注册事件监听器。

**DTD定义：**

```xml

<!ELEMENT lang-listener (ANY|EMPTY)>
<!ATTLIST lang-listener name CDATA #IMPLIED>
<!ATTLIST lang-listener type CDATA #IMPLIED>
<!ATTLIST lang-listener target CDATA #IMPLIED>
<!ATTLIST lang-listener params-share CDATA #IMPLIED>
```

**属性定义：**

| 属性名    | 类型      | 默认修饰符   | 说明                                  |
|--------|---------|---------|-------------------------------------|
| name   | String  | string  | 监听器名称（同名的会覆盖）                       |
| type   | String  | string  | 监听的事件类型                             |
| target | String  | string  | 事件对象存放的变量名                          |
| params-share | boolean | boolean | 是否共享事件发生时的上下文，默认false，不共享，在独立上下文中执行 |

**使用示例：**

```xml

<lang-listener name="sqlExecListener" type="SqlExecUseTimeEvent" target="event">

</lang-listener>
```

**验证依据：
** [LangListenerNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangListenerNode.java)

---

### 5.36 lang-async

**功能说明：**
异步执行，内部变量会被复制一份。

**DTD定义：**

```xml

<!ELEMENT lang-async (ANY|EMPTY)>
<!ATTLIST lang-async await CDATA #IMPLIED>
<!ATTLIST lang-async delay CDATA #IMPLIED>
<!ATTLIST lang-async time-unit CDATA #IMPLIED>
```

**属性定义：**

| 属性名       | 类型      | 默认修饰符   | 默认值  | 说明       |
|-----------|---------|---------|------|----------|
| await     | boolean | boolean | true | 是否等待执行结束 |
| delay     | long    | long    | -    | 延迟开始时间   |
| time-unit | String  | string  | -    | 时间单位     |

**使用示例：**

```xml

<lang-async>
    <sql-update script="v_sql"/>
</lang-async>

<lang-async await="true">
<sql-query-object result="v_cnt" script="v_sql" result-type="long"/>
</lang-async>
<lang-if test="v_cnt==0">
<lang-return/>
</lang-if>
```

**验证依据：
** [LangAsyncNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangAsyncNode.java)

---

### 5.37 lang-async-all

**功能说明：**
多个任务并行执行。

**DTD定义：**

```xml

<!ELEMENT lang-async-all (ANY|EMPTY)>
<!ATTLIST lang-async-all await CDATA #IMPLIED>
```

**属性定义：**

| 属性名   | 类型      | 默认修饰符   | 默认值 | 说明         |
|-------|---------|---------|-----|------------|
| await | boolean | boolean | -   | 是否等待所有任务完成 |

**使用示例：**

```xml

<lang-async-all>
    <lang-body>
        <sql-query-object result="v_cnt" script="v_user_count_sql" result-type="long"/>
    </lang-body>
    <lang-body>
        <sql-query-object result="roleKey" script="v_default_role_sql" result-type="string"/>
    </lang-body>
</lang-async-all>

<lang-async-all await="true">
<lang-async>
    <sql-query-object result="v_cnt" script="v_user_count_sql" result-type="long"/>
</lang-async>
<lang-async>
    <sql-query-object result="roleKey" script="v_default_role_sql" result-type="string"/>
</lang-async>
</lang-async-all>
```

**注意事项：**

- 子标签会被视为独立任务
- 内部变量修改对外不可见，如需修改请使用global变量

**验证依据：
** [LangAsyncAllNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangAsyncAllNode.java)

---

### 5.38 lang-latch

**功能说明：**
创建CountDownLatch。

**DTD定义：**

```xml

<!ELEMENT lang-latch (EMPTY)>
<!ATTLIST lang-latch count CDATA #IMPLIED>
<!ATTLIST lang-latch result CDATA #REQUIRED>
```

**属性定义：**

| 属性名    | 类型     | 默认修饰符 | 说明              |
|--------|--------|-------|-----------------|
| count  | int    | eval  | 计数器初始值（OGNL表达式） |
| result | String | -     | 结果变量名（必需）       |

**使用示例：**

```xml

<lang-latch result="v_latch" count.int="3"/>

<lang-latch result="v_latch" count="userList.size()"/>
```

**验证依据：
** [LangLatchNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangLatchNode.java)

---

### 5.39 lang-latch-down

**功能说明：**
对latch执行count-down操作。

**DTD定义：**

```xml

<!ELEMENT lang-latch-down (EMPTY)>
<!ATTLIST lang-latch-down name CDATA #REQUIRED>
```

**属性定义：**

| 属性名  | 类型     | 默认修饰符 | 说明       |
|------|--------|-------|----------|
| name | String | visit | latch变量名 |

**使用示例：**

```xml

<lang-latch-down name="v_latch"/>
```

**验证依据：
** [LangLatchDownNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangLatchDownNode.java)

---

### 5.40 lang-latch-await

**功能说明：**
等待latch计数归零。

**DTD定义：**

```xml

<!ELEMENT lang-latch-await (EMPTY)>
<!ATTLIST lang-latch-await name CDATA #REQUIRED>
<!ATTLIST lang-latch-await timeout CDATA #IMPLIED>
<!ATTLIST lang-latch-await time-unit CDATA #IMPLIED>
```

**属性定义：**

| 属性名       | 类型     | 默认修饰符  | 说明                |
|-----------|--------|--------|-------------------|
| name      | String | visit  | latch变量名          |
| timeout   | long   | long   | 超时时间（默认永久，没有超时限制） |
| time-unit | String | string | 时间单位              |

**使用示例：**

```xml

<lang-latch-await name="v_latch"/>
<lang-latch-await name="v_latch" time-unit="SECONDS" timeout="30"/>
```

**验证依据：
** [LangLatchAwaitNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangLatchAwaitNode.java)

---

### 5.41 lang-thread-pool

**功能说明：**
创建线程池。

**DTD定义：**

```xml

<!ELEMENT lang-thread-pool (EMPTY)>
<!ATTLIST lang-thread-pool result CDATA #IMPLIED>
<!ATTLIST lang-thread-pool type CDATA #IMPLIED>
<!ATTLIST lang-thread-pool count CDATA #REQUIRED>
```

**属性定义：**

| 属性名    | 类型     | 默认修饰符  | 说明                     |
|--------|--------|--------|------------------------|
| result | String | -      | 结果变量名（ExecutorService） |
| type   | String | string | 线程池类型（forkjoin/fixed）  |
| count  | int    | int    | 核心线程数（必需）              |

**使用示例：**

```xml

<lang-thread-pool result="V_POOL" type="forkjoin" count="30"/>
```

**验证依据：
** [LangThreadPoolNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangThreadPoolNode.java)

---

### 5.42 lang-thread-pool-submit

**功能说明：**
提交任务到线程池。

**DTD定义：**

```xml

<!ELEMENT lang-thread-pool-submit (EMPTY|ANY)>
<!ATTLIST lang-thread-pool-submit result CDATA #IMPLIED>
<!ATTLIST lang-thread-pool-submit pool CDATA #REQUIRED>
```

**属性定义：**

| 属性名    | 类型              | 默认修饰符 | 说明                    |
|--------|-----------------|-------|-----------------------|
| result | String          | -     | 结果变量名（CountDownLatch） |
| pool   | ExecutorService | visit | 线程池变量名（必需）            |

**使用示例：**

```xml

<lang-thread-pool result="V_POOL" type="forkjoin" count="30"/>

<!-- 其他属性，就是传入异步任务的参数，只有传入的参数，在内部才能够访问当，当然global一直都能访问到 -->
<lang-thread-pool-submit result="V_LATCH" pool="V_POOL" IN_TABLE="V_TABLE">
<sql-update>
    truncate table $!{IN_TABLE}
</sql-update>
</lang-thread-pool-submit>
```

**验证依据：
** [LangThreadPoolSubmitNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangThreadPoolSubmitNode.java)

---

### 5.43 lang-thread-pool-shutdown

**功能说明：**
关闭线程池。

**DTD定义：**

```xml

<!ELEMENT lang-thread-pool-shutdown (EMPTY)>
<!ATTLIST lang-thread-pool-shutdown result CDATA #IMPLIED>
<!ATTLIST lang-thread-pool-shutdown pool CDATA #REQUIRED>
<!ATTLIST lang-thread-pool-shutdown force CDATA #IMPLIED>
<!ATTLIST lang-thread-pool-shutdown await CDATA #IMPLIED>
<!ATTLIST lang-thread-pool-shutdown timeout CDATA #IMPLIED>
<!ATTLIST lang-thread-pool-shutdown time-unit CDATA #IMPLIED>
```

**属性定义：**

| 属性名       | 类型              | 默认修饰符   | 默认值        | 说明     |
|-----------|-----------------|---------|------------|--------|
| result    | String          | -       | 未执行任务列表    |
| pool      | ExecutorService | visit   | 线程池变量名（必需） |
| force     | boolean         | boolean | false      | 是否强制关闭 |
| await     | boolean         | boolean | false      | 是否等待关闭 |
| timeout   | long            | long    | -1         | 等待超时   |
| time-unit | String          | string  | SECONDS    | 时间单位   |

**使用示例：**

```xml

<lang-thread-pool-shutdown pool="V_POOL" force="true" await="true"/>
```

**验证依据：
** [LangThreadPoolShutdownNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangThreadPoolShutdownNode.java)

---

### 5.44 lang-sleep

**功能说明：**
线程休眠。

**DTD定义：**

```xml

<!ELEMENT lang-sleep (EMPTY)>
<!ATTLIST lang-sleep timeout CDATA #IMPLIED>
<!ATTLIST lang-sleep time-unit CDATA #IMPLIED>
```

**属性定义：**

| 属性名       | 类型     | 默认修饰符  | 说明   |
|-----------|--------|--------|------|
| timeout   | long   | long   | 睡眠时长 |
| time-unit | String | string | 时间单位 |

**使用示例：**

```xml

<lang-sleep timeout="30" time-unit="MILLISECONDS"/>
```

**验证依据：
** [LangSleepNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangSleepNode.java)

---

### 5.45 lang-eval-java

**功能说明：**
动态编译执行Java代码。

**DTD定义：**

```xml

<!ELEMENT lang-eval-java (lang-java-import?|lang-java-member?|lang-java-body?|#PCDATA)>
<!ATTLIST lang-eval-java result CDATA #IMPLIED>
```

**属性定义：**

| 属性名       | 类型     | 默认修饰符  | 说明                 |
|-----------|--------|--------|--------------------|
| result    | String | -      | 结果变量名，接受内部return的值 |

**子元素：**

| 元素名              | 说明             |
|------------------|----------------|
| lang-java-import | import语句部分     |
| lang-java-member | 成员变量和成员函数      |
| lang-java-body   | 方法体（需return语句） |

**使用示例：**

```xml

<lang-eval-java result="v_now">
    return new Date();
</lang-eval-java>

<lang-eval-java>
executor.visitSet(params,"v_now",new Date());
return null;
</lang-eval-java>

<lang-eval-java>
<lang-java-member>
    public Object nvl(Object a,Object b){
    return a==null?b:a;
    }
</lang-java-member>
<lang-java-body>
    return nvl(executor.visit("v_sql",params),"");
</lang-java-body>
</lang-eval-java>
```

**验证依据：
** [LangEvalJavaNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangEvalJavaNode.java)

---

### 5.46 lang-eval-javascript / lang-eval-js

**功能说明：**
执行JavaScript脚本。

**DTD定义：**

```xml

<!ELEMENT lang-eval-javascript (#PCDATA)>
<!ATTLIST lang-eval-javascript result CDATA #IMPLIED>
```

**属性定义：**

| 属性名    | 类型     | 默认修饰符 | 说明    |
|--------|--------|-------|-------|
| result | String | -     | 结果变量名 |

**使用示例：**

```xml

<lang-eval-javascript result="v_size">
    params.get("v_i")+params.get("v_cnt")
</lang-eval-javascript>

<lang-eval-js result="v_now">
new Date()
</lang-eval-js>
```

**验证依据：
** [LangEvalJavascriptNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangEvalJavascriptNode.java)

---

### 5.47 lang-eval-tinyscript / lang-eval-ts

**功能说明：**
执行TinyScript脚本。

**DTD定义：**

```xml

<!ELEMENT lang-eval-tinyscript (#PCDATA)>
<!ATTLIST lang-eval-tinyscript result CDATA #IMPLIED>
```

**属性定义：**

| 属性名    | 类型     | 默认修饰符 | 说明    |
|--------|--------|-------|-------|
| result | String | -     | 结果变量名 |

**使用示例：**

```xml

<lang-eval-tinyscript>
    v_i=${v_i}+1;
</lang-eval-tinyscript>

<lang-eval-ts result="v_i">
${v_i}+1
</lang-eval-ts>
```

**验证依据：
** [LangEvalTinyScriptNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangEvalTinyScriptNode.java)

---

### 5.48 lang-eval-groovy

**功能说明：**
执行Groovy脚本。

**DTD定义：**

```xml

<!ELEMENT lang-eval-groovy (#PCDATA)>
<!ATTLIST lang-eval-groovy result CDATA #IMPLIED>
```

**属性定义：**

| 属性名    | 类型     | 默认修饰符 | 说明    |
|--------|--------|-------|-------|
| result | String | -     | 结果变量名 |

**使用示例：**

```xml

<lang-eval-groovy result="v_now">
    new Date()
</lang-eval-groovy>

<lang-eval-groovy result="v_cnt">
params.v_cnt+1
</lang-eval-groovy>
```

**验证依据：
** [LangEvalGroovyNode.java](/src/main/java/.../jdbc/procedure/node/impl/LangEvalGroovyNode.java)

---

## 六、SQL操作节点 (sql-*)

节点内部都可以使用Mybatis兼容语法，也就是 `<if>` `<foreach>` `<choose>` `<when>` `<otherwise>` `<where>` `<set>` 等。

### 6.1 sql-script

**功能说明：**
SQL脚本片段，生成BindSql对象用于动态SQL。
生成的result结果变量，可以在其他语句中使用 #{} 方式直接注入，会自动展开

**DTD定义：**

```xml

<!ELEMENT sql-script (EMPTY|ANY)>
<!ATTLIST sql-script result CDATA #IMPLIED>
```

**属性定义：**

| 属性名    | 类型     | 默认修饰符 | 说明        |
|--------|--------|-------|-----------|
| result | String | -     | 结果变量名（必需） |

**使用示例：**

```xml

<sql-script result="v_sql">
    select *
    from ${tableName}
    <where>
        <if test="status!=null">
            and status=#{status}
        </if>
    </where>
</sql-script>
```

**与lang-render的区别：**

- lang-render返回String，需自行处理SQL注入
- sql-script返回BindSql，支持占位符防注入

**验证依据：
** [SqlScriptNode.java](/src/main/java/.../jdbc/procedure/node/impl/SqlScriptNode.java)

---

### 6.2 sql-query-row

**功能说明：**
查询单行数据。

**DTD定义：**

```xml

<!ELEMENT sql-query-row (EMPTY|ANY)>
<!ATTLIST sql-query-row datasource CDATA #IMPLIED>
<!ATTLIST sql-query-row script CDATA #IMPLIED>
<!ATTLIST sql-query-row result CDATA #IMPLIED>
<!ATTLIST sql-query-row result-type CDATA #IMPLIED>
<!ATTLIST sql-query-row limited CDATA #IMPLIED>
```

**属性定义：**

| 属性名         | 类型      | 默认修饰符   | 说明                                |
|-------------|---------|---------|-----------------------------------|
| datasource  | String  | string  | 数据源名称                             |
| script      | String  | visit   | SQL脚本变量（不写就是使用标签内部脚本）             |
| result      | String  | -       | 结果变量名                             |
| result-type | Class   | class   | 结果类型（默认Map）                       |
| limited     | boolean | boolean | 是否只取第一条（分页包装，就算实际语句返回多条，也能够处理为一条） |

**使用示例：**

```xml

<sql-query-row result="tmpRowMap" result-type="Map">
    select * from sys_user where id=#{id}
</sql-query-row>

<sql-query-row datasource="slave" result="tmpRowMap">
select * from sys_user where id=#{id}
</sql-query-row>

<sql-query-row result="anyRow" limited="true">
select * from sys_user where status=#{status}
</sql-query-row>

<sql-query-row result="v_user" script="v_sql"/>

<sql-query-row result="tmpUser" limited="true">
  <sql-dialect databases="oracle,dm,ob">
      SELECT * FROM SYS_USER WHERE STATUS=#{status}
  </sql-dialect>
  <sql-dialect databases="mysql,gbase,mariadb">
      select * from sys_user where status=#{status}
  </sql-dialect>
</sql-query-row>
```

**验证依据：
** [SqlQueryRowNode.java](/src/main/java/.../jdbc/procedure/node/impl/SqlQueryRowNode.java)

---

### 6.3 sql-query-list

**功能说明：**
查询多行数据（列表）。

**DTD定义：**

```xml

<!ELEMENT sql-query-list (EMPTY|ANY)>
<!ATTLIST sql-query-list datasource CDATA #IMPLIED>
<!ATTLIST sql-query-list script CDATA #IMPLIED>
<!ATTLIST sql-query-list result CDATA #IMPLIED>
<!ATTLIST sql-query-list result-type CDATA #IMPLIED>
<!ATTLIST sql-query-list offset CDATA #IMPLIED>
<!ATTLIST sql-query-list limit CDATA #IMPLIED>
```

**属性定义：**

| 属性名         | 类型     | 默认修饰符  | 说明                             |
|-------------|--------|--------|--------------------------------|
| datasource  | String | string | 数据源名称                          |
| script      | String | visit  | SQL脚本变量（不写就是使用标签内部脚本）          |
| result      | String | -      | 结果变量名                          |
| result-type | Class  | class  | 结果类型（默认Map，如有需要也可以写Pojo的全限定类名） |
| offset      | int    | int    | 起始偏移（分页包装，可选）                  |
| limit       | int    | int    | 获取数量（分页包装，可选）                  |

**使用示例：**

```xml

<sql-query-list result="userList">
    select * from sys_user where del_flag=1
</sql-query-list>

<sql-query-list result="userList" script="v_sql"/>

<sql-query-list script="v_sql" offset="100" limit="15"/>
```

**验证依据：
** [SqlQueryListNode.java](/src/main/java/.../jdbc/procedure/node/impl/SqlQueryListNode.java)

---

### 6.4 sql-query-columns

**功能说明：**
查询列元信息。

**DTD定义：**

```xml

<!ELEMENT sql-query-columns (EMPTY|ANY)>
<!ATTLIST sql-query-columns datasource CDATA #IMPLIED>
<!ATTLIST sql-query-columns script CDATA #IMPLIED>
<!ATTLIST sql-query-columns result CDATA #IMPLIED>
```

**属性定义：**

| 属性名        | 类型     | 默认修饰符  | 说明                   |
|------------|--------|--------|----------------------|
| datasource | String | string | 数据源名称                |
| script     | String | visit  | SQL脚本变量（不写就是使用标签内部脚本）              |
| result     | String | -      | 结果变量名（QueryColumn列表） |

**使用示例：**

```xml

<sql-query-columns result="v_columns">
    select * from sys_user where 1!=1
</sql-query-columns>

<sql-query-columns result="v_columns" script="v_sql"/>

        <!-- 拼接列名 -->
<lang-set result="v_sql" value.string=""/>
<lang-foreach collection="v_columns" item="item" first="v_first">
<lang-if test="v_first==false">
    <lang-set result="v_sql" value.render="$!{v_sql},"/>
</lang-if>
<lang-set result="v_sql" value.render="$!{v_sql}$!{item.label}"/>
</lang-foreach>
```

**验证依据：
** [SqlQueryColumnsNode.java](/src/main/java/.../jdbc/procedure/node/impl/SqlQueryColumnsNode.java)

---

### 6.5 sql-query-object

**功能说明：**
查询单个值（一行一列）。

**DTD定义：**

```xml

<!ELEMENT sql-query-object (EMPTY|ANY)>
<!ATTLIST sql-query-object datasource CDATA #IMPLIED>
<!ATTLIST sql-query-object script CDATA #IMPLIED>
<!ATTLIST sql-query-object result CDATA #IMPLIED>
<!ATTLIST sql-query-object result-type CDATA #IMPLIED>
<!ATTLIST sql-query-object limited CDATA #IMPLIED>
```

**属性定义：**

| 属性名         | 类型      | 默认修饰符   | 说明                     |
|-------------|---------|---------|------------------------|
| datasource  | String  | string  | 数据源名称                  |
| script      | String  | visit   | SQL脚本变量（不写就是使用标签内部脚本）  |
| result      | String  | -       | 结果变量名                  |
| result-type | Class   | class   | 结果类型（可写明要转换的类型，基础类型名称） |
| limited     | boolean | boolean | 是否只取第一条（强制只取第一条）       |

**使用示例：**

```xml

<sql-query-object result="v_cnt" result-type="long">
    select count(1) from sys_user where del_flag=1
</sql-query-object>

<sql-query-object result="v_code" result-type="string">
select dict_code form sys_dict where dict_type=#{dictType} and dict_value=#{dictValue}
</sql-query-object>

<sql-query-object result="v_cnt" script="v_sql" result-type="long"/>
```

**验证依据：
** [SqlQueryObjectNode.java](/src/main/java/.../jdbc/procedure/node/impl/SqlQueryObjectNode.java)

---

### 6.6 sql-update

**功能说明：**
执行更新语句（INSERT/UPDATE/DELETE）。

**DTD定义：**

```xml

<!ELEMENT sql-update (EMPTY|ANY)>
<!ATTLIST sql-update datasource CDATA #IMPLIED>
<!ATTLIST sql-update script CDATA #IMPLIED>
<!ATTLIST sql-update result CDATA #IMPLIED>
```

**属性定义：**

| 属性名         | 类型     | 默认修饰符  | 说明                       |
|-------------|--------|--------|--------------------------|
| datasource  | String | string | 数据源名称                    |
| script      | String | visit  | SQL脚本变量（不写就是使用标签内部脚本）    |
| result      | String | -      | 影响行数变量名(取决于具体的JDBC驱动返回值) |

**使用示例：**

```xml

<sql-update>
    delete from sys_user where del_flag=#{delFlag}
</sql-update>

<sql-update result="effectRows">
update sys_user set status=1 where create_time > #{activeDate}
</sql-update>

<sql-update script="v_sql"/>
```

**验证依据：
** [SqlUpdateNode.java](/src/main/java/.../jdbc/procedure/node/impl/SqlUpdateNode.java)

---

### 6.7 sql-dialect

**功能说明：**
指定SQL的数据库方言支持。
只能使用在其他sql-*节点内部作为根节点，内部会自动根据匹配的方言选择分支。

**DTD定义：**

```xml

<!ELEMENT sql-dialect (EMPTY|ANY)>
<!ATTLIST sql-dialect script CDATA #IMPLIED>
<!ATTLIST sql-dialect databases CDATA #REQUIRED>
```

**属性定义：**

| 属性名       | 类型     | 默认修饰符  | 说明                |
|-----------|--------|--------|-------------------|
| script    | String | visit  | SQL脚本变量           |
| databases | String | string | 支持的数据库类型（逗号分隔，必需） |

**使用示例：**

```xml

<sql-update>
    <sql-dialect databases="mysql,gbase,mariadb">
        update sys_user
        <set>
            <if test="true">
                username=#{username}
            </if>
        </set>
        <where>
            id=#{id}
        </where>
    </sql-dialect>
    <sql-dialect databases="oracle,dm">
        delete from sys_user
        where
        <if test="true">
            id=#{id}
        </if>
    </sql-dialect>
    <sql-dialect databases="postgre">
        insert into sys_user
        <trim prefix="(" suffix=")" prefixOverrides="," suffixOverrides=",">
            <if test="true">
                username,
            </if>
        </trim>
        values
        <trim prefix="(" suffix=")" prefixOverrides="," suffixOverrides=",">
            <if test="true">
                #{username},
            </if>
        </trim>
    </sql-dialect>
</sql-update>
```

**支持的数据库类型：**
mysql, oracle, postgre, dm, gbase, mariadb, sqlserver, ob 等

**验证依据：
** [SqlDialect.java](/src/main/java/.../jdbc/procedure/node/base/SqlDialect.java)

---

### 6.8 sql-trans-begin

**功能说明：**
开启事务。

**DTD定义：**

```xml

<!ELEMENT sql-trans-begin (EMPTY)>
<!ATTLIST sql-trans-begin datasource CDATA #IMPLIED>
<!ATTLIST sql-trans-begin isolation CDATA #IMPLIED>
```

**属性定义：**

| 属性名        | 类型     | 默认修饰符  | 说明                                |
|------------|--------|--------|-----------------------------------|
| datasource | String | string | 数据源名称（默认主数据源）                     |
| isolation  | String | string | 隔离级别（如TRANSACTION_READ_COMMITTED） |

**使用示例：**

```xml

<lang-try>
    <lang-body>
        <sql-trans-begin/>
        <sql-update script="v_sql"/>
        <sql-trans-commit/>
    </lang-body>
    <lang-catch>
        <sql-trans-rollback/>
    </lang-catch>
</lang-try>
```

**验证依据：
** [SqlTransBeginNode.java](/src/main/java/.../jdbc/procedure/node/impl/SqlTransBeginNode.java)

---

### 6.9 sql-trans-commit

**功能说明：**
提交事务。

**DTD定义：**

```xml

<!ELEMENT sql-trans-commit (EMPTY)>
<!ATTLIST sql-trans-commit datasource CDATA #IMPLIED>
```

**属性定义：**

| 属性名        | 类型     | 默认修饰符  | 说明    |
|------------|--------|--------|-------|
| datasource | String | string | 数据源名称 |

**使用示例：**

```xml

<sql-trans-commit/>
<sql-trans-commit datasource="primary"/>
```

**验证依据：
** [SqlTransCommitNode.java](/src/main/java/.../jdbc/procedure/node/impl/SqlTransCommitNode.java)

---

### 6.10 sql-trans-rollback

**功能说明：**
回滚事务。

**DTD定义：**

```xml

<!ELEMENT sql-trans-rollback (EMPTY)>
<!ATTLIST sql-trans-rollback datasource CDATA #IMPLIED>
```

**属性定义：**

| 属性名        | 类型     | 默认修饰符  | 说明    |
|------------|--------|--------|-------|
| datasource | String | string | 数据源名称 |

**使用示例：**

```xml

<sql-trans-rollback/>
<sql-trans-rollback datasource="primary"/>
```

**验证依据：
** [SqlTransRollbackNode.java](/src/main/java/.../jdbc/procedure/node/impl/SqlTransRollbackNode.java)

---

### 6.11 sql-trans-none

**功能说明：**
关闭事务（自动提交模式）。

**DTD定义：**

```xml

<!ELEMENT sql-trans-none (EMPTY)>
<!ATTLIST sql-trans-none datasource CDATA #IMPLIED>
```

**属性定义：**

| 属性名        | 类型     | 默认修饰符  | 说明    |
|------------|--------|--------|-------|
| datasource | String | string | 数据源名称 |

**使用示例：**

```xml

<sql-trans-none/>
```

**验证依据：
** [SqlTransNoneNode.java](/src/main/java/.../jdbc/procedure/node/impl/SqlTransNoneNode.java)

---

### 6.12 sql-transactional

**功能说明：**
声明式事务控制，类似Spring的@Transactional。

**DTD定义：**

```xml

<!ELEMENT sql-transactional (EMPTY|ANY)>
<!ATTLIST sql-transactional datasources CDATA #IMPLIED>
<!ATTLIST sql-transactional propagation CDATA #IMPLIED>
<!ATTLIST sql-transactional isolation CDATA #IMPLIED>
<!ATTLIST sql-transactional read-only CDATA #IMPLIED>
<!ATTLIST sql-transactional rollback-for CDATA #IMPLIED>
<!ATTLIST sql-transactional no-rollback-for CDATA #IMPLIED>
```

**属性定义：**

| 属性名             | 类型      | 默认修饰符   | 默认值                        | 说明          |
|-----------------|---------|---------|----------------------------|-------------|
| datasources     | String  | string  | primary                    | 数据源列表（逗号分隔） |
| propagation     | String  | string  | REQUIRED                   | 传播级别        |
| isolation       | String  | string  | TRANSACTION_READ_COMMITTED | 隔离级别        |
| read-only       | boolean | boolean | false                      | 是否只读        |
| rollback-for    | String  | string  | RuntimeException           | 回滚异常类型      |
| no-rollback-for | String  | string  | -                          | 不回滚异常类型     |

**使用示例：**

```xml

<sql-transactional>
    <sql-update>
        delete from xxx where ...
    </sql-update>
</sql-transactional>

<sql-transactional datasources="primary,ods"
                   propagation="REQUIRED"
                   isolation="TRANSACTION_READ_COMMITTED"
                   read-only="false"
                   rollback-for="RuntimeException"
                   no-rollback-for="ReflectiveOperationException">
<sql-update>
    delete from xxx where ...
</sql-update>
</sql-transactional>
```

**验证依据：
** [SqlTransactionalNode.java](/src/main/java/.../jdbc/procedure/node/impl/SqlTransactionalNode.java)

---

### 6.13 sql-runner

**功能说明：**
执行SQL脚本（多语句）。

**DTD定义：**

```xml

<!ELEMENT sql-runner (EMPTY|ANY)>
<!ATTLIST sql-runner datasource CDATA #IMPLIED>
<!ATTLIST sql-runner result CDATA #IMPLIED>
<!ATTLIST sql-runner script CDATA #IMPLIED>
<!ATTLIST sql-runner separator CDATA #IMPLIED>
<!ATTLIST sql-runner full-send CDATA #IMPLIED>
<!ATTLIST sql-runner jump-error CDATA #IMPLIED>
```

**属性定义：**

| 属性名        | 类型      | 默认修饰符   | 默认值   | 说明                   |
|------------|---------|---------|-------|----------------------|
| datasource | String  | string  | -     | 数据源名称                |
| result     | String  | -       | -     | 结果变量名                |
| script     | String  | visit   | -     | SQL脚本变量（不写则使用标签内部脚本） |
| separator  | String  | string  | ;     | 语句分隔符                |
| full-send  | boolean | boolean | false | 完整发送（某些驱动需要）         |
| jump-error | boolean | boolean | false | 错误时是否继续              |

**使用示例：**

```xml

<sql-runner>
    delete from sys_user_role
    where user_id in (select a.user_id from sys_user where del_flag = 1);
    delete from sys_user where del_flag = 1;
</sql-runner>

<lang-set result="v_del_flag" value.int="1"/>
<lang-render result="v_sql" _lang="sql">
delete from sys_user_role where user_id in (select a.user_id from sys_user where del_flag = $!{v_del_flag});
delete from sys_user where del_flag = $!{v_del_flag};
</lang-render>
<sql-runner script="v_sql"/>
```

**验证依据：
** [SqlRunnerNode.java](/src/main/java/.../jdbc/procedure/node/impl/SqlRunnerNode.java)

---

### 6.14 sql-scope

**功能说明：**
创建数据库连接范围。
创建一个独立的数据库连接环境，内部的连接将会重新申请，实现连接隔离。

**DTD定义：**

```xml

<!ELEMENT sql-scope (ANY)>
<!ATTLIST sql-scope datasources CDATA #IMPLIED>
```

**属性定义：**

| 属性名         | 类型     | 默认修饰符  | 说明                  |
|-------------|--------|--------|---------------------|
| datasources | String | string | 数据源列表（逗号分隔，all表示全部） |

**使用示例：**

```xml

<sql-scope datasources="primary">
    <sql-update>
        insert into sys_log(location,create_time,content)
        values (#{location},sysdate,#{content})
    </sql-update>
</sql-scope>
```

**验证依据：
** [SqlScopeNode.java](/src/main/java/.../jdbc/procedure/node/impl/SqlScopeNode.java)

---

### 6.15 sql-cursor

**功能说明：**
游标遍历，类似数据库游标操作。

**DTD定义：**

```xml

<!ELEMENT sql-cursor (sql-query-list|lang-body)>
<!ATTLIST sql-cursor batch-size CDATA #IMPLIED>
<!ATTLIST sql-cursor item CDATA #IMPLIED>
<!ATTLIST sql-cursor accept-batch CDATA #IMPLIED>
<!ATTLIST sql-cursor use-cursor CDATA #IMPLIED>
```

**属性定义：**

| 属性名          | 类型      | 默认修饰符   | 默认值   | 说明                                               |
|--------------|---------|---------|-------|--------------------------------------------------|
| batch-size   | int     | int     | 2000  | 每次处理数量                                           |
| item         | String  | string  | item  | 迭代变量名(如果accept-batch为false，则接受一行数据，为true则接受一批数据) |
| accept-batch | boolean | boolean | false | 是否批量传递                                           |
| use-cursor   | boolean | boolean | false | 是否使用JDBC游标                                       |

**子元素：**

| 元素名            | 说明   |
|----------------|------|
| sql-query-list | 查询语句 |
| lang-body      | 处理逻辑 |

**使用示例：**

```xml

<sql-cursor item="cur_item">
    <sql-query-list>
        select * from sys_user
    </sql-query-list>
    <lang-body>
        <sql-update>
            update sys_user set user_name=trim(user_name) where id=#{cur_item.id}
        </sql-update>
    </lang-body>
</sql-cursor>

<sql-cursor item="v_cur">
<sql-query-list script="v_sql"/>
<lang-body>
    <sql-update>
        update sys_user set user_name=trim(user_name) where id=#{v_cur.id}
    </sql-update>
</lang-body>
</sql-cursor>
```

**验证依据：
** [SqlCursorNode.java](/src/main/java/.../jdbc/procedure/node/impl/SqlCursorNode.java)

---

### 6.16 sql-etl

**功能说明：**
数据库表ETL（抽取、转换、加载）。

**DTD定义：**

```xml

<!ELEMENT sql-etl (sql-query-list|etl-extra|etl-transform+|etl-load|etl-before|etl-after)>
<!ATTLIST sql-etl read-batch-size CDATA #IMPLIED>
<!ATTLIST sql-etl write-batch-size CDATA #IMPLIED>
<!ATTLIST sql-etl before-truncate CDATA #IMPLIED>
<!ATTLIST sql-etl commit-size CDATA #IMPLIED>
<!ATTLIST sql-etl use-cursor CDATA #IMPLIED>
<!ATTLIST sql-etl item CDATA #IMPLIED>
<!ATTLIST sql-etl sync CDATA #IMPLIED>
```

**sql-etl属性定义：**

| 属性名              | 类型      | 默认修饰符   | 默认值              | 说明           |
|------------------|---------|---------|------------------|--------------|
| read-batch-size  | int     | int     | 50000            | 读取批次大小       |
| write-batch-size | int     | int     | 10000            | 写入批次大小       |
| before-truncate  | boolean | boolean | false            | 执行前是否清空表     |
| commit-size      | int     | int     | write-batch-size | 提交批次大小       |
| use-cursor       | boolean | boolean | false            | 是否使用JDBC游标   |
| item             | String  | string  | item             | 迭代变量名        |
| sync             | boolean | boolean | false            | 同步模式（读写同一线程） |

**子元素：**

| 元素名            | 说明     |
|----------------|--------|
| sql-query-list | 源数据查询  |
| etl-extra      | 源表指定   |
| etl-transform  | 列转换映射  |
| etl-load       | 目标表指定  |
| etl-before     | ETL前操作 |
| etl-after      | ETL后操作 |

**使用示例：**

```xml
<!-- 直接指定源表和目标表 -->
<sql-etl>
    <etl-extra datasource="oracle" table="COMM.SYS_DICT"/>
    <etl-load datasource="primary" table="DIM_SYS_DICT"/>
</sql-etl>

        <!-- 使用查询语句 -->
<sql-etl>
<sql-query-list datasource="oracle">
    select * from COMM.SYS_DICT where status=1
</sql-query-list>
<etl-load datasource="primary" table="DIM_SYS_DICT"/>
<etl-before>
    <sql-update datasource="primary">
        truncate table DIM_SYS_DICT
    </sql-update>
</etl-before>
</sql-etl>

        <!-- 手动列映射 -->
<sql-etl>
<etl-extra datasource="oracle" table="COMM.SYS_DICT"/>
<etl-transform source="DICT_ID" target="DICT_ID"/>
<etl-transform source="DICT_NAME" target="DICT_TEXT"/>
<etl-load datasource="primary" table="DIM_SYS_DICT"/>
</sql-etl>

        <!-- 特殊映射属性 -->
<sql-etl item="iter">
<etl-extra datasource="oracle" table="COMM.SYS_DICT"/>
<etl-transform source="DICT_ID" target="DICT_ID"/>
<etl-transform source="DICT_NAME" target="DICT_TEXT"/>
<!-- 排除列 -->
<etl-transform source="" target="ROWID" exclude="true"/>
<!-- 增加列 -->
<etl-transform source="DICT_NAME" target="DICT_TITLE" include="true"/>
<!-- 外部变量 -->
<etl-transform source.date-now="" target="SYNC_TIME" external="true"/>
<etl-transform source.visit="SYNC_ID" target="SYNC_ID" external="true"/>
<etl-transform source.visit="item.DICT_ID" target="SYNC_ID" external="true"/>
<etl-load datasource="primary" table="DIM_SYS_DICT"/>
</sql-etl>
```

**etl-transform属性：**

| 属性名       | 类型      | 默认修饰符   | 说明                    |
|-----------|---------|---------|-----------------------|
| source    | String  | string  | 源列名                   |
| target    | String  | string  | 目标列名                  |
| type      | String  | string  | Java类型                |
| jdbc-type | String  | string  | JDBC类型（如VARCHAR,DATE） |
| exclude   | boolean | boolean | 是否排除此列                |
| include   | boolean | boolean | 是否增加此列                |
| external  | boolean | boolean | 是否从外部上下文取值            |

**etl-extra属性：**

| 属性名        | 类型     | 默认修饰符  | 说明    |
|------------|--------|--------|-------|
| datasource | String | string | 数据源名称 |
| table      | String | string | 表名    |

**etl-load属性：**

| 属性名        | 类型     | 默认修饰符  | 说明    |
|------------|--------|--------|-------|
| datasource | String | string | 数据源名称 |
| table      | String | string | 表名    |

**验证依据：
** [SqlEtlNode.java](/src/main/java/.../jdbc/procedure/node/impl/SqlEtlNode.java)

---

## 七、过程调用节点

### 7.1 procedure

**功能说明：**
定义一个存储过程（入口节点）。

**DTD定义：**

```xml

<!ELEMENT procedure (ANY|EMPTY)>
<!ATTLIST procedure id CDATA #IMPLIED>
```

**属性定义：**

| 属性名 | 类型     | 说明            |
|-----|--------|---------------|
| id  | String | 过程ID（必需，用于调用） |

**使用示例：**

```xml
<!DOCTYPE procedure SYSTEM "procedure.dtd">
<!-- 其他属性，仅仅是声明这个过程仅输入输出参数都是什么名称，
都是什么类型，int/string/double/...
是否是输出参数的，in/out/inout
没有严格要求写明，但是建议写明，方便调用方理解调用契约 -->
<procedure id="SP_USER_PROCESS"
           IN_USER_ID.int=""
           OUT_CODE.int.out=""
           OUT_MSG.string.out=""
>
    <!-- 过程体 -->
</procedure>
```

**验证依据：
** [ProcedureNode.java](/src/main/java/.../jdbc/procedure/node/impl/ProcedureNode.java)

---

### 7.2 procedure-call

**功能说明：**
调用其他存储过程。

**DTD定义：**

```xml

<!ELEMENT procedure-call (ANY|EMPTY)>
<!ATTLIST procedure-call params CDATA #IMPLIED>
<!ATTLIST procedure-call refid CDATA #IMPLIED>
<!ATTLIST procedure-call result CDATA #IMPLIED>
<!ATTLIST procedure-call params-share CDATA #IMPLIED>
<!ATTLIST procedure-call refid.visit CDATA #IMPLIED>
```

**属性定义：**

| 属性名          | 类型      | 默认修饰符   | 说明                                               |
|--------------|---------|---------|--------------------------------------------------|
| refid        | String  | string  | 被调用的过程ID                                         |
| params       | Map     | visit   | 参数上下文（不指定则默认创建独立上下文，当然global还是共享的）               |
| result       | String  | -       | 结果变量名（返回的params Map）                             |
| params-share | boolean | boolean | 是否共享上下文（如果为true，则被调用方使用的上下文和调用方是同一个上下文，不存在上下文切换） |

其他属性，表示传递给被调用过程的参数。

**使用示例：**

```xml
<!-- 调用函数 -->
<procedure-call refid="F_TEST" result="callParams" IN_SUM_MONTH="V_SUM_MONTH"/>
<!-- 如果是被调用方是函数契约，那么可以直接访问固定的 return 得到函数的返回值 -->
<lang-set result="V_IS_TEST" value="callParams.return"/>

        <!-- 调用过程 -->
<procedure-call refid="SP_TEST" result="callParams" IN_SUM_MONTH.int="202501"/>
<lang-set result="V_FLAG" value="callParams.O_FLAG"/>
<lang-set result="V_MSG" value="callParams.O_MSG"/>

        <!-- 使用预定义参数 -->
<lang-new-params result="callParams" IN_SUM_MONTH="V_SUM_MONTH"/>
<procedure-call refid="SP_MAIN" params="callParams"/>

        <!-- 共享上下文 -->
<procedure-call refid="SP_MAIN" params-share="true"/>

        <!-- 动态过程名 -->
<lang-set result="V_SP_NAME" value.string="SP_MAIN"/>
<procedure-call refid.visit="V_SP_NAME" params-share="true"/>
```

**验证依据：
** [ProcedureCallNode.java](/src/main/java/.../jdbc/procedure/node/impl/ProcedureCallNode.java)

---

### 7.3 function-call

**功能说明：**
调用函数，与procedure-call类似但返回值处理不同。
也就是按照函数契约，result返回的就是函数的返回值，不用单独提取 return 返回值。
其余行为是一致的。

**DTD定义：**

```xml

<!ELEMENT function-call (ANY|EMPTY)>
<!ATTLIST function-call params CDATA #IMPLIED>
<!ATTLIST function-call refid CDATA #IMPLIED>
<!ATTLIST function-call result CDATA #IMPLIED>
<!ATTLIST function-call params-share CDATA #IMPLIED>
```

**属性定义：**

| 属性名          | 类型      | 默认修饰符   | 说明                 |
|--------------|---------|---------|--------------------|
| refid        | String  | string  | 被调用的函数ID           |
| params       | Map     | visit   | 参数上下文 （不指定则默认创建独立上下文，当然global还是共享的）               |
| result       | String  | -       | 结果变量名（直接返回return值） |
| params-share | boolean | boolean | 是否共享上下文 （如果为true，则被调用方使用的上下文和调用方是同一个上下文，不存在上下文切换）            |

其他属性，表示传递给被调用过程的参数。

**使用示例：**

```xml
<!-- result直接获取函数返回值 -->
<function-call refid="F_TEST" result="V_IS_TEST" IN_SUM_MONTH.int="202501"/>
```

**与procedure-call的区别：**

- procedure-call的result返回整个params Map
- function-call的result直接返回函数的return值

**验证依据：
** [FunctionCallNode.java](/src/main/java/.../jdbc/procedure/node/impl/FunctionCallNode.java)

---

### 7.4 java-call

**功能说明：**
调用Java回调方法。

**DTD定义：**

```xml

<!ELEMENT java-call (ANY|EMPTY)>
<!ATTLIST java-call target CDATA #IMPLIED>
<!ATTLIST java-call result CDATA #IMPLIED>
```

**属性定义：**

| 属性名    | 类型          | 默认修饰符 | 说明                         |
|--------|-------------|-------|----------------------------|
| target | String | visit | JdbcProcedureJavaCaller实现类 |
| result | String      | -     | 结果变量名                      |

**使用示例：**

```xml

<java-call target="funcTestCaller" result="V_IS_TEST"/>
<java-call target="com.test.caller.FuncTestCaller" result="V_IS_TEST"/>
```

**target查找优先级：**

1. Bean名称
2. Params访问变量
3. Bean全限定类名
4. Bean短类名
5. 反射类名

**验证依据：
** [JavaCallNode.java](/src/main/java/.../jdbc/procedure/node/impl/JavaCallNode.java)

---

## 八、脚本片段节点

### 8.1 script-segment

**功能说明：**
定义可复用的脚本片段。

**DTD定义：**

```xml

<!ELEMENT script-segment (ANY)>
<!ATTLIST script-segment id CDATA #REQUIRED>
```

**属性定义：**

| 属性名 | 类型     | 说明          |
|-----|--------|-------------|
| id  | String | 片段ID（必需，唯一） |

其他属性，表示声明的形式参数。
也可以具有返回值，按照函数契约进行。

**使用示例：**

```xml

<script-segment id="common" IN_SQL.string="">
    <log-info value="执行中..."/>
    <sql-update script="IN_SQL"/>
</script-segment>
```

其实实际作用和 `procedure` 一样。
只不过 `script-segment` 允许在 `procedure` 内部声明。
不同的 `procedure` 内部可以有同名id的 `script-segment` 。

**验证依据：
** [ScriptSegmentNode.java](/src/main/java/.../jdbc/procedure/node/impl/ScriptSegmentNode.java)

---

### 8.2 script-include

**功能说明：**
引用已定义的脚本片段。
这种方式引入的片段，是共享上下文的，

**DTD定义：**

```xml

<!ELEMENT script-include (ANY|EMPTY)>
<!ATTLIST script-include refid CDATA #IMPLIED>
<!ATTLIST script-include refid.visit CDATA #IMPLIED>
```

**属性定义：**

| 属性名   | 类型     | 默认修饰符  | 说明      |
|-------|--------|--------|---------|
| refid | String | string | 引用的片段ID |

可以添加其他属性，用来直接在上下文中定义变量。
实际就是在同一个上下文中进行变量赋值。

**使用示例：**

```xml

<script-include refid="common"/>
<script-include refid="common" IN_SQL="V_SQL"/>
```

**验证依据：
** [ScriptIncludeNode.java](/src/main/java/.../jdbc/procedure/node/impl/ScriptIncludeNode.java)

---

## 九、上下文管理节点

### 9.1 context-load-package

**功能说明：**
添加包名前缀，简化lang-invoke的method书写。

**DTD定义：**

```xml

<!ELEMENT context-load-package (EMPTY)>
<!ATTLIST context-load-package package CDATA #IMPLIED>
<!ATTLIST context-load-package class CDATA #IMPLIED>
```

**属性定义：**

| 属性名     | 类型     | 说明           |
|---------|--------|--------------|
| package | String | 包名前缀         |
| class   | String | 完整类名（会提取包前缀） |

**使用示例：**

```xml

<context-load-package package="com.test.utils"/>
<context-load-package class="com.test.utils.StringUtils"/>
```

**验证依据：
** [ContextLoadPackageNode.java](/src/main/java/.../jdbc/procedure/node/impl/ContextLoadPackageNode.java)

---

### 9.2 context-invoke-method-class

**功能说明：**
注册类中的public方法到上下文中。

**DTD定义：**

```xml

<!ELEMENT context-invoke-method-class (EMPTY)>
<!ATTLIST context-invoke-method-class class CDATA #IMPLIED>
```

**属性定义：**

| 属性名   | 类型     | 说明    |
|-------|--------|-------|
| class | String | 类全限定名 |

**使用示例：**

```xml

<context-invoke-method-class class="com.test.util.StringUtils"/>
```

**验证依据：
** [ContextInvokeMethodClassNode.java](/src/main/java/.../jdbc/procedure/node/impl/ContextInvokeMethodClassNode.java)

---

### 9.3 context-convert-method-class

**功能说明：**
注册类中的静态方法作为类型转换器。

**DTD定义：**

```xml

<!ELEMENT context-convert-method-class (EMPTY)>
<!ATTLIST context-convert-method-class class CDATA #IMPLIED>
```

**属性定义：**

| 属性名   | 类型     | 说明    |
|-------|--------|-------|
| class | String | 类全限定名 |

**要求：**

- 必须是public static方法
- 只有一个入参
- 有返回值
- 方法签名：`public static Object methodName(Object v)`

**使用示例：**

```xml

<context-convert-method-class class="com.test.util.ConvertUtils"/>
```

**验证依据：
** [ContextConvertMethodClassNode.java](/src/main/java/.../jdbc/procedure/node/impl/ContextConvertMethodClassNode.java)

---

## 十、事件节点

### 10.1 event-send

**功能说明：**
同步发送事件，阻塞等待监听器执行完毕。

**DTD定义：**

```xml

<!ELEMENT event-send (EMPTY)>
<!ATTLIST event-send event-type CDATA #IMPLIED>
```

**属性定义：**

| 属性名        | 类型     | 默认修饰符  | 说明   |
|------------|--------|--------|------|
| event-type | String | string | 事件类型 |

其他属性，为事件发布后携带的事件参数。

**使用示例：**

```xml

<event-send event-type="email" title.string="email title" content.render="email content:$!{trace.location}"/>
```

**验证依据：
** [EventSendNode.java](/src/main/java/.../jdbc/procedure/node/impl/EventSendNode.java)

---

### 10.2 event-publish

**功能说明：**
异步发送事件，不阻塞执行。

**DTD定义：**

```xml

<!ELEMENT event-publish (EMPTY)>
<!ATTLIST event-publish event-type CDATA #IMPLIED>
```

**属性定义：**

| 属性名        | 类型     | 默认修饰符  | 说明   |
|------------|--------|--------|------|
| event-type | String | string | 事件类型 |

其他属性，为事件发布后携带的事件参数。

**使用示例：**

```xml

<event-publish event-type="email" title.string="email title" content.render="email content:$!{trace.location}"/>
```

**验证依据：
** [EventPublishNode.java](/src/main/java/.../jdbc/procedure/node/impl/EventPublishNode.java)

---

## 十一、MyBatis兼容标签

框架支持以下MyBatis兼容的动态SQL标签：

### 11.1 where

**功能说明：**
智能WHERE块，自动处理多余AND/OR。

**使用示例：**

```xml

<sql-query-list>
    SELECT * FROM users
    <where>
        <if test="name != null">
            AND name = #{name}
        </if>
        <if test="age != null">
            AND age = #{age}
        </if>
    </where>
</sql-query-list>
```

---

### 11.2 if

**功能说明：**
条件判断，满足条件时包含内容。

**使用示例：**

```xml

<sql-update>
    UPDATE users
    <set>
        <if test="name != null">
            name = #{name},
        </if>
        <if test="age != null">
            age = #{age},
        </if>
    </set>
    WHERE id = #{id}
</update>
```

---

### 11.3 foreach

**功能说明：**
循环遍历，生成IN条件等。

**使用示例：**

```xml
<sql-query-list>
    SELECT * FROM users
    WHERE id IN
    <foreach collection="ids" item="id" open="(" separator="," close=")">
        #{id}
    </foreach>
</sql-query-list>
```

---

### 11.4 trim

**功能说明：**
自定义前后缀处理。

**使用示例：**

```xml

<sql-update>
    INSERT INTO users (name, age)
    VALUES
    <foreach collection="list" item="item" separator=",">
        <trim prefix="(" suffix=")" suffixOverrides=",">
            #{item.name}, #{item.age}
        </trim>
    </foreach>
</sql-update>
```

---

### 11.5 choose / when / otherwise

**功能说明：**
类似switch-case的选择结构。

**使用示例：**

```xml

<sql-query-list>
    SELECT * FROM users
    <where>
        <choose>
            <when test="status == 1">
                AND status = 1
            </when>
            <when test="status == 2">
                AND status = 2
            </when>
            <otherwise>
                AND status = 0
            </otherwise>
        </choose>
    </where>
</sql-query-list>
```

---

### 11.6 bind

**功能说明：**
创建变量。

**使用示例：**

```xml

<sql-query-list>
    <bind name="pattern" value="'%' + name + '%'"/>
    SELECT * FROM users
    WHERE name LIKE #{pattern}
</sql-query-list>
```

---

## 十二、验证依据汇总

本文档中所有节点定义均经过以下源代码验证：

| 节点类                           | 文件路径                                                                                                          |
|-------------------------------|---------------------------------------------------------------------------------------------------------------|
| LogDebugNode                  | /src/main/java/.../jdbc/procedure/node/impl/LogDebugNode.java                  |
| LogInfoNode                   | /src/main/java/.../jdbc/procedure/node/impl/LogInfoNode.java                   |
| LogWarnNode                   | /src/main/java/.../jdbc/procedure/node/impl/LogWarnNode.java                   |
| LogErrorNode                  | /src/main/java/.../jdbc/procedure/node/impl/LogErrorNode.java                  |
| DebuggerNode                  | /src/main/java/.../jdbc/procedure/node/impl/DebuggerNode.java                  |
| LangPrintlnNode               | /src/main/java/.../jdbc/procedure/node/impl/LangPrintlnNode.java               |
| LangPrintfNode                | /src/main/java/.../jdbc/procedure/node/impl/LangPrintfNode.java                |
| LangSetNode                   | /src/main/java/.../jdbc/procedure/node/impl/LangSetNode.java                   |
| LangFormatDateNode            | /src/main/java/.../jdbc/procedure/node/impl/LangFormatDateNode.java            |
| LangFormatNode                | /src/main/java/.../jdbc/procedure/node/impl/LangFormatNode.java                |
| LangStringJoinNode            | /src/main/java/.../jdbc/procedure/node/impl/LangStringJoinNode.java            |
| LangNewParamsNode             | /src/main/java/.../jdbc/procedure/node/impl/LangNewParamsNode.java             |
| LangIfNode                    | /src/main/java/.../jdbc/procedure/node/impl/LangIfNode.java                    |
| LangChooseNode                | /src/main/java/.../jdbc/procedure/node/impl/LangChooseNode.java                |
| LangWhenNode                  | /src/main/java/.../jdbc/procedure/node/impl/LangWhenNode.java                  |
| LangForeachNode               | /src/main/java/.../jdbc/procedure/node/impl/LangForeachNode.java               |
| LangForiNode                  | /src/main/java/.../jdbc/procedure/node/impl/LangForiNode.java                  |
| LangWhileNode                 | /src/main/java/.../jdbc/procedure/node/impl/LangWhileNode.java                 |
| LangDoWhileNode               | /src/main/java/.../jdbc/procedure/node/impl/LangDoWhileNode.java               |
| LangBreakNode                 | /src/main/java/.../jdbc/procedure/node/impl/LangBreakNode.java                 |
| LangContinueNode              | /src/main/java/.../jdbc/procedure/node/impl/LangContinueNode.java              |
| LangReturnNode                | /src/main/java/.../jdbc/procedure/node/impl/LangReturnNode.java                |
| LangThrowNode                 | /src/main/java/.../jdbc/procedure/node/impl/LangThrowNode.java                 |
| LangBodyNode                  | /src/main/java/.../jdbc/procedure/node/impl/LangBodyNode.java                  |
| LangTryNode                   | /src/main/java/.../jdbc/procedure/node/impl/LangTryNode.java                   |
| LangEvalNode                  | /src/main/java/.../jdbc/procedure/node/impl/LangEvalNode.java                  |
| LangStringNode                | /src/main/java/.../jdbc/procedure/node/impl/LangStringNode.java                |
| LangRenderNode                | /src/main/java/.../jdbc/procedure/node/impl/LangRenderNode.java                |
| LangInvokeNode                | /src/main/java/.../jdbc/procedure/node/impl/LangInvokeNode.java                |
| LangShellNode                 | /src/main/java/.../jdbc/procedure/node/impl/LangShellNode.java                 |
| LangFileExistsNode            | /src/main/java/.../jdbc/procedure/node/impl/LangFileExistsNode.java            |
| LangFileMkdirsNode            | /src/main/java/.../jdbc/procedure/node/impl/LangFileMkdirsNode.java            |
| LangFileDeleteNode            | /src/main/java/.../jdbc/procedure/node/impl/LangFileDeleteNode.java            |
| LangFileListNode              | /src/main/java/.../jdbc/procedure/node/impl/LangFileListNode.java              |
| LangFileTreeNode              | /src/main/java/.../jdbc/procedure/node/impl/LangFileTreeNode.java              |
| LangFileReadTextNode          | /src/main/java/.../jdbc/procedure/node/impl/LangFileReadTextNode.java          |
| LangFileWriteTextNode         | /src/main/java/.../jdbc/procedure/node/impl/LangFileWriteTextNode.java         |
| LangSynchronizedNode          | /src/main/java/.../jdbc/procedure/node/impl/LangSynchronizedNode.java          |
| LangRetryNode                 | /src/main/java/.../jdbc/procedure/node/impl/LangRetryNode.java                 |
| LangLockNode                  | /src/main/java/.../jdbc/procedure/node/impl/LangLockNode.java                  |
| LangAiNode                    | /src/main/java/.../jdbc/procedure/node/impl/LangAiNode.java                    |
| LangListenerNode              | /src/main/java/.../jdbc/procedure/node/impl/LangListenerNode.java              |
| LangAsyncNode                 | /src/main/java/.../jdbc/procedure/node/impl/LangAsyncNode.java                 |
| LangAsyncAllNode              | /src/main/java/.../jdbc/procedure/node/impl/LangAsyncAllNode.java              |
| LangLatchNode                 | /src/main/java/.../jdbc/procedure/node/impl/LangLatchNode.java                 |
| LangLatchDownNode             | /src/main/java/.../jdbc/procedure/node/impl/LangLatchDownNode.java             |
| LangLatchAwaitNode            | /src/main/java/.../jdbc/procedure/node/impl/LangLatchAwaitNode.java            |
| LangThreadPoolNode            | /src/main/java/.../jdbc/procedure/node/impl/LangThreadPoolNode.java            |
| LangThreadPoolSubmitNode      | /src/main/java/.../jdbc/procedure/node/impl/LangThreadPoolSubmitNode.java      |
| LangThreadPoolShutdownNode    | /src/main/java/.../jdbc/procedure/node/impl/LangThreadPoolShutdownNode.java    |
| LangSleepNode                 | /src/main/java/.../jdbc/procedure/node/impl/LangSleepNode.java                 |
| LangEvalJavaNode              | /src/main/java/.../jdbc/procedure/node/impl/LangEvalJavaNode.java              |
| LangEvalJavascriptNode        | /src/main/java/.../jdbc/procedure/node/impl/LangEvalJavascriptNode.java        |
| LangEvalTinyScriptNode        | /src/main/java/.../jdbc/procedure/node/impl/LangEvalTinyScriptNode.java        |
| LangEvalGroovyNode            | /src/main/java/.../jdbc/procedure/node/impl/LangEvalGroovyNode.java            |
| SqlScriptNode                 | /src/main/java/.../jdbc/procedure/node/impl/SqlScriptNode.java                 |
| SqlQueryRowNode               | /src/main/java/.../jdbc/procedure/node/impl/SqlQueryRowNode.java               |
| SqlQueryListNode              | /src/main/java/.../jdbc/procedure/node/impl/SqlQueryListNode.java              |
| SqlQueryColumnsNode           | /src/main/java/.../jdbc/procedure/node/impl/SqlQueryColumnsNode.java           |
| SqlQueryObjectNode            | /src/main/java/.../jdbc/procedure/node/impl/SqlQueryObjectNode.java            |
| SqlUpdateNode                 | /src/main/java/.../jdbc/procedure/node/impl/SqlUpdateNode.java                 |
| SqlTransBeginNode             | /src/main/java/.../jdbc/procedure/node/impl/SqlTransBeginNode.java             |
| SqlTransCommitNode            | /src/main/java/.../jdbc/procedure/node/impl/SqlTransCommitNode.java            |
| SqlTransRollbackNode          | /src/main/java/.../jdbc/procedure/node/impl/SqlTransRollbackNode.java          |
| SqlTransNoneNode              | /src/main/java/.../jdbc/procedure/node/impl/SqlTransNoneNode.java              |
| SqlTransactionalNode          | /src/main/java/.../jdbc/procedure/node/impl/SqlTransactionalNode.java          |
| SqlRunnerNode                 | /src/main/java/.../jdbc/procedure/node/impl/SqlRunnerNode.java                 |
| SqlScopeNode                  | /src/main/java/.../jdbc/procedure/node/impl/SqlScopeNode.java                  |
| SqlCursorNode                 | /src/main/java/.../jdbc/procedure/node/impl/SqlCursorNode.java                 |
| SqlEtlNode                    | /src/main/java/.../jdbc/procedure/node/impl/SqlEtlNode.java                    |
| ProcedureNode                 | /src/main/java/.../jdbc/procedure/node/impl/ProcedureNode.java                 |
| ProcedureCallNode             | /src/main/java/.../jdbc/procedure/node/impl/ProcedureCallNode.java             |
| FunctionCallNode              | /src/main/java/.../jdbc/procedure/node/impl/FunctionCallNode.java              |
| JavaCallNode                  | /src/main/java/.../jdbc/procedure/node/impl/JavaCallNode.java                  |
| ScriptSegmentNode             | /src/main/java/.../jdbc/procedure/node/impl/ScriptSegmentNode.java             |
| ScriptIncludeNode             | /src/main/java/.../jdbc/procedure/node/impl/ScriptIncludeNode.java             |
| ContextLoadPackageNode        | /src/main/java/.../jdbc/procedure/node/impl/ContextLoadPackageNode.java        |
| ContextInvokeMethodClassNode  | /src/main/java/.../jdbc/procedure/node/impl/ContextInvokeMethodClassNode.java  |
| ContextConvertMethodClassNode | /src/main/java/.../jdbc/procedure/node/impl/ContextConvertMethodClassNode.java |
| EventSendNode                 | /src/main/java/.../jdbc/procedure/node/impl/EventSendNode.java                 |
| EventPublishNode              | /src/main/java/.../jdbc/procedure/node/impl/EventPublishNode.java              |

---

## 附录：节点快速索引

### 语言控制节点 (lang-*)

| 节点                | 说明             |
|-------------------|----------------|
| lang-set          | 变量赋值           |
| lang-if           | 条件判断           |
| lang-choose       | 多分支选择          |
| lang-foreach      | 集合迭代           |
| lang-fori         | 计数循环           |
| lang-while        | 条件循环           |
| lang-do-while     | 先执行后判断循环       |
| lang-break        | 跳出循环           |
| lang-continue     | 继续循环           |
| lang-return       | 返回             |
| lang-throw        | 抛出异常           |
| lang-try          | 异常捕获           |
| lang-eval         | OGNL表达式        |
| lang-eval-java    | Java表达式        |
| lang-eval-js      | JavaScript脚本   |
| lang-eval-ts      | TinyScript脚本   |
| lang-eval-groovy  | Groovy脚本       |
| lang-render       | 模板渲染           |
| lang-string       | 字符串定义          |
| lang-invoke       | 方法调用           |
| lang-synchronized | 同步块            |
| lang-retry        | 重试机制           |
| lang-lock         | 分布式锁           |
| lang-async        | 异步执行           |
| lang-async-all    | 并行执行           |
| lang-shell        | Shell命令        |
| lang-sleep        | 线程休眠           |
| lang-file-*       | 文件操作           |
| lang-println      | 打印输出           |
| lang-printf       | 格式化打印          |
| lang-format       | 格式化字符串         |
| lang-format-date  | 日期格式化          |
| lang-string-join  | 字符串拼接          |
| lang-new-params   | 新建参数上下文        |
| lang-ai           | AI对话           |
| lang-listener     | 事件监听           |
| lang-latch        | CountDownLatch |
| lang-thread-pool  | 线程池            |

### SQL操作节点 (sql-*)

| 节点                 | 说明      |
|--------------------|---------|
| sql-query-row      | 查询单行    |
| sql-query-list     | 查询列表    |
| sql-query-object   | 查询单个值   |
| sql-query-columns  | 查询列信息   |
| sql-update         | 更新操作    |
| sql-script         | SQL脚本片段 |
| sql-dialect        | 数据库方言   |
| sql-trans-begin    | 开启事务    |
| sql-trans-commit   | 提交事务    |
| sql-trans-rollback | 回滚事务    |
| sql-trans-none     | 关闭事务    |
| sql-transactional  | 声明式事务   |
| sql-runner         | SQL脚本执行 |
| sql-scope          | 连接范围    |
| sql-cursor         | 游标遍历    |
| sql-etl            | 数据ETL   |

### 其他节点

| 节点                           | 说明       |
|------------------------------|----------|
| log-debug                    | Debug日志  |
| log-info                     | Info日志   |
| log-warn                     | Warn日志   |
| log-error                    | Error日志  |
| debugger                     | 断点调试     |
| procedure                    | 过程定义     |
| procedure-call               | 过程调用     |
| function-call                | 函数调用     |
| java-call                    | Java方法调用 |
| script-segment               | 脚本片段定义   |
| script-include               | 脚本片段引用   |
| event-send                   | 同步发送事件   |
| event-publish                | 异步发布事件   |
| context-load-package         | 加载包前缀    |
| context-invoke-method-class  | 注册调用方法   |
| context-convert-method-class | 注册转换方法   |

---

**文档版本：** 1.0  
**最后更新：** 2026-04-02  
**维护者：** Ice2Faith
