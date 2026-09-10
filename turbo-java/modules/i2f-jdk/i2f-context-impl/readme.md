# i2f-context-impl

> IoC 容器**纯 JDK 内存实现层**——落地 `i2f-context-std` 全部 4 个接口，以 2 个类约 240 行源码提供「可枚举、可命名、可读写」的轻量 Bean 容器：`ListableContext`（`implements IWritableContext`，77 行）用 `CopyOnWriteArrayList` 做后备存储，`addBean` 经 `synchronized(list)` 去重保护、`getBean` 以「精确类型匹配优先、`isAssignableFrom` 兼容匹配兜底」两阶段线性查找、`getBeans` 筛选全量、`removeBean` 委托 `list.remove`；`ListableNamingContext`（`implements IWritableNamingContext, IWritableContext`，164 行）以 `ConcurrentHashMap`（名→Bean）+ `CopyOnWriteArrayList`（索引）双结构 + `ReentrantReadWriteLock` 写锁保护（写串行、读无锁），`guessBeanName` 默认取 `全限定类名`、`addBean(name, bean)` 重复名抛 `IllegalArgumentException`、`getBean(String)` 直查 Map、`removeBean(Object)` 线性遍历值相等定位后双结构同步清理。两实现均无法满足除 `equals`/`contains` 以外的已注册 Bean 修改语义，无法处理 AOP 代理类型的匹配歧义。`ListableNamingContext` 被 `i2f-ai-std`（MCP 网关/工具提供者/测试）、`i2f-jdbc-procedure` 生产消费，`ListableContext` 被 `i2f-extension-ai-*`（DashScope/LangChain4j8/OpenAI）约 9 个文件消费。

## 模块路径

- `i2f-jdk/i2f-context-impl`

## 模块依赖

| 坐标 | scope | optional | 说明 |
|---|---|---|---|
| `i2f.turbo:i2f-context-std` | compile | false | IoC 容器标准契约，实现全部 4 个接口 |
| `org.projectlombok:lombok` | provided | true | **声明未用**——2 个源文件均无 lombok 注解 |

## 模块设计

- **最小实现策略**：仅用 JDK 内置并发容器（`CopyOnWriteArrayList`/`ConcurrentHashMap`/`ReentrantReadWriteLock`）实现 `i2f-context-std` 的 4 接口契约，零三方、零依赖。
- **两种变体**：`ListableContext`（无名）与 `ListableNamingContext`（具名），双结构设计让命名容器同时支持「按名索引 + 按类型遍历」。
- **查找优先级**：`getBean(Class)` 两阶段——先找 `clazz.equals(type)` 精确匹配（`equal`），再找 `clazz.isAssignableFrom(type)` 兼容匹配（`first`），`equal` 优先返回。这使得 `ListableContext.getBean(CharSequence.class)` 在有 `String` Bean 注入时返回 `String` 实例而非次优匹配。
- **一致性保障**：`ListableNamingContext` 写操作全部由 `lock.writeLock().lock()` 串行化，`beanMap` 与 `beanList` 始终在同一锁内更新；读操作（`getBean/getBeans/getAllBeans`）不经读锁（`CopyOnWriteArrayList` 快照迭代 + `ConcurrentHashMap` 天然安全），但 `getBeansMap` 遍历 `beanMap.entrySet()` 无读锁保护。
- **Bean 名称默认策略**：`guessBeanName()` 直接返回 `bean.getClass().getName()`（全限定类名），无去短逻辑、无元数据注解扫描。

## 模块目的

以最轻量的纯 JDK 实现落地 IoC 容器标准契约，供 `i2f-ai-std` 及其 AI 扩展方（DashScope/LangChain4j8/OpenAI）和 `i2f-jdbc-procedure` 在无 Spring 依赖的场景下获得「可编程注册 + 按类型/按名查询」的基本 Bean 管理能力。

## 模块功能

### ListableContext

| 方法 | 说明 |
|---|---|
| `addBean(Object bean)` | 注册 Bean，`synchronized(list)` + `list.contains(bean)` 去重 |
| `getBean(Class<T> clazz)` | 两阶段查找：精确类型优先，兼容匹配兜底 |
| `getBeans(Class<T> clazz)` | 按类型筛选全部匹配 Bean |
| `getAllBeans()` | 返回 `new ArrayList<>(list)` 快照副本 |
| `removeBean(Object bean)` | 委托 `list.remove(bean)`，null 参数直接返回 |

### ListableNamingContext

| 方法 | 说明 |
|---|---|
| `guessBeanName(Object bean)` | 默认返回 `bean.getClass().getName()`（全限定类名） |
| `addBean(String name, Object bean)` | 注册具名 Bean，bean 非空校验 + name 为空自动推测 + name 已存在抛异常 |
| `addBean(Object bean)` | 无参名重载，委托 `addBean(guessBeanName(bean), bean)` |
| `getBean(String name)` | `ConcurrentHashMap.get(name)` 直查 |
| `getBean(Class<T> clazz)` | 同 `ListableContext` 两阶段查找，遍历 `beanList` |
| `getBeans(Class<T> clazz)` | 遍历 `beanList` 按类型筛选 |
| `getBeansMap(Class<T> clazz)` | 遍历 `beanMap` 按类型筛选，返回 `LinkedHashMap`（保持注册顺序） |
| `getAllBeans()` | 返回 `new ArrayList<>(beanList)` 快照 |
| `getAllBeansMap()` | 返回 `new LinkedHashMap<>(beanMap)` 快照 |
| `removeBean(Object bean)` | 遍历 `beanMap` 按值 `equals` 定位后双结构同步清理 |
| `removeBean(String name)` | 按 name 直查 `beanMap`，双结构同步清理 |

