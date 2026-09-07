# 数据库类型检测与元数据逆向工程体系

## 概述

项目提供了一套完整的数据库类型检测与元数据逆向工程体系，涵盖 **5 个核心模块**：从底层数据库类型识别（`i2f-database-type`
）、元数据模型定义（`i2f-database-metadata-data`）、标准接口抽象（`i2f-database-metadata-std`
）、多数据库实现（`i2f-database-metadata-impl`）到 Bean 级代码生成（`i2f-database-metadata-bean`）。

该体系支持 **34 种数据库类型**的自动识别，提供 **8 种数据库**的专用元数据读取实现，以及 DDL / Java Bean 两种逆向代码生成方案。

## 模块信息

| 属性       | i2f-database-type          | i2f-database-metadata-data       | i2f-database-metadata-std   | i2f-database-metadata-impl           | i2f-database-metadata-bean   |
|----------|----------------------------|----------------------------------|-----------------------------|--------------------------------------|------------------------------|
| **父模块**  | `i2f-jdk`                  | `i2f-jdk`                        | `i2f-jdk`                   | `i2f-jdk`                            | `i2f-jdk`                    |
| **版本**   | `1.0-jdk8`                 | `1.0-jdk8`                       | `1.0-jdk8`                  | `1.0-jdk8`                           | `1.0-jdk8`                   |
| **包路径**  | `i2f.database.type/driver` | `i2f.database.metadata.data/std` | `i2f.database.metadata.std` | `i2f.database.metadata.impl/reverse` | `i2f.database.metadata.bean` |
| **源文件数** | 9                          | 6                                | 2                           | 28                                   | 2                            |
| **定位**   | 数据库类型检测 + 方言代理驱动           | 元数据模型 + 标准类型映射                   | 元数据接口标准定义                   | 多数据库元数据实现 + DDL 逆向                   | Bean 解析 + Java 代码生成          |

## 依赖关系

```
i2f-database-type                        ← 零内部依赖（仅 Lombok）
i2f-database-metadata-data               ← 零内部依赖（仅 Lombok）
i2f-database-metadata-std                ← i2f-database-metadata-data, i2f-jdbc-data
i2f-database-metadata-impl               ← i2f-database-metadata-std, i2f-database-type,
                                            i2f-jdbc-impl, i2f-text, i2f-form-url-encoded
                                            + 8 种数据库 JDBC 驱动（provided）
i2f-database-metadata-bean               ← i2f-database-metadata-std, i2f-database-metadata-data,
                                            i2f-database-type, i2f-reflect, i2f-annotations-db,
                                            i2f-text, i2f-lru-map
```

## 1. i2f-database-type — 数据库类型检测与方言代理

### 1.1 DatabaseType 枚举

核心枚举，定义 **34 种数据库类型**，支持通过枚举名、数据库标识名两种方式查找。

| 枚举值              | 标识              | 说明              |
|------------------|-----------------|-----------------|
| `MYSQL`          | `mysql`         | MySQL           |
| `MARIADB`        | `mariadb`       | MariaDB         |
| `ORACLE`         | `oracle`        | Oracle 11g 及以下  |
| `ORACLE_12C`     | `oracle12c`     | Oracle 12c+     |
| `DB2`            | `db2`           | DB2             |
| `H2`             | `h2`            | H2              |
| `HSQL`           | `hsql`          | HSQL            |
| `SQLITE`         | `sqlite`        | SQLite          |
| `POSTGRE_SQL`    | `postgresql`    | PostgreSQL      |
| `SQL_SERVER2005` | `sqlserver2005` | SQL Server 2005 |
| `SQL_SERVER`     | `sqlserver`     | SQL Server（新版）  |
| `DM`             | `dm`            | 达梦              |
| `XU_GU`          | `xugu`          | 虚谷              |
| `KINGBASE_ES`    | `kingbasees`    | 人大金仓            |
| `PHOENIX`        | `phoenix`       | Phoenix HBase   |
| `GAUSS`          | `zenith`        | 华为 Gauss        |
| `CLICK_HOUSE`    | `clickhouse`    | ClickHouse      |
| `GBASE`          | `gbase`         | 南大通用            |
| `OSCAR`          | `oscar`         | 神通              |
| `SYBASE`         | `sybase`        | Sybase ASE      |
| `OCEAN_BASE`     | `oceanbase`     | OceanBase       |
| `FIREBIRD`       | `Firebird`      | Firebird        |
| `HighGo`         | `highgo`        | 瀚高              |
| `Hive`           | `hive`          | Hive            |
| `YaShanDB`       | `YaShanDB`      | 崖山              |
| `TDengine`       | `TDengine`      | 涛思              |
| `HerdDB`         | `HerdDB`        | HerdDB 嵌入式分布式   |
| `CirroData`      | `CirroData`     | 东方国信            |
| `IbmAs400`       | `IbmAs400`      | IBM AS/400      |
| `Informix`       | `Informix`      | Informix        |
| `Snowflake`      | `Snowflake`     | Snowflake       |
| `Databricks`     | `Databricks`    | Databricks      |
| `RedShift`       | `RedShift`      | RedShift        |
| `Trino`          | `Trino`         | Trino 分布式协调     |
| `OTHER`          | `other`         | 未识别             |
| `ERROR`          | `error`         | URL 解析错误        |

