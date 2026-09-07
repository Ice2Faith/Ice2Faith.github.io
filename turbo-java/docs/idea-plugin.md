# XProc4J IDEA 插件 Wiki

## 概述

XProc4J IDEA 插件是专为 **XProc4J（JDBC Procedure）框架** 开发的 IntelliJ IDEA 插件，为 XProc4J XML
配置文件提供智能开发支持，包括语法高亮、代码补全、语言注入、调试断点、Oracle 语法转换等功能。同时提供 TinyScript 和 Funic
两种脚本语言的完整 IDE 支持。

- **插件名称**: XProc4J
- **唯一标识**: `i2f.turbo.jdbc-procedure-plugin`
- **版本**: 1.0
- **作者**: Ice2Faith
- **邮箱**: ugex_savelar@163.com
- **仓库**: https://github.com/Ice2Faith
- **模块路径**: `i2f-tools/i2f-jdbc-procedure-idea-plugin`
- **构建工具**: Gradle + Kotlin（`build.gradle.kts`）
- **代码仓库**: 与主项目共用同一代码仓库，但独立构建（非 Maven 管理）

## 兼容性

| 项目        | 版本/说明                                |
|-----------|--------------------------------------|
| IDEA 最低版本 | 2023.2（build 232）                    |
| 最高支持版本    | 2024.2.x（build 242.*）                |
| 目标 IDE    | IntelliJ IDEA 2024.1                 |
| 适用 IDE    | IDEA、PyCharm、DataGrip 等 JetBrains 系列 |
| JVM 版本    | Java 17（插件运行需要）                      |

## 插件依赖

插件依赖以下 IntelliJ 平台模块：

| 依赖                              | 说明            |
|---------------------------------|---------------|
| `com.intellij.modules.platform` | 平台基础          |
| `com.intellij.modules.lang`     | 语言基础          |
| `com.intellij.java`             | Java 语言支持     |
| `com.intellij.database`         | 数据库支持         |
| `com.intellij.modules.xml`      | XML 语言支持      |
| `com.intellij.velocity`         | Velocity 模板语言 |
| `org.jetbrains.plugins.yaml`    | YAML 支持       |

## 构建配置

插件使用 Gradle 构建（独立于主项目的 Maven 构建体系）：

| 配置项            | 值                                      |
|----------------|----------------------------------------|
| Gradle 插件      | `org.jetbrains.intellij` 1.17.2        |
| Kotlin         | 1.9.22                                 |
| ANTLR4 Runtime | 4.13.2                                 |
| Velocity       | 2.3                                    |
| Jackson        | 2.13.5                                 |
| XProc4J        | `i2f-extension-xproc4j:1.0-jdk8`（本地依赖） |
| OGNL           | 3.4.11（语法验证）                           |
| Groovy         | 4.0.18（语法验证）                           |
| Nashorn        | 15.4（JavaScript 语法验证）                  |

---

## 核心功能

### 1. TinyScript 语言支持

为 TinyScript（`.tis` 文件）提供完整的 IDE 支持：

| 功能             | 说明                                         |
|----------------|--------------------------------------------|
| 文件类型注册         | 扩展名 `.tis`，语言 ID `TinyScript`              |
| 语法解析器          | `TinyScriptParserDefinition`               |
| 语法高亮           | `TinyScriptSyntaxHighlighterFactory`       |
| 颜色配置页          | `TinyScriptColorSettingsPage`（可自定义配色）      |
| 注释处理           | 单行 `//` 和多行 `/* */`                        |
| 括号配对           | `TinyScriptPairedBraceMatcher`             |
| Live Templates | `TinyScriptLiveTemplatesProvider` + 上下文提供者 |
| 代码补全           | `TinyScriptCompletionContributor`          |
| 代码格式化          | `TinyScriptFormattingModelBuilder`         |
| 调试断点           | `TinyScriptLineBreakpointType`             |
| 调试导航           | `TinyScriptPositionManagerFactory`         |

> 详细语法见 [TinyScript 引擎 Wiki](tinyscript-framework.md)

### 2. Funic 语言支持

