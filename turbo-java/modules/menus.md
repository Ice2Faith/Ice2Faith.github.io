# i2f-turbo-java

> 面向 JDK / Spring / SpringBoot / SpringCloud 的 Java 基础能力增强与扩展库，提供反射、JDBC、类型系统、AI、扩展组件等模块化能力。

## i2f-jdk

> 仅依赖 JDK8 的基础能力模块集合，提供反射、类型系统、集合、IO、加密、SPI 服务加载、JVM Agent、AI 标准抽象、网络通信、AI 协议实现、通用算法、注解元数据、数组工具、字节序编解码、认证契约、参数化 SQL 构建、分页方言适配、SQL 字面量文本化、数据库类型方言识别、类型安全查询语言、可序列化函数式接口体系、方法引用解析（内核 + 任意方法通用层 + 转换器门面）、浏览器抓取标准契约、流式对象修改器、一次性口令（HOTP/TOTP）认证、元组标准契约与强类型实现家族、类型系统判定与泛型超类型令牌、底层内存窥探（Unsafe/对象地址/大小）、字符串匹配标准契约（布尔/优先级打分）、字符串匹配实现（通配/Ant/正则+择优排序）与全仓正则工具箱、内存缓存/自调节容器/弱引用复用/RAII 作用域工具族、外置 classpath 应用启动器（child-first 加载插件 jar）、日志标准门面（ILogger 大门面 + 可插拔 LoggerProvider SPI + StdioLogger 彩色兜底）、日志门面默认完整实现（LogHolder 全局+线程双路由 + 广播/文件/JDBC 写出 + System.out 收编 + log.properties 装配）生命周期契约（ILifeCycle 三动词 create/destroy/close + Closeable 桥接 + LifeCycleException）、按 key 限流控制（Limiter 单动词 require 令牌桶 TokenBucketLimiter + IKeyedLimiter 三动词失败锁定/令牌桶）、锁抽象契约（ILock/INotify/IReadWriteLock/ILockProvider 接口及 JDK 原生实现）、操作系统工具（OsUtil 跨平台命令执行/平台探测 + WindowsOsUtil PowerShell 执行 + PerfUtil/LinuxUtil/WindowsUtil 的 CPU/内存/磁盘采集）、二进制流封包协议（EE EE 引导 + EF 转义 + 多 head/多 body + tail 校验的 StreamPacket/StreamPacketResolver，HTTP 风格 PacketProtocol 映射，512KB 内存/临时文件自适应流适配，纯 JDK 零依赖）、分页数据模型（ApiOffsetSize 偏移-大小-排他结束下标三字段 + ApiPage 零基页索引与一基页号转换 + Page 泛型结果承载的 JDBC/MyBatis/ES/脚本统一分页契约，运行期零依赖仅 lombok 编译期）、对象池与分段并发原语（ObjectPool 队列缓存对象池 + hash 分段对象提供者/分段锁/String.intern 分段同步，纯 JDK）、properties 配置装载（PropertiesUtil 单门面：点分键树化 + 下划线/中划线驼峰归一 + Visitor 前缀定位 + RichConverter 强类型转换的 properties→Bean 装载管线，依赖 i2f-reflect/i2f-text）、代理标准契约（IProxyHandler 五阶段钩子 initContext/before 短路/after 改写/except 替换/onFinally 回调 + IProxyInvocationHandler 函数式三参 invoke + IProxyProvider 桥接 + DefaultMethodSmartInvocationHandler 的 default 方法 MethodHandles 兼容，JDK/CGLIB/AspectJ 统一代理契约，依赖 i2f-invokable）、JDK 动态代理实现（JdkProxyUtil 六重载门面提供函数式/五阶段/原生三契约 × 实例/接口双形态 + normal/interfaces 双 InvocationHandler 适配器 + JdkProxyProvider/JdkDynamicProxyProvider 双提供者 + BasicDynamicProxyHandler 五阶段解包骨架，依赖 i2f-proxy-std）、注解驱动的代理处理器（@Lock 方法级互斥 / @Retry 倍率退避重试 / @Validate 参数返回值深度校验三大 IProxyInvocationHandler 处理器 + ILockProvider 可插拔锁 + 15 校验注解族标签化递归校验，依赖 i2f-proxy-std/i2f-annotations-ext/i2f-lock/i2f-convert/i2f-comparator/i2f-reflect，⚠ 实测必须 normal 实例形态否则递归）、三态引用包装（Reference 单类 183 行：VALUE/NOP/FINISH 三态区分「有值/值为 null/跳过/终止」四义，ReadWriteLock 读写安全，nop/finish/empty/of 四静态工厂 + get/set/isXxx/toXxx，被 i2f-iterator 作元素三态协议、i2f-container RingQueue 作队列槽位直接依赖，经 i2f-text/i2f-match 两条主干传递至 jdbc/ai/脚本族 9 模块消费，零 Maven 依赖）、反射全家桶（ReflectResolver 单类 3414 行七大能力族——类加载/字段方法发现/注解解析（元注解递归 + @Repeatable 展开）/调用匹配（类型距离 + varargs 打包）/值读写（getter 优先）/Bean 复制（copy/assign/merge 三语义 + 弱名）/虚拟字段合成，叠加 RichConverter 泛型递归强转、ObjectRouteResolver 点分路由扁平↔树、ReflectSignature 签名互转与 vistor 表达式引擎（js 风格路径 + $root/$param 内建 + @ 静态调用），约 30 个 LruMap 缓存 + ENABLE_CACHE 开关；被 44 模块 79 源文件消费，是 lambda/properties/bql/spring-mvc-metadata 的共同反射底座，⚠ loadClassWithJdk 直载丢失/迭代器转换死循环等 16 项已实证瑕疵详见文档）、资源定位与类路径扫描（ResourceUtil 六态位置协议 classpath:/classpath*:/file:/URL/相对/绝对 → URL/Stream/Bytes/String + matchResources 通配 + getResourcesFiles 位置展开；ResourcesLoader 全类路径扫描引擎：目录递归 + jar 流 + 嵌套 jar URL 流式解包 + manifest Class-Path 补全 + jumpJre + 约 150 三方前缀默认排除表 + 包名前缀收缩 + ReflectResolver.loadClass 产 Class + RES_CACHE 缓存，支撑 netty 注解控制器扫包与 quartz 任务扫描；ResourceProvider assets 约定 SPI；被 io-file/idcard/ai-std/翻译族/Excel/逆向生成等 11 模块直接消费、经 i2f-ai-std 传递至 jdbc-procedure/xproc4j-starter 等 6 模块，零三方依赖，⚠ provider get(id) 变长参数传 null 数组 NPE 等瑕疵详见文档）、统一 API 响应契约（ApiResp 泛型响应体 code/msg/data 三字段 + 惰性 kvs 扩展键值 + 链式 add/code/msg/data + success/error/resp 静态工厂 + isSuccess 单判据 + ApiCode 七码常量接口 SUCCESS=200/ERROR=0/NO_LOGIN=401/NO_AUTH=403/UNKNOWN=402/NOT_FOUND=404/SYS_EXCEPTION=500，被 spring-starter 以 @ConditionalOnMissingBean 默认装配为全局响应包装/异常转换/404 转换器、security/shiro/sentinel/activity/spring-authentication 处理器与 ai-rest-openai MCP 网关直接使用，共 9 模块 23 源文件消费，仅 lombok 编译期依赖）、AWT 桌面自动化（RobotUtil 单类约 165 行：多屏设备枚举 + 主屏截屏/存图/取色 + 单键与组合键点击（Ctrl+C/V/X、Ctrl+Shift+Esc 等）+ 左中右键点击 + 左键插值拖拽，纯 JDK 零依赖、全仓尚无消费方）、表格行集流式读写（`IRowSet` = `Iterator` + `Closeable` 流式行集契约与 CSV 引号状态机读写 + BigDecimal/日期自动类型推断 + 长数字防科学计数，JSON 数组/JSONL 抽象写出注入 JSON 库，ops-starter 数据源控制台用于 CSV 导出/导入）、JSR-223 脚本引擎门面（ScriptProvider 聚合 ScriptEngine+Invocable+Compilable 三接口 + compile/invoke 运行时特性探测守卫 + getJavaScriptInstance 静态工厂；唯一消费方 xproc4j：`<lang-eval-javascript>` 求值节点与 Java 动态编译 import 注入；lombok 冗余声明、Java15+ 需自行补 nashorn-core）、极简前缀索引树双形态（PrefixSearchTree 泛型键序列 + StringSearchTree String 特化，ConcurrentSkipListMap 有序子节点 + add/find/prefix 前缀召回/collect 有序导出/printTree 树形打印，零消费方，⚠ remove 只清子树不删 data 与 null 键 NPE）、序列化标准契约（ISerializer 双动词统一「对象↔字节/文本」双通道九接口 + serialize=encode 桥接 codec 体系 + 类型化反序列化三级重载/deserializeAsMap/Base64 便捷 + 双向适配器 + 四级异常族；被 AI 栈（MCP 参数 deserializeAsMap）/HTTP 网络栈/SWL 加密传输族/哈希契约族等 26 模块 77 源文件消费，官方实现 JdkBytes/Json2/Xml2 下沉 i2f-serialize-impl，⚠ 适配器 null 语义缺失与类型参数静默忽略等实证瑕疵详见文档）、序列化官方实现（零第三方依赖自研 JSON 引擎 Json2/Json2Serializer 17 处实例化为全仓默认引擎 + JsonGenerator/JsonParser 双侧实现 + XML 只写生成 Xml2/Xml2Serializer + 独立树解析 XmlParser + 自描述文本 FormatText + JDK 原生/字符集字节互转；⚠ 探针实证 unescape 顺序缺陷吞转义、裸键 `{a:1}` 静默丢数、大整数 NFE、`<?xml?>` 声明解析崩溃等 12 项失败详见文档）等零三方依赖的通用工具。

### i2f-jdk-all

> **i2f-jdk 全子模块的 Maven 聚合分发包 / 将 i2f-jdk 域下所有功能模块打包为单体 fat-jar 的一站式构建入口**（仅 1 个 pom.xml 共 633 行、无 Java 源码、零测试零资源，聚合约 91 个内部 `i2f-jdk` 子模块依赖，使用 `maven-assembly-plugin:3.1.0` 以 `jar-with-dependencies` 目标打包，产出含 Manifest 元信息的独立 JAR）。

- 详细文档：[i2f-jdk-all](./i2f-jdk/i2f-jdk-all/readme.md)

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

### i2f-bytes

> 字节序编解码工具模块，单一静态门面 `ByteUtil` 以 48 个 `public static` 方法完成「7 种基本类型（long/int/short/char/boolean/float/double）× Big/Little 端序 × 新建数组/就地写入」双向互转，float/double 经 IEEE-754 位模式、boolean 经 0/1 归一统一收敛到 `long` 位移内核，另支持 1–8 字节任意宽度定长编解码；被 `i2f-otpauth`（HOTP 计数器）、`i2f-sm-crypto`（SM3 分组字）、`i2f-crypto-impl`（checksum）消费，零 Maven 依赖（`ofLittleEndianDouble` 有宽度误用瑕疵，详见文档）。

- 详细文档：[i2f-bytes](./i2f-jdk/i2f-bytes/readme.md)

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

### i2f-uid-impl

> **UID 生成器系列的「默认实现家族」**（3 实现类 448 行、单包 `i2f.uid`、零测试零资源），全量落地上游 uid-std 契约：`SnowflakeIntUid`（147 行，`implements IIntUid`）32 位**秒级**雪花（1 符号 + 28 秒 + 3 序列，2022-01-01 起点约 8 年、每秒实 7 个、**无 worker 位仅限单实例**）；`SnowflakeLongUid`（284 行，`implements ILongUid`）64 位**毫秒级**经典雪花（1 + 41ms + 10 worker + 12 seq，2020-01-01 起点 69 年，`getByMac()` 以网卡 MAC 集 Adler32 校验和推导 workerId 零配置自适应 + `nextPart()` 部件拆解）；`UuidRandomStringUid`（17 行，`implements IStringUid`）UUID 去连字符 32 位小写 hex。双雪花均为「`INSTANCE` 单例 + `public static UID` 可变全局 + 静态 `getId()/getIdHex()`」三重入口，时钟经 `IClock` 注入（默认 `SystemClock.INSTANCE`）。**消费：POM 直接依赖 4 模块**（`i2f-jdbc-procedure:79`、`i2f-log:27`、`i2f-mixins:53`、`i2f-springboot-ops-starter:158`）+ xproc4j 传递；**代码 6 文件全走 `SnowflakeLongUid` 静态入口**（脚本 DSL 系统值 `.snow-uid`、日志表主键、mixin 方法 `snowflake_id()`、AI 工具 `create_new_snowflake_id()`、eval-java 编译模板 `import i2f.uid.*`、idea-plugin 字符串模板），`SnowflakeIntUid`/`UuidRandomStringUid` 零外部消费；聚合 `i2f-jdk-all:597`、根 POM `:846`、清单 `i2f-jdk:162`。⚠ 瑕疵：seqId `% maxSeqId` 模基 off-by-one（每秒实 7 / 每毫秒实 4095 个，注释称 8/4096）、时间回拨 ≤10s 忙等自旋 >10s 直接抛异常、workerId 是哈希槽而非唯一分配（1023 号不可达/可撞槽/同机多实例碰撞）、`System.out` 静默降级、`UID` 静态可变致双入口行为分裂、`nextId()`/`nextPart()` 逻辑复制、固定起点到期（Int 约 2030 年中、Long 约 2089 年）溢出不设防、`UuidRandomStringUid` 细节欠打磨、lombok 声明未用 + 零测试——详见文档。

- 详细文档：[i2f-uid-impl](./i2f-jdk/i2f-uid-impl/readme.md)

### i2f-uid-std

> **UID 生成器系列的「标准契约层」**（std 契约与实现分离，3 接口 40 行、单包 `i2f.uid`、**零依赖**——pom 无任何 `<dependencies>`、零测试零资源）：三层契约树——根契约 `IStringUid`（`nextStringId()`）+ 两个数值派生 `IIntUid`（`nextIntId()` + default `%08x` 8 位 hex）/`ILongUid`（`nextLongId()` + default `%016x` 16 位 hex，定宽补零小写）；三接口均单抽象方法（**函数式接口**，可 lambda 实现）；实现家族全在下游 i2f-uid-impl（448 行 3 类：`SnowflakeIntUid` 147 行雪花 32 位 / `SnowflakeLongUid` 284 行雪花 64 位 / `UuidRandomStringUid` 17 行 UUID 去连字符）。**消费：唯一直接消费者 i2f-uid-impl**（3 类全 implements——`:20`/`:31`/`:10`）；间接链 6 文件全部使用具体类 `SnowflakeLongUid`（xproc4j/jdbc-procedure/i2f-log/i2f-mixins/springboot-ops-starter/idea-plugin 模板注入），无接口类型外部消费；POM 唯一依赖声明 `uid-impl:22`；聚合 `i2f-jdk-all:601`、根 POM `:851`、模块清单 `:163`。⚠ 瑕疵：三接口 `@desc` 全空**零 Javadoc**；`nextStringId` 默认方法为**「再生成」语义**（非视图——生成一次拿两种形态会消耗两个 ID）；字符串格式零契约（8/16/32 位各异、负数值输出补码）；`IIntUid`+`ILongUid` 同时实现**菱形默认方法冲突**须手动消歧；无反向解析/批量/元数据；零测试——详见文档。

- 详细文档：[i2f-uid-std](./i2f-jdk/i2f-uid-std/readme.md)

### i2f-unsafe

> 底层**内存窥探工具**，全模块仅静态类 `UnsafeHacker` 且 `pom.xml` 零 Maven 依赖：反射撬取 `sun.misc.Unsafe`（`getUnsafe` 双检锁缓存）、借一元素 `Object[]` 的引用槽读出对象物理地址（`addressOf`/`addressHexOf`）、反射调用 Nashorn `ObjectSizeCalculator` 估算对象深链字节大小（`sizeOf`，Nashorn 缺失时优雅返回 `-1` 并打印 `nashorn-core` 依赖提示）。面向内存诊断、缓存体积估算、对象身份比对等「绕开 Java 封装」的底层诉求；当前仅被 `i2f-jdk-all` 聚合引入。

- 详细文档：[i2f-unsafe](./i2f-jdk/i2f-unsafe/readme.md)

### i2f-verifycode

> **「看图答题」式图形验证码「生成 + 校验」框架**（19 源文件 1715 行、4 包 `std`/`impl`/`data`/`consts`、零测试零资源）：1 接口 `IVerifyCodeGenerator`（`generate(width,height,params)` + `verify(result,answer)`）+ 5 抽象基类按「交互形态 × 维度」定型模板方法（`AbsText` 文本比对 / `AbsPositionD1` 一维差 <5 / `AbsPositionD2` 二维距离 <8 / `AbsPositionD1Multi`、`AbsPositionD2Multi` 多点有序）+ 8 实现（字符艺术字、四则算式、双箭头加法、极坐标环形加法、横向标尺点击、矩阵散布点击、横向多点、矩阵多点）+ `VerifyCodeType` 枚举（INPUT/D1/D2/D1_MULTI/D2_MULTI，`implements IDict`）+ 4 DTO（`VerifyCodeQuestionDto.make` PNG→Base64 data URL）；答案统一 0~100 百分比（缩放无关），随机源 `MathUtil.RANDOM` 为 **SecureRandom**，模块**无状态**（标准答案随返回，会话业务侧自持）。**消费：全仓零 POM 直接依赖、零源码外部消费**（xml/md 40 + java 52 + 类名 17 命中全为自身/登记）；仅聚合 `i2f-jdk-all:609`、根 POM `:861`、清单 `i2f-jdk:165` 三处登记 + wiki 旁证（enums/graphics-2d/firewall readme）；平行模块 `i2f-extension-verifycode`（kaptcha 封装）**不依赖本模块**。⚠ 瑕疵：**多点有序点击顺序错位功能级 bug**（答案坐标按升序收集 vs 题面按随机索引序，正确点击也大概率失败）、`AbsPositionD2Multi:31` 类型码误用 `D1_MULTI`、Matrix 系 Y 轴三处不一致（`posY` 采 `width` + 单点/多点翻转互斥）、`MathCalc` 除零无兜底（`boundNumber=1` → `ArithmeticException` 直抛）、空 catch 7 处静默吞异常、容差（<5/<8）与 `%.2f` Locale 硬编码、`(Integer)` 强转无防护、`makeCode` 三处复制（2 处死代码）、`Graphics2D` 9 处从不 `dispose()`、`@desc` 空 + 零测试——详见文档。

- 详细文档：[i2f-verifycode](./i2f-jdk/i2f-verifycode/readme.md)

### i2f-workflow

> **「任务依赖编排 + DAG 并发调度」双引擎流程编排模块**（17 源文件 994 行、2 包 `i2f.workflow`/`rag`、零三方运行期依赖仅编译期 lombok）：**两代独立实现**——旧引擎 `WorkFlow`（2024/3）流式声明节点图（`add(…,prevIds)`+`done()`）、轮询监控按「前驱全部完成」触发、`ForkJoinPool(8)` 并发、`CountDownLatch` 通知、`activeIds` 活跃子集重跑、可定制 `exceptionHandler`；新引擎 `rag.DagScheduler`（2026/4）Kahn 拓扑分层调度（层内并发/层间栅栏）、`DagNode` 六态状态机、`DagEdge` 条件边（`Predicate` 判定前驱 result）、可插拔入站网关（`allSuccess` 默认/`anySuccess`/`leastSuccessCount(n)`）、`DagNodeType.HUMAN` 人工节点断点暂停/恢复（WAITING→CONTINUE 后重跑 run()）。**消费：全仓零 POM 直接依赖、零源码外部消费**（POM/源码/类名三层扫描除自身外 0 命中，阳性对照验证），仅聚合 `i2f-jdk-all:611`、根 POM `:864`、清单 `i2f-jdk:166` 三处登记 + wiki 零旁证。⚠ 瑕疵：**WorkFlow 默认异常处理器下失败节点「有下级后代」被移出等待表而 latch 计数不减 → `await()` 永久挂起**（:149/175-177/188）、`activeIds` 叶子遗漏+NPE（:58-68/:143-145/:183）、环零检测（爆栈/无限轮询）；**DagScheduler 条件边 SKIP 被默认 allSuccess 网关归为 FAILURE → run() 抛 IllegalStateException**（:80-81）——「跳过分支」核心语义默认崩溃、任务失败硬传播、重复 run() 时 WAITING 被 `of(WAITING)=SUCCESS` 放行下游、拓扑 O(V²)+幽灵 fromId 误报环、`await()` 无超时——详见文档。

- 详细文档：[i2f-workflow](./i2f-jdk/i2f-workflow/readme.md)

### i2f-xml

> **XML 解析双引擎 + 行号定位工具箱 + Maven POM 解析器**（4 源文件 1226 行、2 包 `i2f.xml`/`i2f.xml.maven`、唯一内部依赖 `i2f-match`（RegexUtil 位置注入）+ 编译期 lombok）：JDK 自带 JAXP 双引擎——**DOM** `parseXml` 七重载（**行号位置注入**：每个标签注入 `__line`/`__file` 属性供「文件:行号」级错误定位，解析失败自动回退原字节流）与 **StAX** `parseXmlSax` 流式构建六类型轻量树 `Xml`（DOCUMENT/ELEMENT/ATTRIBUTE/COMMENT/CDATA/TEXT + location* 字段）；`XmlUtil` 40+ 静态方法覆盖「解析→查找/取值（getRootNode/getChildNodes/getAttribute(s)）→遍历（walkXml 前序/后序）→转换（toDomNode/toText/extraInnerXml 去包裹）→懒填充缓存（walkFillDomAndInnerXml）」全链路；`maven` 子包 `MavenPomReader` 沿目录链递归父 POM + dependencyManagement 版本推导（Spring Boot/Cloud 前缀特化）；双工厂 XXE 三禁闭（禁 DTD/外部实体/命名空间）。**消费（本仓真实被使用的基础设施）**：POM 4 模块直接依赖（i18n:21 / jdbc-procedure:31 / jdbc-proxy-xml:25 / velocity-bindsql:47）+ 源码 8 文件 11 import 40 处 `XmlUtil.` 调用（MybatisMapperParser 12 / XmlI18nParser 11 / JdbcProcedureParser 5 —— StAX 侧已被 jdbc-procedure 与 idea-plugin 采用）+ wiki 旁证 6 处（i18n/jdbc-proxy-xml readme 均列为真实依赖）；登记三处：聚合 `i2f-jdk-all:615`、根 POM `:869`、清单 `i2f-jdk:167`。⚠ 瑕疵：**位置注入管线平台默认字符集缺陷**（:137/:156 未指 charset——非 UTF-8 平台编码下中文 XML 静默乱码或解析回退）、按行正则注入三大边界（跨行标签漏注入 / CDATA 与注释内字面标签被误注入篡改内容 / 标签名含 `.` 不匹配）、`walkClean` 类型判断取根节点（:584）致 TEXT/CDATA 的 value 一并清空、`parseXmlSax` START_DOCUMENT/ATTRIBUTE 分支不可达（next() 永不返回且前者误用 getElementText）+ `parseXmlSax(File/URL)` 输入流泄漏（reader.close 不关底层流）+ 六事件仅 println("ok") 调试残留、`MavenPomReader` 注释过滤笔误（:183 应为 key）、`extraInnerXml` 无条件剥离根全部属性、零测试零资源——详见文档。

- 详细文档：[i2f-xml](./i2f-jdk/i2f-xml/readme.md)

### i2f-match-std

> 字符串**匹配器标准契约层**（`std` 契约与实现分离），全模块仅两个接口：`IMatcher` 定义最小布尔契约 `matches(str, patten)`；`IPriorMatcher extends IMatcher` 把抽象方法换成打分版 `matchRate`（负＝不匹配，非负＝匹配精确度），再用 `default` 让布尔 `matches` 由 `matchRate` 派生，并沉淀供全体实现复用的打分公式 `calcMatchRate` 与规避浮点精度误判的阈值 `MATCH_SUCCESS_LIMIT=-0.5`——解决「一个串同时命中多模式时按精确度择优排序」。真正的 `SimpleMatcher`/`AntMatcher`/`RegexMatcher`、排序门面 `StringMatcher`、桥接 Spring 的 `SpringAntPathMatcher` 均在下游 `i2f-match`/`i2f-spring-core`；自身零 i2f 内部依赖（lombok 声明未用）。

- 详细文档：[i2f-match-std](./i2f-jdk/i2f-match-std/readme.md)

### i2f-match

> 字符串**匹配器实现层 + 正则工具箱**，落地 `i2f-match-std` 契约：`SimpleMatcher`（`*`/`?` 通配转义）、`AntMatcher`（`*`/`?`/`**` 分层，分隔符可配 `/`、`.`）、`RegexMatcher`（纯正则 + `LruMap` 缓存）三 `IPriorMatcher` 共享 `calcMatchRate` 打分，`StringMatcher` 门面以 `priorMatches` 把「一个串命中多模式」按精确度降序择优（`i2f-agent`/`i2f-log` 消费）；另一半 `regex` 子包（`RegexUtil` 的 find/parts/replace/format + `RegexPattens` 预编译目录）是被约 20 个模块共用的全仓正则底座。依赖 `i2f-match-std`+`i2f-lru-map`+`i2f-iterator`，运行期零三方。

- 详细文档：[i2f-match](./i2f-jdk/i2f-match/readme.md)

### i2f-lru-map

> 内存缓存 / 自调节容器 / 弱引用复用 / RAII 作用域**工具族**（单包 `i2f.lru`，13 类）：LRU 家族 `LruMap`（`LinkedHashMap`+`removeEldestEntry` 容量淘汰、全方法套 `ReentrantLock`，`accessOrder=true` 才按访问序）/`WindowLruMap`（`Duration` 时间片槽位键）/`LruList`（`touch` 提头自调节）/`ConcurrentLinkedSet`（双 map 手写双向链集）/`ConcurrentLruCache`（读优并发生成式 LRU）；过期记忆化 `ExpireConcurrentMap`/`CachedSupplier`；弱引用复用 `WeakEntry`（`ReferenceQueue` 清理线程）+ `WeakStackRetrieveCacheProvider`（L1/L2 `ThreadLocal` 按 `==` 复用幂等转换）；RAII `ScopeValue`/`UncheckedScopeValue`（锁/`ThreadLocal`/close 自动配对）。`LruMap` 是全仓反射/编译缓存事实标准（lambda/bql/compiler/jdbc-proxy/log 等大量消费）；实际仅用 `i2f-clock-impl` 的 `SystemClock`（`i2f-cache-std`、`lombok` 声明未用）。

- 详细文档：[i2f-lru-map](./i2f-jdk/i2f-lru-map/readme.md)

### i2f-lru-cache

> 将 LRU 淘汰策略接入缓存接口的**适配桥接模块**（1 源文件 24 行）：`LruMapCache<K,V>` 继承 `i2f-cache.MapCache`，通过构造器注入 `i2f-lru-map.LruMap` 替换底层 `ConcurrentHashMap`，使缓存操作自带 LRU 容量淘汰语义（超出容量自动淘汰最久未访问条目）。三个构造器分别对应默认 1024 容量、指定容量、外部注入 LruMap 实例。产物仍是 `IContainerCache`，可与 `ExpireCacheWrapper` 装饰器组合实现「LRU + TTL」双淘汰策略。依赖 `i2f-lru-map` + `i2f-cache`，`lombok` 声明未用。

- 详细文档：[i2f-lru-cache](./i2f-jdk/i2f-lru-cache/readme.md)

### i2f-math

> **数学计算工具箱**（14 源文件约 3100 行，零三方运行期依赖），覆盖 5 个零耦合子领域：`MathUtil` 静态门面（~70+ 方法：三角/插值/钳制/排列组合/距离/随机数/精度截断）；`FormulaCalculator` 双栈字符串公式计算器（60+ 运算符：基础算术/根对数累加累乘/位运算/三角函数族/阶乘/进制换算/单位转换/斐波那契）；`Matrix`/`MatrixInt` 矩阵运算（加/乘/转置/单位阵）；`Segment<T,D>` 四元组区间抽象（Integer/Long/Double/Date 四实现 + 重叠判定）；`Fibonacci`/`Factorial` 缓存数列（BigInteger 数组），`HexNumberConverter` 2-36 进制互转。下游 `i2f-color`/`i2f-graphics-*`/`i2f-image-impl` 消费 `MathUtil`；`i2f-ai-std`/`i2f-extension-xproc4j` 消费 `FormulaCalculator`。**瑕疵**：`combination` int 溢出/漏乘、`Fibonacci` 负值行为不一致、`regular` while 循环大值性能差、`MatrixDiffrentException` 拼写错误等。

- 详细文档：[i2f-math](./i2f-jdk/i2f-math/readme.md)

### i2f-mixins

> **混入式函数编程工具箱**（22 源文件约 3900 行，10 个运行期 i2f 内部依赖），以 JDK 接口默认方法实现 Java 的"多重继承"式函数编程：`MixinProxyFactory` 基于 `DefaultMethodSmartInvocationHandler` + JDK 动态代理生成接口实例（`ConcurrentHashMap` 缓存，免匿名对象）；`AllMixins` 聚合 18 个 `*Mixins` 接口。九大领域——`StringMixins`（1258 行，~70+ 方法：7 种命名风格转换/命名填充修剪/join 通用五类型/Oracle `to_char` 数字格式/Base64/URL编码/SQL 转义）；`MathMixins`（625 行，~50+ 方法：`BigDecimal` 泛型算术/三角函数族/`round`/`trunc` 精度控制/进制 2-36 互转/`fibonacci`/`factorial`/聚集运算）；`ObjectMixins`（457 行：六级级联比较/`Visitor` 表达式访问/`decode`/`coalesce` 条件选择/多类型 `is_empty`/`length`）；`DateMixins`（363 行：`ChronoUnit` 别名映射 22 种/日期算术/`timestamp` 互转/`trunc`）；`RegexMixins`（322 行：Oracle POSIX 正则转换/`occurrence` 替换/`split_literal`）；`ArrayMixins`（159 行：负索引读写/元素类型转换）；`FileMixins`（103 行：文本文件读写）；`CollectionMixins`/`MapMixins`/`SystemMixins`/`ThreadMixins`/`ThreadLocalMixins`/`CommandLineMixins`/`RandomMixins`/`JvmMixins`/`OsMixins`/`MatchMixins`/`UuidMixins` 各 22–85 行。**瑕疵**：`StringMixins.substr_count` 变量名笔误（自身比自身）、`MathMixins.min_of` 与 `max_of` 返回类型不对称、`CommandLineMixins.exec` 异常仅 `printStackTrace`。

