# i2f-springboot-totp-starter

> TOTP/HOTP 动态口令（Google Authenticator / Microsoft Authenticator / Steam Guard 兼容）的 Spring Boot 即装配 Starter —— 把 `i2f-otpauth` 的 HMAC-OTP 认证内核（`HmacOtpAuthenticator` 及 `TotpAuthenticator`/`MicrosoftAuthenticator`/`SteamAuthenticator` 三实现）接入 Spring 容器：`HmacOtpAutoConfiguration` 经 `@Import` 注册门面 `HmacOtpAccountAuthenticator`（生成随机密钥、按 account 取密钥、`verify`/`generate`/`makeUrl` 生成或校验验证码、产出 `otpauth://` 扫码 URL）与默认工厂 `DefaultTotpAuthenticatorFactory`（按 `type` 分派 totp/microsoft/steam）。业务方只需实现一个 `HmacOtpAccountKeyProvider` Bean（从数据库/缓存按账号返回 Base32 密钥），即可注入 `HmacOtpAccountAuthenticator` 完成二次验证。共 5 个类、唯一内部依赖 `i2f-otpauth`，Boot 全 `provided`，是组内体量最小的专项 Starter 之一。

## 模块路径

- `i2f-springboot/i2f-springboot-totp-starter`

## 模块依赖

| GroupId | ArtifactId | Scope | Optional | 说明 |
|---------|------------|-------|----------|------|
| org.projectlombok | lombok | compile | 否 | `@Data`/`@Slf4j`/`@NoArgsConstructor` |
| org.springframework.boot | spring-boot-starter | provided | 是 | 自动配置基座、`@Conditional*`/`@Import`/`@ConfigurationProperties` |
| org.springframework.boot | spring-boot-configuration-processor | provided | 是 | 元数据生成 |
| i2f.turbo | i2f-otpauth | compile | 否 | HMAC-OTP 内核：`HmacOtpAuthenticator`（`generateSecretKey`/`getMac`/`compute`/`makeQrUrl`）与 `TotpAuthenticator`/`MicrosoftAuthenticator`/`SteamAuthenticator` |

> `i2f-otpauth` 传递引入 `i2f-codec`（`i2f.codec.bytes.basex.Base32`）、`i2f-bytes`（`i2f.bytes.ByteUtil`）、`i2f-log-std` 等，本 Starter 未直声明而直接使用其 `Base32`。
>
> 构建：`maven-assembly-plugin` + `addMavenDescriptor=true`；根 `pom.xml` `dependencyManagement` 第 1479 行以 `${i2f.version}` 登记版本；`i2f-springboot/pom.xml` 第 43 行登记 module。

## 模块设计

本 Starter 采用「**一个自动配置入口 + 一个门面 + 一个可插拔工厂 + 两个 SPI**」结构：`HmacOtpAutoConfiguration` 无 `@Bean` 方法，全靠 `@Import` 把门面 `HmacOtpAccountAuthenticator` 与 `DefaultTotpAuthenticatorFactory` 拉入容器；门面运行期经两个 SPI 接口解耦——`HmacOtpAccountKeyProvider`（用户实现，按 account 返回密钥）与 `HmacOtpAuthenticatorFactory`（默认由 `DefaultTotpAuthenticatorFactory` 实现，产出具体 `HmacOtpAuthenticator`）。

```mermaid
flowchart TD
    AC[HmacOtpAutoConfiguration  i2f.springboot.totp.enable]
    subgraph IMP[@Import 拉入容器]
        FA[HmacOtpAccountAuthenticator 门面 InitializingBean]
        DF[DefaultTotpAuthenticatorFactory  i2f.springboot.totp.factory.enable]
    end
    KP{{HmacOtpAccountKeyProvider  SPI 用户必须实现}}
    OF{{HmacOtpAuthenticatorFactory  SPI}}
    KERNEL[i2f-otpauth HmacOtpAuthenticator Totp/Microsoft/Steam]
    AC -->|@Import| FA
    AC -->|@Import| DF
    DF -.implements.-> OF
    FA -->|@Autowired required| OF
    FA -->|@Autowired required=false + 启动期强校验| KP
    OF -->|getAuthenticator secret| KERNEL
    FA -->|getKey account -> Base32 secret| KERNEL
```

