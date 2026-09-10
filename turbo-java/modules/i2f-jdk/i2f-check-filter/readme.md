# i2f-check-filter

> **存在性判定 / 大数据去重过滤器族**——以 `ICheckFilter<T>`（`mark`/`exists` 双动词）统一「元素是否已被标记」的**内存级**判重契约，直接实现 `BloomFilter<T>`（概率型、位数组 + 多哈希函数、零误判「不存在」、有误判「存在」）；再以 `IRepeatFilter<T>` 统一「多数据源流式去重」的**大数据级**聚合契约——`HashBloomRepeatFilter<T>` 基于布隆过滤器做**近似去重**（先训练后判或边读边判），`HashGroupRepeatFilter<T>` 基于哈希切分组辅以 `IHashGroupProvider`（默认 `StreamHashGroupProvider` 落临时文件）做**精确去重**（支持 `IRepeatDecider` 灵活控制保留条件，如只取重复/只取不重复/按出现次数过滤）。全模块 8 类（3 接口 + 4 实现 + 1 demo 无 Test 类），依赖 `i2f-hash`（`IHashProvider` 哈希提供者）+ `i2f-data-processor`（`IDataReader`/`IDataWriter` 流式读写）+ `lombok`（**声明未用**）。

## 模块路径

- `i2f-jdk/i2f-check-filter`

## 模块依赖

| 坐标 | scope | optional | 说明 |
|------|-------|----------|------|
| `i2f.turbo:i2f-hash` | compile | false | `IHashProvider<T>` 哈希函数接口，`BloomFilter` 用于多哈希索引定位、`HashGroupRepeatFilter` 用于数据分组切片 |
| `i2f.turbo:i2f-data-processor` | compile | false | `IDataReader<T>`/`IDataWriter<T>` 流式读写接口，`HashGroupRepeatFilter`/`HashBloomRepeatFilter` 用于多数据源读取与结果写出；`StreamHashGroupProvider` 依赖其 `StreamReaderDataReader`/`StreamWriterDataWriter` 文件级实现 |
| `org.projectlombok:lombok` | provided | false | 声明但 **8 个源文件全无** `@Data`/`@Slf4j` 等 lombok 注解，属冗余声明 |

## 模块设计

### 架构设计

`i2f-check-filter` 围绕「元素是否存在」这一核心问题，按**内存级**与**大数据级**两个维度组织：

```
i2f.check.filter
├── ICheckFilter<T>            ← 内存级判重契约（mark/exists）
│   └── impl
│       └── BloomFilter<T>     ← 布隆过滤器（位数组 + 多哈希）
│
├── impl.bigdata
│   ├── IRepeatFilter<T>       ← 大数据级多源去重契约（filter）
│   │
│   ├── bloom
│   │   └── HashBloomRepeatFilter<T>  ← 布隆近似去重
│   │
│   └── hash
│       ├── HashGroupRepeatFilter<T>  ← 哈希分组精确去重
│       ├── IHashGroupProvider<T>     ← 分组数据持久化提供者
│       ├── IRepeatDecider<T>         ← 重复判定决策器
│       └── impl
│           └── StreamHashGroupProvider  ← 文件级分组提供者
```

### 设计模式

- **策略模式**：`IHashProvider<T>` 可注入不同哈希算法（默认 `ObjectHashcodeHashProvider`），`BloomFilter` / `HashGroupRepeatFilter` 共用同一哈希接口。
- **模板方法**：`HashGroupRepeatFilter.filter()` 定义了「哈希分组 → 分片比对 → 决策输出」的完整流水线骨架，`IHashGroupProvider` / `IRepeatDecider` 为可替换策略点。
- **桥梁模式**：`IRepeatFilter` 接口连接内存层判重（`BloomFilter`）与持久化层分组（`HashGroupProvider`），两条去重路径以相同接口输出。

### 两大去重路径对比

| 维度 | `HashBloomRepeatFilter` | `HashGroupRepeatFilter` |
|------|------------------------|------------------------|
| 精确性 | 概率型（布隆：不存在的`==`不存在，存在的`==`可能存在） | 精确型（以实际值相等为准） |
| 空间 | `O(bitLen)` 位数组，固定内存 | `O(数据量)` 磁盘临时文件，IO 密集 |
| 速度 | `O(k)` 哈希计算 + 位操作，极快 | `O(数据量 × 分组)` 多轮文件读写，较慢 |
| 场景 | 能容忍少量误判的超大规模预过滤 | 要求精确结果、数据量可控的二次精筛 |
| 生命周期 | 全内存，进程结束即失 | 依托 `IHashGroupProvider` 临盘文件，可跨阶段 |

