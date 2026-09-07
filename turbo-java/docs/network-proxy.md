# i2f-network & i2f-http-proxy — 网络通信与声明式 HTTP 客户端

## 概述

`i2f-network` 是项目的基础网络通信模块，提供零外部依赖的 HTTP 客户端、TCP/UDP 通信（BIO + NIO）、RMI
远程调用、网络扫描等能力。`i2f-http-proxy` 是基于 `i2f-network` 构建的声明式 HTTP 客户端框架，通过注解驱动 + JDK 动态代理实现类似
Feign 的接口式 REST 调用。

两个模块共同构成项目的网络通信基础设施层，完全兼容 JDK8，无第三方网络库依赖。

## 模块信息

| 属性             | i2f-network   | i2f-http-proxy             |
|----------------|---------------|----------------------------|
| **ArtifactId** | `i2f-network` | `i2f-http-proxy`           |
| **父模块**        | `i2f-jdk`     | `i2f-jdk`                  |
| **版本**         | `1.0-jdk8`    | `1.0-jdk8`                 |
| **包路径**        | `i2f.net.*`   | `i2f.network.http.proxy.*` |
| **源文件数**       | 64            | 15                         |
| **定位**         | 基础网络通信工具      | 声明式 HTTP 客户端               |

## 依赖关系

### i2f-network 依赖

```
i2f-network
├── i2f-serialize-impl    -- 序列化实现（JSON/XML）
├── i2f-io-stream         -- 流工具
├── i2f-form-url-encoded  -- URL 编码
└── lombok
```

### i2f-http-proxy 依赖

```
i2f-http-proxy
├── i2f-network           -- 网络通信基础
├── i2f-proxy             -- 代理基础设施
├── i2f-annotations-core  -- 核心注解（@Name）
├── i2f-environment-std   -- 环境接口（变量替换）
└── lombok
```

## i2f-network 架构

### 模块结构

```
i2f.net
├── NetworkUtil                    -- 网络接口工具（获取可用网卡/IP）
├── http/                          -- HTTP 客户端
│   ├── HttpUtil                   -- HTTP 工具入口
│   ├── consts/                    -- 常量定义
│   │   ├── CharsetConstants       -- 字符集常量
│   │   ├── ContentTypeConstants   -- Content-Type 常量
│   │   ├── HttpHeaderConstants    -- HTTP 头常量
│   │   ├── HttpMethodConstants    -- HTTP 方法常量（GET/POST/PUT/DELETE）
│   │   └── HttpStatusConstants    -- HTTP 状态码常量
│   ├── data/                      -- 数据模型
│   │   ├── HttpRequest            -- HTTP 请求（链式 API）
│   │   ├── HttpResponse           -- HTTP 响应（流式读取）
│   │   ├── HttpHeaders            -- HTTP 头（大小写不敏感）
│   │   └── MultipartFile          -- 文件上传
│   ├── impl/                      -- 处理器实现
│   │   ├── HttpUrlConnectProcessor       -- 基于 HttpURLConnection 的处理器
│   │   ├── BasicHttpProcessorProvider    -- 高层便捷 API（get/postJson/postForm）
│   │   ├── HttpFormUrlEncodedRequestBodyHandler  -- Form 请求体
│   │   ├── HttpJsonRequestBodyHandler          -- JSON 请求体
│   │   ├── HttpXmlRequestBodyHandler           -- XML 请求体
│   │   ├── HttpMultipartFormDataRequestBodyHandler -- Multipart 请求体
│   │   ├── HttpRawBytesRequestBodyHandler      -- 原始字节请求体
│   │   └── HttpRawInputStreamRequestBodyHandler -- 流式请求体
│   ├── interfaces/                  -- 核心接口
│   │   ├── IHttpProcessor           -- HTTP 处理器接口
│   │   ├── HttpProcessorProvider    -- 高层 HTTP 提供者接口
│   │   ├── IHttpRequestBodyHandler   -- 请求体写入处理器
│   │   ├── IHttpResponseBodyHandler  -- 响应体读取处理器
│   │   └── IHttpResponseExtractor   -- 响应提取器（函数式）
│   └── rest/                        -- REST 客户端抽象
│       ├── IRestClient              -- REST 客户端接口
│       ├── data/
│       │   ├── RestHttpRequest      -- REST 请求
│       │   └── RestHttpResponse<T>  -- REST 响应（泛型）
│       └── impl/
│           └── HttpProcessorRestClient -- 基于 IHttpProcessor 的 REST 实现
├── tcp/                           -- BIO TCP
│   ├── TcpClient                  -- TCP 客户端
│   ├── TcpServer                  -- TCP 服务端（多线程 accept）
│   ├── TcpClientHandler           -- 客户端事件回调
│   ├── TcpServerHandler           -- 服务端事件回调
│   └── impl/                      -- 会话处理器
│       ├── TcpClientSessionHandler
│       └── TcpServerSessionHandler
├── nio/tcp/                       -- NIO TCP
│   ├── TcpClient                  -- NIO TCP 客户端（Selector）
│   ├── TcpServer                  -- NIO TCP 服务端（Selector）
│   ├── ITcpClientListener         -- 客户端事件监听
│   ├── ITcpServerListener         -- 服务端事件监听
│   ├── ITcpConnector              -- 连接器接口
│   ├── ITcpListener               -- 通用监听
│   └── NioSocketClosedResolver    -- NIO 连接关闭处理
├── udp/                           -- BIO UDP
│   ├── UdpClient                  -- UDP 客户端
│   ├── UdpServer                  -- UDP 服务端（独立接收线程）
│   ├── UdpClientHandler           -- 客户端事件回调
│   └── UdpServerHandler           -- 服务端事件回调
├── nio/udp/                       -- NIO UDP
│   ├── UdpClient                  -- NIO UDP 客户端
│   ├── UdpServer                  -- NIO UDP 服务端
│   ├── IUdpConnector              -- 连接器接口
│   └── IUdpListener               -- 事件监听
├── rmi/                           -- RMI 远程调用
│   ├── RmiClient                  -- RMI 客户端（lookup）
│   ├── RmiServer                  -- RMI 服务端（registry + bind）
│   ├── RmiService                 -- 服务接口标记
│   └── RmiServiceImpl             -- 服务实现标记
└── scan/                          -- 网络扫描
    └── NetScanner                 -- 端口/LAN 扫描器（多线程）
```

