# i2f-springboot-ops-starter

## 模块路径

`i2f-springboot/i2f-springboot-ops-starter`

## 模块概述

i2f-springboot 组中**体量最大、能力最全**的重型一体化运维 / 开发控制台 Starter（174 个 Java 源文件 + 内嵌完整前端 SPA）。它把「应用自省、多数据源 SQL 控制台、SSH/SFTP 文件与命令、Redis、Elasticsearch、MinIO、AWS S3、主机文件、xproc4j、xxl-job、DashScope 图/视频/3D 生成、OpenAI 对话 + AI 工具集 + RAG + Groovy 技能 + TTS」等一整套运维与 AI 能力，连同 Vue2 前端，封装进单个 jar；仅靠把本 Starter 放入 classpath 即**全自动装载**整套控制台（约 80 个组件类被登记进 `EnableAutoConfiguration`），统一挂在 `i2f.springboot.ops.base-url`（默认 `/ops`）路径下，所有请求/响应经一套 **SM2/SM3/SM4 国密安全信封**（`OpsSecureTransfer`）加解密与签名。它是本组少见的「依赖栈顶端聚合枢纽」——直接 compile 引入约 22 个 i2f 内部模块，并被多个上游模块文档标注为消费方，而非孤岛。

## 模块依赖

### i2f 内部依赖（compile，传递引入）

| 依赖 | 用途 |
| --- | --- |
| `i2f-sm-crypto` | 国密 SM4 密钥生成（`Sm4.generateHexKey`），安全信封对称密钥来源 |
| `i2f-jdbc-impl` | 数据源控制台 `JdbcResolver`/`JdbcScriptRunner`/`BindSql` 执行 SQL |
| `i2f-database-metadata-impl` | 导入时 `DatabaseMetadataProviders` 取表/列元数据 |
| `i2f-os` | `OsUtil` 命令执行 / OS 判断（CommandTools、SSH 相关） |
| `i2f-network` | `NetworkUtil.getUsefulAddresses` 计算 hostId |
| `i2f-mutator` | `toMutator().set(...).done()` 装配 DSL（AI/RAG/工具广泛使用） |
| `i2f-image-impl` | 图像能力（dashscope 图/视控制台） |
| `i2f-jdk-ext-web` | `ServletFileUtil` 附件下载、Web 工具 |
| `i2f-extension-sftp` | `SftpUtil`/`ChannelSftp`：SSH 文件管理、exec、隧道式命令 |
| `i2f-extension-groovy` | `GroovyScript.eval`：`/ops/app/eval` 在线求值、技能脚本 |
| `i2f-extension-filesystem-minio` | MinIO 控制台 |
| `i2f-extension-filesystem-oss-aws-s3` | AWS S3 控制台 |
| `i2f-extension-elasticsearch` | ES 控制台 |
| `i2f-rowset` | CSV/JSONL/JSON 行集读写（导出/导入、RowSetWriter） |
| `i2f-ai-std` | AI 工具/Skill/RAG/MCP 抽象（`@Tool`、`ToolManager`、`SkillsTools`、`Rag*`） |
| `i2f-ai-rest-openai` | `HttpOpenAiRagEmbeddingModel`、OpenAI 对话后端 |
| `i2f-extension-ai-rag-sqlite` | `SqliteRagEmbeddingStore`/`SqliteBucketRagMemoryStore` 向量存储 |
| `i2f-spring-core` | `SpringContext` 适配（工具/技能上下文） |
| `i2f-spring-web` | `SpringWebRestClient`（RAG embedding HTTP） |
| `i2f-uid-impl` | 生成 ID（UidTools） |
| `i2f-extension-jackson`* | `JacksonJsonSerializer`（工具/MCP 序列化，经传递引入） |
| `i2f-extension-document` | `PdfConvertUtil`（PDF→图片给 OCR reader） |

> `*` `i2f-extension-jackson` 未在 pom 直接声明，经其它 i2f 模块 compile 传递后在 `SpringContextToolAutoConfiguration`/`RagAutoConfiguration` 中直接 `import`，属依赖未直声明。

### 外部依赖（provided + optional，按需自装）