### 1.2 类型检测机制

提供三种检测方式，支持 SPI 扩展：

```java
// 1. 按名称查找
DatabaseType.typeOfName("mysql")         →MYSQL
DatabaseType.

typeOfName("MYSQL")         →MYSQL

// 2. 按 JDBC URL 检测（支持 SPI 扩展）
DatabaseType.

typeOfJdbcUrl("jdbc:mysql://localhost:3306/test")  →MYSQL

// 3. 按 Connection 检测（带 WeakHashMap 缓存）
DatabaseType.

typeOfConnection(conn)      →自动识别
```

**SPI 扩展接口：**

| 接口                            | 说明                                                 |
|-------------------------------|----------------------------------------------------|
| `DatabaseTypeDetector`        | 数据库类型检测器，`detect(String jdbcUrl)` → `DatabaseType` |
| `DatabaseDialectTypeDetector` | 方言类型检测器，`detect(String jdbcUrl)` → `DatabaseType`  |

两个检测器均通过 `ServiceLoader` 自动加载，注册到 `DatabaseType.DETECTORS` / `DIALECT_DETECTORS` 全局集合中。

### 1.3 DatabaseDialectMapping — 方言映射

支持将检测到的数据库类型重定向到目标方言，用于兼容模式场景：

```java
DatabaseDialectMapping mapping = new DatabaseDialectMapping();
// 将 DM 数据库重定向为 Oracle 方言
mapping.

redirect(DatabaseType.DM, DatabaseType.ORACLE);
// 按 JDBC URL 重定向
mapping.

redirect("jdbc:dm://localhost:5230/",DatabaseType.ORACLE);

// 获取实际方言
DatabaseType dialect = mapping.dialectOf(conn);
```

### 1.4 ProxyDialectJdbcDriver — 方言代理驱动

专用的 JDBC 代理驱动，用于在连接 URL 中显式指定方言类型，解决国产数据库兼容模式场景。

**URL 格式：** `jdbc:proxy:{方言类型}:{真实驱动URL部分}`

**示例：**

```
# 原始 MySQL 连接
jdbc:mysql://localhost:3306/test_db?serverTimezone=Asia/Shanghai

# 代理连接（显式指定 mysql 方言）
jdbc:proxy:mysql:mysql://localhost:3306/test_db?serverTimezone=Asia/Shanghai

# 达梦 Oracle 兼容模式 — 使用 Oracle 方言
jdbc:proxy:oracle:dm://localhost:5230/
```

**工作原理：**

1. `ProxyDialectJdbcDriver` 注册到 `DriverManager`，拦截 `jdbc:proxy:` 前缀的 URL
2. 解析出方言类型和真实 JDBC URL
3. 通过真实 URL 获取对应的 `Driver`，建立实际连接
4. 使用 JDK 动态代理创建 `ProxyDialectConnection`，同时实现 `Connection` 和 `ProxyDialectConnectionFeature`
5. 代理连接在调用 `getMetaData().getURL()` 时返回原始代理 URL，使 `DatabaseType` 能正确识别方言

**代理连接特性接口（`ProxyDialectConnectionFeature`）：**

| 方法                         | 说明                |
|----------------------------|-------------------|
| `getProxyRealConnection()` | 获取底层真实 Connection |
| `getProxyDialect()`        | 获取代理方言类型          |
| `getProxyRealUrl()`        | 获取真实 JDBC URL     |
| `getProxyRealDriver()`     | 获取真实 Driver       |

## 2. i2f-database-metadata-data — 元数据模型

### 2.1 数据模型

