# i2f-database-metadata-bean

> Java Bean ↔ 数据库元数据映射层 —— 提供从 `@Table`/`@Column`/`@Primary` 等注解标注的 POJO **反射解析**为 `TableMeta` 数据模型，以及从 `TableMeta` **反向生成**带注解的 Java Bean 源码的双向能力，是 `i2f-bql`（Bean 列寻址）、`i2f-extension-reverse-engineer-generator`（代码生成器）的 Bean 元数据枢纽。

---

## 模块定位

- **功能**：
  - **正向（Bean → TableMeta）**：`BeanDatabaseMetadataResolver` 以 `getTableMeta(Class<?>)` 单入口，读取类/字段上的 `i2f-annotations-db` 注解体系（`@Table`/`@Column`/`@Primary`/`@Unique`/`@Index`/`@DataType`/`@JdbcType`/`@Nullable`/`@NotNull`/`@AutoIncrement`/`@Default`/`@DbIgnore`/`@DbIgnoreUnAnnotated`/`@Catalog`/`@Schema`/`@Database`/`@Comment`/`@TableType`），反射构建完整的 `TableMeta` → `ColumnMeta` → `IndexMeta` → `IndexColumnMeta` 四级模型，并通过 `StdType.detectType()` 自动推导标准化列类型
  - **反向（TableMeta → Java Bean）**：`JavaBeanDatabaseReverseEngineer` 实现 `DatabaseReverseEngineer` 接口，将 `TableMeta` 渲染为带完整 i2f 注解声明的 `@Data`/`@NoArgsConstructor` Java Bean 源码
- **所属层级**：`i2f-jdk` 持久化基础层，位于 `i2f-database-metadata-data` 和 `i2f-database-metadata-std` 的上游消费层
- **设计原则**：
  - **约定优先配置**：表名默认 `toUnderScore(ClassName)`、列名默认 `toUnderScore(fieldName)`，开发者仅需在命名偏离约定时加注解
  - **全链路 LRU 缓存**：表名、列映射、列名、主键、主键实体五级均以 `LruMap(8192)` 缓存，同一 Class 多次解析零反射开销
  - **单项可定制**：每个 `getXxx0` 方法接受 `Function<Field, String>` 自定义命名映射器，`getTableMeta` 同时接受表名和列名两个映射器
  - **注解驱动**：不依赖任何配置文件或约定扫描，纯反射+注解实现完整元数据推理

---

## 架构与核心流程

```
┌──────────────────────────────────────────────────────────────────┐
│                      BeanDatabaseMetadataResolver                 │
│                                                                   │
│  getTableMeta(Class<?>) ─── 类级注解 ──→ @Catalog/@Schema/       │
│                               @Database/@Table/@Comment/@TableType│
│                                    │                             │
│                                    ▼                             │
│                         getTableColumns(clazz)                   │
│                              @DbIgnore 过滤                       │
│                         @DbIgnoreUnAnnotated 控制                 │
│                                    │                             │
│                     ┌──────────────┴──────────────┐              │
│                     ▼                              ▼              │
│               @Column注解字段              无注解字段(默认模式)    │
│                     │                              │              │
│                     └──────→ 字段级注解遍历 ←──────┘              │
│                                │                                 │
│               @Column/@Comment/@DataType/@JdbcType                │
│               @Nullable/@NotNull/@AutoIncrement/@Default          │
│               @Primary → IndexMeta (主键)                         │
│               @Unique  → IndexMeta (唯一索引)                     │
│               @Index   → IndexMeta (普通索引)                     │
│                                │                                 │
│                     StdType.detectType(type, javaType)            │
│                                │                                 │
│                     columns.sort + indexes 去重                   │
│                                │                                 │
│                                ▼                                 │
│                          TableMeta                                │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                   JavaBeanDatabaseReverseEngineer                  │
│                                                                   │
│  generate(TableMeta)                                              │
│       │                                                           │
│       ├── fillColumnIndexMeta()  ← 填充列的 indexKey/uniqueKey    │
│       ├── import lombok.Data/NoArgsConstructor                    │
│       ├── @Data @NoArgsConstructor @Catalog @Schema @Database     │
│       ├── @Comment @TableType @Table("表名")                      │
│       ├── public class Xxx {                                     │
│       │      for each ColumnMeta:                                 │
│       │        if isPrimaryKey → @Primary                         │
│       │        if isUniqueKey  → @Unique                          │
│       │        if isIndexKey   → @Index                           │
│       │        if hasDefault   → @Default                         │
│       │        if autoIncr     → @AutoIncrement                   │
│       │        if !nullable    → @NotNull                         │
│       │        @Comment @DataType @JdbcType @Column               │
│       │        protected JavaType fieldName;                      │
│       └── }                                                       │
└──────────────────────────────────────────────────────────────────┘
```

