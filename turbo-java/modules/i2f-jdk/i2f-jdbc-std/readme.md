# i2f-jdbc-std — JDBC 标准契约层

> **JDBC 体系的最小契约层 / 依赖倒置地基**（3 源文件、50 行、2 包、零测试）：全模块只有三个接口——`JdbcInvokeContextProvider<T>`（连接获取的上下文抽象：`beginContext` → `getConnection` → `endContext` 生命周期 + 两个 `Object` 桥接方法）、`SQLFunction<T,R>` / `SQLBiFunction<T,U,R>`（SQL 感知函数式接口，唯一差别是 `throws SQLException`）。零执行逻辑、零三方运行期依赖；其中 `i2f-jdbc-data` 声明后自身并不消费，而是作为**传递通道**让下游 `i2f-jdbc-impl` 经由本模块获得 data 包。被 4 个模块（9 文件、14 处 import）消费，是 `JdbcTemplate`/`JdbcResolver`/`BqlTemplate`/`JdbcCursorImpl`/`JdbcProxy`/Spring Boot Starter 的共同依赖点。

## 一、模块定位

本模块回答两个贯穿整个 JDBC 家族的问题：

1. **「连接从哪来、何时归还」**——由 `JdbcInvokeContextProvider<T>` 抽象。调用方（`JdbcTemplate`、`ProxyRenderSqlHandler`）只依赖此接口，不关心背后是裸 `Connection`（直连）还是来自 Spring 托管 `DataSource`（事务感知），实现完整的依赖倒置。
2. **「如何在 lambda 里透明地抛 SQL 异常」**——由 `SQLFunction`/`SQLBiFunction` 抽象。JDK 的 `Function`/`BiFunction` 不允许受检异常，JDBC 操作链会充满 try/catch；这两个接口声明 `throws SQLException` 后，`transaction`/`queryHandler`/游标装配等 API 可以直接接收 `JdbcResolver::xxx` 方法引用与纯 lambda。

```
        i2f-jdbc-impl（JdbcTemplate / JdbcResolver / JdbcCursorImpl）
        i2f-jdbc-bql（BqlTemplate）
        i2f-jdbc-proxy（ProxySqlExecuteGenerator / ProxyRenderSqlHandler）
        i2f-springboot-jdbc-bql-starter（SpringDatasourceJdbcInvokeContextProvider ...）
             │ 依赖（倒置）
             ▼
  ┌──────────────────────── i2f-jdbc-std ────────────────────────┐
  │  context.JdbcInvokeContextProvider<T>   ← 上下文/连接生命周期契约  │
  │  func.SQLFunction / func.SQLBiFunction  ← SQL 感知函数式接口     │
  │  （无实现、无执行逻辑、仅 java.sql 基础类型）                        │
  └──────────────────────────────────────────────────────────────┘
```

## 二、源码结构

| 包 | 文件（行数） | 类型 | 职责 |
|----|------------|------|------|
| `i2f.jdbc.std.context` | `JdbcInvokeContextProvider`（25） | 接口（泛型） | 上下文开启/取连接/结束三阶段 + 2 个 Object 桥接方法 |
| `i2f.jdbc.std.func` | `SQLFunction`（14） | `@FunctionalInterface` | `R apply(T t) throws SQLException` |
| `i2f.jdbc.std.func` | `SQLBiFunction`（14） | `@FunctionalInterface` | `R apply(T t, U u) throws SQLException` |

合计 3 文件 50 行（.NET `ReadAllLines` 口径）。全部为接口，**无实现类、无工具类、无测试**。

## 三、核心契约详解

### 3.1 JdbcInvokeContextProvider——上下文生命周期契约

```java
public interface JdbcInvokeContextProvider<T> {
    T beginContext();                                   // ① 开启上下文，返回上下文载体
    Connection getConnection(T context);                // ② 从上下文载体取得连接
    default Connection getConnectionInner(Object context) {
        return getConnection((T) context);              // ②' 桥接：Object → 泛型（未检查转型）
    }
    void endContext(T context, Connection conn);        // ③ 结束上下文，归还/释放连接
    default void endContextInner(Object context, Connection conn) {
        endContext((T) context, conn);                  // ③' 桥接：Object → 泛型（未检查转型）
    }
}
```

