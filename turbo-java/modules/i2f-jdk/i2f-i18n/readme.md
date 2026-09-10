# i2f-i18n

> **国际化（i18n）消息工具集**——10 源文件约 935 行，纯 JDK + `i2f-xml` 依赖。提供 `I18n` 静态门面 + SPI 发现 + 线程级语言上下文 + 文件扫描自动加载（properties/XML 双格式），支持类型安全取值与多级回退。被 `i2f-jdk-all` 全仓聚合引入，目前全仓零 Java 代码级消费者。

---

## 模块定位

- **功能**：提供统一的国际化消息解析能力——通过线程级 `lang` 上下文 + 多格式配置文件 + SPI 可扩展 Provider，支持 `String.format` 占位符替换与基础类型转换
- **所属层级**：`i2f-jdk` 基础工具层，位于 `i18n` 消息领域
- **设计原则**：
  - **SPI 可扩展**：通过 `ServiceLoader<I18nProvider>` 发现自定义 Provider，支持系统属性指定首选实现
  - **三级别语言优先级**：传入参数 `lang` > `I18n.getThreadLang()` 线程上下文 > `DEFAULT_LANG`（`"default"`），适合 Web 过滤器逐请求设语言
  - **自动文件发现**：通过笛卡尔积枚举 classpath/file 下的多种文件名模式，properties/XML 双格式自动识别

## 依赖关系

| 依赖 | 类型 | 用途 | 是否真实使用 |
|------|------|------|-------------|
| `lombok` | 编译期 | `@Data`+`@NoArgsConstructor`（4 类：`I18nItem`、`XmlI18nParser`、`DefaultI18nProvider`、`MergedI18nProvider`） | **是** |
| `i2f-xml` | 编译+运行 | `XmlUtil` 解析 XML 文档，被 `XmlI18nParser` 使用 | **是** |

## 包结构

```
i2f.i18n
├── I18n.java              (177 行) — 静态门面，线程 lang 上下文，SPI 初始化
├── data
│   └── I18nItem.java       (23 行) — 数据模型：lang + name + value
├── parser
│   ├── I18nParser.java     (24 行) — 解析器接口 + unescape 静态方法
│   └── impl
│       ├── PropertiesI18nParser.java (86 行) — .properties 文件解析
│       └── XmlI18nParser.java       (240 行) — XML 文件解析（含 ref/keep/only 特性）
├── provider
│   ├── I18nProvider.java   (95 行) — Provider 接口，含类型转换 default 方法
│   └── impl
│       ├── DefaultI18nProvider.java (188 行) — 默认实现：文件扫描 + 缓存
│       └── MergedI18nProvider.java  (37 行) — 复合 Provider：多 provider 链式查询
├── test
│   └── TestI18n.java       (39 行) — Demo（在 main 源码集）
└── util
    └── I18nUtil.java       (149 行) — 工具：笛卡尔积、文件/类路径 I/O
```

## 类结构总览

| 分组 | 类 | 行数 | 职责 |
|------|-----|------|------|
| **门面** | `I18n` | 177 | 静态 API 入口，SPI 初始化，`InheritableThreadLocal` lang 上下文 |
| **模型** | `I18nItem` | 23 | lang/name/value 三元组数据模型 |
| **解析** | `I18nParser` | 24 | `parse()` 接口 + `unescape()` 转义静态方法 |
| **解析** | `PropertiesI18nParser` | 86 | properties 格式解析，4 种构造器（Properties/InputStream/Reader/String） |
| **解析** | `XmlI18nParser` | 240 | XML 格式解析，支持 ref 外部文件引用、keep 保持格式、only 仅 | 行 |
| **提供** | `I18nProvider` | 95 | 核心接口：`get(lang, name)` + 类型转换 default 方法（6 种基础类型） |
| **提供** | `DefaultI18nProvider` | 188 | 默认实现：文件扫描 `cacheMap`、`loadLangMap` 懒加载、双格式自动识别 |
| **提供** | `MergedI18nProvider` | 37 | 复合实现：遍历 `providers` 返回首个非 null 值 |
| **测试** | `TestI18n` | 39 | 命令行 Demo（非 JUnit 测试） |
| **工具** | `I18nUtil` | 149 | 笛卡尔积生成文件名、`trimLeft`、文件/ClassLoader 流读取 |

## 核心机制

### 1. Provider 初始化优先级（3 级 SPI）

```
I18n 静态初始化
  → System.getProperty("i18n.default.provider")    ← ① 系统属性指定类名
  → ServiceLoader.load(I18nProvider.class)            ← ② 匹配指定类? 是则单用
  → 所有 SPI Provider + DefaultI18nProvider 合成为 MergedI18nProvider  ← ③ 未指定则合并
  → DefaultI18nProvider 仅自身                        ← ④ 无 SPI 则兜底
```

