# jdbc-procedure (XProc4J) 框架总体架构及功能介绍

## 一、框架概述

jdbc-procedure（也称 XProc4J，即 Xml Procedure for Java）是一个用于实现"去数据库存储过程"的 Java 框架。

### 1.1 设计目标

根据 [procedure.md](./procedure.md) 第3行描述：
> jdbc-procedure 是为了进行去数据库过程而实现的Java框架，目的是为了取代数据库过程的依赖性，将过程转换为Java代码实现

### 1.2 核心定位

根据 [procedure.xml](./procedure.xml) 第6-10行描述：
> 采用XML为主体，参考Mybatis的XML标签写法，构建以XML+JDBC+脚本引擎+模板引擎为基础技术支持的存储过程方案，用来替换数据库中的一切过程体，包括存储过程（procedure）和函数(function)

### 1.3 技术特点

根据 [procedure.md](./procedure.md) 第25-44行描述：
- 以解析XML文件为主，内部使用SAX解析
- 参考Mybatis的XML语法特点进行顺序化的语句调用
- 采用OGNL作为默认表达式引擎
- 引入JavaScript、Groovy、TinyScript、Java作为脚本引擎
- 引入Velocity作为模板引擎进行字符串渲染

## 二、模块结构

### 2.1 模块划分

根据项目目录结构，框架包含以下模块：

```
jdbc-procedure/
   │└── src/main/java/.../jdbc/procedure/ # 核心实现模块
   │    ├── annotations/   # 注解定义
   │    ├── consts/         # 常量定义
   │    ├── context/        # 上下文管理
   │    ├── datasource/    # 数据源管理
   │    ├── event/          # 事件系统
   │    ├── executor/       # 执行器核心
   │    ├── log/            # 日志接口
   │    ├── node/           # 执行节点
   │    ├── parser/         # XML解析
   │    ├── plugin/         # 插件支持
   │    ├── provider/       # 提供者接口
   │    ├── registry/       # 注册中心
   │    ├── reportor/       # 语法报告
   │    ├── script/         # 脚本支持
   │    ├── signal/         # 信号异常
   │    ├── test/           # 测试代码
   │    └── util/           # 工具类
   └── src/main/java/.../springboot/jdbc/bql/procedure/ # Spring Boot集成模块
       └── SpringContextJdbcProcedureExecutorAutoConfiguration.java
```

### 2.2 核心包说明

根据代码文件路径分析：

| 包名 | 功能说明 | 代码依据 |
|------|----------|----------|
| `executor` | 执行器核心，负责执行流程管理 | [BasicJdbcProcedureExecutor.java](/src/main/java/.../jdbc/procedure/executor/impl/BasicJdbcProcedureExecutor.java) |
| `node` | 执行节点，每个XML标签对应一个ExecutorNode | [ExecutorNode.java](/src/main/java/.../jdbc/procedure/node/ExecutorNode.java) |
| `parser` | XML解析器，将XML文件解析为XmlNode | [JdbcProcedureParser.java](/src/main/java/.../jdbc/procedure/parser/JdbcProcedureParser.java) |
| `context` | 上下文管理，管理过程元数据和运行时上下文 | [JdbcProcedureContext.java](/src/main/java/.../jdbc/procedure/context/JdbcProcedureContext.java) |
| `event` | 事件系统，支持过程执行事件监听 | [XProc4jEventHandler.java](/src/main/java/.../jdbc/procedure/event/XProc4jEventHandler.java) |

## 三、核心组件架构

### 3.1 核心组件关系图

```
┌─────────────────────────────────────────────────────────────┐
│                    JdbcProcedureExecutor                      │
│         (执行器接口，定义执行过程的API)                         │
│  [JdbcProcedureExecutor.java](.../jdbc/procedure/executor/JdbcProcedureExecutor.java)
└──────────────────────┬──────────────────────────────────────┘
                       │ 实现
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                  BasicJdbcProcedureExecutor                  │
│              (执行器默认实现，核心逻辑所在)                    │
│  [BasicJdbcProcedureExecutor.java](.../jdbc/procedure/executor/impl/BasicJdbcProcedureExecutor.java)
└──────────────────────┬──────────────────────────────────────┘
                       │ 持有
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              ConcurrentHashMap<String,                       │
│              CopyOnWriteArrayList<ExecutorNode>>             │
│                    (节点注册表)                              │
└──────────────────────┬──────────────────────────────────────┘
                       │ 驱动
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                      ExecutorNode                            │
│              (执行节点接口，对应XML标签)                      │
│            [ExecutorNode.java](.../jdbc/procedure/node/ExecutorNode.java)
└─────────────────────────────────────────────────────────────┘
                       │
          ┌────────────┼────────────┐
          ▼            ▼            ▼
    ┌──────────┐ ┌──────────┐ ┌──────────┐
    │ SqlNode   │ │ LangNode │ │ LogNode  │
    │ (SQL操作) │ │ (语言控制)│ │ (日志)   │
    └──────────┘ └──────────┘ └──────────┘
```

