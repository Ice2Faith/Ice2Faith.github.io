# i2f-database-metadata-data

> 数据库元数据**数据模型与类型系统层**——沉淀 `TableMeta`/`ColumnMeta`/`IndexMeta`/`IndexColumnMeta` 四级元数据 POJO + `StdType` 标准化类型枚举（34 常量）+ `IColumnType` 方言类型映射接口，是 `i2f-database-metadata-std`/`-impl`/`-bean` 及 `i2f-extension-reverse-engineer-generator` 的公共数据模型地基。

---

## 模块定位

- **功能**：定义数据库元数据读取流程中的完整数据模型（表 → 列 → 索引 → 索引列），并提供跨方言的标准化列类型体系（数据库类型 → Java 类型 ↔ JDBC 类型双向映射）
- **所属层级**：`i2f-jdk` 持久化基础层，位于 `i2f-database-metadata-std` 的下游数据模型层
- **设计原则**：
  - **模型即协议**：所有元数据接口（`DatabaseMetadataProvider`）和方言实现（各种 `*DatabaseMetadataProvider`）都共享此模块定义的数据模型，避免了各模块各自维护一份 DTO 的散落风险
  - **类型标准化**：`StdType` 将各数据库方言的字符串类型名归一为枚举，提供精确（strict）和宽松（loose）两种类型映射视角，供代码生成器使用
  - **共享包架构**：与 `i2f-database-metadata-std` 共同贡献 `i2f.database.metadata.std` 包——本模块提供 `StdType` 枚举 + `IColumnType` 接口，`std` 模块提供 `DatabaseMetadataProvider` + `DatabaseReverseEngineer` 两个接口——编译后属于同一 JAR 的 classpath，**运行期无需显式依赖**即可互相引用

---

## 架构一览

```
i2f-database-metadata-data  (本模块, 零 i2f 内部依赖)

┌─────────────────────────────────────────────────────────────────┐
│  package i2f.database.metadata.data  (数据模型)                  │
│                                                                   │
│  TableMeta ──1:N──▶ ColumnMeta                                    │
│      │                 │                                           │
│      ├──1:1──▶ IndexMeta (primary)                                │
│      │               │                                            │
│      └──1:N──▶ IndexMeta (uniqueIndexes/indexes)                  │
│                    │                                              │
│                    └──1:N──▶ IndexColumnMeta                      │
│                                                                   │
│  TableMeta.fillColumnIndexMeta() ←── 后处理：将 PK/UK/IK          │
│      标志回填到 ColumnMeta                                        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  package i2f.database.metadata.std  (类型系统, 共享包)            │
│                                                                   │
│  IColumnType (interface) ───┬── StdType (enum, 34 常量)          │
│   ├── text() : String        │   ├── text / precision / scale    │
│   ├── precision() : boolean  │   ├── javaType / jdbcType        │
│   ├── scale() : boolean      │   ├── looseJavaType / looseJdbc   │
│   └── stdType() : StdType    │   └── detectType() 四级级联      │
│                              │                                    │
│                              ├── 方言 *Type enum (impl 各模块)   │
│                              │    MySqlType / OracleType / ...   │
│                              └── ColumnMeta 消费 detectType      │
└─────────────────────────────────────────────────────────────────┘

消费关系：

i2f-database-metadata-data  ──▶ i2f-database-metadata-std  (POM 依赖)
         │                              (Provider 返回 TableMeta)
         ├──▶ i2f-database-metadata-impl  (方言实现 populate 模型)
         ├──▶ i2f-database-metadata-bean  (Bean ↔ 元数据解析)
         └──▶ i2f-extension-reverse-engineer-generator (代码生成)
```

---

## 数据模型详解

### TableMeta（表元数据）

```java
public class TableMeta {
    protected String catalog;       // 目录
    protected String schema;        // 模式
    protected String database;      // 数据库
    protected String name;          // 表名
    protected String comment;       // 注释
    protected String type;          // 表类型（TABLE/VIEW）
    protected List<ColumnMeta> columns;       // 列列表
    protected IndexMeta primary;              // 主键
    protected List<IndexMeta> uniqueIndexes;  // 唯一索引列表
    protected List<IndexMeta> indexes;         // 普通索引列表
}
```

