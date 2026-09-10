# i2f-io-filesystem

> **统一文件系统抽象层**——7 源文件约 795 行，纯 JDK + `i2f-io-stream` 依赖，全 main 无测试。以「`IFile` 对象语义接口 + `IFileSystem` 路径字符串接口」双层契约 + `AbsFile`/`AbsFileSystem` 抽象基类 + `FileSystemUtil` 路径工具 + `JdkFile`/`JdkFileSystem` JDK 本地实现，构筑可插拔的文件系统抽象。被 6 个 `i2f-extension-filesystem-*` 模块（FTP/HDFS/MinIO/AliyunOSS/AwsS3/SFTP，共 14 个类继承 `AbsFile`/`AbsFileSystem`）作为实现地基全面消费——新增一种远端文件系统只需实现约 10 个原语方法，其余 40+ 个方法（文本/行读写、拷贝、移动、递归建目录、严格路径校验）全部由基类自动获得。

---

## 模块定位

- **功能**：定义文件系统操作的双层接口契约与公共抽象实现，屏蔽本地盘、FTP、HDFS、对象存储等异构后端的差异，提供「面向对象文件」与「面向路径字符串」两种等价操作风格
- **所属层级**：`i2f-jdk` IO 工具层，位于 `i2f-io-stream`（流工具）之上、`i2f-extension-filesystem-*`（远端实现）之下
- **设计原则**：
  - **双层接口**：`IFile` 是「对象是路径的封装」——全部操作委托回 `IFileSystem` 的路径版方法；`IFileSystem` 是路径字符串直操作风格，二者能力等价
  - **模板方法**：`AbsFileSystem` 用 `FileSystemUtil` 提供组合型能力（`combinePath`/`absPath`/`getStrictFile`/`recursiveMkdirs`/`store`/`load`/`copyTo`/`moveTo`），实现方只需提供原语（是否存在/流/列目录/删除/建目录/长度）
  - **安全防御**：`getStrictFile` 通过 `absPath` 规约 `../`、`./`、`//`、`%00` 后做前缀校验，防止路径穿越非法访问
  - **跨文件系统桥接**：`copyTo`/`moveTo` 自动识别「同文件系统」（走原生路径操作）与「跨文件系统」（走流拷贝 + 删除）

## 依赖关系

| 依赖 | 类型 | 用途 | 是否真实使用 |
|------|------|------|-------------|
| `i2f-text` | 编译+运行 | — | **未使用**（全模块零 `i2f.text.*` 引用） |
| `i2f-io-stream` | 编译+运行 | `StreamUtil.streamCopy` 流拷贝（`AbsFile`/`AbsFileSystem`/`JdkFileSystem` 使用） | 真实使用 |

## 包结构

```
i2f.io.filesystem
├── IFile                  (122 行)  文件对象接口（~46 方法：读写/拷贝/移动/目录/元信息）
├── IFileSystem            ( 81 行)  文件系统接口（~27 方法：路径直操作 + getStrictFile 安全校验）
├── abs
│   ├── AbsFile            (273 行)  IFile 抽象基类：全操作委托回 FileSystem + 默认读写实现
│   ├── AbsFileSystem      (117 行)  IFileSystem 抽象基类：组合能力模板方法
│   └── FileSystemUtil     (112 行)  静态工具：recursiveMkdirs/combinePath/absPath/getStrictFile
└── jdk
    ├── JdkFile            (147 行)  JDK 本地 File 包装：状态化路径对象
    └── JdkFileSystem      (159 行)  JDK 本地文件系统：无状态原语 + volatile 共享单例
```

## 类结构总览

