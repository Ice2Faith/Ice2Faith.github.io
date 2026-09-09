# i2f-turbo-java

> 面向 JDK / Spring / SpringBoot / SpringCloud 的 Java 基础能力增强与扩展库，提供反射、JDBC、类型系统、AI、扩展组件等模块化能力。

## i2f-jdk

> 仅依赖 JDK8 的基础能力模块集合，提供反射、类型系统、集合、IO、加密、SPI 服务加载、JVM Agent、AI 标准抽象、网络通信、AI 协议实现、通用算法、注解元数据、数组工具、认证契约、参数化 SQL 构建、分页方言适配、SQL 字面量文本化、数据库类型方言识别、类型安全查询语言、可序列化函数式接口体系、方法引用解析（内核 + 任意方法通用层 + 转换器门面）、浏览器抓取标准契约、流式对象修改器、一次性口令（HOTP/TOTP）认证、元组标准契约与强类型实现家族、类型系统判定与泛型超类型令牌、底层内存窥探（Unsafe/对象地址/大小）、字符串匹配标准契约（布尔/优先级打分）、字符串匹配实现（通配/Ant/正则+择优排序）与全仓正则工具箱、内存缓存/自调节容器/弱引用复用/RAII 作用域工具族、外置 classpath 应用启动器（child-first 加载插件 jar）、日志标准门面（ILogger 大门面 + 可插拔 LoggerProvider SPI + StdioLogger 彩色兜底）、日志门面默认完整实现（LogHolder 全局+线程双路由 + 广播/文件/JDBC 写出 + System.out 收编 + log.properties 装配）等零三方依赖的通用工具。

### i2f-spi-annotations

> SPI 注解定义模块，提供 `@Spi` 标记注解，声明服务实现类及其提供的接口，配合构建期插件生成 `META-INF/services/` 描述文件。

- 详细文档：[i2f-spi-annotations](./i2f-jdk/i2f-spi-annotations/readme.md)

### i2f-spi

> SPI 运行期支撑模块，基于 `java.util.ServiceLoader` 封装统一的服务加载、组件/工厂契约接口与描述文件编程式生成工具。

- 详细文档：[i2f-spi](./i2f-jdk/i2f-spi/readme.md)

### i2f-agent

> 基于 `java.lang.instrument` 的 Java Agent 模块，支持静态 `premain` 与动态 `agentmain` 挂载，提供 Instrumentation 装配、按 Ant 模式匹配类的字节码转换骨架与交互式 attach 工具。

- 详细文档：[i2f-agent](./i2f-jdk/i2f-agent/readme.md)

### i2f-ai-std

> AI 能力标准抽象（SPI）模块，模型无关地定义大模型对话、工具（function-calling）、RAG、技能、MCP 网关、记忆与 Re-Act Agent 引擎，并提供声明式 `@AiService` 动态代理。

- 详细文档：[i2f-ai-std](./i2f-jdk/i2f-ai-std/readme.md)

### i2f-network

> 基于 JDK 标准网络 API 的通用网络模块，封装 HTTP/REST 客户端、BIO/NIO 双栈 TCP/UDP、RMI 远程调用、本机网卡与出口 IP 探测及并发端口扫描。

- 详细文档：[i2f-network](./i2f-jdk/i2f-network/readme.md)

### i2f-ai-rest-openai

> `i2f-ai-std` 抽象契约的 OpenAI 兼容 HTTP 实现，基于 `i2f-network` 对接对话/Embedding/Rerank/Models 端点（支持 SSE 流式），并提供自研 HMAC 签名的 Simple MCP 跨进程工具网关（客户端 + 服务端）。

- 详细文档：[i2f-ai-rest-openai](./i2f-jdk/i2f-ai-rest-openai/readme.md)

### i2f-algo

> 通用算法模块，提供基于二分（策略驱动）的边界近似求交点算法（数值区间/圆形/多边形）与基于动态规划的最短编辑距离（Levenshtein）算法。

- 详细文档：[i2f-algo](./i2f-jdk/i2f-algo/readme.md)

### i2f-annotations-core

> i2f 注解核心库，零依赖收录 67 个纯语义的标记/描述型注解（base/check/doc/env/except/format/naming/resources/value/version 十大类），统一 RUNTIME 保留、自描述，供反射与文档/代码生成消费。

