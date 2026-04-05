# jdbc-procedure 语法转换对照入门

- jdbc-procedure (也称 XProc4J, Xml Procedure for Java) 是为了进行去数据库过程而实现的Java框架
- 目的是为了取代数据库过程的依赖性，将过程转换为Java代码实现
- 但是由于Java代码繁荣的语法和对代码中字符串字面值的处理不友好等特点
- 因此采用XML为主体，参考Mybatis的XML标签写法，构建以XML+JDBC+脚本引擎+模板引擎为基础技术支持的存储过程方案
- 用来替换数据库中的一切过程体，包括存储过程（procedure）和函数(function)
- 因此理想情况下，是可以做到不再需要数据库端的存储过程和函数了
- 但是，有些SQL语句中可能会使用到函数的情况，这也可以保留一部分函数在数据库中，不进行转换
- 同时，为了进行多数据库类型的支持，也支持了dialect方言性质，用来为不同的数据库写不同的代码语句
- 运行时根据数据库连接选择不同的dialect方言的语句进行执行
- 另外，由于实际处理中，还存在从不同的数据源之间进行交叉操作的情况，因此也可以使用datasource指定数据源进行执行语句
- 因此，在同一个过程中，是允许不同的数据源之间进行操作的，比如ETL操作

## 一、重要概念

- 将每个存储过程视为一个XML文件
- 按照XML格式的顺序进行执行语句
- 每个XML执行时，运行在一个Map对象的上下文中
- 这个对象包含了，变量的读取，全局变量，JDBC连接等信息
- 默认情况下，每个数据源在过程中，都是用同一个Connection连接
- 即使在发生过程内部调用其他过程时，也是同一个连接
- 除非显式指定了使用新的连接

## 二、技术实现

- 技术上，以解析XML文件为主，为了保持XML文件中的属性顺序和报错日志定位，内部使用SAX解析
- 参考Mybatis(成熟的ORM框架)的XML语法特点，进行顺序化的语句调用的XML定义过程
- 因为Mybatis使用OGNL(对象图导航语言)作为默认的表达式引擎，应用在取值和test属性上等地方
- 因此，为了给使用Mybatis熟练的人员使用，此类表达式默认情况下也采用OGNL(visit/test)
- 虽然，大部分语法和Mybatis相同，但是使用上略有一些差异
- 主要的差异在于，底层并不是基于Mybatis构建的，而是直接基于JDBC实现，没有用Mybatis的依赖库
- 其次引入JavaScript，Groovy，TinyScript,Java等语言，作为脚本引擎(eval)，用来处理一些XML标签不方便处理的内容
- 其中，TinyScript是为了解决JAVA语法冗繁的书写规则、从上下文中读写值麻烦、嵌套函数调用等问题，专门设计的可拓展语言
- 设计的初衷就是为了解决转换存储过程时的困难度和简易度
- 由于存储过程中，存在大量的字符串拼接等的处理场景
- 因此引入Velocity(模板引擎)来进行字符串的拼接和渲染(render)操作
- 上面这一段描述中，提到了几个关键词eval,visit,test,render
- 这是比较核心的几个内容
- eval: 表示进行表达式或者脚本执行，主要是用于复杂表达式的执行，实际可以使用Java(eval-java),JavaScript(eval-js),Groovy(
  eval-groovy),TinyScript(eval-ts)
- visit: 表示从Map上下文中访问值,实现上优先使用反射获取值，其次使用OGNL表达式获取值
- test: 表示计算表达式的布尔逻辑值，当表达式的结果不是boolean类型时，会隐式转换为boolean类型，默认使用OGNL引擎进行表达式运算
- render: 表示进行字符串渲染，使用Velocity模板引擎实现

## 三、快速入门

- 你可以通过查看 procedure.xml 中的注释
- 获取节点定义以及功能的详细描述

```shell
./procedure.xml
```

### 3.1 Ognl 对象图表达式语言快速入门

- 在本框架中，Ognl 被用作 if 等条件分的 test 属性判断，以及在SQL中用作取值使用
- 如果你使用过 Mybatis/Mybatis-Plus 这个 ORM 框架，那么你就已经学会了 OGNL 语言的基础使用
- 已经足够在本框架中使用了，可以忽略此处的介绍和入门讲解
- 下面，我们开始讲解 OGNL 在本框架中最常见的使用方式
- OGNL 对象图表达式语言，主要是针对一个单一表达式构建的语言
- 可以调用JAVA中的实例方法
- 详细介绍可以到官网查看

```shell
https://commons.apache.org/dormant/commons-ognl/language-guide.html
```

#### 3.1.1 if/when 分支判断中用作条件判断语句

- 一个场景就是使用在 test 属性中

```xml

<lang-if test="V_NUM>0">

</lang-if>
```

- 在这里例子中，下面的这个不分就是 OGNL 表达式驱动的

```shell
V_NUM>0
```

- 其含义是，使用环境中的 V_NUM 变量与 0 进行比较
- 因为在本框架中，这是最多使用的场景，因此就以案例进行说明
- 多条件使用 and/or 进行连接，也支持使用括号定义优先级

```xml

<lang-if test="(V_NUM!=null and V_NUM>0) or V_NAME!=null">

</lang-if>
```

- 如果是与字符串进行比较，则需要使用双引号，则XML属性就使用单引号

```xml

<lang-if test='V_NAME=="admin"'>

</lang-if>
```

- 如果是与空字符串比较，则可以使用单引号

```xml

<lang-if test="V_NAME!=null and V_NAME!=''">

</lang-if>
```

- 因为 OGNL 是基于 JAVA 的，所以可以调用变量的方法

```xml

<lang-if test="V_NAME!=null and V_NAME.length()>0">

</lang-if>
```

- 有了上面的基础知识之后，下面直接使用对照案例的方式来描述SQL与OGNL表达式的对比
- 同时，因为 TinyScript 是为了进行数据库转换提供的脚本语言，因此也先在这里进行一些对比

```shell
// OGNL 的变量名直接书写即可
// TinyScript 的变量引用需要使用 ${} 进行包裹
SQL: V_NAME is null
OGNL: V_NAME==null
TinyScript: ${V_NAME}==null
TinyScript: isnull(${V_NAME})

SQL: V_NAME is not null
OGNL: V_NAME !=null
TinyScript: ${V_NAME} !=null
TinyScript: !isnull(${V_NAME})

// 注意，SQL中，一般情况下，任何null参与的逻辑表达式结果都为null，而null逻辑含义为false
// 所以，转换之后，就需要考虑判空的逻辑，否则可能导致逻辑不一致
SQL: V_NAME >= 0
OGNL: V_NAME!=null and V_NAME >= 0
TinyScript: ${V_NAME}!=null and ${V_NAME} >= 0

SQL: V_NAME like '%abc%'
OGNL: V_NAME !=null and V_NAME.contains("abc")
TinyScript: like(${V_NAME},'abc')

// TinyScript 的 like 函数虽然支持空参数判断
// 但是如果直接使用取反，却会导致和原来的逻辑不一致
// 如果 V_NAME 为 null , 那么按照原来的逻辑，表达式null与其他值进行逻辑运算，逻辑结果为false
// 所以，转换之后，都需要进行判空
SQL: V_NAME not like '%abc%'
OGNL: V_NAME !=null and !V_NAME.contains("abc")
TinyScript: ${V_NAME}!=null and !like(${V_NAME},'abc')

SQL: V_NAME like 'abc%'
OGNL: V_NAME !=null and V_NAME.startsWith("abc")
TinyScript: starts_with(${V_NAME},'abc')

SQL: V_NAME like '%abc'
OGNL: V_NAME !=null and V_NAME.endsWith("abc")
TinyScript: ends_with(${V_NAME},'abc')

// 在 ONGL 中，in 的多值使用 {} 花括号表示
// 而在 TinyScript 中，in 的多值使用 [] 中括号表示
SQL: V_ID in (1,2,3)
OGNL: V_ID in {1,2,3}
TinyScript: ${V_ID} in [1,2,3]

// TinyScript 提供的 notin 是合并在一起的，不是分开的
SQL: V_ID not in ('1','2','3')
OGNL: V_ID not in {"1","2","3"}
SQL: ${V_ID} notin ['1','2','3']
```

#### 3.1.2 sql语句中用作占位符

- 和 Mybatis 框架中的用法一样
- ${} 用作替换字符串，#{} 用作替换为占位符变量

```xml

<sql-update>
  select * from ${V_TABLE} where ${V_COLUMN}=#{V_VALUE}
</sql-update>
```

- 在这个例子中，就已经表示了在sql中使用的两种方式
- 那么，这条语句实际在驱动中执行的时候
- 将会变成这样

```sql
select *
from sys_user
where status = ?
```

- 这里就说明了使用 ${} 包裹和使用 #{} 包裹的区别
- ${} 是直接将变量替换为字符串
- #{} 是将变量作为变量占位符进行预编译
- 因此，为了避免可能存在的SQL注入
- 请尽量使用 #{} 而不是 ${} 进行变量占位符
- 除非 ${} 是可信的
- 同时，为了与 Velocity 中的写法统一
- 也支持 $!{} 和 #!{} 这样的变种
- 但是，这样写没有其他任何含义和区别

### 3.2 Velocity 模版引擎快速入门

- 在本框架中，Velocity 被用作字符串的渲染，使用在字符串拼接，占位符替换等场景中
- 如果你使用过 Velocity 引擎，那么可以跳过此部分的介绍和入门讲解
- 详细介绍可以到官网查看

```shell
https://velocity.apache.org/engine/devel/user-guide.html
```

#### 3.2.1 作为模板字符串的占位符

- 这是在本框架中最常使用的方式，一般都是只用来替换变量占位符
- 一般很少会使用其它的动态渲染的功能
- 因此，此处也只介绍这部分
- ${} 用来替换变量，如果变量不存在，则原样显示 ${} 占位符
- $!{} 用来替换变量，如果变量不存在，则显示未空字符串
- 下面直接看例子

```xml

<lang-render result="V_SQL" _lang="sql">
  from ${V_TABLE}$!{V_SUFFIX} where status=1
</lang-render>
```

- 渲染的结果为

```shell
from sys_user_his where status=1
```

- 这里，我们假设 V_SUFFIX=_his,V_TABLE=sys_user
- 因此，渲染的结果，就是粘合在一起的

- 如果为null的情况下，则渲染结果如下

```shell
from ${V_TABLE} where status=1
```

- 也就是说您，V_TABLE为空，又没有使用 $!{} 包裹，因此此处原样保留

### 3.3 TinyScript 脚本引擎

- 此脚本引擎是专门为了解决转换过程中XML繁琐，以及其他脚本语言调用函数繁琐的问题而专门设计的
- 目的是为了尽量贴近原始存储过程的变成体验
- 主要是函数式环境
- 更多详情，请查看 TinyScript.md
- 此部分作为快速入门，只会介绍一些简单的部分
- ${} 表示引用变量
- $!{} 表示引用变量，如果变量为null,则返回空字符串
- 语句之间使用;分号分隔，特别注意if等语句块的括号后面的分号不要丢掉

```xml

<lang-eval-ts>
  V_NUM=0;
  V_CNT=${V_NUM}+1;
  V_MSG='123'+$!{V_NAME};
</lang-eval-ts>
```

- 在这个例子中，两种引用变量都包括了
- 运行这段脚本之后，将会得到以下的几个变量

```shell
V_NUM: 0
V_CNT: 1
V_MSG: "123"
```

- 因为，这里 V_NAME 没有值，默认是 null
- 所以，使用了 $!{} 将 null 替换为空字符串
- 如果是使用 ${}, 则得到的是

```shell
V_MSG: "123null"
```

## 四、转换注意事项

### 4.1 变量名大小写统一

- 由于大部分数据库对于变量时忽略大小写的
- 但是在Java环境中，变量是区分大小写的
- 因此，转换时应该根据自身数据库是否忽略大小写
- 决定对变量如何处理
- 比如，在Oracle中，不区分大小写，但是Oracle都喜欢使用大写来命名
- 因此，可以考虑将所有变量名都大写进行处理

### 4.2 SQL拼接过程中null值处理

- 在一些常见的数据库中，将变量拼接到字符串中时
- 如果变量的值为null,拼接的结果将会把null视为''空字符串
- 因此，在进行字符串拼接是需要注意，如果拼接的目标是SQL语句的一部分
- 需要考虑原始数据库对null的处理结果
- 下面以Oracle为例
- 在Oracle中，这样的语句的结果就是空字符串

```sql
select null || 'abc'
from dual
-- 结果为 'abc'
select concat(null, 'abc')
from dual
-- 结果为 'abc'
```

- 但是在MySQL中，结果可能就不一样

```sql
select concat(null, 'abc')
from dual
-- 结果为 null
```

- 因此，你需要根据自己的目标数据库的实际执行结果
- 结合原来的数据库特性，进行相应的调整
- 比如，如果目标数据库时Oracle
- 则在使用render/sql语句中使用${}占位符时
- 请使用$!{}代替
- 这个!语法是velocity模板引擎提供的一种语法
- 含义为，如果目标值为null,则渲染的结果为''空字符串
- 同时，为了书写的体验与统一，在兼容mybatis的xml语句段中
- 依旧允许使用$!{}语法，#!{}语法也是，含义和velocity中的一致
- 使用案例

```xml

<lang-render result="v_sql">
    select * from $!{tableName}
</lang-render>

<lang-set result="v_str" value.render="from $!{tableName} a"/>

<sql-query-row result="v_user">
select *
from ${tableName} a
<where>
    id=#{id}
</where>
</sql-query-row>
```

- 在案例中，lang-render使用的是velocity引擎进行模板渲染
- lang-set中因为使用了render修饰符，因此也是使用velocity引擎进行模板渲染
- 而在sql-query-row中则使用的是兼容mybatis-xml的语法
- 这两者，都支持了$!{}写法
- 虽然，兼容mybatis-xml中也支持使用#!{}语法，但是需要你确认确实需要这样干
- 一般情况下，我认为是不需要这么干的

### 4.3 SQL中的NULL运算

- 在大多数数据库中，有一条原则
- NULL与任意值的运算结果都是NULL
- 如果这个运算使用在条件中，则条件永远为false不成立
- 因此，在进行转换的过程中，遇到使用变量进行条件判定的时候
- 就需要考虑变量是否可能为NULL的情况
- 如果为NULL就需要先进行判空
- 先举个例子说明一下

```sql
IF V_FLAG!=0 then
   V_COUNT:=1;
END IF;
```

- 在这个例子中，V_FLAG是一个变量
- 则就存在可能空值的情况
- 那么，如果值为NULL，则始终为false不成立
- 那么，转换之后也要保证逻辑一致
- 因此，就需要先判空，这样转换

```xml
<lang-if test="V_FLAG!=null and V_FLAG!=0">
  <lang-set result="V_COUNT" value.int="1"/>
</lang-if>
```

- 怎么验证原来的逻辑？
- 可以通过下面的语句进行验证

```sql
select 
    case when 条件表达式 then 'true'
    else 'false'
    end as v_ok
from dual
```

- 因此，总结一下，遇到条件判定时，一定要考虑变量为空的情况
- 要保证与原来的执行逻辑一致
- 常见的一定要判空的场景包括以下表达式

```shell
变量 != 常量
常量 != 变量
变量 &lt; 常量
常量 > 变量
变量 &lt;= 常量
常量 >= 变量
变量 like 常量
变量 not like 常量
变量 in 常量
变量 not in 常量
```

- 另外小心NULL的陷阱
- 比如，在使用not like的时候
- 举例说明
- 原来的语句

```sql
IF V_NAME not like '%A10%' THEN
```

- 如果，你直接使用like函数进行取反 !like(V_NAME,'A10')
- 那么结果就和原来的逻辑不一样了
- 这里，如果V_NAME为NULL
- 则，始终不成立
- 因此，就需要判空，这样才对

```xml
<lang-if test.eval-ts="${V_NAME}!=null and !like(${V_NAME},'A10')">
  
</lang-if>
```

- 特别注意，在Oracle数据库中
- 空字符串''等价于NULL
- 也就是说，遇到这种情况判空的时候
- 就需要进行is_empty判空
- 而不单单是进行==null的判断


## 五、转换对照介绍

- 下面以Oracle语法的存储过程转换对照进行说明
- 其他SQL语言的可以进行参考转换

### 5.1 前置知识

- 可以使用哪些XML节点，节点应该怎么使用?
- 查看procedure.xml中的节点注释描述

### 5.2 修饰符 feature

- 为了在XML中进行数据类型标注或者转换工作
- 因此引入属性修饰符来进行控制
- 属性修饰符实际上是一个Function转换，即对给定的参数进行一些列转换之后得到另一个值
- 也就是说，对应了这样的函数定义

```shell
Object feature(Object obj);
```

- 这些修饰符，提供了不同的能力
- 比如，提供数据类型装换的

```shell
.int 整型
.double 浮点型
.float 短浮点型
.string 字符串
.long 长整型
.short 短整型
.char 字符型
.byte 字节型
.boolean 布尔型
```

- 更多属性修饰符，可以查看 procedure.xml 中的描述

- 比如，要定义一个值

```xml

<lang-set result="v_int" value.int="1"/>
<lang-set result="v_str" value.string="abc"/>
<lang-set result="v_ok" value.boolean="true"/>
```

- 就比如上述的例子中，因为lang-set的语法定义中，对于value值的访问策略默认是visit进行访问
- 也就是将value属性的值视作变量名
- 因此，如果这样写，就是访问名为abc的变量，而不是将字符串"abc"进行赋值

```xml

<lang-set result="v_str" value="abc"/>
```

- 因此，就需要和你的使用修饰符进行设置对应的值
- 同时，修饰符是支持顺序连接的
- 直接来看例子

```xml

<lang-set result="v_ok" value.visit.string.null.is-null="v_obj"/>
```

- 这个例子就属于是复杂的应用了
- 下面，就对这个进行解析
- 直接来看伪代码

```shell
tmp=visit(v_obj); // 访问v_obj对象
tmp=string(tmp); // 然后转换为string类型
tmp=null; // 然后转换为null类型，到这里，值就直接变成了null
tmp=isNull(tmp); // 然后判断是否为空
```

- 通过这个解析，就可以得到结果v_ok的值为true
- 但是，如果这样写

```xml

<lang-set result="v_ok" value.string.null.is-null="v_obj"/>
```

- 那么等价的伪代码就变了

