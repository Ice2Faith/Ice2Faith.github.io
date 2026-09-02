# jdbc-procedure 存储过程转换对照指南

## 一、概述

本文档提供 Oracle 存储过程转换为 jdbc-procedure (XProc4J) XML 格式的完整对照指南，基于实际转换案例编写，涵盖常见转换场景和最佳实践。

**文档目的：**

- 提供 SQL 存储过程到 XML 的转换参考
- 展示常见代码模式的转换对照
- 说明转换过程中的关键要点

**适用范围：**

- Oracle 存储过程迁移到 Java 应用
- 理解 jdbc-procedure 框架的转换规则
- 学习 XML存储过程的编写方法

---

## 二、基础结构转换

### 2.1 基础知识或基本要求（必读）

- 变量名/UDF过程名/UDF函数名统一大写，不能既有大写也有小写。
- 原本SQL语句中的 `<` `&` 等符号，在XML 中是需要进行转义处理的。
- 文件名去除 `.xml` 后缀之后，应该要和xml中根节点 `procedure` 的 `id` 属性的属性值一致
- 原本的SQL过程中的注释，也要尽量在大体一致的位置，添加到 xml 文件中，维持注释一致性
- SQL 注释中如果存在特殊的XML符号，也是需要进行转义的。
- 转换之后，需要检查转换之后的内容是否符合XML语法。
- `lang-set` / `lang-eval-ts` 进行变量赋值/变量初始化的取舍，当少量变量时，使用 `lang-set`,较多变量时使用 `lang-eval-ts`
- `lang-eval-ts` 的合并，当几个 `lang-eval-ts` 靠近，且他们之间的语句不影响这几个 `lang-eval-ts` 执行的结果，则可以改变一下这些语句顺序，进行
  `lang-eval-ts` 的合并，如果中间语句会影响，那就不能交换顺序与合并
- 严格区分功能节点
- `eval`/`test` 默认是使用 `OGNL` 表达式的，没有 `${}` 和 `#{}` 这种用法
- `eval-ts`/`eval-tinyscript` 默认是使用 `TinyScript` 脚本的，没有 `#{}` 这种用法
- `render` 是使用 `Velocity` 语法的，没有 `#{}` 这种用法
- `TinyScript` 中，除了在赋值时，等号左边变量名是不需要 `${}` 包裹的之外，其余地方都是需要包裹的
- 原本SQL过程中的 `F_`/`SP_` 开头的函数调用，都是UDF过程调用，都不是系统函数，需要使用TinyScript进行函数调用，或者使用
  `function-call`/`procedure-call` 进行过程调用，推荐在调用参数少的函数调用，使用 TinyScript 函数调用直接转换，参数较多或者是过程调用时使用
  `function-call`/`procedure-call` 进行调用；且原本的调用，如果没有接受返回值，那么 `function-call`/`procedure-call`
  也不需要接受返回值的 `result` 属性。
- 原本的SQL过程中的系统内置函数（例如：`substr`,`to_char` 等非 `F_`/`SP_` 开头的函数），都需要转换为 `TinyScript` 对应的内建函数，并且
  `TinyScript` 内建的函数都是小写的函数名。
- 如果是在函数调用或者过程调用中参数直接传递系统时间的情况，建议直接在函数的调用属性上使用 `date-now`
  修饰符即可，没必要先定义一个变量再传递变量
- 如果在函数调用或者过程调用中参数是一小段代码逻辑，简短的情况下，可以合理使用 `eval-ts`/`eval`/`render`
  等修饰符直接在属性上进行，没必要单独先处理为一个变量再传递变量
- 转换之后的XML过程中的 `function-call`/`procedure-call` 每个属性独立占用一行，且保存参数顺序与原来一致。
- 原本SQL过程中的日期时间格式化串，需要转换为java中对应的格式，例如：yyyy年份是小写的，MM月份是大写的，mi分钟应该转换为mm小写的分钟等
- 针对未识别的没有直接提供转换指导的语法结构，应该原样照搬为一段多行注释，并在注释上方添加 `TODO`
  说明为什么没有转换；函数/过程/系统函数调用等结构都是有指导的。
- 紧邻的 `lang-eval-ts` 标签可以进行合并，以提高运行效率，减少上下文切换
- TinyScript 中的 `substr` 第二个参数是从 0 开始的，Oracle 中是从 1 开始的，因此要减 1
- 在使用 `lang-render`/`lang-string` 的时候，如果原来的语句是一个SQL或者SQL片段，应该添加 `_lang="sql"` 属性，辅助IDE进行语法高亮显示
- 原本SQL过程中，将SQL赋值给变量后立即执行这个变量的语句的情况，可以考虑直接合并为一个 `sql-update`/`sql-query-*` 节点，不用先
  `lang-render`/`lang-string` 再进行 `sql-update`/`sql-query-*` 执行
- 根据原本SQL过程中的语句情况，合理使用 XML标签转换 与 TinyScript 转换，增加可读性和可维护性
- 如果原本的SQL过程中，存在使用了一些系统函数且未在 TinyScript 中的内建函数的情况，依旧当做有内建函数进行转换，但是必须添加
  `TODO` 说明缺少内建函数，需要进行内建函数实现
- 在 `test` 属性中如果需要使用 TinyScript 内建函数，则一定要对 `test` 属性添加 `eval-ts` 修饰符，并且遵从 TinyScript
  语法。如果不使用 eval-ts 修饰符，就是 Ognl 语法，Ognl 中不能使用内建函数，只有java对象自身的方法。
- 原本过程中定义的SQL语句或片段，如果没有严格的前后空格要求，都建议使用 `lang-string`/`lang-render` 转换，配合
  `_lang="sql"` 属性可以在IDE中进行语法高亮，方便阅读

### 2.2 过程定义转换

**原始 SQL (Oracle PL/SQL):**

```sql
CREATE
OR REPLACE PROCEDURE SP_EXAMPLE_PROC(
    IN_PARAM1     IN NUMBER,
    IN_PARAM2     IN VARCHAR2,
    OUT_PARAM1    OUT NUMBER,
    OUT_PARAM2    OUT VARCHAR2
) AS
    -- 变量声明区
    V_LOCAL_VAR1  NUMBER;
    V_LOCAL_VAR2
VARCHAR2(100);
BEGIN
    -- 过程体
NULL;
END;
```

**转换后 XML:**

```xml
<!DOCTYPE procedure SYSTEM "procedure.dtd">
<procedure id="SP_EXAMPLE_PROC"
           IN_PARAM1.int=""
           IN_PARAM2.string=""
           OUT_PARAM1.int.out=""
           OUT_PARAM2.string.out=""
>
    <!-- 局部变量在 lang-eval-ts 中声明，如果变量没有初始值，其实就没有必要定义，因为没定义使用时也是null -->
    <lang-try>
        <lang-body>
            <!-- 业务逻辑 -->
        </lang-body>
        <lang-catch>
            <!-- 异常处理 -->
        </lang-catch>
    </lang-try>
</procedure>
```

