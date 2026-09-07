# 链路追踪 MDC — Trace MDC Starter

## 概述

`i2f-springboot-trace-mdc-starter` 是基于 `i2f-trace-mdc` 基础模块构建的 SpringBoot 自动配置 Starter，提供全链路 TraceId
追踪与 MDC（Mapped Diagnostic Context）上下文传递能力。通过自动装配机制，覆盖 Web 请求入口、微服务调用、HTTP
客户端、定时任务、线程池等全部场景，确保 TraceId 在整个调用链中透明传递。

## 模块定位

| 属性             | 值                                                                    |
|----------------|----------------------------------------------------------------------|
| **ArtifactId** | `i2f-springboot-trace-mdc-starter`                                   |
| **Parent**     | `i2f-springboot`                                                     |
| **基础模块**       | `i2f-jdk/i2f-trace-mdc`（11 文件，核心 MDC 抽象与线程传递）                        |
| **Java 源码**    | 11 文件（Starter 层）+ 11 文件（基础层）= **22 文件**                              |
| **自动配置**       | 10 个自动配置类，全部 `@ConditionalOnClass` + `@ConditionalOnExpression` 按需激活 |

## 依赖关系

### 核心依赖

| 模块                    | 说明                                                 |
|-----------------------|----------------------------------------------------|
| `i2f-trace-mdc`       | MDC 核心抽象层（MdcHolder/MdcManager/MdcTraces + 线程传递工具） |
| `i2f-extension-slf4j` | SLF4J 日志扩展                                         |
| `lombok`              | 代码简化                                               |

### 可选依赖（provided，按需激活）

| 依赖                                          | 激活场景           | 说明                                                                |
|---------------------------------------------|----------------|-------------------------------------------------------------------|
| `spring-boot-starter-web`                   | Servlet Web 应用 | MdcWebFilter                                                      |
| `spring-boot-starter-aop`                   | AOP 切面         | MdcAnnotationAspect / MdcXxlJobAspect / MdcSpringSchedulingAspect |
| `spring-cloud-starter-openfeign`            | Feign 微服务调用    | MdcFeignInterceptor                                               |
| `spring-cloud-starter-gateway`              | Gateway 网关     | MdcGatewayFilter                                                  |
| `xxl-job-core` 2.4.1                        | XXL-JOB 定时任务   | MdcXxlJobAspect                                                   |
| `powerjob-worker-spring-boot-starter` 4.3.9 | PowerJob 定时任务  | MdcPowerJobAspect                                                 |

## 核心架构

### 基础层 — i2f-trace-mdc

基础层提供零 Spring 依赖的 MDC 抽象，可在任何 Java 环境中使用。

#### MdcManager — MDC 管理接口

```
MdcManager                          -- 接口：put/get/remove/clear/copyOf/replaceAs
└── DefaultMdcManager               -- 默认实现：InheritableThreadLocal + ReentrantReadWriteLock
```

- **SPI 扩展**: 通过 `ServiceLoader<MdcManager>` 发现实现
- **优先级**: 系统属性 `mdc.manager` 指定类 → SPI 发现（slf4j 优先 > log4j 次之 > 其他）→ `DefaultMdcManager` 兜底
- **线程安全**: `DefaultMdcManager` 使用 `ReentrantReadWriteLock` + `InheritableThreadLocal` 保证并发安全

#### MdcHolder — MDC 静态持有器

统一入口，封装 `MdcManager` 的静态方法：

| 方法                          | 说明           |
|-----------------------------|--------------|
| `MdcHolder.put(key, value)` | 设置 MDC 变量    |
| `MdcHolder.get(key)`        | 获取 MDC 变量    |
| `MdcHolder.remove(key)`     | 移除 MDC 变量    |
| `MdcHolder.clear()`         | 清空全部 MDC 变量  |
| `MdcHolder.copyOf()`        | 快照当前 MDC 上下文 |
| `MdcHolder.replaceAs(map)`  | 整体替换 MDC 上下文 |

#### MdcTraces — 追踪常量与工具

| 常量             | 值             | 说明     |
|----------------|---------------|--------|
| `TRACE_ID`     | `traceId`     | 追踪 ID  |
| `TRACE_SOURCE` | `traceSource` | 追踪来源   |
| `TRACE_URL`    | `traceUrl`    | 请求 URL |
| `TRACE_IP`     | `traceIp`     | 客户端 IP |
| `TRACE_APP`    | `traceApp`    | 应用名称   |