```shell
tmp="v_obj"; // 看做字符串字面值
tmp=null; // 然后转换为null类型，到这里，值就直接变成了null
tmp=isNull(tmp); // 然后判断是否为空
```

- 看出区别了吧，因为第一个修饰符是string，直接将属性值看做字符串
- 而不是默认的visit，这就改变了默认的节点行为
- 如果要保留原来的默认行为，就需要像之前写的一样，先使用visit进行访问对象
- 到这里，就已经说明了feature属性修饰符的用法和作用
- 当然，要注意例如null这种修饰符，会丢弃之前的值，直接进行赋值
- 不过，需要注意的是
- 修饰符，按照顺序进行解析执行，如果遇到不支持的修饰符，也就是未定义的修饰符
- 将会跳过，继续执行，因此需要注意拼写
- 同时，这也为你提供了自定义一些标记的能力
- 因为这些标记会被跳过不会被执行
- 所以，常用的标记可以是：in,out,inout等用来表示形参是入参还是出参
- 最后，每个节点属性对于修饰符的默认性质是不一样的，需要根据节点定义的描述来决定
- 更多的修饰符，参见：procedure.xml中对【属性修饰符】的说明

### 5.3 存储过程定义

- 本框架的目的就是进行过程的转换操作
- 因此这也是必要的一部分
- 先看下原来的定义

```sql
PROCEDURE SP_PREDICATE_COND ( 
IN_CITY_CODE NUMBER, 
IN_SUM_MONTH NUMBER, 
IN_COND_ID NUMBER, 
O_MSG OUT VARCHAR2, 
O_CODE OUT NUMBER 
)
```

- 再看一下转换后的定义
- 转换方式1
- 使用XML进行转换，这也是本框架核心的部分
- 编写一个文件
- 下面是文件名和文件路径
- 文件路径是默认的扫描路径
- 文件名则推荐和要转换的过程名称一致

```shell
resources/procedure/SP_PREDICATE_COND.xml
```

- 下面就是定义的文件内容部分
- 注意几个点
- 根节点名为procedure，使用id属性指定过程的名称
- 这个id需要在项目中是唯一的，因为在发生调用时，使用的就是这个id
- 另外，为了方便他人调用时明确的直到过程需要使用哪些参数
- 以及参数的类型要求，则使用其他属性指定形参名称，使用.来标注类型
- 特别的，建议使用.out来标注出参，这样调用方才能知道有哪些是出参
- 当然，也可以使用.in来标注为入参，但是一般不用，默认认为都是入参
- 因此，调用方需要指定这些属性名的参数进行调用
- 同时，调用完毕之后，可以取到标有.out名称属性的输出参数
- 这是一个约定

```xml

<procedure id="SP_PREDICATE_COND"
           IN_CITY_CODE.int=""
           IN_SUM_MONTH.int=""
           IN_COND_ID.int=""
           O_MSG.string.out=""
           O_CODE.int.out="">

</procedure>
```

- 另外，某些情况下，转换更适合使用Java代码来编写
- 使用XML来编写反而更加麻烦
- 这种情况下，也可以选择使用java-bean的方式来进行转换
- 下面是转换的内容
- 使用@Component注册为一个spring-bean对象
- 使用@JdbcProcedure注解指定过程名称value,使用arguments指定需要的参数及其类型
- 写法和XML类似
- 但是，因为是存储过程，因此一般返回值都为 executor.nop();
- 如果不是 return executor.nop(); 将会认为这个返回值是有效的返回值，即使是 return null;
- 也会认为null值是有效值，在框架中会被视作函数的返回值
- 框架将会将入参params作为结果返回给调用者
- 同时，由于是java类，返回值也会被设置到结果的params的return键上
- 这一点和函数的转换上，是一个区别点，需要注意
- 可以使用executor.call调用，得到返回的结果params
- 实际上返回的就是入参的params对象
-

```java

@Component
@JdbcProcedure(
        value = "SP_PREDICATE_COND",
        arguments = {
                "IN_CITY_CODE.int",
                "IN_SUM_MONTH.int",
                "IN_COND_ID.int",
                "O_MSG.string.out",
                "O_CODE.int.out
        }
)
public class SpPredicateCondJavaCaller implements JdbcProcedureJavaCaller {
    @Override
    public Object exec(JdbcProcedureExecutor executor, Map<String, Object> params) throws Throwable {
        String inCityCode = executor.visitAs("IN_CITY_CODE", params);

        return executor.nop();
    }
}
```

### 5.4 函数定义

- 函数其实上，在本框架中，是一个特例
- 本质上也看做一种过程，只不过有一些特点
- 先来看一下原来的定义

```sql
FUNCTION F_IS_TEST(IN_CITY_CODE      NUMBER,
                    IN_SUM_MONTH      NUMBER,
                    IN_LOG_ID        NUMBER) RETURN NUMBER
```

- 再来看一下转换后的XML定义
- 和存储过程的定义是基本一样的
- 只不过，区别在于返回值的描述
- 这个是固定的约定，约定return名称的属性就是对返回值的描述
- 其他的和存储过程时一致的

```xml

<procedure id="F_IS_TEST"
           IN_CITY_CODE.int=""
           IN_SUM_MONTH.int=""
           IN_LOG_ID.int=""
           return.int="">

</procedure>
```

- 当然，也可以使用java类来实现
- 下面就是java定义
- 需要注意几个点
- 和存储过程基本一致
- 但是，区别点是返回值，会被当做结果params的return属性
- 也就是说，return值是有意义的
- 如果在代码中设置了return属性，也将会被代码的return值覆盖
- 如果代码中已经设置了return属性，不想要被返回值覆盖，则返回语句请使用 executor.nop();
- 表示无返回值，这个需要进行说明，无返回值不表示返回值是null，而是表示void无返回值
- 这点在存储过程的转换也是一样的
- 可以使用executor.invoke进行调用，得到返回值
- 当然，也可以使用executor.call调用得到结果params，然后自行从params中取出return键的值即为return的值

```java

@Component
@JdbcProcedure(
        value = "F_IS_TEST",
        arguments = {
                "IN_CITY_CODE.int",
                "IN_SUM_MONTH.int",
                "IN_LOG_ID.int",
                "return.int"
        }
)
public class FuncIsTestJavaCaller implements JdbcProcedureJavaCaller {
    @Override
    public Object exec(JdbcProcedureExecutor executor, Map<String, Object> params) throws Throwable {
        String inCityCode = executor.visitAs("IN_CITY_CODE", params);

        return 1;
    }
}
```

### 5.5 变量定义

- 在存储过程中通常会在一开头定义要使用到的变量
- 但是，因为转换后使用的是Map保存变量，所以只要变量不需要有初始值
- 也就是变量初始值为null的情况下，可以不定义变量
- 原始语句

```sql
v_begin_time DATE;
V_CITY_CODE VARCHAR2(64) := '101010';
v_num number(10,0) := 12;
```

- 转换方式1
- 直接使用XML标签进行赋值
- 这种方式就要求灵活的使用修饰符feature来确定数据类型

```xml

<lang-set result="V_BEGIN_TIME" value.null=""/>
<lang-set result="V_CITY_CODE" value.string="101010"/>
<lang-set result="V_NUM" value.int="12"/>
```

- 转换方式2
- 使用TinyScript进行转换
- 这种方式 ，对于大批量的变量赋值来说是友好的

```xml

<lang-eval-ts>
    V_BEGIN_TIME=null; // 此句实际上没什么意义
    V_CITY_CODE='101010'; 
    // TinyScript 支持使用单引号和双引号两种模式进行定义字符串，都是可行的，
    // 单引号的字符串类的双引号不用转义，同样双引号内的单引号也是不用转义的
    V_NUM=12;
    // TinyScript默认会返回最后一条语句执行的结果
    // 因此可以不用return语句
</lang-eval-ts>
```

- 转换方式3
- 使用Java进行转换

```xml

<lang-eval-java>
    params.put("V_BEGIN_TIME",null);
    params.put("V_CITY_CODE","101010");
    params.put("V_NUM",12);
    return null;
    // 因为Java脚本实际上会被编译为一个Class运行，这一段会作为函数体
    // 因此需要使用return语句进行返回
</lang-eval-java>
```

- 转换方式4
- 使用groovy进行转换

```xml

<lang-eval-groovy>
    params.V_BEGIN_TIME=null;
    params.V_CITY_CODE="101010";
    params.V_NUM=12;
    // groovy脚本默认会返回最后执行的一条语句的结果，因此可以不用return语句
</lang-eval-groovy>
```

- 转换方式5
- 使用JavaScript进行转换，需要注意的是，JavaScript调用Java也需要像Java一样进行访问

```xml

<lang-eval-javascript>
    params.put('V_BEGIN_TIME',null);
    params.put("V_CITY_CODE",'101010');
    params.put("V_NUM",12);
</lang-eval-javascript>
```

- 当出现大量的赋值语句的时候，我更偏向于使用TinyScript进行转换

### 5.6 变量赋值

- 其实在变量赋值是，转换方式和变量定义差不多
- 这里就少写几种转换方式了

```sql
v_begin_time:=sysdate; -- 当前时间赋值
v_end_time:=v_begin_time; -- 变量赋值
V_CITY_CODE:=IN_CITY_CODE||'00'; -- 这里进行字符串拼接
V_SQL:='select * from '||V_TABLE||' where '||V_WHERE;
```

- 转换方式1
- 直接使用XML标签进行转换

```xml

<lang-set result="V_BEGIN_TIME" value.date-now=""/>
<lang-set result="V_END_TIME" value="V_BEGIN_TIME"/>
<lang-set result="V_CITY_CODE" value.render="${IN_CITY_CODE}00"/>
        <!-- 这里字符串拼接，使用render修饰符进行字符串模板渲染 -->

<lang-set result="V_CITY_CODE" value.render="$!{IN_CITY_CODE}00"/>
        <!-- 如果原来是Oracle的情况，则需要使用$!{}来定义占位符，以处理NULL变量的情况 -->

<lang-render result="V_CITY_CODE">$!{IN_CITY_CODE}00</lang-render>
    <!-- 这里也可以使用 lang-render 来渲染字符串，
    但是原来的内容是前后没有空格的，因此内部就是紧贴着XML标签的
    也就是需要注意，XML标签内部的内容是除了标签的部分都包含的
     -->

<lang-render result.trim="V_CITY_CODE">
  $!{IN_CITY_CODE}00
</lang-render>
        <!-- 这里如果使用 lang-render 来渲染字符串，
        但是内部进行了换行，这样的话，变量实际得到的内容就有前后的换行以及前后的空格
        这时候，就可以借助 trim 修饰符对结果进行 trim ，从而达到相同的目的
         -->

<lang-render result="V_SQL" _lang="sql">
    select * 
   from $!{V_TABLE}
  where $!{V_WHERE}
</lang-render>
    <!-- 
        对于这种拼接SQL的情况，SQL没有要求必须严格的前后空格或者换行的要求
        而且语句相对较长的情况，就可以直接使用 lang-render 进行字符串渲染
        这里多了一个属性 _lang="sql" 这句话其实是给插件用的
        用于辅助插件，指明此块内容的类型其实是一个SQL语句，这样插件就能够为其注入SQL语言的语法高亮和补全能力
    -->
```

- 转换方式2
- 使用TinyScript进行转换

```xml

<lang-eval-ts>
    V_BEGIN_TIME=now(); // 提供了内建的 now() 和 sysdate() 函数
    V_END_TIME=${V_BEGIN_TIME}; // 记住一个技巧，除了声明变量之外（也就是变量名在等号左侧），变量都应该被${}包裹
    // 注意，在进行变量赋值的情况下，如果不涉及字符串拼接，建议不要使用 $!{} , 否则可能改变语义
    V_CITY_CODE=${IN_CITY_CODE}+'00'; // 字符串拼接可以直接使用+号连接，取变量则使用${}包裹
    // V_CITY_CODE=R"${IN_CITY_CODE}00"; // 或者也可以使用模板字符串语法
    V_SQL='select * from '+$!{V_FROM}+' where '+$!{V_WHERE};
   // V_SQL=R'select * from $!{V_FROM} where $!{V_WHERE}';

   V_BEGIN_TIME=sysdate(); // 提供了sysdate()函数和now()函数
   V_CITY_CODE=$!{IN_CITY_CODE}+'00'; // 如果原来是Oracle，则建议使用$!{}进行包裹，以处理NULL变量
    // $!{}是特殊的，含义为，如果变量为 null，则替换为 '' 空字符串，而不是默认的 'null'
   // V_CITY_CODE=R"$!{IN_CITY_CODE}00"; // 或者也可以使用模板字符串语法
</lang-eval-ts>
```

### 5.7 拼接字符串

- 原始语句

```sql
v_sql:=' and t.user_id='||v_user_id||' and t.status='||v_status;
```

- 注意，原始语句中这里是一个条件语句，最前面的and之前需要有空白符
- 防止在之后进行拼接时发生关键字粘连
- 使用.render修饰符

```xml
<lang-set result="V_SQL" value.render=" and t.user_id=$!{V_USER_ID} and t.status=$!{V_STATUS}"/>
```

- 使用.render的好处是可以自己精确控制前后的空格
- 另外这里使用$!{}进行占位符包裹，$!{}表示的是，如果内部的变量为null，则显示的结果为空白字符串''
- 按照原来的语句时Oracle的情况，Oracle如果变量为null，就是显示空白字符
- 这个占位符是velocity模板引擎提供的
- velocity引擎，提供了${}和$!{}占位符
- 区别就在于对null变量的渲染规则上
- ${}如果为null,则保持原样，举例：${v_status},如果为null，则渲染结果为：${v_status}
- $!{}如果为null,则显示空字符，举例：[$!{v_status}],如果为null，则渲染结果为：[]
- 默认情况下，框架的render都是使用velocity进行渲染字符串
- 如果，要求null的时候，结果为'null',就要使用内建函数实现了

```shell
${_vm.str(${v_status})}
```

- 内部内建了一个 _vm 属性对象，用于提供内建的方法，这里 _vm.str 就是一个内建函数
- 使用功能lang-render标签

```xml
<lang-render result.trim.spacing-left="V_SQL" _lang="sql">
  and t.user_id=$!{V_USER_ID} and t.status=$!{V_STATUS}
</lang-render>
```

- 这里使用lang-render渲染，这样的话方便书写和阅读，但是前后的空格处理有些缺陷
- 如果要和原来的保持一模一样，那就需要和上面的修饰符一样，先进行trim，然后使用spacing-left在左侧添加一个空格
- 另外使用_lang属性标注了内部的语法类型，是sql，结合插件就能够准确的实现内部语法高亮
- 但是，对于举例的语句来说，保证前面有空白字符就行，后面有没有空白字符都可以
- 这种情况，直接这样写就行，这样前面自然有一个换行，后面自然也有一个换行，因为XML标签内部内容都是内容

```xml
<lang-render result="V_SQL" _lang="sql">
  and t.user_id=$!{V_USER_ID} and t.status=$!{V_STATUS}
</lang-render>
```

- 当然，手动控制标签格式，也能达到一模一样的情况，比如像下面这样写

```xml
<lang-render result="V_SQL" _lang="sql"> and t.user_id=$!{V_USER_ID} and t.status=$!{V_STATUS}</lang-render>
```

- 使用ts脚本（TinyScript）

```sql
<lang-eval-ts>
    V_SQL=' and t.user_id='+$!{V_USER_ID}+' and t.status='+${V_STATUS};
</lang-eval-ts>
```

- 使用ts脚本的时候，可以直接用+号连接进行拼接即可
- $!{}的语义和velocity一样，都是如果null，则结果为空字符串
- 但是，${}的语义，和Java中时一样的，如果是null，结果就是'null'
- 当然，ts还支持占位符渲染，框架内就是模板字符串，模板字符串规则和velocity一致
- 因为实际上模板字符串就是用velocity实现的替换
- 所以可以这样写

```xml
<lang-eval-ts>
  V_SQL=R" and t.user_id=$!{V_USER_ID} and t.status=$!{V_STATUS}";
</lang-eval-ts>
```

- 使用 R 引导的字符串就是模板字符串
- 多行字符串也可以

```xml
<lang-eval-ts>
  V_SQL=R" and t.user_id=$!{V_USER_ID}
        and t.status=$!{V_STATUS}";
</lang-eval-ts>
```

- 也可以使用专用的多行字符串
- 语法上要求，引导的三个"或者`符号之后必须有一个换行
- 结束的引导符之前也需要有一个换行

```xml
<lang-eval-ts>
  V_SQL=R""" 
    and t.user_id=$!{V_USER_ID}
        and t.status=$!{V_STATUS}
  """;
</lang-eval-ts>
```

- 多行字符串内部也支持几个修饰符 align,trim,render

```xml
<lang-eval-ts>
  V_SQL="""trim.render
    and t.user_id=$!{V_USER_ID}
        and t.status=$!{V_STATUS}
  """;
</lang-eval-ts>
```

### 5.8 单分支条件语句-if

- if语句的情况，在转换时比较复杂
- 因此分作两种情况讨论，第一种是只有一个if分支的
- 也就是本节讨论的内容
- 另一种是多个分支的，也就是if-else的情况
- 现在先来看一下原来的语句

```sql
if V_LINK_OPER = 'OR' and v_cond_type=0 and v_role_key in ('admin','logger') and v_ogran_key like 'sys%' then
   O_MSG:='OK';
end if;
```

- 现在来看下对应的转换方式
- 第一种，使用XML进行转换
- 需要注意，SQL中的等于判定使用一个等号，而XML中的判定使用双等号
- 其次，XML中使用的是OGNL表达式，因此，字符串使用双引号
- in操作符在OGNL中是使用{}花括号表示的
- 针对like这种场景，则使用java的方法进行转换，startsWith,endsWith,contains进行表达
- 在OGNL环境中，当发生字符串与数值类型进行比较的时候，会自动进行隐式类型转换为数值类型进行比较
- 但是，如果明确的知道类型的情况下，还是建议使用同类型进行比较运算

