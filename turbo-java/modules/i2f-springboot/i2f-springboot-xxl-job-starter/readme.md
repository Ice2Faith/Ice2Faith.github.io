# i2f-springboot-xxl-job-starter

> xxl-job 执行器（`xxl-job-core:2.4.1`）的 Spring Boot 装配 Starter —— 把官方「`XxlJobConfig` 手动装配 `XxlJobSpringExecutor`」样例改造成一个自动配置类：`XxlJobAutoConfiguration` 以 `@ConditionalOnExpression("${xxl.job.enable:true}")` + `@ConditionalOnClass(XxlJobSpringExecutor, XxlJob)` 为进入条件，`@EnableConfigurationProperties(XxlJobProperties)` 绑定 `xxl.job.*`（admin.addresses / access-token / executor.{appname,address,ip,port,log-path,log-retention-days}），并在 `xxlJobExecutor()` 里 `new XxlJobSpringExecutor()` 逐字段 `setXxx` 后注册为 Bean，交由 xxl-core 自身在容器启动时完成「注册到 admin 中心 + 内嵌 NettyServer 接收调度 + 扫描 `@XxlJob` 方法」全生命周期。本模块仅 2 个类、无任何 i2f 内部 compile 依赖，Boot 与 `xxl-job-core` 全 `provided`，是组内最简单、几乎照搬上游官方集成范式的专项 Starter。

## 模块路径

- `i2f-springboot/i2f-springboot-xxl-job-starter`

## 模块依赖

| GroupId | ArtifactId | Scope | Optional | 说明 |
|---------|------------|-------|----------|------|
| org.projectlombok | lombok | compile | 否 | `@Data`/`@Slf4j`/`@NoArgsConstructor` |
| org.springframework.boot | spring-boot-starter | provided | 是 | 自动配置基座、`@Conditional*`/`@EnableConfigurationProperties`/`@Bean` |
| org.springframework.boot | spring-boot-configuration-processor | provided | 是 | 元数据生成 |
| com.xuxueli | xxl-job-core | provided | 否（未标 optional） | 执行器内核：`XxlJobSpringExecutor`、`@XxlJob`、注册/内嵌服务/调度回调 |

> `xxl-job-core` 为 `provided` 但**未标 `<optional>`**，与同组 Boot 依赖的 provided+optional 风格不一致；`provided` 不传递给宿主，故宿主必须自行再引入一份 `com.xuxueli:xxl-job-core:2.4.1` 运行时，否则 `XxlJobSpringExecutor` 类缺失、`@ConditionalOnClass` 直接不满足而静默不装配。
>
> 构建：`maven-assembly-plugin` + `addMavenDescriptor=true`；根 `pom.xml` `dependencyManagement` 第 1499 行以 `${i2f.version}` 登记版本；`i2f-springboot/pom.xml` 第 46 行登记 module。

## 模块设计

本 Starter 采用「**一个自动配置类 + 一个层级属性类**」极简结构：`XxlJobProperties`（`@ConfigurationProperties("xxl.job")`，含嵌套 `AdminProperties`/`ExecutorProperties`）承载全量配置，`XxlJobAutoConfiguration.xxlJobExecutor(properties)` 把扁平属性逐一套进 `XxlJobSpringExecutor` 的 setter 并注册为 Bean，其余（注册中心通信、内嵌 server、`@XxlJob` handler 扫描与调度执行）全部由 xxl-core 依靠该 Bean 的 `SmartInitializingSingleton`/`DisposableBean` 生命周期自管，本 Starter 不介入。

```mermaid
flowchart TD
    AC[XxlJobAutoConfiguration  xxl.job.enable:true + @ConditionalOnClass]
    PROP[XxlJobProperties  @ConfigurationProperties xxl.job]
    BEAN["@Bean xxlJobExecutor(XxlJobProperties)"]
    EXEC[XxlJobSpringExecutor  xxl-core]
    ADMIN[(xxl-job-admin 调度中心)]
    HANDLER["@XxlJob 业务方法 宿主提供"]
    CFG[application.yml  xxl.job.*]
    AC -->|@EnableConfigurationProperties| PROP
    CFG -.Binder  relaxed binding.-> PROP
    AC --> BEAN
    BEAN -->|new + setXxx 八项| EXEC
    EXEC -->|启动期注册/心跳| ADMIN
    ADMIN -->|调度回调| EXEC
    EXEC -->|反射调用| HANDLER
```

- **双通道自动装配登记**：`META-INF/spring.factories`（Boot 2.x `EnableAutoConfiguration`）与 `META-INF/spring/...AutoConfiguration.imports`（Boot 2.7+）双登记同一个 `XxlJobAutoConfiguration`。
- **条件化防呆**：`@ConditionalOnClass({XxlJobSpringExecutor, XxlJob})` 保证宿主缺 `xxl-job-core` 时不装配（配合 provided 语义），`@ConditionalOnExpression("${xxl.job.enable:true}")` 提供运行期总开关。
- **属性分层绑定**：`xxl.job.{admin,executor}` 用嵌套静态类映射，字段名 relaxed-binding 兼容 `access-token`/`log-path`/`log-retention-days` 短横线写法。

