# i2f-container

> **集合容器增强工具族**（30 源文件、约 3800 行源码、零三方依赖）——补充 JDK 集合框架六大缺失能力：`CollectionUtil`（~300 个 `public static` 方法、870 行）以 `of/as/ofArgs/ofArray/as/arrayAs` 六族 + 变长参数 + `Iterator` 源 + `index/length` 切片 + `filter/mapper` + 8 种基本类型数组 9 核电重载覆盖全部集合→迭代器/数组的批量收集场景；`RingQueue` 基于环形数组 + `ReentrantReadWriteLock` + `Condition` 双条件变量实现**有界阻塞环形队列**（容量自动 +1 哨兵槽），`enqueue`/`dequeue` 满/空时 `await` 阻塞等待、`dequeueIf`/`dequeueAllIf` 非阻塞变体、`head`/`tail`/`get`/`set` 索引随机访问；`map.LruMap` 以 44 行覆写 `LinkedHashMap.removeEldestEntry` 实现**容量淘汰 LRU Map**，`SyncLruMap` 借 `SyncLinkedHashMapAdapter` 套线程安全壳；`set.ConcurrentSet` 以 `ConcurrentHashMap<E,Boolean>` 实现**并发 Set**（`add`/`remove` 无锁、`addAll`/`retainAll`/`removeIf` 写锁保护）；`sync.*` 族以 `Syncs` 门面（12 工厂）+ `Synchronizer`（泛型读写锁门面）+ `SyncAdapter`（代理式泛型加锁）+ `SyncProxyAdapter`（JDK 动态代理）+ 12 个 `Sync*Adapter`（`ReentrantLock` 装饰器，覆盖 `Collection/List/Set/Map/Queue/Stack/LinkedList/LinkedHashMap/Iterator/ListIterator/Enumeration/Spliterator`）提供**完备的同步集合包装**；`readonly.*` 族以 `Readonlys` 门面（4 工厂）+ 6 个 `Readonly*Adapter` + `ReadonlyException`（篡改抛异常）提供**只读集合装饰器**。本模块为 `i2f-container-builder`（`Builders`/`MapBuilder`/`ListBuilder`/`ObjectBuilder`）的依赖上游，实际消费方 `i2f-bql`/`i2f-extension-xproc4j` 经 builder 间接使用；`lombok` 未声明、`i2f-iterator` pom 声明但**未直接 import**。

## 模块路径

- `i2f-jdk/i2f-container`

## 模块依赖

| 坐标 | scope | optional | 说明 |
|---|---|---|---|
| `i2f.turbo:i2f-reference` | compile | false | 被 `RingQueue` 通过 `Reference.of(val)` 包装入队元素 |
| `i2f.turbo:i2f-iterator` | compile | false | pom 声明但源码**未直接 import**（`CollectionUtil` 仅用 `java.util.Iterator`），属冗余声明 |

## 模块设计

六大子领域的分层设计：

```
i2f.container
├── CollectionUtil              # 集合收集工具（6族 × 9原始类型 × index/length/filter/mapper 重载）
├── RingQueue                   # 有界阻塞环形队列（Reference 包装 + RWLock + Condition）
├── map/
│   ├── LruMap                  # LinkedHashMap 覆写 removeEldestEntry 容量淘汰
│   └── SyncLruMap              # LruMap + SyncLinkedHashMapAdapter 线程安全壳
├── set/
│   └── ConcurrentSet           # ConcurrentHashMap 后备的并发 Set
├── sync/
│   ├── Syncs                   # 静态工厂（12 个工厂方法，eat 原生集合→同步包装）
│   ├── Synchronizer<T>         # 泛型读写锁门面（readFunction/writeConsumer 等 8 方法）
│   ├── SyncAdapter<T>          # 泛型代理 + Lock 基类（map/accept 模板方法）
│   ├── SyncProxyAdapter        # JDK 动态代理（InvocationHandler，proxy 静态工厂）
│   └── adapter/
│       ├── SyncCollectionAdapter
│       ├── SyncListAdapter
│       ├── SyncSetAdapter
│       ├── SyncMapAdapter
│       ├── SyncQueueAdapter
│       ├── SyncStackAdapter          # 589 行（复杂数据结构）
│       ├── SyncLinkedListAdapter     # 589 行（复杂数据结构）
│       ├── SyncLinkedHashMapAdapter  # 302 行（支持 accessOrder）
│       ├── SyncIteratorAdapter
│       ├── SyncListIteratorAdapter
│       ├── SyncEnumerationAdapter
│       └── SyncSpliteratorAdapter
└── readonly/
    ├── Readonlys               # 静态工厂（collection/list/set/map 4 工厂）
    ├── adapter/
    │   ├── ReadonlyCollectionAdapter
    │   ├── ReadonlyListAdapter
    │   ├── ReadonlySetAdapter
    │   ├── ReadonlyMapAdapter
    │   ├── ReadonlyIteratorAdapter
    │   └── ReadonlyListIteratorAdapter
    └── exception/
        └── ReadonlyException   # 篡改操作抛出的运行时异常
```

