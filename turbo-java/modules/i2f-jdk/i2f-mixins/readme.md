# i2f-mixins 混入式函数编程工具箱

## 概述

`i2f-mixins` 是 i2f-turbo-java 框架中基于 **JDK 接口默认方法（default method）** 实现的混入式（mixin）函数编程工具集（22 源文件约 3900 行）。它通过接口提供一系列具有默认实现的方法，使使用者可以通过实现（或代理）接口获得完整的函数式编程环境，变相实现 Java 的"多重继承"。

### 设计动机

- 传统 Java 仅允许单继承，通过接口默认方法可以在不引入复杂继承层次的前提下为类附加一组行为
- 所有方法均为默认实现，混入后无副作用
- 提供 `MixinProxyFactory` 基于 JDK 动态代理生成接口实例，无需创建匿名对象

### 子领域概览

| 子领域 | 接口 | 行数 | 方法数 |
|--------|------|------|--------|
| 字符串处理 | `StringMixins` | 1258 | ~70+ |
| 数学运算 | `MathMixins` | 625 | ~50+ |
| 通用对象 | `ObjectMixins` | 457 | ~30+ |
| 日期时间 | `DateMixins` | 363 | ~20+ |
| 正则匹配 | `RegexMixins` | 322 | ~20+ |
| 数组操作 | `ArrayMixins` | 159 | ~15+ |
| 文件IO | `FileMixins` | 103 | ~10 |
| 集合操作 | `CollectionMixins` | 85 | ~10 |
| Map操作 | `MapMixins` | 58 | ~7 |
| 系统控制 | `SystemMixins` | 56 | ~8 |
| JDK动态代理工厂 | `MixinProxyFactory` | 53 | 3 |
| 常量定义 | `MixinConsts` | 62 | — |
| 线程操作 | `ThreadMixins` | 48 | ~7 |
| 线程本地变量 | `ThreadLocalMixins` | 48 | ~7 |
| 命令行执行 | `CommandLineMixins` | 36 | 4 |
| 随机数 | `RandomMixins` | 28 | 4 |
| JVM信息 | `JvmMixins` | 26 | 4 |
| 通配匹配 | `MatchMixins` | 23 | 3 |
| OS判定 | `OsMixins` | 22 | 3 |
| UUID生成 | `UuidMixins` | 22 | 2 |
| 聚合接口 | `AllMixins` | 29 | 聚合 18 个接口 |

## 依赖关系

| 依赖类型 | 坐标 | 说明 |
|---------|------|------|
| 编译 | `i2f.turbo:i2f-jdk` (parent) | 仅继承父 POM 版本管理 |
| compile | `i2f.turbo:i2f-proxy-std` | `MixinProxyFactory` 使用 `DefaultMethodSmartInvocationHandler` |
| compile | `i2f.turbo:i2f-reflect` | `ObjectMixins` 使用 `ReflectResolver`/`Visitor` |
| compile | `i2f.turbo:i2f-convert` | 广泛使用 `ObjectConvertor`（类型转换/数字运算/日期解析） |
| compile | `i2f.turbo:i2f-text` | `StringMixins` 使用 `StringUtils` |
| compile | `i2f.turbo:i2f-match` | `RegexMixins` 使用 `RegexUtil`; `MatchMixins` 使用 `AntMatcher`/`SimpleMatcher` |
| compile | `i2f.turbo:i2f-io-stream` | `FileMixins` 使用 `StreamUtil` |
| compile | `i2f.turbo:i2f-uid-impl` | `UuidMixins` 使用 `SnowflakeLongUid` |
| compile | `i2f.turbo:i2f-jvm` | `JvmMixins` 使用 `JvmUtil` |
| compile | `i2f.turbo:i2f-os` | `OsMixins` 使用 `OsUtil` |
| compile | `i2f.turbo:i2f-math` | `MathMixins` 使用 `Fibonacci`/`Factorial`/`HexNumberConverter` |
| provided | `org.projectlombok:lombok` | 声明未实际使用 |

> 全模块真实运行期依赖 10 个 i2f 内部模块，是 i2f-jdk 中**依赖最密集**的模块之一。

## 包结构

