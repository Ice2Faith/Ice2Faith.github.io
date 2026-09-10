# i2f-compress-std

> 压缩**标准契约层**（`std` 契约与实现分离），延续 `i2f-codec-std`/`i2f-cache-std`/`i2f-clock-std` 的「接口稳定、实现可换」范式。全模块仅 **5 个类型**（2 接口 + 2 数据模型 + 1 抽象骨架），以 `ICompressor` 定义**多文件归档级**压缩契约（`compress*` 打包 + `release` 解包），以 `ISingleCompressor` 定义**单流级**压缩契约（`compress(is,os)`/`release(is,os)` 流式编解码），以 `AbsCompressor` 沉淀 `compressFile`（`File` 集合递归遍历→`CompressBindFile`→`CompressBindData`→`compressBindData`）与 `release`（默认解压到磁盘目录）的公共骨架。`CompressBindData`（`@Data` `@NoArgsConstructor`：`fileName`+`directory`+`InputStream`+`size`）与 `CompressBindFile`（`File`+`directory`）为数据载体。`i2f-compress-impl`（JDK 内置 Zip/Jar + Gzip/Deflate/Zip 单流共 5 实现）、`i2f-extension-7zip`、`i2f-extension-compress`（Apache Commons Compress 五格式）、`i2f-extension-zip4j` 均为其下游实现。

## 模块路径

- `i2f-jdk/i2f-compress-std`

## 模块依赖

| 坐标 | scope | optional | 说明 |
|---|---|---|---|
| `i2f.turbo:i2f-io-stream` | compile | false | `AbsCompressor.release` 默认解压用 `StreamUtil.streamCopy` 写文件 |
| `org.projectlombok:lombok` | compile | false | `CompressBindData`/`CompressBindFile` 真实使用 `@Data` `@NoArgsConstructor` |

> 注：`lombok` 为本模块**真实使用**（区别于 `i2f-cache-std`/`i2f-codec-std` 等 std 模块的冗余声明），`CompressBindData.java` 第 3–4 行逐行标注 `@Data` `@NoArgsConstructor`。

## 模块设计

### 正交双轴契约

```
┌──────────────────────────────────────────┐
│            ICompressor                    │
│  多文件归档级（archive-level）             │
│  compressBindData / compressBindFile      │
│  compressFile / release                   │
│  输入/输出均为 File                        │
└──────────────┬───────────────────────────┘
               │  extends
               ▼
┌──────────────────────────────────────────┐
│          AbsCompressor                    │
│  抽象骨架：                               │
│  · compressFile → fetchFiles(递归遍历)    │
│    → compressBindFile → CompressBindData  │
│    → compressBindData(留给子类实现)        │
│  · release → release(callback)(默认写磁盘) │
└──────────────────────────────────────────┘

┌──────────────────────────────────────────┐
│          ISingleCompressor                │
│  单流级（single-stream level）             │
│  compress(is, os) / release(is, os)       │
│  + compressAsBytes / releaseAsBytes       │
│  输入/输出均为 Stream                      │
└──────────────────────────────────────────┘
```

- **`ICompressor`**：面向**归档格式**（Zip/Tar/7z/Jar/Cpio 等），操作单位是「目录 → 压缩包文件」与「压缩包文件 → 目录」的**整体打包解包**
- **`ISingleCompressor`**：面向**单流压缩算法**（Gzip/Deflate 等），操作单位是 `InputStream → OutputStream` 的**流式编解码**，不关心目录结构
- **`AbsCompressor`**：模板方法模式——`compressFile` 经 `fetchFiles` 递归遍历 `File` 集合（支持 `Predicate<File>` 过滤）、组装 `CompressBindFile` 列表、转为 `CompressBindData`（打开 `FileInputStream`），最终由子类实现的 `compressBindData` 写压缩包；`release` 默认经 `StreamUtil.streamCopy` 写到输出目录

### 数据模型

- **`CompressBindData`**（`@Data` `@NoArgsConstructor`）：`fileName`（条目名）+ `directory`（在压缩包中的目录路径）+ `InputStream`（数据源）+ `size`（字节数，默认 `-1` 未知）
- **`CompressBindFile`**（`@Data` `@NoArgsConstructor`）：`File` + `directory`（在压缩包中的目录路径）

`CompressBindData.of(CompressBindFile)` 将 `File` 转换为 `InputStream`+`fileName`+`size` 绑定数据。

## 模块目的

1. **统一归档/压缩契约**：为全仓多种压缩格式（Zip/Jar/Tar/7z/Cpio/Gzip/Deflate）提供「接口稳定、实现可换」的编程接口
2. **数据模型标准化**：`CompressBindData`/`CompressBindFile` 统一「条目名 + 目录路径 + 数据源」的描述模型，解耦压缩算法与文件系统
3. **双轴正交分离**：归档级（目录结构感知）与单流级（纯数据流）分离，避免将 Zip 的多文件操作与 Gzip 的流操作混为一谈

## 模块功能

| 功能 | 接口/类 | 方法 |
|---|---|---|
| 多文件压缩（绑定流） | `ICompressor` | `compressBindData(output, Collection<CompressBindData>)` |
| 多文件压缩（绑定文件） | `ICompressor` | `compressBindFile(output, Collection<CompressBindFile>)` |
| 多文件压缩（File 集合 + 过滤） | `ICompressor` → `AbsCompressor` | `compressFile(output, inputs, filter)` |
| 解包到目录 | `ICompressor` → `AbsCompressor` | `release(input, output)` / `release(input, output, consumer)` |
| 变参便捷调用 | `ICompressor` | `compress(output, CompressBindData...)` / `compress(output, File...)` |
| 单流压缩 | `ISingleCompressor` | `compress(is, os)` |
| 单流解压 | `ISingleCompressor` | `release(is, os)` |
| 单流字节数组便捷 | `ISingleCompressor` | `compressAsBytes(is/byte[])` / `releaseAsBytes(is/byte[])` |
| 文件递归遍历 | `AbsCompressor` | `fetchFiles(files, filter)` / `fetchFilesNext(...)` |
| `CompressBindFile`→`CompressBindData` | `CompressBindData` | `of(CompressBindFile)` |