| 类                 | 说明                                                                                                                                                    |
|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|
| `TableMeta`       | 表元数据：catalog、schema、database、name、comment、type、columns、primary、uniqueIndexes、indexes                                                                  |
| `ColumnMeta`      | 列元数据：index、name、type、comment、precision、scale、nullable、autoIncrement、generated、defaultValue、javaType、jdbcType、stdType、primaryKey/uniqueKey/indexKey 标记 |
| `IndexMeta`       | 索引元数据：name、isUnique、columns                                                                                                                           |
| `IndexColumnMeta` | 索引列元数据：index、name、isDesc、type                                                                                                                         |

### 2.2 类型系统

**`IColumnType` 接口** — 列类型抽象：

```java
public interface IColumnType {
    String text();           // 类型名称

    boolean precision();     // 是否支持精度

    boolean scale();         // 是否支持小数位

    StdType stdType();       // 对应的标准类型
}
```

**`StdType` 枚举** — 33 种标准列类型，每种类型定义了精确映射和宽松映射：

| 类型          | Java 类型      | JDBC 类型     | 精度  | 小数  | 宽松 Java      | 宽松 JDBC   |
|-------------|--------------|-------------|-----|-----|--------------|-----------|
| `INT`       | `Integer`    | `INTEGER`   | -   | -   | `Integer`    | `NUMERIC` |
| `VARCHAR`   | `String`     | `VARCHAR`   | ✓   | -   | `String`     | `VARCHAR` |
| `BIGINT`    | `Long`       | `BIGINT`    | -   | -   | `Long`       | `NUMERIC` |
| `DATETIME`  | `Date`       | `DATE`      | -   | -   | `Date`       | `DATE`    |
| `DECIMAL`   | `BigDecimal` | `DECIMAL`   | ✓   | ✓   | `BigDecimal` | `NUMERIC` |
| `CHAR`      | `String`     | `CHAR`      | ✓   | -   | `String`     | `VARCHAR` |
| `DOUBLE`    | `Double`     | `DOUBLE`    | ✓   | ✓   | `Double`     | `NUMERIC` |
| `FLOAT`     | `Float`      | `FLOAT`     | ✓   | ✓   | `Double`     | `NUMERIC` |
| `TEXT`      | `String`     | `VARCHAR`   | -   | -   | `String`     | `VARCHAR` |
| `BLOB`      | `String`     | `BLOB`      | -   | -   | `String`     | `BLOB`    |
| `TIMESTAMP` | `Timestamp`  | `TIMESTAMP` | -   | -   | `Date`       | `DATE`    |
| `BIT`       | `Boolean`    | `BIT`       | -   | -   | `Boolean`    | `BIT`     |
| `BOOL`      | `Boolean`    | `BOOLEAN`   | -   | -   | `Boolean`    | `BOOLEAN` |
| `DATE`      | `Date`       | `DATE`      | -   | -   | `Date`       | `DATE`    |
| `TIME`      | `Date`       | `TIME`      | -   | -   | `Date`       | `TIME`    |
| `NUMERIC`   | `Double`     | `NUMERIC`   | ✓   | ✓   | `Double`     | `NUMERIC` |
| `TINYINT`   | `Short`      | `TINYINT`   | -   | -   | `Integer`    | `NUMERIC` |
| `SMALLINT`  | `Short`      | `SMALLINT`  | -   | -   | `Integer`    | `NUMERIC` |
| ...         | ...          | ...         | ... | ... | ...          | ...       |

每种类型支持通过 `detectType(typeName, javaType)` 进行多级匹配：精确文本 → 前缀匹配 → JDBC 名称 → 宽松 JDBC → Java 类型名。

## 3. i2f-database-metadata-std — 标准接口定义

### 3.1 DatabaseMetadataProvider — 元数据提供者接口

核心接口，定义了数据库元数据读取的标准契约：

