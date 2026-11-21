# i2f-springboot-ops-starter

## 模块路径

`i2f-springboot/i2f-springboot-ops-starter`

## 模块概述

i2f-springboot 组中**体量最大、能力最全**的重型一体化运维 / 开发控制台 Starter（185 个 Java 源文件 + 内嵌完整前端
SPA）。它把「应用自省、多数据源 SQL 控制台、SSH/SFTP 文件与命令、Redis、Elasticsearch、MinIO、AWS
S3、主机文件、xproc4j、xxl-job、DashScope 图/视频/3D 生成、OpenAI 对话 + AI 工具集 + RAG + Groovy 技能 + TTS」等一整套运维与
AI 能力，连同 Vue2 前端，封装进单个 jar；仅靠把本 Starter 放入 classpath 即**全自动装载**整套控制台（84
个组件类被登记进 `EnableAutoConfiguration`），统一挂在 `i2f.springboot.ops.base-url`（默认 `/ops`）路径下，所有请求/响应经一套
**SM2/SM3/SM4 国密安全信封**（`OpsSecureTransfer`）加解密与签名。

近期结构发生一次**依赖反转**：RAG 装配、技能扫描、AI 工具管理器等自动配置整体**下沉到 `i2f-springboot-ai-starter`**
，本模块改为其消费方（并新增 `i2f-extension-ai-embedding`）；SM 算法实现从 `com.antherd:sm-crypto`
彻底切到自研 `i2f-sm-crypto`，`nashorn` 依赖被注释停用。同时新增**把自身能力反向暴露为 MCP 工具**
的三条通道（`OpsMcpServerAdditionalToolProvider` / `OpsMcpServerApiToolProvider` / `DashScopeOpsMcpServerAdditionalToolProvider`
）与一个 `/mcp/api` 纯 HTTP 文件通道，使外部 MCP 客户端（如 IDE 智能体）可反向操作本控制台。

本轮另新增**入口请求限流**：`common/limit` 下 4 个类（`OpsLimitedAutoConfiguration` / `OpsLimitProperties` /
`OpsLimitedRequestFilter` / `OpsLimitedException`），以 order=1 的 `FilterRegistrationBean` 挂在 `{base-url}/*`，按「全局 /
每 IP /
ANT 路径」三层令牌桶判定，任一层取不到令牌即统一 429；每 IP 桶用 `LruMap`（`lru-max-size` 默认 8192）封顶，避免 IP 维度无限增长。

## 模块依赖

### i2f 内部依赖（compile，23 项，传递引入）

| 依赖                                    | 用途                                                                                                                                                                                                              |
|---------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `i2f-springboot-ai-starter`           | **RAG / 技能 / 工具管理器自动配置**（`AiRagsAutoConfiguration`、`AiSkillsAutoConfiguration`、`AiToolsAutoConfiguration`、`GroovySkillScriptRunner`），本模块 `OpenAiOpsController` 注入其 `RagWorker`/`SkillsTools`/`McpProviderTools` |
| `i2f-extension-ai-embedding`          | Embedding 模型实现层，供 ai-starter 的 RAG 装配与技能向量检索使用                                                                                                                                                                  |
| `i2f-sm-crypto`                       | 国密 SM2（密钥对/签名）+ SM3（摘要）+ SM4（对称密钥），安全信封唯一算法来源（替代原 antherd 移植版）                                                                                                                                                  |
| `i2f-jdbc-impl`                       | 数据源控制台 `JdbcResolver`/`JdbcScriptRunner`/`BindSql` 执行 SQL                                                                                                                                                       |
| `i2f-database-metadata-impl`          | 导入时 `DatabaseMetadataProviders` 取表/列元数据                                                                                                                                                                         |
| `i2f-os`                              | `OsUtil` 命令执行 / OS 判断（CommandTools、SSH 相关）                                                                                                                                                                      |
| `i2f-network`                         | `NetworkUtil.getUsefulAddresses` 计算 hostId                                                                                                                                                                      |
| `i2f-mutator`                         | `toMutator().set(...).done()` 装配 DSL（AI/RAG/工具广泛使用）                                                                                                                                                             |
| `i2f-image-impl`                      | 图像能力（dashscope 图/视控制台）                                                                                                                                                                                          |
| `i2f-jdk-ext-web`                     | `ServletFileUtil` 附件下载、Web 工具                                                                                                                                                                                   |
| `i2f-extension-sftp`                  | `SftpUtil`/`ChannelSftp`：SSH 文件管理、exec、隧道式命令（`SshOpsController` 与 `SshTools` 共用）                                                                                                                                |
| `i2f-extension-groovy`                | `GroovyScript.eval`：`/ops/app/eval` 在线求值、技能脚本                                                                                                                                                                   |
| `i2f-extension-filesystem-minio`      | MinIO 控制台                                                                                                                                                                                                       |
| `i2f-extension-filesystem-oss-aws-s3` | AWS S3 控制台                                                                                                                                                                                                      |
| `i2f-extension-elasticsearch`         | ES 控制台                                                                                                                                                                                                          |
| `i2f-rowset`                          | CSV/JSONL/JSON 行集读写（导出/导入、RowSetWriter）                                                                                                                                                                         |
| `i2f-ai-std`                          | AI 工具/Skill/RAG/MCP 抽象（`@Tool`、`ToolManager`、`McpServerAdditionalToolProvider`、`ToolCallContextHolder`、`AsyncTaskResolver`）                                                                                     |
| `i2f-ai-rest-openai`                  | `HttpOpenAiRagEmbeddingModel`、OpenAI 对话后端                                                                                                                                                                       |
| `i2f-extension-ai-rag-sqlite`         | `SqliteRagEmbeddingStore`/`SqliteBucketRagMemoryStore`/`SqliteRagDocumentsStore` 向量存储（并被 `RagDataSourceCollector` 反桥为只读数据源）                                                                                     |
| `i2f-spring-core`                     | `SpringContext` 适配（工具/技能上下文）                                                                                                                                                                                    |
| `i2f-spring-web`                      | `SpringWebRestClient`（RAG embedding HTTP）                                                                                                                                                                       |
| `i2f-uid-impl`                        | 生成 ID（UidTools）                                                                                                                                                                                                 |
| `i2f-extension-document`              | `PdfConvertUtil`（PDF→图片给 OCR reader）                                                                                                                                                                            |

