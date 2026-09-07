# 文件系统抽象与多实现

## 概述

项目提供了统一的标准文件系统接口体系（`i2f-io-filesystem`），通过接口-抽象类-具体实现的分层设计，将本地文件系统、FTP、SFTP、HDFS、MinIO、阿里云
OSS、AWS S3 等 7 种完全不同的存储后端统一在同一套 API 下。业务代码面向 `IFile` / `IFileSystem` 编程，可无缝切换底层存储。

## 模块信息

| 模块                                                  | 所属层           | 说明                        |
|-----------------------------------------------------|---------------|---------------------------|
| `i2f-jdk/i2f-io-filesystem`                         | i2f-jdk       | 核心接口 + 抽象类 + JDK 本地文件系统实现 |
| `i2f-extension/i2f-extension-filesystem-ftp`        | i2f-extension | FTP 文件系统实现                |
| `i2f-extension/i2f-extension-filesystem-sftp`       | i2f-extension | SFTP 文件系统实现（含代理跳板）        |
| `i2f-extension/i2f-extension-filesystem-hdfs`       | i2f-extension | HDFS 文件系统实现               |
| `i2f-extension/i2f-extension-filesystem-minio`      | i2f-extension | MinIO 对象存储文件系统实现          |
| `i2f-extension/i2f-extension-filesystem-oss-aliyun` | i2f-extension | 阿里云 OSS 文件系统实现            |
| `i2f-extension/i2f-extension-filesystem-oss-aws-s3` | i2f-extension | AWS S3 对象存储文件系统实现         |

## 依赖关系

```
i2f-io-filesystem (核心接口层)
    ├── 依赖: i2f-text, i2f-io-stream
    │
    ├── i2f-extension-filesystem-ftp     (commons-net FTPClient)
    ├── i2f-extension-filesystem-sftp    (JSch ChannelSftp)
    ├── i2f-extension-filesystem-hdfs    (Hadoop FileSystem)
    ├── i2f-extension-filesystem-minio   (MinIO Java SDK)
    ├── i2f-extension-filesystem-oss-aliyun  (Aliyun OSS SDK)
    └── i2f-extension-filesystem-oss-aws-s3  (AWS S3 SDK v2)
```

## 核心接口体系

### 接口继承图谱

```
IFileSystem                         -- 文件系统接口（25 个方法）
├── AbsFileSystem                   -- 抽象实现（路径组合/安全路径/流拷贝/递归mkdir）
│   ├── JdkFileSystem               -- JDK 本地文件系统（单例）
│   ├── FtpFileSystem               -- FTP（commons-net，Closeable）
│   ├── SftpFileSystem              -- SFTP（JSch，Closeable）
│   ├── ProxySftpFileSystem         -- 代理跳板 SFTP（JSch + 端口转发，Closeable）
│   ├── HdfsFileSystem              -- Hadoop HDFS（Closeable）
│   ├── MinioFileSystem             -- MinIO 对象存储
│   ├── AliyunOssFileSystem         -- 阿里云 OSS
│   └── AwsS3OssFileSystem          -- AWS S3

IFile                               -- 文件对象接口（35+ 个方法）
├── AbsFile                         -- 抽象实现（委托 IFileSystem，读写文本/字节/行）
│   ├── JdkFile                     -- JDK 本地文件（包装 java.io.File）
│   ├── FtpFile                     -- FTP 文件
│   ├── SftpFile                    -- SFTP 文件
│   ├── ProxySftpFile               -- 代理 SFTP 文件
│   ├── HdfsFile                    -- HDFS 文件
│   ├── MinioFile                   -- MinIO 文件
│   ├── AliyunOssFile               -- 阿里云 OSS 文件
│   └── AwsS3OssFile                -- AWS S3 文件

FileSystemUtil                      -- 工具类（路径组合/安全路径解析/递归mkdir）
```

### IFileSystem — 文件系统接口

定义了文件系统的完整操作抽象，共 25 个方法：

