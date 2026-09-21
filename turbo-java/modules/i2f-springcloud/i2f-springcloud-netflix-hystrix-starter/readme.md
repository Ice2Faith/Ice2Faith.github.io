# i2f-springcloud-netflix-hystrix-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-netflix-hystrix-starter`

## 模块概述

Spring Cloud 组中面向 **Netflix Hystrix（熔断降级）** 的「装配 Starter」（本组第 16 个建档模块，**仅 1 个 Java 源文件（29 行）+ 4 个资源文件**，无任何 i2f 内部 compile 依赖）。

`HystrixAutoConfiguration` 类体零字段，唯一功能由类级 `@EnableHystrix` 注解提供——触发 Spring Cloud Netflix Hystrix 断路器自动配置，再由 `InitializingBean.afterPropertiesSet()` 打一行日志。与同组 eureka-client/server 的纯空壳不同，本件多了一个 `implements InitializingBean`，但行为仍仅为 `log.info`。

**本件是本组乃至全仓唯一在模块级自行声明 `<dependencyManagement>` 覆盖根 pom 版本治理的异常件**：硬钉 `spring-boot:2.3.7.RELEASE` / `spring-cloud:Hoxton.SR12`，与根 pom 的 `2.7.18` / `2021.0.8` 严重背离。Hystrix 自 Spring Cloud 2020.0（Ilford）起已被官方移除，根 BOM 不含该 artifact，模块被迫自引旧 BOM 使 `spring-cloud-starter-netflix-hystrix` 可解析。

## 模块依赖

| 依赖 | scope | 说明 |
|---|---|---|
| `lombok` | compile | 编译期注解 |
| `spring-boot-starter` | provided, optional | 基础 Boot 环境（版本由**本模块自引 2.3.7 BOM** 管理，非根 2.7.18） |
| `spring-boot-configuration-processor` | provided, optional | 元数据生成（无实际绑定字段，形同虚设） |
| `spring-cloud-starter-netflix-hystrix` | provided | Hystrix 全家桶；**未标 optional → 不传递**；根 BOM 不含此件，须本模块自引 Hoxton BOM |

### 版本治理异常

```xml
<project>
  <!-- 模块级覆盖（L15-41），本组唯一 -->
  <properties>
      <spring.version>5.2.12.RELEASE</spring.version>
      <spring-boot.version>2.3.7.RELEASE</spring-boot.version>
      <spring-cloud.version>Hoxton.SR12</spring-cloud.version>
  </properties>
  <dependencyManagement>
      <!-- 导入 Boot 2.3.7 + Cloud Hoxton.SR12 BOM -->
  </dependencyManagement>
</project>
```

根 pom：`spring-boot:2.7.18` / `spring-cloud:2021.0.8`。

## 模块设计

```mermaid
graph LR
    A[应用 pom 引入本 starter] -->|provided 不传递| B[HystrixAutoConfiguration]
    B -->|@ConditionalOnExpression enable:true| C{@EnableHystrix}
    C -->|import| D[官方 HystrixCircuitBreakerConfiguration<br/>spring-cloud-netflix-hystrix]
    D --> E[断路器 / 线程池隔离 / 降级回退]
    B -->|implements InitializingBean| F[afterPropertiesSet → log.info 仅一行]
    B -.->|@ConfigurationProperties 零字段| G[无任何属性绑定]
```

## 模块目的

以 i2f 统一命名空间前缀 `i2f.springcloud.hystrix.enable` 控制 Hystrix 断路器启停，免去使用方在 Main 类手动标注 `@EnableHystrix`。sample 配合 `feign.hystrix.enabled=true` 暗示与 OpenFeign 的联合使用场景。

## 模块功能

- `@EnableHystrix`：等价于 `@EnableCircuitBreaker` + HystrixDashboard 依赖导入，激活全局断路器代理。
- `InitializingBean.afterPropertiesSet()`：打印 `"HystrixConfig config done."`（纯装饰，无逻辑）。
- `@ConditionalOnExpression("${i2f.springcloud.hystrix.enable:true}")`：布尔门，设 false 可阻止本类装配。

## 模块主要使用方法

