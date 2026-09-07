# i2f-log-std & i2f-log — 日志标准定义与完整实现体系

## 概述

`i2f-log-std` 是项目的日志标准定义模块，定义了 `ILogger` / `LoggerFactory` / `LoggerProvider`
等核心接口和抽象类，采用门面设计模式，提供零外部依赖的日志门面抽象。`i2f-log` 是基于 `i2f-log-std`
构建的完整日志实现模块，提供配置系统、日志级别决策、格式化、多种输出目标（控制台/文件/JDBC/广播）、`System.out/err` 重定向等能力。

两个模块共同构成项目的日志基础设施，支持 SPI 扩展和 properties 文件配置，完全兼容 JDK8。

## 模块信息

| 属性             | i2f-log-std     | i2f-log     |
|----------------|-----------------|-------------|
| **ArtifactId** | `i2f-log-std`   | `i2f-log`   |
| **父模块**        | `i2f-jdk`       | `i2f-jdk`   |
| **版本**         | `1.0-jdk8`      | `1.0-jdk8`  |
| **包路径**        | `i2f.log.std.*` | `i2f.log.*` |
| **源文件数**       | 10              | 23          |
| **定位**         | 日志标准定义与门面       | 完整日志实现      |

## 依赖关系

### i2f-log-std 依赖

```
i2f-log-std
├── i2f-clock-impl          -- 系统时钟
├── i2f-trace               -- 线程追踪
├── i2f-trace-mdc           -- MDC 追踪
├── i2f-lru-map             -- LRU 缓存
├── i2f-console-color       -- 控制台彩色输出
└── Lombok
```

### i2f-log 依赖

```
i2f-log
├── i2f-log-std             -- 日志标准定义
├── i2f-uid-impl            -- 雪花 ID 生成
├── i2f-match               -- 字符串模式匹配
├── i2f-reflect             -- 反射工具
└── Lombok
```

---

## i2f-log-std — 日志标准定义

### ILogger — 核心日志接口

`ILogger` 是项目的日志门面接口，定义了 6 个日志级别和极其丰富的日志方法重载。每个级别（fatal/error/warn/info/debug/trace）均支持以下参数组合：

- 基础格式：`format` + `args`
- 带异常：`Throwable` + `format` + `args`
- 带元数据：`meta` + `format` + `args`
- 延迟求值：`Supplier<?>` / `PerfSupplier<?>` / `Function<T,?>` / `BiFunction<T,U,?>`
- 纯参数模式：`writeArgs(...)` 仅传参数数组

```java
public interface ILogger {
    String getLocation();

    boolean enableLevel(LogLevel level);

    // 核心写入方法（需实现）
    void write(Object meta, LogLevel level, String format, Object... args);

    void write(Object meta, LogLevel level, Throwable ex, String format, Object... args);

    // 6 个级别 × 多种重载 = 约 1500 行 default 方法
    default void fatal(String format, Object... args);

    default void error(String format, Object... args);

    default void warn(String format, Object... args);

    default void info(String format, Object... args);

    default void debug(String format, Object... args);

    default void trace(String format, Object... args);
    // ... 每个级别约 20+ 个重载
}
```

### LogLevel — 日志级别枚举

| 级别      | 数值 | 说明   |
|---------|----|------|
| `OFF`   | 0  | 关闭   |
| `FATAL` | 1  | 致命错误 |
| `ERROR` | 2  | 错误   |
| `WARN`  | 3  | 警告   |
| `INFO`  | 4  | 信息   |
| `DEBUG` | 5  | 调试   |
| `TRACE` | 6  | 追踪   |
| `ALL`   | 99 | 全部开启 |

### LogData — 日志数据模型

