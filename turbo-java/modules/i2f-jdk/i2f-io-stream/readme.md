# i2f-io-stream

> **Java 字节流操作工具集**——13 源文件约 727 行，纯 JDK 零外部依赖，全 main 无测试。提供 `StreamUtil` 全能静态工具（流拷贝/广播/范围拷贝/本地化/读写） + `CheckedStreamUtil` 校验和流工具 + `BoostChecksum` 自定义校验和 + XOR 加密流体系（`IEncryptor`/`XorEncryptor`/`EncryptInputStream`/`EncryptOutputStream`）+ 4 种特殊流实现（`BlackHoleOutputStream` 黑洞/`WhiteHoleInputStream` 白洞/`LazyInputStream`/`LazyOutputStream` 延迟初始化/`TempFileInputStream` 自动删除临时文件）。被全仓 25+ 模块（`i2f-extension-antlr4`、`i2f-extension-compress`、`i2f-extension-document`、`i2f-extension-okhttp`、`i2f-extension-freemarker` 等）作为 IO 基础设施广泛消费。

---

## 模块定位

- **功能**：提供 JDK 流操作的增强工具与特殊流实现——流拷贝（普通/范围/广播/加密/校验）、流本地化（内存/临时文件回退）、读写字节/字符串到流/文件/URL、以及多款即用型装饰流
- **所属层级**：`i2f-jdk` IO 基础层，位于 `i2f-io-file`（文件操作）和 `i2f-io-filesystem`（文件系统）的上游

## 依赖关系

| 依赖 | 类型 | 用途 | 是否真实使用 |
|------|------|------|-------------|
| 无 | — | — | 纯 JDK，零外部依赖 |

> **零依赖设计**：POM 不声明任何依赖（含 lombok），所有能力基于 `java.io`/`java.nio`/`java.net`/`java.util.zip` 纯 JDK API 实现。

## 包结构

```
i2f.io.stream/
├── StreamUtil.java              ← 343 行 · 全能静态工具
├── checksum/
│   ├── BoostChecksum.java       ← 38 行 · 自定义校验和
│   └── CheckedStreamUtil.java   ← 71 行 · 校验和流工具
├── encrypt/
│   ├── IEncryptor.java          ← 15 行 · 加解密接口
│   ├── XorEncryptor.java        ← 61 行 · XOR 动态因子加解密器
│   ├── EncryptInputStream.java  ← 44 行 · 加密包装输入流
│   ├── EncryptOutputStream.java ← 39 行 · 加密包装输出流
│   └── EncryptStreamUtil.java   ← 36 行 · 加密流工具
└── impl/
    ├── BlackHoleOutputStream.java ← 37 行 · 黑洞输出流（/dev/null）
    ├── WhiteHoleInputStream.java  ← 24 行 · 白洞输入流（随机字节源）
    ├── LazyInputStream.java       ← 84 行 · 延迟初始化输入流
    ├── LazyOutputStream.java      ← 61 行 · 延迟初始化输出流
    └── TempFileInputStream.java   ← 37 行 · 自动删除临时文件输入流
```

## 类结构总览

### StreamUtil（343 行）——全能静态工具

| 方法 | 功能 | 特性 |
|------|------|------|
| `broadcastStream` | 一输入多输出广播 | 单 InputStream → N × OutputStream |
| `streamCopy(is, os, ...)` | 流拷贝（多重重载） | 自动 Buffered 包装、灵活 close 控制 |
| `streamCopySize` | 定长流拷贝 | 指定 bytes 数 |
| `streamCopyRange` | 范围流拷贝 | offset + size，支持边界回退 |
| `convertByteStream` | 逐字节变换 | Function<Byte,Byte> 映射器 |
| `readBytes` | 读字节（InputStream/File/URL） | 多重重载（定长/偏移） |
| `readString` | 读字符串（InputStream/File/URL） | 指定字符集，默认 UTF-8 |
| `writeBytes` | 写字节（OutputStream/File） | 自动创建父目录 |
| `writeString` | 写字符串 | 支持文件输出自动 mkdirs |
| `localStream` | 流本地化 | ≤5MB 内存 → ByteArrayInputStream；>5MB 临时文件 → TempFileInputStream |

### checksum 包——校验和工具

- **`BoostChecksum`**：实现 `java.util.zip.Checksum` 接口的自定义校验和算法，`sign = abs(sign × 17 + (idx × b) × 27 % 2077)`，初始值 177
- **`CheckedStreamUtil`**：基于 JDK `CheckedInputStream`/`CheckedOutputStream` 的便捷工具，支持 Adler32 与自定义 Checksum 类型

