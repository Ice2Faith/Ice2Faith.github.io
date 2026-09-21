# i2f-springcloud-discovery-server-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-discovery-server-starter`

## 模块概述

Spring Cloud 组中一个**自研的轻量级服务注册中心「服务端」**装配 Starter（本组第 9 个建档模块，5 个 Java 源文件 + 4 个资源文件，**不含任何 i2f 内部 compile 依赖**，仅 lombok + Spring + Redis）。

与同组 `nacos`/`consul`/`eureka` 等「把第三方注册中心 starter 改造成放 classpath 即自动装载」的薄封装**根本不同**：本模块**不依赖任何现成注册中心框架**，而是用 **Redis 作为实例存储后端 + 一组 HTTP POST 接口 + SHA-256 签名校验**，从零实现了一个最小可用的服务注册/发现服务端：

- 服务实例通过 `POST /api/api/registry` 上报 `{uid, sign, serviceId, port}`，服务端以 `http://{remoteAddr}:{port}` 组装实例地址并写入带 TTL 的 Redis 键；
- 消费方通过 `POST /api/api/services` 拉取全部 `{serviceId -> [url...]}` 实例表；
- 所有接口调用都需携带 `sign = SHA-256(secretKey + "#" + uid)` 做简单鉴权。

它是本组「服务发现」子域中唯一的服务端**实现**（而非第三方接入），配套 `i2f-springcloud-discovery-starter`（客户端）。设计意图是提供一个无重型中间件（不装 Nacos/Eureka 服务器）、仅靠已有 Redis 即可运作的极简注册中心。

## 模块依赖

### 内部依赖（compile）

| 依赖 | 说明 |
|---|---|
| （无） | 本模块不含任何 `i2f.*` 内部 compile 依赖 |

### 外部依赖

| 依赖 | scope | optional | 用途 |
|---|---|---|---|
| `org.projectlombok:lombok` | provided | - | `@Data`/`@Slf4j`/`@NoArgsConstructor` |
| `org.springframework.boot:spring-boot-starter` | provided | true | Spring 基础 |
| `spring-boot-configuration-processor` | provided | true | 元数据生成 |
| `org.springframework.cloud:spring-cloud-starter` | provided | **false** | **代码零引用（死依赖）** |
| `spring-boot-starter-web` | provided | true | `@RestController` 提供 HTTP 端点 |
| `spring-boot-starter-data-redis` | provided | true | `RedisTemplate` 实例存储后端 |

> 依赖全部为 `provided`：使用方须自行补齐 `spring-boot-starter-web`、`spring-boot-starter-data-redis` 才能实际启用（Redis 缺失时 `RedisServiceInstanceManager` 会因 `@ConditionalOnClass` 退避，但见下文高危缺陷——退避后控制器仍会崩溃）。

## 模块设计

```mermaid
graph TD
    A[DiscoveryServerAutoConfiguration<br/>@ConditionalOnExpression discovery.server.enable:true] -->|@Import| B[RedisServiceInstanceManager]
    A -->|@Import| C[DiscoverServerController]
    A -->|@EnableConfigurationProperties| D[DiscoveryServerProperties<br/>secretKey/keepaliveSeconds/redisManager.prefix]
    C -->|@Autowired required| E[IServiceInstanceManager]
    B -.implements.-> E
    B -->|@Autowired| F[RedisTemplate]
    C -->|POST /api/api/registry| G[makeSign SHA-256 校验 → saveInstance TTL]
    C -->|POST /api/api/services| H[makeSign 校验 → getAllInstances]
    B --> I[(Redis keyspace<br/>prefix:services:serviceId:url)]
```

## 模块目的

为不想部署 Nacos/Eureka/Consul 等重型注册中心、但已有 Redis 的团队，提供一个**开箱即用的极简服务注册/发现服务端**：放入 classpath、配好 Redis 连接即自动暴露注册与查询 HTTP API，实例以带 TTL 的 Redis 键存储，靠 keepalive 过期实现「心跳即存活」。