### 3.2 核心接口说明

#### 3.2.1 JdbcProcedureExecutor 执行器接口

根据 [JdbcProcedureExecutor.java](/src/main/java/.../jdbc/procedure/executor/JdbcProcedureExecutor.java)：

**主要职责：**
- 定义执行存储过程的API接口
- 管理节点注册表（ExecutorNode）
- 提供SQL执行方法
- 管理连接和事务
- 支持表达式求值（visit/eval/test/render）

**核心方法：**
```java
// 过程调用
<T> T invoke(String procedureId, Map<String, Object> params);
Map<String, Object> call(String procedureId, Map<String, Object> params);
Map<String, Object> exec(String procedureId, Map<String, Object> params);

// 上下文操作
Object visit(String script, Object params);
Object eval(String script, Object params);
String render(String script, Object params);
boolean test(String test, Object params);

// SQL操作
List<?> sqlQueryList(String datasource, BindSql bql, Map<String, Object> params, Class<?> resultType);
int sqlUpdate(String datasource, BindSql bql, Map<String, Object> params);

// 事务管理
void sqlTransBegin(String datasource, int isolation, Map<String, Object> params);
void sqlTransCommit(String datasource, Map<String, Object> params, boolean checked);
void sqlTransRollback(String datasource, Map<String, Object> params, boolean checked);
```

#### 3.2.2 ExecutorNode 执行节点接口

根据 [ExecutorNode.java](/src/main/java/.../jdbc/procedure/node/ExecutorNode.java)：

**接口定义：**
```java
public interface ExecutorNode {
    String tag();  // 返回该节点处理的XML标签名
    
    default String[] alias();  // 返回标签别名
    
    default boolean support(XmlNode node);  // 判断是否支持该节点
    
    void exec(XmlNode node, Map<String, Object> context, JdbcProcedureExecutor executor);
}
```

#### 3.2.3 AbstractExecutorNode 执行节点抽象基类

根据 [AbstractExecutorNode.java](/src/main/java/.../jdbc/procedure/node/basic/AbstractExecutorNode.java)：

**主要功能：**
- 实现节点执行的生命周期钩子（onBefore/onAfter/onThrowing/onFinally）
- 维护执行跟踪信息（traceStack, traceLocation等）
- 统一异常处理机制
- 执行时间统计和事件发布

**关键常量：**
```java
public static final String POINT_KEY_LOCATION = "location";
public static final String POINT_KEY_BEGIN_TS = "beginTs";
public static final String POINT_KEY_END_TS = "endTs";
public static final String POINT_KEY_USE_TS = "useTs";
```

### 3.3 BasicJdbcProcedureExecutor 核心实现

根据 [BasicJdbcProcedureExecutor.java](/src/main/java/.../jdbc/procedure/executor/impl/BasicJdbcProcedureExecutor.java)：

#### 3.3.1 节点注册机制

**默认节点注册（第152-242行）：**
```java
public static List<ExecutorNode> defaultExecutorNodes() {
    List<ExecutorNode> ret = new ArrayList<>();
    // ServiceLoader加载
    ServiceLoader<ExecutorNode> nodes = ServiceLoader.load(ExecutorNode.class);
    
    // 注册语言控制节点 (lang-*)
    ret.add(new LangIfNode());
    ret.add(new LangForiNode());
    ret.add(new LangForeachNode());
    ret.add(new LangWhileNode());
    ret.add(new LangDoWhileNode());
    ret.add(new LangTryNode());
    ret.add(new LangReturnNode());
    ret.add(new LangSetNode());
    // ... 更多lang节点
    
    // 注册SQL操作节点 (sql-*)
    ret.add(new SqlQueryListNode());
    ret.add(new SqlQueryRowNode());
    ret.add(new SqlQueryObjectNode());
    ret.add(new SqlUpdateNode());
    ret.add(new SqlScopeNode());
    ret.add(new SqlCursorNode());
    ret.add(new SqlTransactionalNode());
    // ... 更多sql节点
    
    // 注册日志节点 (log-*)
    ret.add(new LogDebugNode());
    ret.add(new LogInfoNode());
    ret.add(new LogWarnNode());
    ret.add(new LogErrorNode());
    
    // 注册过程调用节点
    ret.add(new ProcedureCallNode());
    ret.add(new ProcedureNode());
    
    return ret;
}
```