> `i2f-extension-jackson` 仍未在 pom 直接声明，经其它 i2f 模块 compile
> 传递后在 `RagEmbeddingCache`、`common/JacksonJson*RowSetWriter` 等处直接 `import`，属依赖未直声明。

### 外部依赖（provided，按需自装）

| 依赖                                                                                        | 版本              | 用途                                                                                     |
|-------------------------------------------------------------------------------------------|-----------------|----------------------------------------------------------------------------------------|
| `com.antherd:sm-crypto`                                                                   | 0.3.2.1-RELEASE | **已注释停用**（原前端一致 SM 实现，现由 `i2f-sm-crypto` 取代）                                           |
| `org.openjdk.nashorn:nashorn-core`                                                        | 15.4            | **已注释停用**（webjs 工具随之降级为空壳，见瑕疵）                                                         |
| `com.github.jsqlparser:jsqlparser`                                                        | 4.9             | SQL 校验（`OpsSqlParserAstSqlValidator`），注释注明 4.9 为 JDK8 最后版本                             |
| `com.baomidou:dynamic-datasource-spring-boot-starter`                                     | 3.5.2           | 动态多数据源探测（BaomidouDynamicDatasourceCollector）                                           |
| `spring-boot-starter-data-redis` / `redis.clients:jedis` / `redisson-spring-boot-starter` | - / - / 3.20.1  | Redis 控制台三种客户端解析                                                                       |
| `com.xuxueli:xxl-job-core`                                                                | 2.4.1           | xxl-job 控制台                                                                            |
| `com.h2database:h2`                                                                       | 2.2.224         | sample 内嵌库                                                                             |
| `com.jcraft:jsch`                                                                         | 0.1.55          | SFTP/SSH 底层（provided，未 optional），亦是 `SshTools` 的 `@ConditionalOnClass(ChannelSftp)` 依据 |
| `org.apache.groovy:groovy`                                                                | 4.0.18          | 求值/技能脚本（provided+optional）                                                             |
| `io.minio:minio`                                                                          | 7.1.0           | MinIO 控制台                                                                              |
| `software.amazon.awssdk:s3 / kms / s3control`                                             | BOM 2.17.100    | AWS S3 控制台                                                                             |
| `org.elasticsearch[.client]:*`                                                            | 7.6.2           | ES 控制台（含 `RestHighLevelClient`）                                                        |
| `cn.6tail:lunar`                                                                          | 1.3.14          | 农历/干支工具（LunarTools）                                                                    |
| `org.apache.pdfbox:pdfbox`                                                                | 2.0.29          | PDF 处理                                                                                 |
| `org.java-websocket:Java-WebSocket`                                                       | 1.5.3           | Qwen TTS WebSocket                                                                     |

> 依赖面极广：23 个 i2f 内部 compile + 上述大量 provided。由于内部依赖均为 compile 传递，**引入本 Starter 会把整台「运维 +
AI」控制台的重资产一次性拉入**（现在还包含整个 ai-starter 及其 embedding 实现）；外部集成库标
> provided+optional，由宿主按启用的功能自行补齐。构建用 `maven-assembly-plugin`，`addMavenDescriptor=true`。

## 模块设计

```mermaid
flowchart TD
    subgraph Boot[classpath 存在即自动装载]
        SF["spring.factories + AutoConfiguration.imports\n84 个组件类登记为 EnableAutoConfiguration"]
    end

    subgraph Common[common：安全信封 + 装载基座]
        HOLDER[SpringHolder\n静态 context/env @Component]
        SEC[OpsSecureTransfer @Component\nSM2 加密密钥 + SM4 payload + SM3 摘要 + SM2 签名]
        HELPER[OpsSecureHelper / OpsSecureKeyPair\nBase64 JSON 承载含私钥密钥对]
        AUTOCONFIG[OpsSecureAutoConfiguration\n无 cert 时启动生成密钥对并 System.out 打印]
        HOSTID[HostIdHelper / HostIdProxyHelper\nip#nic@port 主机标识 + 定向代理]
        LIMIT["OpsLimitedRequestFilter\n三层令牌桶 · order=1\n全局 / 每 IP / ANT 路径"]
        STATIC[静态资源与 mjs media-type 配置]
    end

    subgraph Home[home：菜单聚合]
        HC[OpsHomeController /ops/menus\n遍历 IOpsProvider.getMenus 汇总]
    end

    subgraph Cap[能力域：@Controller，均过安全信封 + hostId]
        APP[app：system/env/beans/deadlock/logging + eval Groovy]
        DS[datasource：Provider + 4 Collector\nquery/update/runner/import/export]
        SSH[ssh：SftpUtil 文件/exec/cmd]
        MID[minio / aws-s3 / elasticsearch / redis / host / xproc4j / xxl-job]
    end

    subgraph AI[openai + dashscope]
        OAI[OpenAiOpsController 默认关\n/stream SSE + /tool/tags + /async/task/query]
        TOOLS[tool/impl 领域工具 24 个 @Tools\n@McpServerExpose 控制 MCP 暴露]
        MCP1[OpsMcpServerAdditionalToolProvider\nops. 前缀 3 工具]
        MCP2[OpsMcpServerApiToolProvider\n/mcp/api + X-MCP-TOKEN]
        MCP3[DashScopeOpsMcpServerAdditionalToolProvider\nops. 前缀 8 工具]
        RAGDS[RagDataSourceCollector\nSqlite RAG store 反桥为 rag_* 只读数据源]
        DASH[DashScopeOps*：图/视频/3D 生成 + qwen_tts]
    end

    subgraph AIStarter[消费：i2f-springboot-ai-starter]
        AICFG[AiRagsAutoConfiguration / AiSkillsAutoConfiguration / AiToolsAutoConfiguration\nRAG 装配、技能文件系统扫描、ToolManager 归属]
    end

    SF --> Common & Home & Cap & AI
    AI --> AIStarter
    AIStarter --> RAGDS
    Cap --> SEC
    AI --> SEC
    MCP1 & MCP2 & MCP3 -.-> TOOLS
    MCP1 --> RAGDS
```

