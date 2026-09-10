# i2f-form-url-encoded

> **form-urlencoded 编解码器 + URI 结构化解析器**（5 源文件约 750 行，主类 2 个）：
>
> - `FormUrlEncodedEncoder`（185 行）：以 `ObjectRouteResolver` 的**点号路径扁平化协议**（`user.roles[0].name=admin`）为基础，实现「任意 Java 对象 / 嵌套 Map / 集合 ↔ form-urlencoded 字符串」的双向转换，并可直接将 form 串还原为目标 Bean、泛型 `TypeToken` 或 `Type`；
> - `UriMeta`（447 行）：9 字段 URI 结构模型（schema/user/password/host/port/path/query/hash），以「前缀路由 + 专用解析器」手动状态机解析 8 类 URI 方言（通用 `http(s)`/`jdbc:*` 类、`file:`、`jar:file:`、`git@` scp 风格、Oracle SID、SQLServer、H2、SQLite；另有 2 个 Oracle 变体解析器已实现但未接入路由），并以 `hashBefore` 开关支持 `?query#hash` 与 `#hash?query`（SPA 路由风格）两种输出顺序。
>
> 该模块是 **SWL 安全传输体系的序列化底座**：加密请求头 `SwlHeader` 的序列化/反序列化（`serializeHeader`/`deserializeHeader`）与解密后参数串的解析（`toMap`）均依赖它；同时被 HTTP 客户端（`HttpUtil`/OkHttp/SpringWeb）用于表单体与 URL query 拼接，被数据库元数据模块用于 JDBC URL 解析。

## 模块定位

| 项 | 值 |
|---|---|
| Maven 坐标 | `i2f.turbo:i2f-form-url-encoded`（父模块 `i2f-jdk`） |
| 包根 | `i2f.url`（主类）、`i2f.url.test`（手工测试） |
| 源文件 | 5 个：2 个主类约 632 行 + 3 个手工测试约 121 行，合计约 750 行 |
| 声明依赖 | 3 个：`lombok`、`i2f-reflect`、`i2f-text`（**全部真实使用**） |
| 打包 | `maven-assembly-plugin`（fat-jar） |
| 模块注册 | `i2f-jdk/pom.xml` L77（modules）、`i2f-jdk-all/pom.xml` L257（聚合）、根 `pom.xml` L421（版本托管） |
| 状态 | **活跃**：被 6 个模块的 9 个文件真实消费（含 SWL 头部序列化核心链路） |

## 依赖关系

| 依赖 | 用途 | 真实使用点 | 类型 |
|---|---|---|---|
| `lombok` | `@Data` / `@NoArgsConstructor` | `UriMeta`、`TestFormBean` | 声明且使用 |
| `i2f-reflect` | `ObjectRouteResolver`（routeMap/flatMap/mapTree 互转）、`RichConverter`（宽松递归转换） | `FormUrlEncodedEncoder` 全链路 | 声明且使用 |
| `i2f-text` | `StringUtils.isEmpty` | `UriMeta.toUrlString` 空判断 | 声明且使用 |
| `i2f-convert` | `ObjectConvertor.isBooleanType/isNumericType/isCharType/isDateType/tryConvertAsType` | `FormUrlEncodedEncoder.toForm` 值分类、Date 转换 | **隐式传递**（经 `i2f-reflect`） |
| `i2f-typeof` | `TypeOf.isBaseType/typeOfAny/typeOf`、`TypeToken` | `FormUrlEncodedEncoder` 值分类、泛型转换重载 | **隐式传递**（经 `i2f-reflect`） |

> 说明：`i2f-reflect` 声明依赖 `i2f-lru-map`、`i2f-convert`、`i2f-typeof`、`i2f-invokable`，其中 `i2f-convert` 与 `i2f-typeof` 为本模块编译期实际使用（`ObjectConvertor`/`TypeOf`/`TypeToken`），但本模块 POM 未显式声明，属**隐式传递依赖**（若上游调整传递链会编译失败）。

## 包结构

