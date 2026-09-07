# i2f-turbo-java 项目 Wiki

## 项目概述

- **项目名称**: i2f-turbo-java
- **GroupId**: `i2f.turbo`
- **ArtifactId**: `i2f-turbo-java`
- **版本**: `1.0-jdk8`
- **许可证**: GNU General Public License v3.0
- **作者**: Ice2Faith
- **邮箱**: ugex_savelar@163.com
- **GitHub**: https://github.com/Ice2Faith/i2f-turbo-java
- **Gitee**: https://gitee.com/Ice2Faith/i2f-turbo-java

## 技术栈

| 技术                   | 版本         | 说明            |
|----------------------|------------|---------------|
| Java                 | 1.8 (JDK8) | 最低支持版本        |
| Maven                | -          | 构建工具，多模块管理    |
| Lombok               | 1.18.44    | 注解简化代码        |
| Spring Framework     | 5.3.31     | Spring 核心框架   |
| Spring Security      | 5.7.11     | 安全框架          |
| Spring Boot          | 2.7.18     | 快速开发框架        |
| Spring Cloud         | 2021.0.8   | 微服务框架         |
| Spring Cloud Alibaba | 2021.0.5.0 | 阿里巴巴微服务组件     |
| Jackson              | 2.13.5     | JSON 处理       |
| SLF4J                | 1.7.36     | 日志门面          |
| Servlet API          | 4.0.1      | javax.servlet |
| 编码                   | UTF-8      | 全局编码          |

## 项目架构

项目为大型 Java 多模块 Maven 项目，采用分层架构设计，根 pom 统一管理依赖版本。

```
i2f-turbo-java (根 POM)
├── i2f-jdk/            -- Java 基础工具库（核心模块，~150个子模块）
├── i2f-jdk-ext/        -- JDK 扩展模块（all/swl/web 三个聚合）
├── i2f-extension/      -- 第三方扩展集成（~80个子模块）
├── i2f-spring/         -- Spring 体系封装（8个子模块）
├── i2f-springboot/     -- SpringBoot Starter 集合（~36个子模块）
├── i2f-springcloud/    -- SpringCloud Starter 集合（~24个子模块）
├── i2f-tools/          -- 独立工具模块
└── i2f-spring-ai/      -- Spring AI 模块（JDK17，独立构建）
```

### 模块依赖关系

```
i2f-jdk (基础层，无外部框架依赖)
    ↑
i2f-jdk-ext (JDK扩展层)
    ↑
i2f-spring (Spring适配层)
    ↑
i2f-extension (第三方扩展层)
    ↑
i2f-springboot (SpringBoot自动装配层)
    ↑
i2f-springcloud (微服务层)
```

## 核心模块详情

### 1. i2f-jdk — Java 基础工具库

项目核心模块，提供约 150 个细分子模块，覆盖 Java 开发各方面能力。子模块命名遵循 `i2f-{功能}`
或 `i2f-{功能}-std`/`i2f-{功能}-impl` 的接口-实现分离模式。

> 详细子模块列表见 [docs/module-i2f-jdk.md](docs/module-i2f-jdk.md)

**主要功能分类：**

| 分类         | 模块示例                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | 说明                    |
|------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------|
| 注解体系       | `i2f-annotations`, `i2f-annotations-api`, `i2f-annotations-core`, `i2f-annotations-db`, `i2f-annotations-ext`                                                                                                                                                                                                                                                                                                                                                                                                                              | 分层注解定义                |
| 数据结构       | `i2f-array`, `i2f-tuple-std`, `i2f-tuple-impl`, `i2f-iterator`, `i2f-container`, `i2f-reference`                                                                                                                                                                                                                                                                                                                                                                                                                                           | 数组、元组、容器、引用           |
| IO 体系      | `i2f-io-file`, `i2f-io-filesystem`, `i2f-io-stream`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | 文件、文件系统、流             |
| 数据库        | `i2f-database`, `i2f-database-dialect`, `i2f-database-type`, `i2f-database-metadata-*`                                                                                                                                                                                                                                                                                                                                                                                                                                                     | 数据库抽象与元数据             |
| JDBC       | `i2f-jdbc-std`, `i2f-jdbc-impl`, `i2f-jdbc-data`, `i2f-jdbc-bql`, `i2f-jdbc-proxy`, `i2f-jdbc-procedure`                                                                                                                                                                                                                                                                                                                                                                                                                                   | JDBC 全流程封装            |
| SQL 绑定     | `i2f-bindsql`, `i2f-bindsql-page`, `i2f-bindsql-stringify`, `i2f-bql`                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | SQL 绑定与分页             |
| 加密/编解码     | `i2f-crypto-std`, `i2f-crypto-impl`, `i2f-codec-std`, `i2f-codec-impl`, `i2f-sm-crypto`, `i2f-hash`                                                                                                                                                                                                                                                                                                                                                                                                                                        | 加密、编码、国密              |
| 缓存         | `i2f-cache`, `i2f-cache-std`, `i2f-lru-cache`, `i2f-lru-map`                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | 缓存与LRU                |
| 序列化        | `i2f-serialize-std`, `i2f-serialize-impl`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | 序列化接口与实现              |
| 网络/HTTP    | `i2f-network`, `i2f-http-proxy`, `i2f-proxy`, `i2f-proxy-std`, `i2f-proxy-handlers`                                                                                                                                                                                                                                                                                                                                                                                                                                                        | 网络与代理                 |
| 并发/线程      | `i2f-thread`, `i2f-atomic`, `i2f-lock`, `i2f-pool`, `i2f-limit`                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | 线程安全、锁、池化、限流          |
| 日期时间       | `i2f-datetime`, `i2f-clock-std`, `i2f-clock-impl`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | 日期时间与时钟               |
| 文本/国际化     | `i2f-text`, `i2f-i18n`, `i2f-translate`, `i2f-translate-en2zh`, `i2f-translate-zh2pinyin`                                                                                                                                                                                                                                                                                                                                                                                                                                                  | 文本处理、翻译、拼音            |
| 图形图像       | `i2f-graphics`, `i2f-graphics-2d`, `i2f-graphics-3d`, `i2f-image-std`, `i2f-image-impl`, `i2f-color`                                                                                                                                                                                                                                                                                                                                                                                                                                       | 2D/3D 图形与图像           |
| 反射/编译      | `i2f-reflect`, `i2f-compiler`, `i2f-script`, `i2f-javacode-graph`                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | 反射、动态编译、脚本            |
| 函数式/Lambda | `i2f-functional`, `i2f-functional-lambda`, `i2f-lambda`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | 函数式编程支持               |
| 日志         | `i2f-log`, `i2f-log-std`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | 日志抽象                  |
| 上下文/环境     | `i2f-context-std`, `i2f-context-impl`, `i2f-environment-std`, `i2f-environment-impl`                                                                                                                                                                                                                                                                                                                                                                                                                                                       | 上下文与环境                |
| 事件/生命周期    | `i2f-event`, `i2f-lifecycle`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | 事件总线与生命周期             |
| 认证/安全      | `i2f-authentication`, `i2f-firewall`, `i2f-otpauth`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | 认证、防火墙、OTP            |
| 压缩         | `i2f-compress-std`, `i2f-compress-impl`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | 压缩解压                  |
| 校验         | `i2f-check`, `i2f-check-filter`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | 参数校验与过滤               |
| 数学/算法      | `i2f-math`, `i2f-algo`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | 数学运算与算法               |
| 页面/分页      | `i2f-page`, `i2f-rowset`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | 分页与行集                 |
| 模板渲染       | `i2f-template-render`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | 模板引擎                  |
| 表单         | `i2f-form`, `i2f-form-url-encoded`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | 表单解析                  |
| 响应封装       | `i2f-resp`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | 统一响应                  |
| 设计模式       | `i2f-design-pattern`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | 23种设计模式实现             |
| SWL        | `i2f-swl`, `i2f-swl-std`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | 项目特有抽象层               |
| 原生调用       | `i2f-native-core`, `i2f-native-windows`, `i2f-native-windows-easyx`                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | JNI 原生功能              |
| 其他         | `i2f-agent`, `i2f-jvm`, `i2f-os`, `i2f-robot`, `i2f-search`, `i2f-geo`, `i2f-features`, `i2f-workflow`, `i2f-xml`, `i2f-properties`, `i2f-resources`, `i2f-bytes`, `i2f-code`, `i2f-dict`, `i2f-enums`, `i2f-match`, `i2f-comparator`, `i2f-console-color`, `i2f-data-processor`, `i2f-detegate`, `i2f-invokable`, `i2f-mixins`, `i2f-packet`, `i2f-spi`, `i2f-std-const`, `i2f-streaming`, `i2f-trace`, `i2f-trace-mdc`, `i2f-typeof`, `i2f-uid-std`, `i2f-uid-impl`, `i2f-unsafe`, `i2f-verifycode`, `i2f-launcher`, `i2f-number-idcard` | 各类工具模块                |
| AI 标准      | `i2f-ai-std`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | AI 工具链标准定义（平台无关、依赖无关） |
| AI OpenAI  | `i2f-ai-rest-openai`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | OpenAI 兼容协议 REST 实现   |
| 聚合         | `i2f-jdk-all`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | 全量聚合包                 |