| 字段           | 类型          | 说明           |
|--------------|-------------|--------------|
| `location`   | `String`    | 日志位置（类名/方法名） |
| `level`      | `LogLevel`  | 日志级别         |
| `date`       | `Date`      | 日志时间         |
| `msg`        | `String`    | 日志消息         |
| `ex`         | `Throwable` | 异常对象         |
| `meta`       | `Object`    | 元数据          |
| `threadName` | `String`    | 线程名          |
| `threadId`   | `long`      | 线程 ID        |
| `className`  | `String`    | 调用类名         |
| `methodName` | `String`    | 调用方法名        |
| `fileName`   | `String`    | 源文件名         |
| `lineNumber` | `int`       | 行号           |
| `traceId`    | `String`    | 分布式追踪 ID     |

### AbsLogger — 抽象日志基类

实现 `ILogger` 的通用逻辑：

1. 检查日志级别 `enableLevel()`
2. 构建 `LogData` 对象（`newLogData()`）
3. 格式化消息（`formatMsg()`）
4. 调用抽象方法 `writeLogData(LogData)` 由子类完成实际输出

### StdioLogger — 默认控制台实现

继承 `AbsLogger`，将日志输出到控制台：

- **彩色输出**：每个日志级别对应不同 ANSI 颜色（FATAL=亮红、ERROR=红、WARN=黄、INFO=绿、DEBUG=亮黑、TRACE=亮白）
- **格式化**：`时间 [级别] [位置] [线程] - 消息 --@类.方法(文件:行) --#traceId`
- **分流输出**：INFO 及以上输出到 `System.out`，WARN 及以下输出到 `System.err`
- **智能截断**：位置名和线程名超长时智能缩写（包名首字母缩写 + LRU 缓存）

### LoggerFactory — 日志工厂

采用 **LRU 缓存**（1024）+ **三级 Provider 发现**策略：

```
1. 系统属性: logger.provider.class → 反射实例化
2. 默认配置: META-INF/log.properties → logger.provider.class
3. SPI 加载: ServiceLoader<LoggerProvider> → 按名称选择或取首个
4. 回退默认: StdioLogger
```

支持多种获取方式：

- `getLogger(String location)` — 按位置字符串
- `getLogger(Class<?>)` — 按类
- `getLogger(Method)` — 按方法
- `getLogger()` — 自动追踪调用栈

### LoggerProvider — SPI 扩展接口

```java
public interface LoggerProvider {
    String getName();

    ILogger getLogger(String location);
}
```

### PerfSupplier — 性能敏感参数化 Supplier

```java

@FunctionalInterface
public interface PerfSupplier<T> {
    T get(Object... args);
}
```

用于日志消息的延迟求值，避免在日志级别未启用时进行不必要的字符串构建。

---

## i2f-log — 完整日志实现

### 架构总览

```
LogConfiguration                    -- 配置入口（发现并加载 log.properties）
    ↓
LogProperties                       -- 配置模型（5 大配置块）
    ↓
PropertiesFileLogPropertiesLoader   -- properties 文件解析器
    ↓
LogHolder                           -- 全局持有器（Decider/Writer/Formatter × Global/ThreadLocal）
    ├── ILogDecider                 -- 日志级别决策
    │   └── DefaultClassNamePattenLogDecider  -- 类名模式匹配决策
    ├── ILogWriter                  -- 日志写入
    │   ├── DefaultBroadcastLogWriter         -- 广播写入（多 Writer 并行）
    │   ├── StdoutPlanTextLogWriter           -- 控制台输出
    │   ├── LocalFilePlanTextLogWriter        -- 本地文件（滚动+清理）
    │   └── JdbcDatasourceLogWriter           -- JDBC 数据库（批量+异步）
    ├── ILogDataFormatter           -- 日志数据格式化
    │   └── DefaultLogDataFormatter             -- 彩色格式化
    └── ILogMsgFormatter            -- 消息格式化
        ├── IndexedPattenLogMsgFormatter      -- 索引模式（{0},{1}）
        └── StringFormatLogMsgFormatter       -- String.format 模式

DefaultLogger                       -- 默认 Logger 实现
DefaultLoggerProvider               -- 默认 LoggerProvider（SPI）
LogWriterProvider                   -- Writer SPI 扩展接口

StdoutRedirectPrintStream           -- System.out/err 重定向
```