### HTTP 客户端核心设计

#### 分层架构

```
高层便捷 API
  BasicHttpProcessorProvider (get/postJson/postForm...)
      ↓ 委托
  IHttpProcessor (核心处理接口)
      ↓ 默认实现
  HttpUrlConnectProcessor (基于 HttpURLConnection)
      ↓ 根据 Content-Type 选择
  IHttpRequestBodyHandler (请求体序列化)
      ├── HttpJsonRequestBodyHandler
      ├── HttpFormUrlEncodedRequestBodyHandler
      ├── HttpXmlRequestBodyHandler
      ├── HttpMultipartFormDataRequestBodyHandler
      ├── HttpRawBytesRequestBodyHandler
      └── HttpRawInputStreamRequestBodyHandler
```

#### IHttpProcessor — 核心处理器接口

提供两种调用模式：

- **阻塞模式** (`http2Local`): 等待所有数据传输到本地/临时文件，响应流为本地流
- **非阻塞模式** (`http`): 不等待数据传输，适用于流式处理场景

```java
public interface IHttpProcessor {
    // 阻塞：数据全部传输到本地
    default HttpResponse http2Local(HttpRequest request) throws IOException;

    // 非阻塞：流式处理
    default HttpResponse http(HttpRequest request) throws IOException;

    // 带提取器的非阻塞调用
    <T> T http(HttpRequest request, IHttpResponseExtractor<T> extractor) throws IOException;
}
```

#### IHttpProcessor 全项目实现一览

项目中共有 **4 个** `IHttpProcessor` 实现类，分布在不同模块中，覆盖从零依赖到第三方库集成的全场景需求：

| # | 实现类                       | 所属模块                       | 底层技术                        | 外部依赖         |
|---|---------------------------|----------------------------|-----------------------------|--------------|
| 1 | `HttpUrlConnectProcessor` | `i2f-network`              | `HttpURLConnection`（JDK 内置） | 无            |
| 2 | `HttpClientHttpProcessor` | `i2f-extension-httpclient` | Apache HttpClient           | `httpclient` |
| 3 | `OkHttpHttpProcessor`     | `i2f-extension-okhttp`     | OkHttp3                     | `okhttp`     |
| 4 | `SpringWebHttpProcessor`  | `i2f-spring-web`           | Spring `RestTemplate`       | `spring-web` |