**转换要点:**

- 使用 `<!DOCTYPE procedure SYSTEM "procedure.dtd">` 声明 DTD
- 参数通过属性定义：`参数名。类型。修饰符="默认值"`
- `.int`、`.string` 等表示参数类型
- `.out` 表示输出参数
- 使用 `<lang-try>` 包裹异常处理结构

---

### 2.3 函数定义转换

**原始 SQL:**

```sql
CREATE OR REPLACE FUNCTION F_GET_CONST(
    V_CONST_TYPE IN NUMBER
) RETURN VARCHAR2 AS
    V_RESULT VARCHAR2(100);
BEGIN
    -- 函数逻辑
    RETURN V_RESULT;
END;
```

**转换后 XML:**

```xml

<procedure id="F_GET_CONST"
           V_CONST_TYPE.int=""
           return.string=""
>
    <lang-try>
        <lang-body>
            <!-- 函数逻辑 -->
            <lang-return value="V_RESULT"/>
        </lang-body>
        <lang-catch>
            <lang-return value.string=""/>
        </lang-catch>
    </lang-try>
</procedure>
```

**转换要点:**

- 函数使用 `return.类型=""` 定义返回值
- 使用 `<lang-return value="变量"/>` 返回结果
- 支持在 catch 块中返回默认值

---

## 三、变量与赋值转换

### 3.1 变量声明与初始化

**原始 SQL:**

```sql
V_SUM_MONTH VARCHAR2(6);
V_STAT_DATE VARCHAR2(8);
V_FIRST_DATE VARCHAR2(8);
V_CNT NUMBER := 0;
V_FLAG NUMBER := -1;

V_T_PARATION_NAME := 'T' || IN_THREAD_ID;
```

**转换后 XML:**

```xml
<!-- 方式 1: 使用 lang-set 直接赋值 -->
<lang-set result="V_SUM_MONTH" value.null=""/>
<lang-set result="V_CNT" value.int="0"/>

<!-- 方式 2: 使用 lang-eval-ts 批量声明 -->
<lang-eval-ts>
  V_STAT_DATE = null;
  V_FIRST_DATE = null;
  V_FLAG = -1;
</lang-eval-ts>

<!-- 方式 3: 使用 render 渲染赋值 -->
<lang-set result="V_T_PARATION_NAME" value.render="T$!{IN_THREAD_ID}"/>
```

**转换要点:**

- TinyScript 是弱类型语言，无需显式声明类型
- 使用 `.int`、`.string` 等修饰符标注类型
- 支持 OGNL 表达式 `${变量}` 和 Velocity 渲染 `$!{变量}`

---

### 3.2 常量定义转换

**原始 SQL:**

```sql
V_NULL_DATE DATE := TO_DATE('19000101', 'YYYYMMDD');
V_COMM VARCHAR2(100) := 'DB_COMM.';
```

**转换后 XML:**

```xml
<!-- 方式 1: 调用常量函数获取 -->
<lang-eval-ts>
    V_NULL_DATE = to_date('19000101', 'yyyyMMdd');
    V_COMM = 'DB_COMM.';
</lang-eval-ts>
```

**转换要点:**

- 注意内建函数的大小写，特别是日期格式化与解析的时候的pattern的大小写

---

### 3.3 日期计算转换

**原始 SQL:**

```sql
V_SUM_MONTH := TO_CHAR(TO_DATE(STAT_DATE, 'YYYYMMDD'), 'YYYYMM');
V_RUN_DATE :=V_SUM_MONTH || '01';
V_LM_MONTH := TO_CHAR(ADD_MONTHS(TO_DATE(STAT_DATE, 'YYYYMMDD'), -1), 'YYYYMM');
V_LAST_DATE := TO_CHAR(LAST_DAY(TO_DATE(STAT_DATE, 'YYYYMMDD')), 'YYYYMMDD');
V_CUR_MONTH_DAYS := SUBSTR(V_LAST_DATE, 7, 2);
```

**转换后 XML:**

```xml

<lang-eval-ts>
    V_SUM_MONTH= to_char(to_date(${STAT_DATE}, 'yyyyMMdd'), 'yyyyMM');
    V_RUN_DATE=${V_SUM_MONTH} + '01';
    V_LM_MONTH= to_char(add_months(to_date(${STAT_DATE}, 'yyyyMMdd'), -1), 'yyyyMM');
    V_LAST_DATE= to_char(last_day(to_date(${STAT_DATE}, 'yyyyMMdd')), 'yyyyMMdd');
    V_CUR_MONTH_days= substr(${V_LAST_DATE}, 6, 2);
</lang-eval-ts>
```

**转换要点:**

- 内建函数支持：`substr`、`to_char`、`to_date`、`add_months`、`last_day` 等
- 语法与 Oracle PL/SQL 高度相似
- 注意字符串拼接使用 `+` 而非 `||`
- 注意，substr 虽然用法一样，但是第二个参数，oracle从1开始，本框架内部从0开始

---

## 四、流程控制转换

### 4.1 IF 条件判断

**原始 SQL:**

```sql
-- 单分支
IF V_CNT > 0 THEN
    -- 条件成立时执行
    V_FLAG := 1;
END IF;

-- 多分支
IF V_CNT > 0 THEN
    -- 条件成立时执行
    V_FLAG := 1;
ELSIF V_CNT = 0 AND V_FLAG = 1 THEN
    V_FLAG := 2;
ELSE
    V_FLAG := 0;
END IF;
```

**转换后 XML:**

```xml
<!-- 方式 1: 使用 lang-if 处理单分支 -->
<lang-if test="V_CNT > 0">
  <lang-set result="V_FLAG" value.int="1"/>
</lang-if>

        <!-- 使用 lang-choose 处理多分支 -->
<lang-choose>
  <lang-when test="V_CNT > 0">
    <lang-set result="V_FLAG" value.int="1"/>
  </lang-when>
  <lang-when test="V_CNT == 0 and V_FLAG == 1">
    <lang-set result="V_FLAG" value.int="2"/>
  </lang-when>
  <lang-otherwise>
    <lang-set result="V_FLAG" value.int="0"/>
  </lang-otherwise>
</lang-choose>

        <!-- 方式 2: 在 eval-ts 中使用脚本语法 -->
<lang-eval-ts>
  if (${V_CNT} > 0) {
    V_FLAG = 1;
  };
  
  if (${V_CNT} > 0) {
    V_FLAG = 1;
  } else if (${V_CNT} == 0 and ${V_FLAG} == 1) {
    V_FLAG = 2;
  } else {
    V_FLAG = 0;
  };
</lang-eval-ts>
```

**转换要点:**

