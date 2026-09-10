# i2f-container-builder

> **流式集合/Map/对象构建器族**（4 Builder + 1 静态门面 `Builders`、约 1190 行源码、依赖 `i2f-typeof`）——以 *fluent builder* 模式为 JDK 集合框架补齐「链式构造」能力：`ObjectBuilder<T>` 用 `then`/`set` 经方法引用链式修改任意 POJO；`CollectionBuilder<E,C>`/`ListBuilder<E,C>` 以 `add`/`adds` 多重重载（变长参数/Iterable/Iterator + 转换函数 + Predicate 过滤 + null 安全）流式填充集合；`MapBuilder<K,V,M>` 以 `put`/`putKeys` 多重变体（固定值/值函数 + 键转换 + key 过滤）流式填充 Map，并委拖 Map 全部变更操作的 fluent 包装（`putAll`/`remove`/`replaceAll`/`computeIfAbsent`/`merge` 等）。全部 Builder 实现 `Supplier<T>`（`.get()` 终结），并由 `Builders` 提供约 50 个静态工厂方法（`newArrayList(String.class)` / `newHashMap(String.class,Object.class)` / `newObj(TestBean::new)`），借助 `i2f-typeof.TypeToken` 可选还原泛型类型——但 `TypeToken`/`Class` 参数仅接受存储，不做运行期类型校验，属于「API 友好设计」。真实消费方 `i2f-bql`（BQL 表达式树链式装配）、`i2f-extension-xproc4j`/`i2f-jdbc-procedure`/`i2f-springboot-xproc4j-starter` 经 `MapBuilder`/`ListBuilder` 做声明式数据拼装。

## 模块路径

- `i2f-jdk/i2f-container-builder`

## 模块依赖

| 坐标 | scope | optional | 说明 |
|---|---|---|---|
| `i2f.turbo:i2f-typeof` | compile | false | `TypeToken` 泛型令牌（`Builders`/`ObjectBuilder`/`CollectionBuilder`/`ListBuilder`/`MapBuilder` 均使用） |

无任何三方运行期依赖。

## 模块设计

### 1. 四 Builder + 一门面架构

```
Builders (静态工厂门面, ~50 方法)
 ├── obj(T) / newObj(Supplier) ──→ ObjectBuilder<T>  (57 行)
 ├── map(M) / newMap(Supplier) ──→ MapBuilder<K,V,M> (423 行)
 ├── collection(C) / newCollection(Supplier) ──→ CollectionBuilder<E,C> (227 行)
 └── list(C) / newList(Supplier) ──→ ListBuilder<E,C>    (267 行)

全部实现 Supplier<T> ──→ .get() 终结
```

- **`Builders`**：约 50 个 `public static` 工厂方法，每个 Builder 均提供「按现有实例包装」与「按 `Supplier` 新建」两个入口，并为常用容器类型（`HashMap`/`LinkedHashMap`/`ConcurrentHashMap`/`ArrayList`/`LinkedList`/`CopyOnWriteArrayList`/`HashSet`/`LinkedHashSet`/`CopyOnWriteArraySet`）提供专用快捷工厂（如 `Builders.newArrayList(String.class)`）。
- 每个 Builder 的构造器均接受可选的 `Class<T>` 或 `TypeToken<T>` 参数——源于 `i2f-typeof` 的泛型令牌，但当前版本**仅存储不校验**，属于预留扩展点。

### 2. 通用链式骨架（四 Builder 共享）

每个 Builder 均实现 `Supplier<T>`（`.get()` 返回内部持有容器实例），并提供 4 个通用方法：

| 方法 | 签名 | 语义 |
|---|---|---|
| `then` | `Consumer<C>` | 消费当前容器做任意操作，返回 `this` |
| `set` | `BiConsumer<C, U>, U` | 带参数的 `then` 变体 |
| `call` | `Function<C, R>` | 调用返回值的操作（忽略返回值），返回 `this` |
| `apply` | `BiFunction<C, U, R>, U` | 带参数的 `call` 变体 |
| `getAs` | `Function<C, R>` | 终结 + 转换（不同于 `.get()` 的直接返回） |

### 3. 领域特异方法