```
i2f.mixin
├── MixinProxyFactory.java       # JDK动态代理工厂
├── all/
│   └── AllMixins.java           # 聚合全部18个Mixins接口
├── consts/
│   └── MixinConsts.java         # 共享常量（SecureRandom/ThreadLocal/MathContext/Oracle正则映射/ChronoUnit映射）
├── impl/
│   ├── StringMixins.java        # 字符串处理（1258行）
│   ├── MathMixins.java          # 数学运算（625行）
│   ├── ObjectMixins.java        # 通用对象（457行）
│   ├── DateMixins.java          # 日期时间（363行）
│   ├── RegexMixins.java         # 正则匹配（322行）
│   ├── ArrayMixins.java         # 数组操作（159行）
│   ├── FileMixins.java          # 文件IO（103行）
│   ├── CollectionMixins.java    # 集合操作（85行）
│   ├── MapMixins.java           # Map操作（58行）
│   ├── SystemMixins.java        # 系统控制（56行）
│   ├── ThreadMixins.java        # 线程操作（48行）
│   ├── ThreadLocalMixins.java   # 线程本地变量（48行）
│   ├── CommandLineMixins.java   # 命令行执行（36行）
│   ├── RandomMixins.java        # 随机数（28行）
│   ├── JvmMixins.java           # JVM信息（26行）
│   ├── MatchMixins.java         # 通配匹配（23行）
│   ├── OsMixins.java            # OS判定（22行）
│   └── UuidMixins.java          # UUID生成（22行）
└── test/
    └── TestMixins.java          # 演示/测试
```

## 使用方式

### 方式一：通过代理工厂获取（推荐）

```java
import i2f.mixin.MixinProxyFactory;
import i2f.mixin.all.AllMixins;

AllMixins mixins = MixinProxyFactory.getMixinInstance(AllMixins.class);
// 立即获得所有 mixin 方法的访问权限
String name = mixins.to_pascal("hello_world");   // HelloWorld
String joined = mixins.join(",", 1, 2, 3);        // 1,2,3
mixins.println("hello", "world");                  // 控制台输出
```

`MixinProxyFactory.getMixinInstance(Class)` 使用 `ConcurrentHashMap` 缓存，同一接口类仅创建一次代理实例。

### 方式二：匿名对象（不推荐）

```java
AllMixins mixins = new AllMixins() {};
```

每次创建新匿名对象，不利于管理和性能。

## 子领域详解

### 1. StringMixins 字符串处理（1258 行，~70+ 方法）

| 功能组 | 方法 | 说明 |
|--------|------|------|
| 字符/符号生成 | `newline()`/`sharp()`/`dollar()` | 生成换行符/井号/美元符号 |
| 空值判定 | `is_empty(str)`/`not_empty(str)`/`if_empty(obj,def)` | 委托 `StringUtils.isEmpty` |
| 格式化/拼接 | `format(fmt,obj...)`/`append(Appendable,objs...)` | `String.format`/Appendable 链式追加 |
| 命名风格转换 | `to_pascal/camel/underscore/snake/property/path/colon_case(str)` | 7 种命名风格互转 |
| 大小写/首字母 | `upper/lower`/`first_upper/first_lower`/`init_capital` | 全大写/小写/首字母 |
| 修剪 | `trim`/`ltrim`/`rtrim`(支持指定子串) | 两端/左/右修剪 |
| 填充 | `lpad`/`rpad(str,len,padStr?)` | 左/右填充到指定长度 |
| 子串提取 | `left/right`/`substr/substring`/`substrb`(字节感知) | 负索引支持 |
| 查找 | `index_of/last_index_of/contains/instr` | 字符串查找 |
| 拼接 | `join(obj,sep,ignoreNull,ignoreEmpty)`/`concat/concat_ws` | 数组/Map/Iterable/Iterator/Enumeration 通用 |
| 替换 | `replace/remove`/`escape_sql_string/descape_sql_string` | SQL 转义 |
| 编解码 | `to_url_encoded/to_base64/escape_sql_string` | URL/Base64/SQL |
| Oracle兼容 | `to_char(obj,pattern)` | 支持 Oracle 数字格式 `99999.99`/`fm99999.99` |
| 其他 | `repeat/trim_empty_lines/init_capital`/`substr_count/substr2_index` | 计数/子串定位 |