- 支持三种方式实现条件分支
- 推荐使用 `<lang-choose>` 处理多分支场景 `<lang-if>` 处理单分支场景
- TinyScript 中使用 `&&`、`||`、`!` 作为逻辑运算符 ，但是也可以使用对应的 `and`、`or`、`not` 作为逻辑运算符
- 对于内部语句不复杂的，优先考虑使用 TinyScript 更加简洁
- 如果内部语句复杂的情况，例如包含执行语句等，还是建议使用 xml 标签

---

### 4.2 循环结构转换

#### 4.2.1 FOR 循环

**原始 SQL:**

- 这里注意，oracle中，这样的loop是包括左右边界的

```sql
FOR i IN 1..10 LOOP
    V_SUM := V_SUM + i;
END LOOP;
```

**转换后 XML:**

```xml
<!-- 方式 1: 使用 lang-fori，借助enclose="true"处理包含右边界，默认是左闭右开区间 -->
<lang-fori begin.int="1" end.int="10" item="i" enclose="true">
    <lang-eval-ts>
        V_SUM = ${V_SUM} + ${i};
    </lang-eval-ts>
</lang-fori>

        <!-- 方式 2: 使用 lang-eval-ts 的 for -->
<lang-eval-ts>
  for(i=1;${i} lte 10; i=${i}+1){
    V_SUM=${V_SUM}+${i};
  };
</lang-eval-ts>
```

#### 4.2.2 WHILE 循环

**原始 SQL:**

```sql
WHILE V_CNT < V_MAX LOOP
    V_CNT := V_CNT + 1;
    IF V_CNT > 5 THEN
        CONTINUE;
    END IF;
    V_SUM := V_SUM + V_CNT;
END LOOP;
```

**转换后 XML:**

```xml
<!-- 方式 1: 使用 lang-while -->
<lang-while test="V_CNT &lt; V_MAX">
    <lang-eval-ts>
        V_CNT = ${V_CNT} + 1;
    </lang-eval-ts>

    <lang-if test="V_CNT > 5">
        <lang-continue/>
    </lang-if>

    <lang-eval-ts>
        V_SUM = ${V_SUM} + ${V_CNT};
    </lang-eval-ts>
</lang-while>

<!-- 方式 2: 使用 lang-eval-ts 的 while -->
<lang-eval-ts>
  while( ${V_CNT} lt ${V_MAX}) {
    V_CNT = ${V_CNT} + 1;
    if( ${V_CNT} > 5 ) {
         continue;
    };
    V_SUM = ${V_SUM} + ${V_CNT};
  };
</lang-eval-ts>
```

**转换要点:**

- 支持 `lang-fori`、`lang-foreach`、`lang-while`、`lang-do-while`
- 使用 `<lang-break/>` 跳出循环
- 使用 `<lang-continue/>` 跳过本次迭代

---

### 4.3 游标循环

**原始 SQL:**

```sql
CURSOR cur_table IS
SELECT table_name
FROM user_tables
WHERE table_name LIKE 'TMP%';

OPEN cur_table;
  LOOP
  FETCH cur_table INTO rec_table;
      EXIT WHEN cur_table%NOTFOUND;
      
      -- 处理逻辑
      EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || rec_table.table_name;
  END LOOP;
CLOSE cur_table;
```

**转换后 XML:**

```xml

<sql-cursor item="REC_TABLE">
    <sql-query-list>
        SELECT table_name FROM user_tables WHERE table_name LIKE 'TMP%'
    </sql-query-list>
    <lang-body>
        <sql-update>
            TRUNCATE TABLE $!{REC_TABLE.TABLE_NAME}
        </sql-update>

    </lang-body>
</sql-cursor>
```

**转换要点:**

- 使用 `<sql-cursor>` 替代 Oracle 游标
- `item` 属性指定当前行变量名
- 通过 `变量。列名` 访问列值
- 自动管理游标的打开、遍历和关闭

---

## 五、SQL 操作转换

### 5.1 INSERT 语句

**原始 SQL:**

```sql
V_SQL :='INSERT INTO TMP_USER_01
(user_id, user_name,ope_time)
SELECT T1.user_id,t1.user_name,sysdate
FROM '||V_TAB_NAME||' t1
WHERE t1.level_id = '||V_LEVEL_ID||'
  AND t1.is_valid = 1';
EXECUTE IMMEDIATE V_SQL;
```

**转换后 XML:**

```xml
<!-- 方式1，分两步 -->
<lang-render result="V_SQL" _lang="sql">
    INSERT INTO TMP_USER_01
    (user_id, user_name,ope_time)
    SELECT T1.user_id,t1.user_name,sysdate
    FROM $!{V_TAB_NAME} t1
    WHERE t1.level_id = $!{V_LEVEL_ID}
    AND t1.is_valid = 1
</lang-render>
<sql-update script="V_SQL"/>

<!-- 方式2，（推荐）一步直接就行，原来是一个更新类型的语句(非select)，因此直接使用 sql-update 即可，语句直接在内部渲染 -->
<sql-update>
  INSERT INTO TMP_USER_01
  (user_id, user_name,ope_time)
  SELECT T1.user_id,t1.user_name,sysdate
  FROM $!{V_TAB_NAME} t1
  WHERE t1.level_id = $!{V_LEVEL_ID}
  AND t1.is_valid = 1
</sql-update>

```

**转换要点:**

- 使用 `<lang-render>` 渲染 SQL 模板
- `_lang="sql"` 指定语言类型为 SQL
- 支持动态表名和列名：`$!{表变量}`
- 使用 `<sql-update>` 执行 INSERT/UPDATE/DELETE

---

### 5.2 UPDATE 语句

**原始 SQL:**

```sql
UPDATE TMP_USER_01 T1
SET T1.LOAD_STATUS = 1,
    T1.LOAD_MONTH  = V_LOAD_MONTH
WHERE T1.USER_STATUS = V_STATUS;
COMMIT;
```

**转换后 XML:**

```xml

<sql-update>
    UPDATE TMP_USER_01 T1
    SET T1.LOAD_STATUS = 1,
    T1.LOAD_MONTH = #{V_LOAD_MONTH}
    WHERE T1.USER_STATUS = #{V_STATUS}
</sql-update>
<sql-trans-commit/>
```

**转换要点:**

- 使用 `#{变量}` 表示绑定变量（防 SQL 注入）
- 使用 `$!{变量}` 表示直接替换（用于动态 SQL）
- 使用 `<sql-update>` 执行 INSERT/UPDATE/DELETE
- 执行后建议调用 `<sql-trans-commit/>` 提交事务

---

### 5.3 DELETE 语句

**原始 SQL:**

```sql
DELETE
TMP_USER_01
WHERE LOAD_MONTH = V_LOAD_MONTH
  AND USER_STATUS != 0;
```

**转换后 XML:**

```xml

<sql-update>
    DELETE FROM TMP_USER_01
    WHERE LOAD_MONTH = #{V_LOAD_MONTH}
    AND USER_STATUS != 0
</sql-update>
```

**转换要点:**

- 使用 `<sql-update>` 执行 INSERT/UPDATE/DELETE