- 详细文档：[i2f-mixins](./i2f-jdk/i2f-mixins/readme.md)

### i2f-native-core

> **原生（JNI）指针工具箱**（5 源文件约 180 行 + 309 行 C/C++ 教程），为 JNI 开发提供底层基础设施：`Ptr` 指针值类型安全包装（`isZero`/`isNegOne` 哨兵判定 + `equals`/`hashCode`）；`MallocPtr`/`NewPtr`/`NewArrayPtr` 三指针类型标记（区分 `malloc`/`new`/`new[]` 分配来源，便于上层封装对应释放方式）；`NativeUtil` 原生库加载工具（`loadClasspathLib` 从 classpath 释放 `.dll`/`.so` 到 `./lib/` 目录后 `System.load`，一行解决 JAR 内打包原生库场景）；附带 `cpp_native_dev.md` 系统教程（JNI 函数命名/字符串数组操作/Visual Studio DLL 工程配置）。下游 `i2f-native-windows`/`i2f-native-windows-easyx` 消费。**瑕疵**：`Ptr` 无自动释放/AutoCloseable、`loadClasspathLib` 并发无锁、释放路径硬编码不可配置等。

- 详细文档：[i2f-native-core](./i2f-jdk/i2f-native-core/readme.md)

### i2f-native-windows

> **Windows（JNI）原生 API 门面**（153 Java 源文件 + 2 C++ 项目，总计约 15000+ 行），两层架构（`NativesWindows` 920 行 ~250+ native 原生方法声明 + `WinApi` 3494 行类型安全 Java 门面 + 50 个 Handle 子类 + 94 个常量接口），13 大子域覆盖：窗口管理（findWindow/enumWindows/createWindowEx/messageBox/messageLoop/bindMessageCallbacker）；GDI 绘图（120+ 方法：bitBlt/stretchBlt/createCompatibleBitmap/createDIBSection/rectangle/ellipse/polygon/polyBezier/path/region/DC 全栈）；输入模拟（keyboardEvent/mouseEvent/setCursorPos/getAsyncKeyState）；进程/线程（openProcess/createThread/suspendResume/snapshot/toolhelp/privilege）；文件系统（createFile/readFile/writeFile/encryptFile/symbolicLink）；注册表（8 方法 CRUD）；服务控制（12 方法全生命周期）；COM（coInitialize/coCreateInstance/coInstanceQueryInterface）；Shell（shortcut/recycleBin/fileOp/specialFolder）；控制台（allocConsole/freopenStdio）；Win32 App 框架（registerClassEx/createWindowEx/defWindowProc/postQuitMessage）；Win8 DPI 扩展（getDpiForMonitor/getScaleFactorForMonitor）。依赖 `i2f-native-core`（Ptr/NativeUtil）+ `i2f-graphics-2d`（Point/Size/Rectangle）+ `i2f-convert`。**瑕疵**：`freeMallocPtr` 等需手动 finally 释放、JNI 异常无包装、`registerClassEx` 10 参无 Builder、`WinSendMessageMsg` 300+ 消息常量平铺、测试类在 src/main/java 下随 jar 发布等。

- 详细文档：[i2f-native-windows](./i2f-jdk/i2f-native-windows/readme.md)

### i2f-native-windows-easyx

> **EasyX 图形库（JNI）Java 门面**（9 Java 源文件 + 1 C++ 项目 1571 行，总计约 2900 行），两层架构（`NativesEasyX` 378 行 ~110 native 方法 + `EasyXApi` 953 行类型安全 Java API 门面），在 `i2f-native-windows` 的 Win32 GDI 基础之上封装 EasyX 轻量级图形库，一行 `initGraph` 即创建图形窗口。覆盖 11 大功能域：窗口生命周期（initGraph/closeGraph/clearDevice/beginBatchDraw/endBatchDraw）；绘图原语（circle/rectangle/ellipse/pie/polygon/roundRect/bar/bar3d/arc + 4 变体 outline/fill/clear/solid 共 40+ 方法）；文字输出（outText/outTextXy/drawText/setTextStyle 4 重载/setTextStyleLogFont 14 参）；图像操作（loadImage/createImage/freeImage/saveImage/putImage/resize/rotateImage + 像素缓冲区读写）；绘图状态（color/fillColor/lineColor/textColor/bkColor/bkMode/fillStyle 4 重载/lineStyle 4 重载/writeMode/polyFillMode/rop2/origin/aspectRatio）；批量绘制（beginBatchDraw/endBatchDraw/flushBatchDraw）；鼠标输入（mouseHit/getMouseMsg/flushMouseMsgBuffer）；输入框（inputBox 6 重载）；颜色转换（hslToRgb/hsvToRgb/bgr/getRValue/getGValue/getBValue/rgbToGray/rgbToHsl/rgbToHsv）；光标/坐标（getX/getY/getPoint/moveTo/moveRel/lineTo/lineRel + getWidth/getHeight/getMaxX/getMaxY）；工作图像（setWorkingImage/getWorkingImage）。依赖 `i2f-native-windows`（Hwnd/Hdc/WinApi/GDI 常量）+ `i2f-native-core`（Ptr）+ `i2f-graphics-2d`（Point/Size/Rectangle）+ `i2f-convert`。**瑕疵**：`freeImage` 需手动 finally 释放、JNI 字符串解析无编译期保护、`setTextStyleLogFont` 14 参无 Builder、颜色 int 无类型安全、测试类在 src/main/java 下随 jar 发布等。

- 详细文档：[i2f-native-windows-easyx](./i2f-jdk/i2f-native-windows-easyx/readme.md)

### i2f-number-idcard

> **中国大陆身份证号码解析/校验工具**（3 源文件约 164 行 + 3516 行行政区划字典随 jar 内置），以 GB 11643-1999 标准实现 18 位公民身份号码的一站式解析与校验：`IdCardNumberUtil.parse` 一次切分「区划码/出生日期/顺序码/性别位/校验位」五段并回填 16 字段结果模型 `IdNumberData`（区划中文名、性别中文、闰年判定、日期对象等派生字段俱全），失败时以 `illegalReason` 说明原因而不抛异常；`isLegalIdNumber` 聚合「格式 + 日期 + 校验码」三层判定；校验码按标准「加权因子表 `{7,9,10,5,8,4,2,1,6,3,7,9,10,5,8,4,2}` + 模 11 余数映射表」计算（已手工验算与 GB 11643 一致）；`RegionMap` 类加载时经 `i2f-resources` 加载内置字典，`decode` 提供 6 位区划码 → 中文全称查询。依赖 `i2f-datetime`（`Dates.isLeapYear`/`isLegalDate`）+ `i2f-resources` + `lombok`（`@Data` 真实使用）；全仓暂无源码级消费者（仅 `i2f-jdk-all` 聚合与根 POM 版本托管）。**瑕疵**：字典 630000-659004（青海 53 行/宁夏 31 行/新疆 117 行，共 201 行）名称全部误加「甘肃省」前缀、字典版本陈旧（含崇文/宣武/密云县等已撤销区划且缺港澳台）、`RegionMap` 未指定 UTF-8 字符集（GBK 环境乱码）、格式正则 `[0-9|x]` 混入字面量 `|`、`dateFmt` 共享 `SimpleDateFormat` 线程不安全等。

- 详细文档：[i2f-number-idcard](./i2f-jdk/i2f-number-idcard/readme.md)

### i2f-cache-std

> 缓存**标准契约层**（`std` 契约与实现分离），全模块仅 6 个纯接口、零实现零逻辑：根接口 `ICache<K,V>` 以 `get/set/exists/remove` 四动词刻画键值缓存最小本质，沿「容器枚举」`IContainerCache`（`keys/clean` + 默认 `size/forEach`）、「过期」`IExpireCache`（TTL `set` + `expire/getExpire` + `preferSetAndTtl` 提示）、「持久/分布式」`IPersistCache`/`IDistributedCache`（两个空标记接口）三条正交轴继承扩展，并以 `IExpireContainerCache`（容器 ∩ 过期）汇聚组合契约。真正的 `MapCache`/`ExpireCacheWrapper`（`i2f-cache`）、`RedisCache`/`ZookeeperCache`/`HazelcastCache`（各 `i2f-extension-*`）为其下游实现，`i2f-swl`/`i2f-limit`/`i2f-jdk-ext-web` 等面向接口消费；自身零 i2f 内部依赖（pom 声明的 lombok 实际未用）。

- 详细文档：[i2f-cache-std](./i2f-jdk/i2f-cache-std/readme.md)

### i2f-cache

> 缓存**本地实现层**（落地 `i2f-cache-std`，4 类零三方）：`MapCache`（`implements IContainerCache`）把可注入的 `Map`（默认 `ConcurrentHashMap`）适配为可枚举容器缓存，覆写 `size/forEach` 走原生 `Map`；`ExpireCacheWrapper`（`implements IExpireCache`）以「装饰器 + `ExpireData` 信封编解码」把任意 `ICache` 升级为带 TTL 过期缓存、单 `ReentrantLock` 串行化 + 读取时惰性淘汰；`ObjectExpireCacheWrapper` 是其 `T=Object` 具化，与 `MapCache` **正交组合**即得「本地 + 可过期」默认装配（`i2f-swl`/`i2f-limit`/各 `*-starter` 广泛消费，`i2f-lru-cache` 的 `LruMapCache extends MapCache` 换底层为 `LruMap`）；依赖 `i2f-cache-std` + `lombok`（真用于 `ExpireData`）。**瑕疵**：`getExpire` 忽略入参 `TimeUnit`（实返毫秒差）、`exists` 不校验过期（与 `get` 判期自相矛盾）、粗粒度单锁串行全部读写、过期条目无后台清扫等（详见文档）。

- 详细文档：[i2f-cache](./i2f-jdk/i2f-cache/readme.md)

### i2f-check

> **校验/断言工具箱**（3 类、**pom 零依赖**）：`Checker<T>` 是可累积、可换值、可快速失败的流式校验链——`begin(val)` 起链，`test/testOr/testBi`（断言真）与 `not/notOr/notBi`（断言假）把未满足的断言以错误消息累积进 `errList`，`next/map` 及 3 参 `test/not` 重载沿链切换当前值并**拷贝前滚**已收集错误，终态经 `get/errors/errorMessage/error/end/except/exceptMessage` 一次性消费（判过、拼接、回调或以自定义 `Function` 抛异常），`once()` 一键切换「记全部」与「只记首个」；`Predicates` 是约 90 个「为方法引用而生」的静态布尔谓词（判空/相等/字符串/集合/数组/类型/字符/成员判定），匹配 `Checker` 的 `Predicate`/`BiPredicate` 槽位亦可独立使用。生产侧仅 `Predicates` 被 `i2f-serialize-impl`（`JsonGenerator`）、`i2f-extension-xproc4j` 消费，`Checker` 目前仅 `TestChecker` demo 使用。**瑕疵**：`isIntegerString`/`isDoubleString` 正则 `[+|-]` 误含字面量 `|`、`isDoubleString` 强制带小数位、换值错误列表拷贝不共享、`Checker` 非线程安全且无生产消费方等（详见文档）。

- 详细文档：[i2f-check](./i2f-jdk/i2f-check/readme.md)

### i2f-check-filter

> **存在性判定 / 大数据去重过滤器族**（8 类，内存级 + 大数据级）：`ICheckFilter<T>` 以 `mark/exists` 定义内存判重契约，直接实现 `BloomFilter<T>`（位数组 + 多哈希、概率型）；`IRepeatFilter<T>` 以 `filter(writer, readers)` 定义大数据多源流式去重契约——`HashBloomRepeatFilter<T>` 基于布隆做近似去重（边读边判或预训练后判），`HashGroupRepeatFilter<T>` 基于哈希分组 + 临时文件做精确去重（可自定义 `IRepeatDecider` 保留条件）；`IHashGroupProvider` 抽象分组持久化、默认 `StreamHashGroupProvider` 落临时文件。依赖 `i2f-hash` + `i2f-data-processor`，`lombok` 声明未用。全仓无外部 import 消费（仅 `i2f-jdk-all` 聚合纳入）。

- 详细文档：[i2f-check-filter](./i2f-jdk/i2f-check-filter/readme.md)

### i2f-code

> **码值/密钥生成器**（全模块仅 1 个静态门面类 `CodeUtil`、2 组方法、42 行源码、零内部依赖）：`makeUUID()` 把 `UUID.randomUUID()` 去连字符全大写压缩为 32 位紧凑形式；`makeCheckCode(len)` / `makeCheckCode(len, onlyNumber)` 基于 `SecureRandom` 从 `[0-9a-zA-Z]` 62 字符均匀采样（纯数字模式缩为 10 字符），`rand.nextInt(bounce)` 避免模偏差。真实消费方 `i2f-swl.SwlAesSymmetricEncryptor`（`makeCheckCode(16)` 生成 AES-128 密钥）与 `i2f-extension-swl.SwlBcAes256SymmetricEncryptor`（`makeCheckCode(32)` 生成 AES-256 密钥）；`lombok` 声明未用。

- 详细文档：[i2f-code](./i2f-jdk/i2f-code/readme.md)

### i2f-codec-std

> **编解码标准契约层**（`std` 契约与实现分离，8 类型全接口+1异常、零 i2f 内部依赖、零三方运行期）：根接口 `ICodec<E,D>` 以 `encode/decode` 双动词定义「类型 E ↔ D 之间双向转换」的最小契约，沿数据形态正交衍生 5 个子接口——`IStringByteCodec`（`String↔byte[]`，Base64/Hex/Charset 等）、`IStringStringCodec`（`String↔String`，URL/HTML/Unicode 转义）、`IStringCollectionCodec<T,C>`（`String↔Collection<T>`，ID 打包解包）、`IByteByteCodec`（`byte[]↔byte[]`，压缩加密）、`IStreamCodecEx`（`OutputStream↔InputStream`，流式零拷贝）；`ICodecEx<E,D>` 以「目标入参风格」补充流式场景；`CodecException` 统一异常。下游 `i2f-codec-impl`（25 实现类）、`i2f-serialize-std`、`i2f-crypto-std`；lombok 声明未用。

- 详细文档：[i2f-codec-std](./i2f-jdk/i2f-codec-std/readme.md)

### i2f-codec-impl

> 编解码**实现层**——落地 `i2f-codec-std` 全部 5 组接口（36 源文件、12 子包、23 实现类），覆盖 5 大领域：字节编解码（Base64/Base32/Base16/Hex/Bin/Dec/Otc/Charset 共 10 实现）、字符串转义（URL/%XX/HTML CER+NCR/Unicode/XML 共 6 实现）、集合 ID 打包（`IdPackCodec`）、压缩（Gzip/Deflate/Zip × 字节 + 流式双模式共 6 实现）；`CodecUtil` 静态门面（25+ 便捷方法）一行完成常见操作；引擎与适配器分离（`Base16`/`Base32`/`Base64` 纯算法零 i2f 依赖）；`DataProtocolUtil` 支持 data: URI 协议、`Base64Obfuscator` 提供 Base64 混淆。依赖 `i2f-codec-std` + `i2f-io-stream` + `i2f-match`；lombok 真实用于 `DataProtocolMeta`。外部消费方 `i2f-extension-swl`/`i2f-extension-jce-bc`/`i2f-extension-jce-sm-antherd`/`i2f-extension-verifycode`。

- 详细文档：[i2f-codec-impl](./i2f-jdk/i2f-codec-impl/readme.md)

### i2f-color

> RGBA / HSL 色彩空间表示与转换模型（全模块仅 2 个类 `Rgba` + `Hsl`、约 310 行源码）：`Rgba`（`@Data` `@NoArgsConstructor`）以 4 个 `public int`（`r/g/b/a`）定义 0–255 范围 RGBA 色彩，内嵌 `Channel` 位掩码枚举（R/G/B/A/RGB/RGBA），提供 `rgba(int)`/`argb(int)` 双字节序工厂与 `rgba()`/`argb()` 序列化、gamma 2.2 灰度 `gray()`、归一化曼哈顿色差 `diff()`、代理 `MathUtil.smooth` 的线性插值；`Hsl` 以 `h/s/l` 双精度浮点描述 HSL 色彩，含标准 `rgb2hsl`/`hsl2rgb` 双向转换算法；`Rgba.hsl()`/`Hsl.rgba()` 彼此持有引用，实现 RGBA↔HSL 零拷贝互转。预定义 10 色常量。依赖 `i2f-math`（`MathUtil.between/smooth`）+ `lombok`（**真实用于 `Rgba`**）。`i2f-graphics-2d`/`i2f-graphics-3d`/`i2f-image-impl`（~18 滤镜）/`i2f-extension-gif` 为其下游消费方。**瑕疵**：`Hsl.hsl2rgb()` L120 复制粘贴笔误——`b` 通道未钳制（`r` 被钳两次，`b` 跳过）。

- 详细文档：[i2f-color](./i2f-jdk/i2f-color/readme.md)

### i2f-comparator

> **通用比较器工具箱**（6 类、零三方依赖）：核心为 `NullableComparator` 的 **null 哨兵协议**（`compareNull` 三态返回——`0`/`±1`/哨兵 `9` 表示「均非空需继续」），`reverseNull`/`reverseResult` 双开关贯穿全模块；`DefaultComparator.compareDefault()` 实现**六级兜底级联**：同类 `Comparable` → `TypeOf` 类型兼容（父子类/包装基本类型）→ 数值 `BigDecimal` 精比 → `CharSequence` 字典序 → try 尝试 `Comparable` → `hashCode` 兜底；`ArrayComparator` 提供 `T[]` + 8 种基本类型数组字典序比较（4 重载链）；`AntiComparator`（反序）/`BeanPropertyComparator`（方法引用提取属性比较）为装饰器；`Comparators` 是方法引用友好静态门面（~28 方法，`Comparators::compareInteger` 即得 `Comparator<Integer>`）。依赖 `i2f-typeof` + `i2f-convert`。真实消费方 `i2f-proxy-handlers.ValidateProxyHandler`（`@Validate` 值相等与 min/max 范围判定）。**瑕疵**：`Comparators.compareBooleanArray(short[])` 命名笔误（应为 `compareShortArray`）、`DefaultComparator` 归一化死代码致符号丢失（`if (ret>0) ret=-1;` 后被 `ret=1` 覆盖，违反反对称契约）、`DefaultComparator` 实例开关不可配置、原始类型数组装箱开销等（详见文档）。

- 详细文档：[i2f-comparator](./i2f-jdk/i2f-comparator/readme.md)

### i2f-compiler

> **内存 Java 编译器 / 表达式求值器**（全模块仅 1 个静态门面类 `MemoryCompiler`、551 行、~27 方法、2 源文件）：基于 `javax.tools.JavaCompiler`（JDK 编译 API）实现三级递进能力——文件级 `compileAsFile` 编译到磁盘、类级 `compileClass`/`findCompileClass` 编译→类加载→自动清理（四级 `LruMap` 2048 缓存）、求值级 `evaluateExpression(expr, root)` 以 `###import`/`###class`/`###method` 三标签 DSL 包装表达式为完整 Java 类后反射求值并自动注入 13 条默认 import 与智能 `return` 补全；`compileCall`/`compileCallRandomClass` 支持编译后直接调用指定方法。实际依赖 `i2f-io-file` + `i2f-reflect` + `i2f-lru-map` + `i2f-std-const`（均真实使用），`lombok` 声明未用。下游 `i2f-extension-xproc4j`/`i2f-jdbc-proxy-xml`/`i2f-extension-agent-javassist` 广泛消费。需完整 JDK（`tools.jar`），JRE 不可用。

- 详细文档：[i2f-compiler](./i2f-jdk/i2f-compiler/readme.md)

### i2f-compress-std

> 压缩**标准契约层**（`std` 契约与实现分离，5 类型：2 接口 + 2 数据模型 + 1 抽象骨架、零 i2f 内部依赖）：以 `ICompressor` 定义**多文件归档级**压缩契约（`compress*` 打包 + `release` 解包），以 `ISingleCompressor` 定义**单流级**压缩契约（`compress/release(is, os)` 流式编解码），以 `AbsCompressor` 沉淀 `compressFile`（`Predicate` 过滤递归遍历→`CompressBindFile`→`CompressBindData`）与 `release`（默认解压到磁盘目录）的公共骨架；`CompressBindData`/`CompressBindFile` 为数据载体。下游 `i2f-compress-impl`（JDK Zip/Jar + Gzip/Deflate/Zip 单流共 5 实现）、`i2f-extension-7zip`、`i2f-extension-compress`（Apache 五格式）、`i2f-extension-zip4j` 加 `i2f-jdk-all` 聚合；依赖 `i2f-io-stream` + `lombok`（**真实使用**于数据模型，区别于多数 std 模块的冗余声明）。

- 详细文档：[i2f-compress-std](./i2f-jdk/i2f-compress-std/readme.md)

### i2f-compress-impl

> 压缩**JDK 内置实现层**——落地 `i2f-compress-std` 全部契约（`ICompressor` + `ISingleCompressor`），以 5 个实现类 + 1 个 Test demo 覆盖 JDK 标准库自带的 5 种格式：归档级 `ZipJdkCompressor` / `JarJdkCompressor`（`extends AbsCompressor`，`ZipEntry`/`JarEntry` 条目遍历，目录项跳过、路径前缀裁剪）；单流级 `GzipSingleCompressor` / `DeflaterSingleCompressor` / `ZipSingleCompressor`（`implements ISingleCompressor`，各自包装 JDK 流，`ZipSingleCompressor` 以固定 `"data"` 条目名模拟单流 + `BlackHoleOutputStream` 吞非目标条目）。全模块零三方运行期依赖。真实消费方 `i2f-translate-en2zh`/`i2f-translate-zh2pinyin` 经 `ZipJdkCompressor` 解压内置词典 zip；依赖 `i2f-compress-std` + `i2f-io-file` + `lombok`（后两者实际未直接 import）。

- 详细文档：[i2f-compress-impl](./i2f-jdk/i2f-compress-impl/readme.md)

### i2f-console-color

> **ANSI 控制台彩色输出工具**（全模块 6 源文件、约 330 行、**pom 零依赖**）：以 `ConsoleElement` 标记接口为锚，3 枚举（`ConsoleColor` 18 前景 / `ConsoleBackground` 18 背景 / `ConsoleStyle` 5 样式）覆盖标准 ANSI SGR 参数；`ConsoleOutput` 门面以 `encode`/`toString`/`toAnsiString` 三组方法自动编排 `\u001b[{code}m` 转义（连续元素 `;` 合并、末尾自动 `RESET`）；`DETECT`/`ALWAYS`/`NEVER` 三态开关 + IDEA agent 白名单检测 + `System.console()` + Windows 判定自动化检测；禁用模式过滤 ConsoleElement 仅输出纯文本。真实消费方 `i2f-log-std.StdioLogger`/`i2f-log.DefaultLogDataFormatter`（彩色日志行格式化）。

- 详细文档：[i2f-console-color](./i2f-jdk/i2f-console-color/readme.md)

### i2f-container

> **集合容器增强工具族**（30 源文件、约 3800 行，零三方依赖）——六大子领域：`CollectionUtil`（~300 方法、870 行）以 `of/as/ofArgs/ofArray/as/arrayAs` 六族 × `Iterator` 源 + `index/length` 切片 + `filter/mapper` + 8 种基本类型数组共 9 核电重载覆盖全部集合收集场景；`RingQueue`（环形数组 + ReentrantReadWriteLock + Condition 双条件变量）实现有界阻塞队列；`map.LruMap`（44 行覆写 `LinkedHashMap.removeEldestEntry` 容量淘汰）与 `SyncLruMap`（线程安全壳）；`set.ConcurrentSet`（ConcurrentHashMap 后备并发 Set，`addAll`/`retainAll`/`removeIf` 写锁保护）；`sync.*` 族（`Syncs` 12 工厂 + `Synchronizer` 泛型读写锁门面 + `SyncAdapter` 模板方法 + `SyncProxyAdapter` JDK 动态代理 + 12 个 `Sync*Adapter` 覆盖 Collection/List/Set/Map/Queue/Stack/LinkedList/LinkedHashMap/Iterator/ListIterator/Enumeration/Spliterator）提供完备同步包装；`readonly.*` 族（`Readonlys` 4 工厂 + 6 `Readonly*Adapter` + `ReadonlyException` 篡改抛异常）。依赖 `i2f-reference`（RingQueue 使用），`i2f-iterator` pom 声明但未直接 import。

- 详细文档：[i2f-container](./i2f-jdk/i2f-container/readme.md)

### i2f-container-builder

> **流式集合/Map/对象构建器族**（4 Builder + 1 静态门面 `Builders`、约 1190 行、依赖 `i2f-typeof`）：以 *fluent builder* 模式补齐 JDK 集合框架缺失的链式构造——`ObjectBuilder<T>` 用 `then`/`set` 经方法引用链式修改 POJO；`CollectionBuilder<E,C>`/`ListBuilder<E,C>` 以 `add`/`adds` 多重重载（变长参数/Iterable/Iterator + 转换函数 `Function<H,E>` + `Predicate` 过滤 + null 安全）流式填充集合/List；`MapBuilder<K,V,M>` 以 `put`/`putKeys` 多重变体（固定值/值函数 + 键转换 `Function<H,K>` + key 过滤）流式填充 Map，并委拖 Map 全部变更操作（`putAll`/`replaceAll`/`computeIfAbsent`/`merge` 等）的 fluent 壳。全部实现 `Supplier<T>`（`.get()` 终结），`Builders` 提供约 50 静态工厂（`Builders.newArrayList(String.class)` / `newHashMap(String.class,Object.class)` / `newObj(TestBean::new)`）。真实消费方 `i2f-bql`/`i2f-extension-xproc4j`/`i2f-jdbc-procedure`/`i2f-springboot-xproc4j-starter`。**瑕疵**：`TypeToken`/`Class` 参数仅接受不校验、无 fluent 查询操作、`putKeys` 重载爆炸 ~30 个、Builder 非线程安全等（详见文档）。

- 详细文档：[i2f-container-builder](./i2f-jdk/i2f-container-builder/readme.md)

### i2f-context-std

> IoC 容器**标准契约层**（`std` 契约与实现分离），全模块仅 **4 个纯接口**（58 行总代码、零 i2f 内部依赖、零三方运行期）：根接口 `IContext` 以 `getBean(Class)`/`getBeans(Class)`/`getAllBeans()` 三动词刻画「按类型查询 Bean」的最小 IoC 契约；`INamingContext extends IContext` 补充 `getBean(String)`/`getBeansMap(Class)`/`getAllBeansMap()` 按名查询维度；`IWritableContext extends IContext` 与 `IWritableNamingContext extends INamingContext` 各自添加 `addBean`/`removeBean` 写操作，4 接口构成 **2×2 正交矩阵**（查询维度 × 读写性）。下游 `i2f-context-impl.ListableContext` 提供纯 JDK 内存实现，`i2f-ai-std`/`i2f-extension-ai-*`（约 25 文件）面向接口编程消费，`i2f-spring-core` 适配 Spring 容器。lombok 声明未用。

- 详细文档：[i2f-context-std](./i2f-jdk/i2f-context-std/readme.md)

### i2f-context-impl

> IoC 容器**纯 JDK 内存实现层**——落地 `i2f-context-std` 全部 4 接口，以 2 个类约 240 行源码提供双变体实现：`ListableContext`（`implements IWritableContext`）用 `CopyOnWriteArrayList` + `synchronized` 去重保护做无名类型仓储，`getBean` 以精确类型匹配优先、`isAssignableFrom` 兼容匹配兜底两阶段查找；`ListableNamingContext`（`implements IWritableNamingContext, IWritableContext`）以 `ConcurrentHashMap`（名→Bean）+ `CopyOnWriteArrayList` 双结构 + `ReentrantReadWriteLock` 写锁串行化变更、`guessBeanName` 默认取全限定类名、`addBean(name, bean)` 重复名抛异常、`removeBean(Object)` 线性遍历值相等定位后双结构清理。依赖 `i2f-context-std`；lombok 声明未用。真实消费方 `i2f-ai-std`（MCP 网关/工具提供者）与 `i2f-jdbc-procedure` 用 `ListableNamingContext`，三大 AI 扩展（DashScope/LangChain4j8/OpenAI）用 `ListableContext`。**瑕疵**：`getBeansMap` 遍历无读锁保护、`removeBean(Object)` O(n) 全表扫描、AOP 代理 Bean 精确匹配分支不可达、`synchronized(list)` 非强一致等（详见文档）。

- 详细文档：[i2f-context-impl](./i2f-jdk/i2f-context-impl/readme.md)

### i2f-convert

> **通用类型转换工具箱**（6 源文件、约 1760 行、真实依赖 `i2f-typeof`）——以 `ObjectConvertor.tryConvertAsType(val, targetType)` 为核心的单片式「万能类型转换器」，覆盖数值/布尔/字符/日期/字符串/枚举/集合/Map/数组/URL/URI/File/Charset/Locale/InetAddress/MessageDigest/Mac/Cipher/Class 等 20+ 类型域，以源→目标双向匹配 + BigDecimal/Instant 归一化中转 + 字符串字面量解析 + 构造器/静态工厂反射四级策略实现最大兼容；`Converters` 提供 12 个 parse* 轻量级门面（异常安全、null 安全）；`tree.*` 子包（`TreeConvertor` + 3 接口）提供列表⇄树双向转换（接口/函数式/反射字段名/完整路径四种策略）。约 25 个内部/扩展模块真实消费（`i2f-comparator`、`i2f-ai-std`、`i2f-database-dialect`、`i2f-dict`、`i2f-extension-antlr4`、`i2f-extension-jackson` 等）。lombok 声明未用。**瑕疵**：`tryConvertAsType` 浮点精度不可控、日期格式轮询 40+ 不缓存失败模式、`formatDate` 粗粒度 synchronized、`toBoolean` 空字符串误归 true 等（详见文档）。

- 详细文档：[i2f-convert](./i2f-jdk/i2f-convert/readme.md)

### i2f-crypto-std

> 加密/解密/摘要/签名**标准契约层**（`std` 契约与实现分离，10 类型：5 接口 + 5 密钥模型、真实依赖 `i2f-array` + `i2f-codec-impl`）：根接口 `IEncryptor` 以 `encrypt/decrypt` 定义加解密最小契约、`ISignatureSigner` 以 `sign/verify` 定义签名验签契约、`IMessageDigester extends ISignatureSigner` 以 `digest` 定义摘要契约；`ISymmetricEncryptor extends IEncryptor` 补充 `setKey/setKeyBytes/setKeyString` 密钥管理；`IAsymmetricEncryptor extends IEncryptor, ISignatureSigner` 补充公私钥全维度管理 + `privateEncrypt/publicDecrypt` 弥合 JDK 不对称语义；全部接口内建 Base64/Hex 默认方法。5 个 `Bytes*Key`（`BytesKey`/`BytesSecretKey`/`BytesPublicKey`/`BytesPrivateKey`）以 `algorithm+format+data` 三段式实现 JDK 密钥接口做字节适配桥梁；`AsymKeyPair`（`@Data`）以 Base64Obfuscator 混淆提供密钥对流式序列化。下游 `i2f-crypto-impl`/`i2f-sm-crypto`/`i2f-swl-std` 及各扩展模块广泛实现。lombok **真实使用**于 `AsymKeyPair`。

