# i2f-graphics-2d & i2f-graphics-3d — 二维/三维图形学引擎

## 概述

`i2f-graphics-2d` 是项目的二维图形学基础模块，提供点/线/面/向量/贝塞尔曲线等几何原语、多边形分析工具（面积/顺逆时针/凸凹判断）、坐标投影体系、仿射变换体系、函数图像绘制、Swing
可视化组件以及分形樱花树生成器等能力。`i2f-graphics-3d` 是基于 2D 模块构建的三维图形引擎，提供完整的 3D
渲染管线：三维几何原语 → 变换 → 背面剔除 → 光照/材质 → 投影 → 二维显示，以及 12 种内置几何体、10 种投影方式、25+ 种变换、Phong
光照模型、20+ 种预设材质和交互式 3D 视窗。

两个模块共同构成项目的图形学基础设施，纯 Java AWT 实现，零外部依赖（仅 Lombok +
项目内部 `i2f-math`/`i2f-color`/`i2f-tuple-impl`），完全兼容 JDK8。

## 模块信息

| 属性             | i2f-graphics-2d                 | i2f-graphics-3d                                                      |
|----------------|---------------------------------|----------------------------------------------------------------------|
| **ArtifactId** | `i2f-graphics-2d`               | `i2f-graphics-3d`                                                    |
| **父模块**        | `i2f-jdk`                       | `i2f-jdk`                                                            |
| **版本**         | `1.0-jdk8`                      | `1.0-jdk8`                                                           |
| **包路径**        | `i2f.graphics.d2.*`             | `i2f.graphics.d3.*`                                                  |
| **源文件数**       | 42                              | 74                                                                   |
| **定位**         | 二维图形学基础                         | 三维图形引擎                                                               |
| **外部依赖**       | Lombok, `i2f-math`, `i2f-color` | Lombok, `i2f-math`, `i2f-color`, `i2f-graphics-2d`, `i2f-tuple-impl` |

## 依赖关系

```
i2f-graphics-3d
├── i2f-graphics-2d
│   ├── i2f-math
│   └── i2f-color
├── i2f-math
├── i2f-color
└── i2f-tuple-impl
```

---

## i2f-graphics-2d — 二维图形学基础

### 核心几何原语

| 类              | 说明                                                   |
|----------------|------------------------------------------------------|
| `Point`        | 二维点（x, y），支持 move2/add/sub/dotMul/crossMul/mul 运算    |
| `Vector`       | 二维向量（继承 `Point`），实现 `ILenght` 接口，支持模长/单位化/加法/点乘/夹角计算 |
| `Line`         | 直线（begin → end），支持 length/dx/dy/direction/spin 运算    |
| `Flat`         | 平面（3 点定义：p1, p2, p3）                                 |
| `Size`         | 尺寸（dx, dy），支持自适应缩放 `adaptSize()`（保持宽高比）              |
| `Scope`        | 二维空间范围（Point + Size），支持 left/top/right/bottom 边界     |
| `D2Calc`       | 2D 运算工具：方向角/方向移动/偏移移动/直线旋转/反射角计算                     |
| `Bezier`       | 贝塞尔曲线：Bernstein 基函数、曲线点计算、重采样/自适应采样                  |
| `D2VaryUtil`   | 2D 变异/变换工具                                           |
| `LocationUtil` | 位置计算工具                                               |

### 几何形状（shape 包）

| 类           | 说明                  |
|-------------|---------------------|
| `Circle`    | 圆形（center + radius） |
| `Ellipse`   | 椭圆                  |
| `Rectangle` | 矩形（继承 `Scope`）      |
| `Polygon`   | 多边形（`List<Point>`）  |

### 多边形分析工具（polygon 包）

