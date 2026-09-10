# i2f-graphics

> 二维/三维图形学能力**聚合门面模块** —— 零源码纯聚合，通过 `maven-assembly-plugin`（`jar-with-dependencies`）将 `i2f-graphics-2d`（二维图形学基础库，42 源文件约 2622 行）与 `i2f-graphics-3d`（三维图形学基础库，74 源文件约 4798 行）打包为单一 fat-jar，供 `i2f-jdk-all` 全仓聚合引入，避免使用方逐一声明 graphics 族子模块坐标。

---

## 模块定位

- **功能**：将 i2f 图形学子系统的**二维原语与运算**和**三维渲染管线与形状生成**两个核心领域打包为单入口依赖
- **所属层级**：`i2f-jdk` 图形学基础层，位于 `i2f-graphics-2d` 和 `i2f-graphics-3d` 的**上层聚合**位置
- **设计原则**：
  - **零源码聚合**：只通过 `pom.xml` 声明依赖关系 + `maven-assembly-plugin` 做构建期装配，不贡献任何 Java 类或资源文件
  - **单坐标引入**：使用方（如 `i2f-jdk-all`）只需依赖 `i2f-graphics` 一个坐标，即可获得完整的二维+三维图形学能力
  - **运行时独立分发**：`jar-with-dependencies` 模式产出包含 `i2f-graphics-2d` 和 `i2f-graphics-3d`（含其传递依赖）的 fat-jar，适合需要独立部署或嵌入的场景

## 依赖关系

```
i2f-graphics (聚合门面)
 ├── i2f-graphics-2d  ── 二维原语、运算、形状、投影、变换、函数绘图
 │     ├── i2f-math          ── MathUtil 数学工具
 │     ├── i2f-color         ── Rgba 颜色模型
 │     └── i2f-tuple-impl    ── Pair 双值返回
 └── i2f-graphics-3d  ── 三维渲染管线、投影/变换、光照/材质、形状、三角化
       ├── i2f-graphics-2d   ── 复用 Point/Line/Flat/Bezier/IProjection/ILenght
       ├── i2f-math          ── MathUtil 数学工具
       └── i2f-color         ── Rgba 光源与材质颜色
```

### 聚合内容详解

| 子模块 | 角色 | 源文件数 | 约行数 |
|--------|------|----------|--------|
| `i2f-graphics-2d` | 二维原语层 + 运算层 + 工具层 + 可视化 | 42 | 2622 |
| `i2f-graphics-3d` | 三维渲染管线 + 投影/变换 + 光照/材质 + 形状 + 三角化 | 74 | 4798 |

### 传递依赖链

`i2f-graphics-2d` 传递依赖以下模块，均被 fat-jar 覆盖：

- `i2f-math` — 数学工具（`MathUtil.sin/cos/sqrt/atan2` 等）
- `i2f-color` — 颜色模型（`Rgba`）
- `i2f-tuple-impl` — 双值返回（`Pair`）

`i2f-graphics-3d` 除传递获取上述全部依赖外，还直接依赖 `i2f-graphics-2d`（复用 7 个类）。

## 构建产物

```xml
<!-- pom.xml 构建配置 -->
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-assembly-plugin</artifactId>
            <!-- 继承自根 POM pluginManagement：
                 descriptorRefs → jar-with-dependencies
                 appendAssemblyId → false
                 在 package 阶段 single 目标执行 -->
        </plugin>
    </plugins>
</build>
```

运行 `mvn package` 后，在 `target/` 目录产出：

- `i2f-graphics-1.0-jdk8.jar` — **fat-jar**（含所有依赖的 `.class` 和资源），`appendAssemblyId=false` 因此 jar 名不含 `-jar-with-dependencies` 后缀

## 消费方

| 项目 | 坐标 |
|------|------|
| `i2f-jdk-all` | `<artifactId>i2f-graphics</artifactId>` |

`i2f-jdk-all` 作为 i2f-jdk 的全量聚合模块，依赖 `i2f-graphics` 以单坐标将图形学子系统的全部能力纳入全仓包。

## 注册链路

| 层级 | 用途 | 位置 |
|------|------|------|
| 根 `pom.xml` | 版本托管 `<artifactId>i2f-graphics</artifactId>` | L441 |
| `i2f-jdk/pom.xml` | 模块声明 `<module>i2f-graphics</module>` | L81 |
| `i2f-jdk-all/pom.xml` | 全仓聚合依赖声明 | L273 |

## 与相邻模块的对比

| 模块 | 源码 | 约行数 | 职责 |
|------|------|--------|------|
| `i2f-graphics` | 0 | 0 | **聚合门面**：打包 i2f-graphics-2d + i2f-graphics-3d 为 fat-jar |
| `i2f-graphics-2d` | 42 类 | 2622 | 二维原语（点线面矩形）、运算（3×3 齐次）、投影、变换、函数绘图 |
| `i2f-graphics-3d` | 74 类 | 4798 | 三维渲染管线、投影/变换/光照/背面剔除、形状生成、散点三角化 |

## 子模块文档

详细文档请参阅各子模块的独立文档：

- [i2f-graphics-2d 详细文档](../i2f-graphics-2d/readme.md)
- [i2f-graphics-3d 详细文档](../i2f-graphics-3d/readme.md)