### LogHolder — 全局日志持有器

核心中枢，管理 4 类组件的全局 + 线程级实例：

| 组件                  | 全局默认                               | ThreadLocal             |
|---------------------|------------------------------------|-------------------------|
| `ILogDecider`       | `DefaultClassNamePattenLogDecider` | `THREAD_DECIDER`        |
| `ILogWriter`        | `DefaultBroadcastLogWriter`        | `THREAD_WRITER`         |
| `ILogMsgFormatter`  | `IndexedPattenLogMsgFormatter`     | `THREAD_MSG_FORMATTER`  |
| `ILogDataFormatter` | `DefaultLogDataFormatter`          | `THREAD_DATA_FORMATTER` |

获取方法优先返回 ThreadLocal 值，为空则回退到全局值。

提供便捷的注册方法：

- `registryWriter(name, writer)` — 向广播 Writer 注册子 Writer
- `registryDecideLevel(patten, level)` — 注册类名级别的日志级别控制

### DefaultLogger — 默认日志实现

继承 `AbsLogger`，组合 `ILogDecider` + `ILogWriter`：

- **级别决策缓存**：使用 `ExpireConcurrentMap`（30 秒 TTL）缓存级别判断结果，避免每次日志都进行模式匹配
- **消息格式化**：委托 `LogHolder.getMsgFormatter()`
- **日志写入**：委托 `ILogWriter.write(LogData)`

### DefaultClassNamePattenLogDecider — 类名模式匹配决策器

基于 Ant 风格类名模式匹配实现日志级别控制：

- 维护 `rootLevel`（全局默认级别）
- 维护 `pattenMapping`（`ConcurrentHashMap`，模式 → 级别映射）
- 使用 `StringMatcher.antClass()` 进行模式匹配，支持通配符
- 匹配时按优先级返回最精确的模式

### ILogWriter 体系 — 日志输出目标

#### ILogWriter — 写入接口

```java
public interface ILogWriter {
    void write(LogData data);
}
```

#### AbsPlainTextLogWriter — 纯文本写入抽象

将 `LogData` 通过 `LogHolder.getDataFormatter().format(data)` 格式化为纯文本，再调用 `write(LogLevel, String)`。

#### DefaultBroadcastLogWriter — 广播写入器

同时向多个命名 Writer 广播日志：

- 内部维护 `ConcurrentHashMap<String, ILogWriter>`
- 支持异步模式（`WorkStealingPool`，默认 5 线程）
- 启动时自动加载 `StdoutPlanTextLogWriter` 和 SPI Writer
- 支持 SPI 扩展：`ServiceLoader<LogWriterProvider>`

#### StdoutPlanTextLogWriter — 控制台写入器

- 名称：`STDOUT`
- INFO 及以上 → `System.out.println()`
- WARN 及以下 → `System.err.println()`
- 格式化时启用 ANSI 彩色

#### LocalFilePlanTextLogWriter — 本地文件写入器

- 名称：`FILE`
- **文件路径**：`{filePath}/{applicationName}.log`
- **级别限制**：仅写入 ≤ `limitLevel` 的日志
- **滚动策略**：单文件达到 `fileLimitSize`（默认 200MB）时按时间戳重命名归档
- **清理策略**：所有日志文件总大小超过 `fileLimitTotalSize`（默认 1GB）时删除最旧文件
- **检查频率**：每 `fileSizeCheckCount`（默认 100）次写入检查一次文件大小
- **参数设置**：支持通过 `setParams(String)` 方法以 URL 参数格式配置

#### JdbcDatasourceLogWriter — JDBC 数据库写入器

