# i2f-bindsql & i2f-bql — SQL 绑定构建与动态查询框架

## 概述

`i2f-bindsql` 是项目的 SQL 绑定构建基础模块，提供参数化 SQL 的链式构建、动态 SQL 片段组装、SQL 格式化与合并等能力。`i2f-bql`
是基于 `i2f-bindsql` 构建的高层动态查询框架，提供 Map 模式、Lambda 模式、Bean 模式三层递进的 SQL 构建抽象，以及 Wrapper
声明式条件构建器体系。

两个模块共同构成项目的 SQL 构建基础设施，支持从底层手动拼 SQL 到高层 Lambda 类型安全查询的全流程需求。

## 模块信息

| 属性             | i2f-bindsql   | i2f-bql              |
|----------------|---------------|----------------------|
| **ArtifactId** | `i2f-bindsql` | `i2f-bql`            |
| **父模块**        | `i2f-jdk`     | `i2f-jdk`            |
| **版本**         | `1.0-jdk8`    | `1.0-jdk8`           |
| **包路径**        | `i2f.bindsql` | `i2f.bql.core.*`     |
| **源文件数**       | 1             | 26                   |
| **定位**         | SQL 绑定构建基础    | 动态查询构建框架             |
| **外部依赖**       | Lombok        | Lombok + 多个 i2f 内部模块 |

## 依赖关系

### i2f-bindsql

```
i2f-bindsql
└── lombok (编译期)
```

### i2f-bql

```
i2f-bql
├── i2f-bindsql              -- SQL 绑定基础
├── i2f-annotations-core     -- 核心注解
├── i2f-annotations-db       -- 数据库注解（@Table, @Column, @Primary）
├── i2f-lambda               -- Lambda 解析
├── i2f-functional           -- 函数式接口
├── i2f-lru-map              -- LRU 缓存（名称解析缓存）
├── i2f-container-builder    -- 容器构建器
├── i2f-reflect              -- 反射工具
├── i2f-text                 -- 文本处理（驼峰转下划线）
├── i2f-database-metadata-bean -- Bean 数据库元数据解析
└── lombok (编译期)
```

---

## i2f-bindsql — SQL 绑定构建基础

### 核心类 BindSql

`BindSql` 是 SQL 绑定构建的核心类，封装了 SQL 文本 + 参数列表，提供链式构建、动态组装、SQL 关键字方法、格式化工具等全套能力。

#### 数据结构

```java
public class BindSql {
    protected Type type = Type.UNSET;  // SQL 类型：UNSET/QUERY/UPDATE/CALL
    protected String sql = "";          // SQL 文本（含 ? 占位符）
    protected List<Object> args = new ArrayList<>();  // 绑定参数列表
}
```

#### 基础构建 API

| 方法                             | 说明               |
|--------------------------------|------------------|
| `BindSql.of()`                 | 创建空实例            |
| `BindSql.of(sql, args...)`     | 创建带 SQL 和参数的实例   |
| `add(sql, args...)`            | 追加 SQL 片段（带空格分隔） |
| `concat(sql, args...)`         | 拼接 SQL 片段（无分隔符）  |
| `val(value)`                   | 添加占位符 `?` 并绑定参数值 |
| `line()` / `space()` / `tab()` | 添加换行/空格/制表符      |

#### 动态 SQL 构建

| 方法                                                           | 说明                                       |
|--------------------------------------------------------------|------------------------------------------|
| `when(predicate, consumer)`                                  | 条件满足时追加 SQL 片段                           |
| `when(value, predicate, consumer)`                           | 值非空/非空字符串/非空集合时追加                        |
| `choose(branches...)`                                        | 多分支选择（类似 MyBatis `<choose>`），首个满足条件的分支生效 |
| `foreach(iterable, consumer, separator, open, close)`        | 遍历集合生成 SQL 片段                            |
| `vars(iterable)`                                             | 快捷生成 `?,?,?` 占位符序列 `(?,...)`             |
| `trim(consumer, trimPrefixes, trimSuffixes, prefix, suffix)` | 智能裁剪前后缀（类似 MyBatis `<trim>`）             |
| `bracket(consumer)`                                          | 自动包裹括号，空内容则不生成                           |

#### SQL 关键字方法

提供完整的 SQL 关键字链式方法，支持自然语义构建：

**查询类：**

- `select()` / `select(consumer)` — SELECT 子句
- `from()` / `from(table, alias)` — FROM 子句
- `where()` / `where(consumer)` — WHERE 子句（自动裁剪 AND/OR 前缀）
- `and()` / `and(consumer)` — AND 条件
- `or()` / `or(consumer)` — OR 条件
- `join()` / `leftJoin()` / `rightJoin()` / `innerJoin()` / `outerJoin()` — JOIN 系列
- `on()` / `on(consumer)` — ON 条件
- `groupBy()` / `orderBy()` / `having()` — 分组/排序/过滤
- `asc()` / `desc()` — 排序方向

