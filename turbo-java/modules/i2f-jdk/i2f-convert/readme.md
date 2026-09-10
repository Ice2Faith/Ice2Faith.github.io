# i2f-convert

> **通用类型转换工具箱**（6 源文件、约 1760 行源码、真实依赖 `i2f-typeof`）——以 `ObjectConvertor.tryConvertAsType(val, targetType)` 为核心的单片式「万能类型转换器」，把任意对象尝试转换为任意目标类型，覆盖数值/布尔/字符/日期/字符串/枚举/集合/Map/数组/URL/URI/File/Charset/Locale/InetAddress/MessageDigest/Mac/Cipher/Class 等 20+ 种类型域，以「源→目标」类型双向匹配 + `Instant`/`BigDecimal` 归一化中转 + 宽松字符串字面量解析 + 构造器/静态工厂反射尝试四级策略实现最大兼容；`Converters` 提供 12 个 `parse*` 轻量级门面（7 种基本类型 × 有/无默认值 + `parseAs` 通用骨架），异常安全、null 安全；`tree.*` 子包（`TreeConvertor` + `ITreeNode`/`IChildren`/`INextLevelDataProvider` 3 接口）提供列表→树/树→列表双向转换，支持接口方法引用、反射字段名、完整路径构造等多种树构建策略。全模块约 25 个内部/扩展模块真实消费，是 `i2f-jdk` 中覆盖面最广的底层转换基础设施。

## 模块路径

- `i2f-jdk/i2f-convert`

## 模块依赖

| 坐标 | scope | optional | 说明 |
|---|---|---|---|
| i2f.turbo:i2f-typeof | compile | false | `TypeOf.typeOf` 做类型兼容判定与 `TypeOf.instanceOf` 实例判定 |
| org.projectlombok:lombok | provided | false | 源码无注解，冗余声明 |

## 模块设计

### 两级门面体系

- `Converters`（80 行）：异常安全的轻量级解析门面，适合「已知源类型、确定目标值类型」的简单场景
- `ObjectConvertor`（1270 行）：万能类型转换重型门面，适合「未知源类型、泛化目标类型转换」的复杂场景

### ObjectConvertor 四级转换策略

对于 `tryConvertAsType(val, targetType)`，按以下优先级级联尝试：

1. **精确匹配/字符串化**：如果源类型与目标类型匹配（`TypeOf.typeOf`），直接返回原值；如果目标类型是 String/byte[]/char[]/Reader/InputStream 等字符串相关类型，经 `stringify()` 转换
2. **类型域内部互转**：源和目标同属一个类型域（数值/布尔/字符/日期），通过归一化中转（`BigDecimal`/`Instant`）做双向互转
3. **字符串字面量解析**：字面量识别数值（10进制/16进制/8进制/2进制/浮点）、布尔（true/false/1/0/y/n/t/f）、日期（40+ 格式轮询）、Enum（name/ordinal 双向）、URL/URI/File/Charset/Locale/InetAddress/Class/MessageDigest/Mac/Cipher
4. **构造器/静态工厂反射**：`tryConvertAsTypeWithConstructor` 反射目标类型的单参构造器或单参静态工厂方法尝试构造

### 类型域转换体系

| 类型域 | 归一化中转 | 覆盖目标类型 |
|---|---|---|
| 数值 | `BigDecimal` | int/short/long/byte/float/double/BigInteger/AtomicInteger/AtomicLong |
| 布尔 | 直接 | boolean/Boolean |
| 字符 | 直接 | char/Character |
| 日期时间 | `Instant` | Date/sql.Date/Time/Timestamp/LocalDateTime/LocalDate/LocalTime/Calendar/Clock/Long(时间戳) |
| 字符串 | `stringify()` | StringBuilder/StringBuffer/char[]/Reader/InputStream/byte[] |
| 集合 | 元素拷贝 | ArrayList/LinkedList/Vector/CopyOnWriteArrayList/HashSet/LinkedHashSet/CopyOnWriteArraySet/TreeSet/Stack/PriorityQueue/LinkedBlockingQueue/ConcurrentLinkedQueue |
| Map | 元素拷贝 | HashMap/LinkedHashMap/TreeMap/ConcurrentHashMap/IdentityHashMap/WeakHashMap/Hashtable/Properties |
| 数组 | 元素逐一遍历转换 | 任意目标组件类型数组 |

### 树转换设计

`TreeConvertor` 提供三种树构建策略：