| 类 | 类型 | 职责 |
|----|------|------|
| `IFile` | 接口 | 文件对象契约：`getInputStream/getOutputStream/getReader/getWriter`（IO）+ `readText/readLines/writeText/appendLines`（便捷）+ `copyTo/moveTo/mkdir/mkdirs/delete`（操作）+ `getName/getExtension/getAbsolutePath/getDirectory/isFile/isDirectory/isExists/length`（元信息）；默认字符集 `UTF-8` |
| `IFileSystem` | 接口 | 文件系统契约：与 `IFile` 等价能力的路径版；独有 `getStrictFile`（防穿越严格获取）、`combinePath`（路径拼接）、`absPath`（相对路径规约）、`isReadable/isWritable/isAppendable`（权限判定） |
| `AbsFile` | 抽象类 | `IFile` 全方法实现：元信息/IO/操作**全部委托** `getFileSystem()` 对应路径方法；自带 `getName`（按分隔符取尾段）、`getReader/Writer`（InputStreamReader 包装）、`readBytes/readLines/writeLines`（流组合实现）、跨 FS `copyTo/moveTo`（流桥接） |
| `AbsFileSystem` | 抽象类 | `IFileSystem` 组合层实现：默认分隔符 `/`、`getFile(path,subPath)`/`getStrictFile`/`combinePath`/`absPath`/`getName`/`getDirectory` 由 `FileSystemUtil` 组合；`store/load/copyTo/moveTo/mkdirs` 用 `StreamUtil` + 流原语实现；`isReadable/isWritable` 弱判（存在 + 是文件） |
| `FileSystemUtil` | 工具类 | `recursiveMkdirs`（逐级向上建目录）、`combinePath`（智能拼接去重分隔符）、`absPath`（`%00` 截断 + 反斜杠归一 + Stack 规约 `./..///`）、`getStrictFile`（规约后前缀校验，越界抛 `IllegalStateException`） |
| `JdkFile` | 实现类 | `File` 包装：`fs` 字段实例初始化默认绑 `JdkFileSystem.getInstance()`（可 `setFileSystem` 替换）；IO/元信息直接委托 `java.io.File`；`moveTo` 对 `JdkFile` 目标用 `renameTo`，否则回退父类流桥接 |
| `JdkFileSystem` | 实现类 | 无状态（每次 `new File(path)`）：`volatile` 静态单例 `getInstance()`；`pathSeparator` = `File.separator`；`moveTo` 用 `renameTo`；`isReadable/isWritable/isAppendable` 均为「存在 + 是文件」弱判 |

## 分层架构

```mermaid
graph TB
    subgraph Consumer["消费者（i2f-extension-filesystem-*）"]
        EXT["FtpFileSystem / HdfsFileSystem / MinioFileSystem<br/>AliyunOssFileSystem / AwsS3OssFileSystem / SftpFileSystem<br/>（14 个类）"]
    end
    subgraph Abstract["抽象层"]
        AF["AbsFile<br/>(IFile 全委托)"]
        AFS["AbsFileSystem<br/>(组合能力模板)"]
        FSU["FileSystemUtil<br/>(路径工具)"]
    end
    subgraph Contract["契约层"]
        IF["IFile<br/>(~46 方法)"]
        IFS["IFileSystem<br/>(~27 方法)"]
    end
    subgraph Builtin["内置实现"]
        JF["JdkFile"]
        JFS["JdkFileSystem<br/>(volatile 单例)"]
    end
    subgraph Dep["依赖"]
        SU["i2f-io-stream<br/>StreamUtil.streamCopy"]
    end
    EXT -->|extends| AF
    EXT -->|extends| AFS
    AF -->|implements| IF
    AFS -->|implements| IFS
    AFS -->|使用| FSU
    AF -->|委托 to<br/>getFileSystem()| IFS
    JF -->|extends| AF
    JFS -->|extends| AFS
    AF -->|流桥接| SU
    AFS -->|流桥接| SU
    JFS -->|流拷贝| SU
```

## 核心机制详解

### 1. 双层接口：对象语义 ↔ 路径直操作

`IFile` 与 `IFileSystem` 是同一能力的两种表达——`IFile` 持路径状态、`IFileSystem` 无状态：

```java
// AbsFile：每一个对象方法都委托回 FileSystem 的路径版
@Override
public boolean isDirectory() {
    return getFileSystem().isDirectory(getPath());
}

@Override
public InputStream getInputStream() throws IOException {
    return getFileSystem().getInputStream(getPath());
}

@Override
public void delete() {
    getFileSystem().delete(getPath());
}
```

