# i2f-annotations-core

> i2f 注解核心库，收录 67 个与运行时框架无关、纯语义的**标记/描述型注解**，按用途分为 base（基础语义）、check（校验规则）、doc（文档元信息）、env（运行环境）、except（异常声明）、format（格式）、naming（命名别名）、resources（资源生命周期）、value（取值约束）、version（版本/生命周期）十大类。所有注解统一为 `RUNTIME` 保留、`@Documented`、宽 `@Target`，并通过模块自身的 `@Comment` 实现「注解自描述」，可被 `i2f-reflect`、代码生成、文档生成、校验等上层能力反射读取。

## 模块路径

- `i2f-jdk/i2f-annotations-core`

## 模块依赖

| GroupId | ArtifactId | Scope | Optional | 说明 |
|---------|-----------|-------|----------|------|
| — | — | — | — | 无 Maven 依赖，仅依赖 JDK 标准注解类型（`java.lang.annotation.*`） |

> 本模块是**零依赖叶子模块**：`pom.xml` 无 `<dependencies>`，全部注解仅建立在 JDK `java.lang.annotation` 之上，且互相之间只在包内引用（如各注解引用同模块的 `@Comment`）。可被任意模块安全引入，不引入任何传递依赖。

## 模块设计

### 统一的注解骨架

模块内每个注解遵循完全一致的书写范式，这是它区别于零散自定义注解的核心设计：

```java
@Comment({            // ① 自描述：用本模块的 @Comment 说明用途（中文）
        "范围",
        "在指定的范围内",
        "值在min-max之间，这是闭区间，也就是包含最大最小值"
})
@Target({             // ② 宽目标：几乎可标注于任意元素
        ElementType.FIELD, ElementType.PARAMETER, ElementType.LOCAL_VARIABLE,
        ElementType.METHOD, ElementType.TYPE_PARAMETER, ElementType.TYPE,
        ElementType.ANNOTATION_TYPE, ElementType.CONSTRUCTOR,
        ElementType.PACKAGE, ElementType.TYPE_USE
})
@Retention(RetentionPolicy.RUNTIME)  // ③ 运行期保留，供反射读取
@Documented                            // ④ 进入 javadoc
// ⑤（可选）可重复：如 @Check 标注 @Repeatable(Checks.class)，本示例 @Range 不可重复
public @interface Range {
    String min();
    String max();
    String message() default "";
}
```

- **`RUNTIME` + 宽 `@Target`**：保证任何反射型工具（`i2f-reflect`、API/文档生成器、校验引擎）都能在运行期读到，且不限定标注位置。
- **`@Comment` 自描述**：注解携带机器可读的中文说明，文档/代码生成器可据此产出描述文本，实现「注解即文档」。
- **`@Repeatable` + 容器**：需要多次标注的注解（`Check`/`Match`/`NotMatch`/`Comment`/`Description`/`Format`/`Alias`/`Recommend`/`Reference`）都配套一个容器注解（`Checks`/`Matches`/`NotMatches`/`Comments`/`Descriptions`/`Formats`/`Aliases`/`Recommends`/`References`）。
- **成员即语义**：注解属性精简到位，如 `Refer` 用 `Class<?> value()` + `String like()` 表达「值来源于某类的哪些特征常量」，`Types` 用 `Class<?>[] value()` 限定允许类型。

### 十大分类与包结构

```
i2f.annotations.core
├── base       基础语义标记（15）  Const / NotNull / Nullable / NotEmpty / ReadOnly / WriteOnly
│                                    / ParamIn / ParamOut / Returned / Returns / Unsafe / Unchecked
│                                    / Refer / Types / Tag
├── check      校验规则（11）      Check(+Checks) / Match(+Matches) / NotMatch(+NotMatches)
│                                    / Size / NotSize / NotRange / NotIn / Validate
├── doc        文档元信息（10）    Comment(+Comments) / Description(+Descriptions) / Author
│                                    / CreateTime / Creator / Updater / Email / Link
├── env        运行环境（7）       Os / Jdk / Jre / Arch / Platform / Vendor / Dependence
├── except     异常声明（2）       Exceptions / NoExcept
├── format     格式约束（2）       Format(+Formats)
├── naming     命名别名（3）       Name / Alias(+Aliases)
├── resources  资源生命周期（2）   Closed / Unclosed
├── value      取值约束（5）       Default / Range / Min / Max / In
└── version    版本/生命周期（10） Version / Support / Experimental / Discarded / Outdated
                                     / Cautious / Recommend(+Recommends) / Reference(+References)
```

### 复合注解：以 `@Creator` 为例

`doc` 类注解可组合成结构化元信息。`@Creator` 聚合了 `Author`、`CreateTime` 及可选的 `Comments`/`Descriptions`/`Email`/`Link`，一个注解即可完整描述「谁、何时、附注、联系方式、链接」：