---

### 5.4 SELECT INTO 查询

**原始 SQL:**

```sql
SELECT COUNT(*)
INTO V_CNT
FROM TMP_USER_01 T1
WHERE T1.LOAD_MONTH = V_LOAD_MONTH;
```

**转换后 XML:**

```xml
<!-- 方式 1: 查询单个值 -->
<sql-query-object result="V_CNT" result-type="long">
    SELECT COUNT(*)
    FROM TMP_USER_01 T1
    WHERE T1.LOAD_MONTH = #{V_LOAD_MONTH}
</sql-query-object>

<!-- 方式 2: 查询单行多列 -->
<sql-query-row result="tmpRowMap">
  SELECT COUNT(*) as CNT
  FROM TMP_USER_01 T1
  WHERE T1.LOAD_MONTH = #{V_LOAD_MONTH}
</sql-query-row>

<!-- 访问查询结果，将结果从行变量 tmpRowMap 中取出来，因此上面 sql-query-row 中列取了别名为 CNT，在这里要用到列名 -->
<lang-set result="V_CNT" value="tmpRowMap.CNT"/>
```

**转换要点:**

- `<sql-query-object>` 查询单个值
- `<sql-query-row>` 查询单行数据
- `<sql-query-list>` 查询多行数据（列表）
- 使用 `result` 指定接收变量
- 使用 `result-type` 指定返回类型
    - 一般只使用在 `<sql-query-object>` 查询单个值中
    - `<sql-query-row>` 查询单行数据 很少使用，除非有ORM需求转换为具体的pojo对象

---

### 5.5 分页查询

**原始 SQL:**

```sql
SELECT *
FROM (SELECT t.*, ROWNUM rn
      FROM (SELECT *
            FROM sys_dict
            ORDER BY dict_id) t
      WHERE ROWNUM <= 100)
WHERE rn > 0;
```

**转换后 XML:**

```xml

<sql-query-page result="pageResult"
                page.int="0"
                size.int="100"
                count-sql="false">
    SELECT *
    FROM sys_dict
    ORDER BY dict_id
</sql-query-page>

  <!-- 访问分页结果 -->
<lang-eval-ts>
  totalRows = ${pageResult.total};
  dataList = ${pageResult.data};
</lang-eval-ts>
```

**转换要点:**

- 使用 `<sql-query-page>` 实现分页查询
- 自动处理分页逻辑和总数统计
- 返回包含数据和总数的分页对象

---

## 六、异常处理转换

### 6.1 TRY-CATCH 结构

这里主要看的是一个 begin ... end 代码块中的 exception when 子句。
一般来说，每个过程活成方法体里面，最后的部分都可能有这样的子句。
依次在转换一个过程内部逻辑前，就要先看下过程最后有没有异常处理子句。
如果有，就要使用 `lang-try` 包裹整个过程内容来实现转换。

**原始 SQL:**

```sql
BEGIN
    -- 业务逻辑
    V_SQL := 'INSERT INTO ...';
    EXECUTE IMMEDIATE V_SQL;

EXCEPTION
    WHEN OTHERS THEN
        rollback;
        V_FLAG := -1;
        V_ERROR_MSG := SQLERRM;

END;
```

**转换后 XML:**

```xml

<lang-try> <!-- 对应 begin 这一个代码块 -->
    <lang-body> <!-- 这里面就对象 begin 到 exception 之间的业务逻辑 --> 
        <!-- 业务逻辑 -->
        <lang-render result="V_SQL" _lang="sql">
            INSERT INTO ...
        </lang-render>
        <sql-update script="V_SQL"/>

    </lang-body>
    <lang-catch e="e" ><!-- 对应 exception when 子句 -->
      <!-- 这里面就对象 exception 到 end 之间的业务逻辑 -->
      
      <!-- 回滚事务 -->
        <sql-trans-rollback/>

        <!-- 异常处理 -->
        <lang-set result="V_FLAG" value.int="-1"/>
        <lang-set result="V_ERROR_MSG" value="${e}.getMessage()"/>
        <!-- 或者通过内建变量获取最后异常的信息 -->
        <lang-set result="V_ERROR_MSG" value="trace.errmsg"/>
    </lang-catch>
</lang-try> <!-- 对应 end -->
```

**转换要点:**

- `<lang-try>` 包裹正常业务逻辑
- `<lang-catch>` 处理异常情况
- `e="e"` 捕获异常对象
- 通过 `${trace.errmsg}` 获取错误消息
- 通过 `<sql-trans-rollback/>` 回滚事务

---

### 6.2 自定义异常抛出

**原始 SQL:**

```sql
IF V_FLAG = -1 THEN
    RAISE_APPLICATION_ERROR(-20001, '业务验证失败');
   -- RAISE; -- 或者是使用 raise 直接抛出异常
END IF;
```

**转换后 XML:**

```xml

<lang-if test="V_FLAG == -1">
    <lang-throw type="RuntimeException" value.string="-20001, 业务验证失败"/>
</lang-if>

```

**转换要点:**

- 使用 `<lang-throw>` 抛出异常
- 通过type指定java中的异常类名，value指定异常的message描述
- 异常会被外层 catch 捕获

---

## 七、过程调用转换

### 7.1 调用其他存储过程

- 第一种情况，具名调用，也就是知道形参名称，传递实参的情况

**原始 SQL:**

```sql
SP_RECORD_LOG
(
    I_USER_NAME => V_USER,
    I_PROCESS_NAME => V_CONST_PROCESS_NAME,
    I_EXEC_SQL => SUBSTRB(V_SQL, 1, 4000),
    I_RUN_STATUS => 0,
    I_START_TIME => V_START_TIME,
    I_END_TIME => SYSDATE,
    I_ROW_CNT => V_ROW_COUNT
);
```

**转换后 XML:**

```xml

<!-- 原来的过程，如果没有接受返回值或者出参，则下面的result属性可以不写 -->
<procedure-call refid="SP_RECORD_LOG"
                result="callParams"
                IC_USER_NAME="V_USER"
                IC_PROCESS_NAME="V_CONST_PROCESS_NAME"
                IC_EXEC_SQL.eval-ts="substrb(${V_SQL},0,4000)"
                IC_RUN_STATUS.int="0"
                IC_START_TIME="V_START_TIME"
                IC_END_TIME.date-now=""
                IC_ROW_CNT="V_ROW_COUNT"
/>
```

- 第二种情况，按顺序调用，不知道形参名称的情况

**原始 SQL:**

```sql
SP_RECORD_LOG
(
    V_USER,
    V_CONST_PROCESS_NAME,
    SUBSTRB(V_SQL, 1, 4000),
    0,
    V_START_TIME,
     SYSDATE,
    V_ROW_COUNT
);
```

**直接使用TinyScript 转换**