### 设计模式应用

- **装饰器模式**：全部 `Sync*Adapter` / `Readonly*Adapter` 均包装原生集合，委托其方法并在外围加锁/检查
- **代理模式**：`SyncProxyAdapter` 用 JDK 动态代理做通用同步包装（比手写每个接口更通⽤，但限接口类型）
- **模板方法**：`SyncAdapter<T>` 的 `map`/`accept` 方法供子类在加锁上下文中执行任意操作
- **静态工厂**：`Syncs`/`Readonlys` 统一创建入口
- **读写锁分离**：`Synchronizer` 显式区分读/写操作；`RingQueue` 用 `ReentrantReadWriteLock` + `Condition`
- **LRU 淘汰**：`LruMap extends LinkedHashMap` 覆写 `removeEldestEntry`

## 模块目的

1. **补全 JDK 缺失的集合转换**：`CollectionUtil` 提供 `Iterator→Collection` 的过滤/映射/切片一站式转换，覆盖 8 种原始类型数组
2. **提供有界阻塞队列**：`RingQueue` 补 `ArrayBlockingQueue` 外的轻量环形实现
3. **秒级 LRU 缓存**：`LruMap` 44 行即得容量淘汰 Map
4. **完备同步包装**：`Syncs` 覆盖 12 种集合/迭代器类型，比 `Collections.synchronizedXxx` 更全面且含 `Stack`/`LinkedList`/`LinkedHashMap`
5. **只读防御机制**：`Readonlys` 提供同族只读装饰器（JDK 仅 `Collections.unmodifiableXxx`）
6. **并发 Set**：`ConcurrentSet` 以 `ConcurrentHashMap` 后备，免去 `ConcurrentHashMap.newKeySet()` 的 Java 8 版本依赖

## 模块功能

### CollectionUtil（870 行，~300 方法）

- **`of(ret, iterator, ...)`**：把 `Iterator` 收集到已有容器，支持 `filter`/`mapper`/`offset`/`length` 4 参数变体
- **`as(supplier, iterator, ...)`**：同 of 但由 `Supplier` 创建目标容器
- **`ofArgs(ret, filter, mapper, arr)` / `argsAs(...)`**：从变长参数 `T...` 收集
- **`ofArray(ret, filter, mapper, arr)` / `arrayAs(...)`**：从对象数组 `T[]` 和 8 种基本类型数组收集
- **全部 4 参数组合** × **9 种数组类型**（`T[]` + `int[]/long[]/short[]/char[]/byte[]/boolean[]/float[]/double[]`）= 大量重载

### RingQueue（222 行）

- 有界环形数组（容量 = `arr.length - 1` 哨兵槽区分 full/empty）
- `enqueue`/`dequeue`：满/空时 `Condition.await()` 阻塞
- `dequeueIf`/`dequeueAllIf`：非阻塞变体，空时返回 `Reference.nop()`
- `head`/`tail`/`get(int)`/`set(int,val)`：索引随机访问（读锁保护）
- `isEmpty`/`isFull`/`size`/`clear`：状态查询与管理

### LruMap（44 行）

- `extends LinkedHashMap<K,V>`，覆写 `removeEldestEntry`：`size() > maxSize`
- 不设 `accessOrder` 默认按插入序淘汰（构造器提供 `accessOrder` 参数覆写）

### SyncLruMap（44 行）

- `extends SyncLinkedHashMapAdapter`，构造器接受 `LruMap` 参数或直接转发 `maxSize`

### ConcurrentSet（173 行）

- `implements Set<E>`，`ConcurrentHashMap<E,Boolean>` 后备
- `add`/`remove`/`contains`：无锁（利用 CHM 自身并发性）
- `addAll`/`retainAll`/`removeAll`/`removeIf`：写锁保护 `ReentrantReadWriteLock`

### Syncs（60 行）+ 12 SyncAdapter

- **`Synchronizer<T>`**：封装任意对象，提供 8 方法（读锁：`get`/`readFunction`×2/`readConsumer`×2；写锁：`writeFunction`×2/`writeConsumer`×2）
- **`SyncAdapter<T>`**：基类提供 `lock.lock()` + `map`/`biMap`/`accept`/`accept` 模板方法
- **`SyncProxyAdapter`**：JDK 动态代理 `InvocationHandler`，`proxy(Class, target)` 静态工厂
- **12 个 `Sync*Adapter`**：每个 `extends SyncAdapter<被包装类型> implements 目标接口`，各自实现该接口全部方法，方法体 `return map(target->target.method(args))` 或 `return biMap((target,val)->target.method(val), val)`