| 方法分类  | 方法                                                             | 说明                     |
|-------|----------------------------------------------------------------|------------------------|
| 路径操作  | `pathSeparator()`                                              | 路径分隔符                  |
|       | `combinePath(path, subPath)`                                   | 路径拼接                   |
|       | `absPath(path)`                                                | 相对路径转绝对路径（防路径遍历攻击）     |
|       | `getAbsolutePath(path)`                                        | 获取绝对路径                 |
|       | `getName(path)`                                                | 获取文件名                  |
| 文件获取  | `getFile(path)` / `getFile(path, subPath)`                     | 获取 IFile 对象            |
|       | `getStrictFile(rootPath, path)`                                | 严格模式获取文件（限定子树范围，防截断攻击） |
|       | `getDirectory(path)`                                           | 获取目录                   |
| 状态检测  | `isDirectory(path)` / `isFile(path)` / `isExists(path)`        | 类型与存在性检测               |
|       | `isReadable(path)` / `isWritable(path)` / `isAppendable(path)` | 权限检测                   |
| 目录操作  | `listFiles(path)`                                              | 列举目录内容                 |
|       | `mkdir(path)` / `mkdirs(path)`                                 | 创建目录/递归创建              |
|       | `delete(path)`                                                 | 删除文件/目录                |
| 流 I/O | `getInputStream(path)`                                         | 获取输入流                  |
|       | `getOutputStream(path)`                                        | 获取输出流（覆盖写）             |
|       | `getAppendOutputStream(path)`                                  | 获取追加输出流                |
|       | `store(path, is)`                                              | 从输入流存储数据               |
|       | `load(path, os)`                                               | 加载数据到输出流               |
| 文件操作  | `copyTo(src, dst)`                                             | 复制文件                   |
|       | `moveTo(src, dst)`                                             | 移动文件                   |
|       | `length(path)`                                                 | 获取文件大小                 |

### IFile — 文件对象接口

面向文件实体的完整操作抽象，共 35+ 个方法（含 default 方法）：

| 方法分类  | 方法                                                                                  | 说明                         |
|-------|-------------------------------------------------------------------------------------|----------------------------|
| 基础属性  | `getPath()` / `getName()` / `getExtension()` / `getAbsolutePath()`                  | 路径信息                       |
|       | `getFileSystem()` / `setFileSystem(fs)`                                             | 所属文件系统                     |
|       | `pathSeparator()`                                                                   | 路径分隔符                      |
| 导航    | `getFile(path)` / `getFile(path, subPath)` / `getFile(IFile, subPath)`              | 获取关联文件                     |
|       | `getDirectory()`                                                                    | 获取父目录                      |
| 状态    | `isDirectory()` / `isFile()` / `isExists()`                                         | 类型与存在性                     |
| 目录    | `listFiles()`                                                                       | 列举子项                       |
| 删除    | `delete()`                                                                          | 删除                         |
| 流 I/O | `getInputStream()` / `getOutputStream()` / `getAppendOutputStream()`                | 字节流                        |
|       | `getReader(charset)` / `getWriter(charset)` / `getAppendWriter(charset)`            | 字符流（BufferedReader/Writer） |
|       | `store(is)` / `load(os)`                                                            | 流式传输                       |
| 快捷读写  | `writeBytes(data)` / `readBytes()`                                                  | 字节读写                       |
|       | `writeText(text, charset)` / `readText(charset)`                                    | 文本读写                       |
|       | `appendBytes(data)` / `appendText(text, charset)`                                   | 追加写入                       |
|       | `readLines(charset)` / `writeLines(lines, charset)` / `appendLines(lines, charset)` | 行读写                        |
| 目录操作  | `mkdir()` / `mkdirs()`                                                              | 创建目录                       |
| 文件操作  | `copyTo(file)` / `moveTo(file)`                                                     | 复制/移动（支持跨文件系统）             |
|       | `length()`                                                                          | 文件大小                       |

