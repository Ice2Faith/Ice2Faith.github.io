# i2f-turbo-java

> 面向 JDK / Spring / SpringBoot / SpringCloud 的 Java 基础能力增强与扩展库，提供反射、JDBC、类型系统、AI、扩展组件等模块化能力。

## i2f-jdk

> 仅依赖 JDK8 的基础能力模块集合，提供反射、类型系统、集合、IO、加密、JDBC、SPI、JVM Agent、AI 标准抽象、网络通信、脚本引擎、日志门面等通用工具与契约层。

### i2f-jdk-all

> i2f-jdk 全子模块的 Maven 聚合分发包，将约 91 个 i2f-jdk 子模块经 `maven-assembly-plugin` 打包为单体 fat-jar，是「一次依赖、全套引入」的一站式构建入口。

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

> 字节序编解码工具模块，单一静态门面 `ByteUtil` 以 48 个方法完成「7 种基本类型 × Big/Little 端序 × 新建数组/就地写入」双向互转，另支持 1–8 字节任意宽度定长编解码；零 Maven 依赖。

- 详细文档：[i2f-bytes](./i2f-jdk/i2f-bytes/readme.md)

### i2f-atomic

> 原子变量补充模块，零依赖自研 JDK 缺失的 `AtomicDouble`/`AtomicDoubleArray`，把 double 经 raw-long-bits 编码复用 `AtomicLongFieldUpdater`/`AtomicLongArray` 做无锁 CAS，语义对齐 `java.util.concurrent.atomic` 家族。

- 详细文档：[i2f-atomic](./i2f-jdk/i2f-atomic/readme.md)

### i2f-array

> 数组工具模块，单一静态门面 `ArrayUtil` 提供 458 个方法，覆盖判定/读写/构造/集合互转/映射过滤/合并/二维扁平/填充/拷贝/反转/比较/相等，对象与 8 种基本类型数组全覆盖。

- 详细文档：[i2f-array](./i2f-jdk/i2f-array/readme.md)

### i2f-authentication

> 认证标准契约模块，框架无关地定义密码编码/登录密码解码/用户与 RBAC 主体模型，并给出加盐 + 多轮迭代、密文自描述参数的 `MessageDigestPasswordEncoder` 实现；被 Spring Security、Shiro、SpringBoot starter 实现与继承。

- 详细文档：[i2f-authentication](./i2f-jdk/i2f-authentication/readme.md)

### i2f-bindsql

> 参数化 SQL 流式构建器，以 `BindSql` 将「SQL 文本 + 绑定参数」一体化链式拼装，内建 MyBatis 风格动态 SQL（when/choose/foreach/连接词裁剪）与关键字 DSL，并提供字面量回填/美化/去注释的正则文本处理；为分页、JDBC、BQL 等持久化能力的地基。

- 详细文档：[i2f-bindsql](./i2f-jdk/i2f-bindsql/readme.md)

### i2f-bindsql-page

> 分页/计数 SQL 方言适配器，以 `IPageWrapper`/`ICountWrapper` 双扩展点把 `BindSql` 改写为各库分页与 `count(1)` 语句；内置 9 方言 + 20+ 小库重定向归并，经 ThreadLocal→SPI Provider→方言映射→内置分发四级解析链选择。

- 详细文档：[i2f-bindsql-page](./i2f-jdk/i2f-bindsql-page/readme.md)

### i2f-bindsql-stringify

> 参数化 SQL 文本化模块，以 `WrappedBindSqlStringifier` 把 `BindSql` 的裸 `?` 按目标方言回填为 SQL 字面量（字符串转义、MySQL `STR_TO_DATE`/Oracle `TO_DATE`），还原成完整可执行/可展示语句，供日志打印与纯 Statement 脚本执行器使用。

- 详细文档：[i2f-bindsql-stringify](./i2f-jdk/i2f-bindsql-stringify/readme.md)

### i2f-database-type

> 数据库类型/方言识别层（持久化族的类型地基），`DatabaseType` 枚举收录 36 库经「URL 嗅探 + 连接探测 + SPI」三路径识别，`DatabaseDialectMapping` 做小库→主流方言归并；纯 JDK 零三方依赖。

- 详细文档：[i2f-database-type](./i2f-jdk/i2f-database-type/readme.md)

### i2f-bql

> 类型安全绑定查询语言（BQL），在 `BindSql` 之上提供全量 SQL 关键字 DSL、方言自适应标识符装饰与动态 SQL；以 core→map→lambda→bean 四级继承链支持「字符串/Map/方法引用/实体 Bean」递进式列寻址，产物仍是 `BindSql`。

- 详细文档：[i2f-bql](./i2f-jdk/i2f-bql/readme.md)

### i2f-lambda-core

> 方法引用解析内核，以 `extends Serializable` 的 `IGetter`/`ISetter`/`IBuilder` 承接 getter/setter 型方法引用，经 `writeReplace`→`SerializedLambda` 反查引用的类/方法/字段，反射定位 `Class`/`Method`/`Field`；是 bql/mutator/lambda 的类型安全底座。

- 详细文档：[i2f-lambda-core](./i2f-jdk/i2f-lambda-core/readme.md)

### i2f-lambda

> 方法引用解析通用层，在 `i2f-lambda-core` 的 getter/setter 命名约定之上补上「任意方法引用」的还原：用 `SerializedLambda` 的方法名 + JVM 描述符经 `i2f-reflect` 精确匹配真实 `Method`。

- 详细文档：[i2f-lambda](./i2f-jdk/i2f-lambda/readme.md)

### i2f-functional

> 可序列化函数式接口地基（零依赖），以 `IFunctional extends Serializable` 为顶点按「返回域 × 元数 × 是否抛异常」枚举 327 个接口，是上层 lambda 反解方法引用的前提。

- 详细文档：[i2f-functional](./i2f-jdk/i2f-functional/readme.md)

### i2f-functional-lambda

> 「函数式接口 × 方法引用解析」粘合层：把 `ExFunctionalDelegator` 重载汇聚前门与 `LambdaInflater` 方法引用反解器对接，产出 `Lambdas.FIELD/METHOD/LAMBDA` 三个无状态转换器单例，一行即得 `Field`/`Method`/`SerializedLambda`。

- 详细文档：[i2f-functional-lambda](./i2f-jdk/i2f-functional-lambda/readme.md)

### i2f-browser-std

> 浏览器搜索引擎抓取的标准契约层，零引擎依赖地沉淀统一出参模型 `SearchContext`/`SearchResult`、爬行阶段枚举、运行期可变屏蔽常量与 URL 归一工具；是 Playwright 与 Selenium 两套抓取实现的共同上游契约。

- 详细文档：[i2f-browser-std](./i2f-jdk/i2f-browser-std/readme.md)

### i2f-mutator

> 流式对象修改器，以 `Mutator<T>` 门面用方法引用链式修改任意对象（set/with 四维矩阵 + apply/when/map 控制流），并借方法引用反射提供 `field*` 族「只给 getter 即读改写」的特色能力。

- 详细文档：[i2f-mutator](./i2f-jdk/i2f-mutator/readme.md)

### i2f-otpauth

> 一次性口令（OTP）认证模块，纯 JDK 实现 RFC 4226/6238 的「HMAC → 动态截断 → 数字码」内核与 `otpauth://` 密钥 URI 装配，抽象骨架下沉 HOTP/TOTP 与 Microsoft/Steam 两级厂商兼容；运行期零三方依赖。

- 详细文档：[i2f-otpauth](./i2f-jdk/i2f-otpauth/readme.md)

### i2f-tuple-std

> 元组标准契约层，全模块仅 `Tuple` 接口：以 size/get/set/toList 四抽象刻画「下标化异质多值容器」，并用 default 派生判空/转数组/可遍历，是 `Tuple0…Tuple20` 实现族的向上转型锚点。

- 详细文档：[i2f-tuple-std](./i2f-jdk/i2f-tuple-std/readme.md)

### i2f-tuple-impl

> 元组强类型实现家族，以「一档 arity 一类」提供 `Tuple0`…`Tuple20`（@Data POJO）+ 变长 `TupleVars`，由 `Tuples.of/ofVars` 工厂按实参数分派产出；`Tuple2` 兼任 `Map.Entry`。

- 详细文档：[i2f-tuple-impl](./i2f-jdk/i2f-tuple-impl/readme.md)

### i2f-typeof

> 类型系统地基：自动装箱感知的类型谓词门面 `TypeOf`（原始/包装/父子三态统一判定）+ Guava 风格超类型令牌 `TypeToken`/`TypeNode`（匿名子类反泛型擦除、还原任意深度嵌套泛型），是 reflect/convert/container-builder 等的共同判据。

- 详细文档：[i2f-typeof](./i2f-jdk/i2f-typeof/readme.md)

### i2f-uid-impl

> UID 生成器系列的默认实现家族：32 位秒级雪花 `SnowflakeIntUid`、64 位毫秒级雪花 `SnowflakeLongUid`（MAC 哈希推导 workerId 零配置自适应）与 UUID 压缩 `UuidRandomStringUid`，全量落地上游 `i2f-uid-std` 契约。

- 详细文档：[i2f-uid-impl](./i2f-jdk/i2f-uid-impl/readme.md)

### i2f-uid-std

> UID 生成器系列的标准契约层：三层契约树 `IStringUid`/`IIntUid`/`ILongUid`（均函数式接口 + 定宽 hex 默认方法），零依赖。

- 详细文档：[i2f-uid-std](./i2f-jdk/i2f-uid-std/readme.md)

### i2f-unsafe

> 底层内存窥探工具：静态类 `UnsafeHacker` 反射撬取 `sun.misc.Unsafe`，提供对象物理地址读取与对象深链字节大小估算（Nashorn 缺失时优雅降级），零 Maven 依赖。

- 详细文档：[i2f-unsafe](./i2f-jdk/i2f-unsafe/readme.md)

### i2f-verifycode

> 「看图答题」式图形验证码「生成 + 校验」框架：1 接口 + 5 抽象基类按「交互形态 × 维度」定型 8 种实现（艺术字/算式/极坐标加法/标尺与矩阵点击等），答案统一百分比且缩放无关，模块无状态。

- 详细文档：[i2f-verifycode](./i2f-jdk/i2f-verifycode/readme.md)

### i2f-workflow

> 「任务依赖编排 + DAG 并发调度」双引擎流程编排模块：旧引擎 `WorkFlow` 流式声明节点图轮询触发，新引擎 `rag.DagScheduler` 拓扑分层调度 + 条件边 + 人工节点断点暂停/恢复。

- 详细文档：[i2f-workflow](./i2f-jdk/i2f-workflow/readme.md)

### i2f-xml

> 「XML 解析双引擎 + 行号定位工具箱 + Maven POM 解析器」：DOM 解析行号位置注入（「文件:行号」级错误定位）+ StAX 流式轻量树 + 父 POM 依赖版本推导，双工厂 XXE 三禁闭。

- 详细文档：[i2f-xml](./i2f-jdk/i2f-xml/readme.md)

### i2f-match-std

> 字符串匹配器标准契约层：`IMatcher` 布尔契约 + `IPriorMatcher` 打分契约（matchRate 负值不匹配），沉淀打分公式与浮点阈值，解决「一个串命中多模式」时按精确度择优排序。

- 详细文档：[i2f-match-std](./i2f-jdk/i2f-match-std/readme.md)

### i2f-match

> 字符串匹配器实现层 + 正则工具箱：Simple/Ant/Regex 三实现共享打分公式，`StringMatcher` 门面按精确度降序择优；另一半 `regex` 子包是被约 20 个模块共用的全仓正则底座。

- 详细文档：[i2f-match](./i2f-jdk/i2f-match/readme.md)

### i2f-lru-map

> 「内存缓存 / 自调节容器 / 弱引用复用 / RAII 作用域」工具族：LruMap 家族（容量淘汰/时间片/自调节/并发缓存）、过期记忆化、弱引用复用与 ScopeValue 配对释放；`LruMap` 是全仓反射/编译缓存的事实标准。

- 详细文档：[i2f-lru-map](./i2f-jdk/i2f-lru-map/readme.md)

### i2f-lru-cache

> 将 LRU 淘汰策略接入缓存接口的适配桥接模块：`LruMapCache` 继承 `MapCache` 并以注入的 `LruMap` 替换底层 Map，使缓存自带 LRU 容量淘汰，可与过期装饰器组合出「LRU + TTL」双淘汰。

- 详细文档：[i2f-lru-cache](./i2f-jdk/i2f-lru-cache/readme.md)

### i2f-math

> 数学计算工具箱：`MathUtil` 静态门面（三角/插值/排列组合/精度截断）、双栈公式计算器 `FormulaCalculator`（60+ 运算符）、`Matrix` 矩阵运算、`Segment` 区间抽象与大数数列。

- 详细文档：[i2f-math](./i2f-jdk/i2f-math/readme.md)

### i2f-mixins

> 混入式函数编程工具箱：以 JDK 接口默认方法实现 Java「多重继承」式函数编程，18 个 `*Mixins` 接口聚合为 `AllMixins`，覆盖 String/Math/Object/Date/Regex 等九大领域数百函数，`MixinProxyFactory` 动态代理免匿名对象。

- 详细文档：[i2f-mixins](./i2f-jdk/i2f-mixins/readme.md)

### i2f-native-core

> 原生（JNI）指针工具箱：`Ptr` 指针值类型安全包装 + 三种分配来源标记指针（malloc/new/new[]）+ `NativeUtil` 从 classpath 释放并加载原生库，附系统 JNI 开发教程。

- 详细文档：[i2f-native-core](./i2f-jdk/i2f-native-core/readme.md)

### i2f-native-windows

> Windows（JNI）原生 API 门面：`NativesWindows` 约 250+ native 方法声明 + `WinApi` 类型安全门面，13 大子域覆盖窗口管理/GDI 绘图/输入模拟/进程线程/注册表/服务/COM/Shell/控制台等。

- 详细文档：[i2f-native-windows](./i2f-jdk/i2f-native-windows/readme.md)

### i2f-native-windows-easyx

> EasyX 图形库（JNI）Java 门面：一行 `initGraph` 即创建图形窗口，11 大功能域覆盖绘图原语/文字输出/图像操作/绘图状态/批量绘制/鼠标输入/颜色转换/工作图像等。

- 详细文档：[i2f-native-windows-easyx](./i2f-jdk/i2f-native-windows-easyx/readme.md)

### i2f-number-idcard

> 中国大陆身份证号码解析/校验工具：18 位公民身份号码五段切分（区划/日期/顺序/性别/校验位）+ 加权模 11 校验码判定 + 内置行政区划字典（GB 11643-1999），失败以原因说明而不抛异常。

- 详细文档：[i2f-number-idcard](./i2f-jdk/i2f-number-idcard/readme.md)

### i2f-cache-std

> 缓存标准契约层（6 个纯接口零实现）：根接口 `ICache` 沿「容器枚举 / 过期 / 持久分布式」三条正交轴继承扩展，为本地/Redis/Zookeeper/Hazelcast 等多形态缓存提供统一契约。

- 详细文档：[i2f-cache-std](./i2f-jdk/i2f-cache-std/readme.md)

### i2f-cache

> 缓存本地实现层：`MapCache` 把可注入 Map 适配为容器缓存，`ExpireCacheWrapper` 以装饰器 + ExpireData 信封把任意 ICache 升级为 TTL 过期缓存，二者正交组合即得「本地 + 可过期」默认装配。

- 详细文档：[i2f-cache](./i2f-jdk/i2f-cache/readme.md)

### i2f-check

> 「校验/断言」工具箱（pom 零依赖）：可累积、可换值、可快速失败的流式校验链 `Checker<T>` + 约 90 个「为方法引用而生」的静态布尔谓词 `Predicates`。

- 详细文档：[i2f-check](./i2f-jdk/i2f-check/readme.md)

### i2f-check-filter

> 存在性判定 / 大数据去重过滤器族：内存级 `ICheckFilter`/`BloomFilter`（位数组多哈希概率判重）+ 大数据级 `IRepeatFilter`（布隆近似去重 / 哈希分组 + 临时文件精确去重）。

- 详细文档：[i2f-check-filter](./i2f-jdk/i2f-check-filter/readme.md)

### i2f-clock-impl

> 时钟源契约 IClock 的默认实现：SystemClock 以单线程守护调度池每 1ms 刷新一个 volatile ts，把 currentTimeMillis 系统调用移出热路径（只读 volatile），为雪花 ID 等高频取时提速；另附分段秒表 TimeCounter。瑕疵：定时任务无 try/catch，异常即停刷致时间冻结。

- 详细文档：[i2f-clock-impl](./i2f-jdk/i2f-clock-impl/readme.md)

### i2f-clock-std

> 时钟源标准契约层：纯接口零实现，IClock 仅强制 currentMillis()，秒/分为 default 派生，把「读时间」与获取策略解耦供上层注入可替换时钟；由 SystemClock 实现，被 uid-impl、xproc4j 消费。瑕疵：包名与实现不对称、无 nanoTime 单调约束。

- 详细文档：[i2f-clock-std](./i2f-jdk/i2f-clock-std/readme.md)

### i2f-code

> 码值/密钥生成器（单静态门面 `CodeUtil`）：`makeUUID` 去连字符大写压缩 + `makeCheckCode` 基于 SecureRandom 的 62 字符均匀采样（避免模偏差），被 SWL 加密器用于生成 AES 密钥。

- 详细文档：[i2f-code](./i2f-jdk/i2f-code/readme.md)

### i2f-codec-std

> 编解码标准契约层：根接口 `ICodec` 以 encode/decode 双动词定义「类型 E ↔ D 双向转换」，沿数据形态衍生 5 个子接口（字节/字符串/集合打包/流式），配套统一异常。

- 详细文档：[i2f-codec-std](./i2f-jdk/i2f-codec-std/readme.md)

### i2f-codec-impl

