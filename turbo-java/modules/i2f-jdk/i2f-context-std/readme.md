# i2f-context-std

> IoC 容器**标准契约层**（`std` 契约与实现分离），延续 `i2f-cache-std`/`i2f-codec-std`/`i2f-compress-std` 的「接口稳定、实现可换」范式。全模块仅 **4 个纯接口**（58 行总代码），零 i2f 内部依赖、零三方运行期依赖：以根接口 `IContext` 用 `getBean(Class)`/`getBeans(Class)`/`getAllBeans()` 三动词刻画「按类型查询 Bean」的最小 IoC 容器契约；`INamingContext extends IContext` 补充按名查询维度 — `getBean(String)` + `getBeansMap(Class)`（类型→名值 Map）+ `getAllBeansMap()`，把无名的类型仓储提升为具名的 IoC 容器；`IWritableContext extends IContext` 与 `IWritableNamingContext extends INamingContext` 各自添加 `addBean`/`removeBean` 写操作，覆盖「可写无名」和「可写具名」两种容器变体。4 接口构成 2×2 矩阵（查询维度 × 读写性），正交完备。下游 `i2f-context-impl.ListableContext`（`IWritableContext` 实现）与 `i2f-ai-std`/`i2f-extension-ai-*` 等约 25 个文件面向 `IContext`/`INamingContext` 接口编程消费；`i2f-spring-core` 依赖本模块做 Spring 容器适配。

## 模块路径

- `i2f-jdk/i2f-context-std`

## 模块依赖

| 坐标 | scope | optional | 说明 |
|---|---|---|---|
| `org.projectlombok:lombok` | provided | - | 声明未用——4 个源文件均为纯接口，无注解 |

## 模块设计

### 2×2 正交接口矩阵

模块以两个维度正交组合出 4 个接口：

| 维度 | 只读 | 可写（+`addBean`/`removeBean`） |
|---|---|---|
| **按类型查询** | `IContext` | `IWritableContext` |
| **按名+按类型查询** | `INamingContext` | `IWritableNamingContext` |

### 继承层次

```
IContext (getBean, getBeans, getAllBeans)
├── INamingContext (getBean(String), getBeansMap, getAllBeansMap)
│   └── IWritableNamingContext (addBean(name,bean), removeBean(name))
└── IWritableContext (addBean(bean), removeBean(bean))
```

- `IContext` 定义最小 IoC 契约：按类型取单例 / 批量取 / 取全部
- `INamingContext` 在此基础上补充「按名查找」与「类型→名值 Map」能力，是主流 IoC 容器（Spring/Guice）的抽象映射
- `IWritableContext`/`IWritableNamingContext` 打开写入口，让容器可编程注册/移除 Bean，适用于无 DI 注入的轻量环境

### 设计特点

- **查询与写入分离**：只读接口（`IContext`/`INamingContext`）面向消费者，可写接口（`IWritable*`）面向容器实现者和装配器
- **纯标记语义**：4 接口合计仅 10 个方法签名，无默认方法、无泛型约束、无异常声明，是框架无关的最薄契约
- **零内部依赖**：不依赖 `i2f` 任何模块，仅 JDK 标准库（`java.util.List`/`Map`）

## 模块目的

1. **统一 IoC 容器抽象**：为整个 `i2f-turbo-java` 生态（AI 标准层、扩展模块、Spring 集成）提供框架无关的容器查询契约，让库代码不绑定 Spring/Guice 等具体 IoC 容器
2. **读写分离**：消费者只需 `IContext`/`INamingContext` 只读接口即可完成依赖查找，实现层通过 `IWritable*` 提供编程式 Bean 注册
3. **多实现兼容**：`i2f-context-impl` 提供 JDK 纯内存实现（`ListableContext`），`i2f-spring-core` 适配 Spring 容器，`i2f-extension-*-ai` 在 AI 场景下全域消费

## 模块功能

| 接口 | 方法 | 功能描述 |
|---|---|---|
| `IContext` | `getBean(Class<T>)` | 按类型返回唯一匹配的 Bean |
| | `getBeans(Class<T>)` | 按类型返回全部匹配的 Bean 列表 |
| | `getAllBeans()` | 返回容器中所有 Bean |
| `INamingContext` | `getBean(String)` | 按名称返回 Bean |
| | `getBeansMap(Class<T>)` | 按类型返回 `Map<名称, Bean>` |
| | `getAllBeansMap()` | 返回全量 `Map<名称, Bean>` |
| `IWritableContext` | `addBean(Object)` | 注册无名称的 Bean 实例 |
| | `removeBean(Object)` | 移除指定的 Bean 实例 |
| `IWritableNamingContext` | `addBean(String, Object)` | 按名称注册 Bean 实例 |
| | `removeBean(String)` | 按名称移除 Bean |