## 模块目的

- 为基于 i2f 的 Boot 应用提供「零配置、加 jar 即得」的一体化在线运维 / 调试 / AI 控制台：运行时自省、多数据源 SQL、目标机文件与命令、常见中间件（Redis/ES/MinIO/S3）操作、定时任务与存储过程查看，以及 DashScope/OpenAI 多媒体与工具调用能力。
- 用国密安全信封统一封装所有入站/出站数据（签名 + 时效 + 加密），并以 hostId 做主机定向/代理路由，供集群中定位具体实例。
- 作为 **MCP 工具服务端**把「本地文件 ↔ 远端文件 ↔ 异步媒体任务」串起来，让外部智能体可以上传素材、取回产物、轮询任务状态。
- 内嵌 Vue2 + vxe-table + echarts + three.js + mermaid + pdf.js + xlsx 等前端资产，形成自包含的可视化后台。

## 模块功能

- **应用自省**（`AppOpsController`，`i2f.springboot.ops.app.enable:true`）：system-properties、system-env、input-arguments、class-metadata、locked-threads（`ThreadMXBean.findDeadlockedThreads` 死锁检测）、beans 列表、运行期 `logging-level/set`。
- **在线求值**（`AppEvalOpsController` `/ops/app/eval`，新增 `@ConditionalOnClass(GroovyShell.class)` 兜底）：以 Groovy
  执行任意脚本，作用域注入 `out`/`context`(ApplicationContext)/`env`/`beanMap`(全部 bean)/`request`。
- **多数据源 SQL 控制台**（`DatasourceOpsController`，`ops.datasource.enable:true`）：SPI
  探测驱动、列数据源、多库 `query`/`update`、脚本 `runner`（可配 autoCommit/delimiter/stopOnError）、CSV `export`、带 MD5 校验的
  CSV `import`（按表头匹配列拼 insert）。数据源经 `DatasourceProvider` + 四种 `DatasourceCollector`（Static /
  BaomidouDynamic / Default / **RAG 反桥**）聚合。
- **SSH/SFTP 控制台**（`SshOpsController`，`ops.ssh.enable:true`）：file-list、mkdirs、delete、upload/download（MD5 校验）、head/tail 日志、`cmd`（远程 shell，可 runAsFile 落 `.sh` 后 `sh -c` 执行）、内置 sftp 命令解释器（cd/ls/rm/rename/symlink…）。
- **SSH 具名主机工具**（`SshTools`，`ai.tools.ssh.enable:false` 默认关，`@ConditionalOnClass(ChannelSftp)`）：`ssh_hosts`
  列出启用主机（`ai.tools.ssh.hosts[]` 的 `name` 即工具入参 `host`，逐台 `enable`）；`ssh_command` 一次调用一次短会话，按输出末行
  `exit status: N` 派生 `completed`/`exitStatus`，`ll` / 交互式 `top` 重写为非交互形式，等待上限
  3600s；`ssh_upload`/`ssh_download`
  的本机路径统一经 `LocalFileTools.getFile()` 沙箱（远端路径不限制），下载覆盖前按 `ai.tools.file.backup-file` 备份；结果统一
  `success/code/hints`（`SshOutcome` 枚举派生），可经 `@McpServerExpose` 对外暴露。
- **中间件控制台**：Redis（Jedis/Lettuce/Redisson 三解析）、Elasticsearch、MinIO、AWS S3、主机本地文件、xproc4j、xxl-job，各带 `ops.{name}.enable:true` 独立开关。
- **OpenAI 对话 + AI 工具集
  **（`OpenAiOpsController`，`i2f.springboot.ops.open-ai.enable:false` + `@ConditionalOnClass(RestTemplate)`）：`/models`
  列模型、`/stream` 以 `SseEmitter` 流式对话（两个 `ThreadPoolExecutor`：`pool`/`toolPool`
  ，均 `CallerRunsPolicy`）、`/tool/tags` 暴露 `AiTags`
  标签体系（READONLY/WRITABLE/EXECUTABLE/HIGH_COST/SLOW_EXEC/PUBLIC_NET/AUTO/RETRYABLE/DATABASE_VALUE）、`/async/task/query`
  轮询异步任务、`/tmp-file/upload|download|inline` 临时素材通道（上传带 MD5 校验）；入站 HTTP 头/参数/客户端 IP
  经 `HttpServletToolContextUtil` 注入 `ToolCallContextHolder`；`OpenAiOptionsUtil`
  统一「请求体优先、否则回落 `defaultEndpoint`/`dashscopeEndpoint`」的端点选择。
