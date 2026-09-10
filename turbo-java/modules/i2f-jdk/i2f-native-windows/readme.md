# i2f-native-windows Windows（JNI）原生 API 门面

## 概述

`i2f-native-windows` 是 i2f-turbo-java 框架中面向 **Windows 原生 API** 的完整 JNI 封装模块（153 Java 源文件 + 2 C++ 项目约 6175 行 C++ 源码，总计约 15000+ 行），通过 **两层架构**（`NativesWindows` 原生方法声明 + `WinApi` 类型安全门面）为 Java 提供 13 个领域约 300+ 个 Windows API 的调用能力，覆盖窗口管理、GDI 绘图、输入模拟、进程/线程、文件系统、注册表、服务控制、COM、Shell、Win32 应用框架等。

### 架构设计

```
┌─────────────────────────────────────────────────────────────┐
│  WinApi / Win8Api             类型安全 Java 门面              │
│  (3494行 + 29行)               Handle 子类 + 领域对象转换       │
├─────────────────────────────────────────────────────────────┤
│  NativesWindows / NativesWindows8  native 方法声明            │
│  (920行 + 22行)                 JNI 边界                      │
├─────────────────────────────────────────────────────────────┤
│  NativesWindows.cpp / NativesWindows8.cpp  C++ 实现           │
│  (6043行 + 132行)              Windows API 调用               │
└─────────────────────────────────────────────────────────────┘
```

### 子领域概览

| 子领域 | 类 | 行数 | 覆盖 API 数量 |
|--------|-----|------|--------------|
| 系统信息 | `WinApi` | ~80 | 10+ (metrics, memory, version, DPI) |
| 窗口管理 | `WinApi` | ~400 | 40+ (find/enum/create/destroy/position/text/style) |
| 输入模拟 | `WinApi` | ~50 | 6 (keyboard/mouse/cursor/asyncKey) |
| GDI 绘图 | `WinApi` | ~1200 | 120+ (DC/bitmap/brush/pen/font/shape/path/region) |
| 进程/线程 | `WinApi` | ~350 | 35+ (open/terminate/suspend/priority/privilege/snapshot) |
| 文件系统 | `WinApi` | ~250 | 25+ (create/read/write/delete/move/copy/encrypt) |
| 注册表 | `WinApi` | ~80 | 8 (open/create/delete/query/set) |
| 服务控制 | `WinApi` | ~150 | 12 (open/create/start/stop/delete/query) |
| COM | `WinApi` | ~80 | 8 (initialize/createInstance/queryInterface) |
| Shell | `WinApi` | ~100 | 10 (recycleBin/fileOp/shortcut/folderPath) |
| 控制台 | `WinApi` | ~40 | 6 (alloc/free/attach/flush/freopen) |
| Win32 App | `WinApi` | ~300 | 25+ (registerClass/createWindow/messageLoop/paint) |
| Win8 DPI | `Win8Api` | ~30 | 2 (getDpiForMonitor, getScaleFactorForMonitor) |

### 依赖关系

| 依赖 | 类型 | 用途 |
|------|------|------|
| `i2f-native-core` | 编译+运行 | `Ptr` 指针基类、`NativeUtil` 原生库加载 |
| `i2f-graphics-2d` | 编译+运行 | `Point`、`Size`、`Rectangle` 领域对象 |
| `i2f-convert` | 编译+运行 | `Converters` 类型转换（少量使用） |
| `lombok` | 编译 | POJO 数据类注解 |
| `NativesWindows.dll` | 运行 | 实际 JNI 原生库（需从 classpath 释放） |
| `NativesWindows8.dll` | 运行 | Win8+ 扩展原生库（需从 classpath 释放） |

## 包结构

