# i2f-springboot-xproc4j-starter

> XProc4J「去数据库存储过程」引擎的 Spring Boot 全量装配 Starter —— 把上游 `i2f-extension-xproc4j`（`i2f.jdbc.procedure.*`）的 XML/Java 存储过程执行内核接进 Spring 容器，一次性完成「环境注入 + 过程注册 + 执行装配 + 脚本函数扩展 + 声明式代理 Mapper + AI Provider」五件事：`SpringContextJdbcProcedureExecutorAutoConfiguration` 以约 15 个各带独立 `@ConditionalOnExpression`+`@ConditionalOnMissingBean` 的 `@Bean`，把 `INamingContext`(SpringContext)/`IEnvironment`(SpringEnvironment)/`XProc4jEventHandler`/两套 `DataSourceProvider`（baomidou `DynamicRoutingDataSource` 与 Spring `AbstractRoutingDataSource`）/XML 过程元数据扫描器（`SpringJdbcProcedureXmlNodeMetaCacheProvider` + 目录 watch 热更新）/Java caller provider/注册表/`JdbcProcedureContext`/`JdbcProcedureExecutor`（按 `enable-funic` 选 `FunicJdbcProcedureExecutor` 或 `DefaultJdbcProcedureExecutor`）+ 慢 SQL 阈值/日志器/语法报告器/预加载与调用日志监听器逐组装配；`SpringExtensionJdbcProcedureAutoConfiguration` 把 `spring_bean`/`spring_env`/`redis_*`/`log_*`/`to_json`/`http_get` 等静态方法注册进上游 `ContextHolder` 全局函数表供脚本调用；`SpringJdbcProcedureProxyMapperAutoConfiguration`（`BeanDefinitionRegistryPostProcessor`）扫描 `@ProcedureMapper` 接口用 `FactoryBean`+JDK 动态代理注册为「方法名匹配过程 id、参数按名/序回填」的声明式 Mapper；`JdbcProcedureHelper` 提供 `call/invoke` 静态统一入口。本模块 23 源文件、直接依赖 6 个 i2f 内部 compile 模块（`i2f-extension-xproc4j`/`-antlr4`/`-ognl`/`i2f-spring-core`/`-ai-dashscope`/`-ai-openai`），velocity/ognl/antlr4/dynamic-datasource/redisson/dashscope-sdk/spring-web 全 `provided`+`optional`，是 i2f-springboot 组内**依赖面最广、装配最重**的专项 Starter，也是**少数有仓库内真实消费方**（`i2f-tools-ops` compile 依赖、未注释）的模块。

## 模块路径

- `i2f-springboot/i2f-springboot-xproc4j-starter`

## 模块依赖

| GroupId | ArtifactId | Scope | Optional | 说明 |
|---------|------------|-------|----------|------|
| org.projectlombok | lombok | compile | 否 | `@Data`/`@Slf4j` |
| org.springframework.boot | spring-boot-starter | provided | 是 | Boot 自动配置基础 |
| org.springframework.boot | spring-boot-configuration-processor | provided | 是 | 元数据处理器 |
| org.springframework.boot | spring-boot-starter-web | provided | 是 | `RestTemplate`/`ObjectMapper`（`SpringWebFunctions`） |
| i2f.turbo | i2f-extension-xproc4j | compile | 否 | 核心：`i2f.jdbc.procedure.*` 执行引擎 |
| i2f.turbo | i2f-extension-antlr4 | compile | 否 | 过程脚本语言（Funic/TinyScript）底座 |
| i2f.turbo | i2f-extension-ognl | compile | 否 | OGNL 求值 |
| i2f.turbo | i2f-spring-core | compile | 否 | `SpringContext`/`SpringEnvironment` 桥接 |
| i2f.turbo | i2f-extension-ai-dashscope | compile | 否 | DashScope AI Provider |
| i2f.turbo | i2f-extension-ai-openai | compile | 否 | OpenAI AI Provider |
| org.apache.velocity | velocity-engine-core:2.3 | provided | 是 | 过程内模板渲染（间接） |
| ognl | ognl:3.4.11 | provided | 是 | OGNL 运行时 |
| org.antlr | antlr4-runtime:4.13.2 | provided | 是 | ANTLR 运行时 |
| com.baomidou | dynamic-datasource-spring-boot-starter:3.5.2 | provided | 是 | baomidou 多数据源路由（`@ConditionalOnClass`） |
| org.redisson | redisson-spring-boot-starter:3.20.1 | provided | 是 | Redisson 锁函数 `redis_lock`/`redis_unlock` |
| com.alibaba | dashscope-sdk-java:2.22.12 | provided | 是 | DashScope `Generation`（排除 slf4j） |