---

## 源文件清单

| 文件 | 行数 | 职责 |
|------|------|------|
| `BeanDatabaseMetadataResolver.java` | 426 | Bean 元数据解析器——正向映射核心 |
| `JavaBeanDatabaseReverseEngineer.java` | 86 | Java Bean 源码反向生成器 |

---

## 依赖关系

### POM 声明依赖（8 个）

| 依赖 | 真实使用 | 用途 |
|------|----------|------|
| `i2f-text` | **是** | `StringUtils.toUnderScore/toPascal/toCamel`, `substringBeforeIndexOf`, `isEmpty` |
| `i2f-database-type` | **间接** | `StdType.detectType` 内部消费（经 `i2f-database-metadata-data` 传递） |
| `i2f-reflect` | **是** | `ReflectResolver.getAnnotation/getFields/findAllAnnotation/getFieldsWithAnnotation/cacheDelegate` |
| `i2f-annotations-db` | **是** | 17 个数据库映射注解的全量引用 |
| `i2f-database-metadata-data` | **是** | `TableMeta/ColumnMeta/IndexMeta/IndexColumnMeta/StdType` |
| `i2f-lru-map` | **是** | 五级 `LruMap(8192)` 缓存 |
| `i2f-database-metadata-std` | **是** | `DatabaseReverseEngineer` 接口 |
| `lombok` | **否** | 0 个 `import lombok.*`（声明未用） |

### 下游 POM 依赖

| 模块 | 引入方式 |
|------|----------|
| `i2f-bql` | POM 依赖 + `import BeanDatabaseMetadataResolver`（Bean 列寻址） |
| `i2f-extension-reverse-engineer-generator` | POM 依赖 + `import BeanDatabaseMetadataResolver`（代码生成器） |
| `i2f-jdk-all` | POM 聚合 |
| `i2f-translate-en2zh` | 测试文件引用 |

---

## 关键设计要点

### 1. `getTableMeta` 的完整注解模型

类级注解处理优先级：
```java
// 读取顺序：@Catalog → @Schema → @Database → @Table → @Comment → @TableType
// @Table.value() 为空时，fallback 到 defaultTableNameMapper (toUnderScore)
Catalog → meta.setCatalog()
Schema  → meta.setSchema()
Database→ meta.setDatabase()
Table   → meta.setName()    // fallback: toUnderScore(simpleName)
Comment → meta.setComment() // 多行 "; " 拼接
TableType→ meta.setType()
```

字段级注解处理（遍历每个 `Field` 的所有注解）：
```java
for (Annotation ann : fieldAnns) {
    if (ann instanceof Column)     → col.setName(dban.value())    // fallback: toUnderScore(name)
    if (ann instanceof Comment)    → col.setComment()
    if (ann instanceof DataType)   → col.setType/Precision/Scale  // 自动解析 "VARCHAR(255)" 截断
    if (ann instanceof JdbcType)   → col.setRawJdbcType/JdbcType
    if (ann instanceof Nullable)   → col.setNullable(true)
    if (ann instanceof NotNull)    → col.setNullable(false)
    if (ann instanceof AutoIncrement)→ col.setAutoIncrement(true)
    if (ann instanceof Default)    → col.setDefaultValue()
    if (ann instanceof Primary)    → 构建主键 IndexMeta（默认名 "pk_{表名}"）
    if (ann instanceof Unique)     → 构建唯一索引 IndexMeta（默认名 "unq_{列名}"）
    if (ann instanceof Index)      → 构建普通索引 IndexMeta（默认名 "idx_{列名}"）
}
```

类型自动推导：
```java
StdType stdType = StdType.detectType(col.getType(), col.getJavaType());
if (stdType == null) stdType = StdType.VARCHAR;  // 兜底
// 填充 8 个类型字段: rawDialectType/rawJdbcType/jdbcType/rawStdType/stdType
//                rawLooseJavaType/looseJavaType/rawLooseJdbcType/looseJdbcType
```

### 2. 索引去重策略

