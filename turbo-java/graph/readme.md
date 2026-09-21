# 仓库全景地图

> 使用标准svg技术，从各个方面绘制本仓库的能力全景地图，并通过连接引用到本文档中，形成完善的全景一览地图

## 编写标准

- svg 文件存放路径：./imgs
- svg 文件命名规范：{序号}-{全英文snake命名的内容小标题}.svg

## 全景预览

> 以下 19 张 SVG 全景地图从不同维度刻画本仓库的能力版图，全部基于 [`.wiki/wiki.md`](../wiki.md) 与仓库实测数据绘制。点击标题可跳转，图片可直接内嵌预览。
>
> - **01–08 全局维度**：架构、模块组、分层能力、装配体系、设计范式、技术栈。
> - **09–10 度量维度**：规模量化仪表盘与依赖治理拓扑。
> - **11–14 子系统细化**：AI 能力栈、序列化/编解码族谱、加密与安全、数据/JDBC 管线。
> - **15–19 关键框架细化**：XProc4J 编排、脚本引擎(Funic/TinyScript/ANTLR4)、统一文件系统、图形学与图像、JNI 原生调用。

### 地图索引

| # | 全景地图 | 维度 | 关注点 |
| --- | --- | --- | --- |
| 01 | [分层依赖架构](#01-分层依赖架构) | 纵向分层 | 6 层依赖栈、各层规模 |
| 02 | [顶级模块组版图](#02-顶级模块组版图) | 横向分布 | 8 大组、约 320 子模块 |
| 03 | [i2f-jdk 能力分类](#03-i2f-jdk-核心能力分类) | 基础层能力 | 152 子模块的约 30 类能力 |
| 04 | [第三方集成](#04-第三方扩展集成) | 扩展层能力 | 86 扩展模块、集成域 |
| 05 | [Spring Starter 体系](#05-spring-starter-体系) | 上层装配 | spring / boot / cloud 三栈 |
| 06 | [关键框架能力](#06-关键框架能力) | 旗舰能力 | 12 面跨模块框架 |
| 07 | [std/impl 契约范式](#07-stdimpl-契约分层范式) | 设计范式 | 接口-实现分离落地 |
| 08 | [技术栈与依赖治理](#08-技术栈与构建依赖治理) | 工程基座 | 版本 / 构建 / 治理策略 |
| 09 | [规模度量仪表盘](#09-规模度量仪表盘) | 量化度量 | LOC / 类文件 / 各组占比 |
| 10 | [聚合与依赖治理拓扑](#10-聚合与依赖治理拓扑) | 依赖治理 | 分层流向 / *-all 聚合 / provided |
| 11 | [AI 能力栈](#11-ai-能力栈) | 子系统细化 | 契约→引擎→MCP→JDK17 spring-ai |
| 12 | [序列化/编解码族谱](#12-序列化编解码契约族谱) | 子系统细化 | 契约继承链 + 多 JSON 引擎 |
| 13 | [加密与安全](#13-加密与安全) | 子系统细化 | crypto / 国密 / JCE / 认证防火墙 |
| 14 | [数据/JDBC 管线](#14-数据jdbc-管线) | 子系统细化 | JDBC→查询→元数据→引擎→集成 |
| 15 | [XProc4J 编排](#15-xproc4j-存储过程编排) | 关键框架细化 | XML 过程/多语言混编/生产迁移 |
| 16 | [脚本引擎](#16-脚本引擎-antlr4-funic-tinyscript) | 关键框架细化 | ANTLR4 基座 + Funic/TinyScript |
| 17 | [统一文件系统](#17-统一文件系统抽象) | 关键框架细化 | IFileSystem 契约 + 7 后端 |
| 18 | [图形学与图像](#18-图形学与图像处理) | 关键框架细化 | 2D/3D 渲染引擎 + 视觉扩展 |
| 19 | [JNI 原生调用](#19-jni-原生调用体系) | 关键框架细化 | Win32/EasyX/Launcher |

---

### 01 分层依赖架构

自底向上的六层依赖栈：`i2f-jdk → i2f-jdk-ext → i2f-spring → i2f-extension → i2f-springboot → i2f-springcloud`，上层依赖下层；`i2f-tools`、`i2f-spring-ai` 独立构建。

- 分层依赖架构全景

```svg
link:./imgs/01-layered_architecture.svg
```

### 02 顶级模块组版图

8 大模块组、约 320 个子模块的能力分布与规模一览，逐组列出代表性能力。

- 顶级模块组能力版图全景

```svg
link:./imgs/02-module_landscape.svg
```

### 03 i2f-jdk 核心能力分类

核心基础层 `i2f-jdk`（152 子模块）按能力域归类的地图，命名遵循 `{功能}-std` / `{功能}-impl` 契约分离。

- i2f-jdk 核心能力分类全景

```svg
link:./imgs/03-jdk_capabilities.svg
```

### 04 第三方扩展集成

扩展层 `i2f-extension`（86 模块）按集成域划分的全景，多数三方依赖以 `provided` 引入、运行时自备。

- 第三方扩展集成全景

```svg
link:./imgs/04-extension_integrations.svg
```

### 05 Spring Starter 体系

`i2f-spring`（Framework 封装）→ `i2f-springboot`（自动装配 Starter）→ `i2f-springcloud`（微服务治理 Starter）三栈能力对照。

- Spring Starter 体系全景

```svg
link:./imgs/05-spring_starter_system.svg
```

### 06 关键框架能力

由跨模块协作形成的 12 面旗舰能力（XProc4J、TinyScript→Funic、AI 工具链、统一文件系统、SQL 绑定/BQL、数据库元数据、日志、Mixin、图形学、JNI、声明式 HTTP、运维/追踪）。

- 关键框架能力全景

```svg
link:./imgs/06-key_frameworks.svg
```

### 07 std/impl 契约分层范式

项目核心架构约定：接口（`-std`）定义契约、实现（`-impl` / 扩展 / Spring）提供能力，单向依赖、可替换、按需引入，并汇总全仓契约-实现配对。

- std-impl 契约分层范式全景

```svg
link:./imgs/07-std_impl_pattern.svg
```

### 08 技术栈与构建依赖治理

根 `pom.xml` 统一治理下的技术栈版本、Maven 构建插件、依赖管理策略与项目七大特性。

- 技术栈与构建依赖治理全景

```svg
link:./imgs/08-tech_stack.svg
```

### 09 规模度量仪表盘

按 `src/main/java` 实测的量化视图：全仓约 348K 行 / ~3574 类文件 / 324 pom；`i2f-jdk` 独占约 52% 代码量，是仓库绝对重心；各组 LOC/类数/模块数横向对比。

- 仓库规模度量仪表盘

```svg
link:./imgs/09-metrics_dashboard.svg
```

### 10 聚合与依赖治理拓扑

自底向上的单向依赖流向、`*-all` 聚合包边界（jdk / jdk-ext / extension / spring）、std→impl 契约分层，以及 `i2f-extension` 实测的 `provided`=159 / `optional`=76 依赖作用域治理。

- 聚合与依赖治理拓扑全景

```svg
link:./imgs/10-dependency_aggregation.svg
```

### 11 AI 能力栈

从契约到应用的完整 AI 栈：`i2f-ai-std` 契约 → openai / dashscope / langchain4j 多引擎适配 + RAG(sqlite) → `springboot-ai-*`（Starter + MCP client/server）→ JDK17 独立构建的 `i2f-spring-ai`（alibaba-starter / sse-mcp-server）。

- AI 能力栈分层全景

```svg
link:./imgs/11-ai_stack.svg
```

### 12 序列化/编解码契约族谱

`i2f-serialize-std` 的五层接口继承链（ICodec→ISerializer→ITypeSerializer→IString*→IJsonSerializer），以及 Jackson / Gson / fastjson / fastjson2 / fory-json 五个「一契约多引擎」并列实现与 codec 编解码子族。

- 序列化编解码契约族谱

```svg
link:./imgs/12-serialize_codec_family.svg
```

### 13 加密与安全

三条安全主线：通用密码（`crypto-std↔impl`）、国密（`sm-crypto` + `jce-sm-antherd`）、身份与边界（`authentication` + `firewall` + `otpauth`）；JCE Provider 可插拔与 Spring 侧 Starter 装配。

- 加密与安全能力全景

```svg
link:./imgs/13-crypto_security.svg
```

### 14 数据/JDBC 管线

数据访问全链闭环：JDBC 抽象与执行 → 查询构建（BQL / BindSQL / sqlparser）→ 元数据与方言 → 多存储引擎（MyBatis / Redis 一契约双实现 / ES / Mongo / Hazelcast）→ 数据集成（DataX / Flink）→ Spring Boot 数据 Starter。

- 数据-JDBC 管线全景

```svg
link:./imgs/14-data_jdbc_pipeline.svg
```

### 15 XProc4J 存储过程编排

基于 XML 的 JDBC 存储过程编排框架全景：`extension-xproc4j` 引擎 + `i2f-jdbc-procedure` 基座 + `xproc4j-starter` 装配，支持 Java/Groovy/OGNL/TinyScript/Funic/JavaScript 多语言混编，一键 `enable-funic` 切换，并附生产迁移数据（500+ 系统 / 12 万+ 行 / 日调度 2000+）。

- XProc4J 存储过程编排全景

```svg
link:./imgs/15-xproc4j_orchestration.svg
```

### 16 脚本引擎 ANTL4 Funic TinyScript

一个 ANTLR4 运行时基座承载三门 DSL：`Funic`（TinyScript 的增强替代，`.fic` / 575 行文法 / Lambda·go-await·沙箱）与 `TinyScript`（旧，`.tis` / 397 行），函数能力均来自 `i2f-mixins` 的 `AllMixins`。

- 脚本引擎 ANTLR4-Funic-TinyScript 全景

```svg
link:./imgs/16-script_funic_engine.svg
```

### 17 统一文件系统抽象

一份 `IFileSystem` / `IFile` 契约收敛 7 种存储后端：本地 `JdkFileSystem` 与 FTP / SFTP（含代理）/ HDFS / MinIO / 阿里云 OSS / AWS S3，接口→抽象类→实现分层，内建路径遍历防护与跨系统透明搬运。

- 统一文件系统抽象全景

```svg
link:./imgs/17-filesystem_abstraction.svg
```

### 18 图形学与图像处理

纯 Java 图形栈 `graphics-2d`（几何原语/投影/仿射变换/函数绘制）→ `graphics-3d`（渲染管线/12 几何体/10 投影/Phong 光照/20+ 材质），配合 `image-std↔impl`、`color`，以及 extension 侧 OpenCV / OCR / 二维码 / GIF 视觉扩展。

- 图形学与图像处理全景

```svg
link:./imgs/18-graphics_imaging.svg
```

### 19 JNI 原生调用体系

`native-core` 指针基座 → `native-windows` 双层封装（`NativesWindows` 918 行 + `WinApi` 3487 行，覆盖 20+ 类 Win32、94 常量类、50 句柄类）→ `native-windows-easyx` 图形；辅以 `i2f-launcher` 动态 Classpath 与 `agent` 字节码增强。

- JNI 原生调用体系全景

```svg
link:./imgs/19-native_jni.svg
```