**条件类：**

- `eq(value)` / `neq(value)` / `gt(value)` / `lt(value)` / `gte(value)` / `lte(value)` — 比较运算
- `like(value)` / `startsWith(value)` / `endsWith(value)` — 模糊匹配
- `in(iterable)` — IN 查询
- `between(begin, end)` — 范围查询
- `isNull()` / `isNotNull()` — NULL 判断
- `exists(consumer)` / `notExists(consumer)` — EXISTS 子查询

**操作类：**

- `insert()` / `into()` / `values()` — INSERT 语句
- `update()` / `set(consumer)` — UPDATE 语句
- `delete()` — DELETE 语句
- `create()` / `table()` / `view()` / `index()` / `drop()` — DDL 语句
- `with(alias, consumer)` — CTE (Common Table Expression)
- `primaryKey()` / `foreignKey()` / `references()` — 约束

#### SQL 格式化工具

| 方法                                               | 说明                               |
|--------------------------------------------------|----------------------------------|
| `pretty()` / `prettySql(sql)`                    | SQL 美化格式化（关键字换行、括号缩进、逗号换行）       |
| `trimComment()` / `trimCommentSql(sql)`          | 移除 SQL 注释（保留字符串内容）               |
| `toMergeSql()` / `toMergeSql(convertor)`         | 合并 SQL（将 `?` 替换为实际参数值，生成可执行 SQL） |
| `escapeSqlString(str)` / `descapeSqlString(str)` | SQL 字符串转义/反转义                    |

#### 使用示例

```java
BindSql sql = BindSql.of()
        .select(s -> s.add("a.*").add("b.user_name"))
        .from().add("sys_user").add("a")
        .leftJoin().add("sys_role b").on(c -> c.add("a.role_id = b.id"))
        .where(q -> q
                .and(s -> s.add("a.status").eq(1))
                .and(s -> s.add("a.user_name").like("admin"))
                .choose(e -> e
                        .add(() -> roleId != null, s -> s.and(v -> v.add("b.role_id").eq(roleId)))
                        .add(s -> s.and(v -> v.add("a.is_deleted").eq(0)))
                )
        )
        .orderBy(o -> o.add("a.create_time").desc());

// 获取 BindSql（含参数）
BindSql bindSql = sql;

// 合并为可执行 SQL（参数已替换）
String mergedSql = sql.toMergeSql();

// 格式化输出
String prettySql = sql.pretty().getSql();
```

---

## i2f-bql — 动态查询构建框架

### 架构设计

BQL 采用四层继承体系，每层提供不同抽象级别的能力：

```
i2f.bql.core.Bql<H>                    -- 基础层：通用 SQL 构建、方言支持、动态片段
    ↑
i2f.bql.core.map.Bql<H>                -- Map 层：基于 Map 的 CRUD 操作
    ↑
i2f.bql.core.lambda.Bql<H>             -- Lambda 层：Lambda 表达式解析、类型安全列名
    ↑
i2f.bql.core.bean.Bql<H>               -- Bean 层：实体对象驱动的全自动 CRUD
```

**工厂方法约定：**

- `Bql.$_()` — 创建基础 Bql 实例
- `Bql.$map()` — 创建 Map 模式实例
- `Bql.$lambda()` — 创建 Lambda 模式实例
- `Bql.$bean()` — 创建 Bean 模式实例

### 基础层 — i2f.bql.core.Bql

提供通用 SQL 构建能力，支持多方言、多上下文配置。

#### 核心字段

```java
protected LinkedList<BindSql> builder = new LinkedList<>();  // SQL 片段队列
protected String link = "and";           // 默认连接符
protected String separator = " ";        // 片段分隔符
protected String alias = null;           // 当前表别名
protected String placeholder = "?";      // 占位符
protected boolean upperKeywords = false; // 关键字大写
protected Function<String, String> columnNameDecorator;  // 列名装饰器
protected Function<String, String> tableNameDecorator;   // 表名装饰器
```

#### 方言支持

支持 MySQL 和 Oracle 两种方言模式，可全局或线程级设置：

| 方法                                               | 说明                        |
|--------------------------------------------------|---------------------------|
| `globalMysqlMode()`                              | 全局 MySQL 模式（反引号包裹列名/表名）   |
| `globalOracleMode()`                             | 全局 Oracle 模式（双引号包裹，关键字大写） |
| `threadMysqlMode()` / `threadOracleMode()`       | 线程级方言设置                   |
| `dialectGlobalMysql()` / `dialectThreadOracle()` | 实例级方言快捷方法                 |

**MySQL 装饰器：**

```java
MYSQL_COLUMN_NAME_DECORATOR: `column_name`
MYSQL_TABLE_NAME_DECORATOR: `table_name`
```

**Oracle 装饰器：**

```java
ORACLE_COLUMN_NAME_DECORATOR:"COLUMN_NAME"
ORACLE_TABLE_NAME_DECORATOR:"TABLE_NAME"
```