## 模块主要使用方法

```java
// 使用 ListableContext（无名容器）
IWritableContext ctx = new ListableContext();
ctx.addBean(new String("hello"));
ctx.addBean(42);  // Integer 自动装箱

String str = ctx.getBean(String.class);         // → "hello"
List<Integer> ints = ctx.getBeans(Integer.class); // → [42]
List<Object> all = ctx.getAllBeans();            // → ["hello", 42]

// 使用 ListableNamingContext（具名容器）
ListableNamingContext named = new ListableNamingContext();
named.addBean("myService", new MyService());
named.addBean(new OtherService());  // 自动命名为 "i2f.context.impl.OtherService"

MyService svc = named.getBean("myService");  // 按名直查
OtherService other = named.getBean(OtherService.class);  // 按类型查
Map<String, Object> namedMap = named.getAllBeansMap();
named.removeBean("myService");
```

## 模块特性总结

- **极简实现**：2 个实现类约 240 行源码，落地 `i2f-context-std` 全部 4 接口
- **零三方运行期依赖**：仅依赖 `i2f-context-std` 契约接口 + JDK 内置并发容器
- **双变体覆盖**：`ListableContext`（无名类型仓储） + `ListableNamingContext`（具名 IoC 容器）
- **写安全**：`ListableNamingContext` 使用 `ReentrantReadWriteLock` 写锁串行化全部变更操作
- **快照返回**：`getAllBeans()`/`getAllBeansMap()` 返回不可变副本，避免调用方篡改内部状态
- **精确优先查找**：`getBean(Class)` 精确类型匹配优先于父子类兼容匹配，减少歧义
- **AI 生态标配**：被 `i2f-ai-std` 及三大 AI 扩展模块（DashScope/LangChain4j8/OpenAI）广泛消费

## 已知实现瑕疵

| 问题 | 位置 | 描述 |
|---|---|---|
| 读锁不一致 | `ListableNamingContext.getBeansMap()` L55-65 | 遍历 `beanMap.entrySet()` 时无读锁保护，并发 `put`/`remove` 可能抛出 `ConcurrentModificationException`（`ConcurrentHashMap` 弱一致性不抛，但若 `getBeansMap` 结合其他非并发操作仍有竞态） |
| `getBean` beanList 遍历非当期快照 | `ListableNamingContext.getBean(Class)` L74-97 | `beanList` 系 `CopyOnWriteArrayList`，`foreach` 获得的迭代器反映的是创建时刻快照——并发 `add` 后新 Bean 可能在一段时间内不可见 |
| `removeBean(Object)` O(n) 全表扫描 | `ListableNamingContext.removeBean(Object)` L122-145 | 没有维护 值→名 反向索引，每次按 Bean 实例删除都需要遍历整个 `beanMap`，大容器下性能差 |
| AOP 代理匹配歧义 | 两实现 `getBean(Class)` | 对于 CGLIB/JDK 动态代理 Bean，`bean.getClass()` 返回的是代理子类/$Proxy 类，与 `clazz.isAssignableFrom(type)` 兼容但 `clazz.equals(type)` 永远不会成立，导致精确匹配分支对代理 Bean 完全不可达 |
| `ListableContext` 的 `synchronized(list)` 粒度 | L18-23 | `addBean` 加锁仅覆盖 `contains`+`add`，未锁住整个 `CopyOnWriteArrayList` 的迭代器创建（`getBean` 等在锁外），非强一致性 |
| 禁止同名重写 | `ListableNamingContext.addBean(name, bean)` L39-40 | 重复名直接抛 `IllegalArgumentException`，不支持重写/覆盖，对于动态刷新场景不够灵活 |
| lombok 冗余声明 | pom.xml L16-18 | 2 个源文件均无 `@Data`/`@Getter`/`@Setter` 等注解，lombok 属**声明未用** |

## 下游与关联

```
i2f-context-std (4 接口契约)
        │
        ├── i2f-context-impl (本模块，2 实现类)
        │       ├── ListableContext
        │       │       ├── i2f-extension-ai-dashscope  (DashScopeChatAiProvider, DashScopeRoleChatAiProvider)
        │       │       ├── i2f-extension-ai-langchain4j8 (Langchain4j8ChatAiProvider, Langchain4j8RoleChatAiProvider)
        │       │       └── i2f-extension-ai-openai      (OpenAiChatAiProvider, OpenAiRoleChatAiProvider)
        │       └── ListableNamingContext
        │               ├── i2f-ai-std  (ContextMcpToolGatewayManager, ContextAppMcpToolProvider)
        │               ├── i2f-jdbc-procedure (BasicJdbcProcedureExecutor)
        │               └── i2f-tools (JdbcProcedureXmlLangInjectInjector 模板字符串)
        │
        ├── i2f-spring-core (适配 Spring 容器)
        └── i2f-extension-ai-* (面向接口编程)
```