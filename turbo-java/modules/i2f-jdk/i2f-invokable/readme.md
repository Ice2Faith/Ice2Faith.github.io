# i2f-invokable

> **JDK 反射调用抽象层**——10 源文件约 381 行，纯 JDK + lombok，全 main 无测试。通过 `IInvokable`/`IMethod` 双层接口统一屏蔽 `Method.invoke()` 与 `Constructor.newInstance()` 的反射差异，提供方法元数据查询（名称/声明类/修饰符/返回类型/参数类型）与装饰器支持。被 `i2f-extension-antlr4`（Funic 脚本引擎语义层）和 `i2f-extension-aspectj`（AOP 工具）作为核心调用抽象消费，同时作为 `i2f-proxy-std` 和 `i2f-reflect` 的 POM 级依赖。

---

## 模块定位

- **功能**：为 Java 方法/构造器调用提供统一的接口抽象，将反射 API 的差异收敛到单个 `invoke(ivkObj, args)` 方法签名下
- **所属层级**：`i2f-jdk` 反射/代理基础设施层，位于 `i2f-reflect`（反射工具）和 `i2f-proxy-std`（代理标准）的上游

## 依赖关系

| 依赖 | 类型 | 用途 | 是否真实使用 |
|------|------|------|-------------|
| `lombok` | 编译期 | `@Data`/`@Getter`/`@Setter`/`@NoArgsConstructor`/`@EqualsAndHashCode`/`@ToString` | **是**（6 文件使用） |

纯 JDK 依赖，无任何运行时三方库。

## 包结构

```
i2f.invokable                    (2 文件)
i2f.invokable.method             (2 文件)
i2f.invokable.method.impl        (2 文件)
i2f.invokable.method.impl.jdk    (4 文件)
```

## 类结构总览

| 类名 | 行数 | 说明 |
|------|------|------|
| **核心接口** | | |
| `IInvokable` | 17 | 核心契约：`invoke(Object ivkObj, Object... args)` + `setAccessible(boolean)` 默认空方法 |
| `IMethod` | 33 | 扩展 IInvokable，增加元数据：`getName`/`getDeclaringClass`/`getModifiers`/`getReturnType`/`getParameterTypes`/`getParameterCount` |
| **数据类** | | |
| `Invocation` | 23 | 调用快照：`target` + `invokable` + `args`，lombok `@Data`/`@NoArgsConstructor` |
| **抽象与装饰** | | |
| `AbstractMethod` | 59 | 抽象基类，提供字段 `name/declaringClass/modifiers/returnType/parameterTypes` 与空值保护（返回 `Object.class`/空数组），lombok `@Getter/@Setter/@EqualsAndHashCode/@ToString` |
| `MethodWrapper` | 55 | 装饰器基类，全委托转发至被包装的 `IMethod` 实例 |
| `DecorateNameMethod` | 27 | 扩展 MethodWrapper，通过 `Function<String,String>` 装饰器动态变换 `getName()` 返回值 |
| **JDK 反射包装** | | |
| `JdkMethod` | 71 | 包装 `java.lang.reflect.Method`，完整实现 IMethod |
| `JdkConstructor` | 75 | 包装 `java.lang.reflect.Constructor`，名称固定为 `<init>`，强制追加 `STATIC` 修饰符，`invoke()` 委托 `constructor.newInstance(args)` |
| `JdkExecutable` | 78 | 包装 `java.lang.reflect.Executable`，统一支持 `Constructor` + `Method`，`invoke()` 运行时按类型分发：`Constructor`→`newInstance`、`Method`→`invoke` |
| `JdkInstanceStaticMethod` | 38 | 扩展 JdkMethod，增加 `target` 回退字段：当 `invoke(obj, args)` 的 `obj` 为 null 时自动切换到构造时绑定的目标对象，强制追加 `STATIC` 修饰符 |

## 核心机制详解

### 1. 双层接口设计

```
IInvokable                     ← 最小化调用契约
  └── invoke(ivkObj, args)     ← 统一调用入口
  └── setAccessible(boolean)   ← 可访问性控制（默认空）
        ↑
IMethod extends IInvokable    ← 方法元数据扩展
  └── getName()                ← 方法名
  └── getDeclaringClass()      ← 声明类
  └── getModifiers()           ← 修饰符位掩码
  └── getReturnType()          ← 返回类型
  └── getParameterTypes()      ← 参数类型数组
  └── getParameterCount()      ← 参数个数
```

`IInvokable` 只关注「能否被调用」，`IMethod` 在此基础上增加反射元数据查询能力，形成关注点分离。

