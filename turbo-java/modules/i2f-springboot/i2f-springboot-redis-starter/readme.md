# i2f-springboot-redis-starter

> Redis 的 Spring Boot 自动装配 Starter，由 4 个自动配置类分层装配：`RedisAutoConfiguration` 产出带 Jackson 默认类型的 `Jackson2JsonRedisSerializer`，`RedisTemplateAutoConfiguration` 据此组装 String-key / JSON-value 的 `RedisTemplate<String,Object>`，`RedisCacheConfiguration` 把二者桥接为 i2f 统一分布式缓存抽象 `IRedisClient`+`RedisCache`，`LettuceRedisHeartbeatConfiguration` 用后台线程周期 `validateConnection` 规避 Lettuce 的 15 分钟 TCP 重传假死。缓存/客户端实现下沉内部依赖 `i2f-extension-redis-cache` 与 `i2f-spring-redis`；四者各由独立 `@ConditionalOnExpression` 开关控制。

## 模块路径

- `i2f-springboot/i2f-springboot-redis-starter`

## 模块依赖

| groupId | artifactId | scope | optional | 说明 |
|---------|-----------|-------|----------|------|
| i2f.turbo | i2f-extension-redis-cache | compile | 否 | 内部依赖，提供 `RedisCache`（实现 `IExpireContainerCache`/`IPersistCache`/`IDistributedCache`）与 `IRedisClient` 抽象 |
| i2f.turbo | i2f-spring-redis | compile | 否 | 内部依赖，提供 `SpringRedisClient`（把 `RedisTemplate` 适配为 `IRedisClient`） |
| org.projectlombok | lombok | compile | 否 | `@Slf4j`/`@Data` 代码生成 |
| org.springframework.boot | spring-boot-starter | provided | 是 | Boot 基础自动装配 |
| org.springframework.boot | spring-boot-configuration-processor | provided | 是 | 配置元数据处理器 |
| org.springframework.boot | spring-boot-starter-json | provided | 否 | 提供 Jackson `ObjectMapper`（序列化器依赖） |
| org.springframework.boot | spring-boot-starter-data-redis | provided | 否 | 提供 `RedisTemplate`/`RedisConnectionFactory`/`Jackson2JsonRedisSerializer`/`@EnableRedisRepositories` 等 |

> 本模块为装配桥接层：真正的客户端与缓存能力来自 `i2f-extension-redis-cache`（`RedisCache`/`IRedisClient`）与 `i2f-spring-redis`（`SpringRedisClient`）；spring-data-redis / starter-json 为 provided，需使用方自行提供 Redis 驱动与连接配置（`spring.redis.*`）。

## 模块设计

```mermaid
flowchart TD
    subgraph A["RedisAutoConfiguration（enable:true）"]
        SER["getRedisSerializer()<br/>@ConditionalOnMissingBean<br/>Jackson2JsonRedisSerializer（dateFormat + defaultTyping）"]
    end
    subgraph B["RedisTemplateAutoConfiguration（redis-template.enable:true）"]
        TPL["redisStringKeyTemplate(factory)<br/>String-key + Jackson-value<br/>（无 @ConditionalOnMissingBean）"]
    end
    subgraph C["RedisCacheConfiguration（redis-cache.enable:true）"]
        CLI["redisClient() → SpringRedisClient<br/>@ConditionalOnMissingBean(IRedisClient)"]
        CCH["redisCache(client) → RedisCache<br/>@ConditionalOnMissingBean(RedisCache)<br/>encoder/decoder = Jackson 序列化"]
    end
    subgraph D["LettuceRedisHeartbeatConfiguration（heart-beat.enable:true + @ConditionalOnClass(RedisClient)）"]
        HB["afterPropertiesSet → 单线程 scheduleAtFixedRate<br/>heartBeat() → factory.validateConnection()"]
    end

    RD["spring-boot-starter-data-redis<br/>RedisConnectionFactory / RedisTemplate"]

    SER -->|@Autowired serializer| TPL
    SER -->|@Autowired serializer| CCH
    TPL -->|@Autowired RedisTemplate| CLI
    CLI --> CCH
    TPL -.->|注入连接工厂| RD
    HB -.->|@Autowired + instanceof| RD
```