> **跨文件系统操作**: `AbsFile.copyTo()` / `moveTo()` 自动判断源和目标是否同一文件系统，同系统直接操作，跨系统则通过流中转。

## 抽象基类

### AbsFileSystem — 文件系统抽象实现

提供大部分 `IFileSystem` 方法的通用实现，子类仅需实现少量核心方法：

- **默认路径分隔符**: `/`
- **路径组合**: 委托 `FileSystemUtil.combinePath()`，自动处理分隔符
- **安全路径**: 委托 `FileSystemUtil.absPath()`，去除 `../`、`./`、`//`、`%00` 等
- **严格文件获取**: 委托 `FileSystemUtil.getStrictFile()`，校验路径子树关系
- **流操作**: `store()`/`load()`/`copyTo()`/`moveTo()` 基于 `StreamUtil.streamCopy()` 流拷贝
- **递归创建**: `mkdirs()` 委托 `FileSystemUtil.recursiveMkdirs()`

**子类必须实现的方法**（模板方法模式）：

```
getFile(path)          -- 创建具体 IFile 实例
getAbsolutePath(path)  -- 路径解析
isDirectory(path)      -- 目录判断
isFile(path)           -- 文件判断
isExists(path)         -- 存在性判断
listFiles(path)        -- 目录列举
delete(path)           -- 删除
getInputStream(path)   -- 输入流
getOutputStream(path)  -- 输出流
mkdir(path)            -- 创建目录
length(path)           -- 文件大小
```

### AbsFile — 文件对象抽象实现

将几乎所有操作委托给所属的 `IFileSystem`，子类仅需提供：

```
getPath()              -- 文件路径
getFileSystem()        -- 所属文件系统
setFileSystem(fs)      -- 设置文件系统
```

通用实现包括：所有状态检测、流 I/O、读写文本/字节/行、目录操作、跨文件系统复制/移动。

### FileSystemUtil — 工具类

| 方法                                      | 说明                                     |
|-----------------------------------------|----------------------------------------|
| `combinePath(path, subPath, separator)` | 智能路径拼接，自动处理分隔符重复                       |
| `absPath(path, separator)`              | 路径安全化：去除 `../`、`./`、`//`、`%00`，防路径遍历攻击 |
| `getStrictFile(fs, rootPath, path)`     | 严格文件获取：校验目标路径必须在 rootPath 子树下，否则抛异常    |
| `recursiveMkdirs(file)`                 | 递归创建目录（自动创建不存在的父级）                     |

## 实现详情

### JdkFileSystem — JDK 本地文件系统

| 属性        | 值                                                      |
|-----------|--------------------------------------------------------|
| 模块        | `i2f-jdk/i2f-io-filesystem`                            |
| 类         | `JdkFileSystem` / `JdkFile`                            |
| 底层        | `java.io.File` + `FileInputStream`/`FileOutputStream`  |
| 实例化       | **单例模式**（`JdkFileSystem.getInstance()`，volatile + DCL） |
| 路径分隔符     | `File.separator`（平台相关）                                 |
| Closeable | 否                                                      |

**特点**：

- 单例模式，全局共享一个实例
- `JdkFile` 内部持有 `java.io.File` 对象
- `moveTo()` 对 `JdkFile` 优化：直接使用 `File.renameTo()` 零拷贝移动
- `mkdirs()` 直接使用 `File.mkdirs()`

**使用示例**：

```java
IFileSystem fs = JdkFileSystem.getInstance();
IFile file = fs.getFile("D:\\01test\\test.txt");
IFile directory = file.getDirectory();
List<IFile> files = directory.listFiles();
```

### FtpFileSystem — FTP 文件系统

| 属性        | 值                                      |
|-----------|----------------------------------------|
| 模块        | `i2f-extension-filesystem-ftp`         |
| 类         | `FtpFileSystem` / `FtpFile`            |
| 底层        | Apache Commons Net `FTPClient`         |
| 配置        | `FtpMeta`（host/port/username/password） |
| 路径分隔符     | `/`                                    |
| Closeable | **是**（logout + disconnect）             |