```
i2f.url
├── FormUrlEncodedEncoder                 form-urlencoded 编解码门面（静态工具类）
├── UriMeta                               URI 9 字段结构模型 + 多方言解析/还原
└── test
    ├── TestFormBean                      嵌套 Bean 样例（含 List<RoleItem> 两层嵌套）
    ├── TestFormUrlEncoded                手工 main 验证：toForm / ofFormMapTree / ofFormBean
    └── TestUriMeta                       手工 main 验证：23 个真实 URI 样例 parse→toUrlString
```

## 类结构

| 类 | 行数 | 职责 | 关键成员 |
|---|---|---|---|
| `FormUrlEncodedEncoder` | 185 | 对象 ↔ form-urlencoded 双向转换 | `toForm`、`ofFormBean`×6（Class/TypeToken/Type × 有无 keyMapper）、`ofFormMapTree`、`toMap` |
| `UriMeta` | 447 | URI 结构模型 + 多方言解析路由 + 专用还原方法族 | `parse`×3、10 个 `parseXxx`（含 `parseCommon`，其中 2 个未接入路由）、`toUrlString(hashBefore)`、10 个 `toUrlStringXxx`（其中 1 个不可达）、`toURL`×2、`toURI`×2 |
| `TestFormBean` | 29 | 嵌套样例 Bean（`username/password/roles[].perms[]`） | 内部类 `RoleItem` |
| `TestFormUrlEncoded` | 41 | 手工测试 | `main` |
| `TestUriMeta` | 51 | 手工测试（23 个真实 URL 样例） | `main` |

## 架构总览

```mermaid
flowchart LR
    subgraph SER["序列化 toForm"]
        A["Java 对象<br/>Bean / Map / 集合"] --> B["ObjectRouteResolver<br/>.toRouteMap"]
        B --> C["扁平 routeMap<br/>user.roles[0].name=admin"]
        C --> D{"值类型分类"}
        D -->|"null"| D1["key="]
        D -->|"基础/布尔/数值/字符"| D2["String.valueOf"]
        D -->|"Date"| D3["yyyy-MM-dd HH:mm:ss SSS"]
        D -->|"CharSequence/URL/URI"| D4["String.valueOf"]
        D -->|"Charset"| D5[".name()"]
        D -->|"Class"| D6[".getName()"]
        D -->|"兜底"| D7["toString"]
        D1 & D2 & D3 & D4 & D5 & D6 & D7 --> E["URLEncoder.encode(UTF-8)<br/>拼接 a=1&b=2"]
    end
    subgraph DES["反序列化 ofFormBean"]
        E --> F["toMap<br/>key→List 值（TreeMap）"]
        F --> G["ObjectRouteResolver.toFlatMap<br/>多值→key[i]"]
        G --> H["ObjectRouteResolver.ofMapTree<br/>点号分段重建树"]
        H --> I["RichConverter.convert<br/>宽松递归映射 Bean"]
        I --> J["目标对象<br/>Class / TypeToken / Type"]
    end
```

```mermaid
flowchart TD
    U["URI 字符串"] --> P{"parse() 前缀路由"}
    P -->|"file:"| F1["parseFile"]
    P -->|"jar:file:"| F2["parseJarFile"]
    P -->|"git@"| F3["parseGit<br/>scp 风格 git@gitee.com:user/repo.git"]
    P -->|"jdbc:oracle:thin:@"| F4["parseJdbcOracleBySid<br/>⚠ 同时吞掉 Sid2/ServiceName 形式导致崩溃"]
    P -->|"jdbc:sqlserver://"| F5["parseJdbcSqlserver<br/>⚠ 无 ; 参数时崩溃"]
    P -->|"jdbc:h2:file:"| F6["parseJdbcH2File"]
    P -->|"jdbc:sqlite:"| F7["parseJdbcSqlite"]
    P -->|"默认（含 http/https/jdbc:mysql 等）"| F8["parseCommon<br/>手动状态机"]
    F1 & F2 & F3 & F4 & F5 & F6 & F7 & F8 --> M["UriMeta 9 字段模型"]
    M --> O1["toUrlString(hashBefore)<br/>? 与 # 顺序可切换"]
    M --> O2["toUrlStringXxx × 10<br/>按 schema 分发"]
    M --> O3["toURL / toURI<br/>仅标准协议可用"]
```

