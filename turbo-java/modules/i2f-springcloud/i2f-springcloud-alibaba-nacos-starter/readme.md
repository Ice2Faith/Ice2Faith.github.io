# i2f-springcloud-alibaba-nacos-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-alibaba-nacos-starter`

## 模块概述

Spring Cloud 组中一个面向 **阿里巴巴 Nacos（服务注册发现 + 配置中心）** 的「即插即用」装配 Starter（本组第 3 个建档模块，1 个 Java 源文件 + 6 个资源文件，**不含任何 i2f 内部 compile 依赖**，仅 lombok）。它把 `com.alibaba.cloud:spring-cloud-starter-alibaba-nacos-discovery`（注册发现）与 `spring-cloud-starter-alibaba-nacos-config`（配置拉取/刷新）以及 `spring-cloud-starter-loadbalancer`（客户端负载均衡）作为 `provided` 依赖引入，并通过一个带 `@EnableDiscoveryClient` 的 `@Configuration` 类 `NacosAutoConfiguration` 做「放 classpath + 布尔开关 `i2f.springcloud.nacos.enable`（默认 `true`）即自动装载」的门控，配套 sample 的 `bootstrap-nacos.yaml` 演示完整的 nacos 注册/配置/共享配置/命名空间/权重等设置。它是本组「注册中心」子域与 eureka/consul 并列的核心接入件。

需说明：本模块的 `NacosAutoConfiguration` 相比同组 `actuator-*` 两个空壳类**略实**（至少携带 `@EnableDiscoveryClient` 并 `implements InitializingBean` 打印一行日志），但真正让 nacos 生效的仍是 `spring-cloud-starter-alibaba-nacos-*` 自身的自动配置，本类的 `enable` 开关对其约束有限（详见「模块瑕疵」）。

## 模块依赖

### 内部依赖（compile）

| 依赖 | 说明 |
|---|---|
| `org.projectlombok:lombok` | 编译期注解（`@Data`/`@NoArgsConstructor`/`@Slf4j`），本模块唯一 compile 项 |

> 无任何 `i2f.*` 内部 compile 依赖。

### 外部依赖（provided）

| 依赖 | 版本来源 | scope / optional | 说明 |
|---|---|---|---|
| `org.springframework.boot:spring-boot-starter` | 根 DM | provided + optional | Boot 基础 |
| `org.springframework.boot:spring-boot-configuration-processor` | 根 DM | provided + optional | 元数据处理器 |
| `com.alibaba.cloud:spring-cloud-starter-alibaba-nacos-discovery` | 根 BOM `2021.0.5.0` | provided + optional | 服务注册与发现 |
| `com.alibaba.cloud:spring-cloud-starter-alibaba-nacos-config` | 根 BOM `2021.0.5.0` | provided + optional | 配置拉取与刷新 |
| `org.springframework.cloud:spring-cloud-starter-loadbalancer` | 根 DM | **provided（非 optional）** | 客户端负载均衡 |