```xml

<lang-if test='V_LINK_OPER == "OR" and v_cond_type==0 and v_role_key in {"admin","logger"} and v_ogran_key.startsWith("sys")'>
    <lang-set result="O_MSG" value.string="OK"/>
</lang-if>

<!-- 
需要注意，NULL值运算在数据库中时非常特殊的，
因为在大多数数据库中，NULL与任意值运算的结果都是NULL
因此，建议对变量进行判空
避免因为NULL值的出现，导致与原来的逻辑不一致
 -->

<lang-if test='(V_LINK_OPER!=null and V_LINK_OPER == "OR") and (v_cond_type!=null and v_cond_type==0) and (v_role_key!=null and v_role_key in {"admin","logger"}) and (v_ogran_key!=null and v_ogran_key.startsWith("sys"))'>
    <lang-set result="O_MSG" value.string="OK"/>
</lang-if>

<!-- 
特别注意，在Oracle中，空字符串''与NULL值是等价的
因此，处理判空的时候，常常也需要判断是否是空字符串''
这种时候，写起来比较复杂
建议使用嵌入ts脚本修饰符进行转换
-->
<lang-if test.eval-ts='(!is_empty(${V_LINK_OPER}) and ${V_LINK_OPER} == "OR") and (!is_empty(${v_cond_type}) and ${v_cond_type}==0) and (!is_empty(${v_role_key}) and ${v_role_key} in ["admin","logger"]) and (!is_empty(${v_ogran_key}) and starts_with(${v_ogran_key},"sys"))'>
    <lang-set result="O_MSG" value.string="OK"/>
</lang-if>
```

- 另外针对这种条件内部处理比较简单的
- 也可以考虑使用TinyScript进行转换
- 需要注意，TinyScript的表达式中，和OGNL中接近，但有区别
- 第一个就是变量引用得使用${}进行包裹
- 第二个就是字符串不区分单双引号，都认为是字符串
- in操作符，是和JSON一样的表达，使用[]中括号进行表示的
- 对于like的处理，和OGNL的表达一样，直接使用java的方法进行表示
- 在TinyScript环境中，当字符串与数值类型进行比较运算的时候，会饮食转换为数值进行比较
- 但是在明确知道类型的情况下，建议使用同类型进行比较
- 具体规则如下，规则从上至下顺序进行优先匹配：
- 当类型相同时，如果是 Comparable 类型的，则直接进行比较
- 当双方均为可转换的Number类型时，按照Number类型进行比较
- 当双方均为可转换Date类型时，按照Date类型进行比较
- 当一方类型为Number 类型时，将另一方尝试转换为Number类型进行比较
- 当一方类型为Boolean类型时，将另一方尝试转换为Boolean类型比较
- 当一方类型为String类型时，将另一方尝试转换为String类型比较
- 当一方为Comparable类型时，按照Comparable进行比较
- 以上规则都不满足，按照对象的hashcode进行比较
- 这个规则使用于普通比较运算符，以及in/notin运算符

```xml

<lang-eval-ts>
    if(${V_LINK_OPER} == 'OR'
    and ${v_cond_type}==0
    and ${v_role_key} in ['admin','logger']
    and ${v_ogran_key}.startsWith("sys")){
        O_MSG='OK';
    };
</lang-eval-ts>

<!-- 
同样，注意数据库中的NULL运算处理判空
-->
<lang-eval-ts>
  if(${V_LINK_OPER} == 'OR' // 可以不用判空，因为NULL时，不可能等于常量字面值
  and ${v_cond_type}==0 // 同上
  and ${v_role_key} in ['admin','logger'] // 同上
  and starts_with(${v_ogran_key},"sys")){ // 改为内建函数，函数内部处理NULL的情况
    O_MSG='OK';
  };
</lang-eval-ts>

<!--
同样，如果是Oracle数据库，因为空字符与NULL等价，因此特别判空
-->
<lang-eval-ts>
  if(!is_empty(${V_LINK_OPER}) and ${V_LINK_OPER} == 'OR' // 必须使用is_empty判空，同时判定NULL和空字符的情况
  and ${v_cond_type}==0 // 这里理论是数值类型，可以考虑不判断
  and !is_empty(${v_role_key}) and ${v_role_key} in ['admin','logger'] // 同上必须判空
  and !is_empty(${v_ogran_key}) and starts_with(${v_ogran_key},"sys")){ // 同上必须判空
    O_MSG='OK';
  };
</lang-eval-ts>
```

### 5.9 多分支条件语句if-else

- 针对多分支语句时，XML中则需要额外的标签来处理
- 但是总体和Mybatis中对多分支的处理一致
- 直接来看例子吧
- 原来的语句如下

```sql
if v_score >= 90 then
   v_grade:='A';
elseif v_score >=80 then
    v_grade:='B';
elseif v_score >= 60 then
    v_grade:='C';
else
    v_grade:='D';
end if;
```

- 先来看使用XML方式转换吧
- 需要注意，因为是在XML中编写
- 因此，需要注意一些符号的转义的问题
- 例如如下符号

```shell
< &amp;lt;
> &amp;gt;
& &amp;amp;
```

- 直接来看转换的XML结果

```xml

<lang-choose>
    <lang-when test="v_score >= 90">
        <lang-set result="v_grade" value.string="A"/>
    </lang-when>
    <lang-when test="v_score >= 80">
        <lang-set result="v_grade" value.string="B"/>
    </lang-when>
    <lang-when test="v_score >= 60">
        <lang-set result="v_grade" value.string="C"/>
    </lang-when>
    <lang-otherwise>
        <lang-set result="v_grade" value.string="D"/>
    </lang-otherwise>
</lang-choose>
```

- 这种情况，其实使用TinyScript就比较合适
- 不用那么繁琐了
- 需要注意的是if语句最后的分号记得加

```xml

<lang-eval-ts>
    if(${v_score} >= 90){
        v_grade='A';
    }else if(${v_score} >= 80){
        v_grade='B';
    }else if(${v_score} >= 60){
        v_grade='C';
    }else{
        v_grade='D';
    };
</lang-eval-ts>
```

- 当然使用其他脚本语言也可以
- 比如使用groovy，JavaScript，java都是可以的

### 5.10 函数调用

- 在存储过程中，很多地方都可能使用了数据库内建的函数，例如rtrim/replace等
- 也会使用自定义的UDF函数
- 转换之后，则有几种选择，一个就是使用Java将自rtrim/replace等内建函数进行实现，好处是不用考虑数据库类型，坏处是有的函数可能不好实现
- 第二种是使用SQL查询实现，这种方式的局限性就是数据库要兼容

```sql
COND.CONTENT:=rtrim(COND.CONTENT,';');
COND.CONTENT:=replace(COND.CONTENT,'1=1','1 = 1 ');
v_f_cnt:=LENGTH(COND.CONTENT) - LENGTH(REPLACE(COND.CONTENT, ';', ''))+1;
```

- 转换方式1
- 使用XML标签进行转换，这种函数的大量大量或者拼接
- 不适合使用XML标签进行描述

```xml

<lang-invoke result="COND.CONTENT" method="rtrim" target="COND.CONTENT" arg0.string=";"/>
<lang-invoke result="COND.CONTENT" method="replace" target="COND.CONTENT" arg0.string="1=1" arg1.string="1 = 1 "/>
<lang-invoke result="tmp_len" method="length" target="COND.CONTENT"/>
<lang-invoke result="tmp_str" method="replace" target="COND.CONTENT" arg0.string=";" arg1.string=""/>
<lang-invoke result="tmp_str_len" method="length" target="tmp_str"/>
<lang-eval result="V_F_CNT">
    tmp_len-tmp_str_len+1
</lang-eval>
```

- 转换方式2
- 使用数据库自己的函数，通过查询的方式进行转换

```xml

<sql-query-object result="COND.CONTENT" result-type="string">
    select rtrim(#{COND.CONTENT},';') as v1 from dual
</sql-query-object>

<sql-query-object result="COND.CONTENT" result-type="string">
    select replace(#{COND.CONTENT},'1=1','1 = 1 ') as v1 from dual
</sql-query-object>

<sql-query-object result="V_F_CNT" result-type="int">
    select LENGTH(#{COND.CONTENT}) - LENGTH(REPLACE(#{COND.CONTENT}, ';', ''))+1 as v1 from dual
</sql-query-object>
```

- 转换方式3
- 使用Java进行转换

```xml

<lang-eval-java>
    String content = executor.visitAs("COND.CONTENT", params);
  content=ContextFunctions.INSTANCE.trim(content);
    content=content.replace("1=1","1 = 1 ");
    executor.visitSet(params,"COND.CONTENT",content);
    int len=content.length()-content.replace(";","").length()+1;
    executor.visitSet(params,"V_F_CNT",len);
    return null;
</lang-eval-java>
```

- 转换方式4
- 使用TinyScript进行转换

```xml

<lang-eval-ts>
    COND.CONTENT=rtrim(${COND.CONTENT},';');
    COND.CONTENT=replace(${COND.CONTENT},'1=1','1 = 1 ');
    V_F_CNT=length(${COND.CONTENT}) - length(replace(${COND.CONTENT}, ';', ''))+1;
</lang-eval-ts>
```

- 在这种场景下，使用XML标签或者使用其他eval脚本语言
- 都比原来的语句复杂的多
- 因为TinyScript设计就是为了解决这个问题的，所以更偏向于使用TinyScript进行转换

### 5.11 UDF自定义函数调用(内部之间调用)

- UDF用户自定义函数常常也会出现在存储过程中
- 现在，这种情况比较复杂，我们以一个例子来说明
- 先看原来函数的定义

```sql
FUNCTION F_IS_TEST(IN_CITY_CODE      NUMBER,
                  IN_SUM_MONTH      NUMBER,
                  IN_LOG_ID        NUMBER) RETURN NUMBER
```

- 那么如果这个函数转换为XML来写应该是这样的
- 虽然定义一个过程，只需要指定ID就行，但是应该写上函数需要的参数，以及参数的类型
- 以及返回值的类型

```xml

<procedure id="F_IS_TEST"
           IN_CITY_CODE.int=""
           IN_SUM_MONTH.int=""
           IN_LOG_ID.int=""
           return.int="">

</procedure>
```

- 那再来看一下原来是怎么调用的

```sql
V_IS_TEST:=F_IS_TEST(101010,V_SUM_MONTH,V_LOG_ID);
```

- 也或者是这样的调用

```sql
v_sql:='select F_IS_TEST('||101010||','||V_SUM_MONTH||','||V_LOG_ID||') from dual';

execute immediate v_sql into V_IS_TASK_TEST;
```

- 那么一下都是可以的转换方式
- 转换方式1
- 使用XML标签进行调用，则属性名就是目标的参数名，属性值就是传递的值
- 即属性名为形参，属性值为实参

```xml

<function-call refid="F_IS_TEST"
               result="V_IS_TEST"
               IN_CITY_CODE.int="101010"
               IN_SUM_MONTH="V_SUM_MONTH"
               IN_LOG_ID="V_LOG_ID"/>
```

- 转换方式2
- 还是使用XML标签，但是使用存储过程的方式，自行提取返回值

```xml

<procedure-call refid="F_IS_TEST"
                result="callParams"
                IN_CITY_CODE.int="101010"
                IN_SUM_MONTH="V_SUM_MONTH"
                IN_LOG_ID="V_LOG_ID"/>
<lang-set result="V_IS_TEST" value="callParams.return"/>
<!-- 如果是使用procedure-call调用函数，那么在result这个Map中的return键存的就是返回值，所以先提取出来，方便后续处理 -->
```

- 转换方式3
- 使用Java代码调用
- 注意，java内部调用，请先使用 executor.newParams(params) 来获得基础的属性，以继承全局变量，连接等信息
- 如果直接使用空的Map对象，则不会继承这些共有的属性，全局变量，连接这些将会被重新分配

```xml

<lang-eval-java>
    int V_SUM_MONTH = executor.visitAs("V_SUM_MONTH", params);
    int IN_LOG_ID = executor.visitAs("IN_LOG_ID", params);

    int ret=executor.invoke("F_IS_TEST", executor.mapBuilder(executor.newParams(params)) // 注意，内部之间调用，需要使用newParams来继承全局变量
      .put("IN_CITY_CODE", 101010)
      .put("IN_SUM_MONTH", V_SUM_MONTH)
      .put("IN_LOG_ID", IN_LOG_ID)
      .get()
    );
    executor.visitSet(params,"V_IS_TEST",ret);
    return null;
    // return executor.nop();
    // 这里，因为xml标签没有使用result属性指定返回值，因此return null的值，也是没有关系的
</lang-eval-java>
```

- 转换方式4
- 和上面一样，但是因为lang-eval-java支持result属性来指定返回值
- 因此，也可以配合使用

```xml

<lang-eval-java result="V_IS_TEST">
    return executor.invoke("F_IS_TEST", executor.mapBuilder(executor.newParams(params)) // 注意，内部之间调用，需要使用newParams来继承全局变量
      .put("IN_CITY_CODE", 101010)
      .put("IN_SUM_MONTH", executor.visit("V_SUM_MONTH", params))
      .put("IN_LOG_ID", executor.visit("IN_LOG_ID", params))
      .get()
    );
</lang-eval-java>
```

- 转换方式5
- 使用TinyScript具名参数调用,这样就不用考虑参数顺序问题，只考虑参数名对应就行

```xml

<lang-eval-ts>
    V_IS_TEST=F_IS_TEST(
      IN_CITY_CODE:101010,
      IN_SUM_MONTH:${V_SUM_MONTH},
      IN_LOG_ID:${V_LOG_ID}
    );
</lang-eval-ts>
```

- 转换方式6
- 使用TinyScript参数顺序调用，这就要求顺序和XML中属性的顺序一致

```xml

<lang-eval-ts>
    V_IS_TEST=F_IS_TEST(101010,${V_SUM_MONTH},${V_LOG_ID});
</lang-eval-ts>
```

- 上面这几种方式中，使用TinyScript是最好最方便快捷的

### 5.12 Proc存储过程调用(内部之间调用)

- 其实函数掉调用时从存储过程的调用简化来的
- 因此，很多部分和存储过程时基本一样的
- 下面来看一下这个存储过程的定义

```sql
PROCEDURE SP_PREDICATE_COND ( 
IN_CITY_CODE NUMBER, 
IN_SUM_MONTH NUMBER, 
IN_COND_ID NUMBER, 
O_MSG OUT VARCHAR2, 
O_CODE OUT NUMBER
)
```

- 再看一下转换后的定义

```xml

<procedure id="SP_PREDICATE_COND"
           IN_CITY_CODE.int=""
           IN_SUM_MONTH.int=""
           IN_COND_ID.int=""
           O_MSG.string.out=""
           O_CODE.int.out="">

</procedure>
```

- 看一下原来怎么调用的

```sql
v_sql := ' begin SP_PREDICATE_COND(:1,:2,:3,:4,:5) ; end ; ';
execute immediate v_sql using in V_CITY_CODE, in V_SUM_MONTH, in V_COND_ID, out V_MSG, out  V_CODE;
```

- 转换方式1
- 使用XML标签进行转换
- 因为O_MSG和O_CODE都是输出变量，因此也可以不写
- 另外使用lang-set将变量提取出来，以和原来过程中的变量相兼容
- 可以避免一些转换过程中变量名的使用错误问题

```xml

<procedure-call refid="SP_PREDICATE_COND"
                result="callParams"
                IN_CITY_CODE="V_CITY_CODE"
                IN_SUM_MONTH="V_SUM_MONTH"
                IN_COND_ID="V_COND_ID"
                O_MSG="V_MSG"
                O_CODE="V_CODE"/>
<lang-set result="V_MSG" value="callParams.O_MSG"/>
<lang-set result="V_CODE" value="callParams.O_CODE"/>
```

- 因为说了输出参数可以不写，因此这样也是可以的

```xml

<procedure-call refid="SP_PREDICATE_COND"
                result="callParams"
                IN_CITY_CODE="V_CITY_CODE"
                IN_SUM_MONTH="V_SUM_MONTH"
                IN_COND_ID="V_COND_ID"/>
```

- 转换方式2
- 使用Java代码转换

```xml

<lang-eval-java>
    Map ret=executor.call("SP_PREDICATE_COND",executor.mapBuilder(executor.newParams(params)) // 注意，内部之间调用，需要使用newParams来继承全局变量
      .put("IN_CITY_CODE",executor.visit("V_CITY_CODE",params))
      .put("IN_SUM_MONTH",executor.visit("V_SUM_MONTH",params))
      .put("IN_COND_ID",executor.visit("V_COND_ID",params))
      .get()
    );
    executor.visitSet(params,"V_MSG",executor.visit("O_MSG",ret));
    executor.visitSet(params,"V_CODE",executor.visit("O_CODE",ret));
    return null;
</lang-eval-java>
```

- 转换方式3
- 使用groovy代码转换

```xml

<lang-eval-groovy>
    def ret=executor.call("SP_PREDICATE_COND",executor.mapBuilder(executor.newParams(params)) // 注意，内部之间调用，需要使用newParams来继承全局变量
      .putAll([
        IN_CITY_CODE:params.V_CITY_CODE,
        IN_SUM_MONTH:params.V_SUM_MONTH,
        IN_COND_ID:params.V_COND_ID
      ])
      .get()
    );
    params.V_MSG=ret.O_MSG;
    params.V_CODE=ret.O_CODE;
</lang-eval-groovy>
```

- 转换方式4
- 使用TinyScript脚本转换

```xml

<lang-eval-ts>
    callParams=SP_PREDICATE_COND(
      IN_CITY_CODE:${V_CITY_CODE},
      IN_SUM_MONTH:${V_SUM_MONTH},
      IN_COND_ID:${V_COND_ID}
    );
    V_MSG=${callParams.O_MSG};
    V_CODE=${callParams.O_CODE};
</lang-eval-ts>
```

### 5.13 Java程序调用XML过程(外部入口调用)

- 这部分，直接使用上面内部调用的例子进行演示
- Java程序调用，也就是在Java程序中调用XML的过程的方式
- 也就是程序如何运行，程序的运行入口
- 在与springboot集成的环境starter中，会自动从springboot环境中获取数据源等相关信息注入到执行环境中
- 这部分是自动装配实现的，因此一般不考虑
- 而是直接进行使用即可
- 调用方式1，使用静态工具类进行调用
- 这种调用方式将是比较常见的，也是常规调用方式
- 内部屏蔽了一些不必要的细节
- 函数调用

```java
int vIsTest = JdbcProcedureHelper.invoke("F_IS_TEST", (map) ->
            map.put("IN_CITY_CODE", 101010)
            .put("IN_SUM_MONTH", 202501)
            .put("IN_LOG_ID", 1)
);
```

- 过程调用

```java
Map<String, Object> ret = JdbcProcedureHelper.call("SP_PREDICATE_COND", (map) ->
        map.put("IN_CITY_CODE", 101010)
          .put("IN_SUM_MONTH", 202501)
          .put("IN_COND_ID", 6666)
          .get()
);
String oMsg = (String) ret.get("O_MSG");
Integer oCode = (Integer) ret.get("O_CODE");
```

