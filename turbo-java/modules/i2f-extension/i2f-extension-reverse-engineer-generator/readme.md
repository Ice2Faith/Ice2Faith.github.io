# i2f-extension-reverse-engineer-generator

> 数据库反向工程与代码生成模块，基于 Velocity 模板引擎，将数据库表结构或 Spring MVC API 元数据反向生成 SSM/SSMP 分层代码、建表 DDL、表结构设计文档、API 设计文档以及多种 ER 图（draw.io / xmlpainter）。

## 模块路径

- `i2f-extension/i2f-extension-reverse-engineer-generator`

## 模块依赖

| GroupId | ArtifactId | Scope | Optional | 说明 |
|---------|-----------|-------|----------|------|
| i2f.turbo | i2f-database-metadata-impl | compile | false | 数据库元数据提供者，从 JDBC 连接读取表/列结构 |
| i2f.turbo | i2f-database-metadata-bean | compile | false | 从 Java Bean 类解析 `TableMeta` |
| i2f.turbo | i2f-spring-mvc-metadata | compile | false | 解析 Spring MVC API 元数据（`ApiMethod`/`ModuleController`） |
| i2f.turbo | i2f-resources | compile | false | 类路径资源读取（加载 `.vm` 模板） |
| i2f.turbo | i2f-serialize-impl | compile | false | XML 序列化/转义（`Xml2.toXmlString`） |
| i2f.turbo | i2f-text | compile | false | 字符串工具（`StringUtils`） |
| i2f.turbo | i2f-extension-velocity | compile | false | Velocity 模板渲染封装（`VelocityGenerator`） |
| org.projectlombok | lombok | compile | false | 编译期代码生成（@Data） |
| org.springframework | spring-core / context / web / webmvc | provided | true | Spring 运行时（可选，仅 API 解析用到） |
| io.swagger | swagger-annotations | provided | true | Swagger 注解（可选） |
| org.apache.velocity | velocity-engine-core | provided | true | Velocity 引擎（由 i2f-extension-velocity 提供） |
| com.mysql | mysql-connector-j | provided | true | MySQL 驱动（示例/测试反查数据库用） |

## 模块设计

### 架构设计

本模块采用 **统一入口 + 上下文模型 + 模板渲染** 的三层架构：

- **入口层**（`ReverseEngineerGenerator`）：所有生成能力的静态门面（Facade），负责输入源归一化（`Connection` / `Class` Bean / `TableMeta` / `ApiMethod` / `ModuleController`）并委派给渲染或适配器。
- **上下文模型层**（`database` 包 + `er` 各子包的 Context）：将原始元数据（`TableMeta`、`ColumnMeta`）转换为模板友好的数据结构，做类型名简化、主键提取等预处理。
- **渲染层**（`i2f-extension-velocity` 的 `VelocityGenerator` + `resources/tpl` 模板）：以 Velocity 模板产出最终代码/文档/图。

### 包结构

```
i2f.extension.reverse.engineer.generator
├── ReverseEngineerGenerator          # 统一生成门面（入口）
├── database/                          # 数据库代码生成上下文
│   ├── TableContext                   # 表上下文（列、主键、注释）
│   ├── ColumnContext                  # 列上下文（类型名简化）
│   ├── PrimaryContext                 # 主键上下文（默认 id / Long）
│   └── JavaCodeContext                # 代码生成配置（包名、author、restful、lombok、swagger 等）
└── er/                                # ER 图生成器（三个版本）
    ├── er0/drawio/                    # 实体框图（表级别，8 列网格布局）
    │   ├── DatabaseEr0DrawIoGenerator
    │   └── DatabaseEr0TableContext
    ├── er1/                           # 实体-属性关系图
    │   ├── drawio/                    # draw.io 输出（含 link 连线）
    │   │   ├── DatabaseEr1DrawIoAdapter
    │   │   └── DrawIoErElem
    │   └── xmlpainter/                # XML-Painter 输出
    │       ├── ErContext / ErEntity / ErAttribute / ErLine
    └── er2/drawio/                    # 表结构内嵌 HTML 的 drawio 图
        ├── DatabaseEr2DrawIoGenerator
        └── DatabaseEr2TableContext
```

