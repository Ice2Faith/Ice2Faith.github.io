# i2f-image-std

> **图像处理标准接口与工具集**——11 源文件约 424 行，纯 JDK + `i2f-color` 依赖，全 main 无测试。提供 `ImageUtil`（简单图片 I/O 封装）+ `FontUtil`（字体加载与注册）+ 三层过滤器接口体系（`IImageFilter`/`PixelFilter`/`RgbaFilter`）及 6 个适配器实现，构成双向桥接适配器矩阵。被 `i2f-image-impl`（约 140+ 源文件）作为滤波器基础设施全面消费。

---

## 模块定位

- **功能**：定义图像过滤器的标准接口体系与基础工具，为 `i2f-image-impl` 等实现层提供合约与适配基础设施
- **所属层级**：`i2f-jdk` 图像处理标准层，位于 `i2f-image-impl`（实现层）的下游依赖

## 依赖关系

| 依赖 | 类型 | 用途 | 是否真实使用 |
|------|------|------|-------------|
| `lombok` | 编译期 | 注解处理器 | **未使用**（全模块零 lombok 注解引用） |
| `i2f-color` | 编译+运行 | 提供 `Rgba` 颜色模型，被 `RgbaFilter` 体系用于类型安全的逐像素颜色变换 | 是（5 个文件 import `i2f.color.Rgba`） |

## 包结构

| 包 | 文件数 | 职责 |
|----|--------|------|
| `i2f.image` | 2 | 基础工具（`ImageUtil`、`FontUtil`） |
| `i2f.image.filter.std` | 3 | 过滤接口（`IImageFilter`、`PixelFilter`、`RgbaFilter`） |
| `i2f.image.filter.std.impl` | 6 | 适配器实现（双向桥接矩阵） |

## 类结构总览

### 基础工具（`i2f.image`）

| 类 | 行数 | 职责 |
|----|------|------|
| `ImageUtil` | 42 | 图片 I/O 工具：委托 `ImageIO.read/write`，`save(BufferedImage, File)` 自动从文件名推断格式 |
| `FontUtil` | 140 | 字体加载与注册：递归扫描目录加载 `.ttf/.ttc/.woff/.ottf/.pfa/.pfb` 字体文件，通过反射调用 `sun.font.FontManagerFactory.registerFont()` 注册到 JVM |

### 过滤接口（`i2f.image.filter.std`）

| 接口 | 方法签名 | 层级 |
|------|---------|------|
| `IImageFilter` | `BufferedImage filter(BufferedImage img)` | 图像级 |
| `PixelFilter` | `int pixel(int pixel)` | 像素级（int ARGB） |
| `RgbaFilter` | `Rgba pixel(Rgba color)` | 像素级（Rgba 对象） |

### 适配器实现（`i2f.image.filter.std.impl`）

6 个适配器构成双向桥接矩阵，实现「图像级 ↔ 像素级 int ↔ 像素级 Rgba」三层之间的两两转换与合并：

```
                    ┌──────────────────┐
                    │   IImageFilter    │
                    │  filter(BufferedImage) │
                    └────────┬─────────┘
                             │
              ┌──────────────┴──────────────┐
              │                             │
  PixelFilterImageFilter           RgbaFilterImageFilter
  (PixelFilter → IImageFilter)    (RgbaFilter → IImageFilter)
              │                             │
              ▼                             ▼
          PixelFilter                  RgbaFilter
      pixel(int)→int               pixel(Rgba)→Rgba
              ▲                             ▲
              │                             │
  PixelFilterRgbaFilter           RgbaFilterPixelFilter
  (PixelFilter → RgbaFilter)     (RgbaFilter → PixelFilter)
                                      │
                                      ▼
                              MergePixelFilter / MergeRgbaFilter
                              (链式合并多个同层滤波器)
```