| 方法                                           | 说明                 |
|----------------------------------------------|--------------------|
| `getSpiDrivers()`                            | SPI 加载所有 JDBC 驱动   |
| `getProductName(conn)`                       | 获取数据库产品名称          |
| `getProductVersion(conn)`                    | 获取数据库产品版本          |
| `getDriverName(conn)`                        | 获取驱动名称             |
| `getDriverVersion(conn)`                     | 获取驱动版本             |
| `getConnectionUrl(conn)`                     | 获取连接 URL           |
| `getUsername(conn)`                          | 获取用户名              |
| `detectDefaultDatabase(conn/jdbcUrl)`        | 检测默认数据库名           |
| `getDataTypes(conn)`                         | 获取所有数据类型名          |
| `getCatalogs(conn)`                          | 获取所有 Catalog       |
| `getSchemas(conn)`                           | 获取所有 Schema        |
| `getDatabases(conn)`                         | 获取所有数据库            |
| `getTables(conn, database, tablePattern)`    | 获取表列表              |
| `getTableInfo(conn, database, table)`        | 获取完整表元数据（含列、主键、索引） |
| `getTableInfoByQuery(result/rs/conn, table)` | 通过查询结果反推表元数据       |

### 3.2 DatabaseReverseEngineer — 逆向工程接口

代码生成接口，将 `TableMeta` 转换为目标代码：

```java
public interface DatabaseReverseEngineer {
    String generate(TableMeta meta);

    default String generate(Iterable<TableMeta> list);  // 批量生成
}
```

## 4. i2f-database-metadata-impl — 多数据库实现

### 4.1 DatabaseMetadataProvider 实现一览

| #  | 实现类                                  | 目标数据库               | 特点                                                               |
|----|--------------------------------------|---------------------|------------------------------------------------------------------|
| 1  | `BaseDatabaseMetadataProvider`       | 抽象基类                | 通用 JDBC DatabaseMetaData 解析、表/列/主键/索引解析、注释回退机制                   |
| 2  | `MysqlDatabaseMetadataProvider`      | MySQL / MariaDB     | 自定义表注释查询、MySQL 类型映射（`MySqlType`，含 ENUM/SET/JSON 等）               |
| 3  | `OracleDatabaseMetadataProvider`     | Oracle / Oracle 12c | Oracle 专用注释查询（`ALL_TAB_COMMENTS`/`ALL_COL_COMMENTS`）、Oracle 类型映射 |
| 4  | `PostgreSqlDatabaseMetadataProvider` | PostgreSQL          | Schema 感知、PostgreSQL 类型映射（含 JSON/JSONB/UUID/ARRAY 等）             |
| 5  | `SqlServerDatabaseMetadataProvider`  | SQL Server          | SQL Server 类型映射（含 UNIQUEIDENTIFIER/XML/NVARCHAR 等）               |
| 6  | `H2DatabaseMetadataProvider`         | H2                  | H2 内嵌数据库适配                                                       |
| 7  | `Sqlite3DatabaseMetadataProvider`    | SQLite              | SQLite 特殊元数据读取（`PRAGMA table_info`）、SQLite 类型映射                  |
| 8  | `DmDatabaseMetadataProvider`         | 达梦                  | 达梦国产数据库适配                                                        |
| 9  | `GbaseDatabaseMetadataProvider`      | 南大通用                | GBase 国产数据库适配                                                    |
| 10 | `JdbcDatabaseMetadataProvider`       | 通用 JDBC             | 标准 JDBC 回退实现，支持所有数据库                                             |
| 11 | `DelegateDatabaseMetadataProvider`   | 委托模式                | 组合多个 Provider，按顺序尝试，首个成功返回                                       |

**工厂类 `DatabaseMetadataProviders`：**

```java
// 自动根据连接识别数据库类型，返回对应 Provider（附带 JdbcDatabaseMetadataProvider 作为回退）
DatabaseMetadataProvider provider = DatabaseMetadataProviders.getProvider(conn);
// 仅查找对应 Provider，不包装委托
DatabaseMetadataProvider found = DatabaseMetadataProviders.findProvider(conn);
```

自动路由规则：MySQL/MariaDB → MySQL Provider，Oracle/Oracle12c → Oracle Provider，PostgreSQL → PostgreSQL
Provider，SQLServer → SQLServer Provider，H2 → H2 Provider，SQLite → SQLite Provider，DM → DM Provider，GBase → GBase
Provider，OceanBase → 根据用户名判断 Oracle/MySQL 模式。

### 4.2 方言类型映射枚举

每个数据库实现提供专用类型映射枚举，实现 `IColumnType` 接口：