**设计要点：**
- **四级链式装配**：序列化器 → 模板 → 客户端/缓存，靠 `@AutoConfigureAfter` 保证顺序、`@Autowired` 字段完成传递。
- **两处抽象下沉**：`SpringRedisClient` 把 `RedisTemplate` 适配为 i2f `IRedisClient`；`RedisCache` 再在 `IRedisClient` 之上叠加 key 前缀与 `Object↔String` 编解码，实现统一分布式缓存接口。
- **序列化闭环**：`RedisCache` 的 encoder/decoder 复用同一个 `Jackson2JsonRedisSerializer`，对象先转 JSON 字符串，再经模板的 Jackson value 序列化器落库。
- **心跳保活独立成类**：仅当连接工厂是 `LettuceConnectionFactory` 时启用后台 `validateConnection`，并监听 `ContextClosedEvent` 关闭线程池。
- **双层注册**：`spring.factories`（Boot 2.x）与 `AutoConfiguration.imports`（Boot 2.7+/3.x）同时登记 4 个配置类。

**包结构：**

```
i2f.springboot.redis
├── RedisAutoConfiguration            # 产出 Jackson2JsonRedisSerializer（@EnableRedisRepositories）
├── RedisTemplateAutoConfiguration    # 组装 RedisTemplate<String,Object>（String-key/Jackson-value）
├── RedisCacheConfiguration           # 桥接 SpringRedisClient + RedisCache
└── LettuceRedisHeartbeatConfiguration# Lettuce 连接保活心跳（InitializingBean + ApplicationListener）
```

## 模块目的

在 spring-data-redis 之上，为 i2f 生态提供一层"开箱即用"的 Redis 装配：统一 JSON 序列化策略、String 可读 key 的模板、把 Spring 的 `RedisTemplate` 适配为 i2f 标准分布式缓存 `RedisCache`，并附带 Lettuce 长空闲假死的保活兜底，降低业务接入 Redis 与缓存抽象的样板成本。

## 模块功能

| 能力 | 触发条件 | 载体 |
|------|----------|------|
| Jackson 序列化器 | `i2f.spring.redis.enable`（默认 `true`）且无同类 Bean | `RedisAutoConfiguration.getRedisSerializer()` |
| Redis repositories 扫描 | `RedisAutoConfiguration` 激活即开启 | `@EnableRedisRepositories` |
| String-key/Jackson-value 模板 | `i2f.spring.redis.redis-template.enable`（默认 `true`） | `RedisTemplateAutoConfiguration.redisStringKeyTemplate()`（无 `@ConditionalOnMissingBean`） |
| i2f Redis 客户端 | `i2f.spring.redis.redis-cache.enable`（默认 `true`）且无 `IRedisClient` | `RedisCacheConfiguration.redisClient()` → `SpringRedisClient` |
| i2f 分布式缓存 | 同上且无 `RedisCache` | `RedisCacheConfiguration.redisCache()` → `RedisCache` |
| Lettuce 连接保活 | `i2f.spring.redis.lettuce.heart-beat.enable`（默认 `true`）且 `RedisClient` 在类路径 | `LettuceRedisHeartbeatConfiguration` |

## 模块主要使用方法

引入本 Starter 并自备 `spring-boot-starter-data-redis` 与连接配置，即可注入 i2f `RedisCache` 或原生 `RedisTemplate`：

```yaml
spring:
  redis:
    host: 127.0.0.1
    port: 6379

i2f:
  spring:
    redis:
      enable: true
      date-format: "yyyy-MM-dd HH:mm:ss SSS"
      redis-cache:
        enable: true
        client-prefix: "cli:"
        cache-prefix: "cache:"
      lettuce:
        heart-beat:
          enable: true
          init-delay-seconds: 30
          rate-seconds: 30
```

```java
@Autowired
private RedisCache redisCache;   // i2f 统一分布式缓存（含 key 前缀 + 过期）

public void demo() {
    redisCache.set("user:1", somePojo, 30, java.util.concurrent.TimeUnit.MINUTES);
    Object v = redisCache.get("user:1");
}
```

也可直接使用被装配了 JSON 序列化的模板：

```java
@Autowired
private RedisTemplate<String, Object> redisStringKeyTemplate;

public void raw() {
    redisStringKeyTemplate.opsForValue().set("k", somePojo);
}
```

## 配置项参考

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `i2f.spring.redis.enable` | Boolean | `true` | 序列化器/`@EnableRedisRepositories` 总开关 |
| `i2f.spring.redis.date-format` | String | `yyyy-MM-dd HH:mm:ss SSS` | Jackson 序列化 `ObjectMapper` 的日期格式 |
| `i2f.spring.redis.redis-template.enable` | Boolean | `true` | 是否装配 `RedisTemplate<String,Object>` |
| `i2f.spring.redis.redis-cache.enable` | Boolean | `true` | 是否装配 `IRedisClient`+`RedisCache` |
| `i2f.spring.redis.redis-cache.client-prefix` | String | 无 | `SpringRedisClient` key 前缀 |
| `i2f.spring.redis.redis-cache.cache-prefix` | String | 无 | `RedisCache` key 前缀（叠加于 client 前缀之上） |
| `i2f.spring.redis.lettuce.heart-beat.enable` | Boolean | `true` | 是否启用 Lettuce 保活心跳 |
| `i2f.spring.redis.lettuce.heart-beat.init-delay-seconds` | Long | `30` | 首次心跳延迟秒数 |
| `i2f.spring.redis.lettuce.heart-beat.rate-seconds` | Long | `30` | 心跳周期秒数 |