- 详细文档：[i2f-crypto-std](./i2f-jdk/i2f-crypto-std/readme.md)

### i2f-crypto-impl

> 加密/解密/摘要/签名**JDK 内置实现层**——落地 `i2f-crypto-std` 全部契约，以 **51 源文件**覆盖 4 大领域：`SymmetricEncryptor`（`implements ISymmetricEncryptor`，支持 AES/DES/3DES/Blowfish/RC2/RC4/ARCFOUR/PBE 共 8 算法）与 `AsymmetricEncryptor`（`implements IAsymmetricEncryptor`，支持 RSA/ElGamal 共 2 算法，均经 `RsaType`/`AesType` 等枚举控制模式/填充/向量需求）；`SignatureSigner`（`implements ISignatureSigner`，支持 DSA/ECDSA/RSA 签名共 12 变体）；3 种消息摘要器（`MessageDigester` MD/SHA 标准摘要 + `HmacMessageDigester` HMAC 带密钥摘要 + `ChecksumMessageDigester` Adler32/CRC32/Hashcode 校验和）+ `MessageDigestUtil` 静态门面（34 便捷方法一行出 Hex）；最底层 `Encryptor`（541 行 static）封装 Cipher/KeyGenerator/KeyPairGenerator/Signature/SecureRandom/KeyFactory 全部 JDK 安全 API 实例化；25 个 `supports.*` 算法常量枚举消除 JDK 算法名字面量散落。依赖 `i2f-crypto-std` + `i2f-array` + `i2f-bytes` + `i2f-codec-impl`（均真实使用）；lombok 声明未用。下游 `i2f-extension-jce-bc`（25 文件 import）重度消费，`i2f-otpauth`/`i2f-swl`/`i2f-tools-encrypt` 等 POM 依赖。

- 详细文档：[i2f-crypto-impl](./i2f-jdk/i2f-crypto-impl/readme.md)

### i2f-data-processor

> 数据读/写抽象处理器，基于 ILifeCycle 生命周期约束的逐条读写最小契约，提供 IDataReader/IDataWriter 双接口 + 2 个文本行 JDK IO 实现，被 i2f-check-filter 的大数据去重族消费。

- 详细文档：[i2f-data-processor](./i2f-jdk/i2f-data-processor/readme.md)

### i2f-datetime

> Java 日期时间一站式工具箱，零三方依赖以 Dates 静态门面 + fluent 实例 API 双模式提供格式解析、日期算术、边界计算、类型互转及时令判定；Calendars 内建中国农历生肖（12 属相）与干支纪年（60 甲子）推算；DateFormatter 以 ConcurrentHashMap 双引擎缓存覆盖 24 种格式的自动解析；被 i2f-number-idcard 消费。

- 详细文档：[i2f-datetime](./i2f-jdk/i2f-datetime/readme.md)

### i2f-design-pattern

> 设计模式教学演示模块，以 189 源文件系统化落地 5 大类 31 种设计模式（GoF 创建型 5 + 结构型 7 + 行为型 11，扩展并发型 4 + 架构型 4），每模式以「package-info 定义 + 业务场景实现 + Test 演示入口 + readme 详解」四件套呈现（地球单例/电商支付策略/餐厅厨房生产者-消费者/智能家居中介者等生活化场景），配 589 行总纲 design-pattern.md 梳理定义/适用场景/JDK·Spring·SpringBoot 典型案例与 SOLID 原则；仅真实依赖 lombok（104 处，POJO 示例类），仅被 i2f-jdk-all 聚合引入。瑕疵：26 个 Test 演示类位于 src/main/java 随 jar 发布且无 JUnit 自动化、architectural 4 包与 readWriteLock/threadPool 仅 package-info 无实现、7 包缺 readme、md 文档混杂源码目录等。

- 详细文档：[i2f-design-pattern](./i2f-jdk/i2f-design-pattern/readme.md)

### i2f-detegate

> **通用委托执行骨架三件套**（3 类零状态静态门面、约 320 行、真实依赖 `i2f-functional` 的可抛异常函数式接口 `IExFunction1/2`·`IExConsumer2/3`，POM 未声明 lombok；artifactId 拼写为 `i2f-detegate`——delegate 误拼而包名 `i2f.delegate` 正确）：`BatchDelegator.batch` 把「供应器反复拉页（返回 null 终止）→ 跨页攒满 batchCount → batchConsumer 批量消费 → 尾批补刷」骨架化；`CacheDelegator.cache` 以 cacheSupplier/supplier/cacheSaver/cacheConfirmer/cacheRefresher 五回调在任意 cacheHolder 上实现读穿缓存（命中确认→续期刷新→回源→回写）；`FallbackDelegator.fallback` 提供「重试（retries）+ 几何退避（sleepTs×multiplier）+ 异常三路由（thrower 直抛/breaker 断路降级/其余退避重试）+ 降级回退（fallbacker(arg,ex)）+ 异常收集」完整容错骨架。**瑕疵**：Cache 缺 confirmer 时 null 未命中被当命中致 supplier 永不调用且不回写（读穿失效）、缓存读取异常不降级；Fallback confirmer 失败重试热自旋、末次失败空等一次退避、InterruptedException 被吞、fallbacker 空时静默 null；Batch batchCount≤0 无校验退化为单巨批、空页非 null 将死循环等。全仓无源码级消费者（仅 i2f-jdk-all 聚合与 assembly fat-jar 分发）。

- 详细文档：[i2f-detegate](./i2f-jdk/i2f-detegate/readme.md)

### i2f-dict

> **注解驱动的字典码值双向转换器**（13 源文件约 440 行：5 注解 + 1 数据模型 + 3 提供者 + 1 解析器 + 3 演示类）：以 `@DictDecode`（标在展示字段、`value()` 指向码值来源字段）与 `@DictEncode`（标在码值字段、`value()` 指向文本来源字段）声明跨字段或**就地**双向映射，`@Dict(code/text/desc)` 可重复标注（`@Repeatable(Dicts.class)`）内联字典项、null 值按空串匹配空 code 项实现"未知"兜底；`DictResolver.decode/encode` 静态门面沿 `ReflectResolver.getFields`（子类→父类、过滤 transient/static-final）遍历字段，经 `IDictProvider` 提供者链（首个非空胜出，默认仅 `DictsAnnotationDictProvider` 注解内联字典）取字典项后线性匹配，命中值经 `ObjectConvertor.tryConvertAsType` 转换后写回目标字段；`AbsDictMapAnnotationDictProvider` + `@DictMap(group/type)` 预留外部字典源（数据库/Redis）扩展骨架。依赖 `lombok`/`i2f-text`/`i2f-reflect` 均**真实使用**，`i2f-convert` 为**隐式传递依赖**（POM 未声明而直接使用 `ObjectConvertor`）；全仓**无源码级消费者**（仅 `i2f-jdk-all` 聚合与根 POM 依赖托管）。**瑕疵**：encode/decode 同名多级字段去重策略不一致（子类 vs 父类优先）、转换异常空 catch 静默、`findDictList` 返回 null 致下游 NPE、`@DictMap` 扩展骨架全仓无实现、空值语义三处靠约定无文档等（详见文档）。

- 详细文档：[i2f-dict](./i2f-jdk/i2f-dict/readme.md)

### i2f-enums

> **字典枚举契约 `IDict` 与两个开箱即用的三值基础枚举**（3 源文件约 120 行，零依赖）：`IDict` 以 `int code()` / `String text()` / `default String key()` / `default String remark()` 四方法定义字典条目最小公共协议；`Bool`（`UNSET(-1)`/`TRUE(1)`/`FALSE(0)`）与 `YesNo`（`UNSET(-1)`/`YES(1)`/`NO(0)`）为 boolean 语义提供标准化三值枚举（未定义/真-是/假-否），code/text 硬编码中文字符串。全模块零 i2f 内部依赖、零三方运行期依赖、无 lombok。外部消费者 `i2f-annotations-db.OrderMode`、`i2f-annotations-ext.PaddingMode`、`i2f-verifycode.VerifyCodeType` 均直接 `implements IDict`，被其注解元数据解析器反射消费。**瑕疵**：`key()`/`remark()` 默认 null 语义模糊；`Bool` 与 `YesNo` code 值重叠（TRUE=YES=1、FALSE=NO=0）致混用时无法区分；无 `getByCode`/`fromName` 反向查找、无 `Serializable` 继承、无国际化回退、无 `Map` 缓存（消费方需线性遍历 `values()` 匹配 code）；`UNSET(-1)` 语义边界靠约定无校验；`key()` 命名与 `@Dict.key` 注解属性名重叠易混淆。

- 详细文档：[i2f-enums](./i2f-jdk/i2f-enums/readme.md)

### i2f-environment-std

> **环境配置标准契约层**（2 接口约 102 行，零运行期依赖）：`IEnvironment` 以 `getProperty(name)`/`getAllProperties()` 两抽象 + 4 组类型安全 default getter（`getInteger`/`getLong`/`getBoolean`/`getDouble`，均含带默认值重载）定义只读环境契约，parse 异常空 catch 静默吞噬；`IWritableEnvironment extends IEnvironment` 以 `setProperty(name,value)` 抽象 + 4 个类型安全 default setter（`setInteger`/`setLong`/`setBoolean`/`setDouble`，null 值传字符串 `"null"`）补齐写入能力。pom 声明的 lombok 实际未使用。11 个源码级消费者跨 5 层级：`i2f-environment-impl`（`SystemAdditionalEnvironment`/`ListableDelegateEnvironment` 实现）、`i2f-http-proxy`（`RestClientProvider` 字段类型）、`i2f-jdbc-procedure`（执行器构造参数）、`i2f-extension-xproc4j`（3 文件字段/参数）、`i2f-spring-core`（`SpringEnvironment` 适配 Spring `Environment`）、`i2f-springboot-xproc4j-starter`（Bean 装配）、`i2f-tools-idea-plugin`（代码生成文本引用）。**瑕疵**：异常静默吞噬致调用者无法区分"属性不存在"与"格式错误"；`getBoolean` 仅认 `"true"`（忽略大小写）为真、`"1"/"yes"/"on"` 等误归 false；`getDouble` 无区域感知（欧洲 `,` 分隔符必失败）；`getAllProperties` 未约定不可变性与一致性；`setProperty(null,value)` 未约定行为；lombok 冗余依赖等。

- 详细文档：[i2f-environment-std](./i2f-jdk/i2f-environment-std/readme.md)

### i2f-event

> **轻量级异步事件发布/订阅调度框架**（4 源文件约 292 行，真实依赖 `lombok` + `i2f-clock-impl`）：`IEventPublisher`/`IEventSubscriber` 双接口定义发布-订阅契约，`EventDispatcher` 以**单守护线程 + 无界 `LinkedBlockingQueue` + 工作窃取线程池**实现异步批处理分发——`publish(event)` 包装 `SimpleEntry(event, SystemClock 缓存毫秒时间戳)` 入队，CAS 确保仅一个调度线程 `doDispatchLoop()` `while(true)` 永续轮询：内层批量 `poll()` 最多攒 64 条、经 `subscriber.test()` 过滤后 `pool.submit(EventRunnable)` 异步执行 `subscriber.handle(event)`；`threadIdleMillSeconds`（默认 300ms）控制空闲睡眠、`waitSubscriber` 使首事件前阻塞等待首个订阅者注册、`dropOverMillSeconds` 按入队时间戳丢弃超期事件、`dispatcherThreadConsumer` 自定义线程属性（如设非守护、优先级）。全仓无外部源码级消费者。**瑕疵**：`EventRunnable.run()` L198 `this.exception = exception` 为变量名 bug（应 `= e`）致 catch 异常恒丢失；`while(true)` 无法优雅退出且线程异常退出后 `initialized` 不重置致事件永久积压；中断信号与异常空 catch 吞噬；无界队列 OOM 风险；无 unsubscribe/shutdown；无容量控制背压机制等 11 条。

- 详细文档：[i2f-event](./i2f-jdk/i2f-event/readme.md)

### i2f-environment-impl

> **环境配置契约的默认实现层**（2 类约 163 行，真实依赖 `i2f-environment-std` + `i2f-jvm`，lombok 声明未用）：`SystemAdditionalEnvironment`（单例 `INSTANCE`，实现 `IWritableEnvironment`）静态块一次性采集 15 项 JVM 运行时/编译/OS 信息入 `unmodifiedMap` 快照（`runtime.boot.class.path`/`runtime.class.path`（**try-catch 空吞**致 JDK9+ 缺失）/`runtime.input.arguments`（`\n` 拼接）/`runtime.library.path`/`runtime.pid`（`JvmUtil.getPid()`）/`runtime.start.time`/`runtime.vm.name|vendor|version`/`compilation.total.compilation.time`（**快照冻结永不更新**）/`compilation.name`/`operating.system.arch|available.processors|name|version`），`setProperty` 双写本地 `ConcurrentHashMap` + `System.setProperty`（**全局副作用**，value==null 静默忽略），`getProperty` 三级查找 `unmodifiedMap → map → System`（快照优先级固化不可覆盖），`getAllProperties` = System 全量 → map → unmodifiedMap 覆盖合并；`ListableDelegateEnvironment`（`CopyOnWriteArrayList` 委托链默认装入 `INSTANCE`）单键正向遍历首个非空胜出、全量反向 putAll 使索引 0 最高优先级（两者语义一致），但 `list` 为 `protected` 且**无公开 add/remove 方法致委托能力外部不可用**。消费者：`i2f-jdbc-procedure.BasicJdbcProcedureExecutor` 默认装配 `environment` 字段 + idea-plugin 代码生成文本引用。**瑕疵**：`unmodifiedMap` 不可变性伪装（public static final 但底层 HashMap 可改）、MXBean 空值（CompilationMXBean）NPE 致类初始化失败、`setProperty(name,null)` 无删除语义、无 removeProperty、动态指标冻结误导、getAllProperties 无缓存全量复制开销等 11 条。

- 详细文档：[i2f-environment-impl](./i2f-jdk/i2f-environment-impl/readme.md)

### i2f-exception

> **语义化运行时异常词汇表**（16 源文件约 435 行，零依赖、零构造负担）：16 个直接继承 `RuntimeException` 的扁平异常类覆盖长度（`BadLengthException`）/报文（`BadPacketException`）/大小（`BadSizeException`）/类型（`BadTypeException`）/并发（`ConcurrentException`）/数据访问（`DataAccessException`）/断连（`DisconnectException`）/内部（`InternalException`）/缺失参数（`MissingArgumentException`）/原生（`NativeException`）/未找到（`NotFoundException`）/反射（`ReflectException`）/远程（`RemoteException`）/服务（`ServiceException`）/未处理（`UnHandledException`）/不支持（`UnSupportException`）共 16 类场景；其中 15 个统一镜像 JDK `RuntimeException` 五构造器模板（无参/message/message+cause/cause/全参 enableSuppression+writableStackTrace），仅 `UnHandledException` 特殊——持 `reason` 字段 + `getReason()`（与 `getCause()` 恒等冗余）且仅 3 构造器；pom 无任何依赖但声明 maven-assembly-plugin（fat-jar 对零依赖库无意义）。**全仓零源码级消费者**（`import i2f.exception.*` 0 处），仅 i2f-jdk-all 聚合打包 + 根 pom 版本托管，处于「备而未用」状态。**瑕疵**：`RemoteException` 与 `java.rmi.RemoteException` 重名且受检性相反（checked vs unchecked）、`UnSupportException` 拼写不规范（应为 Unsupported）、16 类全缺 `serialVersionUID`、无公共基类/错误码/上下文载体、length/size/packet 三异常语义边界模糊、全部 unchecked 无 forced-handle 变体等 12 条。

- 详细文档：[i2f-exception](./i2f-jdk/i2f-exception/readme.md)

### i2f-features

> **能力标记接口集**（11 个空标记接口约 110 行，零依赖、零实现、零消费者）：四个子包 `cluster`（`IDistributed` 分布式的 / `IStandalone` 单机的）、`concurrent`（`IConcurrent` 并发的 / `IParallel` 并行的 / `ISequence` 串行的）、`store`（`IDisk` 磁盘的 / `IMemory` 内存的 / `INetwork` 网络的 / `IPersist` 持久化的）、`sync`（`IAsync` 异步的 / `ISync` 同步的）共 11 个逐字节同构的空标记接口（marker interface，格式统一为 `@author/@date/@desc` 注释 + 空接口体），以 `@desc` 中文注释标注语义，设计意图为供实现类 `implements` 打能力标签 + 上层 `instanceof` 嗅探（类 `java.io.Serializable`/`RandomAccess`）；三重 grep 验证全仓零 `import`、零 `implements`、零外部引用（全文 `i2f.features` 仅 11 处自身 package 声明），纯「备而未用」占位状态（2024/6/27 创建后未见推进）；注册于 i2f-jdk modules L74、i2f-jdk-all L245 聚合、根 pom L406 版本托管。**瑕疵**：标记接口无元数据携带能力（不如标记注解 `@Distributed(cluster=...)` 可参数化）、`implements` 零编译期约束（同步实现可误标 `IAsync` 无从拦截）、与 i2f-cache-std 的 `IDistributedCache`/`IPersistCache` 命名高度近似易混淆、store 包内存储位置（Disk/Memory/Network）与存储特性（Persist）维度混放、`IConcurrent`/`IParallel`/`ISequence` 语义非严格互斥、形容词式命名偏离 Java 惯例（应为 -able 后缀或能力名词）、无 package-info 说明设计意图、assembly 插件冗余等 10 条。

- 详细文档：[i2f-features](./i2f-jdk/i2f-features/readme.md)

### i2f-firewall

> **注入攻击防护防火墙**（18 源文件约 2380 行）：以 `IFirewallAsserter<T>.doAssert(errorMsg, value)`（泛型）+ `IStringFirewallAsserter`（String 特化）双接口定义断言式契约（失败抛异常、通过静默），为 CRLF 头注入（`CrlfFirewallAsserter`：`\r`/`\n`/`\0`）、主机头（`HostFirewallAsserter`：27 坏字符 + `//`/`\\`）、路径穿越（`PathFirewallAsserter`：坏字符 + `../`/`~/` + 60+ 后缀黑名单 + 50+ 文件名黑名单 + `STRICT` 单例）、反序列化类名（`SerializeFirewallAsserter`：全类名正则 + `*executor` 等 8 后缀词 + JDK 前缀白名单）、SQL 注入（`SqlFirewallAsserter`：100+ 正则覆盖 MySQL/Oracle/PostgreSQL/MSSQL/DB2 等十余方言 + `strict` 二级规则）、XSS（`XssFirewallAsserter`：40+ 危险串 + 40+ 混淆正则）、XXE（`XxeFirewallAsserter`：`<!(doctype|entity)` 正则）共 7 类各配检测器与专属异常（`FirewallException extends IllegalArgumentException` 的 7 子类），检测引擎 `FirewallAsserterUtils` 以 `merge` 规则四元合并（replace>basic→+include→−exclude）+ `getAllCombinations` DFS 幂集 + `combinationsWrappers` 生成 **10 种编码变体（原文/URL×2 双重编码/0x%02x/%%02x/\x%02x/\u%04x/HTML/UCode/XCode）的 1023 组合** 与 Decode 路线（6 变体 63 组合）实现嵌套编码地毯式匹配。**依赖异常**：POM 声明 4 依赖中 lombok、`i2f-reflect`、`i2f-text` 三个**未使用**，仅 `i2f-codec-impl`（Url/Html/UCode/XCode 4 codec）真实使用；`i2f-match`（`RegexUtil`）为**隐式传递依赖**（经 codec-impl）。**消费者**：仅 `i2f-jdk-ext-web` 8 文件 import `FirewallException`（`FirewallFilter` 捕获转 400 + 5 个自有子异常继承），**7 个检测器零外部消费者**（web 层 `FirewallUtils` 为独立重实现）。**瑕疵**：【严重】`PathFirewallAsserter.STRICT` 静态初始化因 `Arrays.asList(null)` NPE 致**整类不可用**（ExceptionInInitializerError）；`Rules` 字段 null 即 NPE 的隐性契约；`disableDomXxeConfig()` 空操作；`assertClassname` 恒真死代码 + 非 JDK 前缀直接放行；Sql/Xss 无 Decode 路线存在单字符混编绕过；组合爆炸性能风险（45+ 测试词 × 1023 wrapper 无缓存）；4 类残留调试 `main`；Xss 类注释误抄 Sql；误报率设计性偏高（"function"/"count " 等宽泛词）等 15 条。

- 详细文档：[i2f-firewall](./i2f-jdk/i2f-firewall/readme.md)

### i2f-form

> **Swing 模态对话框组件库 + 统一预览系统**（42 源文件约 3450 行）：以 `DialogBoxes` 静态门面提供消息/确认（`ConfirmDialog`）、输入（`InputDialog`）、单选（`RadioDialog`，含 UP/DOWN/Home/End 键盘导航与自定义项）、多选（`CheckboxDialog`，含全选/反选）、倒计时（`CountDownDialog`，无边框半透明置顶 + 鼠标移入即随机移位的"逃避"窗口）共 6 类模态窗口，统一采用「`CountDownLatch` 阻塞调用线程 + `SwingUtilities.invokeLater` 在 EDT 构建 UI」实现同步模态（EDT 内调用直接抛 IllegalStateException 防死锁）；`ModernUi`（418 行）以纯 JDK 程序化绘制现代扁平皮肤（主题色/圆角输入框/扁平按钮/自绘单选复选图标/动态应用图标）；预览子系统 `IPreviewDialog` 契约 + 3 个 std 子接口（IFile/Uri/Url + default 转换方法）+ 15 个实现类（7 图片 + 4 媒体 + 3 文本 + 1 Web）覆盖图片/GIF/媒体/文本/网页，媒体与网页经 JavaFX `JFXPanel` 桥接。**依赖**：4 声明全部真实使用（lombok 3 结果类、i2f-jvm `JvmUtil.isDebug()`、i2f-io-stream `StreamUtil`、`jdk:javafx` system scope 硬编码 jar 路径）。**消费者**：唯一外部消费者 `i2f-jdbc-procedure`（`JdbcProcedureExecutor.evalScriptUiInput` 用 DialogBoxes.input 且未判取消）。**瑕疵**：【严重】`PreviewDialogs.preview()` 走 `ServiceLoader` 但模块无 `META-INF/services` 注册文件、`DEFAULTS`（15 个预置）成死代码——双重失效致统一入口恒 fallback 字符串预览，图片/媒体/网页预览不可达；javafx system scope 不可移植且不传递下游；File 预览不校验存在性致 NPE；RadioDialog 确认未选择返回 cancel 语义；InputResult 数值转换 null NPE；窗口强制置顶无开关；文本后缀 `htm` 缺前导点永不命中；MediaDialogs 优先级错误/跨线程操作 Swing；CountDownDialog 无法手动关闭；4 对话框约 60% 复制粘贴模板、无真单元测试等 15 条。

- 详细文档：[i2f-form](./i2f-jdk/i2f-form/readme.md)

### i2f-form-url-encoded

> **form-urlencoded 编解码器 + URI 结构化解析器**（5 源文件约 750 行，主类 2 个）：`FormUrlEncodedEncoder`（185 行）以 `i2f-reflect` 的 `ObjectRouteResolver` 点号路径扁平化协议（`user.roles[0].name=admin`）实现「任意对象/嵌套 Map/集合 ↔ form 串」双向转换（`toForm` 值类型分类处理 Date→`yyyy-MM-dd HH:mm:ss SSS`/Charset/Class；反序列化 `toMap→toFlatMap→ofMapTree→RichConverter.convert` 四连直达 Bean/泛型/Type，支持 keyMapper）；`UriMeta`（447 行）9 字段模型 + 前缀路由解析 8 类 URI 方言（通用 http/jdbc 类/file/jar:file/scp 风格 git@/Oracle SID/SQLServer/H2/SQLite）+ `hashBefore` 开关切换 `?query#hash` 与 `#hash?query`（SPA 风格）。**依赖**：3 声明全部真实使用（lombok、i2f-reflect ObjectRouteResolver/RichConverter、i2f-text StringUtils），i2f-convert/i2f-typeof 为隐式传递（经 reflect）。**消费者**：6 模块 9 文件真实使用——SWL 体系核心（SwlWebFilter/SwlGatewayFilter 用 toForm/ofFormBean 序列化加密头 SwlHeader + toMap 解析解密参数）、HttpUtil/OkHttpFormRequestBodyHandler/SpringWebRestClient 拼 query 与表单体、database-metadata-impl 3 文件解析 JDBC URL；i2f-springboot-swl-starter 与 test-secure 声明未用。**瑕疵**：【严重】`UriMeta.parse` 对 Oracle ServiceName（`@//host:port/service`）与 Sid2（`@host:port/sid`）形式误路由至 parseJdbcOracleBySid → `substring(0,-1)` 抛 StringIndexOutOfBoundsException 崩溃，正确实现 parseJdbcOracleBySid2/parseJdbcOracleByServiceName 不可达死代码；SQLServer URL 无 `;` 参数崩溃；IPv6 无端口 NumberFormatException；空串/尾 `&` 产生空 key 条目；全链路 TreeMap 致字段顺序丢失；空集合↔null 语义丢失；null 与空串同形 `key=`；单/多值路径协议歧义；Date 固定格式无时区；URLEncoder 空格→`+` 与 RFC3986 互操作；7 处静默 catch；@Data 可构造非法状态；parse(null) NPE；测试为 main 手工类且混入主 jar 等 17 条。

- 详细文档：[i2f-form-url-encoded](./i2f-jdk/i2f-form-url-encoded/readme.md)

### i2f-geo

> **地理坐标转换与米度概算工具**（3 源文件约 433 行，零依赖、全仓零消费者）：`CoordinateConvertor`（297 行）覆盖五大坐标系互转——WGS84（国际 GPS）↔ GCJ-02（火星/高德/腾讯，加偏多项式 transLat/transLng + 单步近似反解）↔ BD-09LL（百度经纬度，z·θ 旋转 ±0.0065/0.006）并链式派生 BD09↔WGS84，WGS84 ↔ WebMercator（球面公式），GCJ-02 ↔ BD-09MC（百度墨卡托，mc2ll/ll2mc 分段多项式 + convert 通用求值）及 BDMC↔WGS84/BD09 链式，共 13 个专用转换方法（6 对互转 + 1 个单向）；`GeoUtil` 提供 38°N 基准米度概算（9 常量 + 6 方法）；`GeoPoint` 极简 lng/lat 承载。**注册**：i2f-jdk modules L80、i2f-jdk-all 聚合、根 pom 版本托管；**全仓零 import 消费者**（wiki 仅清单级提及）。**瑕疵**：【严重】`GCJ02ToBDMC` 南半球必抛异常（回退选带被 `if (f.length > 0)` 拦截，应为 == 0）；`GeoUtil.COS_38` 误存 38° 弧度 0.6632 而非余弦 0.7880，米度换算偏小约 15.8%；【中】`BDMCToGCJ02` 入口 abs 丢符号、共享静态异常单例栈帧冻结、`GCJ02ToWGS84` 单步反解残差 1~5 米、米度换算对非互逆；【低】convert 公有契约仅校验空数组、`isInChina` 矩形粗判误伤境外区域、BD-09 无境内外判断、生产类残留 main、无单元测试等 16 条。

- 详细文档：[i2f-geo](./i2f-jdk/i2f-geo/readme.md)

### i2f-graphics-2d

> **二维图形学基础库**（42 源文件约 2622 行，全部在 main、无测试目录）：纯 JDK + AWT，零图形引擎依赖。三层结构——原语层 `Point/Size/Line/Flat/Scope/Vector` + `ILenght`（拼写错误已传染 3D 的 D3Line/D3Vector）+ shape 4 形状（Circle/Ellipse/Polygon/Rectangle）；运算层 `D2Calc`（方向移动/旋转/反射角）、`LocationUtil`（叉积定向+绕数，Y 向下版）、`Bezier`（Bernstein 采样，自适应密度）、`D2VaryUtil`（3×3 齐次「行向量右乘」约定，平移在第三行）；工具层 polygon 5 件套（鞋带面积/顺逆时针凸凹/时钟序重排/双坐标系内外判定/凸多边形外扩内缩）、`IProjection` 投影 4 实现（屏幕恒等/数学中心/数学左下/自定义偏移）、`ITransform` 变换 11 实现（`AbstractMatrixTransform` 矩阵/标量双路径 + 相对点/相对线 `addTransform` 链式组合）、`GraphicsUtil`（箭头/逐字符随机艺术字/AffineTransform 显式回滚）、`FunctionPainter`（380 行，CROSS/CENTER/ARGUMENTS 三模式函数绘图 + 网格坐标轴）；可视化 `D2Canvas`/`D2Frame`/`CherryTree`（12 层递归分形树）。**依赖**：4 声明全部真实使用（lombok / i2f-math MathUtil / i2f-color Rgba 仅 CherryTree / i2f-tuple-impl 仅 normalize 返回双值）。**消费者**：6 模块 41 文件——i2f-graphics-3d 19（`D3Painter.d2proj` 屏幕映射底座 + `SpinBezierCube` 复用 Bezier + D3Line/D3Vector 复用 ILenght）、i2f-verifycode 10（GraphicsUtil 绘制艺术字/点阵/极坐标验证码）、i2f-algo 5（PolygonLocationTool 边界判定）、i2f-native-windows 4 + easyx 1（窗口坐标 Point/Size/Rectangle）、i2f-image-impl 2（Point 四点插值/洪水填充）；聚合壳 i2f-graphics 声明 2d+3d 依赖。**瑕疵**：【中】`sortClock` 的 `yAxisUp` 双分支代码完全相同参数失效（Y 向下输出方向恰相反）；`PolygonOffsetTool.offset` sina=0/零长边除零 Infinity/NaN；`FunctionPainter` accX=0 死循环；`isLeftOnUpAxisY(target,end,begin)` 参数序颠倒与 Down 版不一致极易误用；【低】ILenght 拼写错误传染、Bezier 采样不含终点 t=1、normalize 自赋值死代码、geoDistance 无意义缩放、共线 cp==0 计入方向统计、D2VaryUtil 4 元素数组仅用 3、CherryTree 12 层 2~3 分支递归爆炸、Pair 重复造轮子、4 类残留 main、adaptSize 截断、@Data+public 双访问、无单元测试等 16 条。