为 Funic（`.fic` 文件）提供完整的 IDE 支持，功能与 TinyScript 对等：

| 功能             | 说明                                    |
|----------------|---------------------------------------|
| 文件类型注册         | 扩展名 `.fic`，语言 ID `Funic`              |
| 语法解析器          | `FunicParserDefinition`               |
| 语法高亮           | `FunicSyntaxHighlighterFactory`       |
| 颜色配置页          | `FunicColorSettingsPage`（可自定义配色）      |
| 注释处理           | 单行 `//` 和多行 `/* */`                   |
| 括号配对           | `FunicPairedBraceMatcher`             |
| Live Templates | `FunicLiveTemplatesProvider` + 上下文提供者 |
| 代码补全           | `FunicCompletionContributor`          |
| 代码格式化          | `FunicFormattingModelBuilder`         |
| 调试断点           | `FunicLineBreakpointType`             |
| 调试导航           | `FunicPositionManagerFactory`         |

> Funic 是 TinyScript 的增强替代版本。详见 [Funic 引擎 Wiki](funic-framework.md)

### 3. XML 语言增强

为 XProc4J 的 XML 配置文件提供丰富的语言增强功能。

#### 3.1 语言注入 (Language Injection)

插件将以下语言动态注入到 XML 特定标签的内容中：

**SQL 系列**：

| 数据库        | 语言 ID          |
|------------|----------------|
| MySQL      | `MySQL`        |
| Oracle     | `Oracle`       |
| PostgreSQL | `PostgreSQL`   |
| MariaDB    | `MariaDB`      |
| DB2        | `DB2_IS`       |
| ClickHouse | `ClickHouse`   |
| Hive       | `HiveQL`       |
| Spark SQL  | `SparkSQL`     |
| Cassandra  | `CassandraQL`  |
| MongoDB    | `MongoDB-JSON` |
| 通用 SQL     | `SQL`          |

**其他语言注入**：

| 语言           | 注入标签                                                                    |
|--------------|-------------------------------------------------------------------------|
| Java         | `lang-eval-java`、`lang-java-body`、`lang-java-import`、`lang-java-member` |
| Groovy       | `lang-eval-groovy`                                                      |
| JavaScript   | `lang-eval-js`                                                          |
| TinyScript   | `lang-eval-tinyscript` / `lang-eval-ts`                                 |
| Funic        | `lang-eval-funic`                                                       |
| Velocity/VTL | `lang-string`(lang="vtl")、`lang-render`                                 |
| FreeMarker   | `InjectedFreeMarker`                                                    |
| Thymeleaf    | `ThymeleafExpressions`                                                  |
| JSON         | `JSON`                                                                  |
| 正则表达式        | `RegExp`                                                                |
| TypeScript   | `TypeScript`                                                            |
| Shell/Bash   | `Shell Script`                                                          |
| YAML         | `yaml`                                                                  |
| Vue          | `Vue`                                                                   |
| Markdown     | `Markdown`                                                              |
| CSS/SASS     | `CSS` / `SASS`                                                          |
| ANTLR4       | `ANTLRv4`                                                               |
| Redis        | `Redis`                                                                 |
| Cron         | `CronExp`                                                               |
| SpEL         | `SpEL`                                                                  |

**自动语言检测**: 插件根据标签名和 `_lang` 属性自动检测注入语言（如标签名包含 `sql-` → SQL，包含 `java-` → Java）。

**Java 注入增强**: 对于 Java 相关标签，插件自动添加框架相关导入（`i2f.jdbc.procedure.*`、`i2f.bindsql.*`、`i2f.script.*` 等）。

#### 3.2 代码补全 (Completion)

**XML 属性补全**：

