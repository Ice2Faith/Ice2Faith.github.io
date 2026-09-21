# i2f-springcloud-sleuth-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-sleuth-starter`

## 模块概述

Spring Cloud 组中面向 **Spring Cloud Sleuth（分布式链路跟踪）** 的「装配 Starter」（本组第 21 个建档模块，**仅 1 个 Java 源文件（27 行）+ 4 个资源文件**，无任何 i2f 内部 compile 依赖）。

它是本组典型的**纯空壳转发件**，与 `loadbalancer-starter`、`netflix-eureka-client/server`、`netflix-ribbon` 同族：`SleuthAutoConfiguration` 类体**零字段零方法**，除 `InitializingBean.afterPropertiesSet()` 打一行 `log.info("SleuthConfig config done.")` 外**不做任何定制或增强**——无 `@Bean`、无自定义 `Sampler`/`TraceIdLoggers`/采样策略、无 Sleuth 属性绑定。链路跟踪能力全部来自使用方自行引入的官方 `spring-cloud-starter-sleuth`（本件以 `provided` 代引但不传递）。

模块把 `spring-cloud-starter-sleuth` 作为 `provided`（**未标 optional**）依赖引入，版本由根 pom `spring-cloud-dependencies:2021.0.8` BOM 治理。唯一属性 `i2f.springcloud.sleuth.enable` 实际由 `@ConditionalOnExpression` 的 SpEL 直读、并非绑定字段（类上 `@ConfigurationProperties` 挂在一个零字段类上）。

> 相对规范处：本件自动配置类**带了 `@Configuration`**（不同于 gateway 族的 lite 模式无 `@Configuration`），因此跨 `@Bean` 方法直调会被 CGLIB 代理——尽管本件根本没有任何 `@Bean` 方法，该规范性并无实际意义。

## 模块依赖

| 依赖 | 类型 | 作用 |
|------|------|------|
| `org.projectlombok:lombok` | compile | `@Slf4j`/`@Data`/`@NoArgsConstructor` 注解处理 |
| `org.springframework.boot:spring-boot-starter` | provided + optional | `InitializingBean`、`@ConditionalOnExpression`、`@ConfigurationProperties` 编译期 API |
| `org.springframework.boot:spring-boot-configuration-processor` | provided + optional | 生成配置元数据（本件实际手写 additional-...json） |
| `org.springframework.cloud:spring-cloud-starter-sleuth` | provided（**未 optional**） | Sleuth 链路跟踪官方 starter，版本经根 `spring-cloud-dependencies:2021.0.8` BOM 治理 |

## 模块设计

```mermaid
graph TB
    A[SleuthAutoConfiguration<br/>@Configuration @ConditionalOnExpression] -->|afterPropertiesSet| B[log.info 一行]
    A -.登记双通道.-> C[spring.factories EnableAutoConfiguration]
    A -.登记双通道.-> D[AutoConfiguration.imports]
    A ==@ConfigurationProperties 挂零字段类==> E[(无绑定字段)]
    C -.真正能力来自.-> F[官方 spring-cloud-starter-sleuth<br/>使用方自行 provided 引入]
    D -.真正能力来自.-> F
```

设计要点：本件是一个**布尔门占位壳**——`@ConditionalOnExpression("${i2f.springcloud.sleuth.enable:true}")` 只控制本空壳类是否实例化（实例化仅打一行日志），对真正的 Sleuth 自动配置（官方 `brave.autoconfigure` 等）**无任何干预能力**。即使 `enable=false`，只要 classpath 有官方 Sleuth，链路跟踪照常生效。

## 模块目的

在 Spring Cloud 微服务中统一以 `i2f.springcloud.*.enable` 命名空间管理各中间件开关，本件把 Sleuth 也纳入该命名空间。目的仅为「命名一致性占位」，不提供任何实质增强。

## 模块功能

- 唯一功能：`afterPropertiesSet()` 打印 `SleuthConfig config done.` 启动日志一行。
- `i2f.springcloud.sleuth.enable:true` 布尔门：仅决定本空壳配置类是否被实例化。

## 模块主要使用方法

```xml
<dependencies>
    <!-- 本件仅代引 Sleuth 但不传递，须再自引官方 starter 方有真实能力 -->
    <dependency>
        <groupId>i2f.turbo</groupId>
        <artifactId>i2f-springcloud-sleuth-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-sleuth</artifactId>
    </dependency>
</dependencies>
```