### Readonlys（34 行）+ 6 ReadonlyAdapter

- **6 个 `Readonly*Adapter`**：同装饰器模式，所有修改方法抛 `ReadonlyException`
- **`ReadonlyException extends RuntimeException`**：单消息含修改方法名

## 模块主要使用方法

```java
// 1. CollectionUtil：迭代器→集合
List<String> list = CollectionUtil.as(ArrayList::new, iterator, s -> s.startsWith("A"));

// 2. RingQueue：有界阻塞队列
RingQueue<String> queue = new RingQueue<>(100);
queue.enqueue("hello");
String val = queue.dequeue();

// 3. LruMap：容量淘汰
LruMap<String, Object> cache = new LruMap<>(100);
cache.put("key", value); // 超过 100 条自动淘汰最旧

// 4. ConcurrentSet：并发 Set
ConcurrentSet<String> set = new ConcurrentSet<>();
set.add("a");

// 5. Syncs：同步包装
List<String> syncList = Syncs.list(new ArrayList<>());
Map<String,Object> syncMap = Syncs.map(new HashMap<>());

// 6. Synchronizer：泛型同步门面
Synchronizer<List<String>> sync = new Synchronizer<>(list);
sync.writeConsumer(l -> l.add("item"));

// 7. Readonlys：只读包装
Collection<String> ro = Readonlys.collection(list);
ro.add("x"); // 抛出 ReadonlyException

// 8. SyncProxyAdapter：动态代理同步
List<String> proxy = SyncProxyAdapter.proxy(List.class, new ArrayList<>());
```

## 模块特性总结

- **全 JDK 标准库实现**：零三方运行期依赖
- **完备性**：覆盖集合/列表/Set/Map/Queue/Stack/LinkedList/LinkedHashMap/Iterator/ListIterator/Enumeration/Spliterator 共 12 种同步 + 6 种只读
- **并发 Set**：`ConcurrentSet` 基于 CHM，`addAll`/`retainAll`/`removeIf` 写锁保护
- **LRU 简洁**：`LruMap` 44 行即得，`SyncLruMap` 线程安全变体
- **通用同步门面**：`Synchronizer` 不限集合，任意对象加读写锁
- **动态代理同步**：`SyncProxyAdapter` 免手写适配器，限接口类型
- **有界阻塞环形队列**：`RingQueue` + `Condition` 支持生产者/消费者模式

## 已知实现瑕疵

1. **`i2f-iterator` 冗余声明**：pom 声明但 `CollectionUtil` 仅用 `java.util.Iterator`，30 个源文件无 `import i2f.iterator`
2. **`RingQueue` 容错有限**：`enqueue`/`dequeue` 被中断时抛 `IllegalStateException` 而非传播 `InterruptedException`，丢失中断状态
3. **`RingQueue` 无超时变体**：缺少 `offer(timeout, unit)`/`poll(timeout, unit)` JDK `BlockingQueue` 标准接口
4. **同步适配器全部 `ReentrantLock`**：所有 `Sync*Adapter` 均使用单锁（非读写锁），读多写少场景效率不如 `Collections.synchronizedXxx` + 读锁优化
5. **`ConcurrentSet.retainAll`/`removeIf` 全表拷贝**：`new LinkedHashSet<>(map.keySet())` 全量复制，大数据量下 OOM 风险
6. **`Readonly*Adapter` 无序列化支持**：`ReadonlyListAdapter` 未实现 `Serializable`
7. **`SyncProxyAdapter` 仅限接口代理**：因 JDK 动态代理限制，不能代理具体类

## 下游与关联

- **直接消费者**：本模块类无外部 `import` 消费（全仓 grep `import i2f.container.` 除本模块自身外，仅 `i2f-container-builder` 的 `Builders`/`MapBuilder`/`ListBuilder`/`ObjectBuilder` 共享 `i2f.container.builder` 包名体系但属**独立模块**）
- **间接链路**：`i2f-container-builder` → `i2f-bql`/`i2f-extension-xproc4j`；`i2f-jdk-all` 聚合纳入
- **兄弟模块**：`i2f-container-builder`（独立模块，提供 `Builders` 链式集合/Map 构建器）、`i2f-lru-map`（提供全仓通用的 `LruMap` 实现，与本模块 `LruMap` 同名但路径不同 `i2f.lru.LruMap` vs `i2f.container.map.LruMap`）
- **JDK 对标**：`Syncs` ↔ `Collections.synchronizedXxx`（覆盖更多类型）、`Readonlys` ↔ `Collections.unmodifiableXxx`、`RingQueue` ↔ `ArrayBlockingQueue`（轻量但缺超时 API）、`ConcurrentSet` ↔ `ConcurrentHashMap.newKeySet()`（兼容 Java 7）