#### 核心构建 API

| 方法                                                                       | 说明                   |
|--------------------------------------------------------------------------|----------------------|
| `$(sql, args...)`                                                        | 追加 SQL 片段            |
| `$(bql)`                                                                 | 追加另一个 Bql 的片段        |
| `$(supplier)`                                                            | 延迟追加（Supplier 模式）    |
| `$$()`                                                                   | 合并所有片段为单个 BindSql    |
| `$if(val, filter, caller)`                                               | 条件追加（类似 `<if>`）      |
| `$trim(val, filter, trimPrefixes, trimSuffixes, prefix, suffix, caller)` | 智能裁剪追加（类似 `<trim>`）  |
| `$for(collection, separator, itemFilter, itemCaller)`                    | 遍历追加（类似 `<foreach>`） |
| `$forUnion(collection, itemFilter, itemCaller)`                          | UNION 遍历             |
| `$forUnionAll(collection, itemFilter, itemCaller)`                       | UNION ALL 遍历         |
| `$each(suppliers...)`                                                    | 依次执行多个 Supplier      |
| `$var(value)`                                                            | 添加占位符和参数             |
| `$format(format, args...)`                                               | 格式化追加                |
| `$concat(args...)`                                                       | 直接拼接                 |

#### SQL 子句方法

| 方法                                                     | 说明                    |
|--------------------------------------------------------|-----------------------|
| `$select(val, filter, caller)`                         | SELECT 子句（自动裁剪逗号）     |
| `$from(table, alias)`                                  | FROM 子句               |
| `$from(subquery, alias)`                               | FROM 子查询              |
| `$where(val, filter, caller)`                          | WHERE 子句（自动裁剪 AND/OR） |
| `$set(val, filter, caller)`                            | SET 子句（自动裁剪逗号）        |
| `$on(val, filter, caller)`                             | ON 子句（自动裁剪 AND/OR）    |
| `$join(table, alias)`                                  | JOIN 子句               |
| `$groupBy(cols, caller)`                               | GROUP BY 子句           |
| `$orderBy(cols, caller)`                               | ORDER BY 子句           |
| `$having(caller)`                                      | HAVING 子句             |
| `$insert()` / `$into(table, cols)` / `$values(caller)` | INSERT 语句             |
| `$update(table)`                                       | UPDATE 语句             |
| `$deleteFrom(table)`                                   | DELETE FROM 语句        |

#### 条件方法

| 方法                                                                              | 说明                      |
|---------------------------------------------------------------------------------|-------------------------|
| `$eq(col, value)`                                                               | `col = ?`               |
| `$neq(col, value)` / `$ne(col, value)`                                          | `col != ?`              |
| `$gt(col, value)` / `$lt(col, value)` / `$gte(col, value)` / `$lte(col, value)` | 比较运算                    |
| `$like(col, value)`                                                             | `col LIKE '%value%'`    |
| `$instr(col, value)`                                                            | `INSTR(col, value) > 0` |
| `$in(col, collection)`                                                          | `col IN (?,...)`        |
| `$notIn(col, collection)`                                                       | `col NOT IN (?,...)`    |
| `$isNull(col)` / `$isNotNull(col)`                                              | IS NULL / IS NOT NULL   |
| `$exists(caller)` / `$notExists(caller)`                                        | EXISTS / NOT EXISTS 子查询 |
| `$and(caller)` / `$or(caller)`                                                  | AND/OR 嵌套条件             |
| `$eqNull(col)`                                                                  | `col = null`（用于 SET 子句） |

### Map 层 — i2f.bql.core.map.Bql

基于 `Map<String, Object>` 的 CRUD 操作层，适合动态字段场景。

#### 核心方法

| 方法                                                                                                     | 说明                                                |
|--------------------------------------------------------------------------------------------------------|---------------------------------------------------|
| `$mapInsert(table, valueMap)`                                                                          | Map 驱动 INSERT                                     |
| `$mapInsertBatchValues(table, valuesList)`                                                             | 批量 INSERT（VALUES 模式）                              |
| `$mapInsertBatchUnionAll(table, valuesList)`                                                           | 批量 INSERT（UNION ALL SELECT 模式）                    |
| `$mapDelete(table, whereMap, isNullCols, isNotNullCols)`                                               | Map 驱动 DELETE                                     |
| `$mapUpdate(table, updateMap, updateNullCols, whereMap, whereIsNullCols, whereIsNotNullCols)`          | Map 驱动 UPDATE                                     |
| `$mapQuery(table, alias, colMap, whereMap, whereIsNullCols, whereIsNotNullCols, groupCols, orderCols)` | Map 驱动 SELECT                                     |
| `$mapSet(updateMap, updateNullCols)`                                                                   | SET 子句构建                                          |
| `$mapWhere(alias, whereMap, isNullCols, isNotNullCols)`                                                | WHERE 子句构建（智能判断值类型：Condition/Collection/Array/单值） |
| `$mapSelect(alias, colMap)`                                                                            | SELECT 列构建                                        |
| `$mapGroupBy(alias, groupCols)`                                                                        | GROUP BY 构建                                       |
| `$mapOrderBy(alias, orderCols)`                                                                        | ORDER BY 构建                                       |