#### ObjectBuilder\<T\>
- `then(Consumer<T>)`：消费当前对象做任意操作（如调用 setter/incAge）
- `set(BiConsumer<T,U>, U)`：带参的 `then`——典型用法 `objBuilder.set(TestBean::setAge, 22)`

#### CollectionBuilder\<E, C extends Collection\<E\>\>
- `add(E)` / `remove(Object)` / `addAll(Collection)` / `removeAll(Collection)` / `retainAll(Collection)` / `clear()` / `removeIf(Predicate)`
- `adds(E...)` / `adds(Iterable)` / `adds(Iterator)`：直接填充元素
- `adds(Function<H,E>, H...)` / `adds(Iterable<H>, Function<H,E>)` / `adds(Iterator<H>, Function<H,E>)`：转换后填充
- `adds(Predicate<E>, E...)` / `adds(Iterable, Predicate)` / `adds(Iterator, Predicate)`：过滤后填充
- `addsNonNull(E...)` / `addsNonNull(Iterable)` / `addsNonNull(Iterator)`：null 安全填充
- 复合重载：`adds(Function<H,E>, Predicate<E>, H...)` / `adds(Iterable<H>, Function<H,E>, Predicate<E>)` / `adds(Iterator<H>, Function<H,E>, Predicate<E>)`：转换 + 过滤 + 填充

#### ListBuilder\<E, C extends List\<E\>\>
- 继承全部 CollectionBuilder 的 `add/adds/remove/addAll` 等方法
- 专有方法：`add(int, E)` / `set(int, E)` / `remove(int)` / `addAll(int, Collection)` / `replaceAll(UnaryOperator)` / `sort(Comparator)`

#### MapBuilder\<K, V, M extends Map\<K, V\>\>
- 内部静态工厂：`of(M)` / `ofHashMap` / `ofLinkedHashMap` / `ofTreeMap` / `ofObjectMap`
- `put(K, V)` / `putAll(Map)` / `remove(Object)` / `clear()`
- `putKeys(V value, K... keys)` / `putKeys(V value, Iterable<K>)` / `putKeys(V value, Iterator<K>)`：多键共享同一值
- `putKeys(Function<K,V> valueFunction, K... keys)` / `putKeys(Function<K,V>, Iterable)` / `putKeys(Function<K,V>, Iterator)`：按键派生值
- `<H> putKeys(V value, Iterable<H>, Function<H,K> keyFunction)` / `putKeys(V value, Iterator<H>, Function<H,K>)` / `putKeys(V value, Function<H,K> keyFunction, H...)`：键转换后填充
- 复合：`putKeys(V, Iterable<H>, Function<H,K>, Predicate<K>)` / `putKeys(Function<K,V>, Iterable<H>, Function<H,K>, Predicate<K>)` 等：转换 + 过滤 + 填充
- `putNonNullKeys(V value, K... keys)` 等 null 安全变体
- `putIfAbsent` / `replace` / `replaceAll` / `remove(key, value)` / `computeIfAbsent` / `computeIfPresent` / `compute` / `merge`：完整 Map 变更操作 fluent 壳

### 4. 设计模式

- **Fluent Builder 模式**：所有 `add/put/set` 返回 `this`
- **Supplier 终止模式**：`.get()` 返回内部容器，`.getAs(Function)` 提供自定义提取
- **静态工厂**：`Builders` 统一入口，`MapBuilder.of(...)` 另辟直接路径
- **装饰器模式**：Builder 不创建容器，而是包装用户传入的现有实例做链式操作

## 模块目的

- 解决 JDK 集合类无原生链式构造的痛点：`map.put("k1","v1"); map.put("k2","v2");` → `Builders.newHashMap(...).put("k1","v1").put("k2","v2").get()`
- 避免匿名双大括号（`new HashMap{{put(...);}}`）的序列化与内存泄露陷阱
- 为集合/Map 批量填充提供「源转换 + 条件过滤 + null 安全」的多源异构数据接入能力
- 为 POJO 对象提供方法引用风格的流式初始化，替代冗长的多行 setter 调用

## 模块功能

