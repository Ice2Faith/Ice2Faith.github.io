# Mixin 混入体系

## 概述

`i2f-mixins` 模块通过 Java 8 接口默认方法实现了一套
Mixin（混入）体系。核心思想是：将大量常用工具函数以接口默认方法的形式定义，任何类只需 `implements` 对应接口即可获得这些函数能力，实现变相的
**多重继承**。

该体系在项目中扮演着**脚本引擎内建函数库**的关键角色——Funic、TinyScript、XProc4J
存储过程引擎均通过混入接口获取数百个内建函数，使脚本语言可以直接调用 `length()`、`substr()`、`round()`、`now()`、`regex_match()`
等函数。

## 模块信息

| 属性  | 值                                                                                                                                    |
|-----|--------------------------------------------------------------------------------------------------------------------------------------|
| 模块  | `i2f-jdk/i2f-mixins`                                                                                                                 |
| 所属层 | i2f-jdk                                                                                                                              |
| 文件数 | 22 个 Java 文件                                                                                                                         |
| 依赖  | `i2f-proxy-std`, `i2f-reflect`, `i2f-convert`, `i2f-text`, `i2f-match`, `i2f-io-stream`, `i2f-uid-impl`, `i2f-jvm`, `i2f-os`, Lombok |

## 设计原理

### 核心理念

1. **接口默认方法**：所有混入接口的方法均为 `default` 实现，混入后无副作用
2. **变相多重继承**：Java 不支持多继承，但通过 `implements` 多个接口可获得所有默认方法
3. **零实例化开销**：通过 `MixinProxyFactory` 的 JDK 动态代理，无需创建匿名对象即可使用

### MixinProxyFactory — 代理工厂

`MixinProxyFactory` 是混入体系的核心基础设施，通过 JDK 动态代理 + `DefaultMethodSmartInvocationHandler` 实现接口代理：

```java
// 推荐用法：通过代理工厂获取，无需创建匿名对象
AllMixins mixins = MixinProxyFactory.getMixinInstance(AllMixins.class);

// 不推荐：传统匿名对象方式（会创建大量匿名对象）
AllMixins mixins = new AllMixins() {
};
```

**实现特点：**

- 使用 `ConcurrentHashMap` 缓存代理实例，全局单例
- 递归收集目标类的所有接口（`findInterfaces`），确保多重继承链完整
- 依赖 `i2f-proxy-std` 的 `DefaultMethodSmartInvocationHandler`，自动路由到接口默认方法
- 支持跨混入接口互调（如 `StringMixins` 内部调用 `DateMixins`/`MathMixins`）

### 跨混入接口互调

混入接口之间可通过 `MixinProxyFactory` 互相调用，形成内建函数协作网络：

```
StringMixins.to_char()
  ├→ DateMixins.date_format()       // 日期类型格式化
  └→ MathMixins.round()             // 数值精度控制

RegexMixins.regex_find_join()
  └→ StringMixins.join()            // 结果拼接

RegexMixins.substr_regex_index()
  └→ StringMixins.substr()          // 子串截取

ObjectMixins.trunc()
  ├→ MathMixins.trunc()             // 数值截断
  └→ DateMixins.trunc()             // 日期截断
```

## 混入接口清单

### AllMixins — 全量聚合接口

`AllMixins` 是混入体系的核心聚合接口，继承 18 个分类混入接口，提供 500+ 个内建函数：

```java
public interface AllMixins extends
        ArrayMixins,          // 数组操作
        CollectionMixins,     // 集合操作
        CommandLineMixins,    // 命令行执行
        DateMixins,           // 日期时间
        FileMixins,           // 文件操作
        JvmMixins,            // JVM 信息
        MapMixins,            // Map 操作
        MatchMixins,          // 模式匹配
        MathMixins,           // 数学运算
        ObjectMixins,         // 对象通用操作
        OsMixins,             // 操作系统信息
        RandomMixins,         // 随机数
        RegexMixins,          // 正则表达式
        StringMixins,         // 字符串操作（最大，1234行）
        SystemMixins,         // 系统操作
        ThreadLocalMixins,    // 线程本地变量
        ThreadMixins,         // 线程操作
        UuidMixins            // UUID 生成
```

### 各分类混入接口详情

#### 1. StringMixins（1234 行，最大）

字符串处理函数库，覆盖字符串操作的全部场景：