## 模块目的

1. 为**内存单机场景**提供一个自包含、零三方依赖的布隆过滤器实现（`BloomFilter`），解决「海量元素是否已见过」的高效概率判定。
2. 为**大数据流式场景**提供一套可插拔的去重流水线抽象，把「多数据源读取 → 分组切片 → 重复判定 → 结果写出」标准化为 `IRepeatFilter` 单一接口，并给出布隆近似与哈希精确两套开箱实现。
3. 通过 `IHashGroupProvider` / `IRepeatDecider` 策略接口，开放数据持久化方式（内存 Map/文件/数据库）与保留条件（只取重复/只取不重复/按次数过滤）的扩展点。

## 模块功能

### 1. 内存级存在性判定（`ICheckFilter` / `BloomFilter`）

- **标记**：`mark(T obj)` 把元素标记为「已存在」
- **查询**：`exists(T obj)` 判定元素是否已被标记
- **位数组自动对齐**：`prepare()` 确保 `bitLen` 为 8 的倍数（字节对齐），`bits = new byte[bitLen/8]`
- **多哈希注入**：构造接收 `IHashProvider<T>... providers`，缺省时使用 `ObjectHashcodeHashProvider`（即 Java `hashCode()`）
- **最优参数计算**：`calcBestBitLen(wrongRate, allowCount)` / `calcBestHashProviderCount(wrongRate, allowCount)` 按预期容量与可接受误判率反推位数组长度与哈希函数个数

### 2. 布隆近似去重（`HashBloomRepeatFilter`）

- **边读边判**：`filter()` 对每个元素「若已标记则写出（重复），否则标记（首见）」
- **预训练后判**：`trainBloomFilter()` + `filterAfterTrain(repeat)` 分开训练与判定阶段，`repeat=true` 取重复、`repeat=false` 取不重复
- **多源处理**：接收 `List<IDataReader<T>>` 多个读源，按序全部处理

### 3. 哈希分组精确去重（`HashGroupRepeatFilter`）

- **哈希分组切片**：对每个元素 `hasher.hash(data) % groupCount` 切片到不同分组，确保相同（或哈希碰撞）元素落入同一分组
- **分组间精确比对**：对各分组内数据进行 `Map<T, Long>` 计数，相同哈希分组内作全量精确匹配
- **决策器控制**：`IRepeatDecider.save(T data, long cnt)` 可自定义保留策略；缺省时 `cnt > 1` 视为重复（保留重复项）
- **可配置分组数**：`groupCount` 控制切分粒度，越大则每组数据越少（IO 效率与单组内存的 trade-off）
- **hash 分组持久化**：`IHashGroupProvider` 抽象分组数据的临时读写；默认实现 `StreamHashGroupProvider` 以文件形式保存到 `basePath` 目录

### 4. 分组数据持久化（`IHashGroupProvider` / `StreamHashGroupProvider`）

- `StreamHashGroupProvider(File basePath)` 在指定目录创建 `{hash}.data` 临时文件
- `deleteOnDestroy` 控制读取后是否删除临时文件
- 内部委托 `StreamWriterDataWriter` / `StreamReaderDataReader`（来自 `i2f-data-processor`）做行级文本读写

## 模块主要使用方法

### 内存级布隆过滤

```java
// 按 1% 误判率、10000 条容量计算最优参数
long bitLen = BloomFilter.calcBestBitLen(0.01, 10000);
int hashCnt = BloomFilter.calcBestHashProviderCount(0.01, 10000);

// 构造（使用 ObjectHashcodeHashProvider 作为默认哈希）
BloomFilter<String> filter = new BloomFilter<>(bitLen);

// 标记与判定
filter.mark("user001");
filter.mark("user002");
boolean exists = filter.exists("user001"); // true
boolean exists2 = filter.exists("unknown"); // false（确定不存在）

// 清除
filter.cleanBits();
```

### 布隆近似去重（多数据源）

```java
BloomFilter<String> bloomFilter = new BloomFilter<>(4096);
HashBloomRepeatFilter<String> filter = new HashBloomRepeatFilter<>();
filter.setBloomFilter(bloomFilter);

// 边读边判：首次出现的元素被标记，再次出现的写入 writer
// 此处 writer 得到的是「重复数据」
List<IDataReader<String>> readers = Arrays.asList(
    new StreamReaderDataReader(new File("part1.txt")),
    new StreamReaderDataReader(new File("part2.txt"))
);
IDataWriter<String> writer = new StreamWriterDataWriter(new File("repeats.txt"));
filter.filter(writer, readers);

// 或：先训练布隆，再取不重复
for (IDataReader<String> reader : readers) {
    filter.trainBloomFilter(Collections.singletonList(reader));
}
filter.filterAfterTrain(false, writer, readers); // 取不重复
```

