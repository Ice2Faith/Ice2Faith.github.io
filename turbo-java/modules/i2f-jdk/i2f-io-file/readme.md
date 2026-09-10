# i2f-io-file

> **全能文件操作工具集**——6 源文件约 1444 行，纯 JDK + 4 个内部依赖，全 main 无测试。提供 `FileUtil` 全能静态工具（文件读写/拷贝/移动/删除/合并/分割/路径规约/树遍历/CSV 解析）+ `FileType` 魔数判定枚举（76 种）+ `FileTypeUtil` 类型匹配工具 + `FileMime` MIME 类型映射表（~420 条）+ `FileSpecies` 文件种类分类器（8 大类）+ `FileTrash` 应用级回收站机制。被全仓 22+ 模块（`i2f-extension-compress`、`i2f-extension-document`、`i2f-extension-ftp`、`i2f-extension-hdfs`、`i2f-extension-opencv` 等）广泛消费。

---

## 模块定位

- **功能**：提供 JDK 文件操作封装——路径规约（`../` 解析）、文件读取/写入（TXT/CSV 支持）、拷贝/移动/删除（递归+过滤）、合并/分割（Java 序列化格式 meta）、魔数类型判定、MIME 查询、文件分类、回收站管理
- **所属层级**：`i2f-jdk` IO 工具层，位于 `i2f-io-stream`（流操作基础）的消费者位置

## 包结构

```
i2f.io.file/
├── FileUtil.java          (702 行)  全能文件操作静态工具
├── FileType.java          (171 行)  文件类型魔数枚举（76 种）
├── FileTypeUtil.java      (89 行)   文件类型匹配工具
└── i2f.io.file.core/
    ├── FileMime.java      (450 行)  MIME 类型映射表（~420 条目）
    ├── FileSpecies.java   (68 行)   文件种类分类器（8 大类）
    └── FileTrash.java     (111 行)  应用级回收站
```

## 依赖关系

| 依赖 | 类型 | 用途 | 是否真实使用 |
|------|------|------|-------------|
| `lombok` | 编译期 | `@Data`+`@NoArgsConstructor` | **真实使用**（`FileTrash` 使用 `@Data`+`@NoArgsConstructor`） |
| `i2f-text` | 编译+运行 | 提供 `StringUtils`（`isEmpty`/`getFileNameOnly`/`getFileExtension`/`join`） | **真实使用**（`FileUtil`、`FileMime`、`FileSpecies`） |
| `i2f-io-stream` | 编译+运行 | 提供 `StreamUtil`（`streamCopy`/`readBytes`/`convertByteStream`） | **真实使用**（`FileUtil`、`FileTypeUtil`） |
| `i2f-array` | 编译+运行 | 提供 `ArrayUtil`（`compare`） | **真实使用**（`FileTypeUtil`） |
| `i2f-resources` | 编译+运行 | 提供 `ResourceUtil`（`getClasspathResource`） | **真实使用**（`FileUtil.getClasspathExtraFile`） |

## 类详解

### 1. FileUtil（702 行）—— 全能文件操作静态工具

核心功能概览：