- **上下文瘦身**（`RecycleTools`，`ai.tools.recycle.enable:true`）：把超过阈值的工具入参/返回值替换为 `ref://<uuid>`
  引用并存入本次请求的 `recycleMap`，模型可用工具 `ref_content` 按需取回原文（该工具 `@McpServerExpose(false)`）。
- **技能管理**（`SkillManageTools`，`ai.tools.skill-manage.enable:true`，`@Tools(tags="skill_manage")`）：`skill_install`
  （从本地含 `SKILL.md` 的目录装到 `./skills`，`forceCover`
  控制覆盖）、`skill_uninstall`（`FileUtil.moveToTrash`）、`skill_extract`（导出到本地路径）；技能的实际扫描与执行由 ai-starter
  的 `AiSkillsAutoConfiguration` + `GroovySkillScriptRunner` 负责。
- **数据库写工具**（`DatabaseUpdateTools`，`ai.tools.database.update.enable:false`
  默认关，`@ConditionalOnClass(DataSource)`+`@ConditionalOnBean(DatasourceProvider)`+`@AutoConfigureAfter(DefaultDatasourceProvider)`）：`sql_update_datasource`
  （单条 DML 返回影响行数）、`sql_script_datasource`（多语句脚本，可配 autoCommit/delimiter/sendFullScript/stopOnError）。
- **RAG**（`i2f.springboot.ai.rags.enable:true`，装配已下沉 ai-starter）：HTTP OpenAI embedding + Sqlite 向量存储 +
  文档目录后台加载 +
  分桶记忆；ops 侧保留两件：
  - `RagDataSourceCollector`（`ai.rags.datasource.enable:true`
    ）：把 `SqliteRagEmbeddingStore`/`SqliteBucketRagMemoryStore`/`SqliteRagDocumentsStore`
    包装成 `DirectConnectionDatasource`，以 `rag_*`/`ragBucket_*`/`ragDocs_*` 名字注册进数据源池，供 SQL 控制台直接查向量库；
  - `RagEmbeddingCache`（`new RagEmbeddingCache("skills").run()`）：`LruMap(8192)` + 每 30s
    落盘 `runtime/tmp/embedding-cache/<type>.json` 的守护线程，按文本内容缓存 embedding，避免重复计费。
- **MCP 服务端桥接**（三条通道，工具名统一加 `ops.` 前缀）：
  - `OpsMcpServerAdditionalToolProvider`（`@Component`，无开关）：实现 `McpServerAdditionalToolProvider`
    ，用 `ListableAppToolManager` + `ToolRawHelper.parseTools(null, this)` 自建工具清单，暴露 `upload_local_file`
    （本地→临时库）、`store_url_file_to_local`（临时库→本地）、`query_async_task_status_by_url`（按 `task://` 签名 URL
    查询/等待异步任务，`awaitSeconds` 夹取 `[0,180]`）；
  - `OpsMcpServerApiToolProvider`（`ai.mcp-server.api.enable:true`，`@RestController` `@RequestMapping("/mcp/api")`
    ）：除工具 `get_server_guide`（返回含 baseURL 探测顺序、ping 校验、token 获取、上传下载示例的 markdown
    向导）与 `mcp_api_token`（发放 `msk-<uuid>`）外，另开 `GET /ping`（无鉴权）、`POST /file/upload`、`POST /file/download`
    （均要求 `X-MCP-TOKEN` 头，token 存 `LruMap(4096)`，30 分钟滑动过期）；`/file/download` 支持 `url`（临时库）或 `path`
    （本地策略）二选一，走 `ServletFileUtil.downloadFileRangeSupport` 支持 Range；
  - `DashScopeOpsMcpServerAdditionalToolProvider`（`@Conditional(DashScopeOpsController.DashScopeCondition.class)`）：把 8
    个 DashScope 工具（kling/vidu/wan 文生图、happyhorse/kling/pixverse/vidu 文生视频、`qwen_tts`）再以 `ops.`
    前缀暴露，统一返回 `taskUrls` + `hint` 指向 `query_async_task_status_by_url`，形成「提交 → 拿签名任务 URL → 轮询」的协议闭环。
- **异步任务协议**（`AsyncTaskHelper`，`@Component`，`PROTOCOL="task"`）：`signTask` 把任务参数 form-encode 后 hex
  编码拼进 `task://<taskId>/<type>/<resultType>/<params>` 并用 `UrlSigner` 签名；`verifyTask`
  反向验签解析，`DashScopeQwenTtsTools` 等 `AsyncTaskResolver` 按 `type` 处理。
- **TTS**：Qwen（`DashScopeQwenTtsTools`，`ai.tools.qwen_tts.enable:true`，`TASK_TYPE=dashscope_qwen_tts`
  ，默认模型 `qwen-audio-3.0-tts-plus`、默认音色 `longanlingxin`，WebSocket 客户端）、命令行 espeak、Termux 播报。
- **DashScope 生成**（`DashScopeOps*`）：文生图（wan/kling/vidu）、文/图生视频（happyhorse/kling/pixverse/vidu/wan 数字人/换人）、3D（tripo）、任务与临时文件管理。
- **菜单聚合**（`OpsHomeController` `/ops/menus`）：遍历所有 `IOpsProvider` Bean
  汇总并按标题排序，驱动前端导航（`OpenAiOpsController` 归属 `OpsHomeMenuGroup.AI`）。
