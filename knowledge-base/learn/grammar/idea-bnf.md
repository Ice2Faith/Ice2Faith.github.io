# IDEA 家族自定义语言插件开发

- 前提，具有基础的编译原理规范文法基础知识
- 或者，先阅读关于 Antlr4 自定义语言开发的基础知识
- Antlr4 自定义脚本语言开发：[antlr4.md](antlr4.md)
- 因为，下面的内容，第一步就是编写 IDEA 平台进行脚本语言识别的文法语法文件
- 同时，这个章节和 antlr4 脚本语言开发，是相结合的
- 先阅读有助于理解为什么这样做

## 1. 重要说明

- 在 IDEA 中，语法是不支持左递归的
- 所以，一些在antlr4中的写法是不支持的
- 其次，IDEA 中，bnf 的主要目的是为了进行语言的静态检查
- 因此，不必最求语义一致，只要大体语法上的表达大致一致即可
- 也就是能够覆盖原本语法形式即可，不要求语义一致

## 2. 脚本语言参考（Funic）

- 更多示例代码，可以参考我的 github 项目
    - 这是一个自定义的脚本语言
    - 实现了流程控制（if/else/while/for/...）
    - 实现了函数调用
    - 实现了一些其他的脚本语言的特有功能
    - 主要用于在Java中进行一些脚本化任务的开发
    - 可能其中有一些点能够给你提供一些思路
    - [github 仓库](https://github.com/ice2faith/i2f-turbo-java/tree/main/i2f-tools/i2f-jdbc-procedure-idea-plugin/src/main/java/i2f/turbo/idea/plugin/funic)
    - [gitee 镜像仓库](https://gitee.com/ice2faith/i2f-turbo-java/tree/main/i2f-tools/i2f-jdbc-procedure-idea-plugin/src/main/java/i2f/turbo/idea/plugin/funic)

```shell
https://github.com/ice2faith/i2f-turbo-java/tree/main/i2f-tools/i2f-jdbc-procedure-idea-plugin/src/main/java/i2f/turbo/idea/plugin/funic

https://gitee.com/ice2faith/i2f-turbo-java/tree/main/i2f-tools/i2f-jdbc-procedure-idea-plugin/src/main/java/i2f/turbo/idea/plugin/funic
```

## 3. 安装

- 先安装 IDEA 插件 [Plugin DevKit]

## 4. bnf 文法文件编写

- 这里，将直接以 Antlr4 中的 Calc 简易计算器进行讲解
- 下面直接给出对应的转换之后的结果 Calc.bnf
- 那么，可以大体看到，写法基本上是差不多的
- 只是有一些变化
    - 定义了很多的类名，包名（`parserClass` ... `psiImplUtilClass`）
        - `demo.calc.idea.plugin` 是我们要生成的目标的包
        - 你可以根据自己的需要，把这个包名批量替换掉即可
        - `Calc` 这个是类名前缀
        - 你可以对应替换为自己的类名前缀
        - 这些都是固定不变的，直接替换即可
    - 多了 `extends(".*script")=script`
        - 这个主要是用来进行左递归拓展的
        - 但是实际效果并不好
    - 终结符全部都写到 `tokens=[]` 中了
        - 是的，终结符必须全部写到这个里面
        - 大写名称也是一样的
    - 终结符结构变了
        - 终结符使用等号表达式形式表示
        - 其值只能是固定的字符串，或者以 `regexp` 前缀表示的一个标准的Java正则表达式
        - 不支持 fragment
        - 所以，要做的就是把原来终结符的文法，改写为正则表达式的形式表达
        - 移除 fragment
    - 空白符
        - 必须是 `WS` 这个名字，IDEA平台约定的
    - 语法规则略有变化
        - 从 `:` 变成了 `::=`
        - `EOF` 完全匹配变成了 `<<eof>>`
        - 由于后面高亮、识别等开发时，需要处理符号是不是高亮，括号匹配等情况
        - 所以，所有的语法规则里面的匿名终结符，尽量全部提取到 tokens 里面来作为终结符
        - 否则，后面进行高亮、括号匹配等的时候，将会对定位token极其困难
    - 左递归问题
        - 由于 bnf 不支持左递归
        - 因此，之前的例如 `expr '+' expr` 这种，最左侧等于规则本身的情况
        - 是不支持的
        - 所以，就需要对语法单独重写
        - 一种思路是，既然不要求运行，大致匹配得上，能够辅助开发就行
        - 那就形式上能够满足原始语法定义即可
        - 因此，这里直接将 `'+' expr` 部分单独拿出来
        - 看作是右侧部分，就可以理解为，左侧部分可能会有多的右侧部分
        - 虽然语义上不一致，但是语法上能够覆盖的到
        - 也就是，这里的 `segment` 和 `operatorExpr` 干的事情
        - 当然，在正规编译原理中，我们有规范化的方法进行消除左递归
        - 那就要系统学习编译原理课程的内容
        - 或者，在一开始的antlr4的语法规则中，我们就预先进行消除左递归
        - 这样，就能保持 bnf 和 antlr4 的一致性

```bnf
/// 第七步:定义bnf语法
// 第八步:右键生成parse code
// 第九步:右键生成flex文件
{
  // 语言解析器,由Grammar-Kit插件根据bnf语法文件自动生成
  parserClass="demo.calc.idea.plugin.grammar.parser.CalcParser"
  // 定义辅助类,供 CalcParser 类使用
  parserUtilClass="demo.calc.idea.plugin.lang.parser.CalcParserUtil"

  // 指定生成的PsiElement子类需要继承的父类
  extends="demo.calc.idea.plugin.lang.psi.CalcPsiElement"

  // 指定所有生成的PsiElement类的类名前缀
  psiClassPrefix="Calc"
  // 指定所有生成的PsiElement实现类的类名后缀
  psiImplClassSuffix="Impl"
  // 指定所有生成的PsiElement类的包位置
  psiPackage="demo.calc.idea.plugin.grammar.psi.elements"
  // 指定所有生成的PsiElement实现类的包位置
  psiImplPackage="demo.calc.idea.plugin.grammar.psi.elements.impl"

  // 指定ElementType所在的类,由Grammar-Kit自动生成
  elementTypeHolderClass="demo.calc.idea.plugin.grammar.psi.CalcTypes"
  // 定义elementType类型,供 CalcTypes 类使用
  elementTypeClass="demo.calc.idea.plugin.lang.psi.CalcElementType"
  // 定义tokenType类型,供 CalcTypes 类使用
  tokenTypeClass="demo.calc.idea.plugin.lang.psi.CalcTokenType"
  // 定义工具类,供所有PsiElement实现类使用
  psiImplUtilClass="demo.calc.idea.plugin.lang.psi.impl.CalcPsiImplUtil"

  extends(".*script")=script
  // 定义终结符，这里目前只会使用regexp来进行正则表达式匹配得到终结符
  // 研究不深，还不知道怎么对终结符进行重用，也就是一个终极符分解为多个终结符的语法
  tokens=[
        CONST_FLOAT="regexp:([0-9]|[1-9][0-9]+)\.([0-9]|[1-9][0-9]+)[fF]?";
        CONST_INTEGER="regexp:(0[xX]?)?([0-9]|[1-9][0-9]+)[lL]?";

        TERM_PAREN_L= "(";
        TERM_PAREN_R= ")";

        TERM_ADD= "+";
        TERM_SUB= "-";
        TERM_MUL= "*";
        TERM_DIV= "/";

        TERM_PERCENT= "%";

        TERM_EQ= "=";


        // 定义其他一切不匹配的字符
        WORD="regexp:\w+";

        // 定义空白符
        WS="regexp:[ \t\r\n]+";
    ]
}

script::=
    segment TERM_EQ? <<eof>>
;

segment::=
    expr (operatorExpr)*
    ;

operatorExpr::=
    suffixOperator
    |mathMulDivOperator expr
    |mathAddSubOperator expr
;

expr::=
    lParen expr rParen
    | prefixOperator expr
    | number
;

lParen::=
    TERM_PAREN_L
    ;

rParen::=
    TERM_PAREN_R
    ;

prefixOperator::=
    TERM_SUB
    ;

suffixOperator::=
    TERM_PERCENT
;
mathMulDivOperator::=
    TERM_MUL|TERM_DIV
    ;

mathAddSubOperator::=
    TERM_ADD|TERM_SUB
    ;

number::=
    floatNumber
    | intNumber
;

floatNumber::=
    CONST_FLOAT
;

intNumber::=
    CONST_INTEGER
;
```

## 5. 创建一个 Plugin 工程

- 安装了 DevKit 重启 IDEA 之后
- 新建项目的时候，就可以选到 [IDE Plugin] 了
- 根据向导创建完项目即可
- 这是一个 gradle 项目，不是 Maven
- 但是别慌
- 第一步，修改依赖仓库为阿里云的仓库加速
- 修改 settings.gradle.kts
    - 下面的地方修改，其他的地方不动

```kotlin
pluginManagement {
    repositories {
//        mavenCentral()
        // TODO 切换中央仓库
        maven {
            url = uri("https://maven.aliyun.com/repository/public")
        }
        gradlePluginPortal()
    }
}

```

- 第二步，同样修改仓库，以及使用我们本地的IDEA即可
    - 不要每次都网上下载一个慢的要死
- 修改 build.gradle.kts
    - 同样，下面的地方对应修改，其他地方不要动

```kotlin
repositories {
//    mavenCentral()
    // TODO 切换中央仓库
    maven {
        url = uri("https://maven.aliyun.com/repository/public")
    }

}

// Configure Gradle IntelliJ Plugin
// Read more: https://plugins.jetbrains.com/docs/intellij/tools-gradle-intellij-plugin.html
intellij {
//    version.set("2023.2.5")
//    type.set("IC") // Target IDE Platform
    // TODO 不使用下载，直接使用本地安装目录
    localPath.set("D:\\Program Files\\JetBrains\\IntelliJ IDEA 2024.2.1")

    plugins.set(
        listOf(
            /* Plugin Dependencies */
            "com.intellij.java",
            "com.intellij.database",
            "org.intellij.intelliLang",
//        "com.intellij.modules.xml",
            "com.intellij.velocity",
            "org.jetbrains.plugins.yaml",
        )
    )

}

```

## 6. 生成插件代码

- 安装了 DevKit 插件之后
- 在 bnf 文件上右键，选择 [Generate Parser Code] 即可生成插件的 parser 语法解析器
    - 此时，已经生成了 grammar.parser.CalcParser.java 文件
    - grammar 包下面有两个子包 parser 和 psi
- 重新在 bnf 文件上右键，选择 [Generate JFlex Lexer] 选择到刚生成的 parser 目录下的 grammar 路径
    - 现在在 grammar 包下面，已经有了一个 _CalcLexer.flex 的文件
- 在这个 flex 文件上右键，选择 [Run JFlex Generator] 即可在 grammar.parser 包下面生成 _CalcLexer.java 文件
    - 至此，通过插件生成代码就完成了

## 7. 配置插件

- 找到文件
    - src/main/resources/META-INF/plugin.xml
- 在 extensions 节点下添加如下的节点
    - 根据自己的实际情况进行添加或者删减
    - 想要哪些功能就对应实现哪些拓展点、注册哪些拓展点

```xml
    <!-- Extension points defined by the plugin.
         Read more: https://plugins.jetbrains.com/docs/intellij/plugin-extension-points.html -->
<extensions defaultExtensionNs="com.intellij">
    <!-- *************************** Calc  begin *************************** -->

    <!-- 注册文件类型 -->
    <fileType name="Calc"
              implementationClass="demo.calc.idea.plugin.CalcFileType"
              fieldName="INSTANCE"
              language="Calc"
              extensions="fic"/>

    <!-- 注册语言解析器 -->
    <lang.parserDefinition
            language="Calc"
            implementationClass="demo.calc.idea.plugin.lang.CalcParserDefinition"/>

    <!-- 定义语法高亮 -->
    <lang.syntaxHighlighterFactory
            language="Calc"
            implementationClass="demo.calc.idea.plugin.lang.highlighter.CalcSyntaxHighlighterFactory"/>

    <!-- 定义颜色配置页 -->
    <colorSettingsPage
            implementation="demo.calc.idea.plugin.lang.highlighter.CalcColorSettingsPage"/>

    <!-- 注释处理器 -->
    <lang.commenter language="Calc"
                    implementationClass="demo.calc.idea.plugin.lang.comment.CalcCommenter"/>

    <!-- 括号代码块配对高亮 -->
    <lang.braceMatcher language="Calc"
                       implementationClass="demo.calc.idea.plugin.lang.bracket.CalcPairedBraceMatcher"/>

    <!-- 定义语句模版 -->
    <defaultLiveTemplatesProvider order="first"
                                  implementation="demo.calc.idea.plugin.lang.live.templates.CalcLiveTemplatesProvider"/>

    <!-- 注册 Live Templates 上下文类型，使 Calc 在 Live Templates 设置中可选 -->
    <liveTemplateContextProvider
            implementation="demo.calc.idea.plugin.lang.live.templates.CalcLiveTemplateContextProvider"/>

    <completion.contributor
            language="Calc"
            order="first"
            implementationClass="demo.calc.idea.plugin.lang.completion.CalcCompletionContributor"/>

    <lang.foldingBuilder
            language="Calc"
            implementationClass="demo.calc.idea.plugin.lang.folding.CalcFoldingBuilder"/>

    <lang.formatter
            language="Calc"
            implementationClass="demo.calc.idea.plugin.lang.formatter.CalcFormattingModelBuilder"/>

    <!-- 允许在文件中打断点 -->
    <xdebugger.breakpointType
            implementation="demo.calc.idea.plugin.lang.debugger.CalcLineBreakpointType"/>

    <!-- 注册位置管理器工厂，实现调试时自动暂停与源码导航 -->
    <debugger.positionManagerFactory
            implementation="demo.calc.idea.plugin.lang.debugger.CalcPositionManagerFactory"/>


    <!-- *************************** Calc  end *************************** -->
</extensions>
```

## 8. 编写插件实现

- 这个部分的内容很多
- 所以，还是建议看 IDEA 官方的插件开发教程
- 或者，照着我的代码仓库实现，参照实现即可
- 官方地址：[IDEA 插件开发](https://plugins.jetbrains.com/docs/intellij/developing-plugins.html)

```shell
https://plugins.jetbrains.com/docs/intellij/developing-plugins.html
```

## 9. 编译打包

- 直接通过 gradle 任务中的 intelijPlugin 插件提供的 buildPlugin 任务直接打包即可
- 生成的一般是一个 jar 包或者一个 zip 压缩包

## 10. 插件安装

- 在IDEA插件的安装页面
- 找到上方的更多按钮
- 点击从本地磁盘安装
- 选择这个 jar 或者 zip 包即可