- 详细文档：[i2f-graphics-2d](./i2f-jdk/i2f-graphics-2d/readme.md)

### i2f-graphics-3d

> **三维图形学基础库**（74 源文件约 4798 行，全部在 main、无测试目录）：纯 JDK + AWT/Swing，零图形引擎依赖，复用 2D 模块（Point/Line/Flat/ILenght/Bezier/IProjection）。九包——原语层 `D3Point/D3Size/D3Scope/D3Line/D3Flat/D3Vector/D3SphericalPoint`（a 极角/b 方位角）+ `D3Calc`/`D3VaryUtil`（4×4 齐次「行向量右乘」，平移在第四行，同 2D 约定族）；投影层 `ID3Projection` 10 实现（三视图 Main/Side/Top + 正交/斜投影 + 一/二/三点透视 + 任意视角 WorldOrgToScreenOrg，`AbstractMatrixProjection` 矩阵/标量双路径 + swapXZ 钩子）；变换层 `ID3Transform` 23 实现（点变换 Move/Scale/Spin+XYZ/Miscut+XYZ/ReflectAxis+XYZ/ReflectFlat+XoY·YoZ·XoZ/相对点/相对线 + org 坐标系变换 5 个）；光照层 D3Light（9 预置灯）/Material（29 预置材质）/LightAlgorithm（Phong 单灯+多灯）；背面剔除 `BlankingAlgorithm`；模型层 `D3Model`（点云+三角面索引）/`TmFileUtil`（TM 格式）；形状 13 个（参数网格球/锥/柱/环、正多面体 5、旋转体 SpinCube/SpinBezierCube、分形树 D3TreeLine）；三角化 `ShortestDistanceTrianglize`（296 行，最短距离+分层+双向+角度过滤）；可视化 D3Canvas/D3Frame（Alt/Ctrl/Shift+X/Y/Z+滚轮交互）。**依赖**：4 声明全部真实使用（lombok / i2f-color Rgba / i2f-math MathUtil / i2f-graphics-2d 7 类）。**消费者**：**全仓零 Java 消费者**（纯叶子模块）——仅聚合壳 i2f-graphics（POM 声明）与 i2f-jdk-all 聚合；注册 i2f-jdk modules L83、根 pom 托管 L451。**瑕疵**：【中】SpinX/Y/Z 标量路径变量覆盖致旋转出错（默认路径，90° 可把 (0,1,0) 旋到原点；org 子包为正确写法对照）；SideView/TopView 双路径投影不一致（标量 vs 矩阵结果不同）；ShortestDistanceTrianglize 原始面重复添加；SpinBezierCube 的 SpinY 误调 SpinX；Cuboid int 步长<1 死循环；D3Painter 颜色默认 null NPE；【低】point2spherical 用 atan 非 atan2、D3TreeLine alpha 误用 r 通道、单灯版不查 enable、颜色归一失真、D3VaryUtil 漏 static、D3Vector 继承 D3Point、锥/柱中心重复点、无单元测试等 16 条。

- 详细文档：[i2f-graphics-3d](./i2f-jdk/i2f-graphics-3d/readme.md)

### i2f-graphics

> 二维/三维图形学能力**聚合门面模块** —— 零源码纯聚合，通过 `maven-assembly-plugin`（`jar-with-dependencies`）将 `i2f-graphics-2d`（42 源文件约 2622 行）与 `i2f-graphics-3d`（74 源文件约 4798 行）打包为单一 fat-jar，被 `i2f-jdk-all` 全仓聚合引入。

- 详细文档：[i2f-graphics](./i2f-jdk/i2f-graphics/readme.md)

### i2f-hash

> **非加密哈希算法工具箱**（15 源文件约 402 行）：泛型 `IHashProvider<T>` 接口 + `ObjectHashcodeHashProvider`（委托 `obj.hashCode()`）+ `IByteArrayHashProvider` 抽象基类（通过 `IBytesObjectSerializer` 序列化桥接）+ 12 种经典非加密哈希算法（AP/BKDR/Boost/BP/DEK/DJB/ELF/FNV/JS/PJW/RS/SDBM）。被 `i2f-check-filter` 的 BloomFilter 与 HashGroupRepeatFilter 消费。**瑕疵**：FNV 变量名与算法标准不一致（offset_basis 代 prime）、DEK/PJW 无 32 位掩码致 long 位宽偏差、lombok 声明未用等。

- 详细文档：[i2f-hash](./i2f-jdk/i2f-hash/readme.md)

### i2f-http-proxy

> **声明式 REST 客户端框架**（15 源文件约 717 行）：通过 `@RestClient` 接口 + JDK 动态代理 + 11 种自研注解（5 种方法级 Mapping + 4 种参数级注解）构建声明式 HTTP 客户端，内置环境变量替换 `${env}`、可插拔 `IHttpProcessor`/`IStringObjectSerializer`/`IHttpRequestCustomizer`/`IHttpResponseExtractor`，支持 MultipartFile 文件上传与多模式请求头。被 `i2f-jdk-all` 全仓聚合引入，目前全仓零代码级消费者。**缺陷**：lombok 声明未用、@RestHeader.name 重复读取、无反序列化降级保护等（详见文档）。

- 详细文档：[i2f-http-proxy](./i2f-jdk/i2f-http-proxy/readme.md)

### i2f-i18n

> **国际化消息工具集**（10 源文件约 935 行）：`I18n` 静态门面 + SPI 三优先级初始化 + `InheritableThreadLocal` 线程语言上下文 + 自动文件扫描（48 条路径，properties/XML 双格式）+ `I18nProvider` 接口（含 6 种基础类型转换）。XML 格式支持 `ref` 外部文件引用与 `keep`/`only` 格式控制。被 `i2f-jdk-all` 全仓聚合引入，目前全仓零代码级消费者。**瑕疵**：多处空 catch 块吞异常、Properties 构造器用平台默认编码、Test 在 main 源码集等（详见文档）。

- 详细文档：[i2f-i18n](./i2f-jdk/i2f-i18n/readme.md)

### i2f-image-impl

> **图像滤镜与处理实现层**（56 源文件约 1893 行）：`ImageCompressor` 智能压缩（等比例缩放+去 Alpha+二分法寻质量）+ `HideData2Image` LSB 隐写（bit3 RGB 三通道冗余）+ 28 种图像级滤镜（直接实现 IImageFilter 16 类 + 桥接子类 17 类）+ 20 种像素级 RGBA 滤镜（RgbaFilter）。被 `i2f-springboot-ops-starter` 的 OpenAiOpsController 消费。**瑕疵**：ScaleImageFilter 宽高比混淆复制粘贴错误、EnhanceHueRgbaFilter rate=0 归零等（详见文档）。

- 详细文档：[i2f-image-impl](./i2f-jdk/i2f-image-impl/readme.md)

### i2f-image-std

> **图像处理标准接口与工具集**（11 源文件约 424 行）：`ImageUtil` 图片 I/O + `FontUtil` 字体加载注册 + 三层过滤器接口体系（`IImageFilter`/`PixelFilter`/`RgbaFilter`）及 6 适配器实现（双向桥接矩阵）。被 `i2f-image-impl`（140+ 源文件）消费。**瑕疵**：lombok 声明未用、FontUtil 空 catch 块、sun.font 反射 API 等（详见文档）。

- 详细文档：[i2f-image-std](./i2f-jdk/i2f-image-std/readme.md)

### i2f-invokable

> **JDK 反射调用抽象层**（10 源文件约 381 行）：`IInvokable` 最小调用契约 + `IMethod` 元数据扩展（名称/声明类/修饰符/返回类型/参数）+ 4 种 JDK 反射包装（`JdkMethod`/`JdkConstructor`/`JdkExecutable`/`JdkInstanceStaticMethod`）+ `MethodWrapper` 装饰器 + `DecorateNameMethod` 名称变换 + `Invocation` 调用快照数据类。被 `i2f-extension-antlr4`（Funic 脚本引擎）和 `i2f-extension-aspectj` 消费。**瑕疵**：JdkExecutable.getReturnType() 对 Method 返回声明类而非实际返回类型、getName() 对 Constructor 返回类名而非 `<init>` 等（详见文档）。

- 详细文档：[i2f-invokable](./i2f-jdk/i2f-invokable/readme.md)

### i2f-io-stream

> **Java 字节流操作工具集**（13 源文件约 727 行）：`StreamUtil` 全能静态工具（流拷贝/广播/范围拷贝/本地化/读写）+ 校验和体系（`BoostChecksum`/`CheckedStreamUtil`）+ XOR 加密流体系（`IEncryptor`/`XorEncryptor`/`EncryptInputStream`/`EncryptOutputStream`）+ 4 种特殊流（`BlackHoleOutputStream`/`WhiteHoleInputStream`/`LazyInputStream`/`LazyOutputStream`/`TempFileInputStream`）。纯 JDK 零外部依赖，被全仓 25+ 模块广泛消费。**瑕疵**：`CheckedStreamUtil.streamCopyChecksum` 校验和从未更新（拷贝未经过 CheckedOutputStream）、`XorEncryptor` 字节值 0xFF 与流结束返回 -1 冲突、`localStream` 上限截断等（详见文档）。

- 详细文档：[i2f-io-stream](./i2f-jdk/i2f-io-stream/readme.md)

### i2f-io-file

> **全能文件操作工具集**（6 源文件约 1444 行）：`FileUtil` 全能静态工具（文件读写/拷贝/移动/删除/合并/分割/路径规约/树遍历/CSV 解析）+ `FileType` 魔数判定枚举（76 种）+ `FileTypeUtil` 类型匹配 + `FileMime` MIME 映射（~420 条）+ `FileSpecies` 文件种类分类器（8 大类）+ `FileTrash` 应用级回收站。被全仓 22+ 模块广泛消费。**瑕疵**：`splitMeta` ObjectInputStream 反复构造致多文件还原失败、`merge` 使用 Java 序列化专有格式无互操作性等（详见文档）。

- 详细文档：[i2f-io-file](./i2f-jdk/i2f-io-file/readme.md)

### i2f-io-filesystem

> **统一文件系统抽象层**（7 源文件约 795 行）：`IFile` 对象语义契约（~46 方法）+ `IFileSystem` 路径直操作契约（~27 方法）+ `AbsFile`/`AbsFileSystem` 抽象基类（组合能力模板，实现方仅需约 10 个原语）+ `FileSystemUtil` 路径工具（`%00` 截断/`../` 规约/`getStrictFile` 防穿越）+ `JdkFile`/`JdkFileSystem` JDK 本地实现。被 6 个 `i2f-extension-filesystem-*` 模块（FTP/HDFS/MinIO/阿里云OSS/AWS S3/SFTP，14 类继承基类）消费。**瑕疵**：`AbsFile.getExtension()` 语义反转（返回主名而非扩展名）、`JdkFile.moveTo` 忽略 `renameTo` 返回值静默失败、`i2f-text` 依赖声明未用等（详见文档）。

- 详细文档：[i2f-io-filesystem](./i2f-jdk/i2f-io-filesystem/readme.md)

### i2f-iterator

> **迭代器三向适配与增强工具集**（29 源文件约 1362 行）：`Iterators`（38 工厂重载）/`Iterables`/`Enumerations` 三门面实现 Iterator ↔ Iterable ↔ Enumeration 互转（覆盖 Stream/8 种原生数组/任意 Object 数组/Reader 行流）+ 5 装饰器（map/filter/peek/透传/懒加载）+ `ResourceIterator` 资源生命周期模板（函数式三钩子 + Reference 三态协议）+ 17 个数组迭代器（含多维展开 + 下标轨迹）。被 `i2f-text`/`i2f-match`/`i2f-extension-antlr4`（传递）消费。**高危瑕疵**：`ResourceIterator.hasNext()` 的 finally 无条件释放致行迭代器只能读第一行、`PredicateIterator` 循环缺 break 致过滤失效等（详见文档）。

- 详细文档：[i2f-iterator](./i2f-jdk/i2f-iterator/readme.md)

### i2f-javacode-graph

> **Java 代码结构图生成模块**（14 源文件约 1043 行）：三步管线「`JavaCodeNodeResolver`（560 行，反射解析 Class/字段/方法/构造器/注解 + 泛型经 TypeNode 建模 + nodeMap 签名去重 + 六级过滤器）→ `JavaCodeRelationGraphConverter`（节点树按 11 槽位拍平为节点表 + 关系边，签名防重入支持环路）→ `JavaCodeRelationEchartsGraphConverter`（索引化输出 categories/nodes/links）」产出 ECharts graph 数据，可用 `i2f-turbo-web/tools/echarts/echarts-graph.html` 预览；lombok/i2f-reflect/i2f-serialize-impl 真实使用、`i2f-typeof` 隐式传递依赖未声明；目前仅被 `i2f-jdk-all` 聚合引入，全仓零代码级消费者。**高危瑕疵**：方法/构造器异常类型错加至 `parameters` 列表致 EXCEPTION 关系永不产生、注解递归传参错误致节点自引用等（详见文档）。

- 详细文档：[i2f-javacode-graph](./i2f-jdk/i2f-javacode-graph/readme.md)

### i2f-jdbc-data

> **JDBC 生态的数据契约地基**（6 源文件约 290 行、2 包、纯数据载体零执行逻辑）：四组共享模型「`JdbcMeta` 连接元信息 + `QueryResult`/`QueryColumn` 查询结果模型（列 22 字段快照 + 行 `Map<列名,值>`）+ `TypedArgument`/`ArgumentTypeHandler` 类型化参数协议（handler → javaType → jdbcType 三级绑定，落地于 `i2f-jdbc-impl/JdbcResolver.setStatementObject`）+ `NamingOutputParameter` 存储过程命名输出参数（`namingCallableStatement` 注册 + 按名回读）」；被 11 个代码级模块消费（`i2f-jdbc-impl` 核心消费点、`i2f-database-metadata-std/impl`、`i2f-jdbc-proxy`/`proxy-xml`/`bql`/`procedure`、`ai-rag-sqlite`、`xproc4j`、`springboot-ops-starter` 等），`i2f-jdbc-std` 显式声明作传递通道（自身源码零消费 data 包）；lombok 真实使用、**零高危缺陷**。**瑕疵**：`NamingOutputParameter.input` 仅三参构造器置 true（setter 补 value 被静默丢弃）、`QueryResult` @Data toString 全量输出行数据、越界/null 无防御等（详见文档）。

- 详细文档：[i2f-jdbc-data](./i2f-jdk/i2f-jdbc-data/readme.md)

### i2f-jdbc-impl

> **JDBC 体系的核心执行层**（19 源文件约 4375 行、14 包、零测试）：2191 行超级门面 `JdbcResolver`——连接管理/事务模板、`detectType` SQL 分类、query/list/page/find/get 查询家族（`find` 用 `maxCount=2` 探针检测多行）、batch 批处理（`${expr}` 经 `Visitor` 求值 + `?` 占位替换）、call/callNaming 存储过程、cursor 流式游标（MySQL/PG fetchSize `Integer.MIN_VALUE` 特判）、30+ 类型参数绑定级联（`TypedArgument` 三级协议 + JDBCType 全枚举 + null 类型猜测）、`parseResultSet` 三段式泛型解析管线（列元数据 22 字段快照 + 行转换三级列名匹配）、三组 SPI 注册表（参数绑定/结果转换/结果抽取，`CopyOnWriteArrayList` + `ServiceLoader`，内置 SQLite BLOB 抽取器）；辅以 `JdbcTemplate`（`contextActionDelegate` 会话委托模板，被 `BqlTemplate` 继承）、`JdbcCursorImpl`（预取一行 + 耗尽自动 dispose）、`JdbcScriptRunner`（**反编译重建**的脚本执行器）、`SQLState`（803 行 SQLState 常量枚举）与 datasource/extract/handler 支撑件。被 11 个外部模块（31 文件）消费——最重消费者 `i2f-database-metadata-impl`（65 处 `parseResultSet` 直读 `DatabaseMetaData`），另有 `i2f-jdbc-bql/procedure/proxy`、`springboot-ops-starter`、`ai-rag-sqlite` 及 4 个经传递获得的模块；`i2f-jdbc-data`/`i2f-typeof`/`i2f-convert`/`i2f-database-type`/`i2f-reference` 均为隐式传递依赖。**中危瑕疵**：jdbcType 分支双重 `return` 致参数静默不绑定、`loadDriver` 任一失败即抛的 AND 逻辑、空批处理 `stat.executeBatch()` NPE、`LocalDateTime`/`java.util.Date`/`Instant` 参数被 `setDate` 截断时分秒等（详见文档）。

- 详细文档：[i2f-jdbc-impl](./i2f-jdk/i2f-jdbc-impl/readme.md)

### i2f-jdbc-std

> **JDBC 体系的最小契约层 / 依赖倒置地基**（3 源文件仅 50 行、2 包、零测试）：全模块只有三个接口——`JdbcInvokeContextProvider<T>`（连接获取的上下文抽象，`beginContext` → `getConnection` → `endContext` 生命周期 + 两个 `Object` 桥接方法，为 `<?>` 通配符持有者解决 Java 泛型捕获限制）+ `SQLFunction`/`SQLBiFunction`（SQL 感知函数式接口，唯一差别 `throws SQLException`，使 `transaction`/`query`/游标装配等 API 直接接收方法引用与纯 lambda）；标准消费模式为 `i2f-jdbc-impl/JdbcTemplate.contextActionDelegate` 四段式（开启 → 取连接 → 执行 → finally 归还），被 4 个模块（9 文件、14 处 import）消费——`i2f-jdbc-impl`（唯一 POM 显式声明者，含实现类 `DirectJdbcInvokeContextProvider`）、`i2f-jdbc-bql`/`i2f-jdbc-proxy`/`i2f-springboot-jdbc-bql-starter`（均经传递获得，另有实现类 `SpringDatasourceJdbcInvokeContextProvider` 经 `DataSourceUtils` 提供 Spring 事务感知）；`i2f-jdbc-data` 声明后自身零消费是**有意的传递通道**设计，`lombok` 为冗余声明；零高位缺陷（仅无校验转型、桥接方法公开暴露等低危注记）。

- 详细文档：[i2f-jdbc-std](./i2f-jdk/i2f-jdbc-std/readme.md)

### i2f-jdbc-bql

> **BQL 的运行期落地层 / JDBC 执行门面**（单类 `BqlTemplate` 248 行、1 包、零测试）：`extends JdbcTemplate`，把 `i2f-bql` 流式构建器物化（`$$()` → `BindSql`）后直接执行——45 个方法全为转发：Bean CRUD 快捷方法（`Bql.$bean()` 反射实体生成 SQL，insert/update/delete/find/list/page/deleteByPk 直接吃实体对象）、`contextActionDelegate(bql.$$(), JdbcResolver.xxx)` 手工委托的查询方法（get/find/list/page/queryRaw/queryHandler）、`$$()` 后交给继承 `BindSql` 重载的直通通道（batch 8 重载/update/queryRaw/queryHandler）；被 4 个模块显式消费——`i2f-translate-en2zh`（SQLite 词典 `get`）、`i2f-translate-zh2pinyin`（`find` + `toCamel` 列映射）、`i2f-springboot-jdbc-bql-starter`（`i2f.jdbc.bql.enable` 条件自动装配 Bean）与 `test-springboot`（`@DataSource` 动态源演示）；`i2f-jdbc-std`/`i2f-jdbc-data`/`i2f-page`/`i2f-bindsql` 为隐式传递依赖。**中危风险**：`deleteByPk(beanClass)` 传空 varargs/空集合时，`$in` 空集合裁剪 + `$trim` 空前缀守卫（`if (!sql.isEmpty())`）叠加，最终生成**无 WHERE 的整表 DELETE**（`listByPk` 空参同链条全表查询、`findByPk(clazz,null)` 静默返回首行；batch 表达式语义等详见文档）。

- 详细文档：[i2f-jdbc-bql](./i2f-jdk/i2f-jdbc-bql/readme.md)

### i2f-jdbc-proxy

> **Mapper 接口的 JDBC 动态代理层 / MyBatis Mapper 模式的独立实现**（12 源文件 762 行、7 包、零单测——test 包为演示类）：`ProxySqlExecuteGenerator`（工厂）→ `ProxyRenderSqlHandler`（`IProxyInvocationHandler`：参数名解析（@Name/-parameters）、`JdbcInvokeContextProvider` 四段式会话、databaseType/dialectType/connection 自动注入、按返回类型分派 `JdbcResolver`（update/callNaming/query/get/page/list/find，含 ApiOffsetSize 分页探测与 @IgnorePage 开关、泛型 relTypes 缓存））→ `ProxyRenderSqlProvider`（SQL 来源抽象）；`AbstractProxyRenderSqlProvider` 五级管线：BaseMapper 内建桥（31 方法的 `BaseMapperSqlProvider` 按名+参数个数分派 `Bql.$bean()` 反射生成）→ 缓存 → `@SqlScript` → `getScript` → `inflateScript` → `renderSql`；内置 `SimpleProxyRenderSqlProvider`（`<?expr?>` + Visitor），生态扩展 XML（proxy-xml 的 Mybatis provider）与 Velocity（starter）；被 3 模块消费（5 文件全部显式声明）：`i2f-jdbc-proxy-xml`、`i2f-springboot-jdbc-bql-starter`（条件自动装配 + mapper 接口扫描注册 FactoryBean）、`test-springboot`（`TestMapper extends BaseMapper` 端到端）；**注意两个静态推演缺陷**：抽象类 render 的 NPE 链（script 为 null 时 L56/L59，XML provider 自定义方法路径必然触发；含 @SqlScript 时 L58 ret 为 null 亦 NPE）与 Simple provider 贪婪正则 `.+`（单行多 `<?...?>` 被合并吞掉，经 `RegexUtil.replace` 的 matcher.find 迭代确认）。

- 详细文档：[i2f-jdbc-proxy](./i2f-jdk/i2f-jdbc-proxy/readme.md)

### i2f-jdbc-proxy-xml

> **MyBatis 风格的 XML 动态 SQL 引擎 / Mapper XML 的独立重实现**（30 源文件 2159 行 + 3 资源文件、9 包、零单测——test 包为演示类）：`MybatisMapperParser`（XML→节点树，unqId=namespace.id，`<script>` 片段双重转义兜底解析）→ `MybatisMapperInflater`（878 行解释器：15 种脚本标签含 4 个自研 dialect 标签、foreach 5 种集合形态、`${}/#{}/$!{}/#!{}` 占位符 + 注释保护、五元扩展 handler/javaType/jdbcType/convertor/provider + 18 内置组件 + SPI 扩展点，默认 MemoryCompiler 内存编译表达式、OGNL 变体可换）→ `MybatisMapperContext`（节点注册表 + inflate/inflateTemp 入口）；消费：i2f-jdbc-procedure（核心直连）、xproc4j（匿名子类扩展）、SpringBoot starter；⚠ **provider 桥接管线必然 NPE（功能不可用，getScript/renderSql 双 null 组合）+ include/foreach 未命中静默丢弃同层已拼接 SQL + v-* 四个转换器未注册静默失效**

- 详细文档：[i2f-jdbc-proxy-xml](./i2f-jdk/i2f-jdbc-proxy-xml/readme.md)

### i2f-jdbc-procedure

> **XML 存储过程 / 工作流引擎（XProc4J）——「去数据库存储过程」的核心业务引擎**（156 源文件 14257 行 + 39 包、内置 12 份官方技术文档 19873 行、测试 3 类 201 行 + docs 演示）：`JdbcProcedureParser`（228 行：剥离 DTD → `__FILE__`/`__LINE__` 宏替换 → 复用 i2f-xml StAX → `XmlNode` 树 + 语法校验）→ `ProcedureMeta`（100 行：XML/JAVA 双过程源统一元信息）→ `JdbcProcedureExecutor`（425 行接口 ~120 方法）+ `BasicJdbcProcedureExecutor`（2611 行：77 内置节点三通道注册（内置/SPI/IoC bean）+ 修饰符常量优化 + 连接缓存 + JdbcTrans 事务 + 三级慢阈值监控 + 调试桥）→ `AbstractExecutorNode`（365 行 4 切点模板）+ node/impl 77 节点（SQL 全家桶 / lang 控制流 / 子过程 / 事件 / 调试 / AI）；MyBatis 风格顺序执行、`<sql-dialect>` 多方言择一、`EvalScriptProvider` 脚本引擎扩展（xproc4j 六引擎）、异常即控制流（Break/Continue/Return/Throw/NotFound 信号族）、`@JdbcProcedure` Java 过程与 XML 过程统一注册；被 3 扩展模块（xproc4j/datax/flink 经节点 SPI）+ xproc4j-starter + idea-plugin 消费；⚠ 主要风险：`applyNamingContextComponents` 的 return 中断 bean 注册循环（:485）、`CONST_FEATURES` 数组 is-not-null 缺失（FeatureConsts :103）、`SqlTransactionalNode` 无事务分支 NPE（:179）、`LangLockNode` 锁内随机睡眠 3~7 秒（:72）、`SqlEtlNode` 伪事务（事务调用全注释）等 24 条（详见文档）。

- 详细文档：[i2f-jdbc-procedure](./i2f-jdk/i2f-jdbc-procedure/readme.md)

### i2f-database

> 数据库能力聚合门面模块，零源码通过 maven-assembly-plugin 将 i2f-database-type（方言类型识别）与 i2f-database-metadata-impl（元数据多方言实现）打包为单一 fat-jar，被 i2f-jdk-all 全仓聚合引入。

- 详细文档：[i2f-database](./i2f-jdk/i2f-database/readme.md)

### i2f-database-metadata-bean

> Java Bean ↔ 数据库元数据映射层，从 @Table/@Column/@Primary 等注解标注的 POJO 反射解析为 TableMeta 数据模型（BeanDatabaseMetadataResolver），并反向从 TableMeta 生成带注解的 Java Bean 源码（JavaBeanDatabaseReverseEngineer），被 i2f-bql 和 i2f-extension-reverse-engineer-generator 消费。

- 详细文档：[i2f-database-metadata-bean](./i2f-jdk/i2f-database-metadata-bean/readme.md)

### i2f-database-metadata-data

> 数据库元数据数据模型与类型系统层，定义 TableMeta/ColumnMeta/IndexMeta/IndexColumnMeta 四级 POJO + StdType 标准化类型枚举（34 常量）+ IColumnType 方言类型映射接口，是 database-metadata-std/impl/bean 及 reverse-engineer-generator 的公共数据模型地基。

- 详细文档：[i2f-database-metadata-data](./i2f-jdk/i2f-database-metadata-data/readme.md)

### i2f-database-metadata-std

> 数据库元数据标准契约层，定义 DatabaseMetadataProvider（JDBC 元数据读取器）与 DatabaseReverseEngineer（DDL 反向生成器）双接口，被 i2f-database-metadata-impl 多方言实现与 reverse-engineer-generator 消费。

- 详细文档：[i2f-database-metadata-std](./i2f-jdk/i2f-database-metadata-std/readme.md)

### i2f-database-metadata-impl

> 数据库元数据多方言实现层，以模板方法 + 委拖代理双架构提供 9 种方言的 JDBC 元数据读取器（MySQL/Oracle/DM/Gbase/H2/PostgreSQL/SQLite3/SQL Server/JDBC 通用）+ 5 方言 DDL 反向生成器，被 i2f-extension-reverse-engineer-generator 与 i2f-springboot-ops-starter 消费。

- 详细文档：[i2f-database-metadata-impl](./i2f-jdk/i2f-database-metadata-impl/readme.md)

### i2f-database-dialect

> SQL 字面量方言安全转换器，以模板方法 + 9 方言实现将 Java 对象（日期/数值/字符串/布尔）转换为各数据库方言兼容的 SQL 字面量字符串（STR_TO_DATE/TO_DATE/TO_TIMESTAMP 等），被 i2f-bindsql-stringify 作为底层 SQL 文本化引擎消费。

- 详细文档：[i2f-database-dialect](./i2f-jdk/i2f-database-dialect/readme.md)

### i2f-launcher

> 轻量级**应用启动器 / 外置 classpath 加载器**（单包 `i2f.launcher`，3 类，零 i2f 内部依赖、零三方运行期）：借鉴 Spring Boot Loader 并简化——Maven 把 jar 的 `Main-Class` 指向 `ExtApplicationLauncher`，运行期读 `Ext-Main-Class`（真实入口）与 `Ext-Path`（额外 classpath 目录，默认 `lib,libs,plugin,plugins,...`），经 child-first 的 `ExtClasspathClassLoader`（`URLClassLoader` 覆写 `loadClass`/`getResource(s)`，JDK 包名回退父优先）加载外置目录与其下 jar，再反射调真实 `main`；`ExtLauncherSpi.premain` 提供业务启动前的一次性 `ServiceLoader` 钩子。解决「jar 打包期 Class-Path 固化、运行期难追加」痛点，适配插件化与 JDBC Driver 等动态 SPI 加载；真实消费方 `i2f-tools-ops`（lombok 声明未用，`:` 切分破坏 Windows 盘符路径等瑕疵见文档）。

- 详细文档：[i2f-launcher](./i2f-jdk/i2f-launcher/readme.md)

### i2f-log-std

> 日志**标准门面层**（`std` 契约与实现分离）：统一大门面 `ILogger` 以「6 级别 × 入参形态（format / 纯 args / `Supplier` / `PerfSupplier` / `Function` / `BiFunction`）× 带 `meta`/`Throwable`」展开数百 `default` 方法、全部收敛到 2 个抽象 `write`；`LoggerFactory` 用 `LruMap` 缓存 logger 并按「系统属性 → `META-INF/log.properties` → SPI（选名或取首个） → 内置 `StdioLogger` 彩色兜底（warn+ 走 stderr）」多路径解析可插拔 `LoggerProvider`；`AbsLogger` 模板方法把 `write` 收敛为 `writeLogData(LogData)`；`LogData` 携 traceId（MDC）与 DEBUG 级调用点（`ThreadTrace`），惰性求值变体关级零开销。六个依赖（`i2f-clock-impl`/`i2f-trace`/`i2f-trace-mdc`/`i2f-lru-map`/`i2f-console-color`/`lombok`）皆真实使用；下游 `i2f-log`（默认完整实现 + SPI 注册 `DefaultLoggerProvider`）与双向 SLF4J 桥接（`i2f-extension-slf4j-log`/`i2f-extension-log-slf4j`）。**瑕疵**：`*Args`/`*MetaArgs` 全级别门级误用 `enableFatal()`，越过自身级别阈值（对 StdioLogger 被 `AbsLogger.write` 二次判级掩盖）。

- 详细文档：[i2f-log-std](./i2f-jdk/i2f-log-std/readme.md)

### i2f-log

