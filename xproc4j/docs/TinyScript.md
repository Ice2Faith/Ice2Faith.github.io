# TinyScript 表达式引擎

- 主要用于提供嵌套函数调用的功能
- 另外支持多条语句执行
- 调用返回最后一条语句执行的结果
- 基于一个根上下文进行操作

## 核心设计

- 核心使用antlr4生成与解析语法规则
- 暴露TinyScript.script()方法
- 方法声明如下

```shell
public static Object script(String formula, Object context);
```

- 函数说明
- 对formula表达式进行执行，表达式允许对context进行读取
- 最终返回最后一条formula语句执行的结果
- 同时，需要记住，formula是允许对context进行读写的
- 常见的context可能是一个Map对象或者一个普通对象

## 表达式规则

### 注释

- 注释和Java等大多数语言一样

```shell
// 单行注释
/* 多行注释 */
```

- 多行注释内部的*号需要使用\进行转义
- 这是一个特殊的地方

### 基础数据类型

- 包含，int,long，float,double,null,boolean,string基础类型
- int书写

```shell
1;
123;
0xabc;
0t754;
0b10110;
```

- 默认情况下，不带小数点的，都是int类型
- 其中0x表示16进制，0t表示8进制，0b表示2进制
- long书写

```shell
1L;
123L;
0xabcL;
0t754L;
0b10110L;
```

- long的规则和int类型基本一致，只不过在最后添加字符L，大小写均可
- double书写

```shell
1.1;
1.1e6;
```

- 默认情况下，带小数点的都是double类型
- 没有0x/0t/0b这种写法
- 支持科学计数法
- float书写

```shell
1.1F;
1.1e6F;
```

- float的规则和double类型基本一致，只不过在最后添加字符F，大小写均可
- null书写规则

```shell
null;
```

- 固定关键字，区分大小写
- boolean书写规则

```shell
true;
false;
```

- 固定两个关键字，区分大小写
- string书写规则

```shell
"aa\r\n\t \"\\bb\''"
'aa\r\n\t \'\\bb\""'
```

- 书写规则和各种语言中的基本一致，支持使用转义符号转义
- 但是支持使用单引号包含，这样能够避免在单引号中对双引号进行转义
- 模板字符串

```shell
R"abc ${count} def $${size} gh"
R'abc ${count} def $${size} gh'
```