## 核心类详解

### FormUrlEncodedEncoder——对象 ↔ form 串双向转换

**序列化 `toForm(Object)`**：

1. 先经 `ObjectRouteResolver.toRouteMap(obj)` 将对象递归展开为**扁平路径 Map**（`LinkedHashMap`，保序）：
   - Map → `path.key` 递归；Collection/数组 → `path[i]` 递归；
   - 基础类型 / 布尔 / 数值 / 字符 / Date / CharSequence / URL / URI / Charset / Class 作为叶子节点直接入 Map；
   - 其余按字段反射展开。
2. 逐条对 key、value 分别 `URLEncoder.encode(UTF-8)`，以 `&key=value` 拼接，最终去掉首个 `&`。
3. 值类型分类处理（与 `toRouteMap` 的叶子判定一一对应）：

| 值类型 | 编码方式 |
|---|---|
| `null` | 输出 `key=`（空值） |
| 基础类型 / 布尔 / 数值 / 字符 | `String.valueOf` → URL 编码 |
| `Date`（含子类） | 先经 `ObjectConvertor.tryConvertAsType` 转 `Date`，格式化为 `yyyy-MM-dd HH:mm:ss SSS` → URL 编码 |
| `CharSequence` / `URL` / `URI` | `String.valueOf` → URL 编码 |
| `Charset` | `charset.name()` → URL 编码 |
| `Class` | `clazz.getName()` → URL 编码 |
| 兜底 | `toString` → URL 编码 |

**反序列化三连**：

```
ofFormBean(str, target, keyMapper?)
  ├─ toMap(str)                       → TreeMap<String, List<String>>（&切分、=二分、URLDecoder）
  ├─ ObjectRouteResolver.toFlatMap    → TreeMap<String, String>（多值展开为 key[0]、key[1]…；单值保留原 key）
  ├─ ObjectRouteResolver.ofMapTree    → 按 "." 分段重建嵌套树；key[n] 结尾归入 List
  └─ RichConverter.convert/convert2Type → 宽松递归映射（字段名匹配即可，支持泛型）
```

三个目标类型重载：`Class<T>`（`convert`）、`TypeToken<T>`（`convert`，保留泛型）、`Type`（`convert2Type`，支持 `ParameterizedType`/`GenericArrayType`）；每个重载均提供带 `keyMapper`（单段 key 前缀映射函数，作用于每一层路径段）的变体。`ofFormMapTree` 则直接返回中间态 `Map<String, Object>` 树（不做 Bean 转换）。

**解析 `toMap(String)` 细节**：`&` 切分 → `=` 二分（`split("=", 2)`，value 可含 `=`）→ key/value 分别 `URLDecoder.decode(UTF-8)` → 归入 `TreeMap<String, List<String>>`（同名 key 多值累积为 List）。

**路径协议**（由 `ObjectRouteResolver` 定义，本模块是其主要消费者）：

```
user.username=admin
user.age=12
user.roles[0].name=admin
user.roles[0].perms[1]=index
```

### UriMeta——URI 结构模型与多方言解析

**字段模型**（9 字段，`@Data` 全公开读写）：

| 字段 | 含义 | 默认值 |
|---|---|---|
| `uri` | 原始 URI 串（仅 `parseCommon` 会写入） | null |
| `schema` | 协议前缀（含 `://` 或 `:`，如 `https://`、`jdbc:sqlite:`、`git@`） | null |
| `user` / `password` | 认证信息（`user:password@host` 段） | null |
| `host` | 主机（IPv6 保留 `[...]` 括号） | null |
| `port` | 端口 | `-1`（无端口） |
| `path` | 路径 | null |
| `query` | `?` 之后片段（不含 `?`） | null |
| `hash` | `#` 之后片段（不含 `#`） | null |