### 模板资源组织（`src/main/resources/tpl`）

| 目录 | 用途 | 代表模板 |
|------|------|----------|
| `tpl/code/java/ssm` | SSM（SpringMVC+Spring+MyBatis）分层代码 | controller / do / vo / mapper / service / service-impl / mapper-xml |
| `tpl/code/java/ssmp` | SSMP（含 MyBatis-Plus）分层代码 | 同上，适配 BaseMapper 风格 |
| `tpl/code/java/api` | API 请求/响应对象 | ApiCode / ApiPage / ApiResp |
| `tpl/code/vue` | 前端页面 | view.vue |
| `tpl/code/web` | Web API 文档 | api.md |
| `tpl/ddl` | 建表语句 | table-ddl.mysql.sql.vm / table-ddl.oracle.sql.vm |
| `tpl/design` | 设计文档 | table-design / api-design / module-design (html.vm) |
| `tpl/table` | 表结构文档 | table-struct.html.vm |
| `tpl/api` | API 交互文档 | api.html.vm |
| `tpl/er/er{0,1,2}` | 三种 ER 图模板 | er-x.xml.drawio.vm / er-1.xml.vm |

### 核心设计模式

1. **门面模式（Facade）**：`ReverseEngineerGenerator` 以静态方法统一暴露所有生成能力，屏蔽输入源差异。同一能力（如 `generate`/`tablesDoc`/`er1`）对 `TableMeta`、`Connection`、`Class<?>` Bean 三种输入提供重载。

2. **适配器模式（Adapter）**：`DatabaseEr1DrawIoAdapter` 将 `TableMeta` 集合适配为 draw.io 图元素列表（entity/attribute/link），解耦元数据与图布局。

3. **上下文对象模式**：`TableContext`/`ColumnContext`/`ErContext` 等在渲染前对原始元数据做预处理（如 `java.lang.` 前缀剥离、`Timestamp → Date` 归一），使模板保持简洁。

4. **模板方法（渲染流程）**：各生成方法遵循「加载模板 → 构建参数 Map → `VelocityGenerator.render`」固定流程。

### ER 图布局算法

三种 ER 版本采用不同的网格布局参数避免节点重叠：

- **er0**：按 8 列换行（`x*140`, `y*80`），仅绘制表级实体框。
- **er1**：纵向堆叠（每表 `y+=200`，属性横向 `x+=100`），并用 link 元素连接实体与属性。
- **er2**：按 5 列换行（`x*320`, `y*320`），每个表框内嵌 HTML 渲染完整列结构，高度按列数动态计算（`50 + 25*列数`）。

## 模块目的

1. **降低重复劳动**：从已有数据库表或 Bean 一键生成分层 CRUD 代码骨架，保持团队代码风格统一。
2. **文档自动化**：由真实表结构与 API 元数据直接产出设计文档、DDL、ER 图，避免文档与实现脱节。
3. **多输入源统一**：数据库连接、Java Bean、`TableMeta`、Spring MVC Controller 均可作为同一套生成流程的输入。
4. **可扩展模板**：所有产物由外置 Velocity 模板驱动，替换/新增模板即可定制生成结果，无需改动 Java 代码。

## 模块功能

| 分类 | 入口方法 | 输出 |
|------|----------|------|
| 单表代码生成 | `generate(TableMeta/Connection/Class, template, JavaCodeContext)` | 渲染后的字符串（如某个 .java） |
| 批量代码生成 | `batch(..., templatePath, outputPath, codeCtx)` | 写入目标目录的多个文件 |
| 表设计文档 | `tablesDesignDoc(tables)` | HTML 表设计文档 |
| 表结构文档 | `tablesStructDoc(tables)` | HTML 表结构文档 |
| 建表 DDL | `tablesDdlMysql` / `tablesDdlOracle` | MySQL / Oracle DDL 脚本 |
| API 设计文档 | `apisDesign(apis)` | HTML API 设计文档 |
| MVC API 解析 | `apiMvc` / `apiMvcs` / `apiMethod` / `apiVo` | 由 Controller/VO/Method 渲染 API 文档 |
| 全量 Controller 文档 | `apisDesignMvcControllers(context)` / `apisDesignMvcSameComments(context)` | 扫描 Spring 上下文生成 API 文档（含注释补全） |
| 模块设计文档 | `modulesDesignMvc(...)` / `modulesDesignMvcControllers(context)` | 模块级设计文档 |
| ER 图（er0/er1/er2） | `er0DrawIo` / `er1DrawIo` / `er1XmlPainter` / `er2DrawIo` | draw.io / xmlpainter ER 图 |

