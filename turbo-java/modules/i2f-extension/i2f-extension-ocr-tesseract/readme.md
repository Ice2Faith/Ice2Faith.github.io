# i2f-extension-ocr-tesseract

> Tesseract OCR 桥接扩展（tess4j `4.5.1` 以 provided 引入）：仓库内最小的扩展模块之一，单类 `OcrTesseractProvider` 全静态 API，提供三入口 OCR 识别（`InputStream` / `BufferedImage` / `File`）。训练数据采用**自备引导**约定：Tesseract `datapath` 固定指向工作目录下的 `./runtime/persist/tesseract/ocr`，首次调用若目录不存在则创建空目录并抛出引导异常，提示用户自行从 tesseract-ocr/tessdata 下载 `*.traineddata` 放入。1 个主源文件（67 行）+ 1 个 main 型测试，仓库内无源码级消费方（仅 i2f-extension-all 聚合），未实现任何 OCR 契约接口。

## 模块路径

- `i2f-extension/i2f-extension-ocr-tesseract`
- 根 `pom.xml` `<module>` 登记（69 行）；`i2f-extension/pom.xml` 依赖管理（1160 行）；`i2f-extension/i2f-extension-all` 聚合依赖（229 行）

## 依赖

| 依赖 | 版本 | 作用域 | 说明 |
| --- | --- | --- | --- |
| `net.sourceforge.tess4j:tess4j` | 4.5.1（模块内硬编码） | provided | Tesseract 的 JNA 桥接库，含 Windows/Linux 本地库分发 |
| `i2f.turbo:i2f-std-const` | - | compile | 仅用 `StdConst.RUNTIME_PERSIST_DIR` 拼接训练数据目录 |
| `i2f.turbo:i2f-io-file` | - | compile | **源码零使用**（依赖冗余） |
| `org.projectlombok:lombok` | - | compile | **源码零使用**（无任何 lombok 注解，依赖冗余） |

调用方需自行引入 tess4j（provided 不入产物）；模块 API 签名直接透出 `Tesseract` / `TesseractException` 原生类型，与 tess4j 强耦合。

## 架构设计

```mermaid
flowchart TB
    subgraph 调用入口["recognize 三入口（全静态）"]
        A["recognize(InputStream)"] -->|ImageIO.read| B["recognize(BufferedImage)"]
        C["recognize(File)"] -->|tess4j doOCR(File)| D["Tesseract.doOCR"]
        B -->|tess4j doOCR(BufferedImage)| D
    end
    subgraph 实例构建["getTesseract(lang) 实例构建"]
        E["目录检查：./runtime/persist/tesseract/ocr"] -->|不存在| F["mkdirs() + 抛引导异常<br/>提示下载 *.traineddata"]
        E -->|存在| G["new Tesseract()<br/>setDatapath + setLanguage"]
        G --> D
    end
    D -.->|datapath| H["<目录>/chi_sim.traineddata 等<br/>需用户自备"]
```

- **实例构建链**：`getDefaultTesseract()` 固定取 `LANGUAGES[0]`（`chi_sim`）→ `getTesseract(lang)`：目录存在则 `new Tesseract()` + `setDatapath(绝对路径)` + `setLanguage(lang)`；目录不存在则 `mkdirs()` 后抛 `TesseractException`，异常 message 携带下载地址常量 `TRAINED_DATA_DOWNLOAD_URL`（`https://github.com/tesseract-ocr/tessdata`）。
- **识别链**：`InputStream` 重载经 `ImageIO.read` 解码为 `BufferedImage` 后走内存路径；`File` 重载直接交给 `tesseract.doOCR(File)`；两者每次调用都重新构建 Tesseract 实例，无实例缓存或复用。

## 设计目的

- 以最小代价把 tess4j 的 OCR 能力收拢为免配置的静态工具入口：调用方只面对 `recognize(...)` 三重载，不接触 Tesseract 的 datapath/语言装配细节。
- 训练数据不放仓库、不提供下载器，改用「首次调用即抛引导异常」的约定：目录位置、后缀名（`.traineddata`）、下载 URL 全部以常量暴露（`TRAINED_DATA_FILE` / `TRAINED_DATA_SUFFIX` / `TRAINED_DATA_DOWNLOAD_URL` / `LANGUAGES`），引导信息随异常 message 传递。
- 延续 i2f 运行时持久目录约定（`StdConst.RUNTIME_PERSIST_DIR` = `runtime/persist`），训练数据与其它运行期资产统一落在 `./runtime/persist/tesseract/ocr`。

## 功能清单

| 功能 | API | 说明 |
| --- | --- | --- |
| 默认实例 | `getDefaultTesseract()` | 固定 `chi_sim` 语言的 Tesseract 构建器 |
| 指定语言实例 | `getTesseract(String lang)` | datapath 固定、语言可指定；目录不存在时抛引导异常 |
| 流识别 | `recognize(InputStream)` | `ImageIO.read` 解码后识别 |
| 图像识别 | `recognize(BufferedImage)` | 直接识别内存图像 |
| 文件识别 | `recognize(File)` | 交给 tess4j `doOCR(File)` |
| 约定常量 | `TRAINED_DATA_DOWNLOAD_URL` / `TRAINED_DATA_FILE` / `TRAINED_DATA_SUFFIX` / `LANGUAGES` | 训练数据下载地址 / 目录（`./runtime/persist/tesseract/ocr`）/ 后缀 / 内置语言清单（chi_sim、chi_tra、eng） |

