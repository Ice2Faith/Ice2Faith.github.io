# i2f-springcloud-netflix-eureka-server-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-netflix-eureka-server-starter`

## 模块概述

Spring Cloud 组中面向 **Netflix Eureka 注册中心服务端** 的「装配 Starter」（本组第 15 个建档模块，**仅 1 个 Java 源文件（25 行）+ 4 个资源文件**，无任何 i2f 内部 compile 依赖）。

与 `netflix-eureka-client-starter` 为**完全对称的 client/server 对**：`EurekaServerAutoConfiguration` 类体零字段零方法，唯一实质功能是类级 `@EnableEurekaServer` 注解——触发 Spring Cloud Netflix 的 Eureka Server 自动配置（内嵌注册中心管理界面、注册表、驱逐线程等）。通过 `i2f.springcloud.eureka-server.enable` 布尔门统一控制是否启用。

模块把 `spring-cloud-starter-netflix-eureka-server` 作为 `provided`（**未标 optional**）依赖引入，版本由根 pom `spring-cloud-dependencies:2021.0.8` BOM 治理。

## 模块依赖

| 依赖 | scope | 说明 |
|---|---|---|
| `lombok` | compile | 编译期注解 |
| `spring-boot-starter` | provided, optional | 基础 Boot 环境 |
| `spring-boot-configuration-processor` | provided, optional | 元数据生成（本件无实际绑定字段，形同虚设） |
| `spring-cloud-starter-netflix-eureka-server` | provided | Eureka 服务端全家桶；**未标 optional → 不传递** |

## 模块设计

```mermaid
graph LR
    A[应用 pom 引入本 starter] -->|provided 不传递| B[EurekaServerAutoConfiguration 自动装配]
    B -->|@ConditionalOnExpression enable:true| C{@EnableEurekaServer}
    C -->|import| D[官方 EurekaServerAutoConfiguration<br/>spring-cloud-netflix-eureka-server]
    D --> E[注册中心管理面板 / 注册表 / 驱逐线程]
    B -.->|@ConfigurationProperties 零字段| F[无任何属性绑定]
```

## 模块目的

以 i2f 统一命名空间前缀 `i2f.springcloud.eureka-server.enable` 控制 Eureka Server 启停，免去使用方在 Main 类手动标注 `@EnableEurekaServer`，使 Eureka 注册中心应用的启动类保持纯净（仅 `@SpringBootApplication`）。

## 模块功能

- `@EnableEurekaServer`：触发官方 Eureka Server 自动配置（管理面板 / 注册表维护 / 实例驱逐）。
- `@ConditionalOnExpression("${i2f.springcloud.eureka-server.enable:true}")`：布尔门，设 false 可阻止本自动配置类装配，但**若使用方 Main 类仍标有 `@EnableEurekaServer`，Server 不受本门控制照常启动**——静默失效风险。

## 模块主要使用方法

1. 在 Eureka Server 应用 pom 中引入本 starter **并自行引入**官方 `spring-cloud-starter-netflix-eureka-server`（本件 provided 不传递）。
2. 配置 application.properties（参照 sample）：

```properties
# 本件开关
i2f.springcloud.eureka-server.enable=true
# Eureka Server 标准配置
server.port=9999
eureka.instance.hostname=localhost
eureka.server.enable-self-preservation=false
eureka.client.register-with-eureka=false
eureka.client.fetch-registry=false
```

## 模块特性总结

- **与 netflix-eureka-client-starter 完全镜像对称**：同作者、同日创建（2022/6/12 20:37）、同结构、同注解组合，仅 `@EnableEurekaClient` → `@EnableEurekaServer` 与包名/前缀差异。
- 自动配置类带 `@Configuration`（非 lite 模式），本件无 @Bean 故无代理风险。
- 全仓零消费方，属纯孤岛。
- sample 包含完整的 Eureka Server 独立部署推荐配置（关闭自注册 + 关闭自保存 + 驱逐间隔 5s），具有实际参考价值。

## 模块瑕疵或错误（实证）

1. **provided 非 optional + 无 @ConditionalOnClass → 缺 classpath 即启动崩溃**：类级注解 `@EnableEurekaServer` 引用 `org.springframework.cloud.netflix.eureka.server.EnableEurekaServer`，若使用方未引官方 `spring-cloud-starter-netflix-eureka-server`，自动配置类装载即 `NoClassDefFoundError`。同 gateway-starter/actuator-admin/config-server/consul/eureka-client 族。**（高危）**
2. **@ConfigurationProperties 挂零字段类**：前缀 `i2f.springcloud.eureka-server` 绑到无任何字段的类上，`@Data`/`@NoArgsConstructor` 生成无意义方法；唯一属性 `enable` 由 `@ConditionalOnExpression` SpEL 直读、并非绑定字段。与 eureka-client/loadbalancer 同病。
3. **布尔门可被 Main 类注解静默绕过**：`@ConditionalOnExpression` 仅控制本自动配置类是否装配；若使用方 Main 类仍直接标注 `@EnableEurekaServer`（Spring Cloud 文档推荐做法），设 `enable=false` 无法阻止 Server 启动——**开关假象**。
4. **sample 分隔符不一致**：L13 `eureka.server.eviction-interval-timer-in-ms:5000` 使用冒号作分隔符，其余行均用等号 `=`。Java Properties 规范允许两者等价，但同一文件混用违反一致性、易引起误读（被误判为 YAML 语法）。
5. **双通道登记冗余**：`spring.factories` + `AutoConfiguration.imports` 均登记——Boot 2.7 后仅读 imports，spring.factories 条目为过时遗留。
6. **元数据死 hints**：hints 段为 `server.servlet.jsp.class-name` / `server.tomcat.accesslog.encoding`，与本件毫无关联（全组通用拷贝死条目）。
7. **configuration-processor 形同虚设**：本件无 `@ConfigurationProperties` 绑定字段，processor 不产出任何额外描述。

## 生态位置

- **groupId**: `i2f.turbo`
- **artifactId**: `i2f-springcloud-netflix-eureka-server-starter`
- **版本**: `1.0-jdk8`
- **父模块**: `i2f-springcloud`（L30）
- **根 pom DM**: L1582
- **消费方**: 全仓**零引用**（纯孤岛）
- **对应官方件**: `spring-cloud-starter-netflix-eureka-server`（Spring Cloud 2021.0.8）
- **组内关系**: 与 `i2f-springcloud-netflix-eureka-client-starter` 为 client/server 镜像对；`discovery-server-starter`（本组第 9 个建档模块）是更高层的通用服务发现服务端封装，可代理本件功能。
