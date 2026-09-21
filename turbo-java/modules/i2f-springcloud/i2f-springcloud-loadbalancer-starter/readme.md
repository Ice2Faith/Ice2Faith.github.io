# i2f-springcloud-loadbalancer-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-loadbalancer-starter`

## 模块概述

Spring Cloud 组中面向 **Spring Cloud LoadBalancer（客户端负载均衡）** 的「装配 Starter」（本组第 13 个建档模块，**仅 1 个 Java 源文件（27 行）+ 4 个资源文件**，无任何 i2f 内部 compile 依赖）。它是本组最典型的**纯空壳转发件**：`LoadBalancerAutoConfiguration` 除在初始化时打一行日志外**不做任何定制或增强**，`@ConfigurationProperties(prefix="i2f.springcloud.loadbalancer")` 挂在一个**零字段**的类上，唯一属性 `enable` 实际由 `@ConditionalOnExpression` 的 SpEL 直读、并非绑定字段。

模块把 `org.springframework.cloud:spring-cloud-starter-loadbalancer` 作为 `provided`（**未标 optional**）依赖引入，版本由根 pom `spring-cloud-dependencies:2021.0.8` BOM 治理。pom 注释与 `sample` 均明示：要在 cloud-alibaba 等场景启用 LoadBalancer，须**手动**排除/禁用默认的 Ribbon（`spring.cloud.loadbalancer.ribbon.enabled=false`），本 Starter 不代为处理。

## 模块依赖

| 依赖 | 关系 | scope |
|---|---|---|
| `org.projectlombok:lombok` | 编译期注解 | compile |
| `org.springframework.boot:spring-boot-starter` | 自动配置基座 | provided + optional |
| `org.springframework.boot:spring-boot-configuration-processor` | 元数据生成 | provided + optional |
| `org.springframework.cloud:spring-cloud-starter-loadbalancer` | 负载均衡核心 | provided（**未标 optional、不传递**） |

- **零 i2f 内部 compile 依赖**；版本经根 `spring-cloud-dependencies` BOM 治理，无硬编码。
- 根 pom [L1572](file:///C:/home/dev/java/dev-center/i2f-turbo-java/pom.xml#L1572) 有 dependencyManagement 登记，父 pom [i2f-springcloud/pom.xml L28](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/pom.xml#L28) 有 `<module>`。

## 模块设计

```mermaid
graph TD
    K[spring.factories + AutoConfiguration.imports<br/>双通道登记] --> A
    A[LoadBalancerAutoConfiguration<br/>i2f.springcloud.loadbalancer.enable:true<br/>@Configuration·零字段] -->|afterPropertiesSet| L[log.info 一行]
    A -.@ConfigurationProperties 空挂.-> P[无字段可绑定]
    A -.依赖但不引用任何类型.-> B[spring-cloud-starter-loadbalancer<br/>provided 不传递]
```

## 模块目的

名义上「放 classpath 即接入 Spring Cloud LoadBalancer 并可用单一开关启停」，实际仅提供一个 `enable` 布尔门 + 一行启动日志，作为官方 `spring-cloud-starter-loadbalancer` 的占位转发点。

## 模块功能

- **布尔开关装载**：`@ConditionalOnExpression("${i2f.springcloud.loadbalancer.enable:true}")` 决定本自动配置类是否实例化（默认开）。
- **启动日志**：`afterPropertiesSet()` 打印 `LoadBalancerConfig config done.`。
- 无 `@Bean`、无 `ReactorLoadBalancer` 自定义、无 Ribbon 排斥逻辑——负载均衡能力完全由使用方自行的官方 starter 与配置提供。

## 模块主要使用方法

引入 Starter（LoadBalancer 核心为 provided 且不传递，需自行补齐官方 starter）：

```xml
<dependencies>
    <dependency>
        <groupId>i2f.turbo</groupId>
        <artifactId>i2f-springcloud-loadbalancer-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-loadbalancer</artifactId>
    </dependency>
</dependencies>
```

配置示例（注意：`sample` 中的键拼写有误，正确键见下）：

```properties
# 正确开关键（sample 误写为 i2f.springcloud.config.loadbalancer.enable）
i2f.springcloud.loadbalancer.enable=true
# 用 loadbalancer 须手动禁用默认 ribbon
spring.cloud.loadbalancer.ribbon.enabled=false
```

`sample` 另注明自定义策略思路（默认 `RoundRobinLoadBalancer`，可 `@Bean ReactorLoadBalancer` 返回 `RandomLoadBalancer` 并用 `@LoadBalancerClients` 指定），但均为注释示意、非本件实现。

## 模块特性总结

- 本组**最薄的纯空壳转发件**之一（1 个 27 行零字段类，仅一行日志）。
- 自动配置类相对规范地带了 `@Configuration`（不同于 gateway 族的 lite 模式）。
- 无任何负载均衡定制、无任何第三方类型引用，装载行为等价于一个 `if` 日志。

## 模块瑕疵或错误（实证）

1. **【纯空壳·零增强】** [`LoadBalancerAutoConfiguration`](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-loadbalancer-starter/src/main/java/i2f/springcloud/loadbalancer/LoadBalancerAutoConfiguration.java) 类体**零字段**，`@ConfigurationProperties` 前缀空挂（唯一属性 `enable` 由 `@ConditionalOnExpression` SpEL 直读、非绑定字段），`afterPropertiesSet()` 仅 `log.info`。引与不引本件，负载均衡行为完全一致——不提供任何 `ReactorLoadBalancer`/策略/拦截增强。
2. **【provided 非 optional 不传递·名不副实】** `spring-cloud-starter-loadbalancer` 为 `provided` 且**未标 optional**，不具备传递性；使用方仅引本「loadbalancer-starter」**并不会真正获得 LoadBalancer 能力**，必须再自行引入官方 starter，否则「装了 loadbalancer starter 却没有 loadbalancer」。
3. **【sample 开关键拼写错误】** [`application-loadbalancer.properties` L2](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-loadbalancer-starter/src/main/resources/sample/application-loadbalancer.properties#L2) 写 `i2f.springcloud.config.loadbalancer.enable=true`，**多出一段 `.config.`**，与代码 `@ConfigurationProperties` 前缀及元数据登记键 `i2f.springcloud.loadbalancer.enable` 均不符，照抄示例则该开关永不生效。
4. **【Ribbon 排斥须手动·无自动条件】** pom 注释与 sample 均要求用户手动 `spring.cloud.loadbalancer.ribbon.enabled=false` 或排除 `spring-cloud-starter-netflix-ribbon`，本件不做任何 `@ConditionalOnMissingBean`/自动排斥，与同组 `netflix-ribbon-starter` 并存时冲突全交给使用方。
5. **【双通道登记 + 死 hints】** `spring.factories` + `AutoConfiguration.imports` 双份登记同一类（过时冗余）；`additional-spring-configuration-metadata.json` 的 `hints` 是 `server.servlet.jsp.class-name`/`server.tomcat.accesslog.encoding` 跨模块拷贝的死条目，与本模块无关。
6. **【全仓零消费方·生态孤岛】** 全仓仅 `pom.xml`（自身）/父 `<module>`/根 DM 三处出现，无任何下游模块 compile 依赖，属纯孤岛。

## 生态位置

- 位于 Spring Cloud 组「客户端负载均衡」子域，与 `i2f-springcloud-netflix-ribbon-starter`（旧 Ribbon）构成负载均衡选型对偶；本件对应官方新一代 LoadBalancer，但仅空壳转发。
- 不产出被其它模块复用的 i2f 内部 API，**亦无任何真实消费方**（生态孤岛）。