- **策略一（ITreeNode 接口）**：元素自身实现 `isMyChild/isMyParent/asMyChild`，`list2Tree(list)` 一次到位
- **策略二（函数式谓词）**：提供 `secondIsFirstParentPredicate/secondIsFirstChildPredicate/secondAsFirstChildConsumer` 三个 lambda，`list2Tree(list, p1, p2, c)` 灵活适配任意 POJO
- **策略三（反射字段名）**：`list2tree(list, keyFieldName, parentKeyFieldName, childrenFieldName)` 按字段名反射构建，支持 Map/POJO 混合
- **策略四（完整路径构造）**：`constructTree(list, currNodePathExtractor, newNodeCreator, ...)` 适用于数据元素携带完整树路径的场景（如 `/中国/四川省/成都市`）
- **树→列表**：`tree2List(tree, childProvider, childCleaner)` 深度遍历展开

## 模块目的

- 提供「任意对象→任意目标类型」的最大兼容转换，消除项目中大量 `Integer.parseInt`/`String.valueOf`/日期格式化等重复的类型转换样板代码
- 统一全仓的类型转换入口，避免各模块各自实现零散的转换工具
- 提供列表⇄树的通用转换基础设施，消除树结构数据拼装的重复劳动

## 模块功能

### Converters

| 方法 | 说明 |
|---|---|
| `parseInt(T)`/`parseLong(T)`/`parseShort(T)`/`parseBoolean(T)`/`parseDouble(T)`/`parseFloat(T)` | 异常安全地解析，失败返回 `null` |
| `parseInt(T, defVal)` ~ `parseFloat(T, defVal)` | 带默认值的异常安全解析 |
| `parseAs(T, Function, defVal)` | 通用双段解析骨架（mapper→parser），所有 `parse*` 的底层实现 |
| `parseAs(T, Function, Function, defVal)` | 三参通用解析壳（先 mapper 转换，再 parser 解析） |

### ObjectConvertor 主要方法

| 方法 | 说明 |
|---|---|
| `tryConvertAsType(val, targetType)` | 万能类型转换器（四级策略） |
| `safeConvertAsNumberType(value, targetType)` | 精度安全的数值类型转换，精度丢失时返回源值 |
| `safeConvertAsNumberType(value, leftType, rightType)` | 两操作数运算前精度匹配 |
| `stringify(obj, nullAs)` | 通用字符串化（支持 byte[]/char[]/Clob/Reader/InputStream/数组） |
| `toBoolean(obj)` | 宽松布尔判定（null 假、Boolean 原值、Number 非零真、非空 String/Collection/Map/数组真） |
| `tryParseBoolean(valStr)` | 字符串字面量→Boolean（支持 true/false/1/0/y/n/t/f） |
| `tryParseDate(valStr)` | 40+ 格式轮询解析 Date |
| `formatDate(patten, date)` | 日期格式化（`synchronized` 保护) |
| `parseDate(patten, date)` | 日期解析（`synchronized` 保护） |
| `formatDate(patten, TemporalAccessor/LocalDate/LocalTime/LocalDateTime)` | Java 8 日期格式化 |
| `parseLocalDate/LocalDateTime/LocalTime(patten, date)` | Java 8 日期按模式解析 |
| `parseLocalDate/LocalDateTime/LocalTime(date)` | Java 8 日期自动匹配解析 |
| `isNumericType/isBooleanType/isCharType/isDateType(clazz)` | 类型域判定 |
| `getSimpleFormatter/getDateTimeFormatter(patten)` | 格式器缓存获取 |

### TreeConvertor 树转换

| 方法 | 说明 |
|---|---|
| `list2Tree(list)` / `list2Tree(list, provider)` | 列表→树（ITreeNode 接口策略） |
| `list2Tree(list, p1, p2, c)` / `list2Tree(list, provider, p1, p2, c)` | 列表→树（函数式谓词策略） |
| `list2tree(list, keyField, parentKeyField, childrenField)` | 列表→树（反射字段名策略，支持 Map/POJO） |
| `list2tree(list, keyExtractor, parentKeyExtractor, consumer)` | 列表→树（函数式 key 萃取策略） |
| `constructTree(list, currPathExt, newNodeCreator, valueSetter, childrenExt, fullPathExt)` | 完整路径构造树 |
| `tree2List(tree, childProvider, childCleaner)` / `tree2List(tree)` | 树→列表展开 |

## 模块主要使用方法