1. **对象链式修改**：`ObjectBuilder` 通过方法引用链式调用目标对象的 setter/mutator
2. **集合流式填充**：`CollectionBuilder`/`ListBuilder` 支持变长参数、Iterable、Iterator 多源数据接入，含转换函数与 Predicate 过滤
3. **Map 流式填充**：`MapBuilder` 支持多键单值、按键派生值、键类型转换、key 过滤等多种批量填充模式
4. **通用链式骨架**：`then`/`set`/`call`/`apply` 四个通用方法让 Builder 可执行任意操作
5. **静态工厂门面**：`Builders` 统一入口，同时 `MapBuilder.of(...)` 提供直接静态工厂

## 模块主要使用方法

```java
// ObjectBuilder：链式修改 POJO
TestBean bean = Builders.newObj(TestBean::new)
        .set(TestBean::setAge, 22)
        .set(TestBean::setName, "zhang")
        .then(TestBean::incAge)
        .get();

// MapBuilder：链式填充 Map + putKeys 按函数派生值
HashMap<String, Object> map = Builders.newMap(HashMap::new, String.class, Object.class)
        .put("name", "i2f")
        .putKeys(String::valueOf, 1, 2, 3)     // "1"→"1", "2"→"2", "3"→"3"
        .putKeys(true, 4, 5, 6)                 // "4"→true, "5"→true, "6"→true
        .get();

// CollectionBuilder：adds 多源 + filter
ArrayList<String> list = Builders.newList(ArrayList::new, String.class)
        .add("hello")
        .adds(String::valueOf, 1, 2, 3)         // 转换添加 "1","2","3"
        .addsNonNull("a", null, "b")             // null 过滤
        .get();

// MapBuilder.of() 静态工厂直接构造
MapBuilder<String, Object, Map<String, Object>> mb = MapBuilder.ofObjectMap();
mb.put("key", "value");

// getAs 自定义终结
String result = Builders.newArrayList(String.class)
        .add("a").add("b")
        .getAs(list -> String.join(",", list));
```

## 模块特性总结

- **流式链式构造**：一行链式 `put`/`add`/`set` 完成集合/Map/POJO 的初始化
- **多源异构数据接入**：`adds`/`putKeys` 支持变长参数、Iterable、Iterator 三种源，配合转换函数 `Function<H,E>` 做类型适配
- **条件过滤填充**：`Predicate` 过滤 + `addsNonNull`/`putNonNullKeys` null 安全变体
- **通用扩展骨架**：`then`/`set`/`call`/`apply` 四方法可执行任意操作，不受限于 add/put
- **容器无关性**：Builder 本身不创建容器，接受任何实现对应接口的现有实例（HashMap/TreeMap/LinkedHashMap/ConcurrentHashMap 均可）
- **类型提示友好**：`Builders.newHashMap(String.class, Object.class)` 泛型推导配合 `Class` 参数做文档化类型签名
- **零三方依赖**：仅 `i2f-typeof` 一个内部依赖

## 已知实现瑕疵

1. **`TypeToken`/`Class` 参数未实际使用**：各 Builder 的三参构造器接受 `Class<E>` 或 `TypeToken<E>`，但仅存储到构造器参数，既未赋值给字段也未做任何运行期类型校验，属于形同虚设的 API 预留。
2. **无批量 getter/检查能力**：所有 Builder 只关注写入（add/put/set），无 `size()`/`contains()`/`isEmpty()` 等查询操作的 fluent 壳，用户若需中途检查需借用 `then` 回调。
3. **`apply`/`call` 返回值丢弃语义模糊**：`call(Function)` 与 `apply(BiFunction)` 接受有返回值的函数式接口但丢弃返回值返回 `this`，与方法命名的「调用」隐含习惯一致但容易被误用为 `getAs`。
4. **MapBuilder 的 `putKeys` 重载爆炸**：`putKeys` 约 30 个重载（固定值/值函数 × 三种源 × 键转换 × 过滤），编译期选择链路复杂，IDE 自动补全可能混乱。
5. **Builder 非线程安全**：Builder 内部直接操作持有的容器引用，无同步保护，不适合多线程并行链式构造。
6. **`.get()` 返回内部引用**：`get()` 返回 Builder 持有的内部容器引用，构造后可继续通过 Builder 修改（Builder 实例与容器引用未解耦），不符合严格 Builder 模式的不可变契约。