> 编解码实现层（23 实现类覆盖 5 组接口）：Base64/Base32/Hex 等字节编解码、URL/HTML/Unicode 转义、集合 ID 打包、Gzip/Deflate/Zip 压缩，`CodecUtil` 门面 25+ 便捷方法一行完成常见操作。

- 详细文档：[i2f-codec-impl](./i2f-jdk/i2f-codec-impl/readme.md)

### i2f-color

> RGBA / HSL 色彩空间表示与转换模型：`Rgba` 四通道 + 位掩码枚举 + 灰度/色差/平滑插值，`Hsl` 标准双向转换算法，二者零拷贝互转，含 10 色预定义常量。

- 详细文档：[i2f-color](./i2f-jdk/i2f-color/readme.md)

### i2f-comparator

> 通用比较器工具箱：`NullableComparator` null 哨兵协议 + `DefaultComparator` 六级兜底级联（Comparable→类型兼容→BigDecimal→字典序→try→hashCode）+ 数组/反序/Bean 属性比较器与方法引用友好门面。

- 详细文档：[i2f-comparator](./i2f-jdk/i2f-comparator/readme.md)

### i2f-compiler

> 内存 Java 编译器 / 表达式求值器：基于 JDK `JavaCompiler` API 的编译→类加载→自动清理三级能力，以 `###import/###class/###method` 标签 DSL 包装表达式反射求值；需完整 JDK。

- 详细文档：[i2f-compiler](./i2f-jdk/i2f-compiler/readme.md)

### i2f-compress-std

> 压缩标准契约层：多文件归档级 `ICompressor` + 单流级 `ISingleCompressor` 双契约，`AbsCompressor` 沉淀文件遍历/流绑定/解包落地的公共骨架。

- 详细文档：[i2f-compress-std](./i2f-jdk/i2f-compress-std/readme.md)

### i2f-compress-impl

> 压缩 JDK 内置实现层（零三方运行期依赖）：归档级 Zip/Jar + 单流级 Gzip/Deflater/Zip 共 5 实现，全量落地 compress-std 双契约。

- 详细文档：[i2f-compress-impl](./i2f-jdk/i2f-compress-impl/readme.md)

### i2f-console-color

> ANSI 控制台彩色输出工具：3 枚举覆盖标准 SGR 参数（18 前景/18 背景/5 样式）+ `ConsoleOutput` 门面自动编排转义序列（合并与自动 RESET）+ 三态开关自动检测（IDEA/终端/Windows）。

- 详细文档：[i2f-console-color](./i2f-jdk/i2f-console-color/readme.md)

### i2f-container

> 集合容器增强工具族：`CollectionUtil` 约 300 方法全覆盖收集场景 + `RingQueue` 有界阻塞队列 + LRU 族 + 并发 Set + sync 同步包装族（12 适配器 + 模板/代理骨架）+ readonly 只读包装族。

- 详细文档：[i2f-container](./i2f-jdk/i2f-container/readme.md)

### i2f-container-builder

> 流式集合/Map/对象构建器族：`ObjectBuilder`（方法引用改 POJO）/`CollectionBuilder`/`ListBuilder`/`MapBuilder` + `Builders` 约 50 静态工厂，以 fluent 模式补齐 JDK 集合框架缺失的链式构造。

- 详细文档：[i2f-container-builder](./i2f-jdk/i2f-container-builder/readme.md)

### i2f-context-std

> IoC 容器标准契约层（4 个纯接口）：`IContext` 按类型查询 + `INamingContext` 按名查询 + 两个可写变体，构成「查询维度 × 读写性」2×2 正交矩阵。

- 详细文档：[i2f-context-std](./i2f-jdk/i2f-context-std/readme.md)

### i2f-context-impl

> IoC 容器纯 JDK 内存实现层：`ListableContext`（类型仓储，精确匹配优先、兼容匹配兜底）与 `ListableNamingContext`（名→Bean 双结构 + 读写锁），被 AI 栈与存储过程引擎消费。

- 详细文档：[i2f-context-impl](./i2f-jdk/i2f-context-impl/readme.md)

### i2f-convert

> 通用类型转换工具箱：以 `ObjectConvertor.tryConvertAsType` 覆盖 20+ 类型域的万能转换（源→目标双向匹配 + BigDecimal/Instant 归一化中转 + 字符串字面量解析 + 反射四级策略），另含列表⇄树双向转换子包。

- 详细文档：[i2f-convert](./i2f-jdk/i2f-convert/readme.md)

### i2f-crypto-std

> 加密/解密/摘要/签名标准契约层：5 接口（内建 Base64/Hex 默认方法）+ 5 个 `Bytes*Key` 字节适配密钥模型 + `AsymKeyPair` 密钥对流式序列化。

- 详细文档：[i2f-crypto-std](./i2f-jdk/i2f-crypto-std/readme.md)

### i2f-crypto-impl

> 加密/解密/摘要/签名 JDK 内置实现层：对称 8 算法 + 非对称 2 算法 + 签名 12 变体 + 摘要/HMAC/校验和三族，最底层 `Encryptor` 封装全部 JDK 安全 API 实例化，算法常量枚举消除字面量散落。

- 详细文档：[i2f-crypto-impl](./i2f-jdk/i2f-crypto-impl/readme.md)

### i2f-data-processor

> 数据读/写抽象处理器，基于 ILifeCycle 生命周期约束的逐条读写最小契约，提供 IDataReader/IDataWriter 双接口 + 2 个文本行 JDK IO 实现，被 i2f-check-filter 的大数据去重族消费。

- 详细文档：[i2f-data-processor](./i2f-jdk/i2f-data-processor/readme.md)

### i2f-datetime

> Java 日期时间一站式工具箱，零三方依赖以 Dates 静态门面 + fluent 实例 API 双模式提供格式解析、日期算术、边界计算、类型互转及时令判定；Calendars 内建中国农历生肖与干支纪年推算；被 i2f-number-idcard 消费。

- 详细文档：[i2f-datetime](./i2f-jdk/i2f-datetime/readme.md)

### i2f-design-pattern

> 设计模式教学演示模块：189 源文件系统化落地 5 大类 31 种设计模式（GoF 23 + 并发 4 + 架构 4），每模式以「场景实现 + Test 演示 + readme」四件套呈现，附总纲文档梳理定义与 JDK/Spring 典型案例。

- 详细文档：[i2f-design-pattern](./i2f-jdk/i2f-design-pattern/readme.md)

### i2f-detegate

> 「通用委托执行骨架」三件套（零状态静态门面）：`BatchDelegator` 分页批量拉取、`CacheDelegator` 读穿缓存、`FallbackDelegator` 重试 + 几何退避 + 降级容错。

- 详细文档：[i2f-detegate](./i2f-jdk/i2f-detegate/readme.md)

### i2f-dict

> 注解驱动的字典码值双向转换器：`@DictDecode`/`@DictEncode` 声明跨字段或就地映射 + `@Dict` 内联字典项（含 null 兜底），`DictResolver` 沿提供者链取字典强转写回。

- 详细文档：[i2f-dict](./i2f-jdk/i2f-dict/readme.md)

### i2f-enums

> 字典枚举契约 `IDict`（code/text/key/remark 四方法）与两个开箱即用的三值基础枚举 `Bool`/`YesNo`（未定义/真-是/假-否），零依赖。

- 详细文档：[i2f-enums](./i2f-jdk/i2f-enums/readme.md)

### i2f-environment-std

> 环境配置标准契约层：`IEnvironment` 只读契约（getProperty + 4 组类型安全 default getter）与 `IWritableEnvironment` 写入契约（setProperty + 4 setter）。

- 详细文档：[i2f-environment-std](./i2f-jdk/i2f-environment-std/readme.md)

### i2f-event

> 轻量级异步事件发布/订阅调度框架：单守护线程 + 无界队列 + 工作窃取线程池的异步批处理分发（批量攒批、订阅过滤、超期丢弃），支持空闲睡眠与线程属性定制。

- 详细文档：[i2f-event](./i2f-jdk/i2f-event/readme.md)

### i2f-environment-impl

> 环境配置契约的默认实现层：`SystemAdditionalEnvironment` 采集 15 项 JVM 运行时/编译/OS 信息快照并支持写覆盖，`ListableDelegateEnvironment` 提供多环境委托链（首个非空胜出）。

- 详细文档：[i2f-environment-impl](./i2f-jdk/i2f-environment-impl/readme.md)

### i2f-exception

> 语义化运行时异常词汇表：16 个直接继承 RuntimeException 的扁平异常类（长度/报文/类型/并发/数据访问/反射/远程/服务等场景），统一五构造器模板，零依赖。

- 详细文档：[i2f-exception](./i2f-jdk/i2f-exception/readme.md)

### i2f-features

> 能力标记接口集：cluster/concurrent/store/sync 四子包共 11 个空标记接口（分布式的/并发的/内存的/异步的等能力标签），供实现类打标 + `instanceof` 嗅探。

- 详细文档：[i2f-features](./i2f-jdk/i2f-features/readme.md)

### i2f-firewall

> 注入攻击防护防火墙：CRLF/Host/路径穿越/反序列化类名/SQL 注入/XSS/XXE 共 7 类断言式检测器（失败抛异常），检测引擎支持嵌套编码变体组合与 Decode 路线的地毯式匹配。

- 详细文档：[i2f-firewall](./i2f-jdk/i2f-firewall/readme.md)

### i2f-form

> 「Swing 模态对话框组件库 + 统一预览系统」：消息/确认/输入/单选/多选/倒计时 6 类模态窗口（CountDownLatch 同步阻塞）+ 现代扁平皮肤 + 图片/媒体/文本/网页 15 种预览实现（JavaFX 桥接）。

- 详细文档：[i2f-form](./i2f-jdk/i2f-form/readme.md)

### i2f-form-url-encoded

> 「form-urlencoded 编解码器 + URI 结构化解析器」：任意对象/嵌套 Map/集合与 form 串双向转换（点号路径扁平化协议），`UriMeta` 解析 8 类 URI 方言（http/jdbc/file/git@/Oracle 等）。

- 详细文档：[i2f-form-url-encoded](./i2f-jdk/i2f-form-url-encoded/readme.md)

### i2f-geo

> 地理坐标转换与米度概算工具：WGS84/GCJ-02/BD-09/WebMercator 等五大坐标系互转（含火星/百度偏移与反解）+ 米度概算，零依赖。

- 详细文档：[i2f-geo](./i2f-jdk/i2f-geo/readme.md)

### i2f-graphics-2d

> 二维图形学基础库（纯 JDK + AWT 零引擎依赖）：原语/形状层 + 方向旋转反射运算 + 贝塞尔采样 + 齐次变换 + 多边形工具 5 件套 + 投影/变换接口族 + Swing 画布与函数绘图。

- 详细文档：[i2f-graphics-2d](./i2f-jdk/i2f-graphics-2d/readme.md)

### i2f-graphics-3d

> 三维图形学基础库（纯 JDK + AWT/Swing）：3D 原语与齐次变换 + 10 种投影（三视图/正交/透视）+ 23 种变换 + Phong 光照材质 + 背面剔除 + 参数形状 13 个 + 三角化 + 交互画布。

- 详细文档：[i2f-graphics-3d](./i2f-jdk/i2f-graphics-3d/readme.md)

### i2f-graphics

> 二维/三维图形学能力聚合门面模块 —— 零源码纯聚合，将 `i2f-graphics-2d` 与 `i2f-graphics-3d` 经 `maven-assembly-plugin` 打包为单一 fat-jar，被 `i2f-jdk-all` 全仓聚合引入。

- 详细文档：[i2f-graphics](./i2f-jdk/i2f-graphics/readme.md)

### i2f-hash

> 非加密哈希算法工具箱：泛型 `IHashProvider<T>` 接口与序列化桥接基类 + 12 种经典非加密哈希算法（AP/BKDR/Boost/FNV/DJB/JS/PJW/SDBM 等），被 check-filter 的布隆与分组去重消费。

- 详细文档：[i2f-hash](./i2f-jdk/i2f-hash/readme.md)

### i2f-http-proxy

> 声明式 REST 客户端框架：`@RestClient` 接口 + JDK 动态代理 + 11 种自研注解构建声明式 HTTP 客户端，内置环境变量替换与可插拔 Processor/序列化/请求定制/响应抽取扩展点。

- 详细文档：[i2f-http-proxy](./i2f-jdk/i2f-http-proxy/readme.md)

### i2f-i18n

> 国际化消息工具集：`I18n` 静态门面 + SPI 三优先级初始化 + `InheritableThreadLocal` 线程语言上下文 + 自动文件扫描（properties/XML 双格式，XML 支持 ref 引用与 keep/only 格式控制）。

- 详细文档：[i2f-i18n](./i2f-jdk/i2f-i18n/readme.md)

### i2f-image-impl

> 图像滤镜与处理实现层：`ImageCompressor` 智能压缩 + LSB 隐写 + 28 种图像级滤镜 + 20 种像素级 RGBA 滤镜，被 `i2f-springboot-ops-starter` 的 OpenAiOpsController 消费。

- 详细文档：[i2f-image-impl](./i2f-jdk/i2f-image-impl/readme.md)

### i2f-image-std

> 图像处理标准接口与工具集：`ImageUtil` 图片 I/O + `FontUtil` 字体加载注册 + 三层过滤器接口体系（IImageFilter/PixelFilter/RgbaFilter）及双向桥接适配器。

- 详细文档：[i2f-image-std](./i2f-jdk/i2f-image-std/readme.md)

### i2f-invokable

> JDK 反射调用抽象层：`IInvokable` 最小调用契约 + `IMethod` 元数据扩展 + 4 种 JDK 反射包装（Method/Constructor/Executable/InstanceStatic）+ 装饰器与调用快照，被 antlr4 脚本引擎与 aspectj 消费。

- 详细文档：[i2f-invokable](./i2f-jdk/i2f-invokable/readme.md)

### i2f-io-stream

> Java 字节流操作工具集（纯 JDK）：`StreamUtil` 全能静态工具（拷贝/广播/范围/本地化）+ 校验和体系 + XOR 加密流体系 + 黑洞/白洞/懒加载/临时文件等特殊流；被全仓 25+ 模块消费。

- 详细文档：[i2f-io-stream](./i2f-jdk/i2f-io-stream/readme.md)

### i2f-io-file

> 全能文件操作工具集：`FileUtil` 全能静态工具（读写/拷贝/移动/删除/合并/分割/路径规约/树遍历/CSV 解析）+ `FileType` 魔数判定（76 种）+ MIME 映射（约 420 条）+ 文件种类分类器 + 应用级回收站；被全仓 22+ 模块消费。

- 详细文档：[i2f-io-file](./i2f-jdk/i2f-io-file/readme.md)

### i2f-io-filesystem

> 统一文件系统抽象层：`IFile`/`IFileSystem` 双契约 + `AbsFile`/`AbsFileSystem` 抽象基类（组合能力模板，实现方仅需约 10 个原语）+ 路径安全工具 + JDK 本地实现；被 6 个 `i2f-extension-filesystem-*` 模块继承消费。

- 详细文档：[i2f-io-filesystem](./i2f-jdk/i2f-io-filesystem/readme.md)

### i2f-iterator

> 迭代器三向适配与增强工具集：三门面实现 Iterator ↔ Iterable ↔ Enumeration 互转（覆盖 Stream/8 种原生数组/任意对象数组/Reader 行流）+ 5 装饰器（map/filter/peek/透传/懒加载）+ 资源生命周期模板 + 17 个数组迭代器。

- 详细文档：[i2f-iterator](./i2f-jdk/i2f-iterator/readme.md)

### i2f-javacode-graph

> Java 代码结构图生成模块：三步管线（反射解析类/字段/方法/构造器/注解节点树 → 关系图拍平 → ECharts graph 数据输出）产出可预览的类结构关系图。

- 详细文档：[i2f-javacode-graph](./i2f-jdk/i2f-javacode-graph/readme.md)

### i2f-jdbc-data

> JDBC 生态的数据契约地基（纯数据载体零执行逻辑）：连接元信息 `JdbcMeta` + 查询结果模型 `QueryResult`/`QueryColumn` + 类型化参数协议 `TypedArgument` + 存储过程命名输出参数四组共享模型。

- 详细文档：[i2f-jdbc-data](./i2f-jdk/i2f-jdbc-data/readme.md)

### i2f-jdbc-impl

> JDBC 体系的核心执行层：超级门面 `JdbcResolver`（连接/事务/查询家族/批处理/存储过程/游标/类型绑定/结果解析管线）+ 三组 SPI 注册表 + `JdbcTemplate` 会话委托模板与脚本执行器。

- 详细文档：[i2f-jdbc-impl](./i2f-jdk/i2f-jdbc-impl/readme.md)

### i2f-jdbc-std

> JDBC 体系的最小契约层 / 依赖倒置地基（3 接口 50 行）：连接获取上下文 `JdbcInvokeContextProvider` 生命周期抽象 + `SQLFunction`/`SQLBiFunction` SQL 感知函数式接口。

- 详细文档：[i2f-jdbc-std](./i2f-jdk/i2f-jdbc-std/readme.md)

### i2f-jdbc-bql

> BQL 的运行期落地层 / JDBC 执行门面：`BqlTemplate extends JdbcTemplate` 把 BQL 流式构建器物化后直接执行，含 Bean CRUD 快捷方法与继承的查询直通通道。

- 详细文档：[i2f-jdbc-bql](./i2f-jdk/i2f-jdbc-bql/readme.md)

### i2f-jdbc-proxy

> Mapper 接口的 JDBC 动态代理层（MyBatis Mapper 模式的独立实现）：参数名解析 + 会话委托 + 按返回类型分派 `JdbcResolver` + 五级 SQL 来源管线（BaseMapper 内建桥/缓存/@SqlScript/脚本渲染）。

- 详细文档：[i2f-jdbc-proxy](./i2f-jdk/i2f-jdbc-proxy/readme.md)