- **异步批量写入**：`LinkedBlockingQueue` 缓冲 + 守护线程消费
- **批量参数**：`minBatchSize=30`、`maxBatchSize=300`、`maxIdleMillSeconds=15s`
- **自动建表**：首次写入自动检测并创建 `i2f_log` 表
- **方言自动识别**：根据 JDBC URL 自动选择 MySQL（反引号）/ Oracle（双引号）列名引用
- **表结构**：17
  列（id/application/host/location/level/date/msg/is_ex/ex_msg/ex_trace/thread_name/thread_id/class_name/method_name/file_name/line_number/trace_id）
- **ID 生成**：雪花算法 `SnowflakeLongUid`

### StdoutRedirectPrintStream — 控制台重定向

继承 `PrintStream`，拦截所有 `System.out` / `System.err` 调用并转发到日志系统：

- **静态方法**：`redirectSysoutSyserr(keepConsole, useTrace)` 一键替换
- **级别映射**：`System.out` → `INFO`，`System.err` → `ERROR`
- **堆栈追踪**：`useTrace=true` 时追踪调用栈，定位真正的打印位置
- **防递归**：检测 `StdoutPlanTextLogWriter` 的调用，避免无限循环
- **保持控制台**：`keepConsole=true` 时同时输出到原始流

### LogConfiguration — 配置系统

#### 配置文件发现

按顺序查找首个存在的配置文件：

1. `log.properties`
2. `resources/log.properties`
3. `config/log.properties`
4. `conf/log.properties`
5. `META-INF/log.properties`

同时查找 classpath 和当前目录。

#### 配置模型 — LogProperties

| 配置块                 | 主要属性                                                                                                     | 默认值                                    |
|---------------------|----------------------------------------------------------------------------------------------------------|----------------------------------------|
| **stdoutRedirect**  | enable, keepConsole, useTrace                                                                            | true, false, true                      |
| **stdoutWriter**    | enable                                                                                                   | true                                   |
| **fileWriter**      | enable, filePath, applicationName, limitLevel, fileLimitSizeMb, fileLimitTotalSizeMb, fileSizeCheckCount | true, ./logs, INFO, 200MB, 1000MB, 100 |
| **broadcastWriter** | enable, async, parallelism, items[]                                                                      | true, true, -1                         |
| **loggingLevel**    | enable, rootLevel, items[]                                                                               | true, INFO                             |

#### 配置属性格式

```properties
# 标准输出重定向
log.stdout-redirect.enable=true
log.stdout-redirect.keep-console=false
log.stdout-redirect.use-trace=true
# 控制台 Writer
log.stdout-writer.enable=true
# 文件 Writer
log.file-writer.enable=true
log.file-writer.file-path=./logs
log.file-writer.application-name=myapp
log.file-writer.limit-level=INFO
log.file-writer.file-limit-size-mb=200
log.file-writer.file-limit-total-size-mb=1000
# 广播 Writer
log.broadcast-writer.enable=true
log.broadcast-writer.async=true
log.broadcast-writer.items[0].name=jdbc
log.broadcast-writer.items[0].class-name=i2f.log.writer.impl.JdbcDatasourceLogWriter
# 日志级别
log.logging-level.root-level=INFO
log.logging-level.items[0].patten=i2f.*
log.logging-level.items[0].level=DEBUG
```

### LogWriterProvider — Writer SPI 扩展接口

```java
public interface LogWriterProvider {
    String getName();

    boolean test();           // 环境检测

    ILogWriter getWriter();   // 创建 Writer

    default void loaded(DefaultBroadcastLogWriter logWriter) {
    }  // 加载后回调
}
```

通过 `META-INF/services/i2f.log.provider.LogWriterProvider` SPI 文件注册自定义 Writer。

---

## 源文件清单

### i2f-log-std（10 文件）

