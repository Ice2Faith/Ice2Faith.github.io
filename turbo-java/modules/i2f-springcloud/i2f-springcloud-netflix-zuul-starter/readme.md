# i2f-springcloud-netflix-zuul-starter

## 模块路径

`i2f-springcloud/i2f-springcloud-netflix-zuul-starter`

## 模块概述

Spring Cloud 组中面向 **Netflix Zuul 1.x（边缘网关/反向代理）** 的「装配 Starter」（本组第 19 个建档模块，**2 个 Java 源文件（25 + 50 行）+ 4 个资源文件**，无任何 i2f 内部 compile 依赖）。

`ZuulAutoConfiguration` 类体零字段，唯一功能由类级 `@EnableZuulProxy` 注解提供——触发 Spring Cloud Netflix Zuul 的路由/代理自动配置（内置 Ribbon 负载均衡、Host Routing Filter 链、actuator 路由端点等），再由 `i2f.springcloud.zuul.enable` 布尔门统一控制是否启用。与同组 `netflix-eureka-client/server`、`netflix-hystrix` 的纯注解代理不同，本模块**额外携带一个真实的自定义过滤器** `ZuulResponseCharsetFilter`（`extends ZuulFilter`，`pre` 类型，order 0），用于在响应写出前统一设置字符编码，是本组 Netflix 薄壳件中少见的「带实际增强逻辑」的件。

**本件与 `netflix-hystrix-starter`、`netflix-ribbon-starter` 同属「Hoxton 版本时间胶囊」**：模块级自行声明 `<dependencyManagement>` 硬钉 `spring-boot:2.3.7.RELEASE` / `spring-cloud:Hoxton.SR12`，与根 pom 的 `2.7.18` / `2021.0.8` 严重背离。Zuul 1.x 自 Spring Cloud 2020.0 起已被官方移入维护模式并推荐迁移至 Spring Cloud Gateway，`spring-cloud-starter-netflix-zuul` 在根 BOM `2021.0.8` 中不再纳管，本模块通过回退 Hoxton BOM 强行使 artifact 可解析。

## 模块依赖

| 依赖 | scope | 说明 |
| --- | --- | --- |
| `org.projectlombok:lombok` | compile（默认） | `@Data/@Slf4j/@NoArgsConstructor` 注解处理 |
| `org.springframework.boot:spring-boot-starter` | provided + optional | 自动装配基础，标准可选 |
| `org.springframework.boot:spring-boot-configuration-processor` | provided + optional | `@ConfigurationProperties` 元数据生成 |
| `org.springframework.cloud:spring-cloud-starter-netflix-zuul` | **provided（未标 optional）** | Zuul 1.x 网关能力，版本由**模块级 Hoxton.SR12 BOM** 治理（非根 pom） |

## 模块设计

```mermaid
graph TB
    A[ZuulAutoConfiguration<br/>@EnableZuulProxy 布尔门代理] -->|@Import 生效| B[官方 Zuul 自动配置<br/>路由/Filter 链/Ribbon 代理]
    C[ZuulResponseCharsetFilter<br/>extends ZuulFilter pre/0] -->|登记为自动配置类| D[加入 Zuul Filter 链]
    E[spring.factories + AutoConfiguration.imports<br/>双通道登记 A、C] --> A
    E --> C
    F[@ConditionalOnExpression zuul.enable] --> A
    G[@ConditionalOnExpression response-charset-filter.enable] --> C
```

## 模块目的

为需要以 Zuul 1.x 作为边缘网关的 i2f 应用提供「一键开关 + 统一响应编码」的装配入口：引入本件即可获得 `@EnableZuulProxy` 能力，并通过 `ZuulResponseCharsetFilter` 规避 Zuul 转发响应中文乱码这一高频痛点。

## 模块功能

- `ZuulAutoConfiguration`：`@EnableZuulProxy` 布尔门代理，`i2f.springcloud.zuul.enable:true` 控制 Zuul 网关启停。
- `ZuulResponseCharsetFilter`：`ZuulFilter`（`pre` 类型、`filterOrder()` 返回 0、`shouldFilter()` 恒 `true`），`run()` 中 `response.setCharacterEncoding(charset)`，`charset` 字段默认 `UTF-8`，由 `i2f.springcloud.zuul.response-charset-filter.charset` 可配。
- 双通道自动装配登记（`spring.factories` + `AutoConfiguration.imports`），两文件均同时登记 `ZuulResponseCharsetFilter` 与 `ZuulAutoConfiguration`。

## 模块主要使用方法

```xml
<dependencies>
    <dependency>
        <groupId>i2f.turbo</groupId>
        <artifactId>i2f-springcloud-netflix-zuul-starter</artifactId>
    </dependency>
    <!-- provided 不传递，须自行引入官方 Zuul（且版本须落到 Hoxton 线）-->
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-netflix-zuul</artifactId>
    </dependency>
</dependencies>
```

配合 `application.properties`：`i2f.springcloud.zuul.enable=true`、`i2f.springcloud.zuul.response-charset-filter.enable=true`、`...charset=UTF-8`，以及原生 `zuul.*` 路由配置（如 sample 中 `zuul.sensitive-headers=`）。

## 模块特性总结

- 类级注解 `@Configuration` 正确存在（不同于 gateway 族的 lite 模式），`@Data @NoArgsConstructor` 挂在零字段类上。
- 是本组 Netflix 薄壳件中**少数带真实增强逻辑**的件（`ZuulResponseCharsetFilter`）。
- 与 hystrix/ribbon 共用「模块级 Hoxton BOM 覆盖根治理」的危险模式。

