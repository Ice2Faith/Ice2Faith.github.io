# i2f-springboot-oss-minio-starter

> MinIO 对象存储的 Spring Boot 自动装配 Starter：以 `MinioProperties`（继承 `MinioMeta` 的 url/accessKey/secretKey 三元连接参数）绑定 `i2f.minio.*` 配置，`MinioAutoConfiguration` 据此产出两个 Bean —— 面向 MinIO 原生 API 的封装工具 `MinioUtil`（桶/对象/前缀/预签名 URL 等操作），以及把对象存储适配成统一文件系统的 `MinioFileSystem`（实现 `i2f-io-filesystem` 的 `IFileSystem` 抽象）。整体能力由开关 `i2f.minio.enable`（默认 true）控制启停；本 Starter 为薄装配层，真正的实现来自内部依赖 `i2f-extension-minio` 与 `i2f-extension-filesystem-minio`。

## 模块路径

- `i2f-springboot/i2f-springboot-oss-minio-starter`

## 模块依赖

| groupId | artifactId | scope | optional | 说明 |
|---------|-----------|-------|----------|------|
| i2f.turbo | i2f-extension-filesystem-minio | compile | 否 | 内部依赖，提供 `MinioFileSystem`（`IFileSystem` 的 MinIO 实现），并传递依赖 `i2f-extension-minio` |
| org.projectlombok | lombok | compile | 否 | POJO 与日志代码生成 |
| org.springframework.boot | spring-boot-starter | provided | 是 | Boot 基础自动装配 |
| org.springframework.boot | spring-boot-configuration-processor | provided | 是 | 配置元数据处理器 |
| io.minio | minio (7.1.0) | provided | 是 | MinIO 官方客户端，`MinioClient` 及桶/对象 API |

> 说明：`MinioUtil` / `MinioMeta` 位于 `i2f-extension-minio`，本模块 pom 未直接声明，而是通过 `i2f-extension-filesystem-minio`（compile）传递获得；`minio` 客户端在两个 extension 中均为 provided，故使用方需自行引入 MinIO 驱动。

## 模块设计

### 架构设计

本 Starter 是一个纯装配层，把「配置绑定 → 客户端构建 → 两层 API 封装」串成一条链，核心实现下沉到两个 i2f 扩展模块：

```mermaid
flowchart TD
    YML["i2f.minio.* 配置"] -->|@EnableConfigurationProperties| Props["MinioProperties extends MinioMeta"]
    Props -->|url / accessKey / secretKey| Cfg["MinioAutoConfiguration"]
    Cfg -->|"@Bean minioUtil()"| Util["MinioUtil"]
    Util -->|new MinioUtil(meta)| Client1["MinioClient.builder().endpoint().credentials()"]
    Cfg -->|"@Bean minioFileSystem(MinioUtil)"| Fs["MinioFileSystem"]
    Fs -->|getClient 复用 minioUtil.getClient| Client2["同一个 MinioClient"]
    Client1 --> Minio["io.minio MinioClient"]
    Client2 --> Minio
    Fs -.implements.-> IFS["i2f-io-filesystem IFileSystem"]
```

- **配置层**：`MinioProperties` 直接继承 `MinioMeta`（仅 url/accessKey/secretKey 三字段），以 `i2f.minio` 前缀绑定，不额外定义连接参数。
- **客户端层**：`MinioUtil(MinioMeta)` 构造内部经 `MinioUtil.getClient(meta)` 用 `MinioClient.builder()` 建立唯一客户端；`MinioFileSystem` 通过 `minioUtil.getClient()` 复用同一客户端，两 Bean 共享连接。
- **封装层**：`MinioUtil` 暴露原生桶/对象/前缀/预签名 URL 操作；`MinioFileSystem` 将 bucket 映射为目录层级、object 映射为文件，适配成统一 `IFileSystem`。
- **开关层**：类级 `@ConditionalOnExpression("${i2f.minio.enable:true}")` 控制整个自动配置是否生效。

### 包结构

```
i2f.springboot.minio
├── MinioAutoConfiguration     // 自动配置类，产出 MinioUtil / MinioFileSystem 两个 Bean
└── properties
    └── MinioProperties        // 绑定 i2f.minio.*，继承 MinioMeta
```

## 模块目的

- 让 MinIO 对象存储在 Spring Boot 中「开箱即用」：仅配置 endpoint 与密钥三元组即可获得程序化操作客户端。
- 提供两套互补的抽象：贴近 MinIO 原生能力的 `MinioUtil`，以及把对象存储当文件系统使用的 `MinioFileSystem`，屏蔽桶/对象与目录/文件的差异。
- 作为薄装配层复用 i2f 扩展实现，避免在 Starter 内重复封装业务逻辑。

## 模块功能

| 功能 | 触发/条件 | 说明 |
|------|-----------|------|
| 注册 `MinioUtil` Bean | `i2f.minio.enable=true`（默认） | 用 `MinioProperties` 构建客户端，提供桶增删查、对象上传/下载/列举、前缀创建、预签名 URL 等原生操作 |
| 注册 `MinioFileSystem` Bean | 同上，依赖 `MinioUtil` | 以 `minioUtil.getClient()` 构造，将对象存储适配为统一 `IFileSystem`（getFile/isDirectory/isExists/listFiles/store…） |
| 配置绑定 | `@EnableConfigurationProperties(MinioProperties)` | 绑定 `i2f.minio.url/access-key/secret-key` |
| 整体开关 | `@ConditionalOnExpression("${i2f.minio.enable:true}")` | 置 false 时两个 Bean 均不注册 |