### i2f-jdbc-proxy-xml

> MyBatis 风格的 XML 动态 SQL 引擎（Mapper XML 独立重实现）：`MybatisMapperParser` 节点树解析 + 解释器（15 种脚本标签/foreach 多形态/占位符/组件与 SPI 扩展），默认内存编译表达式且 OGNL 变体可换。

- 详细文档：[i2f-jdbc-proxy-xml](./i2f-jdk/i2f-jdbc-proxy-xml/readme.md)

### i2f-jdbc-procedure

> XML 存储过程 / 工作流引擎（XProc4J）——「去数据库存储过程」的核心业务引擎：XML 解析 → 元信息 → 执行器（77 内置节点三通道注册 + 事务/连接缓存/慢监控）+ Java/XML 过程统一注册。

- 详细文档：[i2f-jdbc-procedure](./i2f-jdk/i2f-jdbc-procedure/readme.md)

### i2f-database

> 数据库能力聚合门面模块，零源码纯聚合，将 `i2f-database-type`（方言类型识别）与 `i2f-database-metadata-impl`（元数据多方言实现）经 `maven-assembly-plugin` 打包为单一 fat-jar。

- 详细文档：[i2f-database](./i2f-jdk/i2f-database/readme.md)

### i2f-database-metadata-bean

> Java Bean ↔ 数据库元数据映射层：从 @Table/@Column/@Primary 等注解标注的 POJO 反射解析为 `TableMeta` 数据模型，并支持反向从 `TableMeta` 生成带注解的 Java Bean 源码。

- 详细文档：[i2f-database-metadata-bean](./i2f-jdk/i2f-database-metadata-bean/readme.md)

### i2f-database-metadata-data

> 数据库元数据数据模型与类型系统层：`TableMeta`/`ColumnMeta`/`IndexMeta`/`IndexColumnMeta` 四级 POJO + `StdType` 标准化类型枚举（34 常量）+ 方言类型映射接口。

- 详细文档：[i2f-database-metadata-data](./i2f-jdk/i2f-database-metadata-data/readme.md)

### i2f-database-metadata-std

> 数据库元数据标准契约层：定义 `DatabaseMetadataProvider`（JDBC 元数据读取器）与 `DatabaseReverseEngineer`（DDL 反向生成器）双接口，被多方言实现与逆向生成器消费。

- 详细文档：[i2f-database-metadata-std](./i2f-jdk/i2f-database-metadata-std/readme.md)

### i2f-database-metadata-impl

> 数据库元数据多方言实现层：以模板方法 + 委拖代理双架构提供 9 种方言的 JDBC 元数据读取器（MySQL/Oracle/DM/Gbase/H2/PostgreSQL/SQLite3/SQL Server/通用）+ 5 方言 DDL 反向生成器。

- 详细文档：[i2f-database-metadata-impl](./i2f-jdk/i2f-database-metadata-impl/readme.md)

### i2f-database-dialect

> SQL 字面量方言安全转换器：以模板方法 + 9 方言实现将 Java 对象（日期/数值/字符串/布尔）转换为各数据库方言兼容的 SQL 字面量字符串，被 `i2f-bindsql-stringify` 作为底层文本化引擎消费。

- 详细文档：[i2f-database-dialect](./i2f-jdk/i2f-database-dialect/readme.md)

### i2f-launcher

> 轻量级应用启动器 / 外置 classpath 加载器：`Main-Class` 指向 `ExtApplicationLauncher`，运行期读 `Ext-Main-Class`/`Ext-Path` 经 child-first classloader 加载外置目录与 jar 后反射调用真实入口，适配插件化与动态 SPI 加载。

- 详细文档：[i2f-launcher](./i2f-jdk/i2f-launcher/readme.md)

### i2f-log-std

> 日志标准门面层：统一大门面 `ILogger`（6 级别 × 多种入参形态数百 default 方法收敛到 2 个抽象 write）+ `LoggerFactory` 多路径解析可插拔 `LoggerProvider`（内置彩色 `StdioLogger` 兜底）。

- 详细文档：[i2f-log-std](./i2f-jdk/i2f-log-std/readme.md)

### i2f-log

> `i2f-log-std` 门面的默认完整实现层：全局/线程双路由组件注册表 `LogHolder` + ANSI 彩色格式化 + 多目标异步广播写出（控制台/本地滚动文件/JDBC 表）+ `System.out` 收编 + log.properties 一键装配。

- 详细文档：[i2f-log](./i2f-jdk/i2f-log/readme.md)

### i2f-jvm

> JVM 运行环境探测工具（单类 `JvmUtil` 约 100 行）：进程 PID/启动参数直通与 debug/-javaagent/verify 三大启动参数特征检测，无锁惰性缓存；被 9 模块消费（调试桥门控 14 处）。

- 详细文档：[i2f-jvm](./i2f-jdk/i2f-jvm/readme.md)

### i2f-lifecycle

> 统一生命周期契约模块（1 接口 + 1 异常约 50 行）：`ILifeCycle` 三动词 create/destroy/close（close 桥接 destroy 兼容 try-with-resources）+ `LifeCycleException` 失败信号。

- 详细文档：[i2f-lifecycle](./i2f-jdk/i2f-lifecycle/readme.md)

### i2f-limit

> 按 key 限流器模块：新线单动词 `Limiter.require` + 令牌桶 `TokenBucketLimiter`（按名分桶 + 守护线程补充/清理），旧线三动词 `IKeyedLimiter`（失败锁定 + 令牌补充两实现）。

- 详细文档：[i2f-limit](./i2f-jdk/i2f-limit/readme.md)

### i2f-lock

> 锁抽象契约模块（框架无关）：`ILock`/`INotify`/`INotifyLock`/`IReadWriteLock`/`ILockProvider` 五接口 + JDK 三实现线（ReentrantLock / 读写锁 / 按 key 懒建锁提供者）。

- 详细文档：[i2f-lock](./i2f-jdk/i2f-lock/readme.md)

### i2f-os

> 操作系统工具模块：`OsUtil` 跨平台命令执行四形态 + Windows PowerShell 封装 + `PerfUtil` 按平台分发 CPU/内存/磁盘采集（Linux top/free/df，Windows WMIC 映射 14 类 DTO）。

- 详细文档：[i2f-os](./i2f-jdk/i2f-os/readme.md)

### i2f-packet

> 二进制流封包协议模块（纯 JDK 零依赖）：`EE EE` 引导 + `EF` 转义的流式帧协议（多 head/多 body/tail 校验），`PacketProtocol` 映射 HTTP 风格头，512KB 阈值自适应内存/临时文件。

- 详细文档：[i2f-packet](./i2f-jdk/i2f-packet/readme.md)

### i2f-page

> 分页数据模型模块：`ApiOffsetSize`（偏移/大小/排他结束下标）+ `ApiPage`（零基页索引与一基页号转换）+ `Page<T>` 结果承载，构成 JDBC/MyBatis/ES/脚本统一分页契约。

- 详细文档：[i2f-page](./i2f-jdk/i2f-page/readme.md)

### i2f-pool

> 对象池与分段并发原语模块（纯 JDK）：队列缓存对象池 `ObjectPool` + 分段对象提供者 / 分段锁 / `String.intern` 分段同步族。

- 详细文档：[i2f-pool](./i2f-jdk/i2f-pool/readme.md)

### i2f-properties

> Properties 配置装载模块：`PropertiesUtil` 单门面提供「点分键树化 + 键风格归一 + Visitor 前缀定位 + RichConverter 强转」的「properties → 强类型 Bean」装载管线。

- 详细文档：[i2f-properties](./i2f-jdk/i2f-properties/readme.md)

### i2f-proxy-std

> 代理标准契约层：`IProxyHandler` 五阶段钩子（before 短路/after 改写/except 替换）+ 函数式 `IProxyInvocationHandler` + default 方法 MethodHandles 兼容，JDK/CGLIB/AspectJ 统一代理契约。

- 详细文档：[i2f-proxy-std](./i2f-jdk/i2f-proxy-std/readme.md)

### i2f-proxy

> JDK 动态代理实现模块：`JdkProxyUtil` 六重载门面（三契约 × 实例/接口双形态）+ normal/interfaces 双适配器 + 双 Provider + 五阶段解包骨架。

- 详细文档：[i2f-proxy](./i2f-jdk/i2f-proxy/readme.md)

### i2f-proxy-handlers

> 注解驱动的代理处理器模块：`@Lock`/`@Retry`/`@Validate` 三大横切语义落地为可直接挂动态代理的 `IProxyInvocationHandler`（含 15 校验注解族标签化递归校验）。

- 详细文档：[i2f-proxy-handlers](./i2f-jdk/i2f-proxy-handlers/readme.md)

### i2f-reference

> 值的三态引用包装（单类 183 行、零依赖）：VALUE/NOP/FINISH 三态显式区分「有值/值为 null/跳过/终止」四义，被 iterator/container 直接依赖并传递至 9 模块消费。

- 详细文档：[i2f-reference](./i2f-jdk/i2f-reference/readme.md)

### i2f-reflect

> 全仓反射能力中央底座：`ReflectResolver` 单类 3414 行七大能力族（类加载/字段方法发现/注解解析/调用匹配/值读写/Bean 复制/虚拟字段）+ RichConverter 泛型强转 + 点分路由 + 签名还原 + vistor 表达式引擎。

- 详细文档：[i2f-reflect](./i2f-jdk/i2f-reflect/readme.md)

### i2f-resources

> 「资源定位与类路径扫描」工具箱：`ResourceUtil` 六态位置协议解析 + `ResourcesLoader` 全类路径扫描引擎（目录递归/jar 流/嵌套 jar 解包/manifest 补全/前缀排除/最短收缩）。

- 详细文档：[i2f-resources](./i2f-jdk/i2f-resources/readme.md)

### i2f-resp

> 统一 API 响应契约模块：`ApiResp<T>`（code/msg/data + 惰性 kvs 扩展 + 链式与静态工厂）+ `ApiCode` 七码常量，被 spring-starter 默认装配为全局响应包装/异常转换/404 转换器。

- 详细文档：[i2f-resp](./i2f-jdk/i2f-resp/readme.md)

### i2f-robot

> AWT 桌面自动化工具（单类 `RobotUtil` 约 165 行、纯 JDK）：多屏枚举与主屏截屏/存图/取色 + 单键与组合键模拟 + 左中右键点击与插值拖拽。

- 详细文档：[i2f-robot](./i2f-jdk/i2f-robot/readme.md)

### i2f-rowset

> 表格行集流式读写契约：`IRowSet`（Iterator + Closeable）与 CSV 引号状态机读写（类型自动推断 + 长数字防科学计数），JSON 数组/JSONL 抽象写出注入 JSON 库。

- 详细文档：[i2f-rowset](./i2f-jdk/i2f-rowset/readme.md)

### i2f-script

> JSR-223 脚本引擎统一门面：`ScriptProvider` 聚合 ScriptEngine/Invocable/Compilable 三接口（compile/invoke 前置特性探测守卫）；唯一消费方 xproc4j 的 JavaScript 求值节点。

- 详细文档：[i2f-script](./i2f-jdk/i2f-script/readme.md)

### i2f-search

> 极简前缀索引树（Trie）双形态：`PrefixSearchTree<T,D>` 泛型键序列版 + `StringSearchTree<D>` String 特化版，基于 `ConcurrentSkipListMap` 的 add/find/prefix/collect/printTree。

- 详细文档：[i2f-search](./i2f-jdk/i2f-search/readme.md)

### i2f-serialize-impl

> 序列化契约的官方实现层：零第三方自研 JSON 引擎 `Json2`（17 处实例化为全仓默认引擎）+ JDK 原生字节序列化 + XML 只写生成 + 自描述文本格式。

- 详细文档：[i2f-serialize-impl](./i2f-jdk/i2f-serialize-impl/readme.md)

### i2f-serialize-std

> 序列化标准契约层：`ISerializer` 双动词统一「对象↔字节/文本」双通道九接口 + 类型化反序列化三级重载 + Base64 便捷 + 双向适配器；被 26 模块 77 文件消费。

- 详细文档：[i2f-serialize-std](./i2f-jdk/i2f-serialize-std/readme.md)

### i2f-sm-crypto

> 纯 Java 国密算法实现库：SM2（加解密/签名验签，C1C3C2 与 DER）/ SM3（杂凑与 HMAC）/ SM4（ECB/CBC）全自研三层结构，零密码学三方依赖；被 SWL 国密适配与 ops-starter 消费。

- 详细文档：[i2f-sm-crypto](./i2f-jdk/i2f-sm-crypto/readme.md)

### i2f-sm-crypto-swl

> SWL 安全传输协议族的纯 Java 国密适配层：以适配器模式把 i2f-sm-crypto 包装为 SWL 三大契约 + 3 个 Supplier 工厂，成为 SWL「JDK 默认 / 国密 / BouncyCastle」三套可互换实现中的国密一极。

- 详细文档：[i2f-sm-crypto-swl](./i2f-jdk/i2f-sm-crypto-swl/readme.md)

### i2f-std-const

> 全仓统一的「运行时目录约定」常量词汇表：以 `runtime` 为组合根派生 persist（跨次保留资产）与 tmp（可清理临时产物）两大类目录，被 14 模块 17 文件消费。

- 详细文档：[i2f-std-const](./i2f-jdk/i2f-std-const/readme.md)

### i2f-streaming

> 函数式流式处理框架（JDK8 从零实现的类 Stream 惰性管道、零依赖）：`Streaming<E>` 接口百余方法 + 唯一实现类，含四态引用协议、迭代器工具箱、并行模型、rich 上下文注入与元素窗口。

- 详细文档：[i2f-streaming](./i2f-jdk/i2f-streaming/readme.md)

### i2f-swl

> SWL（Secure Wire Layer）安全网络层的默认实现层与协议引擎：无状态 `SwlExchanger` 收发流水线（时间戳窗口→nonce 防重放→摘要→数字签名→双加密）+ `SwlTransfer` 会话 + 证书链 + JDK 四件密码学实现。

- 详细文档：[i2f-swl](./i2f-jdk/i2f-swl/readme.md)

### i2f-swl-std

> SWL 安全传输协议族的纯契约层 / 密码学 SPI 标准：4 能力接口（非对称/对称/摘要/混淆）+ 3 个 Supplier 类型别名 + 36 常量错误码枚举，为三套密码学实现提供依赖倒置契约。

- 详细文档：[i2f-swl-std](./i2f-jdk/i2f-swl-std/readme.md)

### i2f-template-render

> 基于正则表达式的轻量级文本模板渲染引擎（纯 JDK）：「控制表达式」两阶段渲染管线 + 11 种动作（for/fori/if/tpl/cmd 等）+ 上下文变量（item/root/ctx）+ 路由取值与 @方法转换链。

- 详细文档：[i2f-template-render](./i2f-jdk/i2f-template-render/readme.md)

### i2f-text

> 通用文本/字符串工具库（零三方依赖）：`StringUtils` 判空/清洗/命名风格转换 + `Appender` 泛型链式拼装 DSL + `CnNumber` 中文数字读法 + `Escapes` 转义 + RLE 压缩 + 星号脱敏。

- 详细文档：[i2f-text](./i2f-jdk/i2f-text/readme.md)

### i2f-thread

> 纯 JDK 并发编程工具箱：并行求值 `Asyncs`、跨线程消息等待、异步串行队列、CPU 反馈动态线程池、DAG 编排、命名线程工厂等一站式基础设施。

- 详细文档：[i2f-thread](./i2f-jdk/i2f-thread/readme.md)

### i2f-trace

> 调用点感知基础设施：基于线程栈回溯的 `ThreadTrace`（栈切片定位调用方 + 调用点类名/方法/文件/行号反射还原），被日志体系 3 模块消费。

- 详细文档：[i2f-trace](./i2f-jdk/i2f-trace/readme.md)

### i2f-trace-mdc

> MDC（Mapped Diagnostic Context）上下文容器与跨线程传播基础设施：`MdcHolder` 三级选择的存储门面 + 标准 traceId 键 + 完整线程传播装饰器族（Runnable/Callable/Executor/ThreadFactory）。

- 详细文档：[i2f-trace-mdc](./i2f-jdk/i2f-trace-mdc/readme.md)

### i2f-translate

> 翻译器系列的契约层 + 基础转换器：`ITranslator` 统一接口（extends ILifeCycle）+ 全角/半角双向映射表 + 声调→ASCII 表三组无状态转换器。

- 详细文档：[i2f-translate](./i2f-jdk/i2f-translate/readme.md)

### i2f-translate-en2zh

> 英文标识符→中文注释的「行业词典优先」翻译器：正则逐词替换 + 标识符启发式还原（缩写规范化/蛇形分段/后缀剥离）+ 内置 SQLite FTS3 词典（首用自动释放到 runtime/persist）。

- 详细文档：[i2f-translate-en2zh](./i2f-jdk/i2f-translate-en2zh/readme.md)

### i2f-translate-zh2pinyin

> 中文→拼音 / 简繁双向转换的零配置翻译器：逐字查表 + 声调双模式（保留声调符或转纯 ASCII）+ 内置 SQLite FTS3 词典（首用自动释放）+ 容量 LRU 缓存。

- 详细文档：[i2f-translate-zh2pinyin](./i2f-jdk/i2f-translate-zh2pinyin/readme.md)

## i2f-jdk-ext

> 基于 javax.servlet 规范的 Web 层扩展模块集合，提供安全过滤器矩阵、Web 防火墙、失败锁定守卫与 Servlet 上下文 / 文件 / 包装器基础设施。

### i2f-jdk-ext-web

> Servlet 层 Web 增强套件：过滤器矩阵（Security/Trace/耗时统计）+ Web 防火墙（字符 × 编码变体交叉断言）+ 失败锁定守卫 + Servlet 上下文/文件 Range 下载/包装器（body 可重复读）一站式横切能力层。

