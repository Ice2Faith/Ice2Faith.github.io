# i2f-spi-annotations

> SPI（Service Provider Interface）注解定义模块，提供 `@Spi` 标记注解，用于声明某个类是一组接口的服务提供者实现，配合构建期插件自动生成 `META-INF/services/` 服务描述文件。

## 模块路径

- `i2f-jdk/i2f-spi-annotations`

## 模块依赖

| GroupId | ArtifactId | Scope | Optional | 说明 |
|---------|-----------|-------|----------|------|
| — | — | — | — | 无内部依赖，仅依赖 JDK 标准注解类型（`java.lang.annotation.*`） |

> 本模块为纯注解（annotation-only）叶子模块，不依赖任何 i2f 内部模块，可被 `i2f-spi` 及任意业务模块安全引用，不会引入额外传递依赖。

## 模块设计

### 极简注解设计

模块仅包含一个注解 `@Spi`，其定义刻意保持最小面：

```java
@Documented
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface Spi {
    Class<?>[] value();
}
```

| 元注解 | 取值 | 设计意图 |
|--------|------|----------|
| `@Target` | `ElementType.TYPE` | 只能标注在类/接口/枚举上，标记「服务实现类」 |
| `@Retention` | `RetentionPolicy.RUNTIME` | 运行期保留，既支持构建期字节码扫描，也支持运行期反射读取 |
| `@Documented` | — | 注解会出现在生成的 Javadoc 中 |

### 属性语义

- `value()`：声明本实现类所「提供」的 SPI 接口数组。一个实现类可同时为多个接口提供服务，因此使用 `Class<?>[]`。

```java
@Spi({PaymentService.class, NotificationService.class})
public class AlipayServiceImpl implements PaymentService, NotificationService {
    // ...
}
```

### 与构建期插件的协作（设计约定）

`@Spi` 本身不产生任何运行期行为，它是一个「构建期契约标记」：

```mermaid
flowchart LR
    A["@Spi 标注的实现类"] -->|构建期扫描| B("i2f:spi Maven 插件")
    B -->|为每个 value() 接口| C["META-INF/services/&lt;接口全名&gt;"]
    C -->|运行期读取| D["java.util.ServiceLoader"]
    D --> E["i2f-spi / Spis.load(...)"]
```

> 说明：注解中 Javadoc 提到的 `i2f:spi` Maven 插件负责在编译阶段扫描被 `@Spi` 标注的类，并针对 `value()` 里声明的每一个接口生成对应的 `META-INF/services/` 描述文件（文件内容为实现类全名）。若不使用该插件，也可通过运行期的 `i2f-spi` 模块提供的 `Spis.makeSpiFile(...)` 手工生成描述文件。

## 模块目的

- 用「声明式注解」替代手写 `META-INF/services/` 配置文件，降低 SPI 服务注册的维护成本，避免接口全名与实现类全名的手工对齐错误。
- 作为零依赖的注解载体，可被广泛引用而不污染依赖树。

## 模块功能

- 提供 `@Spi` 注解，标记实现类及其所服务的接口集合。
- 作为构建期插件与运行期加载工具之间的公共契约。

## 模块主要使用方法

在需要作为 SPI 提供者的实现类上标注 `@Spi`，并在 `value()` 中列出其对外提供的接口：

```java
@Spi(i2f.spi.SpiComponent.class)
public class MyComponent implements i2f.spi.SpiComponent {
    // ...
}
```

注意事项：

- `value()` 中的接口应是 `ServiceLoader` 真正要加载的服务类型；标注错误的接口会导致运行期无法命中该实现。
- 注解仅定义契约，真正生成服务文件依赖构建期插件或 `i2f-spi` 的 `Spis.makeSpiFile(...)`。

## 模块特性总结

- 单注解、零内部依赖，作为 SPI 体系的标记契约层。
- `RUNTIME` 保留，兼容构建期扫描与运行期反射两种消费方式。
- `Class<?>[]` 支持「一个实现类同时服务多个接口」的多提供者场景。
- 与 `i2f-spi` 的运行期加载工具、构建期插件解耦配合，职责单一。
