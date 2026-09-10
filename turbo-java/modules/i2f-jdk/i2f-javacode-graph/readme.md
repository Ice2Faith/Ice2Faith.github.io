# i2f-javacode-graph — Java 代码关系图解析与 ECharts 可视化

> **Java 代码结构图生成工具**（14 源文件、约 1043 行）：以 `Class` 对象为输入，经「反射解析 → 关系图扁平化 → ECharts 数据转换」三步管线，产出可直接喂给 ECharts graph 组件的 `categories/nodes/links` 数据结构，用于类关系可视化、代码结构分析；演示类注释指明输出 JSON 可用配套前端页面 `i2f-turbo-web/tools/echarts/echarts-graph.html` 预览。

## 一、模块定位与三步管线

本模块核心价值是把「编译后的 Java 类世界」变成「可视化关系图」：给定一批根 `Class`，递归反射出它们依赖的类/接口/字段/方法/构造器/注解/泛型参数节点，再拍平为「节点表 + 关系边」，最后转换为 ECharts graph 的索引化数据。

```
Class[] 根类
   │
   ▼ ① JavaCodeNodeResolver（560 行）
   │   反射递归解析（Class/Type/Field/Method/Constructor/Annotation）
   │   · nodeMap 签名去重（支持循环引用）
   │   · 六级过滤器（类/字段/方法/构造器/注解 + dropObject）
   │   · withDefault() 默认配置一键装配
   ▼
List<JavaCodeNode> 节点树
   │
   ▼ ② JavaCodeRelationGraphConverter（151 行）
   │   逐节点按「槽位」拍平：realType/fields/methods/constructors/
   │   superClass/interfaces/annotations/parameters/returnType/
   │   exceptions/genericParameters（11 种槽位）
   │   产出：Map<signature, JavaCodeMeta> 节点表 + List<JavaCodeRelation> 关系边
   ▼
JavaCodeRelationGraph 关系图
   │
   ▼ ③ JavaCodeRelationEchartsGraphConverter（70 行）
   │   categories=12 类节点类型（索引=枚举序号）
   │   nodes=节点（id=signature，category=节点类型索引）
   │   links=关系边（source/target=节点索引，value=关系类型名）
   ▼
JavaCodeEchartsGraph → Json2.toJson(...) → echarts-graph.html 预览
```

```mermaid
flowchart LR
    CLS["Class 根类集合"] --> R["JavaCodeNodeResolver<br/>反射解析 · nodeMap 去重 · 过滤器"]
    R -->|"List&lt;JavaCodeNode&gt;"| G["JavaCodeRelationGraphConverter<br/>11 槽位拍平"]
    G -->|"JavaCodeRelationGraph"| E["JavaCodeRelationEchartsGraphConverter<br/>索引化"]
    E -->|"JavaCodeEchartsGraph"| WEB["echarts-graph.html<br/>前端可视化"]
```

## 二、依赖关系

| 依赖 | 作用 | 真实性 |
|------|------|--------|
| `org.projectlombok:lombok` | 9 个数据类 `@Data` 生成 getter/setter | 真实使用 |
| `i2f.turbo:i2f-reflect` | `ReflectResolver.isJdkClas` JDK 类判定（1 处） | 真实使用 |
| `i2f.turbo:i2f-serialize-impl` | `Json2.toJson` 序列化（仅演示类 `TestJavaCode`） | 真实使用 |
| `i2f.turbo:i2f-typeof` | `TypeOf` / `TypeToken` / `TypeNode` 泛型建模 | **隐式传递依赖**（POM 未声明，经 `i2f-reflect` 带入） |

> **POM 完整性缺陷**：解析器核心逻辑（`isGenericType`/`hasGenericType` 判分支、`getFullGenericType` 建模泛型、`TypeNode` 承载类型树）全部来自 `i2f-typeof`，但本模块 POM 只声明了 `i2f-reflect`——依赖是经传递路径获得的。一旦上游调整依赖树，本模块立即编译失败，应显式补声明。本模块无其它三方运行期依赖，全部代码在 `src/main`、零测试。

## 三、包结构（4 包 / 14 文件 / 约 1043 行）