设计要点：

- **`T` 是「上下文载体」而非连接本身**。实现方自由决定它是什么：直连场景就是 `Connection`；Spring 场景是 `DataSource`（真正的连接由 `DataSourceUtils` 按需获取）；自定义场景可以是线程绑定的会话对象。接口本身不约束——这赋予了实现极大的自由度。
- **`beginContext()` 无参**：上下文来源在实现类构造器注入（`DirectJdbcInvokeContextProvider(conn)` / `SpringDatasourceJdbcInvokeContextProvider(dataSource)`）。
- **`endContext(context, conn)` 双参**：`conn` 是要归还的连接，`context` 供实现识别资源来源——Spring 的 `DataSourceUtils.releaseConnection(conn, dataSource)` 正需要两者同时在场。
- **两个 `Inner` 桥接方法的存在意义**：`JdbcTemplate` 等持有方字段类型是 `JdbcInvokeContextProvider<?>`（通配符），其 `context` 局部变量为 `Object` 类型——泛型捕获（capture conversion）使 `getConnection(t)` 无法直接编译，故提供 `Object` 签名的 default 桥接在接口内部完成转型。

### 3.2 两个实现类对照（均在外部模块）

| 维度 | `DirectJdbcInvokeContextProvider`（i2f-jdbc-impl） | `SpringDatasourceJdbcInvokeContextProvider`（springboot starter） |
|------|--------------------------------------------------|---------------------------------------------------------------|
| `T` | `Connection` | `DataSource` |
| `beginContext()` | 返回构造器注入的已持有连接 | 返回 `dataSource` 本身 |
| `getConnection(ctx)` | 原样返回 `context`（纯透传） | `DataSourceUtils.getConnection(context)`——**事务感知**：加入当前事务或新建 |
| `endContext(ctx, conn)` | **空实现**（连接生命周期由调用方管理，此处刻意不关闭） | `DataSourceUtils.releaseConnection(conn, context)`——事务未完成时仅打标记不真正释放 |
| 事务语义 | 无（调用方自行 begin/commit） | 完整的 Spring 事务传播/挂起语义 |
| 典型场景 | 已持有连接的直接调用 | Spring Boot 环境中注入 `DataSource` |

### 3.3 标准消费模式——contextActionDelegate 四段式

`i2f-jdbc-impl/JdbcTemplate` 定义了本接口的标准用法（所有查询/更新/批处理都经由此模板）：

```java
protected <T, R> R contextActionDelegate(T bql, SQLBiFunction<Connection, T, R> action) throws SQLException {
    Object context = contextProvider.beginContext();          // ① 开启
    Connection conn = contextProvider.getConnectionInner(context); // ② 取连接
    try {
        R ret = action.apply(conn, bql);                      // ③ 执行业务（SQLBiFunction）
        return ret;
    } catch (Throwable e) {
        if (e instanceof RuntimeException) { throw e; }
        if (e instanceof SQLException) { throw e; }
        throw new IllegalStateException(e.getMessage(), e);   // 其余包装
    } finally {
        contextProvider.endContextInner(context, conn);       // ④ 保证归还
    }
}
```

`i2f-jdbc-proxy/handler/ProxyRenderSqlHandler`（L92 / L212）采用完全相同的四段式。

### 3.4 SQLFunction / SQLBiFunction——SQL 感知函数式接口

```java
@FunctionalInterface
public interface SQLFunction<T, R>    { R apply(T t) throws SQLException; }
@FunctionalInterface
public interface SQLBiFunction<T, U, R> { R apply(T t, U u) throws SQLException; }
```

与 JDK `java.util.function.Function`/`BiFunction` 的唯一差别是 `throws SQLException`。这使 JDBC 层 API 摆脱了函数体内的 try/catch 噪音：