```xml
<!-- 这是 SP_开头的UDF自定义过程，过程名大写 -->
<lang-eval-ts>
  SP_RECORD_LOG
  (
  ${V_USER},
  ${V_CONST_PROCESS_NAME},
  substrb(${V_SQL}, 1, 4000),
  0,
  ${V_START_TIME},
  sysdate(),
  ${V_ROW_COUNT}
  );
</lang-eval-ts>

```

**具名转换:**

这就需要先在项目中查找有没有目标过程的定义，在原始SQL过程中查找，形参列表。
或者在转换后的XML过程中根据声明，得到形参列表。
然后，依次根据形参名称，一一对应参数进行转换。

```xml

<procedure-call refid="SP_RECORD_LOG"
                result="callParams"
                IC_USER_NAME="V_USER"
                IC_PROCESS_NAME="V_CONST_PROCESS_NAME"
                IC_EXEC_SQL.eval-ts="substrb(${V_SQL},0,4000)"
                IC_RUN_STATUS.int="0"
                IC_START_TIME="V_START_TIME"
                IC_END_TIME.date-now=""
                IC_ROW_CNT="V_ROW_COUNT"
/>
```

**转换要点:**

- 使用 `<procedure-call>` 调用其他过程
- `refid` 指定被调用过程 ID
- 参数直接通过属性传递
- 支持 `.eval-ts`、`.date-now` 等修饰符
- 如果有输出参数需要处理，可以使用 `result` 接受整个对象，再提取输出参数
- 没有需要出参，可以不写 `result`
- 或者直接通过 TinyScript 调用，过程名就是函数名，函数名转为大写，参数顺序保持一致就行

---

### 7.2 调用函数

**原始 SQL:**

```sql
V_RESULT := F_GET_CONST(1);
```

**转换后 XML:**

```xml
<!-- 方式 1: 使用 function-call -->
<function-call refid="F_GET_CONST"
               result="V_RESULT"
               param.int="1"
/>

<!-- 方式 2: 在 eval-ts 中直接调用，这是 F_开头的UDF存储过程的函数，函数名大写 -->
<lang-eval-ts>
V_RESULT = F_GET_CONST(1);
</lang-eval-ts>
```

**转换要点:**

- 使用 `<function-call>` 调用函数
- `result` 接收返回值
- 可在 TinyScript 中像普通函数一样调用

---

### 7.3 共享参数上下文

**原始 SQL:**

```sql
-- 包初始化（只执行一次）
IF PKG_COMPUTE.VG_CITY_USER is null THEN
    PKG_COMPUTE.VG_CITY_USER:='db_user';
END IF;
```

**转换后 XML:**

```xml

<!-- 访问全局变量，通过global寄存全局变量 -->
<lang-eval-ts>
    if (is_empty(${global.VG_CITY_USER})) {
        global.VG_CITY_USER='db_user';
    }
</lang-eval-ts>
```

**转换要点:**

- 包中的全局变量通过 `global.变量名` 访问
- 全局变量贯穿整个调用过程，可实现跨过程共享，后续直接使用

---

## 八、高级特性转换

### 8.1 动态 SQL

**原始 SQL:**

```sql
V_SQL := 'SELECT COUNT(*) FROM ' || V_TABLE_NAME || ' WHERE ORDER_ID = ' || V_ORDER_ID;
IF V_STATUS is not null then 
   V_SQL := V_SQL || ' and STATUS='||V_STATUS;
end if;
EXECUTE IMMEDIATE V_SQL INTO V_CNT;
```

**转换后 XML:**

```xml
<!-- 方式 1: 使用 lang-render 渲染在执行 -->
<lang-render result="V_SQL" _lang="sql">
    SELECT COUNT(1) FROM $!{V_TABLE_NAME} WHERE ORDER_ID = #{V_ORDER_ID}
</lang-render>
<lang-if test="V_STATUS!=null">
  <lang-render result="V_SQL" _lang="sql">
      $!{V_SQL} and STATUS= $!{V_STATUS}
  </lang-render>
</lang-if>
<sql-query-object result="V_CNT" script="V_SQL" result-type="long"/>

<!-- 方式 2: 直接执行，使用动态SQL，使用Mybatis兼容的标签在sql-*标签内部 -->
<sql-query-object result="V_CNT">
  SELECT COUNT(1) FROM $!{V_TABLE_NAME} WHERE ORDER_ID = #{V_ORDER_ID}
  <if test="V_STATUS!=null">
      and STATUS= $!{V_STATUS}
  </if>
</sql-query-object>
```

**转换要点:**

- 使用 `$!{变量}` 动态替换表名、列名
- 使用 `#{变量}` 作为绑定变量传值
- 支持通过 `if`/`where`/`choose`/`set`/... 等Mybatis兼容的标签进行动态SQL创建（需要再sql-*标签内部才行）

---

### 8.2 LRU 缓存使用

**原始 SQL:**

```sql
-- Oracle 无直接对应，通常使用包变量或全局临时表
IF G_CACHE_MAP.EXISTS(V_KEY) THEN
    V_RESULT := G_CACHE_MAP(V_KEY);
ELSE
    V_RESULT := F_CALCULATE(V_KEY);
    G_CACHE_MAP (V_KEY) := V_RESULT;
END IF;
```

**转换后 XML:**

```xml
<!--
框架提供了三种级别的 lru,lru实际上是一个LinkedHashMap为基础构建的
lru 本次执行全过程级别的
executorLru 执行引擎实例级别的，在默认情况下，一个应用只有一个实例
staticLru jvm级别的
这三种，都可以像下面这样使用
-->

<!-- 使用框架提供的 LRU 缓存 -->
<lang-set result="V_RESULT" value.eval="lru.get(V_KEY)"/>

<!-- 计算并放入缓存 -->
<lang-eval-ts>
    cacheValue = F_CALCULATE(${V_KEY});
</lang-eval-ts>

<lang-eval>lru.put(V_KEY, cacheValue)</lang-eval>
<lang-set result="V_RESULT" value="cacheValue"/>

<!-- 也可以在 eval-ts 里面使用 -->
<lang-eval-ts>
    cacheValue=lru.get(${V_KEY});
    cacheValue = F_CALCULATE(${V_KEY});
    lru.put(${V_KEY}, cacheValue)
</lang-eval-ts>

```

**转换要点:**

- 框架提供内置 LRU 缓存（默认 4096 条目）
- 通过 `lru.get(key)` 获取缓存值
- 通过 `lru.put(key, value)` 放入缓存
- 建议在 `<lang-eval>` 节点中操作缓存

---

### 8.3 锁机制

**原始 SQL:**

```sql
-- Oracle 使用 DBMS_LOCK 或 SELECT FOR UPDATE
SELECT GET_LOCK('MY_LOCK', 10)
INTO V_LOCK_RESULT;
-- 执行业务逻辑
SELECT RELEASE_LOCK('MY_LOCK');
```

**转换后 XML:**