### encrypt 包——XOR 加密流体系

- **`IEncryptor`**：加解密接口，因 XOR 加密与解密过程相同，双操作共用同一接口
- **`XorEncryptor`**：XOR 动态因子实现，`b = (b ^ fac) & 0x0ff`，`fac = fac × 31 + idx`，支持 maxLen 限制加密长度
- **`EncryptInputStream`**：继承 `FilterInputStream`，读取时实时解密
- **`EncryptOutputStream`**：继承 `FilterOutputStream`，写入时实时加密
- **`EncryptStreamUtil`**：便捷方法——流加密拷贝、字节/字符串加解密

### impl 包——特殊流实现

| 类 | 功能 | 用途场景 |
|----|------|---------|
| `BlackHoleOutputStream` | 黑洞输出流 | 所有写入无操作，类似 `/dev/null` |
| `WhiteHoleInputStream` | 白洞输入流 | 每次 `read()` 返回 `Random.nextInt(256)`，可设种子 |
| `LazyInputStream` | 延迟初始化输入流 | `Supplier<InputStream>` 懒加载，首次读取时初始化，双重检查锁定线程安全 |
| `LazyOutputStream` | 延迟初始化输出流 | `Supplier<OutputStream>` 懒加载，首次写入时初始化 |
| `TempFileInputStream` | 临时文件输入流 | 继承 `FileInputStream`，`close()` 时自动删除临时文件 |

## 核心机制详解

### 1. 全功能流拷贝体系

`StreamUtil` 提供多重载流拷贝，构成核心能力：

```
streamCopy(is, os)                              ← 基础全量拷贝
streamCopy(is, os, autoClose)                   ← 统一 autoClose
streamCopy(is, os, closeOs, closeIs)            ← 分开控制关闭
streamCopy(os, autoClose, iss...)               ← 多输入合并到同一输出
streamCopyRange(is, os, offset, size, ...)      ← 范围拷贝（分段读写）
streamCopySize(is, os, size, ...)               ← 定长简写
broadcastStream(is, closeIs, closeOs, oss...)   ← 一输入多输出广播
convertByteStream(is, os, mapper)               ← 逐字节变换 + Buffered 包装
```

所有拷贝方法内部默认使用 1MB 缓冲区（`BUFF_SIZE = 1024 × 1024`），并对非 `Buffered*` 流自动包装。

### 2. 流本地化策略（localStream）

`localStream` 是模块中最有价值的设计之一——将网络流/任意流转换为可重复读取的本地流：

```
localStream(is)
    → 最多读 5MB 到 ByteArrayOutputStream
    → 若 count < 5MB：返回 ByteArrayInputStream（全内存）
    → 若 count ≥ 5MB：写临时文件 → 返回 TempFileInputStream（close 自动删）
```

两层防护：`memLimit` 参数受 `Math.min(memLimit, 5MB)` 上限保护（同时也是缺陷）；对已为 `ByteArrayInputStream`/`FileInputStream` 的流可选跳过（`force=false`）。

### 3. XOR 加密流体系

对称加密设计，加密与解密使用完全相同的操作：

```
XorEncryptor(fac, maxLen)
    enc(b): b = (b ^ fac) & 0x0ff, fac = fac × 31 + idx, idx++
    maxLen: 加密长度上限（-1 表示不限）

EncryptInputStream(in, encryptor)       ← FilterInputStream
    read() → super.read() → encryptor.encrypt(b)

EncryptOutputStream(os, encryptor)      ← FilterOutputStream
    write(b) → encryptor.encrypt(b) → super.write(b)
```

### 4. 校验和流工具

`CheckedStreamUtil` 封装 JDK 的 `CheckedInputStream`/`CheckedOutputStream`：

```
streamCopyChecksum(is, os, type)        ← 流拷贝同时计算校验和
streamChecksum(is, type)                ← 仅计算校验和（含空读循环）
bytesChecksum(bytes, type)              ← 字节数组校验和
stringChecksum(str, type)               ← 字符串校验和（UTF-8）
```

### 5. 延迟初始化流（LazyInputStream/LazyOutputStream）

线程安全的延迟初始化装饰器，适用于需要延迟打开资源的场景：

```java
LazyInputStream supplier = new LazyInputStream(() -> {
    // 仅在首次读取时执行
    return new FileInputStream("data.bin");
});
requireCheck() 使用双重检查锁定（DCL）保证线程安全
```

### 6. 特殊流（黑洞/白洞/临时文件）

