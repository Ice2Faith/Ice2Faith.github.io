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
7. **请求限流** — `/ops/**` 入口三级令牌桶（全局 / 每 IP / ANT 路径），超限直接 429，默认开启

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

## 请求限流防护

`OpsLimitedAutoConfiguration`（`@ConditionalOnClass(FilterRegistrationBean.class)` + `@ConditionalOnExpression("${i2f.springboot.ops.limited.enable:true}")`）
以 `FilterRegistrationBean` order=1 注册 `OpsLimitedRequestFilter`，默认挂在 `i2f.springboot.ops.base-url`（`/ops`
）下。它与国密信封**正交**：
加密解决「谁能读」，限流解决「能打多快」，两者互不接管。

### 三级令牌桶

`doFilterInternal` 依次过三道闸，任一层 `tryAcquire(1, TimeUnit.SECONDS)` 取不到令牌即抛 `OpsLimitedException`：

| 层级     | 配置项                                             | 桶 Key                            | 默认值            |
|--------|-------------------------------------------------|----------------------------------|----------------|
| 全局     | `all-rule.enable/rate-per-second/capacity`      | `ops:limited:all`                | 100/s · 容量 300 |
| 每 IP   | `every-ip-rule.rule.*`                          | `ops:limited:ip:{ip}`            | 100/s · 容量 300 |
| ANT 路径 | `path-rules[].ant-path` + `path-rules[].rule.*` | `ops:limited:ant-path:{pattern}` | 无默认（需显式配置）     |

- 全局与路径桶由 `ConcurrentMapKeyedLimiter` 持有，经 `get(key, producer)`
  惰性创建 `TokenBucketRateLimiter(ratePerSecond, capacity)`；
- 每 IP 桶存放在 `LruMap<String, ILimiter>` 中，上限由 `every-ip-rule.lru-max-size`（默认 8192，`accessOrder=true` 按访问序淘汰）
  控制，自动装配类在 `new OpsLimitedRequestFilter()` 后按 `lru-max-size` 注入 `setMaxSize`，避免 IP 维度无限增长；
- 路径规则用 `AntMatcher` 逐一比对 `ServletContextUtil.getFullPathWithoutContextPath(request)`，同一 pattern 共用一根桶；
- 过滤范围由 `filter-url-pattern` 决定，留空时取 `OpsConsts.BASE_URL_PROPERTY`（默认 `/ops`）拼接 `/*`，注册后打印日志。

### 拒绝语义

- 三层判定共用一个 `try`，异常在末尾 `catch (OpsLimitedException)` 统一处理：`reset()` → `setStatus(429)` →
  `text/html;charset=utf-8`，正文为 `global limited.` / `ip limited.` / `path limited.`；
- 写回前先判 `response.isCommitted()`：SSE 已提交首帧时直接返回，避免 `reset()` 抛 `IllegalStateException`；
- `chain.doFilter` 同样在 `try` 内——下游控制器/工具抛出的 `OpsLimitedException` 走同一出口，全链路 429 格式一致。

### 配置

```yaml
i2f:
  springboot:
    ops:
      limited:
        # filter-url-pattern: /ops/*   # 留空则取 {base-url}/*
        all-rule:
          enable: true
          rate-per-second: 100
          capacity: 300
        every-ip-rule:
          lru-max-size: 8192
          rule:
            enable: true
            rate-per-second: 100
            capacity: 300
        path-rules:
          - ant-path: /ops/open-ai/*
            rule:
              enable: true
              rate-per-second: 20
              capacity: 50
```

> 令牌桶参数在首次取桶时固化，运行期改配置不生效，需重启；`every-ip-rule` 的 `enable/rate-per-second/capacity`
> 已收拢到 `rule` 子对象，旧的平铺写法会被 Boot 宽松绑定静默忽略。

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