| 包 | 文件数 | 职责 |
|----|--------|------|
| `i2f.javacode.graph` | 3 | 解析器 + 两级转换器（核心） |
| `i2f.javacode.graph.data` | 6 | 节点/关系数据模型 + 双枚举 |
| `i2f.javacode.graph.data.echcarts` | 4 | ECharts graph 数据模型（**包名 `echcarts` 系 `echarts` 拼写错误**，已成既定 API） |
| `i2f.javacode.graph.test` | 1 | 演示类 `TestJavaCode`（位于 main 源码集，会随制品打包） |

## 四、类结构总览

### 4.1 主流程三件套

| 类 | 行数 | 职责 |
|----|------|------|
| `JavaCodeNodeResolver` | 560 | 反射解析核心：7 个配置字段（`nodeMap`/`dropObject`/4 个过滤器 + `annotationFilter`）、`withDefault()`、10 个 `parse` 重载（`Collection`/`Type`/`TypeNode`/`Class`/`Field`/`Method`/`Constructor`/`Annotation`） |
| `JavaCodeRelationGraphConverter` | 151 | 节点树 → 关系图：`resolve(node)` 按 11 槽位生成 `JavaCodeRelation` 边，节点表存 `copyMeta()` 副本（轻量 meta，不含子树），签名 `containsKey` 防重入（支持环路） |
| `JavaCodeRelationEchartsGraphConverter` | 70 | 关系图 → ECharts：categories 全量 12 类、nodes/links 建立索引映射，`symbolSize=20`、`value/x/y=0` 硬编码待前端布局 |

### 4.2 数据模型（`data` + `data.echcarts`）

| 类 | 行数 | 职责 |
|----|------|------|
| `JavaCodeMeta` | 31 | 节点元信息基类：`nodeType`/`signature`/`name`/`type`（`Type`）+ `copyMeta()` 浅拷贝 |
| `JavaCodeNode` | 26 | 继承 `JavaCodeMeta`，挂 11 个槽位：`realType`/`fields`/`methods`/`constructors`/`superClass`/`interfaces`/`annotations`/`parameters`/`returnType`/`exceptions`/`genericParameters` |
| `JavaCodeRelation` | 15 | 关系边：`startSignature`/`endSignature`/`relationType` |
| `JavaCodeRelationGraph` | 19 | 关系图：`Map<signature, JavaCodeMeta> nodeMap` + `List<JavaCodeRelation> relations` |
| `JavaNodeType` | 37 | 节点类型枚举（12 值，code+text） |
| `JavaRelationType` | 37 | 关系类型枚举（11 值，code+text） |
| `EchartsGraphCategories` / `EchartsGraphLinks` / `EchartsGraphNodes` / `JavaCodeEchartsGraph` | 13/15/19/18 | ECharts 数据四件套：分类（仅 name）、边（source/target/value）、节点（category/id/name/symbolSize/value/x/y）、总装 |

## 五、核心机制详解

### 5.1 解析器：签名去重 + 过滤器 + JDK 剪枝

**签名规则**（`nodeMap` 的主键，决定图去重粒度）：

| 节点来源 | 签名格式 |
|----------|----------|
| 类/接口/父类（`parse(Class)`） | `clazz.getName()` |
| 泛型实体（`parse(TypeNode)`） | `typeNode.fullName()`（如 `java.util.List<java.lang.String>`） |
| 字段 | `声明类全名.字段名` |
| 方法 | `声明类全名.方法名() -> ` + `method.toGenericString()` |
| 构造器 | `声明类全名.<init>() -> ` + `constructor.toGenericString()` |
| 注解 | 注解类型全限定名 |

**六级过滤器**（均为 `Predicate`，`null` 表示不过滤）：

- `defaultClassFilter`：排除 `null`、匿名类、非 public 类（对内部类/包私有类是激进过滤）
- `defaultFieldFiler`：排除 `transient` 与 `static final`（枚举常量等）
- `defaultMethodFilter`：排除 `private` 与 `lambda$` 前缀方法（**未排除 bridge/synthetic 方法**）
- `defaultConstructorFilter`：排除 `private` 构造器
- `annotationFilter`：默认 `null`（注解全保留）
- `dropObject`：排除 `Object` 节点（`withDefault()` 置 `true`）