```xml
<!-- 使用框架提供的分布式锁 -->
<lang-lock value.string="MY_LOCK"
           type.string="redis">
    <!-- 执行业务逻辑 -->
</lang-lock>

  <!-- 或者使用同步块 -->
<lang-synchronized value="global">
<!-- 执行业务逻辑 -->
</lang-synchronized>
```

**转换要点:**

- `<lang-lock>` 支持 Redis 分布式锁，可以通过 type 指定注册到框架中的其他锁类型
- `<lang-synchronized>` 实现 JVM 级别同步，同步级别为global级别，也可以将value绑定到其他jvm级别的对象上
- 自动管理锁的获取和释放

---

### 8.4 重试机制

**原始 SQL:**

```sql
V_RETRY := 0;
BEGIN
    LOOP
      BEGIN
           -- 可能失败的操作
          INSERT INTO...;
          EXIT;
      EXCEPTION
            WHEN OTHERS THEN
                V_RETRY := V_RETRY + 1;
                IF V_RETRY > 3 THEN
                    RAISE;
                END IF;
              DBMS_LOCK.SLEEP(1);
      END;
    END LOOP;
END;
```

**转换后 XML:**

```xml
<!-- 方式1，使用框架提供的重试机制 -->
<lang-retry times.int="3" interval.int="1000">
    <sql-update>
        INSERT INTO ...
    </sql-update>
</lang-retry>

        <!-- 方式2，或者手动实现 -->
<lang-eval-ts>
  retryCount = 0;
  maxRetry = 3;
  while(${retryCount} lt ${maxRetry}) {
    try {
      // 执行业务逻辑
      break;
    } catch(e) {
      retryCount = retryCount + 1;
      if (${retryCount} >= ${maxRetry}) {
          throw e;
      }
      sleep(1);
    }
  };
</lang-eval-ts>
```

**转换要点:**

- `<lang-retry>` 提供声明式重试
- `times` 指定重试次数
- `interval` 指定重试间隔（毫秒）
- 支持指数退阶等策略

---

## 九、数据类型转换

### 9.1 类型转换函数

**原始 SQL:**

```sql
V_NUM := TO_NUMBER(V_STR);
V_DATE := TO_DATE(V_STR, 'YYYYMMDD');
V_STR := TO_CHAR(V_NUM);
V_STR := TO_CHAR(V_DATE, 'YYYY-MM-DD');
```

**转换后 XML:**

```xml

<!-- 一般用法 -->
<lang-eval-ts>
    // 转数值
    V_NUM = to_number(${V_STR});
    V_INT = to_int(${V_STR});
    V_LONG = to_long(${V_STR});

    // 转日期
    V_DATE = to_date(${V_STR}, 'yyyyMMdd');

    // 转字符串
    V_STR = to_char(${V_NUM});
    V_STR = to_char(${V_DATE}, 'yyyy-MM-dd');

    // 类型转换
    V_NUM = ${V_STR} as Double.class;
</lang-eval-ts>

<!-- 借助属性修饰符 feature 进行转换 -->
<lang-set result="V_NUM" value.visit.double="V_STR"/>
<lang-set result="V_INT" value.visit.int="V_STR"/>
<lang-set result="V_NUM" value.visit.long="V_STR"/>
<lang-set result="V_DATE" value="V_STR" pattern="yyyyMMdd"/>
```

**转换要点:**

- 内建类型转换函数：`to_number`、`to_int`、`to_long`、`to_date`、`to_char`
- 支持 `as` 或 `cast` 进行类型转换

---

### 9.2 空值处理

**原始 SQL:**

```sql
V_RESULT := NVL(V_VALUE, '默认值');
V_RESULT := COALESCE(V_VALUE1, V_VALUE2, V_VALUE3);
IF V_VALUE IS NULL THEN
    V_FLAG := 1;
END IF;
```

**转换后 XML:**

```xml

<lang-eval-ts>
    // NVL 等价
    V_RESULT = nvl(${V_VALUE}, '默认值');
    V_RESULT = ifnull(${V_VALUE}, '默认值');

    // COALESCE 等价
    V_RESULT = coalesce(${V_VALUE1}, ${V_VALUE2}, ${V_VALUE3});

    // 空值判断
    if (isnull(${V_VALUE})) {
         V_FLAG = 1;
    };

    // 空字符串判断
    if (is_empty(${V_VALUE})) {
        // 空字符串、null、空集合都返回 true
    };

    if (is_blank(${V_VALUE})) {
        // 空白字符串（空格、制表符等）
    };
</lang-eval-ts>
```

**转换要点:**

- `isnull()` 判断是否为 null
- `is_empty()` 判断是否为空（包含空字符串、空集合）
- `is_blank()` 判断是否为空白字符串
- `nvl()`、`ifnull()`、`coalesce()` 提供空值替代

---

## 十、字符串操作转换

### 10.1 字符串截取

**原始 SQL:**

```sql
V_SUBSTR := SUBSTR(V_STR, 1, 6);
V_LEFT := LEFT(V_STR, 3);
V_RIGHT := RIGHT(V_STR, 2);
V_LENGTH := LENGTH(V_STR);
```

**转换后 XML:**

```xml

<lang-eval-ts>
    V_SUBSTR = substr(${V_STR}, 0, 6); // 从索引 0 开始，长度 6
    V_LEFT = left(${V_STR}, 3);
    V_RIGHT = right(${V_STR}, 2);
    V_LENGTH = length(${V_STR});

    // 更多字符串函数
    V_TRIM = trim(${V_STR});
    V_UPPER = upper(${V_STR});
    V_LOWER = lower(${V_STR});
    V_REPLACE = replace(${V_STR}, 'old', 'new');
</lang-eval-ts>
```

**转换要点:**

- 字符串函数与 Oracle 高度兼容
- 注意 `substr` 索引从 0 开始（Oracle 从 1 开始）
- 支持管道符调用：`${str}.trim().upper()`

---

### 10.2 字符串连接

**原始 SQL:**

```sql
V_FULL_NAME := V_FIRST_NAME || ' ' || V_LAST_NAME;
V_PATH := V_DIR || '/' || V_FILE;
```

**转换后 XML:**

```xml

<lang-eval-ts>
    // 使用 + 连接
    V_FULL_NAME = ${V_FIRST_NAME} + ' ' + ${V_LAST_NAME};
    V_PATH = ${V_DIR} + '/' + ${V_FILE};

    // 或使用 concat 函数
    V_FULL_NAME = concat(${V_FIRST_NAME}, ' ', ${V_LAST_NAME});

    // 使用渲染语法
    V_PATH = R'${V_DIR}/${V_FILE}';

</lang-eval-ts>

<!-- 使用 render 渲染 -->
<lang-set result="V_FULL_NAME" value.render="$!{V_FIRST_NAME} $!{V_LAST_NAME}"/>
<lang-render result="V_PATH">${V_DIR}/${V_FILE}</lang-render>
```

**转换要点:**

