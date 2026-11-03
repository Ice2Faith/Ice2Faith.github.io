# Antlr4 语法生成辅助工具

- antlr4 是一个使用Java实现的词法语法分析生成辅助工具
- 可用于实现自定义的词法分析、语法分析、实现左递归的语法分析、上下文无关的文法
- 达到实现自定义表达式解析执行、自定义语言 DSL（Domain-Special Language）
- 其支持使用类似编译原理中的词法、语法的文法定义语言规则
- 支持输出多种的目标语言的 parser 生成，包括 java/python/js 等

## 1. 安装

- 因为其使用 Java 实现，所以实际上就是一个 jar 依赖包
- 包含开发包与运行时
- 开发包用于生成 parser 语法解析器
- 运行时用于解析运行自定义 DSL 的支撑
- 一般直接在 IDEA 中安装 antlr4 插件即可
- 或者到官网下载独立的安装包运行
- 下面直接说在IDEA 中使用 antlr4
- 插件安装之后
- 主要使用的是其提供的 antlr4 preview 能力
    - 也就是提供了对自定义的文法的可视化 AST 抽象语法树的展示
    - 用于辅助检查文法是否满足设计的意图
    - 以及辅助检查文法定义的错误等
- 另外，就是其提供的 parser 文法解析器生成
    - 也就是提供生成目标语言实现的 parser 语言结构
    - 这样基于生成的结构补充完整自己的语义实现
    - 实现完整的一个自定义的 DSL

## 2. 文法规则文件 (.g4)

- 核心就是使用一个 .g4 文件
- 定义自己的语法规则
- 从而达成自己的DSL设计目标

## 3. 创建文件

- 直接在IDEA中创建一个 .g4 文件
- 例如：Demo.g4

## 4. 组成部分

- 语法单元
    - 文法定义（语法定义）
        - 也就是定义一个名称用来代表这个文法
    - 词法定义
        - 也就是定义词法，即终结符，不可再分的基础词法单元
        - 在Antlr4中，词法名称使用全大写表示
        - 使用：
            - 词法名称: 词法表达式;
        - 形式表示
    - 语法定义
        - 也就是定义语法，即非终结符，词法的构成规则形式
        - 在Antlr4中，语法规则使用驼峰表示
        - 使用：
            - 语法名称: 语法表达式;
        - 形式表示
- 文件内容总体结构

```antlrv4
// 语法定义
grammar Demo;

// 词法定义
DIGIT: [0-9];

// 语法定义
expr:
    DIGIT;
    

```

## 5. 文法定义

- 注意，文法名称必须和文件名一致
    - 没加任何前缀，就表示词法分析、语法分析都进行
    - 大多数情况都是这样使用的

```shell
grammar Demo;
```

- 如果是，只需要词法分析，则可以添加 lexer 前缀，表示词法分析器

```antlrv4
lexer grammar Demo;
```

- 如果是，只需要语法分析，则可以添加 parser 前缀，表示语法分析器

```antlrv4
parser grammar Demo;
```

## 6. 总体规则

- 规范规则
    - `?` 用于表示可选终结符
    - `*` 用于表示0到多个
    - `+` 用于表示1到多个
    - `()` 用于表示组，将多个终结符看做一个整体
    - `|` 用于表示在同一组内多选一的关系
- 优先级规则：
    - 贪心匹配优先，即尽最大能力匹配最长的规则
    - 先定义先优先，即先匹配先定义的规则，也就是前面定义的优先匹配

## 7. 词法定义

- 词法规则
    - 词法名称，使用全大写表示
    - 其规则，则使用单引号包裹的终结符，或者类regexp正则的形式定义
    - 总体上，和词法规范文法类似
    - 只不过，regexp 是不完整的，比如 `\d\s` 这种是不行的
- 基础规则：
    - `[]` 和regexp正则基本一致，用于表示多选一
    - `''` 用于表示一个整体的终结符
    - 以及总体的规范文法规则

### 7.1. 普通规则

- 定义一个0-9的字符集，用于复用

```antlrv4
grammar Demo;

DIGIT: [0-9];
```

- 定义一个不区分大小写的英文字母集合

```antlrv4
grammar Demo;

WORD: [a-zA-Z];
```

- 定义一个不区分大小写的字符 l

```antlrv4
grammar Demo;

L: [lL];
```

- 定义一个不区分大小写的字符 x
- 且，其不作为终结符，不参与词法分析，只辅助编写文法
- 就需要添加 fragment 前缀

```antlrv4
grammar Demo;

fragment X: [xX];
```

- 定义一个固定的序列，一般用作关键字
- 这里就定义了 boolean 类型的字面量表达

```antlrv4
grammar Demo;

BOOLEAN: 'true'|'false';
```

### 7.2. 复合规则

- 定义一个整形数值
    - 其允许 0x 开头表示十六进制
    - 允许 0 开头表示八进制
    - 允许 l 结尾表示是 long 类型
    - 数值部分，要求必须是单个数字0-9
    - 或者，是以1-9非零开头的多位数字
    - 分解：
        - `'0'` 就是匹配0这个字符
        - `X` 就是引用上面定义的终结符
        - `X?` 就是表示，可以没有x
        - `'0' X?` 就是表示以0开头，可能有一个x，也就是0，或0x
        - `('0' X?)?` 就是表示，可以没有这一个括号组，也就是都没有，有0，有0x
        - `DIGIT` 下面定义了，是0-9的数字
        - `DIGIT+` 就表示，至少有一位数字
        - `[1-9] DIGIT+` 就表示，第一位不为0，且至少两位，第二位开始可以是0
        - `DIGIT| [1-9] DIGIT+` 就表示，要么是0-9的个位数，要么就是非0开头的多位数
        - `(DIGIT| [1-9] DIGIT+)` 就表示，这是一组，不然|或关系就会导致语法歧义
        - `L` 就表示，不区分大小写的x
        - `L?` 就表示，可以没有l这个后缀
    - 那这个终结符 INTEGER 就可以表示如下的形式
        - 0
        - 10
        - 123
        - 1L
        - 05L
        - 0x5L

```antlrv4
grammar Demo;

INTEGER: ('0' X?)? (DIGIT| [1-9] DIGIT+) L?;

DIGIT: [0-9];

fragment L: [lL];
fragment X: [xX];
```

- 定义一个标识符
    - 即，以字母或下划线开头，后面可以跟字母、数字、下划线的标识符
    - 也就是大多数编程语言中的变量名、类名等
    - 分解：
        - `'_'` 就是匹配一个下划线
        - `WORD` 就是匹配一个字母
        - `('_' | WORD)` 就是匹配一个下划线或字母
        - `('_' | WORD | DIGIT)*` 就是匹配一个下划线或字母或数字