| 分类    | 主要函数                                                                                                                    | 说明                          |
|-------|-------------------------------------------------------------------------------------------------------------------------|-----------------------------|
| 判空/空值 | `is_empty()`, `not_empty()`, `if_empty()`                                                                               | 空值判断与回退                     |
| 格式化   | `format()`, `to_char()`, `to_string()`                                                                                  | 字符串格式化（支持 Oracle 风格数字/日期模式） |
| 大小写   | `upper()`, `lower()`, `first_upper()`, `first_lower()`, `init_capital()`                                                | 大小写转换                       |
| 命名转换  | `to_pascal()`, `to_camel()`, `to_snake()`, `to_underscore()`, `to_property_case()`, `to_path_case()`, `to_colon_case()` | 7 种命名风格互转                   |
| 查找    | `index_of()`, `last_index_of()`, `instr()`, `contains()`, `starts_with()`, `ends_with()`, `like()`                      | 子串查找                        |
| 截取    | `substr()`, `substring()`, `substrb()`, `left()`, `right()`, `substr_count()`, `substr2_index()`, `substr_index()`      | 多种截取方式（字符/字节/索引）            |
| 替换    | `replace()`, `replace_all()`                                                                                            | 字符串替换                       |
| 填充    | `lpad()`, `rpad()`, `ltrim()`, `rtrim()`, `trim()`                                                                      | 填充与修剪                       |
| 拼接    | `concat()`, `concat_ws()`, `join()`, `append()`                                                                         | 拼接与连接                       |
| 分割    | `split()`, `split_literal()`                                                                                            | 分割（支持字面量分割）                 |
| 编码    | `to_url_encoded()`, `encode_url()`, `decode_url()`, `to_base64()`, `encode_base64()`, `decode_base64()`                 | URL/Base64 编解码              |
| 哈希    | `md5()`, `sha1()`, `sha256()`, `sha384()`, `sha512()`, `mds()`                                                          | 消息摘要（支持 hex/base64 输出）      |
| SQL   | `escape_sql_string()`, `descape_sql_string()`                                                                           | SQL 字符串转义                   |
| 其他    | `reverse()`, `repeat()`, `chr()`, `char_code()`, `length()`, `newline()`, `sharp()`, `dollar()`, `trim_empty_lines()`   | 其他工具函数                      |

#### 2. MathMixins（417 行）

数学运算函数库，基于 `BigDecimal` 高精度计算：

| 分类   | 函数                                                                               | 说明                             |
|------|----------------------------------------------------------------------------------|--------------------------------|
| 基础运算 | `add()`, `sub()`, `mul()`, `div()`, `mod()`, `pow()`, `sqrt()`, `log()`, `neg()` | 加减乘除等（double + BigDecimal 双版本） |
| 三角函数 | `sin()`, `cos()`, `tan()`, `asin()`, `acos()`, `atan()`                          | 三角函数                           |
| 精度控制 | `round()`, `trunc()`                                                             | 四舍五入/截断（支持正/负精度）               |
| 其他   | `abs()`, `ln()`                                                                  | 绝对值、自然对数                       |

#### 3. ObjectMixins（457 行）

对象通用操作函数库：

| 分类   | 函数                                                                                                | 说明                   |
|------|---------------------------------------------------------------------------------------------------|----------------------|
| 类型转换 | `to_number()`, `to_int()`, `to_long()`, `to_boolean()`, `cast()`, `convert()`                     | 类型转换                 |
| 空值判断 | `isnull()`, `not_null()`, `is_empty()`, `is_blank()`                                              | 多层空值判断               |
| 空值回退 | `ifnull()`, `nvl()`, `if_empty()`, `evl()`, `if_blank()`, `bvl()`, `nullif()`                     | SQL 风格空值处理           |
| 条件   | `if2()`, `nvl2()`, `decode()`                                                                     | 条件表达式（类似 SQL DECODE） |
| 合并   | `coalesce()`, `nvl_args()`, `coalesce_empty()`, `evl_args()`                                      | 多值合并                 |
| 长度   | `length()`, `lengthb()`                                                                           | 长度（字符/字节）            |
| 比较   | `equal()`, `compare()`, `cmp_eq()`, `cmp_neq()`, `cmp_gt()`, `cmp_lt()`, `cmp_gte()`, `cmp_lte()` | 通用比较（支持数值/日期/字符串跨类型） |
| 属性访问 | `visit_get()`, `visit_set()`, `visit_del()`                                                       | 表达式驱动的对象属性访问         |
| 其他   | `hashcode()`, `trunc()`                                                                           | 哈希、截断                |

#### 4. DateMixins（363 行）

日期时间函数库：