```
i2f.natives.windows/
├── NativesWindows.java          # 全部 native 方法声明（920 行，~250+ native 方法）
├── NativesWindows8.java         # Win8+ native 方法声明（22 行，2 个 native 方法）
├── WinApi.java                  # 类型安全 Java API 门面（3494 行）
├── Win8Api.java                 # Win8+ Java API 门面（29 行）
├── consts/                      # 94 个常量接口
│   ├── WinConsts.java           # 通用常量
│   ├── access/                  # 访问权限（GenericRights, StandardAccessType）
│   ├── com/                     # COM（CoCreateInstance CLSID/IID/CLSCTX/CoInit）
│   ├── device/                  # 设备（KeyboardEventVk 271行, MouseEventFlag, DeviceCapsIndex, DriverType, MonitorFromFlag）
│   ├── file/                    # 文件（FileAttribute, DesiredAccess, ShareMode, CreationDisposition, SymbolicLinkFlag, EncryptionStatus）
│   ├── gdi/                     # GDI（BitBltRop, PenStyle, BrushStyle, FontWeight/Charset/Quality/Pitch/Family, DrawTextFormat, Color, HatchStyle, MapMode, StretchBltMode, PolyFillMode, Rop2, TextAlign 等 24 个）
│   ├── process/                 # 进程（OpenProcessDesiredAccess, OpenThreadDesiredAccess, TokenPrivileges, LookupPrivilegeName, SnapshotFlag）
│   ├── register/                # 注册表（HKey, SamDesired, ValueType, Option, BootKeys）
│   ├── service/                 # 服务（ControlService, CreateService, EnumServiceStatus, DesiredAccess, CurrentState 等 12 个）
│   ├── shell/                   # Shell（ShGetSpecialFolderLocationCsidl 104行, ShFileOperationFlag/Func/Return, ShEmptyRecycleBinFlag）
│   ├── system/                  # 系统（ExitWindowsFlag, GetComputerNameExFormat, OsVersionInfoPlatformId）
│   ├── winapp/                  # Win32 应用（WinAppCallbacker 回调接口, WinAppResizeMode）
│   └── window/                  # 窗口（SendMessageMsg 500行~300+消息, WindowStyle 107行, SystemMetrics 164行, ClassStyle, ShowWindowCmdShow, SetWindowPosFlag, MessageBoxType, GetWindowLongIndex, ClassLongIndex, SystemColorIndex, StandardCursorId, HotKey, LayeredWindowAttributesFlag, SystemMenuCommand 等 18 个）
├── types/                       # 50 个类型安全 Handle 包装类
│   ├── Handle.java              # 基类 extends Ptr（i2f-native-core）
│   ├── WcharPtr.java            # 宽字符串指针
│   ├── window/                  # Hwnd, HMonitor, HMenu, HCursor, HDesk, MsgPtr, PaintStructPtr, WindowInfo, LayeredWindowAttributes, BitmapDcInfo
│   ├── gdi/                     # Hdc, HBitmap, HBrush, HPen, HFont, HRgn, HPalette, HIcon, HGdiObj, BitmapInfoHeaderPtr, BitmapInfoPtr, LogBrushPtr, LogFontPtr, LogPenPtr, LogFont
│   ├── process/                 # HInstance, HModule, Luid, ProcessEntry32, ModuleEntry32, ThreadEntry32
│   ├── register/                # HKey, RegEnumKeyExInfo, RegEnumValueInfo, RegValueInfo
│   ├── service/                 # ScHandle, ServiceStatusInfo
│   ├── com/                     # CoIUnknownPtr, CoTaskPtr, LpItemIdList
│   ├── file/                    # DiskFreeSpaceExInfo, FileAttributeExInfo, FileHandleInformation
│   ├── winapp/                  # BitmapDcPtr, Win32AppInstancePtr
│   └── system/                  # MemoryStatusEx, OsVersionInfo
└── test/                        # 测试类
    ├── TestNativeWindows.java   # 原生层测试（173 行）
    ├── TestWinApi.java          # API 门面测试（236 行）
    ├── TestWinApp.java          # Win32 应用测试（44 行）
    └── TestWinRawThread.java    # 原生线程测试（24 行）
```

## 功能详解

### 1. 两层架构设计

**NativesWindows**（920 行）是 JNI 边界层，声明约 250+ `public static native` 方法，所有方法直接接收/返回原始 Java 类型（`long` 表示指针、`int[]` 表示坐标/矩形、`int` 表示颜色/RGB），在 `static` 块中通过 `NativeUtil.loadClasspathLib("lib/NativesWindows")` 加载原生 DLL。