| 依赖 | 版本 | 用途 |
| --- | --- | --- |
| `com.antherd:sm-crypto` | 0.3.2.1-RELEASE | 前端一致的 SM2/SM3/SM4 JS 移植实现（安全信封 `Sm2/Sm3/Sm4`） |
| `org.openjdk.nashorn:nashorn-core` | 15.4 | JS 引擎（webjs 工具/前端脚本求值） |
| `com.github.jsqlparser:jsqlparser` | 4.9 | SQL 校验（`OpsSqlParserAstSqlValidator`），注释注明 4.9 为 JDK8 最后版本 |
| `com.baomidou:dynamic-datasource-spring-boot-starter` | 3.5.2 | 动态多数据源探测（BaomidouDynamicDatasourceCollector） |
| `spring-boot-starter-data-redis` / `redis.clients:jedis` / `redisson-spring-boot-starter` | - / - / 3.20.1 | Redis 控制台三种客户端解析 |
| `com.xuxueli:xxl-job-core` | 2.4.1 | xxl-job 控制台 |
| `com.h2database:h2` | 2.2.224 | sample 内嵌库 |
| `com.jcraft:jsch` | 0.1.55 | SFTP/SSH 底层（provided，未 optional） |
| `org.apache.groovy:groovy` | 4.0.18 | 求值/技能脚本（provided+optional） |
| `io.minio:minio` | 7.1.0 | MinIO 控制台 |
| `software.amazon.awssdk:s3 / kms / s3control` | BOM 2.17.100 | AWS S3 控制台 |
| `org.elasticsearch[.client]:*` | 7.6.2 | ES 控制台（含 `RestHighLevelClient`） |
| `cn.6tail:lunar` | 1.3.14 | 农历/干支工具（LunarTools、ba-zi/gan-zhi） |
| `org.apache.pdfbox:pdfbox` | 2.0.29 | PDF 处理 |
| `org.java-websocket:Java-WebSocket` | 1.5.3 | Qwen TTS WebSocket |

> 依赖面极广：约 22 个 i2f 内部 compile + 上述大量 provided。由于内部依赖均为 compile 传递，**引入本 Starter 会把整台「运维 + AI」控制台的重资产一次性拉入**任何宿主应用；外部集成库标 provided+optional，由宿主按启用的功能自行补齐。构建用 `maven-assembly-plugin`，`addMavenDescriptor=true`。

## 模块设计

```mermaid
flowchart TD
    subgraph Boot[classpath 存在即自动装载]
        SF["spring.factories + AutoConfiguration.imports\n(约 80 组件类登记为 EnableAutoConfiguration)"]
    end

    subgraph Common[common：安全信封 + 装载基座]
        HOLDER[SpringHolder\n静态 context/env @Component]
        SEC[OpsSecureTransfer @Component\nSM2 加密密钥 + SM4 payload + SM3 摘要 + SM2 签名]
        HELPER[OpsSecureHelper / OpsSecureKeyPair\nBase64(JSON) 承载含私钥密钥对]
        AUTOCONFIG[OpsSecureAutoConfiguration\n无 cert 时启动生成密钥对并 System.out 打印]
        HOSTID[HostIdHelper\nip#nic@port 主机标识 + canAcceptHostId]
        STATIC[OpsStaticResourceConfiguration\n/ops/lib 7天 / /ops/** 1天 缓存 + mjs media-type]
    end

    subgraph Home[home：菜单聚合]
        HC[OpsHomeController /ops/menus\n遍历 IOpsProvider.getMenus 汇总]
    end

    subgraph Cap[能力域：@Controller，均过安全信封 + hostId]
        APP[app：system/env/beans/deadlock/logging + eval(Groovy)]
        DS[datasource：Provider+Collector\nquery/update/runner/import/export]
        SSH[ssh：SftpUtil 文件/exec/cmd]
        MID[minio / aws-s3 / elasticsearch / redis / host / xproc4j / xxl-job]
    end

    subgraph AI[openai + dashscope]
        OAI[OpenAiOpsController(default off) + AsyncTaskDispatcher]
        TOOLS[tool/impl 约 25 工具\n@Tool 注册进 ContextAppToolManager]
        RAG[RagAutoConfiguration\nSqlite 向量存储 + 文档后台加载]
        SKILL[SkillAutoConfiguration\n静态调度池 30s 扫文件系统 Groovy]
        DASH[DashScopeOps*：图/视频/3D 生成]
    end

    SF --> HOLDER & SEC & AUTOCONFIG & HC & Cap & AI
    SEC --> HELPER
    AUTOCONFIG --> HELPER
    SEC --> HOSTID
    HC --> Cap & AI
    Cap --> SEC
    AI --> SEC
    STATIC -.-> Boot
```

## 模块目的