配置：`i2f.springcloud.sleuth.enable=true`（唯一自有开关，实际对链路跟踪无效果）。真实采样等能力须用官方 `spring.sleuth.*` 键。

## 模块特性总结

- 本组最典型的纯空壳转发件之一（1 个 27 行、零字段源文件）。
- 自动配置类带了 `@Configuration`（相对 gateway lite 族更规范，但无 `@Bean` 故无实际意义）。
- 双通道登记 `spring.factories` + `AutoConfiguration.imports`（本组各薄壳通病，过时冗余）。
- `provided` 代引 Sleuth 但不 optional、不传递，名不副实。

## 模块瑕疵或错误（实证）

1. **纯空壳零增强**：`SleuthAutoConfiguration` 类体零字段，`@ConfigurationProperties(prefix="i2f.springcloud.sleuth")` 空挂在无字段类上，唯一属性 `enable` 由 `@ConditionalOnExpression` SpEL 直读非绑定；`afterPropertiesSet()` 仅 `log.info`。引与不引本件，只要 classpath 有官方 Sleuth，链路跟踪行为完全一致。
2. **provided 非 optional 不传递（名不副实）**：pom L34-38 `spring-cloud-starter-sleuth` 为 `provided`（**未标 optional**），使用方仅引本「sleuth-starter」并不能真正获得 Sleuth 能力，须再自引官方 starter——与 `loadbalancer-starter`/`netflix-eureka-*` 同病。
3. **无 `@ConditionalOnClass` 兜底 → NoClassDefFoundError 崩溃族**：类上仅 `@ConditionalOnExpression` 布尔门，无 `@ConditionalOnClass` 保护。虽本类本身不 import Sleuth 类（故 NCDNF 风险较 gateway/actuator-admin 低），但一旦未来在类中引用 Sleuth 类型即触发同类崩溃；属本组统一反模式。
4. **`enable=false` 关不掉链路跟踪（语义误导）**：`i2f.springcloud.sleuth.enable` 名义上是「Sleuth 开关」，实际仅决定本空壳是否实例化打日志；真正关闭 Sleuth 须用官方 `spring.sleuth.enabled=false`。开关名不副实，用户误配后排查困难。
5. **sample 含废弃/错误 Sleuth 采样键（高危误导）**：`application-sleuth.properties` L4-5 写 `spring.sleuth.sampler.rate=10` 与 `spring.sleuth.sampler.percentage=1`——在 Spring Cloud Sleuth 3.1.x（2021.0.8）中正确的采样键是 `spring.sleuth.sampler.probability`（取值 0.0–1.0）；`percentage`（0–100）是 Sleuth 2.x 旧键、`rate` 亦非标准有效键。照抄 sample 两项均**不生效**，且两值语义互相冲突（rate=10 与 percentage=1）。
6. **`@Data`/`@NoArgsConstructor` 对零字段类生成无意义方法**：`@Data` 在无任何字段的类上仅生成 `equals`/`hashCode`/`toString`，`@NoArgsConstructor` 与隐式构造器重复，纯冗余。
7. **双通道自动装配登记冗余**：`spring.factories`（`EnableAutoConfiguration=`）与 `AutoConfiguration.imports` 同时登记同一 `SleuthAutoConfiguration`；Boot 2.7 已以 imports 通道为准，`spring.factories` 的 EnableAutoConfiguration 条目属过时残留。
8. **元数据 hints 死条目拷贝**：`additional-spring-configuration-metadata.json` 的 `hints` 段为 `server.servlet.jsp.class-name`、`server.tomcat.accesslog.encoding` 两条与 Sleuth 毫无关系的模板拷贝死条目（同 gateway-starter/zuul 等族），仅 `enable` 一个真实键却配了无关 hints。

## 生态位置

- 属 `i2f-springcloud` 组「链路跟踪」子域，与 `i2f-springcloud-zipkin-starter`（数据上报/可视化端）为观测性配对；`sleuth` 负责 traceId 生成与 MDC 注入，`zipkin` 负责 span 收集上报。
- 与 `i2f-springboot` 组的日志/MDC 相关件（如 trace-mdc）在「traceId 进日志」这一点上概念相邻，但本件走 Spring Cloud Sleuth/Brave 体系。
- 全仓**零消费方**，为纯孤岛占位件；真实链路跟踪能力须由使用方直引官方 `spring-cloud-starter-sleuth` 获得，本件仅提供一个无效的 `i2f.springcloud.sleuth.enable` 命名空间占位。