> `i2f-log-std` 门面的**默认完整实现层**（8 子包、23 类，零三方运行期）：`DefaultLoggerProvider` 经 SPI 注册被 `LoggerFactory` 优先选中、产出 `DefaultLogger`（`AbsLogger` 具体化）；运行期四大可插拔组件（决策器 `ILogDecider`、写出器 `ILogWriter`、消息格式化器 `ILogMsgFormatter`、数据格式化器 `ILogDataFormatter`）集中在 `LogHolder`「**全局 `GLOBAL_*` + 线程 `THREAD_*` 双路由**」注册表、可替换；决策器按调用位置 ant 模式就近分级，`DefaultLogDataFormatter` 产出 ANSI 彩色整行 Layout，`DefaultBroadcastLogWriter` 多目标异步广播（work-stealing 池 + 二级 SPI `LogWriterProvider`）并内置控制台/本地滚动文件/`JdbcDatasourceLogWriter`（有界队列攒批写 `i2f_log`、自动建表）三类写出器，`StdoutRedirectPrintStream` 把 `System.out/err` 收编进日志（带递归护栏与逐调用点归因），`LogConfiguration`+`log.properties` 一键装配。真实使用全部 5 个依赖（`i2f-log-std`/`i2f-uid-impl`/`i2f-match`/`i2f-reflect`/`lombok`）并经 std 传递复用 `LruMap`/`ExpireConcurrentMap`/`SystemClock`/`ConsoleColor`/`ThreadTrace`；下游 `i2f-extension-log-slf4j` 提供 `LogWriterProvider` SPI 转投 SLF4J 后端。**瑕疵**：`DefaultLogger` 级别缓存因 std 侧 `ExpireConcurrentMap.get` 反向判定永不相中且每 logger 泄漏一条调度线程；`JdbcDatasourceLogWriter` 丢堆栈、`setDate` 截时间；`LogConfiguration` 两处（stdoutWriter 误挂整个广播器、级别项 `return` 误代 `continue`）等（详见文档）。

- 详细文档：[i2f-log](./i2f-jdk/i2f-log/readme.md)

### i2f-jvm

> **JVM 运行环境探测工具 / 零依赖最小工具模块**（单包 `i2f.jvm`、单类 `JvmUtil` 100 行、7 静态方法、零依赖零资源零测试）：基于 `java.lang.management.RuntimeMXBean` 提供进程标识（`getPid()` 拆 `pid@host` 取 PID、`getStartUser()` **实返回主机名**）、启动参数直通（`getInputArguments`/`getRuntimeMXBean`）与三大启动参数特征检测（`isDebug()` 识别 jdwp、`isAgent()` 识别 `-javaagent:`、`isNoVerify()` 识别历史参数），5 字段以 `AtomicReference.updateAndGet` 无锁惰性缓存；消费 **9 模块**（6 显式 POM + 3 隐式传递）：调试桥门控 **14 处** `isDebug()`（antlr4 脚本引擎 / jdbc-procedure / idea-plugin 的断点桥前置判断）、`i2f-agent` 自附加 `VirtualMachine.attach(getPid())`、spring-starter 启动横幅（PID/User/debug/agent/verify）、env-impl/jvm-mixins/form/agent-javassist；⚠ `getStartUser()` 命名与实现不符（返回**主机名**而非启动用户，启动横幅 `User:` 栏展示错误）、`getPid()` 解析失败降级字符串 `"-1"` 且被永久缓存（attach 场景将失败、"−1" 可被 `Long.parseLong` 静默吞下）。

- 详细文档：[i2f-jvm](./i2f-jdk/i2f-jvm/readme.md)

### i2f-lifecycle

> **统一生命周期契约模块**（全模块仅 2 文件约 50 行：1 接口 + 1 非受检异常，零 i2f 内部依赖、运行期零三方）：ILifeCycle extends Closeable 以 create()/destroy()/close() 三动词刻画「显式创建 → 使用 → 显式销毁」对象的最小生命周期——create/destroy 均为 default 空实现（可选钩子、按需覆写），close() 把 Closeable.close() 桥接为 destroy()，使生命周期对象天然兼容 try-with-resources；配套 LifeCycleException（extends RuntimeException、4 构造器）作为创建/销毁阶段失败的约定信号（create/destroy 签名不带 throws，实现方以非受检异常包装 IO/SQL 失败）。被三族消费：i2f-data-processor（IDataReader/IDataWriter 继承 + 实现类以 LifeCycleException 包装 IO 并支持 deleteOnDestroy 删文件）、i2f-check-filter（IHashGroupProvider 继承，HashGroupRepeatFilter 哈希分组去重管线手工 create/destroy 各级流）、i2f-translate 体系（ITranslator 继承，SQLite 连接随 create/destroy 开关、测试类以 try-with-resources 验证 close→destroy 桥接，另有实现只吃默认空钩子）；⚠ 钩子默认空实现且无状态/无幂等约定、失败信号部分消费方改用 IllegalStateException、pom 声明的 lombok 实际未用。

- 详细文档：[i2f-lifecycle](./i2f-jdk/i2f-lifecycle/readme.md)

### i2f-limit

> **按 key 限流器模块**（5 文件约 350 行、零测试、两条互不相关的契约线）：新线（2024/8）单动词 Limiter.require(name) + TokenBucketLimiter——ConcurrentHashMap 按名分桶（null 走全局桶 nullCnt，新桶初始 1 令牌），单守护线程 limit-thread 每周期给每桶 +incrementCount（封顶 limitCount，默认 300）并清理闲置超 maxKeepaliveMillSeconds（默认 30 分钟）的键，require() 单调用完成「惰性 init → 取桶刷新访问时间 → 原子扣减 → 旧值 > 0 放行」，另有 getQps/setQps 便捷换算；旧线（2022/5）三动词 IKeyedLimiter（hasLimit/limit/unlimited，args 预留未用）+ 两实现：MaxCountWaitTimeExpireKeyedLimiter（最大失败次数 + 等待期的「滑动锁定」，计数存 ObjectExpireCacheWrapper(MapCache) 十进制字符串、limit() 每次重置 TTL、封顶 max(maxCount,maxRecordsCount)，unlimited 即解除，setCache 可换分布式）与 TokenBulletKeyedLimiter（构造即启动定时补充：每 productTime 每键 +1 封顶 maxTokenCount，未登记键默认放行、新键 limit() 建 0 令牌，可外部注入线程池）。依赖 i2f-clock-impl（SystemClock 缓存时钟）与 i2f-cache（本地过期缓存），lombok 真实使用；⚠ 全仓无源码级消费者（仅 i2f-jdk/i2f-jdk-all/根 POM 注册）；setQps 公式错误（仅「秒 + 周期 1」严格成立，分钟截断为 1、毫秒放大 1000 倍）且 getQps 亚秒周期除零；TokenBulletKeyedLimiter 的 synchronized(this) 锁错 Runnable 对象、默认池非守护且无停止手段、counters 无清理、hasLimit 竞态可 NPE；MaxCount... 的 waitTimeUint 未设置时 limit() NPE 等（详见文档）。

- 详细文档：[i2f-limit](./i2f-jdk/i2f-limit/readme.md)

### i2f-lock

> **锁抽象契约模块**（8 文件约 230 行，框架无关、运行期零三方依赖）：以 ILock（lock/unlock throws Throwable） 定义基本锁最小接口；INotify（signal/signalAll/await） 定义条件等待/通知契约；INotifyLock extends ILock, INotify 组合标识；IReadWriteLock（readLock/writeLock 均返回 ILock） 提供读写锁抽象；ILockProvider（name/getLock(key)） 定义按 key 获取锁实例的提供者契约。三条实现线：JdkLock 包装 ReentrantLock + Condition 实现 INotifyLock（3 构造器支持无参/共享 Lock/完全自定义）；JdkReadWriteLock 包装 ReentrantReadWriteLock 适配 IReadWriteLock（读/写锁经 JdkLock 统一为 ILock）；JdkCacheLockProvider 以 ConcurrentHashMap.computeIfAbsent 按 key 懒建 JdkLock 缓存（NAME = "jvm" 标识进程内锁提供者，支持外部注入 Map）。设计要点：接口抛出 Throwable 为分布式锁预留；读写锁均返回 ILock 降低使用复杂度；INotifyLock 通过接口组合表达能力聚合。⚠ JdkCacheLockProvider 缓存不自动清理，key 有限场景安全。

- 详细文档：[i2f-lock](./i2f-jdk/i2f-lock/readme.md)

### i2f-os

> **操作系统工具模块**（25 源文件约 2350 行）：`OsUtil` 静态门面提供 Windows/Linux 判定、`is64bit` 三级判定、命令字符集探测（`sun.jnu.encoding`→`file.encoding`→默认）与命令执行四形态（start/run/exec/execForResult × 单串/数组重载，stdout+stderr 合并读取后返回 `CommandResult`：exitCode/executeTimeout/stdout）；`WindowsOsUtil` 封装 PowerShell（`-Command` 直执行 + UTF-8 BOM 临时 ps1 以 `-File` 执行后清理）；`PerfUtil` 按平台分发 CPU/内存/磁盘使用率采集——Linux 侧 `LinuxUtil` 解析 top/free/df/iostat（含各设备 IO 明细），Windows 侧 `WindowsUtil` 解析 WMIC 并映射 14 类 DTO（CPU/OS/进程/内存条/缓存/逻辑盘/物理盘/网卡×2/打印机×2/显示器/启动项/声卡）。被 `i2f-mixins`（os_* 混入）、`i2f-ai-std`（技能脚本执行 + 命令型 RAG 读取）、`i2f-jdbc-procedure`（LangShell 节点）、模板渲染系与 `i2f-springboot-ops-starter`（主机管理/AI 命令工具）广泛消费；仅依赖 `i2f-convert`。⚠ 性能采集族暂全仓无源码级消费方；`startCmd` 重载行为分叉且均非异步、超时因读流阻塞形同虚设、Linux 内存/CPU 指标语义反转、WMIC 弃用风险等（详见文档）。

- 详细文档：[i2f-os](./i2f-jdk/i2f-os/readme.md)

### i2f-packet

> **二进制流封包协议模块**（12 源文件约 2000 行，纯 JDK 零依赖）：自定义流式帧协议——`EE EE` 双字节引导 + 四控制字节（EE/EF/EA/EB）与 `EF` 前缀转义，帧结构为「head 数 + 多 head（EA 分隔）+ body 数 + 多 body（EA 分隔）+ 可选 8 字节 tail 校验 + EB」；`StreamPacket` 承载多头多体，`StreamPacketResolver` 提供对称 read/write（前导定位、转义解码、校验重建），`PacketRule` 三预设（simpleRule 无校验/hashRule 校验/defaultRule 校验+上下文 XOR 混淆）且控制字节、缓冲阈值、校验累积器、编解码器全可插拔，`PacketProtocol` 映射为 HTTP 风格（action/content-type/name 内置头 + x-body-{i}-{name} 体级附加头，约 62 个 body 容量推导），`LocalOutputStreamInputAdapter` 按 512KB 阈值自适应内存/临时文件（TempFileInputStream 读完即删）。⚠ 全仓无源码级消费方（仅聚合打包与索引提及）；实测存在读端转义状态缺陷——数据/校验尾字节编码后为 0xEF 时其后分隔符/结束符被吞并（静默数据错位或 IOException），另有协议级 read 对无包 NPE、write 关闭调用方流、长度字节无防护等（详见文档）。

- 详细文档：[i2f-packet](./i2f-jdk/i2f-packet/readme.md)

### i2f-page

> **分页数据模型模块**（3 源文件约 216 行，运行期零依赖仅 lombok 编译期）：三层轻量值对象构成全仓统一分页契约——`ApiOffsetSize`（offset 起始下标 + size 页大小 + end 排他结束下标）、`ApiPage`（0 基页索引 index + `ofPageNumSize` 1 基页号转换 + `beginPage` 默认第 1 页/每页 20 兜底）、`Page<T>`（total 总数 + list 数据列表结果承载）；被 `i2f-bindsql-page`（9 个方言包装器，Oracle/DB2/Firebird/CirroData 依赖 end）、`i2f-jdbc-impl`（JdbcResolver.page 族）、`i2f-jdbc-bql`、`i2f-jdbc-procedure`、`i2f-jdbc-proxy`（BaseMapper.page）、`i2f-extension-mybatis`（MybatisPagination）、`i2f-extension-elasticsearch`、`i2f-extension-xproc4j` 等约 35+ 源文件消费。⚠ 实测高危缺陷：`ApiPage.prepare()` 在 index 非空且 size 为 null 时拆箱 NPE（`of(pageNum, null)` 构造即抛）；另有 size=0 反推除零 ArithmeticException、仅 size 时 prepare 单次不补 end 致 Oracle 静默全量返回、`@Data` 继承链 equals 不含父类字段等（详见文档）。

- 详细文档：[i2f-page](./i2f-jdk/i2f-page/readme.md)

### i2f-pool

> **对象池与分段并发原语模块**（6 源文件约 281 行，纯 JDK 零运行期依赖）：`IPool` 双动词契约（require/release）+ `ObjectPool`（LinkedBlockingQueue 缓存 + AtomicInteger 计数 + ReadWriteLock 检查-创建、Supplier 懒创建、maxCount 默认 300）的队列缓存对象池；`SegmentObjectProvider`（hashCode % segmentSize 懒创建槽位共享对象）、`SegmentLock`/`SegmentReentrantLock`（按 key hash 加解锁）、`SegmentSynchronizedObjectProvider`（槽位编号经 String.intern 化为有限全局监视器 + 三态 synchronize 辅助）的分段并发族；被 i2f-swl 的 SwlExchanger 用于加密器/摘要器实例复用。⚠ 实测高危缺陷：`ObjectPool.require()` 新建对象同时入队并返回同一引用，导致同一对象被多个调用者并存持有、配对 require/release 后重复发放（详见文档）。

- 详细文档：[i2f-pool](./i2f-jdk/i2f-pool/readme.md)

### i2f-properties

> **Properties 配置装载模块**（4 源文件约 260 行 + 1 演示 properties，依赖 i2f-reflect/i2f-text）：`PropertiesUtil` 单门面提供「properties → 强类型 Bean」装载管线——`load(File/URL/InputStream)` + `toMap` 排序收集 + `ObjectRouteResolver` 点分键逐层树化（`items[0].name` 合成 List）+ `StringUtils::toCamel` 键风格归一（下划线/中划线/驼峰三种写法等价）+ `Visitor` 前缀定位（支持点路径）+ `RichConverter` 递归转换（嵌套 Bean/List/枚举/File/Class），6 个 `loadAsBean` 重载（Class/TypeToken/Type × 有无 prefix）；自带 `test` 演示包（log.properties 结构 + 混合键风格示例）。⚠ 全仓无源码级消费方（仅聚合打包与索引提及；i2f-log 为自研 loader 未依赖本模块）；实测两处高危缺陷：字符串配置转布尔全部得到 true（`=false` 读回 true，根因 i2f-convert ObjectConvertor 宽泛转换拦截使 tryParseBoolean 成死代码）、顶层键首段含 `_`/`-`/大写开头时 NPE（根因 i2f-reflect groupMap 的 put/get 键不一致），另有流关闭两态不一致、prefix 未命中静默 null、toMap 丢弃非 String 键值等（详见文档）。

- 详细文档：[i2f-properties](./i2f-jdk/i2f-properties/readme.md)

### i2f-proxy-std

> **代理标准契约层**（6 源文件约 320 行，仅依赖 i2f-invokable）：双契约——`IProxyHandler` 五阶段钩子（initContext/before 短路/after 改写/except 替换/onFinally 回调）与 `IProxyInvocationHandler` 函数式三参 invoke（@FunctionalInterface + `of(IProxyHandler)` 适配工厂）；`IProxyProvider` 提供者契约（proxy(obj, handler) 双形态桥接）；`ProxyHandlerAdapter` 五阶段编排器；`DefaultMethodSmartInvocationHandler` 三路分派骨架（Object/default/普通，default 经 MethodHandles findSpecial 特殊调用）；`MethodHandlesUtil` JDK8 私有构造器反射与 JDK9+ privateLookupIn 的跨版本 Lookup 兼容层。被 i2f-proxy/i2f-proxy-handlers/i2f-mixins/i2f-spring-core 与 cglib/aspectj/mybatis/ai-std 等扩展消费。⚠ 实测三处高危缺陷：五阶段适配器任何目标异常 → 变成无信息的 NPE（except 传错变量 + throw null，真实异常彻底丢失）、智能 handler 抽象方法直接崩（IllegalArgumentException）、Object 方法语义颠倒（`proxy.equals(proxy)`=false）（详见文档）。

- 详细文档：[i2f-proxy-std](./i2f-jdk/i2f-proxy-std/readme.md)

### i2f-proxy

> **JDK 动态代理实现模块**（6 源文件约 170 行，依赖 i2f-proxy-std）：`JdkProxyUtil` 六重载门面（IProxyInvocationHandler 函数式 / IProxyHandler 五阶段 / 原生 InvocationHandler 三契约 × 实例/接口双形态）+ normal 适配器（target=原实例可转发）与 interfaces 适配器（target=代理自身）双 InvocationHandler 适配器 + `JdkProxyProvider`/`JdkDynamicProxyProvider` 双 IProxyProvider（INSTANCE 单例）+ `BasicDynamicProxyHandler` 五阶段 before 解包骨架；被 ai-std/http-proxy/jdbc-proxy/aspectj/xproc4j-starter 五处消费（AiServices/RestClientProvider/ProxySqlExecuteGenerator/AspectjUtil 等声明式接口基础设施）。⚠ 实测要点：interfaces 形态 + 五阶段未短路无限递归（before 被调 1030 次后 NPE 终止）、泛型 T 陷阱赋给实现类即 CCE、default 与 Object 方法全部回调 handler（详见文档）。

- 详细文档：[i2f-proxy](./i2f-jdk/i2f-proxy/readme.md)

### i2f-proxy-handlers

> **注解驱动的代理处理器模块**（4 源文件约 706 行，依赖 i2f-proxy-std/i2f-annotations-ext/i2f-lock/i2f-convert/i2f-comparator/i2f-reflect）：把 `@Lock`/`@Retry`/`@Validate` 横切语义落地为三个可直接挂动态代理的 `IProxyInvocationHandler`——`LockProxyHandler`（锁键=类名+方法名+value，JVM ReentrantLock 默认、ILockProvider 可换分布式）、`RetryProxyHandler`（倍率退避 + maxDelay 封顶 + breakOn）、`ValidateProxyHandler`（15 校验注解族 + @Tag 标签过滤 + 对象/集合/Map/数组递归 + 路径化消息 `arg0[0].name`）+ `ValidateException`；全仓暂无源码级消费方（参考实现库，按需手动挂载）。⚠ 实测高危缺陷：三个处理器 interfaces 形态转发即无限递归（getLock 被调 1032 次、根因 SOE，必须 normal 实例形态）、breakOn 因 ITE 包装完全失效、转发业务异常被包成 UndeclaredThrowableException<-ITE<-业务异常、@NotSize 双边界判定反转（区间内放行/低于下界误拒）、@Min 失败消息误报 Max（详见文档）。

- 详细文档：[i2f-proxy-handlers](./i2f-jdk/i2f-proxy-handlers/readme.md)

### i2f-reference

> **值的三态引用包装**（单包单类 `Reference<E>` 183 行、零 Maven 依赖连 lombok 都无）：以 VALUE/NOP/FINISH 三态显式区分「有值（可为 null）/无值跳过/流终止」四种 `null` 无法表达的语义，`ReadWriteLock` 读写锁保护 `get/set/isXxx/toXxx`，`nop/finish/empty/of` 四静态工厂；被 `i2f-iterator`（元素读取三态协议）与 `i2f-container`（RingQueue 队列槽位）直接依赖，经 `i2f-text`、`i2f-match` 两条主干传递至 jdbc/ai/脚本族共 9 模块 19 文件消费（缓存可空值、扩展点短路、SSE 流终止信号）。

- 详细文档：[i2f-reference](./i2f-jdk/i2f-reference/readme.md)

### i2f-reflect

> **全仓反射能力中央底座**（33 个源文件约 6200 行）：`ReflectResolver` 单类 3414 行七大能力族——类加载（双路径 + 前缀补全）、字段/方法发现（序列化视角过滤）、注解解析（元注解递归 + @Repeatable 展开）、调用匹配（类型距离 + varargs 打包）、值读写（getter/setter 优先）、Bean 复制（copy/assign/merge 三语义 + 弱名归一）、虚拟字段；叠加 `RichConverter` 泛型递归强转、`ObjectRouteResolver` 点分路由扁平↔树、`ReflectSignature` 签名互转与 `vistor` 表达式引擎（`user.roles[0].name` 路径 + `@静态调用`），约 30 个 LruMap 缓存 + `ENABLE_CACHE` 开关；被 44 模块 79 源文件消费，是 i2f-lambda/i2f-properties/i2f-bql/i2f-spring-mvc-metadata/i2f-jdbc-procedure 等的共同反射地基（⚠ `loadClassWithJdk` 直载丢失、`RichConverter` 迭代器转换死循环 OOM 等 16 项已实证缺陷——详见文档）。

- 详细文档：[i2f-reflect](./i2f-jdk/i2f-reflect/readme.md)

### i2f-resources

> **资源定位与类路径扫描工具箱**（5 源文件约 1460 行、零三方依赖）：`ResourceUtil` 把 `classpath:`/`classpath*:`/`file:`/URL/相对/绝对六态位置统一解析为 URL/Stream/Bytes/String，另提供 `matchResources` 目录/jar 条目通配与 `getResourcesFiles` 位置集合展开；`ResourcesLoader` 是全类路径扫描引擎——目录递归 + jar 流遍历 + 嵌套 jar URL 流式解包 + manifest `Class-Path` 补全 + `jumpJre` 跳过 JRE + jar/资源双 BiPredicate 过滤（默认排除约 150 个三方前缀）+ 包名最短前缀收缩 + `ReflectResolver.loadClass` 产 Class，`getResources()` 带 `RES_CACHE` 缓存，支撑 netty 注解控制器扫包与 quartz 任务扫描；`ResourceProvider`/`DefaultResourceProvider` 以 `assets.properties`+`assets/bundle/` 约定提供键值/媒体/类型化取值（SPI 尚无消费方）。被 io-file/idcard/ai-std/翻译/Excel/逆向生成等 11 模块直接消费、经 i2f-ai-std 传递至 jdbc-procedure/xproc4j-starter 等 6 模块（共 25 源文件；⚠ 主要瑕疵：provider `get(id)` 变长参数传 null 数组 NPE、嵌套 jar 假递归 URL 失真、classpath 分号硬编码、`isLegalClassFile` 数字规则误杀——详见文档）。

- 详细文档：[i2f-resources](./i2f-jdk/i2f-resources/readme.md)

### i2f-resp

> **统一 API 响应契约模块**（2 源文件约 95 行、运行期零依赖仅 lombok 编译期）：`ApiResp<T>` 泛型响应体——`code`/`msg`/`data` 三字段 + 惰性 `kvs` 扩展键值，链式 `code()/msg()/data()/add()` 与 `success/error/resp` 静态工厂并存，`isSuccess()` 以 `code == 200` 为唯一判据；`ApiCode` 常量接口收纳 7 个状态码（SUCCESS=200、ERROR=0、NO_LOGIN=401、NO_AUTH=403、UNKNOWN=402、NOT_FOUND=404、SYS_EXCEPTION=500）。作为全仓「正常返回链路」的统一响应模型（与 i2f-exception 的「异常抛出链路」互补）：被 `i2f-springboot-spring-starter` 以 `@ConditionalOnMissingBean` 默认装配为全局响应包装/异常转换/404 转换三转换器（可整体替换），security/shiro/sentinel/activity/spring-authentication 安全与业务处理器、ai-rest-openai MCP 网关接口签名直接使用；共 9 模块 23 源文件消费（直接 7 模块 19 文件 + 经 ai-rest-openai 传递 2 模块 4 文件）。⚠ 主要瑕疵：`ApiCode` 常量接口反模式（非 enum 无法穷举）+ 两套码值体系混编且消费方裸数字回潮（UNKNOWN=402 与 HTTP 402 语义冲突）、`error(msg)` 默认码 0 与 HTTP 状态脱钩、`isSuccess()` 被 Bean 序列化额外产出 success 字段、工厂参数顺序（data/msg）不一致、kvs 惰性初始化返回 null——详见文档。

- 详细文档：[i2f-resp](./i2f-jdk/i2f-resp/readme.md)

### i2f-robot

> **AWT 桌面自动化工具**（单类 `RobotUtil` 20 方法名/24 公开静态方法约 165 行、纯 JDK 零依赖、全仓零消费方）：把 `java.awt.Robot` 封装为静态门面——设备层 `defaultGraphicsDevice`/`getGraphicsDevices`（多屏枚举），实例层 `defaultRobot` 懒加载单例（失败包装 UnsupportedOperationException），操作层三族：截屏族（`screenCapture` 主屏截图 / `screenSave(File)` 按扩展名 jpg/jpeg/png/bmp 选编码器存图 / `getPixelColor` 取色 / `getBounds` 主屏边界）、键盘族（`keyClick` 单键、`keyPressCombine` 正序按下逆序弹起、Ctrl+C/V/X、Ctrl+Shift+Esc、Ctrl+Alt+Del、Win 键）、鼠标族（左中右键点击、`mouseDrag` 左键直线插值拖拽 10ms/步），键鼠操作内置 60ms 按下-弹起间隔。定位为面向使用者的独立工具库：经 `i2f-jdk-all` 聚合打包、无 Main-Class 非可执行 jar。⚠ 主要瑕疵：多屏支持残缺（操作全部固定默认屏）、`keyPressCtrlAltDelete()` 受 Windows SAS 安全注意序列保护本质无效、拖拽步长/延迟魔法数不可调、`screenSave` 非白名单后缀静默按 png 编码但保留原扩展名、headless 下设备层 HeadlessException 与 Robot 层 UnsupportedOperationException 失败方式不一致——详见文档。

- 详细文档：[i2f-robot](./i2f-jdk/i2f-robot/readme.md)

### i2f-rowset

> **表格行集流式读写契约**（12 源文件约 830 行、零项目内部依赖仅 lombok 编译期）：`IRowSet` = `Iterator` + `Closeable` 流式行集契约（`IRowHeader`/`IRowSetReader`/`IRowSetWriter` + `SimpleRowHeader`/`SimpleIteratorRowSet`/`SimpleCollectionMapRowSet`），CSV 侧 `CsvReader` 字符级状态机（引号包围/双引号转义/跨行续读/EOF 校验）+ `CsvMapRowSetReader` 自动类型推断（BigDecimal/true/四种日期）+ `CsvMapRowSetWriter` 类型分派格式化（长数字加引号防科学计数、日期三格式），JSON 侧两个抽象 writer（数组套数组/JSONL）把 `toJson` 注入留给使用方不绑定 JSON 库；唯一直接消费方 ops-starter 数据源控制台（/export CSV 导出、/import 流式批量导入；两个 Jackson 适配器备而未用），经其传递至 i2f-tools-ops。⚠ 主要瑕疵：`"false"` 解析返回字符串的布尔不对称 Bug、读写两端 `nullAsEmpty` 同名反义、数据行长于表头越界、静态 ThreadLocal 格式化器跨实例串扰、`"123"`/`"null"` 文本往返类型漂移等——详见文档。

- 详细文档：[i2f-rowset](./i2f-jdk/i2f-rowset/readme.md)

### i2f-script

> **JSR-223 脚本引擎统一门面**（4 源文件约 280 行、零项目内部依赖）：`ScriptProvider` 实现 `ScriptEngine`/`Invocable`/`Compilable` 三接口，把任意 JSR-223 引擎包装为单一门面——静态 `manager` + `getEngine`/`getJavaScriptEngine`/`getInstance`/`getJavaScriptInstance` 双工厂，`compile`/`invokeMethod`/`invokeFunction` 前置 `instanceof` 特性探测（不支持抛 `ScriptFeatureNotSupportException`，而 `getInterface` 却抛 `IllegalArgumentException` 不一致），其余 14 方法纯透传；唯一源码级消费方 `i2f-extension-xproc4j`（`LangEvalJavascriptNode` 求值 `<lang-eval-javascript>` 标签并包装异常、`LangEvalJavaNode` 把 `i2f.script.*` 注入动态编译代码），经 `i2f-jdbc-procedure`（编译级声明但模块内零引用）传递供给；Java15+ 需自行补 nashorn-core（provided+optional，胖包不含）。⚠ 主要瑕疵：引擎 null 静默构造 NPE 延迟爆发、三接口无条件实现致 `instanceof Compilable` 判定失真、getInterface 异常类型不一致、demo 类随主 jar 发布、lombok 冗余声明——详见文档。

- 详细文档：[i2f-script](./i2f-jdk/i2f-script/readme.md)

### i2f-search

> **极简前缀索引树（Trie / 字典树）双形态**（2 源文件约 265 行、零项目内部依赖）：`PrefixSearchTree<T, D>` 泛型键序列版 + `StringSearchTree<D>` String 特化版，均以 `ConcurrentSkipListMap` 作有序子节点容器——`add` 挂载（同键覆盖）/ `find` 精确查找 / `prefix` 前缀批量召回（含端点自身，天然按键序）/ `collect` 有序全量导出 / `printTree` ASCII 树形打印 / `remove` 删除 / `clear` 清空，空迭代器约定为根节点操作。全仓零源码消费方（仅 POM 声明 4 处，经 `i2f-jdk-all` 聚合发布）。⚠ 主要瑕疵：`remove` 只清子树不删自身 `data`（叶子路径删除为完全空操作、中间节点留空壳）、null 键 NPE 与非 `Comparable` 键 `ClassCastException` 延迟爆发、两棵树约 90% 重复代码——详见文档。

- 详细文档：[i2f-search](./i2f-jdk/i2f-search/readme.md)

### i2f-serialize-impl

> **序列化契约的官方实现层**（13 源文件约 1422 行、7 个内部依赖 + lombok 实质使用）：配套 i2f-serialize-std 五接口的官方实现——字节族 `SerializeUtil` 静态门面 + `JdkBytesObjectSerializer`（JDK 原生、INSTANCE 单例、null 透传）+ `CharsetBytesStringSerializer`（UTF8/GBK/ISO88591 三常量）；JSON 族**零第三方依赖自研引擎**：`Json2` 静态门面 + `Json2Serializer`（**17 处实例化为全仓默认 JSON 引擎**）+ `JsonGenerator`（229 行类型分派链 + 双单例 null 策略）/ `JsonParser`（407 行正则分词 + 递归下降，JSON5 风格超集单引号/注释/圆括号）；文本族 `FormatTextSerializer`（「类名:内容」自描述，java.lang. 压缩为 $）；XML 族只写 `Xml2` + `Xml2Serializer`（反序列化全抛 UOE）与独立解析器 `XmlParser`（含 main 演示 + XmlCtx/XmlNode 树节点），`Xml2.toXmlString` 11 处静态转义调用（代码生成器族）；六类能力（SerializeUtil/JdkBytes/Charset/FormatText/XmlParser/XmlCtx）全仓零消费。⚠ 探针实证 40 项（28 通过 12 失败 10 观察）：unescape 顺序缺陷吞转义（字面 `\t` 变 TAB、`\n` 错转换行）、`\b`/`\f`/`\u` 还原不对称、裸键 `{a:1}` 静默丢数、大整数与 `|123` 抛 NFE、`deserializeAsMap` 顶层数组 CCE、带 `<?xml?>` 声明解析崩溃、charset null 泄漏 `CodecException` 等——详见文档。