```java
// ---- Converters 轻量级解析 ----
int val1 = Converters.parseInt("123");       // 123
int val2 = Converters.parseInt("abc", -1);   // -1

// ---- ObjectConvertor 万能转换 ----
// 数值互转
Double d = (Double) ObjectConvertor.tryConvertAsType(123, Double.class);
// 日期字符串→LocalDateTime
LocalDateTime dt = (LocalDateTime) ObjectConvertor.tryConvertAsType(
    "2024-01-15 10:30:00", LocalDateTime.class);
// 枚举按 name 转换
MyEnum e = (MyEnum) ObjectConvertor.tryConvertAsType("VALUE_A", MyEnum.class);
// Map 类型间拷贝
Map<String,Object> src = new HashMap<>();
ConcurrentHashMap dst = (ConcurrentHashMap) ObjectConvertor.tryConvertAsType(src, ConcurrentHashMap.class);

// ---- 树转换 ----
// 策略一：字段名反射
List<Node> flat = loadFlatList();
List<Node> tree = TreeConvertor.list2tree(flat, "id", "parentId", "children");
// 策略二：完整路径构造
List<FileNode> tree2 = TreeConvertor.constructTree(files,
    FileNode::getPath, FileNode::new, FileNode::setData,
    FileNode::getChildren, FileItem::getFullPathParts);
// 树→列表
List<Node> back = TreeConvertor.tree2List(tree, Node::getChildren, Node::cleanChildren);
```

## 模块特性总结

- **万能类型转换**：`tryConvertAsType` 覆盖 20+ 类型域，四级策略级联最大化兼容
- **精度安全数值转换**：`safeConvertAsNumberType` 比较 BigDecimal 确保精度无损
- **宽松布尔解析**：`toBoolean` 与 `tryParseBoolean` 支持 String/字面量/Collection/Map/数组/Number 的零值语义
- **40+ 日期格式自适应**：`tryParseDate` 轮询 40+ 常见格式，涵盖中英文、ISO、紧凑型
- **异常安全**：所有转换方法内部捕获异常，失败返回默认值/null
- **三种树构建策略**：接口/函数式/反射字段名/完整路径，灵活适配任意 POJO
- **广泛消费**：约 25 个内部/扩展模块真实使用

## 模块瑕疵或错误

1. **`tryConvertAsType` 浮点精度不可控**：`BigDecimal(String.valueOf(val))` 对非常大/非常小的 double 值可能引入不精确表示
2. **日期格式轮询性能问题**：`tryParseDate` 对每个字符串尝试 40+ 格式不缓存失败模式，高频调用有性能隐患
3. **`formatDate(patten, Date)` 使用 `synchronized` 粗粒度锁**：全部 pattern 共享同一方法锁，高并发日期格式化可成为瓶颈
4. **`stringify` 中 StringBuilder 无初始容量**：大量循环 `builder.append(buff, 0, len)` 无初始容量导致频繁扩容
5. **`toBoolean` 对非空对象 return true 过于宽泛**：除 null/false/数字0之外的对象一律按 true 处理，包含 `""` 空字符串（String 分支仅在 `!"".equals(obj)` 为 true 时返回 true，即 `""` 会走最终 `return true` 分支，所以空字符串实际返回 true——语义与直觉不符）
6. **`tryConvertAsTypeWithConstructor` 不缓存反射结果**：每次转换都反射 `targetType.getConstructors()`/`getMethods()`，大量重复调用时性能损失
7. **lombok 冗余声明**：6 个源文件均无注解
8. **`parseAs` 内部异常全吞**：`catch(Throwable e) {}` 连日志都没有，排查问题困难

## 下游与关联

| 消费方 | 使用内容 | 场景 |
|---|---|---|
| `i2f-comparator.DefaultComparator` | `ObjectConvertor.isNumericType` | 比较时可互换数值类型 |
| `i2f-ai-std.ToolRawHelper` | `ObjectConvertor.tryConvertAsType` | AI 工具参数类型转换 |
| `i2f-database-dialect`（11 方言） | `ObjectConvertor.stringify` | 数据库对象→SQL 字面量 |
| `i2f-dict.DictResolver` | `ObjectConvertor.tryConvertAsType` | 字典值类型转换 |
| `i2f-form-url-encoded.FormUrlEncodedEncoder` | `ObjectConvertor.stringify` | 表单编码 |
| `i2f-extension-antlr4`（3 Resolver） | `ObjectConvertor` | 脚本引擎值转换 |
| `i2f-extension-canal.CanalClient` | `ObjectConvertor` | Canal 数据转换 |
| `i2f-extension-jackson`（4 Deserializer） | `ObjectConvertor.tryParseDate` | Jackson 日期反序列化适配 |
| `i2f-extension-freemarker.DefaultStringifier` | `ObjectConvertor.stringify` | 模板字符串化 |
| `i2f-extension-velocity.DefaultStringifier` | `ObjectConvertor.stringify` | 模板字符串化 |
| `i2f-extension-xproc4j.LangEvalJavaNode` | `ObjectConvertor` | 表达式求值参数转换 |