| 类                           | 说明                                      |
|-----------------------------|-----------------------------------------|
| `PolygonAreaTool`           | 多边形面积计算（鞋带公式/Shoelace formula），O(n) 复杂度 |
| `PolygonClockDirectionTool` | 多边形顺/逆时针判断（叉积统计法）+ 凸凹判断                 |
| `PolygonClockTool`          | 多边形顺/逆时针修正工具                            |
| `PolygonLocationTool`       | 多边形位置关系工具（218 行）                        |
| `PolygonOffsetTool`         | 多边形偏移工具                                 |

### 投影体系（projection 包）

```
IProjection                          -- 接口：projection(Point) / onSizeChange(w, h)
├── MathCenterProjection             -- 数学中心投影（原点在画布中心，Y 轴向上）
├── MathLeftDownProjection           -- 数学左下角投影（原点在左下角，Y 轴向上）
├── MathOffsetProjection             -- 数学偏移投影（可自定义原点偏移）
└── ScreenProjection                 -- 屏幕投影（原点在左上角，Y 轴向下）
```

### 变换体系（tranform 包）

```
ITransform                           -- 接口：transform(Point) → Point
└── AbstractMatrixTransform          -- 抽象矩阵变换（2x2 矩阵 + 平移）
    ├── MoveTransform                -- 平移变换
    ├── ScaleTransform               -- 缩放变换
    ├── SpinTransform                -- 旋转变换
    ├── MiscutTransform              -- 错切变换
    ├── ReflectAxisTransform         -- 关于原点对称
    ├── ReflectAxisXTransform        -- 关于 X 轴对称
    ├── ReflectAxisYTransform        -- 关于 Y 轴对称
    ├── ReflectOriginTransform       -- 关于原点对称
    ├── RelativeAnyPointTransform    -- 关于任意点的变换
    └── RelativeAnyLineTransform     -- 关于任意直线的变换
```

### 函数图像绘制（function 包）

`FunctionPainter`（380 行）— 通用函数图像绘制器，支持 3 种函数类型：

| 类型          | 说明   | 输入/输出                 |
|-------------|------|-----------------------|
| `CROSS`     | 直角坐标 | x → y1, y2, y3...     |
| `CENTER`    | 极坐标  | θ → r1, r2...         |
| `ARGUMENTS` | 参数方程 | t → x1, y1, x2, y2... |

特性：自动坐标轴绘制、网格线、自适应范围、多曲线随机配色、支持自定义画布尺寸。

### 可视化组件（visual 包）

| 类          | 说明                                                                 |
|------------|--------------------------------------------------------------------|
| `D2Canvas` | 二维画布（继承 `Canvas`），持有 `BufferedImage`，重写 `paint()`/`update()` 实现双缓冲 |
| `D2Frame`  | 二维窗口（继承 `JFrame`），封装 `D2Canvas`，提供 `refresh()` 方法                  |

### 特效 — 分形樱花树

`CherryTree`（181 行）— 递归分形樱花树生成器，使用贝塞尔曲线绘制枝干，颜色渐变（startColor →
endColor），支持步进回调动画（`OnStepListener`），配合 `D2Frame` 实现实时绘制动画。

---

## i2f-graphics-3d — 三维图形引擎

### 渲染管线

```
三维模型（D3Model）
    ↓
变换链（transforms: ID3Transform 列表）
    ↓
背面剔除（BlankingAlgorithm: 法向量·视向量）
    ↓
光照计算（LightAlgorithm: Phong 模型）
    ↓
三维投影（ID3Projection: 3D → 2D）
    ↓
二维投影（IProjection: 数学坐标 → 屏幕坐标）
    ↓
光栅化显示（BufferedImage → Canvas）
```

### 核心几何原语