### 2. i2f-jdk-ext — JDK 扩展模块

| 模块                | 说明       |
|-------------------|----------|
| `i2f-jdk-ext-all` | 全量聚合     |
| `i2f-jdk-ext-swl` | SWL 扩展   |
| `i2f-jdk-ext-web` | Web 相关扩展 |

### 3. i2f-extension — 第三方扩展集成

集成大量第三方库的封装模块，每个模块对应一个第三方库或技术栈。

> 详细子模块列表见 [docs/module-i2f-extension.md](docs/module-i2f-extension.md)

**主要功能分类：**

| 分类       | 模块                                                                                                                                                                                                               | 说明         |
|----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------|
| AI       | `i2f-extension-ai-dashscope`, `i2f-extension-ai-langchain4j8`, `i2f-extension-ai-openai`                                                                                                                         | AI 大模型集成   |
| JSON     | `i2f-extension-fastjson`, `i2f-extension-fastjson2`, `i2f-extension-gson`, `i2f-extension-jackson`                                                                                                               | JSON 库封装   |
| 数据库/ORM  | `i2f-extension-mybatis`, `i2f-extension-mongodb`, `i2f-extension-elasticsearch`                                                                                                                                  | 数据库与搜索引擎   |
| Redis    | `i2f-extension-redis-api`, `i2f-extension-redis-cache`, `i2f-extension-jedis`                                                                                                                                    | Redis 集成   |
| 文件系统     | `i2f-extension-filesystem-ftp`, `i2f-extension-filesystem-hdfs`, `i2f-extension-filesystem-minio`, `i2f-extension-filesystem-sftp`, `i2f-extension-filesystem-oss-aliyun`, `i2f-extension-filesystem-oss-aws-s3` | 多种文件系统     |
| OSS 对象存储 | `i2f-extension-oss-aliyun`, `i2f-extension-oss-aws-s3`, `i2f-extension-minio`                                                                                                                                    | 云存储        |
| 网络通信     | `i2f-extension-netty`, `i2f-extension-okhttp`, `i2f-extension-httpclient`                                                                                                                                        | 网络框架       |
| 文档处理     | `i2f-extension-document`, `i2f-extension-easyexcel`, `i2f-extension-fastexcel`                                                                                                                                   | 文档与Excel   |
| 模板引擎     | `i2f-extension-freemarker`, `i2f-extension-velocity`, `i2f-extension-velocity-bindsql`                                                                                                                           | 模板渲染       |
| 日志       | `i2f-extension-slf4j`, `i2f-extension-slf4j-log`, `i2f-extension-log-slf4j`                                                                                                                                      | 日志实现       |
| 加密       | `i2f-extension-jce-bc`, `i2f-extension-jce-sm-antherd`                                                                                                                                                           | 加密扩展       |
| 图像处理     | `i2f-extension-opencv`, `i2f-extension-opencv-data`, `i2f-extension-opencv-javacv`, `i2f-extension-image-metadata`                                                                                               | OpenCV 与图像 |
| 分词       | `i2f-extension-tokenlization-ansj`, `i2f-extension-tokenlization-hanlp`, `i2f-extension-tokenlization-jcseg`, `i2f-extension-tokenlization-jieba`                                                                | 中文分词       |
| TTS/ASR  | `i2f-extension-tts-espeak`, `i2f-extension-tts-jacob`, `i2f-extension-asr-vosk`                                                                                                                                  | 语音合成与识别    |
| 压缩       | `i2f-extension-compress`, `i2f-extension-7zip`, `i2f-extension-zip4j`                                                                                                                                            | 压缩解压       |
| 定时任务     | `i2f-extension-cron`, `i2f-extension-quartz`                                                                                                                                                                     | 定时任务       |
| 脚本       | `i2f-extension-groovy`, `i2f-extension-antlr4`, `i2f-extension-ognl`                                                                                                                                             | 脚本引擎       |
| 字节码      | `i2f-extension-javassist`, `i2f-extension-cglib`, `i2f-extension-agent-javassist`                                                                                                                                | 字节码操作      |
| 浏览器      | `i2f-extension-browser-selenium`                                                                                                                                                                                 | 浏览器自动化     |
| 二维码/验证码  | `i2f-extension-qrcode`, `i2f-extension-verifycode`                                                                                                                                                               | 二维码与验证码    |
| 邮件       | `i2f-extension-email`                                                                                                                                                                                            | 邮件发送       |
| 分布式      | `i2f-extension-zookeeper`, `i2f-extension-hazelcast`, `i2f-extension-canal`                                                                                                                                      | 分布式组件      |
| 数据同步     | `i2f-extension-jdbc-procedure-datax`, `i2f-extension-jdbc-procedure-flink`                                                                                                                                       | 数据同步与流计算   |
| 逆向工程     | `i2f-extension-reverse-engineer-generator`                                                                                                                                                                       | 代码生成器      |
| 其他       | `i2f-extension-aspectj`, `i2f-extension-gif`, `i2f-extension-ftp`, `i2f-extension-sftp`, `i2f-extension-hdfs`, `i2f-extension-xproc4j`                                                                           | 其他扩展       |
| 聚合       | `i2f-extension-all`, `i2f-extension-swl`                                                                                                                                                                         | 全量聚合       |