#### 使用示例

```java
// Map 模式查询
Map<String, Object> whereMap = new LinkedHashMap<>();
whereMap.

put("status",1);
whereMap.

put("role_id",Arrays.asList(1, 2,3));

BindSql sql = Bql.$map()
        .$mapQuery("sys_user", "u",
                Collections.singletonMap("user_name", "name"),  // 列映射
                whereMap, null, null, null, null)
        .$$();
```

### Lambda 层 — i2f.bql.core.lambda.Bql

基于 Lambda 表达式的类型安全 SQL 构建层，支持方法引用自动解析为列名。

#### Lambda 解析机制

通过 `LambdaInflater` 解析序列化 Lambda，提取字段信息：

```java
// 方法引用 → 列名
User::getUserName → "user_name"  // 默认下划线转换
User::setUserName → "user_name"
```

#### 名称解析器

**IFieldColumnNameResolver — 字段→列名解析：**

| 实现                                          | 说明                         |
|---------------------------------------------|----------------------------|
| `DefaultFieldColumnNameResolver.DEFAULT`    | 优先读取 `@Column` 注解，否则驼峰转下划线 |
| `DefaultFieldColumnNameResolver.ANNOTATION` | 仅读取注解，无注解则用字段名             |
| `DefaultFieldColumnNameResolver.UNDERSCORE` | 强制驼峰转下划线                   |
| `CachedFieldColumnNameResolver`             | 带 LRU 缓存的装饰器（容量 8192）      |

**IClassTableNameResolver — 类→表名解析：**

| 实现                                         | 说明                        |
|--------------------------------------------|---------------------------|
| `DefaultClassTableNameResolver.DEFAULT`    | 优先读取 `@Table` 注解，否则驼峰转下划线 |
| `DefaultClassTableNameResolver.ANNOTATION` | 仅读取注解，无注解则用类名             |
| `DefaultClassTableNameResolver.UNDERSCORE` | 强制驼峰转下划线                  |
| `CachedClassTableNameResolver`             | 带 LRU 缓存的装饰器（容量 8192）     |

#### Lambda 核心方法

| 方法                                                                                                                                       | 说明                        |
|------------------------------------------------------------------------------------------------------------------------------------------|---------------------------|
| `$(IGetter)` / `$(ISetter)` / `$(IBuilder)` / `$(IExecute)`                                                                              | Lambda 方法引用 → 列名          |
| `$(Class<?>)`                                                                                                                            | 类 → 表名                    |
| `$lm(lambda)`                                                                                                                            | 将 Lambda 转为 `IFunctional` |
| `lm2names(collection)`                                                                                                                   | 批量 Lambda → 列名列表          |
| `lm2names(map)`                                                                                                                          | 批量 Lambda Map → 列名 Map    |
| `$lambdaInsert(table, valueMapConsumer)`                                                                                                 | Lambda INSERT             |
| `$lambdaDelete(table, whereMapConsumer, whereIsNullColsConsumer, whereIsNotNullColsConsumer)`                                            | Lambda DELETE             |
| `$lambdaUpdate(table, updateMapConsumer, updateNullColsConsumer, whereMapConsumer, whereIsNullColsConsumer, whereIsNotNullColsConsumer)` | Lambda UPDATE             |
| `$lambdaQuery(table, alias, colMap, whereMap, whereIsNullCols, whereIsNotNullCols, groupCols, orderCols)`                                | Lambda SELECT             |

#### 使用示例

```java
// Lambda 模式查询
BindSql sql = Bql.$lambda()
        .$lambdaQuery(User.class, "u",
                // 选择列
                Bql.$colMapLambda()
                        .put(User::getUserName, "name")
                        .put(User::getEmail, null),
                // WHERE 条件
                Bql.$valueMapLambda()
                        .put(User::getStatus, 1)
                        .put(User::getRoleId, Arrays.asList(1, 2, 3)),
                // IS NULL 列
                null,
                // IS NOT NULL 列
                null,
                // GROUP BY
                null,
                // ORDER BY
                Bql.$colListLambda().add(User::getCreateTime))
        .$$();
```

### Bean 层 — i2f.bql.core.bean.Bql

基于实体对象的全自动 CRUD 层，通过反射自动提取字段值和注解信息。

#### 核心方法

