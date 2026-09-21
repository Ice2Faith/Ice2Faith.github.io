# i2f-springcloud-refresh-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-refresh-starter`

## 模块概述

Spring Cloud 组中面向 **Spring Cloud Context 动态刷新（`ContextRefresher` / `RefreshScope`）** 的「装配 Starter」（本组第 20 个建档模块，**3 个 Java 源文件（60 + 60 + 64 行）+ 3 个资源文件**）。这是本组**功能最完整的自研刷新增强件**——不同于薄壳转发第三方 starter，它在官方 `spring-cloud-context` 的刷新能力之上叠加了「**定时自动刷新**」与「**带 TOTP 二次口令鉴权的 REST 手动刷新端点**」两项自研能力，并因此**引入 i2f 自研 compile 依赖 `i2f-otpauth`**（`TotpAuthenticator`，Base32 编解码则经其传递依赖 `i2f-codec` 提供）。

模块把 `spring-cloud-starter`、`spring-boot-starter-web` 作为 `provided`（**未标 optional**）依赖引入，版本由根 pom `spring-cloud-dependencies:2021.0.8` / `spring-boot:2.7.18` BOM 治理（无 Hoxton 覆盖，与 netflix 三件套不同）。三个顶层能力由单一入口 `RefreshAutoConfiguration`（登记于 `spring.factories`）经 `@Import` 装配，另两个 `@ConditionalOnBean`/`@ConditionalOnExpression` 门控为可选子开关。

## 模块依赖

| 依赖 | scope | 说明 |
| --- | --- | --- |
| `org.projectlombok:lombok` | compile（默认） | `@Data/@Slf4j/@NoArgsConstructor` |
| `org.springframework.boot:spring-boot-starter` | provided + optional | 自动装配基础 |
| `org.springframework.boot:spring-boot-configuration-processor` | provided + optional | 元数据生成 |
| `org.springframework.cloud:spring-cloud-starter` | **provided（未标 optional）** | 提供 `ContextRefresher`/`RefreshScope`/`EnvironmentChangeEvent` |
| `i2f.turbo:i2f-otpauth` | **compile（唯一 i2f 内部 compile 依赖）** | `TotpAuthenticator` 手动刷新端点二次鉴权；`Base32` 经其传递依赖 `i2f-codec` 提供（未直接声明，隐式依赖） |
| `org.springframework.boot:spring-boot-starter-web` | **provided（未标 optional）** | `RefreshController` 的 `@RestController`/Web 端点 |

## 模块设计

```mermaid
graph TB
    A[RefreshAutoConfiguration<br/>入口 布尔门 enable:true 无 @Configuration] -->|@Import| B[RefreshScope<br/>官方作用域]
    A -->|@Import| C[AutoRefreshConfiguration<br/>定时刷新 @Configuration]
    A -->|@Import| D[RefreshController<br/>REST 手动刷新 + TOTP @RestController]
    C -->|scheduleWithFixedDelay| E[refresher.refresh 每 delayTime]
    D -->|POST /refresh/trigger| F{totpKey != null?}
    F -->|是| G[TotpAuthenticator.verify code]
    F -->|否| H[直接 refresh 无鉴权]
    I[spring.factories + AutoConfiguration.imports<br/>仅登记入口 A] --> A
```

## 模块目的

为 i2f 微服务提供开箱即用的「运行时配置热刷新」三通道：① 依赖注入 `RefreshScope` 使 `@RefreshScope` Bean 可刷新；② 可选定时器周期性 `ContextRefresher.refresh()` 拉取最新配置；③ 可选暴露一个受 TOTP 保护的 HTTP 端点，供运维在无消息总线的场景手动触发刷新。

## 模块功能

- `RefreshAutoConfiguration`（入口）：`@Import(RefreshScope, AutoRefreshConfiguration, RefreshController)`；`@Autowired ContextRefresher`；`refresh()` 手动刷新；`@EventListener envListener` 监听 `EnvironmentChangeEvent` 打日志；`i2f.springcloud.refresh.enable:true` 总门。
- `AutoRefreshConfiguration`（`i2f.springcloud.refresh.auto-refresh.enable:true`，默认开）：`afterPropertiesSet` 建单线程调度池，`scheduleWithFixedDelay(refresher::refresh, delayTime=5, MINUTES)` 周期刷新；`delay-time`/`delay-time-unit` 可配。
- `RefreshController`（`i2f.springcloud.refresh.api-refresh.enable:false`，默认关）：`POST /refresh/trigger?code=xxx`，若配了 `totp-key` 则用 `TotpAuthenticator` 校验 `code`，通过后 `refresher.refresh()` 返回 `"ok"`，否则 `"failure!"`。

## 模块主要使用方法

```xml
<dependencies>
    <dependency>
        <groupId>i2f.turbo</groupId>
        <artifactId>i2f-springcloud-refresh-starter</artifactId>
    </dependency>
    <!-- provided 不传递，须自引 -->
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter</artifactId>
    </dependency>
</dependencies>
```

```properties
i2f.springcloud.refresh.enable=true
# 定时自动刷新（默认开，5 分钟一次）
i2f.springcloud.refresh.auto-refresh.enable=true
i2f.springcloud.refresh.auto-refresh.delay-time=5
i2f.springcloud.refresh.auto-refresh.delay-time-unit=MINUTES
# REST 手动刷新端点（默认关）；务必同时设置 totp-key 否则端点无鉴权
i2f.springcloud.refresh.api-refresh.enable=true
i2f.springcloud.refresh.api-refresh.totp-key=YOUR_BASE32_SECRET
```

## 模块特性总结