- 使用 `+` 运算符连接字符串
- 使用 `concat()` 函数连接多个字符串
- 使用 `R'...'` `R"..."` 进行占位符渲染
- 使用 `render` 修饰符 模板渲染更复杂的字符串
- 使用 `<lang-render>` 节点 模板渲染更复杂的字符串

---

### 10.3 正则表达式

**原始 SQL:**

```sql
IF REGEXP_LIKE(V_STR, '^[0-9]+$') THEN
    V_FLAG := 1;
END IF;

V_RESULT := REGEXP_REPLACE(V_STR, '[^0-9]', '');
```

**转换后 XML:**

```xml

<lang-eval-ts>
    // 正则匹配
    if (regexp_like(${V_STR}, '^[0-9]+$')) {
        V_FLAG = 1;
    }

    // 正则替换
    V_RESULT = regex_replace(${V_STR}, '[^0-9]', '');

    // 正则提取
    V_MATCHED = regex_find(${V_STR}, '[0-9]+');
</lang-eval-ts>
```

**转换要点:**

- `regexp_like(str, regex)` 判断是否存在部分匹配
- `regex_match(str, regex)` 判断是否完整匹配
- `regex_replace(str, regex, replacement)` 替换
- `regex_find(str, regex)` 提取匹配内容

---

## 十一、调试与日志

### 11.1 日志记录

**原始 SQL:**

```sql
DBMS_OUTPUT.PUT_LINE('调试信息：' || V_VALUE);
```

**转换后 XML:**

```xml

<!-- 方式 1: 使用日志节点 -->
<log-info value.render="调试信息：${V_VALUE}"/>
<log-warn value.render="调试信息：${V_VALUE} 错误信息：${trace.errmsg}"/>
<log-debug value.render="调试信息：${V_VALUE}"/>
<log-error value.render="调试信息：${V_VALUE}"/>

<!-- 方式 2: 打印输出 -->
<lang-println value.render="调试：$!{V_VALUE}"/>

<lang-printf value="V_VALUE"/>
```

**转换要点:**

- 支持不同级别的日志：debug、info、warn、error
- 使用 `${trace.errmsg}` 获取最近错误消息
- 使用 `<lang-println>` 快速调试输出

---

### 11.2 性能监控

**原始 SQL:**

```sql
V_START_TIME := SYSDATE;
-- 业务逻辑
V_END_TIME := SYSDATE;
V_ELAPSED := (V_END_TIME - V_START_TIME) * 86400; -- 秒
```

**转换后 XML:**

```xml

<!-- 业务逻辑 -->
<sql-update script="V_SQL"/>

<!-- 访问跟踪信息 -->
<lang-eval-ts>
  // 获取最近 SQL 执行时间（毫秒）
  sqlTime = ${trace.last_sql_use_time};
  
  // 获取最近 SQL 影响行数
  rowCount = ${trace.last_sql_effect_count};
  
  // 获取当前位置
  location = ${trace.location};
</lang-eval-ts>
```

**转换要点:**

- 框架自动跟踪 SQL 执行时间和影响行数
- 通过 `trace.*` 访问跟踪信息

---

## 十二、最佳实践

### 12.1 代码组织

**推荐做法:**

```xml

<procedure id="SP_BEST_PRACTICE"
           IN_PARAM1.int=""
           IN_PARAM2.string=""
           OUT_CODE.int.out=""
           OUT_MSG.int.out=""
>

    <!-- 2. 变量初始化 -->
    <lang-eval-ts>
        V_PARAM1 = ${IN_PARAM1};
        V_PARAM2 = ${IN_PARAM2};
        V_CONST_PROCESS_NAME = 'SP_BEST_PRACTICE';
    </lang-eval-ts>

    <!-- 3. 主业务逻辑用 try 包裹 -->
    <lang-try>
        <lang-body>
            <!-- 4. 清空临时表 -->
            <sql-update>
                TRUNCATE TABLE TMP_RESULT
            </sql-update>
            <sql-trans-commit/>

            <!-- 5. 执行业务逻辑 -->
            <lang-render result="V_SQL" _lang="sql">
                INSERT INTO TMP_RESULT ...
            </lang-render>
            <sql-update script="V_SQL" result="V_ROW_COUNT"/>

            <!-- 6. 记录日志 -->
            <procedure-call refid="SP_SET_PROCESS_LOG"
                            IN_PROCESS_NAME="V_CONST_PROCESS_NAME"
                            IN_CONTENT="V_SQL"
                            IN_STATUS.int="0"
            />

            <!-- 7. 设置返回值 -->
            <lang-set result="OUT_CODE" value.int="0"/>
            <lang-set result="OUT_MSG" value.render="执行成功"/>

        </lang-body>
        <lang-catch>
            <!-- 8. 异常处理 -->
            <sql-trans-rollback/>

            <lang-set result="OUT_CODE" value.int="-1"/>
            <lang-set result="OUT_MSG" value.render="执行失败：${trace.errmsg}"/>

            <!-- 9. 记录错误日志 -->
            <procedure-call refid="SP_SET_PROCESS_LOG"
                            IN_PROCESS_NAME="V_CONST_PROCESS_NAME"
                            IN_CONTENT="trace.errmsg"
                            IN_STATUS.int="-1"
            />
        </lang-catch>
    </lang-try>
</procedure>
```

**实践要点:**

1. 过程开始先初始化变量
2. 使用 try-catch 包裹主逻辑
3. 重要操作前后记录日志
4. 事务操作后及时提交/回滚
5. 统一返回值和错误信息格式
6. 使用有意义的变量名和注释

---

### 12.2 错误处理

**推荐做法:**

```xml

<lang-try>
    <lang-body>
        <!-- 关键业务操作 -->
        <sql-update script="V_CRITICAL_SQL"/>

    </lang-body>
    <lang-catch e="e">
        <!-- 1. 回滚事务 -->
        <sql-trans-rollback/>

        <!-- 2. 记录详细错误信息 -->
        <lang-eval-ts>
            errorMsg = "处理失败：" + ${trace.errmsg};
            errorCode = -1;
        </lang-eval-ts>

        <!-- 3. 记录错误日志 -->
        <procedure-call refid="SP_SET_PROCESS_LOG"
                        IN_PROCESS_NAME="V_CONST_PROCESS_NAME"
                        IN_CONTENT.body-text.trim.render=""
                        IN_STATUS.int="-1"
        >
            错误位置：${trace.location}
            错误 SQL: ${trace.last_sql}
            堆栈信息：$!{e}
        </procedure-call>

        <!-- 4. 设置返回值 -->
        <lang-set result="OUT_CODE" value.int="-1"/>
        <lang-set result="OUT_MSG" value.render="$!{errorMsg}"/>

        <!-- 5. 可选择抛出或吞下异常 -->
        <!-- <lang-throw cause="e"/> -->
    </lang-catch>
</lang-try>
```

**处理要点:**

1. 异常时首先回滚事务
2. 记录完整的错误上下文
3. 提供清晰的错误消息
4. 统一错误返回格式
5. 根据场景决定是否抛出异常

