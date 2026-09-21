# i2f-springcloud-zipkin-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-zipkin-starter`

## 模块概述

Spring Cloud 组中面向 **Zipkin（链路跟踪数据上报/收集）** 的「装配 Starter」（本组第 22 个、亦为**最后一个**建档模块，**仅 1 个 Java 源文件（27 行）+ 4 个资源文件**，无任何 i2f 内部 compile 依赖）。

它是本组**最典型的纯空壳转发件**之一，与 `sleuth-starter` **完全同构**（同作者 Ice2Faith、同日 2022/5/28 19:45、逐行对称）：`ZipkinAutoConfiguration` 类体**零字段零方法**，除 `InitializingBean.afterPropertiesSet()` 打一行 `log.info("ZipkinConfig config done.")` 外**不做任何定制或增强**——无 `@Bean`、无自定义 `Reporter`/`Sender`/编码格式、无 Zipkin 属性绑定。上报能力全部来自使用方自行引入的 Zipkin 相关官方依赖。

模块把 `spring-cloud-sleuth-zipkin` 作为 `provided`（**未标 optional**）依赖引入，版本由根 pom `spring-cloud-dependencies:2021.0.8` BOM 治理。唯一属性 `i2f.springcloud.zipkin.enable` 实际由 `@ConditionalOnExpression` 的 SpEL 直读、并非绑定字段（类上 `@ConfigurationProperties` 挂在一个零字段类上）。

> 相对规范处：本件自动配置类**带了 `@Configuration`**（不同于 gateway 族的 lite 模式），但本件无任何 `@Bean`，该规范性并无实际意义。

## 模块依赖

| 依赖 | 类型 | 作用 |
|------|------|------|
| `org.projectlombok:lombok` | compile | `@Slf4j`/`@Data`/`@NoArgsConstructor` 注解处理 |
| `org.springframework.boot:spring-boot-starter` | provided + optional | `InitializingBean`、`@ConditionalOnExpression`、`@ConfigurationProperties` 编译期 API |
| `org.springframework.boot:spring-boot-configuration-processor` | provided + optional | 生成配置元数据（本件实际手写 additional-...json） |
| `org.springframework.cloud:spring-cloud-sleuth-zipkin` | provided（**未 optional**） | Sleuth→Zipkin 上报桥接件（zipkin-reporter + Sender），版本经根 `spring-cloud-dependencies:2021.0.8` BOM 治理 |

## 模块设计

```mermaid
graph TB
    A[ZipkinAutoConfiguration<br/>@Configuration @ConditionalOnExpression] -->|afterPropertiesSet| B[log.info 一行]
    A -.登记双通道.-> C[spring.factories EnableAutoConfiguration]
    A -.登记双通道.-> D[AutoConfiguration.imports]
    A ==@ConfigurationProperties 挂零字段类==> E[(无绑定字段)]
    C -.上报桥接.-> F[spring-cloud-sleuth-zipkin<br/>含 Zipkin 自动配置·读 spring.zipkin.*]
    F -.依赖.-> G[Sleuth tracing 核心<br/>spring-cloud-starter-sleuth·本件未引]
```

设计要点：本件是一个**布尔门占位壳**——`@ConditionalOnExpression("${i2f.springcloud.zipkin.enable:true}")` 只控制本空壳类是否实例化（实例化仅打一行日志），对真正的 Zipkin 自动配置**无任何干预能力**。

## 模块目的

在 Spring Cloud 微服务中统一以 `i2f.springcloud.*.enable` 命名空间管理各中间件开关，本件把 Zipkin 上报也纳入该命名空间。目的仅为「命名一致性占位」，不提供任何实质增强。

## 模块功能

- 唯一功能：`afterPropertiesSet()` 打印 `ZipkinConfig config done.` 启动日志一行。
- `i2f.springcloud.zipkin.enable:true` 布尔门：仅决定本空壳配置类是否被实例化。

## 模块主要使用方法

```xml
<dependencies>
    <!-- 本件仅代引 sleuth-zipkin 上报桥接（provided 不传递），不含 Sleuth tracing 核心 -->
    <dependency>
        <groupId>i2f.turbo</groupId>
        <artifactId>i2f-springcloud-zipkin-starter</artifactId>
    </dependency>
    <!-- 产出可上报 span 须自引 Sleuth 核心 -->
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-sleuth</artifactId>
    </dependency>
</dependencies>
```

配置：`i2f.springcloud.zipkin.enable=true`（唯一自有开关，实际对上报无效果）；真实上报地址须用官方 `spring.zipkin.base-url` 等键。

## 模块特性总结