| 属性类型          | 补全内容                                                                              |
|---------------|-----------------------------------------------------------------------------------|
| `refid`       | procedure 文件中定义的所有 procedure/script-segment 的 id                                  |
| `propagation` | REQUIRED, SUPPORTS, MANDATORY, REQUIRES_NEW, NOT_SUPPORTED, NEVER, NESTED         |
| `isolation`   | TRANSACTION_NONE, READ_UNCOMMITTED, READ_COMMITTED, REPEATABLE_READ, SERIALIZABLE |
| `time-unit`   | NANOSECONDS, MICROSECONDS, MILLISECONDS, SECONDS, MINUTES, HOURS, DAYS            |
| `jdbc-type`   | 所有 JDBCType 枚举值                                                                   |
| `database`    | mysql, oracle, mariadb, gbase, dm, postgre                                        |
| `datasource`  | primary, master, main, slave                                                      |
| `pattern`     | 日期格式模板                                                                            |
| `result-type` | int, long, string, boolean, double, float                                         |
| `method`      | replace, contains, startsWith, indexOf, substring 等                               |

**变量补全**: 在 SQL 表达式中输入 `$` 或 `${}` 时，自动补全当前文件中已定义的变量。

**参数补全**: 在 `procedure-call`/`function-call` 标签的 refid 属性补全后，自动列出目标 procedure 的所有参数。

**多语言补全**: 在 XML 内注入的 TinyScript、Funic、SQL 上下文中同样提供代码补全。

#### 3.3 引用跳转 (Reference Navigation)

| 功能           | 说明                                                                              |
|--------------|---------------------------------------------------------------------------------|
| **refid 跳转** | 在 `procedure-call`、`function-call`、`script-include` 标签中，点击 refid 值跳转到对应 id 定义位置 |
| **标签名跳转**    | 点击 XML 标签名跳转到对应的 Java 实现类                                                       |
| **行标记**      | 在行号区域显示 refid 引用目标图标，点击可导航                                                      |
| **ID 互跳**    | XML 中的 id/refid 双向跳转                                                            |

### 4. $变量高亮

对 XML 文件中的 `$变量` 语法提供实时高亮显示：

| 变量类型    | 语法                 | 说明               |
|---------|--------------------|------------------|
| 普通变量    | `${变量名}`           | 标准变量引用           |
| 非空变量    | `$!{变量名}`          | 变量为 null 时返回空字符串 |
| Hash 变量 | `#{变量名}`、`#!{变量名}` | Hash 变量引用        |
| 短变量     | `$变量名`             | 简写形式             |

通过 `DollarVariablesEditorFactoryListener` 实现，空变量（包含 `{}`）使用错误高亮颜色标记。

### 5. 实时模板 (Live Templates)

插件按 `XProc4j` 模板组分类提供丰富的实时模板：

**结构标签模板**：

| 模板缩写              | 生成内容                |
|-------------------|---------------------|
| `<procedure`      | procedure 标签骨架      |
| `<procedure-call` | procedure-call 调用标签 |
| `<script-include` | script-include 引用标签 |
| `<script-segment` | script-segment 片段定义 |

**Java/脚本代码模板**：

| 模板缩写                    | 生成内容                |
|-------------------------|---------------------|
| `<lang-eval-java`       | Java 代码块（带方法签名）     |
| `<lang-eval-groovy`     | Groovy 代码块          |
| `<lang-eval-tinyscript` | TinyScript 代码块      |
| `<lang-eval-js`         | JavaScript 代码块      |
| `<lang-java-import`     | import 语句块          |
| `<lang-java-member`     | 成员变量块               |
| `<lang-java-body`       | 方法体块                |
| `<lang-if`              | if 条件块              |
| `<lang-foreach`         | foreach 循环块         |
| `<lang-try`             | try-catch-finally 块 |
| `<lang-catch`           | catch 块             |
| `<lang-finally`         | finally 块           |

**SQL 操作模板**：

| 模板缩写                 | 生成内容     |
|----------------------|----------|
| `<sql-query-list`    | SQL 查询列表 |
| `<sql-query-row`     | 单行查询     |
| `<sql-query-object`  | 对象查询     |
| `<sql-update`        | 更新语句     |
| `<sql-cursor`        | 游标遍历     |
| `<sql-scope`         | 数据源作用域   |
| `<sql-transactional` | 事务包装     |
| `<sql-etl`           | ETL 操作   |

**并发控制模板**：

