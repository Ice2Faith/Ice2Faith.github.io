# i2f-extension-slf4j-log

> SLF4J 绑定器扩展（slf4j-api `${slf4j.version}`=1.7.36 以 provided+optional 引入，DM 重复声明）：把 **SLF4J 1.x 的 `org.slf4j.impl.StaticLoggerBinder` 绑定协议**接到 **i2f-log 体系**上的反向桥——与 `i2f-extension-slf4j`（i2f 日志 API → SLF4J 门面）方向相反，本模块让任何使用 `LoggerFactory.getLogger(...)` 的第三方代码在 classpath 放入本 jar 后自动落到 i2f-log（`LoggerProvider` SPI 或 `StdioLogger` 兜底）。8 个主源文件分两层：`org.slf4j.impl` 包 5 个绑定器标准类（StaticLoggerBinder/StaticMarkerBinder/StaticMDCBinder + SimpleMarkerFactory + SimpleMdcAdapter，其中 Marker/MDC 系为 logback 同名类的手写简化复制）+ `i2f.extension.slf4j.log` 包 2 个适配器（`Slf4jLogLoggerAdapter` 375 行全覆写 SLF4J Logger 接口转发 `ILogger`；`Slf4jLogLoggerFactoryAdapter` 以 `LruMap(1024)` 缓存适配器实例）。零测试（仅 1 个 main 型验证），仓库内无源码级消费方（仅 i2f-extension-all 聚合）。**核心静态缺陷：SLF4J 的 `{}` 占位符语义在 i2f-log 侧完全失效**（`LogUtil.formatMsg` 走 printf `%` 语义），消息模板原样输出 + 参数以 `[0](Type)val` 尾巴追加。

## 模块路径

- `i2f-extension/i2f-extension-slf4j-log`
- 根 `pom.xml` 依赖管理（1235 行）；`i2f-extension/pom.xml` 模块登记（84 行）；`i2f-extension/i2f-extension-all` 聚合依赖（289 行）

## 依赖

| 依赖 | 版本 | 作用域 | 说明 |
|------|------|--------|------|
| org.slf4j:slf4j-api | ${slf4j.version}=1.7.36 | provided+optional | 绑定协议宿主 API；使用方须自带 compile 版本 |
| i2f.turbo:i2f-log | 1.0-jdk8 | compile | 落地目标：LoggerFactory/LoggerProvider/LogHolder |
| i2f.turbo:i2f-console-color | 1.0-jdk8 | compile | StdioLogger ANSI 着色传递依赖 |
| org.projectlombok:lombok | - | compile | 主源码零 import，仅测试 @Slf4j 使用（compile scope 会传递给消费方） |
| i2f-lru-map / i2f-trace-mdc | - | 传递 | 经 i2f-log→i2f-log-std 传递（LruMap 缓存 / 测试的 MdcHolder） |

## 架构设计

```mermaid
flowchart LR
    subgraph 用户代码
        A["LoggerFactory.getLogger()"]
    end
    subgraph slf4j-api 1.7.36
        A --> B["静态初始化<br/>javap 证实: invokestatic<br/>StaticLoggerBinder.getSingleton()"]
    end
    subgraph org.slf4j.impl（本模块）
        B --> C[StaticLoggerBinder<br/>REQUESTED_API_VERSION=1.7.30]
        C --> D[Slf4jLogLoggerFactoryAdapter<br/>LruMap 1024 缓存]
        B -.Marker.-> E[StaticMarkerBinder→SimpleMarkerFactory]
        B -.MDC.-> F[StaticMDCBinder→SimpleMdcAdapter<br/>copy-on-write ThreadLocal]
    end
    subgraph i2f.extension.slf4j.log（本模块）
        D --> G[Slf4jLogLoggerAdapter<br/>375 行全覆写 Logger 接口]
    end
    subgraph i2f-log
        G --> H["LoggerFactory.getLogger(location)<br/>再一层 LruMap 1024 缓存"]
        H --> I{LoggerProvider SPI<br/>系统属性→log.properties→ServiceLoader}
        I -->|命中| J[SPI ILogger 实现]
        I -->|未命中| K["StdioLogger 兜底<br/>ANSI 彩色 + System.out/err"]
        H -.冷启动竞态.-> K
    end
```

