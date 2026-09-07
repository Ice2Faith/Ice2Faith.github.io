# JNI 原生调用体系 — Windows API 与 EasyX 图形

## 概述

项目通过三个 `i2f-native-*` 模块构建了完整的 JNI（Java Native Interface）原生调用体系，实现了 Java 对 Windows 操作系统底层
API 的直接访问能力。核心层提供指针管理和库加载基础设施，Windows 层封装了 3487 行的 Win32 API 完整绑定（覆盖窗口管理、GDI
绘图、进程/线程、文件、注册表、服务、Shell、COM、设备控制等 20+ 类别），EasyX 层在此基础上提供面向教学/简单图形场景的 EasyX 图形库
Java 绑定。

## 模块信息

| 模块                                 | 所属层     | 文件数 | 说明                    |
|------------------------------------|---------|-----|-----------------------|
| `i2f-jdk/i2f-native-core`          | i2f-jdk | 5   | 核心基础设施：指针类型体系 + 库加载工具 |
| `i2f-jdk/i2f-native-windows`       | i2f-jdk | 153 | Windows API 完整 JNI 绑定 |
| `i2f-jdk/i2f-native-windows-easyx` | i2f-jdk | 9   | EasyX 图形库 Java 绑定     |

## 依赖关系

```
i2f-native-core          ← 仅依赖 Lombok
       ↑
i2f-native-windows       ← 依赖 i2f-native-core, i2f-convert, i2f-graphics-2d, Lombok
       ↑
i2f-native-windows-easyx ← 依赖 i2f-native-windows, i2f-native-core, i2f-convert, i2f-graphics-2d, Lombok
```

## 核心层 — i2f-native-core

### NativeUtil — 库加载工具

提供从 classpath 资源自动释放并加载本地库的能力，简化 JNI 部署。

```java
// 传统方式：需要手动处理路径、后缀、释放
System.loadLibrary("JniApi");  // 需要在 java.library.path 中

// NativeUtil 方式：自动从 classpath 释放到临时目录并加载
NativeUtil.loadClasspathLib("lib/JniApi");
// 内部流程：getResourceAsStream → 写入临时文件 → System.load(绝对路径)
// 自动处理平台后缀（Windows: .dll, Linux: .so）
```

### 指针类型体系

所有指针类继承自 `Ptr`，核心是 `long value` 存储原生内存地址。

| 类             | 行数 | 说明                                | 释放方式       |
|---------------|----|-----------------------------------|------------|
| `Ptr`         | 56 | 抽象基类，`long value` + `isZero()` 判断 | 抽象         |
| `MallocPtr`   | 17 | `malloc()` 分配的内存指针                | `free()`   |
| `NewPtr`      | 16 | `new` 分配的 C++ 对象指针                | `delete`   |
| `NewArrayPtr` | 17 | `new[]` 分配的数组指针                   | `delete[]` |

## Windows API 层 — i2f-native-windows

### 架构设计

采用**双层封装**模式：

1. **NativesWindows**（918 行）：所有 `native` 方法声明，是 JNI
   的直接入口。参数全部使用基础类型（`long`/`int`/`String`/`boolean`/`byte[]`），与 C++ 端一一对应。
2. **WinApi**（3487 行）：高层 Java 封装，将基础类型参数包装为强类型句柄对象（`Hwnd`/`Hdc`/`Handle` 等），提供重载方法、复合操作、结构化数据解析。

### API 分类覆盖

WinApi 封装了以下 20+ 类 Windows API：

#### 窗口管理

- 窗口查找/创建/销毁：`findWindow`, `findWindowEx`, `createWindowEx`, `registerClassEx`
- 窗口属性：`getWindowText`, `setWindowText`, `getWindowRect`, `getWindowInfo`
- 窗口位置/大小：`setWindowPos`, `moveWindow`, `showWindow`, `setParent`
- 窗口消息：`messageBox`, `sendMessage`, `postMessage`, `getMessage`, `dispatchMessage`
- 窗口过程：`defWindowProc`, `beginPaint`, `endPaint`, `bindMessageCallbacker`
- 窗口类/样式：`WinWindowStyle`(107行), `WinClassStyle`, `WinShowWindowCmdShow`

