# Ops Starter — 运维控制台 Wiki

## 概述

`i2f-springboot-ops-starter` 是一个开箱即用的 SpringBoot 运维控制台 Starter，引入依赖后自动注册一组 Web
管理页面，提供应用诊断、主机操作、数据库管理、Redis/ElasticSearch 操作、对象存储管理、AI 对话、定时任务执行等 13+
个功能模块。所有前端资源（Vue 2 + Element UI）打包在 JAR 内，无需额外部署前端服务。

- **模块路径**: `i2f-springboot/i2f-springboot-ops-starter`
- **ArtifactId**: `i2f-springboot-ops-starter`
- **父模块**: `i2f-springboot`
- **版本**: `1.0-jdk8`
- **基础包名**: `i2f.springboot.ops`
- **访问入口**: `http://{host}:{port}/ops/`

## 模块定位

Ops Starter 是项目的**运维/运营一体化控制台**，将项目各核心模块（数据库、AI、XProc4J、文件系统等）的管理能力统一聚合到一个 Web
界面中。通过 SpringBoot 自动装配，引入 Starter 即可获得完整运维能力。

### 核心特性

1. **开箱即用** — 引入 Starter 即可访问 `/ops/` 控制台，所有功能自动注册
2. **条件装配** — 各功能模块基于 `@ConditionalOnClass` 按需激活，无相关依赖则自动跳过
3. **国密安全传输** — 所有 API 通信采用 SM2/SM3/SM4 国密算法加密，防篡改、防重放
4. **多主机代理** — 支持通过 HostId 机制跨主机代理操作，统一管理多台服务器
5. **前端内嵌** — Vue 2 + Element UI 前端打包在 JAR 内，无需独立部署
6. **SPI 扩展** — 通过 `IOpsProvider` 接口，各模块自动注册菜单项到控制台首页

## 依赖关系

### 核心依赖

| 依赖                                    | 说明                |
|---------------------------------------|-------------------|
| `i2f-sm-crypto`                       | 国密 SM2/SM3/SM4 加密 |
| `i2f-jdbc-impl`                       | JDBC 实现（数据库操作）    |
| `i2f-database-metadata-impl`          | 数据库元数据（元数据查看）     |
| `i2f-os`                              | OS 工具（命令执行）       |
| `i2f-network`                         | 网络工具（主机代理）        |
| `i2f-jdk-ext-web`                     | Web 扩展（文件上传下载）    |
| `i2f-extension-sftp`                  | SFTP（SSH 远程操作）    |
| `i2f-extension-groovy`                | Groovy（脚本执行）      |
| `i2f-extension-filesystem-minio`      | MinIO 文件系统        |
| `i2f-extension-filesystem-oss-aws-s3` | AWS S3 文件系统       |
| `i2f-extension-elasticsearch`         | ElasticSearch 封装  |
| `i2f-rowset`                          | 行集（CSV 导入导出）      |
| `i2f-ai-std`                          | AI 标准定义           |
| `i2f-ai-rest-openai`                  | OpenAI 兼容实现       |
| `i2f-spring-web`                      | Spring Web 集成     |
| `i2f-uid-impl`                        | UID 生成            |

### 可选依赖（provided，按需激活功能）

| 依赖                                                               | 激活功能            |
|------------------------------------------------------------------|-----------------|
| `spring-boot-starter-web`                                        | Web 控制器         |
| `spring-boot-starter-jdbc`                                       | 数据库操作           |
| `spring-boot-starter-data-redis` + `jedis`                       | Redis 操作        |
| `redisson-spring-boot-starter`                                   | Redisson 分布式锁   |
| `dynamic-datasource-spring-boot-starter` (3.5.2)                 | 多数据源            |
| `xxl-job-core` (2.4.1)                                           | XXL-JOB 任务调度    |
| `h2` (2.2.224)                                                   | H2 数据库          |
| `jsch` (0.1.55)                                                  | SSH/SFTP        |
| `groovy` (4.0.18)                                                | Groovy 脚本执行     |
| `minio` (7.1.0)                                                  | MinIO 对象存储      |
| `software.amazon.awssdk:s3/kms/s3control` (2.17.100)             | AWS S3          |
| `elasticsearch` + `elasticsearch-rest-high-level-client` (7.6.2) | ES 搜索引擎         |
| `jsqlparser` (4.9)                                               | SQL 解析验证        |
| `nashorn-core` (15.4)                                            | JavaScript 引擎   |
| `sm-crypto` (0.3.2.1-RELEASE)                                    | 国密算法            |
| `lunar` (1.3.14)                                                 | 农历/日历           |
| `spring-cloud-starter`                                           | Spring Cloud 集成 |

