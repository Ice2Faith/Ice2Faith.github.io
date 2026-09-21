# i2f-springcloud-netflix-ribbon-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-netflix-ribbon-starter`

## 模块概述

Spring Cloud 组中面向 **Netflix Ribbon（客户端负载均衡）** 的「装配 Starter」（本组第 18 个建档模块，**仅 1 个 Java 源文件（27 行）+ 4 个资源文件**，无任何 i2f 内部 compile 依赖）。

`RibbonAutoConfiguration` 类体零字段、零 `@Bean`、**零 `@Enable*` 注解**，`InitializingBean.afterPropertiesSet()` 仅打一行日志——是本组乃至全仓**最纯粹的空壳件**（比 `loadbalancer-starter` 还"纯"，后者也仅 log 但至少 provided 不 optional 还有名义传递意义）。

这不是开发疏忽，而是 Ribbon 的设计本质决定的：**Ribbon 没有 `@EnableRibbon` 注解**，其激活完全依赖 classpath 存在 + `@LoadBalanced RestTemplate` + Spring Cloud Netflix 官方 `RibbonAutoConfiguration`（同名不同包）。本 i2f 件无法通过添加注解来"启用"Ribbon，因此退化为纯日志标记。

**与 `netflix-hystrix-starter` 同为 Hoxton 版本时间胶囊**：模块级自引 `spring-boot:2.3.7` / `spring-cloud:Hoxton.SR12` BOM 覆盖根 `2.7.18` / `2021.0.8`。Ribbon 自 Spring Cloud 2020.0 起标记维护模式、2021.0 官方移除。

## 模块依赖

| 依赖 | scope | 说明 |
|---|---|---|
| `lombok` | compile | 编译期注解 |
| `spring-boot-starter` | provided, optional | 基础 Boot 环境（版本由本模块自引 2.3.7 BOM 管理） |
| `spring-boot-configuration-processor` | provided, optional | 元数据生成（无实际绑定字段，形同虚设） |
| `spring-cloud-starter-netflix-ribbon` | provided, **optional** | Ribbon 全家桶；**本组少数正确标 optional 的件**，不传递且无崩溃风险 |

### 版本治理异常（同 hystrix-starter）

```xml
<project>
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
    A[应用 pom 引入本 starter] -->|provided optional 不传递| B[RibbonAutoConfiguration]
    B -->|@ConditionalOnExpression enable:true| C[类装载]
    C -->|implements InitializingBean| D[afterPropertiesSet → log.info 仅一行]
    B -.->|@ConfigurationProperties 零字段| E[无任何属性绑定]
    B -.->|无任何 @Enable 注解| F[本件不启用 Ribbon 任何功能]
    G[官方 spring-cloud-netflix-ribbon] -.->|classpath 检测| H[RibbonAutoConfiguration 官方同名]
    H --> I[负载均衡拦截 @LoadBalanced RestTemplate]
```

## 模块目的

以 i2f 统一命名空间前缀 `i2f.springcloud.ribbon.enable` 作为 Ribbon 启停的"名义开关"。但由于 Ribbon 无 `@Enable*` 注解且官方 Ribbon 自动配置独立于本件运行，**本件实际不具备控制 Ribbon 启停的能力**——真正的开关是 `spring.cloud.loadbalancer.ribbon.enabled=false`（禁用 Ribbon 转用 LoadBalancer）。

## 模块功能

- `InitializingBean.afterPropertiesSet()`：打印 `"RibbonConfig config done."`（**唯一行为，纯装饰**）。
- 无 `@Enable*`、无 `@Bean IRule`、无 Ribbon NFLoadBalancer 定制——**零实质功能**。

## 模块主要使用方法

1. 在应用 pom 中引入 `spring-cloud-starter-netflix-ribbon`（本件 provided+optional 不传递，须自行引入）。
2. **须使用 Hoxton.SR12 或更早 Spring Cloud 版本**（2021.0.8 已无 Ribbon）。
3. 在 RestTemplate Bean 上标注 `@LoadBalanced` 即自动享有 Ribbon 客户端负载均衡。
4. 本件可选引入仅作启动日志标记，不影响 Ribbon 功能。