#### GDI 绘图（200+ 方法）

- DC 操作：`getDC`, `releaseDC`, `createCompatibleDC`, `deleteDC`, `saveDC`, `restoreDC`
-
画笔/画刷/字体：`createPen`, `createSolidBrush`, `createHatchBrush`, `createFontIndirect`, `createBrushIndirect`, `createPenIndirect`
- 图形绘制：`ellipse`, `circle`, `rectangle`, `square`, `roundRect`, `arc`, `arcTo`, `chord`, `pie`
- 多边形/曲线：`polygon`, `polyline`, `polylineTo`, `polyBezier`, `polyBezierTo`
-
路径操作：`beginPath`, `endPath`, `abortPath`, `fillPath`, `strokePath`, `strokeAndFillPath`, `flattenPath`, `pathToRegion`
- 位图操作：`bitBlt`, `stretchBlt`, `transparentBlt`, `maskBlt`, `patBlt`, `createDIBSection`, `createCompatibleBitmap`
- 像素操作：`getPixel`, `setPixel`, `setPixelV`
- 文本绘制：`textOut`, `setTextAlign`, `getTextAlign`, `getTextFace`, `setBkMode`, `setBkColor`, `setTextColor`
- 区域操作：`fillRgn`, `frameRgn`, `paintRgn`, `offsetRgn`, `setRectRgn`, `ptInRegion`, `rectInRegion`
- 坐标变换：`lpToDp`, `dpToLp`, `setViewportOrgEx`, `setWindowOrgEx`, `setViewportExtEx`, `setWindowExtEx`
- 颜色操作：`rgb`, `getRValue`, `getGValue`, `getBValue`, `colorHLSToRGB`, `colorRGBToHLS`, `colorAdjustLuma`
- 调色板：`createHalftonePalette`, `realizePalette`, `resizePalette`, `selectPalette`

#### 进程/线程管理

- 进程枚举：`listProcess32()`, `process32First`, `process32Next`, `createToolhelp32Snapshot`
- 模块枚举：`listModule32()`, `module32First`, `module32Next`
- 线程枚举：`listThread32()`, `thread32First`, `thread32Next`
- 进程控制：`openProcess`, `terminateProcess`, `suspendProcess`, `resumeProcess`, `getExitCodeProcess`
- 线程控制：`openThread`, `suspendThread`, `resumeThread`, `getExitCodeThread`, `createThread`
-
优先级/亲和性：`getPriorityClass`, `setPriorityClass`, `getProcessAffinityMask`, `setProcessAffinityMask`, `setThreadAffinityMask`
- 同步等待：`waitForSingleObject`, `waitForMultipleObjects`

#### 文件操作

- 文件创建/打开：`createFile`, `openFileExist`, `openFileExistOrCreate`, `openFileReadOnly`, `openFileWriteOnly`
- 读写操作：`readFile`, `writeFile`, `flushFileBuffers`
- 文件属性：`getFileAttributes`, `setFileAttributes`, `getFileAttributesEx`, `getFileInformationByHandle`
- 文件时间：`setFileTime`, `setFileCreationTime`, `setFileLastAccessTime`, `setFileLastWriteTime`
- 文件操作：`moveFile`, `copyFile`, `deleteFile`, `createDirectory`, `removeDirectory`
- 链接/符号链接：`createHardLink`, `createSymbolicLink`
- 加密/解密：`encryptFile`, `decryptFile`, `fileEncryptionStatus`
- 磁盘操作：`getLogicalDriveStrings`, `getDriveType`, `getDiskFreeSpaceEx`
- 回收站：`deleteFileToRecycleBin`, `shEmptyRecycleBin`
- Shell 操作：`shFileOperationDeleteToCycleBin`, `shFileOperationCopy`, `shFileOperationMove`

#### 注册表操作