> 编译期还经 `i2f-extension-xproc4j`/`i2f-spring-core` 传递引入 `i2f-jdbc-procedure`、`i2f-context-std`、`i2f-environment-std`、`i2f-resources`、`i2f-lru`、`i2f-reflect`、`i2f-proxy`、`i2f-convert`、`i2f-invokable`、`i2f-typeof` 等（源码直接 import 但未在 pom 直声明）。

## 模块设计

```mermaid
flowchart TD
    subgraph 阶段["xproc4j.enable（默认 true）总开关"]
        A["SpringContextJdbcProcedureExecutorAutoConfiguration<br/>（无 @Configuration，lite，~15 @Bean）"]
    end
    A -->|形参注入| N["INamingContext ← SpringContext"]
    A --> E["IEnvironment ← SpringEnvironment"]
    A --> H["XProc4jEventHandler"]
    A -->|@ConditionalOnClass| DS["DataSourceProvider ×2<br/>baomidou(200)/spring(100)"]
    A --> XS["XML 过程元数据扫描 + 目录 watch 热更新"]
    A --> JS["Java caller provider"]
    XS --> REG["JdbcProcedureMetaProviderRegistry"]
    JS --> REG
    N --> REG
    REG --> CTX["JdbcProcedureContext"]
    CTX --> EXE["JdbcProcedureExecutor<br/>enableFunic 选 Funic/Default"]
    E --> EXE
    N --> EXE
    A --> LP["Slf4jJdbcProcedureLogger"]
    A --> GR["DefaultGrammarReporter"]
    A --> LS["调用日志/预加载/语法报告监听器"]
    EXE -.ApplicationRunner.run 预热 getMetaMap.-> A
    A -->|@Import| HELP["JdbcProcedureHelper<br/>静态 call/invoke + CountDownLatch"]

    P["SpringJdbcProcedureProxyMapperAutoConfiguration<br/>（BDRPP，xproc4j.proxy.enable）"] -->|扫描 @ProcedureMapper 接口| FB["SpringJdbcProcedureProxyMapperFactoryBean"]
    FB -->|JDK 代理| PH["ProxyJdbcProcedureMapperHandler<br/>方法名→过程id→executor.call"]
    PH --> EXE

    EXT["SpringExtensionJdbcProcedureAutoConfiguration<br/>（@Configuration，InitializingBean）"] -->|registryAllInvokeMethods| CH["上游 ContextHolder 全局函数表<br/>spring_bean/redis_*/log_*/to_json"]

    DASH["DashScopeAiAutoConfiguration<br/>@ConditionalOnClass(Generation)"] --> DASHB["DashScope Chat/RoleChat Provider"]
    OPEN["OpenAiAiAutoConfiguration<br/>@ConditionalOnClass(Generation) ⚠错用 DashScope 类"] --> OPENB["OpenAI Chat/RoleChat Provider"]
```

## 模块目的

让 Spring Boot 应用「引入即得」一整套 XML/Java 存储过程能力：把容器的 `ApplicationContext`/`Environment`/各类 `DataSource` 注入过程执行上下文，把 Spring Bean 与脚本函数暴露给过程引擎，把配置目录下的 `procedure/**/*.xml` 与带注解的 Java 方法注册为可调用的具名过程，并提供 `JdbcProcedureHelper.call()` 静态入口与 `@ProcedureMapper` 声明式接口两条调用姿势，最后附带把 DashScope/OpenAI 大模型 Provider 一并条件装配进过程可引用的上下文。

## 模块功能