## 模块主要使用方法

### 1. 从数据库表生成代码

```java
Connection conn = JdbcResolver.getConnection(driver, url, user, pwd);
JavaCodeContext codeCtx = new JavaCodeContext();
codeCtx.setPkg("com.example.demo");
codeCtx.setAuthor("dev");

// 生成单个模板（如 controller.java.vm）
String template = ResourceUtil.getClasspathResourceAsString("tpl/code/java/ssm/controller.java.vm", "UTF-8");
String java = ReverseEngineerGenerator.generate(conn, "t_user", template, codeCtx);

// 批量渲染整个模板目录到输出路径
ReverseEngineerGenerator.batch(conn, "t_user", "tpl/code/java/ssm", "./output", codeCtx);
```

### 2. 从 Java Bean 生成

```java
// 无需数据库，直接由实体类反推 TableMeta
String java = ReverseEngineerGenerator.generate(UserBean.class, template, codeCtx);
```

### 3. 生成数据库设计文档 / DDL / ER 图

```java
List<TableMeta> tables = provider.getTables(conn, "test_db").stream()
        .map(t -> provider.getTableInfo(conn, t.getDatabase(), t.getName()).fillColumnIndexMeta())
        .collect(Collectors.toList());

ReverseEngineerGenerator.tablesDesignDoc(tables);   // 表设计文档 HTML
ReverseEngineerGenerator.tablesDdlMysql(tables);    // MySQL 建表语句
ReverseEngineerGenerator.er1DrawIo(tables);         // draw.io ER 图
```

### 4. 从 Spring MVC 生成 API / 模块文档

```java
// 单个 Controller
String apiHtml = ReverseEngineerGenerator.apiMvc(UserController.class, tpl);

// 扫描整个 Spring 上下文的所有 Controller（可选 filter 与预处理器）
String doc = ReverseEngineerGenerator.modulesDesignMvcControllers(applicationContext);
```

### 注意事项

- Velocity、Spring、MySQL 驱动均为 `provided` + `optional`，需由运行环境（宿主工程）提供实际依赖。
- 模板路径以类路径资源加载（`ResourceUtil.getClasspathResourceAsString`），自定义模板需放在 `tpl/` 下并保持参数键（`table`/`code`/`apis`/`modules`/`elems`/`er`/`tables`）一致。
- `JavaCodeContext` 的开关（`restful`、`lombok`、`swagger`、`pageHelper`、`beanCopy` 等）直接控制生成代码风格，模板内通过 `code.xxx` 读取。
- API 文档渲染前会对 `typeName`/`comment` 做 `Xml2.toXmlString` 转义，避免 HTML 注入。

## 模块特性总结

- **多输入源统一门面**：`Connection`、`Class` Bean、`TableMeta`、`ApiMethod`、`ModuleController` 均可驱动生成。
- **双代码框架模板**：同时支持 SSM 与 SSMP（MyBatis-Plus）两套分层代码模板，覆盖 controller/vo/do/mapper/service。
- **前后端 + 文档全覆盖**：Java 代码、Vue 页面、API/模块/表设计文档、DDL、ER 图一站式生成。
- **三种 ER 图实现**：er0（简洁实体框）、er1（实体-属性关系，drawio + xmlpainter 两种输出）、er2（内嵌表结构 HTML），适配不同绘图工具。
- **模板外置可定制**：所有产物由 `resources/tpl` 下 Velocity 模板驱动，替换模板即改生成结果。
- **Spring 上下文批量扫描**：`apisDesignMvcControllers` / `modulesDesignMvcControllers` 支持过滤 + 预处理器（如同名参数注释补全）回调。
- **元数据预处理**：类型名简化、主键默认值、XML 转义等在上下文模型中完成，模板保持轻量。