**解析路由**（`parse(String)` 前缀判别顺序）：

| 前缀 | 处理 | 示例 |
|---|---|---|
| `file:` | `parseFile` | `file:/D:/output/doc.html` |
| `jar:file:` | `parseJarFile` | `jar:file:/path/to/x.jar!/com/user/Test.class` |
| `git@` | `parseGit` | `git@gitee.com:ice2faith/i2f-turbo-java.git` |
| `jdbc:oracle:thin:@` | `parseJdbcOracleBySid` | `jdbc:oracle:thin:@localhost:1521:orcl` |
| `jdbc:sqlserver://` | `parseJdbcSqlserver` | `jdbc:sqlserver://localhost:1433;databaseName=test_db` |
| `jdbc:h2:file:` | `parseJdbcH2File` | `jdbc:h2:file:../xxl-job-meta/h2/xxl_job.h2.db` |
| `jdbc:sqlite:` | `parseJdbcSqlite` | `jdbc:sqlite:../meta/xxl_job.db` |
| 其余（`http/https/jdbc:mysql/jdbc:dm` 等） | `parseCommon` 手动状态机 | `https://user:pwd@host:8443/path?query#hash` |

> **未接入路由的专用解析器**：`parseJdbcOracleBySid2`（`@host:port/sid` 斜杠形式）与 `parseJdbcOracleByServiceName`（`@//host:port/service` 形式）实现正确但**不可达**——`parse()` 中 `jdbc:oracle:thin:@` 前缀分支会抢先匹配这两种形式并交给 `parseJdbcOracleBySid`，导致崩溃（详见缺陷 #1）。

**`parseCommon` 状态机**（`schema://user:password@host:port/path?query#hash`）：

1. 切 `://` 得 schema，无 `://` 直接抛 `IllegalArgumentException("un-recognize uri schema!")`；
2. 在剩余串中以 `min(/ 位置, ? 位置, # 位置)` 切出 domain 段；
3. domain 内 `@` 切认证信息（`user[:password]`），再 `lastIndexOf(":")` 切 host/port（port 为 `Integer.parseInt`）；
4. 剩余部分按 `?`/`#` 出现顺序重建 path/query/hash，且**支持 `#` 在 `?` 之前**（`#/login?type=wechat`）与之后（`?type=wechat#/login`）两种书写，均能正确归位。

**输出还原**：

- `toUrlString()` / `toUrlString(hashBefore)`：schema 为空时原样返回 `uri`；否则按 schema 分发到 10 个 `toUrlStringXxx`（9 个专用 + `toUrlStringCommon`；其中 `toUrlStringJdbcOracleSid2` 因 schema 判别缺失不可达）；
- `hashBefore` 控制 `query` 与 `hash` 的输出顺序：`false` → `?query#hash`（常规）；`true` → `#hash?query`（SPA hash 路由风格）；
- `toURL()` / `toURI()`：`new URL/URI(toUrlString())`，仅对标准协议（http/file 等）可用，`git@`、`jdbc:` 等会抛 `MalformedURLException`/`URISyntaxException`。

## 消费关系（全仓）