### 哈希分组精确去重

```java
HashGroupRepeatFilter<String> filter = new HashGroupRepeatFilter<>();
filter.setGroupCount(32);
filter.setHasher(new ObjectHashcodeHashProvider<>());
filter.setProvider(new StreamHashGroupProvider(new File("./temp/groups")));

// 不使用决策器时，默认保留出现次数 > 1 的项（重复项）
// 也可指定决策器：只取出现次数 == 1 的（即不重复）
filter.setDecider((data, cnt) -> cnt == 1);

IDataWriter<String> writer = new StreamWriterDataWriter(new File("result.txt"));
List<IDataReader<String>> readers = Arrays.asList(
    new StreamReaderDataReader(new File("part1.txt")),
    new StreamReaderDataReader(new File("part2.txt"))
);
filter.filter(writer, readers);
```

## 模块特性总结

- **双粒度架构**：`ICheckFilter`（内存级单元素判重）与 `IRepeatFilter`（大数据级多源流式去重）两条正交路线，适用场景从「`O(1)` 快速判定」到「海量数据精确去重」完整覆盖
- **零三方运行期**：pom 声明的 `lombok` 实际未使用；运行期仅依赖自家 `i2f-hash` + `i2f-data-processor`，无第三方运行时 JAR
- **布隆过滤器完整实现**：位数组操作、多哈希策略注入、位长字节对齐、最佳参数静态计算方法，全部自身包含
- **可插拔哈希策略**：`BloomFilter` 与 `HashGroupRepeatFilter` 共用 `IHashProvider<T>` 接口，允许自定义哈希函数（如 MurmurHash、CityHash 等）
- **策略化决策器**：`IRepeatDecider` 接口把「保留什么」与「如何分组/比对」解耦，用户可复用框架的分组+比对逻辑，只自定义最终过滤条件
- **文件级分组开箱可用**：`StreamHashGroupProvider` 以零额外配置提供基于本地临时文件的哈希分组持久化，默认 `deleteOnDestroy=true` 自动清理

## 已知实现瑕疵

1. **默认哈希退化风险**：`BloomFilter` 缺省使用 `ObjectHashcodeHashProvider`（即 `obj.hashCode()`），在 `hashCode()` 分布不均或小范围内（如连续整数 ID）碰撞概率上升，降低布隆有效容量。生产多源场景应注入 `IHashProvider` 实现（如叠加 `i2f-hash` 或外挂 MurmurHash）。
2. **`HashBloomRepeatFilter.filter()` 语义逻辑反转**：当前实现中，若 `bloomFilter.exists(data)==true` 则写入（当作重复输出），否则标记。按常规语义「去重 = 保留首次出现、丢弃后续重复」，`exists==true` 实际是「已存在=重复」，但变量名 `firstWrite` 与注释暗示本意可能是**保留首次出现**——两侧语义矛盾，使用前需确认输出意图。
3. **`HashGroupRepeatFilter` 哈希碰撞导致跨组漏判**：分组依赖 `hasher.hash(data) % groupCount`，若不同实际值哈希碰撞落入同一分组，在该分组内会被计为同一个 key（`Map<T, Long>` 以 `equals` 为准），**不影响正确性**（因 `Map` 用实际对象 key）；但若 `hasher.hash` 碰撞率高，分组内数据量不均衡，导致部分分组过大失去切片意义。
4. **`StreamHashGroupProvider` 线程不安全且无目录清理保障**：同一 `basePath` 被多线程写入可能乱序；`deleteOnDestroy=true` 仅在读路径触发，若写入后未读就直接 `destroy()`，临时文件残留。
5. **`lombok` 冗余声明**：pom 声明了 `lombok` provided 依赖，但全模块 8 个源文件无任何 `@Data`/`@Slf4j`/`@Getter` 等注解，属声明未用（与 `i2f-cache-std`/`i2f-tuple-std` 同类问题）。

## 下游与关联

- 本模块**无外部生产者 import 消费**（经 `import i2f.check.filter.` 全仓 grep 确认仅模块内部自引用）
- `i2f-jdk-all` 聚合 POM 将其纳入批量编译，未排除
- 兄弟模块 `i2f-check`（断言工具箱/谓词库）与 `i2f-check-filter` 包名 `i2f.check` 相同但**各自独立**：`i2f-check` 无 `filter` 子包、不 import 本模块；两模块共同构成 `i2f.check.*` 命名空间的校验/过滤能力