关键方法 `fillColumnIndexMeta()`：
- 遍历所有列，根据 `primary`/`uniqueIndexes`/`indexes` 将主键/唯一键/索引标志回填到每个 `ColumnMeta`
- 最后调用每列的 `fillRawTypes()` 将字符串类型解析为 `StdType`/`Class`/`JDBCType` 运行时对象

### ColumnMeta（列元数据）

```java
public class ColumnMeta {
    protected int index;                    // 列序号
    protected String name;                  // 列名
    protected String type;                  // 数据库类型字符串（如 "varchar(255)")
    protected String comment;               // 注释
    protected int precision;                // 精度
    protected int scale;                    // 小数位
    protected boolean isNullable;           // 是否可为空
    protected boolean isAutoIncrement;      // 是否自增
    protected boolean isGenerated;          // 是否生成列
    protected String defaultValue;          // 默认值

    // 字符串型类型描述（用于序列化/JSON）
    protected String columnType;            // 原始的列类型
    protected String javaType;              // Java 类型全限定名
    protected String jdbcType;              // JDBC 类型名
    protected String stdType;               // 标准化类型
    protected String looseJavaType;         // 宽松 Java 类型
    protected String looseJdbcType;         // 宽松 JDBC 类型

    // 运行时类型对象（经 fillRawTypes 填充）
    protected Class<?> rawJavaType;
    protected JDBCType rawJdbcType;
    protected StdType rawStdType;
    protected Class<?> rawLooseJavaType;
    protected JDBCType rawLooseJdbcType;
    protected Object rawDialectType;

    // 索引标志（需 fillColumnIndexMeta 后才有值）
    protected boolean isPrimaryKey;
    protected String primaryKeyName;
    protected int primaryKeyOrder;
    protected boolean isUniqueKey;
    protected List<Map.Entry<String, Integer>> uniqueKeyList;
    protected boolean isIndexKey;
    protected List<Map.Entry<String, Integer>> indexKeyList;
}
```

**双态类型设计**：`ColumnMeta` 同时维护「字符串型」和「运行时型」两套类型字段——
- 字符串型（`javaType`/`jdbcType`/`stdType`/`looseJavaType`/`looseJdbcType`）用于 JSON 序列化/持久化
- 运行时型（`rawJavaType`/`rawJdbcType`/`rawStdType` 等）用于程序化类型判定

这种设计兼顾了「跨进程传输时的可序列化性」与「运行期反射判断的效率」。

### IndexMeta（索引元数据）

```java
public class IndexMeta {
    protected boolean isUnique;                   // 是否唯一索引
    protected String name;                        // 索引名
    protected List<IndexColumnMeta> columns;      // 索引列列表
}
```

### IndexColumnMeta（索引列元数据）

```java
public class IndexColumnMeta {
    protected int index;          // 列在索引中的序号
    protected String name;        // 列名
    protected boolean isDesc;     // 是否降序
    protected String type;        // 索引类型（BTREE/HASH 等）
}
```

---

## 类型系统

### StdType 枚举

34 个常量覆盖主流数据库列类型，每条记录携带 7 个属性：

| 属性 | 描述 | 示例 |
|------|------|------|
| `text` | 标准化类型名 | `"varchar"`, `"int"`, `"decimal"` |
| `precision` | 是否支持精度 | `false`, `true` |
| `scale` | 是否支持小数位 | `false`, `true` |
| `javaType` | 精确 Java 类型映射 | `Integer.class`, `String.class` |
| `jdbcType` | 精确 JDBC 类型映射 | `JDBCType.INTEGER` |
| `looseJavaType` | 宽松 Java 类型 | `Integer.class`, `String.class` |
| `looseJdbcType` | 宽松 JDBC 类型 | `JDBCType.NUMERIC`, `JDBCType.VARCHAR` |

**精确 vs 宽松**：
- 精确（strict）映射关注语义准确性——`SMALLINT` → `Short.class` + `JDBCType.SMALLINT`
- 宽松（loose）映射关注代码友好性——`SMALLINT` → `Integer.class` + `JDBCType.NUMERIC`

**四组级联检测策略**（`detectType(String type, String javaType)`）：