| 文件                             | 行数   | 说明                           |
|--------------------------------|------|------------------------------|
| `ILogger.java`                 | 1558 | 核心日志接口，6 级别 × 多种重载           |
| `LoggerFactory.java`           | 184  | 日志工厂，LRU 缓存 + 三级 Provider 发现 |
| `data/LogData.java`            | 33   | 日志数据模型                       |
| `enums/LogLevel.java`          | 51   | 日志级别枚举（8 级）                  |
| `logger/AbsLogger.java`        | 58   | 抽象日志基类                       |
| `logger/impl/StdioLogger.java` | 107  | 默认控制台实现（彩色输出）                |
| `perf/PerfSupplier.java`       | 11   | 性能敏感参数化 Supplier             |
| `provider/LoggerProvider.java` | 14   | SPI Provider 接口              |
| `util/LogUtil.java`            | 179  | 日志工具（格式化/截断/LogData 构建）      |
| `test/TestLogger.java`         | 23   | 测试                           |

### i2f-log（23 文件）

| 文件                                                  | 行数  | 说明                |
|-----------------------------------------------------|-----|-------------------|
| `config/LogConfiguration.java`                      | 225 | 配置入口              |
| `config/LogProperties.java`                         | 88  | 配置模型              |
| `config/PropertiesFileLogPropertiesLoader.java`     | 211 | properties 解析器    |
| `decide/ILogDecider.java`                           | 17  | 级别决策接口            |
| `decide/impl/DefaultClassNamePattenLogDecider.java` | 48  | 类名模式匹配决策          |
| `enums/LogType.java`                                | 10  | 日志类型枚举            |
| `format/ILogDataFormatter.java`                     | 16  | 数据格式化接口           |
| `format/ILogMsgFormatter.java`                      | 10  | 消息格式化接口           |
| `format/impl/DefaultLogDataFormatter.java`          | 163 | 默认彩色格式化           |
| `format/impl/IndexedPattenLogMsgFormatter.java`     | 22  | 索引模式格式化           |
| `format/impl/StringFormatLogMsgFormatter.java`      | 22  | String.format 格式化 |
| `holder/LogHolder.java`                             | 116 | 全局持有器             |
| `logger/DefaultLogger.java`                         | 57  | 默认 Logger 实现      |
| `provider/DefaultLoggerProvider.java`               | 25  | 默认 Provider       |
| `provider/LogWriterProvider.java`                   | 21  | Writer SPI 接口     |
| `stdout/StdoutRedirectPrintStream.java`             | 458 | 控制台重定向流           |
| `writer/ILogWriter.java`                            | 12  | 写入接口              |
| `writer/AbsPlainTextLogWriter.java`                 | 26  | 纯文本写入抽象           |
| `writer/DefaultBroadcastLogWriter.java`             | 103 | 广播写入器             |
| `writer/impl/JdbcDatasourceLogWriter.java`          | 323 | JDBC 数据库写入        |
| `writer/impl/LocalFilePlanTextLogWriter.java`       | 198 | 本地文件写入（滚动）        |
| `writer/impl/StdoutPlanTextLogWriter.java`          | 34  | 控制台写入             |
| `test/TestLogger.java`                              | 71  | 测试                |

---

## 设计特点

1. **标准-实现分离**：`i2f-log-std` 定义纯接口抽象，`i2f-log` 提供完整实现，可独立使用或替换
2. **门面设计模式**：`ILogger` 作为统一门面，屏蔽底层实现细节
3. **SPI 双重扩展**：`LoggerProvider`（日志实现扩展）+ `LogWriterProvider`（输出目标扩展）
4. **全局 + 线程级**：`LogHolder` 的 4 类组件均支持 Global + ThreadLocal 双级覆盖
5. **广播写入**：`DefaultBroadcastLogWriter` 支持同时输出到多个目标，异步并行
6. **智能控制台重定向**：`StdoutRedirectPrintStream` 拦截所有 `System.out/err` 并纳入日志体系
7. **类名模式级别控制**：Ant 风格通配符匹配类名，精确控制不同包/类的日志级别
8. **JDBC 批量异步写入**：队列缓冲 + 守护线程 + 批量提交，自动建表和方言适配
9. **文件滚动与清理**：单文件大小限制 + 总大小限制 + 自动归档 + 旧文件清理
10. **延迟求值**：`Supplier` / `PerfSupplier` / `Function` / `BiFunction` 多种延迟消息构建
