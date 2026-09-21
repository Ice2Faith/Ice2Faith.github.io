# i2f-springboot-quartz-starter

> Quartz 定时任务的 Spring Boot 自动装配 Starter：`QuartzAutoConfiguration` 装配 `SchedulerFactoryBean` 与 `Scheduler`，`SpringJobFactory` 让 Quartz 反射创建的 Job 实例接受 Spring 依赖注入，`QuartzScannerConfig` 在容器刷新时扫描 `i2f.springboot.config.quartz.scanner.base-packages` 下带 `@QuartzSchedule` 注解的方法，自动注册/更新为 Interval 或 Cron 触发器；底层扫描与调度能力来自内部依赖 `i2f-extension-quartz`。附带一份标准 `QRTZ_*` 建表 SQL 样例，支持持久化/集群化 JobStore。quartz、spring-boot-starter-quartz、c3p0 均为 provided+optional，使用方自行引入。

## 模块路径

- `i2f-springboot/i2f-springboot-quartz-starter`

## 模块依赖

| groupId | artifactId | scope | optional | 说明 |
|---------|-----------|-------|----------|------|
| i2f.turbo | i2f-extension-quartz | compile | 否 | 内部依赖，提供 `QuartzScanner`/`QuartzJobMeta`/`@QuartzSchedule`/`QuartzAnnotationJob`/`QuartzUtil` 等注解驱动调度核心 |
| org.projectlombok | lombok | compile | 否 | POJO 与日志代码生成 |
| org.springframework.boot | spring-boot-starter | provided | 是 | Boot 基础自动装配 |
| org.springframework.boot | spring-boot-configuration-processor | provided | 是 | 配置元数据处理器 |
| org.springframework.boot | spring-boot-starter-quartz | provided | 是 | Spring 对 Quartz 的 `SchedulerFactoryBean` 等支持 |
| org.quartz-scheduler | quartz (2.3.2) | provided | 是 | Quartz 调度器核心 |
| com.mchange | c3p0 (0.9.5.4) | provided | 是 | 连接池，供持久化/集群 JobStore 使用 |

> 说明：quartz / spring-boot-starter-quartz / c3p0 均 provided+optional 且不锁版本于使用方 classpath 之外，本 Starter 只做装配，不强绑定具体调度器版本；建表脚本位于 `src/main/resources/sample/data-store-init-mysql.sql`（11 张标准 `QRTZ_*` 表 + 一张自定义 `job_entity` 表）。

## 模块设计

### 架构设计

三条装配线协作：调度器生命周期、Job 实例注入、注解扫描驱动。

```mermaid
flowchart TD
    subgraph AC["QuartzAutoConfiguration"]
        SFB["@Bean schedulerFactoryBean()"]
        SCH["@Bean scheduler()"]
    end
    Props["i2f.springboot.config.quartz.*"] -->|@ConfigurationProperties| AC
    JF["SpringJobFactory (@Component)"] -->|setJobFactory| SFB
    SFB -->|getScheduler| SCH
    Sched["Scheduler"] -->|@Autowired| ScanC["QuartzScannerConfig"]
    Ev["ContextRefreshedEvent"] -->|onApplicationEvent| ScanC
    ScanC -->|"QuartzScanner.scanBasePackage"| Ext["i2f-extension-quartz"]
    ScanC -->|"QuartzScanner.makeSchedule"| Sched
    Ext --> Job["QuartzAnnotationJob (反射调用目标方法)"]
    JF -.->|autowireBean| Job
```

- **调度器层**：`QuartzAutoConfiguration`（`@Configuration` + `InitializingBean` + `@EnableScheduling`）以 `overwriteExistingJobs`/`startupDelay`/`configLocation` 三属性构建 `SchedulerFactoryBean`，并派生 `Scheduler` Bean。
- **注入层**：`SpringJobFactory` 继承 `AdaptableJobFactory`，重写 `createJobInstance` 对 Quartz 反射出的 Job 调 `autowireBean`，使 Job 内可用 `@Autowired`。
- **扫描层**：`QuartzScannerConfig` 监听 `ContextRefreshedEvent`，按 `base-packages` 扫描 `@QuartzSchedule` 方法，构建 `QuartzJobMeta`；若声明类在容器中恰有一个 Bean 则以其为 `invokeObj`（复用 Spring 单例），最终交 `QuartzScanner.makeSchedule` 注册或更新触发器。
- **配置探测**：`schedulerFactoryBean()` 遍历 `{configLocation, /application-quartz.properties, /application.properties}` 选择 classpath 配置源。