**1. HttpUrlConnectProcessor**（默认实现，零依赖）

- **位置**: `i2f-jdk/i2f-network` → `i2f.net.http.impl.HttpUrlConnectProcessor`
- **底层**: JDK 内置 `HttpURLConnection`
- **特点**: 项目默认 HTTP 处理器，`@RestClient` 注解的默认 `http` 值；支持 JSON/Form/XML/Multipart/原始字节/流 6
  种请求体格式；通过 `HttpUrlConnectCloser` 内部类管理流和连接的生命周期
- **适用场景**: 无第三方依赖的基础场景，JDK8 兼容

**2. HttpClientHttpProcessor**（Apache HttpClient 实现）

- **位置**: `i2f-extension/i2f-extension-httpclient` → `i2f.extension.httpclient.impl.HttpClientHttpProcessor`
- **底层**: Apache `CloseableHttpClient`
- **特点**: 支持连接超时/读取超时/重定向配置（通过 `RequestConfig`
  ）；每种请求方法（GET/POST/PUT/DELETE）独立构建对应的 `HttpUriRequest` 子类；通过 `HttpClientCloser`
  管理 `CloseableHttpClient` 生命周期；支持 JSON 序列化（`Json2Serializer`）和 XML 序列化（`Xml2Serializer`）
- **适用场景**: 需要 Apache HttpClient 连接池、重试、拦截器等高级特性

**3. OkHttpHttpProcessor**（OkHttp3 实现）

- **位置**: `i2f-extension/i2f-extension-okhttp` → `i2f.extension.okhttp.impl.OkHttpHttpProcessor`
- **底层**: OkHttp3 `OkHttpClient`
- **特点**: 支持外部注入 `OkHttpClient` 单例（推荐复用连接池）；默认超时配置：连接 30s、读取 5min；通过 `OkHttpCloser`
  管理 `Response` 生命周期；同样支持 6 种请求体格式（对应 `OkHttp*RequestBodyHandler` 系列）
- **适用场景**: 偏好 OkHttp 的项目，或需要与 OkHttp 生态（拦截器、缓存等）集成

**4. SpringWebHttpProcessor**（Spring RestTemplate 实现）

- **位置**: `i2f-spring/i2f-spring-web` → `i2f.spring.web.rest.SpringWebHttpProcessor`
- **底层**: Spring `RestTemplate`
- **特点**: 支持注入外部配置的 `RestTemplate` 实例（若未注入则自动创建）；重写了 `http(HttpRequest)`
  方法（默认走 `http2Local` 逻辑，将响应数据缓存到本地）；通过 `SpringWebAutoHttpRequestBodyHandler` 自动处理请求体序列化；响应头通过
  Spring `HttpHeaders` 与项目 `HttpHeaders` 互转
- **适用场景**: Spring 环境下，需要复用 `RestTemplate` 配置（消息转换器、拦截器等）

**切换实现方式**

在 `@RestClient` 注解中通过 `http` 属性指定处理器类：

```java
// 默认：JDK HttpURLConnection（零依赖）
@RestClient(url = "https://api.example.com")
public interface DefaultApi { ...
}

// 使用 Apache HttpClient
@RestClient(url = "https://api.example.com",
        http = HttpClientHttpProcessor.class)
public interface HttpClientApi { ...
}

// 使用 OkHttp
@RestClient(url = "https://api.example.com",
        http = OkHttpHttpProcessor.class)
public interface OkHttpApi { ...
}
```

也可通过 `HttpProcessorSupplier` 函数式接口动态提供处理器实例。

#### HttpRequest — 链式请求构建

```java
// GET 请求
HttpResponse resp = HttpRequest.doGet("https://api.example.com/data")
        .setParams(Map.of("key", "value"))
        .addHeader("Authorization", "Bearer xxx")
        .send();

// POST JSON
HttpResponse resp = HttpRequest.doPost("https://api.example.com/submit")
        .json()
        .setData(myObject)
        .send();

// 文件上传
HttpResponse resp = HttpRequest.doPost("https://api.example.com/upload")
        .multipart()
        .addFile(new File("test.jpg"))
        .send();
```