| 分类     | 函数                                                                                     | 说明                         |
|--------|----------------------------------------------------------------------------------------|----------------------------|
| 当前时间   | `now()`, `sysdate()`, `timestamp()`, `current_time_millis()`, `current_time_seconds()` | 获取当前时间                     |
| 格式化/解析 | `format()`, `date_format()`, `parse_date()`, `to_date()`, `str_to_date()`              | 日期格式化与解析                   |
| 时间戳    | `timestamp_to_date()`, `date_to_timestamp()`                                           | 时间戳转换                      |
| 日期运算   | `date_add()`, `date_sub()`, `add_months()`, `add_days()`                               | 日期加减                       |
| 日期提取   | `year()`, `month()`, `day()`, `hour()`, `minute()`, `second()`, `week()`, `extract()`  | 提取日期分量                     |
| 日期截断   | `trunc()`                                                                              | 按精度截断（年/月/日/时/分/秒/毫秒/周/季度） |
| 月末/月初  | `last_day()`, `first_day()`                                                            | 月末/月初日期                    |

#### 5. RegexMixins（322 行）

正则表达式函数库，兼容 Oracle 正则语法：

| 分类        | 函数                                                                                                          | 说明                |
|-----------|-------------------------------------------------------------------------------------------------------------|-------------------|
| 匹配        | `regex_match()`, `regexp_match()`, `regex_contains()`, `regexp_contains()`, `regex_like()`, `regexp_like()` | 正则匹配/包含           |
| 查找        | `regex_find()`, `regex_extra()`, `regexp_extra()`, `regex_index()`, `regex_index_end()`                     | 正则查找/提取           |
| 替换        | `regex_replace()`, `regexp_replace()`                                                                       | 正则替换（支持指定第 N 次匹配） |
| 删除        | `regex_drop()`                                                                                              | 删除匹配项             |
| 分割        | `regex_split()`                                                                                             | 正则分割              |
| 组合        | `regex_find_join()`                                                                                         | 查找并拼接             |
| 截取        | `substr_regex_index()`, `substr_regex_index_end()`                                                          | 基于正则位置的截取         |
| Oracle 兼容 | `convertOracleRegexExpression()`, `convertOracleRegexReplacement()`                                         | Oracle 正则语法转换     |

#### 6. ArrayMixins（159 行）

| 函数                                                                 | 说明             |
|--------------------------------------------------------------------|----------------|
| `new_array()`, `is_array()`, `arr_len()`, `arr_get()`, `arr_set()` | 数组创建/判断/访问     |
| `arr_to_list()`, `list_to_array()`                                 | 数组↔列表转换（支持负索引） |

#### 7. CollectionMixins（85 行）

| 函数                                                                                                   | 说明      |
|------------------------------------------------------------------------------------------------------|---------|
| `new_list()`, `new_set()`, `list_of()`, `append()`                                                   | 集合创建与追加 |
| `list_get()`, `list_remove()`, `collection_contains()`, `collection_remove()`, `clear()`, `length()` | 集合操作    |
| `iterator_has()`, `iterator_next()`, `enumeration_has()`, `enumeration_next()`                       | 迭代器操作   |

#### 8. MapMixins（58 行）

| 函数                                                                                                     | 说明           |
|--------------------------------------------------------------------------------------------------------|--------------|
| `new_map()`, `map_of()`, `put()`, `map_get()`, `map_contains()`, `map_remove()`, `clear()`, `length()` | Map 创建与 CRUD |

#### 9. FileMixins（103 行）

| 函数                                                                                        | 说明      |
|-------------------------------------------------------------------------------------------|---------|
| `file()`, `file_exists()`, `is_file()`, `is_dir()`, `length()`, `list_file()`, `mkdirs()` | 文件/目录操作 |
| `read_text_file()`, `write_text_file()`                                                   | 文本文件读写  |

#### 10. SystemMixins（56 行）

| 函数                                     | 说明      |
|----------------------------------------|---------|
| `print()`, `println()`                 | 控制台输出   |
| `sys_env()`, `sys_property()`, `jvm()` | 环境/属性读取 |
| `gc()`, `exit()`                       | JVM 控制  |

#### 11. ThreadMixins（48 行）

| 函数                                        | 说明   |
|-------------------------------------------|------|
| `thread_id()`, `thread_name()`, `yield()` | 线程信息 |
| `sleep()`, `sleep_ms()`, `sleep_sec()`    | 线程休眠 |

#### 12. ThreadLocalMixins（48 行）

| 函数                                                                                                                  | 说明          |
|---------------------------------------------------------------------------------------------------------------------|-------------|
| `local_map()`, `local_get()`, `local_set()`, `local_remove()`, `local_contains()`, `local_reset()`, `local_clear()` | 线程本地 Map 操作 |

#### 13. RandomMixins（28 行）

