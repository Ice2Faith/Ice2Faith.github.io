# i2f-springcloud-gateway-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-gateway-starter`

## 模块概述

Spring Cloud 组中面向 **Spring Cloud Gateway（响应式 API 网关）** 的「增强装配 Starter」（本组第 11 个建档模块，9 个 Java 源文件 + 6 个资源文件，**不含任何 i2f 内部 compile 依赖**，仅 lombok + Spring + Spring Cloud Gateway）。它把 `org.springframework.cloud:spring-cloud-starter-gateway` 作为 `provided` 依赖引入，版本由根 pom 的 `spring-cloud-dependencies:2021.0.8` BOM（[pom.xml L50](file:///C:/home/dev/java/dev-center/i2f-turbo-java/pom.xml#L50)/[L102](file:///C:/home/dev/java/dev-center/i2f-turbo-java/pom.xml#L102)）统一治理，无硬编码错配。

与同组 actuator/nacos/consul 等「空壳 + 布尔开关转发第三方 starter」的薄封装**根本不同**，本模块是 i2f-springcloud 组中**功能最完整的自定义网关增强件**：在官方 Gateway 之上叠加了一整套开箱即用的自定义断言、过滤器工厂、全局过滤器与 CORS，全部由一个总开关 `i2f.springcloud.gateway.enable` 经 `GatewayAutoConfiguration` 的 `@Import` 统一装载，各子件另有独立开关：

- **`GatewayCorsConfig`**：以 `@Bean CorsWebFilter`（`@Order(-100)`）提供代码式全局跨域，`urlPatten`/`allowOrigins`/`allowMethods`/`allowHeaders`/`allowCredentials`/`maxAge` 可配；
- **`RequestAttrRoutePredicateFactory`**：自定义 `RoutePredicateFactory`，按 Header/Query 中指定参数名是否存在（并可再匹配正则）决定是否命中路由（`- RequestAttr=token,[a-zA-Z0-9]{16,}`）；
- **`RequestAttrGatewayFilterFactory`**：自定义 `GatewayFilterFactory`，校验 Header/Query 参数、不满足则（设计意图）返回 402；
- **`RequestLogGlobalFilter`**：全局请求日志过滤器，注入 `trace-id`、打印路径/方法/来源/头/参数、可选耗时与按 path/IP 聚合的 `TimeStatistic` 统计；
- **`RequestQueryRepeatFilter`** + `RequestQueryRepeatProperties`：可选的全局过滤器，对 form/json/xml 请求缓冲 body、按 `repeatProps` 去除重复 query 参数（默认 `query-repeat.enable:false` opt-in）；
- **`AbsAuthTokenFilter`**：抽象的 token 鉴权 `GlobalFilter` 模板（白名单、header/param 取 token、`validToken` 抽象、401 HTML/JSON 响应工具）。

配套 `sample/readme.md`（457 行）是本组最翔实的 Gateway 断言/过滤器/跨域/访问日志教学文档。

## 模块依赖

| 依赖 | 关系 | scope |
|---|---|---|
| `org.projectlombok:lombok` | 编译期注解 | compile |
| `org.springframework.boot:spring-boot-starter` | 自动配置基座 | provided + optional |
| `org.springframework.boot:spring-boot-configuration-processor` | 元数据生成 | provided + optional |
| `org.springframework.cloud:spring-cloud-starter-gateway` | 网关核心（GlobalFilter/RoutePredicateFactory/CorsWebFilter 类型来源） | provided（**未标 optional**） |

- **零 i2f 内部 compile 依赖**；版本全部经根 `spring-cloud-dependencies` / spring-boot BOM 治理，无硬编码。
- 根 pom [L1562](file:///C:/home/dev/java/dev-center/i2f-turbo-java/pom.xml#L1562) 有 dependencyManagement 登记，父 pom [i2f-springcloud/pom.xml L26](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/pom.xml#L26) 有 `<module>`。

## 模块设计

```mermaid
graph TD
    A[GatewayAutoConfiguration<br/>i2f.springcloud.gateway.enable:true<br/>无 @Configuration·lite] -->|@Import| B[GatewayCorsConfig<br/>cors.enable:true<br/>@Bean CorsWebFilter]
    A -->|@Import| C[RequestAttrRoutePredicateFactory<br/>predicates.request-attr.enable:true]
    A -->|@Import| D[RequestAttrGatewayFilterFactory<br/>filters.request-attr.enable:true]
    A -->|@Import| E[RequestLogGlobalFilter<br/>global.filters.request-log.enable:true]
    A -->|@Import| F[RequestQueryRepeatFilter<br/>query-repeat.enable:false]
    F -.@EnableConfigurationProperties.-> G[RequestQueryRepeatProperties]
    E -.持.-> H[TimeStatistic]
    I[AbsAuthTokenFilter<br/>abstract] -.未被 @Import·需用户继承.-> A
    A -->|afterPropertiesSet| J[System.setProperty<br/>reactor accessLogEnabled]
    K[spring.factories + AutoConfiguration.imports<br/>双通道登记] --> A
```

## 模块目的

把「放 classpath 即得一套 Spring Cloud Gateway 常用增强」落地：开箱获得代码式 CORS、按 Header/Query 参数的自定义断言与过滤器、请求日志 + trace-id + 耗时统计、可选的重复参数裁剪，并以单一 `gateway.enable` 总开关 + 各子件独立开关分层控制，免去每个网关项目手写这些 `RoutePredicateFactory`/`GlobalFilter` 样板。

## 模块功能

- **总开关装载**：`GatewayAutoConfiguration`（`@ConditionalOnExpression("${i2f.springcloud.gateway.enable:true}")`）经 `@Import` 一把拉入 CORS、断言、过滤器工厂、请求日志、重复参数裁剪五个组件。
- **CORS**：`GatewayCorsConfig.corsFilter()` 用 `UrlBasedCorsConfigurationSource`+`PathPatternParser` 注册 `CorsWebFilter`。
- **自定义断言**：`RequestAttrRoutePredicateFactory` 支持 `RequestAttr=param,regexp` 简写（`shortcutFieldOrder` 绑定 param/regexp）。
- **自定义过滤器**：`RequestAttrGatewayFilterFactory`（继承 `AbstractNameValueGatewayFilterFactory`）按 name/value 校验请求属性。
- **请求日志与统计**：`RequestLogGlobalFilter` 生成 `trace-id`、打印请求/响应头与参数、可选按 path/IP 累计 `TimeStatistic`。
- **重复参数裁剪**：`RequestQueryRepeatFilter` 缓冲 form/json/xml body 并按 `repeatProps` 去重后重建 `ServerHttpRequestDecorator`。
- **鉴权模板**：`AbsAuthTokenFilter` 供业务继承实现 `validToken`。

## 模块主要使用方法

引入 Starter（Gateway 核心为 provided 且不传递，需自行补齐）：

```xml
<dependencies>
    <dependency>
        <groupId>i2f.turbo</groupId>
        <artifactId>i2f-springcloud-gateway-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-gateway</artifactId>
    </dependency>
</dependencies>
```

配置示例（详见 `sample/application-gateway.properties`）：

```properties
i2f.springcloud.gateway.enable=true
i2f.springcloud.gateway.cors.enable=true
i2f.springcloud.gateway.cors.allow-origins=https://a.com,https://b.com
i2f.springcloud.gateway.global.filters.request-log.enable=true
# 路由中即可使用自定义断言/过滤器
# predicates: - RequestAttr=token,[a-zA-Z0-9]{16,}
# filters:    - RequestAttr=token,[0-9]+
```

`sample/readme.md` 另给出完整的 routes/globalcors/内置断言与过滤器清单，可作为网关接入范本。

## 模块特性总结

- 本组**功能最完整、非薄封装**的网关增强件（9 源文件，含 3 类自定义 `GlobalFilter`/`RoutePredicateFactory`/`GatewayFilterFactory` + CORS + 鉴权模板）。
- 总开关 + 各子件独立开关分层条件化，`@Import` 使 `gateway.enable:false` 可整体关停所有增强组件。
- 版本经根 BOM 治理无硬编码；sample 教学文档详尽（457 行）。
- 有同组示例 `test-gateway-swl` 作消费方（非纯孤岛）。

## 模块瑕疵或错误（实证）

1. **【高危·缺 `@ConditionalOnClass` + provided 非 optional 不传递】** `spring-cloud-starter-gateway` 为 `provided` 但**未标 optional**（不具传递性），而 `GatewayAutoConfiguration` 登记进 `EnableAutoConfiguration` 仅有 `@ConditionalOnExpression` 布尔门、**无 `@ConditionalOnClass` 兜底**，其 `@Import` 的各件直接 implements/implements `GlobalFilter`/`AbstractRoutePredicateFactory`/`AbstractNameValueGatewayFilterFactory`/`CorsWebFilter` 等 gateway 类型。使用方未自行补齐 gateway 时 `enable` 默认仍 `true`，装载即 `NoClassDefFoundError` **启动失败而非优雅退避**（同 `actuator-admin`/`config-server`/`consul` 族）。
2. **【高危·`RequestAttrGatewayFilterFactory` 逻辑 bug：NPE + 402 不断链】** [`apply()`](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-gateway-starter/src/main/java/i2f/springcloud/gateway/filters/RequestAttrGatewayFilterFactory.java#L27-L48) 中 header/query 均取不到值（`value==null`）时，设 `402` + `response.setComplete()` 后**既不 return**，继续 `if (regex != null && !regex.isEmpty()) { if (!value.matches(regex)) ... }` → `value==null` 时 **`NullPointerException`**；即便不抛，末尾仍 `return chain.filter(exchange)`，请求照旧转发下游，类注释承诺的「不满足直接 402」根本不成立（设码后仍放行，且 `setComplete()` 后再 `chain.filter` 属 Reactive 双重处理）。
3. **【高危·默认 CORS 不安全】** [`GatewayCorsConfig`](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-gateway-starter/src/main/java/i2f/springcloud/gateway/GatewayCorsConfig.java#L30-L51) 默认 `allowCredentials=true` + `allowOrigins="*"`，代码把含 `*` 的 origin 从 `setAllowedOrigins` 剔除却 `addAllowedOriginPattern(item)` → 等价 `allowedOriginPatterns=*` + 允许携带凭证，Spring 会反射任意请求 Origin，任何站点可发起带 Cookie 跨域读写；默认即不安全且无告警。
4. **【中危·请求日志统计 Map 无界增长 + 重复打印】** `RequestLogGlobalFilter` 的 `pathTimeStatMap`/`ipTimeStatMap`（key 为 path 与客户端 IP）在 `showStatistic` 开启下每条不同 path/IP 永驻不清理，长期运行内存泄漏；同一 `builder` 在请求前 `log.info`（L87）、响应后追加再 `log.info`（L125），`showHeaders`/`showQuerys` 时请求头/参数被完整打印**两遍**。
5. **【中危·元数据默认值与代码不符】** `additional-spring-configuration-metadata.json` 登记 `show-querys`/`show-statistic` `defaultValue:true`，但代码字段默认 `false`；`enable-repeat-form` `defaultValue:false`，但代码默认 `true`（3 处背离，IDE 提示值 ≠ 实际生效值）；功能性的 `repeat-props`/`repeat-list-path-pattens`/`repeat-list-path-exclude-pattens` 三键**完全未登记**。
6. **【装配 lite 模式】** `GatewayAutoConfiguration`、`GatewayCorsConfig`（含 `@Bean corsFilter`）均**无 `@Configuration`/`@AutoConfiguration`**，走 lite 模式（同 spring/consul 族）。`@ConfigurationProperties(prefix="i2f.springcloud.gateway")` 加在仅含 `enableAccessLog` 字段的类上，总开关 `enable` 并非绑定字段（仅被 `@ConditionalOnExpression` 的 SpEL 直读）。
7. **【`AbsAuthTokenFilter` 死模板·文档误导】** 唯一成体系的 token 鉴权全局过滤器 `AbsAuthTokenFilter` 是**抽象类，既不在 `@Import` 列表也无任何注册**，须用户继承并注册才生效——「看似自带鉴权」实则默认零鉴权；其 `getPath` 与 `RequestQueryRepeatFilter` 均用 `subPath(prefixCount * 2)` 魔法数截取路径（按「分隔符+段各占一 element」假设），脱离 Spring `PathContainer` 语义文档、极脆弱。`AbsAuthTokenFilter` 与 `RequestLogGlobalFilter` 的 `getOrder()` 同为 `-1`，相对顺序不确定。
8. **【`RequestQueryRepeatProperties` 双注册/误用】** 该类 `@Configuration @ConfigurationProperties` 既作 `@Configuration` 组件，又被 `RequestQueryRepeatFilter` 上 `@EnableConfigurationProperties(RequestQueryRepeatProperties.class)` 引入；当 filter 被 `@Import` 时可能重复/歧义，`@Configuration` 挂在纯属性持有类上亦属误用。
9. **【`enableAccessLog` 全局 JVM 副作用】** `afterPropertiesSet` 用 `System.setProperty("reactor.netty.http.server.accessLogEnabled", ...)` 改全局系统属性，reactor-netty 在 WebServer 绑定期读取，与 Bean 初始化时序耦合脆弱且污染整个 JVM。
10. **【repeat filter 全量缓冲请求体】** `RequestQueryRepeatFilter` 对命中 content-type 的请求 `collectList().join(...)` 把 body 完整读进内存再重包 `DataBuffer`（含 retain/release），大 body OOM 风险（默认 `enable:false` opt-in 尚可控）；L179 有游离 `;;` 双分号。
11. **【双通道登记 + 装饰滥用】** `spring.factories` + `AutoConfiguration.imports` 双份登记同一 `GatewayAutoConfiguration`（过时冗余）；`@Data` 滥用于自动配置/过滤器类；全类字符串 `+` 拼接日志；`hints` 是 `server.servlet.jsp.class-name`/`server.tomcat.accesslog.encoding` 跨模块拷贝死条目。

## 生态位置

- 位于 Spring Cloud 组「服务网关」子域，是本组**功能最完整、最接近生产可用**的网关增强件（相较 actuator/nacos/consul 薄壳是质的提升）；与 `i2f-springcloud-gateway-swl-starter`（网关 + SWL 安全传输）、`i2f-springcloud-netflix-zuul-starter`（旧网关）构成网关选型族。
- **有真实消费方**：同组示例 `i2f-springcloud/test-gateway-swl`（compile 依赖本 Starter），非纯孤岛（但 `test-` 示例按工作流约定不单独建档）。
- 不产出被其它模块复用的 i2f 内部 API，仅对外提供网关自动装配能力。