- **环境注入**：`SpringContext`→`INamingContext`、`SpringEnvironment`→`IEnvironment`，供过程内按名取 Bean/读属性。
- **数据源路由**：两套 `DataSourceProvider`（baomidou `DynamicRoutingDataSource` order 200、Spring `AbstractRoutingDataSource` order 100），把多数据源暴露给过程 `sql-*` 节点，Spring 版按 key 去尾 `datasource` 归一名。
- **XML 过程扫描 + 热更新**：`SpringJdbcProcedureXmlNodeMetaCacheProvider` 用 `PathMatchingResourcePatternResolver` 并发解析 `xml-locations`，`DirectoryWatchingJdbcProcedureXmlNodeMetaCacheProvider` 监听目录（并把 `target/classes` 反推为 `src/main` 源码目录便于开发期热改）变化重扫。
- **执行器装配**：按 `enable-funic` 选 `FunicJdbcProcedureExecutor` 或 `DefaultJdbcProcedureExecutor`，套用慢 SQL/节点/过程阈值、debug、主数据源名、语法报告选项、预加载上限。
- **脚本函数扩展**：把 `spring_bean`/`spring_type_bean`/`spring_env`/`redis_set/get/del/ttl/inc/dec`/`redis_lock/unlock`/`log_info/warn/error/...`/`to_json/parse_json/http_get_*` 注册进上游 `ContextHolder` 全局表。
- **声明式代理 Mapper**：`@ProcedureMapper` 接口经 BDRPP 注册为 `FactoryBean`+JDK 代理，方法按 `@ProcedureId`/方法名/去下划线弱匹配定位过程，参数按形参名/序号/`@ProcedureParam` 三通道回填，返回值按 `Map`/基础类型/POJO 复制。
- **AI Provider 条件装配**：DashScope、OpenAI 各产 `Chat`/`RoleChat` 两个 Provider，`api-key` 走 `@Value` + 上游 `getPossibleApiKey` 环境变量兜底。
- **静态门面**：`JdbcProcedureHelper.call/invoke` 以 `CountDownLatch` 等待上下文就绪后转发执行器。

## 模块主要使用方法

1. 引入本 Starter，宿主自备过程运行时（`i2f-extension-xproc4j` 已 compile 传递；velocity/ognl/antlr4/dynamic-datasource/redisson/dashscope 均 `provided` 需按需用到再自行添加）：

```xml
<dependency>
    <groupId>i2f.turbo</groupId>
    <artifactId>i2f-springboot-xproc4j-starter</artifactId>
    <version>1.0-jdk8</version>
</dependency>
```

2. 配置过程来源（默认已含 `classpath*:procedure/**/*.xml`），声明式 Mapper 需显式指定扫描包（见瑕疵③）：

```yaml
xproc4j:
  enable: true
  xml-locations: classpath*:procedure/**/*.xml
  mapper-packages: com.demo.procedure   # 不设则代理扫描为空，@ProcedureMapper 不生效
  enable-funic: false
dashscope:
  ai:
    api-key: sk-xxxx
```

3. 静态或代理方式调用过程：

```java
Map<String, Object> res = JdbcProcedureHelper.call("user.getByAge", 18);

@ProcedureMapper
public interface UserProc {
    @ProcedureId("user.getByAge")
    Map<String, Object> getByAge(@ProcedureParam("age") int age);
}
```

## 模块特性总结

- **五合一装配**：环境/数据源/过程注册/脚本函数/代理 Mapper/AI Provider 一次到位，是本组功能最密集的 Starter。
- **可覆盖性好**：执行器路径下约 15 个 `@Bean` 基本都带 `@ConditionalOnMissingBean`，宿主可逐点替换。
- **两套数据源路由 + 两类入站热更新**：兼容 baomidou 与 Spring 原生 `AbstractRoutingDataSource`，XML 目录 watch 支持开发期免重启。
- **`@ConditionalOnClass` 分环境生效**：dynamic-datasource、redisson、dashscope 缺席时对应 Bean/函数自动退避。
- **有真实消费方**：`i2f-tools-ops` 以未注释 compile 依赖引入，装配路径经生产工程引用（区别于组内多个「生态孤岛」Starter）。

## 模块瑕疵或错误