- 当然，你也可以选择将executor注入进来
- 然后使用executor进行调用
- 那就和上面的基本一样了
- 注入executor

```java

@Autowired
private JdbcProcedureExecutor executor;
```

- 也或者通过静态方法获取

```java
JdbcProcedureExecutor executor = JdbcProcedureHelper.getExecutor();
```

- 然后和上面一样的调用即可
- 只不过，因为是使用executor，executor提供了一些其他的辅助方法可以使用
- 在某些场景下会比较实用
- 函数调用

```java
int vIsTest = executor.invoke("F_IS_TEST", (map) ->
        map.put("IN_CITY_CODE", 101010)
                .put("IN_SUM_MONTH", 202501)
                .put("IN_LOG_ID", 1)
);
```

- 过程调用

```java
Map<String, Object> ret = executor.call("SP_PREDICATE_COND", (map) ->
        map.put("IN_CITY_CODE", 101010)
                .put("IN_SUM_MONTH", 202501)
                .put("IN_COND_ID", 6666)
);
String oMsg = executor.visitAs(ret, "O_MSG");
Integer oCode = executor.visitAs(ret, "O_CODE");
```

### 5.14 游标转换

- 游标cursor也是一个比较常见的现象
- 现在看一下原来的语句
- 这个语句比较简单，只是一个实例，没有实际的意义

```sql
cur_obj sys_refcursor; -- 声明游标
-- 游标的语句
v_sql :='select a.USER_NAME,a.nick_name from '||V_SCHEMA_PREFIX||'SYS_USER a where a.STATUS='||V_USER_SATUS||' and a.DEL_FLAG='||V_DEL_FLAG;
OPEN cur_obj FOR v_sql; -- 打开游标

LOOP
FETCH cur_obj INTO v_user_name,v_nick_name ; -- 将游标的结果保存到变量中
            EXIT WHEN cur_obj%NOTFOUND; -- 循环游标，直到没有数据为止

            -- 游标执行的操作
update sys_user
set role_id=V_ROLE_ID
where USER_NAME = v_user_name
;

END LOOP;
```

- 针对这种情况，目前提供的转换方式是使用XML
- 这样对于SQL语句的编辑更方便

```xml

<sql-cursor item="tmpRowMap"> <!-- 游标返回的必定是Map对象，指定Map对象存放的键 -->
    <sql-query-list> <!-- 游标指定的语句 -->
        select a.USER_NAME,a.nick_name
        from ${V_SCHEMA_PREFIX}SYS_USER a
        where a.STATUS=#{V_USER_SATUS}
        and a.DEL_FLAG=#{V_DEL_FLAG}
    </sql-query-list>
    <lang-body>
        <!-- 将游标的变量提取出来，后续则可以不用变更变量名 -->
        <lang-set result="v_user_name" value="tmpRowMap.USER_NAME"/>
        <lang-set result="v_nick_name" value="tmpRowMap.NICK_NAME"/>

        <!-- 游标指定的操作 -->
        <sql-update>
            update sys_user
            set role_id=#{V_ROLE_ID}
            where USER_NAME=#{v_user_name}
        </sql-update>
    </lang-body>
</sql-cursor>
```

### 5.15 for循环转换

- 有时候，也会存在for春环变量的使用
- 也就是for...in的语法
- 这种其实本质上可以理解为一种游标
- 因此也可以使用游标的转换方式
- 看一下原来的语句

```sql
FOR c_dict IN (SELECT * FROM SYS_DICT t WHERE DICT_KEY=V_USER_GROUP_KEY   And T.STATUS  =1  )
LOOP

delete
from SYS_USER
where USER_GOUP = c_dict.DICT_VALUE;

END LOOP;
```

- 直接使用XML转换即可

```xml

<sql-cursor item="c_dict"> <!-- 因为语句返回的就是一个对象，所以直接使用原来的名称 -->
    <sql-query-list> <!-- for的语句 -->
        SELECT * FROM SYS_DICT t
        WHERE DICT_KEY=#{V_USER_GROUP_KEY}
        And T.STATUS =1
    </sql-query-list>
    <lang-body>

        <sql-update>
            delete from SYS_USER
            where USER_GOUP=#{c_dict.DICT_VALUE}
        </sql-update>
    </lang-body>
</sql-cursor>
```

### 5.16 for-i型循环

- 这种其实就是for-i语句
- 直接进行转换即可
- 原始语句

```sql
v_size :=0;
for v_i in 2..v_count loop
    v_size:=v_size+v_i;
end loop;
```

- 这种语句，只是为了演示怎么进行转换
- 实际的情况，一般循环内部不会这么简单
- 因此先说，一般的转换方式
- 直接使用XML进行转换
- 使用begin指定初始值，使用end指定结束值，使用incr指定增量/步长

```xml

<lang-set result="v_size" value.int="0"/>
<lang-fori item="v_i" begin.int="2" end="v_count" incr.int="1">
    <lang-set result="v_size" value.eval="v_size+v_i"/>
</lang-fori>
```

- 当然，因为举例非常简单
- 可以使用嵌入脚本的方式
- 下面使用TinyScript来转换

```shell
<lang-eval-ts>
    v_size=0;
    for(v_i=2;${v_i} < ${v_count}; v_i=${v_i}+1){
        v_size=${v_size}+${v_i};
    };
</lang-eval-ts>
```

### 5.17 while型循环

- 这种语句其实也比较常见
- 直接转换即可
- 原始语句

```sql
v_size :=0;
v_i :=0;
while v_i < v_count loop
      v_size:=v_size+v_i;
      v_i =v_i+1;
end loop;
```

- 一般使用XML直接转换

```xml

<lang-set result="v_size" value.int="0"/>
<lang-set result="v_i" value.int="0"/>
<lang-while test="v_i < v_count">
  <lang-set result="v_size" value.eval="v_size+v_i"/>
  <lang-set result="v_i" value.eval="v_i+1"/>
</lang-while>
```

- 当然示例比较简单
- 也可以使用TinyScript直接进行转换

```xml

<lang-eval-ts>
    v_size=0;
    v_i=0;
  while (${v_i} lt ${v_count} ) {
      v_size=${v_size}+${v_i};
      v_i=${v_i}+1;
    };
</lang-eval-ts>
```

### 5.18 SQL语句拼接与执行

- SQL语句拼接是一个比较常见的场景
- 下面将介绍进行语句拼接，并执行拼接之后的语句的场景
- 先来看源语句

```sql
v_sql :='insert into sys_user (name,age';
if v_all = 1 then
   v_sql:=v_sql||',status,del_flag)';
else 
    v_sql:=v_sql||')';
end if;

if v_thrid=1 then
   v_sql:=v_sql||' select user_name,user_age from o_sys_user ';
else
    v_sql:=v_sql||' select username,age from syn_user ';
end if;

v_sql :=v_sql||' where 1=1 ';
   
if v_inc_date is not null then
   v_sql:=v_sql||' and modify_time > '||v_inc_date;
end if;

execute immediate v_sql;
```

- 这个案例比较简单
- 下面那直接进行转换
- 在这次的转换之中，我们使用多种方式组合来进行转换
- 目的只是为了表示，不是只有一种方法能够进行转换
- 灵活结合各种方法进行转换也是一个不错的选择
- 当然，这个案例比较简单，可以有更简单的转换方式
- 这个转换实例是在使用比较复杂的场景中常用的手段

```xml

<lang-set result="v_sql" value.string="insert into sys_user (name,age"/>

<lang-choose>
  <lang-when test="v_all == 1">
      <lang-render result="v_sql" _lang="sql">
          ${v_sql},status,del_flag)
      </lang-render>
  </lang-when>
  <lang-otherwise>
      <lang-render result="v_sql" _lang="sql">
          ${v_sql})
      </lang-render>
  </lang-otherwise>
</lang-choose>

<lang-choose>
  <lang-when test="v_thrid == 1">
      <lang-render result="v_sql" _lang="sql">
          ${v_sql} select user_name,user_age from o_sys_user
      </lang-render>
  </lang-when>
  <lang-otherwise>
      <lang-render result="v_sql" _lang="sql">
          ${v_sql} select username,age from syn_user
      </lang-render>
  </lang-otherwise>
</lang-choose>

<lang-set result="v_sql" value.render="${v_sql} where 1=1 "/>

<lang-eval-ts>
if (${v_inc_date}!= null) {
    v_sql=${v_sql}+' and modify_time > '+v_inc_date;
};
</lang-eval-ts>

<sql-update script="v_sql"/>
```

- 直接进行执行动态脚本即可
- 也就是直接按照Mybatis的方式组合就行
- 这种方式适合比较简单或者能够在转换时比较容易看出整体结构得场景

```xml

<sql-update>
    insert into sys_user (name,age
    <choose>
        <when test="v_all==1">
            ,status,del_flag)
        </when>
        <otherwise>
            )
        </otherwise>
    </choose>
    <choose>
        <when test="v_thrid==1">
            select user_name,user_age from o_sys_user
        </when>
        <otherwise>
            select username,age from syn_user
        </otherwise>
    </choose>
    <where>
        <if test="v_inc_date!=null">
            and modify_time > #{v_inc_date}
        </if>
    </where>
</sql-update>
```

- 当然由于这个例子的特殊性
- 针对字符串拼接的部分
- 可以直接使用eval-ts来即可
- 这种方式适合于语句较短，但是拼接工具量大的场景

```xml

<lang-eval-ts>
    v_sql='insert into sys_user (name,age';
    if (${v_all} == 1 ){
        v_sql=${v_sql}+',status,del_flag)';
    }else{
        v_sql=${v_sql}+')';
    };

    if (${v_thrid}==1 ){
        v_sql=${v_sql}+' select user_name,user_age from o_sys_user ';
    }else{
        v_sql=${v_sql}+' select username,age from syn_user ';
    };

    v_sql=${v_sql}+' where 1=1 ';

    if( ${v_inc_date} != null ){
        v_sql=${v_sql}+' and modify_time > '+${v_inc_date};
    };

</lang-eval-ts>

<sql-update script="v_sql"/>
```

- 当然执行SQL，不一定非要用sql-update标签
- 根据实际场景，选择合适的sql-标签进行使用

### 5.19 异常处理的转换

- 异常处理的转换比较复杂
- 同时有一部分异常，因为是基于JDBC的，并不能得到和原始的写法一样的异常类型
- 也就是说，大多数情况下，你都只能拿到一个SQLException异常
- 并且由于各个jdbc-driver实现（Oracle，Mysql）等的驱动抛出的异常类型不一致
- 因此处理也比较麻烦
- 因此，本节将只会介绍一些能够进行区分的异常类型的转换过程
- 未提及的，需要根据实际情况决定如何转换

#### 5.19.1 普通一般性异常（exception when others then）

- 这种异常在不同的数据库中可能表达方式不一样
- 主要的含义就是处理一切发生的异常
- 对应Java中，也就是处理Throwable类型的异常
- 先来看示例，这种用于在整个过程中发生异常的处理方式
- 一般书写在整个过程的末尾
- 下面是原始语句

```sql
PROCEDURE SP_TEST ( 
O_CODE OUT NUMBER, 
O_MSG OUT VARCHAR2, 
IN_SUM_DATE IN NUMBER
)
AS
    v_sql varchar2(4000);
BEGIN
    v_sql:='delete from xxx where '; -- 错误的语句
execute immediate v_sql;

-- 执行成功设置正常执行返回值
    O_CODE :=0;
    O_MSG :='ok';

EXCEPTION
  WHEN OTHERS THEN -- 发生其他异常
    -- 执行失败设置错误执行返回值
    O_CODE:=-1;
    O_MSG:='error: code='||SQLCODE||', msg='||SQLERRM;
end SP_TEST;
```

- 下面直接来看转换结果吧

```xml

<procedure id="SP_TEST"
           O_CODE.int=""
           O_MSG.string=""
           IN_SUM_DATE.int="">
    <lang-try> <!-- 通过try-catch语句块包裹，自行决定需要catch哪些异常，catch块可以支持多个，和Java一样，按顺序捕获 -->
        <lang-body>
            <lang-render result="v_sql" _lang="sql">
                delete from xxx where
            </lang-render> <!-- 错误的语句 -->
            <sql-update script="v_sql"/>

            <!-- 执行成功设置正常执行返回值 -->
            <lang-set result="O_CODE" value.int="0"/>
            <lang-set result="O_MSG" value.string="ok"/>
        </lang-body>
        <lang-catch type="Throwable|java.sql.SQLException"
                    e="e"> <!-- 发生其他异常，捕获所有异常类Throwable或SQLException，不写type的时候，默认也是Throwable -->
            <lang-eval-ts>
                error_msg=${e}.getClass().getName()+':'+${e}.getMessage();
            </lang-eval-ts>
            <!-- 执行失败设置错误执行返回值 -->
            <lang-set result="O_CODE" value.int="-1"/>
            <lang-set result="O_MSG" value.render="error:${error_msg}"/>
        </lang-catch>
    </lang-try>
</procedure>
```

- 还有一种情况，内部的异常块
- 也就是过程内部的一小段异常处理块
- 不是过程级别的情况
- 直接看原始语句

```sql
PROCEDURE SP_TEST ( 
O_CODE OUT NUMBER, 
O_MSG OUT VARCHAR2, 
IN_SUM_DATE IN NUMBER
)
AS
    v_sql varchar2(4000);
BEGIN
    v_sql :='delete from xxx where '; -- 错误的语句
   
    -- 内部语句块
begin
execute immediate v_sql;
EXCEPTION
      WHEN OTHERS THEN -- 发生其他异常
        -- 执行失败也无妨，不影响后续执行
        -- 在此处打印日志
        SP_LOG('SP_TEST',IN_SUM_DATE,'execute delete error: code='||SQLCODE||', msg='||SQLERRM);
end;
  
    -- 执行其他后续处理
  
  
    -- 执行成功设置正常执行返回值
    O_CODE :=0;
    O_MSG :='ok';

end SP_TEST;
```

- 直接看转换结果

```xml

<procedure id="SP_TEST"
           O_CODE.int=""
           O_MSG.string=""
           IN_SUM_DATE.int="">
    <lang-render result="v_sql" _lang="sql">
        delete from xxx where
    </lang-render> <!-- 错误的语句 -->
    <lang-try>
        <lang-body>

            <sql-update script="v_sql"/>

        </lang-body>
        <lang-catch type="Throwable" e="e"> <!-- 发生其他异常 -->
            <!-- 执行失败也无妨，不影响后续执行 -->
            <!-- 在此处打印日志 -->
            <lang-eval-ts>
                error_msg=${e}.getClass().getName()+':'+${e}.getMessage();
            </lang-eval-ts>
            <procedure-call refid="SP_LOG"
                            IN_PROCEDURE_NAME.string="SP_TEST"
                            IN_SUM_DATE="IN_SUM_DATE"
                            IN_MSG.body-text.trim.render="">
                execute delete error: ${error_msg}
            </procedure-call>
        </lang-catch>
    </lang-try>
    <!-- 执行其他后续处理 -->

    <!-- 执行成功设置正常执行返回值 -->
    <lang-set result="O_CODE" value.int="0"/>
    <lang-set result="O_MSG" value.string="ok"/>
</procedure>
```

#### 5.19.2 无数据返回异常(exception when NO_DATA_FOUND then)

- 这种异常发生在进行查询时
- 查询没有数据，一般来说，这是一种正常情况
- 不属于异常的定义范围
- 因此，转换之后，也不按照异常进行catch处理
- 而是对结果进行判空处理
- 直接看原始语句
- 这个示例比较单件，只是单纯的进行查询
- 查询得到，就直接返回结果
- 查询不到返回NULL

```sql
v_sql:='select * from sys_user where id='||v_user_id;

begin
execute immediate v_sql into v_user;
O_USER:=V_USER;
exception 
    when NO_DATA_FOUND then
    O_USER:=null;
end;
```

- 下面直接进行转换
- 也就是将NOT_DATA_FOUND处理为判空

```xml

<lang-render result="v_sql" _lang="sql">
    select * from sys_user where id=${v_user_id}
</lang-render>

<sql-query-row script="v_sql" result="v_user" result-type="Map"/>

<lang-choose>
  <lang-when test="v_user==null">
      <lang-set result="O_USER" value.null=""/>
  </lang-when>
  <lang-otherwise>
      <lang-set result="O_USER" value="v_user"/>
  </lang-otherwise>
</lang-choose>
```

#### 5.19.3 除0异常或其他SQL异常(exception when ZERO_DIVIDE then)

- 有时候，在存过的编写中，会利用一些数据库中触发的异常进行编写逻辑
- 比如，当某一类异常出现时，就触发另一套逻辑
- 比如，当运行的SQL出现了除0异常的时候，就进行另外的逻辑
- 下面给出例子说明

```sql
v_sql:='select 1/0 from dual';

begin
execute immediate v_sql;
exception 
    when ZERO_DIVIDE then
    rollback;
    v_sql:='delete from sys_task_log where task_id='||V_TASK_ID;
    execute immediate v_sql;
end;
```

- 这个例子是一定会触发的案例
- 实际情况中，可能并不能直接知道是哪一个参数导致的除0
- 或者是很多参数都可能出现除0的情况，不好处理
- 因此才使用这样的做法
- 下面来看转换结果

```xml
<lang-render result="V_SQL" _lang="sql">
    select 1/0 from dual
</lang-render>
<lang-try>
    <lang-body>
        <sql-query-object script="V_SQL"/>
    </lang-body>
    <!-- SQLException.getSQLState() 得到的是一个规范的SQL编码，当这个编码是22012的时候就是发生了除0异常 -->
    <lang-catch type.cause-first="java.sql.SQLException" e="e" test.eval-ts="${e}.getSQLState()=='22012'">
        <sql-trans-rollback/>
        <sql-update>
            delete from sys_task_log where task_id=#{V_TASK_ID}
        </sql-update>
    </lang-catch>
</lang-try>
```

- 也就是通过SQL规范中定义的SQLState来确定是哪一种具体的数据库异常
- 当然，这个是SQL规范，各个具体的数据库厂商，可能需要具体进行对待处理

## 六、完整转换案例