**JDK 剪枝三处**：JDK 类不展开成员（字段/方法/构造器/注解）；`Object` 节点不再向上解析；「JDK 类且无泛型父类/接口」时提前返回——但由于上游 `TypeOf.isGenericType` 的宽松判定（见缺陷 3），第三处剪枝实际从不生效。

**循环引用安全**：解析阶段 `nodeMap` 先建节点再递归（`parse(Class)`），或先递归 realType 再回填（`parse(TypeNode)`）；转换阶段 `resolve()` 以 `nodeMap.containsKey` 防重入。因此 `A → B → A` 型互相引用不会死循环。

### 5.2 节点类型 vs 关系类型双枚举

| JavaNodeType（12） | 含义 | 对应 JavaRelationType（11） |
|--------------------|------|------------------------------|
| `CLASS` / `FIELD` / `METHOD` / `CONSTRUCTOR` | 类/字段/方法/构造器 | 无 `CLASS`（类自身即节点）；`FIELD`/`METHOD`/`CONSTRUCTOR` 同名对应 |
| `INTERFACE` / `SUPER` | 接口/父类槽位 | `INTERFACE` / `SUPER` |
| `ANNOTATION` / `PARAMETER` / `RETURN` / `EXCEPTION` | 注解/参数/返回/异常 | 同名对应 |
| `TYPE` | 字段泛型类型中间节点（`parse(TypeNode)` 的 `TYPE`） | 无 `TYPE` |
| `GENERIC` | 泛型参数节点 | `GENERIC` |

两者差集：关系枚举比节点枚举少 `{CLASS, TYPE}`——节点类型用于 ECharts categories 着色分类，关系类型用于边的 `value` 标注。

### 5.3 泛型类型建模（TypeNode 路径）

Java 反射的 `Type` 体系（`Class`/`ParameterizedType`/`WildcardType`…）先经 `TypeToken.getFullGenericType` 折叠为 `TypeNode` 树（`type` + `args` 递归），再由 `parse(TypeNode, ...)` 建模：

- `signature = fullName()`：泛型类型产出 `java.util.List<java.lang.String>` 这样的完整签名，与原始类节点（`java.util.List`）**区分**
- `realType`：指向原始类（`rawType`）节点，转换期生成 `REAL` 关系边连接两者
- 参数递归：`args` 逐项解析为 `GENERIC` 节点挂在 `genericParameters` 槽
- `WildcardType`（`? extends X`）被上游归一为 `Object`；`GenericArrayType`/`TypeVariable` 上游返回 `null`，本模块 `parse(TypeNode)` 有 `null` 检查（静默丢弃，不 NPE）

> 例外：**无泛型参数**的引用类型（绝大多数字段/父类）经 TypeNode 路径后 `fullName() == getName()`，与原始类节点同签名，触发「同签名双节点」与 REAL 自环问题（见缺陷 3）。

### 5.4 ECharts 数据转换细节

- `categories`：`JavaNodeType.values()` 全量 12 项按序生成，节点归属用 `categoriesIndexMap.get(nodeType)` 换算索引
- `nodes`：`id = signature`（全限定名，可直接作为前端筛选键）、`name = meta.name`（简单名）
- `links`：`source/target` 用**节点数组索引**（而非 id）、`value = relationType.name()`（如 `FIELD`/`SUPER`）
- 布局字段（`x`/`y`/`symbolSize`/`value`）为常量占位，交由 ECharts `force` 布局运行时计算

## 六、使用示例

### 6.1 完整三步管线（演示类 `TestJavaCode` 主线）

```java
// 1. 反射解析：Class → 节点树（withDefault 一键装配默认过滤器）
List<JavaCodeNode> nodes = new JavaCodeNodeResolver()
        .withDefault()
        .parse(Arrays.asList(
                JavaCodeNodeResolver.class,
                JavaCodeRelationEchartsGraphConverter.class,
                JavaCodeRelationGraphConverter.class));

// 2. 扁平化：节点树 → 关系图（节点表 + 关系边）
JavaCodeRelationGraph graph = JavaCodeRelationGraphConverter.convert(nodes);
// System.out.println(Json2.toJson(graph));   // 关系图本身也可直接输出

// 3. 转换：关系图 → ECharts graph 数据
JavaCodeEchartsGraph echarts = JavaCodeRelationEchartsGraphConverter.convert(graph);

// 4. 输出 JSON（Json2 来自 i2f-serialize-impl）
System.out.println(Json2.toJson(echarts));
// 将 JSON 粘贴到 i2f-turbo-web/tools/echarts/echarts-graph.html 即可可视化
```