---

## 十三、转换检查清单

### 13.1 语法转换检查

- [ ] 所有 PL/SQL 变量已转换为 TinyScript 变量
- [ ] 所有 `:=` 赋值已转换为 `=`
- [ ] 所有 `||` 字符串连接已转换为 `+`
- [ ] 所有 `NULL;` 已移除或转换为适当的空操作
- [ ] 所有 `EXIT` 已转换为 `<lang-break/>`
- [ ] 所有 `CONTINUE` 已转换为 `<lang-continue/>`
- [ ] 所有 `RETURN` 已转换为 `<lang-return/>`
- [ ] 所有 `RAISE` 已转换为 `<lang-throw/>`

### 13.2 SQL 语句检查

- [ ] 所有 DML 语句已放入对应的 SQL 节点
- [ ] 所有绑定变量使用 `#{}` 语法
- [ ] 所有动态替换使用 `$!{}` 语法
- [ ] 所有表名、列名大小写已调整
- [ ] 所有 Oracle 特有函数已找到对应内建函数
- [ ] 所有序列操作已转换为框架支持的方式

### 13.3 异常处理检查

- [ ] 所有异常已用 `<lang-try>` 包裹
- [ ] 所有异常处理逻辑已放入 `<lang-catch>`
- [ ] 所有事务回滚已添加 `<sql-trans-rollback/>`
- [ ] 所有错误日志已记录完整上下文

---

## 十四、常见问题

### Q1: Oracle 包 (PACKAGE) 如何转换？

**答:** 使用 `params-share="true"`的过程调用来模拟包的行为:

```xml
<!-- 定义包过程 -->
<procedure id="PKG_COMMON">
    <!-- 借助全局变量，判断包是否已经初始化 -->
    <lang-if test="global.PKG_COMMON_INIT">
        <lang-return/>
    </lang-if>
    <lang-eval-ts>
        // 包变量（全局）
        global.PKG_COMMON_INIT = true;
        global.VG_COMM = 'DB_COMM.';
    </lang-eval-ts>
</procedure>

        <!-- 在其他过程中调用 PKG_COMMON -->
<procedure-call refid="PKG_COMMON" params-share="true"/>

        <!-- 访问包变量 -->
<lang-eval-ts>
V_COMM = ${global.VG_COMM};
</lang-eval-ts>
```

### Q2: 如何处理 Oracle 序列 (SEQUENCE)?

**答:** 使用框架提供的雪花 ID 生成器:

```xml
<!-- 生成唯一 ID -->
<lang-eval-ts>
    SEQ_ID = snowflake_id();
</lang-eval-ts>

        <!-- 或使用 UUID -->
<lang-eval-ts>
UUID_VAL = uuid();
</lang-eval-ts>

        <!-- 或依旧获取序列 -->
<sql-query-object result="V_SEQ_ID" result-type="long">
select SEQ_TEST_ID.nextval from dual
</sql-query-object>
```

### Q3: 如何实现 Oracle 的 BULK COLLECT?

**答:** 使用 `<sql-query-list>` 直接获取列表:

```xml
<!-- 查询列表 -->
<sql-query-list result="dataList" result-type="java.util.Map">
    SELECT * FROM TABLE WHERE ...
</sql-query-list>

        <!-- 遍历结果 -->
<lang-foreach collection="dataList" item="row">
<lang-eval-ts>
    V_VALUE = ${row.COLUMN_NAME};
</lang-eval-ts>
</lang-foreach>
```

---

## 十五、参考资料

### 15.1 框架文档

- [framework.md](framework.md) - 框架总体架构
- [procedure.xml](./procedure.xml) - 节点功能定义
- [procedure.md](./procedure.md) - 转换指导手册
- [TinyScript.md](./TinyScript.md) -
  TinyScript 语法

### 15.2 内建函数

详细的内建函数列表请参考:

- [ContextFunctions.java](/src/main/java/.../jdbc/procedure/context/ContextFunctions.java)
- [TinyScriptFunctions.java](/src/main/java/.../extension/antlr4/script/tiny/impl/context/TinyScriptFunctions.java)

---

## 附录：转换速查表

| Oracle PL/SQL               | jdbc-procedure XML                     | 说明                |
|-----------------------------|----------------------------------------|-------------------|
| `CREATE PROCEDURE`          | `<procedure id="">`                    | 过程定义              |
| `IS/AS`                     | 无对应                                    | 直接开始 `<lang-try>` |
| `变量 类型;`                    | `<lang-eval-ts>变量=值;</lang-eval-ts>`   | 变量声明              |
| `:=`                        | `=`                                    | 赋值运算符             |
| `IF THEN ELSIF ELSE END IF` | `<lang-if>` `<lang-choose>`            | 条件判断              |
| `LOOP EXIT WHEN END LOOP`   | `<lang-while>` `<lang-break/>`         | 循环                |
| `FOR i IN .. LOOP`          | `<lang-fori>`                          | 计数循环              |
| `FOR rec IN cursor LOOP`    | `<sql-cursor>`                         | 游标循环              |
| `OPEN cursor`               | `<sql-cursor>` 自动处理                    | 打开游标              |
| `FETCH cursor INTO`         | `<sql-cursor item="">`                 | 获取数据              |
| `CLOSE cursor`              | `<sql-cursor>` 自动处理                    | 关闭游标              |
| `EXECUTE IMMEDIATE`         | `<sql-update script="">`               | 动态 SQL            |
| `SELECT INTO`               | `<sql-query-object>` `<sql-query-row>` | 查询赋值              |
| `BULK COLLECT`              | `<sql-query-list>`                     | 批量查询              |
| `COMMIT`                    | `<sql-trans-commit/>`                  | 提交事务              |
| `ROLLBACK`                  | `<sql-trans-rollback/>`                | 回滚事务              |
| `SYSDATE`                   | `now()` `sysdate()`                    | 系统时间              |
| `TO_DATE`                   | `to_date()`                            | 转日期               |
| `TO_CHAR`                   | `to_char()`                            | 转字符串              |
| `TO_NUMBER`                 | `to_number()`                          | 转数值               |
| `NVL`                       | `nvl()` `ifnull()`                     | 空值替代              |
| `DECODE`                    | `decode()`                             | 解码函数              |
| `CASE WHEN`                 | `<lang-choose>`                        | 条件分支              |
| `RAISE_APPLICATION_ERROR`   | `<lang-throw>`                         | 抛出异常              |
| `DBMS_OUTPUT.PUT_LINE`      | `<log-info>` `<lang-println>`          | 输出信息              |
| `DBMS_LOCK.SLEEP`           | `sleep(秒)`                             | 线程睡眠              |
| `SEQ.NEXTVAL`               | `snowflake_id()`                       | 生成唯一 ID           |

---

**文档版本：** 1.0  
**最后更新：** 2026-04-02  
**维护者：** Ice2Faith