- 详细文档：[i2f-jdk-ext-web](./i2f-jdk-ext/i2f-jdk-ext-web/readme.md)

### i2f-jdk-ext-swl

> SWL 安全传输协议的 Servlet 过滤器接入层：请求侧「四头取值 + URL 防篡改校验 + 解密重建」，响应侧「全量缓冲 + 加密回写」，对业务透明的「请求解密 + 响应加密」适配底座。

- 详细文档：[i2f-jdk-ext-swl](./i2f-jdk-ext/i2f-jdk-ext-swl/readme.md)

### i2f-jdk-ext-all

> i2f-jdk-ext 子模块的 Maven 聚合分发包，将 `i2f-jdk-ext-swl` 与 `i2f-jdk-ext-web` 经 `maven-assembly-plugin` 打包为单体 fat-jar 的构建入口。

- 详细文档：[i2f-jdk-ext-all](./i2f-jdk-ext/i2f-jdk-ext-all/readme.md)

## i2f-spring

> Spring 生态集成模块集合，封装 Spring 核心、MVC、安全、Redis、Web 等能力的增强与元数据解析。

### i2f-spring-all

> i2f-spring 子模块的 Maven 聚合分发 fat-jar（纯 pom、无源码）：以 7 枚 compile 依赖聚合本组 authentication/core/redis/security/swl/web 等全部模块（版本由根 DM 锁定），继承根 pom assembly 产 jar-with-dependencies，作统一依赖入口。瑕疵：残留注释自依赖易成循环依赖。

- 详细文档：[i2f-spring-all](./i2f-spring/i2f-spring-all/readme.md)

### i2f-spring-authentication

> Spring Security/Shiro 认证结果的统一出口控制器（单类 SecurityForwardController）：映射 /forward/response，承接安全过滤器链 forward 的登录成功/失败/登出/鉴权结果，纳入统一 ApiResp JSON 序列化。瑕疵：部分分支死代码、printStackTrace 绕过日志、未限定 HTTP 方法。

- 详细文档：[i2f-spring-authentication](./i2f-spring/i2f-spring-authentication/readme.md)

### i2f-spring-core

> Spring 基础能力到 i2f 契约的桥接基座（22 主源）：SpringContext/SpringEnvironment/CglibProxyProvider/AntPathMatcher 落地四大契约，附 SpringUtil、事务、SpEL、扫描等工具，被 10+ starter 消费，核心装配 SpringCoreAutoConfiguration。瑕疵：Event source 自赋值恒 null、双发布、事务超时二次提交冲突。

- 详细文档：[i2f-spring-core](./i2f-spring/i2f-spring-core/readme.md)

### i2f-spring-mvc-metadata

> 基于反射解析 Spring MVC Controller 的 API 元数据，提取 URL、HTTP 方法、参数、返回值与 Swagger 注释，为 API 文档生成提供结构化数据。

- 详细文档：[i2f-spring-mvc-metadata](./i2f-spring/i2f-spring-mvc-metadata/readme.md)

### i2f-spring-redis

> IRedisClient 契约的 Spring Data Redis 适配器（单类 SpringRedisClient）：持有 RedisTemplate+可选 prefix，将 21 个 String/List/Hash/TTL 方法一一映射到 opsForXxx；消费方 redis-starter 以 @ConditionalOnMissingBean 注册。瑕疵：hashGetAll 恒返空 map、listSet 二次 wrapKey 读错键、flushDb 连接泄漏。

- 详细文档：[i2f-spring-redis](./i2f-spring/i2f-spring-redis/readme.md)

### i2f-spring-security

> Spring Security 认证上下文与密码编码的极薄工具（3 主源）：SecurityUtil 门面取上下文/认证/principal/权限，SecurityCryptoUtil 提供 BCrypt 单例与便捷编解码，SpringPasswordEncoder 适配 IPasswordEncoder。瑕疵：未认证时 getPrincipal 无兜底致 NPE、强转未检查。

- 详细文档：[i2f-spring-security](./i2f-spring/i2f-spring-security/readme.md)

### i2f-spring-swl

> SWL 透明加解密的 Spring MVC 切面件（3 主源）：两个 @ControllerAdvice 将 SwlExchanger（RSA+AES+签名+防重放）接入 MVC 读写管线，按 @SwlCtrl 逐方法开关，统一 SwlData 信封收发。瑕疵：两 Advice 字段重复无 @Autowired、空列表越界、非 servlet 线程强转 NPE。

- 详细文档：[i2f-spring-swl](./i2f-spring/i2f-spring-swl/readme.md)

### i2f-spring-web

> Spring Web MVC/WebFlux 工具箱 + i2f-network REST 契约的 RestTemplate 落地（13 主源）：SpringMvcUtil/WebfluxContextUtil 双栈上下文、MappingUtil 路由反查、HttpProxy 反代、SpringWebRestClient 落地 IRestClient、三类 MultipartFile 适配。瑕疵：include 误调 forward、代理响应泄漏、isEmpty 语义反转。

- 详细文档：[i2f-spring-web](./i2f-spring/i2f-spring-web/readme.md)

## i2f-extension

> 可选扩展能力集合，按需集成第三方库与增强组件（7z 压缩、AI、文档、数据库反向工程、文件系统、序列化、ANTLR4 语言引擎、Java Agent 字节码增强观测等）。

### i2f-extension-7zip

> 基于 SevenZipJBinding 的 7z 归档压缩器实现：`SevenZCompressor` 落地 `i2f-compress-std` 的 `ICompressor` 契约，复用 `AbsCompressor` 骨架把目录树打包为 `.7z`（可选密码、头加密）或解包回目录。

- 详细文档：[i2f-extension-7zip](./i2f-extension/i2f-extension-7zip/readme.md)

### i2f-extension-ai-dashscope

> 阿里云百炼（DashScope）官方 SDK 的 `i2f-ai-std` 契约实现：对话（qwen-plus）/文本向量化/重排序三组契约 + function-calling 自循环 + `@Tool` 注解桥接；SDK 以 provided + optional 引入。

- 详细文档：[i2f-extension-ai-dashscope](./i2f-extension/i2f-extension-ai-dashscope/readme.md)

### i2f-extension-ai-langchain4j8

> 面向 Java 8 的 langchain4j 0.31.0 版 `i2f-ai-std` 契约实现：对话/模型/RAG 三件套复用 langchain4j 原生类型对接任意 OpenAI 兼容端点（默认百炼 qwen-plus）+ function-calling 自循环；provided + optional。

- 详细文档：[i2f-extension-ai-langchain4j8](./i2f-extension/i2f-extension-ai-langchain4j8/readme.md)

### i2f-extension-ai-openai

> 官方 OpenAI Java SDK 4.28.0 的 `i2f-ai-std` 契约实现：对话/模型/向量化三组契约对接 OpenAI 与任意兼容端点 + function-calling 自循环 + `@Tool` 注解桥接；provided + optional。

- 详细文档：[i2f-extension-ai-openai](./i2f-extension/i2f-extension-ai-openai/readme.md)

### i2f-extension-ai-rag-sqlite

> sqlite-vec 原生扩展版的 RAG 存储层实现：单库 `SqliteRagEmbeddingStore` + 分桶记忆 `BucketRagEmbeddingStore` 双契约落地本地向量库（vec0 虚拟表 + KNN 检索），原生扩展自动释放。

- 详细文档：[i2f-extension-ai-rag-sqlite](./i2f-extension/i2f-extension-ai-rag-sqlite/readme.md)

### i2f-extension-all

> i2f-extension 子模块的 Maven 聚合分发 fat-jar（纯 pom、无源码）：以 81 枚 compile 依赖「一处声明、整组引入」聚合本组全部功能模块（版本由根 DM 锁定），全继承根 pom assembly，是全仓规模最大的组级门面。瑕疵：残留注释自依赖易成循环依赖、合并时同名 services 后者胜。

- 详细文档：[i2f-extension-all](./i2f-extension/i2f-extension-all/readme.md)

### i2f-extension-antlr4

> ANTLR4 语言族（calculator + tinyscript + funic）的 Maven 聚合分发模块，将三个子模块及传递依赖打包为单体 fat-jar，是 xproc4j 系的统一依赖入口。

- 详细文档：[i2f-extension-antlr4](./i2f-extension/i2f-extension-antlr4/readme.md)

### i2f-extension-antlr4-calculator

> 基于 ANTLR4 的计算器表达式解析与求值模块：设计为 `Calculator.eval(String)` → BigDecimal 一步式求值（算术 + 多参数函数调用）；主源码与文法文件缺失，当前为不可构建的占位模块。

- 详细文档：[i2f-extension-antlr4-calculator](./i2f-extension/i2f-extension-antlr4-calculator/readme.md)

### i2f-extension-antlr4-funic

> 基于 ANTLR4 的「脚本引擎 + 模板引擎」双语言模块（Funic + Funvi）：静态门面 + 语法树缓存 + 可扩展 Resolver + 值对象体系 + 沙箱/代理双安全方案；被 xproc4j 与 IDEA 插件消费。

- 详细文档：[i2f-extension-antlr4-funic](./i2f-extension/i2f-extension-antlr4-funic/readme.md)

### i2f-extension-antlr4-tinyscript

> 基于 ANTLR4 的嵌入式迷你脚本语言引擎（TinyScript）：`TinyScript.script()` 静态门面 + 语法树缓存 + Resolver 扩展点 + 内建方法注册表；被 xproc4j 与 IDEA 插件消费。

- 详细文档：[i2f-extension-antlr4-tinyscript](./i2f-extension/i2f-extension-antlr4-tinyscript/readme.md)

### i2f-extension-aspectj

> AspectJ 连接点与 i2f-proxy 统一代理模型之间的桥接层：把 `@Around` 切面的 `ProceedingJoinPoint` 经 JDK 动态代理包装为编程式执行点（可读方法/改写参数/短路返回）；aspectjweaver 以 provided 引入。

- 详细文档：[i2f-extension-aspectj](./i2f-extension/i2f-extension-aspectj/readme.md)

### i2f-extension-asr-vosk

> 基于 Vosk 的本地离线语音识别门面：`AsrVoskProvider` 把「模型获取→释放到 runtime/persist→初始化→WAV 解码→分帧识别」收敛为 4 个静态方法；vosk/jna 以 provided 引入。

- 详细文档：[i2f-extension-asr-vosk](./i2f-extension/i2f-extension-asr-vosk/readme.md)

### i2f-extension-browser-playwright

> 基于 Microsoft Playwright 的浏览器自动化搜索抓取扩展：驱动工厂/四层持有者/网络屏蔽与 DOM 清洗 + 五大搜索引擎同构实现（阶段队列爬行 + 配额截断）；playwright 以 provided + optional 引入。

- 详细文档：[i2f-extension-browser-playwright](./i2f-extension/i2f-extension-browser-playwright/readme.md)

### i2f-extension-browser-selenium

> 基于 Selenium WebDriver 的浏览器自动化搜索抓取扩展：Edge/Chrome 双引擎驱动工厂（内置 driver 释放 + 版本不匹配 CDN 下载）+ CDP 网络拦截/DOM 清洗 + 五大搜索引擎同构搜索类。

- 详细文档：[i2f-extension-browser-selenium](./i2f-extension/i2f-extension-browser-selenium/readme.md)

### i2f-extension-caffeine

> Caffeine（2.9.3，provided）本地缓存契约适配：CaffeineCache 落地 IContainerCache（maximumSize 容量淘汰 + null 占位包装），CaffeineExpireCache 落地 IExpireContainerCache——借 Caffeine 原生 per-entry Expiry 直接实现逐条 TTL，无需 Guava 式后台清扫线程；与 guava、hazelcast、redis-cache 同属 cache 契约实现族。

- 详细文档：[i2f-extension-caffeine](./i2f-extension/i2f-extension-caffeine/readme.md)

### i2f-extension-canal

> 基于 Alibaba Canal 的 MySQL Binlog 订阅消费模板：`CanalClient` 模板方法封装「连接→订阅→轮询→解析→分发」骨架，子类只需重写 insert/delete/update 三个钩子；canal 依赖 provided + optional。

- 详细文档：[i2f-extension-canal](./i2f-extension/i2f-extension-canal/readme.md)

### i2f-extension-cglib

> 基于 CGLIB 字节码增强的 `IProxyProvider` 代理实现：`CglibUtil` 六重载门面 + Adapter 桥接 `IProxyInvocationHandler`；cglib 以 provided + optional 引入，与 JDK 动态代理/AspectJ 共享统一契约。

- 详细文档：[i2f-extension-cglib](./i2f-extension/i2f-extension-cglib/readme.md)

### i2f-extension-compress

> 基于 Apache Commons Compress 的归档压缩适配层：ZIP/JAR/TAR/CPIO/7Z 五种格式的 `ICompressor` 桥接实现（继承 `AbsCompressor` 骨架免费获得组合能力）。

- 详细文档：[i2f-extension-compress](./i2f-extension/i2f-extension-compress/readme.md)

### i2f-extension-cron

> 基于 cron-utils 的嵌入式单机 CRON 任务调度器：`CronUtil` 三方言解析与执行时间计算 + `CronExecutor` 三池分离调度（扫描/触发/执行）；cron-utils 以 provided + optional 引入。

- 详细文档：[i2f-extension-cron](./i2f-extension/i2f-extension-cron/readme.md)

### i2f-extension-document

> 基于 Aspose 与 PDFBox 生态的办公文档格式转换与处理套件：Word/Excel 20+ 格式互转 + Velocity 模板渲染导出 + documents4j COM 转换（仅 Windows）+ PDFBox 文本提取与逐页 PNG 渲染。

- 详细文档：[i2f-extension-document](./i2f-extension/i2f-extension-document/readme.md)

### i2f-extension-easyexcel

> 基于 Alibaba EasyExcel 的 Excel 导入/导出工具套件：导入导出双门面 + 循环分页引擎（自动分 sheet）+ 7 种数据提供器策略 + `@ExcelCellStyle` 注解驱动样式 + 转换器注册中心。

- 详细文档：[i2f-extension-easyexcel](./i2f-extension/i2f-extension-easyexcel/readme.md)

### i2f-extension-elasticsearch

> 基于 ES RestHighLevelClient 7.6.2 的索引/文档/查询操作封装套件：`EsManager` 三层门面（客户端/索引/CRUD/批量/搜索）+ `EsBeanManager` 注解映射 + SQL-like 查询构建器 + Spring Data 桥接。

- 详细文档：[i2f-extension-elasticsearch](./i2f-extension/i2f-extension-elasticsearch/readme.md)

### i2f-extension-email

> 基于 JavaMail 的邮件发送工具门面：`directSend` 一键发信与分步装配 + 流式 Builder 配置（预设 20+ 邮箱服务商 SMTP 常量）+ SSL/认证/多收件人 + 纯文本/HTML + 多附件。

- 详细文档：[i2f-extension-email](./i2f-extension/i2f-extension-email/readme.md)

### i2f-extension-fastexcel

> 基于 cn.idev.excel（fastexcel 1.2.0）的 Excel 导入/导出工具套件：与 i2f-extension-easyexcel 同构架构、底层引擎切换为 fastexcel（分页引擎/提供器策略/注解样式/转换器注册中心）。

- 详细文档：[i2f-extension-fastexcel](./i2f-extension/i2f-extension-fastexcel/readme.md)

### i2f-extension-fastjson

> 基于 fastjson1 兼容包（`com.alibaba:fastjson:2.0.26`，实由 fastjson2 引擎驱动）的 `IJsonSerializer` 契约适配器：三路类型化反序列化分派 + `INSTANCE` 单例；与 fastjson2 模块为可替换双实现。

- 详细文档：[i2f-extension-fastjson](./i2f-extension/i2f-extension-fastjson/readme.md)

### i2f-extension-fastjson2

> 基于原生 fastjson2（2.0.34）的 `IJsonSerializer` 契约适配器：三路类型化反序列化分派 + `INSTANCE` 单例；与 fastjson1 兼容包模块为可替换双实现，面向新项目优先推荐。

- 详细文档：[i2f-extension-fastjson2](./i2f-extension/i2f-extension-fastjson2/readme.md)

### i2f-extension-filesystem-ftp

> 基于 Apache Commons Net FTPClient 的 `IFileSystem` 契约适配器：把 FTP 协议装配为统一文件系统契约（11 操作原语 + 继承 40+ 组合能力），默认每操作新建连接规避流传输应答残留。

- 详细文档：[i2f-extension-filesystem-ftp](./i2f-extension/i2f-extension-filesystem-ftp/readme.md)

### i2f-extension-filesystem-hdfs

> 基于 Apache Hadoop FileSystem 客户端（hadoop-client 3.2.1）的 `IFileSystem` 契约适配器：薄封装直通 HDFS（三态元信息/三路流/递归 mkdir），注意 Hadoop 全局静态缓存按 scheme+authority+user 跨实例共享。

- 详细文档：[i2f-extension-filesystem-hdfs](./i2f-extension/i2f-extension-filesystem-hdfs/readme.md)

### i2f-extension-filesystem-minio

> 基于 MinIO Java SDK 的 `IFileSystem` 契约适配器：MinIO/S3 对象存储装配为统一契约（桶/键两级拆分 + `.ignore` 占位模拟目录）；写通道需用 `getOutputStream` 规避 `store()` 已知缺陷。

- 详细文档：[i2f-extension-filesystem-minio](./i2f-extension/i2f-extension-filesystem-minio/readme.md)

### i2f-extension-filesystem-oss-aliyun

> 基于阿里云 OSS Java SDK 的 `IFileSystem` 契约适配器：桶/键两级拆分 + 同桶 `moveTo` 走服务端 rename；写通道全可用（未知长度流自动 chunked 传输）。

- 详细文档：[i2f-extension-filesystem-oss-aliyun](./i2f-extension/i2f-extension-filesystem-oss-aliyun/readme.md)

### i2f-extension-filesystem-oss-aws-s3

