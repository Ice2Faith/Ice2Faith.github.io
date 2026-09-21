# i2f-springcloud-gateway-swl-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-gateway-swl-starter`

## 模块概述

Spring Cloud 组中面向 **Spring Cloud Gateway 的「SWL 安全传输（加解密）网关装配 Starter」**（本组第 12 个建档模块，7 个 Java 源文件 + 3 个资源文件）。它是 Servlet 侧 `i2f-springboot-swl-starter`（`SwlWebFilter`）的**响应式对偶**——把同一套 `i2f.web.swl.filter.SwlWebConfig`/`SwlWebCtrl`/`SwlTransfer` 加解密协议搬到网关边缘：请求进网关时自动解密、响应出网关时自动加密，并额外暴露一个 `/swl/swapKey` 握手端点供客户端交换非对称公钥。

与前 11 个多为「薄壳转发第三方 starter」不同，本模块**带有真实 i2f 内部 compile 依赖**（`i2f-spring-core`、`i2f-swl`、`i2f-sm-crypto-swl`、`i2f-jdk-ext-swl`、`i2f-extension-swl`），并把 `spring-cloud-starter-gateway` 作为 `provided` 依赖引入，版本由根 pom 的 `spring-cloud-dependencies:2021.0.8` BOM 治理。核心组件：

- **`SwlGatewayAutoConfiguration`**（`i2f.gateway.swl.enable:true`）：`@EnableConfigurationProperties` 装载 Web/Transfer 两组配置；`@Bean swlTransfer()`（`@ConditionalOnMissingBean(SwlTransfer)`）按算法类装配非对称/对称/摘要/混淆四供应商 + 一个 `IExpireCache` 适配缓存 + `SwlExpireCacheNonceManager`；`@Bean routes()` 注册 `/swl/swapKey` 路由；
- **`SwlGatewayFilter`**（`i2f.swl.filter.enable:true`，`GlobalFilter` order `-100`）：全模块核心，解密请求体/查询参数并重建 `ServerHttpRequestDecorator`，加密响应并包装 `ServerHttpResponseDecorator`；
- **`SwlGatewayApiFilter`**（`i2f.swl.api.enable:true`，`GlobalFilter` order `-999`）：拦截 `POST /swl/swapKey` 完成服务端握手、交换服务端公钥；
- **`SwlMissingBeanConfiguration`**（`i2f.swl.missing.enable:true`）：`@ConditionalOnMissingBean(IExpireCache)` 兜底一个进程内 `ConcurrentHashMap` 过期缓存；
- **`SwlWebConfigProperties`** / **`SwlTransferConfigProperties`**：分别继承 `SwlWebConfig`、`SwlTransferConfig` 并给出算法类默认（RSA/AES/SHA256/Base64 混淆）；
- **`ISwlExceptionAdvideConverter`**：一个孤立异常转换接口。

## 模块依赖

| 依赖 | 关系 | scope |
|---|---|---|
| `org.projectlombok:lombok` | 编译期注解 | compile |
| `org.springframework.boot:spring-boot-starter` | 自动配置基座 | provided + optional |
| `org.springframework.boot:spring-boot-configuration-processor` | 元数据生成 | provided + optional |
| `org.springframework.cloud:spring-cloud-starter-gateway` | 网关核心（`GlobalFilter`/`ServerHttpRequestDecorator`/`RouteLocator` 类型来源） | provided（**未标 optional**） |
| `i2f.turbo:i2f-spring-core` | `MatcherUtil` ant 路径匹配 | compile |
| `i2f.turbo:i2f-swl` | `SwlTransfer` 加解密传输核心 | compile |
| `i2f.turbo:i2f-sm-crypto-swl` | 国密算法实现 | compile |
| `i2f.turbo:i2f-jdk-ext-swl` | `i2f.web.swl.filter.*` Web 侧配置/常量/控制 | compile |
| `i2f.turbo:i2f-extension-swl` | SWL 扩展聚合 | compile |
| `com.antherd:sm-crypto` (0.3.2.1-RELEASE) | 国密 JS 兼容算法库 | provided（**硬编码版本**） |
| `org.bouncycastle:bcprov-jdk15to18` (1.74) | 国密底层 Provider | provided（**硬编码版本**） |