```
文件元数据
├── getTempFileName() / getTempFile()          临时文件名/文件
├── getSpecies(String) / getMimeType(String)   文件种类+MIME 委托
├── getFilename / getNameOnly / getSuffix      文件名/纯名/后缀

目录操作
├── useDir / useParentDir                      确保目录存在（递归 mkdirs）
├── getWritableFile / getFile                  可写文件/路径拼接

路径规约（核心）
├── pathGen(String)                            ../ 解析、分隔符统一
├── pathGen(basePath, relativePath)            基路径+相对路径拼接
├── pathRoute(String[], Vector)                路径片段栈规约

文件读写
├── load(File, OutputStream)                   文件→输出流
├── save(InputStream, File)                    输入流→文件
├── save(byte[]/String, File)                  字节/字符串→文件
├── loadTxtFile(File)                          全文文本读取
├── readTxtFile(File, ...)                     行级文本读取（偏移量/计数/过滤/映射）
├── readCvsFile(File, ...)                     CSV 解析（表头映射）

文件操作
├── copy(src, dst, filter)                     递归拷贝（含 renameTo 尝试）
├── move(src, dst)                             移动（copy+delete）
├── delete(file, filter)                       递归删除
├── merge(dst, withMeta, srcFiles, filter)     多文件合并（Java 序列化元数据）
├── splitMeta(dstPath, metaFile, filter)       合并文件还原

遍历
├── tree(file, level, filter)                  递归树遍历

工具
├── convertByteStream(byte 变换)               字节变换过滤器
├── overwriteRenameFile                        同名自动编号
├── getFileWithClasspath                       支持 classpath: 前缀
├── getClasspathExtraFile                      类路径资源外置
├── moveToTrash(file)                          回收站
├── realpath(path)                             路径规约别名
```

**路径规约核心算法：**

```java
// pathGen("/usr/./local/../bin/") → "/usr/bin"
// 根据首次出现分隔符位置判断偏好（/ 或 \\）
// 遇 . 跳过，遇 .. 出栈，其余入栈
// 保持首尾分隔符不变
```

**merge/splitMeta 文件合并格式：**

```
[文件1元数据] [文件1内容] [文件2元数据] [文件2内容] ...
元数据格式（Java ObjectOutputStream）：
    int:   文件名长度
    byte[]:文件名 UTF-8
    long:  文件大小
```

### 2. FileType（171 行）—— 76 种文件魔数判定枚举

按文件头魔数（magic number）识别文件类型，比后缀识别更可靠。

| 类别 | 类型枚举 |
|------|---------|
| 压缩 | ZIP、RAR、TAR、GZIP、7Z、BZIP2、XZ |
| Java | CLASS、JAR、SMALI |
| 文档 | MS2003、MS2007、PDF、DOC、WPS |
| 图片 | PNG、JPG、BMP、GIF、WEBP、ICO、TIFF、JPEG、PSD |
| 音频 | MP3、WAV、AMR、WMA、FLAC、AIFF、AC3、DTS |
| 视频 | MP4、FLV、AVI、MOV、MKV、WMV、MPEG |
| 可执行 | EXE（3 变体）、ELF、SO、OBJ、DLL、LIB |
| 数据库 | SQLITE、DB、IDX、INNODB、MDB |
| 字体 | TTF、OTF、WOFF、WOFF2、TTC |
| 其他 | CHM、ISO、MSI、CAB、APK、VHD 等 |

### 3. FileTypeUtil（89 行）—— 魔数匹配工具

```java
// 单匹配
FileType type = FileTypeUtil.matchType(file);  // 按魔数长度降序，返回最长匹配
// 多匹配（如 ZIP 和 JAR 可能同时匹配）
List<FileType> types = FileTypeUtil.matchTypes(file);
// 指定类型判定
boolean isPdf = FileTypeUtil.isType(file, FileType.PDF);
```

### 4. FileMime（450 行）—— MIME 类型映射表

包含约 420 条后缀↔ MIME 类型的映射，覆盖标准 MIME 类型（text/plain、image/jpeg、application/json 等）和大量边缘类型。默认返回 `application/octet-stream`。

### 5. FileSpecies（68 行）—— 文件种类分类器

将文件归为 8 大类：
- **pictures**：jpg/jpeg/png/gif/bmp/ico/webp/svg/psd 等
- **videos**：mp4/mkv/rmvb/flv/avi/mov/wmv 等
- **audios**：mp3/ogg/wav/aac/flac/wma/amr 等
- **documents**：txt/doc/docx/xls/xlsx/pdf/html/xml/json/java 等
- **execuables**：exe/msc/elf/apk/bat/jar/py/sh/class
- **compresses**：zip/rar/gz/tar/7z/iso/war 等
- **libdlls**：lib/dll/sys/so/a
- **others**：未匹配归入此类