```antlrv4
grammar Demo;

IDENTIFIER: ('_' | WORD) ('_' | WORD | DIGIT)*;

DIGIT: [0-9];

WORD: [a-zA-Z];
```

### 7.3. 内置规则

- 跳过终结符，在词法分析阶段
    - 将这个终结符，从词法中移除，不参与到词法流中
    - 也就是会被直接忽略，在后续的语法分析阶段也就不可用
    - 常用于，空白符的跳过，大多数编程语言都是这样，空白符号都是不处理的
    - 这个时候，就使用 `-> skip` 进行表示
    - 这是 antlr4 提供的

```antlrv4
grammar Demo;

WS: [ \r\n\t] -> skip;
```

## 8. 语法定义

- 语法规则
    - 语法名称，使用驼峰表示
    - 其规则，使用递归向下的左递归的方式，组合子语法和语法分析得到的终结符
    - 构建出的语法规则
    - 总体上，和语法规范文法类似
- 基础规则：
    - 基本上就是，总体的规范文法规则

### 8.1. 基础规则

- 下面， number 规则，就是一个最基础的语法规则
- 其表示，number 是由一个 INTEGER 终结符构成的
- 也就是，表示的就是一个数值

```antlrv4
grammar Demo;

INTEGER: ('0' X?)? (DIGIT| [1-9] DIGIT+) L?;

DIGIT: [0-9];

fragment L: [lL];
fragment X: [xX];

number:
    INTEGER
;
```

### 8.2. 复合规则

- 也就是在一个规则中引用其他子规则
- 构成完整的语法定义
- 下面的 expr 就是一个两位数字的加法运算的语法

```antlrv4
grammar Demo;

INTEGER: ('0' X?)? (DIGIT| [1-9] DIGIT+) L?;

DIGIT: [0-9];

fragment L: [lL];
fragment X: [xX];

expr:
    number '+' number
;

number:
    INTEGER
;
```

- 当然，下面这种写法可不可以？
- 当然可以，但是不推荐，不便于后续实现自己的DSL语言逻辑编写
- 也就是将语法进行统一收敛，方便后续进行DSL语言的逻辑编写
- 也就是实现自己的表达式引擎
- 这里，就是要统一收敛对 INTEGER 的处理，都放到 number 的语法上去处理

```antlrv4
grammar Demo;

INTEGER: ('0' X?)? (DIGIT| [1-9] DIGIT+) L?;

DIGIT: [0-9];

fragment L: [lL];
fragment X: [xX];

expr:
    number '+' INTEGER
;

number:
    INTEGER
;
```

### 8.3. 语法全匹配

- 默认情况下，antlr4在解析输入字符流的时候
- 会进行最大匹配，匹配不完整个输入流，也不会出错
    - 也就是，输入不完全满足语法规则
- 这样的情况，在大多数情况下，是不能容忍的
- 比如，想要运行一个表达式，本来输入很长的
- 但是能解析运行一部分，其他不能解析的却被忽略了
- 我们希望不要忽略，解析不了就报错是更加理想的
- 这时候，我们就需要在根语法规则后添加 `EOF` 表示一直匹配到输入流
- 这样，目前只支持两位数值的加法，多一个数值加法是不支持的
- 因为会语法解析失败
- 也就是
- `1+2` 是允许的
- `1+2+3` 是不允许的，因为 `1+2` 已经匹配完了语法规则
    - 语法规则要求下一个是 `EOF` 输入结束
    - 但是得到的是一个 `+` 号
    - 所以不满足语法

```antlrv4
grammar Demo;

INTEGER: ('0' X?)? (DIGIT| [1-9] DIGIT+) L?;

DIGIT: [0-9];

fragment L: [lL];
fragment X: [xX];

expr:
    number '+' number EOF
;

number:
    INTEGER
;
```

### 8.4. 递归规则

- 即规则的展开，使用了规则本身
- 从而形成递归
- 比如，四则运算中，3个数字运算
- 实际上拆分之后，就是先选两个计算完，再与第三个计算
- 这样，实际上，就抽象出来了
- 数字可能与数字计算
- 数字也可能和一个计算结果（即表达式）运算
- 下面例子中
    - expr有两条规则
        - 高优先级的是 `expr '+' expr`, 表示两个表达式相加
        - 低优先级的是 `number`，表示 expr 可能是一个数字
        - 那么，合起来就是说，expr可以是数字，也可以两个表达式相加
        - 这样，这份语法规则就表示了，支持多个数字相加
    - 另外，为了方便，我们单独抽取出来了一个 script 的语法
    - 主要目的是为了全匹配输入

```antlrv4
grammar Demo;

INTEGER: ('0' X?)? (DIGIT| [1-9] DIGIT+) L?;

DIGIT: [0-9];

fragment L: [lL];
fragment X: [xX];


script:
    expr EOF
;

expr:
    expr '+' expr
    | number
;

number:
    INTEGER
;
```

- 同理，我们可以拓展其他的运算规则
- 让他支持减法
- 【注意】我们只支持加减，因为乘除会有优先级问题
- 后面再讲解

```antlrv4
grammar Demo;

INTEGER: ('0' X?)? (DIGIT| [1-9] DIGIT+) L?;

DIGIT: [0-9];

fragment L: [lL];
fragment X: [xX];


script:
    expr EOF
;

expr:
    expr ('+'|'-') expr
    | number
;

number:
    INTEGER
;
```

### 8.5. 语法优先级

- 在进行四则运算时，要求先乘除后加减
- 如果直接添加运算符，则会按照从左至右顺序计算
- 这样根本不满足先乘除后加减的原则
- 因此，必须使用优先级
- 前面总体规则说了，在上面的优先级高，下面的优先级低
- 因此，我们就可以把四则运算拆分成两组：乘除、加减
- 乘除优先级高，加减优先级低
- 下面的例子
    - 括号的优先级最高
    - 乘除次之
    - 加减优先级最低
- 现在，四则运算的计算器就已经基本满足了

```antlrv4
grammar Demo;

INTEGER: ('0' X?)? (DIGIT| [1-9] DIGIT+) L?;

DIGIT: [0-9];

fragment L: [lL];
fragment X: [xX];

script:
    expr EOF
;

expr:
    '(' expr ')'
    | expr ('*'|'/') expr
    | expr ('+'|'-') expr
    | number
;

number:
    INTEGER
;
```

## 9. 左递归问题

- 前面的 expr 语法中，有的子分支时以 expr 开头的
- 这样，expr 的最多边元素是 expr 就构成了左递归
- 这种属于子元素的直接左递归
- 还有间接左递归的形式，也就是，子元素的语法中，第一个元素使父元素，从而形成简介左递归