| 类                    | 说明                                               |
|----------------------|--------------------------------------------------|
| `D3Point`            | 三维点（x, y, z），支持球坐标转换 `spherical()`               |
| `D3Vector`           | 三维向量（继承 `D3Point`），支持模长/单位化/加法/点乘/**叉乘**/法向量/偏转角 |
| `D3Line`             | 三维直线（begin → end），支持投影到 2D `Line`                |
| `D3Flat`             | 三维平面（3 点定义），支持法向量 `normalLine()`                 |
| `D3Calc`             | 3D 运算工具：球坐标方向移动/偏移移动                             |
| `D3SphericalPoint`   | 球坐标点（radius, aAngle, bAngle），支持直角坐标转换 `point()`  |
| `D3Scope` / `D3Size` | 三维范围/尺寸                                          |
| `D3VaryUtil`         | 3D 变异/矩阵运算工具                                     |

### 数据模型（data 包）

| 类             | 说明                                                    |
|---------------|-------------------------------------------------------|
| `D3Model`     | 三维模型（`List<D3Point>` 点云 + `List<D3ModelFlat>` 三角片面索引） |
| `D3ModelFlat` | 三角片面（p1, p2, p3 三个点索引）                                |
| `TmFileUtil`  | 模型文件读写工具（80 行）                                        |

### 内置几何体（shape 包）— 12 种

| 类                | 说明     | 生成方式                              |
|------------------|--------|-----------------------------------|
| `Ball`           | 球体     | 经纬度细分 / 二十面体递归细分（2 种 `makeModel`） |
| `Cuboid`         | 长方体    | 三面网格点云                            |
| `Cone`           | 圆锥     | 底面圆 + 顶点                          |
| `Cylinder`       | 圆柱     | 双底面圆                              |
| `Torus`          | 环面     | 双参数方程                             |
| `SpinCube`       | 旋转体    | 2D 轮廓点绕 X/Y 轴旋转                   |
| `SpinBezierCube` | 贝塞尔旋转体 | 贝塞尔曲线轮廓旋转                         |
| `Tetrahedron`    | 正四面体   | 4 顶点                              |
| `Hexahedron`     | 正六面体   | 6 面 8 顶点                          |
| `Octahedron`     | 正八面体   | 8 面 6 顶点                          |
| `Dodecahedron`   | 正十二面体  | 12 面 20 顶点                        |
| `Icosahedron`    | 正二十面体  | 20 面 12 顶点                        |
| `D3TreeLine`     | 三维分形树线 | 递归分支                              |

### 投影体系（projection 包）— 10 种

```
ID3Projection                        -- 接口：projection(D3Point) → Point(2D)
└── AbstractMatrixProjection         -- 抽象矩阵投影（4x4 矩阵变换 + 投影）
    ├── MainViewProjection           -- 主视图（前视图，yoz 平面）
    ├── SideViewProjection           -- 侧视图
    ├── TopViewProjection            -- 俯视图
    ├── OrthogonalProjection         -- 正交投影
    ├── ObliqueProjection            -- 斜投影
    ├── OnePointProjection           -- 一点透视投影
    ├── TwoPointProjection           -- 二点透视投影
    ├── ThreePointProjection         -- 三点透视投影
    └── WorldOrgToScreenOrgProjection -- 世界原点→屏幕原点投影
```

### 变换体系（transform 包）— 25+ 种

```
ID3Transform                         -- 接口：transform(D3Point) → D3Point
└── AbstractMatrixTransform          -- 抽象矩阵变换
    ├── MoveTransform                -- 平移（mx, my, mz）
    ├── ScaleTransform               -- 缩放（sx, sy, sz）
    ├── SpinTransform                -- 旋转（sx, sy, sz）
    ├── SpinXTransform/Y/Z           -- 单轴旋转
    ├── MiscutAxisTransform          -- 错切（6 参数）
    ├── MiscutAxisX/Y/ZTransform     -- 单轴错切
    ├── ReflectAxisTransform         -- 轴反射（rx, ry, rz 布尔）
    ├── ReflectAxisX/Y/ZTransform    -- 单轴反射
    ├── ReflectFlatTransform         -- 面反射（xoy, yoz, xoz 布尔）
    ├── ReflectFlatXoY/XoZ/YoZTransform -- 单面反射
    ├── RelativeAnyPointTransform    -- 关于任意点变换
    ├── RelativeAnyLineTransform     -- 关于任意线变换
    └── org/                         -- 原点相关变换子包
        ├── OrgMoveTransform         -- 原点平移
        ├── OrgSpinTransform         -- 原点旋转
        └── OrgSpinX/Y/ZTransform    -- 原点单轴旋转
```