| 方法                                                                                                       | 说明                                       |
|----------------------------------------------------------------------------------------------------------|------------------------------------------|
| `$beanInsert(bean)`                                                                                      | 实体 INSERT（自动提取非空字段）                      |
| `$beanInsertBatchValues(list)`                                                                           | 批量 INSERT（VALUES 模式）                     |
| `$beanInsertBatchUnionAll(list)`                                                                         | 批量 INSERT（UNION ALL SELECT 模式）           |
| `$beanDelete(bean, whereIsNullCols, whereIsNotNullCols)`                                                 | 实体 DELETE（非空字段作为 WHERE 条件）               |
| `$beanDeleteByPk(beanClass, pkValue...)`                                                                 | 主键 DELETE（需 `@Primary` 注解）               |
| `$beanUpdate(update, cond, updateNullCols, whereIsNullCols, whereIsNotNullCols)`                         | 实体 UPDATE（update 对象为 SET，cond 对象为 WHERE） |
| `$beanUpdateByPk(update, updateNullCols)`                                                                | 主键 UPDATE（需 `@Primary` 注解）               |
| `$beanQuery(bean, alias, selectCols, selectExcludeCols, whereIsNullCols, whereIsNotNullCols, orderCols)` | 实体 SELECT（非空字段为 WHERE，支持 Lambda 指定列）     |
| `$beanQueryByPk(beanClass, alias, selectCols, selectExcludeCols, orderCols, pkValue...)`                 | 主键 SELECT                                |

#### 注解支持

Bean 层依赖 `i2f-annotations-db` 的注解：

| 注解                       | 目标 | 说明               |
|--------------------------|----|------------------|
| `@Table("table_name")`   | 类  | 指定表名，无注解则类名转下划线  |
| `@Column("column_name")` | 字段 | 指定列名，无注解则字段名转下划线 |
| `@Primary`               | 字段 | 标记主键字段           |

#### 使用示例

```java
// Bean 模式查询
User queryBean = new User();
queryBean.

setStatus(1);
queryBean.

setRoleId(100);

BindSql sql = Bql.$bean()
        .$beanQuery(queryBean, "u",
                Arrays.asList(User::getUserName, User::getEmail),  // 选择列
                null,  // 排除列
                null,  // IS NULL 列
                null,  // IS NOT NULL 列
                Arrays.asList(User::getCreateTime))  // 排序列
        .$$();

// Bean 主键查询
BindSql sql = Bql.$bean()
        .$beanQueryByPk(User.class, "u", null, null, null, 1001L)
        .$$();

// Bean 插入
User user = new User();
user.

setUserName("admin");
user.

setEmail("admin@example.com");
user.

setStatus(1);

BindSql sql = Bql.$bean()
        .$beanInsert(user)
        .$$();

// Bean 主键更新
User update = new User();
update.

setUserId(1001L);
update.

setUserName("new_name");

BindSql sql = Bql.$bean()
        .$beanUpdateByPk(update)
        .$$();
```

### Wrapper 体系 — 声明式条件构建器

Wrapper 提供了更高层次的声明式 API，将 SQL 构建过程封装为可组合的对象。

#### 继承体系

```
BqlWrapper (interface)           -- 基础接口：BindSql bindSql() / Bql<?> get()
    ↑
ConditionWrapper<H>              -- 条件构建器：条件列表 + AND/OR 连接
    ├── QueryWrapper<H>          -- 查询构建器：表 + 列 + 条件 + GROUP BY + ORDER BY
    ├── UpdateWrapper<H>         -- 更新构建器：表 + SET 值 + 条件
    └── DeleteWrapper<H>         -- 删除构建器：表 + 条件

InsertWrapper<H>                 -- 插入构建器：表 + INSERT 值（独立实现）
```

#### BqlWrapper 接口

```java
public interface BqlWrapper extends Supplier<Bql<?>> {
    default BindSql bindSql() {
        return get().$$();  // 合并为 BindSql
    }
}
```

#### ConditionWrapper — 条件构建器

核心方法 `cond()` 支持多种重载，接受 Lambda、字符串、IFunctional 等作为列标识：

```java
ConditionWrapper<?> wrapper = new ConditionWrapper<>()
        .and().cond(User::getStatus, 1)
        .and().cond(User::getRoleId, Condition.$in(1, 2, 3))
        .or().cond(User::getUserName, Condition.$like("admin"));
```

**条件工厂方法（Condition 类）：**

| 方法                                                                    | 说明                                          |
|-----------------------------------------------------------------------|---------------------------------------------|
| `Condition.def(value)`                                                | 智能判断：null→IS NULL，Collection/Array→IN，其他→EQ |
| `Condition.$eq(value)`                                                | 等于                                          |
| `Condition.$neq(value)` / `$ne(value)`                                | 不等于                                         |
| `Condition.$like(value)`                                              | 模糊匹配                                        |
| `Condition.$lt(value)` / `$lte(value)` / `$gt(value)` / `$gte(value)` | 比较                                          |
| `Condition.$isNull()` / `$isNotNull()`                                | NULL 判断                                     |
| `Condition.$in(values...)` / `$in(collection)`                        | IN 查询                                       |
| `Condition.$notIn(values...)` / `$notIn(collection)`                  | NOT IN 查询                                   |
| `Condition.$exists(caller)` / `$notExists(caller)`                    | EXISTS 子查询                                  |
| `Condition.$and(caller)` / `$or(caller)`                              | 嵌套条件                                        |

