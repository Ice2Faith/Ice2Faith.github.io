# i2f-springcloud-discovery-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-discovery-starter`

## 模块概述

Spring Cloud 组中一个**自研的轻量级服务发现「客户端」**装配 Starter（本组第 10 个建档模块，6 个 Java 源文件 + 6 个资源文件，**不含任何 i2f 内部 compile 依赖**，仅 lombok + Spring + Spring Cloud Commons）。它是同组自研注册中心服务端 [`i2f-springcloud-discovery-server-starter`](./i2f-springcloud-discovery-server-starter/readme.md) 的**客户端对偶**（一服务端存储/派发实例、一客户端注册自身/拉取实例）。

与同组 `nacos`/`consul`/`eureka` 等「把第三方注册中心 starter 改造成放 classpath 即自动装载」的薄封装**根本不同**：本模块不依赖任何现成注册中心框架，而是自己实现了 Spring Cloud `DiscoveryClient` 接口，提供**两种并存的服务发现来源**：

- **配置式（`DiscoveryClientProvider`）**：`DiscoveryAutoConfiguration.discoveryClientProvider()` 读取 `i2f.springcloud.discovery.instances`（服务名 → 实例 URI 列表）静态装配一张实例表，并把本应用自身（`spring.application.name` + `InetUtils` 主机名 + 端口）也塞进表里，`@Order(10)` 注册为 `DiscoveryClient` bean。
- **远程注册式（`RemoteDiscoveryClientProvider`）**：`@Component` 且默认开启，用 `RestTemplate` + `@PostConstruct` 启动两个周期任务——每 `heart-beat-seconds`（默认 10s）向注册中心 `POST {base-url}{registry-path}` 上报 `{uid, sign, serviceId, port}`，每 `pull-service-seconds`（默认 30s）`POST {base-url}{pull-path}` 拉全量实例进本地 `holder`；`sign = SHA-256(secretKey#uid)` 与服务端约定一致。

设计上它补齐了「不引重型注册中心、只靠一个 Redis + 几个 HTTP 接口就完成注册发现」的最小闭环；`DiscoveryServiceInstance` 完整实现了 Spring Cloud `ServiceInstance`（`setUri` 时反推 host/port/secure）。但落地质量存在多处高危缺陷，详见下文。

## 模块依赖

### 内部依赖

无（本模块**不 compile 任何 i2f 内部模块**）。

### 外部依赖

| 依赖 | 作用域 | 是否 optional | 版本来源 | 说明 |
|---|---|---|---|---|
| `org.projectlombok:lombok` | provided | 是（根 pom 统一） | 根 DM | `@Data`/`@Slf4j`/`@NoArgsConstructor` |
| `org.springframework.boot:spring-boot-starter` | provided | 是 | 根 BOM `2.7.18` | `@Configuration`/`@ConditionalOnExpression`/`ServerProperties` |
| `org.springframework.boot:spring-boot-configuration-processor` | provided | 是 | 根 BOM | 元数据生成 |
| `org.springframework.cloud:spring-cloud-starter` | provided | **否** | 根 BOM `spring-cloud 2021.0.8` | `DiscoveryClient`/`ServiceInstance`/`InetUtils`（经 spring-cloud-commons） |
| `org.springframework:spring-web` | provided | 是 | **硬编码 `5.3.31`** | `RestTemplate`（远程注册式用） |
| `com.fasterxml.jackson.core:jackson-databind` | provided | 是 | **硬编码 `2.13.5`** | 解析注册中心 JSON 响应 |