调用链：SLF4J `Logger` 方法 → `Slf4jLogLoggerAdapter` 转发（异常参数重排为 `ILogger` 的 `(ex, format, args)` 签名；Marker 版在适配器内判级并拼 `marker + " " + s` 进消息；非 Marker 版由 `ILogger` default 方法判级）→ `i2f-log` 的 `LoggerFactory.getLogger`（provider 探测 + 缓存）→ SPI 实现 / `StdioLogger`。

## 设计目的

1. **零侵入接管第三方日志**：业务引入的第三方库面向 SLF4J 编程时，无需改代码即可把日志落到 i2f-log 体系（统一格式/traceId/着色/级别控制），与 `i2f-extension-slf4j` 构成双向桥接对。
2. **补齐 SLF4J 三件套绑定**：Logger 之外同时提供 Marker 工厂与 MDC 适配器绑定，避免 `Failed to load class StaticMDCBinder` 类报错；`SimpleMdcAdapter` 是 i2f-trace-mdc 在「无第三方日志后端」场景下的 MDC 落地容器（配合 `MdcHolder` 使用）。

## 功能清单

| 文件 | 类型 | 职责 | 静态备注 |
|------|------|------|----------|
| org.slf4j.impl.StaticLoggerBinder | 绑定器 | SLF4J 1.x 标准 Logger 绑定入口，返回 FactoryAdapter 单例 | REQUESTED_API_VERSION=1.7.30 与 pom 1.7.36 双源漂移 |
| org.slf4j.impl.StaticMarkerBinder | 绑定器 | Marker 工厂绑定 | SimpleMarkerFactory 单例 |
| org.slf4j.impl.StaticMDCBinder | 绑定器 | MDC 适配器绑定 | getMDCA() 每次新建实例（SLF4J 仅单次调用，无实害） |
| org.slf4j.impl.SimpleMarkerFactory | Marker | ConcurrentHashMap 名字缓存 | detachMarker 不级联清理引用 |
| org.slf4j.impl.SimpleMarker | Marker | CopyOnWriteArrayList 引用树，logback BasicMarker 手写复制 | equals 接受任意 Marker 实现按名比较（比 logback 宽） |
| org.slf4j.impl.SimpleMdcAdapter | MDC | ThreadLocal copy-on-write，logback LogbackMDCAdapter 简化复制 | setContextMap(null) NPE；getKeys() 返 null |
| i2f...Slf4jLogLoggerFactoryAdapter | 工厂 | ILoggerFactory 实现 + LruMap(1024) 适配器缓存 | public static 可变 CACHE；与 i2f LoggerFactory 双层缓存 |
| i2f...Slf4jLogLoggerAdapter | 适配器 | 5 级 × {marker, 1/2/varargs, throwable} 全 60 方法覆写 | varargs 直通；异常混入参数丢堆栈；Marker 拼串 |

## 用法示例

```java
// 1. 使用方装配（本模块 slf4j-api 为 provided，须自带 API 依赖）
// classpath = slf4j-api:1.7.x + i2f-extension-slf4j-log + i2f-log
Logger logger = LoggerFactory.getLogger(MyService.class); // 自动绑定到 i2f-log

// 2. 消息渲染实际行为（核心缺陷现场）
logger.info("user={}, age={}", "tom", 25);
// SLF4J 预期: user=tom, age=25
// 实际输出:  user={}, age={} [0](String)tom, [1](Integer)25   ← {} 不替换

// 3. printf 风格恰好可用（% 占位符）
logger.info("user=%s age=%s", "tom", 25); // user=tom age=25（printf 语义）

// 4. 异常堆栈保留路径（ex 独立参数版本）
try { risky(); } catch (Exception e) { logger.error("failed", e); } // 堆栈 OK
logger.error("failed {}", e); // 堆栈丢失：e 被当普通参数 toString

// 5. MDC 绑定（i2f-trace-mdc 的 MdcHolder 经 ServiceLoader 可选 Slf4jMdcManager，
//    或直接走 org.slf4j.MDC → SimpleMdcAdapter）
org.slf4j.MDC.put("traceId", "t-123");
logger.info("msg"); // MDC 渲染依赖 ILogger 实现是否读取

// 6. SPI 选择落点（i2f-log 侧配置，非本模块能力）
// -Dlogger.provider.class=xxx | META-INF/log.properties | -Dlogger.provider.spi.select.name=xxx
// 未配置时 StdioLogger 兜底（WARN 及以上走 System.err，其余 System.out，ANSI 着色）
```