```java
@Creator(
    value = @Author("Ice2Faith"),
    time  = @CreateTime("2024-02-21"),
    email = @Email("dev@example.com")
)
```

## 模块目的

- 沉淀一套**框架无关、语义明确**的通用注解词表，避免各模块重复造轮子式地定义 `@NotNull`/`@Comment`/`@Range` 等。
- 以「注解自描述 + RUNTIME 可读」为契约，为反射解析、API 文档生成、代码生成、参数校验等横切能力提供统一的元数据来源。
- 保持零依赖，使其可下沉到最底层被任意模块安全引用。

## 模块功能

| 分类 | 代表注解 | 提供的能力 |
|------|----------|-----------|
| base | `@Const` `@Nullable` `@ReadOnly` `@Refer` `@Types` | 常量/可空/读写方向/引用来源/类型限定等语义标记 |
| check | `@Check` `@Match` `@Size` `@NotRange` `@Validate` | 声明式校验规则（表达式、正则、尺寸、枚举） |
| doc | `@Comment` `@Description` `@Creator` `@Link` | 运行期可读的文档与作者/来源元信息 |
| env | `@Os` `@Jdk` `@Arch` `@Platform` `@Dependence` | 标注目标运行环境/依赖前提 |
| except | `@Exceptions` `@NoExcept` | 声明未列入 throws 的实际可能异常 |
| format | `@Format` | 取值格式约束（如日期、数字格式） |
| naming | `@Name` `@Alias` | 元素的展示名与别名映射 |
| resources | `@Closed` `@Unclosed` | 资源关闭责任/生命周期标记 |
| value | `@Range` `@Min` `@Max` `@Default` `@In` | 数值/集合取值范围与默认值 |
| version | `@Version` `@Experimental` `@Discarded` `@Recommend` | 版本、实验性、废弃、推荐等生命周期信息 |

## 模块主要使用方法

### 直接标注

```java
import i2f.annotations.core.base.*;
import i2f.annotations.core.value.Range;
import i2f.annotations.core.check.Match;
import i2f.annotations.core.version.Experimental;

@Experimental
public class UserDto {

    @NotNull
    @Comment({"用户名", "登录账号，唯一"})
    private String username;

    @Range(min = "0", max = "150", message = "年龄越界")
    private Integer age;

    @Match("^[\\w.-]+@[\\w.-]+\\.\\w+$")
    private String email;

    @Refer(value = TypeConsts.class, like = "TYPE_*")
    private int type;
}
```

### 供反射/生成器消费

```java
// 上层（如 i2f-reflect、文档生成器）读取注解元数据
Range range = field.getAnnotation(Range.class);
if (range != null) {
    String min = range.min(), max = range.max();
}
// 读取注解自身的自描述文本
Comment self = Range.class.getAnnotation(Comment.class); // "范围" / "在指定的范围内" ...
```

### 可重复注解

```java
@Check("amount > 0")
@Check("currency != null")   // 编译期自动归入 @Checks 容器
private Order order;
```

### 注意事项

- 注解本身**不产生行为**，需由配套引擎（校验器、文档生成器、反射工具）读取并执行；本模块只定义契约。
- `@Target` 已含 `TYPE_USE`，可用于类型使用处；若只想在字段上使用，工具侧需自行甄别标注位置。
- 成员多以 `String` 表达数值边界（如 `@Range.min()`），由消费方按目标类型解析，避免注解属性无法表达泛型/精度。
- 带 `@Repeatable` 的注解其容器类型（`*s`）一般不直接使用，交给编译器合成。
- 与 `javax.annotation` / Jackson / Swagger 等第三方注解语义相近者（如 `@Name`/`@Alias`/`@Nullable`），在同一元素上并用时需注意各自的读取优先级，防止语义冲突。

## 模块特性总结

- **零依赖**：仅 `java.lang.annotation`，可下沉至最底层被任意模块引用。
- **自描述**：统一以 `@Comment` 携带中文说明，实现「注解即文档」，可被生成器读取。
- **一致的注解范式**：`RUNTIME` + `@Documented` + 宽 `@Target`，反射可达、位置不限。
- **十类语义词表**：base/check/doc/env/except/format/naming/resources/value/version 覆盖标记、约束、文档、生命周期等常见元数据需求。
- **可重复 + 容器**：`@Repeatable` 及其 `*s` 容器支持一处多次声明。
- **可复合**：如 `@Creator` 聚合 `@Author`/`@CreateTime`/`@Email`/`@Link` 形成结构化元信息。
- **契约与实现分离**：只定义语义，行为交由校验/文档/反射等上层引擎落地。