- 详细文档：[i2f-serialize-impl](./i2f-jdk/i2f-serialize-impl/readme.md)

### i2f-serialize-std

> **序列化标准契约层**（15 类型约 384 行 = 9 接口 + 4 异常 + 2 适配器，仅依赖 i2f-codec-std，lombok 声明未用）：以 `ISerializer<E,D>` 双动词统一「对象 ↔ 编码结果」并 default 桥接 codec-std 的 `ICodec`（serialize=encode、deserialize=decode），`ITypeSerializer` 叠加类型化反序列化三级重载（`deserialize(enc)`/`(enc, Class)`/`(enc, Object type)`）与 `deserializeAsMap`；沿数据通道固化四子接口——`IBytesObjectSerializer`/`IBytesStringSerializer`（byte[] 通道 + `serializeAsBase64/deserializeByBase64`）与 `IStringObjectSerializer`/`IStringTypeSerializer`（String 通道），叠加领域契约 `IJsonSerializer`（+`map2Bean/bean2Map`）与 `IXmlSerializer`（标记组合）及 `asStringSerializer()/asBytesSerializer()` + 双向镜像适配器（默认 UTF-8）互桥；`SerializeException`（extends `CodecException`）与 Json/Xml/FormatText 三子异常成族；被 26 模块 77 源文件消费（`IJsonSerializer` 53 处 import 为全仓最大契约面）——AI 栈（`AiAgent` 注入 + MCP 工具参数 `deserializeAsMap` 9 处）、HTTP 网络栈（`HttpProcessorProvider` processor 参数 + `HttpResponse.getContentAsObject`）、SWL 安全传输族、i2f-hash 13 个 HashProvider 字节契约与 jackson/fastjson/fastjson2/gson 适配实现；官方实现下沉 i2f-serialize-impl（Json2 被 17 处实例化为默认 JSON 引擎；Xml2 只写）。⚠ 探针实证：双向适配器 null 输入抛 `SerializeException(msg=null,cause=NPE)`（15 断言 3 失败）、`deserialize(enc,clazz)` 默认静默忽略类型参数返回未转换结果、`bean2Map` 默认拒绝/`map2Bean` 默认无转换、`XmlSerializeException` 全仓零抛出的死类等 10 条瑕疵——详见文档。

- 详细文档：[i2f-serialize-std](./i2f-jdk/i2f-serialize-std/readme.md)

### i2f-sm-crypto

> **纯 Java 国密算法实现库**（SM2 / SM3 / SM4 三算法全自研，25 个类型约 2565 行 + 384 行测试 + 8 个内嵌 JS 参考文件约 1340 行）：JS 库 `sm-crypto`（antherd/JuneAndGreen 版，基于 jsbn）的等价 Java 移植——提供 SM2 加解密（C1C3C2/C1C2C3）、SM2 签名验签（裸 r‖s / ASN.1 DER、可开关 ZA 杂凑）、SM3 杂凑与 HMAC-SM3、SM4 分组密码（ECB/CBC、PKCS#5/PKCS#7），零密码学三方依赖（仅编译期 `provided` 引 antherd sm-crypto 做测试对照 + nashorn-core 补 Java15+ JS 引擎）；三层结构 `ec`（射影坐标椭圆曲线，3k 窗口乘法）→ `sm2/sm3/sm4`（算法核心）→ `std`（i2f-crypto-std 契约适配三件套），被 `i2f-sm-crypto-swl`（SWL 安全传输族 3 类 + 3 Supplier）与 `i2f-springboot-ops-starter`（OpsSecureTransfer 仅用 `Sm4.generateHexKey`）消费、随 `i2f-jdk-all` 聚合发布；算法本体经标准向量验证（SM3 `abc`/64×`abcd`、SM4 单块 `681edf34...` 均通过，DER/C1C2C3/hash 往返自洽）。⚠ 探针实证（18 通过 / 2 失败 / 11 观察）**严重安全缺陷**：`Sm2Cipher.boostKeyPair` 静态缓存的 k 进程级永久复用——同明文两次加密密文完全相同、密钥流复用可提取明文差异、**两条签名即可恢复私钥**（实测 match=true）；另有 `verify(byte[])` 签名参数错用为 data 恒失败/抛异常、ZA 杂凑 ENTL 小端与 GB/T 32918 及 JS 版不一致、`doEncrypt(byte[])` 就地篡改入参、std 适配层 UTF-8 String 往返损坏非 UTF-8 二进制、`Sm3Digester.digest(byte[])` 返回 64 字节 hex-ASCII 而非 32 字节摘要等 9 组瑕疵——生产环境使用前务必修复，详见文档。

- 详细文档：[i2f-sm-crypto](./i2f-jdk/i2f-sm-crypto/readme.md)

### i2f-sm-crypto-swl

> **SWL 安全传输协议族的纯 Java 国密适配层**（6 源文件约 217 行、2 包、零算法实现、无 src/test、lombok 声明未用）：以适配器模式把 i2f-sm-crypto 的 std 三件套包装为 i2f-swl-std 三大契约（`SwlSmCryptoSm2AsymmetricEncryptor`→`ISwlAsymmetricEncryptor`、`SwlSmCryptoSm4SymmetricEncryptor`→`ISwlSymmetricEncryptor`、`SwlSmCryptoSm3MessageDigester`→`ISwlMessageDigester`）+ 3 个 Supplier 工厂（供 SwlExchanger 的 ObjectPool 池化 require/release），成为 SWL「JDK 默认 / 国密 / BouncyCastle」三套可互换实现中的国密一极；POM 被 2 个 Starter 内置（springboot-swl-starter:57-60、gateway-swl-starter:49-52，均非 optional）并随 i2f-jdk-all 聚合发布（jdk-all:523-526），全仓 0 处 Java import 消费（对照模块自身 6 文件）——实际激活依赖 `i2f.swl.web.*-algo-class` 配置类名 + ReflectResolver 反射实例化，当前仓库未启用；SM2/SM4/SM3 出/入参均 hex（SM2 密文分组实际 C1C3C2、签名裸 r‖s 不启用 ZA；SM4 默认 ECB/PKCS7；SM3 摘要 64 字符 hex 忽略大小写），不提供 ISwlObfuscator（沿用默认 Base64）。⚠ 瑕疵：算法底座继承 i2f-sm-crypto 的 SM2 boost keypair k 进程级复用严重安全缺陷（同明文同密文、两条签名可恢复私钥，生产使用前必须修复上游）、`generateKeyPair()` 与 SM3 digest/verify 异常未包装 SwlException（IllegalStateException 泄漏、DIGEST_* 段码零使用）、`cipherMode` 死字段（宣称 C1C2C3 实际默认 C1C3C2）、SM4 generateKey 失败误用 SYMMETRIC_INVALID_KEY_EXCEPTION(2300)、零测试 + 配置类名拼错仅运行期暴露（被兜底为 SwlException 2000）——详见文档。

- 详细文档：[i2f-sm-crypto-swl](./i2f-jdk/i2f-sm-crypto-swl/readme.md)

### i2f-std-const

> **全仓统一的「运行时目录约定」常量词汇表**（全模块仅 1 个常量接口 `StdConst`、12 行、3 个常量、零运行期依赖，lombok 声明未用）：以 `RUNTIME_BASE_DIR`（`runtime`）为组合根派生两大类运行时目录——`RUNTIME_PERSIST_DIR`（`runtime/persist`，跨次保留的持久资产：模型/词典/证书/驱动/向量库）与 `RUNTIME_TMP_DIR`（`runtime/tmp`，可随时清理的临时产物：编译中间物/下载中转/TTS 音频），均为相对路径（相对 JVM 工作目录 CWD），消费方自行拼 `./` 前缀并负责建目录；被 **14 模块 17 源文件 31 处**消费（PERSIST 27 处 / TMP 4 处 / BASE 0 处直接引用）——扩展族 AI-RAG/Vosk/Selenium/Tesseract/OpenCV/TTS（模型与数据落盘）、JDK 族 compiler（内存编译产物）/swl（证书）/translate（SQLite 词典）、ops-starter（TTS 音频）与 face-recognizer；工作区实证 `i2f-tools-ops/runtime/` 完整落地划分（persist 存 sqlite-vec.db 与驱动 exe，tmp 存驱动下载 zip 与 tts 音频）；13 模块 POM 显式声明依赖（`browser-playwright` 声明未用），随 `i2f-jdk-all` 聚合发布。⚠ 低危瑕疵：常量接口反模式、三常量无 javadoc（persist/tmp 取舍标准无文字约定）、目录名硬编码无外部化配置、消费方 `./` 拼接风格分裂（27 带 4 不带）、根 .gitignore 无 runtime 条目忽略策略分散——详见文档。

- 详细文档：[i2f-std-const](./i2f-jdk/i2f-std-const/readme.md)

### i2f-streaming

> **函数式流式处理框架 / JDK8 从零实现的类 Stream 惰性管道**（43 源文件约 6258 行、**零 Maven 依赖纯 JDK8**、无 src/test 测试目录）：核心为接口 `Streaming<E>`（772 行、百余个方法：19 个静态数据源工厂 + 90 余个算子/default 方法）与唯一实现 `StreamingImpl`（2627 行 god class）。机制特色：① `Reference` 四态协议（NORMAL/EMPTY/NOP/FINISH：有值/空值/本次无产出/结束）+ 9 类迭代器工具箱（Lazy/Supplier/SupplierBuffer/Generator/Resources/Merge/Mixed/Connect/Mapper）；② 并行模型 `parallel()/pool()/parallelism()`——`delegateParallelism` 逐元素提交 + 自研 `AtomicCountDownLatch` 窗口限流 + `GeneratorIterator` 阻塞队列汇集（顺序不保证）；③ rich 上下文注入（`RichStreamProcessor` + 6 个 Rich 抽象函数类：local/global context 与 pool 注入算子、Closeable 自动关闭）；④ 五大元素窗口（view/slide/count/condition/patten）统一 waitList 实现 + `StreamingPatten` 单链表模式 DSL（repeat/repeats/follow/any）+ `timed` 子流（`timeOrdered` TreeMap 乱序容忍、slide/session/view 时间窗、lately*Time）；⑤ `StringStreaming` 字符串子流、`NamingForkJoinPool` 命名池、`DecimalIndex` 数值指标。**当前全仓零消费方**（`import i2f.streaming` 全仓 0 命中，对照 i2f-io-file 42 处验证），仅随 `i2f-jdk-all` 聚合发布（根 POM dependencyManagement:774-778 + jdk-all:539-542）。⚠ 瑕疵：`limit(count)` 计数未自增实际不截断（StreamingImpl:766-783）、`globalContext` 自赋值致跨算子共享失效（:62）、`LifeCycleRunnable/Callable` 异常赋错字段 isThrowable 恒 false、`AtomicCountDownLatch.await` 1ms 忙等待无超时、`NamingForkJoinPool` 反射 JDK 私有 API（JDK9+ 静默回退丢线程名）、`GeneratorIterator` 裸线程无关闭、零测试 + `TestStreaming` 硬编码本机绝对路径且随 jar 发布、调试 println 残留等——详见文档。

- 详细文档：[i2f-streaming](./i2f-jdk/i2f-streaming/readme.md)

### i2f-swl

> **SWL（Secure Wire Layer）安全网络层的默认实现层与协议引擎**（30 源文件 2100 行 + 内嵌 299 行设计文档，11 包）：无状态 `SwlExchanger`（491 行：「时间戳窗口 → nonce 防重放 → 摘要签名 → 非对称数字签名 → 双加密」收发流水线 + 3 个 `ObjectPool` 池化密码器）→ 有状态 `SwlTransfer`（181 行，certId→`SwlCert` TTL 会话缓存 + swap 交换密钥）→ `SwlCertExchanger`（82 行，桥接 `SwlCertManager` 内存/缓存/资源三实现）；配套 JDK 四件密码学实现（RSA 2048 / AES-128 / SHA-256 / Base64 混淆 + 3 Supplier）、证书链（`SwlCert`/`SwlCertPair`/`SwlCertUtil` Base64 行式序列化）、防重放器（`SwlNonceManager` Empty/ExpireCache）、数据模型四件套（`SwlHeader`/`SwlData`/`SwlContext` 19 字段诊断/`SwlDto`）与 2021 遗留 `SwlCtrl` 注解；每请求一次性对称密钥经对端公钥保护，五道校验固定顺序。被 **6 模块 115 处 import** 消费（自身 60、springboot/springcloud 两 swl-starter 14/13、extension-swl 13 测试、spring-swl 12、jdk-ext-swl 3）、`new SwlTransfer` 全仓 14 处、POM 直接依赖 5 模块，随 `i2f-jdk-all` 发布（注：菜单序按 POM 声明，i2f-swl 位于 i2f-streaming 之后、i2f-swl-std 之前）。⚠ 瑕疵：`SwlTransfer.removeCert` 永不删除（L106-114 存在即提前 return）、`sendByRaw`/`receiveByRaw` 池化 require/release 无 try/finally 异常即泄漏、L273 归还摘要器后 L280 复用、畸形 timestamp 抛未包装 `NumberFormatException`、源码硬编码默认交换私钥（`SwlTransferConfig` L21-27）、内嵌 readme 与实现三处不一致（sign 含 clientPublicKey / receive 重置 TTL / nonce 用 uuid）、AES 失败误抛非对称码 1100、消费方实证 `SwlWebFilter.java:369` `"$." + responseBody` 笔误（对照同作者 `SwlGatewayFilter.java:479` 的 `"$." + responseText`）、extension-swl 4 个测试类全脱节旧 API 等——详见文档。

- 详细文档：[i2f-swl](./i2f-jdk/i2f-swl/readme.md)

### i2f-swl-std

> **SWL（Secure Wire Layer）安全传输协议族的纯契约层 / 密码学 SPI 标准**（9 源文件 213 行、零实现零状态、无 src/test 测试目录，唯一实际依赖 i2f-crypto-std 的 `AsymKeyPair` 数据类，lombok 声明未用）：4 个能力接口（`ISwlAsymmetricEncryptor` 11 方法：密钥对/加解密/签名验签；`ISwlSymmetricEncryptor` 5 方法：密钥生成/加解密；`ISwlMessageDigester` 摘要与校验；`ISwlObfuscator` 混淆编解码）+ 3 个 Supplier 类型别名接口（`ObjectPool` 池化用的类型化无参工厂）+ 36 常量 `SwlCode` 错误码枚举（0~10000 共 11 个十进制段位：非对称/对称/摘要/nonce 防重放/签名/随机密钥/客户端密钥/服务端密钥/数字签名/证书）+ 携带 int code 的 `SwlException`；为**三套可互换密码学实现**提供依赖倒置契约——i2f-swl（JDK RSA/AES/SHA-256/Base64）、i2f-sm-crypto-swl（纯 Java 国密 SM2/SM3/SM4）、i2f-extension-swl（BouncyCastle 六件套 + antherd 三件套），协议引擎 `SwlExchanger`/`SwlTransfer` 以 `ObjectPool` 池化组织 Supplier 工厂，jdk-ext/spring/springboot/springcloud 四层 Web 集成栈统一消费。被 **6 模块 115 处 import** 消费（i2f-extension-swl 43、i2f-swl 27、springboot/springcloud 两个 swl-starter 各 15、i2f-sm-crypto-swl 13、i2f-jdk-ext-swl 2）、**74 处** 抛出 `SwlException`、POM 直接依赖 3 处（swl/sm-crypto-swl/extension-swl），随 `i2f-jdk-all` 聚合发布。⚠ 瑕疵：`DIGITAL_MISSING_EXCEPTION` 与 `DIGITAL_VERIFY_FAILURE_EXCEPTION` 码值重复（均 9100，SwlCode.java:50-51）致按码反查后者不可达（springboot 的 SwlExceptionHandler.java:33-40 反查实证）、36 常量中 12 个全仓零引用、枚举缺 `of(int code)` 反查方法、四大接口零 javadoc（参数顺序/编码格式/密钥状态语义无约定）、`SwlException` 无 serialVersionUID、`SYMMETRIC_EXCEPTION` 被集成层当通用兜底码 9 处、i2f-swl 的 AES 实现对称失败误抛 1100 非对称码等——详见文档。

- 详细文档：[i2f-swl-std](./i2f-jdk/i2f-swl-std/readme.md)

### i2f-template-render

> **基于正则表达式的轻量级文本模板渲染引擎 / 纯 JDK 实现的「控制表达式」模板**（15 源文件 2441 行、5 包、零测试零资源，依赖 i2f-reflect/i2f-io-file/i2f-os/i2f-tuple-impl 内部四件）：两阶段渲染管线——`RegexGenerator.render` 先扫描 `#{[action,route],k="v"}` 控制表达式实例化 `IGenerate` 策略对象（core/impl 下 9 个实现）并以 `${_xxx_tmp_N}` 占位符注入参数，再统一经 `generate` 扫描 `${route}` 取值交 `ObjectFinder`（`Visitor` 路由 + `@类.方法` 引用转换 + `class`/`instanceof` 关键字）与 `DefaultValueMapper`（类型分派 + `IGenerate.gen()` 递归回渲染入口）输出；11 种动作 for/fori/if/tpl/include/val/fmt/datefmt/trim/define/cmd（cmd 经 `OsUtil.runCmd` 执行命令、tpl 默认 `FileTemplateLoader` 加载 classpath/文件模板）、上下文 `_item`/`_root`/`_ctx`（first/last/index，fori 增 i/fmti）/`_tpl`/`_def`、条件支持 ==/!=/>/</>=/<=/instanceof/match 与 `&&`/`||`（无括号优先级、两侧须空格）、路由支持 `[i]` 下标与 `@方法` 转换链。**当前全仓零消费方**（模块外 import 0 处；仅 i2f-jdk-all:551-554 聚合 + 根 POM:789-793 版本管理）。⚠ 瑕疵：非法 test 表达式空栈 pop 抛 EmptyStackException（IfGenerate:165）、test 的 true/false 字面量不支持（与 Javadoc 矛盾，null 系 Map 取值副作用）、FmtGenerate/CmdGenerate 缺参 NPE、cmd 的 show=false 不执行且异常静默、ForiGenerate format 空串误判 scondition 且无死循环保护、basePackages 就地 add(0) 致循环渲染列表膨胀、依赖上游缺陷（非 List 的 Iterable `${x[0]}` 强转崩溃、loadClass 前缀拼写错误、Bean 未知属性抛异常、classpath 模板 JAR/中文路径不可用）——详见文档。

- 详细文档：[i2f-template-render](./i2f-jdk/i2f-template-render/readme.md)

### i2f-text

> **通用文本/字符串工具库 / i2f 生态内引用最广的基础模块之一**（6 源文件 2324 行、2 包、零测试零资源，无任何三方依赖，仅实际使用 i2f-iterator）：六类分工——`StringUtils`（800 行，主力）判空/24 种不可见字符清洗/裁剪/命名风格转换（Camel/Pascal/UnderScore/Snake/Property/Path/Colon）/前后缀判定与「保证」/合并切分/文件名与扩展名（含点后缀）/子串定位/嵌套对象与异常堆栈可读化/字符集转换；`Appender`（947 行）泛型链式拼装 DSL（条件/循环/迭代器族/Map/格式化/字节序列/空白快捷）；`CnNumber`（260 行）数字 → 中文简繁/金额读法（万进制 4 位分组 + 简繁双表，完整读法不省略）；`Escapes`（188 行）泛型转义算法 + C 风格 8 组转义表；`CompressStringUtil`（89 行）连续重复字符 RLE 压缩（1-9/A-E/[hex] 三档计数）；`SensibleStringUtil`（40 行）星号脱敏。**消费规模为全仓第一梯队**：19 模块 36 文件真实 import 且**涉及类仅 `StringUtils`**（`isEmpty` 158 处 > `toUnderScore` 10 > `hasText`/`getFileExtension` 各 4），其余 5 类（含 947 行的 `Appender`）模块外零引用；POM 侧 15 个模块直接声明依赖本模块（其中 4 个声明未用：freemarker/velocity/firewall/io-filesystem）、另有 8 个消费方未声明（经传递依赖，关系隐性化），本模块自身声明的 `i2f-match` 亦零引用。⚠ 瑕疵：`trimRight` 索引从不更新完全失效、`ensureStartsWith`/`ensureEndsWith` 的 ignoreCase 分支误用 `str` 比较（后者还以 `startsWith` 判尾致重复追加后缀）、`Appender.$trim` 的 `trimSuffixes` 误用 `startsWith` 致错误截尾、`addMap` 的 close 在遍历前写入、`addsFullMap` 静默丢弃 mapper、`Escapes.escape` 末尾匹配 off-by-one 使串尾转义不生效、`convertCharset` 不可映射字符静默丢弃、`firstUpper("")`/`getFileNameOnly(null)` 越界等——详见文档。

- 详细文档：[i2f-text](./i2f-jdk/i2f-text/readme.md)

### i2f-thread

> **纯 JDK 并发编程工具箱 / 并行执行、跨线程通信、动态线程池、DAG 编排、命名线程的一站式基础设施**（18 源文件 1787 行、7 包、无 src/test 无 resources（3 个演示 main 类位于 src/main）、仅依赖 lombok + i2f-tuple-impl）：九类能力——`Asyncs`（269 行）并行求值门面（共享 ForkJoinPool、`async(Supplier…)` 索引化 Map、1~10 元组 `promise`）；`AsyncMessageAwaiter`（231 行）跨线程异步等待（async/then/await + NullRef 哨兵 + 15 分钟超时清理、Closeable）；`AsyncQueue`（87 行）异步串行队列（poll+指数退避消费）；`DynamicThreadPool`（315 行、模块最大类）CPU 利用率反馈动态池（10s 采样窗口、任务超 1s 扩线、概率 yield 退避、空闲 30s±30% 自退补线）；`ProcessTaskRunner`（139 行）PV 操作 DAG 编排（入度 await → 执行 → 出度 countDown）；`ParallelismDispatcher`（74 行）并发窗口调度；ForkJoin 工具族 `ForkJoinUtil`/`ForkJoinAtomicBlocker`/`NamingForkJoinPool`（反射命名池）；`NamingThreadFactory`（pool-N-thread-M）；协作原语 `LatchRunnable`/`AtomicCountDownLatch`/`ArgsRunnable`。**消费为全仓最低（1 模块 1 文件 3 调用点）**：仅 `i2f-extension-cron` 的 `CronExecutor`（:60-62）用 `NamingThreadFactory` 命名解析/触发/执行三线程池，`Asyncs`/`AsyncQueue`/`AsyncMessageAwaiter`/`DynamicThreadPool`/`ProcessTaskRunner` 等全部类模块外零引用；test-features 的同名包 `i2f.thread`（DynamicSharedThreadPool/ThreadLocalUtil）系其自建、不依赖本模块；POM 有效声明仅 1 处（cron/pom.xml:20-23，无浪费）；聚合 i2f-jdk-all:559-562、根 POM:799-803；发布产物 4 处 jar。⚠ 瑕疵：`Asyncs.promise` 任一 supplier 抛异常被 LatchRunnable 吞入 thr 致索引缺失——`map.get(idx).orElse(null)` **NPE 且原始异常丢失**（10 个重载全中）；`DynamicThreadPool` **无 shutdown/close**、`poolName` 死字段、`Double.doubleToLongBits` 位模式当整数累加统计 bug、CPU 采样「窗口增量÷线程寿命」口径混合；`ProcessTaskRunner.call()` **提交即返回空 map**（异步填充、须自行等待）、无环检测、异常静默；`ParallelismDispatcher` `parallel<=0` 时 **30ms 空转死循环**；`AsyncQueue`/`AtomicCountDownLatch` 忙轮询（poll+sleep 替代 take、sleep(1) 自旋）、线程非守护且无停止入口；`NamingForkJoinPool` 全反射失败全静默退回无命名池——详见文档。

- 详细文档：[i2f-thread](./i2f-jdk/i2f-thread/readme.md)

### i2f-trace

> **调用点感知基础设施 / 基于线程栈回溯的「谁在调用我、我在哪」定位工具**（2 源文件 374 行、2 包 `i2f.trace` + `i2f.trace.test`、零测试零资源、**零依赖**——pom 无任何 `<dependencies>`，纯 JDK 反射+集合实现）：核心类 `ThreadTrace`（284 行、全静态无状态）两大能力——①栈切片：`beforeTrace`（自栈底找最外层同类帧，剥离框架内部帧取用户调用点）、`lastTrace`/`last`（取最内层连续同类帧的下一帧 = 直接调用方）、`currentTrace`/`current`（自身类名快捷切片）；②调用点反射还原：`currentClassName`/`currentMethodName`/`currentFileName`/`currentLineNumber`/`currentLocation`、`currentClass`（类名 → Class，Class.forName + 上下文 ClassLoader 双兜底）、`currentMethod`/`currentSingletonMethod`（+ `getMethods`/`isSameType`/`argsMatchTypes`，8 组原语-包装双向匹配）；另有演示类 `TestFunctional`（90 行，位于 main 源码树）。**消费小而精准（全部属于日志体系）**：3 模块 4 文件 6 调用点——i2f-log-std（无参 `getLogger()` 以调用者类/方法名建 logger、LogUtil 采集源码位置）、i2f-extension-slf4j（Slf4jUtil 调用者标签 ×3）、i2f-log（StdoutRedirectPrintStream 回环阻断；**POM 未声明、经 i2f-log-std 传递**）；POM 有效声明仅 2 处且均被真实使用（无声明浪费）；聚合 i2f-jdk-all:563-566、根 POM:804-808；同目录的 `i2f-trace-mdc` 为**平行模块**（traceId/MDC 跨线程传递），不依赖也不消费本模块。⚠ 瑕疵：`currentMethod` **重载消歧不可靠**（int/Integer 经双向映射同时命中 + `getDeclaredMethods()` 顺序未定义）、**可变参数方法恒不匹配**、null 实参无法消歧、**未命中类名时静默回退「仅栈底帧」**（LogUtil 对 ILogger default 方法栈帧的依赖系跨模块隐式契约，ILogger 去 default 化即行号采集静默失效）、`lastTrace` 交错同名帧处理不完整、lambda/动态代理 `findClass` 返回 null、i2f-log 依赖未声明且自行内联等价栈回溯（重复实现）——详见文档。

- 详细文档：[i2f-trace](./i2f-jdk/i2f-trace/readme.md)

### i2f-trace-mdc

> **MDC（Mapped Diagnostic Context）上下文容器与跨线程传播基础设施 / 日志链路 traceId 统一存取门面**（11 源文件 739 行、4 包 `i2f.trace.mdc`/`.manager`/`.manager.impl`/`.thread`、零测试零资源、**零依赖**——pom 无任何 `<dependencies>`，纯 JDK ThreadLocal + 并发包）：静态门面 `MdcHolder`（119 行）三级选择存储实现——系统属性 `mdc.manager` 指定类 → ServiceLoader SPI（类名含 slf4j > log4j > 第一个）→ 内置 `DefaultMdcManager`（InheritableThreadLocal + 静态 ReentrantReadWriteLock）；`MdcManager` 六操作接口（put/get/remove/clear/copyOf/replaceAs）；`MdcTraces` 5 标准键（traceId/traceSource/traceUrl/traceIp/traceApp）+ 2 组 × 6 HTTP Header 变体 + UUID 32 位 hex traceId；thread 包（7 文件 450 行）完整线程传播族——`MdcRunnable`/`MdcCallable` 构造时快照捕获、finally 清理、`ofNewTrace` 新链路；`MdcThread`/`MdcThreadFactory`/`MdcExecutor`/`MdcExecutorService`/`MdcScheduledExecutorService` 装饰器（周期任务自动新链路、of() 幂等）。**消费围绕日志链路（4 模块 13 文件 71 行调用点 / 123 次符号引用 + 1 SPI 实现）**：i2f-extension-slf4j 的 `Slf4jMdcManager` 写穿 org.slf4j.MDC（META-INF/services 注册，「引入扩展即自动接管」）；i2f-springboot-trace-mdc-starter（9 文件 67 行）全场景入链注入/出链清理/请求头透传（WebFilter 17、GatewayFilter 12 最多）；i2f-log-std 的 LogUtil 落盘 traceId；i2f-extension-slf4j-log（test）经 i2f-log → i2f-log-std 传递消费（POM 未声明）。POM 有效声明 3 处均真实使用无浪费；聚合 i2f-jdk-all:567-570、根 POM:809-813；与同目录 `i2f-trace`（调用栈定位）双向零依赖、平行模块。⚠ 瑕疵：LOCAL 为**原生 InheritableThreadLocal（未覆写 childValue）**——父子线程共享同一 HashMap 引用，子线程写入反向污染父线程（MdcThread + ofNewTrace 改写父 traceId）；MdcRunnable/MdcCallable finally **无条件全量 clear()**（slf4j 下 MDC.clear() 清光所有键、嵌套执行破坏外层上下文）；`ofNewTrace`/`of(…, true)` 对已包装实例**二次包装**——内层旧 traceId 覆盖外层新值使 newTrace 失效；MdcHolder 加载失败**全静默**（mdc.manager 配错无提示、SPI 坏 provider 抛 ServiceConfigurationError 中断类初始化）；MdcManager 零 Javadoc 且两实现 null 契约不一致（copyOf 空返回空 map vs null）、`clear()` 用 set(null) 非 remove()、装饰器无 unwrap 通道——详见文档。

- 详细文档：[i2f-trace-mdc](./i2f-jdk/i2f-trace-mdc/readme.md)

### i2f-translate