### 2. MathMixins 数学运算（625 行，~50+ 方法）

| 功能组 | 方法 | 说明 |
|--------|------|------|
| 基本算术(primitive) | `add/sub/mul/div/mod/pow/sqrt/log` | 基于 `double` 的直接运算 |
| 基本算术(Object) | `add/sub/mul/div/mod/pow/sqrt/ln` | 基于 `BigDecimal` + `ObjectConvertor` 的安全泛型运算，自动保持输入类型 |
| 三角函数 | `sin/cos/tan/asin/acos/atan` | 委托 `Math.*`，经 BigDecimal 中转保类型 |
| 舍入/截断 | `round(n,prec?)`/`trunc(n,prec?)` | 四舍五入/截断，prec<0 整数级 |
| 进制转换 | `from_radix(str,radix)`/`to_radix(num,radix)` | 2-36 进制互转 |
| 弧角互转 | `to_radians/to_degrees` | 角度↔弧度 |
| 数列 | `fibonacci/factorial` | 委托 `i2f-math` 的缓存实现 |
| 聚集 | `max_of/min_of/avg_of/sum_of` | 变长参数/Iterable 通用，保持输入类型 |

### 3. ObjectMixins 通用对象（457 行，~30+ 方法）

| 功能组 | 方法 | 说明 |
|--------|------|------|
| 类型转换 | `to_number/int/long/boolean/date` | 安全类型转换，支持多种输入类型 |
| 空值判定 | `isnull/not_null/is_empty(多类型)/is_blank` | String/Collection/Map/Array/Iterator/Enumeration 通用判空 |
| 长度 | `length(obj)`/`lengthb(obj)`(UTF-8字节长度) | 支持 String/Collection/Map/Array |
| 条件选择 | `ifnull/nvl`/`if_empty/evl`/`if_blank/bvl`/`if2/nvl2` | 各类 null/空/空白 兜底 |
| 聚合选择 | `coalesce/nullif`/`coalesce_empty`/`decode` | 首非空/相等归零/switch-case |
| 类型转换 | `cast/convert(val,type)` | 类名(Class/字符串) + `ObjectConvertor` 通用转换 |
| 访问者 | `visit_get/set/del(obj,expression)` | 委托 `i2f-reflect.Visitor` 的表达式访问 |
| 比较 | `compare`(六级级联)/`cmp_eq/neq/gt/lt/gte/lte` | 六种比较操作 |
| 通用截断 | `trunc(obj)` | 数字 → 小数截断，日期 → 日期截断 |

`ObjectMixins.compare()` 的六级级联比较策略：引用相等 → null 哨兵 → 同类Comparable → 类型兼容 → 数字BigDecimal精比 → 日期Date.compareTo → 布尔Boolean.compareTo → 字符串字典序 → 兜底Comparable → hashCode。

### 4. DateMixins 日期时间（363 行，~20+ 方法）

| 功能组 | 方法 | 说明 |
|--------|------|------|
| 当前时间 | `current_time_millis/seconds`/`sysdate/now/timestamp` | 系统时间与 `SystemClock` 时间 |
| 时间戳互转 | `timestamp_to_date/date_to_timestamp` | 秒级时间戳 ↔ Date |
| 日期转换 | `to_date/str_to_date/parse_date/date_format` | 字符串 ↔ Date，多模式 |
| 日期算术 | `date_add/date_sub/add_months/add_days/next_day/months_between` | 基于 `ChronoUnit` + `LocalDateTime` |
| 日期间隔 | `last_day/months_between/next_day` | 月末/月间隔/下个工作日 |
| 单位映射 | `chrono_unit(unit)` | 别名 → `ChronoUnit`（`dd→DAYS`, `mon→MONTHS` 等 22 种别名） |

### 5. RegexMixins 正则匹配（322 行，~20+ 方法）

