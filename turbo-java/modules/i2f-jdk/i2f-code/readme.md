# i2f-code

> **码值/密钥生成器**（全模块仅 1 个静态门面类 `CodeUtil`，2 组方法、零内部依赖）：`makeUUID()` 把 `UUID.randomUUID()` 的 `36` 位标准格式（含 `-` 分隔符）去连接符、全大写压缩为 `32` 位紧凑形式，适合做数据库主键/业务流水号/Token 前缀；`makeCheckCode(len)` / `makeCheckCode(len, onlyNumber)` 基于 `SecureRandom` 生成指定长度的随机验证码/密钥——从 `[0-9a-zA-Z]` 62 个字符均匀采样（`onlyNumber=true` 时缩为 `[0-9]` 10 个数字），以 `rand.nextInt(bounce)` 避免模偏差。典型消费方 `i2f-swl.SwlAesSymmetricEncryptor` 用 `makeCheckCode(128/8)`（即 16 位字母数字混合）生成 AES-128 密钥，`i2f-extension-swl.SwlBcAes256SymmetricEncryptor` 用 `makeCheckCode(256/8)`（32 位）生成 AES-256 密钥。pom 声明的 `lombok` **声明未用**（源文件无注解）。

## 模块路径

- `i2f-jdk/i2f-code`

## 模块依赖

| 坐标 | scope | optional | 说明 |
|------|-------|----------|------|
| `org.projectlombok:lombok` | provided | false | 声明但唯一源文件 `CodeUtil.java` 无任何 lombok 注解，属冗余声明 |

## 模块设计

### 架构设计

全模块仅 `i2f.code.CodeUtil` 一个类，全部为 `public static` 方法，无实例状态、无继承、无 SPI：

```
i2f.code
└── CodeUtil              ← 纯静态门面，零实例成员
    ├── makeUUID()        ← 32 位紧凑 UUID
    ├── makeCheckCode(len)            ← 62 字符随机码
    └── makeCheckCode(len, onlyNumber) ← 数字/字母数字随机码
```

### 设计要点

- **单例随机源**：`public static volatile SecureRandom rand` 由类加载时初始化，`volatile` 保障线程可见性，全模块共用同一 `SecureRandom` 实例。
- **字符映射算法**：`rand.nextInt(bounce)` 产出 `[0, bounce)` 均匀整数，按三段映射——`[0,10)` → `'0'…'9'`，`[10,36)` → `'a'…'z'`，`[36,62)` → `'A'…'Z'`，确保字母分布均衡（大小写各 26 个、数字 10 个）。
- **无依赖原则**：除 JDK 内置 `java.security.SecureRandom` / `java.util.UUID` 外零外部依赖，`lombok` 为冗余声明。

## 模块目的

1. 提供轻量、线程安全的随机验证码/密钥字符串生成工具，避免各模块各自重复实现「从字符集采样」的逻辑。
2. 封装 UUID 紧凑格式化（去分隔符、全大写），统一项目中 ID 生成格式。
3. 为对称加密（AES）模块提供便捷的随机密钥素材生成入口。

## 模块功能

### 1. 紧凑 UUID 生成（`makeUUID()`）

- 基于 `UUID.randomUUID()` 生成标准 128 位 UUID
- 调用 `.replace("-", "").toUpperCase()` 去除 4 个连字符并大写，得到 `32` 位定长纯十六进制串
- 示例输出：`makeUUID()` → `550E8400E29B41D4A716446655440000`

### 2. 随机验证码/密钥生成（`makeCheckCode`）

- **`makeCheckCode(int len)`**：从 `[0-9a-zA-Z]` 共 62 个字符中均匀采样，返回指定长度的随机字符串
- **`makeCheckCode(int len, boolean onlyNumber)`**：`onlyNumber=true` 时从 `[0-9]` 共 10 个数字中采样；`onlyNumber=false` 时等同无参版本
- 随机源为 `SecureRandom`（cryptographically strong random number generator），适合用于密钥生成
- 示例：`makeCheckCode(6)` → `aK9xQ2`，`makeCheckCode(6, true)` → `384720`

## 模块主要使用方法

```java
// 生成紧凑 UUID（32 位大写十六进制）
String uuid = CodeUtil.makeUUID();
// 输出示例：550E8400E29B41D4A716446655440000

// 生成 6 位字母数字混合验证码
String code = CodeUtil.makeCheckCode(6);
// 输出示例：aK9xQ2

// 生成 6 位纯数字验证码
String numCode = CodeUtil.makeCheckCode(6, true);
// 输出示例：384720

// 生成 AES-128 密钥（16 位字母数字）
String aes128Key = CodeUtil.makeCheckCode(128 / 8);

// 生成 AES-256 密钥（32 位字母数字）
String aes256Key = CodeUtil.makeCheckCode(256 / 8);
```

## 模块特性总结

- **极致轻量**：全模块仅 1 个类、2 组方法、42 行源码，开箱即用
- **零外部运行期依赖**：仅依赖 JDK 内置 `UUID` + `SecureRandom`，pom 中 `lombok` 实未使用
- **密码学安全随机**：基于 `SecureRandom` 而非 `Random` / `ThreadLocalRandom`，适合密钥/Token 等敏感场景
- **直接服务于加密模块**：`i2f-swl`（AES-128）与 `i2f-extension-swl`（AES-256）直接消费 `makeCheckCode` 生成对称密钥素材

## 已知实现瑕疵

1. **字符串拼接低效**：`makeCheckCode` 在循环中使用 `ret += (char)…` 字符串拼接，每次循环创建新 `String` 对象。短码（~32 位以内）性能可接受；长码场景建议使用 `StringBuilder`。
2. **`rand` 为 `public` 可变字段**：`public static volatile SecureRandom rand` 允许外部直接赋值替换，存在被误覆盖的风险，应封装为 `private static` 并通过 getter 访问。
3. **`lombok` 冗余声明**：pom 声明了 `lombok` provided 依赖，但唯一源文件 `CodeUtil.java` 无任何 `@Data`/`@Slf4j`/`@Getter` 等注解，属声明未用。

## 下游与关联

- **`i2f-swl.SwlAesSymmetricEncryptor`**：在 `generateKey()` 中调用 `CodeUtil.makeCheckCode(128 / 8)` 生成 16 位 AES-128 密钥
- **`i2f-extension-swl.SwlBcAes256SymmetricEncryptor`**：在 `generateKey()` 中调用 `CodeUtil.makeCheckCode(256 / 8)` 生成 32 位 AES-256 密钥
- **`i2f-jdk-all`**：聚合 POM 将其纳入批量编译
- 兄弟模块 `i2f-codec-impl` / `i2f-codec-std` 包名 `i2f.codec.*` 与 `i2f.code.*` 不同，**无直接关联**（`codec` 是编解码，`code` 是码值生成）