### 9.1. 经典解法一：LL自上而下的写法

> 让低优先级的连接高优先级的

- 这是经典的LL自上而下的写法
- antlr 的低版本，大多数都采用这种写法
    - 只不过在 antlr4 中，这种写法不常见了
    - 因为会写成一个倒置的冗长的依赖链
- expr 指向最低优先级的 addSubExpr 加减法
- addSubExpr 分别指向
    - 更高优先级的 mulDivExpr
    - 或，`addSubExpr ('+'|'-') mulDivExpr` 自身与高优先级的结合
- 因此，表现形式就是，最低优先级的最先定义
- 让低优先级的定义内部优先返回高优先级，其次再返回自身与高优先级的结合
- 也可以光看 mulDivExpr 定义的部分的形式

```antlrv4
grammar Demo;

INTEGER: ('0' X?)? (DIGIT| [1-9] DIGIT+) L?;

fragment DIGIT: [0-9];

fragment L: [lL];
fragment X: [xX];

script:
    expr EOF
;

expr:
    addSubExpr
;

addSubExpr:
    mulDivExpr
    | addSubExpr ('+'|'-') mulDivExpr
    ;

mulDivExpr:
    number
    | mulDivExpr ('*'|'/') number
    ;

number:
    INTEGER
;
```

### 9.2. 经典解法二：直接0到多后置

- 这也是经典的LL自上而下的写法
- antlr 的低版本，大多数都采用这种写法
    - 只不过在 antlr4 中，这种写法不常见了
    - 因为会写成一个倒置的冗长的依赖链
- 核心思想也是让低优先级的连接高优先级的
- 高优先级的结合完毕，在进行低优先级的结合

```antlrv4
grammar Demo;

INTEGER: ('0' X?)? (DIGIT| [1-9] DIGIT+) L?;

fragment DIGIT: [0-9];

fragment L: [lL];
fragment X: [xX];

script:
    expr EOF
;

expr:
    mulDivExpr ( ('+'| '-') mulDivExpr)*
;

mulDivExpr:
    number (('*'|'/') number)*
;

number:
    INTEGER
;
```

## 10. Antlr4 特有语法支持

- 上面的部分，大部分的语法、词法写法基本是一致的
- 主要区别就是左递归的支持，可能有的不支持左递归的写法
- 但是，大部分语法规则写法是一致的
- 下面，这些是 Antlr4 专门额外提供的一些能力

### 10.1. 多分支别名

- 当某个语法有多个分支时，如果没有别名的话
- 在编写语义实现的时候，往往要进行子元素个数和类型的判断，来决定是哪一个分支
- 这个时候，Antlr4 提供了别名，来额外生成这样的 hook 入口函数
- 这样直接使用 hook 函数，就能够明确的知道是哪个分支
- 同时，终结符或非终结符，当出现多次或需要明确取一个明确的元素的时候
- 不使用别名，只能根据索引下标来取子元素
- 这时候，Antlr4 提供了元素别名，来额外在生成的代码中，添加对应的别名函数
- 用来直接获取这个元素，而不是使用下标索引
- 下面例子中
    - 针对 expr 的这几个分支，都使用 `# 分支别名` 后缀进行分支别名指定
        - 这样，在未来进行 Visitor 实现语义的时候
        - 就能够有一个单独的别名的 hook 函数进行实现
        - 就不用判断到底是哪个分支了
    - 对其中的元素，使用 `元素别名=` 对元素指定别名
        - 这样，在未来进行 Visitor 实现语义的时候
        - 就能够直接通过 expr 元素获取其别名对应的元素
        - 就不用再使用下标了

```antlrv4
grammar Demo;

INTEGER: ('0' X?)? (DIGIT| [1-9] DIGIT+) L?;

DIGIT: [0-9];

fragment L: [lL];
fragment X: [xX];

script:
    expr EOF
;

expr:
    lp='(' mid=expr rp=')' # parenExpr
    | left=expr oper=('*'|'/') right=expr # mulDivExpr
    | left=expr oper=('+'|'-') right=expr # addSubExpr
    | num=number # numExpr
;

number:
    INTEGER
;
```

### 10.2. 右结合支持

- 在默认情况下，同优先级的都是从左到右进行运算的
- 先进性左边的，再进行右边的，这样的是左结合
- 但是某些情况下，希望先计算右边的，再计算左边的
- 这种时候，就需要右结合
- 比如，`a=b=1` 这种需求，就需要有递归，先计算 `b=1` 得到值，才能进行 `a=b`
- 这个时候，就需要在这个分支上，添加 `<assoc=right>` 来指定使用右递归

```antlrv4
grammar Demo;

INTEGER: ('0' X?)? (DIGIT| [1-9] DIGIT+) L?;

IDENTIFIER: [a-zA-Z_][a-zA-Z0-9_]*;

fragment DIGIT: [0-9];

fragment L: [lL];
fragment X: [xX];

script:
    expr EOF
;

expr:
    '(' expr ')'
    | expr ('*'|'/') expr
    | expr ('+'|'-') expr
    | <assoc=right> expr '=' expr
    | variable
    | number
;

variable:
    IDENTIFIER
    ;

number:
    INTEGER
;
```

## 11. 脚本语言参考（Funic）

