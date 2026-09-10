# i2f-native-core 原生（JNI）指针工具箱

## 概述

`i2f-native-core` 是 i2f-turbo-java 框架中面向 **JNI（Java Native Interface）** 开发的底层指针封装与原生库加载工具模块（5 源文件约 180 行 + 309 行 C/C++ 开发教程）。以 `Ptr` 为核心的类型安全指针包装，配合 `NativeUtil` 的 classpath 原生库释放/加载工具，为上层 JNI 模块（`i2f-native-windows`、`i2f-native-windows-easyx`）提供地基设施。

### 子领域概览

| 子领域 | 类 | 行数 | 职责 |
|--------|-----|------|------|
| 指针基类 | `Ptr` | 57 | 长期指针值封装，`isZero`/`isNegOne` 哨兵判定 |
| 分配标记 | `MallocPtr` | 17 | `malloc` 分配内存的指针类型标记 |
| 分配标记 | `NewPtr` | 16 | `new` 分配对象的指针类型标记 |
| 分配标记 | `NewArrayPtr` | 17 | `new[]` 分配数组的指针类型标记 |
| 库加载 | `NativeUtil` | 73 | 从 classpath 释放 `.dll`/`.so` 并 `System.load` |
| 开发文档 | `cpp_native_dev.md` | 309 | C/C++ JNI 完整开发教程（Visual Studio 配置） |

### 依赖关系

| 依赖 | 类型 | 说明 |
|------|------|------|
| `org.projectlombok:lombok` | provided | 仅 pom 声明，实际未使用 |

**下游消费者：**
- `i2f-native-windows`（Win32 API 通过 JNI 调用）
- `i2f-native-windows-easyx`（EasyX 图形库通过 JNI 调用）

### 包结构

```
i2f.natives.core
├── Ptr.java            # 指针基类
├── MallocPtr.java      # malloc 分配标记
├── NewPtr.java         # new 分配标记
├── NewArrayPtr.java    # new[] 分配标记
└── NativeUtil.java     # 原生库加载工具
```

## Ptr 指针基类

`Ptr` 是对原生指针（`long` 地址值）的类型安全包装，提供以下能力：

### 构造

- `Ptr(long ptr)` — 从原生地址构造
- `Ptr(Ptr ptr)` — 从另一指针拷贝

### 方法

| 方法 | 说明 |
|------|------|
| `value()` | 返回原始 `long` 指针值 |
| `isZero()` | 指针为 0（`NULL` 指针）|
| `isNegOne()` | 指针为 -1（错误/无效哨兵）|
| `equals(Object)` | 按指针值比较 |
| `hashCode()` | 按指针值计算 |
| `toString()` | 格式如 `Ptr{ptr=12345678}` |

### 设计意图

- `isZero()` 判断 `NULL` 指针（C/C++ `nullptr`/`NULL`）
- `isNegOne()` 判断错误返回值（Windows API 常用 `INVALID_HANDLE_VALUE` 即 -1）
- 提供 `equals/hashCode` 使指针可用作集合键

## 指针类型标记体系

三个子类均仅继承 `Ptr` 而无额外逻辑，通过**类型标记**区分不同的内存分配来源：

| 类 | 语义 | 对应 C/C++ 分配方式 |
|------|------|---------------------|
| `MallocPtr` | `malloc` 分配的内存 | `(Type*)malloc(size)` |
| `NewPtr` | `new` 分配的对象 | `new Type(args...)` |
| `NewArrayPtr` | `new[]` 分配的数组 | `new Type[size]` |

**设计动机：** 不同分配方式需对应的释放方式（`free` / `delete` / `delete[]`），通过类型标记可在 Java 侧分清指针来源，便于封装正确的资源释放行为。

## NativeUtil 原生库加载工具

`NativeUtil` 解决 JNI 开发中「将 DLL/SO 打包在 JAR 内，运行时释放到文件系统再加载」的常见需求，提供两个层次的方法：

### 基础方法

| 方法 | 说明 |
|------|------|
| `getLibName(String name)` | 包装 `System.mapLibraryName()`，获取平台相关库文件名（如 `example.dll` / `libexample.so`）|
| `getClasspathLib(String name)` | 从 classpath 获取库文件的 `InputStream` |

### 核心方法

**`loadClasspathLib(String name)`** — 一站式加载：

1. 调用 `getLibName(name)` 获取平台相关文件名
2. 在 `./lib/` 目录下检查文件是否已存在（避免重复释放）
3. 不存在则从 classpath 资源流读取并写入 `./lib/` 目录
4. 调用 `System.load(file.getAbsolutePath())` 加载原生库

```java
// 使用示例（通常在静态块中调用）
NativeUtil.loadClasspathLib("native/win32/JniApi");
// 在 Windows 上释放并加载 ./lib/JniApi.dll
// 在 Linux 上释放并加载 ./lib/libJniApi.so
```

## cpp_native_dev.md JNI 开发教程

模块内附带 309 行的 `cpp_native_dev.md` 文档，系统性地讲解：

- **JNI 基础**：Java `native` 方法声明、函数命名规则（`Java_包名_类名_方法名`）、`JNI_METHOD` 宏辅助生成、`JNIEnv` 参数与类型映射
- **字符串/数组操作**：`GetStringUTFChars`/`ReleaseStringUTFChars`、`GetByteArrayElements`/`ReleaseByteArrayElements`、`NewIntArray`/`SetIntArrayRegion`
- **Visual Studio 工程配置**：创建 DLL 项目、配置包含目录（`$(JAVA_HOME)\include` + `$(JAVA_HOME)\include\win32`）、切换到 X64 Release 编译

## 涉及文件

全部源文件清单：

- `i2f/natives/core/Ptr.java` — 指针基类
- `i2f/natives/core/MallocPtr.java` — `malloc` 指针类型标记
- `i2f/natives/core/NewPtr.java` — `new` 指针类型标记
- `i2f/natives/core/NewArrayPtr.java` — `new[]` 指针类型标记
- `i2f/natives/core/NativeUtil.java` — 原生库加载工具
- `cpp_native_dev.md` — C/C++ JNI 开发教程（非编译单元）

## 已知瑕疵

1. **无自动释放机制**：`Ptr` 体系仅包装指针值，不提供 `AutoCloseable` 或 `Cleaner` 注册，上层模块需自行管理原生内存释放。
2. **`NativeUtil.loadClasspathLib` 并发问题**：目录检查与文件写入无锁保护，多线程首次加载可能重复释放相同文件（写覆盖后同名文件由 `System.load` 二次加载将抛 `UnsatisfiedLinkError`）。
3. **`loadClasspathLib` 硬编码 `./lib/` 目录**：释放路径不可配置，在多模块同时使用时可能产生目录冲突。
4. **`getClasspathLib` 无缓存**：每次调用都从 classpath 重新读取流，重复使用场景效率低。
5. **`NativeUtil` 非单例**：全部为静态方法，无状态，测试时无法 mock 或替换 `System.load`。
6. **`cpp_native_dev.md` 混杂源码目录**：位于 `src/main/java` 之外的实际是模块根目录，作为运行时资源打包进 jar（`maven-assembly-plugin` 打包时包含），但 IDE 编译期可访问，设计上属于开发文档而非运行期资源。
7. **指针标记类无编译期约束**：`MallocPtr`/`NewPtr`/`NewArrayPtr` 仅类型标记，无法阻止上层误用 `MallocPtr` 调用 `delete` 对应 C++ 行为（须靠 Java 侧调用约定保证）。