**WinApi**（3494 行）是类型安全门面层，将原始 `long` 指针包装为 `Handle` 子类（`Hwnd`、`Hdc`、`HBitmap` 等 33+ 类型安全句柄），将 `int[]` 转换为 `Point`、`Size`、`Rectangle`（来自 `i2f-graphics-2d`），提供便捷重载（如 `windowFromPoint(Point)`），并添加纯 Java 辅助方法（如 `rgbOf(int,int,int)`、`toRgb(int)`、`getScreenScaleFactor()`）。

### 2. 类型安全 Handle 体系（50 types）

```java
// 来自 i2f-native-core 的指针基类
public class Ptr {                     // 长期指针值封装
    public Ptr(long ptr) { ... }
    public long value() { ... }
    public boolean isZero() { ... }    // ==0 哨兵判定
    public boolean isNegOne() { ... }  // ==-1 哨兵判定
}

// 本模块扩展的句柄层次
public class Handle extends Ptr { }    // Windows HANDLE 基类
public class Hwnd extends Handle { }   // 窗口句柄
public class Hdc extends Handle { }    // 设备上下文句柄
public class HBitmap extends Handle { } // 位图句柄
// ... 33+ 类型安全句柄包装
```

### 3. 窗口管理与消息系统

窗口核心操作链：`findWindow` → `getWindowRect`/`getWindowText` → `setWindowPos`/`showWindow` → 消息循环。

消息系统支持：
- 同步发送/异步投递：`sendMessage`/`postMessage`（500 行消息常量 `WinSendMessageMsg` 覆盖 WM_ 全系列）
- 消息循环：`getMessage`/`dispatchMessage`/`translateMessage`
- 窗口过程回调：`bindMessageCallbacker` 注册 `WinMessageCallbacker` 回调接口
- 窗口子类化：`getWindowLong`/`setWindowLong`（GWL_ 索引）、`getClassLong`/`setClassLong`
- 枚举：`enumWindows`/`enumChildWindows`/`enumThreadWindows`/`enumDesktopWindows`

### 4. GDI 绘图子系统

最完整的子域，覆盖全部 GDI 核心功能：

| 分类 | 方法 | 说明 |
|------|------|------|
| DC 管理 | `getDC/releaseDC/createCompatibleDC/deleteDC/saveDC/restoreDC` | 设备上下文生命周期 |
| 位图操作 | `createCompatibleBitmap/createDIBSection/bitBlt/stretchBlt/transparentBlt/maskBlt/patBlt` | 光栅操作与透明混合 |
| 画刷 | `createSolidBrush/createHatchBrush/createPatternBrush/createBrushIndirect` | 实心/影线/图案/逻辑画刷 |
| 画笔 | `createPen/createPenIndirect` | 逻辑画笔（style/width/color） |
| 字体 | `createFontIndirect/addFontResource/removeFontResource/getTextFace` | GDI 字体创建与加载 |
| 形状 | `rectangle/ellipse/roundRect/polygon/polyline/polyBezier/arc/arcTo/chord/angleArc/lineTo` | 全部 GDI 基本图元 |
| 路径 | `beginPath/endPath/abortPath/flattenPath/pathToRegion/fillPath/strokePath/strokeAndFillPath` | 路径对象 |
| 区域 | `selectClipRgn/fillRgn/frameRgn/paintRgn/ptInRegion/rectInRegion/setRectRgn` | 裁剪与区域操作 |
| 颜色 | `getPixel/setPixel/setPixelV/getBkColor/setBkColor/getTextColor/setTextColor/getDCBrushColor/setDCBrushColor/getDCPenColor/setDCPenColor` | 像素级操作 |
| 坐标变换 | `get/setMapMode/get/setViewportOrgExt/get/setWindowOrgExt/lpToDp/dpToLp` | 映射模式转换 |
| 文本 | `textOut/getTextAlign/setTextAlign/getTextFace/setTextJustification` | GDI 文本输出 |
| 调色板 | `createHalftonePalette/realizePalette/resizePalette/selectPalette` | 调色板管理 |

### 5. 进程/线程与权限管理

