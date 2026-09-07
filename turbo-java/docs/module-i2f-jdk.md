# i2f-jdk 模块详细列表

i2f-jdk 是项目核心模块，包含约 150 个子模块，提供 Java 基础工具能力。

## 完整子模块列表

### 注解体系

| 模块                     | 说明                |
|------------------------|-------------------|
| `i2f-annotations`      | 注解聚合              |
| `i2f-annotations-api`  | API 层注解（接口、方法级注解） |
| `i2f-annotations-core` | 核心注解（基础元注解）       |
| `i2f-annotations-db`   | 数据库相关注解           |
| `i2f-annotations-ext`  | 扩展注解              |

### 数据结构与集合

| 模块                      | 说明     |
|-------------------------|--------|
| `i2f-array`             | 数组工具   |
| `i2f-tuple-std`         | 元组接口定义 |
| `i2f-tuple-impl`        | 元组实现   |
| `i2f-iterator`          | 迭代器增强  |
| `i2f-container`         | 容器抽象   |
| `i2f-container-builder` | 容器构建器  |
| `i2f-reference`         | 引用类型封装 |

### IO 体系

| 模块                  | 说明     |
|---------------------|--------|
| `i2f-io-file`       | 文件操作   |
| `i2f-io-filesystem` | 文件系统抽象 |
| `i2f-io-stream`     | 流操作封装  |

### 数据库与 JDBC

| 模块                           | 说明            |
|------------------------------|---------------|
| `i2f-database`               | 数据库抽象层        |
| `i2f-database-dialect`       | 数据库方言         |
| `i2f-database-type`          | 数据库类型定义       |
| `i2f-database-metadata-bean` | 元数据 Bean      |
| `i2f-database-metadata-data` | 元数据           |
| `i2f-database-metadata-impl` | 元数据实现         |
| `i2f-database-metadata-std`  | 元数据接口         |
| `i2f-jdbc-std`               | JDBC 接口定义     |
| `i2f-jdbc-impl`              | JDBC 实现       |
| `i2f-jdbc-data`              | JDBC 数据操作     |
| `i2f-jdbc-bql`               | BQL（绑定SQL）    |
| `i2f-jdbc-proxy`             | JDBC 代理       |
| `i2f-jdbc-proxy-xml`         | JDBC XML 代理配置 |
| `i2f-jdbc-procedure`         | 存储过程调用        |
| `i2f-bindsql`                | SQL 绑定        |
| `i2f-bindsql-page`           | SQL 分页        |
| `i2f-bindsql-stringify`      | SQL 字符串化      |
| `i2f-bql`                    | BQL 查询语言      |
| `i2f-rowset`                 | 行集处理          |

### 加密/编解码/哈希

| 模块                  | 说明        |
|---------------------|-----------|
| `i2f-crypto-std`    | 加密接口      |
| `i2f-crypto-impl`   | 加密实现      |
| `i2f-codec-std`     | 编解码接口     |
| `i2f-codec-impl`    | 编解码实现     |
| `i2f-sm-crypto`     | 国密算法      |
| `i2f-sm-crypto-swl` | 国密 SWL 适配 |
| `i2f-hash`          | 哈希算法      |

### 缓存

| 模块              | 说明      |
|-----------------|---------|
| `i2f-cache`     | 缓存接口    |
| `i2f-cache-std` | 缓存标准接口  |
| `i2f-lru-cache` | LRU 缓存  |
| `i2f-lru-map`   | LRU Map |

### 序列化

| 模块                   | 说明    |
|----------------------|-------|
| `i2f-serialize-std`  | 序列化接口 |
| `i2f-serialize-impl` | 序列化实现 |

### 网络/HTTP/代理

| 模块                   | 说明      |
|----------------------|---------|
| `i2f-network`        | 网络工具    |
| `i2f-http-proxy`     | HTTP 代理 |
| `i2f-proxy`          | 代理抽象    |
| `i2f-proxy-std`      | 代理接口    |
| `i2f-proxy-handlers` | 代理处理器   |

### 并发/线程/池

| 模块           | 说明   |
|--------------|------|
| `i2f-thread` | 线程工具 |
| `i2f-atomic` | 原子操作 |
| `i2f-lock`   | 锁机制  |
| `i2f-pool`   | 对象池  |
| `i2f-limit`  | 限流   |

### 日期时间

| 模块               | 说明     |
|------------------|--------|
| `i2f-datetime`   | 日期时间工具 |
| `i2f-clock-std`  | 时钟接口   |
| `i2f-clock-impl` | 时钟实现   |

### 文本/国际化/翻译

| 模块                        | 说明    |
|---------------------------|-------|
| `i2f-text`                | 文本处理  |
| `i2f-i18n`                | 国际化   |
| `i2f-translate`           | 翻译抽象  |
| `i2f-translate-en2zh`     | 英译中   |
| `i2f-translate-zh2pinyin` | 中文转拼音 |

### 图形图像

