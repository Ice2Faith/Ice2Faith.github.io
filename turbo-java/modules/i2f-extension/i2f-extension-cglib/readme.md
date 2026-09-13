# i2f-extension-cglib

> **基于 CGLIB 字节码增强的 i2f-proxy-std 代理实现 / 将 CGLIB Enhancer 的子类代理能力装配为 `IProxyProvider` 统一契约的薄适配层**（3 源文件共 105 行、单包族 `i2f.extension.cglib`/`.impl`、零测试零资源，依赖 `cglib:3.3.0` provided + optional，内部依赖 `i2f-proxy-std`）。

## 模块路径

- `i2f-extension/i2f-extension-cglib/pom.xml`
- 相对于仓库根目录：`i2f-extension/i2f-extension-cglib`

## 模块依赖

### 内部模块（compile 依赖）

| Maven 坐标 | scope | optional | 说明 |
|-----------|-------|----------|------|
| `i2f.turbo:i2f-proxy-std:1.0-jdk8` | compile | false | 代理标准契约（`IProxyProvider` 接口 + `IProxyInvocationHandler` 函数式接口 + `IProxyHandler`） |

### 三方依赖（provided + optional）

| Maven 坐标 | 版本 | scope | optional | 说明 |
|-----------|------|-------|----------|------|
| `cglib:cglib:3.3.0` | 3.3.0 | provided | true | CGLIB 字节码增强库（`Enhancer`/`MethodInterceptor`），运行期由使用方提供 |
| `org.projectlombok:lombok` | 父 POM 管理 | provided | true | 代码生成注解（当前源文件均未使用，属冗余依赖） |

### 隐式传递依赖

| 传递来源 | 传递依赖 | 说明 |
|---------|---------|------|
| `i2f-proxy-std` | `i2f-invokable` | `IInvokable`/`Invocation` 接口，由 `JdkMethod` 实现承载 `java.lang.reflect.Method` 适配 |
| `i2f-proxy-std` | `i2f-proxy-std` 的 impl 包 | `ProxyHandlerAdapter` 将 `IProxyHandler` 适配为 `IProxyInvocationHandler` |

## 模块设计

### 包结构

```
i2f.extension.cglib
├── CglibUtil.java                  -- 静态门面，6 个 proxy() 方法重载
├── CglibProxyProvider.java         -- IProxyProvider 实现，装饰 Enhancer 实例
└── impl/
    └── CglibProxyInvocationHandlerAdapter.java  -- MethodInterceptor 适配器
```

### 架构设计

本模块是 i2f 统一代理模型在 CGLIB 字节码增强方向的实现层，采用**适配器模式 + 门面模式**的双层结构：

```
┌─────────────────────────────────────────────────────────┐
│                    调用方 (Consumer)                       │
│  CglibUtil.proxy(Class, IProxyInvocationHandler)        │
│  或 CglibProxyProvider.proxy(obj, handler)              │
└──────────────────────┬──────────────────────────────────┘
                       │
          ┌────────────┴────────────┐
          ▼                        ▼
┌──────────────────┐   ┌──────────────────────────┐
│   CglibUtil      │   │   CglibProxyProvider      │
│   静态门面        │   │   IProxyProvider 实现      │
│   6 重载 proxy() │   │   持有 Enhancer 实例       │
└────────┬─────────┘   └────────┬─────────────────┘
         │                      │
         └──────────┬───────────┘
                    ▼
┌──────────────────────────────────────────────┐
│   CglibProxyInvocationHandlerAdapter          │
│   MethodInterceptor ← IProxyInvocationHandler │
│   intercept() 桥接 → handler.invoke()          │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│   net.sf.cglib.proxy.Enhancer                 │
│   Enhancer.create() → 子类代理实例             │
└──────────────────────────────────────────────┘
```

### 设计要点