- 经过上面的简单讲解之后
- 相信已经对转换有了一定的理解
- 现在，使用一些贴近真实情况的案例
- 进行完整的对照讲解
- 以加强理解
- 由于一些原因，案例中涉及到的表名。列名等名称标识符会被变更
- 因此，可能在你看来是没有任何业务价值的
- 甚至毫无逻辑可言
- 但是，请注意，此处说明的是语法的转换
- 而不是其他的内容
- 因此，请忽略这些业务上的逻辑
- 只关注域语法的转换即可
- 下面的案例，使用原来Oracle的语法，进行转换
- 因为Oracle中NULL值的特殊性，也就是空字符等价于NULL
- 所以，判空的时候都是用is_empty判空
- 注意和其他数据库区分
- 具体可根据自身数据库的特性进行调整

### 6.1 迁移转换纲领

- 为了方便迁移转换之后与就代码进行对照
- 以及在调试过程中发现问题时，能够方便的与旧代码对照
- 以排查可能得问题
- 因此，有以下几点建议
  - 原来的注释，也保留
  - 原来的空行，也尽量保留
  - 原来的参数申明，可以保留，也可以不保留
    - 因为在XML中，在Map环境下，声明一个值为null的变量
    - 和不声明这个变量，在访问这个变量时，没有本质的区别
  - 原来的参数声明并赋值，这样的声明必须保留，否则将会导致缺失默认值
  - 原来的参数声明的是复杂类型，这时候可以保留，也可以不保留
  - 原来的形参声明，保留，以方便调用方知道需要传递的参数
  - 类型对照关系
    - 原来的number,一般情况下可用int,long表示即可，除非确认为小数类型，就是用double即可
    - 原来的varchar,clob等字符类型，直接使用string表示即可
  - 变量大小写问题，统一为大写或者小写
    - 大部分数据库都不区分变量名称的大小写
    - 因此需要根据自身旧代码的情况，统一为大小或者小写
    - 比如Oracle的统一为大写风格，MySQL的统一为小写风格

### 6.2 简单函数 F_GET_PARAM_NAME

- 这个是函数，比较简单，就是根据ID获取名称
- 简单的一条查询语句
- 原始代码

```sql
FUNCTION  F_GET_PARAM_NAME( IN_PARAM_ID NUMBER) RETURN VARCHAR2  AS
  /**************************************************************
  *  获取参数名称
  **************************************************************/
      v_sql     varchar2(4000);
      v_result  varchar2(4000);
  BEGIN
      IF IN_PARAM_ID IS NULL THEN
          RETURN NULL;
      END IF;
  
      v_sql := 'select param_name from sys_dict_param where param_id='||IN_PARAM_ID;
      execute immediate v_sql into v_result ;

      return v_result;
  EXCEPTION WHEN NO_DATA_FOUND THEN
      return null ;
  WHEN OTHERS THEN
      RETURN -1;
  END F_GET_PARAM_NAME;
```

- 转换后XML

```xml
<!DOCTYPE procedure SYSTEM "procedure.dtd">
<procedure id="F_GET_PARAM_NAME"
           IN_PARAM_ID.int=""
           return.string="">
    <!--
    /**************************************************************
    *  获取参数名称
    **************************************************************/
    -->
    <!-- 原来有捕获异常，因此使用try语句块 -->
    <lang-try>
        <lang-body>

            <!-- 原来进行了判空，直接返回null值 -->
            <lang-if test="IN_PARAM_ID==null">
                <lang-return value.null=""/> <!-- 原来直接返回null值，这里也使用.null修饰符直接返回null -->
            </lang-if>
  
            <!--
            原来先拼接SQL，再执行SQL
            没有复杂的拼接场景
            转换后可以直接使用占位符直接拼接并执行
            原来的IN_PARAM_ID参数为number类型，因此是一个参数，使用绑定变量#{}占位符
            如果是一个varchar类型的，则需要考虑是否是绑定变量，是则使用#{}占位符
            如果不是绑定变量，如果是SQL语句的一部分，则使用模板渲染${}占位符
            同时可能需要考虑对单引号的转义问题
            原来语句的执行结果保存到V_RESULT中，类型为varchar
            因此结果result也保存到V_RESULT中，类型result-type对应为string
            同时原来执行是直接保存到变量，
            因此结果集为一行数据，就可选sql-query-row读取一行
            语句中结果集只有一列，也就是只返回一个值，则选用sql-query-object更好
            -->
  
            <sql-query-object result="V_RESULT" result-type="string">
                select param_name from sys_dict_param where param_id=#{IN_PARAM_ID}
            </sql-query-object>

            <!-- 
            将结果进行返回
            需要注意，lang-return返回的值是通过value属性指定的
            不是标签内部的内容
             -->
            <lang-return value="V_RESULT"/>
        </lang-body>
        <lang-catch> <!-- 原来的异常捕获了others异常，也就是所有异常，因此可以不用指明type -->
            <lang-return value.string="-1"/>
        </lang-catch>
    </lang-try>
</procedure>
```

- 转换后XML，变体，分步骤绑定变量执行

```xml
<!DOCTYPE procedure SYSTEM "procedure.dtd">
<procedure id="F_GET_PARAM_NAME"
           IN_PARAM_ID.int=""
           return.string="">
    <!--
    /**************************************************************
    *  获取参数名称
    **************************************************************/
    -->
    <!-- 原来有捕获异常，因此使用try语句块 -->
    <lang-try>
        <lang-body>

            <!-- 原来进行了判空，直接返回null值 -->
            <lang-if test="IN_PARAM_ID==null">
                <lang-return value.null=""/> <!-- 原来直接返回null值，这里也使用.null修饰符直接返回null -->
            </lang-if>
  
            <!--
            原来先拼接SQL，再执行SQL
            严格按照原来的逻辑来
            -->
  
            <!-- 
            先拼接SQL，这里为了使用绑定变量，避免SQL注入
            使用sql-script进行获取BindSql对象
            这样可以使用#{}进行参数绑定，而不是使用${}进行模板渲染
            -->
            <sql-script result="V_SQL">
              select param_name from sys_dict_param where param_id=#{IN_PARAM_ID}
            </sql-script>
  
            <!--
            直接将V_SQL中的BindSql对象作为要执行的SQL传递给script作为sql-query-object执行的SQL语句
            其他的返回值和返回值类型也一样即可
            -->
            <sql-query-object result="V_RESULT" script="V_SQL" result-type="string"/>

            <!-- 将结果进行返回 -->
            <lang-return value="V_RESULT"/>
        </lang-body>
        <lang-catch> <!-- 原来的异常捕获了others异常，也就是所有异常，因此可以不用指明type -->
            <lang-return value.string="-1"/>
        </lang-catch>
    </lang-try>
</procedure>
```

- 转换后XML，变体，分步骤模板渲染执行

```xml
<!DOCTYPE procedure SYSTEM "procedure.dtd">
<procedure id="F_GET_PARAM_NAME"
           IN_PARAM_ID.int=""
           return.string="">
    <!--
    /**************************************************************
    *  获取参数名称
    **************************************************************/
    -->
    <!-- 原来有捕获异常，因此使用try语句块 -->
    <lang-try>
        <lang-body>

            <!-- 原来进行了判空，直接返回null值 -->
            <lang-if test="IN_PARAM_ID==null">
                <lang-return value.null=""/> <!-- 原来直接返回null值，这里也使用.null修饰符直接返回null -->
            </lang-if>
  
            <!--
            原来先拼接SQL，再执行SQL
            严格按照原来的逻辑来
            -->
  
            <!-- 
            先拼接SQL，这里直接进行字符串渲染，因为IN_PARAM_ID是number类型
            就刷直接拼接也没什么问题，因此可以使用lang-render来完成
            在使用lang-render/lang-string时，可以使用_lang属性指定内部的语言类型
            这里指定为sql,这样可以借助IDE插件的高亮能力，提供该语言的语法高亮等特性
            因为，使用velocity进行模板渲染，因此，如果IN_PARAM_ID的值为null时
            velocity的默认行为是保留原样，这里希望是替换为空字符串
            因此使用$!{}进行渲染
            -->
            <lang-render result="V_SQL" _lang="sql">
              select param_name from sys_dict_param where param_id=$!{IN_PARAM_ID}
            </lang-render>
  
            <!--
            直接将V_SQL中的string对象作为要执行的SQL传递给script作为sql-query-object执行的SQL语句
            其他的返回值和返回值类型也一样即可
            -->
            <sql-query-object result="V_RESULT" script="V_SQL" result-type="string"/>

            <!-- 将结果进行返回 -->
            <lang-return value="V_RESULT"/>
        </lang-body>
        <lang-catch> <!-- 原来的异常捕获了others异常，也就是所有异常，因此可以不用指明type -->
            <lang-return value.string="-1"/>
        </lang-catch>
    </lang-try>
</procedure>
```

### 6.3 简单函数 F_GET_TABLE_COLUMNS

- 这个是函数，比较简单，就是获取指定表的所有列名拼接并返回
- 原始代码

```sql
FUNCTION F_GET_TABLE_COLUMNS(IN_SEL_TABLE IN VARCHAR2,IN_SEL_OWNER IN VARCHAR2) RETURN VARCHAR2
        IS
  /**************************************************************
  * 功能：根据表明获取对应的所有表字段
  *   返回值为： 表字段的字符串
  * @IN_SEL_TABLE              查询的表
  * @IN_FROM_TABLE                查询的表
  **************************************************************/
        v_columns VARCHAR2(4000);
        v_sql LONG ;
    BEGIN
        FOR i IN ( SELECT DISTINCT A.COLUMN_NAME FROM all_tab_columns a WHERE upper(A.TABLE_NAME)=UPPER(IN_SEL_TABLE) AND upper(A.OWNER)=UPPER(IN_SEL_OWNER) )LOOP
                v_columns:=v_columns||I.COLUMN_NAME||' ,';
            END LOOP ;
        v_columns:= rtrim(v_columns,',');
        RETURN v_columns;
    END ;
```

- 转换XML，直接复刻逻辑使用cursor

```xml
<!DOCTYPE procedure SYSTEM "procedure.dtd">
<procedure id="F_GET_TABLE_COLUMNS"
           IN_SEL_TABLE.string=""
           IN_SEL_OWNER.string=""
           return.string="">
    <!--
    /**************************************************************

      * 功能：根据表明获取对应的所有表字段
      *   返回值为： 表字段的字符串
      * @IN_SEL_TABLE              查询的表
      * @IN_FROM_TABLE                查询的表
      **************************************************************/
    -->
  
    <!-- 因为目标是拼接字符串，因此先赋值一个空字符串 -->
    <lang-set result="V_COLUMNS" value.string=""/>
  
    <!-- 
    原来是一个for循环语句，对查询结果进行循环
    因此，这里使用游标循环方式sql-cursor
    原来的循环迭代变量为I，这里也设置循环迭代行为 item="I"
     -->
    <sql-cursor item="I">
        <!-- 
        游标固定使用sql-query-list来指定查询的语句
        这里直接照搬原来的语句下来
        但是，逻辑进行调整一下，可以不传库名
        -->
        <sql-query-list>
            SELECT DISTINCT A.COLUMN_NAME FROM all_tab_columns a WHERE upper(A.TABLE_NAME)=UPPER(#{IN_SEL_TABLE})
            <if test="IN_SEL_OWNER!=null and IN_SEL_OWNER!=''">
                AND upper(A.OWNER)=UPPER(#{IN_SEL_OWNER})
            </if>
        </sql-query-list>
        <!-- 
        游标固定使用lang-body进行行迭代
        -->
        <lang-body>
            <!-- 
            原来进行了语句的拼接，现在也进行语句的拼接
            不过这里使用了.render修饰符进行模板渲染拼接
            默认情况下查询出来的列名会强制转换为大写，因此这里是 I.COLUMN_NAME
            -->
            <lang-set result="V_COLUMNS" value.render="$!{V_COLUMNS}$!{I.COLUMN_NAME},"/>
        </lang-body>
    </sql-cursor>

    <!--
    原来游标结束之后，进行了rtrim
    这里适应TinyScript也进行rtrim
    -->
    <lang-eval-ts>
        V_COLUMNS=rtrim(${V_COLUMNS},',');
    </lang-eval-ts>

    <!-- 最后返回结果 -->
    <lang-return value="V_COLUMNS"/>
</procedure>
```

- 转换XML，使用TinyScript进行简化

```xml
<!DOCTYPE procedure SYSTEM "procedure.dtd">
<procedure id="F_GET_TABLE_COLUMNS"
           IN_SEL_TABLE.string=""
           IN_SEL_OWNER.string=""
           return.string="">
    <!--
    /**************************************************************

      * 功能：根据表明获取对应的所有表字段
      *   返回值为： 表字段的字符串
      * @IN_SEL_TABLE              查询的表
      * @IN_FROM_TABLE                查询的表
      **************************************************************/
    -->

  <!--
  直接查询出所有的结果集，保存到 rowList 中
  这时候，rowList 实际是 List 对象，内部都是 Map 元素
  -->
  <sql-query-list result="rowList">
    SELECT DISTINCT A.COLUMN_NAME FROM all_tab_columns a WHERE upper(A.TABLE_NAME)=UPPER(#{IN_SEL_TABLE})
    <if test="IN_SEL_OWNER!=null and IN_SEL_OWNER!=''">
      AND upper(A.OWNER)=UPPER(#{IN_SEL_OWNER})
    </if>
  </sql-query-list>
  
  <lang-eval-ts>
    // 初始化空字符串
    V_COLUMNS='';
    // 对 rowList 进行迭代，迭代对象为 row，因此 row 就是一行数据，就是一个 Map 对象
    foreach(row : ${rowList}){
        // 进行字符串拼接
        V_COLUMNS=$!{V_COLUMNS}+$!{row.COLUMN_NAME}+',';
    };
    // 进行 rtrim
    V_COLUMNS=rtrim(${V_COLUMNS},',');
  </lang-eval-ts>

    <!-- 最后返回结果 -->
    <lang-return value="V_COLUMNS"/>
</procedure>
```

- 转换XML，使用Java进行简化

```xml
<!DOCTYPE procedure SYSTEM "procedure.dtd">
<procedure id="F_GET_TABLE_COLUMNS"
           IN_SEL_TABLE.string=""
           IN_SEL_OWNER.string=""
           return.string="">
    <!--
    /**************************************************************

      * 功能：根据表明获取对应的所有表字段
      *   返回值为： 表字段的字符串
      * @IN_SEL_TABLE              查询的表
      * @IN_FROM_TABLE                查询的表
      **************************************************************/
    -->

  <!--
  直接查询出所有的结果集，保存到 rowList 中
  这时候，rowList 实际是 List 对象，内部都是 Map 元素
  -->
  <sql-query-list result="rowList">
    SELECT DISTINCT A.COLUMN_NAME FROM all_tab_columns a WHERE upper(A.TABLE_NAME)=UPPER(#{IN_SEL_TABLE})
    <if test="IN_SEL_OWNER!=null and IN_SEL_OWNER!=''">
      AND upper(A.OWNER)=UPPER(#{IN_SEL_OWNER})
    </if>
  </sql-query-list>

  <!--
  因为这里使用到了泛型，
  因此内部使用CDATA进行包裹
  避免符号转义
  最后使用return null返回，这是必须的，eval-java必须要返回一个值
  但是这里已经设置了值，就不需要返回值了，所以直接放回null即可
  -->
  <lang-eval-java>
    <![CDATA[
            List<Map<String,Object>> list = executor.visitAs("rowList", params);
            String columns = list.stream()
                    .map(e -> e.get("COLUMN_NAME"))
                    .map(String::valueOf)
                    .collect(java.util.stream.Collectors.joining(","));
            executor.visitSet(params,"V_COLUMNS",columns);
            return null;
        ]]>
  </lang-eval-java>

    <!-- 最后返回结果 -->
    <lang-return value="V_COLUMNS"/>
</procedure>
```

- 转换XML，使用Groovy进行简化

```xml
<!DOCTYPE procedure SYSTEM "procedure.dtd">
<procedure id="F_GET_TABLE_COLUMNS"
           IN_SEL_TABLE.string=""
           IN_SEL_OWNER.string=""
           return.string="">
    <!--
    /**************************************************************

      * 功能：根据表明获取对应的所有表字段
      *   返回值为： 表字段的字符串
      * @IN_SEL_TABLE              查询的表
      * @IN_FROM_TABLE                查询的表
      **************************************************************/
    -->

  <!--
  直接查询出所有的结果集，保存到 rowList 中
  这时候，rowList 实际是 List 对象，内部都是 Map 元素
  -->
  <sql-query-list result="rowList">
    SELECT DISTINCT A.COLUMN_NAME FROM all_tab_columns a WHERE upper(A.TABLE_NAME)=UPPER(#{IN_SEL_TABLE})
    <if test="IN_SEL_OWNER!=null and IN_SEL_OWNER!=''">
      AND upper(A.OWNER)=UPPER(#{IN_SEL_OWNER})
    </if>
  </sql-query-list>
  
  <!--
  因为这里使用到了泛型，
  因此内部使用CDATA进行包裹
  避免符号转义
  groovy默认将最后一条语句作为返回值，
  因此不需要显式的使用return语句
  -->
  <lang-eval-groovy>
    <![CDATA[
            params.V_COLUMNS = ((List<Map<String,Object>>) params.rowList).stream()
                    .map(e -> e.COLUMN_NAME)
                    .collect(java.util.stream.Collectors.joining(","))
        ]]>
  </lang-eval-groovy>

    <!-- 最后返回结果 -->
    <lang-return value="V_COLUMNS"/>
</procedure>
```

### 6.4 简单存储过程 SP_GET_PARAM_VALUE

- 这个是存储过程，并且是在包里面的过程
- 所以有些变量是在包里面定义与初始化的
- 也就是对应迁移后的 global. 中的变量
- 并且过程属于包 PKG_PARAM
- 内部也调用了同一个包下的其他过程或者函数
- 迁移之后，包的概念就不存在了
- 因此没有了包的概念，变为了全局变量维持
- 原始代码