### 光照与材质系统（light 包）

**光照算法** — `LightAlgorithm`（126 行）：

实现 **Phong 光照模型**，包含：

- **漫反射**（Diffuse）：Lambert 余弦定律
- **镜面反射**（Specular）：Blinn-Phong 半角向量法
- **光强衰减**：`1 / (c0 + c1·d + c2·d²)`（三因子衰减）
- **环境光**（Ambient）：全局均匀光照
- **颜色归一化**：最终颜色向量单位化

**灯光** — `D3Light`，9 种预设：

| 预设                 | 说明      |
|--------------------|---------|
| `gold()`           | 金色灯光    |
| `silver()`         | 银色灯光    |
| `redGemstone()`    | 红宝石灯光   |
| `greenGemstone()`  | 绿宝石灯光   |
| `blueGemstone()`   | 蓝宝石灯光   |
| `purpleGemstone()` | 紫水晶灯光   |
| `moon()`           | 月光（冷白色） |
| `sun()`            | 阳光（暖白色） |
| `white()`          | 纯白灯光    |

**材质** — `Material`（338 行），20+ 种预设：

包括：`gold`/`silver`/`stone`/`snow`/`emerald`/`jade`/`obsidian`/`pearl`/`ruby`/`turquoise`/`brass`/`bronze`/`chrome`/`copper`/`glGold`/`glSilver`
等，参数参考 OpenGL 标准材质库。

**颜色** — `D3Color`：浮点 RGB 颜色（0.0 ~ 1.0），支持与 `Rgba` 互转。

### 三角化（triangle 包）

| 类                            | 说明                                        |
|------------------------------|-------------------------------------------|
| `ITrianglize`                | 三角化接口：`D3Model trianglize(D3Model)`       |
| `ShortestDistanceTrianglize` | 最短散点距离三角化（296 行），支持钝角过滤、双向三角化、层级查找、距离规则排序 |

### 可见性（visible 包）

`BlankingAlgorithm` — 背面剔除算法：计算面法向量与视向量的夹角余弦，正值可见，负值不可见（画家算法简化版）。

### 核心绘制器 — D3Painter（377 行）

`D3Painter` 是三维渲染管线的核心协调器，链式 API 设计：

```java
D3Painter painter = new D3Painter(width, height, projection);
painter.

setFillColor(Rgba.rgb(200, 200,200))
        .

clean()                                    // 清屏
       .

drawAxisLine(200)                          // 绘制坐标轴
       .

drawModelLines(model)                      // 线框模式
       .

drawModelFlats(model);                     // 面片模式（含光照）
```

关键属性：

- `transforms`: 变换链列表
- `enableBlanking`: 是否启用背面剔除
- `enableLighting`: 是否启用光照
- `lights`: 灯光列表
- `material`: 当前材质
- `viewPoint`: 视点（球坐标）

### 交互式视窗 — D3Frame（309 行）

`D3Frame` 提供完整的交互式 3D 视窗，支持键鼠操作：

| 操作                   | 功能          |
|----------------------|-------------|
| `Alt + X/Y/Z + 滚轮`   | 绕 X/Y/Z 轴旋转 |
| `Ctrl + X/Y/Z + 滚轮`  | X/Y/Z 方向平移  |
| `Shift + X/Y/Z + 滚轮` | X/Y/Z 轴单独缩放 |
| `滚轮`                 | 等比例缩放       |
| `Ctrl + 空格`          | 重置所有变换      |