**Header 识别**（按优先级依次查找）：

| 用途          | Header 列表                                                                                                   |
|-------------|-------------------------------------------------------------------------------------------------------------|
| TraceId     | `traceId` → `X-Trace-Id` → `Trace-Id` → `X-Request-Id` → `Request-Id` → `RequestId`                         |
| TraceSource | `traceSource` → `X-Trace-Source` → `Trace-Source` → `X-Request-Source` → `Request-Source` → `RequestSource` |

**TraceId 生成**: `UUID.randomUUID().toString().replace("-", "")`（32 位无连字符 UUID）

#### 线程传递工具

基础层提供完整的线程池 MDC 传递工具，解决异步场景下 MDC 上下文丢失问题：

| 类                             | 说明                                                                                                    |
|-------------------------------|-------------------------------------------------------------------------------------------------------|
| `MdcRunnable`                 | Runnable 包装，构造时快照 MDC 上下文，运行时恢复，执行后清理                                                                 |
| `MdcCallable<T>`              | Callable 包装，与 MdcRunnable 相同的快照-恢复-清理机制                                                               |
| `MdcThread`                   | Thread 子类，构造时自动用 `MdcRunnable.of()` 包装 target                                                         |
| `MdcExecutor`                 | Executor 装饰器，`execute()` 自动包装 Runnable                                                                |
| `MdcExecutorService`          | ExecutorService 装饰器，`submit/invokeAll/invokeAny/execute` 全部自动包装                                       |
| `MdcScheduledExecutorService` | ScheduledExecutorService 装饰器，`scheduleAtFixedRate/scheduleWithFixedDelay` 使用 `ofNewTrace` 生成新 TraceId |
| `MdcThreadFactory`            | ThreadFactory 装饰器，`newThread()` 自动包装 Runnable                                                         |

**关键设计**:

- `MdcRunnable.of(runnable)` — 幂等包装（已包装则直接返回）
- `MdcRunnable.ofNewTrace(runnable)` — 强制生成新 TraceId（用于周期任务）
- 所有包装类在 `finally` 中调用 `MdcHolder.clear()` 防止线程池复用导致数据污染

### Starter 层 — 自动配置

#### 10 个自动配置类

| #  | 配置类                                   | 条件                                   | 说明                                         |
|----|---------------------------------------|--------------------------------------|--------------------------------------------|
| 1  | `MdcWebFilter`                        | `OncePerRequestFilter` + Servlet Web | Servlet 请求入口，提取/生成 TraceId，设置 MDC 上下文      |
| 2  | `MdcGatewayFilter`                    | `GlobalFilter` + Reactive Web        | Spring Cloud Gateway 网关入口                  |
| 3  | `MdcFeignInterceptor`                 | `RequestInterceptor`                 | OpenFeign 客户端拦截器，向下游传递 TraceId             |
| 4  | `MdcHttpClientInterceptor`            | `ClientHttpRequestInterceptor`       | RestTemplate/RestClient 拦截器                |
| 5  | `MdcRestTemplateInterceptorProcessor` | `RestTemplate`                       | BeanPostProcessor，自动为所有 RestTemplate 注入拦截器 |
| 6  | `MdcAnnotationAspect`                 | AOP + `@MdcTrace`                    | 注解驱动的 MDC 切面                               |
| 7  | `MdcTaskDecorator`                    | `TaskDecorator`                      | Spring 线程池任务装饰器                            |
| 8  | `MdcXxlJobAspect`                     | AOP + `@XxlJob`                      | XXL-JOB 定时任务切面                             |
| 9  | `MdcPowerJobAspect`                   | AOP + `@PowerJobHandler`             | PowerJob 定时任务切面                            |
| 10 | `MdcSpringSchedulingAspect`           | AOP + `@Scheduled`                   | Spring 定时任务切面                              |

## 功能模块详解

### Servlet Web 请求入口 — MdcWebFilter

**条件**: `spring-boot-starter-web` + Servlet Web 应用 + `i2f.springboot.trace.mdc.servlet.enable=true`（默认开启）

**处理流程**:

1. 从请求 Header 中按优先级查找 TraceId（6 种 Header），未找到则自动生成
2. 从请求 Header 中查找 TraceSource，未找到则使用 `spring.application.name`
3. 解析客户端真实 IP（支持 `X-Forwarded-For` / `Proxy-Client-IP` / `WL-Proxy-Client-IP` / `X-Real-IP` 多级代理）
4. 设置 5 个 MDC 变量：`traceId` / `traceSource` / `traceUrl` / `traceIp` / `traceApp`
5. 同时设置 Request Attribute（`traceId` / `traceSource`）供下游使用
6. 请求完成后清理全部 MDC 变量

**优先级**: `Ordered.HIGHEST_PRECEDENCE` 级别（`-990`）

### Spring Cloud Gateway 入口 — MdcGatewayFilter

**条件**: `spring-cloud-starter-gateway` + Reactive Web 应用 + `i2f.springboot.trace.mdc.gateway.enable=true`（默认开启）

**处理流程**:

1. 从 Reactive 请求 Header 中提取/生成 TraceId 和 TraceSource
2. 设置 MDC 上下文（5 个变量）
3. 通过 `request.mutate().header()` 将 TraceId/TraceSource 注入到下游请求
4. 请求完成后清理 MDC

**优先级**: `-990`

### OpenFeign 客户端 — MdcFeignInterceptor

**条件**: `spring-cloud-starter-openfeign` + `i2f.springboot.trace.mdc.feign.enable=true`（默认开启）

**处理流程**:

1. 从当前 MDC 获取 TraceId，无则生成新的
2. 获取 TraceSource，无则使用应用名
3. 向 Feign 请求模板注入 `traceId` / `traceSource` Header

### RestTemplate 客户端 — MdcHttpClientInterceptor + MdcRestTemplateInterceptorProcessor

**条件
**: `spring-boot-starter-web` + `i2f.springboot.trace.mdc.http-client.enable=true` / `i2f.springboot.trace.mdc.rest-template.enable=true`

**两种使用方式**:

| 方式       | 说明                                                                                      |
|----------|-----------------------------------------------------------------------------------------|
| **手动注入** | 将 `MdcHttpClientInterceptor` 添加到 `RestTemplate.setInterceptors()`                       |
| **自动注入** | `MdcRestTemplateInterceptorProcessor`（BeanPostProcessor）自动为所有 `RestTemplate` Bean 注入拦截器 |

### 注解驱动切面 — @MdcTrace + MdcAnnotationAspect

**条件**: `spring-boot-starter-aop` + `i2f.springboot.trace.mdc.aspect.enable=true`（默认开启）

**使用方式**: 在任意方法上添加 `@MdcTrace` 注解，AOP 切面自动在方法执行期间设置 TraceId 和 TraceSource。

```java
@MdcTrace
public void businessMethod() {
    // 方法执行期间 MDC 中包含 traceId 和 traceSource
}
```

**TraceSource 格式**: `@Aop,ClassName.methodName`

### Spring 线程池 — MdcTaskDecorator

**条件**: `TaskDecorator` 类存在 + `i2f.springboot.trace.mdc.task-decorator.enable=true`（默认开启）

**使用方式**: 配置 `ThreadPoolTaskExecutor` 时设置 `setTaskDecorator(mdcTaskDecorator)`

```java
@Bean
public ThreadPoolTaskExecutor taskExecutor(MdcTaskDecorator decorator) {
    ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
    executor.setTaskDecorator(decorator);
    // ...
    return executor;
}
```

**原理**: 在主线程中 `MdcHolder.copyOf()` 快照上下文，子线程中 `MdcHolder.replaceAs()` 恢复，执行后 `MdcHolder.clear()`
清理。

### XXL-JOB 定时任务 — MdcXxlJobAspect

**条件**: `xxl-job-core` + `spring-boot-starter-aop` + `i2f.springboot.trace.mdc.xxl-job.enable=true`（默认开启）

**处理流程**: 拦截所有 `@XxlJob` 注解方法，每次执行生成新 TraceId。

**TraceSource 格式**: `@XxlJob,{jobHandlerName}` 或 `@XxlJob,ClassName.methodName`

### PowerJob 定时任务 — MdcPowerJobAspect

**条件**: `powerjob-worker` + `spring-boot-starter-aop` + `i2f.springboot.trace.mdc.power-job.enable=true`（默认开启）

**处理流程**: 拦截所有 `@PowerJobHandler` 注解方法，每次执行生成新 TraceId。