- **`BlackHoleOutputStream`**：所有 `write`/`flush`/`close` 均为空操作，适用于丢弃日志/测试场景
- **`WhiteHoleInputStream`**：永不结束的随机字节源，`read()` 返回 `Random.nextInt(256)`，适用于压力测试
- **`TempFileInputStream`**：`close()` 时删除底层临时文件，与 `localStream` 配合使用

## 使用示例

### 基础流拷贝

```java
// 文件到文件拷贝
StreamUtil.streamCopy(
    new FileInputStream("src.bin"),
    new FileOutputStream("dst.bin"));
```

### 读取文件内容

```java
// 读取文件全部字节
byte[] data = StreamUtil.readBytes(new File("data.bin"));

// 读取文件为 UTF-8 字符串
String text = StreamUtil.readString(new File("data.txt"));

// 读取指定范围
byte[] part = StreamUtil.readBytes(new File("data.bin"), 100, 1024);
```

### 写入文件

```java
// 字符串写入文件（自动创建父目录）
StreamUtil.writeString("Hello World", new File("output/hello.txt"));

// InputStream 写入文件
StreamUtil.writeBytes(inputStream, new File("output/data.bin"));

// URL 下载到文件
StreamUtil.writeBytes(new URL("https://example.com/file.zip"),
    new File("downloads/file.zip"));
```

### 流广播

```java
// 一份输入同时写入多个输出
StreamUtil.broadcastStream(
    new FileInputStream("source.bin"),
    true, true,
    new FileOutputStream("copy1.bin"),
    new FileOutputStream("copy2.bin"),
    new FileOutputStream("copy3.bin"));
```

### 流本地化（可重复读取）

```java
// 将网络流本地化（≤5MB 内存，>5MB 临时文件）
InputStream local = StreamUtil.localStream(url.openStream());

// 可多次读取
byte[] data1 = StreamUtil.readBytes(local, true);
// 已关闭，需重新 localStream
```

### XOR 加密流

```java
// 加密写入
IEncryptor enc = new XorEncryptor(177, -1);
OutputStream eos = new EncryptOutputStream(
    new FileOutputStream("encrypted.bin"), enc);
StreamUtil.writeString("Hello World", eos, true);
eos.close();

// 解密读取（相同 XorEncryptor 构造参数）
IEncryptor dec = new XorEncryptor(177, -1);
InputStream eis = new EncryptInputStream(
    new FileInputStream("encrypted.bin"), dec);
String text = StreamUtil.readString(eis, true);
```

### 延迟初始化流

```java
// 资源在首次使用时才打开
LazyInputStream lazy = new LazyInputStream(() -> {
    System.out.println("Opening stream...");
    return new FileInputStream("data.bin");
});

// 此时尚未打开
Thread.sleep(1000);

// 首次读取触发实际打开
byte[] data = StreamUtil.readBytes(lazy, true);
```

## 消费关系

### 全仓消费者

`i2f-io-stream` 是全仓广泛消费的基础 IO 模块，共有 **25+ 处 Java import**（均为 `StreamUtil`）：

| 消费方 | 范围 |
|--------|------|
| `i2f-extension-antlr4`（Funic/Funvi/TinyScript） | 脚本引擎加载脚本 |
| `i2f-extension-compress`（Tar/Zip/Jar/Cpio） | 压缩流拷贝 |
| `i2f-extension-document`（SheetUtil/DocumentUtil） | Excel/Word 文档读写 |
| `i2f-extension-easyexcel`/`i2f-extension-fastexcel` | Excel 导出 |
| `i2f-extension-okhttp` | HTTP 请求体处理 |
| `i2f-extension-filesystem-*`（Minio/AliyunOSS/AwsS3） | 对象存储读写 |
| `i2f-extension-freemarker`/`i2f-extension-velocity` | 模板生成 |
| `i2f-extension-hdfs` | HDFS 读写 |
| `i2f-extension-browser-selenium` | 浏览器驱动 |
| `i2f-extension-ai-rag-sqlite` | AI RAG 向量库 |
| `i2f-extension-tts-espeak` | TTS 语音合成 |
| `i2f-extension-reverse-engineer-generator`（test） | 测试代码生成 |

### POM 注册

| 位置 | 行号 | 内容 |
|------|------|------|
| 根 pom.xml | L496 | 版本托管 |
| `i2f-jdk/pom.xml` | L92 | modules |
| `i2f-jdk-all/pom.xml` | L317 | 全仓聚合依赖 |
| `i2f-io-file/pom.xml` | L27 | 同族模块依赖 |
| `i2f-io-filesystem/pom.xml` | L22 | 同族模块依赖 |
| `i2f-network/pom.xml` | L27 | 网络模块依赖 |
| `i2f-codec-impl/pom.xml` | L27 | 编解码模块依赖 |
| `i2f-compress-std/pom.xml` | L22 | 压缩标准依赖 |
| `i2f-form/pom.xml` | L28 | 表单模块依赖 |
| `i2f-resources/pom.xml` | L22 | 资源模块依赖 |
| `i2f-ai-std/pom.xml` | L37 | AI 标准依赖 |
| `i2f-mixins/pom.xml` | L48 | Mixins 依赖 |
| 20+ 扩展模块 POM | — | 声明为直接依赖 |