### 2. 语言解析链（3 级降级）

```
I18n.get(lang, name)
  → 优先使用传入的 lang 参数
  → 为 null 则用 I18n.getThreadLang()（线程上下文）
  → 仍为 null 则用 I18n.DEFAULT_LANG（常量 "default"）
  
Web 集成示例：
  Filter 中 I18n.setThreadLang(request.getLocale().getLanguage())
  → 后续业务代码无需传参 I18n.get("message.key") 即可自动使用客户端语言
```

### 3. 文件自动发现机制

通过 `I18nUtil.cartesianProduct` 笛卡尔积生成文件名列表：

```
[classpath:, file:]                     ← 2 种前缀
× [i18n/, resources/, config/, lang/]   ← 4 种目录
× [i18n, message, string]               ← 3 种文件名
× [-%s]                                 ← 1 种语言占位符
× [.properties, .xml]                   ← 2 种后缀
= 2×4×3×1×2 = 48 条搜索路径

加载示例（lang = "zh-CN"）：
  classpath:i18n/i18n-zh-CN.properties
  classpath:i18n/i18n-zh-CN.xml
  classpath:resources/i18n-zh-CN.properties
  ...（共 48 条路径，逐一尝试）
```

### 4. XML 格式高级特性

XML 格式在 properties 基础上增加 3 个特性：

```
<i18n lang="default">
    <!-- ref：引用外部文件（名称由 name 指定，语言自动推导） -->
    <ref name="app.help"/>

    <!-- item：普通条目 -->
    <item name="app.version">1.0.0</item>

    <!-- item + keep + only：保持格式，仅保留 | 开头的内容 -->
    <item name="app.banner" lang="en" keep="true" only="true">
        |-----------------
        |name: svc
        |active: prod
        |fallback
        |-----------------
    </item>
</i18n>
```

- `ref`：从外部文件加载内容，搜索 `i18n/i18n-{name}-{lang}.txt` 等 48 条路径
- `keep`：保留换行和缩进（不 trim），处理 `|` 前缀格式
- `only`：配合 `keep` 使用，仅保留以 `|` 开头的行，去除格式对齐前缀

### 5. 类型转换体系

`I18nProvider` 接口提供 6 种基础类型的 `default` 转换方法，统一通过 `getAs` 模板方法实现：

```
getAs(lang, name, Function<String, T> mapper, T defaultValue)
  → get(lang, name)
  → null 则返回 defaultValue
  → mapper.apply(value)，异常则返回 defaultValue

派生方法（每种 x2：带/不带 lang 参数）：
  getInt / getLong / getDouble / getFloat / getBoolean
```

### 6. 转义支持

`I18nParser.unescape()` 静态方法在 parsing 阶段自动处理转义序列：

```java
unescape("line1\\nline2\\tindented") → "line1\nline2\tindented"
```

PropertiesI18nParser 默认对 value 调用 unescape；XmlI18nParser 同样在 value 提取后调用。

## 使用示例

### 基本使用

```java
// 默认情况下，I18n 自动从 classpath 加载 i18n 配置文件
// 需要 src/main/resources/i18n/i18n-default.properties 或 .xml

// 获取消息（使用线程 lang 或默认）
String version = I18n.get("app.version");
System.out.println(version);  // "1.0.0"

// 带默认值
String unknown = I18n.getOrDefault("app.unknown", "N/A");
System.out.println(unknown);  // "N/A"

// 指定语言
String cnVersion = I18n.get("zh-CN", "app.version");
```

### 线程语言上下文

```java
// Web Filter 中设置
I18n.setThreadLang("zh-CN");

// 后续业务代码无需传参
String message = I18n.get("app.banner");
// → 实际调用 I18n.get("zh-CN", "app.banner")

// 清理
I18n.removeThreadLang();
```

### 带占位符的消息

```java
// 配置文件：welcome.message=Hello, {0}! Today is {1}
String msg = I18n.format("welcome.message", "Alice", "Monday");
// → "Hello, Alice! Today is Monday"
```

### 类型安全取值

```java
int timeout = I18n.getInt("app.timeout", 30);       // 默认 30 秒
long maxSize = I18n.getLong("app.maxSize", 1024L);
boolean debug = I18n.getBoolean("app.debug", false);
double rate = I18n.getDouble("app.rate", 0.5);

// 自定义类型转换
MyConfig config = I18n.getAs("app.config", (str) -> parseConfig(str), defaultConfig);
```

### 自定义 Provider（SPI）

```java
// 1. 实现 I18nProvider 接口
public class DatabaseI18nProvider implements I18nProvider {
    @Override
    public String get(String lang, String name) {
        // 从数据库查询
        return queryFromDB(lang, name);
    }
}

// 2. 创建 META-INF/services/i2f.i18n.provider.I18nProvider
// 内容：com.example.DatabaseI18nProvider

// 3. 启动时指定优先使用
// java -Di18n.default.provider=com.example.DatabaseI18nProvider ...
```