- 详细文档：[i2f-annotations-core](./i2f-jdk/i2f-annotations-core/readme.md)

### i2f-annotations-ext

> i2f 注解扩展库，在 core 之上声明缓存/重试降级/锁/事务/调度/异步编排/字典翻译/文本整形等横切行为语义（34 注解 + IDict 枚举），供 i2f 运行期切面/代理引擎解释执行。

- 详细文档：[i2f-annotations-ext](./i2f-jdk/i2f-annotations-ext/readme.md)

### i2f-annotations-db

> 数据库映射注解库，以注解声明「Bean ↔ 关系表 DDL」映射（表/列/类型、主键自增、外键/软引用、唯一/索引/约束、忽略控制，17 注解 + IDict 枚举），供元数据读取与反向工程生成器反射消费。

- 详细文档：[i2f-annotations-db](./i2f-jdk/i2f-annotations-db/readme.md)

### i2f-annotations-api

> API 描述注解库，以协议无关的注解声明接口语义（模块/系统/标签/操作/请求方式/协议，6 注解），为 API 文档生成与接口治理提供结构化描述，由 Spring MVC 元数据解析等反射消费。

- 详细文档：[i2f-annotations-api](./i2f-jdk/i2f-annotations-api/readme.md)

### i2f-annotations

> i2f 注解体系的聚合（门面）模块，零源码，仅通过 POM 将 core/ext/db/api 四支汇总为单一坐标，供使用方「一次依赖、全套注解」引入，版本由父 POM 统一托管。

- 详细文档：[i2f-annotations](./i2f-jdk/i2f-annotations/readme.md)

### i2f-atomic

> 原子变量补充模块，零依赖自研 JDK 缺失的 `AtomicDouble`/`AtomicDoubleArray`，把 double 经 raw-long-bits 编码复用 `AtomicLongFieldUpdater`/`AtomicLongArray` 做无锁 CAS，语义对齐 `java.util.concurrent.atomic` 家族。

- 详细文档：[i2f-atomic](./i2f-jdk/i2f-atomic/readme.md)

### i2f-array

> 数组工具模块，单一静态门面 `ArrayUtil` 提供 458 个方法，覆盖判定/读写/构造/集合互转/映射过滤/合并/二维扁平/填充/拷贝/反转/比较/相等，对象与 8 种基本类型数组全覆盖。

- 详细文档：[i2f-array](./i2f-jdk/i2f-array/readme.md)

### i2f-authentication

> 认证标准契约模块，框架无关地定义密码编码/登录密码解码/用户与 RBAC 主体模型，并给出加盐+多轮迭代、密文自描述参数的 `MessageDigestPasswordEncoder` 实现；被 Spring Security、Shiro、SpringBoot starter 实现与继承。

- 详细文档：[i2f-authentication](./i2f-jdk/i2f-authentication/readme.md)

### i2f-bindsql

> 参数化 SQL 流式构建器，以 `BindSql` 将「SQL 文本 + 绑定参数」一体化链式拼装，内建 MyBatis 风格动态 SQL（when/choose/foreach/连接词裁剪）与关键字 DSL，并提供字面量回填/美化/去注释的正则文本处理；为分页、JDBC、BQL 等持久化能力的地基。

- 详细文档：[i2f-bindsql](./i2f-jdk/i2f-bindsql/readme.md)

### i2f-bindsql-page

> 分页/计数 SQL 方言适配器，以 `IPageWrapper`/`ICountWrapper` 双扩展点把 `BindSql` 改写为各库分页与 `count(1)` 语句；内置 9 方言 + 20+ 小库重定向归并，经 ThreadLocal→SPI Provider→方言映射→内置分发四级解析链选择，`embed` 标志兼顾 JDBC 参数化与 MyBatis 自管参数。

- 详细文档：[i2f-bindsql-page](./i2f-jdk/i2f-bindsql-page/readme.md)

### i2f-bindsql-stringify

> 参数化 SQL 文本化模块，以 `WrappedBindSqlStringifier` 把 `BindSql` 的裸 `?` 按目标方言回填为 SQL 字面量（字符串转义、MySQL `STR_TO_DATE`/Oracle `TO_DATE`），还原成完整可执行/可展示语句；经 `of(conn/jdbcUrl/type)` 走「SPI→方言重定向→内置 9 方言→DEFAULT」四级解析，供日志打印与纯 Statement 脚本执行器使用。