- 键操作：`regOpenKeyEx`, `regCreateKeyEx`, `regDeleteKey`, `regCloseKey`
- 值操作：`regQueryValueEx`, `regSetValueEx`, `regDeleteValue`
- 枚举操作：`regEnumValue`, `regEnumValues`, `regEnumKeyEx`, `regEnumKeys`
- 启动项管理：`regAllBootValues`, `regAddBootItem`, `regDeleteBootItem`, `regOpenDefaultBootKey`
- 便捷方法：`regSetValueExString`, `regSetValueExInteger`, `regSetValueExLong`

#### 服务管理（SCM）

- 服务控制管理器：`openSCManager`, `closeServiceHandle`
- 服务枚举：`enumServicesStatus`
- 服务操作：`openService`, `startService`, `stopService`, `controlService`, `deleteService`, `createService`
- 服务状态：`queryServiceStatus`
- 便捷方法：`startService(name, args)`, `stopService(name)` — 自动完成 SCM → 服务 → 关闭的完整流程

#### Shell/特殊路径

- 特殊路径：`getDesktopPath`, `getProgramsPath`, `getWindowsDirectory`, `getSystemDirectory`, `getTempPath`
- 快捷方式：`createFileShortcut`（7 种重载）, `createFileShortcutDefault`, `createFileShortcutDesktopDefault`
-
COM：`coInitialize`, `coInitializeEx`, `coUninitialize`, `coCreateInstance`, `coReleaseInstance`, `coInstanceQueryInterface`

#### 设备/输入模拟

- 键盘事件：`keyboardEvent`, `keyboardDownEvent`, `keyboardUpEvent`, `keyboardClickEvent`, `keyboardCombineEvent`
- 快捷键模拟：`keyboardCopyEvent`(Ctrl+C), `keyboardPasteEvent`(Ctrl+V), `keyboardCutEvent`(Ctrl+X)
-
音量控制：`keyboardVolumeMute`, `keyboardVolumeUp`, `keyboardVolumeDown`, `keyboardVolumeToZero`, `keyboardVolumeToMax`, `keyboardVolumeToValue`
- 媒体控制：`keyboardMediaNext`, `keyboardMediaPrevious`, `keyboardMediaPlayPause`, `keyboardMediaStop`
- 鼠标事件：`mouseEvent`, `mouseLeftDown/Up/Click`, `mouseRightDown/Up/Click`, `mouseMove`, `mouseWheel`, `setCursorPos`
- 按键状态：`getAsyncKeyState`, `isKeyDown`, `swapMouseButton`
- 控制台：`allocConsole`, `freeConsole`, `attachConsole`, `kbHit`, `getCh`, `flushStdin`, `flushStdout`

#### 系统信息/控制

- 系统信息：`getSystemMetrics`, `getScreenScaleFactor`, `globalMemoryStatusEx`, `getPhysicallyInstalledSystemMemory`
- OS 版本：`getVersionEx`, `getComputerNameEx`
- 系统控制：`exitWindowsEx`, `shutdownWindows`, `rebootWindows`, `logoffWindows`, `lockScreen`
- 屏幕控制：`screenOff`, `screenOn`, `screenLowPower`
-
网络控制：`netWirelessDisconnect`, `netEnableNetCard`, `netDisableNetCard`, `netEnableWirelessCard`, `netDisableWirelessCard`
- 计时：`getTickCount64`, `queryUnbiasedInterruptTime`, `queryProcessCycleTime`, `queryThreadCycleTime`

#### MCI 媒体控制

- `mciSendString` — 通用 MCI 命令
- `mciOpenMedia`, `mciPlayMedia`, `mciPauseMedia`, `mciStopMedia`, `mciResumeMedia`, `mciCloseMedia`
- `mciOpenCdAudioDoor`, `mciCloseCdAudioDoor`

#### Win32 应用程序框架