- **含 5 个 i2f 内部 compile 依赖**（本组少见，区别于 gateway-starter 的零内部依赖）；`sm-crypto`/`bcprov` 直写版本号、绕开根 DM/BOM 治理。
- 根 pom [L1567](file:///C:/home/dev/java/dev-center/i2f-turbo-java/pom.xml#L1567) 有 dependencyManagement 登记，父 pom [i2f-springcloud/pom.xml L27](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/pom.xml#L27) 有 `<module>`。

## 模块设计

```mermaid
graph TD
    K[spring.factories + AutoConfiguration.imports<br/>双通道登记 4 个自动配置类] --> A
    A[SwlGatewayAutoConfiguration<br/>i2f.gateway.swl.enable:true<br/>无 @Configuration·lite·@Import 空] -->|@EnableConfigurationProperties| W[SwlWebConfigProperties<br/>i2f.swl.web]
    A -->|@EnableConfigurationProperties| T[SwlTransferConfigProperties<br/>i2f.swl.transfer]
    A -->|@Bean swlTransfer @ConditionalOnMissingBean| ST[SwlTransfer<br/>receive/response 加解密核心]
    A -->|@Bean routes api-route.enable:true| RT[RouteLocator<br/>/swl/swapKey → http://localhost:80]
    M[SwlMissingBeanConfiguration<br/>missing.enable:true] -.@Bean IExpireCache 兜底.-> ST
    F[SwlGatewayFilter<br/>swl.filter.enable:true<br/>GlobalFilter order -100] -->|@Autowired| ST
    F -->|@Autowired| WC[SwlWebConfig 即 SwlWebConfigProperties]
    API[SwlGatewayApiFilter<br/>swl.api.enable:true<br/>GlobalFilter order -999] -->|@Autowired| ST
    F -.@AutoConfigureAfter.-> A
    API -.@AutoConfigureAfter.-> A
    ORPH[ISwlExceptionAdvideConverter<br/>孤立接口·无实现无引用] -.-> A
```

## 模块目的

让「放 classpath 即得一套网关级透明加解密传输」落地：在 API 网关边缘统一完成 SWL 协议的请求解密、响应加密、公钥握手与 nonce 防重放，业务微服务无需感知加解密即可复用 `i2f-swl` 的传输安全能力，是 Servlet 侧 `swl-starter` 在响应式网关上的等价实现。

## 模块功能

- **透明解密请求**：`SwlGatewayFilter` 缓冲 body、取 `swlp` 加密参数与 `swlh` 安全头，`transfer.receive(clientIp, data)` 解密后重建 `ServerHttpRequestDecorator`（覆盖 `getURI`/`getQueryParams`/`getHeaders`/`getBody`）。
- **透明加密响应**：`wrapperServerHttpResponse` 在 `writeWith` 中 `buffer()` 拼全体、`transfer.response(certId, parts)` 加密、加 `$.` 前缀、改写 `Content-Type` 为 `text/plain` 并暴露 `swlh`/`swlci`/`swlct` 响应头。
- **公钥握手**：`SwlGatewayApiFilter` 处理 `POST /swl/swapKey`，接收客户端公钥、`acceptOtherSwapKey`、回发服务端公钥（Base64+JSON）。
- **算法可插拔**：`SwlWebConfigProperties` 以 `asym/symm/digest/obfuscate-algo-class` 四属性经 `getBeanByTypeOrNewInstance` 装配供应商，`hints` 提供 class-reference 补全。
- **缓存兜底**：`SwlMissingBeanConfiguration` 在无 `IExpireCache` bean 时给进程内实现，供 nonce/密钥过期使用。
- **URL 路径校验**：`enableUrlPathCheck` 下比对 Base64 的 `swlu` 头与实际路径（逐级 strip `contextPath`），防路径被篡改。

## 模块主要使用方法

引入 Starter（Gateway 核心为 provided 且不传递，需自行补齐）：

```xml
<dependencies>
    <dependency>
        <groupId>i2f.turbo</groupId>
        <artifactId>i2f-springcloud-gateway-swl-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-gateway</artifactId>
    </dependency>
</dependencies>
```

配置示例（键详见 `additional-spring-configuration-metadata.json`）：

```properties
i2f.gateway.swl.enable=true
# 加解密总开关与各子件开关
i2f.swl.filter.enable=true
i2f.swl.api.enable=true
i2f.swl.missing.enable=true
# 传输/算法配置
i2f.swl.web.header-name=swlh
i2f.swl.web.asym-algo-class=i2f.swl.impl.supplier.SwlRsaAsymmetricEncryptorSupplier
i2f.swl.web.symm-algo-class=i2f.swl.impl.supplier.SwlAesSymmetricEncryptorSupplier
i2f.swl.transfer.nonce-window-seconds=1800
```

## 模块特性总结

- 本组「服务网关」子域中**唯一带完整加解密业务语义、且有 i2f 内部 compile 依赖**的网关件（`SwlGatewayFilter` 单文件 667 行）。
- Servlet 侧 `i2f-springboot-swl-starter` 的**响应式对偶**，复用同一 `i2f.web.swl.filter` 抽象，保证 Web/网关两端协议一致。
- 请求解密 / 响应加密 / 公钥握手 / nonce 防重放 / 路径篡改校验一体，算法供应商经配置四属性可插拔，缓存有进程内兜底。
- 四个独立开关（gateway/filter/api/missing）分层条件化；`SwlGatewayApiFilter` order `-999` 抢在 `SwlGatewayFilter` `-100` 之前拦截握手。
- **有真实消费方**：同组示例 `i2f-springcloud/test-gateway-swl`（compile 依赖本 Starter），是 SWL 业务线的生产网关装配点。

## 模块瑕疵或错误（实证）

1. **【高危·无 Content-Type 请求解密 NPE】** [`SwlGatewayFilter.filter()`](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-gateway-swl-starter/src/main/java/i2f/springcloud/gateway/swl/SwlGatewayFilter.java#L91-L223) 中 `mediaType = request.getHeaders().getContentType()` **可为 null**（L93 仅对拼字符串用的 `contentType` 判空），但进入 `ctrl.isIn()` 分支后 [L223](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-gateway-swl-starter/src/main/java/i2f/springcloud/gateway/swl/SwlGatewayFilter.java#L223) `Charset charset = mediaType.getCharset();` **无判空** → 无 `Content-Type` 但带 `swlh` 头/参数（或默认 `defaultCtrl.in=true` 且未配 `url-patterns`，几乎所有请求进入）解密时直接 **NPE**。
2. **【高危·swapKey 握手吞异常后 NPE/越界】** [`SwlGatewayApiFilter`](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-gateway-swl-starter/src/main/java/i2f/springcloud/gateway/swl/SwlGatewayApiFilter.java#L102-L113) 握手 body 反序列化包在**空 `catch`**（L107）中，失败时 `reqHandleShake` 仍为 `null`，随后 L113 `reqHandleShake.getAttaches().get(0)` **NPE**；`attaches` 为空则 `IndexOutOfBoundsException`。命中 path 的 POST 对畸形/非握手请求全无防御。
3. **【高危·缺 `@ConditionalOnClass` + provided 非 optional】** 同 gateway-starter/actuator-admin/config-server/consul 崩溃族：`spring-cloud-starter-gateway` 为 `provided` 且**未标 optional**（不具传递性），4 个自动配置类仅有 `@ConditionalOnExpression` 布尔门、**无 `@ConditionalOnClass` 兜底**，而 `SwlGatewayFilter`/`SwlGatewayApiFilter` 直接 implements `GlobalFilter`、依赖 `ServerHttpRequestDecorator`/`RouteLocator`。使用方未自行补齐 gateway 时开关默认仍 `true`，装载即 **`NoClassDefFoundError` 崩溃而非优雅退避**。
4. **【高危·clientIp 可伪造且作会话隔离键】** [`getIp()`](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-gateway-swl-starter/src/main/java/i2f/springcloud/gateway/swl/SwlGatewayFilter.java#L560-L598) 优先取 `x-forwarded-for`（可任意伪造），该值被用作 `transfer.receive(clientIp, data)` 的加密会话/nonce 隔离键（L265）——伪造头即可顶替/扰乱他人在网关侧的会话；各代理头皆 unknown 时更回落 `InetAddress.getLocalHost()` 把**服务端本机 IP** 当作「客户端 IP」，隔离语义失效。
5. **【中危·握手路由硬编码 `localhost:80` 且与 filter 强耦合】** [`routes()`](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-gateway-swl-starter/src/main/java/i2f/springcloud/gateway/swl/SwlGatewayAutoConfiguration.java#L169-L179) 把 `apiSwapKeyPath` 路由到死值 `http://localhost:80`；实际握手靠 `SwlGatewayApiFilter`（order `-999`）短路完成、该 URI 从不被访问。若关 `i2f.swl.api.enable:false` 而保留 `api-route.enable:true`，握手请求将被转发至 `localhost:80`——两个独立开关隐含强耦合，设计脆弱。
6. **【中危·大量功能键零登记元数据 + 国密名不副实】** 代码/条件实际读取但 `additional-spring-configuration-metadata.json` **未登记**：`i2f.gateway.swl.api-route.enable`、web 侧 `api-swap-key-path`、`enable-url-path-check`、`max-strip-url-path-count`、`cert-id-name`、`url-path-name`（`getCertIdName`/`getUrlPathName` 用于 L140/154/476）。且 `swl`/国密命名 + provided `sm-crypto`/`bcprov` 下，**默认装配实为国际算法 RSA/AES/SHA256/Base64**（`SwlWebConfigProperties` 四默认类），非真正 SM2/SM4/SM3，须手动改配置才启用国密。
7. **【中危·URL 路径校验头缺失 NPE】** `enableUrlPathCheck` 下 `swlu` 从 header/param 取可能为 `null`，[L166](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-gateway-swl-starter/src/main/java/i2f/springcloud/gateway/swl/SwlGatewayFilter.java#L166) `Base64StringByteCodec.INSTANCE.decode(swlu.get())` **NPE**；其逐级 strip `contextPath` 的 `endsWith` 匹配（L175-188）逻辑复杂、易误判合法路径。
8. **【装配 lite + 自注册为自动配置类】** 4 个自动配置类全部**无 `@Configuration`/`@AutoConfiguration`** 走 lite；更反常的是 `SwlGatewayFilter`/`SwlGatewayApiFilter` 本身 implements `GlobalFilter` 却**直接登记进 `spring.factories`/`AutoConfiguration.imports` 当作自动配置类**（靠「类即 bean」生效），`@AutoConfigureAfter` 亦挂其上，写法非常规、可读性差。
9. **【`@Import` 空挂 + `@ConfigurationProperties` 空挂】** `SwlGatewayAutoConfiguration` 的 `@Import({})` 为空、`@ConfigurationProperties(prefix="i2f.gateway.swl")` 加在本类却无任何绑定字段（`enable`/`api-route.enable` 均由 `@ConditionalOnExpression` 的 SpEL 直读），与前件 gateway-starter 同款空挂。
10. **【异常吞没 + 响应全量缓冲 OOM + 死代码】** `getBeanByTypeOrNewInstance`（L69/L74）、`swlTransfer()`（L86）、ApiFilter（L107）多处**空 `catch` 吞异常**；`wrapperServerHttpResponse` 对非下载响应 `fluxBody.buffer()` 全量拼进内存再加密，大响应 OOM（注释自陈「使用白名单避免 OOM」，但本件仅有请求侧白名单、**响应侧无 size 白名单**）；`ISwlExceptionAdvideConverter` 全模块无实现无引用属死代码。
11. **【双通道登记 + 装饰滥用 + 死 hints】** `spring.factories` + `AutoConfiguration.imports` 双份登记同一批 4 类（过时冗余）；`@Data` 滥用于自动配置/过滤器类；`hints` 尾部 `server.servlet.jsp.class-name`/`server.tomcat.accesslog.encoding` 为跨模块拷贝死条目；`sm-crypto`/`bcprov` 直写版本号绕开 BOM。

## 生态位置

- 位于 Spring Cloud 组「服务网关」子域，是本组**唯一带完整加解密业务语义**的网关件；与 `i2f-springcloud-gateway-starter`（通用网关增强）构成「网关 + 安全传输」组合——本件解决传输加密、gateway-starter 解决路由/CORS/日志增强。
- 是 Servlet 侧 `i2f-springboot-swl-starter`（`SwlWebFilter`）的**响应式对偶**，二者共享 `i2f.web.swl.filter` 抽象，实现 Web/网关两端一致的 SWL 加解密协议；上游依赖 `i2f-swl`（`SwlTransfer` 核心）、`i2f-sm-crypto-swl`、`i2f-jdk-ext-swl`。
- **有真实消费方**：同组示例 `i2f-springcloud/test-gateway-swl`（compile 依赖本 Starter），非孤岛（`test-` 示例按工作流约定不单独建档）。