- **入口限流**（`i2f.springboot.ops.limited.enable:true`，默认开，`common/limit` 4 类）：`OpsLimitedRequestFilter`
  按「全局 `all-rule`（共享桶 `ops:limited:all`）→ 每 IP `every-ip-rule`（`ops:limited:ip:{ip}`，桶容器 `LruMap`，上限
  `lru-max-size` 默认 8192）→ ANT 路径 `path-rules[]`（`ops:limited:ant-path:{pattern}`，`AntMatcher` 命中才计数）」逐层
  `tryAcquire(1, SECONDS)`；任一层失败抛 `OpsLimitedException`，末尾 `catch` 统一 `reset()` 后写 429 +
  `text/html;charset=utf-8`，写回前先判 `response.isCommitted()`（SSE 已发首帧则直接返回）；`chain.doFilter` 也在 `try`
  内，下游抛出的同类异常走同一出口。挂载范围 `filter-url-pattern` 留空时取 `OpsConsts.BASE_URL_PROPERTY` 拼 `/*`。
- **静态资源**：`OpsStaticResourceConfiguration` 映射 `/ops/lib/**`（7 天）与 `/ops/**`（1 天）并恢复默认映射，`StaticResourceMediaTypeAdjustConfiguration` 注册 `mjs→application/javascript`。

## 主要使用方法

```yaml
# 1) 引入 starter（compile），无需 @ComponentScan 即自动装载整套控制台
# 2) 配置一枚 SM 密钥对（不配则每次启动自动生成并打印，客户端证书随之失效）
i2f:
  springboot:
    ops:
      base-url: /ops
      secure:
        cert: <base64(JSON) 密钥对>
      datasource:                          # 绑定前缀 i2f.springboot.ops.datasource
        datasource-map:                    # 字段 datasourceMap，统一用 kebab-case
          test: { driver: org.h2.Driver, url: jdbc:h2:file:../h2/test.h2.db, username: root, password: 123456 }
      app: { enable: false }     # 建议显式关闭在线求值面
      ssh: { enable: false }
      open-ai: { enable: true }  # 默认关，开启后 /ops/open-ai/**
      limited:                   # 绑定前缀 i2f.springboot.ops.limited
        # filter-url-pattern: /ops/*        # 留空则取 {base-url}/*
        all-rule: { enable: true, rate-per-second: 100, capacity: 300 }
        every-ip-rule:
          lru-max-size: 8192     # 每 IP 桶的 LRU 上限
          rule: { enable: true, rate-per-second: 100, capacity: 300 }
        path-rules:
          - ant-path: /ops/open-ai/*
            rule: { enable: true, rate-per-second: 20, capacity: 50 }
ai:
  tools:
    command: { enable: true }        # 按需开启高危工具
    database:
      update: { enable: true }       # 默认 false
    recycle: { enable: true }        # ref:// 上下文瘦身
    skill-manage: { enable: true }   # skill_install/uninstall/extract
    ssh:                             # ai.tools.ssh.* 具名主机 SSH 工具-默认关，需 jsch
      enable: false
      default-wait-seconds: 120
      max-wait-seconds: 500
      hosts:
        - name: dev                  # 工具入参 host
          enable: true               # 逐台开关
          host: 192.168.1.10
          port: 22
          username: root
          password: xxx
          # private-key: /root/.ssh/id_rsa
          workdir: /opt/app
  rags:
    datasource: { enable: true }     # rag_* 数据源反桥（对应 ${ai.rags.datasource.enable:true}）
    # 注意：RAG 自身总开关是 ai-starter 的 i2f.springboot.ai.rags.enable，不在此前缀下
  mcp-server:
    api: { enable: true }            # /mcp/api 通道，默认 true
```

- 前端访问 `http://host:port/ops/`，`/ops/index.html` 进入控制台，`/ops/menus` 拉取导航。
- 限流：`/ops/**` 开箱即限——全局 100/s（容量 300）、每 IP 100/s（容量 300），路径规则按需追加；令牌不足返回 `429` +
  `global limited.` / `ip limited.` / `path limited.`，SSE 已提交时不再改写响应。
- 所有业务接口 `POST`，请求体为 `OpsSecureDto`（含 `timestamp/nonce/key/payload/sign/digital`），响应为 `OpsSecureReturn<OpsSecureDto>`；客户端须持有配套密钥对方能加解密与签名。
- hostId：请求体带 `hostId` 用于集群定向；不带则本机处理（见瑕疵）。
- **外部 MCP 客户端接入**（纯 HTTP，不需要 SM 信封）：先 `GET /ops/mcp/api/ping` 确认可达，再调用工具 `ops.mcp_api_token`
  取得 `msk-*` 令牌，之后 `POST /ops/mcp/api/file/upload`（`multipart/form-data`，字段 `file`）或 `/file/download`
  （JSON `{url}` 或 `{path}`），请求头带 `X-MCP-TOKEN`。工具清单（含 `ops.` 前缀工具）通过 ai-starter 的 MCP server 端点暴露。

## 特性总结

- **加 jar 即得**：84 个组件经双通道 `EnableAutoConfiguration` 登记，无需组件扫描即可点亮整个控制台——部署最省事，但代价是「误用自动配置机制」（见瑕疵）。
- **国密自研安全信封**：SM2（密钥封装 + 签名）+ SM4（数据加密）+ SM3（摘要），全部来自 `i2f-sm-crypto`，不再依赖 antherd 的 JS
  移植版；兼具机密性、完整性、签名与时效（±12h）校验。
