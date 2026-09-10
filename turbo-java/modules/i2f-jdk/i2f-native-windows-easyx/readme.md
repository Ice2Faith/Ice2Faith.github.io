# i2f-native-windows-easyx

## 概述

**EasyX 图形库（JNI）Java 门面**，9 Java 源文件 + 1 C++ 项目（1571 行），总计约 2900 行。在 `i2f-native-windows` 的 Win32 GDI 基础之上，封装 EasyX 轻量级 Windows 图形库，为 Java 提供**极简 2D 图形编程入口**——无需 Win32/GDI 专业知识，一行 `initGraph` 即创建图形窗口，即可调用画圆/矩形/椭圆/扇形/多边形/文字/图像等约 110 个图形 API。

**架构**：沿袭 `i2f-native-windows` 的两层设计——

```
┌─────────────────────────────────────────────┐
│              EasyXApi (953行)                │ ← 类型安全 Java API 门面
│   initGraph / circle / rectangle / ...       │    953 行，含重载便利方法
├─────────────────────────────────────────────┤
│           NativesEasyX (378行)               │ ← JNI 原生方法声明
│   initGraph / circle / rectangle / ...       │    ~110 public static native 方法
├─────────────────────────────────────────────┤
│        lib/NativesEasyX.dll                  │ ← EasyX C++ 动态链接库
│        (C++ 1571行 + Visual Studio 工程)      │    1571 行 C++ JNI 实现
└─────────────────────────────────────────────┘
```

## 依赖关系

| 依赖 | 用途 | 真实使用 |
|------|------|----------|
| `i2f-native-core` | `Ptr` 指针基类（`ImagePtr`/`ImageBufferPtr` 继承自 `Ptr`） | 是 |
| `i2f-native-windows` | `Hwnd`/`Hdc` 句柄类型、`WinApi`（`getJniStringMap`/`parseLogFont`/`points2flat`/`rgbOf`）、GDI 常量枚举（`WinBitBltRop`/`WinGdiBrushStyle`/`WinGdiHatchStyle`/`WinGdiPenStyle`/`WinGdiFloodFillType`/`WinSetBkModeMode`/`WinGdiColor`） | 是 |
| `i2f-graphics-2d` | `Point`/`Size`/`Rectangle` 几何类型 | 是 |
| `i2f-convert` | `Converters.parseInt`/`parseLong` 字符串解析 | 是 |
| `lombok` | `@Data` 用于 `FillStyle`/`LineStyle`/`MouseMsg` | 是 |

## 包结构

```
i2f.natives.windows.easyx
├── NativesEasyX.java          (378行) JNI 原生方法声明层，~110 native 方法
├── EasyXApi.java              (953行) 类型安全 Java API 门面，含多重重载便利方法
├── consts/
│   └── EasyXInitGraphFlag.java (14行) 图形窗口初始化标志常量
├── types/
│   ├── ImagePtr.java           (18行) 图像指针，extends Ptr
│   ├── ImageBufferPtr.java     (18行) 图像缓冲区指针，extends Ptr
│   ├── FillStyle.java          (15行) 填充样式 POJO（style/hatch/ppattern）
│   ├── LineStyle.java          (15行) 线条样式 POJO（style/thickness/userType）
│   └── MouseMsg.java           (21行) 鼠标消息 POJO（uMsg/修饰键/x/y/wheel）
└── test/
    └── TestEasyXApi.java       (67行) 测试演示类（位于 src/main/java，随 jar 发布）
```

## 功能详解

### 1. 窗口生命周期

```java
// 初始化图形窗口，返回窗口句柄 Hwnd
Hwnd hwnd = EasyXApi.initGraph(720, 480);
// 或带标志位
Hwnd hwnd = EasyXApi.initGraph(720, 480, 
    EasyXInitGraphFlag.SHOWCONSOLE | EasyXInitGraphFlag.NOCLOSE);

// 清空设备（背景擦除）
EasyXApi.clearDevice();

// 关闭图形窗口
EasyXApi.closeGraph();
```