#### HttpResponse — 多种响应读取方式

| 方法                                     | 说明               |
|----------------------------------------|------------------|
| `getContentAsBytes()`                  | 读取为字节数组          |
| `getContentAsString()`                 | 读取为字符串（默认 UTF-8） |
| `getContentAsObject(processor, clazz)` | 反序列化为对象          |
| `saveAsFile(file)`                     | 保存为文件            |
| `transferTo(os)`                       | 转移到输出流           |
| `getErrorAsString()`                   | 读取错误流            |

#### HttpHeaders — 大小写不敏感的请求头

继承 `LinkedHashMap<String, ArrayList<String>>`，支持：

- 大小写不敏感的 header 名称查找与合并
- 链式 API：`set()`、`add()`、`contentType()`、`contentLength()`
- 多值 header 支持

#### BasicHttpProcessorProvider — 高层便捷 API

封装常用 HTTP 操作，提供类似 RestTemplate 的便捷方法：

| 方法类别      | 示例方法                                                                                     |
|-----------|------------------------------------------------------------------------------------------|
| GET       | `get(url)`, `getForString(url, charset)`, `getForObject(url, charset, clazz, processor)` |
| POST JSON | `postJson(url, data)`, `postJsonForString(...)`, `postJsonForObject(...)`                |
| POST Form | `postForm(url, data)`, `postFormForString(...)`, `postFormForObject(...)`                |

每个方法均支持 `params`（URL 参数）和 `header`（自定义请求头）的可选重载。

#### REST 客户端抽象

```java
// IRestClient - 类型安全的 REST 接口
public interface IRestClient {
    <T> RestHttpResponse<T> rest(RestHttpRequest request, Class<T> responseType);
}

// HttpProcessorRestClient - 基于 IHttpProcessor 的实现
// 自动 JSON 序列化/反序列化，UTF-8 编码
```

### TCP 通信

#### BIO TCP（`i2f.net.tcp`）

基于 `ServerSocket`/`Socket` 的传统阻塞式 TCP 通信：

- **TcpServer**: 支持绑定地址、端口、backlog，独立线程 accept 循环
- **TcpClient**: 支持连接/关闭生命周期管理
- **Handler 回调**: `onListening`、`onAccepting`、`onClientArrive`、`onClientException` 等

#### NIO TCP（`i2f.net.nio.tcp`）

基于 `Selector`/`SocketChannel` 的非阻塞 TCP 通信：

- **TcpServer**: 单 Selector 管理所有连接，`OP_ACCEPT` + `OP_READ` 事件驱动
- **TcpClient**: `OP_CONNECT` + `OP_READ` + `OP_WRITE` 事件驱动
- **客户端上下文管理**: `clientsMap` 维护每个连接的地址信息
- **连接关闭自动检测**: `NioSocketClosedResolver` 处理 IO 异常判断连接关闭

### UDP 通信

#### BIO UDP（`i2f.net.udp`）

- **UdpServer**: 独立接收线程，支持配置最大包大小（默认 65530）
- **UdpClient**: 无连接 UDP 发送，支持指定目标地址

#### NIO UDP（`i2f.net.nio.udp`）

基于 NIO 的 UDP 通信实现。

### RMI 远程调用

封装 Java RMI，简化服务端注册与客户端查找：

```java
// 服务端
RmiServer server = new RmiServer(1099);
server.

listen();
server.

bindByName("myService",myServiceImpl);

// 客户端
RmiClient client = new RmiClient(remoteAddr, 1099);
client.

connect();

MyService service = client.getServiceByName("myService");
```

支持两种寻址方式：

- **ByName**: 通过 Registry 的 `lookup`/`rebind`
- **ByPath**: 通过 `rmi://host:port/path` 格式的 `Naming` API

### 网络扫描

`NetScanner` 提供多线程网络扫描能力：

| 方法                                       | 说明                      |
|------------------------------------------|-------------------------|
| `getLocalUsefulInetAddresses()`          | 获取本机有效 IP 地址            |
| `portScan(addr, minPort, maxPort, pool)` | 端口扫描（多线程 Socket 连接）     |
| `lanScan(addr, minPort, maxPort, pool)`  | 局域网扫描（遍历 /24 网段 + 端口扫描） |
| `localScan(minPort, maxPort, pool)`      | 本机所有网卡局域网扫描             |