- **可反向被智能体操作**：三条 `McpServerAdditionalToolProvider` 通道 + `/mcp/api` 文件面，把控制台从「人来点的后台」变成「Agent
  可调的工具集」，且以 `@McpServerExpose(false)` 精确排除 RAG 长耗时与内部工具。
- **具名主机 SSH 工具**：`ai.tools.ssh.hosts[]` 用 `name` 标识多台主机，模型只能在该清单内选主机；本机路径始终过
  `LocalFileTools` 沙箱，远端路径不限制，结果以 `SshOutcome` 结果码 + `hints` 引导下一步（默认关闭）。
- **能力域模块化 + 逐域开关**：app/datasource/ssh/redis/es/minio/aws-s3/host/xproc4j/xxl-job/openai/dashscope 各带 `@ConditionalOnExpression` 独立 enable；AI 工具/技能/RAG 另有 `ai.*` 细粒度开关。
- **可扩展装配**：`IOpsProvider`（菜单）、`DatasourceProvider`/`DatasourceCollector`（数据源）、`@Tool`（AI
  工具）、`SkillDefinition`/`AsyncTaskResolver`（技能与异步任务）均为可插拔契约，`@ConditionalOnMissingBean` 允许宿主覆盖。
- **分层清晰**：重型能力（RAG/技能/工具管理器）下沉 ai-starter，ops 只保留「控制台 UI + 运维域 + ops 特有工具 + MCP 桥」。
- **前后端一体**：内嵌大规模 Vue2 SPA 与渲染库（three.js/mermaid/pdf.js/xlsx/echarts…），零独立前端部署。
- **入口限流**：`OpsLimitedRequestFilter`（order=1）以「全局 / 每 IP / ANT 路径」三层令牌桶拦在业务之前，每 IP 桶用
  `LruMap`（默认 8192）封顶、超限统一 429；与 `i2f-springboot-limit-starter` 的分布式限流互补——这里是单机、零外部依赖、开箱即用的兜底。

## 模块瑕疵或错误（实证）

> 以下均经通读源文件 + 元数据 + 全仓 enable 开关分布核实，非臆测。

### 已消解（本轮重构删除的类）

- `RagAutoConfiguration.memoryTools(...)` 缺 `@Bean` 导致 `MemoryTools` 永不注册 —— 该类已整体删除，RAG 装配移交
  ai-starter。
- `SkillAutoConfiguration` 用 `static final ScheduledExecutorService` 每 30s 扫文件系统、类加载即建池从不 shutdown ——
  该类已删除，扫描职责移交 ai-starter 的 `AiSkillsAutoConfiguration`。
- `RagAutoConfiguration.ragWorker` 在 `@Bean` 内 `new Thread(...).start()` 并 `move` 整个 docs 目录 —— 同样随类删除。

### 仍成立

- **【高危·装配反模式·规模空前】84 个组件类被直接登记进 `EnableAutoConfiguration`**（`spring.factories`
  与 `AutoConfiguration.imports` 双份一致）：其中 `AppOpsController`/`SshOpsController`/`OpsMcpServerApiToolProvider`/…
  是 `@Controller`/`@RestController`，`SpringHolder`/`OpsSecureTransfer`/`DefaultDatasourceProvider`/各 `*Tools`
  /各 `*Collector` 是 `@Component`——**它们都不是 `@AutoConfiguration`/`@Configuration`**。这既非自动配置类的语义，也意味着若宿主组件扫描命中同包将
  **双重注册**；auto-config 通道也不提供 lite 全量代理等保证。
- **【高危·加密】`OpsSecureHelper.generateCertPair()` 中 `clientPair = serverPair;`（L36-41，覆盖行 L39）覆盖上一行刚生成的客户端密钥对
  **：`serverCert` 与 `clientCert` 内容**完全相同**，且二者均为「含私钥的完整密钥对」的 Base64(JSON)。server/client
  双密钥对形同虚设，任何拿到 clientCert 者即持有服务端私钥，可自签自解伪造任意请求。
- **【高危·默认攻击面】默认开启的高危能力面过宽**：`i2f.springboot.ops.app.enable:true` → `/ops/app/eval` **Groovy 任意代码执行
  HTTP 端点默认装载**（并注入全部 bean 与
  ApplicationContext）；`ops.datasource/ssh/host/redis/elasticsearch/minio/aws-s3/xproc4j/xxl-job` 均默认 `true`（含远程
  shell、文件删改、SQL 增删）。而 AI 侧 `ai.tools.command/groovy/nodejs`、`ai.tools.database.update`
  默认 `false`、`ops.open-ai` 默认 `false`——**同为执行类能力，HTTP eval 后门默认开、AI 命令工具默认关，安全姿态不一致**
  。唯一闸门是 SM 信封 + hostId。
- **【高危·鉴权】`HostIdHelper.canAcceptHostId(reqHostId)` 在 `reqHostId` 为 null/空时直接 `return true`（L75-77）**：hostId
  这道闸门对不带 hostId 的请求一律放行，实质只用于集群定向/代理而非鉴权，易被误当作安全边界。
- **【缺陷·NPE 静默】`DefaultDatasourceProvider.refresh()`**
  ：L69-74 `dataSourceMap.put("primary", dataSourceMap.get(defaultName))` 在未探测到任何数据源、`defaultName` 为 null
  时 `get(null)`→null，`put(k,null)` 抛 NPE 并被紧邻空 `catch(Exception)` 吞掉 → `primary`
  别名静默缺失；`detectPrimaryDatasource` L85-87 在顶部已判空后重复 `isEmpty`（死分支）；两个 `catch` 全空（L61-63、L65-67）致
  collector 抛错半装载无感。