## 模块主要使用方法

### 面向接口消费（消费者视角）

所有 AI 提供者、工具管理器等库代码仅依赖 `IContext`/`INamingContext` 接口：

```java
// 注入或获取 IContext 实例
IContext ctx = ...; // 由上层容器注入

// 按类型获取 Bean
MyService service = ctx.getBean(MyService.class);

// 按类型获取全部 Bean
List<MyService> services = ctx.getBeans(MyService.class);

// 按名称获取 Bean（INamingContext）
INamingContext namingCtx = (INamingContext) ctx;
MyService named = namingCtx.getBean("myService");

// 按类型获取名称→Bean 映射
Map<String, MyService> namedMap = namingCtx.getBeansMap(MyService.class);
```

### 编程式容器装配（实现者视角）

```java
// 创建可写命名容器
IWritableNamingContext ctx = new MyContext();

// 注册 Bean
ctx.addBean("userService", new UserService());
ctx.addBean("orderService", new OrderService());

// 移除 Bean
ctx.removeBean("userService");
```

## 模块特性总结

- **极薄契约**：4 纯接口、10 方法、58 行总代码，是 `i2f-turbo-java` 生态中最薄的 std 模块之一
- **2×2 正交矩阵**：查询维度（类型级 / 名称+类型级）与读写性（只读 / 可写）正交组合
- **零运行期依赖**：pom 仅声明 lombok（未用），运行期零三方
- **生态底座**：被 `i2f-ai-std`（约 8 文件）、`i2f-extension-ai-*`（dashscope/langchain4j/openai 约 12 文件）、`i2f-extension-xproc4j`（3 文件）、`i2f-context-impl`（1 文件）、`i2f-spring-core` 广泛消费
- **框架无关**：不绑定任何特定 IoC 容器，Spring 环境下由 `i2f-spring-core` 适配，纯 JDK 环境由 `i2f-context-impl` 支撑

## 下游与关联

### 直接依赖本模块的模块（POM）

| 模块 | 消费接口 | 说明 |
|---|---|---|
| `i2f-context-impl` | `IWritableContext` | `ListableContext` 纯内存实现 |
| `i2f-ai-std` | `IContext`/`INamingContext` | AI 服务代理、MCP 网关、Tool 管理器等约 8 文件 |
| `i2f-ai-rest-openai` | `IContext` | MCP 服务端实现 |
| `i2f-spring-core` | - | 声明依赖用于 Spring 容器适配 |
| `i2f-extension-ai-dashscope` | `IContext` | DashScope AI 提供者 4 文件 |
| `i2f-extension-ai-langchain4j8` | `IContext` | LangChain4j 提供者 4 文件 |
| `i2f-extension-ai-openai` | `IContext` | OpenAI 提供者 4 文件 |
| `i2f-extension-xproc4j` | `INamingContext` | JDBC 执行器与表达式求值 |

### 生态位关系

```
┌─────────────────────────────────────────────────────┐
│                  消费者 (IContext/INamingContext)      │
│  i2f-ai-std / i2f-extension-ai-* / i2f-extension-xproc4j │
└────────┬────────────────────────────────────────────┘
         │ 面向接口编程
┌────────▼────────────────────────────────────────────┐
│            i2f-context-std (4 接口契约)                │
└────────┬────────────────────────────────────────────┘
         │ 多实现
    ┌────┴────┐
    ▼         ▼
i2f-context-impl    i2f-spring-core
(纯 JDK 内存容器)     (Spring 容器适配)
```

## 已知实现瑕疵

以下瑕疵均经源码逐行核实：

1. **泛型方法 `getBeans`/`getAllBeans` 返回值擦除**：`List<T> getBeans(Class<T>)` 返回 `List<T>` 但实现方内部通常做 unchecked 转型，调用者可能收到类型不匹配的元素——这是 Java 泛型擦除的固有限制，但接口未声明 `@SuppressWarnings` 指引
2. **无唯一性保证**：`getBean(Class)` 未约定多个匹配时的行为（抛异常 / 取首个 / 随机），由各实现自行决定，消费者可能面临不一致体验
3. **生命周期管理缺失**：接口无 `destroy`/`init` 回调或 `AutoCloseable` 约定，`addBean` 注册的 Bean 无生命周期托管
4. **lombok 冗余声明**：pom 声明 `lombok` provided 但 4 个源文件均无注解，属 `i2f-jdk` 父 POM 统一声明模板的残余