### 网络工具

`NetworkUtil` 提供网络接口发现能力：

- 获取可用网卡地址（排除回环、多播、虚拟网卡）
- 智能排序（物理网卡优先于虚拟网卡，IPv4 优先于 IPv6）
- 虚拟网卡识别（docker、vmware、veth 等）

---

## i2f-http-proxy 架构

### 设计理念

`i2f-http-proxy` 提供**声明式 HTTP 客户端**，通过定义 Java 接口 + 注解的方式描述 HTTP 请求，运行时通过 JDK
动态代理自动生成实现。设计理念类似 Feign，但深度集成项目内部体系，支持环境变量替换等特性。

### 核心组件

```
i2f.network.http.proxy.rest
├── annotations/                    -- 注解定义
│   ├── @RestClient                 -- 标记 REST 客户端接口（url/path/http/httpSupplier）
│   ├── @RestMapping                -- 通用路径+方法映射
│   ├── @RestGetMapping             -- GET 映射
│   ├── @RestPostMapping            -- POST 映射
│   ├── @RestPutMapping             -- PUT 映射
│   ├── @RestDeleteMapping          -- DELETE 映射
│   ├── @RestHeader                 -- 请求头参数绑定（name/value/param/attr）
│   ├── @RestHeaders                -- 类/方法级静态请求头声明
│   ├── @RestBody                   -- 请求体参数绑定
│   ├── @RestParam                  -- URL 参数绑定
│   └── @RestPathVariable           -- 路径变量绑定（{name} 占位符）
├── core/
│   └── RestClientProxyHandler      -- 动态代理核心处理器（394行）
├── HttpProcessorSupplier           -- HTTP 处理器提供者（函数式接口）
├── IHttpRequestCustomizer          -- 请求定制器（函数式接口）
└── RestClientProvider              -- 客户端工厂（创建代理实例）
```

### 注解体系

#### @RestClient — 接口级声明

```java

@RestClient(url = "https://api.example.com", path = "/v1")
public interface UserApi {
    // ...
}
```

| 属性             | 说明          | 默认值                       |
|----------------|-------------|---------------------------|
| `url`          | 基础 URL      | `""`                      |
| `path`         | 基础路径        | `""`                      |
| `http`         | HTTP 处理器类   | `HttpUrlConnectProcessor` |
| `httpSupplier` | HTTP 处理器提供者 | `HttpProcessorSupplier`   |

#### 方法映射注解

| 注解                   | HTTP 方法          | 作用域    |
|----------------------|------------------|--------|
| `@RestMapping`       | 自定义（`method` 属性） | 类 + 方法 |
| `@RestGetMapping`    | GET              | 类 + 方法 |
| `@RestPostMapping`   | POST             | 类 + 方法 |
| `@RestPutMapping`    | PUT              | 类 + 方法 |
| `@RestDeleteMapping` | DELETE           | 类 + 方法 |

#### 参数绑定注解

| 注解                  | 作用域 | 说明                                      |
|---------------------|-----|-----------------------------------------|
| `@RestHeader`       | 参数  | 绑定到请求头，支持 `name`/`value`/`param`/`attr` |
| `@RestBody`         | 参数  | 绑定到请求体                                  |
| `@RestParam`        | 参数  | 绑定到 URL 查询参数                            |
| `@RestPathVariable` | 参数  | 绑定到路径变量 `{name}`                        |

#### @RestHeaders — 静态请求头

```java
@RestHeaders({
        @RestHeader(name = "X-Api-Key", value = "${api.key}"),
        @RestHeader(name = "Authorization", param = "0", attr = "token")
})
```

支持环境变量替换（`${prop}` 或 `$!{prop}`）和参数属性提取（`param` + `attr`）。

### RestClientProxyHandler — 代理核心

核心处理流程：