### 4. i2f-spring — Spring 体系封装

| 模块                          | 说明                 |
|-----------------------------|--------------------|
| `i2f-spring-all`            | 全量聚合               |
| `i2f-spring-core`           | Spring 核心封装        |
| `i2f-spring-web`            | Spring Web 封装      |
| `i2f-spring-authentication` | Spring 认证封装        |
| `i2f-spring-security`       | Spring Security 封装 |
| `i2f-spring-redis`          | Spring Redis 封装    |
| `i2f-spring-mvc-metadata`   | MVC 元数据            |
| `i2f-spring-swl`            | SWL Spring 适配      |

### 5. i2f-springboot — SpringBoot Starter 集合

提供开箱即用的 SpringBoot 自动配置 Starter。

| 模块                                              | 说明                               |
|-------------------------------------------------|----------------------------------|
| `i2f-springboot-spring-starter`                 | Spring 基础 Starter                |
| `i2f-springboot-websocket-starter`              | WebSocket Starter                |
| `i2f-springboot-redis-starter`                  | Redis Starter                    |
| `i2f-springboot-redisson-starter`               | Redisson Starter                 |
| `i2f-springboot-mybatis-starter`                | MyBatis Starter                  |
| `i2f-springboot-security-starter`               | Security Starter                 |
| `i2f-springboot-shiro-starter`                  | Shiro Starter                    |
| `i2f-springboot-auth-starter`                   | 认证 Starter                       |
| `i2f-springboot-ai-starter`                     | AI Starter                       |
| `i2f-springboot-activity-starter`               | 活动/Starter                       |
| `i2f-springboot-dubbo-starter`                  | Dubbo Starter                    |
| `i2f-springboot-dynamic-datasource-starter`     | 动态数据源 Starter                    |
| `i2f-springboot-encrypt-property-starter`       | 配置加密 Starter                     |
| `i2f-springboot-http-proxy-starter`             | HTTP 代理 Starter                  |
| `i2f-springboot-jackson-sensible-starter`       | Jackson 增强 Starter               |
| `i2f-springboot-jdbc-bql-starter`               | BQL JDBC Starter                 |
| `i2f-springboot-kafka-starter`                  | Kafka Starter                    |
| `i2f-springboot-limit-starter`                  | 限流 Starter                       |
| `i2f-springboot-nginx-rtmp-auth-server-starter` | Nginx RTMP 认证 Starter            |
| `i2f-springboot-ops-starter`                    | 运维 Starter                       |
| `i2f-springboot-oss-minio-starter`              | MinIO OSS Starter                |
| `i2f-springboot-quartz-starter`                 | Quartz 定时任务 Starter              |
| `i2f-springboot-rabbitmq-starter`               | RabbitMQ Starter                 |
| `i2f-springboot-ssh-tunnel-starter`             | SSH 隧道 Starter                   |
| `i2f-springboot-swagger2-starter`               | Swagger2 文档 Starter              |
| `i2f-springboot-swl-starter`                    | SWL Starter                      |
| `i2f-springboot-totp-starter`                   | TOTP Starter                     |
| `i2f-springboot-trace-mdc-starter`              | 链路追踪 MDC Starter（全链路 TraceId 传递） |
| `i2f-springboot-xproc4j-starter`                | XProc4J Starter                  |
| `i2f-springboot-xxl-job-starter`                | XXL-JOB 分布式任务 Starter            |
| `i2f-springboot-zookeeper-starter`              | ZooKeeper Starter                |

> 完整分类详情见 [docs/module-i2f-springboot.md](docs/module-i2f-springboot.md)

### 6. i2f-springcloud — SpringCloud Starter 集合

提供微服务治理相关的 SpringCloud 自动配置 Starter。

| 分类    | 模块                                                                                                                                                                          | 说明                            |
|-------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------|
| 注册中心  | `i2f-springcloud-alibaba-nacos-starter`, `i2f-springcloud-netflix-eureka-server-starter`, `i2f-springcloud-netflix-eureka-client-starter`, `i2f-springcloud-consul-starter` | Nacos/Eureka/Consul           |
| 服务网关  | `i2f-springcloud-gateway-starter`, `i2f-springcloud-gateway-swl-starter`, `i2f-springcloud-netflix-zuul-starter`                                                            | Gateway/Zuul                  |
| 服务调用  | `i2f-springcloud-netflix-openfeign-starter`, `i2f-springcloud-netflix-ribbon-starter`, `i2f-springcloud-loadbalancer-starter`                                               | OpenFeign/Ribbon/LoadBalancer |
| 熔断降级  | `i2f-springcloud-alibaba-sentinel-starter`, `i2f-springcloud-netflix-hystrix-starter`                                                                                       | Sentinel/Hystrix              |
| 分布式事务 | `i2f-springcloud-alibaba-seata-starter`                                                                                                                                     | Seata                         |
| 配置中心  | `i2f-springcloud-config-server-starter`, `i2f-springcloud-config-client-starter`                                                                                            | Spring Cloud Config           |
| 服务发现  | `i2f-springcloud-discovery-starter`, `i2f-springcloud-discovery-server-starter`                                                                                             | 服务发现                          |
| 链路追踪  | `i2f-springcloud-sleuth-starter`, `i2f-springcloud-zipkin-starter`                                                                                                          | Sleuth/Zipkin                 |
| 监控    | `i2f-springcloud-actuator-starter`, `i2f-springcloud-actuator-admin-starter`                                                                                                | Actuator 监控                   |
| 动态刷新  | `i2f-springcloud-refresh-starter`                                                                                                                                           | 配置动态刷新                        |

> 完整详情见 [docs/module-i2f-springcloud.md](docs/module-i2f-springcloud.md)

### 7. i2f-tools — 独立工具

| 模块                               | 说明                                      |
|----------------------------------|-----------------------------------------|
| `i2f-tools-source-copier`        | 源码拷贝工具                                  |
| `i2f-jdbc-procedure-idea-plugin` | XProc4J IDEA 插件（Gradle 独立构建，非 Maven 管理） |

### 8. i2f-spring-ai — Spring AI 模块（JDK17）

此模块独立于主构建，需要 JDK17。