---

## 源文件清单

### i2f-graphics-2d（42 文件）

| 包                            | 文件数 | 主要内容                                                                                                       |
|------------------------------|-----|------------------------------------------------------------------------------------------------------------|
| `i2f.graphics.d2`            | 12  | Point, Vector, Line, Flat, Size, Scope, Bezier, D2Calc, CherryTree, GraphicsUtil, D2VaryUtil, LocationUtil |
| `i2f.graphics.d2.shape`      | 4   | Circle, Ellipse, Rectangle, Polygon                                                                        |
| `i2f.graphics.d2.polygon`    | 5   | PolygonAreaTool, PolygonClockDirectionTool, PolygonClockTool, PolygonLocationTool, PolygonOffsetTool       |
| `i2f.graphics.d2.projection` | 5   | IProjection + 4 实现                                                                                         |
| `i2f.graphics.d2.tranform`   | 12  | ITransform + AbstractMatrixTransform + 10 实现                                                               |
| `i2f.graphics.d2.function`   | 1   | FunctionPainter                                                                                            |
| `i2f.graphics.d2.visual`     | 2   | D2Canvas, D2Frame                                                                                          |
| `i2f.graphics.d2.std`        | 1   | ILenght 接口                                                                                                 |

### i2f-graphics-3d（74 文件）

| 包                            | 文件数 | 主要内容                                                                                                                                      |
|------------------------------|-----|-------------------------------------------------------------------------------------------------------------------------------------------|
| `i2f.graphics.d3`            | 10  | D3Point, D3Vector, D3Line, D3Flat, D3Calc, D3Painter, D3Scope, D3Size, D3SphericalPoint, D3VaryUtil                                       |
| `i2f.graphics.d3.data`       | 3   | D3Model, D3ModelFlat, TmFileUtil                                                                                                          |
| `i2f.graphics.d3.shape`      | 13  | Ball, Cuboid, Cone, Cylinder, Torus, SpinCube, SpinBezierCube, Tetrahedron, Hexahedron, Octahedron, Dodecahedron, Icosahedron, D3TreeLine |
| `i2f.graphics.d3.projection` | 11  | ID3Projection + AbstractMatrixProjection + 9 实现                                                                                           |
| `i2f.graphics.d3.transform`  | 25+ | ID3Transform + AbstractMatrixTransform + 20+ 实现（含 org 子包）                                                                                 |
| `i2f.graphics.d3.light`      | 4   | D3Light, Material, LightAlgorithm, D3Color                                                                                                |
| `i2f.graphics.d3.triangle`   | 2   | ITrianglize + ShortestDistanceTrianglize                                                                                                  |
| `i2f.graphics.d3.visible`    | 1   | BlankingAlgorithm                                                                                                                         |
| `i2f.graphics.d3.visual`     | 2   | D3Canvas, D3Frame                                                                                                                         |

---

## 设计特点

1. **2D/3D 分层架构**：3D 引擎完全依赖 2D 基础原语（Point/Line/Vector/Projection），3D 投影最终落地为 2D 显示
2. **完整渲染管线**：变换 → 背面剔除 → 光照/材质 → 投影 → 光栅化，管线各阶段独立可替换
3. **Phong 光照模型**：漫反射 + 镜面反射 + 环境光 + 三因子衰减，20+ 种预设材质
4. **丰富的几何体库**：12 种内置几何体，涵盖基本体/正多面体/旋转体/分形体
5. **10 种投影方式**：三视图/正交/斜投影/一/二/三点透视，覆盖工程制图和透视效果需求
6. **交互式 3D 视窗**：键盘+滚轮操控旋转/平移/缩放，实时渲染
7. **纯 Java 实现**：仅依赖 AWT/Swing，零第三方库，JDK8 完全兼容
8. **链式 API**：`D3Painter` 所有方法返回 `this`，支持流畅链式调用