## 使用示例

```java
// 1) 首次使用：下载训练数据放入 ./runtime/persist/tesseract/ocr
//    https://github.com/tesseract-ocr/tessdata
//    chi_sim.traineddata / eng.traineddata ...
// 2) 引入 tess4j 依赖（模块为 provided，需调用方自带）
```

```java
// 文件识别（默认 chi_sim）
String text = OcrTesseractProvider.recognize(new File("./tmp.png"));
System.out.println(text);
```

```java
// 流识别（如从上传接口）
try (InputStream in = new FileInputStream("./tmp.png")) {
    String text = OcrTesseractProvider.recognize(in);
}
```

```java
// 指定语言的 Tesseract 实例（可进一步自配 PSM/OEM 等 tess4j 原生选项）
Tesseract t = OcrTesseractProvider.getTesseract("eng");
String text = t.doOCR(new File("./tmp.png"));
```

```java
// 内存图像识别
BufferedImage img = ImageIO.read(new File("./tmp.png"));
String text = OcrTesseractProvider.recognize(img);
```

## 特性总结

- **零配置入口**：三重载静态方法开箱即用，datapath/语言装配细节内聚在 `getTesseract`。
- **自备训练数据引导**：目录 + 后缀 + 下载地址三常量约定，首次调用异常即引导；不内置下载器、不打包训练文件。
- **运行时持久目录约定**：训练数据落位与 i2f 全局 `runtime/persist` 资产布局一致。
- **原生类型直通**：直接返回/抛出 tess4j 的 `Tesseract` / `TesseractException`，调用方可无缝使用 tess4j 全部原生配置能力（如 PSM/OEM），但也被 tess4j 版本绑定。
- **每次新建实例**：`recognize` 每调用一次即构建一个 Tesseract 实例，天然规避 Tesseract 非线程安全问题，代价是重复构建开销。

## 已知问题（静态识别，未实证）

1. **首次调用引导异常是一次性的**：目录不存在时 `mkdirs()` 已创建空目录再抛异常；第二次调用目录已存在，直接返回 Tesseract 实例——若用户尚未放入 `*.traineddata`，错误降级为 tess4j 内部报错，引导提示不再出现。
2. **`ImageIO.read` 返回 null 未判空**：`recognize(InputStream)` 对不支持/损坏的图像流会得到 null，随后 `doOCR((BufferedImage) null)` 在 tess4j 内部 NPE，无法定位是输入问题。
3. **`mkdirs()` 返回值未检查**：目录创建失败（权限、同名文件占位等）时静默继续 `setDatapath`，错误延迟到识别阶段。
4. **训练文件存在性不校验**：`setLanguage(lang)` 不检查 `<dir>/<lang>.traineddata` 是否存在，语言写错或文件缺失时错误由本地 Tesseract 输出呈现，难以定位；`LANGUAGES` 数组仅用于取 `[0]`，无「列出可用语言」API。
5. **实例无复用**：每次识别重建 Tesseract（JNA 本地库绑定级开销）；高频识别场景无缓存/复用支持，`getDefaultTesseract` 固定 `chi_sim` 硬编码。
6. **无任何 tess4j 高级配置面**：PSM 页面分割模式、OEM 引擎模式、识别超时、字符白名单、图像预处理（缩放/二值化）均未暴露，仅能借 `getTesseract` 返回的原生实例自行配置。
7. **异常 message 可能为 null**：`new TesseractException(e.getMessage(), e)`——`IOException` 无 message 时引导信息缺失（虽有 cause 兜底）。
8. **相对路径锚定工作目录**：`TRAINED_DATA_FILE = "./" + RUNTIME_PERSIST_DIR + "/tesseract/ocr"` 依赖 JVM `user.dir`，`./` 前缀冗余；分隔符用 `/` 未用 `File.separator`，跨工作目录/多实例部署时训练数据位置漂移。
9. **依赖冗余**：`lombok` 与 `i2f-io-file` 声明于 pom 但源码零使用，依赖面虚胖且误导使用者。
10. **类名契约语义落空**：`*Provider` 后缀暗示契约实现，但类不实现任何接口，纯静态工具——无法以实例注入/替换，也无法参与 i2f 的 Provider 体系。
11. **API 与 tess4j 强耦合**：方法签名直接透出 `Tesseract`/`TesseractException`，tess4j 升级（4.5.1 硬编码于模块 pom，未上提版本管理）需同步调整调用方。
12. **`doOCR` 返回值契约未声明**：无文本时 tess4j 行为（空串/null）未在 API 层归一，调用方需自行判空。
13. 风格类：`recognize` 中 `String ret = ...; return ret;` 冗余临时变量；每次调用重复 `File` 构建。
14. 测试 `TestOcrTesseract` 为 main 型手工测试（依赖仓库根 `./tmp.png`），非 JUnit，无法进入 CI。

## 生态位置（消费方）

- 仓库内**无源码级消费方**：仅 `i2f-extension-all` 聚合打包，测试类自引用；属「按需引入」的独立扩展。
- 与 i2f 其它 OCR 能力无横向集成（无共享 OCR 契约接口），后续若引入契约化 OCR Provider 体系，本类需改造为实现类。