1. **三层重载门面**：`CglibUtil` 提供 6 个 `proxy()` 重载，覆盖三种处理器类型（`IProxyHandler` / `IProxyInvocationHandler` / `MethodInterceptor`），每种可选自定义 `Enhancer` 实例，使用方可根据场景选择最简接口
2. **共享默认 Enhancer**：`DEFAULT_ENHANCER` 静态字段持有共享 `Enhancer` 实例，`setUseFactory(true)` 启用 Factory 优化（`Factory` 接口允许运行期更换 callback）
3. **单次适配桥接**：`CglibProxyInvocationHandlerAdapter.intercept()` 将 CGLIB 的 `MethodInterceptor` 回调转为 `IProxyInvocationHandler.invoke(ivkObj, IInvokable, args)`，其中 `IInvokable` 通过 `JdkMethod(method)` 包装原始 `java.lang.reflect.Method`
4. **IProxyProvider 统一接入**：`CglibProxyProvider` 实现 `IProxyProvider` 契约，使 CGLIB 代理能力与 JDK 动态代理（`i2f-proxy`）、AspectJ 桥接（`i2f-extension-aspectj`）等实现在同一接口下可互换
5. **轻量零外部依赖耦合**：仅 105 行源码，CGLIB 以 provided 引入，编译期无需 CGLIB 也可通过——实际运行期由使用方提供 `cglib:3.3.0`

## 模块目的

- 将 i2f 上层代理抽象（`IProxyProvider`/`IProxyInvocationHandler`）落地到 CGLIB 字节码子类化技术栈
- 提供 CGLIB 代理的简化静态门面 `CglibUtil`，降低原生 `Enhancer` API 的复杂度
- 使 CGLIB 代理可在 i2f 代理生态中与 JDK 动态代理、AspectJ 桥接等其他实现互换使用

## 模块功能

1. **CglibUtil 静态门面**：6 个 `proxy()` 重载方法，支持 `IProxyHandler` / `IProxyInvocationHandler` / `MethodInterceptor` 三种处理器签名
2. **CglibProxyProvider 契约实现**：实现 `IProxyProvider` 接口，接受 `Enhancer` 实例的自定义注入（构造器注入）
3. **CglibProxyInvocationHandlerAdapter 适配桥接**：将 `IProxyInvocationHandler.invoke()` 桥接到 CGLIB 的 `MethodInterceptor.intercept()`，方法签名经 `JdkMethod` 包装为 `IInvokable`
4. **Factory 模式优化**：`enhancer.setUseFactory(true)` 启用 CGLIB Factory 接口，允许代理实例在运行期动态更换 MethodInterceptor
5. **共享实例支持**：预置 `DEFAULT_ENHANCER` 静态共享实例，省去多数场景下创建 Enhancer 的开销

## 模块主要使用方法

### 1. Maven 依赖引入

```xml
<dependency>
    <groupId>i2f.turbo</groupId>
    <artifactId>i2f-extension-cglib</artifactId>
    <version>1.0-jdk8</version>
</dependency>
<!-- 运行期需自行引入 cglib -->
<dependency>
    <groupId>cglib</groupId>
    <artifactId>cglib</artifactId>
    <version>3.3.0</version>
</dependency>
```

### 2. 使用 CglibUtil 静态门面创建代理

```java
// 方式一：使用 IProxyInvocationHandler（推荐）
IProxyInvocationHandler handler = (ivkObj, invokable, args) -> {
    System.out.println("before: " + invokable.getName());
    Object ret = invokable.invoke(ivkObj, args);
    System.out.println("after: " + ret);
    return ret;
};
UserService proxy = CglibUtil.proxy(UserService.class, handler);

// 方式二：使用 IProxyHandler
IProxyHandler handler2 = (ivkObj, invokable, args) -> {
    return invokable.invoke(ivkObj, args);
};
UserService proxy2 = CglibUtil.proxy(UserService.class, handler2);

// 方式三：使用原生 CGLIB MethodInterceptor
MethodInterceptor interceptor = (obj, method, args, methodProxy) -> {
    return methodProxy.invokeSuper(obj, args);
};
UserService proxy3 = CglibUtil.proxy(UserService.class, interceptor);

// 方式四：自定义 Enhancer 实例
Enhancer myEnhancer = new Enhancer();
myEnhancer.setClassLoader(new URLClassLoader(...));
UserService proxy4 = CglibUtil.proxy(UserService.class, handler, myEnhancer);
```