| 工具类                     | 说明                                    |
|-------------------------|---------------------------------------|
| `DatetimeTools`         | 日期时间工具                                |
| `RandomTools`           | 随机数工具                                 |
| `UidTools`              | UID 生成工具                              |
| `JceTools`              | JCE 加密工具                              |
| `CodecTools`            | 编解码工具                                 |
| `DatabaseMetadataTools` | 数据库元数据工具                              |
| `DatabaseQueryTools`    | 数据库查询工具                               |
| `LocalFileTools`        | 本地文件工具（411 行）                         |
| `CommandTools`          | 命令执行工具                                |
| `SshTools`              | SSH 具名主机工具（命令 / 上传 / 下载，本机路径复用本地文件沙箱） |
| `WebDownloadTools`      | 网页下载工具                                |
| `LunarTools`            | 农历日历工具                                |
| `AgentTools`            | Agent-to-Agent 工具（126 行）              |

**SQL 安全验证**: `OpsSqlValidator` 接口 + 两种实现（正则 / JSqlParser AST），防止 AI 工具执行危险 SQL。

**技能系统**: `SkillAutoConfiguration` 自动扫描文件系统技能定义，30
秒刷新，通过 `ai.skills.enable` / `ai.skills.tool.enable` 配置开关。

**ReAct 循环与插话（安全临界点）**:

- 一次 `/stream` 请求 = 一次 LLM 往返：服务端在本轮返回前完成 `tool_calls` 执行并追加 `tool` 响应，前端收到 `tool_calls` 后再发起下一轮，形成 ReAct 循环
- 前端严格「单飞」：同一会话同一时刻只允许一个请求在飞，`session.sending` 即单飞锁，多个续跑请求统一排队后串行执行
- 循环运行中的用户输入一律进入会话维度插话队列 `session.interjects`，不再直接发起请求（避免两个 ReAct 循环并行交错）
- 插话只在安全临界点投递：前端构建请求时取出队首插话放入 `req.interject`，后端 `appendInterjectMessage` 在 `tool_calls` 与 `tool` 成对完整、且工具回传的附加消息插入完成之后，把插话追加为本轮最后一条消息；不在安全边界（最后一条是待响应的 `assistant(tool_calls)`）则跳过，由下一轮继续携带
- 插话显示与其他回显消息一致，统一由后端在真正插入的时机回显：后端用 `canAppendInterject` 校验后调用 `echoInterjectMessage` 发送 `echo_interject`（回显原始内容，早于 `convertOpenAiUserMessage` 追加附件清单），前端收到后按 `insertBeforeLast` 插入到助手占位之前，保证 LLM 的答复消息始终是最后一条；本轮结束仍未回显（异常/中断/不在安全边界）则退回队首，同一条连续 3 次未投递才丢弃
- 本轮结束后统一在 `finally` 中通过 `drainSessionContinues` 串行调度下一轮（会话总结优先，其次普通续跑，最后插话投递）
- 自动/手动会话总结同样纳入单飞调度：指令消息先落历史，再通过 `requestSessionContinue` 排队（`action=summary-history`）；续跑队列按 action 类型分槽存储（`summary-history` / `continue`），不同类型互不覆盖，调度优先级为「会话总结 > 普通续跑 > 插话投递」
- 会话总结独占一轮：总结指令所在轮次及其后的工具续跑轮（`session.lastOptions.action=summary-history`）不投递插话，插话留在队列由下一轮投递；后端同时通过 `req.action`（`OpenAiOperateDto.action`）二次把关，命中 `ACTION_SUMMARY_HISTORY` 时不插入、不回显插话，避免一轮内同时携带总结指令与插话导致总结内容被干扰
- 需要用户交互（工具授权/表单）或异常/中断时挂起，不自动续跑；页面刷新后重置 `sending` 等运行时状态，避免会话被视为运行中
- 交互提示：输入框上方悬浮 `pending-interject-bar`，展示队首插话预览与排队数，并支持「撤回本条到输入框继续编辑」（回填时剔除发送时间前缀并自动聚焦输入框）与「丢弃本条」；窄屏（`max-width: 768px`）下收紧边距字号并隐藏文案只留图标

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

### AutoConfiguration.imports（84 个自动配置类）

所有自动配置类通过 `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports` 注册，覆盖：

