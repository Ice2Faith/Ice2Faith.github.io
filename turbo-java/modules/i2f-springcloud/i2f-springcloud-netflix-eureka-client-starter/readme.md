# i2f-springcloud-netflix-eureka-client-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-netflix-eureka-client-starter`

## 模块概述

Spring Cloud 组中面向 **Netflix Eureka 服务注册客户端** 的「装配 Starter」（本组第 14 个建档模块，**仅 1 个 Java 源文件（25 行）+ 5 个资源文件**，无任何 i2f 内部 compile 依赖）。

与同组 `loadbalancer-starter`（类体完全空、仅 log）类似，`EurekaClientAutoConfiguration` 类体**零字段零方法**，但携带 `@EnableEurekaClient` 注解——该注解是 Spring Cloud Netflix 的元注解，import 官方 `EurekaClientAutoConfiguration`（同名不同包），使本件具备真实功能：**通过 `i2f.springcloud.eureka-client.enable` 布尔门统一控制是否启用 Eureka 客户端注册**。

模块把 `spring-cloud-starter-netflix-eureka-client` 作为 `provided`（**未标 optional**）依赖引入，版本由根 pom `spring-cloud-dependencies:2021.0.8` BOM 治理。

## 模块依赖

| 依赖 | scope | 说明 |
|---|---|---|
| `lombok` | compile | 编译期注解 |
| `spring-boot-starter` | provided, optional | 基础 Boot 环境 |
| `spring-boot-configuration-processor` | provided, optional | 元数据生成（本件无实际绑定字段，形同虚设） |
| `spring-cloud-starter-netflix-eureka-client` | provided | Eureka 客户端全家桶；**未标 optional → 不传递** |

## 模块设计

```mermaid
graph LR
    A[应用 pom 引入本 starter] -->|provided 不传递| B[EurekaClientAutoConfiguration 自动装配]
    B -->|@ConditionalOnExpression enable:true| C{@EnableEurekaClient}
    C -->|import| D[官方 EurekaClientAutoConfiguration<br/>spring-cloud-netflix-eureka-client]
    D --> E[实例注册 / 心跳 / 拉取注册表]
    B -.->|@ConfigurationProperties 零字段| F[无任何属性绑定]
```

## 模块目的

以 i2f 统一命名空间前缀 `i2f.springcloud.eureka-client.enable` 控制 Eureka 客户端启停，免去使用方在 Main 类手动标注 `@EnableEurekaClient`，使多服务切换注册中心时仅需改一行配置。

## 模块功能

- `@EnableEurekaClient`：触发官方 Eureka 客户端自动配置（注册/发现/心跳）。
- `@ConditionalOnExpression("${i2f.springcloud.eureka-client.enable:true}")`：布尔门，设 false 可阻止本自动配置类装配，但 **Eureka 客户端仍可使用官方 `@EnableEurekaClient` 或 `spring.cloud.discovery.enabled` 控制**。

## 模块主要使用方法

1. 在应用 pom 中引入本 starter **并自行引入**官方 `spring-cloud-starter-netflix-eureka-client`（本件 provided 不传递）。
2. 配置 bootstrap.properties：

```properties
# 本件开关
i2f.springcloud.eureka-client.enable=true
# 官方 Eureka 配置（参照 sample/bootstrap-eureka-client.properties）
eureka.client.service-url.defaultZone=http://localhost:9999/eureka/
```

## 模块特性总结

- **有效功能仅为一个注解代理**：`@EnableEurekaClient` 提供「自动注册 + 布尔门关闭能力」，相比 loadbalancer-starter 的完全空壳略有实质差异。
- 自动配置类带 `@Configuration`（非 lite 模式），跨 @Bean 代理不受影响（本件无 @Bean 故无实际风险）。
- 全仓零消费方，属纯孤岛。

## 模块瑕疵或错误（实证）

1. **provided 非 optional + 无 @ConditionalOnClass → 缺 classpath 即启动崩溃**：类级注解 `@EnableEurekaClient` 引用 `org.springframework.cloud.netflix.eureka.EnableEurekaClient`，若使用方未引官方 `spring-cloud-starter-netflix-eureka-client`，自动配置类装载即 `NoClassDefFoundError`。同组 gateway-starter/actuator-admin/config-server/consul 族。**（高危）**
2. **@ConfigurationProperties 挂零字段类**：前缀 `i2f.springcloud.eureka-client` 绑到一个无任何字段的类上，`@Data`/`@NoArgsConstructor` 生成无意义方法；唯一属性 `enable` 实际由 `@ConditionalOnExpression` 的 SpEL 直读、并非绑定字段——与 loadbalancer-starter 同病。
3. **布尔门语义与官方重叠**：`@ConditionalOnExpression("${...enable:true}")` 与 Spring Cloud 原生 `spring.cloud.discovery.enabled` / `eureka.client.enabled` 功能重叠，多一个"假开关"——真正关闭注册只需官方属性，本件不添加任何增值逻辑。
4. **sample 键非规范拼写**：`bootstrap-eureka-client.properties` L5 写 `eureka.instance.instance_id`（下划线），Spring Boot relaxed binding 虽可识别但非 canonical kebab-case 形式（`instance-id`），易误导复制者。
5. **双通道登记冗余**：`spring.factories` + `AutoConfiguration.imports` 均登记 `EurekaClientAutoConfiguration`——Boot 2.7 后仅读 imports，spring.factories 条目为过时遗留。
6. **元数据死 hints**：`additional-spring-configuration-metadata.json` 的 hints 段为 `server.servlet.jsp.class-name` / `server.tomcat.accesslog.encoding`，与本件毫无关联（全组通用拷贝死条目）。
7. **configuration-processor 形同虚设**：本件无 `@ConfigurationProperties` 绑定字段，processor 不会产出任何额外描述——依赖引入纯属冗余。

## 生态位置

- **groupId**: `i2f.turbo`
- **artifactId**: `i2f-springcloud-netflix-eureka-client-starter`
- **版本**: `1.0-jdk8`
- **父模块**: `i2f-springcloud`（L29）
- **根 pom DM**: L1577
- **消费方**: 全仓**零引用**（纯孤岛）
- **对应官方件**: `spring-cloud-starter-netflix-eureka-client`（Spring Cloud 2021.0.8）
- **组内关系**: 与 `i2f-springcloud-netflix-eureka-server-starter` 为 client/server 对，`discovery-server-starter` 为其高阶封装；本件定位为最低级别的 Eureka 客户端「布尔门代理」。