## 模块特性总结

- **分层清晰**：序列化器 / 模板 / 缓存客户端 / 心跳四个关注点各拆一个配置类，可按开关单独裁剪。
- **对接 i2f 缓存抽象**：不止装配 `RedisTemplate`，还把 Spring 实现适配为 i2f 标准 `RedisCache`/`IRedisClient`，与生态其它缓存组件同构。
- **可读 key**：模板统一 String-key + Jackson-value，Redis 可视化工具中 key/中文值不再二进制。
- **保活兜底**：针对 Lettuce 长空闲 TCP 重传假死提供 `validateConnection` 心跳，并在容器关闭时优雅停线程。
- **Bean 可缺省让位**：序列化器、客户端、缓存均带 `@ConditionalOnMissingBean`，不粗暴覆盖使用方自定义实现。

## 模块瑕疵或错误

> 以下为按源码静态阅读标注的潜在问题，仅作提示、未运行实证。

1. **心跳线程一旦抛异常即永久停摆**：`run()`→`heartBeat()` 调 `factory.validateConnection()` 无 try/catch，而 `ScheduledExecutorService.scheduleAtFixedRate` 在任务抛出未捕获异常后会**取消后续所有执行**；一次瞬时 Redis 连接失败即令保活彻底失效，直到重启——恰与其"防假死"目的相悖，为最实质缺陷。
2. **开关不可独立关停（强依赖链）**：`RedisTemplateAutoConfiguration`/`RedisCacheConfiguration` 以 `@Autowired`（默认 required）依赖 `RedisAutoConfiguration` 产出的 `Jackson2JsonRedisSerializer`；若关闭 `i2f.spring.redis.enable` 却保留子开关默认 `true`，则所依赖序列化器 Bean 缺失导致启动失败。同理缓存层强依赖模板层的 `RedisTemplate`。
3. **`redisStringKeyTemplate` 缺 `@ConditionalOnMissingBean`**：与本类其它 Bean 相反，它无条件产出第二个 `RedisTemplate<String,Object>`，与 Boot 自带 `RedisAutoConfiguration` 的 `redisTemplate`/`StringRedisTemplate` 叠加，消费端按类型注入 `RedisTemplate` 时易触发多候选歧义。
4. **4 个自动配置类均无 `@Configuration`**：仅靠被登记为自动配置类以"轻量模式"生效，`@Bean` 方法间不走 CGLIB 代理，语义脆弱且依赖导入机制兜底。
5. **`enableDefaultTyping(NON_FINAL)` 已废弃且有反序列化安全隐患**：`Jackson2JsonRedisSerializer` 开启默认类型信息，既有已知多态 gadget 攻击面，又将 Redis 中数据与具体类名耦合，类重构即读取失败。
6. **编码链存在重复 Jackson 序列化**：`RedisCache` 的 encoder 已把对象转 JSON 字符串，该字符串再经模板 value 序列化器（同为 Jackson）落库，读写各多一次编解码，冗余且低效。
7. **`@Data` 误用于配置类**：`RedisCacheConfiguration`/`LettuceRedisHeartbeatConfiguration` 用 `@Data` 会为注入的 `RedisTemplate`/`RedisConnectionFactory`/`ScheduledExecutorService` 生成 `equals`/`hashCode`/`toString`，噪音大且可能触发不必要初始化。
8. **`RedisAutoConfiguration.dateFormat` 无 `@Data`/setter**：字段为包级私有且无读写方法，`date-format` 绑定仅靠 Spring Boot 字段直写兜底，与另两个用 `@Data` 的配置类风格不一致。
9. **`@EnableRedisRepositories` 无条件开启**：只要总开关激活就强制启用 Spring Data Redis 仓库扫描（基包默认 `i2f.springboot.redis`），对仅需序列化器/心跳的使用方属多余耦合。
10. **缺 `@ConditionalOnClass` 类存在保护**：除心跳类外，其余 3 个直接引用 spring-data-redis/Jackson 类型，而 data-redis 为 provided；未自备驱动时加载这些自动配置类会 `NoClassDefFoundError` 而非优雅退避。
11. **元数据 hints 模板残留**：`additional-spring-configuration-metadata.json` 的 `hints` 为 `server.servlet.jsp.class-name`、`server.tomcat.accesslog.encoding` 等与 Redis 无关的遗留项。