```sql

PROCEDURE SP_GET_PARAM_VALUE(IN_CITY_CODE        NUMBER,
                                          IN_SUM_MONTH      NUMBER,
                                          IN_DICT_TYPE_ID VARCHAR2,
                                          IN_FORMULA_ID     NUMBER,
                                          IN_TASK_ID        NUMBER,
                                          IN_INSTANCE_ID    NUMBER,
                                          IN_PARAM_ID       NUMBER,
                                          IN_PARTITION_ID   NUMBER,
                                          O_PARAM_VALUE     OUT VARCHAR2,
                                          O_FLAG            OUT NUMBER)    AS
        /**************************************************************
        *  获取规则配置
        **************************************************************/
        V_CITY_CODE      NUMBER(4);
        V_SUM_MONTH      NUMBER(6);
        V_DICT_TYPE_ID VARCHAR2(12);
        V_TASK_ID        NUMBER(12);
        V_SQL            LONG;
        V_PARTITION_ID NUMBER(2);
        V_PARAMS  varchar(32767);
        V_PARAM_NAME     VARCHAR2(128);
        V_PARAM_DESC     VARCHAR2(1024);
        v_param_id number(12);
        v_GET_TAB_ALIAS varchar2(128);
        v_GET_column varchar2(512);
        V_PARAM_TYPE number(6);
        v_instance_id number(12);
        v_c VARCHAR2(4000);
        V_IS_DICT_CODE             NUMBER(2);
        V_FORMULA_ID    SYS_DICT_FORMULA.FORMULA_ID%TYPE;
        v_ERROR_INFO            VARCHAR2(4000);
        V_FLAG number(10);
BEGIN

    --============================================ 变量初始化=============================================--

    V_CITY_CODE      := IN_CITY_CODE;
    V_SUM_MONTH      := IN_SUM_MONTH;
    V_DICT_TYPE_ID := IN_DICT_TYPE_ID;
    V_TASK_ID        := IN_TASK_ID;
    V_FORMULA_ID     := IN_FORMULA_ID;
    v_instance_id :=IN_instance_id   ;
    v_param_id    :=IN_param_id      ;
    v_PARTITION_ID:=IN_PARTITION_ID  ;

    v_ERROR_INFO :='FORMULA_ID='||V_FORMULA_ID||',instance_id='||v_instance_id||',param_id='||v_param_id||',PARTITION_ID='||v_PARTITION_ID||' ';
    --============================================ 开始酬金规则有效性判断=============================================--


    V_PARAMS    :='';

    v_ERROR_DETAIL:='获取SYS_DICT_PARAM信息 步骤';

    v_sql:='select  t2.param_name,t2.param_desc
                from   '||V_SCHEMA||'.PKG_PARAM.SYS_DICT_PARAM t2
                where  T2.param_id = '||v_param_id||'    ';

    execute immediate v_sql into V_PARAM_NAME,V_PARAM_DESC  ;


    v_sql:=
            'select '||V_SCHEMA||'.PKG_PARAM.F_GET_TAB_ALIAS('||v_param_id||','||v_PARTITION_ID||')
         from dual';
    v_ERROR_DETAIL:='FORMULA_ID='||V_FORMULA_ID||' param_id='||v_param_id||' PARTITION_ID='||v_PARTITION_ID||'  在 SP_GET_PARAM_VALUE   中F_GET_TAB_ALIAS 步骤';

    execute immediate v_sql into v_GET_TAB_ALIAS;
    -- 参数类型 时间类型时转换格式
    v_sql:=
            'select '||V_SCHEMA||'.PKG_PARAM.F_GET_PARAM_TYPE('||v_param_id||')
          from dual';
    v_ERROR_DETAIL:=' F_GET_PARAM_TYPE 步骤';

    execute immediate v_sql into V_PARAM_TYPE;

    if V_PARAM_TYPE =3 THEN


        v_GET_column:= 'decode('||v_GET_TAB_ALIAS||'.'||V_PARAM_NAME||',null,'' 空'',to_char('||v_GET_TAB_ALIAS||'.'||V_PARAM_NAME||',''yyyy-mm-dd hh24:mi:ss''))';
    ELSE


        v_sql:='select count(1) from '||V_SCHEMA||'.PKG_PARAM.SYS_DICT_PARAM  where  param_id='||v_param_id||'
                          AND is_code = 1
                          AND UPPER(code_sql) NOT LIKE ''%SUM_MONTH%''
                          AND UPPER(code_sql) NOT LIKE ''%SUM_DATE%''
                          AND UPPER(code_sql) NOT LIKE ''%EX_MONTH%''
                          AND UPPER(code_sql) NOT LIKE ''%EX_DATE%''
                          AND CODE_SQL IS NOT NULL ';
        v_ERROR_DETAIL:='获取PARAM_NAME步骤';

        execute immediate v_sql into V_IS_DICT_CODE;
        IF V_IS_DICT_CODE >0 THEN
            V_PARAM_NAME:=V_PARAM_NAME||'_DESC';
        END IF ;

        IF V_IS_DICT_CODE=0 AND V_PARAM_TYPE =1 AND (V_PARAM_DESC  LIKE '%(元)%'OR  V_PARAM_DESC LIKE '%金额%' ) THEN
            V_PARAM_NAME:='trim(to_char('||v_GET_TAB_ALIAS||'.'||V_PARAM_NAME||',''9999999999990.99''))';
        ELSE --加上表别名 下面处理就可以不要加了
            V_PARAM_NAME:=v_GET_TAB_ALIAS||'.'||V_PARAM_NAME;
        END IF ;

        v_GET_column:= 'decode('||V_PARAM_NAME||',null,'' 空'', '||V_PARAM_NAME||')';
    END IF;

    V_PARAMS :='''['||V_PARAM_DESC||'='||chr(39)||'||'
        ||v_GET_column||'||'||chr(39)||']''';

    O_PARAM_VALUE :=V_PARAMS ;
    O_FLAG:=0;
exception when others then
    O_FLAG := -1;
    --记录错误日志
    v_ERROR_DETAIL:=v_ERROR_INFO||v_ERROR_DETAIL;
    SP_TASK_LOG(V_SUM_MONTH,V_CITY_CODE,V_TASK_ID,V_DICT_TYPE_ID,v_sql,2,v_begin_time,sysdate,-1,SQLERRM,
                                          '获取规则配置。传入参数：'||V_CITY_CODE||','||V_SUM_MONTH||','||V_DICT_TYPE_ID||','||V_FORMULA_ID||','||V_TASK_ID||','||v_instance_id||','||v_param_id||','||v_PARTITION_ID||' 具体失败为： '||v_ERROR_DETAIL,V_FLAG);



END  SP_GET_PARAM_VALUE;
```

- 转换后XML

```xml
<!DOCTYPE procedure SYSTEM "procedure.dtd">
<procedure id="SP_GET_PARAM_VALUE"
           IN_CITY_CODE.int=""
           IN_SUM_MONTH.int=""
           IN_DICT_TYPE_ID.string=""
           IN_FORMULA_ID.int=""
           IN_TASK_ID.int=""
           IN_INSTANCE_ID.int=""
           IN_PARAM_ID.int=""
           IN_PARTITION_ID.int=""
           O_PARAM_VALUE.string=""
           O_FLAG.int.out=""
>
    <!--
    /**************************************************************
    *  获取规则配置
    **************************************************************/
    -->

    <!--
    变量都是只有什么，因此不做初始化了
    如果变量存在声明并赋值的情况
    就需要额外初始化变量
    -->

    <!--
    这个过程有进行异常捕获
    因此也进行try-catch处理
    -->
    <lang-try>
        <lang-body>
            <!--
            因为过程在包里面
            因此就将包变量的初始化放到单独的过程中进行
            这个过程的作用就是，检查包变量是否进行初始化了
            如果没有就进行初始化，如果已经初始化，则不进行任何处理
            因此，内部实现伪代码大体如此：
            if(global.PKG_PARAM==true){
                // 已经处理，直接返回
                return;
            }
            global.PKG_PARAM=true;
            // 进行初始化
            也就是借助一个标志位判断是否已经初始化
            同时，这里设置了 params-share="true"
            也就是将本过程的上下文直接透传过去初始化，共享上下文
            这样在内部调用改变参数，也就实现了包变量的初始化
            -->
            <procedure-call refid="PKG_PARAM" params-share="true"/>

            <!-- ============================================ 变量初始化============================================= -->

            <!--
            简单赋值，使用 TinyScript 进行转换最快捷
            -->
            <lang-eval-ts>
                V_CITY_CODE = ${IN_CITY_CODE};
                V_SUM_MONTH = ${IN_SUM_MONTH};
                V_DICT_TYPE_ID = ${IN_DICT_TYPE_ID};
                V_TASK_ID = ${IN_TASK_ID};
                V_FORMULA_ID = ${IN_FORMULA_ID};
                V_INSTANCE_ID =${IN_INSTANCE_ID} ;
                V_PARAM_ID =${IN_PARAM_ID} ;
                V_PARTITION_ID=${IN_PARTITION_ID} ;
            </lang-eval-ts>

            <!--
            字符串拼接，直接进行render
            又因为这是错误信息，用于记录日志使用
            所以，可以放心的进行trim
            -->
            <lang-render result.trim="V_ERROR_INFO">
                FORMULA_ID=$!{V_FORMULA_ID},instance_id=$!{V_INSTANCE_ID},param_id=$!{V_PARAM_ID},PARTITION_ID=$!{V_PARTITION_ID}
            </lang-render>

            <!-- ============================================ 开始规则判断============================================= -->


            <lang-set result="V_PARAMS" value.string=""/>

            <lang-string result.trim="V_ERROR_DETAIL">
                获取SYS_DICT_PARAM信息 步骤
            </lang-string>

            <!--
            这里的V_SCHEMA实际就是包变量定义的
            包变量变为全局变量之后，就变成了从全局变量获取
            -->
            <sql-query-row result="tmpRowMap">
                select t2.param_name,t2.param_desc
                from $!{global.V_SCHEMA}SYS_DICT_PARAM t2
                where T2.param_id = #{V_PARAM_ID}
            </sql-query-row>

            <!--
            原来的语句时直接查询到多个变量中
            为了和原来的语句兼容
            因此，将变量从Map中提取出来
            和原来保持一致，方便对照调试
            -->
            <lang-set result="V_PARAM_NAME" value="tmpRowMap.PARAM_NAME"/>
            <lang-set result="V_PARAM_DESC" value="tmpRowMap.PARAM_DESC"/>


            <lang-render result.trim="V_ERROR_DETAIL">
                FORMULA_ID=$!{V_FORMULA_ID} param_id=$!{V_PARAM_ID} PARTITION_ID=$!{V_PARTITION_ID} 在
                SP_GET_PARAM_VALUE 中F_GET_TAB_ALIAS 步骤
            </lang-render>

            <!--
            进程函数调用，形参和入参进行对应
            例如：形参="入参"
            也就是：IN_PARAM_ID="V_PARAM_ID"
            最后因为是function-call函数调用
            因此就会有函数返回值接受
            使用result属性指定接受的变量名
            result="V_GET_TAB_ALIAS"
            这样，这个函数调用的结果就保存到V_GET_TAB_ALIAS变量中了
            -->
            <function-call refid="F_GET_TAB_ALIAS"
                           IN_PARAM_ID="V_PARAM_ID"
                           IN_PARTITION_ID="V_PARTITION_ID"
                           result="V_GET_TAB_ALIAS"/>

            <!-- 参数类型 时间类型时转换格式 -->
            <lang-string result.trim="V_ERROR_DETAIL">
                F_GET_PARAM_TYPE 步骤
            </lang-string>

            <function-call refid="F_GET_PARAM_TYPE"
                           IN_PARAM_ID="V_PARAM_ID"
                           IN_V_SCHEMA="global.V_SCHEMA"
                           result="V_PARAM_TYPE"/>

            <lang-choose>
                <lang-when test="V_PARAM_TYPE ==3">
                    <lang-render result="V_GET_COLUMN" _lang="sql">
                        decode($!{V_GET_TAB_ALIAS}.$!{V_PARAM_NAME},null,'空',to_char($!{V_GET_TAB_ALIAS}.$!{V_PARAM_NAME},'yyyy-mm-dd hh24:mi:ss'))
                    </lang-render>
                </lang-when>
                <lang-otherwise>


                    <lang-string result.trim="V_ERROR_DETAIL">
                        获取PARAM_NAME步骤
                    </lang-string>

                    <sql-query-object result="V_IS_DICT_CODE" result-type="long">
                        select count(1) from $!{global.V_SCHEMA}SYS_DICT_PARAM where param_id=#{V_PARAM_ID}
                        AND is_code = 1
                        AND UPPER(code_sql) NOT LIKE '%SUM_MONTH%'
                        AND UPPER(code_sql) NOT LIKE '%SUM_DATE%'
                        AND UPPER(code_sql) NOT LIKE '%EX_MONTH%'
                        AND UPPER(code_sql) NOT LIKE '%EX_DATE%'
                        AND CODE_SQL IS NOT NULL
                    </sql-query-object>
                    <lang-if test="V_IS_DICT_CODE >0">
                        <lang-set result="V_PARAM_NAME" value.render="$!{V_PARAM_NAME}_DESC"/>
                    </lang-if>

                    <lang-choose>
                        <!--
                        这里这个条件比较复杂，使用OGNL来写不太好写
                        直接使用 TinyScript 进行判断
                        -->
                        <lang-when
                                test.eval-ts='${V_IS_DICT_CODE}==0 and ${V_PARAM_TYPE} ==1 and (like(${V_PARAM_DESC},"元") or  like(${V_PARAM_DESC},"金额")  )'>
                            <lang-set result="V_PARAM_NAME"
                                      value.render="trim(to_char(${V_GET_TAB_ALIAS}.${V_PARAM_NAME},'9999999999990.99'))"/>
                        </lang-when>
                        <lang-otherwise> <!-- 加上表别名 下面处理就可以不要加了 -->
                            <lang-set result="V_PARAM_NAME" value.render="$!{V_GET_TAB_ALIAS}.$!{V_PARAM_NAME}"/>
                        </lang-otherwise>
                    </lang-choose>

                    <lang-set result="V_GET_COLUMN" value.render="decode($!{V_PARAM_NAME},null,' 空', $!{V_PARAM_NAME})"/>
                </lang-otherwise>
            </lang-choose>

            <lang-set result="V_PARAMS" value.render="'[$!{V_PARAM_DESC}='||$!{V_GET_COLUMN}||']'"/>

            <lang-set result="O_PARAM_VALUE" value="V_PARAMS"/>
            <lang-set result="O_FLAG" value.int="0"/>

        </lang-body>
        <lang-catch>
            <lang-set result="O_FLAG" value.int="-1"/>
            <!-- 记录错误日志 -->
            <lang-render result.trim="V_ERROR_DETAIL">
                $!{V_ERROR_INFO}$!{V_ERROR_DETAIL}
            </lang-render>
            <!--
            这里进行过程调用
            其中入参有几个比较特别的
            IN_EXEC_STATUS.int="2"
            使用了int修饰符，也就是说属性值"2"要经过int修饰符转换，所以得到的就是int类型的2
            IN_END_TIME.date-now=""
            使用的date-now修饰符，也就是说属性值""要经过date-now转换，所以得到的就是 new Date()
            这个修饰符就比较特殊了，因为date-now不需要考虑输入，也就是属性值是什么，而是直接返回
            此类修饰符还有如 null 等
            IN_ERROR_DETAIL.body-text.trim.render=""
            这里有三个属性修饰符
            所以属性值""要分别经过这三个修饰符
            首先属性值""经过body-text之后，因为该修饰符将内部文本作为返回值，所以此时的值变为了内部的文本
            然后此时的内部文本经过trim修饰符，进行了trim
            然后此时的文本经过render修饰符进行了模版渲染
            最后此时的值就是最终的值
            因此，这里的作用就是将内部的文本进行trim后进行render之后最为入参传递
            O_FLAG.null=""
            这里，这个其实是出参,所以他不需要入参，直接给null修饰符，或者不写就行
            但是建议是写上给null
            -->
            <procedure-call refid="SP_TASK_LOG"
                            result="callParams"
                            IN_SUM_MONTH="V_SUM_MONTH"
                            IN_CITY_CODE="V_CITY_CODE"
                            IN_TASK_ID="V_TASK_ID"
                            IN_DICT_TYPE_ID="V_DICT_TYPE_ID"
                            IN_CONTENT="V_SQL"
                            IN_EXEC_STATUS.int="2"
                            IN_BEGIN_TIME="V_BEGIN_TIME"
                            IN_END_TIME.date-now=""
                            IN_ERROR_CODE.int="-1"
                            IN_ERROR_DESC="V_ERROR_DETAIL"
                            IN_ERROR_DETAIL.body-text.trim.render=""
                            O_FLAG.null=""
            >
                获取规则配置失败。
                传入参数：$!{V_CITY_CODE},$!{V_SUM_MONTH},$!{V_DICT_TYPE_ID},$!{V_FORMULA_ID},$!{V_TASK_ID},$!{V_INSTANCE_ID},$!{V_PARAM_ID},${V_PARTITION_ID}
                具体失败为： $!{V_ERROR_DETAIL}
            </procedure-call>
            <!--
            按照原来的逻辑，保存了调用的出参到V_FLAG
            使用procedure-call时，内部的出参保存在result指定的Map对象中
            因此，如果后续要使用，最好将变量提取出来，和原来的逻辑能够尽量兼容
            -->
            <lang-set result="V_FLAG" value="callParams.O_FLAG"/>
        </lang-catch>
    </lang-try>
</procedure>
```

## 七、内建变量

- 这部分主要提供一些调试跟踪的手段或者变量

### 7.1 XML文件名 trace.location

- 最后一次访问的XML节点所在文件名
- 这个变量将会在节点执行前进行赋值
- 因此可以在节点执行时，获取到当前节点所在的XML文件名称
- 使用方法例如

```xml

<lang-render result="RUN_INFO">
    current step is 1, at ${trace.location}
</lang-render>
```

### 7.2 XML标签行号 trace.line

- 最后一次访问的XML节点所在的行号
- 这个变量将会在节点执行前进行赋值
- 因此可以在节点执行时，获取到当前节点所在的行号
- 使用方法例如

```xml

<lang-render result="RUN_INFO">
    current step is 1, at ${trace.line}
</lang-render>
```

### 7.3 最后一次异常的错误信息 trace.errmsg

- 能够获取最后一次执行异常时的错误信息
- 一般可用于catch语句块中直接获取错误信息
- 而不在调用异常对象的方法获取异常信息e.getMessage()
- 使用方法例如

```xml

<lang-try>
    <lang-body>

    </lang-body>
    <lang-catch>
        <lang-render result="RUN_INFO">
            run error, at ${trace.location}:${trace.line} msg: ${trace.errmsg}
        </lang-render>
    </lang-catch>
</lang-try>
```

### 7.4 获取当前节点元数据 trace.node

- 能够获取最后一次执行的XML节点的元数据信息，返回的是XmlNode对象
- 需要注意，请不要轻易的修改对象的值
- 除非你深刻的评估过了
- 一般情况下只建议进行读取操作
- 使用方法例如