- 本组**功能最完整的自研件**之一：定时刷新 + TOTP 保护的 REST 刷新端点，非注解代理空壳。
- **是本组唯一依赖 i2f 自研 `i2f-otpauth` 的 Spring Cloud 件**，把安全能力（TOTP）接入配置刷新运维通道。
- 三开关分层清晰（总门 `enable` / `auto-refresh.enable` / `api-refresh.enable`），且 `api-refresh` 默认关闭属安全的 opt-in 设计。
- 元数据登记较完整（6 个属性键全覆盖，远优于 gateway/zuul 族的漏登）。

## 模块瑕疵或错误（实证）

1. **【高危·线程池泄漏】`AutoRefreshConfiguration.afterPropertiesSet` 先建池后判界**：L46 `pool = Executors.newSingleThreadScheduledExecutor()` 已创建非守护线程池，L47-50 才判断 `delayTime <= 0` 并 `return`——当用户配置 `delay-time<=0` 时，调度任务未提交但**线程池已创建且从不 shutdown**，单线程池泄漏一个存活线程。
2. **【死代码/无效防御】`pool != null` 重建分支永不命中且缺 shutdown**：L42-45「pool 已存在则告警重建」对全新 Bean 的 `afterPropertiesSet` 恒为 false（字段初始 null），是死分支；且即便命中也只是 `pool = null` 而未 `pool.shutdownNow()`，若真被二次调用会**泄漏旧线程池**。
3. **【高危·鉴权旁路】`RefreshController` 当 `totpKey == null` 时端点完全无鉴权**：L42 `if (totpKey != null)` 才校验 code——未配 `totp-key` 却开启 `api-refresh.enable=true` 时，`POST /refresh/trigger` 无需任何凭据即可反复触发全量上下文刷新，构成可被滥用的运维接口（元数据 L58 亦自证「if not null enable totp」）。
4. **【元数据 vs 代码默认值背离】`api-refresh.enable` defaultValue 相反**：`additional-spring-configuration-metadata.json` L53 标 `defaultValue: true`，而代码 L26 `@ConditionalOnExpression("${i2f.springcloud.refresh.api-refresh.enable:false}")` 实为 **false（默认关）**——IDE 提示与实际行为相反（同 gateway-starter `show-querys`/`enable-repeat-form` 背离族）。
5. **`Base32.decode(Base32.encode(totpKey.getBytes()))` 编解码空转**：L44 对 `totpKey` 先 `Base32.encode` 再立即 `Base32.decode`，二者互逆，净效果等于 `totpKey.getBytes()`——多余的往返计算，属无意义代码（或直接表明作者对 Base32 语义理解偏差）。
6. **`Base32` 依赖 `i2f-codec` 未直接声明、仅靠 `i2f-otpauth` 传递引入**（pom 无 `i2f-codec` 条目，L3 `import i2f.codec.bytes.basex.Base32`）：对传递依赖的直接使用属脆弱依赖（`i2f-otpauth` 一旦升级去掉 codec 即编译断裂），应显式声明。
7. **入口 `RefreshAutoConfiguration` 缺 `@Configuration`（lite 模式）**：登记为自动配置类却无 `@Configuration`/`@AutoConfiguration`（同 gateway 组 `GatewayAutoConfiguration`、`GatewayCorsConfig` lite 族）。本类无 `@Bean` 方法故暂未触发跨方法直调不代理问题，但属装配规范瑕疵。
8. **`@ConfigurationProperties` 与 `@Autowired` 字段混挂 + `@Data` setter 暴露**：`RefreshAutoConfiguration` 的 `applicationContext`/`refreshScope`/`refresher` 三个 `@Autowired` 字段同时是 `@ConfigurationProperties(prefix="i2f.springcloud.refresh")` 的潜在绑定位（`@Data` 生成了 setter），存在被 `i2f.springcloud.refresh.refresh-scope` 等同名属性意外覆盖的隐患（当前无此类配置故未爆发）。
9. **双通道自动装配登记冗余**：`spring.factories`（`EnableAutoConfiguration`）与 `AutoConfiguration.imports` 均登记 `RefreshAutoConfiguration`（同本组各件普遍的双通道过时冗余）。
10. **`@ConditionalOnBean(RefreshAutoConfiguration.class)` 顺序敏感隐患**：`AutoRefreshConfiguration`/`RefreshController` 靠 `@ConditionalOnBean` 依赖入口 Bean，而二者又是被入口 `@Import` 引入——`@ConditionalOnBean` 的求值依赖 Bean 定义注册顺序，官方明确警告其不宜用于普通 `@Component`，此处虽经 import 链勉强成立但脆弱。
11. **`hints` 为拷贝死条目**：metadata L62-85 的 `server.servlet.jsp.class-name`、`server.tomcat.accesslog.encoding` 与本模块零相关（与 gateway/zuul/薄壳同一份拷贝模板残留）。

## 生态位置

- 登记：父 `i2f-springcloud/pom.xml` L35（module）、根 `pom.xml` L1607（dependencyManagement）。
- 消费方：**全仓零真实 compile 消费方，纯孤岛**（grep 仅命中本模块自身 pom、父聚合、根 DM 三处）。
- 组内定位：Spring Cloud 组「配置外部化与动态刷新」子域，与 `config-client-starter`（Nacos/Consul 配置拉取）互补——config-client 负责「取到」新配置，本件负责「怎么触发刷新」（定时/手动端点）。是本组少见的与 i2f 自研安全件（`i2f-otpauth`）打通的功能件。
- 依赖 i2f 生态：`i2f-otpauth`（TOTP）、传递依赖 `i2f-codec`（Base32）。
