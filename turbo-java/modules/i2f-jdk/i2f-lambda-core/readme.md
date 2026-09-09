# i2f-lambda-core

> 方法引用解析**内核**（lambda-core）。以一组必须 `extends Serializable` 的函数式接口（`IGetter`/`ISetter`/`IBuilder`）承接「**getter/setter 型方法引用**」（如 `SysUser::getUserName`、`SysUser::setUserName`、`Builder::withAge`），借助编译器为可序列化 lambda 生成的 `writeReplace()` → `java.lang.invoke.SerializedLambda`，反查出它**引用的类、方法名、字段名**，并进一步定位到真实的 `Class` / `Method` / `Field`。本模块刻意「保持功能最小化」——只针对 getter/setter 形状的方法引用，不处理任意方法/lambda 表达式体，是全仓库类型安全 API（`i2f-bql` 的 lambda 列寻址、`i2f-mutator` 的流式改值、`i2f-lambda` 的通用解析）共同依赖的底座。所有反射结果均落 `LruMap`（唯一内部依赖）缓存，线程安全。

## 模块路径

- `i2f-jdk/i2f-lambda-core`

## 模块依赖

| GroupId | ArtifactId | Scope | Optional | 说明 |
|---------|-----------|-------|----------|------|
| i2f.turbo | i2f-lru-map | compile | false | 提供 `i2f.lru.LruMap`——所有静态反射缓存的载体（`ReentrantLock` 保护的 LRU `LinkedHashMap`） |

> 本模块**零第三方依赖**，运行期构建于 JDK 反射与 `java.lang.invoke.SerializedLambda` 之上。`pom.xml` 仅一个 `<dependency>`（`i2f-lru-map`，版本由父 `i2f-jdk` 的 `dependencyManagement` 托管），build 块仅声明 `maven-assembly-plugin`（无源码，纯库打包）。

## 模块设计

### 包结构

```
i2f.lambda.core
├── Lambda          // 唯一门面类，全 public static，无实例状态
└── func
    ├── IGetter<R, V>    // @FunctionalInterface extends Serializable：R apply(V v)        —— 读取（取值为方法返回）
    ├── ISetter<T, V>    // @FunctionalInterface extends Serializable：void accept(T, V)    —— 写回（void setter）
    └── IBuilder<R, T, V>// @FunctionalInterface extends Serializable：R apply(T, V)        —— 链式 setter（返回 R）
```

三个函数式接口的**唯一关键约定是 `extends Serializable`**——只有可序列化的 lambda，编译器才会为其生成 `writeReplace()` 方法，`SerializedLambda` 才拿得到。普通 `java.util.function.*`（未实现 `Serializable`）的方法引用无法被解析，这正是本模块另立 `IGetter`/`ISetter`/`IBuilder` 而非复用 JDK 内置函数接口的情形之一。

### 核心机制：writeReplace → SerializedLambda

```mermaid
flowchart TD
    A["方法引用 SysUser::getUserName<br/>(须为 IGetter 等 Serializable 函数式类型)"] --> B["getSerializedLambda(fn)"]
    B --> B1["反射调用 fn.getClass()<br/>.getDeclaredMethod(\"writeReplace\")"]
    B1 --> B2["setAccessible + invoke<br/>(编译器为可序列化 lambda 生成)"]
    B2 --> C["SerializedLambda"]
    C --> D1["getImplClass() → 'com/x/SysUser'"]
    C --> D2["getImplMethodName() → 'getUserName'"]
    D1 --> E1["extractClassName：<br/>\\→/ → /→. 去 .class 首尾去点"]
    D2 --> E2["extractFieldName：<br/>剥 get/set/is/has/enable/with/build 前缀 + 首字母小写"]
    E1 --> F["ofClass → findClass → Class"]
    E2 --> G["ofField/ofGetter/ofSetter → 反射定位 Field / Method"]
```

`getSerializedLambda` 是整个模块的命门（源码注释「关键在于这个方法」）：它对 lambda 实例反射调用 `writeReplace`，拿到承载「实现类 / 方法名 / 方法签名」元信息的 `SerializedLambda`。包装方法有两个语义不同的变体：

- `getSerializedLambdaNullable(fn)`：吞异常返回 `null`（**真正静默**）。
- `getSerializedLambdaNoExcept(fn)`：捕获后**重新抛 `UnsupportedOperationException`**（命名含「NoExcept」但实际会抛，属命名瑕疵，静默版是上面的 `Nullable`）。