- 详细文档：[i2f-bindsql-stringify](./i2f-jdk/i2f-bindsql-stringify/readme.md)

### i2f-database-type

> 数据库类型/方言识别层（持久化族的类型地基），`DatabaseType` 枚举收录 36 库经「URL 嗅探 + 连接探测 + SPI」三路径识别，`DatabaseDialectMapping` 做小库→主流方言归并，`ProxyDialectJdbcDriver`（`jdbc:proxy:{方言}:{真实URL}`）为不自报方言的库显式声明方言；纯 JDK 零三方依赖。

- 详细文档：[i2f-database-type](./i2f-jdk/i2f-database-type/readme.md)

### i2f-bql

> 类型安全绑定查询语言（BQL），在 `BindSql` 之上提供全量 SQL 关键字 DSL、方言自适应标识符装饰与动态 SQL（值空跳过/连接词裁剪）；以 core→map→lambda→bean 四级继承链支持「字符串/Map/方法引用/实体 Bean」递进式列寻址，另有 Condition+Wrapper 声明式延迟渲染，产物仍是 `BindSql` 供分页/文本化/JDBC 消费。

- 详细文档：[i2f-bql](./i2f-jdk/i2f-bql/readme.md)

### i2f-lambda-core

> 方法引用解析内核，以 `extends Serializable` 的 `IGetter`/`ISetter`/`IBuilder` 承接 getter/setter 型方法引用，经 `writeReplace`→`SerializedLambda` 反查引用的类/方法/字段，反射定位 `Class`/`Method`/`Field`；仅依赖 `i2f-lru-map`，全链路 LruMap 缓存，是 bql/mutator/lambda 的类型安全底座。

- 详细文档：[i2f-lambda-core](./i2f-jdk/i2f-lambda-core/readme.md)

### i2f-lambda

> 方法引用解析通用层，在 `i2f-lambda-core` 的 getter/setter 命名约定之上补上「任意方法引用」的还原：用 `SerializedLambda` 的方法名 + JVM 描述符经 `i2f-reflect` 精确匹配真实 `Method`，`Object` 入参做 `Serializable` 兜底、`LruMap` 缓存；供 `i2f-functional-lambda` 作为通用转换器解析函数。

- 详细文档：[i2f-lambda](./i2f-jdk/i2f-lambda/readme.md)

### i2f-functional

> 可序列化函数式接口地基（零依赖），以 `IFunctional extends Serializable` 为顶点按「返回域 × 元数 × 是否抛异常」枚举 327 个接口（func/consumer/predicate/comparator 0–10 + base 标量/array 数组 0–5 及其 `IEx` 变体）；`adapt` 语义别名、`Functionals` JDK 桥接/柯里化、`{,Ex}FunctionalDelegator` 重载汇聚、`Func.setIf` 空值安全赋值；统一 `Serializable` 是上层 lambda 反解方法引用的前提。

- 详细文档：[i2f-functional](./i2f-jdk/i2f-functional/readme.md)

### i2f-functional-lambda

> 「函数式接口 × 方法引用解析」粘合层，把 `i2f-functional` 的 `ExFunctionalDelegator`（~300 个 `get()` 重载汇聚前门）与 `i2f-lambda` 的 `LambdaInflater`（方法引用反解器）对接，产出 `Lambdas.FIELD/METHOD/LAMBDA` 三个无状态转换器单例；一行 `Lambdas.METHOD.get(方法引用)` 即得 `Field`/`Method`/`SerializedLambda`，无需关心接口种类、元数与是否抛异常。5 文件零自建逻辑，仅依赖 `i2f-functional`+`i2f-lambda`。

- 详细文档：[i2f-functional-lambda](./i2f-jdk/i2f-functional-lambda/readme.md)

### i2f-browser-std

> 浏览器搜索引擎抓取的标准契约层（`std` 契约与实现分离），零引擎依赖地沉淀四类共用底座：统一出参模型 `SearchContext`/`SearchResult`、驱动队列爬行的 `SearchType` 阶段枚举、无头抓取屏蔽图片/音视频/字体的运行期可变常量 `SearchBlockConsts`、URL 后缀归一 `SearchUtil`；是 Playwright 与 Selenium 两套抓取实现的共同上游契约，仅依赖 lombok。