> 基于 AWS SDK v2 S3 的 `IFileSystem` 契约适配器：桶/键两级拆分 + 服务端 copyObject，签名全程 AWS4-HMAC-SHA256；`store()` 已知失败，写通道需用 `getOutputStream`。

- 详细文档：[i2f-extension-filesystem-oss-aws-s3](./i2f-extension/i2f-extension-filesystem-oss-aws-s3/readme.md)

### i2f-extension-filesystem-sftp

> 基于 JSch 的 `IFileSystem` 契约适配器：SFTP 装配为统一契约（14 覆写方法 + 继承 40+ 组合能力），`ProxySftpFileSystem` 经 SSH 端口转发实现「跳板机 → 目标机」两跳接入。

- 详细文档：[i2f-extension-filesystem-sftp](./i2f-extension/i2f-extension-filesystem-sftp/readme.md)

### i2f-extension-ftp

> 独立 FTP 操作工具类 `FtpUtil`（Apache Commons Net `FTPClient`，provided）：链式封装登录/递归建目录/上传/下载/删除/列举，单连接会话 + 完整操作式应答消费；`IFtpMeta`/`FtpMeta` 配置契约被 `i2f-extension-sftp` 继承复用。注意 `login()` 正负应答判断反转（登录成功反而抛异常），使用前需先修复。

- 详细文档：[i2f-extension-ftp](./i2f-extension/i2f-extension-ftp/readme.md)

### i2f-extension-gif

> 极简 GIF 动图编解码工具（`animated-gif-lib`，provided）：`Gif`/`GifFrame` 帧模型 + `GifUtil.save`/`load` 静态门面，帧序列经等比缩放居中合成统一画布（`Rgba` 颜色键透明底）后编码为 GIF，或把 GIF 解码回帧序列（含帧延迟与循环次数）。

- 详细文档：[i2f-extension-gif](./i2f-extension/i2f-extension-gif/readme.md)

### i2f-extension-groovy

> Groovy 脚本执行工具（Apache Groovy 4，provided）：`GroovyScript.eval`（LruMap 缓存脚本 Class）与 `evalScript`（即时解析）双轨求值，`delegating` 子包经 Groovy MOP 把脚本方法调用路由到 Java 类/对象/方法 provider；被 xproc4j 脚本节点与 ops-starter 在线求值消费。

- 详细文档：[i2f-extension-groovy](./i2f-extension/i2f-extension-groovy/readme.md)

### i2f-extension-fory-json

> IJsonSerializer 契约的 Apache Fory 实现适配层（fory-json:1.7.4 provided）：单类 ForyJsonSerializer 把 ForyJson 门面适配到序列化契约族，实现全变体序列化/反序列化与 bean2Map，与 Jackson/Gson/fastjson 并列多引擎。瑕疵：共享裸默认配置未开线程安全、异常未统一包装。

- 详细文档：[i2f-extension-fory-json](./i2f-extension/i2f-extension-fory-json/readme.md)

### i2f-extension-gson

> 基于 Google Gson（2.10.1，provided）的 `IJsonSerializer` 契约适配器：`GsonJsonSerializer` 把 `toJson`/`fromJson` 装配为契约实现，支持 `Class`/`Type`/`TypeToken` 类型化反序列化与 `bean2Map`/`deserializeAsMap`；可经注入构造器携带定制 `Gson`，与 fastjson/fastjson2/jackson 为可替换多实现。

- 详细文档：[i2f-extension-gson](./i2f-extension/i2f-extension-gson/readme.md)

### i2f-extension-guava

> Google Guava 33.7.1（provided）本地缓存契约适配：GuavaCache 落地 IContainerCache（有界容量+null 占位），GuavaExpireCache 落地 IExpireContainerCache——因 Guava 无 Caffeine 式 per-entry Expiry，以守护线程 30s 周期清扫 + 读时 compute 惰性判定模拟逐条 TTL。瑕疵：每实例常驻不释放清扫线程、初始化块 this 逸出；源码建议改用 caffeine。

- 详细文档：[i2f-extension-guava](./i2f-extension/i2f-extension-guava/readme.md)

### i2f-extension-hazelcast

> Hazelcast 分布式缓存适配器（Hazelcast 5.3，provided）：`HazelcastCache` 把分布式并发 `IMap` 装配为 `IExpireContainerCache` 契约实现——泛型 K/V 直存（原生 Java 序列化、零编码器）+ TTL 原子写入，构造器兼容 client/member 双形态；`HazelcastUtil` 提供智能客户端快速创建。与 redis-cache、zookeeper 同属 cache 契约远程实现族。

- 详细文档：[i2f-extension-hazelcast](./i2f-extension/i2f-extension-hazelcast/readme.md)

### i2f-extension-hdfs

> HDFS 操作与 Hadoop 上下文工具（hadoop-client 3.2.1，provided）：`HdfsUtil` 以 `IHdfsMeta` 四要素契约双检锁懒加载 `FileSystem`，链式封装建目录/上传/下载/删除/列举；`HadoopContext` 提供 `Configuration` 定制钩子与 `JobBuilder` 链式构建 MapReduce 作业。与 `i2f-extension-filesystem-hdfs` 构成同协议双轨。

- 详细文档：[i2f-extension-hdfs](./i2f-extension/i2f-extension-hdfs/readme.md)

### i2f-extension-httpclient

> Apache HttpClient 4.x 的 `IHttpProcessor` 传输层绑定（httpclient/httpmime provided）：`HttpClientHttpProcessor` 按 Content-Type 分派 JSON/XML/Form/Multipart 请求体处理器（Bean 经反射展开），逐请求装配超时与重定向；`HttpClientUtil` 提供全局静态单例切换点。与 JDK 原生、okhttp、spring-web 实现可互换。

- 详细文档：[i2f-extension-httpclient](./i2f-extension/i2f-extension-httpclient/readme.md)

### i2f-extension-image-metadata

> 图像元数据读取工具（metadata-extractor 2.18.0，provided）：`ImageFileMetadata` 单静态门面把图片文件解析为 `Metadata`（Directory × Tag 树形），支持 JPEG/PNG/GIF/TIFF/WebP 等格式的 EXIF、GPS、XMP、尺寸等元数据读取；需 XMP 支持时还应引入传递依赖 xmpcore。

- 详细文档：[i2f-extension-image-metadata](./i2f-extension/i2f-extension-image-metadata/readme.md)

### i2f-extension-jackson

> Jackson 多格式序列化适配器与扩展件集合（jackson 2.13.5，provided）：`AbsJacksonSerializer` 基座派生 8 个格式适配器（JSON/XML/YAML/CBOR/CSV/Protobuf/Smile + 类型保留 JSON），datetime 六处理器、`@Sensible` 注解式数据脱敏（双注册表 + 字典翻译扩展）、`@Long2String` 精度保护；有专属 SpringBoot 脱敏 starter，全仓消费最广的序列化适配模块。

- 详细文档：[i2f-extension-jackson](./i2f-extension/i2f-extension-jackson/readme.md)

### i2f-extension-javassist

> Javassist 字节码工具（javassist 3.28.0-GA，provided）：`JavassistUtil` 两个静态原语——`isAssignableFrom`（CtClass 递归超类/接口链的全限定名类型判断）与 `getAllMethods`（含父类/接口的全量方法枚举，Map 保留声明类）；是 `i2f-extension-agent-javassist` 六个 transformer 的字节码工具底座。

- 详细文档：[i2f-extension-javassist](./i2f-extension/i2f-extension-javassist/readme.md)

### i2f-extension-jce-bc

> BouncyCastle 加密增强适配器（bcprov 1.74，provided）：`Bc*` 四件套继承 `i2f-crypto-impl` 基类、把 provider 切换为 `BC`，配套 8 个 BC 版算法枚举，解锁国密 SM4、SHA3/SHAKE、Tiger 等算法；`BcSm2Encryptor` 走 BC 轻量 API 实现 SM2 加密签名一体。是 `i2f-extension-swl` 与 `i2f-tools-encrypt` 的 BC 引擎底座。

- 详细文档：[i2f-extension-jce-bc](./i2f-extension/i2f-extension-jce-bc/readme.md)

### i2f-extension-jce-sm-antherd

> antherd 国密适配器（sm-crypto 0.3.2.1，provided）：Nashorn 执行内嵌 JS 实现 SM2/SM3/SM4，`Sm2Encryptor`/`Sm4Encryptor`/`Sm3Digester` 等四件套适配 `i2f-crypto-std` 契约，密钥密文统一 hex；JDK15+ 需另补 nashorn-core。`i2f-extension-swl` 与 `i2f-tools-encrypt` 的国密引擎。

- 详细文档：[i2f-extension-jce-sm-antherd](./i2f-extension/i2f-extension-jce-sm-antherd/readme.md)

### i2f-extension-jdbc-procedure-datax

> `i2f-jdbc-procedure` 的 DataX 节点扩展（零三方 Maven 依赖）：`DataxExecNode` 经 SPI 注册为 `<datax-exec>` 标签，把内联/变量 JSON 作业写入临时文件后以外部进程调用 `datax.py` 做异构数据批量 ETL，可选捕获标准输出回写上下文、`await` 控阻塞；与姊妹 `jdbc-procedure-flink`（JVM 内流批计算）构成数据工程双轨。

- 详细文档：[i2f-extension-jdbc-procedure-datax](./i2f-extension/i2f-extension-jdbc-procedure-datax/readme.md)

### i2f-extension-jdbc-procedure-flink

> `i2f-jdbc-procedure` 的 Flink 节点扩展：8 个 `flink-*` 标签经 SPI 注册，把「建环境→执行/查询 FlinkSQL→转 Changelog 流→打印→提交作业」拆为可编排节点，Flink 对象经上下文变量流转；`org.apache.flink:*` 全 `provided`。与姊妹 `jdbc-procedure-datax`（外部进程批量同步）构成 JVM 内流批计算双轨。

- 详细文档：[i2f-extension-jdbc-procedure-flink](./i2f-extension/i2f-extension-jdbc-procedure-flink/readme.md)

### i2f-extension-reverse-engineer-generator

> 数据库反向工程与代码生成模块，基于 Velocity 模板从表结构或 Spring MVC 元数据生成分层代码、DDL、设计文档与 ER 图。

- 详细文档：[i2f-extension-reverse-engineer-generator](./i2f-extension/i2f-extension-reverse-engineer-generator/readme.md)

### i2f-extension-freemarker

> 基于 FreeMarker 2.3.34（provided）的模板渲染与代码生成工具：三源渲染（字符串/文件系统/类路径）+ 整目录批量生成（`#filename` 动态输出名）+ 模板内 `_vm` 工具对象（混入 500+ 函数 + Stringifier SPI）。

- 详细文档：[i2f-extension-freemarker](./i2f-extension/i2f-extension-freemarker/readme.md)

### i2f-extension-agent-javassist

> 基于 Java Instrumentation Agent + Javassist 的运行期字节码增强观测套件：`-javaagent`/动态附加无侵入打点，覆盖 JDBC/文件/RMI/异常/退出/进程等事件监听 + Spring 上下文捕获 + traceId 编织 + 活体 REPL。

- 详细文档：[i2f-extension-agent-javassist](./i2f-extension/i2f-extension-agent-javassist/readme.md)

### i2f-extension-log-slf4j

> `i2f-log` 的 SLF4J 输出桥接：实现 `LogWriterProvider` SPI，探测到 `org.slf4j.Logger` 即挂载 `LogSlf4jLogWriter`，把 i2f 的 `LogData` 转投 SLF4J 后端，并在 `loaded()` 摘除 STDOUT 完成接管；`slf4j-api`/`i2f-log` 全 `provided`。与反向 `slf4j-log`（SLF4J→i2f）方向相反，不可共存否则成环。

- 详细文档：[i2f-extension-log-slf4j](./i2f-extension/i2f-extension-log-slf4j/readme.md)

### i2f-extension-minio

> MinIO SDK（`io.minio:minio:7.1.0`，provided）的零内部依赖薄封装：`MinioMeta` 承载 url/ak/sk 连接配置，`MinioUtil` 包装 `MinioClient` 提供桶/对象上传下载/前缀/预签名 URL 便捷方法并将受检异常降级为 `IOException`。作 `filesystem-minio` 适配层与 oss-minio starter 的连接底座（实际仅复用构造器与 `getClient`）。

- 详细文档：[i2f-extension-minio](./i2f-extension/i2f-extension-minio/readme.md)

### i2f-extension-mongodb

> MongoDB 旧版统一驱动（`mongo-java-driver:3.10.2`，provided）的 insert-only 薄门面：`MongoDbMeta` 承载 host/port/source/账号连接配置，`MongoDbUtil` 有状态持有 client/库/集合，链式「选库→选集合→插入(Document/Map/Bean/批量)」，Bean 经内部依赖 `i2f-reflect` 摊平为文档。仓库内无消费方；固定 PLAIN 认证、单点、无 close 为主要隐患。

- 详细文档：[i2f-extension-mongodb](./i2f-extension/i2f-extension-mongodb/readme.md)

### i2f-extension-mybatis

> MyBatis 桥接扩展层（mybatis 以 provided 引入）：以「空壳拦截器+适配器+IProxyInvocationHandler」实现 Executor 物理分页、SQL 执行记录、结果集列元数据捕获三条 ThreadLocal 驱动功能线，附动态 script 直连执行器与 LOB TypeHandler；消费方 mybatis-starter。

- 详细文档：[i2f-extension-mybatis](./i2f-extension/i2f-extension-mybatis/readme.md)

### i2f-extension-netty

> Netty 桥接扩展层（netty-all:4.1.65 provided）：三条能力线——注解驱动 HTTP 服务器（@NettyController 扫描路由+多源参数绑定）、自定义 TCP 二进制协议栈（16 字节头+心跳/ECHO/BROADCAST）、同步风格 TCP-RPC（JDK 动态代理+seqId→Promise+JSON）。仓库内无源码级消费方。

- 详细文档：[i2f-extension-netty](./i2f-extension/i2f-extension-netty/readme.md)

### i2f-extension-ocr-tesseract

> Tesseract OCR 桥接扩展（tess4j:4.5.1 provided）：单类 OcrTesseractProvider 全静态 API，recognize 三入口（流/图像/文件）识别；训练数据自备引导——datapath 固定 ./runtime/persist/tesseract/ocr，缺失抛引导异常。未实现 OCR 契约，无源码级消费方。

- 详细文档：[i2f-extension-ocr-tesseract](./i2f-extension/i2f-extension-ocr-tesseract/readme.md)

### i2f-extension-ognl

> OGNL 表达式桥接扩展（ognl:3.4.11 provided+optional）：2 源文件——OgnlUtil 提供 LruMap(4096) AST 缓存 + evaluateExpression 求值（root 双通道），DefaultMemberAccess 默认全放行；是 i2f 数据访问 DSL 的表达式引擎底座，消费方含 xproc4j、jdbc-proxy-xml、jdbc-bql-starter。

- 详细文档：[i2f-extension-ognl](./i2f-extension/i2f-extension-ognl/readme.md)

### i2f-extension-okhttp

> OkHttp HTTP 客户端桥接扩展（okhttp:4.9.3 provided）：i2f-network 的 IHttpProcessor 契约在 OkHttp 上的适配——OkHttpHttpProcessor 按 Content-Type 分派 6 个 RequestBodyHandler（表单/JSON/XML/Multipart/Raw 系列），响应以 HttpResponse+OkHttpCloser 双模释放；与 JDK 版平行可互换。

- 详细文档：[i2f-extension-okhttp](./i2f-extension/i2f-extension-okhttp/readme.md)

### i2f-extension-opencv

> 原生 OpenCV 4.3.0 桥接扩展（system scope 指向 opencv-430.jar）：静态块自引导释放/加载本地 DLL（需自备）+ 全静态门面——detectFrontFace/detectFullBody/detectEye/detectMultiScale（Haar 级联来自 opencv-data）与 findContours。瑕疵：system 依赖不入 fat jar、DLL 释放链空转 NPE。

- 详细文档：[i2f-extension-opencv](./i2f-extension/i2f-extension-opencv/readme.md)

### i2f-extension-opencv-data

> OpenCV 训练数据资源模块：单类 OpenCvDataFileProvider + 35 个官方级联分类器 XML（约 25MB，Haar/HOG/LBP），无 OpenCV 运行时依赖；职责是把 classpath 资源幂等释放到 ./runtime/persist/opencv/data 供 CascadeClassifier 加载，是 opencv 与 opencv-javacv 的共享数据底座。瑕疵：资源缺失静默、释放非原子。

- 详细文档：[i2f-extension-opencv-data](./i2f-extension/i2f-extension-opencv-data/readme.md)

### i2f-extension-opencv-javacv

> JavaCV 桥接人脸识别扩展（javacv 1.5.9 双 provided，绑定 OpenCV 4.7.0）：单类 OpenCvFaceRecognizer 封装「目录约定训练 + LBPH 识别」——子目录名即标签、模型三件套持久化、预处理取首个脸 ROI resize 256×256、置信度应用层后置过滤；级联来自 opencv-data，消费方 tools-face-recognizer。瑕疵：越界未守卫。

- 详细文档：[i2f-extension-opencv-javacv](./i2f-extension/i2f-extension-opencv-javacv/readme.md)

### i2f-extension-oss-aliyun

> 阿里云 OSS 桥接扩展（aliyun-sdk-oss:3.17.4 provided+optional）：2 类轻量适配——AliyunOssMeta 配置元数据 + AliyunOssUtil 实例门面（桶管理、上传三形态/下载/元信息、prefix 模拟目录、presigned URL，异常统一包装 IOException）；消费方 filesystem-oss-aliyun。瑕疵：ClientBuilderConfiguration 从未传入 builder，签名配置被架空。

- 详细文档：[i2f-extension-oss-aliyun](./i2f-extension/i2f-extension-oss-aliyun/readme.md)

### i2f-extension-oss-aws-s3

