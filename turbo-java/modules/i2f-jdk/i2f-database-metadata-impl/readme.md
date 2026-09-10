# i2f-database-metadata-impl

> 数据库元数据**多方言实现层**——落地 `i2f-database-metadata-std` 标准契约，以 **模板方法 + 委拖代理** 双架构提供 **9 种方言** 的 JDBC 元数据读取器（MySQL/Oracle/DM/Gbase/H2/PostgreSQL/SQLite3/SQL Server/JDBC 通用）+ **5 方言 DDL 反向生成器**，由 `i2f-extension-reverse-engineer-generator`（代码生成器）和 `i2f-springboot-ops-starter`（运维控制台）消费。

---

## 模块定位

- **功能**：
  - 从 JDBC `Connection` 读取表/列/索引元数据，适配各方言 JDBC API 差异（大小写、catalog/schema 语义、`information_schema` 备用查询）
  - 从 `TableMeta` 数据模型生成方言兼容的 `CREATE TABLE`/`CREATE INDEX`/`DROP TABLE` DDL 语句
- **所属层级**：`i2f-jdk` 持久化基础层，位于 `i2f-database-metadata-std` 和 `i2f-database-metadata-data` 的上游实现层
- **设计原则**：
  - **模板方法**：`BaseDatabaseMetadataProvider` 定义 `getTableInfo()` 完整流程（查表 → 查列 → 查主键 → 查索引 → 排序），各方言子类 hook 覆写特定步骤
  - **大小写容错容灾**：MySQL 以 `lower_case_table_names` 小写回退、Oracle 全大写回退、`JdbcDatabaseMetadataProvider` 不区分大小写字段匹配
  - **Delegate 委拖链**：`DelegateDatabaseMetadataProvider` 将多个 Provider 以「依次尝试、异常穿透」模式编排，先方言特有、后 JDBC 通用兜底
  - **DDL 双向转换**：`CONVERT` 内部匿名子类支持从 `StdType` 跨方言映射类型名（如 Oracle `NUMBER(15,0)` → MySQL `INT`）

---

## 架构一览