#### 3.3.2 参数上下文结构

**createParamsInner方法（第801-839行）定义的参数结构：**
```java
Map<String, Object> ret = new LinkedHashMap<>();
ret.put(ParamsConsts.STACK_LOCK, new ReentrantLock());          // 栈锁
ret.put(ParamsConsts.CONTEXT, getNamingContext());             // 命名上下文
ret.put(ParamsConsts.ENVIRONMENT, getEnvironment());           // 环境变量
ret.put(ParamsConsts.GLOBAL, Collections.synchronizedMap(new HashMap<>()));  // 全局变量
ret.put(ParamsConsts.METAS, Collections.synchronizedMap(new HashMap<>()));     // 过程元数据
ret.put(ParamsConsts.LISTENERS, Collections.synchronizedMap(new HashMap<>())); // 事件监听器
ret.put(ParamsConsts.TRACE, trace);                            // 跟踪信息
ret.put(ParamsConsts.LRU, new LruMap<>(4096));                 // LRU缓存
ret.put(ParamsConsts.EXECUTOR, this);                          // 执行器引用
ret.put(ParamsConsts.BEANS, beanMap);                          // Bean映射
ret.put(ParamsConsts.DATASOURCES, datasourceMap);              // 数据源映射
```

#### 3.3.3 执行流程

**exec方法（第583-598行）执行流程：**
```java
public Map<String, Object> exec(XmlNode node, Map<String, Object> params, 
                                 boolean beforeNewConnection, boolean afterCloseConnection) {
    // 1. 获取支持该XML节点的ExecutorNode
    ExecutorNode execNode = getSupportNode(node);
    
    // 2. 通过ExecutorNode执行该节点
    execXmlNodeByExecutorNode(execNode, node, params, beforeNewConnection, afterCloseConnection);
    
    return params;
}
```

### 3.4 JdbcProcedureParser XML解析器

根据 [JdbcProcedureParser.java](/src/main/java/.../jdbc/procedure/parser/JdbcProcedureParser.java)：

**解析流程：**
1. 读取XML文件或字符串
2. 移除DOCTYPE声明（如果存在）
3. 替换宏变量（__FILE__, __LINE__）
4. 使用SAX解析生成XmlNode树
5. 解析属性修饰符（feature）

**parseAttrFeatures方法（第123-131行）解析属性修饰符：**
```java
// 例如: value.string.int 会被解析为
// 属性名: "value"
// 修饰符列表: ["string", "int"]
```

### 3.5 XmlNode 数据结构

根据 [XmlNode.java](/src/main/java/.../jdbc/procedure/parser/data/XmlNode.java)：

```java
@Data
public class XmlNode {
    NodeType nodeType;              // 节点类型：ELEMENT, TEXT, CDATA
    String tagName;                // 标签名
    Map<String, String> tagAttrMap; // 标签属性
    Map<String, List<String>> attrFeatureMap; // 属性修饰符
    String tagBody;                // 标签内容
    String textBody;               // 文本内容
    List<XmlNode> children;       // 子节点
    String locationFile;           // 源文件位置
    int locationLineNumber;        // 源文件行号
    String nodeLocation;           // 完整位置描述
}
```

## 四、节点分类体系

根据 [BasicJdbcProcedureExecutor.java](/src/main/java/.../jdbc/procedure/executor/impl/BasicJdbcProcedureExecutor.java) 第152-242行的节点注册，框架包含以下节点类型：

### 4.1 语言控制节点 (lang-*)

