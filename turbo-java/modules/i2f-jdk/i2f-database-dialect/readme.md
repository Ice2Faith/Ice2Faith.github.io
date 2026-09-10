# i2f-database-dialect

> **SQL 字面量方言安全转换器** — 以模板方法 + 策略模式将 Java 对象（日期/数值/字符串/布尔/null）转换为各数据库方言兼容的 SQL 字面量字符串（`'value'`/`STR_TO_DATE('…')`/`TO_DATE('…')` 等），适用于非占位符式 SQL 拼接或日志中打印完整可执行语句；被 `i2f-bindsql-stringify` 作为底层 SQL 文本化引擎消费。

---

## 模块定位

- **功能**：将任意 Java `Object` 按目标方言规则转换为 SQL 安全的字面量字符串，包括 null 处理、数值直出、布尔 1/0 映射、字符串 `'` 单引号转义为 `''`、以及 9 种方言各异的日期字面量函数包装
- **所属层级**：`i2f-jdk` 持久化基础层，位于 `i2f-database-type` 的下游方言敏感层
- **设计原则**：
  - **模板方法骨架**：`AbsDatabaseObject2SqlStringifier.stringify()` 按类型链式委拖（`preStringify` → null → 数值 → 布尔 → 日期 → 字符串/Appendable → 对象），子类只需覆写 `dateToString` 和 `support`
  - **SPI + 内置双加载**：`DatabaseObject2SqlStringifiers` 先 SPI 加载自定义实现，再追加 9 个内置方言实例，SPI 实现优先级高于内置
  - **方言重定向**：`DIALECT_MAPPING` 将 DM 映射到 ORACLE，减少重复实现
  - **SQL 注入防御**：所有字符串值经 `decorateAsSqlString` 转义 `'` → `''` 并包裹 `'…'`

---

## 架构

```
DatabaseObject2SqlStringifier (接口)
  ├── support(DatabaseType) → boolean
  └── stringify(Object) → String
        │
AbsDatabaseObject2SqlStringifier (抽象模板)
  │   stringify(obj):
  │     preStringify(obj)     ← 子类可注入预处理
  │     null       → "null"
  │     数值        → String.valueOf(obj)
  │     布尔(true) → "1" / "0"
  │     日期        → decorateAsSqlString(dateToString(obj))
  │     字符串      → decorateAsSqlString(String.valueOf(obj))
  │     其他        → decorateAsSqlString(String.valueOf(obj))
  │
  ├── decorateAsSqlString(val) → "'" + val.replace("'", "''") + "'"
  │
  ├── DefaultDatabaseObject2SqlStringifier (support=always true, 兜底)
  │
  ├── MysqlDatabaseObject2SqlStringifier     STR_TO_DATE('…', '%Y-%m-%d %H:%i:%s')
  │    支持: MYSQL MARIADB OSCAR GBASE
  ├── OracleDatabaseObject2SqlStringifier    TO_DATE('…','yyyy-MM-dd HH24:mi:ss')
  │    支持: ORACLE ORACLE_12C
  ├── PostgreSqlDatabaseObject2SqlStringifier TO_TIMESTAMP('…', 'YYYY-MM-DD HH24:MI:SS')
  ├── Db2DatabaseObject2SqlStringifier        TIMESTAMP('…')
  ├── GuassDatabaseObject2SqlStringifier      '…'::timestamp
  ├── H2DatabaseObject2SqlStringifier         PARSEDATETIME('…', 'yyyy-MM-dd HH:mm:ss')
  ├── HiveDatabaseObject2SqlStringifier       cast('…' as timestamp)
  ├── PhoenixDatabaseObject2SqlStringifier    to_date('…')
  └── SqlServerDatabaseObject2SqlStringifier  CONVERT(datetime, '…', 120)
       支持: SQL_SERVER SQL_SERVER2005

DatabaseObject2SqlStringifiers (门面)
  ├── SPI 加载自定义实现 (优先级高于内置)
  ├── 9 方言内置实例 (按 support() 顺序匹配)
  ├── DIALECT_MAPPING: DM → ORACLE
  └── getStringifier(type) → 按方言匹配，无匹配走 Default
```