- 首页与菜单（`OpsHomeController`）
- 安全传输（`OpsSecureTransfer` / `OpsSecureHelper` / `OpsSecureAutoConfiguration`）
- 请求限流（`OpsLimitedAutoConfiguration` → `OpsLimitedRequestFilter`，order=1，默认 url-pattern `{base-url}/*`）
- 主机标识（`HostIdHelper` / `HostIdProxyHelper`）
- 数据源（`DatasourceAutoConfiguration` + 3 种 Collector + Provider + Helper + 2 个 Controller）
- 各功能控制器（Redis / SSH / MinIO / AwsS3 / ElasticSearch / XProc4J / OpenAI / DashScope × 12）
- AI 工具（24 个 openai 域 `@Tools` 实现 + 8 个 DashScope 多媒体工具 + `SpringContextToolDefinitionProvider`）

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

### Java 源码（185 文件）

| 包               | 文件数 | 说明                                                  |
|-----------------|-----|-----------------------------------------------------|
| `home`          | 5   | 首页控制器 + IOpsProvider 接口 + 菜单 DTO/分组                 |
| `common`        | 22  | 安全传输/主机标识/限流（`limit` 子包 4 类）/异常/计时/JSON 写入器         |
| `app`           | 16  | 应用管理（控制器 + DTO + 工具 + 表达式）                          |
| `host`          | 3   | 主机管理（1 控制器 + 2 DTO）                                 |
| `ssh`           | 2   | SSH 管理（1 控制器 + 1 DTO）                               |
| `datasource`    | 17  | 数据库管理（控制器 + 配置 + Provider/Collector + Helper + DTO） |
| `redis`         | 7   | Redis 管理（控制器 + 动态工具 + DTO）                          |
| `elasticsearch` | 3   | ES 管理（1 控制器 + 1 Helper + 1 DTO）                     |
| `minio`         | 2   | MinIO 管理（1 控制器 + 1 DTO）                             |
| `awss3`         | 2   | AWS S3 管理（1 控制器 + 1 DTO）                            |
| `xxljob`        | 3   | XXL-JOB 管理（1 控制器 + 2 DTO/Meta）                      |
| `xproc4j`       | 3   | XProc4J 管理（1 控制器 + 1 Helper + 1 DTO）                |
| `openai`        | 63  | AI 对话（控制器 + Skill 配置 + Provider + 工具实现 + DTO）       |
| `dashscope`     | 36  | DashScope（12 控制器 + 工具实现 + DTO）                      |
| `util`          | 1   | HumanUtil（人类可读文件大小）                                 |

## 设计特点

1. **国密安全** — 全链路 SM2/SM3/SM4 加密，自动证书生成，时间戳防重放
2. **条件装配** — 13+ 功能模块全部 `@ConditionalOnClass`，按需激活零浪费
3. **统一传输** — `OpsSecureTransfer` 统一加解密 + 耗时统计 + 主机标识
4. **SPI 菜单** — `IOpsProvider` 接口自动发现，新模块只需实现接口即可注册到首页
5. **多主机代理** — HostId 机制 + `HostIdProxyHelper` 实现跨主机统一管理
6. **前端内嵌** — 所有前端资源打包在 JAR 内，引入依赖即可使用
7. **复用项目生态** — 文件系统操作复用 `IFileSystem` 抽象，数据库操作复用 `JdbcResolver`，AI 复用 `i2f-ai-std`
8. **AI 工具集成** — 24 个领域 Function Calling 工具 + 8 个 DashScope 多媒体工具 + 技能系统 + SQL 安全验证
9. **入口限流** — 三层令牌桶（全局 / 每 IP / ANT 路径）+ LRU 上限保护 IP 桶 + 统一 429 出口

## 相关文档

- [AI 工具链](ai-framework.md) — AI 标准定义与 OpenAI 实现
- [XProc4J 框架](xproc4j-framework.md) — XML 存储过程编排
- [统一文件系统](filesystem.md) — IFileSystem/IFile 抽象体系
- [数据库元数据](database-metadata.md) — 逆向工程体系
- [SQL 绑定与动态查询](bindsql-bql.md) — BindSql/BQL 框架
- [模块列表](module-i2f-springboot.md) — SpringBoot Starter 完整列表