由于一个字段可以同时被 `@Primary`/`@Unique`/`@Index` 标注，同一索引名可能在多个字段上重复出现：
```java
Set<String> indexNames = new LinkedHashSet<>();
// 遍历完成后，用 indexNames 去重：
// 主键名 → uniqueIndexes（去重）→ indexes（去重）
```

### 3. 全链路 LRU 缓存

```java
private static LruMap<String, String> CACHE_GET_TABLE_NAME = new LruMap<>(8192);
private static LruMap<String, Map<Field, String>> CACHE_GET_TABLE_COLUMNS = new LruMap<>(8192);
private static LruMap<String, String> CACHE_GET_COLUMN_NAME = new LruMap<>(8192);
private static LruMap<String, Map<Field, String>> CACHE_GET_TABLE_PRIMARIES = new LruMap<>(8192);
private static LruMap<String, Map.Entry<Field, String>> CACHE_GET_TABLE_PRIMARY = new LruMap<>(8192);
```

通过 `ReflectResolver.cacheDelegate` 访问，且仅在 `ReflectResolver.ENABLE_CACHE.get()` 为 true 时启用缓存（可通过系统属性控制），缓存的 value 以 `new LinkedHashMap<>(e)` 防御性拷贝保护。

### 4. `JavaBeanDatabaseReverseEngineer` 的输出风格

生成的 Java Bean 源码包含：
- 类级：`@Data` `@NoArgsConstructor` + `@Catalog/@Schema/@Database/@Comment/@TableType/@Table`
- 字段级：按 `ColumnMeta` 的 `isPrimaryKey/isUniqueKey/isIndexKey/isAutoIncrement/isNullable/hasDefaultValue` 开关，组合输出 `@Primary/@Unique/@Index/@AutoIncrement/@NotNull/@Default/@Comment/@DataType/@JdbcType/@Column`
- 索引列通过 `fillColumnIndexMeta()` 填充的 `indexKeyList/uniqueKeyList/primaryKeyName/primaryKeyOrder` 列表顺序输出
- 类型名采用 `col.getJavaType()`（`StdType` 推导的松散 Java 类型简名）

---

## 已知缺陷

1. **`@Default` 注解生成笔误**：`JavaBeanDatabaseReverseEngineer.java` L67 将 `item.getComment()` 误填入 `@Default` 的 value，应为 `item.getDefaultValue()`

2. **`@TableType` 的 type 字段丢失**：类级注解解析中 `@TableType.value()` 已读入 `meta.setType()`，但 `JavaBeanDatabaseReverseEngineer.INSTANCE` 生成时没有将 tableType 的 value 输出到类体的 tableType 属性定义（仅输出为注解参数）

3. **`@DataType 精度/刻度整数溢出风险**：`DataType.precision()`/`scale()` 的 int 默认值 `-1` 被 `"precision=0, scale=0"` 无条件写入 DDL，当两者为 `-1` 时产生 `VARCHAR(-1)` 等非法精度

4. **`@Index` 误设 `setUnique(true)`**：`BeanDatabaseMetadataResolver.java` L344 将普通索引的 `IndexMeta` 也设为 `setUnique(true)`，与 `@Unique` 处理的 L318 写法一致，导致普通索引与唯一索引在 `IndexMeta` 层面无法区分

5. **`@Primary` 与 `@Unique`/`@Index` 字段上索引去重相同**：`indexNames` 去重集合共用于主键/唯一/普通三类索引，当某字段同时标注 `@Primary("pk_tab")` 和 `@Index("pk_tab")` 时，后者被去重逻辑跳过

6. **`getTableMeta` 的索引重排序问题**：`uniqueIndexes.clear()`（L364）和 `indexes.clear()`（L373）位于 `for (Field field : fields.keySet())` 循环内部，但对应添加逻辑（L197-354）却在同一个循环中更早的位置，这意味着每次迭代都会清空并重建索引列表——最终结果仅保留最后一个字段产生的索引，前面的索引全部丢失

7. **`UnsupportedOperationException` 风险**：`ReflectResolver.cacheDelegate` 返回的 `Map<Field, String>` 是 `LruMap` 视图，外层 `new LinkedHashMap<>(e)` 防御拷贝的保护链仅在 `getTableColumns` 和 `getTablePrimaries` 方法中做了拷贝，但 `getTableMeta` 在 `fields.keySet()` 上迭代时修改了 `uniqueIndexes`/`indexes` 列表（clear/add），但这些列表不是从缓存获取的，不构成问题

8. **lombok 声明未使用**：`pom.xml` 声明的 `lombok` 在 2 个源文件中均无 `import lombok.*`