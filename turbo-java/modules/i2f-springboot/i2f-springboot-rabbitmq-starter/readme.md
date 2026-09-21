# i2f-springboot-rabbitmq-starter

> RabbitMQ 的 Spring Boot 自动装配 Starter（薄装配层，仅 4 个类、零内部依赖）：`RabbitMqAutoConfiguration` 在开关 `i2f.springboot.config.rabbit.enable`（默认 true）下产出全局 `RabbitTemplate`——注入 `ConnectionFactory`、按 `mandatory` 设置强制回退、并按开关可选挂载确认/返回日志回调；`RabbitMqManager` 提供 `send(exchange, routing, msg)` 的极简发送封装；`RabbitConfirmCallbackLogImpl`/`RabbitReturnCallbackLogImpl` 是两个只打印日志的 `ConfirmCallback`/`ReturnCallback` 观测实现。真正的连接/工厂/序列化能力全部委托 `spring-boot-starter-amqp`（provided+optional）。

## 模块路径

- `i2f-springboot/i2f-springboot-rabbitmq-starter`

## 模块依赖

| groupId | artifactId | scope | optional | 说明 |
|---------|-----------|-------|----------|------|
| org.projectlombok | lombok | compile | 否 | `@Slf4j`/`@Data` 代码生成 |
| org.springframework.boot | spring-boot-starter | provided | 是 | Boot 基础自动装配 |
| org.springframework.boot | spring-boot-configuration-processor | provided | 是 | 配置元数据处理器 |
| org.springframework.boot | spring-boot-starter-amqp | provided | 是 | RabbitMQ 支持（`RabbitTemplate`/`ConnectionFactory`/`@RabbitListener` 等），版本由父 pom 统一管理 |

> 本模块**零 i2f 内部依赖**，仅叠加在官方 `spring-boot-starter-amqp` 之上；amqp 为 `provided`+`optional`，使用方须自行引入才能实际连接 RabbitMQ。

## 模块设计

```mermaid
flowchart TD
    subgraph AC["RabbitMqAutoConfiguration（@ConditionalOnExpression enable:true）"]
        P["@ConfigurationProperties<br/>i2f.springboot.config.rabbit<br/>mandatory / logConfirmCallback / logReturnCallback"]
        RT["createRabbitTemplate(ConnectionFactory)<br/>@ConditionalOnMissingBean(RabbitTemplate)"]
    end
    subgraph CB["可选回调（观测桩）"]
        CC["RabbitConfirmCallbackLogImpl<br/>implements ConfirmCallback"]
        RC["RabbitReturnCallbackLogImpl<br/>implements ReturnCallback"]
    end
    subgraph MGR["RabbitMqManager（@Component）"]
        SEND["send(exchange, routing, msg)<br/>→ rabbitTemplate.convertAndSend"]
    end

    AMQP["spring-boot-starter-amqp<br/>ConnectionFactory / RabbitTemplate"]
    BOOT["Boot RabbitAutoConfiguration<br/>（默认已产出 RabbitTemplate）"]

    P --> RT
    RT -->|setConnectionFactory| AMQP
    RT -.->|logConfirmCallback=true| CC
    RT -.->|logReturnCallback=true| RC
    RT -->|产出 Bean| RT
    MGR -->|@Autowired| RT
    BOOT -.->|"@ConditionalOnMissingBean 命中则本模块 RT 被跳过"| RT
```

**设计要点：**
- **单装配类 + 属性绑定**：`RabbitMqAutoConfiguration` 同时充当 `@Configuration`（产 Bean）与 `@ConfigurationProperties`（绑 `i2f.springboot.config.rabbit.*` 三属性），并以 `@Data` 暴露读写。
- **模板可缺省让位**：`createRabbitTemplate` 带 `@ConditionalOnMissingBean(RabbitTemplate.class)`，语义为"使用方/Boot 已有 `RabbitTemplate` 时不覆盖"。
- **回调可选插桩**：确认/返回回调按 `logConfirmCallback`/`logReturnCallback` 布尔开关分别 `new` 出日志实现挂到模板上，二者相互独立、默认关闭。
- **发送器解耦**：`RabbitMqManager` 作为对外门面，仅依赖 `RabbitTemplate` 转发 `convertAndSend`，不感知回调细节。
- **双层注册**：`spring.factories`（Boot 2.x）与 `AutoConfiguration.imports`（Boot 2.7+/3.x）同时登记 `RabbitMqAutoConfiguration` 与 `RabbitMqManager`。

**包结构：**

```
i2f.springboot.mq.rabbit
├── RabbitMqAutoConfiguration     # @Configuration + @ConfigurationProperties，产出 RabbitTemplate
├── RabbitMqManager               # @Component，convertAndSend 发送门面
└── impl
    ├── RabbitConfirmCallbackLogImpl   # ConfirmCallback 日志实现
    └── RabbitReturnCallbackLogImpl    # ReturnCallback 日志实现
```

## 模块目的

在官方 `spring-boot-starter-amqp` 之上，提供一层"开箱即用"的 `RabbitTemplate` 装配与极简发送门面，并把生产端"消息确认（Confirm）/消息回退（Return）"两类回调以日志形式标准化，降低接入 RabbitMQ 生产者侧回调观测的样板代码成本。

## 模块功能