**ConditionItem — 条件项：**

```java
public class ConditionItem {
    protected boolean and = true;        // AND 或 OR
    protected String alias;              // 表别名
    protected Serializable column;       // 列（Lambda/字符串）
    protected Condition value;           // 条件
}
```

#### QueryWrapper — 查询构建器

```java
QueryWrapper<?> wrapper = QueryWrapper.select()
        .from(User.class)
        .alias("u")
        .col(User::getUserName, "name")
        .col(User::getEmail, null)
        .and().cond(User::getStatus, 1)
        .and().cond(User::getRoleId, Condition.$in(1, 2, 3))
        .groupBy(User::getStatus)
        .orderBy(User::getCreateTime);

BindSql sql = wrapper.bindSql();
```

#### UpdateWrapper — 更新构建器

```java
UpdateWrapper<?> wrapper = UpdateWrapper.update()
        .table(User.class)
        .set(User::getUserName, "new_name")
        .set(User::getEmail, "new@example.com")
        .setNull(User::getPhone)
        .and().cond(User::getUserId, 1001L);

BindSql sql = wrapper.bindSql();
```

#### DeleteWrapper — 删除构建器

```java
DeleteWrapper<?> wrapper = DeleteWrapper.from()
        .table(User.class)
        .and().cond(User::getUserId, 1001L);

BindSql sql = wrapper.bindSql();
```

#### InsertWrapper — 插入构建器

```java
InsertWrapper<?> wrapper = InsertWrapper.into()
        .table(User.class)
        .set(User::getUserName, "admin")
        .set(User::getEmail, "admin@example.com")
        .set(User::getStatus, 1);

BindSql sql = wrapper.bindSql();
```

### 名称解析配置

BQL 提供了灵活的全局/线程级名称解析配置：

```java
// 全局设置 Lambda 名称解析器
Bql.GLOBAL_FIELD_NAME_RESOLVER =DefaultFieldColumnNameResolver.UNDERSCORE;
Bql.GLOBAL_CLASS_NAME_RESOLVER =DefaultClassTableNameResolver.UNDERSCORE;

// 线程级设置（优先级更高）
Bql.fieldNameResolverHolder.

set(customResolver);
Bql.tableNameResolverHolder.

set(customResolver);

// 恢复默认
Bql.fieldNameResolverHolder.

remove();
Bql.tableNameResolverHolder.

remove();
```

---

## 源文件清单

### i2f-bindsql（1 文件）

| 文件             | 行数  | 说明          |
|----------------|-----|-------------|
| `BindSql.java` | 967 | SQL 绑定构建核心类 |

### i2f-bql（26 文件）

#### core 包 — 基础层

| 文件         | 行数   | 说明                            |
|------------|------|-------------------------------|
| `Bql.java` | 2162 | 基础 BQL 构建器（通用 SQL 构建、方言、动态片段） |

#### core/condition 包 — 条件体系

| 文件                   | 行数  | 说明                                       |
|----------------------|-----|------------------------------------------|
| `Condition.java`     | 126 | 条件函数式接口（工厂方法：eq/like/in/isNull/exists 等） |
| `ConditionItem.java` | 26  | 条件项（AND/OR + 别名 + 列 + 条件）                |

#### core/map 包 — Map 层

| 文件         | 行数  | 说明                       |
|------------|-----|--------------------------|
| `Bql.java` | 379 | Map 模式 BQL（Map 驱动的 CRUD） |

#### core/lambda 包 — Lambda 层

| 文件                                                | 行数   | 说明                                |
|---------------------------------------------------|------|-----------------------------------|
| `Bql.java`                                        | 1706 | Lambda 模式 BQL（类型安全列名、Lambda CRUD） |
| `builder/AbsMapBuilder.java`                      | 81   | 抽象 Map 构建器                        |
| `builder/AliasMapBuilder.java`                    | 28   | 别名 Map 构建器                        |
| `builder/ValueListBuilder.java`                   | 91   | 值列表构建器                            |
| `builder/ValueMapBuilder.java`                    | 28   | 值 Map 构建器                         |
| `lambda/IClassTableNameResolver.java`             | 10   | 类→表名解析接口                          |
| `lambda/IFieldColumnNameResolver.java`            | 13   | 字段→列名解析接口                         |
| `lambda/impl/CachedClassTableNameResolver.java`   | 43   | 带 LRU 缓存的类名解析器                    |
| `lambda/impl/CachedFieldColumnNameResolver.java`  | 44   | 带 LRU 缓存的字段名解析器                   |
| `lambda/impl/DefaultClassTableNameResolver.java`  | 61   | 默认类名解析器（@Table 注解 + 下划线转换）        |
| `lambda/impl/DefaultFieldColumnNameResolver.java` | 61   | 默认字段名解析器（@Column 注解 + 下划线转换）      |