- 更多示例代码，可以参考我的 github 项目
    - 这是一个自定义的脚本语言
    - 实现了流程控制（if/else/while/for/...）
    - 实现了函数调用
    - 实现了一些其他的脚本语言的特有功能
    - 主要用于在Java中进行一些脚本化任务的开发
    - 可能其中有一些点能够给你提供一些思路
    - [github 仓库](https://github.com/ice2faith/i2f-turbo-java/tree/main/i2f-extension/i2f-extension-antlr4-funic)
    - [gitee 镜像仓库](https://gitee.com/ice2faith/i2f-turbo-java/tree/main/i2f-extension/i2f-extension-antlr4-funic)
    - 如果，你觉得这个比较复杂，可以先看同级模块下面的这两个实现
    - 这两个是我学习时，早期的产物
    - i2f-extension-antlr4-calculator 最早学习时
    - i2f-extension-antlr4-tinyscript 中间过渡期
    - i2f-extension-antlr4-funic 最终形态

```shell
https://github.com/ice2faith/i2f-turbo-java/tree/main/i2f-extension/i2f-extension-antlr4-funic

https://gitee.com/ice2faith/i2f-turbo-java/tree/main/i2f-extension/i2f-extension-antlr4-funic
```

## 12. 官方参考

- 提供了一些官方的编程语言的语法定义
- 在编写和学习的过程中，可以参考已有的编程语言的一些语法规则是怎么写的
- 从而借鉴写法或用来未自己编写语法规则提供思路
- 官方地址：[Antlr4 编程语言参考合集](https://github.com/antlr/grammars-v4/tree/master)

```shell
https://github.com/antlr/grammars-v4/tree/master
```

## 13. 简单计算器（普适版）

### 13.1. 语法定义

- 现在有了基础知识，我们已经能够编写一个简单的计算器了
- 现在，直接给出语法定义文件 Calc.g4
- 调整了几个点
    - 支持了浮点数
    - 支持了负数
    - 支持了百分数
    - 支持了尾部可选的等号
    - 支持忽略空白符
    - 完整输入流解析
    - 终结符全部命名到词法分析中
    - 规范化命名
- 另外，我们需要生成的是Java代码
- 所以，我们就添加了 `@header` 部分
- 用于指定生成的内容的包名
- 这里，我们存放到 `demo.calc.grammar` 包
- 后面我们自己的实现代码，放到 `demo.calc.lang` 包中实现
- 这样，当我们后面修改 g4 文件重新生成的时候，不会乱

```antlrv4
grammar Calc;

@header {
    package demo.calc.grammar;
}

fragment NUM: (DIGIT| [1-9] DIGIT+);
fragment DIGIT: [0-9];
fragment L: [lL];
fragment F: [xX];
fragment X: [xX];

CONST_FLOAT: NUM '.' NUM F?;
CONST_INTEGER: ('0' X?)? NUM L?;

TERM_PAREN_L: '(';
TERM_PAREN_R: ')';

TERM_ADD: '+';
TERM_SUB: '-';
TERM_MUL: '*';
TERM_DIV: '/';

TERM_PERCENT: '%';

TERM_EQ: '=';

WS: [ \r\n\t] -> skip;

script:
    expr TERM_EQ? EOF
;

expr:
    lParen expr rParen
    | prefixOperator expr
    | expr suffixOperator
    | expr mathMulDivOperator expr
    | expr mathAddSubOperator expr
    | number
;

lParen:
    TERM_PAREN_L
    ;

rParen:
    TERM_PAREN_R
    ;

prefixOperator:
    TERM_SUB
    ;

suffixOperator:
    TERM_PERCENT
;
mathMulDivOperator:
    TERM_MUL|TERM_DIV
    ;

mathAddSubOperator:
    TERM_ADD|TERM_SUB
    ;

number:
    floatNumber
    | intNumber
;

floatNumber:
    CONST_FLOAT
;

intNumber:
    CONST_INTEGER
;
```

### 13.2. Java代码生成

- 安装好 IDEA 的 Antlr4 插件之后
- 将上方的 g4 文法定义文件保存
- 并在 IDEA 中打开
- 在 g4 文件上右键
- 先 [Configure Antlr4] 进行一些基础的配置
    - 选择生成的存放路径，也就是我们上面的 grammar 包所在的路径
    - 选择生成的目标语言为 Java
- 选择 [Generate Antlr4 Recognizer] 生成 Antlr4 的语法识别器代码
- 会生成这样的一些列文件
    - 除了 Java 文件，都是可以删掉的
    - Listener 也可以删掉，大部分时候不用
    - 或者在配置的时候，就不勾选生成 Listener

```shell
src
    java
        demo
            calc 
              grammar
                  Calc.interp
                  Calc.tokens
                  CalcBaseListener.java
                  CalcBaseVisitor.java
                  CalcLexer.interp
                  CalcLexer.java
                  CalcLexer.tokens
                  CalcListener.java
                  CalcParser.java
                  CalcVisitor.java
```

- 那么呢，我们需要做的就是实现一个 CalcListener 或者 CalcVisitor
- 这个呢，就是我们的语言的实际的语义逻辑的处理了
- 一般来说，根据我们定义的语法规则
- 我们是只要每一条语法规则，需要处理的具体事情的
- 比如 intNumber 这个语法规则，我们很清晰的知道
- 下面就只有一个终结符节点，这里面实际上就是一个整数的数值的一个字符串
- 所以，只需要解析这个字符串，转换为一个整形数值即可
- 同时，我们的 expr 这个语法规则，里面有很多的分支
- 每个分支里面，子元素的个数不同，每个子元素的类型不同
- 因此，就可以通过子元素的个数和对应元素的类型，直到应该是哪个分支
- 进行对应的处理即可
- 那么，我们的这个语法规则的目的是什么
- 是为了得到一个最终的结果，这个结果由不同的语法规则一步一步算出来
- 这样，就非常适用于 Visitor 模式
- Visitor 模式，允许自由的访问子元素，控制逻辑，每个节点返回一个计算值
- 正好符合我们计算器的计算逻辑
- 实际上，大多数的语言运行，都可以使用 Visitor 模式实现
- 因此，这里我们只介绍使用 Visitor 模式实现计算器的总体逻辑

### 13.3. 实现 Visitor 计算逻辑

- 首先，添加Maven依赖

```xml

<dependency>
    <groupId>org.antlr</groupId>
    <artifactId>antlr4-runtime</artifactId>
    <version>4.13.2</version>
</dependency>
```

- 我们先查看 CalcVisitor 的定义是什么
- 他是一个泛型接口
- 并且有许多的接口函数需要实现
- 每个接口函数返回类型都是泛型
- 入参都是一个 Parser.xxxContext
- 那么，这个 xxxContext 名字是不是很眼熟
- 对的，这个就是语法规则文件里面的语法规则名
- 所有，到这一步，你已经知道了，语法规则文件是怎么对应的了
- 那么，就可以对照着语法规则文件，实现响应的接口逻辑了
- 那么，返回值怎么定义
- 返回值泛型，因为我们这个知识简单的计算器，有浮点数运算
- 所以，我们每个语法的结果都认为是一个浮点数即可
- 其他复杂的情况，就需要定义一个Pojo类来保存一些其他的状态了
- 为了计算的精确度，可以选择 BigDecimal 作为泛型返回值
- 【注意】我们不是还有终结符吗，也就是计算符号，计算符号怎么返回呢
    - 所以，我们实际实现的时候，返回值是Object
    - 当然，更好的做法是，写一个接口类获取值
    - 写两个实现类，分别对终结符和值实现这个接口类
    - 返回值就返回接口

```java
public interface CalcVisitor<T> extends ParseTreeVisitor<T> {
    /**
     * Visit a parse tree produced by {@link CalcParser#script}.
     * @param ctx the parse tree
     * @return the visitor result
     */
    T visitScript(CalcParser.ScriptContext ctx);

    /**
     * Visit a parse tree produced by {@link CalcParser#expr}.
     * @param ctx the parse tree
     * @return the visitor result
     */
    T visitExpr(CalcParser.ExprContext ctx);

    // ... mores
}
```

- 那么我们来实现我们自己的实现类
- `demo.calc.lang.impl.DefaultCalcVisitor`
- 内容比较多，不逐一实现，只针对重要的几个点说清楚
- 大家自行实现即可
- 【注意】大家应该先编写完 g4 语法规则文件时
    - 先挑选一些符合自己语法的规则的表达式
    - 在 Antlr4 Preview 中看一下语法树是否符合逻辑
    - 这也是实现 Visitor 的一个参考
- 简单讲解一下
    - 首先，泛型我们选择 Object
        - 是因为，我们的最终计算结果虽然是一个 BigDecimal
        - 但是，中间过程会有一些运算符号的参与，他们是一个 String
        - 因此，这里只是简单的使用 Object 来表示
        - 更好的做法是，抽象出一个接口，加上两个实现（符号、结果值）
    - 其次，根据语法定义，对每个节点的结果有预期
        - 因此可以直接强制类型转换
    - 注意报错，这里使用 getTreeLocationText 和 debugLog 来进行跟踪过程
        - 以确保，当表达式复杂时，能够较为准确地提供报错的具体位置
        - 方便对输入的字符脚本进行排错修正
    - 实现方法重点
        - 第一个，就是一般一份语法文件，都有一个根节点，这里是 script
            - 因此，visitScript() 的实现是必须的
        - 其次，一般会有更多复杂的多分支的语法定义，这个是比较麻烦的，这里是 expr
            - 因此 visitExpr() 的实现是最重要的
            - 注意分支之间的识别与判断
            - 必要时，通过调整语法规则文件方式，在保证语义不发生变化的情况下
            - 使得实现更加方便
        - 接着，一般的通用的 visit() 方法，可以选取头两层节点进行处理即可
            - 这个主要是提供一种更加通用的访问方式
            - 使得使用方不需要知道你的语法中，哪一个是根节点
        - 还有，一般通用的 visitChildren() 方法，不想实现可以不实现
            - 这个不是必须的，根据情况而定
        - 而，一般通用的 visitTerminal() 也会比较麻烦
            - 有两种方式
            - 一个是像下面这样，直接格局 symbolType 符号类型提前处理返回
            - 另一个则是直接全部返回原始文本，让调用的上方节点自行处理
            - 根据实际情况而定
        - 最后，通用的 visitErrorNode() 方法，最好是直接抛出错误
            - 让使用的开发者进行排查输入的错误

```java
package demo.calc.lang.impl;


import demo.calc.grammar.CalcParser;
import demo.calc.grammar.CalcVisitor;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.tree.ErrorNode;
import org.antlr.v4.runtime.tree.ParseTree;
import org.antlr.v4.runtime.tree.RuleNode;
import org.antlr.v4.runtime.tree.TerminalNode;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.MathContext;
import java.math.RoundingMode;
import java.util.function.Supplier;


public class DefaultCalcVisitor implements CalcVisitor<Object> {
    public static final MathContext MATH_CONTEXT = new MathContext(20, RoundingMode.HALF_UP);

    @Override
    public Object visitScript(CalcParser.ScriptContext ctx) {
        try {
            debugNode(ctx);
            ParseTree child = ctx.getChild(0);
            if (child instanceof CalcParser.ExprContext) {
                CalcParser.ExprContext nextCtx = (CalcParser.ExprContext) child;
                return visitExpr(nextCtx);
            }
            throw new IllegalStateException(getTreeLocationText("location ", ctx, " ") + " un-support script node!");
        } catch (Throwable e) {
            throw new IllegalStateException(getTreeLocationText("location ", ctx, " ") + "cause by: " + e.getMessage(), e);
        }
    }

    @Override
    public Object visitExpr(CalcParser.ExprContext ctx) {
        try {
            debugNode(ctx);
            ParseTree child = ctx.getChild(0);
            if (child instanceof CalcParser.LParenContext) {
                CalcParser.ExprContext nextCtx = (CalcParser.ExprContext) ctx.getChild(1);
                return visitExpr(nextCtx);
            } else if (child instanceof CalcParser.PrefixOperatorContext) {
                CalcParser.PrefixOperatorContext operCtx = (CalcParser.PrefixOperatorContext) child;
                String prefix = (String) visitPrefixOperator(operCtx);

                CalcParser.ExprContext nextCtx = (CalcParser.ExprContext) ctx.getChild(1);
                BigDecimal value = (BigDecimal) visitExpr(nextCtx);
                if ("-".equals(prefix)) {
                    return value.negate();
                } else {
                    throw new IllegalStateException(getTreeLocationText("location ", ctx, " ") + " un-support prefix [" + prefix + "]!");
                }
            } else if (child instanceof CalcParser.ExprContext) {
                CalcParser.ExprContext nextCtx = (CalcParser.ExprContext) child;
                BigDecimal left = (BigDecimal) visitExpr(nextCtx);

                ParseTree secCtx = ctx.getChild(1);
                if (secCtx instanceof CalcParser.SuffixOperatorContext) {
                    CalcParser.SuffixOperatorContext operCtx = (CalcParser.SuffixOperatorContext) secCtx;
                    String suffix = (String) visitSuffixOperator(operCtx);

                    if ("%".equals(suffix)) {
                        return left.divide(BigDecimal.valueOf(100), MATH_CONTEXT);
                    } else {
                        throw new IllegalStateException(getTreeLocationText("location ", ctx, " ") + " un-support suffix [" + suffix + "]!");
                    }
                } else if (secCtx instanceof CalcParser.MathMulDivOperatorContext) {
                    CalcParser.ExprContext rightCtx = (CalcParser.ExprContext) ctx.getChild(2);
                    BigDecimal right = (BigDecimal) visitExpr(rightCtx);

                    CalcParser.MathMulDivOperatorContext operCtx = (CalcParser.MathMulDivOperatorContext) secCtx;
                    String oper = (String) visitMathMulDivOperator(operCtx);
                    if ("*".equals(oper)) {
                        return left.multiply(right, MATH_CONTEXT);
                    } else if ("/".equals(oper)) {
                        return left.divide(right, MATH_CONTEXT);
                    } else {
                        throw new IllegalStateException(getTreeLocationText("location ", ctx, " ") + " un-support operator [" + oper + "]!");
                    }
                } else if (secCtx instanceof CalcParser.MathAddSubOperatorContext) {
                    CalcParser.ExprContext rightCtx = (CalcParser.ExprContext) ctx.getChild(2);
                    BigDecimal right = (BigDecimal) visitExpr(rightCtx);

                    CalcParser.MathAddSubOperatorContext operCtx = (CalcParser.MathAddSubOperatorContext) secCtx;
                    String oper = (String) visitMathAddSubOperator(operCtx);
                    if ("+".equals(oper)) {
                        return left.add(right, MATH_CONTEXT);
                    } else if ("-".equals(oper)) {
                        return left.subtract(right, MATH_CONTEXT);
                    } else {
                        throw new IllegalStateException(getTreeLocationText("location ", ctx, " ") + " un-support operator [" + oper + "]!");
                    }
                }
            } else if (child instanceof CalcParser.NumberContext) {
                CalcParser.NumberContext nextCtx = (CalcParser.NumberContext) child;
                return visitNumber(nextCtx);
            }
            throw new IllegalStateException(getTreeLocationText("location ", ctx, " ") + " un-support expr node!");
        } catch (Throwable e) {
            throw new IllegalStateException(getTreeLocationText("location ", ctx, " ") + "cause by: " + e.getMessage(), e);
        }
    }

    // ... mores


    @Override
    public Object visitNumber(CalcParser.NumberContext ctx) {
        try {
            debugNode(ctx);
            ParseTree child = ctx.getChild(0);
            if (child instanceof CalcParser.FloatNumberContext) {
                CalcParser.FloatNumberContext nextCtx = (CalcParser.FloatNumberContext) child;
                return visitFloatNumber(nextCtx);
            } else if (child instanceof CalcParser.IntNumberContext) {
                CalcParser.IntNumberContext nextCtx = (CalcParser.IntNumberContext) child;
                return visitIntNumber(nextCtx);
            }
            throw new IllegalStateException(getTreeLocationText("location ", ctx, " ") + " un-support number node!");
        } catch (Throwable e) {
            throw new IllegalStateException(getTreeLocationText("location ", ctx, " ") + "cause by: " + e.getMessage(), e);
        }
    }


    @Override
    public Object visitIntNumber(CalcParser.IntNumberContext ctx) {
        try {
            debugNode(ctx);
            ParseTree child = ctx.getChild(0);
            Object value = visitTerminal((TerminalNode) child);
            return value;
        } catch (Throwable e) {
            throw new IllegalStateException(getTreeLocationText("location ", ctx, " ") + "cause by: " + e.getMessage(), e);
        }
    }

    @Override
    public Object visit(ParseTree tree) {
        try {
            debugNode(tree);
            if (tree instanceof CalcParser.ScriptContext) {
                CalcParser.ScriptContext nextCtx = (CalcParser.ScriptContext) tree;
                return visitScript(nextCtx);
            } else if (tree instanceof CalcParser.ExprContext) {
                CalcParser.ExprContext nextCtx = (CalcParser.ExprContext) tree;
                return visitExpr(nextCtx);
            }
            throw new IllegalStateException(getTreeLocationText("location ", tree, " ") + " un-support visit node!");
        } catch (Throwable e) {
            throw new IllegalStateException(getTreeLocationText("location ", tree, " ") + "cause by: " + e.getMessage(), e);
        }
    }

    @Override
    public Object visitChildren(RuleNode node) {
        throw new IllegalStateException(getTreeLocationText("location ", node, " ") + " current method not supported!");
    }

    @Override
    public Object visitTerminal(TerminalNode ctx) {
        try {
            debugNode(ctx);
            Token symbol = ctx.getSymbol();
            int symbolType = symbol.getType();
            String symbolText = symbol.getText();
            String terminalText = ctx.getText();
            Object value = terminalText;

            if (CalcParser.CONST_FLOAT == symbolType) {
                String text = terminalText.toLowerCase();
                boolean isFloat = text.endsWith("f");
                if (isFloat) {
                    text = text.substring(0, text.length() - 1);
                }
                value = new BigDecimal(text);
                // ignore float type, all cast to BigDecimal
            } else if (CalcParser.CONST_INTEGER == symbolType) {
                String text = terminalText.toLowerCase();
                boolean isLong = text.endsWith("l");
                if (isLong) {
                    text = text.substring(0, text.length() - 1);
                }
                if (text.startsWith("0x")) {
                    value = new BigDecimal(new BigInteger(text.substring(2), 16));
                } else if (text.startsWith("0")) {
                    value = new BigDecimal(new BigInteger(text.substring(1), 8));
                } else {
                    value = new BigDecimal(text);
                }
                value = new BigDecimal(text);
                // ignore long type, all cast to BigDecimal
            } else {
                // other flags
                value = terminalText;
            }
            return value;
        } catch (Throwable e) {
            throw new IllegalStateException(getTreeLocationText("location ", ctx, " ") + "cause by: " + e.getMessage(), e);
        }
    }

    @Override
    public Object visitErrorNode(ErrorNode node) {
        throw new IllegalStateException(getTreeLocationText("location ", node, " ") + " unexpect error node found!");
    }

    public void debugNode(ParseTree context) {
        debugLog(() -> context.getClass().getSimpleName().replace("$", ".") + ": " + context.getText() + getTreeLocationText(", location ", context, null));
    }

    public void debugLog(Supplier<Object> supplier) {
        System.out.println(supplier.get());
    }

    public String getTreeLocationText(String prefix, ParseTree context, String suffix) {
        String loc = "";
        if (context instanceof ParserRuleContext) {
            ParserRuleContext ruleContext = (ParserRuleContext) context;
            Token start = ruleContext.getStart();
            if (start != null) {
                if (prefix == null) {
                    prefix = "";
                }
                if (suffix == null) {
                    suffix = "";
                }
                loc = prefix + "at line " + start.getLine() + ":" + start.getCharPositionInLine() + suffix;
            }
        }
        String text = context.getText();
        if (text.length() > 50) {
            text = text.substring(0, 50) + "...";
        }
        loc += ", near " + text;
        return loc;
    }
}

```

### 13.4. 实现调用门面

- 因为，Visitor 有部分方法我们没有实现
- 或者实现的较为简单
- 因此，最好提供一个更加友好的调用门面
- 提供更加简单的使用方式
- 下面，编写 `demo.calc.lang.Calc`
- 几个点
    - 默认的 Antlr4 解析失败不会报错
        - 因此，需要通过自定义的 ANTLRErrorListener 方式进行报错
        - 默认情况下，只会在控制台输出错误日志，不会报错
        - 下面使用 ERROR_LISTENER 方式进行注册默认的报错监听器
    - 字符串解析的缓存优化
        - CalcParser.ScriptContext parse(String formula)
        - 这个方法，如果高频调用时
        - 建议使用 LRU 进行缓存优化
        - 避免重复解析
    - 门面的另一个职责，就是结果类型转换
        - 将 Visitor 得到的结果进行明确的类型转换
        - 提供给调用者

```java
package demo.calc.lang;

import demo.calc.grammar.CalcLexer;
import demo.calc.grammar.CalcParser;
import demo.calc.lang.errors.DefaultAntlrErrorListener;
import demo.calc.lang.errors.DefaultErrorStrategy;
import org.antlr.v4.runtime.ANTLRErrorListener;
import org.antlr.v4.runtime.ANTLRInputStream;
import org.antlr.v4.runtime.CommonTokenStream;

import java.math.BigDecimal;
import java.util.concurrent.CopyOnWriteArrayList;

public class Calc {

    public static final CopyOnWriteArrayList<ANTLRErrorListener> ERROR_LISTENER = new CopyOnWriteArrayList<>();

    static {
        ERROR_LISTENER.add(DefaultAntlrErrorListener.INSTANCE);
    }

    public static BigDecimal script(String formula) {
        CalcParser.ScriptContext root = parse(formula);
        return script(root, null);
    }

    public static BigDecimal script(String formula, DefaultCalcVisitor visitor) {
        CalcParser.ScriptContext root = parse(formula);
        return script(root, visitor);
    }

    public static BigDecimal script(CalcParser.ScriptContext tree, DefaultCalcVisitor visitor) {
        if (visitor == null) {
            visitor = new DefaultCalcVisitor();
        }
        Object value = visitor.visit(tree);
        return (BigDecimal) value;
    }

    public static CalcParser.ScriptContext parse(String formula) {
        if (formula != null) {
            formula = formula.trim();
        }
        CommonTokenStream tokens = parseTokens(formula);
        CalcParser parser = new CalcParser(tokens);
        parser.setErrorHandler(new DefaultErrorStrategy());
        for (ANTLRErrorListener item : ERROR_LISTENER) {
            if (item == null) {
                continue;
            }
            parser.addErrorListener(item);
        }
        CalcParser.ScriptContext tree = parser.script();
        return tree;
    }

    public static CommonTokenStream parseTokens(String formula) {
        ANTLRInputStream input = new ANTLRInputStream(formula);
        CalcLexer lexer = new CalcLexer(input);
        for (ANTLRErrorListener item : ERROR_LISTENER) {
            if (item == null) {
                continue;
            }
            lexer.addErrorListener(item);
        }
        CommonTokenStream tokens = new CommonTokenStream(lexer);
        return tokens;
    }
}

```

- 添加直接抛出异常的监听器

```java
package demo.calc.lang.errors;

import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;

import java.lang.reflect.Method;


public class DefaultAntlrErrorListener extends BaseErrorListener {

    public static final DefaultAntlrErrorListener INSTANCE = new DefaultAntlrErrorListener();

    protected static volatile Object SLF4J_LOGGER;
    protected static volatile Method SLF4J_ERROR_METHOD;

    static {
        Class<?> clazz = null;
        try {
            clazz = Thread.currentThread().getContextClassLoader().loadClass("org.slf4j.LoggerFactory");
        } catch (Throwable e) {

        }
        if (clazz == null) {
            try {
                clazz = Class.forName("org.slf4j.LoggerFactory");
            } catch (Throwable e) {

            }
        }
        if (clazz == null) {
            SLF4J_LOGGER = null;
        }
        try {
            Method method = clazz.getMethod("getLogger", Class.class);
            if (method != null) {
                SLF4J_LOGGER = method.invoke(null, DefaultAntlrErrorListener.class);
            }
        } catch (Exception e) {
        }
        if (SLF4J_LOGGER != null) {
            try {
                Class<?> cls = SLF4J_LOGGER.getClass();
                SLF4J_ERROR_METHOD = cls.getMethod("error", String.class, Throwable.class);
                SLF4J_ERROR_METHOD.setAccessible(true);
            } catch (Exception e) {

            }
        }
    }

    @Override
    public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) {
        String errorMsg = "line " + line + ":" + charPositionInLine + " " + msg;
        logError(errorMsg, e);
        throw e;
    }

    public void logError(String msg, Throwable e) {
        if (SLF4J_ERROR_METHOD != null) {
            try {
                SLF4J_ERROR_METHOD.invoke(SLF4J_LOGGER, msg, e);
            } catch (Exception ex) {
            }
            return;
        }
        System.err.println(msg);
        e.printStackTrace();
    }

}

```

- 添加报错策略

```java
package demo.calc.lang.errors;

import org.antlr.v4.runtime.*;


public class DefaultErrorStrategy extends org.antlr.v4.runtime.DefaultErrorStrategy {
    public static final DefaultErrorStrategy INSTANCE = new DefaultErrorStrategy();

    @Override
    public void reportError(Parser parser, RecognitionException e) {
        Token startToken = e.getOffendingToken();
        Token offendingToken = e.getOffendingToken();
        if (e instanceof NoViableAltException) {
            NoViableAltException ex = (NoViableAltException) e;
            startToken = ex.getStartToken();
        }
        TokenStream tokens = parser.getInputStream();
        String input;
        if (tokens != null) {
            if (startToken.getType() == -1) {
                input = "<EOF>";
            } else {
                input = tokens.getText(startToken, offendingToken);
            }
        } else {
            input = "<unknown input>";
        }

        int line = offendingToken.getLine();
        int charPositionInLine = offendingToken.getCharPositionInLine();
        String msg = "no viable alternative at input " + this.escapeWSAndQuote(input);
        String errorMsg = "line " + line + ":" + charPositionInLine + " " + msg;
        throw new IllegalArgumentException(errorMsg);
    }
}

```

## 14. 简单计算器（深度优先版）

- 如果，你的语法，只需要深度优先遍历进行计算
- 即可得到你需要的结果
- 或者，大部分情况都只需要深度优先遍历即可完成目标
- 那么，完全可以使用上 Antlr4 提供的这些能力，从而简化开发
    - 分支别名、参数别名
    - BaseVisitor 基础的默认的深度优先遍历的实现，覆盖部分核心操作即可

### 14.1. 语法定义

```antlrv4
grammar Calc;

@header {
    package demo.calc.grammar;
}

fragment NUM: (DIGIT| [1-9] DIGIT+);
fragment DIGIT: [0-9];
fragment L: [lL];
fragment F: [xX];
fragment X: [xX];

CONST_FLOAT: NUM '.' NUM F?;
CONST_INTEGER: ('0' X?)? NUM L?;

TERM_PAREN_L: '(';
TERM_PAREN_R: ')';

TERM_ADD: '+';
TERM_SUB: '-';
TERM_MUL: '*';
TERM_DIV: '/';

TERM_PERCENT: '%';

TERM_EQ: '=';

WS: [ \r\n\t] -> skip;

script:
    expr TERM_EQ? EOF
;

expr:
    lop=lParen mid=expr rop=rParen # parenExpr
    | prefix=prefixOperator val=expr # prefixOperExpr 
    | val=expr suffix=suffixOperator # suffixOperExpr
    | left=expr oper=mathMulDivOperator right=expr # mathMulDivOperExpr
    | left=expr oper=mathAddSubOperator right=expr # mathAddSubOperExpr
    | num=number # numExpr
;

lParen:
    TERM_PAREN_L
    ;

rParen:
    TERM_PAREN_R
    ;

prefixOperator:
    TERM_SUB
    ;

suffixOperator:
    TERM_PERCENT
;
mathMulDivOperator:
    TERM_MUL|TERM_DIV
    ;

mathAddSubOperator:
    TERM_ADD|TERM_SUB
    ;

number:
    floatNumber
    | intNumber
;

floatNumber:
    CONST_FLOAT
;

intNumber:
    CONST_INTEGER
;
```

### 14.2. 实现 Visitor 计算逻辑

- 这里，BaseVisitor 的逻辑是深度优先的
- 通过下面的这个默认实现，实现深度优先遍历

```java
    public T visitChildren(RuleNode node) {
    T result = this.defaultResult();
    int n = node.getChildCount();

    for (int i = 0; i < n && this.shouldVisitNextChild(node, result); ++i) {
        ParseTree c = node.getChild(i);
        T childResult = c.accept(this);
        result = this.aggregateResult(result, childResult);
    }

    return result;
}
```

- 因此，每访问一个节点，先获取一个默认值 `defaultResult()`
- 然后遍历每个子节点，获取子节点的值 `c.accept(this)`
- 然后同一个节点中多个子节点之间的值允许进行聚合 `aggregateResult()`
    - 也就是允许你将当前子元素的值与兄弟节点的值进行加减运算进行聚合等操作
- 我们这里需要默认值吗？
    - 我们可以不需要，默认返回的就是null
    - 也可以需要默认值，那默认值就是0
    - 因此，我们可以不重写 defaultResult
- 我们需要处理哪些子节点的运算？
    - 识别到，只有数值参与计算或数值字面量才需要处理
    - 那么，只需要选择 floatNumber 、intNumber 这两个数值字面量，用于获取最初计算的值
    - 还需要 prefixOperExpr、suffixOperExpr、mathMulDivOperExpr、mathAddSubOperExpr 等值的计算或者变化的语法规则
    - 好了，完全足够了，其他的节点都是一些符号，或者直接值透传即可的，不需要覆盖，默认就行
- 我们需要处理聚合吗？
    - 经过我们的选取处理覆盖节点之后
    - 剩下的都是一些运算符、终结符、这些都是不影响值变化的，只需要传递即可
    - 默认的聚合是返回最后一个节点的值
    - 但是，我们存在最后一个值实际上是一个运算符号、终结符的情况
    - 比如，右括号、可选等号、以及EOF流结尾
    - 如果按照默认的返回之后一个值，那默认是null
    - 导致最终运算结果就会是null
    - 因此，聚合逻辑就是
    - 只要之后一个值不为null，那就返回最后一个值
    - 否则就返回之前的值
- 具体实现逻辑如下

```java
package demo.calc.impl;

import demo.calc.grammar.CalcBaseVisitor;
import demo.calc.grammar.CalcParser;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.MathContext;
import java.math.RoundingMode;

public class DefaultCalcVisitor extends CalcBaseVisitor<BigDecimal> {
    public static final MathContext MATH_CONTEXT = new MathContext(20, RoundingMode.HALF_UP);

    @Override
    public BigDecimal visitPrefixOperExpr(CalcParser.PrefixOperExprContext ctx) {
        BigDecimal value = visit(ctx.val);
        String prefix = ctx.prefix.getText();
        if ("-".equals(prefix)) {
            return value.negate();
        } else {
            throw new IllegalStateException(" un-support prefix [" + prefix + "]!");
        }
    }

    @Override
    public BigDecimal visitSuffixOperExpr(CalcParser.SuffixOperExprContext ctx) {
        BigDecimal left = visit(ctx.val);
        String prefix = ctx.suffix.getText();
        if ("%".equals(prefix)) {
            return left.divide(BigDecimal.valueOf(100), MATH_CONTEXT);
        } else {
            throw new IllegalStateException(" un-support prefix [" + prefix + "]!");
        }
    }

    @Override
    public BigDecimal visitMathAddSubOperExpr(CalcParser.MathAddSubOperExprContext ctx) {
        BigDecimal left = visit(ctx.left);
        BigDecimal right = visit(ctx.right);
        String oper = ctx.oper.getText();
        if ("+".equals(oper)) {
            return left.add(right, MATH_CONTEXT);
        } else if ("-".equals(oper)) {
            return left.subtract(right, MATH_CONTEXT);
        } else {
            throw new IllegalStateException(" un-support operator [" + oper + "]!");
        }
    }

    @Override
    public BigDecimal visitMathMulDivOperExpr(CalcParser.MathMulDivOperExprContext ctx) {
        BigDecimal left = visit(ctx.left);
        BigDecimal right = visit(ctx.right);
        String oper = ctx.oper.getText();

        if ("*".equals(oper)) {
            return left.multiply(right, MATH_CONTEXT);
        } else if ("/".equals(oper)) {
            return left.divide(right, MATH_CONTEXT);
        } else {
            throw new IllegalStateException(" un-support operator [" + oper + "]!");
        }
    }

    @Override
    public BigDecimal visitIntNumber(CalcParser.IntNumberContext ctx) {
        String text = ctx.CONST_INTEGER().getText().toLowerCase();
        boolean isLong = text.endsWith("l");
        if (isLong) {
            text = text.substring(0, text.length() - 1);
        }
        BigDecimal value = null;
        if (text.startsWith("0x")) {
            value = new BigDecimal(new BigInteger(text.substring(2), 16));
        } else if (text.startsWith("0")) {
            value = new BigDecimal(new BigInteger(text.substring(1), 8));
        } else {
            value = new BigDecimal(text);
        }
        return value;
    }

    @Override
    public BigDecimal visitFloatNumber(CalcParser.FloatNumberContext ctx) {
        String text = ctx.CONST_FLOAT().getText().toLowerCase();
        boolean isFloat = text.endsWith("f");
        if (isFloat) {
            text = text.substring(0, text.length() - 1);
        }
        return new BigDecimal(text);
    }

    @Override
    protected BigDecimal aggregateResult(BigDecimal aggregate, BigDecimal nextResult) {
        return nextResult == null ? aggregate : nextResult;
    }

}

```