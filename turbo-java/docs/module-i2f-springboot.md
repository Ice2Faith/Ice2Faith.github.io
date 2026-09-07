# i2f-springboot 模块详细列表

i2f-springboot 提供 SpringBoot 自动配置 Starter，开箱即用。

## 完整子模块列表

### 基础 Starter

| 模块                              | 说明                  |
|---------------------------------|---------------------|
| `i2f-springboot-spring-starter` | Spring 基础能力 Starter |
| `i2f-springboot-swl-starter`    | SWL 抽象层 Starter     |

### Web 与通信

| 模块                                              | 说明                 |
|-------------------------------------------------|--------------------|
| `i2f-springboot-websocket-starter`              | WebSocket 支持       |
| `i2f-springboot-http-proxy-starter`             | HTTP 代理配置          |
| `i2f-springboot-nginx-rtmp-auth-server-starter` | Nginx RTMP 流媒体认证服务 |
| `i2f-springboot-ssh-tunnel-starter`             | SSH 隧道             |

### 安全与认证

| 模块                                        | 说明                 |
|-------------------------------------------|--------------------|
| `i2f-springboot-security-starter`         | Spring Security 集成 |
| `i2f-springboot-shiro-starter`            | Apache Shiro 集成    |
| `i2f-springboot-auth-starter`             | 认证框架 Starter       |
| `i2f-springboot-totp-starter`             | TOTP 动态口令          |
| `i2f-springboot-encrypt-property-starter` | 配置文件加密             |

### 数据库与 ORM

| 模块                                          | 说明             |
|---------------------------------------------|----------------|
| `i2f-springboot-mybatis-starter`            | MyBatis ORM 集成 |
| `i2f-springboot-dynamic-datasource-starter` | 动态数据源切换        |
| `i2f-springboot-jdbc-bql-starter`           | BQL JDBC 集成    |

### 缓存

| 模块                                | 说明               |
|-----------------------------------|------------------|
| `i2f-springboot-redis-starter`    | Redis 缓存         |
| `i2f-springboot-redisson-starter` | Redisson 分布式锁与缓存 |

### 消息队列

| 模块                                | 说明              |
|-----------------------------------|-----------------|
| `i2f-springboot-kafka-starter`    | Apache Kafka 集成 |
| `i2f-springboot-rabbitmq-starter` | RabbitMQ 集成     |

### 定时任务

| 模块                               | 说明              |
|----------------------------------|-----------------|
| `i2f-springboot-quartz-starter`  | Quartz 定时任务     |
| `i2f-springboot-xxl-job-starter` | XXL-JOB 分布式任务调度 |

### AI

| 模块                          | 说明      |
|-----------------------------|---------|
| `i2f-springboot-ai-starter` | AI 能力集成 |

### RPC/微服务

| 模块                             | 说明                  |
|--------------------------------|---------------------|
| `i2f-springboot-dubbo-starter` | Apache Dubbo RPC 集成 |

### 对象存储

| 模块                                 | 说明         |
|------------------------------------|------------|
| `i2f-springboot-oss-minio-starter` | MinIO 对象存储 |

### JSON 处理

| 模块                                        | 说明           |
|-------------------------------------------|--------------|
| `i2f-springboot-jackson-sensible-starter` | Jackson 增强配置 |

### API 文档

| 模块                                | 说明              |
|-----------------------------------|-----------------|
| `i2f-springboot-swagger2-starter` | Swagger2 API 文档 |

### 运维与监控

| 模块                                 | 说明                                                                             |
|------------------------------------|--------------------------------------------------------------------------------|
| `i2f-springboot-ops-starter`       | 运维控制台 Starter（132 Java 文件，13+ 功能模块，国密安全传输，详见 [ops-starter.md](ops-starter.md)） |
| `i2f-springboot-trace-mdc-starter` | 链路追踪 MDC（全链路 TraceId 传递，10 个自动配置，详见 [trace-mdc.md](trace-mdc.md)）              |
| `i2f-springboot-limit-starter`     | 接口限流                                                                           |

### 流程引擎

| 模块                                | 说明           |
|-----------------------------------|--------------|
| `i2f-springboot-activity-starter` | Activity 工作流 |
| `i2f-springboot-xproc4j-starter`  | XProc 流程处理   |

### 分布式组件

| 模块                                 | 说明           |
|------------------------------------|--------------|
| `i2f-springboot-zookeeper-starter` | ZooKeeper 集成 |

### 测试模块

| 模块                 | 说明             |
|--------------------|----------------|
| `test-springboot`  | SpringBoot 测试  |
| `test-swl-starter` | SWL Starter 测试 |
| `test-xxl-job`     | XXL-JOB 测试     |