### 6.2 自定义过滤器（需继承，字段无 setter）

`JavaCodeNodeResolver` 的 7 个配置字段全为 `protected` 且类未标注 Lombok 注解、无 setter，外部包**无法直接定制**，标准途径是继承覆写：

```java
public class MyResolver extends JavaCodeNodeResolver {
    public MyResolver() {
        this.dropObject = true;                                              // 丢弃 Object
        this.classFilter = clazz -> !clazz.getName().startsWith("java.");    // 仅保留业务类
        this.methodFilter = method -> Modifier.isPublic(method.getModifiers());
        this.annotationFilter = null;                                        // 注解保留
    }
}

List<JavaCodeNode> nodes = new MyResolver().parse(Arrays.asList(MyService.class));
```

### 6.3 只解析单个类 / 只转关系图

```java
// 单类解析（type 传 null 时按 CLASS 处理）
JavaCodeNode node = new JavaCodeNodeResolver().withDefault().parse(MyService.class, null);

// 只到关系图（不转 ECharts），自行消费节点表与边
JavaCodeRelationGraph graph = JavaCodeRelationGraphConverter.convert(Arrays.asList(node));
graph.getNodeMap();   // Map<signature, JavaCodeMeta>
graph.getRelations(); // List<JavaCodeRelation>
```

## 七、消费关系与注册链路

**全仓零外部代码级消费者**（`import i2f.javacode.graph` 仅出现在模块自身 4 个文件）。POM 注册 3 处：

| 位置 | 用途 |
|------|------|
| `i2f-jdk/pom.xml` L94 | 模块聚合（`i2f-iterator` 之后） |
| `i2f-jdk-all/pom.xml` L325 | 全仓聚合引入（fat-jar 分发） |
| 根 `pom.xml` L506 | `dependencyManagement` 版本托管 |

反向记录：`i2f-typeof` 的文档已将本模块登记为其 `TypeOf` 消费方之一（与 `i2f-ai-std`/`i2f-comparator`/`i2f-http-proxy` 等同列）。

## 八、已知缺陷与注意事项

### 高危

1. **方法/构造器异常类型错加至 `parameters` 列表**（`JavaCodeNodeResolver.parse(Method)`/`parse(Constructor)` 的 `getExceptionTypes()` 循环）：应为 `node.getExceptions().add(...)`，实际写成 `node.getParameters().add(...)`。后果：`exceptions` 槽位**永远为空** → 转换器中 `EXCEPTION` 关系永不产生；异常类型混入参数槽，在图中以 `PARAMETER` 关系边出现（语义错位）。
2. **`parse(Annotation)` 递归传参错误产生节点自引用**：遍历注解类型自身的注解时，循环变量是 `nextAnnotation` 却递归 `parse(annotation, ...)`（原始注解）。由于签名相同且节点已在 `nodeMap` 缓存，递归直接返回自身 → `node.getAnnotations().add(node)` 自环；且 `annotationFilter.test(nextAnnotation)` 的过滤对象与实际解析对象不一致。触发条件：注解类型上标有自定义 RUNTIME 注解且不带 `@Retention`/`@Target` 等（否则被 meta-annotation 拦截分支提前 return）。

### 中等