| 模块 | 消费文件 | 使用方式 | 依赖声明 |
|---|---|---|---|
| `i2f-network` | `HttpUtil.generateUrlEncodeString` | `toForm(params)` 拼接 URL query（GET 参数） | 直接声明 |
| `i2f-database-metadata-impl` | `BaseDatabaseMetadataProvider.detectStandardDefaultDatabase` | `UriMeta.parse(jdbcUrl)` 取 path 作默认库名 | 直接声明 |
| `i2f-database-metadata-impl` | `OracleDatabaseMetadataProvider.detectDefaultDatabase` | `parseJdbcOracleBySid` 取 path 作库名 | 同上 |
| `i2f-database-metadata-impl` | `SqlServerDatabaseMetadataProvider.detectDefaultDatabase` | `parseJdbcSqlserver` + `ofFormMapTree(query)` 取 `databaseName` | 同上 |
| `i2f-jdk-ext-swl` | `SwlWebFilter`（4 处） | `toMap`（解密参数解析）+ `ofFormBean`/`toForm`（`SwlHeader` 头部序列化对） | 直接声明 |
| `i2f-extension-okhttp` | `OkHttpFormRequestBodyHandler.writeBody` | `toForm(data)` 生成表单请求体 | 直接声明 |
| `i2f-spring-web` | `SpringWebRestClient.rest` | `toForm(rawParams)` 拼接 query | **隐式传递**（经 `i2f-network`） |
| `i2f-springcloud-gateway-swl-starter` | `SwlGatewayFilter`（3 处） | 同 SwlWebFilter（Gateway 版头部序列化） | **隐式传递**（经 `i2f-jdk-ext-swl`） |
| `i2f-springboot-swl-starter` | — | **无源码级使用**（声明未用，疑似为下游传递保留） | 声明未用（POM L110） |
| `test-secure` | — | **无源码级使用** | 声明未用（POM L37） |

> **最大消费场景**：SWL 安全体系——`SwlHeader`（timestamp/nonce/randomKey/sign/digital/certId）经 `toForm` → Base64 → 混淆加密后放入 `swl` 请求头，服务端逆向 `deserializeHeader` 还原，是加密头部的序列化底座。

## 使用示例

**1. Bean ↔ form 串**

```java
TestFormBean bean = new TestFormBean();
bean.setUsername("admin");
bean.setPassword("123456");
// roles[0].id=1&roles[0].key=admin&…（点号路径扁平化）
String form = FormUrlEncodedEncoder.toForm(bean);

// 还原为 Bean（字段名匹配即可，支持嵌套 List）
TestFormBean back = FormUrlEncodedEncoder.ofFormBean(form, TestFormBean.class);
// 先还原中间态树（Map<String,Object>）
Map<String, Object> tree = FormUrlEncodedEncoder.ofFormMapTree(form);
// 还原为泛型类型
List<TestFormBean> list = FormUrlEncodedEncoder.ofFormBean(form, new TypeToken<List<TestFormBean>>() {});
```

**2. 拼 URL query（HttpUtil 同款）**

```java
Map<String, Object> params = new LinkedHashMap<>();
params.put("page", 1);
params.put("keyword", "中文 搜索");   // 空格编码为 +，中文为 %XX
String query = FormUrlEncodedEncoder.toForm(params);   // page=1&keyword=%E4%B8%AD%E6%96%87+%E6%90%9C%E7%B4%A2
String url = "http://api.example.com/list?" + query;
```

**3. 加密头序列化（SWL 体系同款）**

```java
SwlHeader header = new SwlHeader();
header.setTimestamp(String.valueOf(System.currentTimeMillis()));
header.setNonce("random-nonce");
header.setCertId("cert-1");

String encoded = FormUrlEncodedEncoder.toForm(header);          // 序列化
SwlHeader decoded = FormUrlEncodedEncoder.ofFormBean(encoded, SwlHeader.class);  // 反序列化
```

**4. JDBC URL 解析**

```java
UriMeta meta = UriMeta.parse("jdbc:mysql://localhost:3306/xxl_job?useUnicode=true&characterEncoding=UTF-8");
meta.getHost();    // localhost
meta.getPort();    // 3306
meta.getPath();    // /xxl_job
meta.getQuery();   // useUnicode=true&characterEncoding=UTF-8

// Oracle SID 标准形式（冒号分隔）
UriMeta oracle = UriMeta.parse("jdbc:oracle:thin:@localhost:1521:orcl");  // host=localhost, port=1521, path=orcl
// ⚠ 切勿对 ServiceName（@//）与 Sid2（@host:port/sid 斜杠）形式走 parse()——会崩溃，见缺陷 #1
```

**5. `#` 路由风格往返（SPA）**