## 模块目的

- 省去官方样例要求每个应用手写 `@Configuration + @Bean XxlJobSpringExecutor` 的重复代码，改为「引 Starter + 配 `xxl.job.*`」即装配分布式任务执行器。
- 复用 `xxl-job-core` 的注册/调度/日志/失败重试能力，本模块只做属性 → 执行器的桥接，不触碰调度语义。
- 以 `@ConditionalOnClass` + `enable` 开关，让未引入 xxl-core 或未开启的 Boot 应用零副作用。

## 模块功能

- `XxlJobAutoConfiguration`：`@ConditionalOnExpression("${xxl.job.enable:true}")` + `@ConditionalOnClass` 总开关，`@EnableConfigurationProperties(XxlJobProperties)`，产 `@Bean XxlJobSpringExecutor xxlJobExecutor(properties)`（把 admin.addresses、executor.{appname,address,ip,port,accessToken,logPath,logRetentionDays} 共 8 项 setter 应用后返回）。
- `XxlJobProperties`（`@ConfigurationProperties("xxl.job")`）：`accessToken:String` + 嵌套 `AdminProperties{addresses:String}` + `ExecutorProperties{appname,address,ip,port:int,logPath,logRetentionDays:int}`。

## 模块主要使用方法

1. 引入本 Starter，并由宿主自备 `xxl-job-core` 与 Boot 运行时（本模块全 `provided` 不传递，需自行再添加一份 `com.xuxueli:xxl-job-core:2.4.1`，否则 `@ConditionalOnClass` 不满足而静默不装配）：

```xml
<dependency>
    <groupId>i2f.turbo</groupId>
    <artifactId>i2f-springboot-xxl-job-starter</artifactId>
    <version>1.0-jdk8</version>
</dependency>
```

2. 配置执行器参数（注意：`xxl.job.enable` 未登记元数据、且属性类无对应字段，见瑕疵②）：

```yaml
xxl:
  job:
    enable: true            # 总开关（非 XxlJobProperties 字段，仅被 @ConditionalOnExpression 读取）
    access-token: default_token
    admin:
      addresses: http://127.0.0.1:8080/xxl-job-admin   # 逗号分隔多地址
    executor:
      appname: biz-executor
      address: ""
      ip: ""
      port: 9999            # 不配则绑定为 0（Java int 默认），见瑕疵③
      log-path: ./xxl-job/logs
      log-retention-days: 30
```

3. 在业务 Bean 方法上标 `@XxlJob`，由调度中心按 JobHandler 名回调：

```java
@Component
public class DemoJob {
    @XxlJob("demoJobHandler")
    public void run() {
        XxlJobHelper.log("被调度中心触发");
    }
}
```

## 模块特性总结

- **极简、零内部耦合**：2 类、无任何 i2f 内部 compile 依赖，仅把 `xxl-job-core` 执行器装成 Bean，语义与官方样例等价。
- **条件化到位**：`@ConditionalOnClass` 防缺包、`@ConditionalOnExpression` 给总开关，未引入 xxl-core 的应用零副作用。
- **全生命周期外包**：注册、心跳、内嵌 server、`@XxlJob` 扫描、调度回调、日志清理全由 `XxlJobSpringExecutor`（`SmartInitializingSingleton`/`DisposableBean`）自管，Starter 无需 `@Bean(initMethod)`。

## 模块瑕疵或错误