- **【缺陷·重复刷新】`initialize()` 以 `defaultDataSourceName.get() != null` 作短路（L46-51）**
  ：本机无任何数据源时每次 `getDatasourceMap()`/`getDefaultDataSourceName()` 都会全量重跑所有
  collector（`RagDataSourceCollector` 也会被反复反射查询）。
- **【缺陷·裸线程 + 死分支】`AppEvalOpsController.eval`**：每次请求 `new Thread(task).start()`
  （L113，非守护、无池）；`latch.await(waitForSeconds)` 超时后**不中断**脚本线程，失控脚本继续运行；`waitForSeconds`
  现被夹取为「`<0` → 120、`>=500` → 500」（有默认值后恒 `>=0`），使后续 `else latch.await()`
  成为死分支；`catch(InterruptedException){}` 仍吞。
- **【缺陷·启动开销/日志】`OpsSecureAutoConfiguration.opsSecureKeyPair()`（L27-42）**：未配 cert
  时启动即生成密钥对并用 `System.out.println`（非 logger）打印，且**每次无 cert 启动都换新密钥** → 已下发 clientCert
  立即失效；随后调用 `test()` 再生成一对做一次加解密自测往返（无谓密码学开销）。
- **【安全面·鉴权外扩】`SshOpsController.cmd`/`execSftpCmd`**：`util.exec(...)` 在目标机执行任意 shell、`runAsFile` 上传 `.sh` 再 `sh -c`（目标机 RCE）；`download`/`head`/`tail` 把请求携带的任意服务器路径直接作为 SFTP 参数（路径穿越面）；`delete` 递归删。均只受 SM 信封 + 可空放行的 hostId 保护。
- **【安全面·注入】`DatasourceOpsController.doImport`**：`insert into {table} (列...) values (${列})` 中 `table` 取 `req.getTable()` **原样字符串拼接**（`${}` 值走 `BindSql` 参数绑定，但表名/列名未走标识符白名单或转义），存在标识符注入面。
- **~~【欠登记·元数据】`additional-spring-configuration-metadata.json` 仅登记 `i2f.springboot.ops.secure.cert` 一个属性~~
  （已修复）**
  ：现已按源码 `@ConditionalOnExpression`/`@Value`/`@ConfigurationProperties` 全量同步，登记 6 个
  groups（`i2f.springboot.ops`、
  `.secure`、`.datasource`、`.limited`、`ai.openai`、`ai.tts.qwen`）与 117 个 properties，覆盖 `base-url`、13 个域级 `enable`、
  `datasource.datasource-map.*`（kebab-case，字段仍为 `datasourceMap`）、`ai.tools.*` 全部开关与模型参数（含
  `skill-manage`/`ssh`/`recycle`/`database.update`/`qwen_tts`/`happyhorse-t2v` 等）、`ai.rags.datasource.enable`、
  `ai.mcp-server.api.enable`、`i2f.springboot.ops.limited.*`（14 项：开关/挂载范围/三层规则）、`ai.tts.qwen.*`、`ai.openai.*`
  ；原两条从别处拷贝的死 `hints`（`server.servlet.jsp.class-name` /
  `server.tomcat.accesslog.encoding`）已删除。本模块不存在 `ai.rags.enable`（RAG 总开关在 ai-starter
  的 `i2f.springboot.ai.rags.enable`）。
- **【一致性】`AppOpsController`/`AppEvalOpsController` 每个端点重复 `if(!canAcceptHostId){ if(isProxyHostId) proxy }` + `assertHostId` 样板**，未抽公共拦截器，漏写风险高；`SpringHolder` 以静态字段持有 context（多上下文/测试串扰风险）；自动配置类/`@Component` 普遍叠加 `@Data`+`@NoArgsConstructor`（暴露 setter、本组通病）。

### 新增问题（本轮重构引入）

- **【高危·弱鉴权】`/mcp/api` 的令牌可自助发放且无主体绑定**：`mcp_api_token`
  只要被任意已接入的模型/客户端调用就返回新的 `msk-<uuid>`，不记录来源、不区分权限、不与 hostId/SM 信封关联；`verifyToken`
  （L262-272）仅查 `LruMap` 时间戳并在命中时续期 30 分钟。凡能触达 `/ops/mcp/api`
  且能调用一次工具者即可获得上传/下载能力；`GET /ping`（L253-260）更是完全无鉴权，直接回 `code:200`。
- **【缺陷·NPE】`/mcp/api` 与 `upload_local_file` 对可选依赖未判空**：`OpsMcpServerApiToolProvider.fileUpload`
  （L290）直接用 `tmpFileTools.saveFile(...)`、`OpsMcpServerAdditionalToolProvider.upload_local_file`
  （L121/L128）直接用 `localFileTools.getFile(...)` 与 `tmpFileTools.saveFile(...)`
  ，而两者字段均为 `@Autowired(required=false)`；当宿主只关了 `TmpFileTools`/`LocalFileTools`（对应工具开关）时，工具与端点仍在清单里却必抛
  NPE（同文件 L144 对 `store_url_file_to_local` 有判空，说明是遗漏）。
- **【缺陷·状态覆盖】`fileDownload` 的 404 分支未 `return`**（L324-329）：`url` 下载失败写入 404 文案后继续进入 `path`
  分支，若 `path` 为空则落到 L344 `setStatus(400)` 覆盖状态码，客户端收到 400 但正文是 404 提示。