> **翻译器系列的「契约层 + 基础转换器」基础设施——「ITranslator 统一接口 + 全角/半角双向映射表 + 声调→ASCII 表」**（6 源文件 175 行、2 包 `i2f.translate` + `.impl`、零测试零资源、**2 依赖**——lombok（声明零使用）+ i2f-lifecycle）：`ITranslator`（11 行）契约接口（`translate(String)` + extends `ILifeCycle`）；3 个**无状态纯函数转换器**（单例 `INSTANCE`）——`FullWidth2HalfWidthTranslator`（全角→半角：ASCII 直通 + 111 键表）、`HalfWidth2FullWidthTranslator`（半角→全角：95 键反转表，**零外部消费**）、`ZhTone2AsciiTranslator`（声调→ASCII：20 键）；2 个映射 Provider——`FullAndHalfProvider`（EN 95 对〔含 IPA `ɡ` U+0261→g〕+ ZH 35 对中文标点〔全角空格、·、￥、…、×、—、【】、‘’“”、。、《》 等〕拼接、19 重叠合并 → full2halfMap 111 键、half2fullMap 95 键反转派生）、`ZhToneProvider`（āáǎà→aaaa 等 20 对）。**消费：2 模块 6 文件 24 处行级引用（低消费但关键）**——i2f-translate-zh2pinyin 以 `ITranslator` 契约 + `FullWidth2HalfWidthTranslator.INSTANCE`/`ZhTone2AsciiTranslator.INSTANCE` 做拼音规范化与去声调（Zh2PinyinTranslator.java:42/44）、i2f-translate-en2zh 实现 `ITranslator`；`ITranslator` 共 7 实现类分布 3 模块；POM 2 处声明均真实使用；聚合 i2f-jdk-all:571-574、根 POM:814-818、模块清单:156。⚠ 瑕疵：`half2fullMap` **反转非双射**——111 全角键 → 95 半角值，`'`/`"` 各 3 候选（＇‘’/＂“”）、`g`/`_`/`^`/`*`/`$`/`[`/`]`/反引号/`.`/`/`/`<`/`>` 各 2 候选（共 14 字符），半→全产出**由 HashMap 迭代序决定**；ZH 映射激进（`…→^`、`×→*`、`—→_`、`、→/`、`。→.`——语义信息损失）；声调表缺 ü 系（ǖǘǚǜ）；`ZhTone2Ascii` 无 ASCII 快路径 + `ch+""` 每字符新建 String；lombok 声明零使用；`ITranslator` 零 Javadoc；零测试——详见文档。

- 详细文档：[i2f-translate](./i2f-jdk/i2f-translate/readme.md)

### i2f-translate-en2zh

> **英文标识符→中文注释的「行业词典优先」翻译器——「正则逐词替换 + 标识符启发式还原 + 内置 SQLite FTS3 词典 + 首用自动释放」**（3 源文件 416 行、3 子包 data/impl/test、1 资源 zip 6.6MB 内含 16.7MB FTS3 词典库（五列 id/word/book_id/trans_pos/trans_cn）、零测试——演示类位于 main 源码树）：`SimpleWordTranslator`（296 行）核心——`RegexUtil.regexFindAndReplace("[a-zA-Z]+('s)?")` 逐英文词翻译（非英文部分原样保留）；`translateLetters` 预处理链（去 `'s` → `toForceCamel` 缩写规范化（XMLParser→xmlParser）→ `toUnderScore` 蛇形 → `split("_|-")` 分段）；`translateSingleWord` 候选序列（原词 + 剥 ing/ed/fy/ion/able/or/er/ies/es/ly/cs 后缀 + 截尾至半长）+ **BQL 十档权重查询**（software 词典 200/199 > computer 100/99 > 通用 10/9/8 > 前缀模糊 7/6/5；名词优先、`snum desc` 短词优先、limit 1 命中即止）；实例级 `priorWordTranslateMap` 自定义优先词典 + 双静态 `LruMap`（16k 段级/8k 整词级）缓存；词典首用释放至 `./runtime/persist/database/translate_en2zh.db`（`ResourceUtil`+`StreamUtil`+`ZipJdkCompressor`+`JdbcResolver`，同 zh2pinyin 模式）；`ILifeCycle` 管连接（create 幂等重建、translate 检测关闭自动重建）。**消费现状：Java 层全仓零消费**——唯一外部引用为 `i2f-extension-reverse-engineer-generator` 的 `tpl/readme.md` 文档模板（6 处：systemPath 引 jar/import/实例化/prior 词典/表列注释翻译示范——反向工程生成器的推荐集成示例）；POM 无消费方声明（聚合 i2f-jdk-all:575-578、根 POM:819-823、模块清单:157）。⚠ 瑕疵：**隐性依赖八连**（i2f-bql/i2f-jdbc-impl/i2f-io-stream/i2f-lru-map/i2f-match/i2f-text/i2f-annotations-db/i2f-database-metadata-bean 未声明、靠 i2f-jdbc-bql 与 i2f-resources→i2f-io-stream 传递链）；**`fastLetterCacheMap` 缓存读写键不一致**（put 蛇形变形键 vs get 原样键——含大写输入重复翻译永不命中该层）；查询 `SQLException` 空 catch 静默 + 「解压静默→SQLite 空库自动建档→查询静默」三层链（校验失效时输出无报错）；`sqlite-jdbc` provided+optional（无静态块、调用期可重试异常）；`TranslateEn2ZhDom` 死代码且缺 `book_id` 列；后缀 `"cs"` 疑笔误；`translate` 未同步（destroy 并发窗口 NPE）+ `translateSingleWord` `synchronized` 段级串行；`@Data` 暴露 `getConn()`/`getTemplate()`；零测试、演示类硬编码仓库相对路径——详见文档。

- 详细文档：[i2f-translate-en2zh](./i2f-jdk/i2f-translate-en2zh/readme.md)

### i2f-translate-zh2pinyin

> **中文→拼音 / 简繁双向转换的零配置翻译器——「ITranslator 三实现 + 内置 SQLite FTS3 词典 + 首用自动释放」**（6 源文件 369 行、3 子包 `data`/`impl`/`test`、1 资源 zip 431KB 内含 1.4MB FTS3 词典库、零测试——演示类位于 main 源码树）：`ITranslator` 三实现共享静态单例词典——`Zh2PinyinTranslator`（逐字查表转拼音，`keepTone` 双模式：保留声调符 ǎ 或经 `ZhTone2AsciiTranslator` 转纯 ASCII）、`Zh2SimTranslator`（繁体→简体，取 `word`）、`Zh2TraTranslator`（简体→繁体，取 `old_word`）；`PinyinProvider.PROVIDER` 静态块自动 `create()`——首用从 classpath 释放词典 zip（`ResourceUtil` + `ZipJdkCompressor.release` → `./runtime/persist/database/translate_zh2pinyin.db`）→ `JdbcResolver` 建 SQLite 连接 → `BqlTemplate.find`（`word=? or old_word=? limit 1` + `toCamel` 列映射）→ 8192 容量静态 `LruMap` 缓存；`Zh2PinyinVo`（word/oldWord/strokeNum/pinYin/radicals）；`ILifeCycle` 管理连接。**消费现状：全仓零消费（0 模块 0 文件 0 调用点）**——grep/PowerShell 全仓/非 Java 三路均无源码引用，POM 也无任何模块声明依赖（纯「能力先行、待落地」模块）；反向作为消费方被 7 处上游 readme 记录（compress-impl/jdbc-bql/jdbc-impl/lifecycle/resources/std-const/text）。⚠ 瑕疵：**隐性依赖五连**（i2f-bql/i2f-jdbc-impl/i2f-io-stream/i2f-lru-map/i2f-text 均未在 POM 声明、经 `i2f-jdbc-bql → i2f-bql` 传递）；**sqlite-jdbc provided+optional**——运行期缺驱动即静态块初始化失败且不可恢复（类永久 erroneous、`NoClassDefFoundError` 无重试）；**「解压→建库→查询」三层静默失效链**（解压 printStackTrace 静默 → SQLite 空库自动建档 → 查询 SQLException 空 catch 吞掉，翻译全量原样输出而无报错）；`getWordInfo` `synchronized`（缓存命中亦串行）+ 无负缓存；`LruMap` 名义 LRU 实为插入序 FIFO；`destroy()` 后再用即 NPE；逐字符转换多音字上下文无关；FTS3 仅当普通存储（MATCH 闲置）、strokeNum/radicals 闲置——详见文档。

- 详细文档：[i2f-translate-zh2pinyin](./i2f-jdk/i2f-translate-zh2pinyin/readme.md)

## i2f-jdk-ext

> 基于 javax.servlet 规范的 Web 层扩展模块集合,提供安全过滤器矩阵、Web 防火墙、失败锁定守卫与 Servlet 上下文 / 文件 / 包装器基础设施。

### i2f-jdk-ext-web

> **Servlet 层 Web 增强套件 / 安全过滤 + 防火墙 + 守卫 + 上下文与包装器的一站式横切能力层**(24 源文件约 3680 行、5 包 `i2f.web.filter` `.firewall`(context/exception/util/wrapper)`.guarder` `.servlet` `.wrapper`、零测试零资源、8 依赖 = 6 内部(i2f-network/io-stream/io-file/serialize-impl/cache/firewall)+ lombok + `javax.servlet-api`(provided+optional)):①`filter` 过滤器矩阵——抽象骨架 `OncePerHttpServletFilter`(attribute 防二次执行)、`SecurityFilter`(1428 行,方法/Content-Type/不可见字符/SQL 注入/远程调用/路径穿越/文件访问/命令注入/多编码变体检测 + IP/Origin/Referer 白名单 + body 缓存检查,违规 403;spring-starter `i2f.security.filter.*` 近 80 项配置)、`TraceFilter`(trace-id 头/参数→ThreadLocal + 钩子)、`MoveAverageProcessTimeStatFilter`(1024 段锁滑窗耗时);②`firewall`——`FirewallFilter`(@WebFilter,FirewallException→400)+ `FirewallContext`(6 静态开关 + 后缀/文件名双黑名单)+ `FirewallUtils`(字符×7 编码×4 字符集交叉断言)+ 请求/响应包装器(构造即预检查)+ 5 类异常;③`guarder`——`ResourcesFailureGuarder` 资源/IP 双维失败计数(默认 5/30 次)+ `IExpireCache` 过期锁定(30 分钟),`LoginGuarder` 登录特化;④`servlet`——`ServletContextHolder`(ThreadLocal 上下文)、`ServletContextUtil`(转发/Token/多级 IP/BaseUrl)、`ServletFileUtil`(Range 断点续传 206、附件下载)、`ServletResponseUtil`(JSON/XML/CORS);⑤`wrapper`——`HttpServletRequestProxyWrapper`(body 全缓存可重复读 + 头/参数可覆写)、`HttpServletResponseProxyWrapper`(响应体缓冲)、字节数组 Servlet 流。消费 7 模块:jdk-ext-swl(SwlWebFilter)、spring-web、springboot spring/security/shiro/ops-starter、spring-authentication。⚠ 瑕疵:`MoveAverageProcessTimeStatFilter` 滑窗淘汰 `addAndGet(lastTime)` 应为减(avgTime 失真);`SecurityFilter` **REMOTE_INVOKE_PATTERNS 误用 SQL_INJECT_REGEXES 编译**、`matchRemoteInvoke` 用 `matches` 全匹配难命中、`isExceedRootPath` 的 `..` 分支 pop 后又 push、`matchIllegalFileAccessFileName` `substring(0,idx)` **取到目录而非文件名**、`isMissingHeadersParameters` 豁免列表为空即跳过必填检查;`FirewallContext` add/remove 集合**语义颠倒**;`HttpServletRequestProxyWrapper` 第二构造器 `this.body = body` **自赋值**;`ByteArrayServletInputStream.isFinished()` 恒 false——详见文档。

- 详细文档：[i2f-jdk-ext-web](./i2f-jdk-ext/i2f-jdk-ext-web/readme.md)

### i2f-jdk-ext-swl

> **SWL（Secure Wire Layer）安全传输协议的 Servlet 过滤器接入层 / 「请求解密 + 响应加密」对业务透明的容器适配底座**（4 源文件 562 行、单包 `i2f.web.swl.filter`、零测试零资源、5 依赖 = 3 内部（i2f-swl 协议引擎 / i2f-form-url-encoded 表单编解码 / i2f-jdk-ext-web 过滤器与包装器基础设施）+ lombok + javax.servlet-api（均 provided+optional））：`SwlWebFilter`（488 行，extends `OncePerHttpServletFilter`）核心流水线——**请求侧** swlh（混淆 SwlHeader）/ swlci（certId）/ swlu（Base64 原始 URL）/ swlp（加密参数）四头取值 + URL 防篡改滑窗校验（剥离 contextPath + 最多 2 段容差剥离 + 尾部匹配）+ `transfer.receive` 解密 + `HttpServletRequestProxyWrapper` 重建可重复读请求（参数 / Content-Type / 长度覆写）；**响应侧** 全量缓冲 + content-disposition 下载白名单（跳过加密防 OOM）+ `transfer.response` 加密 + `$.` 前缀密文 + swlh / swlci / swlct 回写 + `Access-Control-Expose-Headers` 合并去重；`SwlWebCtrl` in/out 双开关（每请求从 defaultCtrl 克隆、携带 swlh 强制 in、multipart 强制关 in）+ `parseCtrl` / `onException` 双钩子 + 6 个 request attribute 属性契约（解密异常暂存后由消费方 AOP 重抛交由 ExceptionHandler）。消费 2 模块：springboot-swl-starter（`SwlSpringWebFilter extends` 实现 @SwlCtrl 注解 + urlPatterns / 白名单 + 返回 String 标记）、springcloud-gateway-swl-starter（WebFlux 668 行同构复制版，保留正确写法）。⚠ 瑕疵：`SwlWebFilter.java:369` `"$." + responseBody` **byte[] 拼接笔误**（对照 SwlGatewayFilter.java:479 应为 `"$." + responseText`——响应体变 `$.[B@hash` 垃圾文本、加密计算白费，所有 out 加密响应损坏）；`getCharacterEncoding()` 为 null 时 `new String(bytes, null)` NPE（L169 / L235，被吞为「解密失败」）；`catch (Throwable)` 连 Error 也吞掉放行；响应加密段无异常兜底（直接 500）；`SWL_REQUIRE_ENCRYPT_RESPONSE` 契约断裂（消费方 SwlSpringAop:93 设置、核心从不读取）；urlPatterns / whiteListIn / whiteListOut 三字段核心空转（仅子类消费）——详见文档。

- 详细文档：[i2f-jdk-ext-swl](./i2f-jdk-ext/i2f-jdk-ext-swl/readme.md)

### i2f-jdk-ext-all

> **i2f-jdk-ext 子模块的 Maven 聚合分发包 / 将 i2f-jdk-ext-swl + i2f-jdk-ext-web 打包为单体 fat-jar 的构建入口**（仅 1 个 pom.xml 共 41 行、无 Java 源码、零测试零资源，依赖 2 个内部模块，使用 `maven-assembly-plugin:3.1.0` 以 `jar-with-dependencies` 目标打包，产出含 Manifest 元信息的独立 JAR）。

- 详细文档：[i2f-jdk-ext-all](./i2f-jdk-ext/i2f-jdk-ext-all/readme.md)

## i2f-spring

> Spring 生态集成模块集合，封装 Spring 核心、MVC、安全、Redis、Web 等能力的增强与元数据解析。

### i2f-spring-mvc-metadata

> 基于反射解析 Spring MVC Controller 的 API 元数据，提取 URL、HTTP 方法、参数、返回值与 Swagger 注释，为 API 文档生成提供结构化数据。

- 详细文档：[i2f-spring-mvc-metadata](./i2f-spring/i2f-spring-mvc-metadata/readme.md)

## i2f-extension

> 可选扩展能力集合，按需集成第三方库与增强组件（7z 压缩、AI、文档、数据库反向工程、文件系统、序列化（fastjson1 兼容 + fastjson2 原生）、ANTLR4 语言引擎（脚本/模板/计算器）、Java Agent 字节码增强观测等）。

### i2f-extension-7zip

> 基于 SevenZipJBinding 的 7z 归档压缩器实现，`SevenZCompressor` 落地 `i2f-compress-std` 的 `ICompressor` 契约：复用 `AbsCompressor` 的文件遍历/流绑定骨架，把目录树打包为 `.7z`（可选密码、头加密）或将其解包回目录；sevenzipjbinding 以 `provided` 引入，运行期由使用方提供。

- 详细文档：[i2f-extension-7zip](./i2f-extension/i2f-extension-7zip/readme.md)

### i2f-extension-ai-dashscope

> 阿里云百炼（DashScope）官方 Java SDK 的 `i2f-ai-std` 契约实现：以 `ChatAi`/`RoleChatAi`（+Provider）、`AiModel`（`DashScopeModel` + `DashScopeJsonSerializer`）、`RagEmbeddingModel`/`RagRerankModel` 三组契约对接通义千问对话（qwen-plus）、文本向量化（text-embedding-v4）与重排序（gte-rerank-v2）；`DashScopeAi` 内置 function-calling 自循环（工具执行、同参限流、错误回填），`DashScopeToolHelper` 把 `@Tool` 注解桥接为 DashScope `ToolFunction`；dashscope-sdk-java 以 `provided` + `optional` 引入，运行期由使用方提供。

- 详细文档：[i2f-extension-ai-dashscope](./i2f-extension/i2f-extension-ai-dashscope/readme.md)

### i2f-extension-ai-langchain4j8

> 面向 Java 8 的 langchain4j 0.31.0 版 `i2f-ai-std` 契约实现：以 `ChatAi`/`RoleChatAi`（+Provider）、`AiModel`（`Langchain4j8Model` + `Langchain4j8OpenAiModel` + `Langchain4j8JsonSerializer`）与 RAG 三件套（`RagEmbeddingModel`/`RagEmbeddingStore`/`RagTextSplitter`）复用 langchain4j 原生模型、消息与工具类型对接任意 OpenAI 兼容端点（默认百炼兼容模式 qwen-plus）；`Langchain4j8Ai` 内置 function-calling 自循环（工具执行、同参限流、错误回填），注解解析器在上游 `@Tool` 体系之外追加识别 langchain4j `@Tool`/`@P`（名称覆盖存在缺陷）；langchain4j 与 langchain4j-open-ai 以 `provided` + `optional` 引入，运行期由使用方提供。

- 详细文档：[i2f-extension-ai-langchain4j8](./i2f-extension/i2f-extension-ai-langchain4j8/readme.md)

### i2f-extension-ai-openai

> 官方 OpenAI Java SDK（`com.openai:openai-java` 4.28.0，Kotlin 编译）的 `i2f-ai-std` 契约实现：以 `ChatAi`/`RoleChatAi`（+Provider）、`AiModel`（`OpenAiModel` 内嵌 Builder）、`RagEmbeddingModel`（`OpenAiRagEmbeddingModel`）三组契约对接 OpenAI 官方与任意 OpenAI 兼容端点（默认百炼 compatible-mode + `qwen-plus`）；`OpenAiAi` 内置 function-calling 自循环（工具执行、同参限流、错误回填），`OpenAiToolHelper` 把 `@Tool` 注解桥接为 `ChatCompletionTool`（参数 schema 经 `JsonValue.from` 直通，strict 未透传）；openai-java 与 kotlin-stdlib 均以 `provided` + `optional` 引入，运行期由使用方提供。

- 详细文档：[i2f-extension-ai-openai](./i2f-extension/i2f-extension-ai-openai/readme.md)

### i2f-extension-ai-rag-sqlite

> **sqlite-vec 原生扩展**版的 `i2f-ai-std` RAG 存储层实现（3 源文件 425 行、单包 `i2f.extension.ai.rag.sqlite`、随包携带 `vec0.dll`/`vec0.so` 双平台原生扩展、零测试）：以单库 `RagEmbeddingStore`（`SqliteRagEmbeddingStore`）与分桶记忆 `BucketRagEmbeddingStore`（`SqliteBucketRagMemoryStore`）双契约落地本地嵌入式向量库——vec0 虚拟表（`vector float[1024] distance_metric=cosine`）承载 JSON 文本向量写入与 float32 BLOB 读出（`SqliteVecUtils.jdbcBytes2FloatArray` LITTLE_ENDIAN 解码），KNN 检索（`vector MATCH ? [+ and bucket in (...)] ORDER BY distance LIMIT ?`）距离转 `(2-distance)/2` 相似度；`SqliteVecUtils` 负责原生扩展自举（classpath → `runtime/persist/sqlite-vec/` 释放 + `enableLoadExtension` + `load_extension`）；`sqlite-jdbc` 以 `provided`+`optional` 引入、运行期由使用方提供；唯一消费方 ops-starter（`ai.rags` 双 store bean + `RagDataSourceCollector` 包装 DataSource + `MemoryTools` 记忆工具）。⚠ 三处确定性运行时缺陷（vec0 虚拟表建索引必失败 `virtual tables may not be indexed`、bucket 版 insert 6 列 5 占位 `5 values for 6 columns`、DLL 重复释放被文件锁拒绝）+ Linux 资源名不匹配（`libvec0.so` vs `vec0.so`）——详见文档。

- 详细文档：[i2f-extension-ai-rag-sqlite](./i2f-extension/i2f-extension-ai-rag-sqlite/readme.md)

### i2f-extension-antlr4

> **ANTLR4 语言族（calculator + tinyscript + funic）的 Maven 聚合分发模块 / 将三个 ANTLR4 子模块及其 24 个 i2f-jdk 传递依赖打包为单体 fat-jar 的一站式构建入口**（仅 1 个 pom.xml 共 51 行、无 Java 源码、零测试零资源，三个子模块均 compile 依赖；使用 `maven-assembly-plugin:3.1.0` 以 `jar-with-dependencies` 目标打包，产出 1.07 MB / 733 条目 / 516 类文件的独立 JAR；`i2f-extension-xproc4j` 与 `i2f-springboot-xproc4j-starter` 的统一依赖入口，ANTLR 运行时按 `provided` 约定由使用方自备）。⚠ calculator 子模块主源码缺失致聚合产物无其类文件（jar 中 `FormulaCalculator` 实为 i2f-math 传递依赖所带）、fat-jar 不含 antlr4-runtime（独立 `-cp` 使用需自备）——详见文档。

- 详细文档：[i2f-extension-antlr4](./i2f-extension/i2f-extension-antlr4/readme.md)

### i2f-extension-antlr4-calculator

> **基于 ANTLR4 的计算器表达式解析与求值模块**（仅 1 测试源文件 37 行、主源码与 ANTLR 文法文件缺失、`antlr4-runtime:4.13.2` provided + optional、9 个内部 i2f 依赖）：设计为 `Calculator.eval(String)` → `BigDecimal` 的一步式求值门面——底层通过 ANTLR4 `.g4` 文法生成 `CalculatorParser`/`CalculatorLexer`，`Calculator` 实现类以 Visitor/Listener 模式树遍历求值，支持算术运算符 + 多参数函数调用（如 `avg(4+3,5,6)`）+ BigDecimal 高精度计算。消费方 `i2f-extension-antlr4` 聚合 + `i2f-extension-all` 聚合 + 根 POM。⚠ 主源码完全缺失（src/main/java 为空目录）、POM 未配置 antlr4 代码生成插件、文法文件丢失致 API 合约不可查阅，当前为不可构建的占位模块。

- 详细文档：[i2f-extension-antlr4-calculator](./i2f-extension/i2f-extension-antlr4-calculator/readme.md)

### i2f-extension-antlr4-funic

> **基于 ANTLR4 的「脚本引擎 + 模板引擎」双语言模块（Funic + Funvi）**（82 个 Java 源文件约 2.3 万行：funic 生成代码 6 类约 1.2 万行 + 手写 51 文件约 8000 行，funvi 生成代码 6 类约 1800 行 + 手写 19 文件约 1800 行；文法 `Funic.g4` 586 行 + `Funvi.g4` 86 行、语言手册 `Funic.md` 1382 行 + `Funvi.md` 365 行随包；`antlr4-runtime:4.13.2` provided + optional、9 个内部 i2f 依赖）：Funic 为 TinyScript 的完全重构增强替代品——静态门面 `Funic.script()` 12 重载 + LRU(4096) 语法树缓存 + `FunicResolver` 30 方法扩展点（`DefaultFunicResolver` 1383 行：运算符表/三级全局方法搜索/模板渲染/函数调用链）+ `FunicValue` 值对象体系（18 类）+ 安全双方案（`SandboxFunicResolver` 白名单沙箱 + `SafeFunicResolverProxy` 876 行动态代理黑名单）；语言覆盖渲染字符串 `${}`/`$!{}`、多行字符串、`#{}` 解包、管道 `|>`、lambda、`go`/`<-` 异步、`synchronized`、`func` 函数、`import`、try-catch-finally；Funvi 为轻量模板引擎（`Funvi.render()` 10 重载 + 11 种块处理器 + `BindSqlFunviResolver` `#{}`→`?` 参数化 SQL），`R"..."` 渲染字符串可联动委托 Funvi。消费方 `i2f-extension-xproc4j`（`lang-eval-funic` 节点 + `ProcedureFunicResolver` 等 8 文件）+ springboot starter（`enable-funic` 开关）+ IDEA 插件（.fic/.fvi 双语言一等支持：PSI/高亮/格式化/折叠/补全/断点调试）。**22 项运行时验证：5 通过、17 缺陷实锤**——⚠ `try-catch` 完全失效（`resolved` 死变量致 catch 副作用生效但原异常照抛、catch 体结果丢弃）、错误监听器消息双打印 + 词法异常裸抛 + `e=null` NPE 吞真实语法错误、下划线数字字面量求值必抛 NFE、Funvi `concat` 遇 null 追加值丢弃全部前文、Funvi 默认 `debug=true` 全节点 stdout 日志——详见文档。

- 详细文档：[i2f-extension-antlr4-funic](./i2f-extension/i2f-extension-antlr4-funic/readme.md)

### i2f-extension-antlr4-tinyscript

> **基于 ANTLR4 的嵌入式迷你脚本语言引擎（TinyScript）**（30 主源文件约 1.33 万行：ANTLR4 生成 6 类约 8600 行入库 + 手写求值器 `TinyScriptVisitorImpl` 3129 行；`antlr4-runtime:4.13.2` provided + optional、9 个内部 i2f 依赖）：静态门面 `TinyScript.script()`（File/String/语法树 9 重载）+ LRU(4096) 语法树缓存 + `TinyScriptResolver` 16 方法扩展点（`DefaultTinyScriptResolver` 运算符表/BigDecimal 精度 20/模板渲染）+ 内建方法注册表（String/Math/System/Runtime/TinyScriptFunctions）；语言覆盖模板字符串、`$!{}` null 安全取值、`#{}` 解包、`|>` 管道、JSON 字面量、`func` 自定义函数与 `debugger` 调试断点。消费方 `i2f-extension-xproc4j`（`lang-eval-tinyscript` 节点 + `ProcedureTinyScriptResolver` 等 10 文件）+ IDEA 插件（.tis PSI 独立实现）；Funic 为其增强替代方案。**23 项运行时验证：13 通过、10 缺陷实锤**——⚠ 任何 `catch` 子句收集阶段必 NPE（`classNameCtxList` 未初始化）致 try-catch 完全不可用、try 异常被 `un-support try segment found` IAE 替换致原异常丢失、默认 `debug=true` 全节点 stdout 日志、下划线数字字面量求值失败、null 参与算术/复合赋值 NPE、函数声明不跨 `script()` 调用保留——详见文档。

- 详细文档：[i2f-extension-antlr4-tinyscript](./i2f-extension/i2f-extension-antlr4-tinyscript/readme.md)

### i2f-extension-aspectj

> **AspectJ 连接点与 i2f-proxy 统一代理模型之间的桥接层**（3 源文件 93 行、单包族 `i2f.extension.aspectj`/`.impl`，零资源零 JUnit 测试、src/test 为 2 个 main 演示类）：把 `@Around` 切面中的 `ProceedingJoinPoint` 经 `JdkProxyUtil` 包装为 JDK 动态代理——`proceed*` 调用被重定向为「`AspectjInvoker`（`invoke` ≡ `pjp.proceed(args)`，继承 `JdkMethod` 可读方法签名）+ `IProxyInvocationHandler`」的编程式执行点：handler 可读方法、就地改写 `pjp.getArgs()` 数组（参数改写生效）、短路返回、拦截异常，由 `invokable.invoke(...)` 决定何时放行；非 `proceed` 方法原样转发。`AspectjProxyProvider` 将同一能力注册为 `IProxyProvider` 家族一员；`aspectjweaver 1.9.6` 以 `provided` 引入（版本硬编码）+ `aspectj-maven-plugin`（javac 后二进制织入，规避 Lombok 冲突）工程化编译期织入。**11 项运行时验证**（javac 直编 + JDK 动态代理 mock PJP）：核心链路 7 项通过；3 处行为瑕疵实锤——`proceed(Object[])` 新参数被静默丢弃、构造器连接点强转 `MethodSignature` 抛 CCE、`IProxyHandler` 重载异常路径因上游 `ProxyHandlerAdapter` 缺陷退化为无信息 NPE——详见文档。

- 详细文档：[i2f-extension-aspectj](./i2f-extension/i2f-extension-aspectj/readme.md)

### i2f-extension-asr-vosk

> **基于 Vosk 的本地离线语音识别门面**（1 源文件 75 行：`AsrVoskProvider` 全静态 API，单包 `i2f.extension.asr.vosk`，零资源、无 JUnit——`src/test` 仅 1 个 main 演示类）：把「模型获取 → 释放到 `./runtime/persist/vosk/vosk-model-small-cn-0.22`（`StdConst.RUNTIME_PERSIST_DIR` 拼接）→ 初始化 → WAV 解码 → 分帧识别」收敛为 4 个静态方法——`init()`/`init(String)` 惰性/显式初始化静态单例 `Model`，`recognize(File)`/`recognize(InputStream)` 用 `javax.sound` 解码、`try-with-resources` 构造 `Recognizer(model, 16000)`、4096 字节缓冲循环 `acceptWaveForm`、`getFinalResult()` **原样返回 JSON**（text 由调用方解析）；`vosk 0.3.32`（JNA 封装 libvosk 原生库）与 `jna 5.7.0` 均以 `provided` 引入且版本仅本模块硬编码，运行期须知「jar + 原生库」三件套。**30 项运行时验证全部通过**（同签名桩替换 `org.vosk` + javac 直编；另以真实 vosk-0.3.32 + jna-5.7.0 编译验证 API 兼容）：核心链路符合预期；**4 处缺陷实锤**——`init(String)` 自定义路径被完全忽略（恒加载默认常量）、每次成功 init 泄漏一个关机钩子且退出时对同一模型重复 `close()`、初始化失败后字段遗留**已关闭模型**（后续识别静默使用之）、识别失败路径不关输入流（文件句柄泄漏，Windows 无法删除）——详见文档。

- 详细文档：[i2f-extension-asr-vosk](./i2f-extension/i2f-extension-asr-vosk/readme.md)

### i2f-extension-browser-playwright