#### core/bean 包 — Bean 层

| 文件         | 行数  | 说明                         |
|------------|-----|----------------------------|
| `Bql.java` | 556 | Bean 模式 BQL（实体驱动的全自动 CRUD） |

#### core/wrapper 包 — Wrapper 体系

| 文件                      | 行数  | 说明                                                 |
|-------------------------|-----|----------------------------------------------------|
| `BqlWrapper.java`       | 16  | Wrapper 基础接口                                       |
| `ConditionWrapper.java` | 455 | 条件构建器（条件列表 + AND/OR）                               |
| `QueryWrapper.java`     | 180 | 查询构建器（SELECT + FROM + WHERE + GROUP BY + ORDER BY） |
| `UpdateWrapper.java`    | 111 | 更新构建器（UPDATE + SET + WHERE）                        |
| `DeleteWrapper.java`    | 39  | 删除构建器（DELETE FROM + WHERE）                         |
| `InsertWrapper.java`    | 80  | 插入构建器（INSERT INTO + VALUES）                        |

#### test 包 — 测试示例

| 文件                | 行数  | 说明                          |
|-------------------|-----|-----------------------------|
| `SysDict.java`    | 45  | 字典实体示例                      |
| `SysRole.java`    | 27  | 角色实体示例                      |
| `SysUser.java`    | 174 | 用户实体示例（含完整字段和注解）            |
| `TestLambda.java` | 849 | Lambda 模式测试用例（覆盖全部 CRUD 场景） |

---

## i2f-bindsql-page — SQL 分页与计数构建模块

### 模块信息

| 属性             | 值                                                      |
|----------------|--------------------------------------------------------|
| **ArtifactId** | `i2f-bindsql-page`                                     |
| **父模块**        | `i2f-jdk`                                              |
| **版本**         | `1.0-jdk8`                                             |
| **包路径**        | `i2f.bindsql.*`                                        |
| **源文件数**       | 18                                                     |
| **依赖**         | `i2f-bindsql`, `i2f-page`, `i2f-database-type`, Lombok |

### 概述

`i2f-bindsql-page` 构建在 `i2f-bindsql` 之上，提供数据库方言感知的 SQL 分页改写与计数 SQL
生成能力。核心功能是将任意 `BindSql` 查询 + 分页参数（`ApiOffsetSize`）自动改写为对应数据库方言的分页 SQL，同时生成配套的计数
SQL。

### 核心架构

#### 入口类 — BindSqlWrappers

统一入口，提供 3 种调用方式（按 `Connection` / `jdbcUrl` / `DatabaseType`），一次性生成分页 SQL 和计数
SQL，返回 `PageBindSql` 结果。

```java
public class BindSqlWrappers {
    // 按 Connection 自动识别方言
    static PageBindSql page(Connection conn, BindSql sql, ApiOffsetSize page);

    // 按 JDBC URL 识别方言
    static PageBindSql page(String jdbcUrl, BindSql sql, ApiOffsetSize page);

    // 按 DatabaseType 指定方言
    static PageBindSql page(DatabaseType type, BindSql sql, ApiOffsetSize page);
}
```

#### 数据模型 — PageBindSql

```java

@Data
public class PageBindSql {
    private BindSql countSql;      // 计数 SQL
    private BindSql pageSql;       // 分页 SQL
    private ApiOffsetSize page;    // 分页参数
}
```

#### 分页包装器 — IPageWrapper

函数式接口，将原始 SQL 改写为方言分页 SQL。支持两种模式：

- **embed=true**: 直接将参数值嵌入 SQL 文本
- **embed=false**: 使用 `?` 占位符，参数追加到 `BindSql.args`

```java

@FunctionalInterface
public interface IPageWrapper {
    BindSql apply(BindSql bql, ApiOffsetSize page, boolean embed);
}
```

#### 分页提供者 — IPageWrapperProvider

SPI 扩展接口，通过 `ServiceLoader` 加载自定义分页实现，优先级高于内置实现。

```java
public interface IPageWrapperProvider {
    boolean support(DatabaseType databaseType);

    IPageWrapper getPageWrapper();
}
```

#### 计数包装器 — ICountWrapper

将原始 SQL 包装为 `SELECT count(1) cnt FROM (原始SQL) tmp_cnt`。

```java
public interface ICountWrapper extends Function<BindSql, BindSql> {
}
```

### 方言路由 — PageWrappers

`PageWrappers` 是方言路由核心，维护了完整的方言重定向映射表：