## 模块主要使用方法

### 1. 实现自定义归档压缩器（继承 `AbsCompressor`）

```java
public class ZipCompressor extends AbsCompressor {
    @Override
    public void compressBindData(File output, Collection<CompressBindData> inputs) throws IOException {
        try (ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(output))) {
            for (CompressBindData data : inputs) {
                String entryName = data.getDirectory() + "/" + data.getFileName();
                if (entryName.startsWith("/")) entryName = entryName.substring(1);
                zos.putNextEntry(new ZipEntry(entryName));
                StreamUtil.streamCopy(data.getInputStream(), zos, false, false);
                zos.closeEntry();
            }
        }
    }

    @Override
    public void release(File input, File output, BiConsumer<CompressBindData, File> consumer) throws IOException {
        try (ZipInputStream zis = new ZipInputStream(new FileInputStream(input))) {
            ZipEntry entry;
            while ((entry = zis.getNextEntry()) != null) {
                String name = entry.getName();
                String dir = name.contains("/") ? name.substring(0, name.lastIndexOf("/")) : "";
                String fileName = name.contains("/") ? name.substring(name.lastIndexOf("/") + 1) : name;
                CompressBindData data = new CompressBindData(fileName, dir, zis, entry.getSize());
                consumer.accept(data, output);
                zis.closeEntry();
            }
        }
    }
}
```

### 2. 实现自定义单流压缩器（实现 `ISingleCompressor`）

```java
public class GzipCompressor implements ISingleCompressor {
    @Override
    public void compress(InputStream is, OutputStream os) throws IOException {
        try (GzipOutputStream gos = new GzipOutputStream(os)) {
            StreamUtil.streamCopy(is, gos, false, true);
        }
    }

    @Override
    public void release(InputStream is, OutputStream os) throws IOException {
        try (GzipInputStream gis = new GzipInputStream(is)) {
            StreamUtil.streamCopy(gis, os, true, false);
        }
    }
}
```

### 3. 使用 `AbsCompressor` 的 `compressFile` 便捷方法

```java
ZipCompressor compressor = new ZipCompressor();
// 递归打包多个目录/文件，支持过滤器
List<File> sources = Arrays.asList(new File("/path/to/dir"), new File("/path/to/file.txt"));
compressor.compressFile(new File("/path/to/output.zip"), sources,
    file -> !file.getName().endsWith(".tmp"));  // 过滤临时文件

// 解压到指定目录
compressor.release(new File("/path/to/output.zip"), new File("/path/to/extract"));
```

## 模块特性总结

- **双轴正交契约**：`ICompressor`（归档级）与 `ISingleCompressor`（单流级）分离，各司其职
- **模板方法骨架**：`AbsCompressor` 沉淀文件遍历/绑定转换/默认解压，子类只需实现最底层 `compressBindData` 与 `release(callback)`
- **`Predicate` 过滤**：`compressFile` 支持 `Predicate<File>` 运行时过滤文件
- **`BiConsumer` 回调**：`release(input, output, consumer)` 每条目的自定义落盘逻辑
- **数据模型统一**：`CompressBindFile`（文件级）→ `CompressBindData`（流级）→ `compressBindData`（算法级）递进转换
- **下游覆盖广**：JDK 原生/7-Zip/Apache Compress/Zip4j 四套实现共用同一契约

## 下游与关联

| 下游实现模块 | 实现类 | 格式 |
|---|---|---|
| `i2f-compress-impl` | `ZipJdkCompressor` / `JarJdkCompressor` | Zip / Jar |
| `i2f-compress-impl` | `GzipSingleCompressor` / `DeflaterSingleCompressor` / `ZipSingleCompressor` | Gzip / Deflate / Zip 单流 |
| `i2f-extension-7zip` | `SevenZCompressor` | 7z |
| `i2f-extension-compress` | `ZipApacheCompressor` / `TarApacheCompressor` / `JarApacheCompressor` / `CpioApacheCompressor` / `SevenZApacheCompressor` | Zip / Tar / Jar / Cpio / 7z |
| `i2f-extension-zip4j` | `ZipZip4jCompressor` | Zip |
| `i2f-jdk-all` | 聚合门面 | 依赖收口 |

## 已知实现瑕疵

- **`AbsCompressor.compressBindFile` 逐一打开 `FileInputStream` 未惰性化**：所有输入文件的流在同一时间全部打开，大文件集合场景内存压力高
- **`AbsCompressor.release`（默认）catch 吞异常**：L106 `catch (Exception e) { e.printStackTrace(); }` 静默吞掉单条目解压异常，不中断整体释放流程也不抛给调用方
- **`fetchFilesNext` 目录自身也作为条目加入**：L44 `ret.add(new CompressBindFile(file, rootDir));` 把目录本身也加入压缩列表（尚未过滤），可能导致部分实现中空目录重复处理
- **`CompressBindData.size` 默认 `-1` 语义未契约化**：下游实现消费 `size` 时须自行判 `-1`（未知），否则可能造成异常或性能损失
- **`ICompressor.release(File, File)` 无返回/回调检测**：无法获知解压成功与否的统计信息
- **`ISingleCompressor` 无 `close()` 契约**：调用方需自行管理 `InputStream`/`OutputStream` 的关闭