1. **【自动配置类缺 `@Configuration`，走 lite 模式】**：`XxlJobAutoConfiguration` 被登记进 `spring.factories` 的 `EnableAutoConfiguration` 与 `AutoConfiguration.imports`，却未标 `@Configuration`/`@AutoConfiguration`。含 `@Bean` 方法的类在无 `@Configuration` 时按 lite 模式处理，本类 `xxlJobExecutor` 无跨 `@Bean` 方法调用故暂未爆雷，但违背 Boot 2.7+ 自动配置规范（应 `@AutoConfiguration`），Full 模式类级增强不发生，风格脆弱（同 `spring-starter`/`totp-starter`/`swagger2-starter` 无 `@Configuration` 家族）。
2. **【`xxl.job.enable` 是零元数据、且非属性字段的隐式开关】**：`@ConditionalOnExpression("${xxl.job.enable:true}")` 读取 `xxl.job.enable`，但（a）`additional-spring-configuration-metadata.json` 从未登记该键，IDE 补全永不命中；（b）`XxlJobProperties`（prefix `xxl.job`）也无 `enable` 字段，该键仅被表达式读取、与 `@ConfigurationProperties` 无关。用 `@ConditionalOnExpression` 承载一个纯布尔开关也不如 `@ConditionalOnProperty(name="xxl.job.enable", matchIfMissing=true)` 规范。
3. **【八项 setter 无条件套用，把 Java 默认值灌进执行器覆盖 xxl-core 自身默认】**：`xxlJobExecutor` 对 `getPort()`（`int`，未配则 0）、`getLogRetentionDays()`（`int`，未配则 0）、`getAdmin().getAddresses()`（未配则 `null`）等一律 `setXxx(...)`。因 `XxlJobProperties` 所有字段无初始值，未配置的项会以 `0`/`null` 强制写入 `XxlJobSpringExecutor`，**覆盖掉 xxl-core 构造里的合理默认**（如默认端口 9999、日志保留策略对 `<0` 与 `0` 的不同语义），使「不配 = 用官方默认」不成立；`getAdmin()`/`getExecutor()` 若整段未配还会是 `null`，`properties.getAdmin().getAddresses()` 直接 NPE 启动失败。
4. **【元数据 `defaultValue` 与实际生效值不符，纯误导】**：元数据给 `port`（9999）、`addresses`、`log-path`、`log-retention-days`（30）、`appname`、`access-token` 等都标了 `defaultValue`，但 Spring Boot 的 `defaultValue` 只用于 IDE 提示、**不参与实际绑定**，真正缺省值取决于 Java 字段默认（见瑕疵③），二者不一致会让使用者误以为「不配也有 9999/30 天」。
5. **【`xxlJobExecutor` 缺 `@ConditionalOnMissingBean`】**：`@Bean XxlJobSpringExecutor` 无条件注册，宿主若因需定制（如接 `InetUtils` 自动取 IP，正是类内那段被注释的死指引所暗示的场景）而自带一个 `XxlJobSpringExecutor` Bean，将与本 Bean 冲突（两个同类型 `SmartInitializingSingleton` 各自注册/起 server），无法按同组惯例用 `@ConditionalOnMissingBean` 让位。
6. **【`@Data` + `@NoArgsConstructor` 滥用于自动配置类】**：`XxlJobAutoConfiguration` 无任何实例字段，`@Data` 仍生成 `equals/hashCode/toString`，`@NoArgsConstructor` 对配置类无意义；对 Spring 单例配置 Bean 施加这对注解是组内反复出现的反模式（同 `totp-starter` 等）。
7. **【`xxl-job-core` provided 但未标 optional】**：Boot 三件套均 `provided`+`optional=true`，而 `xxl-job-core` 只 `provided` 无 `optional`，风格不统一；虽 provided 本就不传递，但缺 `optional` 标记不影响消费方却与组内约定偏离，且实际要求宿主必须自行再引 xxl-core（见使用方法①），文档/sample 未强调此点。
8. **【sample/元数据 log-path 默认值拼写 `xxj-job`（j/l 转置）】**：`additional-spring-configuration-metadata.json` 与 `sample/application-xxljob.{properties,yml}` 的默认日志路径均写成 `./xxj-job/logs`（应为 `xxl-job`），仓库根目录确实生成了 `xxj-job\logs\gluesource` 残留目录，印证拼写错误已落到实际运行产物。
9. **【类内「多网卡 InetUtils 定制注册 IP」注释是死指引】**：`XxlJobAutoConfiguration` 末尾 15 行大注释教用户引 `spring-cloud-commons` 的 `InetUtils` 自动取 IP，但本 Starter 无任何实现——只暴露一个必须手填的 `executor.ip`，注释描述的自动化能力不存在，易误导。
10. **【保留上游 `@author xuxueli 2017-04-28` 与空 `@desc`】**：`XxlJobAutoConfiguration` 直接沿用官方样例作者与日期注释，`XxlJobProperties` 的 `@desc` 为空；改造为 Starter 后未补本模块说明。
11. **【唯一疑似消费方 `test-xxl-job` 已注释掉本 Starter，属未经运行验证的孤岛】**：`i2f-springboot/test-xxl-job/pom.xml` 第 31-35 行把 `i2f-springboot-xxl-job-starter` 依赖整段注释、改为直接依赖 `xxl-job-core`，但其 `application.properties` 仍保留全量 `xxl.job.*` 配置（现绑定不到本 Starter 的属性类、也不产生执行器 Bean）。即：仓库内没有任何模块真正装配验证过本 Starter 的自动配置路径，`@ConfigurationProperties`/`@Conditional*` 生效性未经运行时检验。

## 生态位置

- **归属**：`i2f-springboot` 组，分布式定时任务（xxl-job）执行器接入专项 Starter。
- **上游依赖**：无 i2f 内部 compile 依赖，仅桥接社区 `com.xuxueli:xxl-job-core:2.4.1`（provided）。
- **下游消费**：无活跃消费方——`test-xxl-job` 注释掉本 Starter 改用 xxl-core 直连，仓库内暂无模块经本 Starter 装配。
- **定位小结**：它是官方 `XxlJobConfig` 样例的「自动配置化」最小改版，职责单一、条件化做得到位；但**自动配置类缺 `@Configuration`、`xxl.job.enable` 零元数据且非属性字段、八项 setter 无条件套用把 Java 默认值灌入并可能 NPE、元数据 default 与实际脱节、缺 `@ConditionalOnMissingBean`**，加上唯一疑似消费方已绕过本 Starter，成熟度与可靠性均偏低。