| 节点名 | 功能说明 | 代码位置 |
|--------|----------|----------|
| lang-if | 条件判断 | LangIfNode |
| lang-choose | 多分支选择 | LangChooseNode |
| lang-foreach | 集合迭代 | LangForeachNode |
| lang-fori | 计数循环 | LangForiNode |
| lang-while | 条件循环 | LangWhileNode |
| lang-do-while | 先执行后判断循环 | LangDoWhileNode |
| lang-set | 变量赋值 | LangSetNode |
| lang-return | 返回 | LangReturnNode |
| lang-throw | 抛出异常 | LangThrowNode |
| lang-try | 异常捕获 | LangTryNode |
| lang-break | 跳出循环 | LangBreakNode |
| lang-continue | 继续循环 | LangContinueNode |
| lang-invoke | 调用方法 | LangInvokeNode |
| lang-eval | 表达式求值 | LangEvalNode |
| lang-eval-java | Java脚本执行 | LangEvalJavaNode |
| lang-eval-ts | TinyScript执行 | LangEvalTinyScriptNode |
| lang-eval-groovy | Groovy脚本执行 | LangEvalGroovyNode |
| lang-eval-js | JavaScript执行 | LangEvalJavascriptNode |
| lang-render | 模板渲染 | LangRenderNode |
| lang-format | 格式化 | LangFormatNode |
| lang-format-date | 日期格式化 | LangFormatDateNode |
| lang-string | 字符串处理 | LangStringNode |
| lang-string-join | 字符串拼接 | LangStringJoinNode |
| lang-synchronized | 同步块 | LangSynchronizedNode |
| lang-retry | 重试机制 | LangRetryNode |
| lang-lock | 锁机制 | LangLockNode |
| lang-latch | 门闩机制 | LangLatchNode |
| lang-new-params | 新建参数上下文 | LangNewParamsNode |
| lang-file-* | 文件操作 | LangFileReadTextNode等 |
| lang-shell | Shell命令执行 | LangShellNode |
| lang-println | 打印输出 | LangPrintlnNode |
| lang-printf | 格式化打印 | LangPrintfNode |
| lang-thread-pool-* | 线程池操作 | LangThreadPoolNode等 |
| lang-async | 异步执行 | LangAsyncNode |

### 4.2 SQL操作节点 (sql-*)

| 节点名 | 功能说明 | 代码位置 |
|--------|----------|----------|
| sql-query-list | 查询返回列表 | SqlQueryListNode |
| sql-query-row | 查询返回单行 | SqlQueryRowNode |
| sql-query-object | 查询返回对象 | SqlQueryObjectNode |
| sql-query-columns | 查询返回列信息 | SqlQueryColumnsNode |
| sql-query-page | 分页查询 | SqlQueryPageNode |
| sql-update | 更新操作 | SqlUpdateNode |
| sql-script | SQL脚本执行 | SqlScriptNode |
| sql-scope | 作用域管理 | SqlScopeNode |
| sql-cursor | 游标操作 | SqlCursorNode |
| sql-etl | ETL操作 | SqlEtlNode |
| sql-transactional | 事务包装 | SqlTransactionalNode |
| sql-trans-begin | 事务开始 | SqlTransBeginNode |
| sql-trans-commit | 事务提交 | SqlTransCommitNode |
| sql-trans-rollback | 事务回滚 | SqlTransRollbackNode |
| sql-trans-none | 关闭事务 | SqlTransNoneNode |

### 4.3 日志节点 (log-*)

| 节点名 | 功能说明 | 代码位置 |
|--------|----------|----------|
| log-debug | Debug级别日志 | LogDebugNode |
| log-info | Info级别日志 | LogInfoNode |
| log-warn | Warn级别日志 | LogWarnNode |
| log-error | Error级别日志 | LogErrorNode |

### 4.4 过程调用节点

| 节点名 | 功能说明 | 代码位置 |
|--------|----------|----------|
| procedure | 过程定义 | ProcedureNode |
| procedure-call | 过程调用 | ProcedureCallNode |
| function-call | 函数调用 | FunctionCallNode |
| java-call | Java方法调用 | JavaCallNode |

### 4.5 其他节点

| 节点名 | 功能说明 | 代码位置 |
|--------|----------|----------|
| script-segment | 脚本片段定义 | ScriptSegmentNode |
| script-include | 脚本片段引用 | ScriptIncludeNode |
| debugger | 调试断点 | DebuggerNode |
| text | 文本节点 | TextNode |

## 五、上下文函数体系

### 5.1 ContextFunctions 接口

根据 [ContextFunctions.java](/src/main/java/.../jdbc/procedure/context/ContextFunctions.java)：

**主要函数分类：**

#### 5.1.1 空值判断函数
```java
boolean isnull(Object obj)           // 判断是否为空
boolean is_empty(Object obj)         // 判断是否为空（包含空字符串、空集合等）
boolean is_blank(Object obj)          // 判断是否为空白（空格、制表符等）
Object nvl(Object v1, Object v2)     // 如果v1为空返回v2
Object ifnull(Object v1, Object v2) // 同nvl
Object nullif(Object v1, Object v2)  // 如果v1等于v2返回null
Object coalesce(Object... values)     // 返回第一个非空值
```