3. **上游 `isGenericType` 宽松判定引发连锁效应**：`TypeOf.isGenericType` 以 `Class.class.equals(type)` 判断（正确写法应为 `type instanceof Class`），对任意普通 `Class` 实例恒返回 `true`。连锁后果：① 解析器中父类/接口/字段的「非泛型处理分支」全部成为死代码，所有类型引用统一走 TypeNode 路径；② 「JDK 类且无泛型父类/接口」剪枝不生效，JDK 类会展开全部接口链；③ 无泛型类型产生**同签名双节点**（TYPE 节点与 CLASS 节点），转换期后者被签名去重挡下，出现 `REAL` 自环边（`start == end`），且被挡 CLASS 节点的子结构边（如 JDK 类的接口关系）丢失——具体表现取决解析顺序（先到先得的节点类型占位）。
4. **`parse(Class)` 超类过滤 `doNext` 条件写反**（`if (classFilter == null || classFilter.test(superclass)) { doNext = true; }` 恒真死代码）：过滤失败时未置 `false`，本意「父类不过滤则不解析」失效；所幸被 `parse()` 内部的二次过滤兜底，且因缺陷 3 该分支实际不可达，无现网影响。
5. **`parse(TypeNode)` 的 `nodeMap.put` 滞后于 `realType` 递归**：递归泛型（如 `class Node<T> { Node<T> next; }`）场景下同签名会创建两个节点对象，后 `put` 者覆盖先 `put` 者，字段引用保留被覆盖对象（悬挂引用/图分裂）。修复：将 `put` 提前到 `realType` 递归之前（与 `parse(Class)` 一致）。
6. **配置字段无 setter**：7 个配置字段全 `protected`、类无 Lombok 注解码，外部包只能通过 `withDefault()`（全默认）或继承覆写定制；作为「过滤器框架」的公开 API 缺少必要的可变入口（或 Builder），可用性受限。

### 低危

7. **`parse(Type)` 的 `Class.class.equals(genType)` 判定错误**：应为 `genType instanceof Class`；普通 `Class` 实例会绕过首个分支直达 TypeToken（功能侥幸可用），仅当恰传 `Class.class` 对象本身才进入——分支语义与作者意图错位（与缺陷 3 同源写法）。
8. **ECharts links 自动拆箱 NPE 风险**：`vo.setSource(nodeIndexMap.get(relation.getStartSignature()))` 以 `Integer → int` 拆箱，若关系边的签名不在节点表（两级转换器可被独立调用、状态不一致），null 拆箱直接 NPE；建议 `getOrDefault(-1)` 或校验。
9. **bridge/synthetic 方法未过滤**：`defaultMethodFilter` 只排除 `private` 与 `lambda$` 前缀，泛型桥接方法（`Modifier.isBridge()`）会生成语义重复的方法节点；`toGenericString()` 签名不同但业务等价。
10. **注解节点 `name` 用全限定名**（`annotation.annotationType().getName()`），与其余节点的 `getSimpleName()` 风格不一致，前端展示会更长。
11. **解析器实例状态跨调用共享**：`nodeMap` 无重置机制，同一实例多次 `parse` 会复用/污染节点（签名命中直接返回旧节点对象，`nodeType` 先到先得）；如需干净解析应每次 `new`。
12. **工程组织瑕疵**：包名 `echcarts` 拼写错误；演示类 `TestJavaCode` 位于 `src/main/java`（随制品打包，含 main 方法与注释掉的调试代码）；`JavaCodeRelationGraphConverter` 11 个槽位块近乎复制粘贴（可抽象为「槽位表 + 统一遍历」）；**零测试覆盖**——叠加上述解析器缺陷，任何修复都缺乏回归保障。

## 九、总结

`i2f-javacode-graph` 是一个「小而专」的代码可视化基础模块：三步管线职责清晰（解析 → 拍平 → 索引化），节点签名去重天然支持循环引用，`withDefault()` + 双枚举分类让最简用法一行到位。但模块处于「实验性工具」成熟度：两个高危解析缺陷（异常槽位错位、注解自引用）直接影响图的语义正确性；`isGenericType` 联动问题使「过滤器/非泛型分支/JDK 剪枝」多处设计意图落空，并引入 REAL 自环与子结构丢失；POM 隐式依赖 `i2f-typeof` 与零测试进一步放大了维护风险。使用建议：单类/小规模图分析可放心用于可视化展示，但不要依赖 `EXCEPTION` 关系与无泛型类型的 REAL 边语义；修复时应优先补 `exceptions` 槽位写入、注解递归传参、`put` 时序三处，并为解析器补最小回归测试。