## 安全传输体系

所有 Ops API 通信采用国密算法加密传输，确保运维操作的安全性。

### 加密流程

```
请求端:
  1. 生成随机 SM4 密钥 (randomKey)
  2. SM2 公钥加密 randomKey → key
  3. SM4 加密 JSON 请求体 → payload
  4. SM3 哈希(timestamp + nonce + key + payload) → sign
  5. SM2 私钥签名 sign → digital

响应端:
  1. 验证 timestamp 时效（12 小时窗口）
  2. 重算 SM3 哈希，校验 sign
  3. SM2 验签 digital → 确认 sign 合法
  4. SM2 私钥解密 key → randomKey
  5. SM4 解密 payload → 原始 JSON
```

### 核心类

| 类                            | 说明                                                 |
|------------------------------|----------------------------------------------------|
| `OpsSecureTransfer`          | 加解密核心组件，`send()` 加密响应 / `recv()` 解密请求              |
| `OpsSecureDto`               | 加密传输 DTO（timestamp/nonce/key/payload/sign/digital） |
| `OpsSecureReturn`            | 统一响应包装（code/msg/data + useMillSeconds + hostId）    |
| `OpsSecureKeyPair`           | SM2 密钥对                                            |
| `OpsSecureCertPair`          | 证书对（serverCert/clientCert）                         |
| `OpsSecureHelper`            | 证书生成/序列化/反序列化工具                                    |
| `OpsSecureAutoConfiguration` | 自动配置：未配置证书时自动生成并打印                                 |
| `OpsSecureProperties`        | 配置属性 `i2f.springboot.ops.secure.cert`              |

### 配置

```yaml
i2f:
  springboot:
    ops:
      secure:
        cert: # SM2 证书，留空则自动生成
```

## 主机身份与代理

### HostId 机制

`HostIdHelper` 自动计算当前主机标识（格式：`port@[IP#网卡名]`），用于：

- 请求来源校验（防止请求发往错误主机）
- 多主机代理（请求转发到目标主机执行）

### 代理转发

`HostIdProxyHelper` 支持当请求的 HostId 与当前主机不匹配时，自动通过 HTTP 转发到目标主机执行并返回结果，实现**跨主机统一管理
**。

## 功能模块一览

### 1. 控制台首页（Home）

- **路径**: `/ops/`
- **控制器**: `OpsHomeController`
- **前端**: `static/ops/index.html`（Vue 2 + Element UI）
- **功能**: 聚合所有 `IOpsProvider` 实现的菜单项，分组展示，支持搜索过滤
- **菜单分组**: Default / App / Host / SQL / NoSQL / Oss / AI / Schedule / Component

### 2. 应用管理（App）

- **路径**: `/ops/app/`
- **控制器**: `AppOpsController` / `AppEvalOpsController` / `AppCloudOpsController`
- **前端**: `static/ops/app/index.html`（1924 行）
- **功能**:

| 接口                   | 说明                                    |
|----------------------|---------------------------------------|
| `/hostId`            | 获取当前主机标识                              |
| `/system-properties` | 查看 JVM 系统属性                           |
| `/system-env`        | 查看系统环境变量                              |
| `/input-arguments`   | 查看 JVM 启动参数                           |
| `/logging-level/set` | 动态修改日志级别                              |
| `/class-metadata`    | 查看类元数据（字段/方法/继承）                      |
| `/locked-threads`    | 检测死锁线程                                |
| `/beans`             | 列出所有 Spring Bean                      |
| `/eval`              | 执行 Groovy 脚本（可访问 context/beanMap/env） |

### 3. 主机管理（Host）

- **路径**: `/ops/host/`
- **控制器**: `HostOpsController`（505 行）
- **前端**: `static/ops/host/index.html`（1823 行）
- **功能**:

| 接口           | 说明                   |
|--------------|----------------------|
| `/workdir`   | 获取工作目录               |
| `/file-list` | 文件列表（支持通配符过滤）        |
| `/cmd`       | 执行系统命令（支持脚本模式，可配置超时） |
| `/upload`    | 上传文件（MD5 校验）         |
| `/download`  | 下载文件                 |
| `/delete`    | 删除文件/目录              |
| `/mkdirs`    | 创建目录                 |
| `/tail`      | 查看文件末尾 N 行           |
| `/head`      | 查看文件开头 N 行           |

### 4. SSH 远程管理（SSH）