### 3. 使用 CglibProxyProvider 通过 IProxyProvider 契约

```java
IProxyProvider provider = new CglibProxyProvider();
UserService proxy = provider.proxy(UserService.class, (ivkObj, invokable, args) -> {
    return invokable.invoke(ivkObj, args);
});
```

### 4. 注意事项

- `CglibProxyProvider.proxy()` 的首参数虽然接口签名为 `Object obj`，但底层强制转换为 `Class<T>`——调用时必须传入 `Class` 对象而非实例
- CGLIB 通过子类化实现代理，因此**不能代理 `final` 类**，也**不能代理 `final` 方法**
- 共享 `DEFAULT_ENHANCER` 在多线程并发创建代理时存在线程安全问题，高并发场景建议为每次调用创建独立的 `Enhancer` 实例

## 模块特性总结

- **超薄适配**：仅 105 行源码完成 i2f-proxy-std 到 CGLIB 的全链路桥接
- **三重处理器兼容**：同时支持 `IProxyHandler`、`IProxyInvocationHandler`、`MethodInterceptor` 三种回调签名
- **IProxyProvider 可互换**：与 `i2f-proxy`（JDK 动态代理）、`i2f-extension-aspectj`（AspectJ 桥接）等实现共享同一代理契约
- **Factory 模式优化**：启用 `setUseFactory(true)` 允许运行期动态更换回调
- **自定义 Enhancer 注入**：支持调用者传入自配置的 `Enhancer` 实例（如自定义 ClassLoader）

## 模块瑕疵或错误

1. **lombok 依赖冗余**（POM L15-18）：POM 声明了 `lombok` 依赖，但全部 3 个源文件均未使用任何 lombok 注解（`@Data`/`@Slf4j` 等），属构建期冗余声明
2. **共享 DEFAULT_ENHANCER 非线程安全**（`CglibUtil.java` L15）：`DEFAULT_ENHANCER` 是 `static final` 共享实例，CGLIB 官方文档明确指出 `Enhancer` 非线程安全——多线程并发调用 `proxy()` 时，多个线程同时操作同一 `Enhancer` 的 `setSuperclass`/`setCallback`/`create` 存在竞态条件，可能导致代理创建失败或产生错误代理
3. **零测试覆盖**：无任何 JUnit 测试文件，核心的适配桥接逻辑（`MethodInterceptor` → `IProxyInvocationHandler` 的调用链）未经自动化验证
4. **CglibProxyProvider.proxy() 参数语义需文档化**（`CglibProxyProvider.java` L25-26）：从 `IProxyProvider` 接口继承的签名 `proxy(Object obj, ...)` 中，`obj` 参数在此实现中必须是 `Class<?>` 而非实例——违反直觉但无法通过接口签名表达，调用者传入错误类型将在运行时抛出 `ClassCastException`

## 消费方情况

| 消费方 | 关系 | 说明 |
|-------|------|------|
| `i2f-extension-all` | POM 聚合 | 将本模块纳入 extension 全量分发包 |
| `i2f-extension` 父 POM | 子模块注册 | `pom.xml` L29 声明为子模块 |
| `i2f-turbo-java` 根 POM | dependencyManagement | `pom.xml` L960 统一版本管理 |
| `i2f-jdk/test-features` | 测试依赖 | `pom.xml` L32 引入用于测试 |
| `i2f-spring/i2f-spring-core` | **同构复制**（非消费） | `i2f.spring.cglib` 包下同名类使用 Spring 内建 `org.springframework.cglib.proxy.Enhancer`，与本模块为平行独立实现 |