### 6. FileTrash（111 行）—— 应用级回收站

```java
FileTrash.DEFAULT.moveToTrash(file);  // 移动到回收站目录
FileTrash.DEFAULT.cleanTrash();        // 清空回收站
FileTrash.DEFAULT.cleanTrashBeforeDays(7);  // 清理 N 天前文件
```

回收站结构：
```
.app_trash/              ← 回收站根目录（可系统属性 file.trash.default 指定）
  └── 2026-09-10/        ← 按日期分目录
        ├── HHmmss_uuid.suffix    ← 重命名后的文件
        └── metadata.properties   ← 元数据（原名、原始路径、创建时间）
```

## 使用示例

### 路径规约

```java
FileUtil.pathGen("/usr/./local/../bin/");
// → "/usr/bin"

FileUtil.pathGen("C:\\Users\\..\\Windows\\System32");
// → "C:\\Windows\\System32"

FileUtil.pathGen("/base/path", "../other/file.txt");
// → "/base/other/file.txt"
```

### 文件递归拷贝+过滤

```java
FileUtil.copy(new File("/dst"), new File("/src"),
    file -> file.getName().endsWith(".java"));
```

### 文件递归删除

```java
FileUtil.delete(new File("/tmp/dir"),
    file -> !file.getName().endsWith(".keep"));
```

### 多文件合并与还原

```java
// 合并
FileUtil.merge(new File("merged.dat"), true,
    new File[]{file1, file2, file3});

// 还原（将合并文件按元数据拆分到目标目录）
FileUtil.splitMeta(new File("/output"), new File("merged.dat"));
```

### 魔数类型判定

```java
FileType type = FileTypeUtil.matchType(new File("test.pdf"));
// → FileType.PDF (魔数 0x25,0x50,0x44,0x46)
```

### CSV 解析

```java
List<Map<String, String>> data = FileUtil.readCvsFile(
    new File("data.csv"), ",", true, Charset.forName("UTF-8"));
```

### 回收站模式

```java
FileTrash.DEFAULT.moveToTrash(new File("temp.txt"));
// → 移动到 .app_trash/2026-09-10/HHmmss_uuid.txt
```

## 消费关系

**全仓 22+ 模块以 POM 声明 + Java import 形式消费：**

| 消费者 | 使用内容 |
|--------|---------|
| `i2f-extension-compress` | `FileUtil`（压缩/解压文件处理） |
| `i2f-extension-document` | `FileUtil`（Word/Excel 文档处理） |
| `i2f-extension-ftp` | `FileUtil` |
| `i2f-extension-hdfs` | `FileUtil` |
| `i2f-extension-opencv` / `i2f-extension-opencv-data` / `i2f-extension-opencv-javacv` | `FileUtil` |
| `i2f-extension-sftp` | `FileUtil`（2 文件） |
| `i2f-extension-tts-espeak` / `i2f-extension-tts-jacob` | `FileUtil` |
| `i2f-extension-okhttp` / `i2f-extension-httpclient` / `i2f-extension-ocr-tesseract` / `i2f-extension-gif` / `i2f-extension-asr-vosk` | `FileUtil`（POM 声明） |
| `i2f-jdk-ext-web` | `FileUtil` + `FileMime` |
| `i2f-spring-web` | `FileMime` |
| `i2f-compiler` / `i2f-compress-impl` / `i2f-ai-std` | `FileUtil` |
| `i2f-swl` / `i2f-template-render` | `FileUtil` |

**POM 注册点：**
- `i2f-jdk/pom.xml` L90 — modules 声明
- `i2f-jdk-all/pom.xml` L309 — 全仓聚合依赖
- `pom.xml`（根）L486 — versions 托管

## 已知缺陷