## 特性总结

- **标准绑定协议**：javap 静态证实 slf4j-api 1.7.36 `LoggerFactory` 经 `StaticLoggerBinder.getSingleton()` 反射绑定，本模块在 `org.slf4j.impl` 包的标准类名/单例/`REQUESTED_API_VERSION` 三要素齐备，1.7.x 线内即放即用。
- **全量接口覆写**：`Slf4jLogLoggerAdapter` 对 SLF4J Logger 全部 5 级 × 12 形态方法逐一手写转发，异常参数按 `ILogger` 的 `(ex, format, args)` 签名重排，无反射分发开销。
- **MDC/Marker 自包含**：不依赖 logback 即提供 MDC（copy-on-write ThreadLocal）与 Marker（引用树）的最小实现，三绑定器一次到位。
- **双缓存架构**：适配器层与 i2f-log 层各持 `LruMap(1024)`，location→Adapter→ILogger 两级去重。
- 与 `i2f-extension-slf4j` 构成**方向相反的双向桥对**：后者把 i2f 日志代码接到 SLF4J 后端，本模块把 SLF4J 代码接到 i2f 后端；两者同 classpath 共存时不构成环（本模块落 `ILogger` SPI，后者落 `org.slf4j.Logger`），但均改写 `MdcHolder` 的 SPI 选中结果。

## 已知问题（静态识别，未实证）

