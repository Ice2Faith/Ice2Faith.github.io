# i2f-springcloud-actuator-admin-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-actuator-admin-starter`

## 模块概述

Spring Cloud 组中一个**极薄的第三方能力封装 Starter**：它的全部作用是把 [codecentric 的 Spring Boot Admin Server](https://github.com/codecentric/spring-boot-admin)（`de.codecentric:spring-boot-admin-starter-server`）通过一个空的 `@Configuration` + `@EnableAdminServer` 类，改造成「放入 classpath 即自动装载、可用单一布尔开关关闭」的自动配置，从而在无需手写启动类注解的情况下拉起 **Spring Boot Admin 图形化监控台**（集中查看已注册微服务的健康、环境、指标、日志级别、线程转储等 Actuator 端点）。全模块仅 **1 个 Java 源文件 + 3 个资源文件**，**不含任何 i2f 内部 compile 依赖**，是 i2f-springcloud 组里对外部中间件「即插即用」风格的典型代表，本身不产出业务逻辑，仅承担自动装配与条件化开关。

## 模块依赖

| 依赖 | 类型 | 作用 |
| --- | --- | --- |
| `org.projectlombok:lombok` | compile | 为 `ActuatorServerAutoConfiguration` 生成 `@Data`/`@NoArgsConstructor`（本类无字段，实际产出为空构造与占位 getter/setter） |
| `org.springframework.boot:spring-boot-starter` | provided + optional | 提供自动配置、`@ConditionalOnExpression`、`@ConfigurationProperties` 等注解与运行底座 |
| `org.springframework.boot:spring-boot-configuration-processor` | provided + optional | 编译期生成配置元数据（本模块另附手写 `additional-spring-configuration-metadata.json`） |
| `de.codecentric:spring-boot-admin-starter-server:2.2.3` | provided（**未标 optional**） | Spring Boot Admin 服务端，`@EnableAdminServer` 真正引入的能力来源 |

> 说明：本模块 **无 i2f 内部 compile 依赖**，是纯第三方 Starter 封装；与同组其它 starter 一样从父 `i2f-springcloud` → 根 `i2f-turbo-java`（Spring Boot BOM `2.7.18`）继承版本管理。

## 模块设计

```mermaid
flowchart TD
    A[spring.factories / AutoConfiguration.imports] -->|登记自动配置| B[ActuatorServerAutoConfiguration]
    B --> C{&quot;i2f.springcloud.actuator-server.enable<br/>(默认 true)&quot;}
    C -->|true 命中| D[&quot;@Configuration + @EnableAdminServer&quot;]
    C -->|false| E[整个配置类不装载]
    D -->|@Import AdminServerConfiguration| F[de.codecentric Spring Boot Admin Server]
    F --> G[图形监控台：健康/环境/指标/日志级别/线程等]
    H[additional-spring-configuration-metadata.json] -.仅登记 1 项 enable.-> C
```

## 模块目的

- 让「搭建一个 Spring Boot Admin 监控中心」这件事从「自定义启动类 + 加 `@EnableAdminServer` + 引依赖」简化为「引入本 Starter 即自动开启」，并统一收归到 `i2f.springcloud.actuator-server.*` 命名空间下管理。
- 为微服务集群提供一个集中式的运行期可视化/运维入口（配合同组 `i2f-springcloud-actuator-starter` 暴露各服务端的 Actuator 端点）。

## 模块功能

- **自动装载 Admin Server**：`ActuatorServerAutoConfiguration` 被登记进 `EnableAutoConfiguration`（`spring.factories` 与 `AutoConfiguration.imports` 双通道），命中条件后由 `@EnableAdminServer` 拉起 Spring Boot Admin 服务端全部组件（UI、注册、实例视图等由 codecentric 自管）。
- **单一开关**：`@ConditionalOnExpression("${i2f.springcloud.actuator-server.enable:true}")` 提供布尔开关，默认 `true`（放入 classpath 即生效，可显式设 `false` 关闭）。
- **配置样例**：`sample/application-actuator-server.properties` 给出端口 `11024`、应用名 `actuator-server`、开关 `true` 的最小可用配置。

## 模块主要使用方法

1. 在监控中心服务的 `pom.xml` 引入本 Starter；因 `spring-boot-admin-starter-server` 为 `provided` 且**非 optional**（provided 不具传递性），使用方需**自行显式引入** `de.codecentric:spring-boot-admin-starter-server` 才能补齐运行期类。
2. 配置（properties）：

   ```properties
   # 开关，默认 true，可省略
   i2f.springcloud.actuator-server.enable=true
   # Admin 控制台端口与应用名
   server.port=11024
   spring.application.name=actuator-server
   ```

3. 正常启动 Spring Boot 应用后，本 Starter 即自动完成 `@EnableAdminServer`，访问 `http://<host>:11024/` 进入 Admin 图形界面；各业务微服务通过 client 侧依赖注册上来即可被监控。

## 模块特性总结

- **零 i2f 内部依赖**：纯粹把第三方 Spring Boot Admin Server 包装成自动配置，耦合面极小。
- **一键开关 + 默认开启**：约定优于配置，引入即装载，`enable=false` 可关。
- **标准双通道登记**：同时写 `spring.factories` 与 `AutoConfiguration.imports`，兼容 Boot 2.7 的新旧两套自动配置发现机制。
- **正牌 `@Configuration`**：不同于 springboot 组大量 Starter 的 lite 模式，本类显式 `@Configuration`，不存在跨 `@Bean` 直调代理失效问题（本类也无 `@Bean`）。

## 模块瑕疵或错误（实证）

1. **【高危·缺 `@ConditionalOnClass` 兜底】** 本 Starter 的核心价值依赖 `de.codecentric` 的 `@EnableAdminServer` / `AdminServerConfiguration`，但 `ActuatorServerAutoConfiguration` **只有 `@ConditionalOnExpression` 布尔门，没有任何 `@ConditionalOnClass(EnableAdminServer.class)`**。当 `spring-boot-admin-starter-server` 未随附（其为 `provided` 且非 optional、不具传递性）时，`enable` 默认仍为 `true`，配置类被装载、`@EnableAdminServer` 的 `@Import` 引用缺失类，直接 `NoClassDefFoundError`/`ClassNotFoundException` 导致**启动失败而非优雅退避**。
2. **【版本错配】** 本模块 pin `spring-boot-admin-starter-server:2.2.3`（对应 Spring Boot 2.2.x 时代），而工程根 pom（`pom.xml:49`）统一使用 `spring-boot.version=2.7.18`。Spring Boot Admin 2.2.3 与 Boot 2.7 并非官方兼容组合（Boot 2.7 应配 Admin 2.6.x/2.7.x/3.x 线），存在运行期 API 不兼容风险；且版本硬编码在子 pom，未纳入根 `dependencyManagement` 统一托管。
3. **`@ConfigurationProperties(prefix = "i2f.springcloud.actuator-server")` 实为空挂**：该注解加在一个**没有任何字段**的类上，不发生任何有意义的属性绑定；真正被读的 `enable` 键也并非本类字段，而是由 `@ConditionalOnExpression` 的 SpEL 直接求值。`@ConfigurationProperties` + `@Data` + `@NoArgsConstructor` 三者在此均属装饰性冗余（`@Data` 对空类只生成 `equals/hashCode/toString`）。
4. **封装价值单薄**：去掉条件开关后，本 Starter 相对「直接依赖 `spring-boot-admin-starter-server` 并在启动类加 `@EnableAdminServer`」几乎无额外产出；且 `@EnableAdminServer` 无条件随配置类生效，无法在使用方已有自己的 Admin 配置时避免冲突（无 `@ConditionalOnMissingBean`/无退避）。
5. **配置元数据 `hints` 为跨模块拷贝死条目**：`additional-spring-configuration-metadata.json` 的 `hints` 段是 `server.servlet.jsp.class-name` 与 `server.tomcat.accesslog.encoding` 两条与本模块毫无关系的条目（与本仓库多个 starter 同源的复制粘贴残留），`properties` 仅登记 `enable` 一项。
6. **`spring-boot-admin-starter-server` scope 处理不一致**：同为 provided，`spring-boot-starter`/`configuration-processor` 标了 `optional`，而核心的 admin-server 依赖**未标 optional**；结合其不具传递性，形成「编译期可见、运行期缺失且不提示」的坑（与瑕疵 1 叠加）。
7. **双通道登记冗余**：Boot 2.7 下 `spring.factories` 的 `EnableAutoConfiguration` 已让位于 `AutoConfiguration.imports`，二者同时登记同一类虽被 Boot 去重、暂无功能问题，但属过时冗余写法。
8. **无测试、无下游消费方**：全仓库仅在父 pom `<module>`、根 pom `dependencyManagement`（`pom.xml:1512`）及 wiki 概览表中出现，**无任何模块真实 compile 依赖本 Starter**，也无 `test-*` 样例，属**生态孤岛**（其登记路径未经运行验证）。
9. **文档留白**：`ActuatorServerAutoConfiguration` 的类级 javadoc `@desc` 为空。

## 生态位置

- 处于 `i2f-springcloud` 组（该组 22 个真实模块，本模块为该组首个建档对象），定位为**监控运维族**：与 `i2f-springcloud-actuator-starter`（暴露被监控端的 Actuator）配套，一个负责「被监控」一个负责「监控台」。
- 纯下游消费者角色，不引入任何 i2f 内部 compile 依赖，也不被任何 i2f 模块 compile 依赖——在依赖图中是一个**孤立叶子节点**。
- 若要实际启用，需使用方自行补齐 `spring-boot-admin-starter-server` 依赖，并注意其 2.2.3 与全工程 Boot 2.7.18 的版本兼容性缺口。