- `winAppCreateWin32App` — 创建完整的 Win32 应用程序（窗口注册 + 创建 + 消息循环）
- `winAppCreateBitmap` — 创建位图
- `winAppResizeCompatibleDC` — 调整兼容 DC 大小
- `bindMessageCallbacker` — 绑定消息回调（支持 Java `WinMessageCallbacker` 接口）

### 常量体系（94 个常量类）

| 分类         | 常量类数量 | 代表性常量                                                                                                             |
|------------|-------|-------------------------------------------------------------------------------------------------------------------|
| **访问权限**   | 2     | `WinGenericRights`, `WinStandardAccessType`                                                                       |
| **COM**    | 5     | `WinCoCreateInstanceClsctx/Clsid/Iid`, `WinCoInitializeExCoInit`, `WinCoInstanceQueryInterfaceIid`                |
| **设备/输入**  | 7     | `WinKeyboardEventVk`(271行, 完整虚拟键码), `WinMouseEventFlag`, `WinDeviceCapsIndex`, `WinMonitorFromFlag`               |
| **文件**     | 7     | `WinFileDesiredAccess`, `WinFileAttribute`, `WinFileCreationDisposition`, `WinFileShareMode`                      |
| **GDI**    | 24    | `WinBitBltRop`, `WinGdiPenStyle`, `WinGdiBrushStyle`, `WinGdiCharset`, `WinGdiFontWeight`, `WinGdiDrawTextFormat` |
| **进程**     | 6     | `WinOpenProcessDesiredAccess`, `WinOpenThreadDesiredAccess`, `WinCreateToolhelo32SnapshotFlag`                    |
| **注册表**    | 5     | `WinRegOpenKeyHkey`, `WinRegBootKeys`, `WinRegValueType`                                                          |
| **服务**     | 10    | `WinControlServiceControl`, `WinEnumServiceStatusServiceType/State`, `WinOpenScManagerDesiredAccess`              |
| **Shell**  | 5     | `WinShGetSpecialFolderLocationCsidl`(104行), `WinShFileOperationFlag/Func`                                         |
| **系统**     | 3     | `WinExitWindowsFlag`, `WinGetComputerNameExFormat`                                                                |
| **窗口**     | 17    | `WinWindowStyle`(107行), `WinSendMessageMsg`(500行), `WinSystemMetrics`(163行), `WinMessageBoxType`(73行)             |
| **WinApp** | 2     | `WinAppCallbacker`, `WinAppResizeMode`                                                                            |

### 类型体系（50 个类型类）

| 分类         | 类型                                                                                                                                                                 | 说明                            |
|------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------|
| **基础**     | `Handle`, `WcharPtr`                                                                                                                                               | 通用句柄、宽字符指针                    |
| **COM**    | `CoIUnknownPtr`, `CoTaskPtr`, `LpItemIdList`                                                                                                                       | COM 对象指针、COM 任务内存、Shell ID 列表 |
| **文件**     | `DiskFreeSpaceExInfo`, `FileAttributeExInfo`, `FileHandleInformation`                                                                                              | 磁盘空间、文件属性、文件句柄信息              |
| **GDI**    | `Hdc`, `HBitmap`, `HBrush`, `HPen`, `HFont`, `HGdiObj`, `HIcon`, `HPalette`, `HRgn`, `LogFont`, `LogBrushPtr`, `LogPenPtr`, `BitmapInfoHeaderPtr`, `BitmapInfoPtr` | GDI 对象句柄 + 逻辑对象描述             |
| **进程**     | `HInstance`, `HModule`, `ProcessEntry32`, `ModuleEntry32`, `ThreadEntry32`, `Luid`                                                                                 | 进程/模块/线程快照数据                  |
| **注册表**    | `HKey`, `RegEnumKeyExInfo`, `RegEnumValueInfo`, `RegValueInfo`                                                                                                     | 注册表键/值                        |
| **服务**     | `ScHandle`, `ServiceStatusInfo`                                                                                                                                    | 服务句柄、服务状态                     |
| **系统**     | `MemoryStatusEx`, `OsVersionInfo`                                                                                                                                  | 内存状态、OS 版本                    |
| **窗口**     | `Hwnd`, `HCursor`, `HDesk`, `HMenu`, `HMonitor`, `LResult`, `MsgPtr`, `PaintStructPtr`, `BitmapDcPtr`, `WindowInfo`, `LayeredWindowAttributes`, `BitmapDcInfo`     | 窗口/UI 对象句柄 + 数据               |
| **WinApp** | `Win32AppInstancePtr`                                                                                                                                              | Win32 应用实例指针                  |