```java
String spa = "http://192.168.1.100:9600/web/#/login/custom?type=wechat&code=123456";
UriMeta meta = UriMeta.parse(spa);
meta.getHash();    // /login/custom
meta.getQuery();   // type=wechat&code=123456
meta.toUrlString(true);   // 保持 # 在前：#/login/custom?type=wechat&code=123456
meta.toUrlString(false);  // 常规风格：?type=wechat&code=123456#/login/custom
```

## 已知缺陷

| # | 级别 | 位置 | 问题 |
|---|---|---|---|
| 1 | **严重** | `UriMeta.parse` / L44 | Oracle `jdbc:oracle:thin:@//host:port/service`（ServiceName）与 `jdbc:oracle:thin:@host:port/sid`（Sid2 斜杠形式）会误入 `parseJdbcOracleBySid`：该实现 `lastIndexOf(":")` 切分后对已无冒号的 host 段再取 `substring(0, -1)`，直接抛 `StringIndexOutOfBoundsException`（ServiceName 形式）或 `NumberFormatException`（Sid2 形式）**崩溃**；真正正确的 `parseJdbcOracleBySid2`/`parseJdbcOracleByServiceName` 因路由缺 `@//` 判别与顺序问题**永不可达**（死代码），对应输出方法 `toUrlStringJdbcOracleSid2` 亦不可达 |
| 2 | **高** | `UriMeta.parseJdbcSqlserver` / L279 | `jdbc:sqlserver://localhost:1433`（无 `;` 参数）时 `indexOf(";")` 返回 -1，`substring(0, -1)` 抛 `StringIndexOutOfBoundsException` **崩溃**；仅带分号参数的 URL 可用 |
| 3 | **高** | `UriMeta.parseCommon` / L121 | host/port 切分用 `lastIndexOf(":")` + `Integer.parseInt`：无端口的 IPv6 地址（如 `http://[::1]/path`）会把 `[:`/`1]` 误切为 host/port 并抛 `NumberFormatException`（带端口的 `[fe80::…%9]:9999` 恰好可用，测试仅覆盖后者） |
| 4 | 中 | `FormUrlEncodedEncoder.toMap` | 空串、尾部 `&`、连续 `&&` 会产生空 key 条目（`""→[""]`），污染 Map 树 |
| 5 | 中 | 全链路 `TreeMap` | `toMap`/`toFlatMap`/`groupMap` 均用 `TreeMap`，字段顺序按 key 字典序重排；`toForm→ofFormBean→toForm` 往返后串序改变，无法保序 |
| 6 | 中 | `toForm`/`toRouteMap` | 空集合、空 Map、无字段对象不产生任何条目 → 反序列化后为 `null`，**空集合与 null 语义丢失** |
| 7 | 中 | `toForm` / L40 | `null` 值与空字符串同样编码为 `key=`，**无法区分** |
| 8 | 中 | `ObjectRouteResolver.toFlatMap` | 多值展开 `key[i]`、单值保留 `key`：`roles=a`（标量）与 `roles[0]=a`（单元素集合）在协议上无法同时表达，混合使用会产生同名路径冲突（结构歧义） |
| 9 | 中 | `toForm` / L60 | Date 固定格式 `yyyy-MM-dd HH:mm:ss SSS`（无时区、不可配置），且每次新建 `SimpleDateFormat`（线程安全但高频场景有性能负担）；解析侧无对称的日期回解 |
| 10 | 中 | `toForm` | 使用 `URLEncoder`（空格→`+`），与 RFC 3986 的 `%20` 风格互操作时，第三方（严格解析器）可能把 `+` 当字面加号；仅与本模块 `toMap` 闭环自洽 |
| 11 | 低 | `toForm` / `toMap` | 7 处 `catch (Exception e) {}` 静默吞异常（`URLEncoder` 的 `UnsupportedEncodingException` 在 UTF-8 下不可能发生），冗余且掩盖潜在异常 |
| 12 | 低 | `toUrlStringCommon` / L365 | `user` 为 null 而 `password` 非 null 时输出 `:password@`（无用户名的非法语法）；`host` 为 null 时输出字符串 `"null"` |
| 13 | 低 | `parseFile` / `parseJarFile` | 不做路径归一化：`file:///D:/…`（三斜杠）、`%20` 转义、`.`/`..` 相对段均原样保留在 path |
| 14 | 低 | `UriMeta` / `@Data` | 全部字段公开 setter + 无参构造：可构造出 schema 与 host/path 不一致的非法对象，`toUrlString` 无校验直接拼接输出错误串 |
| 15 | 低 | `parse` / L37 | `parse(null)` 直接 NPE（无入参防护）；`parseCommon` 抛 `IllegalArgumentException` 但不带原始输入信息，排查困难 |
| 16 | 低 | `toURL`/`toURI` | 方法名暗示通用转换，实际仅标准协议可用（`git@`/`jdbc:` 抛异常），无文档说明 |
| 17 | 低 | `i2f.url.test` | 测试为 3 个 `main` 手工类（依赖 `System.out` 人工核对，无断言），且位于 `src/main/java` 随主 jar 发布；`TestUriMeta` 的 23 个样例也未覆盖 Oracle ServiceName/Sid2、SQLServer 无参、IPv6 无端口三个崩溃场景 |