| 功能组 | 方法 | 说明 |
|--------|------|------|
| Oracle方言转换 | `convertOracleRegexExpression/Replacement` | 将 Oracle POSIX 正则（`[:digit:]` 等）转为 Java 标准正则 |
| 替换 | `regex_replace/regexp_replace(occurrence?)` | 支持指定第几次出现替换 |
| 匹配 | `regex_match/regexp_match` | 全匹配 |
| 包含 | `regex_contains/regexp_contains/regex_like/regexp_like` | 部分匹配 |
| 查找 | `regex_find/regex_index/regexp_index/regex_index_end` | 索引位置 |
| 提取 | `regex_extra(str,regex,index?)` | 提取第 index 个分组 |
| 计数 | `regex_count` | 匹配次数 |
| 分割 | `split_literal(str,delimiter)` | 字面量分割 |

### 6. ArrayMixins 数组操作（159 行，~15+ 方法）

| 方法 | 说明 |
|------|------|
| `new_array(elemType,len)` | 反射创建数组 |
| `is_array(arr)` | 判定是否为数组 |
| `arr_len(arr)` | 数组长度 |
| `arr_get/set(arr,index,value?)` | 读写元素（支持负索引） |
| `arr_to_list(arr, elemType?, index?, len?)` | 数组 → List，支持元素类型转换、范围切片 |
| `list_to_array(collection, elemType?, index?, len?)` | Iterable → 数组，支持范围切片 |

### 7. FileMixins 文件IO（103 行）

| 方法 | 说明 |
|------|------|
| `file(path)`/`file_exists`/`is_file`/`is_dir` | 文件路径判定 |
| `length(file)`/`list_file` | 文件大小/子文件列表 |
| `mkdirs(path)` | 创建目录 |
| `read_text_file(path, charset?)`/`write_text_file(path, content, charset?)` | 读写文本文件 |

### 8. 小型 Mixin 接口一览

| 接口 | 方法 | 功能 |
|------|------|------|
| `CollectionMixins` | `new_list/set`/`append`/`list_of`/`list_get`/`collection_contains/remove`/`list_remove`/`iterator_has/next`/`enumeration_has/next`/`clear` | 集合操作 |
| `MapMixins` | `new_map`/`put`/`map_get/contains/remove/clear/length`/`map_of(key,val...)` | Map操作 |
| `SystemMixins` | `print/println`/`sys_env/jvm/sys_property`/`gc/exit` | 系统控制 |
| `ThreadMixins` | `thread_id/name`/`yield`/`sleep_ms/sleep_sec` | 线程操作 |
| `ThreadLocalMixins` | `local_map/get/set/remove/contains/reset/clear` | 线程本地变量 |
| `CommandLineMixins` | `exec/system(cmd)` | 命令行执行 |
| `RandomMixins` | `rand()/rand(bound)/rand(min,max)`/`random()` | 随机数（基于 SecureRandom） |
| `JvmMixins` | `jvm_pid/user/debug/agent` | JVM信息 |
| `OsMixins` | `os_windows/linux/64bit` | OS判定 |
| `MatchMixins` | `ant_match_path/pkg(text,pattern)`/`simple_match` | 通配匹配 |
| `UuidMixins` | `uuid()`/`snowflake_id()` | UUID/雪花ID |

## 已知瑕疵

1. **`StringMixins.substr_count` L965 变量名笔误**：`String.valueOf(obj)` 赋值给 `sstr`（应为 `substr` 参数值），导致计算的是字符串自身与自身的出现次数，而非与 `substr` 参数比较。
2. **`MathMixins.min_of` L554 与 `max_of` 不对称**：`min_of` 中 `originRet = item` 应为 `originRet = number`，与 `max_of` 的 `originRet = number` 不一致，但影响仅在于返回原始类型而非转换类型。
3. **`CommandLineMixins.exec` 异常处理不完善**：异常仅 `printStackTrace()`，未包装或抛出，调用者无法感知执行失败。
4. **`StringMixins.to_char` Oracle 格式溢出时**：返回 `#` 填充字符串不区分溢出方向。
5. **`RegexMixins` 大量 `regex_*`/`regexp_*` 别名方法**：造成方法名膨胀（约 10 组别名），实际仅调用同一实现。
6. **`MixinProxyFactory.findInterfaces` 不考虑接口泛型参数**：`Class.getInterfaces()` 仅返回原始类型，不包含类型参数信息。