#### 5.1.2 字符串函数
```java
String trim(String str)              // 去除首尾空白
String upper(String str)             // 转大写
String lower(String str)             // 转小写
String left(Object obj, int len)     // 取左边字符串
String right(Object obj, int len)    // 取右边字符串
String substr(Object obj, int index) // 截取字符串
String replace(Object str, Object target) // 字符串替换
String regex_replace(Object str, String regex, Object replacement) // 正则替换
boolean contains(Object obj, Object substr) // 判断包含
boolean like(Object obj, Object substr)      // 判断相似
int length(Object obj)               // 获取长度
String repeat(CharSequence str, int count) // 重复字符串
String concat(Object... args)         // 字符串连接
```

#### 5.1.3 日期函数
```java
Date now()                           // 当前时间
Date sysdate()                       // 系统时间（同now）
Date add_days(Object date, long interval)  // 日期加减天数
Date add_months(Object date, long interval) // 日期加减月数
Object last_day(Object date)        // 月末日期
Object first_day(Object date)        // 月初日期
String date_format(Object date, String pattern) // 日期格式化
Date to_date(Object obj)             // 字符串转日期
Object trunc(Object obj)             // 截断（日期或数值）
Object round(Object number)           // 四舍五入
```

#### 5.1.4 数值函数
```java
Object add(Object v1, Object v2)    // 加法
Object subtract(Object v1, Object v2) // 减法
Object multiply(Object v1, Object v2) // 乘法
Object divide(Object v1, Object v2)  // 除法
Object round(Object number, Integer precision) // 指定精度四舍五入
Object trunc(Object number, Integer precision) // 指定精度截断
BigDecimal to_number(Object obj)     // 转数值
Integer to_int(Object obj)           // 转整数
Long to_long(Object obj)             // 转长整数
```

#### 5.1.5 其他工具函数
```java
Object decode(Object target, Object... args) // 解码函数（类似Oracle decode）
Object cast(Object val, Object type)         // 类型转换
long snowflake_id()                 // 生成雪花ID
String uuid()                       // 生成UUID
void sleep(long seconds)            // 线程睡眠
void print(Object... objs)          // 打印（不换行）
void println(Object... objs)         // 打印（换行）
String sys_env(String key)          // 获取系统环境变量
String jvm(String key)              // 获取JVM系统属性
```

### 5.2 TinyScriptFunctions 接口

根据 [TinyScriptFunctions.java](/src/main/java/.../extension/antlr4/script/tiny/impl/context/TinyScriptFunctions.java)：

**TinyScript独有函数：**
```java
// 随机函数
int rand()                           // 返回随机整数
int rand(int bound)                  // 返回0到bound之间的随机整数
double random()                      // 返回0到1之间的随机小数
String uuid()                        // 生成UUID

// 集合操作
<T> List<T> new_list()              // 创建新列表
<K, V> Map<K, V> new_map()           // 创建新映射
<T> Set<T> new_set()                 // 创建新集合
Collection append(Collection collection, Object... objs) // 添加元素
Object list_get(List list, int index) // 获取列表元素
Object list_remove(List list, int index) // 移除列表元素

// 线程本地存储
Map<String, Object> local_map()      // 获取线程本地Map
Object local_get(String key)         // 获取线程本地值
void local_set(String key, Object value) // 设置线程本地值

// 数组操作
Object new_array(Class<?> elemType, int len) // 创建数组
int arr_len(Object arr)              // 获取数组长度
<T> T arr_get(Object arr, int index) // 获取数组元素
```

## 六、执行上下文管理

### 6.1 ContextHolder 线程上下文持有者

根据 [ContextHolder.java](/src/main/java/.../jdbc/procedure/context/ContextHolder.java)：

**ThreadLocal变量：**
```java
public static final ThreadLocal<String> TRACE_LOCATION;    // 当前位置
public static final ThreadLocal<String> TRACE_FILE;       // 源文件
public static final ThreadLocal<Integer> TRACE_LINE;         // 行号
public static final ThreadLocal<String> TRACE_TAG;          // 标签名
public static final ThreadLocal<String> TRACE_ERRMSG;        // 错误消息
public static final ThreadLocal<Throwable> TRACE_ERROR;       // 异常
public static final ThreadLocal<XmlNode> TRACE_NODE;        // 当前节点
public static final ThreadLocal<BindSql> TRACE_LAST_SQL;     // 最近SQL
public static final ThreadLocal<Integer> TRACE_LAST_SQL_EFFECT_COUNT; // 影响行数
public static final ThreadLocal<Long> TRACE_LAST_SQL_USE_TIME; // SQL执行时间
```

### 6.2 参数常量定义