### 名称还原与反射定位（全部 LruMap 缓存）

| 静态缓存 | 容量 | 键 | 值 | 对应方法 |
|----------|------|----|----|----------|
| `CACHE_EXTRACT_CLASS_NAME` | 2048 | implClass | 类全名 | `extractClassName` |
| `CACHE_EXTRACT_FIELD_NAME` | 2048 | 方法名 | 字段名 | `extractFieldName` |
| `CACHE_CLASS` | 2048 | 类全名 | `Optional<Class>` | `findClass`（`Class.forName`→上下文 ClassLoader） |
| `CACHE_SETTER` | 4096 | `类#字段` | `Optional<Method>` | `getSetter` |
| `CACHE_GETTER` | 4096 | `类#字段` | `Optional<Method>` | `getGetter` |
| `CACHE_FIELD` | 4096 | `类#字段` | `Optional<Field>` | `getField` |

- **`getGetter(clazz, fieldName)`**：public、0 参、返回名等于 `fieldName` 或命中前缀 `get/is/has/enable` + 大驼峰字段名。
- **`getSetter(clazz, fieldName)`**：public、1 参、返回名等于 `fieldName` 或命中前缀 `set/with/enable/build` + 大驼峰字段名。
- **`getField(clazz, fieldName)`** 经 `findField`/`walkField`：按 `getFields()` → `getDeclaredFields()` → 递归父类（至 `Object` 停）的顺序查找匹配字段，用 `Predicate` 的返回布尔作「是否继续」信号。

### 分层 API：三类入口 × 多种入参形态

顶层提供**类型安全的重载**，让用户直接传方法引用即得 `Field`/`Method`：

```java
public static <R, V>    Field  getField(IGetter<R, V> getter);
public static <T, V>    Field  getField(ISetter<T, V> setter);
public static <R,T, V>  Field  getField(IBuilder<R, T, V> builder);
public static <R, V>    Method getGetter(IGetter<R, V> getter);
public static <T, V>    Method getSetter(ISetter<T, V> setter);
public static <R, T, V> Method getSetter(IBuilder<R, T, V> builder);
```

其下是一组 `ofXxx` 组合子，每个都对**入参形态**做伸缩：

- 以解析目标分：`ofClass` / `ofGetter` / `ofSetter` / `ofField` / `ofClassName` / `ofMethodName` / `ofFieldName`。
- 以入参形态分：`(Serializable)`（从方法引用现场解析）、`(SerializedLambda)`（已拿到 lambda 时跳过 `writeReplace`）、`(Class<?> bindClass, Serializable)`（**已知宿主类**，只用 lambda 取字段名，避免 `getImplClass` 推断）三组重载。

## 模块目的

- 把「**用字符串写死列名/属性名**」升级为「**用方法引用表达并类型安全地反查字段**」，让重构（改属性名）时编译期即暴露不一致。
- 用一个极小、零三方依赖的内核，统一「方法引用 → `Field`/`Method`/`Class`」这一底层能力，供上层 DSL（查询、赋值、元数据）复用，避免各处重复 `writeReplace` 反射样板。
- 通过 `LruMap` 缓存高频反射结果，使「每次拼 SQL / 每次改值都解析方法引用」的开销降到接近一次哈希查表。

## 模块功能

| 能力 | 代表方法 | 说明 |
|------|----------|------|
| 解析可序列化 lambda | `getSerializedLambda` / `getSerializedLambdaNullable` / `getSerializedLambdaNoExcept` | 反射 `writeReplace` 取 `SerializedLambda` |
| 取引用的类 | `ofClass` / `ofClassName` | 由 `getImplClass` 还原类名并 `findClass` |
| 取引用的方法名 | `ofMethodName` | 直接 `getImplMethodName` |
| 取引用字段名 | `ofFieldName` / `extractFieldName` | 剥 getter/setter/builder 前缀并小写首字母 |
| 定位 `Field` | `ofField` / `getField` / `findField` / `walkField` | 含父类向上遍历 |
| 定位 getter/setter `Method` | `ofGetter`/`getGetter`、`ofSetter`/`getSetter` | 按前缀 + 大驼峰匹配 |
| 类型安全入口 | `getField(IGetter/ISetter/IBuilder)` 等 | 直接传方法引用 |

## 模块主要使用方法