- **双通道自动装配登记**：`META-INF/spring.factories`（Boot 2.x）与 `META-INF/spring/...AutoConfiguration.imports`（Boot 2.7+）双登记同一个 `HmacOtpAutoConfiguration`。
- **密钥与算法解耦**：门面只认「account → 密钥字符串（Base32）→ 认证器实例」，密钥来源（DB/Redis/文件）完全交给用户的 `HmacOtpAccountKeyProvider` 实现，认证器类型（totp/microsoft/steam）交给 `HmacOtpAuthenticatorFactory`。
- **启动期硬约束**：`HmacOtpAccountAuthenticator.afterPropertiesSet` 检查 `accountKeyProvider` 是否为空，未提供则启动失败，强制使用方接入密钥来源。

## 模块目的

- 让应用以极低成本接入「基于时间的一次性密码（TOTP）」二次验证：生成共享密钥、产出 `otpauth://` 二维码 URL 供 Google/Microsoft Authenticator 扫码绑定、按账号校验用户输入的 6 位动态码。
- 复用 `i2f-otpauth` 的 HMAC-OTP 内核，仅以 5 个 Spring 装配件桥接容器与生命周期，避免每个应用手写密钥获取/认证器分派。
- 支持 totp / microsoft / steam 三种兼容风格，并可通过替换 `HmacOtpAuthenticatorFactory` Bean 扩展自定义算法参数。

## 模块功能

- `HmacOtpAutoConfiguration`：`@ConditionalOnExpression("${i2f.springboot.totp.enable:true}")` 总开关，`@Import` 门面与默认工厂。
- `HmacOtpAccountAuthenticator`：门面，提供 `generateRandomKey()`（16 字节随机种子 Base32）、`generateKey(byte[])`、`getAuthenticator(account)`（经 provider 取密钥）、`getAuthenticatorBySecretKey(totpKey)`、`verify(account,code)`、`generate(account)`、`makeUrl(account,issuer)`（生成 `otpauth://` 扫码地址）。
- `DefaultTotpAuthenticatorFactory`：`@ConditionalOnExpression("${i2f.springboot.totp.factory.enable:true}")` + `@ConditionalOnMissingBean(HmacOtpAuthenticatorFactory.class)`，按 `type` 分派 totp/microsoft/steam，可配 `algorithm`/`digits`。
- `HmacOtpAccountKeyProvider`（SPI）：用户实现 `getKey(account)` 返回该账号的 Base32 密钥。
- `HmacOtpAuthenticatorFactory`（SPI）：`getAuthenticator(byte[] secret)` 产出认证器实例，可替换默认工厂。

## 模块主要使用方法

1. 引入 Starter，并由宿主自备 Boot 运行时（`provided`）：

```xml
<dependency>
    <groupId>i2f.turbo</groupId>
    <artifactId>i2f-springboot-totp-starter</artifactId>
    <version>1.0-jdk8</version>
</dependency>
```

2. 实现 `HmacOtpAccountKeyProvider` Bean（从数据库/缓存按账号返回密钥），否则应用启动失败：

```java
@Component
public class DbTotpKeyProvider implements HmacOtpAccountKeyProvider {
    @Override
    public String getKey(String account) {
        return userMapper.findTotpKey(account); // Base32 密钥
    }
}
```

3. 注入门面完成绑定与校验（注意：默认 `type=totp` 下 `algorithm`/`digits` 配置不生效，见瑕疵①）：

```yaml
i2f:
  springboot:
    totp:
      enable: true          # 总开关
      factory:
        enable: true        # 默认工厂开关（元数据键错位，见瑕疵②）
        type: totp          # totp | microsoft | steam
        algorithm: SHA1     # 仅对未知 type 生效
        digits: 6           # 仅对未知 type 生效
```

```java
@Autowired
private HmacOtpAccountAuthenticator authenticator;
// 绑定时：String key = authenticator.generateRandomKey(); 存库 + 展示 authenticator.makeUrl(account, issuer) 二维码
// 登录时：authenticator.verify(account, userInputCode);
```

## 模块特性总结