> **基于 Microsoft Playwright 的浏览器自动化搜索抓取扩展**（9 源文件 1677 行、包族 `i2f.extension.browser.playwright`/`.context`/`.search`/`.search.utils`，零资源、无 JUnit）：`i2f-browser-std` 契约之上实现四层能力——`BrowserPlaywright.getWebDriver(withUi, launchOptions)` 驱动工厂（默认 4 项反自动化 Chromium 参数 + `chromiumSandbox=false` + 60s/30s 超时）、`PlaywrightDriver` 四层持有者（page→context→browser→playwright 级联 close，`Closeable` 支持 try-with-resources）、`PlaywrightUtil`（`blockNetworkResources` 双层判定拦截图片/音视频/字体省带宽 + `removeNoContentElements` 三段 JS 清洗 + `TargetClosedError` 判定）、`WebPageScraper.scraper(url, webUi)` 通用正文抓取，以及五大搜索引擎同构实现 `BaiduSearch`/`BaiduKaifaSearch`/`BiYingSearch`/`SouGouSearch`/`TouTiaoSearch`（三重重载 `search(question[, maxArticleCount[, webUi]])`，`LinkedBlockingDeque<Map.Entry<SearchResult, SearchType>>` 阶段队列：SEARCH_FIRST 聚合 + 翻页入队 + AI 摘要、SEARCH_PAGE 仅聚合、SouGou 滚动加载独有；`maxArticleCount` 为含 AI 摘要的总配额）；`playwright 1.58.0` 以 `provided + optional` 引入且版本仅本模块硬编码（运行期需备 playwright jar + driver-bundle + Chromium 三件套），消费方 `i2f-tools-ops` 封装为 4 个 AI Tool（Windows + 开关双条件装配）。**72 项桩替换运行时验证全部通过**（同签名桩替换 `com.microsoft.playwright` + javac 直编，另以真实 playwright-1.58.0.jar 双阶段编译验证 API 兼容）：核心链路（驱动装配/关闭链/网络拦截/清洗/抓取/五引擎检索/配额截断/滚动加载）全通过；**实锤缺陷**——五搜索类整页 title/html/text 写入队列局部对象后从不入 results（整页数据丢失）、`WebPageScraper` 等待 body 失败被吞后未判空直接解引用（NPE）、队列排空忙等固定多耗约 1s、`getWebDriver` 原地改写调用者 launchOptions——详见文档。

- 详细文档：[i2f-extension-browser-playwright](./i2f-extension/i2f-extension-browser-playwright/readme.md)

### i2f-extension-browser-selenium

> **基于 Selenium WebDriver 的浏览器自动化搜索抓取扩展**（9 源文件 2016 行、双驱动内置 `chromedriver.exe` + `msedgedriver.exe`、`selenium-java:4.32.0` provided + optional）：`BrowserSelenium` 驱动工厂（Edge/Chrome 双引擎 + 内置 driver 释放 + 版本不匹配自动 CDN 下载）+ `SeleniumUtil` CDP 网络拦截/DOM 清洗/异常判定 + `WebPageScraper` 通用正文页抓取 + 五大搜索引擎同构搜索类（Baidu/BaiduKaifa/BiYing/SouGou/TouTiao，`LinkedBlockingDeque` 阶段队列爬行，配额截断）。消费方 `i2f-tools-ops` AI Tool 封装 + `i2f-extension-all` 聚合。⚠ 瑕疵：整页数据丢失、队列排空忙等、自动下载平台硬编码 win64、空列表解引用等。

- 详细文档：[i2f-extension-browser-selenium](./i2f-extension/i2f-extension-browser-selenium/readme.md)

### i2f-extension-canal

> **基于 Alibaba Canal 的 MySQL Binlog 订阅消费模板**（2 源文件 345 行、`canal.client:1.1.7` + `canal.protocol:1.1.7` provided + optional）：`CanalClient` 以模板方法模式封装 Canal 连接→订阅→轮询→Protobuf 解析→SQL 类型映射→事件分发的完整骨架——子类只需重写 `onInsertEventMap`/`onDeleteEventMap`/`onUpdateEventMap` 三个钩子；`CanalMeta` 连接元数据 POJO；内置 15+ JDBC 类型 Java 映射引擎（二进制、字符串、整数、浮点、高精度、时间、布尔）。消费方 `i2f-extension-all` 聚合 + 根 POM dependencyManagement。⚠ 瑕疵：无 ACK 确认、无自动重连、空 catch 静默吞异常、非 daemon 线程、FLOAT 精度降级等。

- 详细文档：[i2f-extension-canal](./i2f-extension/i2f-extension-canal/readme.md)

### i2f-extension-cglib

> **基于 CGLIB 字节码增强的 i2f-proxy-std 代理实现**（3 源文件 105 行、`cglib:3.3.0` provided + optional）：`CglibUtil` 六重载静态门面 + `CglibProxyProvider` 实现 `IProxyProvider` 契约 + `CglibProxyInvocationHandlerAdapter` 将 `IProxyInvocationHandler` 桥接为 CGLIB `MethodInterceptor`；Adapter Pattern + Facade Pattern 双层结构，与 `i2f-proxy`（JDK 动态代理）、`i2f-extension-aspectj`（AspectJ 桥接）共享同一代理契约。消费方 `i2f-extension-all` 聚合 + `i2f-jdk/test-features` 测试依赖；`i2f-spring-core` 含同构复制版（使用 Spring 内建 `org.springframework.cglib.proxy.Enhancer`）。⚠ 瑕疵：lombok 冗余、共享 DEFAULT_ENHANCER 非线程安全、零测试覆盖。

- 详细文档：[i2f-extension-cglib](./i2f-extension/i2f-extension-cglib/readme.md)

### i2f-extension-compress

> **基于 Apache Commons Compress 的归档压缩适配层**（5 源文件 393 行、`commons-compress:1.21` + `xz:1.8` provided + optional）：`ZipApacheCompressor`/`JarApacheCompressor`/`TarApacheCompressor`/`CpioApacheCompressor`/`SevenZApacheCompressor` 五种 Apache Commons Compress Archive API 的 `ICompressor` 桥接实现——同一接口操作 ZIP/JAR/TAR/CPIO/7Z 五种格式；Tar 支持未知大小条目自动暂存临时文件；7Z 非 Stream 体系通过匿名 InputStream 包装适配；继承 `AbsCompressor` 骨架获得 `compressBindFile`/`compressFile`/`release(二参)` 免费实现。消费方 `i2f-extension-all` 聚合 + 根 POM dependencyManagement。⚠ 瑕疵：无 try-finally 资源保护、Tar 临时文件风险、SevenZ 解压流语义不清、路径分隔符硬编码等。

- 详细文档：[i2f-extension-compress](./i2f-extension/i2f-extension-compress/readme.md)

### i2f-extension-cron

> **基于 cron-utils 的嵌入式单机 CRON 任务调度器**（2 源文件 237 行、`cron-utils:9.2.1` provided + optional）：`CronUtil` 静态门面（UNIX/Spring/Quartz 三种 cron 方言的解析与未来 N 次执行时间计算）+ `CronExecutor` 三池分离调度器（cronPool 300ms 扫描预生成 10 个时间点 → triggerPool 300ms 扫描触发 → executePool CachedThreadPool 执行；`ConcurrentSkipListMap` 时间有序队列 + 双锁粒度分离）。支持 cron 周期任务、指定时间一次性任务、延迟一次性任务三态提交。消费方 `i2f-extension-all` 聚合 + 根 POM dependencyManagement。⚠ 瑕疵：无 shutdown/remove 方法、无空值保护、时间回跳风险、300ms 固定精度。

- 详细文档：[i2f-extension-cron](./i2f-extension/i2f-extension-cron/readme.md)

### i2f-extension-document

> **基于 Aspose 与 PDFBox 生态的办公文档格式转换与处理套件**（7 源文件 574 行、5 个三方库 system/provided）：`DocumentUtil` Aspose.Words 转换门面（内置 License + 字体路径搜索 + 20+ 格式互转 + html2word/word2pdf/word2png）+ `SheetUtil` Aspose.Cells 转换门面（内置 License + PDF allColumnsInOnePagePerSheet + excel2pdf/excel2csv/excel2tiff）+ `DocumentExportUtil` Velocity 模板渲染 + Base64 图片嵌入流水线 + `WindowsDocumentUtil` documents4j Office COM 转换（仅 Windows）+ `PdfConvertUtil` PDFBox 文本提取与逐页 PNG 渲染（150 DPI）。消费方 `i2f-springboot-ops-starter`（2 处 PdfConvertUtil 用于 RAG/AI Tool）+ `i2f-extension-all` 聚合。⚠ 瑕疵：硬编码 Aspose 盗版许可、system-scope 依赖不可 CI 构建、空 catch 吞异常、字体路径硬编码混乱等。

- 详细文档：[i2f-extension-document](./i2f-extension/i2f-extension-document/readme.md)

### i2f-extension-easyexcel

> **基于 Alibaba EasyExcel 的 Excel 导入/导出工具套件**（约 53 源文件共约 4200 行、`easyexcel:4.0.3` + `spring-context`/`spring-expression`/`spring-jdbc`/`mybatis:3.5.19`/`jackson` provided + optional）：`ExcelExportUtil` 21+ 重载静态写门面 + `ExcelImportUtil` Map/Bean 双模式读门面 + `ExcelExportTask` 循环分页引擎（pageSize=5000/sheetSize=65530 双阈值自动分 sheet）+ `IDataProvider` 策略族（List/Function/Service/MyBatis Cursor/JPA Stream 7 种实现）+ `@ExcelCellStyle` 注解驱动样式系统（SpEL 条件渲染 + 超链接/批注/下拉框）+ `Convertors` 注册中心（23+ 预置转换器 + SPI 扩展）+ `EasyExcelComplexUtil` 递归展平算法（`$` 路径分隔多块同 sheet 渲染）。消费方仅 POM 聚合。⚠ 瑕疵：空 catch 多处吞异常、静态 deletePool 永不关闭、createTemplateFileByColumns 双临时文件异步删除竞争、分页顺序校验严格、SpEL 异常不处理、下标越界等 12 项。

- 详细文档：[i2f-extension-easyexcel](./i2f-extension/i2f-extension-easyexcel/readme.md)

### i2f-extension-elasticsearch

> **基于 Elasticsearch RestHighLevelClient 7.6.2 的索引/文档/查询操作封装套件**（8 源文件 1233 行、`elasticsearch:7.6.2` + `rest-high-level-client` + `spring-data-elasticsearch:4.0.6` + `spring-boot-starter-data-elasticsearch:2.3.7` provided + optional）：`EsManager` 三层门面（客户端工厂 + 索引管理 + 文档 CRUD + 批量 Bulk + 搜索查询）+ `EsBeanManager` POJO 注解映射层（`@EsIndex`/`@EsId`/`@EsField` 三注解 + ConcurrentHashMap 缓存 + 双向 Bean↔Map 转换）+ `EsQuery` Fluent SQL-like 查询构建器（BoolQuery 状态机 eq/gt/like/match/range + 分页/排序/列选择）+ `SpringEsQuery` Spring Data 桥接。消费方 `i2f-springboot-ops-starter`（3 处 Java 引用）+ `i2f-extension-all` 聚合。⚠ 瑕疵：空 catch 吞异常、批量空列表 `get(0)` NPE、缓存无限增长、`SpringEsQuery.inflate` 空 BoolQuery 等 10 项。

- 详细文档：[i2f-extension-elasticsearch](./i2f-extension/i2f-extension-elasticsearch/readme.md)

### i2f-extension-email

> **基于 JavaMail (javax.mail 1.6.2) 的邮件发送工具门面**（3 源文件 396 行、`javax.mail:1.6.2` + `javax.activation:1.1.1` provided、零内部 i2f 依赖）：`EmailUtil` 10 静态方法门面（`directSend` 一键发信 + `getSession`/`makeMimeMessage`/`fillMimeMessage`/`send` 分步装配）+ `EmailConfigData` 流式 Builder（预设 20+ 邮箱服务商 SMTP 常量 + SSL/认证/多收件人配置）+ `EmailSendData` 流式 Builder（纯文本/HTML 双模式 + 多附件 + 自定义字符集）。消费方仅 POM 聚合。⚠ 瑕疵：`mail.stmp.host` 拼写错误、`System.getProperties()` 全局污染、SSL 信任所有证书、from/to 空值无保护等 10 项。

- 详细文档：[i2f-extension-email](./i2f-extension/i2f-extension-email/readme.md)

### i2f-extension-fastexcel

> **基于 cn.idev.excel (fastexcel:1.2.0) 的 Excel 导入/导出工具套件**（56 源文件约 3350 行、`fastexcel:1.2.0` + `spring-context`/`spring-expression`/`spring-jdbc`/`jackson`/`mybatis:3.5.19` provided + optional）：与 i2f-extension-easyexcel 同构架构，底层引擎切换为 fastexcel——`ExcelExportUtil` 21+ 重载静态写门面 + `ExcelImportUtil` Map/Bean 双模式读门面 + `ExcelExportTask` 循环分页引擎（pageSize=5000/sheetSize=65530 双阈值自动分 sheet）+ `IDataProvider` 策略族（List/Function/Service/MyBatis Cursor/JPA Stream 7 种实现）+ `@ExcelCellStyle` 注解驱动样式系统（SpEL 条件渲染 + 超链接/批注/下拉框）+ `Convertors` 注册中心（23+ 预置转换器 + SPI 扩展）+ `EasyExcelComplexUtil` 递归展平算法（`$` 路径分隔多块同 sheet 渲染）。消费方仅 POM 聚合。⚠ 瑕疵：空 catch 多处吞异常、静态 deletePool 永不关闭、createTemplateFileByColumns 临时文件异步删除竞争等 10 项。

- 详细文档：[i2f-extension-fastexcel](./i2f-extension/i2f-extension-fastexcel/readme.md)

### i2f-extension-fastjson

> **基于 fastjson1 兼容包（`com.alibaba:fastjson:2.0.26`，POM 自述 `fastjson1-compatible`、实由 fastjson2 引擎驱动）的 `IJsonSerializer` 契约适配器**（1 源文件 63 行、单类 `FastJsonSerializer`、零测试零资源）：把 `JSON.toJSONString`/`parse`/`parseObject` 装配为 i2f-serialize-std 的 JSON 契约实现——`Class`/`Type`/`TypeReference` 三路类型化反序列化分派 + `bean2Map`/`deserializeAsMap` 覆写 + `INSTANCE` 无状态单例；fastjson 以 provided 声明、运行期使用方自备；与兄弟模块 i2f-extension-fastjson2（原生 fastjson2 API）为同一契约的可替换双实现。消费方仅 POM 聚合与分发产物。⚠ 瑕疵：异常未包装契约 `JsonSerializeException`、`bean2Map` 对非对象 JSON 抛 JSONException、双次编解码开销、lombok 冗余声明等 9 项。

- 详细文档：[i2f-extension-fastjson](./i2f-extension/i2f-extension-fastjson/readme.md)

### i2f-extension-fastjson2

> **基于原生 fastjson2（`com.alibaba.fastjson2:fastjson2:2.0.34`，自包含零运行时传递依赖）的 `IJsonSerializer` 契约适配器**（1 源文件 63 行、单类 `FastJson2Serializer`、零测试零资源）：把 `JSON.toJSONString`/`parse`/`parseObject` 装配为 i2f-serialize-std 的 JSON 契约实现——`Class`/`Type`/`TypeReference` 三路类型化反序列化分派 + `bean2Map`/`deserializeAsMap` 覆写 + `INSTANCE` 无状态单例；fastjson2 以 provided 声明、运行期使用方自备；与兄弟模块 i2f-extension-fastjson（fastjson1 兼容包）为同一契约的可替换双实现，本模块面向新项目优先推荐。21 项运行时实证全部通过（JDK8 javac 直编）。消费方仅 POM 聚合与分发产物。⚠ 瑕疵：异常未包装契约 `JsonSerializeException`（实测抛 fastjson2 原生 `JSONException`）、`bean2Map` 对非对象 JSON 抛 JSONException、null 边界静默返回、双次编解码开销、lombok 冗余声明等 10 项。

- 详细文档：[i2f-extension-fastjson2](./i2f-extension/i2f-extension-fastjson2/readme.md)

### i2f-extension-filesystem-ftp

> **基于 Apache Commons Net `FTPClient`（`commons-net:commons-net:3.6` provided）的 `IFileSystem` 契约适配器**（3 源文件 315 行、`i2f-io-filesystem` 内部依赖、零测试零资源）：把 FTP 协议装配为 `i2f-io-filesystem` 的 `IFileSystem`/`IFile` 契约实现——仅实现 11 个操作原语（`isDirectory`/`isFile`/`isExists`/`listFiles` 均为「切分目录 + 被动 LIST + 名称匹配」；`retrieveFileStream`/`storeFileStream`/`appendFileStream` 三路流；`makeDirectory`），另覆写 `getFile`/`getAbsolutePath`（契约覆写共 13 个），`mkdirs`/`copyTo`/`moveTo`/`store`/`load`/`readText`/`writeText` 等 40+ 组合能力全部继承自 `AbsFileSystem`/`AbsFile`（上游契约文档以其为扩展参照模板）；默认 `enableNewClient=true` 每操作新建连接（实测约 40 个逻辑操作 46 连接/46 登录，天然规避 FTP 流传输应答残留），复用模式因流传输后不调用 `completePendingCommand()` 导致 226 应答永久残留、控制连接逐次错位（29 项运行时实证全部通过，T25/T26 实锤：`IOException: Stream closed` → `ConnectException: Connection refused`，不自愈）。消费方仅 POM 聚合与分发产物。⚠ 瑕疵：从不调用 completePendingCommand、流传输恒 ACTIVE（PORT=9）而列目录被动（PASV=35）、根路径 `/` 三态恒 false、delete 非空目录静默失败、缺失文件读抛 IOException 而写缺失目录抛 NPE、close 后静默重连、commons-net 3.6 版本硬编码等 16 项。

- 详细文档：[i2f-extension-filesystem-ftp](./i2f-extension/i2f-extension-filesystem-ftp/readme.md)

### i2f-extension-filesystem-hdfs

> **基于 Apache Hadoop `FileSystem` 客户端（`hadoop-client:3.2.1` provided）的 `IFileSystem` 契约适配器**（3 源文件 225 行：`HdfsFileSystem` 176 行 + `HdfsFile` 35 行 + `HdfsMeta` 14 行、`i2f-io-filesystem` 内部依赖、零测试零资源）：把 HDFS 分布式文件系统装配为 `i2f-io-filesystem` 的 `IFileSystem`/`IFile` 契约实现——覆写 15 个方法（14 个契约方法 + `close`：三态元信息与 `listFiles` 直通 `getFileStatus`/`listStatus`，三路流直通 `open`/`create(path,true)`/`append`，`mkdir`/`mkdirs` 均委托 Hadoop 递归 `mkdirs`），`copyTo`/`moveTo`/`store`/`load`/`readText`/`writeText` 等 40+ 组合能力全部继承自 `AbsFileSystem`/`AbsFile`。设计核心是「薄封装」：构造即建连（`FileSystem.get` 二选一路径：`uri`+`user` 齐备则指定用户身份），**Hadoop 全局静态缓存按 scheme+authority+user 跨实例共享**（实测两实例同一底层实例、后建实例 `meta.config` 被静默忽略、关闭其一影响共享者）；元数据六方法空 `catch (Throwable)` 吞异常（`listFiles` 缺失返回空列表）、`mkdir`/`length` 包装 `IllegalStateException`、三路流直抛原始异常（`UnsupportedOperationException` 实测透传）——三种异常策略并存；`isAppendable` 恒 `true`、`close()` 仅直通不重连；`hadoop-client` provided 声明、运行期使用方自备。38 项运行时实证全部通过（`file:///` LocalFileSystem 模式 + winutils 桩 + NativeIO 类路径 shim，两次运行 11.7s/13.3s 结果一致）。消费方仅 POM 聚合与分发产物。⚠ 瑕疵：六方法空 catch 连 `Error` 都吞成诊断盲区（实测无 `hadoop.dll` 时 `listStatus` 的 `UnsatisfiedLinkError` 被吞为空列表）、delete 忽略返回值致非空目录静默失败、isAppendable 恒 true、close 不重连、全局缓存四连锁、构造期异常包装不完整（`IllegalArgumentException` vs `IllegalStateException`）、listFiles 路径形态变化（`/C:/...`）与文件路径返回自身、length 目录语义漂移、`getExtension` 继承反转缺陷等 14 项。

- 详细文档：[i2f-extension-filesystem-hdfs](./i2f-extension/i2f-extension-filesystem-hdfs/readme.md)

### i2f-extension-filesystem-minio

> **基于 MinIO Java SDK（`io.minio:minio:7.1.0` provided）的 `IFileSystem` 契约适配器**（1 pom 52 行 + 2 源文件 444 行：`MinioFileSystem` 400 行 + `MinioFile` 44 行，另有配套依赖模块 `i2f-extension-minio` 2 文件 191 行、`i2f-io-filesystem` 内部依赖、零测试零资源）：把 MinIO/S3 对象存储装配为 `i2f-io-filesystem` 的 `IFileSystem`/`IFile` 契约实现——路径按「首段=桶、余段=对象键」两级拆分（根列举桶 `listBuckets`、桶级 `bucketExists`/`makeBucket`/`removeBucket`、对象级 `statObject`/`getObject`/`putObject`/`removeObject` 直通），目录为 `.ignore` 空对象占位 + 键前缀模拟，覆写 16 个方法（含 `pathSeparator` 转发），`copyTo`/`moveTo`/`load`/`readText` 等 40+ 组合能力继承自 `AbsFileSystem`/`AbsFile`。设计核心是「无显式目录的桶/键模型 + 全方法吞异常降级」：五方法空 `catch (Throwable)` 静默（false/空列表/-1/0）、`delete` 目录静默 no-op（消费方自建递归补偿）、非空桶抛 `IllegalStateException`、追加流抛原生 `UnsupportedOperationException` 且 `isAppendable` 恒 false。54 项运行时实证（49 通过 + 5 记录，自研 578 行 S3 协议桩，三次运行：run1 崩溃暴露缺陷 → run2/run3 全绿，含 T48b 含 `+` 名编解码往返）。真实消费方：`i2f-springboot-oss-minio-starter` 自动装配（`@Bean MinioFileSystem`）+ `i2f-springboot-ops-starter` `MinioOpsController` 7 端点（upload 走 `getOutputStream` 规避缺陷、delete 自建递归）。⚠ 头号缺陷：`store()` 以 `.stream(is,-1,-1)` 上传——minio-java 7.1.0 `validateSizes` 在 build 期抛 `IllegalArgumentException: valid part size must be provided when object size is unknown`（包装 IOException），`MinioFile.writeBytes`（覆写为 store）→ `writeText` 连带报废。另：`decodeObjectName` 双重解码风险（非法 `%` 序列异常被吞致条目静默消失）、`length` 语义碎片化、`getExtension` 继承反转缺陷、io.minio 版本硬编码 5 处等 16 项。

- 详细文档：[i2f-extension-filesystem-minio](./i2f-extension/i2f-extension-filesystem-minio/readme.md)

### i2f-extension-filesystem-oss-aliyun

> **基于阿里云 OSS Java SDK（`com.aliyun.oss:aliyun-sdk-oss:3.17.4` provided）的 `IFileSystem` 契约适配器**（1 pom 79 行 + 2 源文件 484 行：`AliyunOssFileSystem` 436 行 + `AliyunOssFile` 48 行，另有配套依赖模块 `i2f-extension-oss-aliyun` 2 文件 237 行、`i2f-io-filesystem` 内部依赖、零测试零资源）：把阿里云 OSS 对象存储装配为 `i2f-io-filesystem` 的 `IFileSystem`/`IFile` 契约实现——路径按「首段=桶、余段=对象键」两级拆分（根列举桶 `listBuckets`、桶级 `doesBucketExist`/`createBucket`/`deleteBucket`、对象级 `doesObjectExist`/`getObject`/`putObject`/`deleteObject` 直通），目录为 `.ignore` 空对象占位 + 键前缀模拟，覆写 18 个方法（含 `pathSeparator` 转发），`copyTo` 走服务端 `copyObject`、`moveTo` 同桶走服务端 `renameObject`（`POST ?x-oss-rename`，全仓独有）、跨桶先拷贝后删除。**与 MinIO 模块最大差异：写通道全可用**——`store()` 未知长度流被 SDK 自动转 chunked 传输成功（T17 帧 `TE=chunked | CL=null`），`writeBytes`/`writeText` 随身可用（T19），`getOutputStream` 临时文件中转备选（T20 `CL=8`）。112 项运行时实证（112 通过 / 0 失败 / 13 记录，自研 714 行 OSS 协议桩 + 虚拟主机风格寻址，两次运行一致）。⚠ 头号缺陷：**签名版本配置失效**——`AliyunOssUtil.getClient` 创建的 `ClientBuilderConfiguration`（setSignatureVersion V4）从未传给 `OSSClientBuilder`，`meta` 默认 V4 被静默降级为 V1（T02 生效配置=V1、T48a wire 首词 `OSS`；手动补传对照 T02b/T48b=V4）；另 `listFiles` 分页缺陷（`nextMarker` 未用，真实 OSS 死循环，T47）、`decodeObjectName` 无条件 URLDecoder 污染原文键（`+`→空格 T45、`%41`→A T46）、`getStrictFile` 绝对路径恒拒绝（T42a）、`delete(目录)` 静默 no-op、`.ignore` 占位致桶删不掉等 18 项。

- 详细文档：[i2f-extension-filesystem-oss-aliyun](./i2f-extension/i2f-extension-filesystem-oss-aliyun/readme.md)

### i2f-extension-filesystem-oss-aws-s3

> **基于 AWS SDK v2（`software.amazon.awssdk:s3` 2.17.100，provided + optional，模块内 BOM 版本管理）的 `IFileSystem` 契约适配器**（1 pom 79 行 + 2 源文件 580 行：`AwsS3OssFileSystem` 532 行 + `AwsS3OssFile` 48 行，另有配套依赖模块 `i2f-extension-oss-aws-s3` 2 文件 287 行、`i2f-io-filesystem` 内部依赖、零测试零资源）：把 AWS S3 对象存储装配为 `i2f-io-filesystem` 的 `IFileSystem`/`IFile` 契约实现——路径按「首段=桶、余段=对象键」两级拆分（根列举桶 `listBuckets`、桶级 `getBucketPolicyStatus` 探测 + `createBucket`/`deleteBucket`、对象级 `getObject`/`putObject`/`copyObject`/`deleteObject`/`listObjects` 直通），目录为 `.ignore` 空对象占位 + 键前缀模拟，覆写 18 个方法（含 `pathSeparator` 转发），`copyTo` 走服务端 `copyObject`、`moveTo` 恒为拷贝+删除两步（无跨桶分支）。**与 MinIO/Aliyun 模块最大差异：签名全程 `AWS4-HMAC-SHA256` 零降级**（T48：78 请求全覆盖——与 Aliyun「配置 V4 实际降级 V1」恰好相反）。127 项运行时实证（127 通过 / 0 失败 / 26 记录，自研 798 行 Mock S3 协议桩 + 虚拟主机风格寻址 + aws-chunked 信封解码，两次运行一致）。⚠ 头号缺陷：**`store()` 100% 失败**——`RequestBody.fromInputStream(is, -1L)`（L429）在构造 `RequestBody` 瞬间即被 SDK `Validate.isNotNegative` 拒绝（`IllegalArgumentException` 包装为 `IOException`，**请求从未发出**，T17），`AwsS3OssFile.writeBytes`（覆写为 store）→ `writeBytes`/`writeText` 连带报废，唯一可用写通道为 `getOutputStream`（临时文件 + `RequestBody.fromFile`，T20 帧 signed aws-chunked 信封 `CL=181`）。其他重点缺陷：`getBucketPolicyStatus` 桶探测缺陷簇（无 policy 桶 404 `NoSuchBucketPolicy` 未被 SDK 建模 → `isExists` 泄漏 `S3Exception` T13a、`isDirectory`=false T12a、`mkdir` 409 T09a、`AwsS3OssUtil.bucketCreate` 完全不可用 T51c）、`length()` 恒 0（available T14b/c）、`listFiles` 分页缺陷（无 delimiter 时 `NextMarker` 不返回、真实 S3 死循环 T47）、`urlOf` 预签名恒失败（`Duration.of(999, YEARS)` 抛 `UnsupportedTemporalTypeException` T53）、`decodeObjectName` 无条件 URLDecoder 污染 `+`/`%xx` 键（T44/T45）等 19 项。真实消费方：`i2f-springboot-ops-starter` 的 `AwsS3OpsController`（387 行 8 端点，upload 走 `getOutputStream` 规避 store 缺陷、delete 自建递归）。

- 详细文档：[i2f-extension-filesystem-oss-aws-s3](./i2f-extension/i2f-extension-filesystem-oss-aws-s3/readme.md)

### i2f-extension-filesystem-sftp

> **基于 JSch（`com.jcraft:jsch:0.1.55` provided）的 `IFileSystem` 契约适配器**（1 pom 48 行 + 6 源文件 649 行：`SftpFileSystem` 258 行 + `ProxySftpFileSystem` 281 行（跳板双隧道）+ `SftpFile` 31 行 + `ProxySftpFile` 31 行（死代码）+ `SftpMeta` 23 行 + `ProxySftpMeta` 25 行，`i2f-io-filesystem` 内部依赖、零测试零资源）：把 SFTP 装配为 `i2f-io-filesystem` 的 `IFileSystem`/`IFile` 契约实现——覆写 14 个方法（11 个操作原语 + `getFile`/`getAbsolutePath`/`close`），`copyTo`/`moveTo`/`store`/`load`/`readText`/`writeText` 等 40+ 组合能力全部继承自 `AbsFileSystem`/`AbsFile`；`ProxySftpFileSystem` 经 SSH 本地端口转发实现「跳板机 → 目标机」两跳接入。**核心缺陷**：`getChannel()` 守卫 `!channel.isClosed()` 恒真（JSch 新建 channel `close=false`，`isClosed()` 仅在 `disconnect()` 后为 true）→ 每次操作都断旧会话并全量重连（实测每次操作恰好 1 个新 SSH 会话，Proxy 每次 2 个）；叠加 delete 三重失效链（外层 channel 被 `isFile()` 内部重建作废 + `isFile` 对目录误判 `true` + 异常全吞）→ **`delete` 对文件/目录全部静默失效**；`listFiles(path)` 实际列出**父目录**内容（含 `.`/`..`）；同 FS `copyTo`/`moveTo` 因「先取输入流、再取输出流触发重连断源流」必然抛 `IOException: Pipe closed`。64 项运行时实证（38 通过 / 5 对立断言失败实锤缺陷 / 21 记录；真实 OpenSSH 9.0p1 mock sshd + `sshd.log` 会话计数 + JSch `get()` 惰性流探针）。

- 详细文档：[i2f-extension-filesystem-sftp](./i2f-extension/i2f-extension-filesystem-sftp/readme.md)

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