- 为基于 i2f 的 Boot 应用提供「零配置、加 jar 即得」的一体化在线运维 / 调试 / AI 控制台：运行时自省、多数据源 SQL、目标机文件与命令、常见中间件（Redis/ES/MinIO/S3）操作、定时任务与存储过程查看，以及 DashScope/OpenAI 多媒体与工具调用能力。
- 用国密安全信封统一封装所有入站/出站数据（签名 + 时效 + 加密），并以 hostId 做主机定向/代理路由，供集群中定位具体实例。
- 内嵌 Vue2 + vxe-table + echarts + three.js + mermaid + pdf.js + xlsx 等前端资产，形成自包含的可视化后台。

## 模块功能

- **应用自省**（`AppOpsController`，`i2f.springboot.ops.app.enable:true`）：system-properties、system-env、input-arguments、class-metadata、locked-threads（`ThreadMXBean.findDeadlockedThreads` 死锁检测）、beans 列表、运行期 `logging-level/set`。
- **在线求值**（`AppEvalOpsController` `/ops/app/eval`）：以 Groovy 执行任意脚本，作用域注入 `out`/`context`(ApplicationContext)/`env`/`beanMap`(全部 bean)/`request`。
- **多数据源 SQL 控制台**（`DatasourceOpsController`，`ops.datasource.enable:true`）：SPI 探测驱动、列数据源、多库 `query`/`update`、脚本 `runner`（可配 autoCommit/delimiter/stopOnError）、CSV `export`、带 MD5 校验的 CSV `import`（按表头匹配列拼 insert）。数据源经 `DatasourceProvider` + 三种 `DatasourceCollector`（Static / BaomidouDynamic / Default）聚合。
- **SSH/SFTP 控制台**（`SshOpsController`，`ops.ssh.enable:true`）：file-list、mkdirs、delete、upload/download（MD5 校验）、head/tail 日志、`cmd`（远程 shell，可 runAsFile 落 `.sh` 后 `sh -c` 执行）、内置 sftp 命令解释器（cd/ls/rm/rename/symlink…）。
- **中间件控制台**：Redis（Jedis/Lettuce/Redisson 三解析）、Elasticsearch、MinIO、AWS S3、主机本地文件、xproc4j、xxl-job，各带 `ops.{name}.enable:true` 独立开关。
- **OpenAI 对话 + AI 工具集**（`ops.open-ai.enable:false`，但 `ai.tools.enable:true`）：`OpenAiOpsController`、异步任务派发 `AsyncTaskDispatcher`；约 25 个 `@Tool` 工具（datetime/random/uid/jce/codec/database-metadata/database-query/local-file/tmp-file/truth-store/session-record/webjs/command/groovy/python/nodejs/powershell/web-download/lunar/a2a/mcp-provider/sql-validator…）经 `SpringContextToolAutoConfiguration` 注册进 `ContextAppToolManager`；`ai.tools.command/groovy/nodejs/pandoc/form.enable:false` 默认关。
- **RAG**（`ai.rags.enable:true`）：HTTP OpenAI embedding + Sqlite 向量存储 + 文档目录后台加载（markitdown/easyocr/pandoc reader 可选）+ 分桶记忆。
- **Groovy 技能**（`ai.skills.enable:true`）：`SkillAutoConfiguration` 定时扫描文件系统技能定义并暴露 `SkillsTools`。
- **TTS**：Qwen（WebSocket）、命令行 espeak、Termux 播报。
- **DashScope 生成**（`DashScopeOps*`）：文生图（wan/kling/vidu）、文/图生视频（happyhorse/kling/pixverse/vidu/wan 数字人/换人）、3D（tripo）、任务与临时文件管理。
- **菜单聚合**（`OpsHomeController` `/ops/menus`）：遍历所有 `IOpsProvider` Bean 汇总并按标题排序，驱动前端导航。
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
      datasource:
        datasourceMap:
          test: { driver: com.h2.Driver, url: jdbc:h2:file:../h2/test.h2.db, username: root, password: 123456 }
      app: { enable: false }     # 建议显式关闭在线求值面
      ssh: { enable: false }
ai:
  tools: { command: { enable: true } }   # 按需开启高危工具
  rags: { enable: true }
```

- 前端访问 `http://host:port/ops/`，`/ops/index.html` 进入控制台，`/ops/menus` 拉取导航。
- 所有业务接口 `POST`，请求体为 `OpsSecureDto`（含 `timestamp/nonce/key/payload/sign/digital`），响应为 `OpsSecureReturn<OpsSecureDto>`；客户端须持有配套密钥对方能加解密与签名。
- hostId：请求体带 `hostId` 用于集群定向；不带则本机处理（见瑕疵）。

## 特性总结