`AbsFile.getFile(String path)` 则通过 `getFileSystem().getFile(path)` 派生新文件对象——即 **「文件对象 = 文件系统 + 路径」** 的组合，实现方只要维护好 `fs` 和 `path` 两个字段即可获得全部对象语义能力。

### 2. 路径规约 absPath：安全防线第一层

`FileSystemUtil.absPath` 是路径穿越防御的基础设施：

```java
public static String absPath(String path, String pathSeparator) {
    if (path == null) { return null; }
    // URL 编码的 NUL 字节截断（防 %00 截断攻击）
    int idx = path.indexOf("%00");
    if (idx >= 0) { path = path.substring(0, idx); }
    // 反斜杠统一为正斜杠再处理
    if (path.contains("\\")) { path = path.replaceAll("\\\\", "/"); }
    // Stack 规约：. 忽略；.. 弹栈；空段忽略
    String[] arr = path.split("/");
    Stack<String> stack = new Stack<>();
    for (String item : arr) {
        if (".".equals(item)) { }
        else if ("..".equals(item)) { if (!stack.isEmpty()) { stack.pop(); } }
        else if ("".equals(item)) { }
        else { stack.push(item); }
    }
    // 重新拼接（栈空出栈的 .. 被静默丢弃 —— 无法逃逸到上级）
    StringBuilder ret = new StringBuilder();
    boolean first = true;
    for (String str : stack) {
        if (!first) { ret.append(pathSeparator); }
        ret.append(str);
        first = false;
    }
    return ret.toString();
}
```

`/a/b/../../etc` 规约后为 `etc`——栈空后的 `..` 被丢弃，保证无法向上逃逸。

### 3. 严格模式 getStrictFile：防穿越第二层

```java
public static IFile getStrictFile(IFileSystem fileSystem, String rootPath, String path) {
    IFile file = fileSystem.getFile(rootPath, path);
    String fullPath = fileSystem.absPath(file.getAbsolutePath());   // 规约后绝对路径
    if (fullPath.equals(rootPath)) { return file; }                 // 恰好等于根目录
    if (!fullPath.startsWith(rootPath + fileSystem.pathSeparator())) {
        throw new IllegalStateException("target path cannot access.");   // 越界拒绝
    }
    return file;
}
```

直接子路径前缀校验——`/root2` 不匹配 `/root/`，精确隔离子树。适用场景：Web 文件下载接口把用户传入的 `fileName` 作为 `path`，`rootPath` 固定为受控目录。

### 4. 跨文件系统桥接：同 FS 原生 / 跨 FS 流拷贝

```java
// AbsFile.copyTo
if (this.getFileSystem() == file.getFileSystem()) {
    this.getFileSystem().copyTo(this.getPath(), file.getPath());   // 同 FS：交给实现方（可优化）
} else {
    InputStream is = this.getInputStream();                        // 跨 FS：流桥接
    OutputStream os = file.getOutputStream();
    StreamUtil.streamCopy(is, os);
}

// AbsFile.moveTo 跨 FS 时追加删除源
```

`JdkFile.moveTo` 进一步优化：目标是 `JdkFile` 时走 `renameTo`（同盘瞬间完成），否则回退父类流桥接。

### 5. 内置 JDK 实现：状态化 File 包装 + 无状态系统

- **`JdkFile`**：持有 `java.io.File` 实例，元信息直接委托（`getName`/`getAbsolutePath`/`isDirectory`）；实例初始化块默认绑定共享单例 `JdkFileSystem.getInstance()`，可通过 `setFileSystem` 替换；
- **`JdkFileSystem`**：无状态——每个方法 `new File(path)` 临时构造；`volatile` 静态单例 + 私有构造器（类初始化保证线程安全）；`pathSeparator` = `File.separator`（Windows 为 `\`）。

### 6. 扩展模式：实现远端文件系统仅需原语

以 `i2f-extension-filesystem-ftp` 为参照，扩展一个文件系统分两步：

```java
// 第一步：文件对象 —— 只需 3 个字段方法
public class FtpFile extends AbsFile {
    private IFileSystem fs;
    private String path;
    public FtpFile(IFileSystem fs, String path) { this.fs = fs; this.path = path; }
    @Override public void setFileSystem(IFileSystem fs) { this.fs = fs; }
    @Override public IFileSystem getFileSystem() { return this.fs; }
    @Override public String getPath() { return path; }
}