- 详细文档：[i2f-browser-std](./i2f-jdk/i2f-browser-std/readme.md)

### i2f-mutator

> 流式**对象修改器**，以 `Mutator<T>` 门面用「方法引用」在链式中即时修改任意对象：`set`/`with`（void vs 返回源 setter）× 单/双值（`set2`/`with2`）× 类引用/实例引用四维矩阵，叠加 `apply`/`when`/`map`/`cast`/`orElse` 控制流；特色是借 `i2f-lambda-core` 反射的 `field*` 族（`fieldIfAbsent`/`fieldCompute`/`fieldEachCompute`）——只给 getter 方法引用即读改写、按类型批量遍历全部字段。`BaseMutator<T>` 让领域对象一个 default 方法即接入 `.toMutator()`，被 network/ai/spring/funic 等广泛实现。

- 详细文档：[i2f-mutator](./i2f-jdk/i2f-mutator/readme.md)

### i2f-otpauth

> 一次性口令（OTP）认证模块，纯 JDK 实现 RFC 4226/6238 的「HMAC → 动态截断 → 10^digits」内核与 `otpauth://` 密钥 URI 装配：`OtpAuthenticator` 以 `generate`/`verify`/`makeQrUrl` 三动词收敛全流程，抽象骨架 `HmacOtpAuthenticator` 沉淀密钥/算法/码长与全部静态密码学原语，`HotpAuthenticator`（`AtomicLong` 自增）与 `TotpAuthenticator`（时间窗整除 + `aliveSeconds`）只提供「计数因子」，另有 `MicrosoftAuthenticator`（零覆写别名）与 `SteamAuthenticator`（5 位去元音字母表）两级厂商兼容。账号密钥存取与 Bean 装配留给 `i2f-springboot-totp-starter`；运行期零三方依赖。

- 详细文档：[i2f-otpauth](./i2f-jdk/i2f-otpauth/readme.md)

### i2f-tuple-std

> 元组**标准契约层**（`std` 契约与实现分离），全模块只有一个接口 `Tuple extends Iterable<Object>, Serializable`：以 `size()`/`get(int)`/`set(int,Object)`/`toList()` 四抽象刻画「下标化异质多值容器」本质，再用 `isEmpty()`/`toArray()`/`iterator()` 三 `default` 派生出判空、转数组、可 for-each 遍历，让 `Tuple0…Tuple20`/`TupleVars`（均在下游 `i2f-tuple-impl`）与 `Tuples.of(...)` 工厂共享同一向上转型锚点。自身零 i2f 内部依赖、零三方运行期依赖（pom 声明的 lombok 实际未用）。

- 详细文档：[i2f-tuple-std](./i2f-jdk/i2f-tuple-std/readme.md)

### i2f-tuple-impl

> 元组**强类型实现家族**，落地 `i2f-tuple-std.Tuple` 契约：以「一档 arity 一类」模板生成 `Tuple0`…`Tuple20`（每档 `@Data` POJO，将类型参数存为具名字段 `v1..vN`，另有 `size/get/set/toList` 的 switch 擦除统一路径）加变长 `TupleVars`，由 `Tuples.of(...)/ofVars(...)` 工厂按实参数分派产出。两特例：`Tuple0.INSTANCE` 零元占位、`Tuple2` 兼任 `Map.Entry`。典型落地是 `i2f-thread` 的 `Asyncs.promise(...)` 并发多返回值装配；依赖 `i2f-tuple-std` + `lombok`（真实使用）。

- 详细文档：[i2f-tuple-impl](./i2f-jdk/i2f-tuple-impl/readme.md)

### i2f-typeof

> 类型系统**地基**，两支零内部依赖的正交组件：`TypeOf` 是**自动装箱感知**的类型谓词门面，用双向 `basicTypeMap` 把 `int.class` 与 `Integer.class`、原始/包装/父子三态统一为一次 `typeOf`，并识别 `Collections` 同步/不可变包装类；`TypeToken`/`TypeNode` 是 **Guava 风格超类型令牌**，靠匿名子类 `new TypeToken<X>(){}` 反泛型擦除、`getGenericSuperclass` 还原任意深度嵌套泛型并折叠成可递归渲染的 `TypeNode` 树（`fullName`/`simpleName`/`importName`）。是 `i2f-reflect`/`i2f-convert`/`i2f-container-builder`/`i2f-ai-std` 的共同判据，仅依赖 lombok。

