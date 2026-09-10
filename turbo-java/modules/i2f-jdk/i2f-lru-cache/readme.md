# i2f-lru-cache LRU 缓存适配模块

## 概述

`i2f-lru-cache` 是 i2f-turbo-java 框架中**将 LRU 淘汰策略接入缓存接口的适配桥接模块**。全模块仅一个源码文件（`LruMapCache.java`，24 行），通过继承 `i2f-cache.MapCache`、替换底层 `Map` 为 `i2f-lru-map.LruMap`，使 `IContainerCache` 缓存接口天然具备 LRU 容量淘汰行为。

```text
ILock/INotify(IReadWriteLock/ILockProvider(ILockProvider)
              ↓  extends
         MapCache (i2f-cache)
              ↓  extends
         LruMapCache  ← 注入 LruMap (i2f-lru-map)
```

## 依赖关系

| 依赖类型 | 坐标 | 说明 |
|---------|------|------|
| 编译 | `i2f.turbo:i2f-jdk` (parent) | 仅继承父 POM 版本管理 |
| 编译 | `i2f.turbo:i2f-lru-map` | 提供 `LruMap` LRU 容器 |
| 编译 | `i2f.turbo:i2f-cache` | 提供 `MapCache` 缓存基类 |
| provided | `org.projectlombok:lombok` | 声明但未使用（模块无注解/日志） |

> 模块编译产物无任何运行期外部依赖，`lombok` 为冗余声明。

## 包结构

```
i2f.lru.cache
  └── LruMapCache.java   (24 行，1 类)
```

## 类说明

### LruMapCache\<K, V\>

**继承链**：`LruMapCache → MapCache (implements IContainerCache)`

**职责**：将 `LruMap` 作为 `MapCache` 的后备 `Map`，使缓存操作自动获得 LRU 容量淘汰语义。

**构造器**：

| 构造器 | 底层 Map | 容量约束 |
|--------|----------|----------|
| `LruMapCache()` | `new LruMap<>()` | 默认 1024 |
| `LruMapCache(int maxSize)` | `new LruMap<>(maxSize)` | 指定最大容量 |
| `LruMapCache(LruMap<K, V> map)` | 外部注入的 `LruMap` 实例 | 由注入实例决定 |

**全部缓存操作**由父类 `MapCache` 委托给底层 `LruMap`：

| 操作 | 委托目标 |
|------|----------|
| `get(key)` | `map.get(key)` — 命中后条目移至末尾（`accessOrder=true`） |
| `set(key, value)` | `map.put(key, value)` — 超出容量淘汰最久未访问条目 |
| `exists(key)` | `map.containsKey(key)` |
| `remove(key)` | `map.remove(key)` |
| `keys()` / `clean()` / `size()` | 对应 `Map` 操作 |

## 使用示例

```java
// 1. 默认 1024 容量的 LRU 缓存
LruMapCache<String, Object> cache = new LruMapCache<>();

// 2. 指定容量的 LRU 缓存
LruMapCache<String, Object> cache = new LruMapCache<>(500);

// 3. 与 ExpireCacheWrapper 组合：LRU + TTL 过期
ICache<String, Object> expireCache = new ExpireCacheWrapper<>(
    new LruMapCache<>(1000), 300_000L);
```

## 设计说明

1. **桥接而非重写**：不重复实现缓存接口，复用 `MapCache` 的全部 `IContainerCache` 实现，仅通过构造器注入替换底层 `Map`，零模板代码。

2. **可组合性**：`LruMapCache` 输出仍是 `IContainerCache`，可与 `ExpireCacheWrapper` 装饰器组合实现「LRU + TTL」双淘汰策略。

3. **最大容量下放**：不封装单独的大小方法，由 `LruMap` 的构造参数直接控制，保持 `MapCache` 基类的纯净。

## 已知限制

- 仅 LRU 淘汰，不支持 LFU/TTL 等混合淘汰（TTL 需 `ExpireCacheWrapper` 装饰）
- `LruMap` 的 `accessOrder=true` 行为是硬编码的，构造器注入方可更换策略