> 与 actuator 家族不同：本模块 **nacos 依赖不写死版本**，由根 pom 的 `spring-cloud-alibaba-dependencies:2021.0.5.0` BOM 统一管理（[pom.xml L51](file:///C:/home/dev/java/dev-center/i2f-turbo-java/pom.xml#L51)、[L111-112](file:///C:/home/dev/java/dev-center/i2f-turbo-java/pom.xml#L111-L112)），与 Spring Boot 2.7.x / Spring Cloud 2021.0.x 相容——这一点优于同组硬编码 `2.2.3` 的 actuator 件。

## 模块设计

```mermaid
graph TD
    A[宿主引入 alibaba-nacos-starter] --> B{enable:true 默认}
    B -->|装载| C[NacosAutoConfiguration]
    C --> D[@EnableDiscoveryClient 激活服务发现]
    C --> E[InitializingBean 打印 config done 日志]
    F[spring-cloud-starter-alibaba-nacos-discovery] --> G[Nacos 自身自动配置: 注册 + 拉取配置]
    H[bootstrap-nacos.yaml 的 spring.cloud.nacos.* 属性] --> G
    G --> I[(注册到 Nacos Server / 拉取远程配置)]
    D -.->|Spring Cloud 2021 已默认自动注册, 本注解冗余| G
```

真实的注册与配置拉取由 nacos 自身自动配置（右支）驱动；本 Starter 的 `@EnableDiscoveryClient` 在 Spring Cloud 2021 下已属冗余。

## 模块目的

为基于 Spring Cloud Alibaba 的微服务提供「一行依赖即接入 Nacos 注册发现 + 配置中心」的自动装载入口，屏蔽 `@EnableDiscoveryClient` 手动注解，并附带 sample `bootstrap-nacos.yaml` 作为接入范本；与同组 eureka/consul 注册中心件并列，供宿主按需择一。

## 模块功能

- 双通道登记 1 个自动配置类：`META-INF/spring.factories`（`EnableAutoConfiguration`）+ `META-INF/spring/...AutoConfiguration.imports`，内容一致，均指向 `NacosAutoConfiguration`。
- `NacosAutoConfiguration`：`@Configuration` + `@ConditionalOnExpression("${i2f.springcloud.nacos.enable:true}")` + `@ConfigurationProperties(prefix="i2f.springcloud.nacos")` + `@EnableDiscoveryClient` + `@Data`/`@NoArgsConstructor`/`@Slf4j`，`implements InitializingBean` 仅在 `afterPropertiesSet()` 打印 `"NacosConfig config done."`；**无任何字段、无 `@Bean`**。
- 提供 sample 配置范本：`application-nacos.properties`（仅 `enable`）、`bootstrap-nacos.sample.yaml`（discovery+config 双段、共享配置、命名空间）、`bootstrap-nacos.yaml`（含 `extension-configs`/`shared-configs`/`weight`/优先级说明等详尽注释的完整范例）。
- pom 内注释说明「在 cloud-alibaba 中用 loadbalancer 需从 discovery 排除默认 ribbon，或配 `spring.cloud.loadbalancer.ribbon.enabled=false`」——但该 `<exclusions>` 被整段注释、未实际生效。

## 模块主要使用方法

1. 引入本 Starter（因 provided+optional 不传递，仍需自行补齐 `spring-cloud-starter-alibaba-nacos-discovery` / `-config`）。
2. 在 `bootstrap.yaml`（非 application）配置 `spring.cloud.nacos.discovery.server-addr`、`config.server-addr`、命名空间、分组、`file-extension`、`shared-configs`/`extension-configs` 等（可直接参考本模块 sample）。
3. 服务启动后自动向 Nacos 注册并拉取远程配置——**主要由 nacos starter 自身自动配置驱动**，`i2f.springcloud.nacos.enable` 门控的是本模块的 `@EnableDiscoveryClient` 与日志行。

## 模块特性总结

- 本组「注册中心」子域核心接入件之一，风格延续「放 classpath + 单布尔开关自动装载 + 双通道登记 + sample 范本齐备」。
- 相较 actuator 家族的两个空壳类，本类至少承载 `@EnableDiscoveryClient`；且 nacos 版本经 BOM 统一治理，无硬编码错配，是本组中封装相对规范的一个。
- sample 资料翔实（三份、含大量中文注释与配置优先级说明），接入指导价值高于代码本身。

## 模块瑕疵或错误（实证）

1. **【中危·开关约束有限】** `@ConditionalOnExpression("${i2f.springcloud.nacos.enable:true}")` 以 SpEL 门控本类，但真正的 nacos 注册/配置拉取由 `spring-cloud-starter-alibaba-nacos-*` 自身自动配置驱动（读取 `spring.cloud.nacos.*`）。故将 `enable` 设为 `false` 只移除本类的 `@EnableDiscoveryClient` 与一行日志，**并不能阻止** nacos 客户端注册与配置拉取——语义与「一键关闭 nacos」的直觉不符。应改用 `@ConditionalOnProperty` 且明确其只管本类附加行为。
2. **【冗余·`@EnableDiscoveryClient` 已非必需】** 本模块经 BOM 归属 Spring Cloud 2021.0.x，此版本 nacos-discovery 默认开启自动服务注册，`@EnableDiscoveryClient` 注解已无实际作用；本模块 sample `bootstrap-nacos.yaml` 注释亦自陈「旧版本需要添加 @EnableDiscoveryClient，现在新版本可以不用添加了」（[bootstrap-nacos.yaml L25-26](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/i2f-springcloud-alibaba-nacos-starter/src/main/resources/sample/bootstrap-nacos.yaml#L25)），代码与自身文档相矛盾。
3. **【一致性·loadbalancer 依赖 scope 不统一】** `spring-cloud-starter-loadbalancer` 为 `provided` 但**未标 `optional`**（其余 nacos/boot 依赖均 optional），且无任何代码引用它；其 pom 注释建议「用 loadbalancer 需排除 ribbon」，但对应 `<exclusions>` 整段被注释、未生效——依赖引入了却没配套排除，说明与实际装配脱节。
4. **`@ConfigurationProperties` 空挂**：注解加在无字段类上，`prefix` 无可绑定属性；`enable` 实由 `@ConditionalOnExpression` 的 SpEL 直读，非经字段绑定。
5. **`@Data`/`@NoArgsConstructor`/`@Slf4j` 装饰、`InitializingBean` 仅日志**：`afterPropertiesSet() throws Exception` 声明的受检异常从不抛出、方法体仅一行 log，价值单薄。
6. **provided + optional 不传递**：nacos-discovery/config 均 provided 且 optional，不随本 Starter 传递给使用方，使用方必须自行补齐才能生效——这虽便于按需择取 discovery/config，但也意味着本 Starter 本身「不带任何 nacos 能力」，封装增益主要落在 `@EnableDiscoveryClient` 便捷注解与 sample 文档上。
7. **元数据 `hints` 为死条目**：`additional-spring-configuration-metadata.json` 的 `hints` 是 `server.servlet.jsp.class-name`、`server.tomcat.accesslog.encoding` 两条与本模块无关的跨模块拷贝残留；`properties` 仅登记 `enable` 一项，真正需要提示的 `spring.cloud.nacos.*` 均未涉及。
8. **双通道登记过时冗余**：`spring.factories` 与 `AutoConfiguration.imports` 对同一单类重复登记（Boot 2.7 推荐仅用后者）。
9. **生态孤岛**：全仓除自身 pom、父 pom `<module>` 登记（[i2f-springcloud/pom.xml L18](file:///C:/home/dev/java/dev-center/i2f-turbo-java/i2f-springcloud/pom.xml#L18)）、根 pom DM 登记（[pom.xml L1522](file:///C:/home/dev/java/dev-center/i2f-turbo-java/pom.xml#L1522)）及 wiki 清单外，**无任何模块 compile/test 依赖本 Starter**，亦无样例工程/测试验证。

## 生态位置

处于 i2f-springcloud 组「注册中心 / 配置中心」子域，与 `netflix-eureka-*`、`consul`、`discovery-*` 等注册发现件并列，是接入 Spring Cloud Alibaba Nacos 生态的封装入口；配套的 `spring-cloud-starter-loadbalancer` 亦呼应同组 `loadbalancer-starter`。因全仓无消费方，暂属**生态孤岛**。整体封装质量在本组「薄壳 Starter」族群中相对较好（版本经 BOM 治理、附详尽 sample），主要问题集中在 `enable` 开关语义有限与 `@EnableDiscoveryClient`/loadbalancer 排除等「时代遗留」冗余上。