| 模块                              | 说明                      |
|---------------------------------|-------------------------|
| `i2f-spring-ai-alibaba-starter` | 阿里巴巴 AI 集成              |
| `i2f-spring-ai-chat-starter`    | AI 聊天 Starter（含 Web UI） |
| `i2f-spring-ai-sse-mcp-server`  | SSE MCP Server          |

## 关键框架

### XProc4J — XML 存储过程编排框架

XProc4J 是基于 XML 的 JDBC 存储过程编排框架，支持多语言脚本（Java/Groovy/JavaScript/TinyScript/Funic/OGNL）混编执行，提供语法预检、脚本预热、依赖分析等能力。

- **模块**: `i2f-extension-xproc4j`
- **基础模块**: `i2f-jdk/i2f-jdbc-procedure`
- **Starter**: `i2f-springboot-xproc4j-starter`
- **核心能力**: XML 过程定义、多语言脚本执行、SQL 方言适配、动态数据源、事务控制、Java Caller、调试追踪
- **脚本语言演进**: Funic 是 TinyScript 的增强替代，将逐渐完全替代
  TinyScript（详见 [演进指南](docs/funic-framework.md#tinyscript--funic-演进指南)）
- **一键切换 Funic**: 配置 `xproc4j.enable-funic=true` 即可将默认 OGNL 执行器整体替换为 Funic 执行器，**当前阶段已具备完全替代能力
  **
- **官方文档**: 框架架构、设计思想、快速入门、Oracle 过程转换指南、XML 节点白皮书、TinyScript/Funic
  语法等（详见 [文档索引](docs/xproc4j-framework.md#官方文档索引)）
- **效果预览**: IDEA 语法高亮与代码补全插件效果（详见 [效果预览](docs/xproc4j-framework.md#效果预览)）
- **生产实践**: 已完成线上系统 Oracle 存储过程（含函数）向国产数据库的迁移，覆盖 **500+ 核心计算系统**，迁移 **12 万+ 行**
  过程代码，每日调度 **2000+ 次**，稳定运行 **1 年+**（详见 [生产实践](docs/xproc4j-framework.md#生产实践)）

> 详细文档见 [docs/xproc4j-framework.md](docs/xproc4j-framework.md)

### TinyScript — 轻量级嵌入式脚本引擎（旧，将被 Funic 替代）

TinyScript 是基于 ANTLR4 构建的轻量级嵌入式脚本引擎，提供嵌套函数调用、多语句执行、控制流、自定义函数等能力，是 XProc4J
框架的核心脚本语言之一。

> **演进提示**: Funic 是 TinyScript 的增强版本和未来替代方案。在 XProc4J 中，Funic 将逐渐演变并最终完全替代 TinyScript。*
*新项目建议直接使用 Funic。**

- **模块**: `i2f-extension-antlr4`（运行时引擎）
- **核心入口**: `TinyScript.script(formula, context)`
- **扩展接口**: `TinyScriptResolver` / `DefaultTinyScriptResolver`
- **语法定义**: ANTLR4 文法 `TinyScript.g4`（397 行规则）
- **IDE 支持**: IDEA 插件（`.tis` 文件，语法高亮 + 代码补全）
- **核心特性**: 多数据类型、JSON 构建、管道调用链、模板字符串、多行字符串、解包语句、debugger 调试、用户自定义函数

> 详细文档见 [docs/tinyscript-framework.md](docs/tinyscript-framework.md)

### Funic — 函数逻辑驱动的嵌入式脚本引擎（TinyScript 的增强替代）

Funic（Functional Logic）是基于 ANTLR4 构建的函数逻辑驱动脚本引擎，**是 TinyScript 的增强版本和未来替代方案**。比 TinyScript
语法更简洁（变量直接访问无需 `${}`），特性更丰富：Lambda 表达式、异步并发（go/await）、用户自定义函数、import
导入、沙箱执行、synchronized 同步块等。

- **模块**: `i2f-extension-antlr4`（运行时引擎）
- **定位**: TinyScript 的增强版本与未来替代
- **核心入口**: `Funic.script(formula, context)`
- **扩展接口**: `FunicResolver` / `DefaultFunicResolver` / `SandboxFunicResolver`
- **语法定义**: ANTLR4 文法 `Funic.g4`（575 行规则）
- **文件扩展名**: `.fic`
- **IDE 支持**: IDEA 插件（语法高亮 + 代码补全）
- **核心特性**: Lambda、go/await 异步并发、用户自定义函数、管道调用链、import 导入、沙箱模式、synchronized、for-range
  循环、类型转换运算符(as)、严格相等(===)、展开运算符(...)
- **一键启用**: 配置 `xproc4j.enable-funic=true` 即可将默认 OGNL 执行器整体替换为 Funic，无需修改业务代码

> 详细文档见 [docs/funic-framework.md](docs/funic-framework.md)

### AI 工具链 — 平台无关化 AI 标准定义与 OpenAI 实现

项目提供了一套平台无关化、依赖无关化的 AI 工具链标准定义（`i2f-ai-std`），以及基于 OpenAI 兼容协议的 REST
实现（`i2f-ai-rest-openai`）。核心能力包括：Agent 智能体（Re-Act 循环）、Function Calling 工具体系、RAG 检索增强生成、技能系统、对话记忆、MCP
工具提供者、声明式 AI Service 代理。

- **标准模块**: `i2f-jdk/i2f-ai-std`（平台无关、依赖无关）
- **OpenAI 实现**: `i2f-jdk/i2f-ai-rest-openai`（兼容 OpenAI/DashScope/Ollama/vLLM 等）
- **核心入口**: `AiAgent.generate()` / `AiModel.generate()`
- **声明式代理**: `@AiService` + `@AiSystem` + `@AiTools` 注解驱动
- **核心特性**: Re-Act 循环、Function Calling、并行工具调用、结构化输出、RAG（被动+主动）、技能系统、SSE 流式、JSON Schema 自动生成
- **技术全景网页**: `i2f-springboot/i2f-springboot-ops-starter/spec/index.html`（ops-starter OpenAI 兼容 AI
  对话框架设计全景，HTML+SVG 静态站点，可离线阅读）

> 详细文档见 [docs/ai-framework.md](docs/ai-framework.md)

### 网络通信与声明式 HTTP 客户端

项目提供零外部依赖的网络通信基础设施（`i2f-network`）和基于注解驱动的声明式 HTTP 客户端框架（`i2f-http-proxy`）。

**i2f-network** 覆盖 HTTP 客户端（基于 HttpURLConnection，支持 JSON/Form/XML/Multipart 等格式）、BIO/NIO TCP 通信、BIO/NIO
UDP 通信、RMI 远程调用、网络扫描等能力。

**i2f-http-proxy** 提供类似 Feign 的声明式 HTTP 客户端，通过 `@RestClient` + `@RestGetMapping`/`@RestPostMapping`
等注解定义接口，运行时 JDK 动态代理自动生成实现，支持环境变量替换、路径变量、文件上传、请求定制等。

- **基础网络模块**: `i2f-jdk/i2f-network`（HTTP/TCP/UDP/RMI/网络扫描）
- **声明式客户端**: `i2f-jdk/i2f-http-proxy`（注解驱动 + 动态代理）
- **SpringBoot 集成**: `i2f-springboot-http-proxy-starter`
- **核心入口**: `HttpUtil.http()` / `HttpRequest.doGet()` / `RestClientProvider.getClient()`
- **核心特性**: 零外部依赖、BIO+NIO 双模式、多种 Content-Type、环境变量替换、声明式接口代理

> 详细文档见 [docs/network-proxy.md](docs/network-proxy.md)

### XProc4J IDEA 插件 — XML 存储过程开发 IDE 支持

XProc4J IDEA 插件是专为 XProc4J 框架开发的 IntelliJ IDEA 插件，提供 XML 配置文件的语法高亮、代码补全、多语言注入（11 种
SQL + 20+ 其他语言）、TinyScript/Funic 脚本语言完整 IDE 支持、$变量高亮、Live Templates、Oracle 语法转换、调试断点等能力。

- **插件标识**: `i2f.turbo.jdbc-procedure-plugin`
- **模块路径**: `i2f-tools/i2f-jdbc-procedure-idea-plugin`
- **构建工具**: Gradle（独立于主项目 Maven 体系，共用代码仓库）
- **IDEA 版本**: >= 2023.2
- **核心能力**: XML 语言增强、TinyScript/Funic IDE 支持、多语言注入、代码补全、引用跳转、调试断点、Oracle 转换、Live Templates

> 详细文档见 [docs/idea-plugin.md](docs/idea-plugin.md)

### SQL 绑定构建与动态查询框架

项目提供零外部依赖的 SQL 绑定构建基础（`i2f-bindsql`）和基于四层递进抽象的动态查询框架（`i2f-bql`）。

**i2f-bindsql** 是 SQL 绑定构建的核心类 `BindSql`，封装 SQL 文本 + 参数列表，提供链式构建、动态 SQL
片段（when/choose/foreach/trim）、完整 SQL 关键字方法、SQL 格式化（pretty/trimComment）、参数合并（toMergeSql）等能力。

**i2f-bql** 构建在 `i2f-bindsql` 之上，提供四层递进抽象：基础层（通用 SQL 构建 + 多方言）→ Map 层（Map 驱动 CRUD）→ Lambda
层（类型安全列名解析）→ Bean 层（实体驱动全自动 CRUD）。同时提供 Wrapper
声明式条件构建器体系（QueryWrapper/UpdateWrapper/DeleteWrapper/InsertWrapper）。

**i2f-bindsql-page** 构建在 `i2f-bindsql` 之上，提供数据库方言感知的 SQL 分页改写与计数 SQL 生成能力，内置 9
种数据库方言分页实现（MySQL/PostgreSQL/Oracle/SQLServer/DB2/CirroData/IBM AS400/Informix/Firebird），支持 SPI
扩展和方言自动重定向映射（覆盖 34 种数据库到 4 种核心方言）。

- **SQL 绑定基础**: `i2f-jdk/i2f-bindsql`（BindSql 参数化 SQL 构建）
- **动态查询框架**: `i2f-jdk/i2f-bql`（四层抽象 + Wrapper 体系）
- **分页与计数**: `i2f-jdk/i2f-bindsql-page`（9 种方言分页 + 通用计数 + SPI 扩展）
- **SpringBoot 集成**: `i2f-springboot-jdbc-bql-starter`
- **核心入口**: `BindSql.of()` / `Bql.$_()` / `BindSqlWrappers.page()` / `PageWrappers.wrapper()`
- **核心特性**: 零外部依赖、Lambda 类型安全、@Table/@Column 注解解析、MySQL/Oracle 多方言、动态 SQL 片段、Wrapper 声明式
  API、9 种方言分页自动改写

> 详细文档见 [docs/bindsql-bql.md](docs/bindsql-bql.md)

### 日志标准定义与完整实现体系

项目提供零外部依赖的日志标准定义（`i2f-log-std`）和基于门面设计模式的完整日志实现（`i2f-log`）。

**i2f-log-std** 定义核心日志接口 `ILogger`（6 个日志级别 × 多种参数重载，约 1500 行 default 方法），`LoggerFactory`（LRU
缓存 + 三级 Provider 发现：系统属性 → META-INF/log.properties → SPI），`AbsLogger`
抽象基类，以及默认控制台实现 `StdioLogger`（ANSI 彩色输出）。

**i2f-log** 构建在 `i2f-log-std` 之上，提供：`LogHolder` 全局持有器（Decider/Writer/Formatter × Global/ThreadLocal
双级覆盖）、`DefaultClassNamePattenLogDecider`（Ant 风格类名模式级别控制）、4 种日志写入目标（控制台/本地文件/JDBC
数据库/广播）、`StdoutRedirectPrintStream`（`System.out/err` 重定向到日志体系）、`LogConfiguration`（properties 文件配置系统）。

- **日志标准**: `i2f-jdk/i2f-log-std`（ILogger/LoggerFactory/LoggerProvider SPI）
- **日志实现**: `i2f-jdk/i2f-log`（配置/决策/格式化/多目标输出/控制台重定向）
- **核心入口**: `LoggerFactory.getLogger(Class)` / `LogConfiguration.config()`
- **写入目标**: 控制台（彩色）/ 本地文件（滚动+清理）/ JDBC 数据库（批量异步）/ 广播（多目标并行）
- **核心特性**: 门面设计模式、SPI 双重扩展、延迟求值、类名模式级别控制、System.out 重定向、JDBC 自动建表

> 详细文档见 [docs/log.md](docs/log.md)

### 动态 Classpath 启动器

项目提供零外部依赖的 Java 应用动态 Classpath 启动器（`i2f-launcher`），参考 Spring Boot Launcher
设计并简化。核心能力是在 `java -jar` 启动时动态加载额外的 classpath 或外部 JAR 包，实现插件模式应用。

**i2f-launcher** 通过自定义 `ExtClasspathClassLoader`（子优先加载策略，打破双亲委派）实现额外 classpath 的优先加载。启动器作为
JAR 的 `Main-Class` 先于应用运行，递归扫描指定目录（默认 `lib,libs,plugin,plugins,ext-lib,ext-libs`）中的所有 JAR（含 JAR 内嵌
JAR），设置为线程上下文 ClassLoader 后反射调用真正的入口 `main()` 方法。支持命令行参数、JVM 系统属性、Manifest 属性三级配置来源。

- **模块**: `i2f-jdk/i2f-launcher`
- **核心入口**: `ExtApplicationLauncher.main()`
- **配置键**: `Ext-Main-Class`（真正入口类）/ `Ext-Path`（额外 classpath 目录）
- **核心特性**: 零外部依赖、子优先 ClassLoader、递归 JAR 扫描、三级配置来源、Spring Boot 兼容

> 详细文档见 [docs/launcher.md](docs/launcher.md)

### 数据库类型检测与元数据逆向工程

项目提供完整的数据库类型检测与元数据逆向工程体系，涵盖 5 个核心模块：类型检测（`i2f-database-type`
）、元数据模型（`i2f-database-metadata-data`）、标准接口（`i2f-database-metadata-std`
）、多数据库实现（`i2f-database-metadata-impl`）、Bean 代码生成（`i2f-database-metadata-bean`）。

**i2f-database-type** 定义 34 种数据库类型枚举（MySQL/Oracle/PostgreSQL/达梦/人大金仓/OceanBase 等），支持 JDBC URL
自动识别、Connection 检测（带 WeakHashMap 缓存）、SPI 扩展检测器，以及方言代理 JDBC 驱动（`jdbc:proxy:{方言}:{真实URL}`
）解决国产数据库兼容模式场景。

**i2f-database-metadata-impl** 提供 8 种数据库的专用元数据读取实现（MySQL/Oracle/PostgreSQL/SQLServer/H2/SQLite/达梦/GBase）+
通用 JDBC 回退，以及 5 种 DDL 逆向工程实现（MySQL/Oracle/PostgreSQL/GBase/标准）。**i2f-database-metadata-bean** 支持 Bean ↔
TableMeta 双向转换和 Java Bean 代码生成。

- **类型检测**: `i2f-jdk/i2f-database-type`（34 种数据库 + 方言代理驱动）
- **元数据模型**: `i2f-jdk/i2f-database-metadata-data`（TableMeta/ColumnMeta/StdType）
- **标准接口**: `i2f-jdk/i2f-database-metadata-std`（DatabaseMetadataProvider/DatabaseReverseEngineer）
- **多数据库实现**: `i2f-jdk/i2f-database-metadata-impl`（8 种专用 + 1 通用 + 5 DDL 逆向）
- **Bean 解析**: `i2f-jdk/i2f-database-metadata-bean`（Bean ↔ TableMeta + Java 代码生成）
- **核心入口
  **: `DatabaseType.typeOfJdbcUrl()` / `DatabaseMetadataProviders.getProvider()` / `DdlDatabaseReverseEngineers.getEngineer()`

> 详细文档见 [docs/database-metadata.md](docs/database-metadata.md)

### 二维/三维图形学引擎

项目提供纯 Java 实现的二维图形学基础（`i2f-graphics-2d`）和完整三维图形引擎（`i2f-graphics-3d`），构成项目的图形学基础设施。

**i2f-graphics-2d** 提供二维几何原语（Point/Vector/Line/Flat/Scope/Size）、贝塞尔曲线、多边形分析工具（面积/顺逆时针/凸凹判断）、4
种坐标投影（数学中心/左下/偏移/屏幕）、11 种仿射变换（平移/缩放/旋转/错切/反射/任意点线变换）、函数图像绘制器（直角坐标/极坐标/参数方程
3 种模式）、Swing 可视化组件以及分形樱花树生成器。

**i2f-graphics-3d** 构建在 2D 模块之上，实现完整渲染管线：变换链 → 背面剔除 → Phong 光照/材质 → 三维投影 → 二维显示。内置
12 种几何体（球/柱/锥/环/正多面体/旋转体/分形体）、10 种投影方式（三视图/正交/斜投影/透视）、25+ 种三维变换、Phong
光照模型（漫反射+镜面反射+环境光+衰减）、20+ 种预设材质（金/银/宝石/金属等）、散点三角化算法，以及支持键鼠交互的 3D
视窗（Alt/Ctrl/Shift + 滚轮操控旋转/平移/缩放）。

- **二维图形**: `i2f-jdk/i2f-graphics-2d`（几何原语/投影/变换/多边形工具/函数绘制）
- **三维引擎**: `i2f-jdk/i2f-graphics-3d`（渲染管线/12 几何体/10 投影/Phong 光照/20+ 材质/交互视窗）
- **核心入口**: `D3Painter`（三维绘制）/ `FunctionPainter`（函数图像）/ `D2Frame`/`D3Frame`（可视化窗口）
- **核心特性**: 纯 Java AWT 零依赖、完整渲染管线、Phong 光照、20+ 材质预设、10 种投影、交互式 3D 操控

> 详细文档见 [docs/graphics.md](docs/graphics.md)

### 统一文件系统抽象

项目提供统一的标准文件系统接口体系（`i2f-io-filesystem`），通过接口-抽象类-具体实现的分层设计，将 7 种完全不同的存储后端统一在同一套
API 下。业务代码面向 `IFile` / `IFileSystem` 编程，可无缝切换底层存储。

**核心模块**: `i2f-jdk/i2f-io-filesystem`（接口定义 + JDK 本地实现）

**扩展实现**（均在 `i2f-extension` 层）：

| 实现                    | 模块                                    | 底层技术           | 说明              |
|-----------------------|---------------------------------------|----------------|-----------------|
| `JdkFileSystem`       | `i2f-io-filesystem`                   | `java.io.File` | 本地文件系统（单例）      |
| `FtpFileSystem`       | `i2f-extension-filesystem-ftp`        | Commons Net    | FTP 协议，自动重连     |
| `SftpFileSystem`      | `i2f-extension-filesystem-sftp`       | JSch           | SFTP 协议，密码/私钥认证 |
| `ProxySftpFileSystem` | `i2f-extension-filesystem-sftp`       | JSch + 端口转发    | 跳板机代理 SFTP      |
| `HdfsFileSystem`      | `i2f-extension-filesystem-hdfs`       | Hadoop         | HDFS 分布式文件系统    |
| `MinioFileSystem`     | `i2f-extension-filesystem-minio`      | MinIO SDK      | MinIO 对象存储      |
| `AliyunOssFileSystem` | `i2f-extension-filesystem-oss-aliyun` | Aliyun OSS SDK | 阿里云 OSS         |
| `AwsS3OssFileSystem`  | `i2f-extension-filesystem-oss-aws-s3` | AWS SDK v2     | AWS S3 对象存储     |

- **核心接口**: `IFileSystem`（25 方法）/ `IFile`（35+ 方法）
- **抽象基类**: `AbsFileSystem`（模板方法）+ `AbsFile`（委托模式）
- **安全特性**: `absPath()` 防路径遍历攻击，`getStrictFile()` 限定子树访问
- **跨系统操作**: `AbsFile.copyTo()`/`moveTo()` 自动检测同一文件系统，支持跨系统透明操作

> 详细文档见 [docs/filesystem.md](docs/filesystem.md)

### Mixin 混入体系 — 脚本引擎内建函数库

项目通过 `i2f-mixins` 模块提供基于 Java 8 接口默认方法的 Mixin（混入）体系，将 500+ 个常用工具函数以 18
个分类混入接口定义，任何类只需 `implements` 即可获得全部函数能力。该体系是 Funic、TinyScript、XProc4J 等脚本引擎的**内建函数库
**核心。

**核心模块**: `i2f-jdk/i2f-mixins`（22 文件，18 个混入接口 + 代理工厂 + 聚合接口 + 常量）

**聚合接口**: `AllMixins` 继承全部 18 个混入接口：`StringMixins`(1234行) / `ObjectMixins`(457行) / `MathMixins`(
417行) / `DateMixins`(363行) / `RegexMixins`(
322行) / `ArrayMixins` / `CollectionMixins` / `MapMixins` / `FileMixins` / `SystemMixins` / `ThreadMixins` / `ThreadLocalMixins` / `RandomMixins` / `UuidMixins` / `JvmMixins` / `OsMixins` / `MatchMixins` / `CommandLineMixins`

**在脚本引擎中的应用：**

| 应用                      | 类                     | 方式                                                           | 说明            |
|-------------------------|-----------------------|--------------------------------------------------------------|---------------|
| **Funic**               | `Funic` (static)      | `MixinProxyFactory.getMixinInstance()` + `registryMethods()` | 代理实例反射注册为全局函数 |
| **TinyScript**          | `TinyScriptFunctions` | `extends AllMixins` + 匿名实例                                   | 接口继承，脚本可直接调用  |
| **XProc4J**             | `ContextFunctions`    | `extends AllMixins` + 匿名实例                                   | 存储过程上下文函数     |
| **Freemarker/Velocity** | `GeneratorTool`       | `implements AllMixins`                                       | 模板渲染时可用混入函数   |

**核心基础设施**: `MixinProxyFactory`（JDK 动态代理 + `ConcurrentHashMap`
缓存），支持跨混入接口互调（如 `StringMixins.to_char()` 内部调用 `DateMixins.date_format()`）

**函数覆盖**: 字符串(80+)、数学运算(30+)、对象操作(40+)、日期时间(30+)、正则表达式(25+)
、数组/集合/Map、文件IO、系统/线程/随机数/UUID、哈希(MD5/SHA)、URL/Base64 编解码、Oracle 正则兼容、SQL 风格函数(
nvl/decode/coalesce)

> 详细文档见 [docs/mixins.md](docs/mixins.md)

### JNI 原生调用体系 — Windows API 与 EasyX 图形

项目通过三个 `i2f-native-*` 模块构建完整的 JNI 原生调用体系，实现 Java 对 Windows 底层 API 的直接访问。

**核心模块**: `i2f-jdk/i2f-native-core`（5 文件）— 指针类型体系（`Ptr`/`MallocPtr`/`NewPtr`/`NewArrayPtr`）+
库加载工具（`NativeUtil.loadClasspathLib`）

**Windows API 模块**: `i2f-jdk/i2f-native-windows`（153 文件）— 双层封装：`NativesWindows`（918 行 native 方法）+ `WinApi`
（3487 行高层封装），覆盖 20+ 类 API：

- **窗口管理**：查找/创建/消息/位置/样式/消息循环
- **GDI 绘图**（200+ 方法）：画笔/画刷/字体/图形/位图/路径/区域/坐标变换/颜色
- **进程/线程**：枚举/控制/优先级/亲和性/同步等待
- **文件操作**：创建/读写/属性/时间/加密/磁盘/回收站/Shell
- **注册表**：键值 CRUD/枚举/启动项管理
- **服务管理**：SCM/枚举/启停/创建/删除
- **设备/输入模拟**：键盘/鼠标/音量/媒体/控制台
- **系统控制**：关机/屏幕/网络/内存/版本
- **COM/Shell**：初始化/实例/快捷方式/特殊路径
- **Win32 应用框架**：`winAppCreateWin32App` 创建完整原生桌面应用

**常量体系**：94 个常量类（`WinWindowStyle`/`WinSendMessageMsg`(500行)/`WinSystemMetrics`(163行)/`WinKeyboardEventVk`(
271行) 等）
**类型体系**：50 个强类型句柄类（`Hwnd`/`Hdc`/`Handle`/`HKey`/`ScHandle`/`HBitmap` 等）

**EasyX 图形模块**: `i2f-jdk/i2f-native-windows-easyx`（9 文件）— `EasyXApi`（954 行）封装 EasyX
图形库：图形窗口管理/双缓冲/图像加载保存/图形绘制（圆/矩形/椭圆/扇形/多边形/圆角矩形各 4 种变体）/文本/像素/颜色工具

> 详细文档见 [docs/native.md](docs/native.md)

### 运维控制台 — Ops Starter

`i2f-springboot-ops-starter` 是开箱即用的 SpringBoot 运维控制台 Starter，引入依赖后自动注册 Web 管理页面，提供 13+
个功能模块的统一运维界面。所有前端资源（Vue 2 + Element UI）打包在 JAR 内，无需额外部署前端服务。

**核心能力：**

- **应用诊断** — 系统属性/环境变量/JVM 参数/日志级别/类元数据/死锁检测/Bean 列表/Groovy 脚本执行
- **主机管理** — 远程命令执行/文件浏览/上传/下载/删除/tail/head 查看
- **SSH 远程管理** — 通过 SFTP 连接远程主机，提供与 Host 一致的远程操作能力
- **数据库管理** — 多数据源/SQL 查询/执行/导入导出/元数据查看（支持 Baomidou 动态数据源）
- **Redis 管理** — scan/keys/get/set/del + Hash/List/Set/ZSet 全数据结构操作
- **ElasticSearch** — 索引 CRUD/文档 CRUD/DSL 查询/Mapping 管理
- **对象存储** — MinIO / AWS S3 文件浏览/上传/下载/删除
- **XXL-JOB** — 任务列表/Handler 列表/手动执行
- **XProc4J** — 存储过程调用/元数据查看/调试追踪
- **OpenAI 对话** — OpenAI 兼容协议对话/流式对话/Function Calling（12 种内置工具 + 技能系统）
- **DashScope** — 通义千问系列（文生图/文生视频/3D 模型/数字人等 10+ 种 AI 能力）

**安全特性：** 全链路国密加密（SM2/SM3/SM4），自动证书生成，时间戳防重放，签名验证

**扩展机制：** `IOpsProvider` SPI 接口，新模块只需实现接口即可自动注册菜单到控制台首页

- **模块**: `i2f-springboot/i2f-springboot-ops-starter`
- **访问入口**: `http://{host}:{port}/ops/`
- **Java 源码**: 132 文件
- **前端页面**: 20+ 个 HTML 页面（含 CodeMirror 代码编辑器）
- **自动装配**: 55 个自动配置类，全部 `@ConditionalOnClass` 按需激活

> 详细文档见 [docs/ops-starter.md](docs/ops-starter.md)

### 全链路追踪 MDC — Trace MDC Starter

`i2f-springboot-trace-mdc-starter` 是基于 `i2f-trace-mdc` 基础模块的 SpringBoot 自动配置 Starter，提供全链路 TraceId 追踪与
MDC 上下文传递能力。通过 10 个自动配置类，覆盖 Web 请求入口、微服务调用、HTTP 客户端、定时任务、线程池等全部场景，确保 TraceId
在整个调用链中透明传递。

**核心能力：**

- **Web 入口** — Servlet（MdcWebFilter）/ Gateway 网关（MdcGatewayFilter），自动提取或生成 TraceId
- **微服务传递** — OpenFeign 拦截器，自动向下游传递 TraceId/TraceSource Header
- **HTTP 客户端** — RestTemplate 拦截器 + BeanPostProcessor 自动注入
- **线程池传递** — MdcTaskDecorator（Spring）+ MdcExecutorService/MdcRunnable/MdcCallable（原生）
- **定时任务** — XXL-JOB / PowerJob / Spring @Scheduled 切面，每次执行生成新 TraceId
- **注解驱动** — `@MdcTrace` 注解，任意方法自动纳入追踪

**基础层**: `i2f-trace-mdc`（11 文件），零 Spring 依赖的 MDC 抽象，SPI 扩展 MdcManager，完整线程传递工具（7 个包装类）

- **模块**: `i2f-springboot/i2f-springboot-trace-mdc-starter`
- **基础模块**: `i2f-jdk/i2f-trace-mdc`
- **Java 源码**: 22 文件（11 基础 + 11 Starter）
- **自动装配**: 10 个自动配置类，全部 `@ConditionalOnClass` + `@ConditionalOnExpression` 按需激活
- **配置开关**: 10 个独立开关（`i2f.springboot.trace.mdc.*.enable`），全部默认开启

> 详细文档见 [docs/trace-mdc.md](docs/trace-mdc.md)

### 核心基础接口 — IContext 与 IEnvironment

项目定义了两个贯穿全局的核心基础接口，被 AI 工具链、XProc4J、HTTP 代理、Spring 集成等几乎所有模块依赖。

#### IContext — Bean 容器上下文接口

`IContext` 提供轻量级 Bean 容器抽象，支持按类型获取单例/多例 Bean，是项目脱离 Spring 也能运行的基础。

**接口继承体系：**

```
IContext                          -- 只读：getBean(Class) / getBeans(Class) / getAllBeans()
├── IWritableContext              -- 可写：addBean(Object) / removeBean(Object)
├── INamingContext                -- 命名：getBean(String) / getBeansMap(Class) / getAllBeansMap()
│   └── IWritableNamingContext    -- 命名可写：addBean(String, Object) / removeBean(String)
└── IWritableContext + IWritableNamingContext  -- 同时实现两者
```

**全项目实现一览：**

| # | 实现类                     | 所属模块               | 实现接口                                          | 说明                                                                                                                                       |
|---|-------------------------|--------------------|-----------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| 1 | `ListableContext`       | `i2f-context-impl` | `IWritableContext`                            | 基于 `CopyOnWriteArrayList` 的线程安全列表式容器，支持 add/remove，按类型查找（精确匹配优先于 assignable）                                                             |
| 2 | `ListableNamingContext` | `i2f-context-impl` | `IWritableNamingContext` + `IWritableContext` | 在列表基础上增加 `ConcurrentHashMap` 命名索引，支持按名称注册/查找/移除，`ReadWriteLock` 保证并发安全                                                                   |
| 3 | `SpringContext`         | `i2f-spring-core`  | `IWritableNamingContext`                      | Spring 适配实现，委托 `ApplicationContext` / `BeanFactory`；`addBean` 通过 `registerSingleton` 注册并自动注入；`removeBean` 通过 `BeanDefinitionRegistry` 移除 |

#### IEnvironment — 环境属性接口

`IEnvironment` 提供统一的环境属性读取抽象，支持 `String`/`Integer`/`Long`/`Boolean`/`Double` 等多种类型的安全获取，带默认值回退。

**全项目实现一览：**

| # | 实现类                           | 所属模块                   | 实现接口                                | 说明                                                                                                                                                      |
|---|-------------------------------|------------------------|-------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1 | `SystemAdditionalEnvironment` | `i2f-environment-impl` | `IWritableEnvironment`              | 单例实现，增强系统属性：自动采集 JVM 运行时信息（PID、启动时间、VM 信息、类路径等）、OS 信息（架构、处理器数、版本）、编译信息；查找优先级：内置属性 → 自定义属性 → `System.getProperty()`                                      |
| 2 | `ListableDelegateEnvironment` | `i2f-environment-impl` | `IEnvironment`                      | 委托式组合实现，内部维护 `IEnvironment` 列表，按顺序查找属性（首个非空值返回）；默认包含 `SystemAdditionalEnvironment`；`getAllProperties()` 按逆序合并                                           |
| 3 | `SpringEnvironment`           | `i2f-spring-core`      | `IEnvironment` + `EnvironmentAware` | Spring 适配实现，委托 Spring `Environment`；`getAllProperties()` 遍历所有 `PropertySource`（支持 Map 和 Properties 类型源）；额外提供 `getActiveProfiles()` 和 `getSourceNames()` |

## 构建配置

### Maven 插件

| 插件                     | 版本    | 说明                                  |
|------------------------|-------|-------------------------------------|
| maven-compiler-plugin  | 3.8.1 | 编译插件，启用 `-parameters` 参数，支持 Lombok  |
| maven-resources-plugin | 2.6   | 资源处理，支持 `src/main/java` 下的非 Java 资源 |
| maven-jar-plugin       | 3.0.2 | 打包插件，JAR 清单注入项目元信息                  |
| maven-assembly-plugin  | 3.1.0 | 全量打包，含依赖                            |

### 资源配置特点

- 支持从 `src/main/java` 目录打包非 Java 资源（xml, json, ftl, properties, yaml, html, js, css, vue, vm, db 等）
- 资源过滤排除了二进制文件（doc, xls, pdf, zip, dll, so 等）
- 编译时自动开启 `-parameters` 选项，便于运行时获取参数名

### 构建命令

```bash
# 全量编译
mvn clean compile -DskipTests

# 全量打包
mvn clean package -DskipTests

# 安装到本地仓库
mvn clean install -DskipTests
```

## 项目特性

1. **接口-实现分离**: 大量使用 `std`(接口)/`impl`(实现) 分离模式
2. **SWL 抽象层**: 项目特有的 `swl` 抽象层，贯穿多个模块
3. **全量聚合包**: 各模块提供 `all` 聚合包，方便一次性引入全部依赖
4. **Spring 体系全覆盖**: 从 Spring 核心到 SpringCloud 微服务，提供完整的 Starter 体系
5. **丰富的第三方集成**: 80+ 扩展模块覆盖 AI、数据库、搜索引擎、消息队列、文件系统等
6. **JDK8 兼容**: 核心模块全部兼容 JDK8
7. **统一依赖管理**: 根 POM 统一管理所有内部模块和外部依赖版本