| 模板缩写                 | 生成内容 |
|----------------------|------|
| `<lang-async`        | 异步执行 |
| `<lang-async-all`    | 全部异步 |
| `<lang-latch`        | 门闩创建 |
| `<lang-latch-await`  | 门闩等待 |
| `<lang-latch-down`   | 门闩减数 |
| `<lang-synchronized` | 同步块  |

**文件操作模板**：

| 模板缩写                    | 生成内容   |
|-------------------------|--------|
| `<lang-file-read-text`  | 读取文本文件 |
| `<lang-file-write-text` | 写入文本文件 |
| `<lang-file-list`       | 列出文件   |
| `<lang-file-tree`       | 文件树    |
| `<lang-file-exists`     | 检查文件存在 |
| `<lang-file-mkdirs`     | 创建目录   |
| `<lang-file-delete`     | 删除文件   |

**其他模板
**：`<lang-sleep`、`<lang-shell`、`<lang-return`、`<lang-throw`、`<lang-string`、`<lang-render`、`<lang-format-date`、`<lang-format`、`<lang-printf`、`<event-publish`、`<event-send`
等。

### 6. Oracle 语法转换器

将 Oracle 存储过程语法转换为 XProc4J 格式。

- **访问方式**: 右键菜单 → `XProc4J Tools` → `Oracle 2 XProc4J`
- **转换选项**: XProc4J XML 格式 / TinyScript 表达式 / OGNL 表达式
- **实现**: 基于 ANTLR4 解析 Oracle PL/SQL 语法

### 7. 调试支持

插件提供完整的调试能力：

| 功能                | 说明                                                                  |
|-------------------|---------------------------------------------------------------------|
| **断点类型**          | `JdbcProcedureLineBreakpointType`（XML 过程文件断点）                       |
| **位置管理**          | `JdbcProcedurePositionManagerFactory`（调试时自动暂停与源码导航）                 |
| **TinyScript 断点** | `TinyScriptLineBreakpointType` + `TinyScriptPositionManagerFactory` |
| **Funic 断点**      | `FunicLineBreakpointType` + `FunicPositionManagerFactory`           |

### 8. 文件模板

注册 XProc4J 文件模板，创建新文件时可选择 `XProc4J file` 模板（通过 `XProc4jFileTemplateGroupDescriptorFactory`）。

---

## 右键菜单 / Actions

| Action                              | 说明                     | 位置            |
|-------------------------------------|------------------------|---------------|
| **XProc4J Jump Source**             | 跳转到 XML 过程源文件          | 编辑器右键菜单       |
| **TinyScript Function Jump Source** | 跳转到 TinyScript 函数源文件   | 编辑器右键菜单       |
| **XProc4J Tools** (子菜单)             | 工具集                    | 编辑器右键菜单       |
| → **Oracle 2 XProc4J**              | Oracle 语法转换            | XProc4J Tools |
| → **Test XProc4J**                  | 测试 XProc4J 语法          | XProc4J Tools |
| → **Test TinyScript**               | 测试 TinyScript 语法/表达式求值 | XProc4J Tools |
| → **Test Funic**                    | 测试 Funic 语法/表达式求值      | XProc4J Tools |
| → **Test Groovy**                   | 测试 Groovy 语法/表达式求值     | XProc4J Tools |

---

## 源文件结构