```xml

<lang-render result="RUN_INFO">
    current step is 1, on tag: ${trace.node.tagName} , with attrs: ${trace.node.tagAttrMap}
    at ${trace.node.locationFile}:${trace.nodelocationLineNumber}
</lang-render>
```

## 八、内建函数（TinyScript）

- 内建函数，这里说的是在 TinyScript 环境中使用的函数
- 也就是说，可以在 lang-eval-ts 标签内，或者在 eval-ts 属性修饰符内使用的函数
- 目前，有以下几类来源定义了可用的函数
- TinyScript 脚本语言默认注册的函数
- 与 Jdbc-Procedure 框架集成之后注册的函数

### 8.1 TinyScript 脚本语言默认注册的函数

- 这个是在 TinyScript 脚本中默认注册的
- 在 TinyScript.BUILTIN_METHOD 中保存了默认注册的内建函数
- 当然，也可以向其中添加自己的函数，以实现自己的拓展函数
- 可以通过 TinyScript 类中提供的 registry 类函数进行注册函数
- 也可以自己根据规则，将函数直接注册到 TinyScript.BUILTIN_METHOD 静态变量中
- 默认注册的函数在 TinyScript 类的静态代码块中进行了初始化
- 具体包含的函数可以再静态代码块中进行查看，哪些函数进行了注册
- 同时，在 TinyScriptFunctions 类中，定义了一些内建函数
- 也可以通过代码实现查看，有哪些函数注册到了其中

### 8.2 与 Jdbc-Procedure 框架集成之后注册的函数

- 与 Jdbc-Procedure 框架集成之后，添加的函数
- 主要是为了对接数据库中的函数而添加的部分函数
- 为了方便在进行存储过程转换后的数据库函数的转换问题
- 这部分函数，主要分为以下几个部分
- 通过 ContextHolder.INVOKE_METHOD_MAP 中保存的注册的静态内建函数
  - 当然，你也可以向其中添加自己的函数，注册到其中，以便自己的使用
- 还有，类中通过 ExecutorMethodProvider 和 ExecContextMethodProvider 绑定的上下文函数
  - 另外，也提供了 ProcedureFunctionCallContext 线程上下文参数，可以通过 TinyScript.FUNCTION_CALL_CONTEXT 获取到这个上下文参数
  - 这个上下文参数中，保存了调用内建函数时的上下文参数，以便能获得基于上下文操作的能力
  - 从而提供了更加有效的函数，而不用局限于上下文无关的函数

#### 8.2.1 静态注册的函数

- 通过 ContextHolder.INVOKE_METHOD_MAP 中保存的注册的静态内建函数
- 在 ContextFunctions 类中，定义了默认注册的函数
- 包含了一些列常用的和数据库函数类似的函数
- 以辅助进行数据库函数的转换
- 具体包含的函数和出入参数，可以在其中进行查看详情
- 以了解具体的使用方法和与数据库函数的差异

#### 8.2.2 绑定的上下文函数

- 这部分是深度整合 Jdbc-Procedure 框架之后，从框架的执行上下文中添加的绑定函数
- 提供了基于上下文操纵的能力以及相关的交互函数
- 其中，可用的函数可以在 在 ExecutorMethodProvider 和 ExecContextMethodProvider 类进行查看可以使用的函数
- 当然，绑定上下文函数，已经实现在了这两个内部类中
- 有可能你不希望直接修改这两个类
- 因此，你也可以通过 TinyScript.FUNCTION_CALL_CONTEXT 线程上下文参数获取到执行函数是的上下文参数
- 这样，即使你定义的静态函数，也能够通过线程上下文参数获取到执行上下文信息 ProcedureFunctionCallContext 对象
- 这样就能够具备上下文访问变更的能力
- 下面给出一段示例代码，用于体现通过线程上下文获取执行上下文实现一个注册内建函数

```java
public class TestThreadLocalContextFunctions {

  public static void main(String[] args) {
    // 此处的注册，在默认与 springboot 集成的环境中，可以考虑在 ApplicationRunner 中进行注册
    // 或者直接通过 springboot 提供的一些其他的初始化点中进行注册，例如 Aware 类接口、

    // 直接注册到 TinyScript 脚本中
    TinyScript.registryBuiltMethodByStaticMethod(TestThreadLocalContextFunctions.class);

    // 或者注册到与 Jdbc-Procedure 框架集成的环境中
    ContextHolder.registryAllInvokeMethods(TestThreadLocalContextFunctions.class);
  }

  public static ProcedureFunctionCallContext function_call_context() {
    // 注意，这里获取到的线程上下文参数，因为是和 Jdbc-Procedure 框架集成了，所以，类型才是 ProcedureFunctionCallContext
    // 否则，默认是 DefaultFunctionCallContext 类型
    return (ProcedureFunctionCallContext) TinyScript.FUNCTION_CALL_CONTEXT.get();
  }

  public static XmlNode get_node() {
    ProcedureFunctionCallContext context = function_call_context();
    return context.getNode();
  }
}
```

## 九、问题解答

### 9.1 怎么将主数据切换为其他数据源来执行过程？

- 默认情况下，框架自动检测primary,master,main,default,leader这些数据源作为主数据源primary
- 在多数据源场景中，就是按照这个顺序进行检测的，检测到为止，则不再继续检测
- 要运行过程，如果过程中都没有明确指定数据源
- 则需要具有primary这样一个数据源
- 但是，有的情况下，代码是写在一起，但是实际上却需要再不同的数据源中进行执行
- 例如，某一类存过要在ods层的数据库执行，另一类存过要在ads层的数据库执行
- 这样的情况下，程序如果默认的primary是ods层的数据库
- 则旧导致ads层的存过调用起来比较费劲个，需要手动调整ads作为主数据源primary
- 因此，内部进行了设计上的调整，添加了datasourcesMapping数据源映射的特性
- 定义如下

```java
datasourcesMapping=new HashMap<String, String>();
```

- 键为映射的名称，值为被映射的名称
- 默认情况下，这个映射是空的，也就是不进行任何映射
- 下面直接来看这种场景怎么调用

```java
Map<String, Object> ret = JdbcProcedureHelper.call("SP_ODS_MAIN", (map) -> {
    map.put("O_CODE", "")
            .put("O_MSG", "")
            .put("IN_SUM_MON", "202501")
            .put(ParamsConsts.DATASOURCES_MAPPING, // 添加datasourcesMapping数据源映射
                    new MapBuilder<>(new HashMap<>(), String.class, String.class)
                            .put(ParamsConsts.DEFAULT_DATASOURCE, "ods") // 将默认数据卷primary指向ods数据源
                            .get()
            );
});
```

- 也就是在调用参数上加上datasourcesMapping这个映射Map
- 并且指定了默认数据源指向ods数据源
- 这样，在调用这个存过时，默认数据源就是ods数据源
- 而不再是程序配置中默认的主数据源
- 需要注意的是，这种操作只建议在入口的地方进行设置映射
- 不建议在过程内部也调整映射
- 因为在内部调整之后，可能在子过程或者内部过程调用时，发生事务控制混乱以及主数据源混乱的情况

### 9.2 上下文中有哪些固定的参数？

- 内置了一些固定的运行常量
- 这些常量可以根据需要进行使用和调整值
- 这些固定的参数，基本上在发生内部嵌套调用时，保持了这些参数的共享性
- 这些参数始终都进行共享
- 在使用上，应该避免对这些值进行赋值
- 比如，常用的global,trace,executor参数
- 更多详细的固定变量，可以在如下的函数中进行查看
- 未来可能会发生一些变化

```shell
BasicJdbcProcedureExecutor.createParams()
```

- 下面简单介绍一下这些固定变量的设计初衷和目的
- context 类型INamingContext,具名上下文/应用上下文，主要用于能够结合其他框架的上下文，以使用一些其他框架特有的能力，默认对接springboot中时为ApplicationContext对象
- env 类型IEnvironment,环境变量，主要用于提供一些环境变量的配置，以便能够进行环境变量的读取操作，默认对接springboot中时为Environment对象
- beans 类型Map<String,Object>用于提供一些具名的对象实例，主要是配合固定的框架使用，能够读取到框架中的bean对象，进行调用bean方法，默认对接springboot中定义的所有bean对象
- datasources 类型Map<String,DataSource>
  ,用于提供可用的数据源，不管是否是什么框架，只要执行SQL都应该具有数据源，至少一个primary数据源，默认对接springboot中时自动读取配置的所有数据源
- datasourcesMapping 类型Map<String,String>,用于提供数据源名称映射功能，在需要使用key的数据源时，替换为使用对应的value指向的数据源，默认是空配置，不做映射
- connections 类型Map<String,Connection>
  ,用于保存过程执行期间的所使用的每个数据源的实际连接，只有在发生对应数据源的SQL执行操作时，即使发生了内部过程嵌套调用，也是用的是同一个连接，除非手动指定使用新连接，才会初始化连接到其中，默认是空的
- global 类型Map<String,Object>,用于保存全局变量，在发生过程内部嵌套调用时，依旧能够保持全局变量的共享和传递，默认是空的
- trace 类型Map<String,Object>,用户保存运行时的跟踪信息，方便进行日志跟踪或者源码位置溯源等操作，配合调试等功能，一般对于用户来说只读即可
- executor 类型JdbcProcedureExecutor,用于提供executor的操作能力，方便在一些场景中，能够获取executor的操作能力
- 关于这些参数是如何在发生内部调用时进行传递的，请看下一节

### 9.3 发生内部嵌套调用时上下文是怎么传递的？

- 针对固定参数是使用直接引用赋值的方式进行传递的
- 始终保持引用不变
- 具体可参看如下代码

```java
BasicJdbcProcedureExecutor.newParams()
```

### 9.4 是怎么注入了上下文的固定参数的？

- 用户调用古城，一般只需要传递过程声明的形式参数
- 但是固定参数，用户一般都不需要显式的进行设置
- 那这是在什么时候添加的固定参数？
- 具体可查看如下代码

```java
BasicJdbcProcedureExecutor.prepareParams()
```

### 9.5 怎么添加自己的全局自定义参数？

- 比较常见的就是，希望在每个过程运行的时候
- 都能够注入自己的全局参数
- 或者是对运行的上下文进行修改调整等情况
- 这时候就可以选择事件系统，通过监听准备上下文事件
- 实现对上下文的变更
- 事件 PreparedParamsEvent 是在框架准备完框架的参数之后进行同步调用的
- 因此就可以达到在正式执行之前自定义自己的上下文
- 例如如下代码

```java
@Component
public class PreparedParamsEventListener implements XProc4jEventListener {

    @Autowired
    private TaskProperties config;

    @Override
    public boolean support(XProc4jEvent event) {
        return event instanceof PreparedParamsEvent;
    }

    @Override
    public boolean handle(XProc4jEvent event) {
        PreparedParamsEvent evt = (PreparedParamsEvent) event;
        JdbcProcedureExecutor executor = evt.getExecutor();
        Map<String, Object> context = evt.getContext();
        // 注入全局变量 props 
        executor.visitSet(context, "global.props", config);
  
        // 如果不存在线程的traceId则生成一个并保存
        String traceId = executor.visitAs("trace.traceId", context);
        if(traceId==null){
            traceId= UUID.randomUUID().toString().replaceAll("-","").toLowerCase();
            executor.visitSet(context,"trace.traceId",traceId);
    
            // 同时设置到Slf4j的MDC上下文中
            MDC.put("traceId",traceId);
        }
        return false;
    }
}
```

## 十、拓展和其他

### 10.1 拓展自己的TinyScript自定义函数

- 一些函数是TinyScript内建的函数
- 能够提供基本和数据库内建函数一样的能力
- 但是，也会有一些情况，你想要定义自己的函数
- 可能用户实现数据库的内建函数，可能用户某种场景下的简化操作
- 不管怎样，你都可能有这样的需求
- 那怎么样实现自己的函数，并注册到TinyScript内建函数库呢
- 下面开始教程
- 如果你想要添加自己的内建函数
- 也就是不适用类名.方法名的方式调用
- 直接使用方法名的方式调用
- 那么就需要注册内建函数

#### 10.1.1 内建函数的保存

- 内建函数是通过静态变量实现的
- 变量位置如下

```java
public class TinyScript {
    public static final ConcurrentHashMap<String, CopyOnWriteArrayList<IMethod>> BUILTIN_METHOD = new ConcurrentHashMap<>();

}
```

- 并且提供了一系列的registryBuiltinMethod方法用了进行注册函数

```java
public class TinyScript {
    // 将Java静态函数注册为内建函数
    public static void registryBuiltinMethod(Method method) {

    }

    // 可以自行封装实现内建函数声明
    // 这种情况下允许没有实际的Java方法定义即可
    // 实际的实现允许是任意的，比如执行脚本等都可以
    public static void registryBuiltinMethod(IMethod method) {

    }

    // 将类中的所有静态方法都注册为内建函数
    public static void registryBuiltMethodByStaticMethod(Class<?> clazz) {

    }

    // 将类中所有的静态方法都注册为内建函数
    // 允许使用filter来过滤需要注册为内建函数的函数
    public static void registryBuiltMethodByStaticMethod(Class<?> clazz, Predicate<Method> filter) {

    }

    // 将实例对象的所有public公开方法（实例函数和静态函数）注册为内建函数，函数调用的对象就是传入的对象
    public static void registryBuiltMethodByInstanceMethod(Object object) {

    }

    // 将实例对象的所有public公开方法（实例函数和静态函数）注册为内建函数，函数调用的对象就是传入的对象
    // 允许使用filter来过滤需要注册为内建函数的函数
    public static void registryBuiltMethodByInstanceMethod(Object object, Predicate<Method> filter) {

    }
}
```

- 因此，你只需要在使用tiny-script之前，调用以上的注册方法进行注册内建函数即可
- 一般的情况，自己编写一个工具类，编写一些需要注册为内建函数的静态方法
- 例如

```java
public class MySqlFunctions {
    public static Object ifnull(Object val, Object defVal) {
        if (val == null) {
            return defVal;
        }
        return val;
    }
}
```

- 然后将这个类注册为内建函数

```java
TinyScript.registryBuiltMethodByStaticMethod(MySqlFunctions .class);
```

- 这样就可以在TinyScript脚本中使用这个内建函数了
- 例如

```xml

<lang-eval-ts>
    v_sql=null;
    v_sql=ifnull(${v_sql},"");
</lang-eval-ts>
```

#### 10.1.2 TinyScript默认内建函数

- 除此之外，TinyScript默认就将一部分Java类函数注册为内建函数了
- 具体可以查看如下的位置
- 静态构造代码块

```java
public class TinyScript {
    static {
        // 静态构造代码块
    }
}
```

#### 10.1.3 Jdbc-Procedure集成内建函数

- 当然，因为TinyScript被Jdbc-Procedure集成了
- 因此也可以使用集成的方式
- 这种方式，不但TinyScript可以进行使用
- 在lang-invoke中也可以进行使用
- 同样也是通过静态变量维护内建函数的

```java
public class ContextHolder {
    // 用于静态直接根据方法名在这个集合类中查找同名的方法，使用于LangInvokeNode中，方法需要为public的，不限制是否为static的方法
    public static final ConcurrentHashMap<String, List<IMethod>> INVOKE_METHOD_MAP = new ConcurrentHashMap<>();

}
```

- 同样通过静态方法进行注册
- 也可以支持将实例公开方法转换为实例静态方法的方法
- 将实例公开方法转换为静态方法进行注册

```java
public class ContextHolder {
    // 将所有公开方法进行注册
    public static void registryAllInvokeMethods(Class<?>... classes) {

    }

    // 将所有公开方法进行注册
    public static void registryAllInvokeMethods(Method... methods) {

    }

  // 将对象实例的公开方法转换为静态方法进行注册
  // 这样就允许将实例的公开方法思维静态方法，提供了一些非静态方法注册的可能性
  public static void registryInvokeMethodByInstanceMethod(Object object) {

  }

  // 将对象实例的公开方法转换为静态方法进行注册
  public static void registryInvokeMethodByInstanceMethod(Object object, Predicate<Method> filter) {

  }
}
```

- 默认的 Jdbc-Procedure 内建函数在 ContextFunctions 中进行定义
- 包含了一些常用的数据库函数的实现
- 另外，在 ExecutorMethodProvider 和 ExecContextMethodProvider 绑定上下文的内建函数
- 这些函数，可以在 eval-ts 中进行使用

### 10.2 拓展自己的属性修饰符feature

- 之前已经介绍过属性修饰符了
- 因为其直接作用在属性上，方便了一些场景的处理
- 因此，你也可能有需要拓展自己属性修饰符的场景
- 因为属性修饰符实际上是一个转换操作
- 所以，你只需要定义自己的转换操作函数，将他注册到环境中即可
- 注册保存位置

```java
public class ContextHolder {
    // 用于静态直接根据方法名在这个集合类中查找同名的方法，使用于BasicJdbcProcedureExecutor的Feature中，方法需要为public static的，且一个入参，具有返回值
    public static final ConcurrentHashMap<String, IMethod> CONVERT_METHOD_MAP = new ConcurrentHashMap<>();

    // 使用于BasicJdbcProcedureExecutor的Feature中
    public static final ConcurrentHashMap<String, Function> CONVERT_FUNC_MAP = new ConcurrentHashMap<>();

}
```

- 可以直接将方法或者类中的方法进行静态注册

```java
public class ContextHolder {
    public static void registryAllConvertMethods(Class<?>... classes) {
        ...
    }

    public static void registryAllConvertMethods(Method... methods) {
        ...
    }
}
```

- 这些函数需要满足以下定义

```java
public static R convert(T obj);
```

- 也就是说，需要时公开的、静态函数
- 并且需要具有一个形参和返回值
- 至于形参和返回值的类型不做要求

### 10.3 拓展自己的XML节点

- 目前内置的节点主要分为两类lang-(逻辑控制类)和sql-(数据库操作类)两类
- 如果有需求增加其他的控制，也可以编写自己的xml-node节点来处理
- 比如，想要实现命令执行的节点

#### 10.3.1 定义节点规则（非必要）

- 定义如下

```xml
<!--
执行shell命令
可以使用Script指定使用的脚本变量
如果Script没有指定脚本变量，则默认使用xml内部文本作为执行脚本
await指定是否需要等待命令执行结束
如果指定了await，则可以使用result指定接受命令执行的标准输出结果
-->
<cmd-exec script="" await="" result="">

</cmd-exec>
```