根据 [ParamsConsts.java](/src/main/java/.../jdbc/procedure/consts/ParamsConsts.java)：

```java
STACK_LOCK = "stack_lock"           // 栈锁
CONTEXT = "context"                 // 命名上下文
ENVIRONMENT = "env"         // 环境变量
GLOBAL = "global"                   // 全局变量
METAS = "metas"                     // 过程元数据
LISTENERS = "listeners"             // 事件监听器
TRACE = "trace"                     // 跟踪信息
LRU = "lru"                         // LRU缓存
EXECUTOR = "executor"                // 执行器引用
BEANS = "beans"                      // Bean映射
DATASOURCES = "datasources"          // 数据源映射
CONNECTIONS = "connections"          // 连接映射
TRACE_STACK = "trace.stack"          // 跟踪栈
TRACE_LOCATION = "trace.location"   // 当前位置
TRACE_FILE = "trace.file"            // 源文件
TRACE_LINE = "trace.line"            // 行号
TRACE_TAG = "trace.tag"             // 标签名
TRACE_ERROR = "trace.error"         // 错误
TRACE_ERRORS = "trace.errors"       // 错误列表
TRACE_ERRMSG = "trace.errmsg"       // 错误消息
TRACE_NODE = "trace.node"           // 当前节点
TRACE_CALLS = "trace.calls"         // 调用栈
TRACE_LAST_SQL = "trace.last_sql"  // 最近SQL
TRACE_LAST_SQL_EFFECT_COUNT = "trace.last_sql_effect_count" // 影响行数
TRACE_LAST_SQL_USE_TIME = "trace.last_sql_use_time" // SQL执行时间
```

## 七、事件系统

### 7.1 事件处理器

根据 [XProc4jEventHandler.java](/src/main/java/.../jdbc/procedure/event/XProc4jEventHandler.java)：

**事件类型：**
- XmlExecUseTimeEvent - 节点执行时间事件
- XmlNodeExecEvent - 节点执行事件（Before/After/Throwing/Finally）
- ExecutorInitializeEvent - 执行器初始化事件
- SqlExecUseTimeEvent - SQL执行时间事件
- SlowSqlEvent - 慢SQL事件
- ExecutorContextEvent - 执行上下文事件

### 7.2 事件传播方式

根据 [BasicJdbcProcedureExecutor.java](/src/main/java/.../jdbc/procedure/executor/impl/BasicJdbcProcedureExecutor.java) 第273-308行：

```java
// 发送事件（同步）
void sendEvent(XProc4jEvent event)

// 发布事件（异步）
void publishEvent(XProc4jEvent event)
```

## 八、Spring Boot集成

### 8.1 自动配置类

根据 [SpringContextJdbcProcedureExecutorAutoConfiguration.java](/src/main/java/.../springboot/jdbc/bql/procedure/SpringContextJdbcProcedureExecutorAutoConfiguration.java)：

**配置项（通过SpringJdbcProcedureProperties）：**
```java
xproc4j.enable                        // 是否启用
xproc4j.naming-context.enable        // 命名上下文
xproc4j.environment.enable           // 环境变量
xproc4j.event-handler.enable          // 事件处理器
xproc4j.provider.xml-node.scan.enable // XML节点扫描
xproc4j.provider.xml-node.watching.enable // XML目录监听
xproc4j.provider.java-caller.enable   // Java调用器
xproc4j.provider.registry.enable       // 注册中心
xproc4j.context.enable                // 过程上下文
xproc4j.executor.enable               // 执行器
```

**自动注册的Bean：**
- JdbcProcedureExecutor - 执行器
- JdbcProcedureContext - 过程上下文
- JdbcProcedureLogger - 日志记录器
- DataSourceProvider - 数据源提供者
- XProc4jEventHandler - 事件处理器
- ScriptPreloadEventListener - 脚本预加载监听器

### 8.2 配置属性类

根据 [SpringJdbcProcedureProperties.java](/src/main/java/.../springboot/jdbc/bql/procedure/SpringJdbcProcedureProperties.java)：

```java
// XML文件位置
xmlLocations = "classpath*:/procedure/**/*.xml"

// 监听目录
watchingDirectories = "./procedure" 

// 刷新间隔（秒）
refreshXmlIntervalSeconds = 60

// 慢查询阈值（毫秒）
slowSqlMinMillsSeconds = 5000
slowNodeMillsSeconds = 15000
slowProcedureMillsSeconds = 30000

// 调试模式
debug = false

// 报告配置
reportOnBoot = false
```

## 九、表达式引擎体系

### 9.1 表达式类型

