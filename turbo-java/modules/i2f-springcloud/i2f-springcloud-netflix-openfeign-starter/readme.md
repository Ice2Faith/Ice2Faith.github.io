# i2f-springcloud-netflix-openfeign-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-netflix-openfeign-starter`

## 模块概述

Spring Cloud 组中面向 **Spring Cloud OpenFeign（声明式 HTTP 客户端）** 的「装配 Starter」（本组第 17 个建档模块，**仅 1 个 Java 源文件（29 行）+ 4 个资源文件**，无任何 i2f 内部 compile 依赖）。

`FeignAutoConfiguration` 类体零字段，唯一功能由类级 `@EnableFeignClients` 注解提供——触发 Spring Cloud OpenFeign 的 `FeignClientsRegistrar`，自动扫描 `@FeignClient` 接口并注册声明式 HTTP 代理 Bean。`InitializingBean.afterPropertiesSet()` 仅打一行日志。通过 `i2f.springcloud.feign.enable` 布尔门统一控制是否启用。

**注意**：模块 artifactId/包名含 "netflix" 为 Hoxton 时代历史遗留命名——`spring-cloud-starter-openfeign` 实际由 Spring Cloud 项目维护，非 Netflix 组件，2021.0.8 版本仍活跃维护。本件不存在 Hystrix 件的 BOM 覆盖问题。

## 模块依赖

| 依赖 | scope | 说明 |
|---|---|---|
| `lombok` | compile | 编译期注解 |
| `spring-boot-starter` | provided, optional | 基础 Boot 环境 |
| `spring-boot-configuration-processor` | provided, optional | 元数据生成（无实际绑定字段，形同虚设） |
| `spring-cloud-starter-openfeign` | provided | OpenFeign 全家桶；**未标 optional → 不传递** |

## 模块设计

```mermaid
graph LR
    A[应用 pom 引入本 starter] -->|provided 不传递| B[FeignAutoConfiguration]
    B -->|@ConditionalOnExpression enable:true| C{@EnableFeignClients}
    C -->|imports| D[FeignClientsRegistrar]
    D -->|fallback AutoConfigurationPackages| E[扫描应用包下 @FeignClient 接口]
    E --> F[注册声明式 HTTP 代理 Bean]
    B -->|implements InitializingBean| G[afterPropertiesSet → log.info 仅一行]
    B -.->|@ConfigurationProperties 零字段| H[无任何属性绑定]
```

## 模块目的

以 i2f 统一命名空间前缀 `i2f.springcloud.feign.enable` 控制 OpenFeign 声明式 HTTP 客户端的启停，免去使用方在 Main 类手动标注 `@EnableFeignClients`。

## 模块功能

- `@EnableFeignClients`：激活 `FeignClientsRegistrar`，扫描 `@FeignClient` 接口并注册为可注入的 HTTP 代理。basePackages 未指定时 fallback 至 `AutoConfigurationPackages`（即 `@SpringBootApplication` 所在包树）。
- `InitializingBean.afterPropertiesSet()`：打印 `"FeignConfig config done."`（纯装饰）。
- `@ConditionalOnExpression("${i2f.springcloud.feign.enable:true}")`：布尔门（**默认 true = 全量开启 Feign 扫描**）。

## 模块主要使用方法

1. 在应用 pom 中引入本 starter **并自行引入**官方 `spring-cloud-starter-openfeign`（provided 不传递）。
2. 在应用包下声明 `@FeignClient` 接口。
3. 配置：

```properties
i2f.springcloud.feign.enable=true
```

## 模块特性总结

- **本组声明式 HTTP 调用核心件**，功能上比 eureka-client/server/hystrix 等纯注解代理件更"重"——`@EnableFeignClients` 会触发真实类路径扫描。
- 模块名中 "netflix" 为 Hoxton 历史分组遗留（Feign 非 Netflix 组件），artifact 路径 `org.springframework.cloud:spring-cloud-starter-openfeign` 证实归属 Spring Cloud 项目。
- sample 最丰富（42 行），含日志级别/OkHttp/Hystrix 联动/Ribbon 超时/契约配置/拦截器等教学注释。
- 全仓零消费方，属纯孤岛。

## 模块瑕疵或错误（实证）

1. **provided 非 optional + 无 @ConditionalOnClass → 缺 classpath 即启动崩溃**：类级注解 `@EnableFeignClients` 引用 `org.springframework.cloud.openfeign.EnableFeignClients`，若使用方缺 `spring-cloud-starter-openfeign`，自动配置类装载即 `NoClassDefFoundError`。同 gateway/actuator-admin/config-server/consul/eureka/hystrix 族。**（高危）**
2. **默认开启（enable:true）全局 Feign 扫描的隐患**：布尔门默认 true，只要本 starter 在 classpath 即自动激活 `@EnableFeignClients` 全量扫描——若应用根本不使用 Feign，仍会无谓执行类路径扫描，且 `FeignClientsRegistrar` 可能注册冲突 Bean。对比官方设计：Spring Cloud 推荐用户主动在 Main 类标注 `@EnableFeignClients`（显式优于隐式）。
3. **sample 含大量 Hoxton 废弃键**：L12 `feign.hystrix.enabled=true`、L14 `hystrix.command...`（Hystrix 2021.0.8 已移除）、L16-18 Ribbon 超时注释（Ribbon 2021.0.8 已弃用改用 LoadBalancer）。照搬 sample 在当前主版本下无效甚至引起冲突。**（与 hystrix-starter sample 同病）**
4. **@ConfigurationProperties 挂零字段类**：前缀 `i2f.springcloud.feign` 绑到无任何字段的类上，唯一属性 `enable` 由 SpEL 直读非绑定。与 eureka/loadbalancer/hystrix 同病。
5. **模块名/包名 "netflix" 误导**：`i2f.springcloud.netflix.openfeign` 包名及 artifactId 中的 "netflix" 均不准确——OpenFeign 自始不属于 Netflix，而是 Spring Cloud 独立子项目（2021.0.8 仍活跃维护），易误导为 EOL 组件。
6. **双通道登记冗余**：`spring.factories` + `AutoConfiguration.imports`——Boot 2.7 后 spring.factories 过时。
7. **元数据死 hints**：`server.servlet.jsp.class-name` / `server.tomcat.accesslog.encoding`（全组通用拷贝死条目）。
8. **configuration-processor 形同虚设**：无绑定字段。

## 生态位置

- **groupId**: `i2f.turbo`
- **artifactId**: `i2f-springcloud-netflix-openfeign-starter`
- **版本**: `1.0-jdk8`
- **父模块**: `i2f-springcloud`（L32）
- **根 pom DM**: L1592
- **消费方**: 全仓**零引用**（纯孤岛）
- **对应官方件**: `spring-cloud-starter-openfeign`（Spring Cloud 2021.0.8，**活跃维护**）
- **组内关系**: 与 `netflix-hystrix-starter`（sample 中 `feign.hystrix.enabled` 暗示联动）功能耦合；`netflix-ribbon-starter`/`loadbalancer-starter` 为 Feign 的底层负载均衡依赖；`alibaba-sentinel-starter` 可替代 Hystrix 作为 Feign 的熔断层。
- **本组定位**: 声明式 HTTP 服务调用的入口件，在本组 Netflix 三件套（hystrix/openfeign/ribbon）中是唯一仍被 Spring Cloud 官方积极维护的组件。