## 模块瑕疵或错误（实证）

1. **【架构级·版本时间胶囊】模块级 BOM 覆盖根治理**：pom L15-41 自钉 `spring-boot:2.3.7.RELEASE` / `spring-cloud:Hoxton.SR12`，与根 pom `2.7.18` / `2021.0.8` 冲突。Zuul 1.x 已自 Spring Cloud 2020.0+ 进入维护模式，本件编译期依赖链与项目运行时主版本不兼容（同 hystrix/ribbon 族）。
2. **【高危·崩溃族】`spring-cloud-starter-netflix-zuul` provided 未标 optional 且不传递**（pom L62-66），而 `ZuulAutoConfiguration` 类级 `@EnableZuulProxy`、`ZuulResponseCharsetFilter` `extends ZuulFilter`（`com.netflix.zuul.*`）均直接引用 Zuul class；仅引本 starter 而未自引官方 Zuul 时，自动配置类装载即 `NoClassDefFoundError` 启动崩溃——同 gateway-starter / actuator-admin / config-server / consul / eureka-client / hystrix 族。
3. **缺 `@ConditionalOnClass` 兜底**：两配置类仅有 `@ConditionalOnExpression` 布尔门，无 `@ConditionalOnClass(ZuulFilter/EnableZuulProxy)` 守护，使「未引 Zuul 时静默跳过」无法成立，直接触发缺陷 2 的崩溃。
4. **`ZuulResponseCharsetFilter` 被登记为自动配置类而非普通 Bean**：`spring.factories`/`AutoConfiguration.imports` 把一个 `@Component` 的 `ZuulFilter` 列入 `EnableAutoConfiguration` 名单——自动配置位应放 `@Configuration` 类，过滤器本身应经 `@Bean` 暴露。此处依赖「自动配置类自身会被注册为 Bean」的副作用生效，语义误用（同 gateway 组 `RequestQueryRepeatProperties` 的 `@Configuration` 挂属性类误用族）。
5. **`@Component` + 自动配置双通道登记重叠**：`ZuulResponseCharsetFilter` 同时带 `@Component` 又被登记进 `EnableAutoConfiguration`。若使用方主类恰在 `i2f.springcloud.netflix.zuul.filter` 扫描路径内（罕见）将双注册；正常情形下 `@Component` 因 starter jar 不被组件扫描而形同冗余注解。
6. **元数据登记严重不全**：`additional-spring-configuration-metadata.json` 仅登记 `i2f.springcloud.zuul.enable`，而 `ZuulResponseCharsetFilter` 实际绑定的 `i2f.springcloud.zuul.response-charset-filter.enable` 与 `...charset` **两个功能键均未登记**（sample 已在用却无 IDE 提示/校验），是本组「代码实读键 vs 元数据登记键」背离族的新实例。
7. **`hints` 为拷贝死条目**：metadata L18-41 的 `server.servlet.jsp.class-name`、`server.tomcat.accesslog.encoding` 与本模块零相关（与 gateway-starter/其它薄壳同一份拷贝模板残留）。
8. **`ZuulAutoConfiguration` 类体零字段 + `@ConfigurationProperties` 空挂**：`@ConfigurationProperties(prefix="i2f.springcloud.zuul")` 挂在无任何字段的类上，`@Data` 生成无意义方法，唯一 `enable` 由 `@ConditionalOnExpression` 的 SpEL 直读、并非绑定字段（与 loadbalancer/eureka/hystrix/ribbon 同病）。
9. **`spring.version` 死属性**：pom L16 声明 `5.2.12.RELEASE` 后从未被引用（Boot BOM 已管 Spring 版本），纯冗余（同 hystrix/ribbon）。
10. **`run()` 恒返回 `null` 且 `shouldFilter()` 恒 `true`**：`pre` 过滤器无条件对每个请求 `setCharacterEncoding`，未区分响应是否已含自定义 `Content-Type charset`，可能对二进制/下载类透传响应做无意义的编码设置（无实质危害但缺乏精细化判断）。
11. **开关语义与官方重叠且名不副实**：`i2f.springcloud.zuul.enable=false` 仅移除本件 `@EnableZuulProxy` 代理；若应用主类另有 `@EnableZuulProxy` 则本开关无法关闭 Zuul。真正关闭须官方 `zuul.*` / 依赖排除。

## 生态位置

- 登记：父 `i2f-springcloud/pom.xml` L34（module）、根 `pom.xml` L1602（dependencyManagement）。
- 消费方：**全仓零真实 compile 消费方，纯孤岛**（grep 仅命中本模块自身 pom、父聚合、根 DM 三处）。
- 组内定位：Spring Cloud 组「服务网关」子域的 **Zuul 1.x（Servlet 阻塞式）分支**，与本组 `gateway-starter`（Spring Cloud Gateway，响应式）互为「旧/新网关」对偶；`ZuulResponseCharsetFilter` 是 Servlet 侧编码兜底，`gateway-swl-starter` 则是响应式侧加解密对偶。
- 迁移建议：Zuul 1.x 与 `netflix-hystrix`、`netflix-ribbon` 同属 Spring Cloud 2020.0+ 已弃用的 Netflix 旧栈，新网关能力应统一到 `i2f-springcloud-gateway-starter` / 官方 Spring Cloud Gateway。