`EasyXInitGraphFlag` 支持 4 种标志位组合：
- `DEFAULT = 0`：默认模式（隐藏控制台）
- `SHOWCONSOLE = 1`：保留控制台显示
- `NOCLOSE = 2`：禁用关闭按钮
- `NOMINIMIZE = 4`：禁用最小化按钮

### 2. 绘图原语

每种几何图形提供 **4 种绘制变体**：

| 变体 | 行为 | 对应 EasyX 函数 |
|------|------|-----------------|
| `shape()` | 轮廓（使用当前线条颜色/样式） | `circle`/`rectangle`/`ellipse` 等 |
| `fillShape()` | 填充（使用当前填充颜色/样式） | `fillcircle`/`fillrectangle`/`fillellipse` 等 |
| `clearShape()` | 清空（用背景色清除区域） | `clearcircle`/`clearrectangle`/`clearellipse` 等 |
| `solidShape()` | 实心（带轮廓线的填充） | `solidcircle`/`solidrectangle`/`solidellipse` 等 |

支持的图形：

| 图形 | 方法 | 参数 |
|------|------|------|
| 圆 | `circle`/`fillCircle`/`clearCircle`/`solidCircle` | (x, y, radius) |
| 矩形 | `rectangle`/`fillRectangle`/`clearRectangle`/`solidRectangle` | (left, top, right, bottom) |
| 椭圆 | `ellipse`/`fillEllipse`/`clearEllipse`/`solidEllipse` | (left, top, right, bottom) |
| 扇形 | `pie`/`fillPie`/`clearPie`/`solidPie` | (left, top, right, bottom, startRadian, endRadian) |
| 多边形 | `polygon`/`fillPolygon`/`clearPolygon`/`solidPolygon` | (int[] points) / (Point[] points) |
| 圆角矩形 | `roundRect`/`fillRoundRect`/`clearRoundRect`/`solidRoundRect` | (left, top, right, bottom, ellipseWidth, ellipseHeight) |
| 柱/3D柱 | `bar`/`bar3d` | (left, top, right, bottom[, depth, topFlag]) |
| 弧 | `arc` | (left, top, right, bottom, startRadian, endRadian) |
| 折线 | `polyline` | (int[] points) / (Point[] points) |
| 贝塞尔 | `polyBezier` | (int[] points) / (Point[] points) |
| 直线 | `line`/`lineRel`/`lineTo` | (x1,y1,x2,y2) / (dx,dy) / (x,y) |
| 洪水填充 | `floodFill` | (x, y, color[, fillType]) |

### 3. 绘图状态控制

```java
// 颜色设置
EasyXApi.setColor(WinApi.rgbOf(255, 0, 0));      // 当前绘图色
EasyXApi.setFillColor(WinApi.rgbOf(0, 255, 0));  // 填充色
EasyXApi.setLineColor(WinApi.rgbOf(0, 0, 255));  // 线条色
EasyXApi.setTextColor(WinApi.rgbOf(0, 255, 255));// 文字色
EasyXApi.setBkColor(WinApi.rgbOf(255, 255, 255));// 背景色
EasyXApi.setBkMode(WinSetBkModeMode.TRANSPARENT);// 背景模式

// 填充样式（4 重载）
EasyXApi.setFillStyle();                                       // 默认实心
EasyXApi.setFillStyle(WinGdiBrushStyle.BS_SOLID);              // 仅样式
EasyXApi.setFillStyle(WinGdiBrushStyle.BS_HATCHED,             // 样式 + 纹理
    WinGdiHatchStyle.HS_CROSS);
EasyXApi.setFillStyle(WinGdiBrushStyle.BS_PATTERN,             // 样式 + 纹理 + 图像
    WinGdiHatchStyle.HS_HORIZONTAL, imagePtr);

// 线条样式（4 重载）
EasyXApi.setLineStyle();                                       // 默认实线
EasyXApi.setLineStyle(WinGdiPenStyle.PS_DASH);                 // 虚线
EasyXApi.setLineStyle(WinGdiPenStyle.PS_USERSTYLE, 3);         // 线宽 3
EasyXApi.setLineStyle(WinGdiPenStyle.PS_USERSTYLE, 2,         // 自定义虚线
    new int[]{3, 1, 5, 1});

// 其他绘图模式
EasyXApi.setWriteMode(mode);      // 写入模式（R2_COPYPEN 等）
EasyXApi.setPolyFillMode(mode);   // 多边形填充模式（ALTERNATE/WINDING）
EasyXApi.setRop2(mode);           // 光栅操作码
EasyXApi.setOrigin(x, y);         // 坐标原点偏移
EasyXApi.setAspectRatio(xasp, yasp); // 宽高比
```