```
1. 解析 @RestClient 获取基础 URL 和 HTTP 处理器
2. 解析方法上的映射注解（@RestGetMapping 等）确定路径和方法
3. 解析 @RestHeaders 类/方法级静态请求头
4. 遍历方法参数，根据注解分类处理：
   ├── @RestHeader → 添加到请求头
   ├── @RestBody → 设置为请求体
   ├── @RestPathVariable → 替换 URL 中的 {name}
   ├── @RestParam → 设置为 URL 参数
   ├── File/MultipartFile → 添加为文件上传
   ├── IHttpRequestCustomizer → 请求定制器
   └── IHttpResponseExtractor → 响应提取器
5. 环境变量替换（URL、路径、请求头值）
6. 执行 HTTP 请求
7. 根据返回类型自动转换响应：
   ├── HttpResponse → 直接返回
   ├── byte[] → 字节数组
   ├── InputStream → 本地临时文件流
   ├── String → 字符串
   └── 其他类型 → JSON 反序列化
```

### 环境变量替换

支持在 URL、路径、请求头值中使用环境变量占位符：

| 语法                | 说明                      |
|-------------------|-------------------------|
| `${prop}`         | 从 IEnvironment 获取属性值    |
| `${prop:default}` | 带默认值的属性获取               |
| `$!{prop}`        | 空值转为空字符串（null-to-empty） |

### 使用示例

```java
// 1. 定义接口
@RestClient(url = "${api.base-url}", path = "/api/v1")
@RestHeaders(@RestHeader(name = "X-Api-Key", value = "${api.key}"))
public interface UserApi {

    @RestGetMapping("/users/{id}")
    User getUser(@RestPathVariable("id") Long id);

    @RestPostMapping("/users")
    User createUser(@RestBody User user);

    @RestGetMapping("/users")
    List<User> listUsers(@RestParam("page") int page,
                         @RestParam("size") int size);

    @RestPostMapping("/users/{id}/avatar")
    String uploadAvatar(@RestPathVariable("id") Long id,
                        File avatarFile);
}

// 2. 创建客户端
RestClientProvider provider = new RestClientProvider();
UserApi api = provider.getClient(UserApi.class, jsonSerializer, environment);

// 3. 调用
User user = api.getUser(123L);
```

### 特殊参数类型

方法参数中可以直接传入以下特殊类型，代理会自动识别并处理：

| 类型                          | 作用                    |
|-----------------------------|-----------------------|
| `IHttpRequestCustomizer`    | 在请求发送前自定义 HttpRequest |
| `IHttpResponseExtractor<?>` | 自定义响应提取逻辑             |
| `File` / `MultipartFile`    | 自动添加为文件上传             |

---

## 源文件清单

### i2f-network（64 文件）