- 好了，节点的规范定义好了

#### 10.3.2 定义节点DTD语法约束（非必要）

- 那么，就可以添加对应节点定义的DTD约束了

```xml

<!ELEMENT cmd-exec (ANY|EMPTY)>
<!ATTLIST cmd-exec script CDATA #IMPLIED>
<!ATTLIST cmd-exec await CDATA #IMPLIED>
<!ATTLIST cmd-exec result CDATA #IMPLIED>
```

- 将新增加的节点加到合适的DTD节点节点中去
- 一般都是添加到根节点中去即可

```xml

<!ELEMENT procedure (
        debugger*
        |cmd-exec*
        )>
```

- 这样dtd文件规则就编写好了

#### 10.3.3 定义节点处理逻辑（必要）

- 接下来，就需要实现自己的节点处理逻辑了
- 首先需要实现ExecutorNode接口
- 或者继承默认的抽象类AbstractExecutorNode
- 一般选择继承抽象类，抽象类中已经提供了一些必要的逻辑
- 因此选择抽象类即可
- 编写自己的实现类

```java
public class CmdExecNode extends AbstractExecutorNode {
    @Override
    public boolean support(XmlNode node) {
        // 判断节点是否支持进行处理
        // 一般就是判断节点名称是否满足
        return false;
    }

    @Override
    public void reportGrammar(XmlNode node, Consumer<String> warnPoster) {
        // 非必要实现的
        // 用于检查节点的语法是否满足
        // 比如检查必要的节点属性是否填写
        // 属性的值是否正常等
    }

    @Override
    public void execInner(XmlNode node, Map<String, Object> context, JdbcProcedureExecutor executor) {
        // 处理你的节点逻辑
    }

}
```

- 接着，完成这个类即可
- 下面展示一般的逻辑
- 因为这个节点的定义，是没有子节点需要处理的
- 因此，就不用考虑子节点的事情了

```java
public class CmdExecNode extends AbstractExecutorNode {
    public static final String TAG_NAME = "cmd-exec";

    @Override
    public boolean support(XmlNode node) {
        return TAG_NAME.equals(node.getTagName());
    }

    @Override
    public void reportGrammar(XmlNode node, Consumer<String> warnPoster) {
        // 由于本节点，有三个属性，script/await/result
        // 都不是必须得
        // 只需要script属性有值或者body有值即可
        // 所以就检查这个即可
        String script = node.getTagAttrMap().get(AttrConsts.SCRIPT);
        String body = node.getTextBody().trim();
        if ((script == null || script.isEmpty())
                && (body.isEmpty())) {
            warnPoster.accept(TAG_NAME + " must have script attribute or not empty body");
        }
    }

    @Override
    public void execInner(XmlNode node, Map<String, Object> context, JdbcProcedureExecutor executor) {
        // 首先进行获取属性值
        String script = (String) executor.attrValue(AttrConsts.SCRIPT, FeatureConsts.VISIT, node, context);
        Boolean await = (Boolean) executor.attrValue(AttrConsts.AWAIT, FeatureConsts.BOOLEAN, node, context);
        String result = node.getTagAttrMap().get(AttrConsts.RESULT);
        String body = node.getTextBody().trim();
        if (script == null || script.isEmpty()) {
            script = body;
        }
        if (await == null) {
            await = false;
        }

        try {
            // 执行命令
            String val = execCmd(script, await);

            // 当有需要结果时，才设定结果
            if (result != null && !result.isEmpty()) {
                // 设置结果
                Object res = executor.resultValue(val, node.getAttrFeatureMap().get(AttrConsts.RESULT), node, context);
                executor.visitSet(context, result, res);
            }
        } catch (Exception e) {
            throw new ThrowSignalException(e.getMessage(), e);
        }
    }

    public static String execCmd(String cmd, boolean await) throws Exception {
        Process process = Runtime.getRuntime().exec(cmd);
        if (!await) {
            return null;
        }
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        try (InputStream is = process.getInputStream()) {
            byte[] buff = new byte[4096];
            int len = 0;
            while ((len = is.read(buff)) > 0) {
                bos.write(buff, 0, len);
            }
        }
        process.waitFor();
        // 这里可能需要根据操作系统的字符集，设置正确的字符集
        return new String(bos.toByteArray());
    }
}
```

- 接下来，就需要将这个处理节点注册到执行环境中了
- 有以下几种方式
- 方式1，直接添加到executor的初始化代码中

```java
public class BasicJdbcProcedureExecutor implements JdbcProcedureExecutor {
    public static List<ExecutorNode> defaultExecutorNodes() {
        List<ExecutorNode> ret = new ArrayList<>();
        // ... 之前的代码
        ret.add(new TextNode());
        // 添加自己的节点实现
        ret.add(new CmdExecNode());

        return ret;
    }
}
```

- 方式2，在子类实现或者直接修改添加节点

```java
public class BasicJdbcProcedureExecutor implements JdbcProcedureExecutor {
    protected void addNodes() {
        this.nodes.add(new CmdExecNode());
    }

}
```

- 方式3，通过注册为SPI对象实现
- 这种方式不需要修改源码
- 首先编写SPI配置文件到自己的resources路径中
- 获取到ExecutorNode类的完整类名
- 比如

```shell
xxx.jdbc.procedure.node.ExecutorNode
```

- 然后创建这样的路径

```shell
resources/META-INF/services/
```

- 在这个路径下新建一个和类名一致的文件
- 注意文件没有后缀，就是完整的类名

```shell
xxx.jdbc.procedure.node.ExecutorNode
```

- 完整的文件路径如下

```shell
resources/META-INF/services/xxx.jdbc.procedure.node.ExecutorNode
```

- 编辑这个文件，将需要添加的节点的完整类名都添加到这个文件中
- 每个类名独占一行
- 比如

```shell
com.test.xpro4j.node.CmdExecNode
com.test.xpro4j.node.HttpRequestNode
```

- 这样即可

### 10.4 事件系统（event）

- 在一些情况下，我们可能需要再框架的基础上，增加一些自己的处理逻辑
- 比如
- 怎么在参数Map中添加自己的固定全局参数？
- 怎么监控监控慢SQL执行？
- 怎么添加XML文件扫描后置处理？
- 怎么监控XML节点的执行过程？
- 怎么在XML节点执行时添加切面逻辑？
- 这一些列的问题，都可以通过事件系统来解决
- 事件系统介绍
- 事件系统主要为：
  - XProc4jEventHandler 事件处理器
  - XProc4jEventListener 事件监听器
  - XProc4jEvent 接口类
- 在默认的配置情况下，所有的已配置组件都公用一个 EventHandler 事件处理器
- EventHandler 主要负责以下几件事
  - event 事件的同步分发 send
  - event 事件的异步分发 publish
  - EventListener 的监听器注册
  - 主要功能就是将 XProc4jEvent 对象分发给注册到 EventHandler 中的每个 EventListener
- EventListener 主要负责以下事情
  - support 用于判断是否支持处理此类型的 event 事件
  - handle 用于处理 event 事件
    - 返回值说明
    - 一类型的事件允许多个监听器监听
    - 监听器是一个监听器列表
    - 事件将会按顺序分发给所有的监听器
    - 当某一个监听器的 handle 返回值为 true 时
    - 表示事件已被处理，不再发送给后续的监听器
    - 因此，一般情况下，理论返回值都是false
- 现在，来说说之前的问题都是怎么解决的
- 因为是在spring环境中，因此，监听器只需要注册为spring的bean即可
- 也就是通过@Component注解标识类即可
- 一般监听器就是这样写的

```java
@Component
public class PreparedParamsEventListener implements XProc4jEventListener {

    @Override
    public boolean support(XProc4jEvent event) {
        return event instanceof PreparedParamsEvent;
    }

    @Override
    public boolean handle(XProc4jEvent event) {
        PreparedParamsEvent evt = (PreparedParamsEvent) event;
        // 此处是你的自定义逻辑
        return false;
    }
}
```

- 怎么在参数Map中添加自己的固定全局参数？
  - 可以添加监听器监听 PreparedParamsEvent
- 怎么监控监控慢SQL执行？
  - 可以添加监听器监听 SlowSqlEvent
- 怎么添加XML文件扫描后置处理？
  - 可以添加监听器监听 JdbcProcedureMetaMapRefreshedEvent
- 怎么监控XML节点的执行过程？
  - 可以添加监听器监听 XmlNodeExecEvent
- 怎么在XML节点执行时添加切面逻辑？
  - 可以添加监听器监听 XmlNodeExecEvent
  - 因为，在 XmlNodeExecEvent 中定义了 type 属性，说明了是切名的那个周期 BEFORE/AFTER/THROWING/FINALLY
  - 同时提供了一个关联切面的Map对象 pointContext
  - 这个 pointContext 贯穿了一次执行的全周期
  - 具体可以查看源码 AbstractExecutorNode
- 需要注意的点是，事件系统区分了同步事件和异步事件
- 同步事件是直接阻塞源代码执行的，属于直接调用
- 异步事件是通过异步队列处理的，属于消息通知
- 因此，要正确使用事件监听与处理逻辑
- 具体通过查看源码，已确定是否是同步事件
- 另外，事件的发送，会根据实际需要，慢慢迭代添加一些事件

### 10.5 IDEA(Jetbrains 系列IDE)插件支持

- jdbc-procedure-plugin(或 xproc4j-plugin) 是针对 xproc4j 框架开发的一款适用于 Jetbrains 系列IDE的插件
- 能够提供语法高亮和部分语法的自动补全提示
- 插件设计的初衷
  - 由于 xproc4j 框架是基于 XML 文件进行的语法拓展的脚本式解释执行框架
  - 但是，由于默认是XML结果，导致在没有插件的情况下，仅依靠DTD对XML标签进行规范描述的情况下
  - 不能对内嵌的SQL语句、脚本语言提供语法高亮和自动补全的能力
  - 导致对于开发人员来说并不友好
  - 对于编写和检查都带来一定的困扰
  - 插件的主要目的就是为了解决这种情况而设计的
  - 虽然，插件能够提供一部分能力，但是目前的插件并不能做到完全覆盖的场景
  - 只针对大多数的情况予以支持
  - 提供尽可能完善的语法高亮和补全能力
- 插件的功能
  - 目前提供的功能如下
  - SQL高亮，根据IDEA数据源自动补全
  - TinyScript语法高亮
  - 上下文参数自动提示
  - 跳转到过程定义
  - 右键菜单跳转到内建函数定义
  - 创建XML模板文件
  - 其他功能敬请期待
- 插件的安装
- 插件以jar包的形式提供

```shell
jdbc-procedure-plugin-1.0.jar
```

- 或者改为其他名字

```shell
xproc4j-plugin-1.0.jar
```

- 因为插件是基于Jetbrains系列的IDE框架进行开发的
- 因此，使用于大部分的Jetbrains系列的IDE
- 包括但不限于：IDEA(Java),WebStrom(Web),CLion(C/C++),DataGrip(Database)
- 安装步骤
- Menus -> Settings -> Plugin -> Setting(Icon) -> Install From Local Disk ... -> Choice this jar file
- 菜单 -》设置 -》 插件 -》 设置（图标） -》 从本地磁盘安装。。。 -》 选择此jar包文件
- 暗转完成后，在已安装的插件中搜索(procedure或xproc4j)看到插件即可
- 在项目中新建一个XML文件

```shell
test.xml
```

- 文件内容为

```xml
<!DOCTYPE procedure SYSTEM "procedure.dtd">

<procedure id="test">
    <lang-eval-java>
      Date now=new Date();
      return now;
    </lang-eval-java>
    <sql-query-object>
      select sysdate from dual
    </sql-query-object>
    <lang-eval-ts>
      v_cnt=0;
      v_cnt=${v_cnt}+1;
    </lang-eval-ts>
</procedure>
```

- 能够看到语法正常高亮即可
- 也就是关键字的语法高亮正常即可

### 10.6 调试XML过程

- 由于是对XML过程进行解析执行
- IDE自带的调试功能是对Java代码进行调试的
- 这带来了一定的麻烦和困扰
- 但是，也并不是说调试非常困难和麻烦
- 以上面的插件中的过程 test.xml 为例进行调试
- 因为 test.xml 中的 procedure 根节点的 id 为 test
- 所以过程的名称就是 test
- 首先，在Java代码中调用此过程

```java
import ....springboot.jdbc.bql.procedure.JdbcProcedureHelper;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Component
public class TestDemo implements ApplicationRunner {

  @Override
  public void run(ApplicationArguments args) throws Exception {
    Map<String, Object> ret = JdbcProcedureHelper.call("test", new HashMap<>());
    System.out.println("ok");
  }
}
```

- 以上就是调试的入口代码
- 这里借用 springboot 框架的 ApplicationRunner 来达到在项目启动时执行的目的
- 这样在项目启动时，就会执行到代码
- 执行的代码只有一句 JdbcProcedureHelper.call()
- 这是在于 springboot 框架集成之后提供的静态方法调用
- 当然也可以通过 @Autowired 注入 JdbcProcedureExecutor 对象，调用 call 方法
- 这是一样的
- 那么，就可以进行运行了
- 为了更好地观测运行是的历史情况
- 建议开启以下配置

```yaml
xproc4j:
  debug: true
```

- 这样，将会打印一些日志，辅助调试
- 但是，调试的目的是为了观测运行过程中的运行堆栈和变量值
- 已确定运行状态是否正常
- 因此，断点调试是一个常用的手段
- 但是 XML 文件不支持打断点（以后插件更新，可能提供直接在XML中进行打断点的功能）
- 所以，就需要结合Java的断点调试功能来实现
- 一般情况下，只需要看运行到代码对应XML的行数即可
- 也就是，如何知道目前运行到XML的哪一行了
- 这有两种方式
- 第一种，直接对源码的 AbstractExecutorNode.exec 方法进行断点即可
- 此方法内部，具有一个location变量
- 记录了当前即将运行的XML文件名和行号
- 当然，也可以通过入参的 XmlNode 参数获取文件名和行号
- 第二种，通过同步事件监听器，监听 XmlNodeExecEvent 事件
- 这样，也能够得到当前即将运行的位置
- 条件断点，这是一个比较常用的技巧
- 因为，一般过程都比较长，嵌套调用更是比较常见
- 那么就可以基于上述两种方法，进行在断点上添加条件
- 下面举例一个条件

```java
location.startsWith("test.xml:5")
```

- 这样就能够得到条件在执行到 test.xml 的第5行的时候进行断点
- 这里第5行，也就是 sql-query-object 标签执行的时候进行断点
- 需要注意的是，行号并不是任意一行都行
- 可行的行号是XML开始标签所在的行才行
- 举个例子进行说明

```xml
<!DOCTYPE procedure SYSTEM "procedure.dtd">

<procedure id="test"> <!-- 可断点 -->
    <lang-eval-java> <!-- 可断点 -->
      Date now=new Date();
      return now;
    </lang-eval-java>
    <sql-query-object> <!-- 可断点 -->
      select sysdate from dual
    </sql-query-object>
    <lang-eval-ts> <!-- 可断点 -->
      v_cnt=0;
      v_cnt=${v_cnt}+1;
    </lang-eval-ts>
</procedure>
```

- 还有一种情况，想要从某一行开始往下继续运行的条件
- 条件断点可以这样写

```java
location.startsWith("test.xml") && && node.getLocationLineNumber()>=5
```

- 这样，便可以从第5行之后的节点执行都会进行断点
- 结合变量值断点
- 因为框架运行时，都是以一个Map对象保存所有变量的
- 因此，变量都保存在 context 这个Map里面
- 所以，可以这样写条件断点

```java
location.startsWith("test.xml:5") && context.get("v_cnt")==null
```

- 当然，因为执行提供了 executor 对象，可以使用 executor 的一些方法辅助
- 举个例子说明

```java
location.startsWith("test.xml:5") && (Integer) executor.visit("user.status",context)==1
```

- 还有一些情况，那就是接下来执行的节点可能是一段脚本
- 比如，例子中的

```xml
<lang-eval-ts>
  v_cnt=0;
  v_cnt=${v_cnt}+1;
</lang-eval-ts>
```

- 这种情况，因为内部是脚本，无法断点
- 但是可能脚本比较长
- 因此，可以使用 executor 进行辅助断点
- 举个例子说明

```java
location.startsWith("test.xml:5") && (Integer) executor.evalScript("ts","v_cnt=0;v_cnt=${v_cnt}+1;",context)==1
```

- 当然，结合IDE提供的 Evaluate Expression 能力，在合适的断点上，提前运算判断下脚本运行的结果
- 辅助判断运行情况，是更加的调试运行方式
- 到这里，你已经会调试运行框架和自己的过程XML文件了
- 最后，合理使用合适的 EventListener 监听器监听事件，可能更好地进行调试运行
- 一些比较细节的情况上，你一般需要源码调试 BasicJdbcProcedureExecutor 类
- 另外，针对一些指定类型XML节点的断点，可以直接对源码中 ExecutorNode 的实现类进行断点调试
- 针对一些低级的语法错误，请打开以下配置
- 以在项目启动后进行基础语法检查，请注意期间的 Warn 日志
- 根据 Warn 日志调试XML过程

```yaml
xproc4j:
  report-on-boot: true
  procedure-meta:
    grammar-reporter:
      enable: true
```

- 注意，由于 debug 模式对性能的影响较大，因此只建议在调试时开启
- 或者在开发/测试环境下使用
- 启动检查，也只建议在开发/测试环境使用
- 因为，会导致启动时间较长
- 当然，这个根据你的中的过程数量来决定的
- 特别是大型项目，启动时间就会更长，浪费在语法检查上

### 10.7 和其他框架集成

- 默认情况下，是和springboot框架进行了继承
- 如果需要和其他框架进行继承
- 则继承DefaultJdbcProcedureExecutor类，覆盖特定框架的特性
- 具体可以参考SpringContextJdbcProcedureExecutor的实现
- 以及SpringContextJdbcProcedureExecutorAutoConfiguration类的实现组合原理
- 这部分比较简单，不再进行展开讲解，根据源码进行查看即可

### 10.8 直接独立使用，不与springboot集成

- 这部分，请参考TestProcedureExecutor类以及所在包的测试代码
- 结合SpringContextJdbcProcedureExecutorAutoConfiguration配置
- 即可能够进行直接使用

---

**文档版本：** 1.0  
**最后更新：** 2026-04-02  
**维护者：** Ice2Faith