### 1. 方法引用 → 字段名 / Field（最典型）

```java
// IGetter<R,V> 形态承接 getter 方法引用
IGetter<SysUser, String> getter = SysUser::getUserName;
String fieldName = Lambda.ofFieldName(getter);   // -> "userName"
Field field      = Lambda.getField(getter);       // -> SysUser.userName 的 Field
Class<?> owner   = Lambda.ofClass(getter);        // -> SysUser.class
Method m         = Lambda.getGetter(getter);      // -> SysUser.getUserName()
```

### 2. setter / builder 方法引用

```java
ISetter<SysUser, String> setter = SysUser::setUserName;
Field f1 = Lambda.getField(setter);               // 定位到 userName 字段
Method s = Lambda.getSetter(setter);              // -> setUsername(String)

IBuilder<SysUser, SysUser, Integer> builder = SysUser::withAge;
Field f2 = Lambda.getField(builder);              // -> age 字段（with 前缀被剥离）
```

### 3. 已知宿主类时走 bindClass 重载

```java
// 只用方法引用取字段名，类由调用方给定，避免依赖 getImplClass 推断
Field f = Lambda.ofField(SysUser.class, (IGetter<SysUser, String>) SysUser::getUserName);
```

### 4. 函数式接口必须可序列化

```java
// 正确：使用本模块（或任何 extends Serializable）的函数式接口签名承接
Lambda.getField((IGetter<SysUser, String>) SysUser::getUserName);

// 失败：java.util.function.Function 未 extends Serializable，
//        writeReplace 不存在 -> getSerializedLambdaNullable 返回 null
```

**注意事项**

- **仅适用于「方法引用」且形状为 getter/setter/builder**：lambda 表达式体（如 `u -> u.getName()`）的 `getImplClass` 会指向** enclosing 类**而非 `SysUser`，`ofField` 结果不符合预期；本模块类注释明确「不针对其他类型的方法引用处理」。任意方法/签名级解析请用上层 `i2f-lambda` 的 `LambdaInflater`（配合 `i2f-reflect` 按签名匹配）。
- **前缀剥离按 `{get,set,is,has,enable,with,build}` 顺序、命中即止**：字段名本身以这些前缀子串开头时（如属性 `settings` 的引用 `getSettings`→正常，但直接 `setup` 之类会被误剥为 `up`）需谨慎；这也是它「只针对规范 getter/setter」的边界。
- **`getGetter`/`getSetter` 以 `getMethods()`（含继承的 public 方法）匹配**，不区分声明类；`getField` 才向父类遍历私有字段。
- 缓存键含 `Class#字段名`，`Class` 参与字符串拼接，跨 ClassLoader 场景下同名类可能被并入同一键——多 ClassLoader 隔离部署时留意。

## 模块特性总结

- **零三方依赖内核**：仅 `i2f-lru-map` 一个内部依赖，其余全为 JDK 反射 + `SerializedLambda`。
- **`writeReplace` 反解**：以可序列化 lambda 的编译器钩子取得实现类/方法名，是类型安全 API 的通用底层技巧。
- **三类函数式契约**：`IGetter`（读）/`ISetter`（写，void）/`IBuilder`（链式写，返回 R），全部 `extends Serializable`。
- **getter/setter/builder 全覆盖还原**：剥 7 种前缀还原字段名，再反射定位 `Class`/`Method`/`Field`。
- **全链路 LruMap 缓存**：名称还原、类查找、getter/setter/field 定位六张静态缓存，线程安全、有界。
- **API 分层伸缩**：类型安全入口 → `ofXxx`（`Serializable`/`SerializedLambda`/`bindClass` 三形态）→ 底层反射原语，逐层可复用。
- **刻意最小化**：只处理规范 getter/setter 方法引用；复杂/任意方法解析交给上层 `i2f-lambda`。

## 相关模块

- **下游消费者**（grep 验证）：`i2f-bql`（`core/lambda/Bql`、`core/bean/Bql` 的方法引用列寻址）、`i2f-mutator`（`Mutator` 的 `set`/`with` 方法引用赋值）、`i2f-lambda`（`LambdaInflater` 在其之上做签名级通用解析）、`i2f-jdk-all`（聚合引入）。
- **近邻区分**：`i2f-lambda`（`i2f.lambda`）= 通用/全签名 lambda 解析上层；本模块 `i2f-lambda-core` = getter/setter 专用最小内核。