| 函数                                                    | 说明                   |
|-------------------------------------------------------|----------------------|
| `rand()`, `rand(bound)`, `rand(min, max)`, `random()` | 随机数（基于 SecureRandom） |

#### 14. UuidMixins（22 行）

| 函数                         | 说明              |
|----------------------------|-----------------|
| `uuid()`, `snowflake_id()` | UUID / 雪花 ID 生成 |

#### 15. JvmMixins（26 行）

| 函数                                                      | 说明       |
|---------------------------------------------------------|----------|
| `jvm_pid()`, `jvm_user()`, `jvm_debug()`, `jvm_agent()` | JVM 进程信息 |

#### 16. OsMixins（22 行）

| 函数                                         | 说明     |
|--------------------------------------------|--------|
| `os_windows()`, `os_linux()`, `os_64bit()` | 操作系统检测 |

#### 17. MatchMixins（23 行）

| 函数                                                      | 说明              |
|---------------------------------------------------------|-----------------|
| `ant_match_path()`, `ant_match_pkg()`, `simple_match()` | Ant 风格 / 简单模式匹配 |

#### 18. CommandLineMixins（36 行）

| 函数                   | 说明     |
|----------------------|--------|
| `exec()`, `system()` | 执行系统命令 |

## 在 Funic / TinyScript / XProc4J 中的应用

### Funic — 代理实例注册全局函数

Funic 在**静态初始化块**中通过 `MixinProxyFactory` 获取 `AllMixins` 的代理实例，将其所有方法注册为脚本引擎的全局函数。这意味着
Funic 脚本可以直接调用 500+ 个混入函数。

```java
// Funic.java 静态初始化
static {
    ERROR_LISTENER.add(DefaultAntlrErrorListener.INSTANCE);

    // 关键：将 AllMixins 的所有方法注册为 Funic 全局函数
    registryMethods(MixinProxyFactory.getMixinInstance(AllMixins.class));
    // 同时注册 System.out 的 print 方法和 Math 类方法
    registryMethods(System.out, e -> e.getName().toLowerCase().contains("print"));
    registryMethods(Math.class, e -> !e.getName().toLowerCase().contains("extra"));
}
```

**效果**：Funic 脚本中可直接使用：

```javascript
// 字符串函数
length("hello")          // → 5
substr("hello world", 0, 5)  // → "hello"
upper("hello")           // → "HELLO"
to_camel("hello_world")  // → "helloWorld"
md5("data")              // → "8d777f385d3dfec8815d20f7496026dc"

// 数学函数
round(3.14159, 2)        // → 3.14
sqrt(16)                 // → 4.0
abs(-42)                 // → 42

// 日期函数
now()                    // → 当前时间
date_format(now(), "yyyy-MM-dd")  // → "2026-05-14"
date_add(now(), "DAYS", 7)        // → 7天后

// 正则函数
regex_match("hello123", "\\d+")   // → true
regex_find("a1b2c3", "\\d+")      // → ["1", "2", "3"]

// 对象操作
isnull(null)             // → true
coalesce(null, "", "x")  // → ""
to_number("123.45")      // → 123.45

// 集合操作
list_of(1, 2, 3)         // → [1, 2, 3]
length(list_of(1, 2, 3))   // → 3

// 系统函数
uuid()                   // → 随机UUID
rand(100)                // → 0-99随机整数
```

### TinyScript — 接口继承方式

TinyScript 采用**接口继承**方式，`TinyScriptFunctions` 直接 `extends AllMixins`，通过匿名实例获取全部函数：

```java
public interface TinyScriptFunctions extends AllMixins {
    TinyScriptFunctions INSTANCE = new TinyScriptFunctions() {
    };
}
```

**效果**：TinyScript 脚本中同样可直接调用所有混入函数。

### XProc4J 存储过程引擎 — 接口继承方式

XProc4J 的 `ContextFunctions` 同样通过继承 `AllMixins` 获取全部函数，作为存储过程执行上下文：

```java
public interface ContextFunctions extends AllMixins {
    ContextFunctions INSTANCE = new ContextFunctions() {
    };
}
```

**效果**：XProc4J XML 存储过程中，无论使用 TinyScript 还是 Funic 作为脚本语言，都可以调用全部混入函数。

### 模板引擎 — 类直接实现

Freemarker 和 Velocity 的 `GeneratorTool` 直接 `implements AllMixins`，使模板渲染时可使用混入函数：

```java
public class GeneratorTool implements AllMixins {
    // 模板中可直接调用 length(), substr(), round() 等
}
```

## 应用方式对比