根据 [procedure.md](./procedure.md) 第38-44行：

| 类型 | 说明 | 技术实现 |
|------|------|----------|
| visit | 从上下文访问值 | 反射+OGNL |
| test | 条件布尔表达式 | OGNL |
| eval | 脚本表达式执行 | TinyScript/JavaScript/Groovy/Java |
| render | 字符串模板渲染 | Velocity |

### 9.2 TinyScript脚本引擎

根据 [TinyScript.md](./TinyScript.md)：

**特性：**
- 基于ANTLR4实现的轻量级脚本语言
- 支持基本数据类型（int, long, float, double, boolean, string, null）
- 支持JSON数据类型
- 支持管道函数调用链
- 支持自定义函数定义
- 支持if/for/while/foreach/try等控制结构

**变量引用语法：**
```shell
${变量路径}          // 标准引用，变量为null时返回"null"
$!{变量路径}         // 空安全引用，变量为null时返回空字符串
```

### 9.3 DefaultTinyScriptResolver 解析器实现

根据 [DefaultTinyScriptResolver.java](/src/main/java/.../extension/antlr4/script/tiny/impl/DefaultTinyScriptResolver.java)：

**运算符支持：**
```java
// 逻辑运算符
&& / and, || / or, ! / not

// 比较运算符
== / eq, != / ne / <>, > / gt, < / lt, >= / gte, <= / lte
in, notin

// 算术运算符
+, -, *, /, %

// 类型运算符
as / cast, is / instanceof / typeof
```

## 十、多数据源支持

### 10.1 数据源管理

根据 [BasicJdbcProcedureExecutor.java](/src/main/java/.../jdbc/procedure/executor/impl/BasicJdbcProcedureExecutor.java) 第772-796行：

```java
// 自动检测主数据源
private void detectPrimaryDatasource(Map<String, DataSource> ret) {
    // 优先查找名为 primary, master, main, default, leader 的数据源
    // 如果只有一个则自动设为主数据源
}
```

### 10.2 数据库方言支持

**支持的数据库类型：**
- MySQL
- Oracle
- PostgreSQL
- DM（达梦）
- GBase（南大通用）

根据 [procedure.xml](./procedure.xml) 第82-86行：
> 通过dialect属性指定不同数据库类型的SQL语句

### 10.3 事务管理

```xml
<!-- 开启事务 -->
<sql-trans-begin datasource="xxx"/>

<!-- 提交事务 -->
<sql-trans-commit datasource="xxx"/>

<!-- 回滚事务 -->
<sql-trans-rollback datasource="xxx"/>

<!-- 自动提交模式 -->
<sql-trans-none datasource="xxx"/>
```

## 十一、扩展机制

### 11.1 ExecutorNode扩展

通过实现ExecutorNode接口并注册到执行器：
推荐继承 AbstractExecutorNode 以获得框架一些默认的支持
```java
public class MyCustomNode extends AbstractExecutorNode {
    @Override
    public String tag() {
        return "my-custom";
    }
    
    @Override
    public void execInner(XmlNode node, Map<String, Object> context, 
                     JdbcProcedureExecutor executor) {
        // 自定义执行逻辑
    }
}

// 注册方式
executor.registryExecutorNode(new MyCustomNode());
```

### 11.2 FeatureFunction扩展

根据 [BasicJdbcProcedureExecutor.java](/src/main/java/.../jdbc/procedure/executor/impl/BasicJdbcProcedureExecutor.java) 第369-377行：

```java
// 注册属性修饰符
executor.registryFeatureFunction("my-feature", (value, node, params, executor) -> {
    // 自定义修饰符逻辑
    return processedValue;
});
```

### 11.3 JdbcProcedureJavaCaller扩展

通过实现JdbcProcedureJavaCaller接口：
```java
public class MyJavaCaller implements JdbcProcedureJavaCaller {
    @Override
    public Object exec(JdbcProcedureExecutor executor, 
                       Map<String, Object> params) throws Throwable {
        // Java代码实现过程逻辑
        return result;
    }
}
```

## 十二、执行流程详解

### 12.1 整体执行流程