// 第二步：文件系统 —— 只实现原语，组合能力全部从基类继承
public class FtpFileSystem extends AbsFileSystem implements Closeable {
    @Override public IFile getFile(String path) { return new FtpFile(this, path); }
    @Override public InputStream getInputStream(String path) { return getClient().retrieveFileStream(path); }
    @Override public OutputStream getOutputStream(String path) { return getClient().storeFileStream(path); }
    @Override public OutputStream getAppendOutputStream(String path) { return getClient().appendFileStream(path); }
    @Override public boolean isDirectory(String path) { /* listFiles 匹配 */ }
    @Override public boolean isFile(String path) { /* ... */ }
    @Override public boolean isExists(String path) { /* ... */ }
    @Override public List<IFile> listFiles(String path) { /* ... */ }
    @Override public void delete(String path) { /* ... */ }
    @Override public void mkdir(String path) { getClient().makeDirectory(path); }
    @Override public long length(String path) { /* ... */ }
    @Override public boolean isAppendable(String path) { return isFile(path); }
}
```

约 10 个原语方法之外，`getStrictFile`/`combinePath`/`absPath`/`mkdirs`/`store`/`load`/`copyTo`/`moveTo`/`getName`/`getDirectory` 及 `IFile` 全部 46 个对象方法自动获得。

## 使用示例

### 1. 本地文件基本操作

```java
// 通过文件系统获取文件对象
IFileSystem fs = JdkFileSystem.getInstance();
IFile file = fs.getFile("D:/data/demo.txt");

// 元信息
System.out.println(file.getName());       // demo.txt
System.out.println(file.getAbsolutePath());
System.out.println(file.isFile());        // true / false

// 目录操作
IFile dir = fs.getFile("D:/data/output");
dir.mkdirs();                              // 递归创建（FileSystemUtil.recursiveMkdirs）
```

### 2. 读写文本与行

```java
IFile file = JdkFileSystem.getInstance().getFile("D:/data/demo.txt");

file.writeText("你好，i2f", "UTF-8");      // 默认 UTF-8 也有重载
file.appendText("\n第二行", "UTF-8");

String text = file.readText("UTF-8");      // 整体读取
List<String> lines = file.readLines("UTF-8");   // 按行读取（LinkedList）

file.writeLines(Arrays.asList("a", "b", "c"));     // 覆盖写入多行
file.appendLines(Arrays.asList("d", "e"));          // 追加多行
```

### 3. 严格模式防路径穿越

```java
IFileSystem fs = JdkFileSystem.getInstance();
String rootPath = "D:/web/upload";

// 正常访问：命中 rootPath 子树
IFile ok = fs.getStrictFile(rootPath, "images/logo.png");

// 越界访问：absPath 规约后前缀不匹配，抛 IllegalStateException
try {
    IFile bad = fs.getStrictFile(rootPath, "../../etc/passwd");
    // "../../../Windows/win.ini"
} catch (IllegalStateException e) {
    System.out.println("访问被拒绝：" + e.getMessage());   // target path cannot access.
}
```

### 4. 拷贝与移动（含跨文件系统）

```java
IFile src = JdkFileSystem.getInstance().getFile("D:/a.txt");

// 同文件系统拷贝
IFile dst = JdkFileSystem.getInstance().getFile("D:/copy/b.txt");
src.copyTo(dst);

// 同文件系统移动（JdkFile 走 renameTo 瞬间完成）
src.moveTo(JdkFileSystem.getInstance().getFile("D:/moved/a.txt"));