### 2. JDK 反射包装族谱

```
IMethod
├── JdkMethod                   ← java.lang.reflect.Method
│     └── JdkInstanceStaticMethod   ← Method + 目标对象回退
├── JdkConstructor              ← java.lang.reflect.Constructor (name="<init>")
└── JdkExecutable               ← java.lang.reflect.Executable (Method ∪ Constructor 统一)
```

四种 JDK 包装各适用场景：

- **`JdkMethod`**：标准 `Method` 包装，`invoke(obj, args)` 直接映射到 `method.invoke(obj, args)`
- **`JdkConstructor`**：构造器包装，固定返回名称 `<init>`，`invoke()` 忽略 `obj` 参数（构造器仅需 args），修饰符强制含 `STATIC`
- **`JdkExecutable`**：统一包装 `java.lang.reflect.Executable`（Method 和 Constructor 的共同父类），运行时按 `instanceof` 分发，适合不确定是方法还是构造器的场景
- **`JdkInstanceStaticMethod`**：在 `JdkMethod` 基础上绑定一个默认 `target` 对象，当 `invoke(obj, args)` 的 `obj` 参数为 null 时自动 fallback 到绑定的 target，适合从实例方法提取为静态调用的适配场景

### 3. 装饰器模式

```
IMethod
  └── MethodWrapper (delegate)
        └── DecorateNameMethod (Function<String,String> decorator)
```

`MethodWrapper` 实现所有 IMethod 接口方法并全量委托给内部的 `method` 字段，作为装饰器基类。
`DecorateNameMethod` 在其上叠加名称变换能力：通过构造函数注入 `Function<String,String>` 函数，在 `getName()` 返回值上应用装饰逻辑。

### 4. 抽象基类

```java
@Getter
@Setter
@EqualsAndHashCode
@ToString
public abstract class AbstractMethod implements IMethod {
    public static final int DEFAULT_MODIFIER = Modifier.PUBLIC | Modifier.STATIC;
    
    protected String name;
    protected Class<?> declaringClass;
    protected int modifiers = DEFAULT_MODIFIER;
    protected Class<?> returnType;
    protected Class<?>[] parameterTypes;

    @Override
    public Class<?> getDeclaringClass() {
        return declaringClass == null ? Object.class : declaringClass;
    }

    @Override
    public Class<?> getReturnType() {
        return returnType == null ? Object.class : returnType;
    }
}
```

提供完整的字段实现与空值保护（null 时返回 `Object.class` 或空数组），预制 `PUBLIC | STATIC` 默认修饰符。

## 使用示例

### 示例 1：包装 Method

```java
Method method = String.class.getMethod("toUpperCase");
JdkMethod jdkMethod = new JdkMethod(method);

System.out.println(jdkMethod.getName());         // toUpperCase
System.out.println(jdkMethod.getDeclaringClass());// class java.lang.String
System.out.println(jdkMethod.getReturnType());    // class java.lang.String

String result = (String) jdkMethod.invoke("hello");
System.out.println(result); // HELLO
```

### 示例 2：包装 Constructor

```java
Constructor<StringBuilder> constructor = StringBuilder.class
    .getConstructor(String.class);
JdkConstructor jdkConstructor = new JdkConstructor(constructor);

System.out.println(jdkConstructor.getName());         // <init>
System.out.println(jdkConstructor.getDeclaringClass());// class java.lang.StringBuilder

StringBuilder sb = (StringBuilder) jdkConstructor.invoke(null, "Hello");
System.out.println(sb); // Hello
```

### 示例 3：统一 Executable 包装

```java
// 包装 Method
Method method = Integer.class.getMethod("valueOf", int.class);
JdkExecutable exec = new JdkExecutable(method);
Integer val = (Integer) exec.invoke(null, 42);
System.out.println(val); // 42

// 包装 Constructor
Constructor<StringBuilder> constructor = StringBuilder.class.getConstructor();
JdkExecutable exec2 = new JdkExecutable(constructor);
StringBuilder sb = (StringBuilder) exec2.invoke(null);
System.out.println(sb.length()); // 0
```

### 示例 4：InstanceStaticMethod 回退

```java
Method method = List.class.getMethod("size");
List<String> list = Arrays.asList("a", "b", "c");

JdkInstanceStaticMethod im = new JdkInstanceStaticMethod(list, method);

// 传递 obj → 使用 obj
int size = (int) im.invoke(list, new Object[0]);
System.out.println(size); // 3

// obj 为 null → 自动回退到构造时的 target
int size2 = (int) im.invoke(null, new Object[0]);
System.out.println(size2); // 3
```