## 模块功能

| 组件 | 职责 |
|---|---|
| `DiscoveryServerAutoConfiguration` | 标准 `@Configuration` + `@Import` + `@EnableConfigurationProperties` + 布尔开关，`InitializingBean` 打印一行日志 |
| `DiscoveryServerProperties` | `secret-key`（默认 `"123456"`）、`keepalive-seconds`（默认 30）、`redis-manager.prefix`（默认空→`default:`） |
| `IServiceInstanceManager` | 实例存储抽象：`saveInstance`/`getServices`/`getInstances`/`getAllInstances` |
| `RedisServiceInstanceManager` | 基于 `RedisTemplate` 的实现，键格式 `{prefix}:services:{serviceId}:{URLEncode(url)}`，带 TTL |
| `DiscoverServerController` | `/api/api/registry` 注册、`/api/api/services` 查询，SHA-256 签名校验 |

## 模块主要使用方法

```xml
<dependencies>
    <dependency>
        <groupId>i2f.turbo</groupId>
        <artifactId>i2f-springcloud-discovery-server-starter</artifactId>
    </dependency>
    <!-- provided 依赖须使用方自行补齐： -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-redis</artifactId>
    </dependency>
</dependencies>
```

```yaml
spring:
  redis:
    host: 127.0.0.1
    port: 6379
i2f:
  springcloud:
    discovery:
      server:
        enable: true
        api:
          enable: true
        secret-key: 请改为强随机串   # 默认 123456 极弱，见高危缺陷
        keepalive-seconds: 30
        redis-manager:
          enable: true
          prefix: myapp
```

注册示例：`POST /api/api/registry`，body `{"uid":"u1","sign":"<sha256(secretKey#u1)>","serviceId":"order-service","port":8081}`。

## 模块特性总结

- 本组**唯一的服务端自研实现**（非第三方注册中心薄封装），零外部中间件依赖（仅需 Redis）。
- 装配风格相对规范：`DiscoveryServerAutoConfiguration` 是**真正的 `@Configuration`**（非 lite 无注解反模式），被 `@Import` 的两个组件也走条件评估，`RedisServiceInstanceManager` 有 `@ConditionalOnClass(RedisTemplate.class)` 兜底。
- 三级独立布尔开关：`discovery.server.enable`、`discovery.server.api.enable`、`discovery.server.redis-manager.enable`，且**键拼写全部正确并登记进元数据**。
- 简单 HMAC 风格签名（密钥 + uid 的 SHA-256）与带 TTL 的实例存活模型。

## 模块瑕疵或错误（实证）