## 模块特性总结

- **本组最纯粹空壳件**：比 loadbalancer-starter 更无功能（后者至少 provided 非 optional 有名义崩溃风险提醒意义）。
- **provided + optional 正确标注**：本组少数做到这点的件——避免了缺 classpath 即 NCDNF 的崩溃族问题。
- **Hoxton 版本时间胶囊**：与 hystrix-starter 同款（模块级覆盖根 BOM）。
- Ribbon 已 EOL，替代方案为 `i2f-springcloud-loadbalancer-starter`（Spring Cloud LoadBalancer）。
- sample 内容最丰富（46 行，含全局/单 Client 策略/代码方式配置/IRule Bean 注册教学）。
- 全仓零消费方，属纯孤岛。

## 模块瑕疵或错误（实证）

1. **模块级 BOM 覆盖根版本治理（同 hystrix）**：`<dependencyManagement>` 导入 Spring Boot 2.3.7 + Spring Cloud Hoxton.SR12，与根 pom 2.7.18/2021.0.8 背离 2 个大版本。Ribbon 不存在于 `spring-cloud-dependencies:2021.0.8` BOM 中，模块被迫自引旧 BOM 使 artifact 可解析。**（架构级）**
2. **纯空壳零功能（引与不引行为完全一致）**：类体无 `@Enable*`/无 `@Bean`/无 `IRule` 定制，Ribbon 激活不依赖本件。布尔门 `enable:true/false` 对本件外无任何效果——只控制一行日志是否打印。**本件存在的唯一价值是"占位"。**
3. **开关名不副实**：`i2f.springcloud.ribbon.enable=false` 并不能关闭 Ribbon——Ribbon 官方自动配置独立运行。真正关闭 Ribbon 须 `spring.cloud.loadbalancer.ribbon.enabled=false`（本件不知）。
4. **sample L28 未注释的模板占位符**：`${client-name}.ribbon.NFLoadBalancerRuleClassName=...` 作为 .properties 键，`${client-name}` 是文档模板意图但**未注释**，若整文件照抄为 application.properties，Spring 不会解析键中的 `${}` 占位符（仅 value 端解析），产生一条永远不会被任何 Ribbon 实例匹配到的死键。
5. **spring.version 死属性**：L16 `<spring.version>5.2.12.RELEASE</spring.version>` 声明后从未被引用。与 hystrix-starter 同病。
6. **@ConfigurationProperties 挂零字段类**：前缀 `i2f.springcloud.ribbon` 绑到无任何字段的类上。与 eureka/loadbalancer/hystrix 同病。
7. **双通道登记冗余**：`spring.factories` + `AutoConfiguration.imports`。
8. **元数据死 hints**：`server.servlet.jsp.class-name` / `server.tomcat.accesslog.encoding`。
9. **sample 引用已弃用技术栈**：Ribbon 超时键（`ribbon.read-timeout`/`ribbon.connect-timeout`）及 `NacosRule` 均基于 Hoxton 时代，2021.0.8 推荐改用 `spring.cloud.loadbalancer.*` 配置。

## 生态位置

- **groupId**: `i2f.turbo`
- **artifactId**: `i2f-springcloud-netflix-ribbon-starter`
- **版本**: `1.0-jdk8`
- **父模块**: `i2f-springcloud`（L33）
- **根 pom DM**: L1597
- **消费方**: 全仓**零引用**（纯孤岛）
- **对应官方件**: `spring-cloud-starter-netflix-ribbon`（仅存在于 Hoxton.SR12 及更早版本）
- **组内关系**: `i2f-springcloud-loadbalancer-starter` 是其新一代替代（Spring Cloud LoadBalancer）；与 `netflix-hystrix-starter` 同为 Hoxton 版本时间胶囊对；`netflix-openfeign-starter` sample 中引用 Ribbon 超时键暗示历史联动。
- **迁移建议**: Ribbon 已 EOL，应迁移至 Spring Cloud LoadBalancer（本组 loadbalancer-starter）或 Nacos 自带负载均衡策略。