- 详细文档：[i2f-typeof](./i2f-jdk/i2f-typeof/readme.md)

### i2f-unsafe

> 底层**内存窥探工具**，全模块仅静态类 `UnsafeHacker` 且 `pom.xml` 零 Maven 依赖：反射撬取 `sun.misc.Unsafe`（`getUnsafe` 双检锁缓存）、借一元素 `Object[]` 的引用槽读出对象物理地址（`addressOf`/`addressHexOf`）、反射调用 Nashorn `ObjectSizeCalculator` 估算对象深链字节大小（`sizeOf`，Nashorn 缺失时优雅返回 `-1` 并打印 `nashorn-core` 依赖提示）。面向内存诊断、缓存体积估算、对象身份比对等「绕开 Java 封装」的底层诉求；当前仅被 `i2f-jdk-all` 聚合引入。

- 详细文档：[i2f-unsafe](./i2f-jdk/i2f-unsafe/readme.md)

### i2f-match-std

> 字符串**匹配器标准契约层**（`std` 契约与实现分离），全模块仅两个接口：`IMatcher` 定义最小布尔契约 `matches(str, patten)`；`IPriorMatcher extends IMatcher` 把抽象方法换成打分版 `matchRate`（负＝不匹配，非负＝匹配精确度），再用 `default` 让布尔 `matches` 由 `matchRate` 派生，并沉淀供全体实现复用的打分公式 `calcMatchRate` 与规避浮点精度误判的阈值 `MATCH_SUCCESS_LIMIT=-0.5`——解决「一个串同时命中多模式时按精确度择优排序」。真正的 `SimpleMatcher`/`AntMatcher`/`RegexMatcher`、排序门面 `StringMatcher`、桥接 Spring 的 `SpringAntPathMatcher` 均在下游 `i2f-match`/`i2f-spring-core`；自身零 i2f 内部依赖（lombok 声明未用）。

- 详细文档：[i2f-match-std](./i2f-jdk/i2f-match-std/readme.md)

### i2f-match

> 字符串**匹配器实现层 + 正则工具箱**，落地 `i2f-match-std` 契约：`SimpleMatcher`（`*`/`?` 通配转义）、`AntMatcher`（`*`/`?`/`**` 分层，分隔符可配 `/`、`.`）、`RegexMatcher`（纯正则 + `LruMap` 缓存）三 `IPriorMatcher` 共享 `calcMatchRate` 打分，`StringMatcher` 门面以 `priorMatches` 把「一个串命中多模式」按精确度降序择优（`i2f-agent`/`i2f-log` 消费）；另一半 `regex` 子包（`RegexUtil` 的 find/parts/replace/format + `RegexPattens` 预编译目录）是被约 20 个模块共用的全仓正则底座。依赖 `i2f-match-std`+`i2f-lru-map`+`i2f-iterator`，运行期零三方。

- 详细文档：[i2f-match](./i2f-jdk/i2f-match/readme.md)

### i2f-lru-map

> 内存缓存 / 自调节容器 / 弱引用复用 / RAII 作用域**工具族**（单包 `i2f.lru`，13 类）：LRU 家族 `LruMap`（`LinkedHashMap`+`removeEldestEntry` 容量淘汰、全方法套 `ReentrantLock`，`accessOrder=true` 才按访问序）/`WindowLruMap`（`Duration` 时间片槽位键）/`LruList`（`touch` 提头自调节）/`ConcurrentLinkedSet`（双 map 手写双向链集）/`ConcurrentLruCache`（读优并发生成式 LRU）；过期记忆化 `ExpireConcurrentMap`/`CachedSupplier`；弱引用复用 `WeakEntry`（`ReferenceQueue` 清理线程）+ `WeakStackRetrieveCacheProvider`（L1/L2 `ThreadLocal` 按 `==` 复用幂等转换）；RAII `ScopeValue`/`UncheckedScopeValue`（锁/`ThreadLocal`/close 自动配对）。`LruMap` 是全仓反射/编译缓存事实标准（lambda/bql/compiler/jdbc-proxy/log 等大量消费）；实际仅用 `i2f-clock-impl` 的 `SystemClock`（`i2f-cache-std`、`lombok` 声明未用）。

