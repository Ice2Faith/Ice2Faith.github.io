# i2f-springcloud 模块详细列表

i2f-springcloud 提供 SpringCloud 微服务治理相关的自动配置 Starter。

## 完整子模块列表

### 注册中心/配置中心

| 模块                                              | 说明                      |
|-------------------------------------------------|-------------------------|
| `i2f-springcloud-alibaba-nacos-starter`         | Nacos 注册/配置中心           |
| `i2f-springcloud-netflix-eureka-server-starter` | Eureka 服务端              |
| `i2f-springcloud-netflix-eureka-client-starter` | Eureka 客户端              |
| `i2f-springcloud-consul-starter`                | Consul 注册/配置中心          |
| `i2f-springcloud-config-server-starter`         | Spring Cloud Config 服务端 |
| `i2f-springcloud-config-client-starter`         | Spring Cloud Config 客户端 |

### 服务网关

| 模块                                     | 说明                   |
|----------------------------------------|----------------------|
| `i2f-springcloud-gateway-starter`      | Spring Cloud Gateway |
| `i2f-springcloud-gateway-swl-starter`  | Gateway SWL 增强       |
| `i2f-springcloud-netflix-zuul-starter` | Netflix Zuul 网关      |

### 服务调用

| 模块                                          | 说明                        |
|---------------------------------------------|---------------------------|
| `i2f-springcloud-netflix-openfeign-starter` | OpenFeign 声明式调用           |
| `i2f-springcloud-netflix-ribbon-starter`    | Ribbon 客户端负载均衡            |
| `i2f-springcloud-loadbalancer-starter`      | Spring Cloud LoadBalancer |

### 熔断降级

| 模块                                         | 说明            |
|--------------------------------------------|---------------|
| `i2f-springcloud-alibaba-sentinel-starter` | Sentinel 熔断降级 |
| `i2f-springcloud-netflix-hystrix-starter`  | Hystrix 熔断器   |

### 分布式事务

| 模块                                      | 说明          |
|-----------------------------------------|-------------|
| `i2f-springcloud-alibaba-seata-starter` | Seata 分布式事务 |

### 服务发现

| 模块                                         | 说明      |
|--------------------------------------------|---------|
| `i2f-springcloud-discovery-starter`        | 服务发现客户端 |
| `i2f-springcloud-discovery-server-starter` | 服务发现服务端 |

### 链路追踪

| 模块                               | 说明                  |
|----------------------------------|---------------------|
| `i2f-springcloud-sleuth-starter` | Spring Cloud Sleuth |
| `i2f-springcloud-zipkin-starter` | Zipkin 分布式追踪        |

### 监控管理

| 模块                                       | 说明                   |
|------------------------------------------|----------------------|
| `i2f-springcloud-actuator-starter`       | Spring Boot Actuator |
| `i2f-springcloud-actuator-admin-starter` | Actuator Admin 管理面板  |

### 动态刷新

| 模块                                | 说明     |
|-----------------------------------|--------|
| `i2f-springcloud-refresh-starter` | 配置动态刷新 |

### 测试模块

| 模块                 | 说明             |
|--------------------|----------------|
| `test-gateway-swl` | Gateway SWL 测试 |
