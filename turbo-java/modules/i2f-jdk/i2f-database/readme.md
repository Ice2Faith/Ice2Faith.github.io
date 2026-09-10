# i2f-database

> 数据库能力**聚合门面模块** —— 零源码纯聚合，通过 `maven-assembly-plugin`（`jar-with-dependencies`）将 `i2f-database-type`（方言类型识别）与 `i2f-database-metadata-impl`（元数据多方言实现）打包为单一 fat-jar，供 `i2f-jdk-all` 全仓聚合引入，避免使用方逐一声明 database 族子模块坐标。

---

## 模块定位

- **功能**：将 i2f 持久化底层的**方言类型识别**与**元数据多方言读取/DDL 生成**两个核心领域打包为单入口依赖
- **所属层级**：`i2f-jdk` 持久化基础层，位于 `i2f-database-type` 和 `i2f-database-metadata-impl` 的**上层聚合**位置
- **设计原则**：
  - **零源码聚合**：只通过 `pom.xml` 声明依赖关系 + `maven-assembly-plugin` 做构建期装配，不贡献任何 Java 类或资源文件
  - **单坐标引入**：使用方（如 `i2f-jdk-all`）只需依赖 `i2f-database` 一个坐标，即可获得完整的数据功能
  - **运行时独立分发**：`jar-with-dependencies` 模式产出包含 `i2f-database-type` 和 `i2f-database-metadata-impl`（含其传递依赖）的 fat-jar，适合需要独立部署或嵌入的场景

## 依赖关系

```
i2f-database (聚合门面)
 ├── i2f-database-type           ── DatabaseType 方言识别（36 库枚举）
 └── i2f-database-metadata-impl  ── 9 方言元数据 Provider + 5 方言 DDL ReverseEngineer
       ├── i2f-database-metadata-std
       ├── i2f-database-metadata-data
       ├── i2f-text
       ├── i2f-form-url-encoded
       ├── i2f-jdbc-impl
       └── i2f-database-type (传递)
```

### 聚合内容详解

| 子模块 | 角色 | 源文件数 |
|--------|------|----------|
| `i2f-database-type` | 数据库方言类型/识别引擎（36 库枚举） | ~6 类 |
| `i2f-database-metadata-impl` | JDBC 元数据多方言实现 + DDL 反向生成 | 28 类 |

### 传递依赖链

`i2f-database-metadata-impl` 传递依赖以下模块，均被 fat-jar 覆盖：

- `i2f-database-metadata-std` — 元数据契约接口
- `i2f-database-metadata-data` — 元数据数据模型（TableMeta/ColumnMeta/StdType）
- `i2f-text` — 文本工具
- `i2f-form-url-encoded` — 编码工具
- `i2f-jdbc-impl` — JDBC 实现
- `i2f-database-type` — 与前相同

## 构建产物

```xml
<!-- pom.xml 构建配置 -->
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-assembly-plugin</artifactId>
            <!-- 继承自根 POM pluginManagement:
                 descriptorRefs → jar-with-dependencies
                 appendAssemblyId → false
                 在 package 阶段 single 目标执行 -->
        </plugin>
    </plugins>
</build>
```

运行 `mvn package` 后，在 `target/` 目录产出：

- `i2f-database-1.0-jdk8.jar` — **fat-jar**（含所有依赖的 `.class` 和资源），`appendAssemblyId=false` 因此 jar 名不含 `-jar-with-dependencies` 后缀

## 消费方

| 项目 | 坐标 |
|------|------|
| `i2f-jdk-all` | `<artifactId>i2f-database</artifactId>` |

`i2f-jdk-all` 作为 i2f-jdk 的全量聚合模块，依赖 `i2f-database` 以单坐标将数据库子系统的全部能力纳入全仓包。

## 与相邻模块的对比

| 模块 | 源码 | 职责 |
|------|------|------|
| `i2f-database` | 0 | 聚合门面：打包 i2f-database-type + i2f-database-metadata-impl 为 fat-jar |
| `i2f-database-type` | ~6 类 | 方言识别地基：36 库 + URL 嗅探 + SPI |
| `i2f-database-metadata-std` | 2 接口 | 元数据读取 + DDL 反向生成契约 |
| `i2f-database-metadata-data` | 6 类 | 元数据数据模型 + StdType 标准化类型系统 |
| `i2f-database-metadata-impl` | 28 类 | 9 方言 Provider + 5 方言 DDL 实现 |
| `i2f-database-dialect` | 13 类 | SQL 字面量方言安全转换（模板方法 + 9 方言） |