| 源方言                                                                                                   | 重定向至       |
|-------------------------------------------------------------------------------------------------------|------------|
| MariaDB / GBase / XuGu / ClickHouse / OceanBase / Hive / TDengine / HerdDB                            | MySQL      |
| Oscar / HighGo / Gauss / YaShanDB / Snowflake / Databricks / RedShift / Trino / Phoenix / KingBase_ES | PostgreSQL |
| DM（达梦）                                                                                                | Oracle     |
| H2 / SQLite / HSQL                                                                                    | PostgreSQL |
| Oracle_12C / Firebird                                                                                 | SQL Server |

路由优先级：ThreadLocal 覆盖 > SPI Provider > 内置方言映射 > 内置实现

### 内置分页实现一览（9 种）

| # | 实现类                     | 目标方言       | 分页语法                                    |
|---|-------------------------|------------|-----------------------------------------|
| 1 | `MysqlPageWrapper`      | MySQL      | `LIMIT offset, size`                    |
| 2 | `PostgreSqlPageWrapper` | PostgreSQL | `LIMIT size OFFSET offset`              |
| 3 | `OraclePageWrapper`     | Oracle     | `ROWNUM` 三层嵌套子查询                        |
| 4 | `SqlServerPageWrapper`  | SQL Server | `OFFSET x ROWS FETCH NEXT y ROWS ONLY`  |
| 5 | `Db2PageWrapper`        | DB2        | `ROWNUMBER() OVER()` 嵌套子查询              |
| 6 | `CirroDataPageWrapper`  | CirroData  | `LIMIT (offset, end)` 括号语法              |
| 7 | `IbmAs400PageWrapper`   | IBM AS/400 | `OFFSET x ROWS FETCH FIRST y ROWS ONLY` |
| 8 | `InformixPageWrapper`   | Informix   | `SELECT SKIP x FIRST y * FROM (SQL)`    |
| 9 | `FirebirdPageWrapper`   | Firebird   | `ROWS x TO y`                           |

所有实现均为单例（`INSTANCE`），线程安全。

### 计数实现

默认使用 `SqlCountWrapper`（通用 SQL 标准），包装为 `SELECT count(1) cnt FROM (原始SQL) tmp_cnt`，对所有数据库方言通用。

### 源文件清单

| 文件                           | 行数  | 说明                         |
|------------------------------|-----|----------------------------|
| `BindSqlWrappers.java`       | 59  | 统一入口（3 种调用方式）              |
| **page 包**                   |     |                            |
| `IPageWrapper.java`          | 38  | 分页包装器接口（函数式）               |
| `IPageWrapperProvider.java`  | 15  | SPI 扩展接口                   |
| `PageWrappers.java`          | 116 | 方言路由 + 方言映射表               |
| **page/impl 包**              |     |                            |
| `MysqlPageWrapper.java`      | 62  | MySQL 分页                   |
| `PostgreSqlPageWrapper.java` | 60  | PostgreSQL 分页              |
| `OraclePageWrapper.java`     | 68  | Oracle ROWNUM 分页           |
| `SqlServerPageWrapper.java`  | 64  | SQL Server OFFSET/FETCH 分页 |
| `Db2PageWrapper.java`        | 70  | DB2 ROWNUMBER 分页           |
| `CirroDataPageWrapper.java`  | 64  | CirroData LIMIT 括号分页       |
| `IbmAs400PageWrapper.java`   | 64  | IBM AS/400 FETCH FIRST 分页  |
| `InformixPageWrapper.java`   | 69  | Informix SKIP/FIRST 分页     |
| `FirebirdPageWrapper.java`   | 64  | Firebird ROWS TO 分页        |
| **count 包**                  |     |                            |
| `ICountWrapper.java`         | 15  | 计数包装器接口                    |
| `ICountWrapperProvider.java` | 15  | 计数 SPI 扩展接口                |
| `CountWrappers.java`         | 64  | 计数方言路由                     |
| **count/impl 包**             |     |                            |
| `SqlCountWrapper.java`       | 32  | 通用计数实现                     |
| **data 包**                   |     |                            |
| `PageBindSql.java`           | 19  | 分页结果数据模型                   |

---

## 设计特点

1. **四层递进抽象**：基础 → Map → Lambda → Bean，从手动到全自动，满足不同场景需求
2. **类型安全 Lambda**：通过序列化 Lambda 解析字段信息，编译期检查列名，避免硬编码字符串
3. **智能名称解析**：支持 `@Table`/`@Column` 注解、驼峰转下划线、自定义解析器，带 LRU 缓存
4. **多方言支持**：MySQL（反引号）、Oracle（双引号+大写关键字），全局/线程级配置
5. **动态 SQL 构建**：`$if`/`$trim`/`$for`/`$choose` 等动态片段，类似 MyBatis XML 标签
6. **Wrapper 声明式 API**：高层封装简化常见 CRUD 操作，条件可组合、可复用
7. **BindSql 基础**：所有高层构建最终落地为 `BindSql`（SQL 文本 + 参数列表），可直接执行或继续组合
8. **零外部依赖**：`i2f-bindsql` 仅依赖 Lombok，`i2f-bql` 依赖项目内部模块，无第三方库