### 4. 文字输出

```java
// 简单文字输出
EasyXApi.outText("Hello EasyX");                  // 当前位置
EasyXApi.outTextXy(100, 200, "EasyX + Java");     // 指定位置

// 格式化文本输出（返回实际高度）
int height = EasyXApi.drawText("居中文本", rect, 
    WinDrawTextFormat.DT_CENTER | WinDrawTextFormat.DT_VCENTER);

// 文字样式设置（4 重载，从简到繁）
EasyXApi.setTextStyle(36, 0, "楷体");                          // 高度+宽度+字体名
EasyXApi.setTextStyle(36, 0, "楷体", 0, 0, 700,               // + 字重/斜体/下划线/删除线
    false, false, false);
EasyXApi.setTextStyle(36, 0, "楷体", 0, 0, 700,               // + 字符集/输出精度等
    false, false, false, DEFAULT_CHARSET, 
    OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, 
    DEFAULT_QUALITY, DEFAULT_PITCH);
EasyXApi.setTextStyleLogFont(36, 0, 0, 0, 700,                // LOGFONT 完整 14 参数
    false, false, false, DEFAULT_CHARSET, 
    OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, 
    DEFAULT_QUALITY, DEFAULT_PITCH, "楷体");
```

### 5. 图像操作

```java
// 加载图像文件（支持 BMP/JPG/PNG/GIF 等）
ImagePtr img = EasyXApi.loadImage("background.jpg");
// 或指定缩放
ImagePtr img = EasyXApi.loadImage("photo.jpg", 640, 480, true);

// 创建空白图像
ImagePtr img = EasyXApi.createImage(200, 200);

// 显示图像
EasyXApi.putImage(100, 50, img);                       // 默认 SRCCOPY
EasyXApi.putImage(100, 50, img, WinBitBltRop.SRCAND);  // 指定光栅操作

// 图像变换
EasyXApi.resize(img, 400, 300);
EasyXApi.rotateImage(dstImg, srcImg, Math.PI / 4);     // 旋转 45 度
EasyXApi.rotateImage(dstImg, srcImg, radian, bkColor, autosize, highQuality);

// 保存图像
EasyXApi.saveImage(img, "output.png");
EasyXApi.saveImage("screenshot.png");                   // 保存当前工作图像

// 像素级操作
ImageBufferPtr buffer = EasyXApi.getImageBuffer(img);
int pixel = EasyXApi.getImageBufferValue(buffer, i);    // 读取像素
EasyXApi.setImageBufferValue(buffer, i, color);         // 写入像素

// 获取图像信息
Hdc hdc = EasyXApi.getImageHDC(img);                    // 获取图像 HDC
int w = EasyXApi.getImageWidth(img);
int h = EasyXApi.getImageHeight(img);

// 释放图像
EasyXApi.freeImage(img);
```

### 6. 批量绘制

```java
EasyXApi.beginBatchDraw();
for (int i = 0; i < 1000; i++) {
    EasyXApi.solidCircle(x[i], y[i], r[i]);
}
EasyXApi.endBatchDraw();    // 一次刷新到屏幕
// 或手动刷新
EasyXApi.flushBatchDraw();
```

批量绘制将所有绘图操作暂存到内存缓冲区，最后一次性刷新到屏幕，适用于动画/大量绘图场景，避免闪烁。

### 7. 鼠标输入

```java
// 非阻塞查询
if (EasyXApi.mouseHit()) {
    MouseMsg msg = EasyXApi.getMouseMsg();
    // msg.uMsg: WM_MOUSEMOVE/WM_LBUTTONDOWN 等
    // msg.x, msg.y: 鼠标坐标
    // msg.mkLButton/mkRButton/mkMButton: 按键状态
    // msg.mkCtrl/mkShift: 修饰键状态
    // msg.wheel: 滚轮值 (120 的倍数)
}

// 清空鼠标消息缓冲区
EasyXApi.flushMouseMsgBuffer();
```