| 枚举类              | 类型数 | 说明                                            |
|------------------|-----|-----------------------------------------------|
| `MySqlType`      | 33+ | 含 ENUM、SET、JSON、GEOMETRY 等 MySQL 特有类型         |
| `OracleType`     | 20+ | 含 RAW、LONG RAW、BFILE、XMLTYPE 等 Oracle 特有类型    |
| `PostgreSqlType` | 25+ | 含 JSON/JSONB、UUID、ARRAY、INET、MONEY 等          |
| `SqlServerType`  | 15+ | 含 UNIQUEIDENTIFIER、XML、SQL_VARIANT、NVARCHAR 等 |
| `Sqlite3Type`    | 5   | SQLite 简化类型系统                                 |
| `DmType`         | 10+ | 达梦特有类型                                        |
| `GbaseType`      | 10+ | GBase 特有类型                                    |

### 4.3 DDL 逆向工程实现

**`DdlDatabaseReverseEngineer`** 接口继承自 `DatabaseReverseEngineer`，用于生成 CREATE TABLE DDL 语句。

**`DdlDatabaseReverseEngineers` 工厂类** 根据数据库类型自动选择实现：

| 实现类                                 | 适用数据库                                                          | 说明                |
|-------------------------------------|----------------------------------------------------------------|-------------------|
| `MysqlDdlDatabaseReverseEngineer`   | MySQL / MariaDB / H2 / ClickHouse / OceanBase / Hive / Phoenix | MySQL 方言 DDL      |
| `OracleDdlDatabaseReverseEngineer`  | Oracle / Oracle 12c / DM                                       | Oracle 方言 DDL     |
| `PostgreDdlDatabaseReverseEngineer` | PostgreSQL                                                     | PostgreSQL 方言 DDL |
| `GbaseDdlDatabaseReverseEngineer`   | GBase                                                          | GBase 方言 DDL      |
| `StdDdlDatabaseReverseEngineer`     | 其他所有数据库                                                        | 通用标准 DDL（默认回退）    |

## 5. i2f-database-metadata-bean — Bean 级元数据解析与代码生成

| 类                                 | 说明                                                                                     |
|-----------------------------------|----------------------------------------------------------------------------------------|
| `BeanDatabaseMetadataResolver`    | 将 Java Bean 类解析为 `TableMeta`（正向），支持 `@Table`/`@Column` 注解、驼峰转下划线、LRU 缓存                |
| `JavaBeanDatabaseReverseEngineer` | 将 `TableMeta` 生成 Java Bean 源码（逆向），含 Lombok `@Data`/`@NoArgsConstructor` 注解、JDBCType 注释 |

## 6. 完整模块协作流程

```
┌─────────────────────────────────────────────────────────────────────┐
│                      数据库元数据逆向工程流程                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. 建立连接                                                         │
│     jdbc:proxy:oracle:dm://localhost:5230/                          │
│         ↓                                                           │
│  2. 类型检测 (i2f-database-type)                                     │
│     ProxyDialectJdbcDriver → 解析方言 → DatabaseType.DM             │
│     DatabaseDialectMapping → 重定向 → DatabaseType.ORACLE            │
│         ↓                                                           │
│  3. 元数据读取 (i2f-database-metadata-impl)                          │
│     DatabaseMetadataProviders.getProvider(conn)                     │
│         → OracleDatabaseMetadataProvider                            │
│         → 读取表/列/主键/索引/注释                                    │
│         ↓                                                           │
│  4. 元数据模型 (i2f-database-metadata-data)                          │
│     TableMeta → ColumnMeta[] → IndexMeta[]                          │
│         ↓                                                           │
│  5. 代码生成                                                         │
│     ├── DDL: DdlDatabaseReverseEngineers.getEngineer(conn)          │
│     │       → OracleDdlDatabaseReverseEngineer → CREATE TABLE ...   │
│     └── Java Bean: JavaBeanDatabaseReverseEngineer                  │
│             → @Data class User { ... }                              │
│                                                                     │
│  反向流程（Bean → DDL）：                                             │
│     BeanDatabaseMetadataResolver.parse(User.class)                  │
│         → TableMeta → DdlDatabaseReverseEngineer → CREATE TABLE     │
└─────────────────────────────────────────────────────────────────────┘
```

## 7. 源文件清单

### i2f-database-type（9 文件）