| 实现 | 行数 | 功能 |
|------|------|------|
| `PixelFilterImageFilter` | 44 | 将 `PixelFilter` 适配为 `IImageFilter`：逐像素调用 `filter.pixel()`，支持 `returnNew()` 控制是否创建新图 |
| `RgbaFilterImageFilter` | 45 | 将 `RgbaFilter` 适配为 `IImageFilter`：逐像素转 `Rgba` → 调用 `filter.pixel()` → 转回 `argb()` |
| `PixelFilterRgbaFilter` | 26 | 将 `PixelFilter` 适配为 `RgbaFilter`：`Rgba→argb()` → `filter.pixel()` → `Rgba.argb()` |
| `RgbaFilterPixelFilter` | 26 | 将 `RgbaFilter` 适配为 `PixelFilter`：`argb()→Rgba` → `filter.pixel()` → `argb()` |
| `MergePixelFilter` | 37 | `CopyOnWriteArrayList` 链式合并多个 `PixelFilter`，支持运行时 `add()` |
| `MergeRgbaFilter` | 38 | `CopyOnWriteArrayList` 链式合并多个 `RgbaFilter`，支持运行时 `add()` |

## 核心机制详解

### 1. 三层过滤器体系

设计目标：不同消费方在不同抽象层级使用过滤器，通过适配器矩阵无缝互转。

- **图像级**（`IImageFilter`）：处理完整 `BufferedImage`——适用于全局变换（模糊、边框、裁剪）
- **像素级 int**（`PixelFilter`）：处理 `int ARGB` 原始像素——性能最优，适用于颜色矩阵等纯数值运算
- **像素级 Rgba**（`RgbaFilter`）：处理 `Rgba` 对象——类型安全，适用于 HSL/通道分离等需要结构化颜色信息的运算

**适配器桥接**（以 `RgbaFilterImageFilter` 为例）：

```java
// RgbaFilter → IImageFilter 适配器
public BufferedImage filter(BufferedImage img) {
    BufferedImage dimg = new BufferedImage(...);
    for (int x = 0; x < simg.getWidth(); x++) {
        for (int y = 0; y < simg.getHeight(); y++) {
            Rgba src = Rgba.argb(simg.getRGB(x, y));     // int→Rgba
            Rgba dst = filter.pixel(src);                  // RgbaFilter 运算
            dimg.setRGB(x, y, dst.argb());                 // Rgba→int
        }
    }
    return dimg;
}
```

### 2. FontUtil 字体加载

`FontUtil` 通过 `static` 初始块自动加载默认路径下的字体文件。

**加载流程：**

```
static { registryDefaultFonts(); }
  └→ registryDefaultFonts()
       └→ 检查 DEFAULT_FONT_PATHS = ["fonts", "conf/fonts", "resources/fonts"]
       └→ registryFonts(File[]) → loadFonts(File[]) → loadFont(File)
            ├→ 后缀匹配 TRUE_TYPE_SUFFIXES → Font.createFont(TRUETYPE_FONT, file)
            ├→ 后缀匹配 TYPE1_SUFFIXES → Font.createFont(TYPE1_FONT, file)
            └→ 后缀不匹配 → 依次尝试 TRUETYPE_FONT / TYPE1_FONT
       └→ registryFonts(Collection<Font>) → 反射 sun.font.FontManagerFactory.registerFont()
```

**注册方式：** 通过反射调用 `sun.font.FontManagerFactory.getInstance().registerFont(Font)`——这是 JDK 内部 API，非标准公开接口，存在跨 JDK 版本兼容风险。

### 3. ImageUtil 图片 I/O

极简封装，仅委托 `javax.imageio.ImageIO`：

```java
BufferedImage img = ImageUtil.load(new File("photo.jpg"));
ImageUtil.save(img, new File("output.png"));   // 自动从文件名推断格式
ImageUtil.save(img, "jpg", outputStream);
```

## 使用示例

### 示例 1：自定义灰度滤镜

```java
// 实现 PixelFilter
PixelFilter grayFilter = pixel -> {
    Rgba c = Rgba.argb(pixel);
    int g = (c.r + c.g + c.b) / 3;
    return Rgba.rgba(g, g, g, c.a).argb();
};

// 适配为图像级滤镜
IImageFilter imageFilter = new PixelFilterImageFilter(grayFilter);
BufferedImage result = imageFilter.filter(sourceImage);
```