### 包结构

```
i2f.springboot.quartz
├── QuartzAutoConfiguration   // SchedulerFactoryBean / Scheduler 装配，读取 quartz 主配置
├── QuartzScannerConfig       // 容器刷新时扫描 @QuartzSchedule 方法并注册调度
└── SpringJobFactory          // AdaptableJobFactory，令 Quartz Job 接受 Spring 注入
```

## 模块目的

- 让 Quartz 在 Spring Boot 中开箱即用：一个开关即获得调度器、可注入的 Job 实例。
- 提供**注解驱动**的声明式定时任务：在方法上标 `@QuartzSchedule` 即完成注册，免去手写 `JobDetail`/`Trigger`/调度 API。
- 复用 Spring 容器管理的目标 Bean，保证被调度方法与业务对象依赖注入一致。
- 附带建表脚本，支持从内存到 JDBC 持久化/集群 JobStore 的平滑落地。

## 模块功能

| 功能 | 触发/条件 | 说明 |
|------|-----------|------|
| 装配 `SchedulerFactoryBean`/`Scheduler` | `i2f.springboot.config.quartz.enable=true`（默认） | 由 `overwriteExistingJobs`/`startupDelay`/`configLocation` 定制 |
| Quartz Job 依赖注入 | `SpringJobFactory` 注册 | `createJobInstance` 后 `autowireBean`，Job 内可注入 Spring Bean |
| 注解扫描注册调度 | `i2f.springboot.config.quartz.scanner.enable=true` 且配置 `base-packages` | 扫描 `@QuartzSchedule` 方法，Interval/Cron 建/更新触发器 |
| 复用 Spring 单例执行 | 声明类在容器恰有 1 个 Bean | 以该 Bean 作为 `invokeObj` 调用目标方法 |
| classpath 配置探测 | 自动 | 依次探测主配置/quartz/application.properties |

## 模块主要使用方法

### 1. 引入与基础配置

```yaml
i2f:
  springboot:
    config:
      quartz:
        enable: true
        startup-delay: 1
        overwrite-existing-jobs: true
        config-location: /quartz.properties
        scanner:
          enable: true
          base-packages: com.example.jobs
```

### 2. 注解声明定时任务

```java
@Component
public class ReportJob {
    @QuartzSchedule(name = "dailyReport", group = "report",
            type = ScheduleType.Cron, cron = "0 0 2 * * ? *")
    public void run() {
        // 业务逻辑，可 @Autowired 注入依赖
    }
}
```

### 3. 程序化获取调度器

```java
@Autowired
private Scheduler scheduler;
// 可直接调用 scheduler.scheduleJob(...) / pauseJob(...) 等原生 API
```

> 注意：使用方须自行引入 `spring-boot-starter-quartz`（或 `org.quartz-scheduler:quartz` + 数据源/连接池），本 Starter 中均为 provided；持久化/集群模式需执行 `sample/data-store-init-mysql.sql` 建表并在 `quartz.properties` 配置 JobStore。

## 配置项参考

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `i2f.springboot.config.quartz.enable` | Boolean | `true` | 是否启用调度器装配（`@ConditionalOnExpression` 读环境） |
| `i2f.springboot.config.quartz.overwrite-existing-jobs` | boolean | `true` | 集群/持久化下是否覆盖已存在 Job |
| `i2f.springboot.config.quartz.startup-delay` | int | `1` | 调度器启动延迟秒数 |
| `i2f.springboot.config.quartz.config-location` | String | `/quartz.properties` | classpath 下 quartz 配置探测首选路径 |
| `i2f.springboot.config.quartz.scanner.enable` | Boolean | `true` | 是否启用注解扫描（`@ConditionalOnExpression` 读环境） |
| `i2f.springboot.config.quartz.scanner.base-packages` | String | 无 | 逗号分隔的 `@QuartzSchedule` 扫描包，为空则跳过扫描 |

## 模块特性总结