1. **【核心】SLF4J `{}` 占位符语义完全失效**：适配器把 `(format, args)` 直通 `ILogger`，而 `AbsLogger.formatMsg → LogUtil.formatMsg` 按 **printf `%`** 计数并 `String.format(format, args)`，无 `%` 时占位符计数 0 → 原样返回后走 fallback 把参数以 `[0](Type)val, [1](Type)val` 尾巴追加——`log.info("a={}, b={}", 1, 2)` 输出 `a={}, b={} [0](Integer)1, [1](Integer)2`。所有依赖 `{}` 渲染的既有日志（第三方库存量代码的大多数）在本桥下全部失真。
2. **消息中偶发 `%` 被 printf 解释**：`"进度 50%"`、`"100%done"` 等自然文本中的 `%` 进入 `String.format`，非法转换符抛异常被静默 catch 后转 fallback；`"%s"` 类字面量则被误替换为参数——消息内容直接改变输出行为。
3. **异常混入 varargs 丢堆栈**：SLF4J 1.7 约定「最后一个 Throwable 从占位符消耗中剥离并打印堆栈」；本链路 `info(String, Object...)` 把异常对象当普通参数送入 `formatMsg`（仅 toString），堆栈静默丢失——只有适配器独立重排的 `error(String, Throwable)` 等专用重载保留堆栈。
4. **SLF4J 2.x 断代**：`StaticLoggerBinder` 机制为 1.7.x 专属（2.x 改 ServiceLoader `SLF4JServiceProvider`）；classpath 升级 slf4j-api 2.x 后本绑定失效，SLF4J 找不到 provider 回落 NOP 并告警。`REQUESTED_API_VERSION=1.7.30` 与 `${slf4j.version}=1.7.36` 硬编码双源漂移，同线兼容但无单一事实源。
5. **Marker 语义全灭**：Marker 仅被 `marker + " " + s` 拼进消息串，无过滤/标记传播语义（下游 `ILogger` 无 Marker 概念）；依赖 Marker 过滤的框架行为（如 logstash 标记）静默失效。
6. **冷启动竞态固化 StdioLogger**（i2f-log-std 侧，本模块消费链坐实）：`LoggerFactory.getLogger` 中 `hasFindProvider.getAndSet(true)` 后，并发线程在 provider 加载完成前进入 `loggerProvider == null` 分支落 `StdioLogger` 并**永久写入缓存**，provider 就绪后不刷新——应用启动高峰期最先打日志的 location 可能永远走兜底实现。
7. **双层缓存冗余与可变性**：`Slf4jLogLoggerFactoryAdapter.CACHE` 与 i2f `LoggerFactory.CACHE` 各一个 `LruMap(1024)`，同 location 两条缓存项；两个 `public static` 可变缓存字段可被外部整体替换/清空，无访问封装。
8. **SimpleMdcAdapter 边界缺失**：`setContextMap(null)` 直接 `putAll(null)` NPE（logback 原版对 null 容错为 clear）；自有方法 `getKeys()` 在无上下文时返回 `null` 而非空 Set，调用方 NPE 面；`getPropertyMap()` 返回内部 map 直接引用（copy-on-write 机制下仅写入方复制，读方持有可变引用）。
9. **SimpleMarkerFactory.detachMarker 不级联**：名字从缓存移除后，仍被其他 marker `referenceList` 持有的实例不会被回收；`getDetachedMarker` 每次新实例（语义符合但无文档说明与 getMarker 实例不相等）。
10. **StdioLogger 兜底输出侧**：ANSI 着色默认开启（`stdout=true`），Windows 传统 cmd/重定向文件时输出转义序列乱码；日志时间格式 `MM-dd HH:mm:ss.SSS` 无年份且经 `ThreadLocal<SimpleDateFormat>` 持有（`@Data` setter 可整体替换）；异常堆栈 printStackTrace 进内存流拼入消息（大堆栈字符串化）。
11. **判级层次冗余**：Marker 版在适配器 `isXxxEnabled` + 拼 marker 后调 `ILogger`（其 default 方法内部再 `enableXxx` 判级一次）——同一调用双重判级；两处判级依据不同来源（适配器取 `logger.enableXxx()`，ILogger 取 `enableLevel(level)`），若自定义 ILogger 两口径不一致时行为分裂。
12. **i2f-log-std 侧 default 方法判级错乱**（生态提示，本模块依赖链暴露面）：`ILogger` 的 `errorMetaArgs/errorArgs/warnMetaArgs/infoMetaArgs/infoArgs` 等约 10 个 default 方法复制粘贴使用 `enableFatal()` 判级——本模块适配器未调用这批方法（只走 `enableXxx/write` 主线），但同 classpath 的 i2f 直用代码会踩中。
13. **绑定竞争风险（聚合层）**：SLF4J 1.x 多绑定冲突语义——若消费方同时引入 logback-classic/slf4j-log4j12 与本模块（例如经 `i2f-extension-all` 聚合连带），SLF4J 按类路径顺序挑第一个并警告，绑定结果不可预期；`i2f-extension-all` 聚合本绑定器但无任何排除机制。
14. **工程项**：DM 重复声明 slf4j-api（根 POM 属性已管版本）；lombok 主源码零 import（仅测试 `@Slf4j`）且 compile scope 会传递给消费方；`maven-assembly-plugin addMavenDescriptor` 对纯库无意义；`StaticMDCBinder.getMDCA()` 每次新建（MDC 单次调用契约下无实害，但语义应为单例）；绑定器标准类无 `private` 构造保护；测试为 main 型（显式 cast `LogHolder.DEFAULT_DECIDER` + `Thread.sleep` + System 副作用），零 JUnit。

## 生态位置

| 角色 | 模块 | 关系 |
|------|------|------|
| 绑定宿主 | slf4j-api 1.7.36 | provided+optional，使用方自带 compile 版本 |
| 落地后端 | i2f-log → i2f-log-std | LoggerProvider SPI / StdioLogger 兜底 |
| 反向桥对 | i2f-extension-slf4j | 方向相反的双向桥（i2f 代码 → SLF4J 后端） |
| MDC 配套 | i2f-trace-mdc（传递） | MdcHolder ServiceLoader 可选 Slf4jMdcManager（另一模块），本模块提供 slf4j MDC 容器 |
| 聚合 | i2f-extension-all | 收录（有绑定竞争风险，见已知问题 13） |

- 仓库内**无源码级消费方**：本模块面向「用户应用」的 classpath 装配场景，仓库内零 Java 引用、零集成验证。
- 与 `i2f-extension-log-slf4j`（SLF4J 1.x `StaticLoggerBinder` 绑定到 i2f-log 的兄弟实现）功能高度重叠——上一轮生态调查中提及的「反向绑定」即本模块与该兄弟模块共同承担；具体取舍由使用者显式引哪个 jar 决定，仓库内无仲裁机制。