```
┌─────────────────────────────────────────────────────────────┐
│                      调用入口                                 │
│  executor.call("PROCEDURE_ID", params)                      │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   1. 查找过程元数据                            │
│  executor.getMeta(procedureId) -> ProcedureMeta               │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   2. 创建执行参数                              │
│  executor.prepareParams(params)                              │
│  - 初始化全局变量、监听器、LRU缓存等                          │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   3. 解析XML节点                              │
│  JdbcProcedureParser.parse() -> XmlNode                     │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   4. 分发到对应ExecutorNode                   │
│  executor.getSupportNode(node) -> ExecutorNode               │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   5. 执行节点                                 │
│  ExecutorNode.exec(node, params, executor)                  │
│  - onBefore() -> 执行业务逻辑 -> onAfter()                   │
│  - 捕获异常 -> onThrowing() -> 抛出异常                       │
│  - finally -> onFinally()                                   │
└──────────────────────┬──────────────────────────────────────┘
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                   6. 关闭连接（如果需要）                       │
│  executor.closeConnections(params, exception)               │
└─────────────────────────────────────────────────────────────┘
```

### 12.2 节点执行生命周期

根据 [AbstractExecutorNode.java](/src/main/java/.../jdbc/procedure/node/basic/AbstractExecutorNode.java) 第75-280行：

```
┌─────────────────────────────────────────────────────────────┐
│                        exec()                               │
│  ┌───────────────────────────────────────────────────────┐  │
│  │ try {                                                │  │
│  │     updateTraceInfo()     // 更新跟踪信息             │  │
│  │                                                      │  │
│  │     onBefore()            // 前置钩子                │  │
│  │     │  - 发送 XmlNodeExecEvent(Type.BEFORE)         │  │
│  │     ▼                                              │  │
│  │     execInner()           // 实际执行逻辑            │  │
│  │     │  - 由子类实现                                 │  │
│  │     ▼                                              │  │
│  │     onAfter()             // 后置钩子                │  │
│  │        - 发送 XmlNodeExecEvent(Type.AFTER)         │  │
│  │ } catch (Throwable e) {                             │  │
│  │     onThrowing()          // 异常钩子                │  │
│  │        - 发送 XmlNodeExecEvent(Type.THROWING)      │  │
│  │     - 包装为SignalException                         │  │
│  │     - 记录错误到上下文                               │  │
│  │     - 抛出异常                                       │  │
│  │ } finally {                                          │  │
│  │     onFinally()            // 最终钩子               │  │
│  │        - 发送 XmlNodeExecEvent(Type.FINALLY)       │  │
│  │     - 发布 XmlExecUseTimeEvent                      │  │
│  │        - 记录执行耗时                               │  │
│  │ }                                                    │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 十三、配置文件参考

### 13.1 application.yml 配置示例

```yaml
xproc4j:
  enable: true
  debug: false
  
  # XML文件扫描位置
  xml-locations: "classpath*:/procedure/**/*.xml"
  
  # 监听目录（热加载）
  watching-directories: "./procedure"
  
  # 刷新间隔（秒）
  refresh-xml-interval-seconds: 60
  
  # 慢查询阈值
  slow-sql-min-mills-seconds: 5000
  slow-node-mills-seconds: 15000
  slow-procedure-mills-seconds: 30000
  
  # 报告配置
  report-on-boot: false
  
  # 各组件开关
  naming-context:
    enable: true
  environment:
    enable: true
  event-handler:
    enable: true
  provider:
    xml-node:
      scan:
        enable: true
      watching:
        enable: true
    java-caller:
      enable: true
    registry:
      enable: true
  context:
    enable: true
  executor:
    enable: true
```

## 十四、总结

### 14.1 框架特点

1. **XML驱动**：以XML格式定义过程，支持SAX解析保持顺序和定位
2. **多引擎支持**：集成TinyScript、OGNL、Velocity等多种表达式引擎
3. **多语言支持**：支持Java、JavaScript、Groovy、TinyScript脚本
4. **多数据源**：支持多个数据源切换和跨数据源操作
5. **多方言支持**：支持MySQL、Oracle、DM等数据库方言
6. **事务管理**：提供完整的事务控制能力
7. **事件机制**：提供完整的生命周期事件监听
8. **Spring集成**：提供Spring Boot自动配置

### 14.2 适用场景

1. 数据库存储过程迁移到Java应用
2. 复杂业务逻辑的XML可视化配置
3. 跨数据源的ETL操作
4. 多步骤批处理任务
5. 动态SQL拼接和执行

### 14.3 核心价值

根据 [procedure.xml](./procedure.xml) 第8-10行：
> 实现使用脚本定义的方式，达到与存储过程相似的能力，核心使用一个Map构成的执行栈来维护执行的变量，预期是既有编程语言的控制灵活度，也有数据库语句直接编写的识别度，避免在java等编程语言中进行SQL语句的拼接操作

---

**文档版本：** 1.0  
**最后更新：** 2026-04-02  
**维护者：** Ice2Faith