## 已知缺陷

| 等级 | 缺陷 | 文件 | 说明 |
|------|------|------|------|
| **中** | `streamCopyChecksum` 校验和从未更新 | `CheckedStreamUtil.java:35` | `StreamUtil.streamCopy(is, os, ...)` 直接拷贝到 `os` 而非 `cos`（`CheckedOutputStream` 包装器），校验和不经 `CheckedOutputStream` 更新值始终为 0 |
| **中** | `XorEncryptor.encrypt(int)` 返回 -1 与流结束冲突 | `XorEncryptor.java:31-37` | 明文字节 `0xFF` 加密后仍为 `(byte)0xFF` → `encrypt` 返回 `-1`（InputStream 的流结束信号），造成 `read()` 提前结束 |
| **低** | `localStream` memLimit 上限被静默截断 | `StreamUtil.java:319` | `memLimit = Math.min(memLimit, defaultMaxLimit)` 将用户传入 >5MB 的值截断为 5MB，参数语义与行为不一致 |
| **低** | `WhiteHoleInputStream` 未实现 `close()` | `WhiteHoleInputStream.java:12-23` | 继承 InputStream 的空 close 实现，如果被包装在外部流中可能漏释放资源 |
| **低** | `LazyOutputStream.flush()` 不触发初始化 | `LazyOutputStream.java:48-51` | `flush()` 时 `os` 为 null 则静默跳过，不执行 `requireCheck()`，与 `close()` 行为一致但不同于 `write()` |
| **低** | `EncryptStreamUtil.stringDecrypt` 命名误导 | `EncryptStreamUtil.java:31-33` | 因 XOR 对称设计，`stringDecrypt` 直接调用 `bytesEncrypt` 实现，命名虽正确但隐藏了对称加密的本质 |
| **低** | 无测试源码 | — | 全模块零测试文件，13 个类无任何单元测试覆盖 |
| **低** | `TempFileInputStream` close 后不置空 fileName | `TempFileInputStream.java:27-34` | `close()` 后 `fileName` 未被置为 null，若重复调用 `close()` 可能触发二次删除已不存在的文件 |

## 与 JDK 原生对比

| 对比维度 | Java 标准库 | i2f-io-stream |
|----------|------------|---------------|
| 流拷贝 | `InputStream.transferTo`（JDK 9+） | 全版本兼容 + 多重载 + 范围拷贝 + 广播 |
| 校验和 | `CheckedInputStream`/`CheckedOutputStream` | `CheckedStreamUtil` 便捷封装 + 自定义 `BoostChecksum` |
| 加密流 | 无标准 XOR 流（需 `CipherInputStream`） | `XorEncryptor` + `EncryptInputStream`/`EncryptOutputStream` 即开即用 |
| 黑洞流 | 无标准实现 | `BlackHoleOutputStream` |
| 白洞流 | 无标准实现 | `WhiteHoleInputStream`（基于 Random） |
| 延迟初始化流 | 无标准实现 | `LazyInputStream`/`LazyOutputStream`（Supplier + DCL） |
| 流本地化 | 无标准实现 | `localStream`（≤5MB 内存 / >5MB 临时文件） |

## 总结

`i2f-io-stream` 是 `i2f-turbo-java` 全仓 IO 流操作的**基石模块**。以 13 文件约 727 行的极简体积实现了流拷贝、广播、范围拷贝、校验和、XOR 加密、流本地化、延迟初始化、黑洞/白洞等丰富功能，零外部依赖，纯 JDK 实现。被全仓 25+ 模块广泛消费作为 IO 基础设施。

核心价值在于：`localStream` 的智能本地化策略、`EncryptInputStream`/`EncryptOutputStream` 的即开即用 XOR 加密流、以及 `LazyInputStream`/`LazyOutputStream` 的延迟加载——这些是 JDK 标准库未直接提供的实用能力。

主要瑕疵包括 `CheckedStreamUtil.streamCopyChecksum` 校验和永不更新的逻辑错误（拷贝未经过 `CheckedOutputStream`）、`XorEncryptor` 字节值 `0xFF` 与流结束 `-1` 的冲突、以及部分方法论缺陷（无测试、memLimit 截断等）。