## EasyX 图形层 — i2f-native-windows-easyx

### 概述

EasyX 是 Windows 平台面向教学/简单图形场景的 C++ 图形库。`EasyXApi`（954 行）提供了完整的 Java 封装，依赖 `WinApi`
和 `i2f-graphics-2d`。

### API 分类

#### 图形窗口管理

- `initGraph(width, height)` — 初始化图形窗口，返回 `Hwnd`
- `closeGraph()` — 关闭图形窗口
- `clearDevice()` — 清屏

#### 批量绘制

- `beginBatchDraw()` / `endBatchDraw()` / `flushBatchDraw()` — 双缓冲批量绘制，消除闪烁

#### 图像操作

- `createImage(width, height)` — 创建离屏图像
- `loadImage(filePath, width, height, resize)` — 从文件加载图像
- `saveImage(pImage, filePath)` — 保存图像到文件
- `freeImage(pImage)` — 释放图像
- `putImage(dstX, dstY, pImage, dwRop)` — 绘制图像（支持光栅操作码）
- `setWorkingImage(pImage)` — 设置当前工作图像

#### 绘图设置

- 颜色：`setColor`, `setFillColor`, `setLineColor`, `setBkColor`, `setBkMode`, `setTextColor`
- 填充样式：`setFillStyle(style, hatch, pImage)`, `setFillStylePattern8x8`
- 线条样式：`setLineStyle(style, thickness, userType)`
- 文本样式：`setTextStyle(height, width, faceName)` 等 4 种重载
- 写模式：`setWriteMode`

#### 图形绘制（每种图形提供 4 种变体：描边/填充/清除/实心）

- 圆形：`circle`, `fillCircle`, `clearCircle`, `solidCircle`
- 矩形：`rectangle`, `fillRectangle`, `clearRectangle`, `solidRectangle`
- 椭圆：`ellipse`, `fillEllipse`, `clearEllipse`, `solidEllipse`
- 扇形：`pie`, `fillPie`, `clearPie`, `solidPie`
- 多边形：`polygon`, `fillPolygon`, `clearPolygon`, `solidPolygon`
- 圆角矩形：`roundRect`, `fillRoundRect`, `clearRoundRect`, `solidRoundRect`
- 三维条形图：`bar`, `bar3d`

#### 线条/曲线

- `line(x1, y1, x2, y2)` — 画线
- `lineRel(dx, dy)` / `lineTo(x, y)` — 相对/绝对画线
- `moveRel(dx, dy)` / `moveTo(x, y)` — 移动当前画笔位置
- `polyBezier(points)` — 贝塞尔曲线
- `polyLine(points)` — 折线
- `drawPoly(points)` / `fillPoly(points)` — 多边形绘制/填充

#### 文本

- `outText(str)` — 在当前位置输出文本
- `outTextXy(x, y, str)` — 在指定位置输出文本

#### 像素操作

- `getPixel(x, y)` — 获取像素颜色
- `putPixel(x, y, color)` — 设置像素颜色
- `floodFill(x, y, color, fillType)` — 泛洪填充

#### 颜色工具

- `rgb(r, g, b)` / `bgr(color)` — RGB 颜色构造/转换
- `getRValue`, `getGValue`, `getBValue` — 颜色分量提取
- `hslToRgb`, `hsvToRgb` — HSL/HSV 到 RGB 转换
- `rgbToGray` — 灰度转换

### EasyX 类型（5 个）