- **注解驱动**：`@QuartzSchedule` 声明 Interval/Cron 任务，底层 `QuartzScanner` + `QuartzAnnotationJob` 反射执行。
- **容器感知注入**：`SpringJobFactory` 让 Quartz 实例化的 Job 支持 `@Autowired`。
- **单例复用**：扫描时优先用容器内唯一 Bean 作为调用目标，保持与业务依赖一致。
- **双开关解耦**：调度器与扫描器各由独立 `@ConditionalOnExpression` 控制。
- **幂等注册**：`makeSchedule` 对已存在 `TriggerKey` 走 `updateTrigger`，避免重复注册报错。
- **持久化就绪**：附带标准 `QRTZ_*` 建表脚本，支持 JDBC/集群 JobStore。
- **零版本绑定**：quartz/spring-boot-starter-quartz/c3p0 全 provided+optional。

## 模块瑕疵或错误

> 以下为按源码静态审阅识别的潜在问题，仅作标注、未做运行实证。

1. **配置探测形同虚设**：`rs = new ClassPathResource(item); if (rs != null)` 中 `new` 结果恒非 null，从不校验资源是否真实存在（应为 `rs.exists()`）。故候选链永远在首个非空项（默认 `/quartz.properties`）即 `break`，后续 `/application-quartz.properties`、`/application.properties` 降级永不到达，且当默认文件不存在时仍被 `setConfigLocation` 指向一个不存在资源。
2. **`scheduler()` 取值时机风险**：`scheduler()` 直接 `schedulerFactoryBean().getScheduler()`。`SchedulerFactoryBean` 的 `scheduler` 在其 `afterPropertiesSet()`/`createScheduler()` 后才非空；若 `scheduler` Bean 早于工厂初始化被创建，`getScheduler()` 可能返回 null 或抛 `IllegalStateException`。
3. **与 Spring Boot 自带 Quartz 自动配置冲突**：本模块 `scheduler` 与官方 `org.springframework.boot.autoconfigure.quartz.QuartzAutoConfiguration` 的 `quartzScheduler` 可能同时生效，产生两个 `Scheduler`；且三个 Bean 均无 `@ConditionalOnMissingBean`，用户无法优雅覆盖。
4. **缺类存在保护**：quartz 全为 provided+optional，但自动配置未加 `@ConditionalOnClass(Scheduler.class)` 等守卫；使用方未引入 quartz 时装配阶段即因类加载失败报错而非跳过。
5. **`SpringJobFactory` 以 `@Component` 混入自动配置登记**：它被同时写进 `spring.factories`/`AutoConfiguration.imports`（应仅登记 `@Configuration` 类），又在类上标 `@Component`；`QuartzAutoConfiguration` 依赖注入它，一旦其未被扫描/登记则注入失败，登记语义混乱。
6. **非唯一/无 Bean 目标类丢失注入**：`scanSchedules()` 仅当 `getBeansOfType(clazz).size()==1` 才设 `invokeObj`；当声明类非 Spring Bean（0 个）或多候选（>1）时 `invokeObj` 为 null，`QuartzAnnotationJob` 退化为 `ReflectResolver.getInstance` 裸实例化，绕过 Spring，其字段注入失效且无任何告警。
7. **`ContextRefreshedEvent` 重复扫描**：多上下文（父/子、Actuator）或多次刷新会重复触发 `scanSchedules()`，虽有 `updateTrigger` 兜底，但每次全量重扫存在冗余与并发风险。
8. **配置元数据拼写与缺项**：metadata 登记项写成 `i2f.springboot.config.quartz.scaner.enable`（`scaner` 拼写错误，与代码 `scanner` 不符）；且 `overwrite-existing-jobs`/`startup-delay`/`config-location`/`base-packages` 均未登记，IDE 自动补全缺失。
9. **`hints` 模板残留**：metadata 的 `hints` 仍是 `server.servlet.jsp.class-name`、`server.tomcat.accesslog.encoding` 等无关示例，未清理。
10. **异常吞没与日志混用**：配置探测 `catch` 内用 `System.out.println(e.getMessage())` 而非 logger，吞掉堆栈；`@Data`+`@NoArgsConstructor` 加于 `@Configuration` 类生成无意义的 equals/hashCode/构造器，`@EnableScheduling` 在两个配置类上重复标注。