---

## 源文件清单

| 文件 | 行数 | 职责 |
|------|------|------|
| `DatabaseObject2SqlStringifier.java` | 27 | 接口定义 |
| `DatabaseObject2SqlStringifiers.java` | 55 | 静态门面，SPI+内置加载+方言分发 |
| `impl/AbsDatabaseObject2SqlStringifier.java` | 84 | 抽象模板骨架 |
| `impl/dialect/MysqlDatabaseObject2SqlStringifier.java` | 34 | MySQL/MariaDB/Oscar/Gbase |
| `impl/dialect/OracleDatabaseObject2SqlStringifier.java` | 33 | Oracle/12c |
| `impl/dialect/PostgreSqlDatabaseObject2SqlStringifier.java` | 29 | PostgreSQL |
| `impl/dialect/SqlServerDatabaseObject2SqlStringifier.java` | 33 | SQL Server/2005 |
| `impl/dialect/Db2DatabaseObject2SqlStringifier.java` | 29 | DB2 |
| `impl/dialect/GuassDatabaseObject2SqlStringifier.java` | 29 | GaussDB |
| `impl/dialect/H2DatabaseObject2SqlStringifier.java` | 29 | H2 |
| `impl/dialect/HiveDatabaseObject2SqlStringifier.java` | 29 | Hive |
| `impl/dialect/PhoenixDatabaseObject2SqlStringifier.java` | 29 | Phoenix |
| `impl/dialect/DefaultDatabaseObject2SqlStringifier.java` | 20 | 通用兜底 |

---

## 依赖关系

### POM 声明依赖（3 个）

| 依赖 | 真实使用 | 用途 |
|------|----------|------|
| `i2f-convert` | **是** | `ObjectConvertor.isNumericType/isBooleanType/isDateType/tryConvertAsType` |
| `i2f-database-type` | **是** | `DatabaseType` 枚举 36 方言 + `DatabaseDialectMapping` 重定向 |
| `lombok` | **否** | 0 个 `import lombok.*` |

### 下游消费者

| 模块 | 引入方式 |
|------|----------|
| `i2f-bindsql-stringify` | POM 依赖 + `import DatabaseObject2SqlStringifier` + `import dialect.*`（~3 文件） |

---

## 关键设计要点

### 1. 类型分支链（`AbsDatabaseObject2SqlStringifier.stringify`）

```java
preStringify(obj)             // 子类钩子，返回非 null 即短路返回
null                 → "null"
数值 (Number 子类)     → String.valueOf(obj)
布尔 (Boolean 子类)    → "1" / "0"
日期 (Date/时间类型)    → decorateAsSqlString(dateToString(obj))
字符串/Appendable     → decorateAsSqlString(String.valueOf(obj))
其他Object            → decorateAsSqlString(String.valueOf(obj))
```

类型判定全部委托 `ObjectConvertor.isNumericType/isBooleanType/isDateType`（`i2f-convert` 的万能类型判定），因此支持 `java.util.Date`/`java.time.LocalDateTime`/`java.sql.Timestamp` 等任意日期子类型。

### 2. SQL 注入防御

```java
public static String decorateAsSqlString(Object value) {
    String str = String.valueOf(value);
    str = str.replace("'", "''");
    return "'" + str + "'";
}
```

所有非 null、非数值的值都经过 `'` → `''` 转义并包裹在单引号中。数值直出不转义（利用 JDBC 驱动自行处理）。

### 3. 日期方言函数矩阵