| 文件                                             | 行数  | 说明                  |
|------------------------------------------------|-----|---------------------|
| `DatabaseType.java`                            | 445 | 数据库类型枚举（34 种）+ 检测逻辑 |
| `DatabaseTypeDetector.java`                    | 19  | 类型检测 SPI 接口         |
| `DatabaseDialectTypeDetector.java`             | 19  | 方言检测 SPI 接口         |
| `DatabaseDialectMapping.java`                  | 72  | 方言映射（重定向）           |
| `ProxyDialectJdbcDriver.java`                  | 109 | 方言代理 JDBC 驱动        |
| `ProxyDialectConnection.java`                  | 12  | 代理连接接口              |
| `ProxyDialectConnectionFeature.java`           | 28  | 代理连接特性接口            |
| `ProxyDialectConnectionInvocationHandler.java` | 42  | 代理连接调用处理器           |
| `ProxyDialectJdbcUrlMeta.java`                 | 18  | 代理 URL 元数据          |

### i2f-database-metadata-data（6 文件）

| 文件                     | 行数  | 说明            |
|------------------------|-----|---------------|
| `TableMeta.java`       | 83  | 表元数据模型        |
| `ColumnMeta.java`      | 82  | 列元数据模型        |
| `IndexMeta.java`       | 18  | 索引元数据模型       |
| `IndexColumnMeta.java` | 21  | 索引列元数据模型      |
| `StdType.java`         | 161 | 标准列类型枚举（33 种） |
| `IColumnType.java`     | 16  | 列类型接口         |

### i2f-database-metadata-std（2 文件）

| 文件                              | 行数 | 说明       |
|---------------------------------|----|----------|
| `DatabaseMetadataProvider.java` | 83 | 元数据提供者接口 |
| `DatabaseReverseEngineer.java`  | 28 | 逆向工程接口   |

### i2f-database-metadata-impl（28 文件）

| 文件                                        | 行数  | 说明              |
|-------------------------------------------|-----|-----------------|
| `DatabaseMetadataProviders.java`          | 72  | Provider 工厂     |
| `BaseDatabaseMetadataProvider.java`       | 665 | 抽象基类            |
| `DelegateDatabaseMetadataProvider.java`   | 240 | 委托模式 Provider   |
| `MysqlDatabaseMetadataProvider.java`      | 364 | MySQL 实现        |
| `MySqlType.java`                          | 162 | MySQL 类型映射      |
| `OracleDatabaseMetadataProvider.java`     | 426 | Oracle 实现       |
| `OracleType.java`                         | 137 | Oracle 类型映射     |
| `PostgreSqlDatabaseMetadataProvider.java` | 322 | PostgreSQL 实现   |
| `PostgreSqlType.java`                     | 174 | PostgreSQL 类型映射 |
| `SqlServerDatabaseMetadataProvider.java`  | 325 | SQL Server 实现   |
| `SqlServerType.java`                      | 97  | SQL Server 类型映射 |
| `H2DatabaseMetadataProvider.java`         | 318 | H2 实现           |
| `Sqlite3DatabaseMetadataProvider.java`    | 602 | SQLite 实现       |
| `Sqlite3Type.java`                        | 50  | SQLite 类型映射     |
| `DmDatabaseMetadataProvider.java`         | 105 | 达梦实现            |
| `DmType.java`                             | 64  | 达梦类型映射          |
| `GbaseDatabaseMetadataProvider.java`      | 88  | GBase 实现        |
| `GbaseType.java`                          | 77  | GBase 类型映射      |
| `JdbcDatabaseMetadataProvider.java`       | 324 | 通用 JDBC 实现      |
| `DdlDatabaseReverseEngineer.java`         | 12  | DDL 逆向接口        |
| `DdlDatabaseReverseEngineers.java`        | 90  | DDL 逆向工厂        |
| `DefaultDdlDatabaseReverseEngineer.java`  | 175 | 默认 DDL 实现       |
| `MysqlDdlDatabaseReverseEngineer.java`    | 49  | MySQL DDL       |
| `OracleDdlDatabaseReverseEngineer.java`   | 154 | Oracle DDL      |
| `PostgreDdlDatabaseReverseEngineer.java`  | 141 | PostgreSQL DDL  |
| `GbaseDdlDatabaseReverseEngineer.java`    | 49  | GBase DDL       |
| `StdDdlDatabaseReverseEngineer.java`      | 24  | 标准 DDL（回退）      |
| `TestDatabaseMetadata.java`               | 478 | 测试类             |

### i2f-database-metadata-bean（2 文件）

| 文件                                     | 行数  | 说明                         |
|----------------------------------------|-----|----------------------------|
| `BeanDatabaseMetadataResolver.java`    | 426 | Bean → TableMeta 正向解析      |
| `JavaBeanDatabaseReverseEngineer.java` | 86  | TableMeta → Java Bean 代码生成 |