1. **【高危·脚本函数注册顺序/遗漏 bug】** `SpringExtensionJdbcProcedureAutoConfiguration.afterPropertiesSet` 在 `SpringContextFunctions.applicationContext` 赋值（L42）**之前**先 `ContextHolder.registryAllInvokeMethods(SpringContextFunctions.class)`（L40），随后又对同一类重复注册（L43）；而 **`SpringEnvironmentFunctions`、`SpringSlf4jFunctions` 从未注册**。上游 `ContextHolder` 按全局方法名建表、未注册即查不到，故过程脚本里 `spring_env()` 与全部 `log_*()` 函数静默不可用。L40 显然是把 `SpringEnvironmentFunctions.class` 误写成 `SpringContextFunctions.class` 的复制粘贴错误。
2. **【高危·OpenAI 配置错用 DashScope 门控】** `OpenAiAiAutoConfiguration` 的进入条件是 `@ConditionalOnClass(com.alibaba.dashscope.aigc.generation.Generation.class)`（DashScope 的类），并 `import i2f.extension.ai.dashscope.impl.DashScopeAi`、调用 `DashScopeAi.getPossibleApiKey(apiKey)` 解析 OpenAI 的 key——整段从 `DashScopeAiAutoConfiguration` 复制。后果：**只引入 openai 运行时而不含 dashscope-sdk 时，OpenAI Provider 因 `Generation` 类缺失被 `@ConditionalOnClass` 挡下、静默不装配**；反之引入 dashscope 才误激活。
3. **【高危·声明式 Mapper 默认扫描永不触发】** `SpringJdbcProcedureProperties.mapperPackages` 默认值是 `new ArrayList<>()`（非 null），BDRPP 中 `if (mapperPackages != null)` 恒真，`else` 分支的 `**.procedure.**`/`**.proc.**`/`**.xproc.**` 兜底模式**永不执行**；用户不显式配 `xproc4j.mapper-packages` 时待扫包集合为空 → 不匹配任何 `.class` 资源 → `@ProcedureMapper` 接口不会被注册为代理 Bean，「开箱即用注解代理」名不副实。
4. **两个核心自动配置类无 `@Configuration` 走 lite 模式**：`SpringContextJdbcProcedureExecutorAutoConfiguration`、`SpringJdbcProcedureProxyMapperAutoConfiguration` 登记进 `EnableAutoConfiguration`/`AutoConfiguration.imports` 却无 `@Configuration`/`@AutoConfiguration`（当前 `@Bean` 方法均以形参注入依赖、无跨 `@Bean` 直调故暂未爆雷，但风格脆弱；同 spring/totp/swagger2/xxl-job/zookeeper 家族）。且都被 `@Data` 标注，为容器 Bean 生成 `equals/hashCode/toString/getter/setter` 纯噪声。
5. **把 `BeanDefinitionRegistryPostProcessor` 当自动配置类经 spring.factories 注册是反模式**：BDRPP 生命周期极早，而 auto-configuration 由 `ConfigurationClassPostProcessor`（其自身即 BDRPP）解析，二者叠加使 `@ConditionalOnExpression("xproc4j.proxy.enable")` 的求值与该 BDRPP 的实例化时机强耦合、不可靠；`postProcessBeanDefinitionRegistry` 内 `Class.forName` 与整个方法体被 `catch (Exception e){ log.error }` 包裹，单个接口扫描/注册失败被吞、无局部跳过错处理。
6. **开关键名含错别字**：`@ConditionalOnExpression("${xproc4j.spring-routring-datasource.enable:true}")` ——「routring」多字母（应 routing），该键名本身拼错，用户按直觉写 `spring-routing-datasource.enable=false` 无法命中，Spring 数据源路由提供器关不掉。
7. **Bean 依赖与条件不成对可致启动失败**：`jdbcProcedureExecutor()`（受 `xproc4j.executor.enable`）形参**强制**依赖 `JdbcProcedureContext`/`IEnvironment`/`INamingContext`，`procedureContext()`（受 `xproc4j.context.enable`）强制依赖 `registry` 参数（受 `provider.registry.enable`）。各开关彼此独立，一旦关掉上游 `context.enable`/`registry.enable` 而保留下游开，`@Bean` 必填参数无候选 → `NoSuchBeanDefinitionException` 启动失败。
8. **元数据登记大面积缺失**：真实存在却零登记的键含 `xproc4j.baomidou-routing-datasource.enable`、`xproc4j.spring-routring-datasource.enable`、`xproc4j.procedure-meta.script-preload.enable`、`xproc4j.enable-funic`、`xproc4j.max-preload-count`、`xproc4j.primary-datasource-names`、`xproc4j.report-options.check-*`（6 项）、全部 `dashscope.ai.*`/`openai.ai.*`；`hints` 段是别处拷贝来的 `server.servlet.jsp.class-name`/`server.tomcat.accesslog.encoding` 死条目（全组通病）。
9. **元数据描述复制粘贴错误**：`xproc4j.xml-locations`、`xproc4j.watching-directories`、`xproc4j.refresh-xml-interval-seconds` 三条 `description` 均以「whether enable auto-configuration for ...」开头——它们是取值/间隔设置而非布尔开关，照抄 enable 条目文案，误导 IDE 提示。
10. **`JdbcProcedureHelper` 静态闩锁脆弱**：`latch` 是 `CountDownLatch(1)` 仅在 `setApplicationContext` 里 `countDown`，而 helper 只被 `@Import`（即 `xproc4j.enable=true` 才创建）。若在总开关关闭、或 helper Bean 尚未就绪前调用 `JdbcProcedureHelper.call/invoke`，`latch.await()` **永久阻塞**；且 `await` 的 `catch (Exception e){}` 吞 `InterruptedException` 不恢复中断位；`getExecutor()` 用 `synchronized (latch)`（拿闩锁对象当监视器）语义可疑。
11. **`run()` 预热用裸线程且吞失败**：`new Thread(...).start()` 非守护、无异常处理，线程内 `applicationContext.getBean(JdbcProcedureContext.class)` 若 context Bean 被关闭或时机未到即抛异常，线程静默死亡，`getMetaMap()` 预热目的落空且无任何告警。
12. **代理 Handler 未处理 `equals`、报错信息失真**：`ProxyJdbcProcedureMapperHandler.invoke` 特判了 `toString`/`hashCode` 却漏 `equals(Object)`——对代理调用 `equals` 会被当作过程名去 `metaMap` 解析、最终抛「missing procedure meta」；末段 `throw ...("missing procedure meta for id=" + callId)` 处 `callId` 恒为 `null`，应打印被调方法名/注解 id，排障信息无效。
13. **AI Provider Bean 缺 `@ConditionalOnMissingBean`、配置来源双路径**：`DashScope*`/`OpenAI*` 四个 Provider `@Bean` 均无 `@ConditionalOnMissingBean`，宿主自定义同类 Bean 会构成多候选注入歧义；`api-key` 走 `@Value("${...api-key:}")` 空默认再交上游 `getPossibleApiKey` 读环境变量兜底，双来源却完全未登记元数据。
14. **`@Data`/`@NoArgsConstructor` 滥用与 IO 异常吞没**：`Slf4jJdbcProcedureLogger`、`SpringJdbcProcedureXmlNodeMetaCacheProvider`、`ReportOptions` 等多处数据注解泛滥；`SpringJdbcProcedureXmlNodeMetaCacheProvider.parseResources` 里 `resourcePatternResolver.getResources` 的 `catch (IOException e){}` 完全吞异常不记日志——某个 `xml-locations` 解析失败无痕迹；成员 `ForkJoinPool` 创建后从不调用 `shutdown`。
15. **属性命名空间异类**：本 Starter 占用裸 `xproc4j.*`、`dashscope.ai.*`、`openai.ai.*` 顶级键（无 `i2f.` 组前缀），与组内 `i2f.*`/`i2f.spring.*` 主流命名割裂，顶级键易与第三方组件撞名。
16. **数据源取用在运行期才暴露**：`SpringRoutingDataSourceProvider`/`BaomidouDynamicRoutingDatasourceProvider.getDataSources()` 用 `namingContext.getBean(...)` 取路由数据源，宿主未配对应 Bean 时 `getBean` 抛 `NoSuchBean`（baomidou 版还直接 `bean.getDataSources()` 不判空），延迟到过程执行阶段而非启动期暴露。
17. **源码目录内嵌 readme 与实现不符**：`src/main/java/.../readme.md` 放于 java 源码目录，且描述称「带 `@JdbcProcedure` 注解的 bean 当具名过程」，而本模块代理注解实为 `@ProcedureMapper`/`@ProcedureId`/`@ProcedureParam`，文档与实现命名不一致。

## 生态位置

- **上游**：`i2f-extension-xproc4j`（`i2f.jdbc.procedure.*` 引擎，见 `i2f-extension-xproc4j` 文档，其 readme 已把本 Starter 记为「有真实深度消费方」）、`i2f-spring-core`（`SpringContext`/`SpringEnvironment`）、`i2f-extension-antlr4`/`-ognl`（脚本语言/求值）、`i2f-extension-ai-dashscope`/`-ai-openai`（AI Provider）。
- **下游消费方**：`i2f-tools-ops`（compile 依赖、未注释）——是本组内少数被生产工程实际引用的专项 Starter。
- **构建登记**：`i2f-springboot/pom.xml` L49 `<module>`；根 `pom.xml` `dependencyManagement` L1494 以 `${i2f.version}` 登记版本。
- **定位**：i2f-springboot 组内**功能最全、依赖面最广、装配最重**的专项 Starter，把「XML/Java 存储过程 + 脚本函数 + 声明式代理 + 多数据源 + AI」收敛为一个 `xproc4j.enable` 总开关下的重型装配层。