```
i2f-jdbc-procedure-idea-plugin/
├── build.gradle.kts                     -- Gradle 构建配置
├── plugin-intro.md                      -- 插件介绍文档
├── src/main/resources/META-INF/
│   └── plugin.xml                       -- 插件配置（注册所有扩展点）
├── src/main/java/i2f/turbo/idea/plugin/
│   ├── jdbc/procedure/                  -- XProc4J XML 核心功能
│   │   ├── reference/                   -- 引用跳转（XmlTagReference、XmlIdRefReference）
│   │   ├── dollar/                      -- $变量高亮
│   │   ├── debugger/                    -- 调试支持（断点、位置管理）
│   │   ├── JdbcProcedureXmlLangInjectInjector    -- 多语言注入器
│   │   ├── JdbcProcedureXmlCompletionContributor  -- XML 代码补全
│   │   ├── AnyHelpXmlCompletionContributor        -- 通用帮助补全
│   │   ├── JdbcProcedureDomFileDescription         -- DOM 文件描述
│   │   ├── JdbcProcedureRefidLineMarkerProvider    -- refid 行标记
│   │   ├── Oracle2Xproc4jConvertAction             -- Oracle 转换
│   │   ├── XProc4jFileTemplateGroupDescriptorFactory -- 文件模板
│   │   ├── XProc4jLiveTemplatesProvider              -- Live Templates
│   │   └── ...（Action 类）
│   ├── tinyscript/                      -- TinyScript 语言支持
│   │   ├── TinyScriptLanguage.java      -- 语言定义
│   │   ├── TinyScriptFileType.java      -- 文件类型
│   │   ├── TinyScriptConsts.java        -- 常量定义
│   │   ├── grammar/                     -- 语法（BNF/Flex 生成的 Parser/Lexer）
│   │   ├── lang/                        -- 语言功能
│   │   │   ├── highlighter/             -- 语法高亮
│   │   │   ├── comment/                 -- 注释
│   │   │   ├── bracket/                 -- 括号配对
│   │   │   ├── completion/              -- 代码补全
│   │   │   ├── formatter/               -- 格式化
│   │   │   ├── debugger/                -- 调试
│   │   │   └── live/templates/          -- Live Templates
│   │   └── grammar/psi/elements/        -- PSI 元素（语法树节点）
│   ├── funic/                           -- Funic 语言支持（结构同 tinyscript/）
│   │   ├── FunicLanguage.java
│   │   ├── FunicFileType.java
│   │   ├── FunicConsts.java
│   │   ├── grammar/
│   │   ├── lang/
│   │   └── grammar/psi/elements/
│   ├── groovy/                          -- Groovy 测试 Action
│   └── inject/                          -- 项目级语言模板注入
└── src/main/resources/assets/           -- 图标等资源
```

**PSI 元素规模**：

- TinyScript: 约 80 个 PSI 元素类
- Funic: 约 100 个 PSI 元素类（比 TinyScript 多出 Lambda、go/await、import、synchronized 等语法节点）

---

## 安装与使用

### 安装步骤

1. 打开 IDEA 菜单栏：`File` → `Settings` → `Plugins`
2. 点击设置图标 → `Install Plugin from Disk...`
3. 选择插件 JAR 文件
4. 点击 `OK` 并重启 IDEA

### 验证安装

1. 在 `Settings` → `Plugins` → `Installed` 中搜索 `XProc4J`
2. 打开任意 `procedure.xml` 文件，检查：
    - SQL 标签中的关键字是否变色
    - 输入 `$` 是否有变量补全提示
    - 标签名是否有导航标记
3. 打开 `.tis` 或 `.fic` 文件，验证语法高亮

---

## 注意事项

1. **功能完整性**: 插件提供的提示和补全功能可能不完全，实际运行结果以框架执行为准
2. **错误提示**: 插件标记的错误有时可能是误报，请以实际运行结果为准
3. **版本兼容性**: 建议使用 IDEA 2023.2 及以上版本以获得最佳体验
4. **独立构建**: 插件使用 Gradle 构建，独立于主项目的 Maven 体系，但共用代码仓库

---

## 官方文档

| 文档   | 路径                                                                                |
|------|-----------------------------------------------------------------------------------|
| 插件介绍 | `i2f-tools/i2f-jdbc-procedure-idea-plugin/plugin-intro.md`                        |
| 插件配置 | `i2f-tools/i2f-jdbc-procedure-idea-plugin/src/main/resources/META-INF/plugin.xml` |
| 构建配置 | `i2f-tools/i2f-jdbc-procedure-idea-plugin/build.gradle.kts`                       |

## 交叉引用

| 文档                                            | 说明                       |
|-----------------------------------------------|--------------------------|
| [XProc4J 框架 Wiki](xproc4j-framework.md)       | 插件所服务的框架                 |
| [TinyScript 引擎 Wiki](tinyscript-framework.md) | 插件支持的脚本语言                |
| [Funic 引擎 Wiki](funic-framework.md)           | 插件支持的脚本语言（TinyScript 替代） |