> AWS S3 桥接扩展（AWS SDK v2 bom:2.17.100 provided+optional）：与 oss-aliyun 平行同构的 2 类适配——AwsS3OssMeta 配置 + AwsS3OssUtil 门面（桶/上传/下载/prefix 模拟目录、presigned URL）；消费方 filesystem-oss-aws-s3。瑕疵：bucketExists 误用 policyStatus 判存在、presigner 丢 endpointOverride。

- 详细文档：[i2f-extension-oss-aws-s3](./i2f-extension/i2f-extension-oss-aws-s3/readme.md)

### i2f-extension-qrcode

> 二维码桥接扩展（zxing 3.4.1 双 provided）：仓库最小扩展之一（2 文件约 180 行）——QrCodeWorker 链式封装「生成 + 2D 贴 Logo + 解码」（QR_CODE + 纠错 H 预留 Logo 面积、圆角描边、Logo 缺失静默降级），QrCodeUtil 全静态门面（生成/解析，输出硬编码 JPG）。瑕疵：Logo 缩放逻辑自相矛盾致拉伸失真、ImageIO.read 空 NPE。

- 详细文档：[i2f-extension-qrcode](./i2f-extension/i2f-extension-qrcode/readme.md)

### i2f-extension-quartz

> Quartz 调度桥接扩展（quartz:2.3.2 provided）：双层结构——QuartzUtil 全静态门面（Scheduler/JobDetail/Cron Trigger 构建与生命周期）+ 注解驱动线（@QuartzSchedule → QuartzScanner 扫描 → 统一注册为 QuartzAnnotationJob，执行时反射回调）；消费方 quartz-starter。瑕疵：热更新仅换 Trigger 丢弃新 JobDetail。

- 详细文档：[i2f-extension-quartz](./i2f-extension/i2f-extension-quartz/readme.md)

### i2f-extension-jedis

> IRedisClient 契约的 Jedis 实现适配层（jedis:3.8.0 provided）：单类 JedisRedisClient（自管 JedisPool）+ JedisMeta，以 delegate(Function) 模板统一借出—执行—归还实现 23 契约方法，prefix 隔离键空间；是「一契约双实现」的 Jedis 路线。瑕疵：setUnique 丢弃 setnx 恒返 true（锁必误判）、getJedis 串行化抵消池并发。

- 详细文档：[i2f-extension-jedis](./i2f-extension/i2f-extension-jedis/readme.md)

### i2f-extension-redis-api

> Redis 统一客户端契约模块（纯 SPI，零 Redis 客户端依赖）：单接口 IRedisClient（23 方法，Spring Data Redis 风格，string/list/hash + 过期），是 Redis 体系 SPI 中枢——双实现 jedis 的 JedisRedisClient 与 spring-redis 的 SpringRedisClient，双消费 redis-cache 与 redis-starter。瑕疵：接口零语义文档已致双实现行为分歧。

- 详细文档：[i2f-extension-redis-api](./i2f-extension/i2f-extension-redis-api/readme.md)

### i2f-extension-redis-cache

> Redis 缓存适配扩展（单类 RedisCache 92 行）：把 IRedisClient string KV 向上适配为 i2f-cache-std 三契约（IExpireContainerCache/IPersistCache/IDistributedCache），机制 prefix 键空间隔离 + 可注入编解码器；消费方 redis-starter 装配 + security/shiro 存 token 会话。瑕疵：clean() 直接 flushDb 清空整库（数据灾难级）。

- 详细文档：[i2f-extension-redis-cache](./i2f-extension/i2f-extension-redis-cache/readme.md)

### i2f-extension-sftp

> SFTP/SSH 桥接扩展（jsch:0.1.55 provided）：三条能力线——SftpUtil 单会话门面（登录/递归建目录/上传下载/删除/列举 + exec）、ProxySftpUtil 跳板两级会话、SshTunnelUtil 通用 SSH 本地端口正向隧道（daemon keepalive + shutdown hook）；消费方 ops-starter、ssh-tunnel-starter。瑕疵：硬编码 password 认证使纯私钥失效、exec 不消费 stderr 挂死。

- 详细文档：[i2f-extension-sftp](./i2f-extension/i2f-extension-sftp/readme.md)

### i2f-extension-slf4j

> SLF4J 桥接增强扩展（slf4j-api:1.7.36 provided）：4 源文件——PerfLogger 延迟求值门面、Slf4jPrintStream 控制台重定向、Slf4jUtil 栈扫描调用点、Slf4jMdcManager（i2f-trace-mdc 的 MdcManager SPI 实现）；消费方 spring-starter、trace-mdc-starter。瑕疵：重定向早于日志初始化可无限递归、行级 logger 名致注册表膨胀。

- 详细文档：[i2f-extension-slf4j](./i2f-extension/i2f-extension-slf4j/readme.md)

### i2f-extension-slf4j-log

> SLF4J 绑定器扩展（slf4j-api:1.7.36 provided+optional）：把 SLF4J 1.x StaticLoggerBinder 协议反向桥接到 i2f-log——org.slf4j.impl 五绑定标准类 + i2f 两适配器（Slf4jLogLoggerAdapter 转发 ILogger、FactoryAdapter 缓存），SPI→StdioLogger 兜底。瑕疵：SLF4J {} 占位符在 i2f-log 侧失效、2.x 断代。

- 详细文档：[i2f-extension-slf4j-log](./i2f-extension/i2f-extension-slf4j-log/readme.md)

### i2f-extension-sqlparser

> SQL 解析桥接扩展（JSqlParser:4.9 provided+optional）：仓库最小扩展之一（单类约 53 行），SqlParserUtil.wrapAsCountSql 把查询 SQL 改写为 count(1)——快路径替换查询列并剥 order by，解析失败或非 PlainSelect 降级为子查询包装。瑕疵：catch(ParseException) 静默吞异常、丢 DISTINCT 保留 GROUP BY 致计数错误。

- 详细文档：[i2f-extension-sqlparser](./i2f-extension/i2f-extension-sqlparser/readme.md)

### i2f-extension-swl

> SWL 安全传输协议密码学引擎扩展（BouncyCastle:1.74 + sm-crypto provided）：为 i2f-swl-std 三大 SPI 提供 BC 六件套（RSA/AES/SHA/SM2/SM3/SM4）与 Antherd 国密三件套共 18 主源，含 9 个对等 Supplier 供池化；下游 gateway/两个 swl-starter 以 compile 引入切换引擎。瑕疵：对称加密异常误用非对称码、AES 密钥熵不足名义。

- 详细文档：[i2f-extension-swl](./i2f-extension/i2f-extension-swl/readme.md)

### i2f-extension-tokenlization-ansj

> 中文分词扩展（ansj_seg:5.1.6 provided+optional，零内部依赖）：四个并列分词桥接（ansj/hanlp/jcseg/jieba）之一，单类 AnsjTokenlizer 两静态方法——tokenlize 透传带词性 Term 列表、tokenlizeSplit 展平词串，桥接面收窄到 ToAnalysis 简分词；仅 extension-all 聚合。瑕疵：tokenlization/Tokenlizer 拼写错误固化、null 直穿 NPE。

- 详细文档：[i2f-extension-tokenlization-ansj](./i2f-extension/i2f-extension-tokenlization-ansj/readme.md)

### i2f-extension-tokenlization-hanlp

> 中文分词扩展（hanlp:portable-1.8.2 provided+optional，零内部依赖）：四个并列分词桥接中功能最全者，单类 HanlpTokenlizer 以 Mode 枚举 + if-else 链把 HanLP 六套分词器收拢到 tokenlize/tokenlizeSplit 两组重载（默认 STANDARD，透传原生 Term）；仅 extension-all 聚合。瑕疵：拼写错误固化、null/未匹配 Mode 静默降级掩盖失效。

- 详细文档：[i2f-extension-tokenlization-hanlp](./i2f-extension/i2f-extension-tokenlization-hanlp/readme.md)

### i2f-extension-tokenlization-jcseg

> 中文分词扩展（jcseg-core:2.5.0 provided+optional，零内部依赖）：四个并列分词桥接之一，单类 JcsegTokenlizer 以两 public static 共享字段（config+dic）复用词典，tokenlize 每次新建 ISegment 收集 IWord（默认 COMPLEX_MODE），Split 取 getValue 展平；仅 extension-all 聚合。瑕疵：public static 可变共享字段非线程安全、对象抖动无池化。

- 详细文档：[i2f-extension-tokenlization-jcseg](./i2f-extension/i2f-extension-tokenlization-jcseg/readme.md)

### i2f-extension-tokenlization-jieba

> 中文分词扩展（jieba-analysis:1.0.2 provided+optional，零内部依赖）：四个并列分词桥接之一，单类 JiebaTokenlizer 三静态方法——tokenlize 默认 SEARCH 模式返回带词性偏移 SegToken、tokenlizeSplit 走 sentenceProcess 展平词串；仅 extension-all 聚合。瑕疵：getSegmenter 每次 new 触发全量词典重复加载（四兄弟最严重）、两路径算法不对称命名易误导。

- 详细文档：[i2f-extension-tokenlization-jieba](./i2f-extension/i2f-extension-tokenlization-jieba/readme.md)

### i2f-extension-tts-espeak

> 文本转语音（TTS）扩展（非 Maven 三方而是原生二进制内嵌路线）：把 espeak 命令行引擎作为 classpath 资源打进 jar，TtsEspeakProvider 静态块解压 zip 至 runtime/persist 再 Runtime.exec 调 espeak.exe 合成（可选产 wav）；仅 Windows、中文语音硬编码。瑕疵：espeak.zip 缺失时 init 吞 NPE 置位后永久静默失败、waitFor 不消费输出可阻塞。

- 详细文档：[i2f-extension-tts-espeak](./i2f-extension/i2f-extension-tts-espeak/readme.md)

### i2f-extension-tts-jacob

> 文本转语音（TTS）扩展（JACOB Java-COM Bridge + Windows SAPI 进程内 COM 路线）：内置 jacob.jar 与 1.21 DLL，TtsJacobProvider 静态块释放 DLL 后实例化 Sapi.SpVoice 本地播放或经 SpFileStream 落盘 wav；仅 Windows、参数全硬编码。瑕疵：system scope 不传递易 NoClassDefFoundError、getResource null NPE、COM 句柄泄漏。

- 详细文档：[i2f-extension-tts-jacob](./i2f-extension/i2f-extension-tts-jacob/readme.md)

### i2f-extension-velocity

> Velocity 模板渲染与代码生成扩展（velocity-engine-core:2.3 provided）：与 freemarker 同构但更重——VelocityGenerator 三源渲染门面 + batchRender 目录镜像 + Stringifier SPI + 独有 #trim/#richFor/#fori/#script 等 7 指令，12 主源；被 document、xproc4j 等复用。瑕疵：fori 死循环、#script+cmd 构成 RCE 面。

- 详细文档：[i2f-extension-velocity](./i2f-extension/i2f-extension-velocity/readme.md)

### i2f-extension-velocity-bindsql

> Velocity 模板 + BindSql 桥接扩展（velocity-engine-core:2.3 provided）：把模板渲染与 i2f-bindsql 参数化模型对接，实现 MyBatis 风格 XML Mapper → 参数化 BindSql（? 占位 + args）动态 SQL 引擎，VelocityResourceSqlTemplateResolver 解析 <mapper> 缓存热重载；消费方 jdbc-bql-starter。瑕疵：占位正则过宽误匹配、裸插值注入面。

- 详细文档：[i2f-extension-velocity-bindsql](./i2f-extension/i2f-extension-velocity-bindsql/readme.md)

### i2f-extension-verifycode

> Kaptcha 2.3.2（provided）图形验证码极薄封装（2 主源约 167 行）：VerifyCodeUtil 收敛两套 DefaultKaptcha 配置——字符型与算术型，genVerifyCode 按枚举产 VerifyCodeData（UUID key/img/showText/code/imgBase64），base64url 裸编码；与 i2f-verifycode 互不依赖。瑕疵：算术模式硬编码 com.ruoyi 外部类致必实例化失败、无 null 兜底 NPE。

- 详细文档：[i2f-extension-verifycode](./i2f-extension/i2f-extension-verifycode/readme.md)

### i2f-extension-xproc4j

> XProc4J 多语言脚本执行扩展（18 主源约 2900 行）：DefaultJdbcProcedureExecutor 向 i2f-jdbc-procedure 引擎补齐 Java/Groovy/JS/Funic/TinyScript/OGNL 六语言 lang:eval-* 节点，Java 走 MemoryCompiler 缓存、脚本 FUN_/SP_ 回落嵌套 exec；消费方 xproc4j-starter。瑕疵：bodyNode 误置、空 catch 吞异常。
- 详细文档：[i2f-extension-xproc4j](./i2f-extension/i2f-extension-xproc4j/readme.md)

### i2f-extension-zip4j

> Zip4J 2.9.1（provided）的 ICompressor 契约适配器（单类约 90 行）：继承 AbsCompressor 只补 compressBindData（逐条 addStream 写）与 release(三参)（extractAll 落盘读），密码非空时构造 AES-128 加密参数，是本契约族唯一开箱提供 AES-128 加密的实现。瑕疵：release(三参) 忽略 BiConsumer 违约、close 不在 finally 泄漏。

- 详细文档：[i2f-extension-zip4j](./i2f-extension/i2f-extension-zip4j/readme.md)

### i2f-extension-zookeeper

> Apache ZooKeeper 3.6.3 + Curator（provided）的分布式协调适配套件（17 主源约 1200 行）：以 ZookeeperManager 为连接与 CRUD 核心（阻塞建连/重连/KV/TTL/watch），派生 Cache/LockProvider/ClusterProvider（临时节点+递归 watch 分片）三契约；消费方 zookeeper-starter。瑕疵：serializer 恒 null 致读写通道 NPE。

- 详细文档：[i2f-extension-zookeeper](./i2f-extension/i2f-extension-zookeeper/readme.md)

## i2f-springboot

> SpringBoot 生态的开箱即用 Starter 集合，以条件装配（`@ConditionalOnClass` / `@ConditionalOnExpression` / `@ConditionalOnMissingBean`）为核心，将 i2f 的 AI 工具链、数据访问、安全认证、缓存、分布式任务、运维控制台等能力自动配置为可插拔的 Spring Boot 组件。

### i2f-springboot-activity-starter

> Activiti 7 工作流 Starter：条件自动装配 `ProcessEngine` 与五大运行时服务（Repository/Runtime/History/Management/Task），数据源支持独立 JDBC 或复用容器二选一，`ActivityManager` 封装部署/启动/待办/完成/历史/挂起激活/组任务拾取归还转派全流程 API，另附默认关闭的 REST 演示接口与请假流程 BPMN 样例。

- 详细文档：[i2f-springboot-activity-starter](./i2f-springboot/i2f-springboot-activity-starter/readme.md)

### i2f-springboot-ai-mcp-server

> MCP 服务端 Starter：将 Spring 容器中的 `@Tool`/`@Tools` 工具以 HMAC-SHA256 签名认证的 Simple MCP 协议（`/mcp/tool/list`、`/mcp/tool/call`）对外暴露，内置 Spring Web MVC（共享宿主 Web 端口）与 Netty（独立端口）双传输模式的自动装配，支持 nonce 防重放与请求级上下文透传。

- 详细文档：[i2f-springboot-ai-mcp-server](./i2f-springboot/i2f-springboot-ai-mcp-server/readme.md)

### i2f-springboot-ai-mcp-client

> MCP 客户端 Starter：按 instances 配置把远程 MCP Server 注册为本地 McpToolProvider Bean，内置 Simple MCP 私协议（HMAC 签名）、标准 JSON-RPC Streamable HTTP 与 solon-ai-mcp SDK 三套客户端，供 AI 工具网关聚合为动态工具。

- 详细文档：[i2f-springboot-ai-mcp-client](./i2f-springboot/i2f-springboot-ai-mcp-client/readme.md)

### i2f-springboot-ai-starter

> AI 能力 Starter：两级条件自动装配注册 `AiModel`（REST OpenAI / DashScope 二选一）、`IJsonSerializer`、`AiAgent`，并以 `BeanDefinitionRegistryPostProcessor` 扫描 `@AiService` 接口、用 `FactoryBean` + JDK 动态代理实例化为「方法即提示词、参数即上下文、返回值即结构化输出」的声明式 AI 服务，对齐 LangChain4j `@AiService` 范式。

- 详细文档：[i2f-springboot-ai-starter](./i2f-springboot/i2f-springboot-ai-starter/readme.md)

### i2f-springboot-auth-starter

> RBAC 声明式权限校验 Starter：@CheckPermissions 承载 SpEL 表达式，@Before 拦截并注入 user/auth/args 上下文求值，非 true 抛 PermissionDenyException；提供 hasAll/AnyRoles/Perms 判定，不绑定认证框架、零内部依赖。

- 详细文档：[i2f-springboot-auth-starter](./i2f-springboot/i2f-springboot-auth-starter/readme.md)

### i2f-springboot-dubbo-starter

> Dubbo 集成 Starter：单个空壳 @Configuration 承载 @EnableDubbo，由 @ConditionalOnExpression 一键开关；零内部依赖，上游为 EOL 的 dubbo-spring-boot-starter:0.2.0（com.alibaba.dubbo 旧命名空间），运行时 provided 需宿主自备。

- 详细文档：[i2f-springboot-dubbo-starter](./i2f-springboot/i2f-springboot-dubbo-starter/readme.md)

### i2f-springboot-dynamic-datasource-starter

> 多数据源动态路由 Starter：基于 AbstractRoutingDataSource，以 @DataSource + AOP 将目标数据源写入 ThreadLocal 路由；支持 multiply 批量声明、group 分组与 ring/random 负载均衡，缺失按 strict 抛异常或回落 primary，内置 Druid/Hikari。