### 示例 5：名称装饰

```java
Method method = String.class.getMethod("length");
DecorateNameMethod decorated = new DecorateNameMethod(
    new JdkMethod(method),
    name -> "get" + name.substring(0, 1).toUpperCase() + name.substring(1)
);

System.out.println(decorated.getName()); // getLength
System.out.println(decorated.invoke("hello")); // 5
```

### 示例 6：Invocation 数据类

```java
IInvokable invokable = new JdkMethod(
    String.class.getMethod("startsWith", String.class)
);
Invocation invocation = new Invocation("Hello World", invokable, "Hello");

boolean result = (boolean) invocation.getInvokable()
    .invoke(invocation.getTarget(), invocation.getArgs());
System.out.println(result); // true
```

## 消费关系

### 代码级消费者

| 消费方 | 位置 | 使用内容 |
|--------|------|---------|
| `i2f-extension-antlr4` | Funic 脚本引擎语义层（15+ import 语句） | `IMethod`、`JdkMethod`、`JdkInstanceStaticMethod`、`DecorateNameMethod`、`MethodWrapper` |
| `i2f-extension-aspectj` | `AspectjUtil`/`AspectjInvoker`（3 import 语句） | `IInvokable`、`JdkMethod` |

### POM 声明依赖（无代码级引用）

| 消费方 | 位置 |
|--------|------|
| `i2f-proxy-std` | `i2f-jdk/i2f-proxy-std/pom.xml` L18 |
| `i2f-reflect` | `i2f-jdk/i2f-reflect/pom.xml` L37 |

### 注册链路

| 注册点 | 位置 | 说明 |
|--------|------|------|
| `i2f-jdk/modules` | `i2f-jdk/pom.xml` L89 | 模块声明 |
| 根 pom 版本管理 | `pom.xml` L481 | 版本托管 `${i2f.version}` |
| `i2f-jdk-all` | `i2f-jdk-all/pom.xml` L305 | 全仓聚合 |

## 已知缺陷

| 级别 | 位置 | 描述 |
|------|------|------|
| 中 | `JdkExecutable.getReturnType()` | 对 `Method` 返回 `executable.getDeclaringClass()`（即声明类）而非 `method.getReturnType()`（实际返回类型），与 `JdkMethod` 行为不一致 |
| 中 | `JdkExecutable` | `getName()` 对 `Constructor` 返回声明类名（例如 `java.lang.StringBuilder`）而非 `<init>`，与 `JdkConstructor.getName()` 行为不一致 |
| 低 | `JdkConstructor.invoke()` | `obj` 参数被静默忽略而不做任何校验（构造器不需要目标对象可理解，但接口签名无提示） |
| 低 | `JdkConstructor` 构造器 | `Executable executable;` 变量声明但未使用 |
| 低 | 全模块 | 无 test 源码集，无单元测试 |

## 对比

| 维度 | i2f-invokable | java.lang.reflect.Method | java.lang.reflect.Constructor |
|------|--------------|--------------------------|------------------------------|
| 统一调用 | `invoke(ivkObj, args)` | `invoke(obj, args)` | `newInstance(args)` |
| 元数据接口 | `IMethod` 6 方法 | 各 API 独立 | 各 API 独立 |
| 构造器标识 | `getName()` → `<init>` | 不适用 | `getName()` → 类名 |
| 装饰器 | `MethodWrapper` + `DecorateNameMethod` | 无 | 无 |
| 统一类型 | `JdkExecutable`（Method∪Constructor） | 不适用 | 不适用 |
| 目标回退 | `JdkInstanceStaticMethod` | 无 | 不适用 |

## 总结

`i2f-invokable` 是一个极精简（381 行）的反射调用抽象层，核心价值在于：

1. **统一调用入口**：将 `Method.invoke(obj, args)` 与 `Constructor.newInstance(args)` 统一为 `IInvokable.invoke(ivkObj, args)`
2. **元数据契约**：通过 `IMethod` 接口提供调用者的元数据自描述能力（名称/声明类/修饰符/返回类型/参数）
3. **装饰器支持**：`MethodWrapper` + `DecorateNameMethod` 支持在方法调用链中透明插入变换逻辑
4. **脚本引擎基础设施**：被 `i2f-extension-antlr4` Funic 脚本引擎广泛消费，作为方法调用的多态抽象

主要不足在于 `JdkExecutable` 的 `getReturnType()`/`getName()` 对 Method/Constructor 的处理与专用包装类不一致，以及全模块零测试覆盖。