**TraceSource 格式**: `@PowerJobHandler,{handlerName}` 或 `@PowerJobHandler,ClassName.methodName`

### Spring 定时任务 — MdcSpringSchedulingAspect

**条件**: `spring-boot-starter-aop` + `i2f.springboot.trace.mdc.scheduling.enable=true`（默认开启）

**处理流程**: 拦截所有 `@Scheduled` 注解方法，每次执行生成新 TraceId。

**TraceSource 格式**: `@Scheduled,ClassName.methodName`

## 配置属性

所有功能默认开启，可通过配置关闭：

| 配置项                                              | 默认值    | 说明                |
|--------------------------------------------------|--------|-------------------|
| `i2f.springboot.trace.mdc.servlet.enable`        | `true` | Servlet Web 过滤器   |
| `i2f.springboot.trace.mdc.gateway.enable`        | `true` | Gateway 网关过滤器     |
| `i2f.springboot.trace.mdc.feign.enable`          | `true` | Feign 拦截器         |
| `i2f.springboot.trace.mdc.http-client.enable`    | `true` | HTTP 客户端拦截器       |
| `i2f.springboot.trace.mdc.rest-template.enable`  | `true` | RestTemplate 自动注入 |
| `i2f.springboot.trace.mdc.aspect.enable`         | `true` | `@MdcTrace` 注解切面  |
| `i2f.springboot.trace.mdc.task-decorator.enable` | `true` | 线程池任务装饰器          |
| `i2f.springboot.trace.mdc.xxl-job.enable`        | `true` | XXL-JOB 切面        |
| `i2f.springboot.trace.mdc.power-job.enable`      | `true` | PowerJob 切面       |
| `i2f.springboot.trace.mdc.scheduling.enable`     | `true` | Spring 定时任务切面     |

## 全链路追踪流程

```
                    ┌─────────────────────────────────────────────────────────────┐
                    │                     请求入口层                               │
                    │  MdcWebFilter (Servlet)  /  MdcGatewayFilter (Reactive)     │
                    │  提取/生成 TraceId → 设置 MDC 上下文 → 注入 Header 到下游    │
                    └──────────────────────┬──────────────────────────────────────┘
                                           │
                    ┌──────────────────────▼──────────────────────────────────────┐
                    │                     微服务调用层                             │
                    │  MdcFeignInterceptor (OpenFeign)                            │
                    │  从 MDC 获取 TraceId → 注入 Feign 请求 Header → 下游服务     │
                    └──────────────────────┬──────────────────────────────────────┘
                                           │
                    ┌──────────────────────▼──────────────────────────────────────┐
                    │                     HTTP 客户端层                            │
                    │  MdcHttpClientInterceptor + MdcRestTemplateInterceptorProcessor │
                    │  从 MDC 获取 TraceId → 注入 RestTemplate 请求 Header         │
                    └──────────────────────┬──────────────────────────────────────┘
                                           │
                    ┌──────────────────────▼──────────────────────────────────────┐
                    │                     异步/线程池层                            │
                    │  MdcTaskDecorator (Spring 线程池)                            │
                    │  MdcExecutorService / MdcRunnable / MdcCallable (原生线程池) │
                    │  主线程快照 → 子线程恢复 → 执行后清理                         │
                    └──────────────────────┬──────────────────────────────────────┘
                                           │
                    ┌──────────────────────▼──────────────────────────────────────┐
                    │                     定时任务层                               │
                    │  MdcXxlJobAspect (@XxlJob)                                 │
                    │  MdcPowerJobAspect (@PowerJobHandler)                       │
                    │  MdcSpringSchedulingAspect (@Scheduled)                     │
                    │  每次执行生成新 TraceId → 设置 MDC → 执行后清理              │
                    └─────────────────────────────────────────────────────────────┘
```

## 源文件清单

### 基础层 — i2f-jdk/i2f-trace-mdc（11 文件）