```java
// 进程操作
long hProcess = openProcess(PROCESS_ALL_ACCESS, false, pid);
process32First/Next(hSnapshot);  // 遍历进程
terminateProcess(hProcess, 0);
getExitCodeProcess(hProcess);

// 线程操作
long hThread = openThread(THREAD_ALL_ACCESS, false, threadId);
suspendThread(hThread);
resumeThread(hThread);
createThread(stackSize, flags, runnable);  // JNI 创建原生线程

// 权限提升
long hToken = openProcessToken(hProcess, TOKEN_ADJUST_PRIVILEGES);
long[] luid = lookupPrivilegeValue(null, "SeDebugPrivilege");
adjustTokenPrivileges(hToken, false, attributes, luid[0], luid[1]);
// 一行封装
adjustProcessPrivileges(hProcess, "SeDebugPrivilege", true);
```

### 6. 文件系统操作

覆盖 Win32 文件 API 的完整子集：
- 基础：`createFile/readFile/writeFile/closeHandle/flushFileBuffers`
- 属性：`getFileAttributes/setFileAttributes/getFileAttributesEx/getFileInformationByHandle`
- 时间：`setFileTime(creationTime, lastAccessTime, lastWriteTime)`
- 操作：`moveFile/copyFile/deleteFile/createDirectory/removeDirectory`
- 高级：`createHardLink/createSymbolicLink/encryptFile/decryptFile/fileEncryptionStatus/getBinaryType`
- 卷：`getLogicalDriveStrings/getDriveType/getDiskFreeSpaceEx`
- 回收站：`deleteFileToRecycleBin/shEmptyRecycleBin/deleteToRecycleBinModern`

### 7. 注册表操作

完整的注册表 CRUD：
```java
HKey hKey = regOpenKeyEx(HKEY_LOCAL_MACHINE, "SOFTWARE\\...", 0, KEY_READ);
RegEnumKeyExInfo info = regEnumKeyEx(hKey, index);  // 枚举子键
RegEnumValueInfo valInfo = regEnumValue(hKey, index);  // 枚举值
String data = regQueryValueEx(hKey, "valueName");      // 查询值
regSetValueEx(hKey, "valueName", REG_SZ, "data");      // 设置值
regDeleteValue(hKey, "valueName");                      // 删除值
regDeleteKey(hKey, "subKey");                           // 删除子键
regCloseKey(hKey);                                      // 关闭句柄
regCreateKeyEx(hKey, "newSubKey", ...);                 // 创建子键
```

### 8. 服务控制管理

Windows 服务全生命周期操作：
```java
ScHandle hScm = openSCManager(null, null, SC_MANAGER_ALL_ACCESS);
ScHandle hService = openService(hScm, "ServiceName", SERVICE_ALL_ACCESS);

// 服务信息
ServiceStatusInfo status = queryServiceStatus(hService);
String statusText = enumServicesStatus(hScm, SERVICE_WIN32, SERVICE_STATE_ALL);

// 服务操作
startService(hService, 0, null);
controlService(hService, SERVICE_CONTROL_STOP);
deleteService(hService);

// 创建服务
createService(hScm, "name", "displayName", access, type, startType, errorControl,
              binaryPath, null, null, null, null);

closeServiceHandle(hScm);
```

### 9. COM 与 Shell

COM 初始化与基本接口查询：
```java
coInitialize();  // 或 coInitializeEx(COINIT_APARTMENTTHREADED)
CoIUnknownPtr ptr = coCreateInstance(CLSID_XXXX, CLSCTX_INPROC_SERVER, IID_IUnknown);
CoIUnknownPtr iface = coInstanceQueryInterface(ptr, IID_XXXX);
coReleaseInstance(ptr);
coUninitialize();
```

Shell 操作：
```java
// 特殊文件夹路径
String path = shGetSpecialFolderPath(CSIDL_DESKTOP);
// 快捷方式创建
createFileShortcut(src, lnk, args, workDir, desc, iconPath, iconIndex, hotKey, vk, showCmd);
// 文件操作（复制/删除/重命名等）
shFileOperation(hwnd, FO_COPY, fromPath, toPath, FOF_ALLOWUNDO, false, title);
// 回收站
shEmptyRecycleBin(hwnd, null, SHERB_NOCONFIRMATION);
```