```
第一组 (匹配 type):
  1. text 精确匹配        "int"      == "int"    → StdType.INT
  2. text 前缀匹配        "intunsigned" startsWith "int" → StdType.INT
  3. jdbcType 精确匹配    "integer"  == "INTEGER" (ignore case) → StdType.INTEGER
  4. jdbcType 前缀匹配    "integer_" startsWith "integer" → StdType.INTEGER
  5. looseJdbcType 精确匹配
  6. looseJdbcType 前缀匹配

第二组 (匹配 javaType):
  7. javaType.getSimpleName() 精确匹配
  8. javaType.getSimpleName() 后缀匹配
  9. looseJavaType.getSimpleName() 精确匹配
  10. looseJavaType.getSimpleName() 后缀匹配
```

### IColumnType 接口

```java
public interface IColumnType {
    String text();          // 类型文本
    boolean precision();    // 是否需要精度
    boolean scale();        // 是否需要小数位
    StdType stdType();      // 映射到的 StdType
}
```

所有方言类型枚举（如 `MySqlType`、`OracleType`、`DmType`、`PostgreSqlType`、`SqlServerType`、`GbaseType`、`Sqlite3Type`）都实现此接口，将各自的方言类型字符串映射回 `StdType`，实现跨方言类型归一。

---

## 依赖关系

| 依赖 | 类型 | 用途 |
|------|------|------|
| `lombok` | 编译期 | `@Data` 生成 4 个 POJO 的 getter/setter/toString/equals/hashCode（**真实使用**） |

零 i2f 内部依赖——`StdType` 仅依赖 `java.sql.JDBCType` 和 JDK 内置类型，`ColumnMeta` 引用 `StdType` 属于模块内自引用（同模块不同包）。

---

## 下游消费者

| 模块 | 消费方式 | 消费文件数 |
|------|----------|-----------|
| `i2f-database-metadata-std` | POM 依赖，获取 TableMeta/ColumnMeta 返回类型 | ~2 文件 |
| `i2f-database-metadata-impl` | POM 依赖，populate 数据模型 | ~15 文件（含所有方言类型） |
| `i2f-database-metadata-bean` | POM 依赖，Bean ↔ 元数据互转 | ~5 文件 |
| `i2f-extension-reverse-engineer-generator` | import `TableMeta`/`ColumnMeta` | ~16 文件 |
| `i2f-jdk-all` | 聚合模块 | - |

---

## 已知缺陷

1. **`StdType.detectType` 首匹配胜出规则**：`type` 的前缀匹配按枚举声明顺序返回第一个匹配，而 `EnumSet` 的 `ordinal()` 顺序在 `Enum` 类中并非业务含义上的优先级顺序。例如 `"tinytext"` 的 `startsWith("t")` 可能在 `TEXT` 之前匹配上无意义的类型。实际上声明顺序保障了较长文本在前，但并非显式契约。

2. **`ColumnMeta` 双态字段不一致风险**：字符串型字段与运行时型字段没有强一致性校验——如果某列的 `stdType` 字符串值与 `rawStdType` 通过 `detectType` 推导出的结果不一致（比如 JSON 反序列化后未重新调用 `fillRawTypes()`），代码将以 `rawStdType` 为准，而 JSON 展示的仍是旧值。

3. **`IndexMeta.columns` 为 `null` 时的 NPE**：`TableMeta.fillColumnIndexMeta()` 遍历 `primary.getColumns()`/索引列时未做 null 检查，如果 `primary` 非 null 但 `primary.columns` 为 null，会抛出 `NullPointerException`。

4. **`ColumnMeta` 索引列表泛型过于宽松**：`uniqueKeyList`/`indexKeyList` 定义为 `List<Map.Entry<String, Integer>>`，使用 `AbstractMap.SimpleEntry` 填充。下游代码需要通过 `getKey()`/`getValue()` 访问，类型安全靠约定，编译期不可检查。

5. **`StdType` 枚举覆盖不完全**：34 个常量无法涵盖所有数据库方言类型（如 `geometry`、`json`、`xml`、`uuid`、`enum` 等），`detectType` 遇到未知类型时返回 `null`，调用方需额外处理。

6. **`IColumnType` 缺少 `serialize()`/`deserialize()` 方法**：方言类型枚举（如 `MySqlType`）需要读取完整的 `JDBCType`、`javaType`、`precision` 等信息时，只能通过 `stdType()` 间接获取中间映射，缺乏直接从方言类型直达 JDBC 类型的便捷方法。