| 能力 | 触发条件 | 载体 |
|------|----------|------|
| 整体装配开关 | `i2f.springboot.config.rabbit.enable`（默认 `true`） | `@ConditionalOnExpression`（仅作用于 `RabbitMqAutoConfiguration`） |
| 产出全局 `RabbitTemplate` | 上表开关开启 **且** 容器中无其它 `RabbitTemplate` | `createRabbitTemplate` + `@ConditionalOnMissingBean(RabbitTemplate.class)` |
| 强制回退（mandatory） | `i2f.springboot.config.rabbit.mandatory`（默认 `true`） | `rabbitTemplate.setMandatory(...)` |
| 挂载确认回调日志 | `i2f.springboot.config.rabbit.log-confirm-callback`（默认 `false`） | `setConfirmCallback(new RabbitConfirmCallbackLogImpl())` |
| 挂载回退回调日志 | `i2f.springboot.config.rabbit.log-return-callback`（默认 `false`） | `setReturnCallback(new RabbitReturnCallbackLogImpl())` |
| 极简发送门面 | 无（`RabbitMqManager` 恒定注册） | `send(exchange, routing, msg)` → `convertAndSend` |

## 模块主要使用方法

引入本 Starter 并自行携带 `spring-boot-starter-amqp`，配置连接与开关后即可注入 `RabbitMqManager` 发送：

```yaml
spring:
  rabbitmq:
    host: 127.0.0.1
    port: 5672
    username: guest
    password: guest
    publisher-confirm-type: correlated   # 确认回调触发前提（由 Boot 侧配置）
    publisher-returns: true              # 回退回调触发前提（由 Boot 侧配置）

i2f:
  springboot:
    config:
      rabbit:
        enable: true
        mandatory: true
        log-confirm-callback: true
        log-return-callback: true
```

```java
@Autowired
private RabbitMqManager rabbitMqManager;

public void demo() {
    // 直接投递到指定 exchange + routingKey
    rabbitMqManager.send("demo.exchange", "demo.key", payloadObject);
}
```

如需更细粒度控制，可直接注入 `RabbitTemplate`：

```java
@Autowired
private RabbitTemplate rabbitTemplate;

public void sendWithCorrelation(Object msg) {
    rabbitTemplate.convertAndSend("demo.exchange", "demo.key", msg,
            m -> { m.getMessageProperties()
                    .setCorrelationId(new org.springframework.amqp.core.CorrelationData("c-1").getId()); return m; });
}
```

## 配置项参考

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `i2f.springboot.config.rabbit.enable` | Boolean | `true` | 整体装配开关（`@ConditionalOnExpression` 读取；**未登记于元数据**） |
| `i2f.springboot.config.rabbit.mandatory` | Boolean | `true` | 是否设置 `RabbitTemplate` 强制回退，`true` 是回退回调触发前提 |
| `i2f.springboot.config.rabbit.log-confirm-callback` | Boolean | `false` | 是否挂载 `RabbitConfirmCallbackLogImpl`（打印相关数据/ack/原因） |
| `i2f.springboot.config.rabbit.log-return-callback` | Boolean | `false` | 是否挂载 `RabbitReturnCallbackLogImpl`（打印消息/回应码/交换机/路由键） |

## 模块特性总结

- **足够薄**：4 个类只做"装配 `RabbitTemplate` + 挂可选日志回调 + 发送门面"，不接管连接、序列化、监听容器等重型配置。
- **零内部耦合**：不依赖任何 i2f 模块，可独立引入或整体移除。
- **可缺省让位**：模板 Bean 带 `@ConditionalOnMissingBean`，不粗暴覆盖使用方自定义 `RabbitTemplate`。
- **回调标准化**：确认/回退两类生产端回调的日志输出格式统一，按需分开关。
- **双层自动配置登记**：兼容 Boot 2.x（`spring.factories`）与 2.7+/3.x（`imports`）。

## 模块瑕疵或错误

> 以下为按源码静态阅读标注的潜在问题，仅作提示、未运行实证。

1. **`@ConditionalOnMissingBean(RabbitTemplate.class)` 使本模块在常态下几乎空转**：只要引入 `spring-boot-starter-amqp` 且配置了 `spring.rabbitmq.*`，Boot 自带的 `RabbitAutoConfiguration` 会**先行产出 `RabbitTemplate`**，本模块 `createRabbitTemplate` 因此被跳过——`mandatory` 与确认/回退日志回调**静默失效**，使用方以为开关生效实则未挂载。
2. **`enable=false` 无法真正关停模块**：开关仅作用于 `RabbitMqAutoConfiguration`，而 `RabbitMqManager` 以无条件的 `@Component` 恒定注册且 `@Autowired RabbitTemplate`（默认 `required=true`）；关闭开关后仍需要一个 `RabbitTemplate` 才能装配，若此时既无 Boot 默认模板又无本模块模板，容器启动即因缺依赖失败。
3. **`RabbitMqManager` 冒充自动配置类登记**：作为业务 `@Component` 被写入 `spring.factories`/`imports`（应通过 `@Import` 或 `@Bean` 装配），与 kafka/mybatis/nginx-rtmp 等模块同类反模式一致。
4. **确认/回退回调非自动生效**：`log-confirm-callback`/`log-return-callback` 仅挂回调对象，但回调真正触发依赖 Boot 侧 `spring.rabbitmq.publisher-confirm-type`、`publisher-returns` 等配置，本模块不校验也不联动，易出现"开了开关却收不到回调"的困惑。
5. **回调仅 `info` 级、无失败区分与补救**：`confirm` 无论 `ack` 成功与否、`returnedMessage` 一律 `log.info`，投递失败（`ack=false`/被回退）既不升级日志级别也无重投/告警，仅为观测桩。
6. **`@Data` 用于 `@Configuration` 类**：为配置类生成 `equals`/`hashCode`/`toString` 无意义且可能与代理/生命周期语义冲突。
7. **元数据不完整/残留**：`additional-spring-configuration-metadata.json` 未登记 `enable` 开关；`hints` 为模板遗留项（`server.servlet.jsp.class-name`、`server.tomcat.accesslog.encoding`），与 RabbitMQ 无关。