| 级别 | 缺陷 | 位置 |
|------|------|------|
| **中** | **`splitMeta` 反复新建 `ObjectInputStream` 致多文件还原失败**：循环中每次 `new ObjectInputStream(is)` 从底层流读取魔数 `0xACED0005`，第二次及以后遇到文件内容数据导致 `StreamCorruptedException`，仅能还原第一个嵌入文件 | `FileUtil.java` L311-317 |
| **中** | **`merge` 使用 Java 序列化专有格式，互操作性差**：元数据写为 Java `ObjectOutputStream` 格式，合并产物只能用本模块 `splitMeta` 解析，无法与其他工具或语言互操作 | `FileUtil.java` L270-281 |
| **低** | **`pathGen` 路径分隔符检测仅扫描第一次出现位置**：混合分隔符路径（如 `C:\\a/b/c`）中反斜杠与正斜杠的第一次出现位置不足以可靠推断用户意图的分隔符偏好 | `FileUtil.java` L64-76 |
| **低** | **`FileTypeUtil.matchType` 与 `matchTypes` 代码重复**：两个方法完全独立实现排序+长度计算，未提取公共方法，维护需同步修改 | `FileTypeUtil.java` |
| **低** | **`FileTrash.cleanTrashBeforeDays` 静默吞异常**：`LocalDateTime.parse` 日期解析失败时 catch 块完全忽略异常 | `FileTrash.java` L106 |
| **低** | **`FileTrash.properties.store` 注释参数为 null**：properties 文件头部无生成说明信息 | `FileTrash.java` L74 |
| **低** | **全模块零测试**：1444 行代码全部在 main 源码集，无任何测试 | 全部 6 文件 |
| **低** | **`getClasspathExtraFile` 未关闭 InputStream**：`getResourceAsStream` 后未显式 close，但 `save` 内部关闭了流 | `FileUtil.java` L692 |
| **低** | **`readTxtFile` 内部 `BufferedReader` 未用 try-with-resources**：JDK 1.8 中 reader 未在 finally 块关闭，异常路径可能泄漏文件句柄 | `FileUtil.java` L537 |

## 对比

| 维度 | i2f-io-file | Apache Commons IO | Google Guava |
|------|-------------|-------------------|--------------|
| 核心类 | `FileUtil` 单工具类 | `FileUtils` + `IOUtils` 等 | `Files` + `ByteStreams` 等 |
| 路径规约 | 内置 `pathGen`（`../` 解析） | `FilenameUtils.normalize` | 无 |
| 文件合并 | 专有 Java 序列化格式 | 无 | 无 |
| 魔数判定 | 76 种内置 | 无 | 无 |
| MIME 映射 | ~420 条内置 | `MimeTypeMap`（有限） | 无 |
| 文件分类 | 8 大类内置 | 无 | 无 |
| 回收站 | `FileTrash` 内置 | 无 | 无 |
| 依赖 | 零外部（仅 i2f 内部模块） | 需要引入 | 需要引入 |

## 总结

`i2f-io-file` 是 i2f-turbo-java 中**文件操作的入口级工具模块**，主要特点：

1. **全能单工具类设计**：`FileUtil` 覆盖文件操作的绝大多数场景——读写、拷贝、移动、删除、合并、分割、路径规约、树遍历、CSV 解析，一行静态调用完成
2. **内置魔数/种类/MIME三文件类型系统**：`FileType`（魔数 76 种）+ `FileSpecies`（8 大类）+ `FileMime`（~420 条），无需外部依赖即支持丰富的文件类型识别
3. **应用级回收站**：`FileTrash` 支持按日期的目录结构、元数据记录、定期清理
4. **广泛消费**：被全仓 22+ 模块消费，是 i2f 生态中文件操作的标准基础设施

关键缺陷在于 `splitMeta` 的多文件还原功能因 `ObjectInputStream` 反复构造而损坏，以及 `merge` 使用 Java 序列化专有格式缺乏互操作性。