- 详细文档：[i2f-lru-map](./i2f-jdk/i2f-lru-map/readme.md)

### i2f-launcher

> 轻量级**应用启动器 / 外置 classpath 加载器**（单包 `i2f.launcher`，3 类，零 i2f 内部依赖、零三方运行期）：借鉴 Spring Boot Loader 并简化——Maven 把 jar 的 `Main-Class` 指向 `ExtApplicationLauncher`，运行期读 `Ext-Main-Class`（真实入口）与 `Ext-Path`（额外 classpath 目录，默认 `lib,libs,plugin,plugins,...`），经 child-first 的 `ExtClasspathClassLoader`（`URLClassLoader` 覆写 `loadClass`/`getResource(s)`，JDK 包名回退父优先）加载外置目录与其下 jar，再反射调真实 `main`；`ExtLauncherSpi.premain` 提供业务启动前的一次性 `ServiceLoader` 钩子。解决「jar 打包期 Class-Path 固化、运行期难追加」痛点，适配插件化与 JDBC Driver 等动态 SPI 加载；真实消费方 `i2f-tools-ops`（lombok 声明未用，`:` 切分破坏 Windows 盘符路径等瑕疵见文档）。

- 详细文档：[i2f-launcher](./i2f-jdk/i2f-launcher/readme.md)

### i2f-log-std

> 日志**标准门面层**（`std` 契约与实现分离）：统一大门面 `ILogger` 以「6 级别 × 入参形态（format / 纯 args / `Supplier` / `PerfSupplier` / `Function` / `BiFunction`）× 带 `meta`/`Throwable`」展开数百 `default` 方法、全部收敛到 2 个抽象 `write`；`LoggerFactory` 用 `LruMap` 缓存 logger 并按「系统属性 → `META-INF/log.properties` → SPI（选名或取首个） → 内置 `StdioLogger` 彩色兜底（warn+ 走 stderr）」多路径解析可插拔 `LoggerProvider`；`AbsLogger` 模板方法把 `write` 收敛为 `writeLogData(LogData)`；`LogData` 携 traceId（MDC）与 DEBUG 级调用点（`ThreadTrace`），惰性求值变体关级零开销。六个依赖（`i2f-clock-impl`/`i2f-trace`/`i2f-trace-mdc`/`i2f-lru-map`/`i2f-console-color`/`lombok`）皆真实使用；下游 `i2f-log`（默认完整实现 + SPI 注册 `DefaultLoggerProvider`）与双向 SLF4J 桥接（`i2f-extension-slf4j-log`/`i2f-extension-log-slf4j`）。**瑕疵**：`*Args`/`*MetaArgs` 全级别门级误用 `enableFatal()`，越过自身级别阈值（对 StdioLogger 被 `AbsLogger.write` 二次判级掩盖）。

- 详细文档：[i2f-log-std](./i2f-jdk/i2f-log-std/readme.md)

### i2f-log

> `i2f-log-std` 门面的**默认完整实现层**（8 子包、23 类，零三方运行期）：`DefaultLoggerProvider` 经 SPI 注册被 `LoggerFactory` 优先选中、产出 `DefaultLogger`（`AbsLogger` 具体化）；运行期四大可插拔组件（决策器 `ILogDecider`、写出器 `ILogWriter`、消息格式化器 `ILogMsgFormatter`、数据格式化器 `ILogDataFormatter`）集中在 `LogHolder`「**全局 `GLOBAL_*` + 线程 `THREAD_*` 双路由**」注册表、可替换；决策器按调用位置 ant 模式就近分级，`DefaultLogDataFormatter` 产出 ANSI 彩色整行 Layout，`DefaultBroadcastLogWriter` 多目标异步广播（work-stealing 池 + 二级 SPI `LogWriterProvider`）并内置控制台/本地滚动文件/`JdbcDatasourceLogWriter`（有界队列攒批写 `i2f_log`、自动建表）三类写出器，`StdoutRedirectPrintStream` 把 `System.out/err` 收编进日志（带递归护栏与逐调用点归因），`LogConfiguration`+`log.properties` 一键装配。真实使用全部 5 个依赖（`i2f-log-std`/`i2f-uid-impl`/`i2f-match`/`i2f-reflect`/`lombok`）并经 std 传递复用 `LruMap`/`ExpireConcurrentMap`/`SystemClock`/`ConsoleColor`/`ThreadTrace`；下游 `i2f-extension-log-slf4j` 提供 `LogWriterProvider` SPI 转投 SLF4J 后端。**瑕疵**：`DefaultLogger` 级别缓存因 std 侧 `ExpireConcurrentMap.get` 反向判定永不相中且每 logger 泄漏一条调度线程；`JdbcDatasourceLogWriter` 丢堆栈、`setDate` 截时间；`LogConfiguration` 两处（stdoutWriter 误挂整个广播器、级别项 `return` 误代 `continue`）等（详见文档）。