**特点**：

- 自动连接管理：`getClient()` 检测连接状态，断线自动重连
- 支持 `enableNewClient` 参数控制是否每次新建连接
- 二进制模式传输（`FTP.BINARY_FILE_TYPE`）
- 支持追加流（`appendFileStream`）
- 路径解析为 `dir + name` 对，通过 `listFiles` 匹配判断文件属性

### SftpFileSystem — SFTP 文件系统

| 属性        | 值                                                         |
|-----------|-----------------------------------------------------------|
| 模块        | `i2f-extension-filesystem-sftp`                           |
| 类         | `SftpFileSystem` / `SftpFile`                             |
| 底层        | JSch `ChannelSftp`                                        |
| 配置        | `SftpMeta`（host/port/username/password/privateKey/config） |
| 路径分隔符     | `/`                                                       |
| Closeable | **是**（channel + session disconnect）                       |

**特点**：

- 支持密码认证和私钥认证（`addIdentity`）
- 自动连接管理：检测 channel 状态，断线自动重连
- `StrictHostKeyChecking` 默认关闭
- 支持自定义配置属性（`SftpMeta.config`）
- 不支持追加流（`UnsupportedOperationException`）
- `isDirectory` 通过 `cd` 尝试判断，`isFile` 通过 `get` 尝试判断
- `length` 通过 `lstat` 获取文件大小

### ProxySftpFileSystem — 代理跳板 SFTP

| 属性        | 值                                                      |
|-----------|--------------------------------------------------------|
| 模块        | `i2f-extension-filesystem-sftp`                        |
| 类         | `ProxySftpFileSystem` / `ProxySftpFile`                |
| 底层        | JSch（双 Session + 端口转发）                                 |
| 配置        | `ProxySftpMeta`（跳板机 + 目标机双重配置）                         |
| 路径分隔符     | `/`                                                    |
| Closeable | **是**（channel + remoteSession + session 三级 disconnect） |

**特点**：

- **两级 SSH 隧道**：先连接跳板机，通过 `setPortForwardingL` 建立本地端口转发，再通过转发端口连接目标机
- 跳板机和目标机各自独立的认证配置（username/password/privateKey/config）
- 复用 `SftpFile` 作为文件对象（`ProxySftpFileSystem.getFile()` 返回 `SftpFile`）
- 关闭时需依次断开 channel → remoteSession → session 三级连接

### HdfsFileSystem — HDFS 文件系统

| 属性        | 值                                     |
|-----------|---------------------------------------|
| 模块        | `i2f-extension-filesystem-hdfs`       |
| 类         | `HdfsFileSystem` / `HdfsFile`         |
| 底层        | Apache Hadoop `FileSystem`            |
| 配置        | `HdfsMeta`（defaultFs/uri/user/config） |
| 路径分隔符     | `/`                                   |
| Closeable | **是**（FileSystem.close）               |

**特点**：

- 支持通过 `Configuration` 自定义 HDFS 配置
- 支持带用户身份的 URI 访问（`FileSystem.get(URI, Configuration, User)`）
- `mkdir` 和 `mkdirs` 等效（HDFS 的 `mkdirs` 自动创建父级）
- 支持追加流（`FileSystem.append`）
- `HdfsFile.mkdirs()` 委托给 `mkdir()`（HDFS 自动递归创建）

### MinioFileSystem — MinIO 对象存储

| 属性        | 值                                          |
|-----------|--------------------------------------------|
| 模块        | `i2f-extension-filesystem-minio`           |
| 类         | `MinioFileSystem` / `MinioFile`            |
| 底层        | MinIO Java SDK `MinioClient`               |
| 配置        | `MinioMeta`（通过 `MinioUtil.getClient()` 构建） |
| 路径分隔符     | `/`                                        |
| Closeable | 否                                          |

**特点**：