- `JdbcResolver.transaction(Connection, SQLBiFunction<Connection,E,R>, E)`——事务模板接收业务操作 lambda；
- `JdbcResolver.query(Connection, BindSql, SQLFunction<ResultSet,R>)`——结果集处理 lambda；
- 游标装配常量：`DEFAULT_CURSOR_STATEMENT_BUILDER = JdbcResolver::buildCursorStatement`（`SQLBiFunction<Connection,String,PreparedStatement>`）、`DEFAULT_CURSOR_CONTEXT_INITIALIZER = JdbcResolver::parseResultSetColumns`（`SQLFunction<ResultSet,List<QueryColumn>>`）、`DEFAULT_CURSOR_ROW_CONVERTOR`（`SQLBiFunction<List<QueryColumn>,ResultSet,Map<String,Object>>`）；
- `JdbcCursorImpl` 的 `contextInitializer`/`rowConvertor` 字段、`BqlTemplate.queryHandler` 参数。

**取舍注记**：声明了受检异常的接口无法与 JDK `Function`/`BiFunction` 互转（方法引用不兼容），会牺牲组合性——这是「SQL 异常透明化」换来的代价，属于有意的设计权衡。

## 四、使用示例

### 示例 1：已持有连接的最小用法

```java
try (Connection conn = DriverManager.getConnection(url, user, pass)) {
    JdbcTemplate template = new JdbcTemplate(new DirectJdbcInvokeContextProvider(conn));
    List<User> users = template.queryList("select * from user where age > ?", 18, User.class);
}
```

### 示例 2：自定义上下文提供者（线程绑定的连接复用）

```java
public class ThreadLocalContextProvider implements JdbcInvokeContextProvider<Connection> {
    private final ThreadLocal<Connection> holder = new ThreadLocal<>();

    @Override
    public Connection beginContext() {
        Connection conn = holder.get();
        if (conn == null) {                 // 首次进入本线程：建立并绑定
            conn = openConnection();
            holder.set(conn);
        }
        return conn;
    }

    @Override
    public Connection getConnection(Connection context) {
        return context;
    }

    @Override
    public void endContext(Connection context, Connection conn) {
        // 不在单次调用结束时关闭，由外层事务统一收口
    }

    public void closeAll() throws SQLException {
        Connection conn = holder.get();
        if (conn != null) { conn.close(); holder.remove(); }
    }
}
```

### 示例 3：SQLFunction/SQLBiFunction 作为 lambda 目标类型

```java
// 事务模板：业务 lambda 直接书写 JDBC 操作
Integer affected = JdbcResolver.transaction(conn, (c, sql) -> {
    try (PreparedStatement stat = c.prepareStatement(sql)) {
        return stat.executeUpdate();
    }
}, "update account set balance = balance - 100 where id = 1");

// 结果集自定义处理
String name = JdbcResolver.query(conn, "select name from user where id = 1",
        rs -> rs.next() ? rs.getString(1) : null);
```

## 五、消费关系

### 5.1 代码级消费者（4 模块 9 文件、14 处 import）

| 模块 | 文件 | 用到的契约 |
|------|------|-----------|
| `i2f-jdbc-impl` | `JdbcResolver` | `SQLFunction`/`SQLBiFunction`（transaction/query/游标常量） |
| | `JdbcTemplate` | 三者全用（字段持有 + `contextActionDelegate` 桥接调用） |
| | `JdbcCursorImpl` | `SQLFunction`/`SQLBiFunction`（游标装配字段） |
| | `DirectJdbcInvokeContextProvider` | 实现 `JdbcInvokeContextProvider<Connection>` |
| `i2f-jdbc-bql` | `BqlTemplate` | `JdbcInvokeContextProvider`（构造器）+ `SQLFunction`（queryHandler） |
| `i2f-jdbc-proxy` | `ProxySqlExecuteGenerator` | `JdbcInvokeContextProvider`（proxy 工厂参数） |
| | `ProxyRenderSqlHandler` | `JdbcInvokeContextProvider`（字段 + 桥接调用 L92/L212） |
| `i2f-springboot-jdbc-bql-starter` | `SpringDatasourceJdbcInvokeContextProvider` | 实现 `JdbcInvokeContextProvider<DataSource>` |
| | `SpringJdbcProxyMapperFactoryBean` | `JdbcInvokeContextProvider`（装配） |

### 5.2 POM 声明与传递链

全仓仅 **1 处显式声明**（`i2f-jdbc-impl/pom.xml` L22）；其余 3 个消费者模块**均未声明**，全部经 `i2f-jdbc-impl` 传递获得：