- **【高危·硬编码盐】`UrlSigner.DEFAULT_URL_SIGN_SALT = "abc123def456"`（L19）**：异步任务 URL（`task://`）与 `ref://`
  引用的签名校验使用固定默认盐且未走配置项，攻击者可自行构造合法签名的 `task://` URL
  交给 `query_async_task_status_by_url` 触发任意 `AsyncTaskResolver` 调用；`AsyncTaskHelper.verifyTask` 完全依赖该签名。
- **【缺陷·空壳】`WebjsTools` 所有 `@Tool` 方法均 `throw getUnSupportException()`（L48/L62）**：`nashorn`
  依赖被注释后未删除工具类，仍带 `@ConditionalOnExpression("${ai.tools.webjs.enable:true}")`
  与工具清单注册，模型调用必得 `UnsupportedOperationException`（现靠 `@McpServerExpose(false)` 才未暴露成 MCP 工具）。
- **【装配·重复登记】`i2f.springboot.ai.skills.GroovySkillScriptRunner`（清单 L34/L33）是 ai-starter 的类**，被同时写进
  ops-starter 与 ai-starter 两份 `EnableAutoConfiguration` 清单。Boot 会按类名去重，功能无损，但两模块版本不一致时极易出现「以为是
  ops 的类」或清单漂移，属跨模块清单耦合。
- **【缺陷·异常静默】`RagDataSourceCollector.collect()`** 三段各自 `catch (Exception e) { /* ignore */ }`（L47/L60/L73）：RAG
  库未初始化、连接失效等问题一律无日志，表现为「数据源列表里莫名少了 `rag_*`」。
- **【缺陷·IO 放大】`RagEmbeddingCache.run()`**：守护线程每 30s 把整张 8192 项 `LruMap` 全量 JSON
  序列化重写一次（无脏标记、无原子替换），`load()` 解析失败仅 `printStackTrace` 后继续以空缓存运行；缓存文件损坏/并发写坏时无自愈与告警。
- **【一致性】`OpsMcpServerAdditionalToolProvider` 与 `OpsMcpServerApiToolProvider` 的 `getHolderManager()`
  各自 `new ListableAppToolManager()` 并重复 `ToolRawHelper.parseTools` + 手动改 `ops.` 前缀**
  （L85-86、L81-82），同一套「前缀工具清单」逻辑复制两遍，前缀字符串也以字面量散落各处，改名/加前缀需多点同步。
- **【缺陷·工具面悬空】`SshTools` 的本机侧依赖 `LocalFileTools`**：`ssh_upload`/`ssh_download` 一律经
  `localFileTools.getFile(...)` 做沙箱，而该字段同为 `@Autowired(required=false)`；宿主关闭 `ai.tools.file.enable`
  后工具仍在清单内，调用返回 `local_file_disabled`（已由 `SshOutcome` 结构化兜底、不再抛 NPE），但上传/下载能力实际不可用。

### 请求限流（本轮新增）

- **【缺陷·配置漂移】`every-ip-rule` 由平铺结构收拢为 `EveryIpLimitRule{lruMaxSize, rule}`**：旧键
  `every-ip-rule.enable/rate-per-second/capacity` 在 Boot `ignoreUnknownFields=true` 下被**静默忽略**
  ，升级后不报错但限流参数静默回落默认值。
- **【缺陷·默认值双份】`OpsLimitedRequestFilter` 字段初始化写死 `new TokenBucketRateLimiter(100, 300)`
  与 `new LruMap<>(8192)`**
  ，与 `OpsLimitProperties` 中的默认值重复；改一处漏一处即出现「配置类改了、过滤器没改」的偏差。
- **【缺陷·不可热更】令牌桶的 `ratePerSecond`/`capacity` 在首次 `computeIfAbsent` 时固化**，运行期改配置不生效需重启；
  IP 桶被 `LruMap` 按访问序淘汰后再次访问会拿到满桶，等于给偶发 IP 重置了配额。
- **【依赖·未直声明】过滤器直接 `import i2f.lru.LruMap` 与 `i2f.match.impl.AntMatcher`**，但 pom 只声明了
  `i2f-limit`，`i2f-lru-map` / `i2f-match` 靠传递引入；传递链一变即编译失败。

## 生态位置

- 位于 i2f **依赖栈顶端的聚合枢纽**：直接 compile 引入 23 个内部模块，并把 `i2f-springboot-ai-starter` 整条 AI
  装配链一并带入，把它们的能力以 HTTP + 前端形式统一对外。
- 与专项 Starter 的关系是**上层复用而非被复用
  **：`i2f-springboot-xproc4j-starter`（`XProc4jOpsController`）、`i2f-springboot-ssh-tunnel-starter`（`SftpUtil`）、`i2f-sm-crypto`、`i2f-extension-groovy`、`i2f-extension-sftp`、`i2f-image-impl`
  等模块文档均把本模块标注为**消费方**；本模块自身一般不被其它库依赖。
- 与 `i2f-springboot-ai-starter` 形成**双向关系**
  ：编译期是它的消费者（RAG/技能/工具管理器），运行期又通过 `RagDataSourceCollector`、`McpServerAdditionalToolProvider` 反向给它的
  RAG 与 MCP 通道供料，二者须同版本演进（`GroovySkillScriptRunner` 双清单登记即为耦合证据）。
- 典型适用场景：内网/自管理型应用需要「一个 jar 换来全套在线运维 + AI 调试台 + 可被 Agent 调用的工具面」；因其默认开启
  eval/SQL/SSH 与 `/mcp/api` 自助发令牌等强能力，生产环境务必显式关闭对应 `ops.*.enable`/`ai.tools.*`
  、配置固定 `secure.cert`，并在网关层限制 `/ops/mcp/api/**` 的访问来源。