### 示例 2：链式多滤镜合并

```java
MergePixelFilter chain = new MergePixelFilter();
chain.add(p -> Rgba.argb(p).toGray().argb())   // 灰度
     .add(p -> Rgba.argb(p).lighter(0.3f).argb());  // 提亮

// 或通过适配器使用 RgbaFilter
RgbaFilter adapter = new PixelFilterRgbaFilter(chain);
Rgba result = adapter.pixel(new Rgba(255, 128, 64, 255));
```

### 示例 3：字体加载

```java
Font font = FontUtil.loadFont(new File("fonts/MyFont.ttf"));
// 或注册到 JVM（通过反射 sun.font.FontManagerFactory）
FontUtil.registryFonts(new File[]{new File("fonts/")});
```

## 消费关系

| 方向 | 详情 |
|------|------|
| **生产者** | 本模块定义标准接口与适配器 |
| **消费者** | `i2f-image-impl`（约 140+ 源文件，25+ 处 import `i2f.image.*`）——本模块的核心消费方，使用 `IImageFilter`/`RgbaFilterImageFilter`/`FontUtil` 等构建具体图像滤镜 |
| **POM 注册** | `i2f-jdk/pom.xml` L88（modules）、`root pom.xml` L476（版本管理）、`i2f-jdk-all/pom.xml` L301（全仓聚合） |

## 已知缺陷

| 严重度 | 缺陷 | 说明 |
|--------|------|------|
| 低 | **lombok 声明未用** | `pom.xml` 声明 `lombok` 依赖，但全模块 11 个源文件零注解引用 |
| 低 | **FontUtil 空 catch 块** | `loadFont()` 中 TrueType/TYPE1 后缀匹配成功后的 `catch(Exception e){}` 静默吞异常，调试困难 |
| 低 | **FontUtil 冗余 fallback** | 后缀不匹配时依次尝试 `TRUETYPE_FONT` 和 `TYPE1_FONT`，但第一轮失败后第二轮几乎必然同失败，仍继续尝试 |
| 低 | **sun.font 反射 API** | `FontUtil.registryFonts()` 通过反射调用 `sun.font.FontManagerFactory`——JDK 内部 API，JDK 9+ 模块化后可能被限制访问（缺 `--add-opens` 参数时抛 `IllegalAccessException`） |
| 低 | **FontUtil 静态初始化** | `static { registryDefaultFonts(); }` 在类加载时执行，若目标目录不存在则 `loadFonts` 遍历空目录产生路径日志，影响启动速度 |
| 低 | **无测试** | 全模块位于 `main` 源码集，无 `test` 目录，无单元测试 |
| 低 | **ImageUtil 功能极简** | 仅封装 `ImageIO.read/write`，不支持格式转换参数、图像缩放、颜色空间管理等高阶能力 |

## 对比参考

| 对比项 | `i2f-image-std` | `i2f-image-impl` |
|--------|-----------------|-------------------|
| 层级 | 标准接口层 | 实现层 |
| 源文件 | 11（~424 行） | ~140+（~5000+ 行） |
| 角色 | 接口+工具+适配器 | 具体滤镜实现（模糊/边框/灰度/HSL/ASCII 风格等） |
| 核心依赖 | JDK + `i2f-color` | JDK + `i2f-image-std` + 多项 |
| 消费方 | `i2f-image-impl` | `i2f-jdk-all` |

## 总结

`i2f-image-std` 是一个**轻量级图像过滤器标件库**——以 424 行代码定义了三层过滤器接口体系（图像级/像素级 int/像素级 Rgba），通过 6 个适配器实现双向桥接矩阵，配合 `FontUtil` 字体工具和 `ImageUtil` 图片 I/O，为 `i2f-image-impl` 的 140+ 滤镜实现提供了完整的标准合约与适配基础设施。主要瑕疵为 lombok 冗余声明和 FontUtil 的内部 API 使用。