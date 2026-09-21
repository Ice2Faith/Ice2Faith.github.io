# i2f-maven-plugin

> i2f 构建期 Maven 插件模块，提供 `i2f:spi` 目标（Mojo），在 `process-classes` 阶段基于 ASM 扫描编译产物中标注 `@Spi` 的 class 文件，自动为声明的 SPI 接口生成并合并 `META-INF/services/` 服务描述文件，免除手工维护 Java SPI 配置。

## 模块路径

- `i2f-tools/i2f-maven-plugin`

## 模块依赖

| GroupId | ArtifactId | Scope | Optional | 说明 |
|---------|-----------|-------|----------|------|
| org.apache.maven | maven-plugin-api | provided | false | Maven 插件 API（`AbstractMojo`、`MojoExecutionException`） |
| org.apache.maven.plugin-tools | maven-plugin-annotations | provided | false | Mojo/参数注解（`@Mojo`、`@Parameter`、生命周期与依赖解析枚举） |
| org.apache.maven | maven-project | provided | false | Maven 2.x 时代的 `MavenProject` 模型（**源码零引用，实为无用依赖**；`${project.build.outputDirectory}` 由 Maven 运行期从工程模型注入，与本 artifact 无关，详见瑕疵 3） |
| org.ow2.asm | asm | compile | false | 字节码读取，解析 class 文件中的 `@Spi` 注解及其 `value` 接口列表 |

> 本模块为**独立构建**的 Maven 插件：`groupId=i2f.turbo`、`artifactId=i2f-maven-plugin`、`version=1.0`、`packaging=maven-plugin`，**未继承仓库根 `i2f-turbo-java` 父 POM**，自行声明编译级别（source/target 8、UTF-8）。Maven 相关依赖均为 `provided`（由 Maven 运行期提供），仅 ASM 为 `compile` 随插件打包。

## 模块设计

### 单 Mojo 职责

模块目前仅一个 Mojo —— `SpiComponentScanMojo`，绑定到 `i2f` goal 前缀下的 `spi` 目标：

| 维度 | 取值 | 说明 |
|------|------|------|
| Goal | `i2f:spi` | `@Mojo(name="spi")` + `<goalPrefix>i2f</goalPrefix>` |
| 默认生命周期阶段 | `PROCESS_CLASSES` | 编译之后、打包之前，此时 `target/classes` 已产出 `.class` |
| 依赖解析要求 | `ResolutionScope.COMPILE` | 需要编译期类路径 |
| 扫描目录 | `${project.build.outputDirectory}` | 只读参数，默认 `target/classes` |
| 注解全名 | `spi.annotation`（默认 `i2f.spi.annotations.Spi`） | 可通过系统属性覆盖，支持扫描其它 SPI 注解 |

### 处理流水线

```mermaid
flowchart TD
    A["execute()"] --> B{classesDirectory 存在?}
    B -- 否 --> B1["warn 并返回"]
    B -- 是 --> C["toAnnotationDescriptor<br/>全名 → ASM 描述符 Li2f/.../Spi;"]
    C --> D["walkFileTree 遍历 target/classes"]
    D --> E["每个 .class：ClassReader.accept(SKIP_CODE|SKIP_DEBUG|SKIP_FRAMES)"]
    E --> F["SpiClassVisitor 命中 @Spi<br/>收集 value 中的接口 internalName"]
    F --> G["spiMappings: 接口 → [实现类...]"]
    G --> H{映射为空?}
    H -- 是 --> H1["info 跳过"]
    H -- 否 --> I["writeServiceFiles"]
    I --> J["mergeWithExistingEntries<br/>读取已有文件 + LinkedHashSet 去重合并"]
    J --> K["写回 META-INF/services/&lt;接口全名&gt;"]
```

### 关键设计点

1. **纯字节码扫描，不加载类**：使用 ASM 以 `ClassReader.SKIP_CODE | SKIP_DEBUG | SKIP_FRAMES` 模式读取 class，仅解析类头与注解，不触发类加载，快且无副作用；这也要求绑定在编译之后的阶段。

2. **兼容单值与数组两种注解写法**：`SpiAnnotationValueCollector` 同时重写 `visit`（单值 `@Spi(A.class)`）与 `visitArray`（数组 `@Spi({A.class, B.class})`），统一从 `Type.getInternalName()` 提取接口并把 `/` 转 `.`。

3. **与手写配置合并而非覆盖**：`mergeWithExistingEntries` 先读已存在的 `META-INF/services/<接口>`（忽略空行与 `#` 注释行），再用 `LinkedHashSet` 保序去重合并扫描结果，保证手工登记的 provider 不被丢失，且幂等可重复执行。