- **Bucket/Object 二级路径模型**：路径第一段为 bucket 名，后续为 object 名
- 根路径（`/`）列举所有 Bucket
- `getOutputStream()` 使用**临时文件中转**：先写临时文件，close 时 `putObject` 上传
- `store()` 直接流式上传（`PutObjectArgs.stream`）
- `mkdir` 创建 Bucket + 放置 `.ignore` 占位对象
- 不支持追加流
- `MinioFile.writeBytes()` 重写：通过 `ByteArrayInputStream` + `store()` 直接上传
- URL 解码处理（`URLDecoder.decode`）

### AliyunOssFileSystem — 阿里云 OSS

| 属性        | 值                                                  |
|-----------|----------------------------------------------------|
| 模块        | `i2f-extension-filesystem-oss-aliyun`              |
| 类         | `AliyunOssFileSystem` / `AliyunOssFile`            |
| 底层        | Aliyun OSS SDK `OSS`                               |
| 配置        | `AliyunOssMeta`（通过 `AliyunOssUtil.getClient()` 构建） |
| 路径分隔符     | `/`                                                |
| Closeable | 否                                                  |

**特点**：

- **Bucket/Object 二级路径模型**（同 MinIO）
- `getOutputStream()` 使用**临时文件中转** + `PutObjectRequest` 上传
- `store()` 直接流式上传（带 `ObjectMetadata`）
- `copyTo()` 使用 OSS 服务端拷贝（`copyObject`），零网络传输
- `moveTo()` 同 Bucket 使用 `renameObject`，跨 Bucket 先拷贝后删除
- `listFiles()` 支持分页遍历（`isTruncated` + `nextMarker`），去重处理
- `isExists()` 同时检查文件和目录两种情况
- 不支持追加流

### AwsS3OssFileSystem — AWS S3

| 属性        | 值                                                |
|-----------|--------------------------------------------------|
| 模块        | `i2f-extension-filesystem-oss-aws-s3`            |
| 类         | `AwsS3OssFileSystem` / `AwsS3OssFile`            |
| 底层        | AWS SDK v2 `S3Client`                            |
| 配置        | `AwsS3OssMeta`（通过 `AwsS3OssUtil.getClient()` 构建） |
| 路径分隔符     | `/`                                              |
| Closeable | 否                                                |

**特点**：

- **Bucket/Object 二级路径模型**（同 MinIO/OSS）
- 使用 AWS SDK v2 Lambda 风格 API（`e -> { e.bucket(...).key(...); }`）
- `getOutputStream()` 使用**临时文件中转** + `RequestBody.fromFile()` 上传
- `copyTo()` 使用 S3 服务端拷贝
- `moveTo()` 先拷贝后删除
- `listFiles()` 支持分页遍历（`isTruncated` + `nextMarker`），去重处理
- Bucket 存在性检测通过 `getBucketPolicyStatus` 实现
- 不支持追加流

## 全项目实现一览

### IFileSystem 实现

| # | 实现类                   | 所属模块                                  | 底层技术           | 说明                     |
|---|-----------------------|---------------------------------------|----------------|------------------------|
| 1 | `JdkFileSystem`       | `i2f-io-filesystem`                   | `java.io.File` | 本地文件系统，单例              |
| 2 | `FtpFileSystem`       | `i2f-extension-filesystem-ftp`        | Commons Net    | FTP 协议，Closeable       |
| 3 | `SftpFileSystem`      | `i2f-extension-filesystem-sftp`       | JSch           | SFTP 协议，Closeable      |
| 4 | `ProxySftpFileSystem` | `i2f-extension-filesystem-sftp`       | JSch + 端口转发    | 跳板机代理 SFTP，Closeable   |
| 5 | `HdfsFileSystem`      | `i2f-extension-filesystem-hdfs`       | Hadoop         | HDFS 分布式文件系统，Closeable |
| 6 | `MinioFileSystem`     | `i2f-extension-filesystem-minio`      | MinIO SDK      | MinIO 对象存储             |
| 7 | `AliyunOssFileSystem` | `i2f-extension-filesystem-oss-aliyun` | Aliyun OSS SDK | 阿里云 OSS                |
| 8 | `AwsS3OssFileSystem`  | `i2f-extension-filesystem-oss-aws-s3` | AWS SDK v2     | AWS S3 对象存储            |