- **加 jar 即得**：约 80 组件经双通道 `EnableAutoConfiguration` 登记，无需组件扫描即可点亮整个控制台——部署最省事，但代价是「误用自动配置机制」（见瑕疵）。
- **国密自研安全信封**：SM2（密钥封装 + 签名）+ SM4（数据加密）+ SM3（摘要），与前端 `sm-crypto` JS 实现镜像，兼具机密性、完整性、签名与时效（±12h）校验。
- **能力域模块化 + 逐域开关**：app/datasource/ssh/redis/es/minio/aws-s3/host/xproc4j/xxl-job/openai/dashscope 各带 `@ConditionalOnExpression` 独立 enable；AI 工具/技能/RAG 另有 `ai.*` 细粒度开关。
- **可扩展装配**：`IOpsProvider`（菜单）、`DatasourceProvider`/`DatasourceCollector`（数据源）、`@Tool`（AI 工具）、`SkillDefinition`（技能）均为可插拔契约，`@ConditionalOnMissingBean` 允许宿主覆盖。
- **前后端一体**：内嵌大规模 Vue2 SPA 与渲染库（three.js/mermaid/pdf.js/xlsx/echarts…），零独立前端部署。

## 模块瑕疵或错误（实证）

> 以下均经通读源文件 + 元数据 + 全仓 enable 开关分布核实，非臆测。