| 包路径                       | 文件                                        | 行数  | 说明                |
|---------------------------|-------------------------------------------|-----|-------------------|
| `i2f.net`                 | `NetworkUtil`                             | 113 | 网络接口工具            |
| `i2f.net.http`            | `HttpUtil`                                | 115 | HTTP 工具入口         |
| `i2f.net.http.consts`     | `CharsetConstants`                        | 14  | 字符集常量             |
|                           | `ContentTypeConstants`                    | 23  | Content-Type 常量   |
|                           | `HttpHeaderConstants`                     | 41  | HTTP 头常量          |
|                           | `HttpMethodConstants`                     | 13  | HTTP 方法常量         |
|                           | `HttpStatusConstants`                     | 87  | HTTP 状态码常量        |
| `i2f.net.http.data`       | `HttpHeaders`                             | 160 | HTTP 请求头          |
|                           | `HttpRequest`                             | 274 | HTTP 请求           |
|                           | `HttpResponse`                            | 137 | HTTP 响应           |
|                           | `MultipartFile`                           | 37  | 文件上传              |
| `i2f.net.http.impl`       | `BasicHttpProcessorProvider`              | 354 | 高层便捷 API          |
|                           | `HttpUrlConnectProcessor`                 | 168 | URLConnection 处理器 |
|                           | `HttpFormUrlEncodedRequestBodyHandler`    | 44  | Form 请求体          |
|                           | `HttpJsonRequestBodyHandler`              | 46  | JSON 请求体          |
|                           | `HttpXmlRequestBodyHandler`               | 46  | XML 请求体           |
|                           | `HttpMultipartFormDataRequestBodyHandler` | 90  | Multipart 请求体     |
|                           | `HttpRawBytesRequestBodyHandler`          | 23  | 字节请求体             |
|                           | `HttpRawInputStreamRequestBodyHandler`    | 25  | 流请求体              |
|                           | `HttpUrlConnectProcessor`                 | 168 | 核心处理器实现           |
|                           | `IOutputStreamHttpRequestBodyHandler`     | 13  | 输出流处理器接口          |
| `i2f.net.http.interfaces` | `IHttpProcessor`                          | 54  | 处理器接口             |
|                           | `HttpProcessorProvider`                   | 82  | 提供者接口             |
|                           | `IHttpRequestBodyHandler`                 | 15  | 请求体处理器            |
|                           | `IHttpResponseBodyHandler`                | 11  | 响应体处理器            |
|                           | `IHttpResponseExtractor`                  | 15  | 响应提取器             |
| `i2f.net.http.rest`       | `IRestClient`                             | 15  | REST 客户端接口        |
|                           | `RestHttpRequest`                         | 39  | REST 请求           |
|                           | `RestHttpResponse`                        | 37  | REST 响应           |
|                           | `HttpProcessorRestClient`                 | 56  | REST 客户端实现        |
| `i2f.net.tcp`             | `TcpClient`                               | 126 | BIO TCP 客户端       |
|                           | `TcpServer`                               | 170 | BIO TCP 服务端       |
|                           | `TcpClientHandler`                        | 20  | 客户端回调             |
|                           | `TcpServerHandler`                        | 41  | 服务端回调             |
|                           | `TcpClientSessionHandler`                 | 51  | 客户端会话处理           |
|                           | `TcpServerSessionHandler`                 | 100 | 服务端会话处理           |
| `i2f.net.nio.tcp`         | `TcpClient`                               | 84  | NIO TCP 客户端       |
|                           | `TcpServer`                               | 103 | NIO TCP 服务端       |
|                           | `ITcpClientListener`                      | 13  | 客户端监听             |
|                           | `ITcpServerListener`                      | 18  | 服务端监听             |
|                           | `ITcpConnector`                           | 12  | 连接器接口             |
|                           | `ITcpListener`                            | 16  | 通用监听              |
|                           | `NioSocketClosedResolver`                 | 37  | 连接关闭处理            |
| `i2f.net.udp`             | `UdpClient`                               | 67  | BIO UDP 客户端       |
|                           | `UdpServer`                               | 177 | BIO UDP 服务端       |
|                           | `UdpClientHandler`                        | 19  | 客户端回调             |
|                           | `UdpServerHandler`                        | 32  | 服务端回调             |
| `i2f.net.nio.udp`         | `UdpClient`                               | 36  | NIO UDP 客户端       |
|                           | `UdpServer`                               | 55  | NIO UDP 服务端       |
|                           | `IUdpConnector`                           | 12  | 连接器接口             |
|                           | `IUdpListener`                            | 16  | 事件监听              |
| `i2f.net.rmi`             | `RmiClient`                               | 72  | RMI 客户端           |
|                           | `RmiServer`                               | 87  | RMI 服务端           |
|                           | `RmiService`                              | 11  | 服务接口标记            |
|                           | `RmiServiceImpl`                          | 11  | 服务实现标记            |
| `i2f.net.scan`            | `NetScanner`                              | 162 | 网络扫描器             |

### i2f-http-proxy（15 文件）

| 包路径                   | 文件                       | 行数  | 说明         |
|-----------------------|--------------------------|-----|------------|
| `...rest.annotations` | `@RestClient`            | 31  | REST 客户端声明 |
|                       | `@RestMapping`           | 23  | 通用映射       |
|                       | `@RestGetMapping`        | 21  | GET 映射     |
|                       | `@RestPostMapping`       | 21  | POST 映射    |
|                       | `@RestPutMapping`        | 21  | PUT 映射     |
|                       | `@RestDeleteMapping`     | 21  | DELETE 映射  |
|                       | `@RestHeader`            | 32  | 请求头绑定      |
|                       | `@RestHeaders`           | 21  | 静态请求头声明    |
|                       | `@RestBody`              | 20  | 请求体绑定      |
|                       | `@RestParam`             | 21  | URL 参数绑定   |
|                       | `@RestPathVariable`      | 21  | 路径变量绑定     |
| `...rest.core`        | `RestClientProxyHandler` | 393 | 动态代理核心     |
| `...rest`             | `HttpProcessorSupplier`  | 15  | 处理器提供者     |
|                       | `IHttpRequestCustomizer` | 15  | 请求定制器      |
|                       | `RestClientProvider`     | 26  | 客户端工厂      |