1. **【高危·默认密钥极弱且被 sample 固化】** `DiscoveryServerProperties.secretKey` 默认值硬编码为 `"123456"`，且 `application-discovery-server.yaml` 示例原样写 `secret-key: 123456`。若使用方未覆盖，整套注册/查询 API 的签名鉴权等于形同虚设——任何知道该弱密钥的人都能伪造 `sign` 注册恶意实例或拉取全量服务表（可投毒、可侦察）。
2. **【高危·条件不一致致启动崩溃】** `RedisServiceInstanceManager` 受 `@ConditionalOnClass(RedisTemplate)` + `redis-manager.enable` 双重门控，可优雅退避；但 `DiscoverServerController` 仅受 `api.enable`（默认 `true`）门控，且以 `@Autowired`（required=true）注入 `IServiceInstanceManager`。当 Redis 未补齐 / `redis-manager.enable:false` 而 `api.enable` 保持默认 `true` 时，控制器找不到必需 bean → `NoSuchBeanDefinitionException` **启动失败**。控制器应加 `@ConditionalOnBean(IServiceInstanceManager.class)` 或改 `required=false`。
3. **【中危·Redis KEYS 命令阻塞】** `getServices`/`getInstances`/`getAllInstances` 均用 `redisTemplate.keys(pattern)`，对应 Redis `KEYS` 命令——O(N) 全键空间扫描且**阻塞 Redis 主线程**，生产大 keyspace 下会造成整个 Redis 卡死。应改用 `SCAN` 游标迭代。
4. **【中危·签名无时间戳/随机数，可重放】** `makeSign(uid)` 仅 `SHA-256(secretKey#uid)`，载荷里只有 `uid`、无 timestamp/nonce。一旦合法 `sign` 被嗅探，可在密钥不变前提无限重放同一注册请求；也无法防止查询接口的重放。
5. **【中危·`getRemoteAddr()` 在网关/代理后取到代理 IP】** `registry()` 用 `request.getRemoteAddr()` 作为实例 host，服务位于 Nginx/K8s Ingress/Sidecar 之后时会把所有实例都记成代理地址，且未处理 `X-Forwarded-For`/`Forwarded`。而端口 `port` 又来自客户端自报，host 与 port 来源割裂易拼出错误 URL。
6. **【中危·关键安全属性未登记元数据】** `additional-spring-configuration-metadata.json` 仅登记 3 个 `*.enable` 布尔项，而 `secret-key`、`keepalive-seconds`、`redis-manager.prefix` 三个真正影响安全/行为的属性**完全缺失**，IDE 无补全、无文档提示，进一步放大第 1 条弱密钥风险。
7. **【低危·组件双重注册风险】** `DiscoverServerController`（`@RestController`）与 `RedisServiceInstanceManager`（`@Component`）既被 `@Import`、又自带 stereotype 注解；若使用方组件扫描命中 `i2f.springcloud.discovery.server` 包，会与其被自动配置 `@Import` 的注册产生冲突/重复。
8. **【低危·键解析对分隔符脆弱】** 读回时用 `key.split(":services:",2)` 再 `split(":",2)` 拆 serviceId 与 url，隐含「serviceId 不含冒号」假设；一旦 serviceId 含 `:`，`getInstances`/`getAllInstances` 会解析错位（url 段被截断）。
9. **【低危·死依赖】** `spring-cloud-starter` 以 `provided`（且未标 `optional`，与本模块其余依赖 scope 惯例不一致）引入，但全模块无任何 `org.springframework.cloud.*` import，是纯死依赖。
10. **【低危·元数据 copy-paste 死条目】** `hints` 为 `server.servlet.jsp.class-name` 与 `server.tomcat.accesslog.encoding`，与本模块毫不相关（同组多模块反复出现的拷贝残留）；`redis-manager.enable` 的 description 误写为 "enable discovery server api."（应从 "api" 改为 "redis manager"）。
11. **【信息·`@Data`/`@NoArgsConstructor` 噪声】** 在 `@RestController`、`@Component`、自动配置类上叠加 `@Data`/`@NoArgsConstructor` 纯属装饰，`@Data` 还会为含 `@Autowired` 字段的控制器生成 `setServiceInstanceManager` 等可变 setter。
12. **【信息·双通道登记】** 同一自动配置类同时登记于 `spring.factories` 与 `AutoConfiguration.imports`（Boot 2.7 只需后者）。
13. **【信息·TTL 语义】** 实例存活性完全依赖 Redis TTL（`keepalive-seconds`），但模块未提供任何续期定时逻辑，客户端须自行按小于 TTL 的周期反复 `registry`，否则实例静默消失。

## 生态位置

处于 i2f-springcloud 组「服务发现」子域的**服务端**，与同组 `i2f-springcloud-discovery-starter`（客户端）配套；不同于 nacos/consul/eureka 系列对第三方框架的薄封装，它是本组**唯一自研实现**的注册中心。全仓 grep 显示除父 pom 模块登记、根 pom DM 登记与文档引用外，**无任何 compile/test 真实消费方**，属生态孤岛。