### 8. 输入框

```java
// 弹出一个图形模式下的输入对话框（6 重载）
String text = EasyXApi.inputBox("请输入姓名", "提示", "默认值");
String text = EasyXApi.inputBox("请输入密码", "提示", "", 300, 150, true);
```

### 9. 颜色转换

```java
// RGB 分量提取
int r = EasyXApi.getRValue(color);
int g = EasyXApi.getGValue(color);
int b = EasyXApi.getBValue(color);

// 色彩空间转换
int hsl = EasyXApi.hslToRgb(0.5f, 0.8f, 0.6f);
int hsv = EasyXApi.hsvToRgb(0.5f, 0.8f, 0.6f);
float[] hslArr = EasyXApi.rgbToHsl(color);
float[] hsvArr = EasyXApi.rgbToHsv(color);

// 灰度化
int gray = EasyXApi.rgbToGray(color);

// BGR 顺序转换
int bgrColor = EasyXApi.bgr(color);
```

### 10. 光标/坐标

```java
// 当前位置
int x = EasyXApi.getX();
int y = EasyXApi.getY();
Point p = EasyXApi.getPoint();

// 工作区尺寸
int width = EasyXApi.getWidth();
int height = EasyXApi.getHeight();
int maxX = EasyXApi.getMaxX();
int maxY = EasyXApi.getMaxY();

// 光标移动（绘图模式）
EasyXApi.moveTo(100, 100);
EasyXApi.moveRel(50, 30);
EasyXApi.lineTo(300, 200);
EasyXApi.lineRel(50, 30);
```

### 11. 工作图像

```java
// 设置/获取当前工作图像（默认指向屏幕）
EasyXApi.setWorkingImage(imagePtr);
ImagePtr current = EasyXApi.getWorkingImage();
```

## 已知瑕疵

1. **测试类位于 src/main/java**：`TestEasyXApi.java`（67 行）置于 `src/main/java` 而非 `src/test/java`，随 jar 发布，与 `i2f-native-windows` 一致。

2. **`ImagePtr` 无自动释放**：`ImagePtr`/`ImageBufferPtr` 继承 `Ptr`（来自 `i2f-native-core`），依赖使用者手动 `EasyXApi.freeImage()` 释放，无 `AutoCloseable` 支持。

3. **JNI 字符串解析耦合**：`MouseMsg`/`FillStyle`/`LineStyle` 的解析依赖 JNI 端返回 `key=value\n` 格式字符串，`WinApi.getJniStringMap` 解析，格式变更无编译期保护。

4. **`EasyXApi` 全部为 `static` 方法**：无实例化能力，无状态封装。多线程场景下并发调用可能产生不可预期结果（EasyX 库本身非线程安全）。

5. **`setTextStyleLogFont` 14 参数**：直接暴露 LOGFONT 结构体全部字段为扁平参数列表，无 Builder 模式，可读性和可维护性差。

6. **颜色值采用 `int` 而非类型安全**：颜色参数（`setColor`/`setFillColor`/`setLineColor`/`setBkColor` 等）均采用 `int` 原生类型，无编译期类型约束，`rgbOf(R,G,B)` 结果为 BGR 格式（EasyX 原生格式），与直觉的 RGB 差异需注意。

7. **`EasyXInitGraphFlag` 常量接口**：采用 `interface` 常量模式而非 `enum`/`class`，`implements` 污染子类命名空间。

8. **鼠标消息 `uMsg` 无类型封装**：`MouseMsg.uMsg` 为裸 `int`，需使用者手动对照 `WinSendMessageMsg` 常量，无消息类型枚举。

9. **`getTxtStyle` 返回 `LogFont`**：依赖 `i2f-native-windows` 的 `LogFont` 类型和 `WinApi.parseLogFont` 解析，跨越模块边界耦合。

10. **`putImage`/`saveImage` 等接收 `null` 语义**：`saveImage(String)` 内部传 `0` 表示工作图像，行为隐晦无注释说明。