// 跨文件系统：src 在本地、dst 在 FTP —— 自动流桥接
src.copyTo(new FtpFileSystem(ftpMeta).getFile("/remote/a.txt"));
```

### 5. 路径工具独立使用

```java
FileSystemUtil.combinePath("/root/", "/sub/a.txt", "/");   // "/root/sub/a.txt"
FileSystemUtil.absPath("/app/../data/./file.txt", "/");     // "app/data/file.txt"
FileSystemUtil.absPath("a/b/%00c/d", "/");                  // "a/b"（%00 截断）
```

### 6. 面向抽象编程：后端无关的业务代码

```java
// 业务代码只依赖 IFileSystem/IFile，本地与远端通用
public void exportReport(IFileSystem fs, String dir) {
    IFile folder = fs.getFile(dir);
    folder.mkdirs();
    IFile report = fs.getFile(dir, "report.csv");
    report.writeLines(buildCsvLines());
}

exportReport(JdkFileSystem.getInstance(), "D:/out");       // 本地盘
exportReport(new HdfsFileSystem(conf), "/data/out");        // HDFS
exportReport(new MinioFileSystem(minio), "/bucket/out");    // MinIO
```

## 消费关系

### Java 代码级消费者（6 模块、14 个类）

| 模块 | 继承类 | 后端 |
|------|--------|------|
| `i2f-extension-filesystem-ftp` | `FtpFile`、`FtpFileSystem` | Apache Commons Net FTP |
| `i2f-extension-filesystem-hdfs` | `HdfsFile`、`HdfsFileSystem` | Hadoop HDFS |
| `i2f-extension-filesystem-minio` | `MinioFile`、`MinioFileSystem` | MinIO |
| `i2f-extension-filesystem-oss-aliyun` | `AliyunOssFile`、`AliyunOssFileSystem` | 阿里云 OSS |
| `i2f-extension-filesystem-oss-aws-s3` | `AwsS3OssFile`、`AwsS3OssFileSystem` | AWS S3 |
| `i2f-extension-filesystem-sftp` | `SftpFile`、`SftpFileSystem`、`ProxySftpFile`、`ProxySftpFileSystem` | SFTP（含代理） |

消费模式统一为：`XxxFile extends AbsFile`（仅 3 方法）+ `XxxFileSystem extends AbsFileSystem`（约 10 原语方法，需资源管理的加 `implements Closeable`）。

### POM 注册链路

| 位置 | 行号 | 内容 |
|------|------|------|
| `i2f-jdk/pom.xml` | L91 | `<module>i2f-io-filesystem</module>` |
| 根 `pom.xml` | L491 | 版本托管 `<artifactId>i2f-io-filesystem</artifactId>` |
| `i2f-jdk-all/pom.xml` | L313 | 全仓聚合引入 |
| 6 个 extension 模块 pom.xml | L22/L23 | `<artifactId>i2f-io-filesystem</artifactId>` |

## 已知缺陷

| # | 位置 | 等级 | 问题 |
|---|------|------|------|
| 1 | `AbsFile.getExtension()` | **中** | **语义反转**：`return name.substring(0, idx)` 返回的是「去掉扩展名的主名」（`"a.txt"` → `"a"`），而非扩展名 `"txt"`——应为 `substring(idx + 1)`；无扩展名/隐藏文件（`.gitignore` → `""`）同样反常。当前全仓零调用方，缺陷尚未被触发 |
| 2 | `FileSystemUtil.getStrictFile` | 低 | 前缀校验隐含要求 `rootPath` 本身已规约且为绝对路径：若 `rootPath` 含 `..` 或为相对路径，`startsWith` 比较失效导致**全量拒绝或误放行**；Windows 下大小写敏感还可能误拒合法路径 |
| 3 | `JdkFile.moveTo` | 低 | `renameTo` 返回值被忽略——跨盘符、目标已存在（Windows）等失败场景**静默无异常**，调用方误以为移动成功；对比 `AbsFileSystem.moveTo` 的流拷贝 + 删除则必然成功 |
| 4 | `JdkFileSystem.getDirectory("/")` | 低 | `new File("/").getParentFile()` 返回 `null` → `getAbsolutePath()` **NPE**；`JdkFile.getDirectory()` 对无父路径相对文件（`"a.txt"`）返回 `new JdkFile(null)`，后续任何操作 NPE |
| 5 | `JdkFile.getFile(String)` | 低 | `return new JdkFile(path)` 绕过 `this.fs` 绑定——若当前对象经 `setFileSystem` 绑定了自定义文件系统，派生的子文件对象仍绑回 `JdkFileSystem` 单例（`AbsFile.getFile` 正确用 `getFileSystem()`） |
| 6 | `isReadable/isWritable/isAppendable` | 低 | 三方法（`JdkFileSystem` 与 `AbsFileSystem`）均为「存在 + 是文件」的弱判定，未使用 `File.canRead/canWrite`——只读文件也返回 `true`，权限语义名不副实 |
| 7 | `pom.xml` | 低 | **`i2f-text` 依赖声明未用**：全模块仅引用 `i2f.io.stream.StreamUtil`，零 `i2f.text.*` 引用 |
| 8 | `AbsFile.copyTo/moveTo`、`readBytes` | 低 | 流拷贝后未关闭输入/输出流——依赖 `StreamUtil.streamCopy` 约定「不关闭、由调用方管理」，但方法本身未提供关闭途径，存在**资源泄漏风险**（`writeBytes` 则有显式 close） |
| 9 | `AbsFile.writeLines/appendLines` | 低 | 行结束符硬编码 `"\n"`（LF），非 `System.lineSeparator()`——Windows 记事本等工具可能显示为一行 |
| 10 | `JdkFileSystem.copyTo` | 信息 | 与 `AbsFileSystem.copyTo` 实现完全重复（仅 `moveTo` 有差异化）——冗余覆写 |
| 11 | `AbsFileSystem` | 信息 | 未实现接口方法 `isAppendable`（抽象类允许），继承方必须自行实现（6 个 extension 均已实现） |

## 对比：i2f-io-file vs i2f-io-filesystem

| 维度 | `i2f-io-file` | `i2f-io-filesystem` |
|------|---------------|---------------------|
| 定位 | **本地**文件全能工具（6 源文件约 1444 行） | **可插拔**文件系统抽象层（7 源文件约 795 行） |
| 核心类型 | `FileUtil` 静态工具 + 枚举/映射表 | `IFile`/`IFileSystem` 契约 + 抽象基类 |
| 后端范围 | 仅 JDK 本地 `java.io.File` | 本地 + FTP/HDFS/MinIO/OSS/S3/SFTP 等 |
| 扩展方式 | 不适用（工具类） | 继承 `AbsFile`/`AbsFileSystem` 实现原语 |
| 附加资产 | 魔数 76 种、MIME ~420 条、回收站 | 路径规约、防穿越校验、跨 FS 桥接 |
| 关系 | **互补**：本地批处理用 io-file；多后端统一接入用 io-filesystem | 同左 |

## 总结

**核心价值**：
- 为 6 种远端存储（FTP/HDFS/MinIO/阿里云 OSS/AWS S3/SFTP）提供了**统一的文件操作契约**——业务代码面向 `IFileSystem`/`IFile` 编程即可自由切换后端
- 抽象层厚度控制得当：795 行实现「双层接口 + 完整默认实现 + 路径安全工具 + JDK 内置实现」
- 内置两层路径穿越防御（`absPath` 规约 + `getStrictFile` 前缀校验），适配 Web 文件访问安全场景

**主要风险**：
- `AbsFile.getExtension()` 语义反转（#1）— 当前无调用方，一旦被使用必错
- `JdkFile.moveTo` 静默失败（#3）与 `getDirectory` 根路径 NPE（#4）— 边缘场景稳定性问题
- `i2f-text` 冗余依赖（#7）与跨 FS 流不关闭（#8）— 工程卫生问题