## 模块主要使用方法

### 1. 引入并配置

```yaml
i2f:
  minio:
    enable: true
    url: http://127.0.0.1:9000
    access-key: minioadmin
    secret-key: minioadmin
```

### 2. 注入 MinioUtil 做原生操作

```java
@Autowired
private MinioUtil minioUtil;

public void demo() throws IOException {
    minioUtil.bucketCreate("my-bucket");
    minioUtil.upload("my-bucket", "a.txt", new File("/tmp/a.txt"), "text/plain");
    InputStream in = minioUtil.download("my-bucket", "a.txt");
    String url = minioUtil.urlOf("my-bucket", "a.txt"); // 预签名访问 URL
}
```

### 3. 注入 MinioFileSystem 当文件系统用

```java
@Autowired
private MinioFileSystem minioFileSystem;

public void demo() throws IOException {
    // path 形如 bucketName/objectName
    minioFileSystem.getFile("my-bucket/dir/a.txt")
            .writeBytes("hello".getBytes(StandardCharsets.UTF_8));
    boolean exists = minioFileSystem.isExists("my-bucket/dir/a.txt");
}
```

> 注意：使用方须自行在应用中引入 `io.minio:minio` 驱动（本 Starter 中为 provided），否则运行期缺少 `MinioClient` 类将导致装配失败。

## 配置项参考

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `i2f.minio.enable` | Boolean | `true` | 是否启用 MinIO 自动配置（由 `@ConditionalOnExpression` 直接读环境，非 `MinioProperties` 字段） |
| `i2f.minio.url` | String | 无 | MinIO endpoint 地址 |
| `i2f.minio.access-key` | String | 无 | 访问密钥 accessKey |
| `i2f.minio.secret-key` | String | 无 | 秘钥 secretKey |

## 模块特性总结

- **双层抽象**：同一客户端同时暴露 `MinioUtil`（原生 API）与 `MinioFileSystem`（统一文件系统），按需选用。
- **薄装配**：本模块仅两个类，实现全部下沉 `i2f-extension-minio` / `i2f-extension-filesystem-minio`，职责清晰。
- **客户端复用**：`MinioFileSystem` 复用 `MinioUtil` 的 `MinioClient`，两 Bean 共享连接、避免重复建链。
- **配置极简**：连接参数直接继承 `MinioMeta` 三元组，无前缀冗余定义。
- **独立开关**：`i2f.minio.enable` 一键启停整套装配。
- **零版本绑定**：minio/spring-boot 均 provided+optional，版本交由使用方 BOM 管理。

## 模块瑕疵或错误

> 以下为按源码静态审阅识别的潜在问题，仅作标注、未做运行实证。

1. **`@Import({MinioClient.class})` 可疑且多余**：`MinioClient`（minio 7.1.0）无公开无参构造，须经 `MinioClient.builder()` 构建；将其 `@Import` 为 Bean 会以构造器注入方式尝试实例化，易在启动期实例化失败或产出一个无人使用的空客户端 Bean。实际两个 Bean 都自行构建/复用客户端，此 `@Import` 无被消费。
2. **缺类存在保护**：`minio` 为 provided+optional，但自动配置未加 `@ConditionalOnClass(MinioClient.class)`（也无 `@ConditionalOnMissingBean`）。若使用方未引入 minio 驱动，`MinioUtil`/`MinioFileSystem` 类加载将失败而非优雅跳过。
3. **自动配置类未标 `@Configuration`**：仅靠 `spring.factories`/`imports` 登记，`@Bean` 方法以 lite 模式代理失效（本例靠方法参数注入规避了跨方法调用问题，但偏离常规自动配置写法）。
4. **`@Data` 用于配置类 + 遗留字段**：`MinioAutoConfiguration` 标注 `@Data` 会为其生成无意义的 getter/setter/equals/hashCode；其中 `String dateFormat = "yyyy-MM-dd HH:mm:ss SSS"` 字段全类未被使用，属模板残留。
5. **日志文案复制粘贴错误**：`minioFileSystem()` 中 `log.info("MinioUtil config done.")` 与 `minioUtil()` 文案相同，未区分实际注册的 Bean。
6. **`enable` 未纳入属性类**：`i2f.minio.enable` 仅被 `@ConditionalOnExpression` 读环境，`MinioProperties`/`MinioMeta` 无对应字段，配置类字段与 metadata 登记项不完全对齐。
7. **配置元数据 hints 模板残留**：`additional-spring-configuration-metadata.json` 的 `hints` 为 `server.servlet.jsp.class-name`、`server.tomcat.accesslog.encoding` 等与本模块无关的示例项，未清理。
8. **无 region / 桶 / 超时等扩展参数**：`MinioMeta` 仅三元连接参数，无法通过配置设定 region、默认 bucket、连接超时等，复杂场景需自行覆盖 Bean。