```
i2f-jdbc-std ──声明──▶ i2f-jdbc-impl ──传递──▶ i2f-jdbc-bql ──▶ i2f-springboot-jdbc-bql-starter
                           │                        （未声明，经传递）
                           ├──传递──▶ i2f-jdbc-proxy（未声明，经传递）
                           └──传递──▶ i2f-jdbc-proxy-xml、i2f-springboot-jdbc-bql-starter 等
```

### 5.3 POM 注册（3 处）

| 位置 | 行号 | 用途 |
|------|------|------|
| `i2f-jdk/pom.xml` | L101 | 模块聚合（i2f-jdbc-proxy-xml 之后、i2f-jdk-all 之前） |
| `i2f-jdk-all/pom.xml` | L353 | 全仓聚合 fat-jar 引入 |
| 根 `pom.xml` | L541 | `dependencyManagement` 版本管理 |

### 5.4 依赖真实性

| 依赖 | POM 声明 | 源码使用 | 结论 |
|------|---------|---------|------|
| `i2f-jdbc-data` | 有（L22） | **零**（3 文件无 `i2f.jdbc.data` import） | **传递通道**：声明意图即让下游经本模块获得 data 包（下游 `i2f-jdbc-impl` 只声明本模块即可用 `TypedArgument`/`QueryResult` 等） |
| `lombok` | 有（L16） | **零**（3 个纯接口无任何 lombok 注解） | **声明未用**（冗余） |

## 六、缺陷与注记

按源码逐行审读，本模块为纯契约层，无执行逻辑，缺陷面小，均为低危/设计注记：

| 级别 | 位置 | 问题 | 说明 |
|------|------|------|------|
| 低危 | `JdbcInvokeContextProvider` L15/L21 | 桥接方法 `(T) context` 为未检查转型且未加 `@SuppressWarnings("unchecked")` | 擦除后转型实际无校验；类型误配的 `ClassCastException` 会延后到实现类的编译器生成 bridge 方法内抛出，堆栈上不直观 |
| 低危 | `JdbcInvokeContextProvider` L15/L21 | `getConnectionInner`/`endContextInner` 为 `public default` | 本意是给持有 `<?>` 通配符的框架内部调用的桥接方法，却对外完全公开，易被误当作主 API 直接调用 |
| 低危 | `DirectJdbcInvokeContextProvider.endContext` | 空实现是隐式契约 | 「不释放连接」是刻意语义（生命周期归调用方），但接口零文档，使用者易误解为遗漏 |
| 低危 | 全部 3 文件 | `@desc` 注释为空、方法无 Javadoc | 契约抽象度高（`T` 的语义自由度大），无文档时新使用者必须读实现才能理解用法 |
| 注记 | `beginContext()` 无参 | 上下文来源强绑定构造器注入 | 动态切换数据源（如多租户）需每次新建 provider 实例，或把「选择逻辑」下沉进自定义 `T` 载体 |
| 注记 | `SQLFunction`/`SQLBiFunction` | 与 JDK `Function`/`BiFunction` 不可互转 | `throws SQLException` 换取 lambda 无需 try/catch 的代价，属有意设计权衡 |
| 注记 | `lombok` POM 声明 | 纯冗余依赖 | 3 接口零注解；不影响构建产物（lombok 为 compile 期），但属 POM 卫生问题 |

## 七、总结

- **契约层定位**：本模块以 50 行代码定义 JDBC 家族的「连接来源抽象」与「SQL 感知 lambda」，是整个 `i2f-jdbc-*` 依赖网中**被依赖最少但被所有执行层依赖**的根节点之一——`JdbcResolver`（2191 行）、`JdbcTemplate`、`BqlTemplate`、代理体系全部立在这三个接口之上。
- **传递通道设计**：POM 声明 `i2f-jdbc-data` 而自身零消费，是有意为之的「再导出」——下游 `i2f-jdbc-impl` 声明本模块即同时获得 data 包（区别于误加的冗余声明；`lombok` 才是真正的冗余）。
- **双层桥接的泛型擦除适配**：`Inner` 方法是为 `<?>` 通配符持有者解决 Java 泛型捕获限制的标准手法，本模块是整个 i2f 体系中该手法的典型样本，代价（无校验转型 + 公开暴露）仅为低危注记。