- 本组最后一个建档模块，与 `sleuth-starter` 逐行对称的纯空壳转发件（1 个 27 行、零字段源文件）。
- 自动配置类带了 `@Configuration`（相对 gateway lite 族更规范，但无 `@Bean` 故无实际意义）。
- 双通道登记 `spring.factories` + `AutoConfiguration.imports`（本组各薄壳通病，过时冗余）。
- `provided` 代引但不 optional、不传递，名不副实。

## 模块瑕疵或错误（实证）

1. **纯空壳零增强**：`ZipkinAutoConfiguration` 类体零字段，`@ConfigurationProperties(prefix="i2f.springcloud.zipkin")` 空挂在无字段类上，唯一属性 `enable` 由 `@ConditionalOnExpression` SpEL 直读非绑定；`afterPropertiesSet()` 仅 `log.info`。引与不引本件，Zipkin 行为完全一致。
2. **本件对上报链路零贡献（依赖须配对 Sleuth 核心方生效）**：pom L34-38 引入 `spring-cloud-sleuth-zipkin`——它确为 Sleuth 3.1.x 中承载 Zipkin 自动配置、绑定 `spring.zipkin.base-url` 的正式组件（官方已弃用 `spring-cloud-starter-zipkin`，推荐 `spring-cloud-starter-sleuth` + `spring-cloud-sleuth-zipkin` 组合）。但它是 Sleuth→Zipkin 的**上报桥接件**，须有 Sleuth tracing 核心（`spring-cloud-starter-sleuth`）在位才产出可上报的 span；本模块**并不引入 Sleuth 核心**，也即单独引本件仅有上报通道而无 trace 来源。而本 i2f 空壳 `ZipkinAutoConfiguration` 本身对上述任何装配**不着一砖**（仅打日志），名带「starter」实为占位壳。
3. **provided 非 optional 不传递（名不副实）**：`spring-cloud-sleuth-zipkin` 为 `provided`（未标 optional），使用方仅引本「zipkin-starter」并不能真正获得上报能力，须再自引 Sleuth 核心 + 让该桥接件进入 runtime classpath——与 `sleuth-starter`/`loadbalancer-starter`/`netflix-eureka-*` 同病。
4. **sample 键拼写正确但依赖本件未引入的 Sleuth 核心**：`application-zipkin.properties` L6-7 的 `spring.zipkin.enabled=true`、`spring.zipkin.base-url=http://localhost:9411` 拼写正确、确由 `spring-cloud-sleuth-zipkin` 的自动配置解析（与 Sleuth 侧 sample 的废弃 `sampler.rate/percentage` 不同），但如瑕疵 2 所述，本件不引 Sleuth tracing 核心，仅有上报通道而无 span 来源；照抄 sample 仍须额外引入 `spring-cloud-starter-sleuth` 方可见链路，示例对本件真实 classpath 完整性有误导性。
5. **`enable=false` 关不掉上报（语义误导）**：`i2f.springcloud.zipkin.enable` 名义上是「Zipkin 开关」，实际仅决定本空壳是否实例化打日志；真正关闭上报须用官方 `spring.zipkin.enabled=false`。开关名不副实。
6. **无 `@ConditionalOnClass` 兜底 → NoClassDefFoundError 崩溃族**：类上仅 `@ConditionalOnExpression` 布尔门，无 `@ConditionalOnClass` 保护；属本组统一反模式（本类不 import Zipkin 类，故 NCDNF 风险较低，但与 sleuth/gateway 族同源）。
7. **`@Data`/`@NoArgsConstructor` 对零字段类生成无意义方法**：`@Data` 在无字段类上仅生成 `equals`/`hashCode`/`toString`，`@NoArgsConstructor` 与隐式构造器重复，纯冗余。
8. **双通道自动装配登记冗余 + 元数据 hints 死条目拷贝**：`spring.factories` 与 `AutoConfiguration.imports` 同时登记同一 `ZipkinAutoConfiguration`（Boot 2.7 以 imports 为准，前者属过时残留）；`additional-...json` 的 `hints` 段为 `server.servlet.jsp.class-name`、`server.tomcat.accesslog.encoding` 两条与 Zipkin 毫无关系的模板拷贝死条目（同 sleuth/gateway/zuul 族）。

## 生态位置

- 属 `i2f-springcloud` 组「链路跟踪/可观测性」子域，与 `i2f-springcloud-sleuth-starter` 为**上报端/生成端配对**——`sleuth` 负责 traceId 生成与 MDC 注入，`zipkin` 负责把 span 上报到 Zipkin Server（`base-url`）。二者源码逐行对称，均为空壳占位。
- 全仓**零消费方**，为纯孤岛占位件；真实上报能力须由使用方直引官方 zipkin 自动配置来源获得，本件仅提供一个无效的 `i2f.springcloud.zipkin.enable` 命名空间占位。
- **本模块为 `i2f-springcloud` 组建档收尾件**：至此该组 22 个真实模块（跳过 `test-gateway-swl`）全部完成文档与索引登记。
