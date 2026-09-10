# i2f-color

> **RGBA / HSL 色彩空间表示与转换模型**（全模块仅 2 个类 `Rgba` + `Hsl`，依赖 `i2f-math` 做值域钳制）：`Rgba`（`@Data` `@NoArgsConstructor`）以 4 个 `public int` （`r/g/b/a`，默认 `a=255`）描述 0–255 范围的 RGBA 色彩，内置 `Channel` 位掩码枚举（R/G/B/A/RGB/RGBA），提供字节序双风格工厂 `rgba(int)`/`argb(int)` 与序列 `rgba()`/`argb()`（RGBA 顺序：`R<<24|G<<16|B<<8|A`，ARGB 顺序：`A<<24|R<<16|G<<8|B`）、gamma 校正灰度计算 `gray()`（2.2 幂次）、归一化色差 `diff()`（RGB 曼哈顿平均 / 256）、线性插值 `smooth()`（代理 `MathUtil.smooth`）、RGB↔HSL 双向转换 `hsl()`/`Hsl.rgb2hsl()`/`Hsl.hsl2rgb()`、预定义颜色常量（`black/white/red/green/blue/transparent/gray/yellow/pink/cyan` 共 10 色）。`i2f-graphics-2d`/`i2f-graphics-3d`/`i2f-image-impl`（~18 个画像滤镜）广泛消费 \(Rgba\) 作为像素操作的最小数据载体。

## 模块路径

- `i2f-jdk/i2f-color`

## 模块依赖

| 坐标 | scope | optional | 说明 |
|---|---|---|---|
| `i2f.turbo:i2f-math` | compile | false | `MathUtil.between()` 做 RGBA 值 `[0,255]` 与 HSL 值 `[0,1]` 的边界钳制，`MathUtil.smooth()` 做色间线性插值 |
| `org.projectlombok:lombok` | provided | false | `Rgba` 类的 `@Data`/`@NoArgsConstructor` **真实使用**（区别于多数 std 模块的冗余声明） |

## 模块设计

1. **双类双向互转**：`Rgba` 与 `Hsl` 彼此持有转换方法——`Rgba.hsl()` 代理 `Hsl.rgb2hsl(this)`，`Hsl.rgba()` 代理 `hsl2rgb(this)`，外部拿到任一对象可无障碍切换到另一色彩空间。

2. **RGBA 整数编码双字节序**：`rgba(int)`/`rgba()` 按「R-G-B-A」从高位到低位排列，而 `argb(int)`/`argb()` 按「A-R-G-B」排列。二者面向不同场景（`BufferedImage.TYPE_INT_ARGB` 用 ARGB，自定义 RGBA 数据用 RGBA 顺序），但同一模块同时支持两个顺序避免调用方手动移位。

3. **位掩码通道枚举**：`Rgba.Channel` 用二进制位掩码（`R=0x01, G=0x02, B=0x04, A=0x08`）组合标识通道，`RGB=0x07, RGBA=0x0F`，为下游画像滤镜按位选通道提供声明式表达。

4. **gamma 校正灰度**：`gray()` 采用 2.2 幂次权值（\(R^{2.2} \times 0.2973 + G^{2.2} \times 0.6274 + B^{2.2} \times 0.0753\) 再开 2.2 次方）计算感知亮度，区别于简单平均法，更符合人眼对不同色光敏感度差异。

5. **标准化色差**：`diff(Rgba, Rgba)` 计算 RGB 曼哈顿距离绝对值的平均 / 256，归一化到 `[0,1]`，为图像相似度判断、颜色替换过滤等提供轻量指标。

## 模块目的

- 为 `i2f-graphics-2d`（樱花树绘制）、`i2f-graphics-3d`（3D 着色与光影）、`i2f-image-impl`（约 18 个画像滤镜：模糊/边框/替换色/ASCII/通道提取/色调增强/冷色调/提亮/暗化/数据隐写等）提供统一的色彩数据载体与 RGBA↔HSL 互转能力。
- 封装像素级最常见的两种色彩空间（加法 RGB 与感知均匀 HSL），避免各消费方重复实现颜色模型转换与钳制逻辑。

## 模块功能