4. **可插拔的注解契约**：目标注解全名由 `spi.annotation` 参数化，默认对接 `i2f-spi-annotations` 的 `@Spi`，但不硬编码依赖该模块（无编译期依赖，纯字符串约定），因此也可适配同名结构的其它 SPI 注解。

### 包结构

| 包 / 类 | 角色 | 说明 |
|---------|------|------|
| `i2f.maven.plugin.spi.SpiComponentScanMojo` | Mojo 入口 | 扫描 + 生成/合并服务文件全流程 |
| `↳ SpiClassVisitor`（内部类） | ASM ClassVisitor | 识别目标注解、记录类名与接口 internalName |
| `↳ SpiAnnotationValueCollector`（内部类） | ASM AnnotationVisitor | 提取注解 `value` 的类引用（单值/数组） |
| `↳ SpiAnnotationInfo`（内部类） | 数据载体 | 保存单个类的实现类名与其提供的接口列表 |

## 模块目的

- 用构建期自动化替代「手写并同步 `META-INF/services/` 文件」的易错劳动，让 `@Spi` 声明与 Java SPI 运行时约定保持一致。
- 与 `i2f-spi-annotations`（注解契约）、`i2f-spi`（`ServiceLoader` 运行期加载）形成「声明 → 构建期生成 → 运行期加载」的完整 SPI 闭环。
- 保证增量与幂等：多次构建、与手工条目共存均不破坏既有注册。

## 模块功能

- 扫描 `target/classes` 下所有 `.class`，识别标注目标 SPI 注解（默认 `@Spi`）的类。
- 为注解 `value` 中声明的每个接口收集其实现类，构建「接口 → 实现列表」映射。
- 在 `target/classes/META-INF/services/` 下按接口全名生成描述文件，并与已有条目去重合并。
- 输出每个已注册实现的构建日志；无命中时安全跳过。

## 模块主要使用方法

在业务模块的 `pom.xml` 中引入插件（打包阶段自动生效，也可显式执行）：