> 版本治理：`spring-web`/`jackson-databind` 在本 pom 内**写死数字**（[pom.xml L42](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-discovery-starter/pom.xml#L42)/[L50](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-discovery-starter/pom.xml#L50)），未引用根 pom 的 `${spring.version}`（[L47](file:///C:/home/dev/java/dev-center/i2f-turbo-java/pom.xml#L47)=5.3.31）/`${jackson.version}`（[L53](file:///C:/home/dev/java/dev-center/i2f-turbo-java/pom.xml#L53)=2.13.5），虽当前数值恰好相等，但绕开了 DM 单点治理。

## 模块设计

```mermaid
flowchart TD
    subgraph 自动配置登记
      SF["spring.factories / AutoConfiguration.imports<br/>(双通道·两份一致)"]
    end
    SF --> DAC["DiscoveryAutoConfiguration<br/>@Configuration(proxyBeanMethods=false)<br/>@ConditionalOnExpression(discovery.enable:true)<br/>@AutoConfigureBefore(...4 个官方类)"]
    SF --> RDC["RemoteDiscoveryClientProvider<br/>@Component（非 @Configuration）<br/>@ConditionalOnExpression(registry.enable:true)"]

    DAC -->|@Import| DP["DiscoveryProperties<br/>prefix=i2f.springcloud.discovery<br/>{instances, order}"]
    DAC -->|@Bean @Order(10)| DCP["DiscoveryClientProvider<br/>implements DiscoveryClient（配置式）"]
    DAC -.->|监听 WebServerInitializedEvent 纠正 port| EV["local.port"]
    DCP -->|读| DP
    RDC -->|@EnableConfigurationProperties| RRP["RemoteRegistryProperties<br/>prefix=...discovery.registry<br/>{baseUrl,registryPath,pullPath,secretKey=123456,...}"]
    RDC -->|@PostConstruct 起 2 线程池| POOL["newScheduledThreadPool(2)"]
    POOL -->|每 10s POST| REG["registry: {baseUrl}+{registryPath}"]
    POOL -->|每 30s POST| PULL["pull: {baseUrl}+{pullPath}"]
    DCP --> SI["DiscoveryServiceInstance<br/>implements ServiceInstance"]
    RDC --> SI
```

## 模块目的

为不接入 Nacos/Eureka/Consul 的轻量微服务，提供一个**自研 `DiscoveryClient`** 的自动装载：既能用配置文件静态声明服务实例列表，也能对接同组自研 Redis 注册中心做「心跳注册 + 周期拉取」，让 `@LoadBalanced RestTemplate`/`LoadBalancerClient` 等按 `serviceId` 解析到真实实例。

## 模块功能

1. **配置式发现**：`i2f.springcloud.discovery.instances` 声明 `服务名 → [{uri}]`，装配进 `DiscoveryClientProvider.holder`；本应用自身实例也自动入表。
2. **远程注册发现**：`RemoteDiscoveryClientProvider` 启动后周期性向注册中心心跳上报自身、拉取全量实例表进本地 `holder`，实现动态发现。
3. **签名约定**：`sign = SHA-256(secretKey + "#" + uid)`，与服务端 `DiscoverServerController` 校验逻辑一致。
4. **ServiceInstance 建模**：`DiscoveryServiceInstance` 由 `setUri` 反推 `host`/`port`/`secure`。
5. **优先级控制**：两个 `DiscoveryClient` 各自 `getOrder()`（配置式默认取 `properties.order`，远程式取 `registry.order`），供 `CompositeDiscoveryClient` 排序。

## 模块主要使用方法

引入 Starter（provided 依赖需使用方自备 `spring-cloud-starter` 等运行时）：

```xml
<dependencies>
    <dependency>
        <groupId>i2f.turbo</groupId>
        <artifactId>i2f-springcloud-discovery-starter</artifactId>
    </dependency>
    <!-- spring-cloud-starter / spring-web / jackson 为 provided，使用方须自行补齐运行时 -->
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter</artifactId>
    </dependency>
</dependencies>
```

配置式发现（`application.yml`）：

```yaml
i2f:
  springcloud:
    discovery:
      enable: true
      order: 0
      instances:
        sys-app:
          - uri: http://192.168.1.100:8080/
          - uri: http://192.168.1.101:8080/
        file-svc:
          - uri: http://192.168.1.110:8080/
```

远程注册式（对接自研服务端，**注意下述路径不对齐缺陷**）：

```yaml
i2f:
  springcloud:
    discovery:
      registry:
        enable: true
        base-url: http://localhost:9999
        registry-path: /api/registry
        pull-path: /api/services
        secret-key: 123456
        heart-beat-seconds: 10
        pull-service-seconds: 30
```

## 模块特性总结

- **组内少见的「自研双实现」实装件**：真正 `implements DiscoveryClient`，非空壳转发；配置式与远程式两条路径。
- **与服务端配对设计**：签名算法、心跳/拉取语义与 `discovery-server-starter` 严格对应（可惜默认路径字符串未对齐，见缺陷）。
- **正确的自动配置意识**：`DiscoveryAutoConfiguration` 是 `@Configuration(proxyBeanMethods=false)`，并用 `@AutoConfigureBefore` 显式抢先于官方 `CompositeDiscoveryClientAutoConfiguration` 等，`WebServerInitializedEvent` 纠正端口——配置式这一半写得相对规范。
- 附三份翔实 sample（配置式 / 远程式 / 官方 simple 对照）。

## 模块瑕疵或错误（实证）

1. **【高危·远程注册式默认开启 → 后台线程持续刷错误日志 + 线程泄漏】** `RemoteDiscoveryClientProvider` 门控为 `@ConditionalOnExpression("${i2f.springcloud.discovery.registry.enable:true}")`（[RemoteDiscoveryClientProvider.java L32](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-discovery-starter/src/main/java/i2f/springcloud/discovery/remote/RemoteDiscoveryClientProvider.java#L32)）**默认 `true`**。任何引入本 Starter 的应用，即便只想用配置式发现，也会在 `@PostConstruct` 启动 `newScheduledThreadPool(2)` 并向 `http://localhost:9999` 每 10s/30s POST；无注册中心时连接被拒 → 每周期 `log.warn`/`log.error` 洪泛，且该线程池**从无 `shutdown`/`@PreDestroy`**，应用关闭时线程泄漏。
2. **【高危·客户端与服务端默认路径不对齐，开箱 404】** 服务端实际映射是 `@RequestMapping("/api")` + `@PostMapping("/api/registry")` = **`/api/api/registry`**（双重前缀，见服务端文档），而客户端 `base-url=http://localhost:9999` + `registry-path=/api/registry` 拼出 **`/api/registry`**（[RemoteRegistryProperties.java L15-L17](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-discovery-starter/src/main/java/i2f/springcloud/discovery/remote/RemoteRegistryProperties.java#L15)）。这对「官方 CP」默认配置下互相打不通（404），须使用方手工把 `registry-path` 改成 `/api/api/registry` 才能对接。
3. **【高危·默认弱密钥】** `RemoteRegistryProperties.secretKey` 默认硬编码 `"123456"`（与服务端同款），未覆盖则 `sign=SHA-256("123456#uid")` 鉴权形同虚设，任何人可伪造注册投毒或拉全量服务表。
4. **【中危·`@PostConstruct` 早于 Web 服务器启动且无端口纠正】** 远程式在 `@PostConstruct init()` 立即 `sendHearBeat()`，端口来自 `ServerProperties.getPort()`；若配 `server.port=0`（随机端口），`findPort()` 因 `port<=0` 回落 `8080`（[RemoteDiscoveryClientProvider.java L106-L118](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-discovery-starter/src/main/java/i2f/springcloud/discovery/remote/RemoteDiscoveryClientProvider.java#L106)）→ 注册错误端口。对比 `DiscoveryAutoConfiguration` 用 `WebServerInitializedEvent` 纠正 `local.port`，远程式**无此监听**。
5. **【中危·`RestTemplate` 无超时】** `@Autowired(required=false) RestTemplate = new RestTemplate()`（[L53-L54](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-discovery-starter/src/main/java/i2f/springcloud/discovery/remote/RemoteDiscoveryClientProvider.java#L53)）无连接/读超时；配合 `scheduleAtFixedRate`，注册中心半死不活（TCP 可连但不响应）时心跳/拉取任务会无限期挂住线程池两条线程，后续全部停摆。
6. **【装配反模式·`@Component` 登记为自动配置 + 双通道】** `RemoteDiscoveryClientProvider` 是 `@Component`（非 `@Configuration`/`@AutoConfiguration`）却被同时写进 `spring.factories` 与 `AutoConfiguration.imports`（[spring.factories L3](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-discovery-starter/src/main/resources/META-INF/spring.factories#L3)）；宿主组件扫描命中 `i2f.springcloud.discovery.remote` 包即**双重注册**、`@PostConstruct` 与线程池翻倍。
7. **【两个 `DiscoveryClient` bean 语义重叠】** 配置式 `discoveryClientProvider`（`@Order(10)`）与远程式 `RemoteDiscoveryClientProvider`（`getOrder()=registry.order`，默认 0）同时作为 `DiscoveryClient` 存在，被 `CompositeDiscoveryClient` 聚合；两者 `holder` 各持一份实例视图，来源与优先级关系不直观，易造成「同一 serviceId 命中哪一份」的困惑。
8. **[@ConfigurationProperties 空挂 `enable`]** 元数据登记 `i2f.springcloud.discovery.enable` 且 sample 设置它，但 `DiscoveryProperties` **无 `enable` 字段**（仅 `instances`/`order`，[DiscoveryProperties.java L18-L21](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-discovery-starter/src/main/java/i2f/springcloud/discovery/properties/DiscoveryProperties.java#L18)）——`enable` 实由 `@ConditionalOnExpression` 直读、并非绑定，登记 `sourceType=DiscoveryProperties` 名不副实。
9. **【真实配置键大量未登记元数据】** 远程式 8 个键（`registry.enable`/`base-url`/`registry-path`/`pull-path`/`secret-key`/`heart-beat-seconds`/`pull-service-seconds`/`order`）与配置式 `instances` 在 `additional-spring-configuration-metadata.json` 中**零登记**（仅登记 `enable`/`order`）；`hints` 是 `server.servlet.jsp.class-name`/`server.tomcat.accesslog.encoding` 拷贝死条目。
10. **【硬编码版本绕开 DM】** 见依赖表：`spring-web`/`jackson-databind` 写死版本数字而非 `${spring.version}`/`${jackson.version}`，未来根升级易遗漏本模块致版本漂移。
11. **【缺 `@ConditionalOnClass`/`OnBean` 兜底】** `DiscoveryAutoConfiguration` 必需 `@Autowired InetUtils`（来自 spring-cloud-commons），而 `spring-cloud-starter` 为 `provided` 且**未标 optional**（其余 provided 均 optional）；若使用方未补齐 spring-cloud-commons，本类默认装载即因缺 `InetUtils` bean `NoSuchBeanDefinitionException`/`NoClassDefFoundError` 启动失败，无优雅退避。
12. **【`setUri` 无端口时 port=-1】** `DiscoveryServiceInstance.setUri` 直接取 `uri.getPort()`（[DiscoveryServiceInstance.java L28](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-discovery-starter/src/main/java/i2f/springcloud/discovery/provider/DiscoveryServiceInstance.java#L28)），配置成 `http://host/`（无显式端口）时 `port=-1`，`getServiceUri()` 拼出的地址端口异常；sample `uri: http://192.168.1.100:8080/` 恰带端口掩盖了此点。
13. **【潜在·`@AutoConfigureBefore` 引 reactive 类】** 抢先列表含 `ReactiveCompositeDiscoveryClientAutoConfiguration`，但本模块不引 WebFlux/reactive；该注解引用不在 classpath 的自动配置类一般被忽略，属冗余声明。

## 生态位置

- 位于 i2f-springcloud 组「服务发现」子域，是 `i2f-springcloud-discovery-server-starter`（自研 Redis 注册中心服务端）的**客户端对偶**，二者共同构成一组「无第三方注册中心」的自研发现闭环。
- 父 pom [i2f-springcloud/pom.xml L25](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/pom.xml#L25) 已登记本模块，根 pom [L1557](file:///C:/home/dev/java/dev-center/i2f-turbo-java/pom.xml#L1557) 有 DM 条目。
- 全仓 grep 未见其它模块真实 compile 消费本 Starter（仅自引用与文档索引），与配对服务端同为**生态孤岛**——一套「造好了但没人接」的自研发现方案。相较同组 nacos/consul 薄壳，本模块封装深度更高、也更值得修通默认路径与默认开关这两处「开箱不可用/开箱即刷屏」的硬伤。