- **【高危·装配反模式·规模空前】约 80 个组件类被直接登记进 `EnableAutoConfiguration`**（`spring.factories` 与 `AutoConfiguration.imports` 双份完全一致）：其中 `AppOpsController`/`SshOpsController`/… 是 `@Controller`，`SpringHolder`/`OpsSecureTransfer`/`OpsSecureHelper`/`DefaultDatasourceProvider`/各 `*Tools`/各 `*Collector` 是 `@Component`——**它们都不是 `@AutoConfiguration`/`@Configuration`**。这既非自动配置类的语义，也意味着若宿主组件扫描命中同包将**双重注册**；auto-config 通道也不提供 lite 全量代理等保证。与 trace-mdc-starter / websocket-starter 同族，但规模放大到约 80 类。
- **【高危·加密】`OpsSecureHelper.generateCertPair()` 中 `clientPair = serverPair;` 覆盖上一行刚生成的客户端密钥对**：导致 `serverCert` 与 `clientCert` 内容**完全相同**，且二者均为「含私钥的完整密钥对」的 Base64(JSON)（`deserializeKeyPair` 反序列出 `publicKey`+`privateKey`）。设计上的 server/client 双密钥对形同虚设，任何拿到 clientCert 者即持有服务端私钥，可自签自解伪造任意请求。
- **【高危·默认攻击面】默认开启的高危能力面过宽**：`i2f.springboot.ops.app.enable:true` → `/ops/app/eval` **Groovy 任意代码执行 HTTP 端点默认装载**（并注入全部 bean 与 ApplicationContext）；`ops.datasource/ssh/host/redis/elasticsearch/minio/aws-s3/xproc4j/xxl-job` 均默认 `true`（含远程 shell、文件删改、SQL 增删）。而 AI 侧 `ai.tools.command/groovy/nodejs` 默认 `false`、`ops.open-ai` 默认 `false`——**同为执行类能力，HTTP eval 后门默认开、AI 命令工具默认关，安全姿态不一致**。唯一闸门是 SM 信封 + hostId。
- **【高危·鉴权】`HostIdHelper.canAcceptHostId(reqHostId)` 在 `reqHostId` 为 null/空时直接 `return true`**：hostId 这道闸门对不带 hostId 的请求一律放行，实质只用于集群定向/代理而非鉴权，易被误当作安全边界；真正准入仅靠是否持有 SM 密钥对。
- **【缺陷·Bean 永不生成】`RagAutoConfiguration.memoryTools(...)` 缺 `@Bean` 注解**（仅 `@ConditionalOnExpression`+`@ConditionalOnMissingBean`）：方法从不作为 Bean 工厂被调用，`MemoryTools` 永不注册，`ai.rags.memory.*` 开关与去重判断全部形同虚设。
- **【缺陷·NPE 静默】`DefaultDatasourceProvider.refresh()`**：`dataSourceMap.put("primary", dataSourceMap.get(defaultName))` 当未探测到任何数据源、`defaultName` 为 null 时，`get(null)`→null，`ConcurrentHashMap.put(k,null)` 抛 NPE，恰被紧邻的空 `catch(Exception)` 吞掉 → `primary` 别名静默缺失、无任何告警；`detectPrimaryDatasource` 顶部已 `isEmpty` 判断后又重复 `isEmpty`（死分支）；collector 抛错整段吞异常致半装载无感。
- **【缺陷·泄漏】`SkillAutoConfiguration` 用 `static final ScheduledExecutorService pool = newScheduledThreadPool(2)`**：类加载即建、从不 shutdown，每 30s 扫文件系统 Groovy 技能；上下文重启/多次刷新会遗留孤儿调度线程。并 `import` 未使用的 `GroovyShell`/`Script`。
- **【缺陷·裸线程】`AppEvalOpsController.eval` 每次请求 `new Thread(task).start()`**（非守护、无池）：`latch.await(waitForSeconds)` 超时后**不中断**脚本线程，超时仅返回而失控脚本继续运行（线程/资源泄漏、可被拖垮）；`waitForSeconds` clamp 为 `[0,500]`，传 `0` 时 `await(0)` 立即返回几乎取不到结果；`catch(InterruptedException){}` 吞。`RagAutoConfiguration.ragWorker` 亦在 `@Bean` 内 `new Thread(()->loadDocs).start()` 后台线程，启动即读 docsPath 并把整个 docs 目录 `move` 到 `rags_history`（副作用重、无幂等/并发保护）。
- **【缺陷·启动开销/日志】`OpsSecureAutoConfiguration.opsSecureKeyPair()`**：未配 cert 时启动即生成密钥对并用 `System.out.println`（非 logger）打印，且**每次无 cert 启动都换新密钥** → 已下发 clientCert 立即失效；随后调用 `test()` 再生成一对做一次加解密自测往返（无谓密码学开销 + 启动期死代码）。
- **【安全面·鉴权外扩】`SshOpsController.cmd`/`execSftpCmd`**：`util.exec(...)` 在目标机执行任意 shell、`runAsFile` 上传 `.sh` 再 `sh -c`（目标机 RCE）；`download`/`head`/`tail` 把请求携带的任意服务器路径直接作为 SFTP 参数（路径穿越面）；`delete` 递归删。均只受 SM 信封 + 可空放行的 hostId 保护。
- **【安全面·注入】`DatasourceOpsController.doImport`**：`insert into {table} (列...) values (${列})` 中 `table` 取 `req.getTable()` **原样字符串拼接**（`${}` 值走 `BindSql` 参数绑定，但表名/列名未走标识符白名单或转义），存在标识符注入面。
- **【欠登记·元数据】`additional-spring-configuration-metadata.json` 仅登记 `i2f.springboot.ops.secure.cert` 一个属性**：数十个 `i2f.springboot.ops.*.enable`、`base-url`、`datasource.datasourceMap.*`、`ai.tools.*`、`ai.rags.*`、`ai.skills.*` 真实开关**全部零登记**；`hints` 段是 `server.servlet.jsp.class-name` / `server.tomcat.accesslog.encoding` 两条从别处拷贝的死条目（与 xproc4j-starter、spring-starter 同款）。
- **【一致性】`AppOpsController`/`AppEvalOpsController` 每个端点重复 `if(!canAcceptHostId){ if(isProxyHostId) proxy }` + `assertHostId` 样板**，未抽公共拦截器，漏写风险高；`SpringHolder` 以静态字段持有 context（多上下文/测试串扰风险）；自动配置类/`@Component` 普遍叠加 `@Data`+`@NoArgsConstructor`（暴露 setter、本组通病）。

## 生态位置

- 位于 i2f **依赖栈顶端的聚合枢纽**：直接 compile 引入约 22 个内部模块（jdbc/元数据/os/network/mutator/image/web/sftp/groovy/minio/s3/es/rowset/ai-std/ai-rest-openai/rag-sqlite/spring-core/spring-web/uid/document/sm-crypto…），把它们的能力以 HTTP + 前端形式统一对外。
- 与专项 Starter 的关系是**上层复用而非被复用**：`i2f-springboot-xproc4j-starter`（`XProc4jOpsController`）、`i2f-springboot-ssh-tunnel-starter`（`SftpUtil`）、`i2f-sm-crypto`、`i2f-extension-groovy`、`i2f-extension-sftp`、`i2f-sqlparser` 等模块文档均把本模块标注为**消费方**；本模块自身一般不被其它库依赖。
- 典型适用场景：内网/自管理型应用需要「一个 jar 换来全套在线运维 + AI 调试台」；因其默认开启 eval/SQL/SSH 等强能力，生产环境务必显式关闭对应 `ops.*.enable` 并配置固定 `secure.cert`，避免上述高危项暴露。