- 书写规则和字符串一样，但是前置的双引号["]之前使用字符R引导，引导字符不区分大小写
- 其中的变量捕获，和取值语句是一样的
- 如果有${符号需要保留，可以提前将这两字符拿出来，作为一个捕获变量
- 同样支持使用单引号包含，也是为了方便，避免对双引号转义
- 多行字符串

```shell
\```trim.align.render
  | 123
  |     456\`  \`` \```
  |  789 ${count}
\```

"""trim.align.render
  | 123
  |     456\"  \"" \"""
  |  789 ${count}
"""
```

- 用法使用三个连续的反引号[`]包含
- 如果内部有反引号[`]，则需要使用[\\]进行转义
- 所表示的内容不包含开始引导符与结束引导符所在的行
- 也就是说，首行和尾行不算在内的
- 并且首行和尾行只允许有空白符，不能出现其他字符
- 当然，首行允许带有特性
- 开头的引导符号之后可以紧跟着几个特性
    - trim 进行trim
    - align 表示只保留每行的第一个[|]符号之后的内容，可用于保持对其，缺点就是每行都需要这个引导符号
    - render 表示要进行模板字符串渲染
    - 特性之间通过[.]符号分割连接，特性从左至右依次执行
    - 也就是说，允许重复使用特性
    - 例如：trim.render.trim
- 除此之外，也支持使用三个连续双引号["]包含
- 这个目的也是为了避免转义

- class书写规则
- 用于表示Class类型
- 定义

```shell
类名.class
```

- 示例

```shell
int.class;
string.class;
java.util.Map.class;
```

- 部分基础类型和jdk类可使用简短类名
- 否则应该使用全限定类名

### 复杂数据类型

- 支持JSON数据类型
- 使用上和JSON的规则差不多
- 但是融合了脚本语言的特性
- 实际上，内部将会转换为LinkedHashMap和ArrayList对象
- 直接看例子

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

- 从这个例子中，便可以看到
- 大体和JSON类似
- 但是具有一些JS构建对象的便利性
- 可以使用函数调用decode
- 可以不用引号包含键名name/roles
- 可以使用${}从环境中取值

## 语法介绍

### 语句分隔
- 表达式允许有多条语句，语句之间使用分号[;]分隔
- 例如

```shell
1;
2.15;
true;
"hello"
```

### 取值语句
- 表达式使用${}来访问context中的值
- 定义

```shell
${要访问的变量路径}
```

- 例如：

```shell
${user.name}
${user.roles[0].name}
```

- 使用于字符串拼接场景的特殊取值语句
- 定义

```shell
$!{要访问的变量路径}
```

- 含义，如果取到的变量值为null，则返回空字符串'',而不是null
- 这样可以方便在字符串拼接或者模板字符串中进行非空判断的渲染
- 举例

```shell
'username:'+$!{user.nickName};
R"age: $!{user.age}";
```

### 赋值语句
- 修改context里面的值，通过赋值语句修改
- 定义

```shell
修改或保存的变量路径 = 变量值
修改或保存的变量路径 += 变量值
修改或保存的变量路径 -= 变量值
修改或保存的变量路径 *= 变量值
修改或保存的变量路径 /= 变量值
修改或保存的变量路径 %= 变量值
修改或保存的变量路径 ?= 变量值
修改或保存的变量路径 .= 变量值
```

- 解释
```shell
= 直接赋值，普通赋值语句
+=，-=，*=，/=，%=和其他语言中一样，都是 a+=b 等价于 a=a+b
?= 空复制语句，只有左侧值为空时，才将右侧的值进行赋值，等价于 if(a==null){a=b;};
.= 替换赋值语句，只有左侧值非空时，才将右侧的值进行赋值，等价于 if(a!=null){a=b;};
```

- 举例

```shell
name = "zhang";
age = 12;
role = {
  name: "root",
  id: 123L
};
status= ${config.user.defaultStatus};
user.roles[1].name="logger";

cnt+=1;
cnt-=1;
cnt*=2;
cnt/=2;
cnt%=10;
```

### 解包语句

- 用于对对象进行解包
- 属于赋值语句的一种特例
- 在返回值为一个复杂数据结构时，有时候为了方便，需要再次从这个复杂对象中提取值出来计算
- 解包语句就将赋值和解包同时结合
- 定义

```shell
#{解包键值对}= 变量值
```

- 举例

```shell
#{name:userName,age:userInfo.age,status}=getUserInfo();
```

- 举例中，已经完全表达了解包语法
- 等号左边为解包语句
- 等号右边为目标值
- 那么这个例子的等价写法如下

```shell
tmp=getUserInfo();
name=${tmp.userName};
age=${tmp.userInfo.age};
status=${tmp.status};
```

- 可以看到，使用解包语法之后
- 可以将多个赋值语句给整合到一起
- 但是也有缺点，如果不提前保存原始返回对象的话
- 就丢失了原始对象
- 如果同时要保留原始对象
- 则，需要两个语句来实现
- 如下

```shell
tmp=getUserInfo();
#{name:userName,age:userInfo.age,status}=${tmp};
```

- 这样就可以实现同时保存变量了

### 括号表达式
- 定义

```shell
(...)
```

- 举例

```shell
1+(1+1);
1+(2-${cnt});
```

### 前置操作符表达式
- 定义

```shell
操作符 表达式
```

- 操作符说明

```shell
! 取反
not 取反
- 取负数,由于可能和其他操作符发生结合性问题，如果在复杂的表达式中使用，请使用括号包裹
```

- 举例

```shell
!${flag};
not ${flag};
-1;
-${cnt};
```

### 后置操作符表达式
- 定义

```shell
表达式 操作符
```

- 操作符说明

```shell
% 百分数
```

- 举例

```shell
15%;
${per}%;
```

### 三元运算符表达式
- 定义

```shell
表达式 ? 表达式 : 表达式
```

- 和JAVA中一样
- 但是，返回的两个可选值，不要求是同类型的数据，不做这个限制
- 同时条件表达式也是宽泛值，不要求是严格的boolean类型

- 举例

```shell
${cnt}>1?"ok":null;
loginStatus=${user}?1:0;
```

### 中括号取值表达式
- 定义

```shell
左表达式 [ 右表达式 ]
```

- 和JAVA中一样
- 但是表达式的约束是宽泛的
- 左表达式可以是 数组Array，集合Iterable，列表List，映射Map，对象Object
- 右表达式根据左表达式而定，常见的就是 可以转换为Integer的值和String数值类型

- 举例

```shell
// 可以对普通对象Object操作，中括号中会被强制转换为 String 作为属性名
// 访问对象，通过对象名，等价于 ${user.name}
${user}["name"];

// 通过变量访问对象，这里实际上还是等价于 ${user.name}
v_prop='name';
${user}[${v_prop]}];

// 可以对Map类型操作，中括号中的就是 key
${map}[1];
${map}['age'];

// 可以对数组Array，集合Iterable，列表List操作，中括号中的需要时可转换为Integer的下标
${list}[1];
${arr}[2];
v_index=3;
${iter}[${v_index}];
```

### 逗号表达式

- 因为脚本的性质，实际上并不需要逗号表达式
- 如果你确实需要类似逗号表达式的功能
- 其实可以使用一个语句块代替
- 因为脚本运行始终返回最后执行的一条语句的结果
- 所以，当一个语句块执行时，默认就是返回最后一条语句执行的结果的
- 另外，语句块的最后一个语句允许不带分好结束

```shell
{语句; 语句; ...}
```

- 和JAVA中一样
- 但是，使用分好分隔，返回最后一个语句执行的值，作为此代码块的返回值

- 举例

```shell
m={ ${a}+1; ${b}-1; ${a}+${b} };
// 等价依次执行
// ${a}+1; 
// ${b}-1; 
// m=${a}+${b};

a={1;2;3 };
// 等价依次执行
// 1;
// 2;
// a=3;
```

### 管道函数调用链表达式

- 定义

```shell
初始表达式 |> 管道函数 |> 管道函数 ...
```

- 管道函数定义

```shell
// 普通管道函数
函数名称(形式参数列表)
// 例如
trim()
// 实际调用的时候，将管道之前作为第一个参数，也就是等价于这样调用
trim(前一个值)
// 又比如
substr(0,1)
// 实际调用
substr(前一个值,0,1)

// 静态管道函数
类名.函数名称(形式参数列表)
// 例如
String.valueOf()
// 实际调用
String.valueOf(前一个值)

// 自身调用形式管道函数，需要使用 :: 符号作为前置引导符
:: 函数名称(形式参数列表)
// 例如
::getName()
// 实际调用 
前一个值.getName()

```

- 管道函数表达式，是一种语法糖，现代编程语言中开始使用
- 目的是为了解决函数嵌套调用带来的括号嵌套地狱问题
- 逻辑就是
- 将管道之前的值作为管道函数的第一个参数进行函数调用

- 举例

```shell
// 嵌套调用的时候这样写
substr(trim(a.user().name()),0,2);

// 转换为管道函数链之后这样写，达到的效果是一样的
${a}
|> ::user()
|> ::name()
|> trim()
|> substr(0, 2);

// 当然，写成一行也是可以的
${a} |> ::user() |> ::name() |> trim() |> substr(0, 2);

// 嵌套管道案例
// 一般写法
// substr(${fileName},1,${fileName}.lastIndexOf("."))
// 管道形式
${fileName}
|> substr(0,
    ${fileName} |> ::lastIndexOf(".")
    )
;
```

### 创建对象
- 定义

```shell
new 类名(参数列表)
```

- 一些常用的类名可以不写完整的全限定类名
- 例如java.lang/java.util/java.time等包下面的
- 可以直接写简短类名，例如Date
- 举例

```shell
new String("xxx");
new Date();
new org.apache.User(1L,"xxx",${status},decode(${str},"是",1,0));
```

### 函数调用
- 函数名需要携带类名，也就是全限定函数名
- 一些常用的类名可以不写完整的类名，同创建对象时的类名
- 不过，有一些情况下，用户可以定义自己的内建函数
- 这种函数只需要写函数名即可
- 内建函数需要用户自己注册到TinyScript.BUILTIN_METHOD中
- 这是一个静态变量，向其中添加即可
- 通过调用TinyScript.registryBuiltinMethod(Method)方法实现
- 默认情况下，具有一些内建函数，在String类的join/format方法，Integer/Long/Float/Double/Boolean类的parse/to开头的方法
- 定义

```shell
函数名(参数列表)
```

- 举例

```shell
String.valueOf(1);
org.apache.Test.run("xxx",true);
```

- 函数支持链式调用
- 和java链式调用一致
- 举例

```shell
String.valueOf(1).repeat(2).length();
```

- 可以在值上面调用函数

```shell
${user}.getName().length();
```

### 双目运算符
- 也就是需要两个运算参数左值和右值，中间是操作符的表达式
- 常见的例如加减乘除
- 定义

```shell
表达式 运算符 表达式
```

- 运算符含义说明

```shell
>= 大于等于
gte 大于等于
<= 小于等于
lte 小于等于
!= 不等于
ne 不等于
<> 不等于
neq 不等于
== 相等
eq 相等
> 大于
gt 大于 
< 小于
lt 小于
in 元素在其中
notin 元素不在其中
&& 逻辑与
and 逻辑与
|| 逻辑或
or 逻辑或
as 类型转换运算符，前面的值转换为后面的值类型
  定义：值 as (值|class)
  例如：${str} as int.class;${str} as ${cnt};
  注意：左边为null,则允许直接转换；右边为null，则抛出类转换异常；不能转换，则抛出类转换异常
cast 用法和as一样，是as的别名
is 类型判断运算符，前面的值是否是后面的值的类型，
  定义：值 is (值|class)
  例如：${str} is string.class;${str} is ${name};${obj}.getClass() is string.class;
  注意：前后任意值为null,结果都为false
instanceof 用法和is一样，是is的别名
typeof 用法和is一样，是is的别名
+ 加
- 减
* 乘
/ 除
% 取模，结果一定是int
```

- 举例

```shell
1>2;
"xxx"+1;
```

### 静态变量/枚举值访问与赋值

- 定义

```shell
@类名.变量名
类名@变量名
```

- 举例

```shell
// 访问静态变量
@java.sql.Types.VARCHAR;
java.sql.Types@VARCHAR;
// 访问枚举值
@java.sql.JDBCType.VARCHAR;
java.sql.JDBCType@VARCHAR;
// 赋值静态变量
// 虽然语法上不限制对枚举值进行复制，但是这样的操作实际上是不可行的
// 因为枚举值不能够被赋值
@DatabaseTypeHolder.TYPE=@DatabaseType.MYSQL;
```

### if-else条件语句
- 定义

```shell
if(条件表达式){
  语句块
} else if(条件表达式){
  语句块
} else {
  语句块
};
```

- 其中 else if 可以运行使用别名 elif
- 也就是允许这样写
```shell
if(条件表达式){
  语句块
} else if(条件表达式){
  语句块
} elif(条件表达式){
  语句块
} else {
  语句块
};
```

- 用法和Java中类似
- 条件语句块比较特殊，不一样需要时boolean值
- 内部会自动转换为boolean值
- 比如，null空值,""空字符串,{}空Map,[]空Collection都认为是false
- 需要注意的是，if语句也算是一条语句，因此最后需要添加分号[;]结尾
- 举例

```shell
if(${num}>0){
    ok=1;
}else if(${role}){
    ok=2;
}else{
    ok=3;
};
```

### foreach循环语句
- 定义

```shell
foreach(迭代变量名 : 被迭代值){
  迭代循环体
};
```

- 用法和Java中类似
- 需要注意的是，foreach语句也算是一条语句，因此最后需要添加分号[;]结尾
- 举例

```shell
sum=0;
foreach(item : [1,2,3,4,5]){
  sum=${sum}+${item};
};
foreach(item : ${arr}){
  if(${arr}==null){
    continue;
  };
  sum=${sum}+${item};
  if(${sum}>10){
    break;
  };
};
${sum};
```

- 在这个例子中,介绍了大多数情况下foreach语句的使用场景
- 包含直接使用立即值[1,2,3,4,5]进行迭代和使用引用值${arr}进行迭代
- 同时演示了结合if进行continue和break控制的场景

### for循环语句
- 定义

```shell
for(初始化语句 ; 条件语句 ; 增量语句){
  循环体
};
```

- 和Java中常用的for-i循环的结构一致
- 需要注意的是，for语句也算是一条语句，因此最后需要添加分号[;]结尾
- 举例

```shell
sum=0;
for(i=0;${i}<10;i=${i}+1){
  if(${i}%2==0){
    sum=${sum}+${i};
  };
};
${sum};
```

- 在这个例子中，就展示了和Java中对应的for-i循环的使用方法

### while循环语句
- 定义

```shell
while(条件语句){
  循环体
};
```

- 和Java中的while循环的结构一致
- 需要注意的是，while语句也算是一条语句，因此最后需要添加分号[;]结尾
- 举例

```shell
sum=0;
i=0;
while(${i}<10){
  if(${i}%2==0){
    sum=${sum}+${i};
  };
  i=${i}+1;
};
${sum};
```

- 在这个例子中，就展示了while循环的使用方法

### do-while循环语句
- 定义

```shell
do{
  循环体
}while(条件语句);
```

- 和Java中的do-while循环的结构一致
- 需要注意的是，do-while语句也算是一条语句，因此最后需要添加分号[;]结尾
- 举例

```shell
sum=0;
i=0;
do{
  if(${i}%2==0){
    sum=${sum}+${i};
  };
  i=${i}+1;
}while(${i}<10);
${sum};
```

- 在这个例子中，就展示了while循环的使用方法

### return语句
- 定义

```shell
return;
return 变量;
```

- return语句可以不返回值，也可以返回一个值
- 区别，不带返回值，则整个脚本的返回值为null
- 带了返回值，则整个脚本的返回值为被返回的值
- 举例

```shell
return;
return 1;
return ${sum};
```

### break/continue语句
- 用于在循环(foreach/for/while)中进行控制
- 属于关键字
- 定义

```shell
break;
continue;
```

### try语句
- 和Java中使用方式一样
- 需要注意的是，try语句也算是一条语句，因此最后需要添加分号[;]结尾

```shell
try{
  语句块
} catch(捕获类型 捕获变量){
  语句块
} finally {
  语句块
};
```

- 举例

```shell
try{
  null;
}catch(NullPointerException|SQLException e){
  null;
}finally{
  null;
};
```

### throw 语句
- 和JAVA中使用方式一样
- 需要注意的是，抛出的对象，如果是引用对象的话，需要使用${}进行引用

```shell
throw 抛出表达式;
```

- 举例

```shell
throw new Throwable("xxx");

try{
  cnt=1/0;
}catch(Throwable e){
  throw new RuntimeException(${e}.getMessage(),${e});
  // throw ${e};
};
```

### debugger 调试语法
- 调试语法，用于帮助进行断点调试的
- 需要结合集成开发环境的断点调试功能共同使用
- 定义
```shell
debugger 断点标签 (断点条件);
```
- 说明，断点标签必须是一个满足Java类型格式的名称，也就是字母数字下划线组成，可分多段用.分隔
- 断点条件是可选的，没有断点条件时，断点条件所携带的括号也不要有
- 举例
```shell
debugger;
debugger entry1;
debugger (${count}==null);
debugger user.loop (${item}==null);
```
- 配合IDE进行断点调试
- 推荐对 DefaultTinyScriptResolver.openDebugger 方法添加断点
- 也可以对 TinyScriptVisitorImpl.visitDebuggerSegment 方法添加断点


### 具名参数函数
- 和常规函数调用一样，只不过，这种调用，适用于一些特殊的场景
- 常常将参数名和值最终合并为一个Map对象调用目标方法
- 定义

```shell
函数名(具名参数列表)
```

- 具名参数定义

```shell
参数名 : 参数值
```

- 举例

```shell
render(str: "123",regex:"\\d+",replacement:"true")
```

- 这种，一般适用于这样的转换目标函数

```shell
Object render(Map<String,Object> params);
params.put("str","123");
params.put("regex","\\d+");
params.put("replacement","true");
```

- 或者也可以用于一些自定义参数，却不是Java类函数的场景中
- 总之，适用于需要自己解析这样的Map作为函数参数的场景
- DefaultTinyScriptResolver.beforeFunctionCall
- 根据需要重写此函数
- 使用Reference.of()方法正确的返回值，如果处理不了
- 则使用Reference.nop()表示无法处理

### 内建函数
- 内建函数，也就是自带的函数
- eval函数
- 用于将内部的字符看做TinyScript脚本进行运行
- 运行时共享内部的上下文
- 定义
- 函数名：eval
- 返回值：Object
- 参数：String|Appendable|CharSequence|StringBuilder|StringBuffer 总之就是字符串兼容类型
```shell
Object eval(String|Appendable|CharSequence|StringBuilder|StringBuffer script)
```
- 其他内建函数
- 详情查阅源码类的静态构造代码块
```java
public class TinyScript{
    static{
        // 此处的内建函数
    }
}
```
- 你也可以参照此方式注册内建函数

### 用户自定义函数

- 像大多数脚本语言一样，同样支持自定义函数
- 区别于内建函数或者注册的方式
- 允许用户直接在脚本中定义函数
- 语法规定

```shell
func 函数名(参数名列表){
  函数体
};
```

- 固定以 func 开头定义一个函数
- 后跟着函数名，满足标识符即可
- 函数参数列表，因为脚本中没有那么明确的类型要求
- 因此，参数列表变为参数名列表，不再需要类型声明
- 函数体，和if等的代码块一样
- 同时，一个函数定义也是一个语句，因此最后也和if等一样，需要使用分好分割
- 举例说明

```shell
v_num=5;
func factor(in_num,in_level){
    println('level='+${in_level});
    if(${in_num}<=1){
        println('v_num='+${global.v_num});
        return 1;
    };
    return ${in_num}*factor(${in_num}-1,${in_level}+1);
};
v_ret=factor(${v_num},0);
${v_ret};
```

- 在这个例子中，以计算阶乘为例进行了说明
- 函数名为 factor
- 参数列表接受两个参数，形参名称为：in_num 和 in_level 的两个参数
- 函数体内部简单写了一下阶乘的逻辑，尽管不严谨，但是足够说明使用方式了
- 最后，直接调用了 factor 函数，传入两个实参
- 注意事项
- 因为需要考虑函数独立的作用域
- 因此，进入函数执行就会开辟一块独立的上下文空间进行执行
- 在上面的例子中，进入函数后，只会有两个形参的参数，不会具有默认的全局上下文中的参数
- 但是，为了提供在函数内部使用默认全局上下文的能力
- 所以，在函数内部的时候，可以通过 global 变量访问到默认的全局上下文
- 因此，在上面的例子中，函数内无法直接访问到全局的 v_num 变量
- 如果要访问这个全局变量，则可以通过 global.v_num 进行访问
- 这个 global 变量无论内部函数递归了多少层次，始终都会死最外层的全局上下文参数
- 虽然，提供了自定义函数的能力，但是自定义函数目前的能力有限
- 有特殊需求的情况下，使用注册内建函数的方式会更加灵活

## 拓展点

### 自定义处理器 TinyScriptResolver
- 如果想要修改一些默认的行为，包括调用一些特殊场景的函数，结合其他框架使用
- 都可以实现自己的 TinyScriptResolver 
- 但是，一般来说，你只需要继承 DefaultTinyScriptResolver 默认实现类
- 修改你的特定逻辑即可
- 然后使用你自己的 resolver 进行脚本解析执行即可
- 举个例子来说
- 比如，你想要和Spring框架结合
- 使用一些Spring框架提供的能力
- 那么，你可以实现一个自己的 resolver
- 比如：SpringApplicationContextTinyScriptResolver
- 然后，根据自己的实现，使用这个resolver即可
- 下面是示例调用代码
```java
public static Object evalTinyScript(String script, Object context,ApplicationContext applicationContext) {

  Object obj = null;

  try {
    TinyScriptResolver resolver = new SpringApplicationContextTinyScriptResolver(applicationContext);
    obj = TinyScript.script(script, context, resolver);
  } catch (Exception e) {
    throw new IllegalStateException(e.getMessage(), e);
  }
  return obj;
}
```

## 特别注意

- 本脚本不支持自然意义上的数学运算优先级
- 也就是先乘除后加减的规则，以及从左向右计算的规则
- 如果涉及到这种情况，请使用括号表达式进行限制运算顺序

## 综合使用案例

- 简单用法示例

```shell
num=1+1.125;
num2=${num}+10L;
tmp=new String("@@@");
str=${str}+1;
sadd=${str};
svl=String.valueOf(1L);
slen=${str}.length();
srptlen=${str}.repeat(2).length();

complex=[{
 username: "123",
 roles: ["admin","log"],
 status: true,
 age: 12,
 image: ${str},
 len: String.length(),
 token: null
}];

streq=${str}==${sadd};
strneq=${str}==${tmp};
numeeq=${num}>=${slen};

if(${num}>4){
    ok=3;
}else if(${num}>3){
    ok=2;
}else{
    ok=1;
};

```

- 运行输入上下文，准备参数如下

```java
Map<String, Object> context = new HashMap<>();
context.put("str", "1,2,3 4-5-6  7  8  9");
Object ret = TinyScript.script(formula, context);
System.out.println(ret);
System.out.println(context);
```

- 运行输出结果如下

```shell
1
{num=2.125, srptlen=42, svl=1, str=1,2,3 4-5-6  7  8  91, numeeq=false, tmp=@@@, streq=true, slen=21, complex=[{username=123, roles=[admin, log], status=true, age=12, image=1,2,3 4-5-6  7  8  91, len=0, token=null}], sadd=1,2,3 4-5-6  7  8  91, strneq=false, ok=1, num2=12.125}

```

- 复杂使用案例
    - 此案例仅说明复杂的场景，不具有实际运行性

```shell
user.status=new BigDecimal(${role.perm}.lrtim(Func.rtrim(replace(${user.name}.isEmpty("user",true).length().size(),"s+",12.125f,0x56l,0t27,0b101L,true),";"),",")).intValue();
```