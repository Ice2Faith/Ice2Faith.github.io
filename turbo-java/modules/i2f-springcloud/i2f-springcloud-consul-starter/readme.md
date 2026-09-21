# i2f-springcloud-consul-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-consul-starter`

## 模块概述

Spring Cloud 组中面向 **HashiCorp Consul（服务注册发现 + 分布式配置中心）** 的「即插即用」装配 Starter（本组第 8 个建档模块，1 个 Java 源文件 + 5 个资源文件，**不含任何 i2f 内部 compile 依赖**，仅 lombok + Spring）。它把 `org.springframework.cloud:spring-cloud-starter-consul-discovery`（注册发现）与 `spring-cloud-starter-consul-config`（配置拉取/刷新）作为 `provided` 依赖引入，版本由根 pom 的 `spring-cloud-dependencies:2021.0.8` BOM（[pom.xml L50](file:///C:/home/dev/java/dev-center/i2f-turbo-java/pom.xml#L50)/[L102](file:///C:/home/dev/java/dev-center/i2f-turbo-java/pom.xml#L102)）统一治理，无硬编码错配。

它是同组 `i2f-springcloud-alibaba-nacos-starter` 的**技术栈对偶**（一 Nacos、一 Consul，同为「注册中心 + 配置中心」双能力接入件），封装风格几乎完全一致：一个带 `@EnableDiscoveryClient` 的 `@Configuration` 类 `ConsulAutoConfiguration`，配一个布尔开关 `i2f.springcloud.consul.enable`（默认 `true`，经 `@ConditionalOnExpression` 门控），并附带翔实的 sample 配置（`bootstrap-consul.yaml` 演示 host/port/service-name/heartbeat/config format、`consul.md` 是 Consul 二进制安装与启动指引）。

需明确：`ConsulAutoConfiguration` 本身**无任何 `@Bean`、无 `@Import`**，`@ConfigurationProperties(prefix = "i2f.springcloud.consul")` 加在这样一个**无字段的空类**上纯属装饰。真正的注册发现与配置拉取全部由 `spring-cloud-starter-consul-discovery`/`-config` 自身的自动配置驱动（读取 `spring.cloud.consul.*`），本类只提供一个「装载即打日志占位」的语义，其存在价值主要是把两个 consul starter 聚合成一个坐标、并以 `@EnableDiscoveryClient` 显式声明「本服务是发现客户端」。

## 模块依赖

### 内部依赖（compile）

| 依赖 | 说明 |
|---|---|
| （无） | 本模块不含任何 i2f 内部 compile 依赖，仅 lombok（provided/optional） |

### 外部依赖

| 依赖 | scope | optional | 说明 |
|---|---|---|---|
| `org.projectlombok:lombok` | 默认 | - | 编译期注解（本类实际未使用任何 lombok 注解） |
| `spring-boot-starter` | provided | 是 | Spring Boot 基础装配 |
| `spring-boot-configuration-processor` | provided | 是 | 配置元数据处理 |
| `spring-cloud-starter-consul-discovery` | provided | **否** | Consul 服务注册发现核心 |
| `spring-cloud-starter-consul-config` | provided | **否** | Consul 分布式配置 |

## 模块设计

```mermaid
graph TB
    A[ConsulAutoConfiguration<br/>空 @Configuration] -->|implements via @EnableDiscoveryClient| B[注册为 Discovery Client 标记]
    A -->|@ConditionalOnExpression i2f.springcloud.consul.enable:true| C{布尔门控本类}
    A -->|@ConfigurationProperties 无字段| D[装饰性空挂]
    E[spring-cloud-starter-consul-discovery] -->|自身 AutoConfig 读 spring.cloud.consul.*| F[真正的注册发现]
    G[spring-cloud-starter-consul-config] -->|自身 AutoConfig 读 spring.cloud.consul.config.*| H[真正的配置拉取/刷新]
    C -.仅门控本类, 不停 E/G.-> F
```

## 模块目的

把 Consul 这一「注册中心 + 配置中心」二合一中间件的两个 Spring Cloud starter 聚合为单一 Maven 坐标，放 classpath + 默认布尔开关键即自动生效，并以 `@EnableDiscoveryClient` 显式声明服务身份；配套 sample 与安装指引降低接入成本。

## 模块功能

- `ConsulAutoConfiguration`：`@Configuration` + `@EnableDiscoveryClient` + `@ConditionalOnExpression` 布尔门控的空类，作为「引本 Starter 即装载 Consul 客户端」的锚点。
- `spring.factories` + `AutoConfiguration.imports`：双通道登记该自动配置类。
- `additional-spring-configuration-metadata.json`：登记 `i2f.springcloud.consul.enable`（默认 true）。
- `sample/bootstrap-consul.yaml`：Consul host/port、discovery service-name、heartbeat、config profile-separator/format 示范。
- `sample/consul.md`：Consul 二进制下载与 `agent -dev` / `agent -server -ui -bootstrap-expect 1` 启动指引。

## 模块主要使用方法

```xml
<dependencies>
    <dependency>
        <groupId>i2f.turbo</groupId>
        <artifactId>i2f-springcloud-consul-starter</artifactId>
    </dependency>
    <!-- 由于 consul 依赖为 provided 且不 optional、不具传递性，使用方须自行补齐： -->
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-consul-discovery</artifactId>
    </dependency>
</dependencies>
```

```yaml
# bootstrap-consul.yaml（需启用 bootstrap 机制：spring-cloud-starter-bootstrap）
spring:
  application:
    name: cloud-payment-service
  cloud:
    consul:
      host: localhost
      port: 8500
      discovery:
        service-name: ${spring.application.name}
        heartbeat:
          enabled: true
      config:
        profile-separator: '-'
        format: yaml
```

## 模块特性总结

- 与本组 `alibaba-nacos-starter` 构成「Consul vs Nacos」注册/配置中心技术栈对偶，风格高度一致。
- 依赖版本经根 BOM `2021.0.8` 统一治理，无子模块硬编码错配（明显优于 `actuator-*` 家族 pin `2.2.3` 的做法）。
- sample 附有独立的 `consul.md` 安装/启动指引，接入文档完备度略优于同族。
- 封装本身是纯「聚合坐标 + 声明式标记」，不产生任何运行期逻辑。

## 模块瑕疵或错误（实证）

1. **【高危·缺 `@ConditionalOnClass` + provided 非 optional 不传递 → 缺类崩溃无优雅退避】** `spring-cloud-starter-consul-discovery`/`-config` 均为 `provided` 且**未标 `optional`**，二者带来的 `spring-cloud-commons`（含 `@EnableDiscoveryClient` 所在包 `org.springframework.cloud.client.discovery`）不具传递性。而 `ConsulAutoConfiguration` 被登记进 `EnableAutoConfiguration` 且仅有 `@ConditionalOnExpression` 布尔门、**无 `@ConditionalOnClass` 兜底**：使用方若未自行补齐 consul/spring-cloud-commons，`enable` 默认仍 `true`，装载本类时其 import 的 `EnableDiscoveryClient` 类缺失 → `NoClassDefFoundError` **启动失败**，而非优雅退避（同 `actuator-admin`/`config-server` 族）。
2. **【开关名不副实·门控范围有限】** `@ConditionalOnExpression("${i2f.springcloud.consul.enable:true}")` 只门控本空类；真正的 Consul 注册与配置拉取由 `spring-cloud-starter-consul-discovery`/`-config` 自身自动配置驱动（读 `spring.cloud.consul.*`）。设 `i2f.springcloud.consul.enable:false` **并不能阻止**本服务向 Consul 注册或拉取配置，与「一键关闭 Consul」的直觉不符。
3. **【`@ConfigurationProperties` 空挂无字段】** `@ConfigurationProperties(prefix = "i2f.springcloud.consul")` 加在无任何字段的空类上，纯属装饰；`enable` 实由 SpEL 直接读取，并非通过本类字段绑定，IDE 也不会因此类生成有效绑定。
4. **【`@EnableDiscoveryClient` 时代冗余】** 版本经根 BOM 属 Spring Cloud 2021，consul-discovery 已默认自动注册，`@EnableDiscoveryClient` 已无实际作用（与本组 `nacos-starter`、`config-client-starter` 同病）；其唯一残留效果是显式标记，但与「靠引包即生效」的整体风格自相矛盾。
5. **【sample 依赖传统 bootstrap 机制与 2021 脱节】** `bootstrap-consul.yaml` 使用 `spring.cloud.consul.config` 的传统 bootstrap 拉取方式，需额外引入 `spring-cloud-starter-bootstrap` 或设 `spring.cloud.consul.config.import-check.enabled=false` 等；在 2021 默认 `spring.config.import` 机制下，照抄 sample 可能因未启用 bootstrap 而配置不生效，sample 未作说明。
6. **【元数据登记不全 + 死条目 hints】** `additional-spring-configuration-metadata.json` 仅登记 `enable` 一个属性，对真正关键的 `spring.cloud.consul.*` 无任何聚合提示；`hints` 段是 `server.servlet.jsp.class-name` / `server.tomcat.accesslog.encoding` 的**拷贝死条目**，与本模块毫无关系。
7. **【双通道登记过时冗余】** 同时保留 `META-INF/spring.factories`（`EnableAutoConfiguration`）与 `META-INF/spring/...AutoConfiguration.imports` 两份登记，Boot 2.7 下前者已被后者取代，属遗留冗余（同组普遍现象）。
8. **【lombok 空引】** 引入 lombok 但源类未使用任何 lombok 注解，纯占位依赖。
9. **【生态孤岛】** 全仓 grep 证实无任何模块 compile/test 依赖本 Starter（仅自引用与 `.wiki` 文档引用）；根 pom L1547 有 DM 登记、父 pom L23 有 module 声明，但无真实消费方。

## 生态位置

- 位于 i2f-springcloud 组「注册中心 / 配置中心」子域，与 `alibaba-nacos-starter`、`netflix-eureka-client/server-starter` 并列，是 Consul 技术栈的接入锚点（见 `.wiki/docs/module-i2f-springcloud.md` L14、`wiki.md` L222）。
- 封装质量与 `alibaba-nacos-starter` 同级（纯空壳 + 布尔开关 + `@EnableDiscoveryClient` + 翔实 sample），优于纯 `@ConditionalOnExpression` 无 `@Enable*` 的 `actuator-*` 空壳，但同样存在「provided 非 optional + 缺 `@ConditionalOnClass` → 缺类崩溃」这一组内高频高危缺陷。
- 处于依赖生态末端、无下游真实消费者，属可选接入件而非聚合枢纽。