- **纯桥接、体量极小**：5 类只做「把 `i2f-otpauth` 认证内核接进 Spring + 用两个 SPI 解耦密钥来源与算法分派」，OTP 计算全在上游。
- **SPI 双扩展点**：`HmacOtpAccountKeyProvider`（必实现）与 `HmacOtpAuthenticatorFactory`（可覆盖）职责清晰，密钥存储与认证器构造均可替换。
- **多兼容风格开箱**：totp/microsoft/steam 三套 `HmacOtpAuthenticator` 子类经工厂分派，`makeUrl` 直接产出标准 `otpauth://` 扫码地址。
- **provided 面克制**：Boot 全 provided，仅 `i2f-otpauth` compile，不与宿主争抢框架版本。

## 模块瑕疵或错误

1. **【高危·配置项对默认类型完全失效】`algorithm`/`digits` 只对「未知 type」生效**：`DefaultTotpAuthenticatorFactory.getAuthenticator` 中 `type=totp`（默认！）走第 29-31 行 `return new TotpAuthenticator(secret)` 直接返回，`microsoft`/`steam` 亦在 if-else 链中提前 return；而应用 `setAlgorithm(...)`/`setDigits(...)` 的语句（第 38-43 行）位于所有分支之后的兜底段，**只有当 `type` 既非 totp/microsoft/steam 时才可达**。元数据 `factory.type` 明列取值仅 `totp|microsoft|steam`，意味着对全部文档化取值，`i2f.springboot.totp.factory.algorithm`（如 SHA256）与 `digits`（如 8）都是死配置，改了毫无效果；且 `SteamAuthenticator` 构造内又硬覆盖 `digits=5`，进一步架空。
2. **【元数据键错位】`factory` 开关登记错键**：代码实际开关是 `@ConditionalOnExpression("${i2f.springboot.totp.factory.enable:true}")`（真实键 `i2f.springboot.totp.factory.enable`），但元数据第 22-28 行登记的是 `i2f.springboot.totp.factory`（Boolean，描述 "enable default factory"），少了 `.enable` 后缀、且真正的 `factory.enable` 从未登记——IDE 对工厂开关的补全永不命中（同 `spring-starter` `enable.enable`、`ssh-tunnel` 键错位家族）。此外 `@ConfigurationProperties(prefix="i2f.springboot.totp.factory")` 把整个 `...factory` 前缀绑到 `DefaultTotpAuthenticatorFactory`（含 type/algorithm/digits），而元数据又把同名 `...factory` 标成 Boolean，类型语义自相冲突。
3. **【无 `@Configuration`，自动配置走 lite 模式】**：`HmacOtpAutoConfiguration` 经 `spring.factories`/`AutoConfiguration.imports` 登记为自动配置类，却未标 `@Configuration`；被 `@Import` 的 `HmacOtpAccountAuthenticator`/`DefaultTotpAuthenticatorFactory` 也无 `@Configuration`/`@Component`。自动配置类缺失 `@Configuration` 属规范违背（当前无跨 `@Bean` 方法调用故未爆雷，但风格脆弱、Full 模式下的类级增强不发生）。
4. **`@ConfigurationProperties` 加在无字段类上纯属噪声**：`HmacOtpAutoConfiguration` 标 `@ConfigurationProperties(prefix="i2f.springboot.totp")` 但类体为空、无任何字段，绑定不到任何属性；`i2f.springboot.totp.enable` 只被 `@ConditionalOnExpression` 读取、并非该类可绑定属性。元数据 group `i2f.springboot.totp` → `HmacOtpAutoConfiguration` 名不副实。
5. **`@ConditionalOnMissingBean` 用在 `@Import` 的普通类上顺序不可靠**：`DefaultTotpAuthenticatorFactory` 标 `@ConditionalOnMissingBean(HmacOtpAuthenticatorFactory.class)`，但它是被 `@Import` 直接引入而非独立的自动配置类，`@ConditionalOnMissingBean` 在非 auto-configuration 场景下的求值顺序不保证——用户自定义的 `HmacOtpAuthenticatorFactory` Bean 未必能稳定压制默认工厂，存在两者共存、进而使 `HmacOtpAccountAuthenticator` 的 `@Autowired HmacOtpAuthenticatorFactory` 注入歧义（`NoUniqueBeanDefinitionException`）的风险。
6. **`verify` 无时间窗偏移容错**：上游 `OtpAuthenticator.verify` 默认实现只比对「当前时刻窗口」`generate()`（`HmacOtpAuthenticator`/`TotpAuthenticator` 未重写以遍历前后窗口），不做人/机时钟几秒偏差或恰好跨 `period`（默认 30s）边界的容错；生产 TOTP 校验通常需 ±1 窗口，本 Starter 既未提供 skew 配置也未兜底，客户端与服务端时钟略偏即验证失败；此外 `HmacOtpAuthenticator` 的 `@Data` 只覆盖父类 `secret`/`algorithm`/`digits`，`TotpAuthenticator.period`（默认 30s）无 setter，本 Starter 工厂连 `period` 也无法配置。
7. **`makeUrl` 产出的 URL 参数与实际不一致（缺陷①连带）**：`makeUrl(account,issuer)` 委托 `makeQrUrl`，其 URL 里的 `algorithm=`/`digits=` 取自认证器实例字段；但由于缺陷①，`type=totp` 时工厂配置的 algorithm/digits 从未写入实例，故扫码 URL 里的 `algorithm`/`digits` 永远是默认 `SHA1`/`6`——即使用户配了 SHA256/8 位，二维码告知认证 App 的参数仍是默认值，导致客户端生成的码与服务端期望不匹配。
8. **`@Data`/`@NoArgsConstructor` 滥用于配置类/门面/工厂**：`HmacOtpAutoConfiguration`（`@Data`+`@NoArgsConstructor`，零字段仍生成全套 getter/setter/equals/hashCode/toString）、`HmacOtpAccountAuthenticator`（`@Data` 会把注入的 `accountKeyProvider`/`authenticatorFactory` 纳入 equals/hashCode/toString）、`DefaultTotpAuthenticatorFactory`（`@Data`）；对 Spring 单例配置 Bean 生成这些方法无意义，`toString` 还可能牵出依赖对象。
9. **`HmacOtpAccountAuthenticator` 用 `@Autowired(required=false)` 表达「必需」**：`accountKeyProvider` 声明 `required=false`，随即在 `afterPropertiesSet` 若为 null 抛 `IllegalStateException`——语义自相矛盾，本应 `@Autowired`（required=true）由容器直接报错；且总开关默认 `enable=true`，意味着只要引入本 Starter 就强制应用必须提供 provider Bean，否则无法启动，缺少「仅用密钥生成、不做校验」的宽松使用姿势。
10. **`generateRandomKey` 种子长度对可配算法偏短**：`HmacOtpAuthenticator.generateSecretKey()` 固定生成 16 字节（128 位）随机种子；一旦按 `algorithm` 想切到 SHA256/SHA512（RFC 6238 建议密钥长度 ≥ 哈希输出长度）即偏短，而该长度不可配、加之缺陷①使 algorithm 本就对 totp 无效，API 表面呈现的「可配强算法」与实际能力不符。
11. **`hints` 段是与本模块无关的拷贝死条目**：元数据 `hints` 含 `server.servlet.jsp.class-name`、`server.tomcat.accesslog.encoding`，与 TOTP 毫无关系，系从其它 Starter 元数据复制残留（同 `swagger2-starter`/`ssh-tunnel-starter`/`swl-starter` 模式）。
12. **生态孤岛、无消费方与样例**：全仓库除自身 pom、父 `i2f-springboot/pom.xml` module、根 DM 外，无任何模块 import 本 Starter（grep 确认无 `test-totp-starter`、无下游消费），与同组多数 starter 至少配一个 `test-*` 样例不同；无集成测试、`@desc` 注释全空，实际可用性未经运行时验证。

## 生态位置

- **归属**：`i2f-springboot` 组，二次验证/动态口令专项 Starter。
- **上游依赖**：`i2f-otpauth`（HMAC-OTP 认证内核，其下再依赖 `i2f-codec`/`i2f-bytes` 等）。
- **下游消费**：无（仓库内暂无任何模块引入，属未被验证的独立装配件）。
- **定位小结**：TOTP 在 Boot 侧的「即用装配」，双 SPI 解耦密钥来源与算法分派是清晰亮点；但**核心可配项 `algorithm`/`digits` 因工厂分支结构对全部文档化 `type` 完全失效**、`factory` 开关元数据键错位、自动配置类无 `@Configuration`、`verify` 无时间窗容错，使其「开箱可用」的成色明显不足，加之仓库内无任何消费方与样例，成熟度偏低。