| 方言 | 日期 SQL 模板 | 示例输出 |
|------|---------------|----------|
| MySQL | `STR_TO_DATE('…', '%Y-%m-%d %H:%i:%s')` | `STR_TO_DATE('2024-01-15 14:30:00', '%Y-%m-%d %H:%i:%s')` |
| Oracle | `TO_DATE('…','yyyy-MM-dd HH24:mi:ss')` | `TO_DATE('2024-01-15 14:30:00','yyyy-MM-dd HH24:mi:ss')` |
| PostgreSQL | `TO_TIMESTAMP('…', 'YYYY-MM-DD HH24:MI:SS')` | `TO_TIMESTAMP('2024-01-15 14:30:00', 'YYYY-MM-DD HH24:MI:SS')` |
| SQL Server | `CONVERT(datetime, '…', 120)` | `CONVERT(datetime, '2024-01-15 14:30:00', 120)` |
| DB2 | `TIMESTAMP('…')` | `TIMESTAMP('2024-01-15 14:30:00')` |
| GaussDB | `'…'::timestamp` | `'2024-01-15 14:30:00'::timestamp` |
| H2 | `PARSEDATETIME('…', 'yyyy-MM-dd HH:mm:ss')` | `PARSEDATETIME('2024-01-15 14:30:00', 'yyyy-MM-dd HH:mm:ss')` |
| Hive | `cast('…' as timestamp)` | `cast('2024-01-15 14:30:00' as timestamp)` |
| Phoenix | `to_date('…')` | `to_date('2024-01-15 14:30:00')` |
| Default | `'2024-01-15 14:30:00'`（纯字符串） | `'2024-01-15 14:30:00'` |

### 4. SPI + 内置双级加载

```java
static {
    // 先加载 SPI（外部可注册）
    ServiceLoader<DatabaseObject2SqlStringifier> iter = ServiceLoader.load(...);
    for (...) { stringifiers.add(item); }
    // 再添加内置 9 方言（SPI 优先于内置）
    stringifiers.add(Db2DatabaseObject2SqlStringifier.INSTANCE);
    stringifiers.add(Guass...);
    // ... 8 more
}
```

`CopyOnWriteArrayList` 保证运行时动态增删安全。

### 5. 方言匹配与重定向

```java
public static DatabaseObject2SqlStringifier getStringifier(DatabaseType databaseType) {
    databaseType = DIALECT_MAPPING.dialectOf(databaseType);  // DM → ORACLE
    for (DatabaseObject2SqlStringifier item : stringifiers) {
        if (item.support(databaseType)) {
            return item;
        }
    }
    return DefaultDatabaseObject2SqlStringifier.INSTANCE;  // 永远兜底
}
```

---

## 已知缺陷

1. **`preStringify` 钩子无默认行为**：抽象方法签名为返回 `null` 的默认实现，但子类若覆写为返回非 null，会绕过全部类型判定和 SQL 注入转义，子类需自行处理 `'` 转义

2. **`booleanToString` 仅返回 "1"/"0"**：不支持所有数据库的布尔字面量（如 PostgreSQL 的 `TRUE`/`FALSE`，MySQL 的 `true`/`false`），统一的 "1"/"0" 可能在非 MySQL 方言中导致类型不匹配

3. **日期转换统一 `yyyy-MM-dd HH:mm:ss` 格式**：不包含时区信息，`LocalDateTime` 格式化不带时区偏移，对于 TIMESTAMP WITH TIME ZONE 类型的列可能产生语义偏差

4. **`objectToString` 与 `stringToString` 逻辑完全一致**：两者都调用 `decorateAsSqlString(String.valueOf(obj))`，对于非 String/CharSequence/Appendable 的自定义对象，`toString()` 输出可能不是预期的 SQL 表示

5. **多方言覆盖不全**：当前 9 种方言覆盖，但 `i2f-database-type` 收录了 36 种数据库，未覆盖的 27 种全部走 `Default`（纯字符串 `'…'`），其中 ClickHouse、TiDB 等有自有日期函数的库无法获得最优 SQL

6. **`DIALECT_MAPPING` 功能过于薄弱**：仅注册了 `DM → ORACLE` 一条重定向，KingbaseES、OceanBase 等可归并的方言未注册

7. **`CopyOnWriteArrayList` 遍历无防重复注册**：多次调用 `ServiceLoader` 或手动添加了相同 `INSTANCE` 的 `stringifiers` 列表会产生重复，`getStringifier` 取首个即不影响结果，但内存浪费

8. **lombok 声明未使用**：`pom.xml` 声明的 `lombok` 在 13 个源文件中均无 `import lombok.*`