```xml
<build>
    <plugins>
        <plugin>
            <groupId>i2f.turbo</groupId>
            <artifactId>i2f-maven-plugin</artifactId>
            <version>1.0</version>
            <executions>
                <execution>
                    <goals>
                        <goal>spi</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

配合注解使用：

```java
@Spi({PaymentService.class, NotificationService.class})
public class AlipayServiceImpl implements PaymentService, NotificationService { }
```

构建后自动生成：

- `META-INF/services/com.example.PaymentService` → 含 `com.example.AlipayServiceImpl`
- `META-INF/services/com.example.NotificationService` → 含 `com.example.AlipayServiceImpl`

命令行单独执行：

```bash
mvn i2f:spi
# 覆盖扫描的注解类型：
mvn i2f:spi -Dspi.annotation=com.mycompany.MySpi
```

注意事项：

- 插件依赖编译产物，务必在 `mvn compile` 之后执行（正常生命周期中 `process-classes` 阶段自动满足）。
- 若 `@Spi` 的接口写成了非服务类型，生成的描述文件将无法被对应 `ServiceLoader` 命中。
- 目标注解需为 `RUNTIME` 保留且写入 class 常量池，否则 ASM 无法读取；默认 `@Spi` 已满足。
- 本模块独立版本 `1.0`，不随父工程聚合构建，需单独 `mvn install` 后方可被消费。

## 模块特性总结

- 单目标插件 `i2f:spi`，聚焦「SPI 服务文件自动生成」单一职责。
- 基于 ASM 的零类加载字节码扫描，绑定 `process-classes` 阶段，快速无副作用。
- 兼容 `@Spi(A.class)` 与 `@Spi({A.class, B.class})` 两种声明形式。
- 与已有服务文件去重合并、幂等可重复构建，保留手工登记的 provider。
- 目标注解类型可通过 `spi.annotation` 参数化，契约式解耦、不硬依赖注解模块。
- 与 `i2f-spi-annotations` / `i2f-spi` 协同，构成声明式 SPI 的构建期枢纽。

## 模块瑕疵或错误（实证）

> 以下均经通读 `SpiComponentScanMojo.java`（341 行）、本模块 `pom.xml`、`i2f-tools/pom.xml`、模块自带 `readme.md` 及全仓 grep 佐证，非臆测。

1. **游离于 reactor 之外、版本脱离治理**：本模块 pom **无 `<parent>`**，且 `i2f-tools/pom.xml` 的 `<modules>` 仅列 `i2f-tools-source-copier`、**未登记本模块**——根聚合 `mvn install` 不会编译/安装它，使用前须单独 `mvn install` 方可被消费。其 `version=1.0`（pom L9）与全仓 `1.0-jdk8` 约定不一致，并自行声明 `maven.compiler.source/target=8`、脱离根 pom 统一治理。全仓 grep `i2f-maven-plugin` 仅命中其自身 pom，**无任何消费方**（既未被任何模块以 build-plugin 引入，也无 test 使用）。

2. **模块自带 readme「项目结构」与事实矛盾**：目录内 `readme.md` L224-234 声称 `src/main/java/i2f/spi/annotations/Spi.java`（`@Spi` 注解定义）位于**本模块内**，但本模块实际仅 3 个文件（`pom.xml`/`readme.md`/`SpiComponentScanMojo.java`），`@Spi` 真实定义在 `i2f-jdk/i2f-spi-annotations`。同一份 readme L64-68 又指导用户去依赖 `i2f-spi-annotations`——结构图与依赖说明自相矛盾，易误导使用者以为注解随插件下发。

3. **`maven-project:2.2.1` 死依赖 + 版本反模式**：pom L34-39 以 `provided` 引入 Maven **2.x** 时代的 `maven-project`，但源码**零 `import`**（无 `MavenProject`/`org.apache.maven.project` 任何引用，grep 佐证）——`${project.build.outputDirectory}` 实际由 Maven 运行期从工程模型注入，与该 artifact 无关。在 `maven-plugin-api:3.6.3`（Maven 3）旁挂 Maven 2 的 `maven-project` 本身即已知反模式，此处更纯属无用。

4. **`i2f.version` 死属性**：pom L18 定义 `<i2f.version>1.0-jdk8</i2f.version>`，但全 pom **无任何 `${i2f.version}` 引用**（本模块不含任何 i2f 内部依赖），为遗留无效属性。

5. **`requiresDependencyResolution=COMPILE` 多余构建开销**：Mojo 仅遍历 `classesDirectory` 目录、**从不使用解析出的依赖类路径**，却声明 `ResolutionScope.COMPILE`——每次执行都强制完整解析消费工程的编译期依赖，无谓拖慢构建，去掉不影响任何功能。

6. **合并会静默丢弃注释与空行**：`readExistingEntries`（L180-194）读取已有 `META-INF/services/<接口>` 时仅保留「非空且非 `#` 开头」的行，写回时把原文件的注释、空行、排版**全部抹去**。自带 readme 称「智能合并、不会覆盖已有条目」仅对**条目**成立，手写文件里的说明性注释在首次构建后即丢失。

7. **增量构建可能残留陈旧 provider**：合并目标写在 `target/classes`，当某个 `@Spi` 类被删除或改名后，其旧条目仍留在上一轮已生成的 services 文件中（Maven 增量不清理该产物），须 `mvn clean` 才彻底一致——所谓「幂等」仅对**新增**成立，对**删除/重命名**不成立。

8. **逐条 INFO 日志噪声**：`writeServiceFile`（L204-209）在写出循环内对每个实现 `getLog().info("Registered SPI: " + impl)`，provider 较多时 INFO 日志刷屏，宜降为 debug 或收尾汇总。

## 生态位置

- **i2f-tools 组首个建档模块**，亦是全仓**唯一 `packaging=maven-plugin` 的构建期工具件**——不同于 springboot/springcloud 组的运行期 Starter，它在消费工程的编译与打包之间（`process-classes`）介入，产出物是随 jar 分发的 `META-INF/services/` 描述文件。
- 处于 i2f 声明式 SPI 闭环的中枢环节：`i2f-spi-annotations`（`@Spi` 注解契约，运行期可读）→ **`i2f-maven-plugin`（本件，构建期扫描生成 services 文件）** → `i2f-spi`（`ServiceLoader` 运行期加载）。三者作者同为 Ice2Faith、集中于 2026/9 新增，是一组配套设计。
- 与 springcloud 组的空壳薄封装相反，本件是**功能完整的自研实用工具**，逻辑清晰、无明显 NPE/崩溃类硬伤；其主要问题集中在**工程治理层**（游离 reactor、虚假结构文档、死依赖/死属性、多余依赖解析）与**边界语义**（注释丢失、删除残留），而非运行时正确性。
- 当前**零消费方**，实际价值取决于后续是否把 SPI 声明式注册推广到各业务模块并单独 `install` 本插件。