| 模块                | 说明    |
|-------------------|-------|
| `i2f-graphics`    | 图形抽象  |
| `i2f-graphics-2d` | 2D 图形 |
| `i2f-graphics-3d` | 3D 图形 |
| `i2f-image-std`   | 图像接口  |
| `i2f-image-impl`  | 图像实现  |
| `i2f-color`       | 颜色处理  |

### 反射/编译/脚本

| 模块                   | 说明         |
|----------------------|------------|
| `i2f-reflect`        | 反射工具       |
| `i2f-compiler`       | 动态编译器      |
| `i2f-script`         | 脚本引擎       |
| `i2f-javacode-graph` | Java 代码图分析 |

### 函数式/Lambda

| 模块                      | 说明        |
|-------------------------|-----------|
| `i2f-functional`        | 函数式接口     |
| `i2f-functional-lambda` | Lambda 增强 |
| `i2f-lambda`            | Lambda 工具 |

### 日志

| 模块            | 说明   |
|---------------|------|
| `i2f-log`     | 日志实现 |
| `i2f-log-std` | 日志接口 |

### 上下文/环境

| 模块                     | 说明    |
|------------------------|-------|
| `i2f-context-std`      | 上下文接口 |
| `i2f-context-impl`     | 上下文实现 |
| `i2f-environment-std`  | 环境接口  |
| `i2f-environment-impl` | 环境实现  |

### 事件/生命周期

| 模块              | 说明     |
|-----------------|--------|
| `i2f-event`     | 事件总线   |
| `i2f-lifecycle` | 生命周期管理 |

### 认证/安全

| 模块                   | 说明       |
|----------------------|----------|
| `i2f-authentication` | 认证框架     |
| `i2f-firewall`       | 防火墙/访问控制 |
| `i2f-otpauth`        | OTP 认证   |

### 压缩

| 模块                  | 说明   |
|---------------------|------|
| `i2f-compress-std`  | 压缩接口 |
| `i2f-compress-impl` | 压缩实现 |

### 校验

| 模块                 | 说明   |
|--------------------|------|
| `i2f-check`        | 参数校验 |
| `i2f-check-filter` | 过滤校验 |

### 数学/算法

| 模块         | 说明   |
|------------|------|
| `i2f-math` | 数学工具 |
| `i2f-algo` | 算法库  |

### 页面/分页

| 模块           | 说明   |
|--------------|------|
| `i2f-page`   | 分页模型 |
| `i2f-rowset` | 行集   |

### 其他工具模块

| 模块                         | 说明               |
|----------------------------|------------------|
| `i2f-agent`                | Java Agent       |
| `i2f-ai-std`               | AI 接口            |
| `i2f-ai-rest-openai`       | OpenAI REST 调用   |
| `i2f-bytes`                | 字节操作             |
| `i2f-code`                 | 编码/代码生成          |
| `i2f-comparator`           | 比较器              |
| `i2f-console-color`        | 控制台颜色            |
| `i2f-data-processor`       | 数据处理器            |
| `i2f-design-pattern`       | 23种设计模式          |
| `i2f-detegate`             | 委托模式             |
| `i2f-dict`                 | 字典               |
| `i2f-enums`                | 枚举工具             |
| `i2f-features`             | 特性开关             |
| `i2f-form`                 | 表单               |
| `i2f-form-url-encoded`     | URL 编码表单         |
| `i2f-geo`                  | 地理位置             |
| `i2f-invokable`            | 可调用对象            |
| `i2f-jvm`                  | JVM 工具           |
| `i2f-launcher`             | 启动器              |
| `i2f-match`                | 匹配工具             |
| `i2f-match-std`            | 匹配接口             |
| `i2f-mixins`               | Mixin 混入         |
| `i2f-native-core`          | 原生调用核心           |
| `i2f-native-windows`       | Windows 原生       |
| `i2f-native-windows-easyx` | Windows EasyX 图形 |
| `i2f-number-idcard`        | 身份证号             |
| `i2f-os`                   | 操作系统             |
| `i2f-packet`               | 数据包              |
| `i2f-properties`           | Properties 工具    |
| `i2f-resources`            | 资源加载             |
| `i2f-resp`                 | 统一响应             |
| `i2f-robot`                | 机器人              |
| `i2f-search`               | 搜索               |
| `i2f-spi`                  | SPI 服务发现         |
| `i2f-std-const`            | 标准常量             |
| `i2f-streaming`            | 流式处理             |
| `i2f-swl`                  | SWL 核心           |
| `i2f-swl-std`              | SWL 接口           |
| `i2f-template-render`      | 模板渲染             |
| `i2f-trace`                | 链路追踪             |
| `i2f-trace-mdc`            | MDC 追踪           |
| `i2f-typeof`               | 类型判断             |
| `i2f-uid-std`              | UID 接口           |
| `i2f-uid-impl`             | UID 实现           |
| `i2f-unsafe`               | Unsafe 操作        |
| `i2f-verifycode`           | 验证码              |
| `i2f-workflow`             | 工作流              |
| `i2f-xml`                  | XML 处理           |
| `i2f-jdk-all`              | 全量聚合包            |

### 测试模块

| 模块              | 说明   |
|-----------------|------|
| `test-features` | 特性测试 |