- 详细文档：[i2f-log](./i2f-jdk/i2f-log/readme.md)

## i2f-spring

> Spring 生态集成模块集合，封装 Spring 核心、MVC、安全、Redis、Web 等能力的增强与元数据解析。

### i2f-spring-mvc-metadata

> 基于反射解析 Spring MVC Controller 的 API 元数据，提取 URL、HTTP 方法、参数、返回值与 Swagger 注释，为 API 文档生成提供结构化数据。

- 详细文档：[i2f-spring-mvc-metadata](./i2f-spring/i2f-spring-mvc-metadata/readme.md)

## i2f-extension

> 可选扩展能力集合，按需集成第三方库与增强组件（AI、文档、数据库反向工程、文件系统、序列化、Java Agent 字节码增强观测等）。

### i2f-extension-reverse-engineer-generator

> 数据库反向工程与代码生成模块，基于 Velocity 模板从表结构或 Spring MVC 元数据生成分层代码、DDL、设计文档与 ER 图。

- 详细文档：[i2f-extension-reverse-engineer-generator](./i2f-extension/i2f-extension-reverse-engineer-generator/readme.md)

### i2f-extension-agent-javassist

> 基于 **Java Instrumentation Agent + Javassist** 的**运行期字节码增强观测套件**（单包族 `i2f.extension.agent.javassist`，24 类，运行期仅 `provided` 依赖 javassist）：以 `-javaagent`（`premain`）或动态附加（`agentmain`）无侵入对整个 JVM 打点。`AgentMain.agentProxy` 复用 `i2f-agent` 的 `AgentUtil` 把 agent jar 注入 Bootstrap 搜索路径并登记 **11 个** transformer；`AgentContextHolder` 是进程级黑板——按事件（SQL/文件/RMI/异常/退出/进程/URL）持 `CopyOnWriteArrayList` 监听并 `notify*` 分发（异常走队列+单守护线程+超 8192 丢弃的异步通道），另捕获 `SpringApplication`/`ApplicationContext`、经反射桥接 SLF4J MDC 与 `i2f-log` 编织每请求 traceId；transformer 覆盖 JDBC（`Connection.prepareStatement`/`Statement.execute*`）、`java.io.File` 构造、`Naming.lookup`、`Shutdown.exit`、`Throwable` 构造、Spring 上下文捕获、`*Filter.doFilter` traceId、XXE 全局关闭；`LocalFileExpressionEvaluator` 轮询 `expression.java` 用 `i2f-compiler` 即时求值充当活体 REPL。真依赖 `i2f-agent`/`i2f-extension-javassist`/`i2f-compiler`（`lombok` 冗余、`tools.jar` 仅服务于 i2f-agent 的 `VirtualMachine`），权威 fat-jar 清单由 `i2f-tools-agent` 打包。**瑕疵**：进程监控因 `start()` 零参与过滤条件不符而完全失效；`Url`/`SpringBean`/`InvokeWatch` 三 transformer 未接线；默认监听恒返回 `true` 截断用户追加监听；`ClassPool.getDefault()` 忽略 `loader` 对 Spring Boot 应用类静默失效；XXE `DocumentBuilderFactory` 分支防护不足等（详见文档）。

- 详细文档：[i2f-extension-agent-javassist](./i2f-extension/i2f-extension-agent-javassist/readme.md)

## i2f-tools

> 开发/构建辅助工具集合，提供与工程构建、代码生成集成的独立能力。

### i2f-maven-plugin

> i2f 构建期 Maven 插件，提供 `i2f:spi` 目标，基于 ASM 扫描 `@Spi` 注解自动并合并生成 `META-INF/services/` 服务描述文件。

- 详细文档：[i2f-maven-plugin](./i2f-tools/i2f-maven-plugin/readme.md)