### XML 多语言配置文件

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<i18n lang="default">
    <ref name="app.help"/>               <!-- 引用外部文件 -->
    <item name="app.version">
        1.0.0
    </item>
    <item name="app.banner" lang="en" keep="true" only="true">
        |-----------------
        |name: svc
        |active: prod
        |-----------------
    </item>
</i18n>
```

## 消费关系

| 消费者 | 类型 | 用途 |
|--------|------|------|
| `i2f-jdk-all` | POM 聚合依赖 | 全仓引入 i18n 能力 |
| 根 pom.xml | 版本管理 | L466：版本托管 |
| `i2f-jdk/pom.xml` | 模块声明 | L86：子模块注册 |

目前全仓**零 Java 代码级消费者**——i18n 模块作为基础设施待消费方集成。

## 注册链路

```
根 pom.xml (L460-468)
  └── <dependencyManagement> i2f-i18n version
       └── i2f-jdk/pom.xml (L86)
            └── <module>i2f-i18n</module>
                 └── i2f-jdk-all/pom.xml (L291-294)
                      └── <dependency> i2f-i18n
```

## 已知缺陷

| 等级 | 缺陷 | 位置 | 说明 |
|------|------|------|------|
| 中 | 空 catch 块过多 | 多处 | `PropertiesI18nParser`（L53-60）、`XmlI18nParser`（L170-172）、`DefaultI18nProvider`（L136-138）、`I18nUtil`（L99-101/L138-140/L144）等多处异常静默吞掉，不利于问题排查 |
| 中 | 平台默认编码 | `PropertiesI18nParser` L46 | `propertiesString.getBytes()` 使用平台默认编码（而非 UTF-8），跨平台时可能出现编码问题 |
| 中 | Test 在 main 源码集 | `test/TestI18n.java` | 测试代码位于 main 而非 test 源码集，无 JUnit 依赖，需手动 `main()` 运行 |
| 低 | 文件名路径膨胀 | `DefaultI18nProvider` | 48 条搜索路径逐一尝试，每次 `loadLangMap` 都有 I/O 开销；`XmlI18nParser` 又有 48 条 ref 搜索路径 |
| 低 | `MergedI18nProvider` 无去重 | L24-33 | 同 lang+name 出现在多个 provider 时，仅返回首个非 null 值，无法感知覆盖关系 |
| 低 | `I18nProvider.get(lang, null)` 返回 null | L167-169 | `name == null` 提前返回 null，但语义上应由 Provider 决定是否支持 null key |
| 低 | 默认语言文件 `-default` 多余搜索 | `DefaultI18nProvider` L115-117 | DEFAULT_LANG 时同时搜索带 `-default` 和不带后缀的路径，可能存在重复加载 |
| 低 | 纯 XML 格式无 DTD/XSD 校验 | `XmlI18nParser` | XML 解析无 Schema 校验，格式错误时被空 catch 吞掉 |

## 对比：i2f-i18n vs. Spring MessageSource

| 维度 | i2f-i18n | Spring MessageSource |
|------|---------|---------------------|
| **设计** | 静态门面 + SPI 可插拔 | IoC 容器管理 Bean |
| **语言上下文** | `InheritableThreadLocal`（线程级，可传参） | `LocaleContextHolder`（线程级） |
| **文件格式** | properties + XML（XML 支持 ref/keep/only 高级特性） | properties 为主 |
| **SPI 扩展** | `ServiceLoader<I18nProvider>` | 实现 `MessageSource` 接口即可 |
| **类型转换** | 6 种基础类型 + 泛型 `getAs` | 需手动转换 |
| **自动扫描** | 笛卡尔积 48 条路径自动发现 | 明确声明 basename |
| **占位符** | `String.format` | `MessageFormat`（更强） |

## 总结

`i2f-i18n` 模块是一个轻量级、零运行期三方依赖的国际化工具集（935 行，不含资源文件）。其核心亮点在于：

1. **SPI 三优先级初始化**：系统属性 > 所有 SPI > 默认文件扫描，兼顾灵活性与开箱即用
2. **线程级语言上下文**：通过 `InheritableThreadLocal` 支持 Web Filter 逐请求设语言，业务代码零侵入
3. **XML 高级格式**：`ref` 外部文件引用 + `keep`/`only` 格式控制，适合多行模板消息
4. **自动文件发现**：48 条搜索路径 + properties/XML 双格式自动识别，零配置即可运行

主要不足：空 catch 块过多掩盖运行时错误、测试代码位于 main 源码集、文件路径枚举有 I/O 开销。