- **路径**: `/ops/ssh/`
- **控制器**: `SshOpsController`（564 行）
- **条件**: `@ConditionalOnClass(ChannelSftp.class)`
- **前端**: `static/ops/ssh/index.html`
- **功能**: 通过 SFTP 连接远程主机，提供与 Host 模块一致的远程文件浏览/上传/下载/删除/命令执行能力

### 5. 数据库管理（Database）

- **路径**: `/ops/datasource/`
- **控制器**: `DatasourceOpsController`（489 行）/ `DatasourceOpsMetadataController`（141 行）
- **条件**: `@ConditionalOnClass(DataSource.class)`
- **前端**: `static/ops/datasource/index.html`（3451 行）
- **功能**:

| 接口             | 说明                 |
|----------------|--------------------|
| `/drivers`     | 列出可用 JDBC 驱动       |
| `/datasources` | 列出可用数据源            |
| `/query`       | 执行 SQL 查询（支持多数据源）  |
| `/export`      | 导出查询结果为 CSV        |
| `/import`      | 导入 CSV 数据          |
| `/run`         | 执行 SQL 脚本（DDL/DML） |
| `/metadata/*`  | 查看数据库元数据（表/列/索引等）  |

**数据源提供者**:

- `DefaultDatasourceProvider` — 自动发现 Spring 管理的 DataSource
- `DefaultDatasourceCollector` — 收集 Spring 数据源 + 配置数据源
- `BaomidouDynamicDatasourceCollector` — 兼容 Baomidou 动态数据源
- `StaticDatasourceCollector` — 收集静态配置的数据源

### 6. Redis 管理

- **路径**: `/ops/redis/`
- **控制器**: `RedisOpsController`（383 行）
- **条件**: `@ConditionalOnClass(RedisTemplate.class)`
- **前端**: `static/ops/redis/index.html`
- **功能**:

| 接口        | 说明                                            |
|-----------|-----------------------------------------------|
| `/scan`   | SCAN 扫描键                                      |
| `/keys`   | KEYS 模式匹配                                     |
| `/get`    | 获取值（含 TTL）                                    |
| `/set`    | 设置值（含过期时间）                                    |
| `/del`    | 删除键                                           |
| `/type`   | 查看键类型                                         |
| `/hash/*` | Hash 操作（hget/hset/hdel/hkeys/hvals/hgetall）   |
| `/list/*` | List 操作（lrange/lpush/rpush/lpop/rpop/llen）    |
| `/set/*`  | Set 操作（smembers/sadd/srem/scard）              |
| `/zset/*` | ZSet 操作（zrange/zadd/zrem/zcard/zrangeByScore） |

支持 Spring 管理的 RedisTemplate 和自定义连接两种方式。

### 7. ElasticSearch 管理

- **路径**: `/ops/elasticsearch/`
- **控制器**: `ElasticSearchOpsController`（260 行）
- **条件**: `@ConditionalOnClass(RestHighLevelClient.class)`
- **前端**: `static/ops/elasticsearch/index.html`（2647 行）
- **功能**: 索引 CRUD、文档 CRUD、DSL 查询、Mapping 管理

### 8. MinIO 对象存储管理

- **路径**: `/ops/minio/`
- **控制器**: `MinioOpsController`（388 行）
- **条件**: `@ConditionalOnClass(MinioClient.class)`
- **前端**: `static/ops/minio/index.html`
- **功能**: 文件浏览/上传/下载/删除，复用 `MinioFileSystem` 统一文件系统抽象

### 9. AWS S3 对象存储管理

- **路径**: `/ops/aws-s3/`
- **控制器**: `AwsS3OpsController`（388 行）
- **条件**: `@ConditionalOnClass(S3Client.class)`
- **前端**: `static/ops/aws-s3/index.html`（1435 行）
- **功能**: 文件浏览/上传/下载/删除，复用 `AwsS3OssFileSystem` 统一文件系统抽象

### 10. XXL-JOB 任务调度

- **路径**: `/ops/xxl-job/`
- **控制器**: `XxlJobOpsController`（393 行）
- **条件**: `@ConditionalOnClass(XxlJobExecutor.class)`
- **前端**: `static/ops/xxl-job/index.html`
- **功能**:

| 接口          | 说明                                  |
|-------------|-------------------------------------|
| `/jobs`     | 列出 XXL-JOB 任务（从数据库 xxl_job_info 读取） |
| `/handlers` | 列出注册的 JobHandler                    |
| `/execute`  | 手动执行任务（支持参数、广播/分片模式）                |

### 11. XProc4J 脚本执行

- **路径**: `/ops/xproc4j/`
- **控制器**: `XProc4jOpsController`（336 行）
- **条件**: XProc4J 执行器存在时激活
- **前端**: `static/ops/xproc4j/index.html`
- **功能**:

| 接口             | 说明                        |
|----------------|---------------------------|
| `/datasources` | 列出 XProc4J 可用数据源          |
| `/metas`       | 列出所有存储过程元数据               |
| `/call`        | 调用存储过程（支持同步/异步、调试模式、日志追踪） |
| `/procedures`  | 列出存储过程列表                  |

### 12. OpenAI 对话工具

- **路径**: `/ops/open-ai/`
- **控制器**: `OpenAiOpsController`（486 行）
- **条件**: `@ConditionalOnClass(RestTemplate.class)`
- **前端**: `static/ops/open-ai/index.html`
- **功能**:

| 接口            | 说明                                   |
|---------------|--------------------------------------|
| `/models`     | 列出可用模型                               |
| `/stream`     | SSE 流式对话（支持 Function Calling、工具调用审批） |
| `/completion` | 非流式对话                                |

**内置 AI 工具（Function Calling）**:

| 工具类                     | 说明                       |
|-------------------------|--------------------------|
| `DatetimeTools`         | 日期时间工具                   |
| `RandomTools`           | 随机数工具                    |
| `UidTools`              | UID 生成工具                 |
| `JceTools`              | JCE 加密工具                 |
| `CodecTools`            | 编解码工具                    |
| `DatabaseMetadataTools` | 数据库元数据工具                 |
| `DatabaseQueryTools`    | 数据库查询工具                  |
| `LocalFileTools`        | 本地文件工具（411 行）            |
| `CommandTools`          | 命令执行工具                   |
| `WebDownloadTools`      | 网页下载工具                   |
| `LunarTools`            | 农历日历工具                   |
| `AgentTools`            | Agent-to-Agent 工具（126 行） |

**SQL 安全验证**: `OpsSqlValidator` 接口 + 两种实现（正则 / JSqlParser AST），防止 AI 工具执行危险 SQL。

**技能系统**: `SkillAutoConfiguration` 自动扫描文件系统技能定义，30
秒刷新，通过 `ai.skills.enable` / `ai.skills.tool.enable` 配置开关。

### 13. DashScope 通义千问 AI 工具

- **路径**: `/ops/dashscope/`
- **控制器**: 12 个控制器
- **前端**: `static/ops/dashscope/`（多个子页面）
- **功能**: 通义千问系列 AI 能力操作面板

| 控制器                                           | 能力              |
|-----------------------------------------------|-----------------|
| `DashScopeOpsController`                      | 基础对话            |
| `DashScopeOpsTaskController`                  | 异步任务管理          |
| `DashScopeOpsTmpFileController`               | 临时文件管理（上传/下载）   |
| `DashScopeOpsD3TripoController`               | 3D 模型生成（Tripo）  |
| `DashScopeOpsImageKlingText2ImageController`  | Kling 文生图       |
| `DashScopeOpsImageWanText2ImageController`    | Wan 文生图         |
| `DashScopeOpsVideoHappyHorseController`       | HappyHorse 视频生成 |
| `DashScopeOpsVideoKlingController`            | Kling 视频生成      |
| `DashScopeOpsVideoPixVerseController`         | PixVerse 视频生成   |
| `DashScopeOpsVideoViduController`             | Vidu 视频生成       |
| `DashScopeOpsVideoWanDigitalPeopleController` | Wan 数字人视频       |
| `DashScopeOpsVideoWanInsteadPeopleController` | Wan 替换人物视频      |

## 自动装配

### AutoConfiguration.imports（55 个自动配置类）

所有自动配置类通过 `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports` 注册，覆盖：

- 首页与菜单（`OpsHomeController`）
- 安全传输（`OpsSecureTransfer` / `OpsSecureHelper` / `OpsSecureAutoConfiguration`）
- 主机标识（`HostIdHelper` / `HostIdProxyHelper`）
- 数据源（`DatasourceAutoConfiguration` + 3 种 Collector + Provider + Helper + 2 个 Controller）
- 各功能控制器（Redis / SSH / MinIO / AwsS3 / ElasticSearch / XProc4J / OpenAI / DashScope × 12）
- AI 工具（`SkillAutoConfiguration` + 12 个 Tools 实现 + `SpringContextToolDefinitionProvider`）

### IOpsProvider 扩展接口

```java
public interface IOpsProvider {
    List<OpsHomeMenuDto> getMenus();
}
```

所有控制器实现此接口，首页通过 `ApplicationContext.getBeanNamesForType(IOpsProvider.class)` 自动发现并聚合菜单。

## 前端技术栈