| 功能 | 方法入口 | 说明 |
|---|---|---|
| RGBA 构造 | `Rgba.rgb(r,g,b)` / `rgba(r,g,b,a)` | 创建 RGBA 色彩对象 |
| 整数解包 | `Rgba.rgba(int)` / `Rgba.argb(int)` | 从 32 位 int 按 RGBA 或 ARGB 字节序解析 |
| 整数打包 | `Rgba.rgba()` / `Rgba.argb()` | 将 RGBα 序列化为 32 位 int |
| 颜色插值 | `Rgba.smooth(rate, c1, c2)` | 按 `rate`（0–1）在 c1→c2 之间线性渐变 |
| 色差计算 | `Rgba.diff(c1, c2)` | 曼哈顿归一化色差 `[0,1]` |
| 灰度转换 | `Rgba.gray()` | gamma 校正 2.2 感知亮度灰度 |
| HSL 互转 | `Rgba.hsl()` / `Hsl.rgb2hsl()` / `Hsl.hsl2rgb()` | RGB ↔ HSL 双向转换 |
| HSL 构造 | `Hsl.hsl(h,s,l)` / `Hsl.hsla(h,s,l,a)` | 创建 HSL 色彩（值域 `[0,1]`） |
| 预定义颜色 | `Rgba.black/white/red/green/blue/transparent/gray/yellow/pink/cyan` | 10 个常用颜色常量 |
| 通道枚举 | `Rgba.Channel` | R/G/B/A/RGB/RGBA 位掩码，画像滤镜按需选择 |

## 模块主要使用方法

```java
// 构造与整数打包
Rgba color = Rgba.rgba(255, 128, 64, 255);
int rgbaInt = color.rgba();   // RGBA 字节序
int argbInt = color.argb();   // ARGB 字节序 (BufferedImage 兼容)

// 整数解包
Rgba fromRgba = Rgba.rgba(rgbaInt);
Rgba fromArgb = Rgba.argb(argbInt);

// HSL 转换
Hsl hsl = color.hsl();
Rgba back = hsl.rgba();

// 颜色插值
Rgba start = Rgba.red();
Rgba end = Rgba.blue();
Rgba mid = Rgba.smooth(0.5, start, end); // 紫色渐变

// 灰度与色差
int gray = color.gray();
double diff = Rgba.diff(start, end);

// 通道枚举
int mask = Rgba.Channel.RGB.mask(); // 0x07
```

## 模块特性总结

- **极简双类**：全模块仅 2 个类（`Rgba` + `Hsl`），共约 310 行源码，聚焦色彩表示与转换单一职责
- **双向互转**：RGBA ↔ HSL 无损双向转换，任一类持有对端的引用方法
- **双字节序**：同时支持 RGBA 与 ARGB 两种 32 位整数编码，适配不同图像库约定
- **色彩操作**：gamma 校正灰度、归一化色差、线性插值、常用颜色常量
- **通道位掩码**：`Channel` 枚举使下游画像滤镜以声明式选取操作通道
- **真实 lombok 使用**：`Rgba` 以 `@Data`/`@NoArgsConstructor` 生成 getter/setter 与无参构造（区别于多数兄弟模块的冗余声明）

## 已知实现瑕疵

| 瑕疵 | 位置 | 现象 | 影响 |
|---|---|---|---|
| **`b` 通道未钳制**（复制粘贴笔误） | `Hsl.hsl2rgb()` L118–120 | `r` 被钳制两次、`b` 完全跳过钳制；最后一行的 `between` 入参 `r` 实为 `b` | 极端 HSL（高饱和 + 极亮/极暗）转换回 RGB 时 `b` 分量可能越 `[0,255]`，`(int)` 转型溢出产生异常像素值 |
| **`gray()` 高开销** | `Rgba.gray()` | `Math.pow` 每个通道各三次（2.2 幂次 + 1/2.2 开方），含浮点运算 | 大批量像素操作时性能敏感 |
| **公共字段暴露** | `Rgba`/`Hsl` | `r/g/b/a` 及 `h/s/l/a` 均为 `public int/double` | 外部可直接修改内部状态，`@Data` 的 `setter` 代码生成浪费，违背封装原则 |

> **hsl2rgb 复制粘贴笔误修复参考**：将 `Hsl.java` L120 的 `r = MathUtil.between(r, 0, 255);` 改为 `b = MathUtil.between(b, 0, 255);`。

## 下游与关联

| 方向 | 模块 | 用途 |
|---|---|---|
| **消费方** | `i2f-graphics-2d` (CherryTree) | 樱花树绘制像素着色 |
| | `i2f-graphics-3d` (D3Painter/D3Color/D3TreeLine) | 3D 图形颜色与光照表现 |
| | `i2f-image-impl` (~18 个滤镜) | 画像滤波器像素级操作（模糊/边框/替换色/ASCII/通道提取/色调增强/冷色调/提亮/暗化/数据隐写等） |
| | `i2f-extension-gif` (Gif) | GIF 生成像素颜色处理 |
| **关联依赖** | `i2f-math` | `MathUtil.between()` / `MathUtil.smooth()` 值域钳制与插值 |