### IFile 实现

| # | 实现类             | 所属模块                                  | 对应 FileSystem         | 说明                             |
|---|-----------------|---------------------------------------|-----------------------|--------------------------------|
| 1 | `JdkFile`       | `i2f-io-filesystem`                   | `JdkFileSystem`       | 包装 `java.io.File`，moveTo 零拷贝优化 |
| 2 | `FtpFile`       | `i2f-extension-filesystem-ftp`        | `FtpFileSystem`       | 轻量路径持有                         |
| 3 | `SftpFile`      | `i2f-extension-filesystem-sftp`       | `SftpFileSystem`      | 轻量路径持有                         |
| 4 | `ProxySftpFile` | `i2f-extension-filesystem-sftp`       | `ProxySftpFileSystem` | 轻量路径持有                         |
| 5 | `HdfsFile`      | `i2f-extension-filesystem-hdfs`       | `HdfsFileSystem`      | mkdirs 委托 mkdir                |
| 6 | `MinioFile`     | `i2f-extension-filesystem-minio`      | `MinioFileSystem`     | writeBytes 重写为 store           |
| 7 | `AliyunOssFile` | `i2f-extension-filesystem-oss-aliyun` | `AliyunOssFileSystem` | writeBytes 重写为 store           |
| 8 | `AwsS3OssFile`  | `i2f-extension-filesystem-oss-aws-s3` | `AwsS3OssFileSystem`  | writeBytes 重写为 store           |

## 各实现特性对比

| 特性        | JDK | FTP | SFTP | ProxySFTP | HDFS | MinIO | AliyunOSS | AWS S3 |
|-----------|-----|-----|------|-----------|------|-------|-----------|--------|
| Closeable | -   | ✓   | ✓    | ✓         | ✓    | -     | -         | -      |
| 追加流       | ✓   | ✓   | ✗    | ✗         | ✓    | ✗     | ✗         | ✗      |
| 服务端拷贝     | -   | -   | -    | -         | -    | -     | ✓         | ✓      |
| 服务端重命名    | -   | -   | -    | -         | -    | -     | ✓         | -      |
| Bucket 模型 | -   | -   | -    | -         | -    | ✓     | ✓         | ✓      |
| 自动重连      | -   | ✓   | ✓    | ✓         | -    | -     | -         | -      |
| 临时文件中转    | -   | -   | -    | -         | -    | ✓     | ✓         | ✓      |
| 分页列举      | -   | -   | -    | -         | -    | ✓     | ✓         | ✓      |

## 设计特点

1. **统一抽象**: 7 种完全不同的存储后端（本地/FTP/SFTP/HDFS/MinIO/OSS/S3）统一在 `IFile`/`IFileSystem` 接口下
2. **模板方法模式**: `AbsFileSystem` + `AbsFile` 提取通用逻辑，子类仅需实现少量核心方法
3. **委托设计**: `AbsFile` 将所有操作委托给 `IFileSystem`，File 对象本身无状态（仅持有路径和系统引用）
4. **跨系统操作**: `AbsFile.copyTo()`/`moveTo()` 自动检测是否同一文件系统，支持跨系统透明操作
5. **安全防护**: `absPath()` 防路径遍历攻击，`getStrictFile()` 限定子树访问范围
6. **连接管理**: 远程文件系统（FTP/SFTP/HDFS）实现 `Closeable`，支持自动重连
7. **Bucket 模型适配**: MinIO/OSS/S3 三种对象存储将 Bucket/Object 二级结构映射到统一的路径模型
8. **临时文件中转**: 对象存储的 `getOutputStream()` 统一采用临时文件中转策略，close 时上传