| 类型               | 说明                                 |
|------------------|------------------------------------|
| `ImagePtr`       | 图像指针（继承 `Ptr`）                     |
| `ImageBufferPtr` | 图像缓冲区指针                            |
| `FillStyle`      | 填充样式（style + hatch + ppattern）     |
| `LineStyle`      | 线条样式（style + thickness + userType） |
| `MouseMsg`       | 鼠标消息                               |

## JNI 开发指南

项目附带 `cpp_native_dev.md` 文档，详细说明：

1. **Java ↔ C++ 方法对照**：`native` 方法声明 → JNI 函数命名规则（`Java_包名_类名_方法名`）
2. **JNI 数据类型映射**：`jint`/`jstring`/`jbyteArray` 等
3. **JNI 环境使用**：`JNIEnv*` 的字符串操作、数组操作、对象创建
4. **Visual Studio 开发流程**：创建 DLL 项目 → 配置 JNI 头文件路径 → 编译生成 → Java 端加载
5. **宏简化**：`JNI_METHOD(name)` 宏自动拼接完整函数名
6. **库加载方式**：`System.loadLibrary` vs `System.load` vs `NativeUtil.loadClasspathLib`

## 源文件清单

### i2f-native-core（5 文件）

| 文件                 | 行数 | 说明        |
|--------------------|----|-----------|
| `NativeUtil.java`  | 72 | 库加载工具     |
| `Ptr.java`         | 56 | 指针抽象基类    |
| `MallocPtr.java`   | 17 | malloc 指针 |
| `NewPtr.java`      | 16 | new 指针    |
| `NewArrayPtr.java` | 17 | new[] 指针  |

### i2f-native-windows（153 文件）

| 文件/分类                  | 行数    | 说明           |
|------------------------|-------|--------------|
| `WinApi.java`          | 3487  | 高层 API 封装    |
| `NativesWindows.java`  | 918   | native 方法声明  |
| `NativesWindows8.java` | 22    | Win8+ 专用 API |
| `Win8Api.java`         | 29    | Win8+ 高层封装   |
| `consts/` (94 文件)      | ~3500 | 常量定义         |
| `types/` (50 文件)       | ~900  | 类型封装         |

### i2f-native-windows-easyx（9 文件）

| 文件                               | 行数  | 说明                |
|----------------------------------|-----|-------------------|
| `EasyXApi.java`                  | 954 | EasyX 高层封装        |
| `NativesEasyX.java`              | 379 | EasyX native 方法声明 |
| `consts/EasyXInitGraphFlag.java` | 14  | 初始化标志             |
| `types/FillStyle.java`           | 15  | 填充样式              |
| `types/LineStyle.java`           | 15  | 线条样式              |
| `types/ImagePtr.java`            | 18  | 图像指针              |
| `types/ImageBufferPtr.java`      | 18  | 图像缓冲指针            |
| `types/MouseMsg.java`            | 21  | 鼠标消息              |
| `test/TestEasyXApi.java`         | 67  | 测试用例              |

## 设计特点

1. **双层封装**：Natives（native 声明，基础类型）→ Api（强类型句柄，重载方法），兼顾 JNI 简洁性和 Java 类型安全
2. **强类型句柄**：每种 Windows 句柄（`Hwnd`/`Hdc`/`Handle`/`HKey`/`ScHandle` 等）独立封装，编译期防止类型混用
3. **结构化数据解析**：JNI 返回结构化字符串 → Java 端 `parse*()` 方法解析为
   POJO（`ProcessEntry32`/`WindowInfo`/`ServiceStatusInfo` 等）
4. **完整常量映射**：94 个常量类完整对应 Windows SDK 宏定义，命名规范一致
5. **Point/Size/Rectangle 集成**：大量方法提供 `i2f-graphics-2d` 几何类型重载版本，与图形学模块无缝衔接
6. **渐进式依赖**：core → windows → easyx，每层可独立使用
7. **Win32 应用框架**：支持创建完整的原生 Win32 应用程序（窗口注册 → 创建 → 消息循环 → 回调），Java 代码即可编写原生 Windows
   桌面程序