## 与同类方案对比

| 维度 | i2f-form-url-encoded | `java.net.URLEncoder/Decoder` | Spring `UriComponentsBuilder` |
|---|---|---|---|
| 核心定位 | 对象↔form 串全链路 + URI 结构解析 | 单值字符串编解码 | URL 构建/模板/编解码 |
| 嵌套对象支持 | ✅ 点号路径协议（`a.b[0].c`）自动展平/还原 | ❌ 手工拼 | ❌ 平铺键值 |
| 反序列化为 Bean | ✅ `ofFormBean`（Class/泛型/Type + keyMapper） | ❌ | ❌ |
| 多方言 URI 解析 | ✅ 9 种（file/jar/git/jdbc 方言） | ❌ | 仅 URI 组件 |
| SPA `#/?` 双风格 | ✅ `hashBefore` 开关 | ❌ | 部分 |
| 类型感知编码 | ✅ Date/Charset/Class 专用处理 | ❌ 一律 String | ❌ |
| 缺陷风险 | Oracle 特殊形式崩溃、TreeMap 失序、隐式传递依赖 | 需手写编码点 | 依赖 Spring 生态 |

## 总结

`i2f-form-url-encoded` 以约 750 行实现了「**扁平对象 ↔ form-urlencoded**」与「**URI 串 ↔ 结构化模型**」两条实用的轻量管线：

- **`FormUrlEncodedEncoder`** 将 `i2f-reflect` 的 routeMap（点号路径 + 数组下标）协议直接映射到 form 串，天然支持嵌套 Bean/集合的序列化与还原（含泛型、key 前缀映射），是 HTTP 表单、URL query、SWL 加密头三类场景的统一序列化入口；
- **`UriMeta`** 以手动状态机覆盖 9 种 URI 方言（测试样例达 23 个真实 URL），`#`/`?` 混序与 `hashBefore` 开关精准服务 SPA 路由场景，是 JDBC URL 解析（默认库名提取）与 URL 重组的实用工具；
- 全仓 **6 模块 9 文件**真实消费：SWL 安全体系的头部序列化核心、HTTP 客户端的 query 拼装、Oracle/SQLServer/通用 JDBC 的库名提取均依赖它；另有 2 个模块声明未用（`i2f-springboot-swl-starter`、`test-secure`）；
- 主要风险集中在 `UriMeta` 的解析边界：**Oracle ServiceName/Sid2 形式直接崩溃且正确实现不可达**（#1）、SQLServer 无参崩溃（#2）、IPv6 无端口崩溃（#3），调用 JDBC URL 解析时需规避；`FormUrlEncodedEncoder` 侧则以「空值同形、TreeMap 失序、单多值协议歧义」等语义损耗为代价换取实现简洁。