| 应用             | 类                      | 方式                                                           | 说明                   |
|----------------|------------------------|--------------------------------------------------------------|----------------------|
| **Funic**      | `Funic` (static block) | `MixinProxyFactory.getMixinInstance()` + `registryMethods()` | 代理实例 → 反射注册所有方法为全局函数 |
| **TinyScript** | `TinyScriptFunctions`  | `extends AllMixins` + 匿名实例                                   | 接口继承 → 匿名实例持有所有默认方法  |
| **XProc4J**    | `ContextFunctions`     | `extends AllMixins` + 匿名实例                                   | 同 TinyScript，存储过程上下文 |
| **Freemarker** | `GeneratorTool`        | `implements AllMixins`                                       | 类直接实现，模板可用混入函数       |
| **Velocity**   | `GeneratorTool`        | `implements AllMixins`                                       | 同 Freemarker         |

## 常量与基础设施

### MixinConsts

混入体系的共享常量：

| 常量                             | 类型                                 | 说明                                      |
|--------------------------------|------------------------------------|-----------------------------------------|
| `RANDOM`                       | `SecureRandom`                     | 安全随机数生成器                                |
| `LOCAL`                        | `ThreadLocal<Map<String, Object>>` | 线程本地变量存储                                |
| `MATH_CONTEXT`                 | `MathContext(20, HALF_UP)`         | 高精度数学运算上下文                              |
| `NUM_0_5`                      | `BigDecimal("0.5")`                | 四舍五入辅助常量                                |
| `ORACLE_REGEX_REPLACE_MAPPING` | `String[][]`                       | Oracle 正则语法映射（`[:alpha:]` → `a-zA-Z` 等） |
| `CHRONO_UNIT_MAPPING`          | `String[][]`                       | 时间单位别名映射（`day`→`DAYS`, `mm`→`MONTHS` 等） |

## 源文件清单

| 文件                            | 行数   | 说明                  |
|-------------------------------|------|---------------------|
| `MixinProxyFactory.java`      | 53   | 代理工厂（核心基础设施）        |
| `all/AllMixins.java`          | 29   | 全量聚合接口（继承 18 个混入接口） |
| `consts/MixinConsts.java`     | 62   | 共享常量                |
| `impl/StringMixins.java`      | 1234 | 字符串函数（最大）           |
| `impl/ObjectMixins.java`      | 457  | 对象通用操作              |
| `impl/MathMixins.java`        | 417  | 数学运算                |
| `impl/DateMixins.java`        | 363  | 日期时间                |
| `impl/RegexMixins.java`       | 322  | 正则表达式               |
| `impl/ArrayMixins.java`       | 159  | 数组操作                |
| `impl/FileMixins.java`        | 103  | 文件操作                |
| `impl/CollectionMixins.java`  | 85   | 集合操作                |
| `impl/MapMixins.java`         | 58   | Map 操作              |
| `impl/SystemMixins.java`      | 56   | 系统操作                |
| `impl/ThreadMixins.java`      | 48   | 线程操作                |
| `impl/ThreadLocalMixins.java` | 48   | 线程本地变量              |
| `impl/CommandLineMixins.java` | 36   | 命令行执行               |
| `impl/RandomMixins.java`      | 28   | 随机数                 |
| `impl/JvmMixins.java`         | 26   | JVM 信息              |
| `impl/MatchMixins.java`       | 23   | 模式匹配                |
| `impl/UuidMixins.java`        | 22   | UUID 生成             |
| `impl/OsMixins.java`          | 22   | 操作系统信息              |
| `test/TestMixins.java`        | 20   | 测试用例                |

## 设计特点

1. **接口默认方法 = 零副作用混入**：所有方法均为 `default` 实现，混入后不影响原有类行为
2. **代理工厂避免匿名对象**：`MixinProxyFactory` 通过 JDK 动态代理 + `ConcurrentHashMap` 缓存，全局只创建一次代理实例
3. **脚本引擎内建函数库**：Funic/TinyScript/XProc4J 通过混入获得 500+ 个内建函数，无需额外注册
4. **跨接口互调**：混入接口之间通过 `MixinProxyFactory` 互相调用，形成协作网络（如 `StringMixins.to_char()`
   调用 `DateMixins.date_format()`）
5. **Oracle 兼容性**：正则函数内置 Oracle 正则语法转换（`[:alpha:]` → `a-zA-Z`），日期函数支持 Oracle 风格 trunc 格式
6. **SQL 风格函数命名**：`nvl()`, `decode()`, `coalesce()`, `nullif()`, `substr()`, `instr()` 等，与 SQL 函数保持一致
7. **高精度数学运算**：基于 `BigDecimal` + `MathContext(20, HALF_UP)`，避免浮点精度丢失