- 详细文档：[i2f-springboot-dynamic-datasource-starter](./i2f-springboot/i2f-springboot-dynamic-datasource-starter/readme.md)

### i2f-springboot-encrypt-property-starter

> 配置属性透明解密 Starter：BeanFactoryPostProcessor 把每个 PropertySource 包装为解密代理，读值按前缀自动解密——aes. 走 AES/ECB、bs64. 走 Base64，敏感配置密文落盘、@Value 透明还原，策略可插拔。瑕疵：两解密器 @Bean 同名默认同开、AES key 默认 null 高危。

- 详细文档：[i2f-springboot-encrypt-property-starter](./i2f-springboot/i2f-springboot-encrypt-property-starter/readme.md)

### i2f-springboot-http-proxy-starter

> HTTP 反向代理 Starter：@ConfigurationProperties(i2f.http.proxy) 绑定 prefix→target 映射，默认开启，把 spring-web 的 HttpProxyHandler/Filter 注册为 order=-1、拦截 /* 的前置过滤器，命中前缀即透明转发。瑕疵：mappings 默认 null 无判空、未配即启动 NPE。

- 详细文档：[i2f-springboot-http-proxy-starter](./i2f-springboot/i2f-springboot-http-proxy-starter/readme.md)

### i2f-springboot-jackson-sensible-starter

> Jackson 脱敏处理器桥接 Starter：容器启动/刷新时把全部 ISensibleHandler Bean 收集进上游 extension-jackson 静态注册表 GLOBAL_HANDLERS，让自定义脱敏「声明为 Bean 即被全局感知」。瑕疵：clear+addAll 非原子有空窗、@ConfigurationProperties 无对应字段。

- 详细文档：[i2f-springboot-jackson-sensible-starter](./i2f-springboot/i2f-springboot-jackson-sensible-starter/readme.md)

### i2f-springboot-jdbc-bql-starter

> BQL 与 JdbcProxy 双引擎自动装配 Starter：JdbcBqlAutoConfiguration 装配 BqlTemplate 程序化查询，JdbcProxyAutoConfiguration 扫描 Mapper 接口注册动态代理 Bean，支持 MyBatis XML→Velocity→注解三级渲染降级；各由独立开关控制。

- 详细文档：[i2f-springboot-jdbc-bql-starter](./i2f-springboot/i2f-springboot-jdbc-bql-starter/readme.md)

### i2f-springboot-kafka-starter

> Kafka 自动装配 Starter，分两层：产原生 AdminClient/Producer/Consumer，及 KafkaTemplate/ListenerContainerFactory 等 spring-kafka Bean，参数由 KafkaConfigProperties 绑定，两层各独立开关；零内部依赖。瑕疵：事务工厂强转复用 @Primary 单例污染非事务模板。

- 详细文档：[i2f-springboot-kafka-starter](./i2f-springboot/i2f-springboot-kafka-starter/readme.md)

### i2f-springboot-limit-starter

> 请求限流自动装配 Starter：LimitManager 启动守护线程每 5s 从可插拔 Provider（配置/JDBC/Redis）刷新规则，基于 Redis INCR+EXPIRE 做分布式固定窗口计数；LimitFilter 与 LimitAop（@Limited）多维判定超限抛 LimitException。瑕疵：scanRule 返回空 Map 致 applyRule 死逻辑、后端故障 fail-open。

- 详细文档：[i2f-springboot-limit-starter](./i2f-springboot/i2f-springboot-limit-starter/readme.md)

### i2f-springboot-maven-project

> Spring Boot 脚手架/模板工程（非发布型，已在父 pom 注释排除）：BaseBootApplication 统一启动并打印 JVM/MBean/SPI/网络/内存诊断 Banner，System.out/err 重定向为 SLF4J；构建层产瘦 jar + assembly tar.gz，附 jarctrl.sh/deploy.sh/startup.bat。瑕疵：startup 的 web 类型判断反向、Banner 判空写错可 NPE。

- 详细文档：[i2f-springboot-maven-project](./i2f-springboot/i2f-springboot-maven-project/readme.md)

### i2f-springboot-mybatis-starter

> MyBatis/MyBatis-Plus 自动装配 Starter，在三方 starter 之上叠加 i2f 增强：@MapperScan 扫描 com.**.mapper/dao 并按开关注册分页拦截器，另产 SQL 记录/结果集元数据两拦截器，DynamicScriptExecutor 对 <script> 片段直接执行。瑕疵：执行器冒充自动配置类、静态单例未初始化时 getInstance 永久阻塞。

- 详细文档：[i2f-springboot-mybatis-starter](./i2f-springboot/i2f-springboot-mybatis-starter/readme.md)

### i2f-springboot-nginx-rtmp-auth-server-starter

> Nginx-RTMP 推拉流鉴权回调自动装配 Starter：控制器暴露 POST /api/rtmp/auth 承接 nginx 回调的 call/addr/name/tcUrl 与 token，委托函数式校验器判定后以 HTTP 状态码回应（2xx 放行/500 拒绝），默认按固定 access-token 比对可覆盖，零内部依赖。瑕疵：空 token 直接放行 fail-open、无 @ConditionalOnMissingBean。

- 详细文档：[i2f-springboot-nginx-rtmp-auth-server-starter](./i2f-springboot/i2f-springboot-nginx-rtmp-auth-server-starter/readme.md)

### i2f-springboot-ops-starter

> 一体化运维/开发/AI 控制台全量装载 Starter（组内最大：174 源 + 内嵌 Vue2 SPA、依赖顶端）：挂默认 /ops，涵盖应用自省/SQL 控制台/SSH/Redis/ES + OpenAI 对话与约 25 个 @Tool，出入站经国密 SM2/SM4/SM3 信封。瑕疵含【高危】约 80 个 @Controller 误登记为自动配置、generateCertPair 私钥泄露、/ops/app/eval Groovy RCE。

- 详细文档：[i2f-springboot-ops-starter](./i2f-springboot/i2f-springboot-ops-starter/readme.md)

### i2f-springboot-oss-minio-starter

> MinIO 对象存储自动装配 Starter（薄层，仅 2 类）：MinioProperties 绑定 i2f.minio.*，产 MinioUtil（桶/对象/预签名 URL）与 MinioFileSystem（适配 IFileSystem）两共享 MinioClient 的 Bean，实现下沉 extension-minio。瑕疵：@Import(MinioClient.class) 无消费、缺 @ConditionalOnClass、未标 @Configuration。

- 详细文档：[i2f-springboot-oss-minio-starter](./i2f-springboot/i2f-springboot-oss-minio-starter/readme.md)

### i2f-springboot-quartz-starter

> Quartz 定时任务自动装配 Starter：装配 SchedulerFactoryBean，SpringJobFactory 令反射创建的 Job 接受 Spring 注入，QuartzScannerConfig 在 ContextRefreshedEvent 扫描 @QuartzSchedule 方法注册触发器；下沉 extension-quartz 附建表 SQL。瑕疵：探测恒真从不校验、与 Boot 自带 Quartz 冲突无条件装配。

- 详细文档：[i2f-springboot-quartz-starter](./i2f-springboot/i2f-springboot-quartz-starter/readme.md)

### i2f-springboot-rabbitmq-starter

> RabbitMQ 自动装配 Starter（薄装配层，仅 4 类、零内部依赖）：enable 开关下以 @ConditionalOnMissingBean 产全局 RabbitTemplate，按 mandatory 设回退并可选挂载仅打印日志的 Confirm/Return 回调观测桩，RabbitMqManager 提供 send→convertAndSend 门面。瑕疵：Boot 自带模板先出使回调静默空转、@Component 冒充自动配置类登记。

- 详细文档：[i2f-springboot-rabbitmq-starter](./i2f-springboot/i2f-springboot-rabbitmq-starter/readme.md)

### i2f-springboot-redis-starter

> Redis 自动装配 Starter，4 配置类分层：产 Jackson 序列化器、String-key/JSON-value 的 RedisTemplate，桥接为 IRedisClient+RedisCache，LettuceRedisHeartbeat 后台周期校验连接规避 Lettuce 假死；下沉 extension-redis-cache/spring-redis。瑕疵：心跳 run 无 try/catch 遇异常即停摆、缺 @ConditionalOnMissingBean。

- 详细文档：[i2f-springboot-redis-starter](./i2f-springboot/i2f-springboot-redis-starter/readme.md)

### i2f-springboot-redisson-starter

> Redisson 分布式锁/自增自动装配 Starter：复用 Boot RedisProperties 构建 RedissonClient，@Import 装配 RedissonLockProvider、RedissonAtomic（RAtomicLong）、RedissonLockAop（解析 @RedisLock 自动加解锁），锁接口下沉 i2f-lock。瑕疵：kidx>0 使 keyIdx=0 分区锁永失效、缺 @ConditionalOnMissingBean。

- 详细文档：[i2f-springboot-redisson-starter](./i2f-springboot/i2f-springboot-redisson-starter/readme.md)

### i2f-springboot-security-starter

> Spring Security 无状态 token 认证自动装配 Starter：继承 WebSecurityConfigurerAdapter 以布尔开关驱动 STATELESS 安全链，过滤器分流 JSON/表单登录，TokenHolder 以 UUID token 缓存 UserDetails 支持单点互踢，失败经 forward 统一 ApiResp 输出。瑕疵含【高危】spring.factories 注册不存在的类致启动 ClassNotFound、默认弱口令。

- 详细文档：[i2f-springboot-security-starter](./i2f-springboot/i2f-springboot-security-starter/readme.md)

### i2f-springboot-shiro-starter

> Apache Shiro 无状态 token 认证自动装配 Starter（23 类，手写全套装配）：产 SecurityManager/ShiroFilterFactoryBean/凭证匹配器，全局过滤器拦 /login/logout 并对带 token 请求续期，TokenHolder 以 UUID token 缓存 IShiroUser 支持互踢，依赖 9 个内部模块。瑕疵含缺 DefaultAdvisorAutoProxyCreator 致注解授权失效、默认弱口令。

- 详细文档：[i2f-springboot-shiro-starter](./i2f-springboot/i2f-springboot-shiro-starter/readme.md)

### i2f-springboot-spring-starter

> Spring 基础 Starter（i2f-springboot 组地基装配件）：以 14 个各带独立开关的自动配置类，把 i2f-spring/i2f-resp/jackson/jdk-ext-web 能力一次性接入 Boot——注册 SpringUtil/EventManager、异步/调度线程池、CORS、全局异常→ApiResp、响应体包装、Jackson 转换器。瑕疵含【高危】startup 对非 null webType 强制 NONE 禁用 Web、enable 键错位。

- 详细文档：[i2f-springboot-spring-starter](./i2f-springboot/i2f-springboot-spring-starter/readme.md)

### i2f-springboot-ssh-tunnel-starter

> SSH 隧道自动建立 Starter（5 类、唯一内部依赖 extension-sftp）：两阶段装配把 SshTunnelUtil 接入 Boot 生命周期——监听器抢在容器/数据源创建前绑定 servers[]，逐台跳板机建本地端口正向隧道，令内网 MySQL/Redis 可按 localhost 直连。瑕疵含【高危】隧道从不加入 manager.servers 致管理器恒空、enable=false 仍会建隧道。

- 详细文档：[i2f-springboot-ssh-tunnel-starter](./i2f-springboot/i2f-springboot-ssh-tunnel-starter/readme.md)

### i2f-springboot-swagger2-starter

> Swagger2（Springfox 2.9.2）接口文档自动装配 Starter（5 类、无内部依赖）：产 ApiInfo 与全量 Docket，按注解维度产 6 个分组 Docket，并可据 dynamic.group.* 用 BeanDefinitionBuilder 动态注册任意多分组，各独立开关默认全开，springfox 全 provided。瑕疵含【高危】无 @EnableSwagger2 故不自标则 Docket 无人消费、缺 @Configuration。

- 详细文档：[i2f-springboot-swagger2-starter](./i2f-springboot/i2f-springboot-swagger2-starter/readme.md)

### i2f-springboot-swl-starter

> SWL 安全传输协议 Spring Boot 透明加解密 Starter（9 类）：按可插拔算法装配 SwlTransfer（非对称/对称/摘要/混淆四套 Supplier，默认 RSA+AES+SHA256+Base64），以 order -10 过滤器注册入站解密出站加密，AOP 环绕 @*Mapping 逐方法标 @SwlCtrl，暴露 /swl/swapKey 握手。瑕疵含【高危】filter.enable 与 web.enable 均为死开关。

- 详细文档：[i2f-springboot-swl-starter](./i2f-springboot/i2f-springboot-swl-starter/readme.md)

### i2f-springboot-totp-starter

> TOTP/HOTP 动态口令自动装配 Starter（5 类、唯一内部依赖 i2f-otpauth）：经 @Import 拉入门面 HmacOtpAccountAuthenticator（generateRandomKey/verify/generate/makeUrl 产 otpauth:// 扫码地址）与按 type 分派的默认工厂，业务方实现 SPI HmacOtpAccountKeyProvider 即可注入。瑕疵含【高危】algorithm/digits 均为死配置。

- 详细文档：[i2f-springboot-totp-starter](./i2f-springboot/i2f-springboot-totp-starter/readme.md)

### i2f-springboot-trace-mdc-starter

> 全链路 TraceId/MDC 上下文传播自动装配 Starter（11 源文件，依赖 i2f-trace-mdc + extension-slf4j 的 MdcManager SPI）：打通 Servlet/Reactive 入站生成 traceId 写 MDC、Feign/RestTemplate 出站注入 trace 头、线程池复制 MDC、切面环绕定时任务生成 traceId，各带独立开关默认全开。瑕疵含【高危】组件类被登记为自动配置却无一为 @Configuration。

- 详细文档：[i2f-springboot-trace-mdc-starter](./i2f-springboot/i2f-springboot-trace-mdc-starter/readme.md)

### i2f-springboot-websocket-starter

> WebSocket 轻量装配 Starter（5 类、唯一内部依赖 i2f-reflect）：同时接入两套并行栈——JSR-356 @ServerEndpoint 风格（含会话表/广播，配 ServerEndpointExporter）与 Spring WebSocket 风格（@EnableWebSocket 按 registry.* 逐条 addHandler）。瑕疵含【高危】@ServerEndpoint 用实例字段存 clients/onlineCount 致广播与在线数整体失效。

- 详细文档：[i2f-springboot-websocket-starter](./i2f-springboot/i2f-springboot-websocket-starter/readme.md)

### i2f-springboot-xproc4j-starter

> XProc4J「去数据库存储过程」引擎全量装配 Starter（23 源文件、直接依赖 6 内部模块、组内装配最重）：以约 15 个带独立开关的 @Bean 装配上下文/事件处理器/数据源/XML 热更新/executor，另注册 spring_bean/redis/log 函数与 @ProcedureMapper 声明式 Mapper。瑕疵含【高危】spring_env/log_ 函数因错类永不注册、mapperPackages 默认空使扫描不执行。

- 详细文档：[i2f-springboot-xproc4j-starter](./i2f-springboot/i2f-springboot-xproc4j-starter/readme.md)

### i2f-springboot-xxl-job-starter

> xxl-job 执行器（xxl-job-core:2.4.1）自动装配 Starter（2 类、无内部依赖）：把官方 XxlJobConfig 样例改造为自动配置，产 XxlJobSpringExecutor，XxlJobProperties（嵌套 Admin/Executor 属性）承载全量配置，注册/内嵌 server/@XxlJob 扫描全外包给 xxl-core 自管。瑕疵含无 @Configuration 走 lite、未配字段默认灌进执行器且 getAdmin 未配 NPE。

- 详细文档：[i2f-springboot-xxl-job-starter](./i2f-springboot/i2f-springboot-xxl-job-starter/readme.md)

### i2f-springboot-zookeeper-starter

> ZooKeeper 分布式协调自动装配 Starter（2 类、内部依赖 i2f-lock + extension-zookeeper）：一把注册 ZookeeperManager/Cache/ClusterProvider 及条件化的 CuratorFramework 与 LockProvider 五个 Bean，ZookeeperProperties 承载连接参数。瑕疵含【高危】clusterProvider 链路 NPE 只要 ZK 可达启动必失败。

- 详细文档：[i2f-springboot-zookeeper-starter](./i2f-springboot/i2f-springboot-zookeeper-starter/readme.md)

## i2f-springcloud

> 面向 Spring Cloud 微服务生态的装配 Starter 集合，覆盖注册发现/配置中心/网关/负载均衡/熔断/链路追踪/监控等能力的自动装载，把「引依赖即生效」的即插即用风格从 SpringBoot 组延伸到 SpringCloud 全家桶。

### i2f-springcloud-actuator-admin-starter

> Spring Boot Admin 监控台自动装载 Starter（1 源文件、零内部依赖）：把 codecentric admin-starter-server 经一个空的 @Configuration+@EnableAdminServer 类改造为放 classpath 即自动拉起图形化监控中心，单布尔开关默认开启。瑕疵含【高危】仅有布尔门无 @ConditionalOnClass、admin 依赖 provided 不传递缺类即启动失败、pin 2.2.3 与根版本错配。

- 详细文档：[i2f-springcloud-actuator-admin-starter](./i2f-springcloud/i2f-springcloud-actuator-admin-starter/readme.md)

### i2f-springcloud-actuator-starter

> Spring Boot Admin 客户端接入 + Actuator 端点暴露自动装载 Starter（admin-starter 的客户端对偶，1 源文件、零内部依赖）：设计意图用单布尔开关（默认 true）控制本服务向 Admin Server 注册并暴露端点。瑕疵含【高危·空转】唯一类是完全空的 @Configuration 无 @Bean/@Import/@Enable，装载对容器零影响、enable:false 亦不能阻止注册。

- 详细文档：[i2f-springcloud-actuator-starter](./i2f-springcloud/i2f-springcloud-actuator-starter/readme.md)

### i2f-springcloud-alibaba-nacos-starter

> 阿里 Nacos（服务注册发现 + 配置中心）即插即用装配 Starter（本组注册中心子域核心，1 源文件、零内部依赖）：将 nacos-discovery/-config 与 loadbalancer 作 provided 引入，经带 @EnableDiscoveryClient 的 @Configuration + 单布尔开关门控自动装载；版本由根 BOM spring-cloud-alibaba 2021.0.5.0 治理。瑕疵含开关无法阻止 nacos 自身注册拉取、全仓零消费方。

- 详细文档：[i2f-springcloud-alibaba-nacos-starter](./i2f-springcloud/i2f-springcloud-alibaba-nacos-starter/readme.md)

### i2f-springcloud-alibaba-seata-starter

> Apache Seata 分布式事务即插即用装配 Starter（本组分布式事务子域唯一接入件，1 源文件、零内部依赖）：将 seata 作 provided+optional 引入，经 @Configuration + 布尔开关门控自动装载，附 sample，版本由根 BOM 治理。瑕疵含【高危·开关键拼写分裂】代码用错拼 seate 而元数据登记正确 seata，致按文档设 seata.enable=false 完全无效、类为空壳。

- 详细文档：[i2f-springcloud-alibaba-seata-starter](./i2f-springcloud/i2f-springcloud-alibaba-seata-starter/readme.md)

### i2f-springcloud-alibaba-sentinel-starter

> 阿里 Sentinel（流控/熔断/热点/系统/授权）即插即用装配 Starter（本组流量治理子域核心，2 源文件，本组首个含真实功能且有内部依赖者）：除空壳 SentinelAutoConfiguration 外，核心 DefaultSentinelBlockExceptionHandler 依赖 i2f-resp，把五类 BlockException 统一转为 ApiResp.error JSON。瑕疵含被限流仍恒 setStatus(200)、缺 @ConditionalOnClass。

- 详细文档：[i2f-springcloud-alibaba-sentinel-starter](./i2f-springcloud/i2f-springcloud-alibaba-sentinel-starter/readme.md)

### i2f-springcloud-config-client-starter

> Spring Cloud Config 客户端装配 Starter（本组配置中心子域客户端，3 源文件，本组功能最完整且唯一带 @ConditionalOnClass 兜底）：除薄壳外，额外实现基于 Git commit 版本轮询、无需消息总线即可让 Config 客户端热更新的自定义刷新器（周期 GET 取 version 比对变化则 refresh）。瑕疵含 new RestTemplate 无超时可卡死调度线程。

- 详细文档：[i2f-springcloud-config-client-starter](./i2f-springcloud/i2f-springcloud-config-client-starter/readme.md)

### i2f-springcloud-config-server-starter

> Spring Cloud Config 服务端装配 Starter（本组配置中心子域服务端，2 源文件含 native 示范配置、零内部依赖）：以 @EnableConfigServer + 布尔开关自动拉起 Config Server；核心 ResponseAdvice 专为 native 本地文件模式（官方 version 恒 null）合成 SHA-256 版本号，补齐客户端轮询刷新所缺的 version。瑕疵含缺 @ConditionalOnClass 致 NCDNF。

- 详细文档：[i2f-springcloud-config-server-starter](./i2f-springcloud/i2f-springcloud-config-server-starter/readme.md)

### i2f-springcloud-consul-starter

> HashiCorp Consul（服务注册发现 + 配置中心）即插即用装配 Starter（本组注册/配置中心子域，1 源文件、零内部依赖）：将 consul-discovery/-config 作 provided 引入，经带 @EnableDiscoveryClient 的 @Configuration + 单布尔开关（默认 true）门控自动装载。瑕疵含【高危】缺 @ConditionalOnClass + provided 不传递，默认开装载即 NCDNF 启动失败。

- 详细文档：[i2f-springcloud-consul-starter](./i2f-springcloud/i2f-springcloud-consul-starter/readme.md)

### i2f-springcloud-discovery-server-starter

> 自研轻量级服务注册中心服务端装配 Starter（本组服务发现子域服务端，配套 discovery-starter 客户端；5 源文件、零内部依赖）：不依赖现成注册中心框架，改用 Redis 作实例存储 + 一组 HTTP POST 接口 + SHA-256 签名校验，从零实现最小可用注册/发现服务端。瑕疵含【高危】默认 secretKey 硬编码 123456 致签名鉴权形同虚设、注入管理器缺失时启动崩溃。

- 详细文档：[i2f-springcloud-discovery-server-starter](./i2f-springcloud/i2f-springcloud-discovery-server-starter/readme.md)

### i2f-springcloud-discovery-starter

> 自研轻量级服务发现客户端装配 Starter（本组服务发现子域客户端，discovery-server-starter 的对偶；6 源文件、零内部依赖）：不依赖现成框架，自研实现 Spring Cloud DiscoveryClient，两并存来源——配置式 Provider 与远程注册式 Provider（起双线程心跳上报/拉全量，sign=SHA-256 与服务端一致）。瑕疵含【高危】registry.enable 默认开使后台持续 POST 刷屏、双前缀 /api/api 开箱 404。

- 详细文档：[i2f-springcloud-discovery-starter](./i2f-springcloud/i2f-springcloud-discovery-starter/readme.md)

### i2f-springcloud-gateway-starter

> Spring Cloud Gateway 增强装配 Starter（本组服务网关子域核心，本组功能最完整非薄封装的增强件：9 源文件、零内部依赖）：经 @Import 拉入代码式 CORS、自定义断言与过滤器 RequestAttr 系列、注入 trace-id 并按 path/IP 统计的请求日志全局过滤器、重复参数剪除，另有抽象 token 鉴权模板，各子件独立开关。瑕疵含缺 @ConditionalOnClass 致 NCDNF、默认 CORS 不安全。

- 详细文档：[i2f-springcloud-gateway-starter](./i2f-springcloud/i2f-springcloud-gateway-starter/readme.md)

### i2f-springcloud-gateway-swl-starter

> Spring Cloud Gateway「SWL 安全传输网关装配 Starter」（本组服务网关子域，Servlet 侧 swl-starter 的响应式对偶；7 源文件、含 5 个内部 compile 依赖本组少见）：把 SwlTransfer 加解密协议搬到网关边缘——GlobalFilter 请求侧缓冲 body 解密重建、响应侧加密包装，另一过滤器拦 POST /swl/swapKey 完成公钥握手。瑕疵含【高危】无 Content-Type 解密 NPE、clientIp 可伪造。

- 详细文档：[i2f-springcloud-gateway-swl-starter](./i2f-springcloud/i2f-springcloud-gateway-swl-starter/readme.md)

### i2f-springcloud-loadbalancer-starter

> Spring Cloud LoadBalancer 客户端负载均衡装配 Starter（本组负载均衡子域，netflix-ribbon-starter 旧 Ribbon 的新一代对偶；仅 1 个 27 行源文件、零内部依赖，本组典型纯空壳转发件）：除 afterPropertiesSet 打一行日志外不做任何定制增强——无 @Bean、无自定义 ReactorLoadBalancer，能力全靠使用方自引官方 starter-loadbalancer。瑕疵含纯空壳零增强、全仓零消费方。

- 详细文档：[i2f-springcloud-loadbalancer-starter](./i2f-springcloud/i2f-springcloud-loadbalancer-starter/readme.md)

### i2f-springcloud-netflix-eureka-client-starter

> Netflix Eureka 服务注册客户端装配 Starter（本组服务注册与发现子域；仅 1 个 25 行源文件、零内部依赖，纯空壳件）：类体零字段，唯一行为是携带 @EnableEurekaClient——作为官方同名自动配置的布尔门代理，通过布尔开关控制是否触发 Eureka 客户端注册。瑕疵含 provided 不传递 + 无 @ConditionalOnClass 缺 classpath 即 NCDNF、全仓零消费方。

- 详细文档：[i2f-springcloud-netflix-eureka-client-starter](./i2f-springcloud/i2f-springcloud-netflix-eureka-client-starter/readme.md)

### i2f-springcloud-netflix-eureka-server-starter

> Netflix Eureka 注册中心服务端装配 Starter（本组服务注册与发现子域，与 eureka-client-starter 为镜像对称的 client/server 对；仅 1 个 25 行源文件、零内部依赖，纯空壳布尔门代理）：类体零字段，唯一行为是携带 @EnableEurekaServer 触发官方 Eureka Server 自动配置（管理面板/注册表/驱逐线程）。瑕疵含缺 @ConditionalOnClass 即 NCDNF、全仓零消费方。

- 详细文档：[i2f-springcloud-netflix-eureka-server-starter](./i2f-springcloud/i2f-springcloud-netflix-eureka-server-starter/readme.md)

### i2f-springcloud-netflix-hystrix-starter

> Netflix Hystrix 熔断降级装配 Starter（本组熔断降级子域，sentinel-starter 的旧 Netflix 对偶、已 EOL；仅 1 个 29 行源文件，本组唯一版本时间胶囊——模块级自引 Boot 2.3.7/Cloud Hoxton BOM 覆盖根版本与主版本不兼容）：类体零字段，@EnableHystrix 触发断路器 + 打一行日志。瑕疵含模块级 BOM 覆盖根版本架构级危险、引用已被移除的组件、全仓零消费方应迁移 Sentinel。

- 详细文档：[i2f-springcloud-netflix-hystrix-starter](./i2f-springcloud/i2f-springcloud-netflix-hystrix-starter/readme.md)

### i2f-springcloud-netflix-openfeign-starter

> Spring Cloud OpenFeign 声明式 HTTP 客户端装配 Starter（本组服务调用子域；仅 1 个 29 行源文件，本组功能最重的 Enable 注解代理）：类体零字段，@EnableFeignClients 触发 FeignClientsRegistrar 扫描 @FeignClient 接口并注册 HTTP 代理 Bean。瑕疵含缺 @ConditionalOnClass 即 NCDNF、默认开全局 Feign 扫描、全仓零消费方。

- 详细文档：[i2f-springcloud-netflix-openfeign-starter](./i2f-springcloud/i2f-springcloud-netflix-openfeign-starter/readme.md)

### i2f-springcloud-netflix-ribbon-starter

> Netflix Ribbon 客户端负载均衡装配 Starter（本组负载均衡子域，loadbalancer-starter 的旧 Ribbon 对偶、已 EOL；仅 1 个 27 行源文件、零内部依赖，本组最纯粹空壳件——类体零字段、零 @Enable、零 @Bean，仅打一行日志）：Ribbon 无 @EnableRibbon，本件退化为纯日志标记。相对规范处：provided 标了 optional 无 NCDNF。瑕疵含纯空壳、全仓零消费方应迁移 LoadBalancer。

- 详细文档：[i2f-springcloud-netflix-ribbon-starter](./i2f-springcloud/i2f-springcloud-netflix-ribbon-starter/readme.md)

### i2f-springcloud-netflix-zuul-starter

> Netflix Zuul 1.x 边缘网关装配 Starter（本组服务网关子域的 Servlet 阻塞式分支、已 EOL；2 个源文件）：ZuulAutoConfiguration 携 @EnableZuulProxy 布尔门代理；ZuulResponseCharsetFilter 在响应写出前 setCharacterEncoding 规避中文乱码。瑕疵含 BOM 覆盖架构级、NCDNF、全仓零消费方应迁移 Gateway。

- 详细文档：[i2f-springcloud-netflix-zuul-starter](./i2f-springcloud/i2f-springcloud-netflix-zuul-starter/readme.md)

### i2f-springcloud-refresh-starter

> Spring Cloud Context 动态刷新装配 Starter（本组配置外部化与动态刷新子域，与 config-client-starter 互补；3 源文件，本组功能最完整自研件、唯一依赖 i2f-otpauth）：在官方 ContextRefresher/RefreshScope 之上叠加定时自动刷新（默认 5min）+ TOTP 二次口令鉴权的 REST 手动刷新端点。瑕疵含【高危】先建池后判 delay 且 return 不 shutdown、端点无鉴权可被滥用。

- 详细文档：[i2f-springcloud-refresh-starter](./i2f-springcloud/i2f-springcloud-refresh-starter/readme.md)

### i2f-springcloud-sleuth-starter

> Spring Cloud Sleuth 分布式链路跟踪装配 Starter（本组链路跟踪子域，与 zipkin-starter 为观测性配对；仅 1 个 27 行零字段源文件，本组典型纯空壳转发件）：类体零字段，afterPropertiesSet 仅打一行日志，无任何 @Bean/自定义 Sampler，能力全靠使用方自引官方 starter-sleuth。瑕疵含纯空壳、enable=false 关不掉跟踪、全仓零消费方。

- 详细文档：[i2f-springcloud-sleuth-starter](./i2f-springcloud/i2f-springcloud-sleuth-starter/readme.md)

### i2f-springcloud-zipkin-starter

> Zipkin 链路跟踪数据上报装配 Starter（本组链路跟踪/可观测性子域、本组最后建档模块，与 sleuth-starter 为上报端/生成端配对且源码逐行对称；仅 1 个 27 行零字段源文件，本组典型纯空壳转发件）：类体零字段，afterPropertiesSet 仅打一行日志，无任何 @Bean/自定义 Reporter；pom 代引 sleuth-zipkin 承载自动配置但须 Sleuth 核心在位才产可上报 span。瑕疵含纯空壳、全仓零消费方。

> 至此 `i2f-springcloud` 组 22 个真实模块（跳过 `test-gateway-swl`）已全部建档并登记索引。

- 详细文档：[i2f-springcloud-zipkin-starter](./i2f-springcloud/i2f-springcloud-zipkin-starter/readme.md)

## i2f-tools

> 开发/构建辅助工具集合，提供与工程构建、代码生成集成的独立能力。

### i2f-jdbc-procedure-idea-plugin

> IntelliJ IDEA 平台桌面插件「XProc4J 智能开发插件」（i2f-tools 组建档模块，全仓唯一 Gradle + org.jetbrains.intellij 构建件；JDK17）：为 XProc4J（XML 存储过程）与 TinyScript/Ognl/Funic/Funvi 4 门自定义语言提供引用跳转/多语言注入/补全/断点调试/语法转换等 IDE 能力。瑕疵集中在工程治理：完全游离 Maven reactor、硬编码本机 IDEA localPath 换机即构建失败。

- 详细文档：[i2f-jdbc-procedure-idea-plugin](./i2f-tools/i2f-jdbc-procedure-idea-plugin/readme.md)

### i2f-maven-plugin

> i2f 构建期 Maven 插件（i2f-tools 组首个建档模块，全仓唯一 packaging=maven-plugin 件）：提供单目标 i2f:spi，绑定 process-classes 阶段，基于 ASM 零类加载扫描 target/classes 下标 @Spi 的 class，为声明接口自动生成并合并 META-INF/services 描述文件，构成 SPI 闭环中枢。瑕疵含游离 reactor 无 parent、version=1.0 需单独 install、全仓零消费方。

- 详细文档：[i2f-maven-plugin](./i2f-tools/i2f-maven-plugin/readme.md)

### i2f-tools-face-recognizer

> 人脸识别可执行工具壳（i2f-tools 组装档模块，纯 main 示例件、零自研算法）：把 extension-opencv-javacv 的 OpenCvFaceRecognizer（JavaCV/OpenCV LBPH）经 assembly 打成带 Main-Class 的自包含 fat jar，演示目录约定训练→模型载入→批量测试→预测画框离线全流程。瑕疵含游离 reactor 被注释不参与构建、fat jar 携全平台原生库体积巨大。

- 详细文档：[i2f-tools-face-recognizer](./i2f-tools/i2f-tools-face-recognizer/readme.md)

### i2f-tools-ops

> 可部署运维控制台 / AI 工具宿主应用（i2f-tools 组唯一成品级 SpringBoot 应用，依赖面最宽）：两级启动，扫描 Ext-Path=plugins 建扩展类加载器实现丢 starter 即扩展；ToolOpsApplication 继承 WarBootApplication 故 jar/war 双形态，@Tools 条件装配 AI 工具集，内置多 JDBC 驱动含国产库。瑕疵含游离 reactor、webType 判断语义反转。
- 详细文档：[i2f-tools-ops](./i2f-tools/i2f-tools-ops/readme.md)

### i2f-tools-agent

> Java Agent 可执行发行壳（i2f-tools 组装档模块，零自研源码、纯 pom 打包件）：把 extension-agent-javassist 的运行时增强引擎经 assembly 打成自包含 jar，清单声明双身份——Main-Class（java -jar 交互式投放器）与 Premain/Agent-Class（-javaagent 入口）。瑕疵含游离 reactor、tools.jar 写死 JDK8 布局 JDK9+ attach 失败。

- 详细文档：[i2f-tools-agent](./i2f-tools/i2f-tools-agent/readme.md)

### i2f-tools-encrypt

> 命令行加解密/编解码一体化工具壳（i2f-tools 组装档模块、零自研密码算法）：以单一契约 IMenuHandler + CryptMain 静态注册表，把 JDK 编码、摘要/HMAC/AES/RSA、PasswordEncoder、jasypt、国密约 104 个算法入口收敛为 java -jar <菜单名> [参数] 单发命令。核心瑕疵：BC 双版本同包冲突、help.txt 张冠李戴、游离 reactor、退出码恒 0。
- 详细文档：[i2f-tools-encrypt](./i2f-tools/i2f-tools-encrypt/readme.md)

### i2f-tools-source-copier

> Java 源码「依赖闭包抽取」命令行工具壳（i2f-tools 组装档模块，单类 main 分发件，组内唯一仍参与 reactor 默认构建）：单类 JavaSourceCodeCopier 以 -s/-c/-o 三参数，从入口做 BFS 传递依赖闭包——解析 package/import、通配展开、跳过 java*/javax*，按包名保结构复制，摘出带依赖的最小源码子集。核心瑕疵：包名拼写 soure、import static 静默丢失、裸 contains 短名假阳性。
- 详细文档：[i2f-tools-source-copier](./i2f-tools/i2f-tools-source-copier/readme.md)