1. 在应用 pom 中引入本 starter **并自行引入** `spring-cloud-starter-netflix-hystrix`（provided 不传递）。
2. **必须使用 Hoxton.SR12 或更早 Spring Cloud 版本**（2021.0.8 已无 Hystrix），或手动引入 `spring-cloud-netflix-hystrix` 兼容层。
3. 配置：

```properties
i2f.springcloud.hystrix.enable=true
# 配合 OpenFeign 使用
feign.hystrix.enabled=true
```

## 模块特性总结

- **本组唯一版本时间胶囊**：锁死在 Hoxton.SR12（2021年3月），与项目主版本（2021.0.8）不兼容。
- Hystrix 官方已于 2018 年进入维护模式、2020 年起被 Spring Cloud 移除，推荐迁移至 Resilience4j / Sentinel。本组 `alibaba-sentinel-starter` 是替代方案。
- 全仓零消费方，属纯孤岛——但也说明尚无应用因版本冲突而受害。
- `spring.version=5.2.12.RELEASE` 属性声明后未使用（Boot BOM 管理 Spring 版本）。

## 模块瑕疵或错误（实证）

1. **模块级 BOM 覆盖根版本治理（架构级危险）**：`<dependencyManagement>` 导入 Spring Boot 2.3.7 + Spring Cloud Hoxton.SR12，与根 pom 2.7.18/2021.0.8 背离 2 个大版本。若本件被消费，其传递依赖链（虽然 provided 不传递编译期版本）在**运行时**可能与主应用类路径中已存在的 Boot 2.7 类冲突。**（高危·架构级）**
2. **引用已移除的 Spring Cloud 组件**：`spring-cloud-starter-netflix-hystrix` 不存在于 `spring-cloud-dependencies:2021.0.8` BOM 中。本件通过自引旧 BOM 绕过，但意味着**此模块与项目声明的 Spring Cloud 主版本互不兼容**——升级 Spring Cloud 即丢失依赖解析能力。
3. **provided 非 optional + 无 @ConditionalOnClass → 缺 classpath 即启动崩溃**：类级注解 `@EnableHystrix` 引用 `org.springframework.cloud.netflix.hystrix.EnableHystrix`，若使用方缺该 jar，自动配置类装载即 `NoClassDefFoundError`。同 gateway/actuator-admin/config-server/consul/eureka-client/server 族。**（高危）**
4. **@ConfigurationProperties 挂零字段类**：前缀 `i2f.springcloud.hystrix` 绑到无任何字段的类上，唯一属性 `enable` 由 SpEL 直读非绑定。与 eureka-client/server/loadbalancer 同病。
5. **spring.version 死属性**：L16 `<spring.version>5.2.12.RELEASE</spring.version>` 声明后从未被引用——Spring Boot BOM 内部已管理 Spring Framework 版本，本属性纯冗余。
6. **sample 耦合已废弃 OpenFeign-Hystrix 联动**：`feign.hystrix.enabled=true` 是 Hoxton 时代的配置键，Spring Cloud 2021.0+ 中 Feign 集成改为 Resilience4j（`spring.cloud.openfeign.circuitbreaker.enabled=true`），照搬 sample 对当前主版本无效。
7. **双通道登记冗余**：`spring.factories` + `AutoConfiguration.imports`——Boot 2.7 后 spring.factories 条目过时。
8. **元数据死 hints**：`server.servlet.jsp.class-name` / `server.tomcat.accesslog.encoding`（全组通用拷贝死条目）。
9. **configuration-processor 形同虚设**：无绑定字段，不产出描述。

## 生态位置

- **groupId**: `i2f.turbo`
- **artifactId**: `i2f-springcloud-netflix-hystrix-starter`
- **版本**: `1.0-jdk8`
- **父模块**: `i2f-springcloud`（L31）
- **根 pom DM**: L1587
- **消费方**: 全仓**零引用**（纯孤岛）
- **对应官方件**: `spring-cloud-starter-netflix-hystrix`（仅存在于 Hoxton.SR12 及更早版本）
- **组内关系**: 与 `i2f-springcloud-netflix-openfeign-starter` 有功能耦合（sample 中 `feign.hystrix.enabled`）；`i2f-springcloud-alibaba-sentinel-starter` 是其在 Spring Cloud 2021.0.8 体系下的**官方推荐替代**。
- **迁移建议**: Hystrix 已 EOL，应迁移至 Sentinel（本组已有）或 Resilience4j。