| 包路径                          | 文件                                 | 行数  | 说明                                                       |
|------------------------------|------------------------------------|-----|----------------------------------------------------------|
| `i2f.trace.mdc`              | `MdcHolder.java`                   | 119 | MDC 静态持有器，SPI 发现 MdcManager                              |
|                              | `MdcTraces.java`                   | 47  | 追踪常量（TRACE_ID/SOURCE/URL/IP/APP）+ Header 列表 + TraceId 生成 |
| `i2f.trace.mdc.manager`      | `MdcManager.java`                  | 22  | MDC 管理接口                                                 |
| `i2f.trace.mdc.manager.impl` | `DefaultMdcManager.java`           | 101 | 默认实现（InheritableThreadLocal + 读写锁）                       |
| `i2f.trace.mdc.thread`       | `MdcRunnable.java`                 | 70  | Runnable 包装，快照-恢复-清理                                     |
|                              | `MdcCallable.java`                 | 71  | Callable 包装                                              |
|                              | `MdcThread.java`                   | 40  | Thread 子类，自动包装 Runnable                                  |
|                              | `MdcExecutor.java`                 | 31  | Executor 装饰器                                             |
|                              | `MdcExecutorService.java`          | 94  | ExecutorService 装饰器                                      |
|                              | `MdcScheduledExecutorService.java` | 114 | ScheduledExecutorService 装饰器                             |
|                              | `MdcThreadFactory.java`            | 30  | ThreadFactory 装饰器                                        |

### Starter 层 — i2f-springboot-trace-mdc-starter（11 文件）

| 包路径                                          | 文件                                         | 行数  | 说明                             |
|----------------------------------------------|--------------------------------------------|-----|--------------------------------|
| `i2f.springboot.trace.mdc.aspect.annotation` | `MdcTrace.java`                            | 17  | `@MdcTrace` 注解定义               |
| `i2f.springboot.trace.mdc.aspect.aop`        | `MdcAnnotationAspect.java`                 | 60  | `@MdcTrace` AOP 切面             |
| `i2f.springboot.trace.mdc.executor`          | `MdcTaskDecorator.java`                    | 39  | Spring 线程池任务装饰器                |
| `i2f.springboot.trace.mdc.feign`             | `MdcFeignInterceptor.java`                 | 50  | OpenFeign 拦截器                  |
| `i2f.springboot.trace.mdc.gateway`           | `MdcGatewayFilter.java`                    | 132 | Spring Cloud Gateway 全局过滤器     |
| `i2f.springboot.trace.mdc.httpclient`        | `MdcHttpClientInterceptor.java`            | 58  | RestTemplate 拦截器               |
|                                              | `MdcRestTemplateInterceptorProcessor.java` | 46  | RestTemplate BeanPostProcessor |
| `i2f.springboot.trace.mdc.powerjob`          | `MdcPowerJobAspect.java`                   | 54  | PowerJob 定时任务切面                |
| `i2f.springboot.trace.mdc.scheduling`        | `MdcSpringSchedulingAspect.java`           | 55  | Spring @Scheduled 切面           |
| `i2f.springboot.trace.mdc.springmvc`         | `MdcWebFilter.java`                        | 144 | Servlet Web 过滤器                |
| `i2f.springboot.trace.mdc.xxljob`            | `MdcXxlJobAspect.java`                     | 56  | XXL-JOB 定时任务切面                 |

## 设计特点

1. **零侵入**: 引入 Starter 依赖即可自动生效，无需修改任何业务代码
2. **全场景覆盖**: Web 入口 → 微服务调用 → HTTP 客户端 → 线程池 → 定时任务，完整链路
3. **按需激活**: 每个组件通过 `@ConditionalOnClass` + `@ConditionalOnExpression` 独立控制，缺依赖自动跳过
4. **可独立关闭**: 10 个配置开关，可精确控制每个组件的启用/禁用
5. **多 Header 兼容**: 支持 6 种 TraceId Header 名称和 6 种 TraceSource Header 名称，兼容各类网关和代理
6. **代理 IP 解析**: 支持多级代理场景下的真实客户端 IP 提取（X-Forwarded-For 等）
7. **线程安全**: 基础层使用 `ReentrantReadWriteLock` + `InheritableThreadLocal`，Starter 层 BeanPostProcessor 自动注入
8. **SPI 可扩展**: `MdcManager` 接口支持 SPI 扩展，可替换为 SLF4J/Log4j 等日志框架的原生 MDC 实现

## 相关文档

- [日志标准定义与完整实现体系](../wiki.md#日志标准定义与完整实现体系) — `i2f-log` 日志体系，MDC 变量可在日志 Pattern 中引用
- [运维控制台 — Ops Starter](ops-starter.md) — 运维控制台 Starter
- [i2f-springboot 模块列表](module-i2f-springboot.md) — SpringBoot Starter 完整列表