| 技术         | 版本      | 用途                   |
|------------|---------|----------------------|
| Vue.js     | 2.x     | 前端框架                 |
| Element UI | 2.15.10 | UI 组件库               |
| Axios      | 1.1.3   | HTTP 客户端             |
| Moment.js  | 2.24.0  | 日期处理                 |
| CodeMirror | 6.65.7  | 代码编辑器（SQL/JSON/JS 等） |
| SM Crypto  | —       | 前端国密加解密（与后端配套）       |

### 前端页面清单

| 页面                                    | 行数       | 功能           |
|---------------------------------------|----------|--------------|
| `index.html`                          | 304      | 控制台首页        |
| `app/index.html`                      | 1924     | 应用管理         |
| `host/index.html`                     | 1823     | 主机管理         |
| `datasource/index.html`               | 3451     | 数据库管理        |
| `elasticsearch/index.html`            | 2647     | ES 管理        |
| `aws-s3/index.html`                   | 1435     | AWS S3 管理    |
| `dashscope/index.html`                | 310      | DashScope 首页 |
| `dashscope/video/*/index.html`        | 962-1112 | 各视频生成页面      |
| `dashscope/image/*/text-2-image.html` | 710-771  | 文生图页面        |
| `dashscope/d3/tripo/tripo-d3.html`    | 819      | 3D 模型生成      |

## 源文件清单

### Java 源码（132 文件）

| 包               | 文件数 | 说明                                                     |
|-----------------|-----|--------------------------------------------------------|
| `home`          | 3   | 首页控制器 + IOpsProvider 接口 + 菜单 DTO                       |
| `common`        | 12  | 安全传输/主机标识/异常/计时/JSON 写入器                               |
| `app`           | 15  | 应用管理（3 控制器 + 10 DTO + 1 工具 + 1 表达式）                    |
| `host`          | 4   | 主机管理（1 控制器 + 3 DTO）                                    |
| `ssh`           | 4   | SSH 管理（1 控制器 + 3 DTO）                                  |
| `datasource`    | 14  | 数据库管理（2 控制器 + 1 配置 + 3 Provider + 1 Helper + 7 DTO）    |
| `redis`         | 5   | Redis 管理（1 控制器 + 1 动态工具 + 3 DTO）                       |
| `elasticsearch` | 4   | ES 管理（1 控制器 + 1 Helper + 2 DTO）                        |
| `minio`         | 3   | MinIO 管理（1 控制器 + 2 DTO）                                |
| `awss3`         | 2   | AWS S3 管理（1 控制器 + 1 DTO）                               |
| `xxljob`        | 4   | XXL-JOB 管理（1 控制器 + 3 DTO）                              |
| `xproc4j`       | 4   | XProc4J 管理（1 控制器 + 1 Helper + 2 DTO）                   |
| `openai`        | 19  | AI 对话（1 控制器 + 1 Skill 配置 + 1 Provider + 13 工具 + 3 DTO） |
| `dashscope`     | 24  | DashScope（12 控制器 + 12 DTO）                             |
| `util`          | 1   | HumanUtil（人类可读文件大小）                                    |

## 设计特点

1. **国密安全** — 全链路 SM2/SM3/SM4 加密，自动证书生成，时间戳防重放
2. **条件装配** — 13+ 功能模块全部 `@ConditionalOnClass`，按需激活零浪费
3. **统一传输** — `OpsSecureTransfer` 统一加解密 + 耗时统计 + 主机标识
4. **SPI 菜单** — `IOpsProvider` 接口自动发现，新模块只需实现接口即可注册到首页
5. **多主机代理** — HostId 机制 + `HostIdProxyHelper` 实现跨主机统一管理
6. **前端内嵌** — 所有前端资源打包在 JAR 内，引入依赖即可使用
7. **复用项目生态** — 文件系统操作复用 `IFileSystem` 抽象，数据库操作复用 `JdbcResolver`，AI 复用 `i2f-ai-std`
8. **AI 工具集成** — 12 种内置 Function Calling 工具 + 技能系统 + SQL 安全验证

## 相关文档

- [AI 工具链](ai-framework.md) — AI 标准定义与 OpenAI 实现
- [XProc4J 框架](xproc4j-framework.md) — XML 存储过程编排
- [统一文件系统](filesystem.md) — IFileSystem/IFile 抽象体系
- [数据库元数据](database-metadata.md) — 逆向工程体系
- [SQL 绑定与动态查询](bindsql-bql.md) — BindSql/BQL 框架
- [模块列表](module-i2f-springboot.md) — SpringBoot Starter 完整列表