### 10. Win32 应用程序框架

完整的 Win32 窗口应用创建流程：
```java
// 1. 注册窗口类
int atom = registerClassEx(style, 0, 0, hInstance, hIcon, hCursor, hbrBkgnd,
                           menuName, className, hIconSm);
// 2. 创建窗口
Hwnd hwnd = createWindowEx(exStyle, className, title, style,
                            x, y, width, height, parent, menu, hInstance);
// 3. 消息循环（通过回调）
NativesWindows.winAppCreateWin32App(className, title, iconFile, nCmdShow,
                                     showConsole, resizeMode, callbacker);
```

回调接口 `WinAppCallbacker`/`WinMessageCallbacker` 允许 Java 端处理窗口消息：
```java
WinMessageCallbacker callbacker = (hwnd, msg, wParam, lParam) -> {
    switch (msg) {
        case WM_PAINT: /* 绘制 */ break;
        case WM_DESTROY: postQuitMessage(0); break;
    }
    return defWindowProc(hwnd, msg, wParam, lParam);
};
bindMessageCallbacker(hwnd, callbacker);
```

### 11. Win8+ DPI 扩展

`NativesWindows8`（22 行）加载独立 DLL `lib/NativesWindows8`，提供 Win8+ 的 DPI 感知 API：
- `getDpiForMonitor(hMonitor, dpiType)` — 获取指定监视器的 DPI 值
- `getScaleFactorForMonitor(hMonitor)` — 获取缩放因子

`Win8Api` 将其包装为类型安全的 `Point` 返回值（`x=DPIx, y=DPIy`）。

## 下游消费者

| 模块 | 消费内容 |
|------|----------|
| `i2f-native-windows-easyx` | 基于 Windows GDI 的 EasyX 风格绘图封装 |

## 已知瑕疵

1. **`NativesWindows.hello()` 返回字符串无版本/校验信息**：出厂测试方法，仅返回常量字符串，无 DLL 版本/校验机制。
2. **`freeMallocPtr`/`deleteNewPtr`/`deleteNewArrayPtr` 需调用者手动管理**：`Ptr` 类型标记仅用于区分分配来源，无自动释放/AutoCloseable，调用者必须 ensure finally 释放。
3. **`NativeUtil.loadClasspathLib` 并发无锁**：`NativesWindows` 和 `NativesWindows8` 的 `static` 块在不同 ClassLoader 下可能重复释放/加载 DLL。
4. **`WinApi` 部分方法返回 `null` 而非 `Optional`**：如 `windowFromCursorPos`、`getDpiForMonitor` 等可能返回 null，调用者需判空。
5. **`WinApi` 少数方法直接调 `NativesWindows` 无空值保护**：如 `getWindowInfo` 内部 `split(",")` 假设非空字符串，若 JNI 层返回空串可能触发 `ArrayIndexOutOfBoundsException`。
6. **JNI 边界无异常转换**：`NativesWindows` native 方法抛出的 C++ 异常直接以 `UnsatisfiedLinkError` 或 JVM crash 形式暴露，无 Java 端异常包装。
7. **`WinSendMessageMsg` 常量接口未分组**：500 行中约 300+ 消息常量平铺在一个接口中，无子域分组，WM_KEYDOWN/WM_KEYUP 等与 WM_PAINT/WM_CLOSE 混放。
8. **`registerClassEx` 参数过多（10 参）**：直接对应 Win32 `RegisterClassExW`，调用方需自行设置所有字段，无 Builder 模式。
9. **`createWindowEx` 部分参数类型不一致**：`dwExStyle`/`dwStyle` 为 `int` 但 `WinWindowStyle` 定义为 `int` 常量（含 `0x80000000` 等负值），可能导致 Java 符号扩展问题。
10. **测试类在 `src/main/java` 下**：`TestNativeWindows`/`TestWinApi` 等位于 `src/main/java/i2f/natives/windows/test/`，随 jar 发布，非标准 `src/test/java` 布局（同模块多处）。