```
┌─────────────────────────────────────────────────────────────────────┐
│  Metadata Providers  (9 方言)                                        │
│                                                                     │
│  DatabaseMetadataProviders.getProvider(conn)                        │
│        │                                                           │
│        ▼                                                           │
│  DelegateDatabaseMetadataProvider (composite + failover)           │
│        │                                                           │
│        ├── 方言特有 Provider (MySQL/Oracle/DM/Gbase/H2/...)        │
│        └── JdbcDatabaseMetadataProvider (通用兜底)                  │
│                                                                     │
│  BaseDatabaseMetadataProvider (abstract, 665 行)                    │
│   ├── getTables() / getTableInfo()        ← 流程骨架               │
│   ├── parseTable() / parseColumn()        ← hook 方法              │
│   ├── getTablesComment() / getColumnsComment() ← hook 方法         │
│   ├── parsePrimaryKey() / parseIndexes()  ← hook 方法              │
│   └── asString/asInteger/asBoolean(...)   ← 空安全类型转换          │
│        │                                                           │
│        ├── MysqlDatabaseMetadataProvider  (364 行, MySQL/MariaDB)   │
│        │     └── GbaseDatabaseMetadataProvider (88 行, 南大通用)    │
│        ├── OracleDatabaseMetadataProvider  (426 行, Oracle/OceanDB) │
│        ├── PostgreSqlDatabaseMetadataProvider (322 行)              │
│        ├── Sqlite3DatabaseMetadataProvider (602 行, 含 DDL 解析)    │
│        ├── DmDatabaseMetadataProvider      (105 行, 达梦)           │
│        ├── H2DatabaseMetadataProvider      (318 行)                 │
│        └── SqlServerDatabaseMetadataProvider (325 行)               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  Type Enums  (方言类型枚举, 均实现 IColumnType)                      │
│                                                                     │
│  MySqlType     (44 常量, 含 GEOMETRY/POINT 等 8 空间类型)          │
│  OracleType    (35 常量, ofStd 精确/NUMBER → INT/BIGINT 精度判据)  │
│  PostgreSqlType(42 常量, ofStd 映射)                                │
│  DmType        (13 常量, 达梦特有 NUMBER/DATE/TIMESTAMP 等)         │
│  GbaseType     (19 常量)                                            │
│  Sqlite3Type   (12 常量, 含 AUTOINCREMENT 特殊处理)                │
│  SqlServerType (24 常量)                                            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  DDL Reverse Engineers  (DDL 反向生成器, 5 方言)                    │
│                                                                     │
│  DdlDatabaseReverseEngineers.getEngineer(conn/type)                 │
│        │                                                           │
│        ▼                                                           │
│  DefaultDdlDatabaseReverseEngineer (DDL 骨架: drop+create+index)    │
│   ├── MysqlDdlDatabaseReverseEngineer   (含 CONVERT 跨方言转换)     │
│   ├── OracleDdlDatabaseReverseEngineer  (序列+comment on 语法)      │
│   ├── PostgreDdlDatabaseReverseEngineer                             │
│   ├── GbaseDdlDatabaseReverseEngineer                               │
│   └── StdDdlDatabaseReverseEngineer    (StdType 兜底)               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 数据类型枚举

### 方言类型枚举概览

| 枚举 | 常量数 | 特色 |
|------|--------|------|
| `MySqlType` | 44 | 含 8 个空间类型(GEOMETRY/POINT/LINESTRING/POLYGON/MULTI*) 全部映射为 `StdType.VARCHAR` |
| `OracleType` | 35 | `ofStd()` 对数值类型做精度细粒度映射：`TINYINT→NUMBER(3,0)`, `INT→NUMBER(15,0)`, `BIGINT→NUMBER(32,0)` |
| `PostgreSqlType` | 42 | 覆盖 PG 特有类型如 BOOL/BYTEA/UUID/JSON/JSONB/XML/ARRAY/MONEY/CIDR/MACADDR/INTERVAL/TXID_SNAPSHOT |
| `SqlServerType` | 24 | 覆盖 SQL Server 特有类型如 UNIQUEIDENTIFIER/DATETIME2/DATETIMEOFFSET/SQL_VARIANT/HIERARCHYID |
| `Sqlite3Type` | 12 | 精简类型映射（SQLite3 只有 5 种存储类） |
| `DmType` | 13 | 达梦特有类型 |
| `GbaseType` | 19 | 南大通用特有类型 |

### 类型映射策略

各方言 `parseColumn()` hook 方法中，不仅使用方言类型枚举获取 `StdType` 映射，还对 Oracle 的 `NUMBER` 做了精度感知的特殊处理：

```java
// OracleDatabaseMetadataProvider.parseColumn() 中
if (oracleType == OracleType.NUMBER) {
    if (col.getScale() <= 0) {
        int prec = col.getPrecision();
        if (prec <= 3)      type = StdType.TINYINT;
        else if (prec <= 5) type = StdType.SMALLINT;
        else if (prec <= 10) type = StdType.INT;
        else if (prec <= 20) type = StdType.BIGINT;
    }
}
```

---

## DDL 反向生成器

### DefaultDdlDatabaseReverseEngineer

`generate(TableMeta)` 方法的生产顺序：

```
1. generateBefore()     ── 注释头 "-- database.table comment"
2. generateDropTable()  ── "drop table if exists xxx;"
3. generateCreateTable()── 列定义 + 主键约束
4. generateUniqueIndexes()── "create unique index ..."
5. generateIndexes()    ── "create index ..."
6. generateAfter()      ── 后置 SQL
```

### 方言 DDL 差异

| 特性 | Default | MySQL | Oracle | PostgreSQL |
|------|---------|-------|--------|------------|
| `auto_increment` | 支持 | `auto_increment` | 生成 SEQUENCE | `serial`/`identity` |
| 关键字大小写 | 原样 | `lower` | `UPPER` | `lower` |
| 表/列名大小写 | 原样 | `lower` | `UPPER` | `lower` |
| `drop table` | `drop table if exists` | 同左 | `begin exception` 保护 | 同左 |
| 注释 | `comment ` 列联 | 同左 | `comment on table/column` | 同左 |
| 类型跨方言转换 | `columnType` 原样 | `CONVERT` 按 StdType 转 MySQL 类型 | `CONVERT` 按 StdType 转 Oracle NUMBER(n,m) | 同左 |

### CONVERT 内部匿名子类

`MysqlDdlDatabaseReverseEngineer.CONVERT` / `OracleDdlDatabaseReverseEngineer.CONVERT` 以 `ofStd(StdType)` 将跨方言表结构的列类型映射为目标方言类型，用于代码生成器的跨方言迁移场景。

---

## 依赖关系

| 依赖 | 类型 | 用途 |
|------|------|------|
| `i2f-database-metadata-data` | 编译 | TableMeta/ColumnMeta/IndexMeta 数据模型 |
| `i2f-database-metadata-std` | 编译 | DatabaseMetadataProvider/DatabaseReverseEngineer 接口 |
| `i2f-text` | 编译 | StringUtils 判空 |
| `i2f-form-url-encoded` | 编译 | UriMeta 从 JDBC URL 解析数据库名 |
| `i2f-jdbc-impl` | 编译 | JdbcResolver 执行 SQL、QueryResult 行/列模型 |
| `i2f-database-type` | 编译 | DatabaseType.typeOfConnection() 方言识别 |
| `lombok` | 编译期 | `@Data @NoArgsConstructor` 仅在 `DelegateDatabaseMetadataProvider`（**真实使用**） |
| 各 JDBC Driver | provided | MySQL/Oracle/PostgreSQL/H2/SQLite/DM/Kingbase/SQL Server/OceanBase |

---

## 下游消费者

| 模块 | 消费内容 |
|------|----------|
| `i2f-extension-reverse-engineer-generator` | `DatabaseMetadataProviders.getProvider(conn)` + `DdlDatabaseReverseEngineers.getEngineer(conn)` |
| `i2f-springboot-ops-starter` | 运维控制台元数据浏览 |
| `i2f-database` | 聚合引入 |
| `i2f-jdk-all` | 聚合引入 |

---

## 已知缺陷

1. **`JdbcDatabaseMetadataProvider` 构建三方方言类型映射的非对称依赖**：`JdbcDatabaseMetadataProvider` 和 `BaseDatabaseMetadataProvider.getTableInfoByQuery()` `parseColumn()` 中 `import` 了 `MySqlType`/`OracleType`/`PostgreSqlType` 三个方言类型枚举来构建 `typeMap`。这导致无三方依赖想仅用 JDBC 通用实现时，仍会把 MySQL/Oracle/PostgreSQL 的类型映射全部加载到 classpath，尽管运行期可能只连接 SQLite。

2. **`OracleDatabaseMetadataProvider.parseIndexes()` 主键误判风险**：通过 `CARDINALITY` 字段匹配主键的启发式算法（`primaryCardinality` 与索引的 `CARDINALITY` 相等即认为是主键），在主键的 `CARDINALITY` 与其他索引相同时可能误匹配。`DdlDatabaseReverseEngineers` 用 `ALL_CONSTRAINTS` + `CONSTRAINT_TYPE='P'` 按理更准确，但 Provider 侧未复用此逻辑。

3. **`parseIndexes()` 与 `parsePrimaryKey()` 重复数据**：`BaseDatabaseMetadataProvider.getTableInfo()` 先调 `parsePrimaryKey()` 填充 `ret.primary`，再调 `parseIndexes()` 期望排除主键。但 MySQL/Oracle 的 `parseIndexes()` 覆写中未跳过 `PRIMARY` 索引名，`parseIndexes()` 可能覆盖 `parsePrimaryKey()` 已经设置的值。

4. **`MysqlDdlDatabaseReverseEngineer.CONVERT` 与 INSTANCE 的职责重叠**：`CONVERT` 子类覆写了 `convertColumnType`/`keyword`/`tableName`/`columnName` 全部方法，但 `INSTANCE`（`super`）与 `CONVERT` 都被定义为 `public static final` 暴露给调用方，缺少选择指导的文档说明。

5. **SQLite3 注释通过 DDL 解析的低效实现**：`Sqlite3DatabaseMetadataProvider.getColumnsComment()` 先执行一条无意义 SQL（`where 1!=1`），再通过 `parseSqliteDdl()` 解析整张表的 CREATE TABLE DDL 来提取注释。对于列数多的表，每次获取元数据都要重复解析 DDL。

6. **`DelegateDatabaseMetadataProvider` 空返回值不抛出异常**：当所有 provider 都抛出异常时，部分方法（`detectDefaultDatabase`）返回 `null` 而非抛出包装后的异常，可能导致调用方拿到 `null` 后 NPE，掩盖真实错误。

7. **测试文件随源码发布**：`TestDatabaseMetadata.java`（478 行）位于 `src/main/java` 而非 `src/test/java`，包含了完整的 MySQL/Oracle/PostgreSQL/SQLite3/H2/DM/SQLServer 连接测试代码，携带了 `localhost` 数据库连接密码硬编码风险。