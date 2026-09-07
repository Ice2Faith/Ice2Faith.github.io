# Goboot 用户手册

- 面向用户的使用文档
- 本文档面向使用 goboot 进行静态网站托管、文件服务器托管、反向代理等场景的用户
- 如果你是开发者，想基于 goboot 进行接口开发，请查看 : [readme.md](./readme.md)

- github仓库：[github](https://github.com/ice2faith/i2f-turbo-go/tree/main/goboot)
- gitee仓库：[gitee](https://gitee.com/ice2faith/i2f-turbo-go/tree/main/goboot)

---

## 一、简介

Goboot 是一个基于 Golang 的轻量级 Web 服务工具，采用类似 SpringBoot 的配置化思想构建而成。

用户无需编写任何代码，只需通过配置文件 `goboot.yml` 即可完成以下功能：

- **静态网站托管**：部署前端项目（Vue、React 等），支持 SPA 单页应用的 `tryFiles` 配置
- **文件服务器**：提供文件上传、下载、在线浏览（支持 Office、PDF、视频、3D 模型等）
- **反向代理**：将请求转发到后端服务
- **HTTPS**：配置 SSL 证书启用加密访问
- **GZIP 压缩**：启用响应压缩提升传输效率
- **CORS 跨域**：配置跨域策略满足前后端分离需求

---

## 二、快速开始

### 1. 获取程序

直接获取编译好的可执行程序：

- Windows：`goboot.exe`
- Linux：`goboot.elf`

也可以从源码编译，参考 `readme.md`。

### 2. 编写配置文件

在程序同级目录下创建 `goboot.yml`，最小化配置如下：

```yaml
goboot:
  application:
    name: my-server
  server:
    port: 8080
```

### 3. 启动运行

```shell
# Windows
goboot.exe

# Linux
./goboot.elf
```

启动成功后，控制台将输出类似如下信息：

```
________  ________  ________  ________  ________  _________   
|\   ____\|\   __  \|\   __  \|\   __  \|\   __  \|\___   ___\ 
\ \  \___|\ \  \|\  \ \  \|\ /\ \  \|\  \ \  \|\  \|___ \  \_| 
 \ \  \  __\ \  \\\  \ \   __  \ \  \\\  \ \  \\\  \   \ \  \  
  \ \  \|\  \ \  \\\  \ \  \|\  \ \  \\\  \ \  \\\  \   \ \  \ 
   \ \_______\ \_______\ \_______\ \_______\ \_______\   \ \__\
    \|_______|\|_______|\|_______|\|_______|\|_______|    \|__|
...

[INFO] app [ my-server ] on [  ] run at port [ 8080 ] on time 2025-01-01 12:00:00
[INFO] local: http://localhost:8080/
```

### 4. 访问验证

浏览器打开 `http://localhost:8080/` 即可访问。

---

## 三、配置文件详解

配置文件名为 `goboot.yml`，采用 YAML 格式，放置在程序同级目录下。

> **注意**：配置项区分大小写，请严格按照文档中的大小写书写。

### 完整配置模板

```yaml
goboot:
  application:
    name: go-server
  profiles:
    active: dev
  server:
    port: 8080
    bannerPath: ./banner.txt
    staticResources:
      enable: true
      items:
        - urlPath: /
          filePath: ./dist
          tryFiles: index.htm index.html
    templateResources:
      enable: false
      filePath: ./templates/**/*.html
    fileServer:
      enable: false
      rootPath: ./file-server
      urlPath: /file-server
      disableUpload: true
      disableDownload: false
      disableList: false
      disableBrowser: false
      disableOffice: false
      disableOfficeCom: false
    https:
      enable: false
      pemPath: ./https/server.pem
      keyPath: ./https/server.key
    gzip:
      enable: false
      level: DefaultCompression
      excludeExtensions:
        - .mp4
      excludePaths:
        - /api/
      excludePathRegexes:
        - ".*download"
    proxy:
      enable: false
      items:
        - name: backend
          path: /api/
          redirect: http://127.0.0.1:9090/
    cors:
      enable: true
      allowAllOrigins: true
      allowOrigins:
        - http://localhost/
      allowMethods:
        - GET
        - PUT
        - DELETE
        - POST
        - PATCH
        - OPTIONS
      allowHeaders:
        - token
        - Origin
        - secure
        - Auth
      exposeHeaders:
        - Content-Length
      allowCredentials: true
      maxAgeMinutes: 0
```

### 多环境配置

goboot 支持类似 SpringBoot 的多环境配置方式。

在主配置文件 `goboot.yml` 中指定激活的环境：

```yaml
goboot:
  profiles:
    active: dev
```

程序将自动查找并加载 `goboot-dev.yml` 作为实际生效的配置文件。

查找规则：
1. 先读取 `goboot.yml`
2. 如果配置了 `profiles.active`，则查找 `goboot-{active}.yml`
3. 如果找到环境配置文件，则使用环境配置覆盖主配置
4. 如果找不到，则回退使用主配置

---

## 四、静态网站托管

这是 goboot 最常用的功能，用于部署前端项目。

### 4.1 部署 Vue/React 等 SPA 项目

以 Vue 项目为例，构建后生成 `dist` 目录，文件结构如下：

```
goboot.exe
goboot.yml
dist/
  ├── index.html
  ├── assets/
  │   ├── app.js
  │   └── style.css
  └── ...
```

配置 `goboot.yml`：

```yaml
goboot:
  application:
    name: vue-app
  server:
    port: 8080
    staticResources:
      enable: true
      items:
        - urlPath: /
          filePath: ./dist
          tryFiles: index.html
```

**关键配置说明：**

| 配置项 | 说明 |
|--------|------|
| `urlPath` | 浏览器访问的 URL 路径前缀，`/` 表示根路径 |
| `filePath` | 对应的本地文件目录路径 |
| `tryFiles` | 当请求的文件不存在时，依次尝试这些文件（SPA 路由必需） |

> **重要提示**：当使用根路径 `/` 作为 `urlPath` 时，请确保关闭 `proxy`、`mapping` 等其他路径匹配类配置，避免冲突。

### 4.2 部署多个前端项目

可以将多个前端项目部署到不同的二级路径下：

```yaml
goboot:
  server:
    port: 8080
    staticResources:
      enable: true
      items:
        - urlPath: /web
          filePath: ./web/
          tryFiles: index.htm index.html
        - urlPath: /app
          filePath: ./app/
          tryFiles: index.htm index.html
```

访问方式：
- `http://localhost:8080/web/` → 访问 `./web/` 目录下的文件
- `http://localhost:8080/app/` → 访问 `./app/` 目录下的文件

### 4.3 部署传统静态网站

对于普通的静态网站（非 SPA），不需要 `tryFiles` 配置：

```yaml
goboot:
  server:
    staticResources:
      enable: true
      items:
        - urlPath: /static
          filePath: ./static
```

### 4.4 推荐搭配

部署静态网站时，建议同时开启 GZIP 和 CORS 以提升性能和兼容性：

```yaml
goboot:
  server:
    port: 8080
    staticResources:
      enable: true
      items:
        - urlPath: /
          filePath: ./dist
          tryFiles: index.html
    gzip:
      enable: true
      level: DefaultCompression
    cors:
      enable: true
      allowAllOrigins: true
```

---

## 五、文件服务器

goboot 内置了功能丰富的文件服务器，支持文件上传、下载、在线浏览。

### 5.1 基础配置

```yaml
goboot:
  server:
    port: 8080
    fileServer:
      enable: true
      rootPath: ./file-server
      urlPath: /file-server
```

配置说明：

| 配置项 | 类型 | 默认值 | 说明 |
|--------|------|--------|------|
| `enable` | bool | `false` | 是否启用文件服务器 |
| `rootPath` | string | - | 文件存储的根目录路径 |
| `urlPath` | string | `/file-server` | 文件服务的 URL 路径前缀 |
| `disableUpload` | bool | `false` | 是否禁止上传功能 |
| `disableDownload` | bool | `false` | 是否禁止下载功能 |
| `disableList` | bool | `false` | 是否禁止列出文件 API |
| `disableBrowser` | bool | `false` | 是否禁止网页浏览功能 |
| `disableOffice` | bool | `false` | 是否禁止 Office 旧格式自动转换预览 |
| `disableOfficeCom` | bool | `false` | 是否禁止使用 Windows COM 组件进行 Office 转换 |

### 5.2 功能接口

启用文件服务器后，以下 URL 路径可用（以 `urlPath` 为 `/file-server` 为例）：

#### 网页浏览（Web UI）

```
GET /file-server/browser/{子路径}
```

在浏览器中打开即可看到一个文件管理界面，支持：
- 浏览目录结构
- 在线上传文件
- 下载文件
- 点击文件在线预览

示例：
- `http://localhost:8080/file-server/browser/` → 浏览根目录
- `http://localhost:8080/file-server/browser/videos/` → 浏览 videos 子目录
- 支持 `?sort_random=1` 参数进行随机排序

#### 文件列表 API

```
GET /file-server/list/{子路径}
```

返回 JSON 格式的文件列表，包含文件名、大小、修改时间等信息。

示例：
```
GET http://localhost:8080/file-server/list/
GET http://localhost:8080/file-server/list/videos/cat
```

响应示例：
```json
{
  "code": 200,
  "msg": "",
  "data": [
    {
      "name": "video.mp4",
      "path": "video.mp4",
      "size": 10485760,
      "sizeText": "10MB",
      "isDir": false,
      "modifyTime": "2025-01-01 12:00:00"
    }
  ]
}
```

#### 文件上传

```
POST /file-server/upload/{子路径}
```

使用 `multipart/form-data` 格式，字段名为 `file`。

示例（curl）：
```shell
curl -X POST -F "file=@dog.mp4" http://localhost:8080/file-server/upload/
```

#### 文件下载

```
GET /file-server/download/{子路径}/{文件名}
```

- 默认以附件形式下载
- 添加 `?type=inline` 参数可在浏览器中直接预览

示例：
- 下载文件：`GET http://localhost:8080/file-server/download/video/dog.mp4`
- 在线预览：`GET http://localhost:8080/file-server/download/video/dog.mp4?type=inline`

### 5.3 在线文件预览

文件服务器内置了丰富的在线预览能力，在网页浏览模式下点击文件即可自动预览：

| 文件类型 | 支持格式 |
|----------|----------|
| 文本/代码 | `.txt`, `.log`, `.md`, `.json`, `.xml`, `.yml`, `.sql`, `.java`, `.py`, `.go`, `.js`, `.css`, `.html` 等 |
| 视频 | `.mp4`, `.avi`, `.mkv`, `.rmvb`, `.flv`, `.wav` |
| Word 文档 | `.docx`，以及 `.doc`, `.wps`, `.rtf`, `.odt` 等（需转换） |
| Excel 表格 | `.xlsx`，以及 `.xls`, `.csv`, `.tsv`, `.ods` 等（需转换） |
| PPT 演示 | `.pptx`，以及 `.ppt`, `.dps`, `.odp` 等（需转换） |
| PDF | `.pdf` |
| OFD | `.ofd`（国产版式文档） |
| 3D 模型 | `.glb`, `.gltf`, `.fbx` |
| HDR 贴图 | `.hdr` |

**Office 旧格式转换说明：**

对于 `.doc`、`.xls`、`.ppt` 等旧格式文件，系统会尝试自动转换为新版格式以便预览。转换方式按以下优先级尝试：

1. **Windows 下使用 Office/WPS COM 组件**（需安装 Microsoft Office 或 WPS）
2. **LibreOffice**（跨平台，需预先安装）

可通过配置 `disableOffice: true` 禁止旧格式转换，此时旧格式文件将无法在线预览。

可通过配置 `disableOfficeCom: true` 单独禁止使用 Windows COM 组件转换，仅使用 LibreOffice。

### 5.4 内嵌静态资源

文件服务器还支持通过 `EmbedStaticFs` 提供内嵌静态资源服务，访问路径为：

```
GET /file-server/public/{文件路径}
```

此功能主要面向开发者使用，用于将前端资源打包到可执行文件中。其中 `/lib/` 或 `/libs/` 路径下的资源会自动设置 7 天缓存，其他资源设置 1 天缓存。

---

## 六、反向代理

反向代理功能可以将指定路径前缀的请求转发到目标服务器。

### 6.1 基础配置

```yaml
goboot:
  server:
    proxy:
      enable: true
      items:
        - name: backend-api
          path: /api/
          redirect: http://127.0.0.1:9090/
```

### 6.2 配置说明

| 配置项 | 说明 |
|--------|------|
| `name` | 代理名称（仅用于日志标识，可随意命名） |
| `path` | 匹配的 URL 路径前缀 |
| `redirect` | 转发的目标地址 |

### 6.3 工作原理

当请求路径匹配 `path` 前缀时，goboot 会将请求代理到 `redirect` 指定的地址。

举例：

```yaml
proxy:
  enable: true
  items:
    - name: baidu
      path: /proxy/baidu/
      redirect: https://www.baidu.com/
    - name: bilibili
      path: /proxy/bilibili/
      redirect: https://www.bilibili.com/
```

- 访问 `http://localhost:8080/proxy/baidu/` → 实际访问 `https://www.baidu.com/`
- 访问 `http://localhost:8080/proxy/bilibili/` → 实际访问 `https://www.bilibili.com/`

### 6.4 典型使用场景

**前后端分离部署时代理后端 API：**

```yaml
goboot:
  server:
    port: 80
    staticResources:
      enable: true
      items:
        - urlPath: /
          filePath: ./dist
          tryFiles: index.html
    proxy:
      enable: true
      items:
        - name: backend
          path: /api/
          redirect: http://127.0.0.1:9090/
```

这样前端页面和后端 API 都通过 80 端口访问，无需处理跨域问题。

---

## 七、HTTPS 配置

### 7.1 配置方式

```yaml
goboot:
  server:
    port: 443
    https:
      enable: true
      pemPath: ./https/server.pem
      keyPath: ./https/server.key
```

### 7.2 配置说明

| 配置项 | 说明 |
|--------|------|
| `enable` | 是否启用 HTTPS |
| `pemPath` | SSL 证书文件路径（PEM 格式） |
| `keyPath` | SSL 私钥文件路径（KEY 格式） |

启用 HTTPS 后，程序将使用 HTTPS 协议启动。

---

## 八、GZIP 压缩

启用 GZIP 压缩可以显著减少传输体积，提升加载速度。

### 8.1 配置方式

```yaml
goboot:
  server:
    gzip:
      enable: true
      level: DefaultCompression
      excludeExtensions:
        - .mp4
        - .mp3
        - .m3u8
        - .xlsx
        - .xls
      excludePaths:
        - /api/
      excludePathRegexes:
        - ".*download"
```

### 8.2 配置说明

| 配置项 | 说明 |
|--------|------|
| `enable` | 是否启用 GZIP |
| `level` | 压缩级别，可选值见下表 |
| `excludeExtensions` | 不进行压缩的文件扩展名列表 |
| `excludePaths` | 不进行压缩的路径前缀列表 |
| `excludePathRegexes` | 不进行压缩的路径正则列表 |

**压缩级别：**

| 级别 | 说明 |
|------|------|
| `DefaultCompression` | 默认压缩（推荐） |
| `BestCompression` | 最佳压缩比，CPU 消耗较高 |
| `BestSpeed` | 最快压缩速度，压缩比较低 |
| `NoCompression` | 不压缩 |

> **建议**：将已经压缩过的文件格式（如 `.mp4`、`.mp3`、`.xlsx` 等）加入 `excludeExtensions`，避免重复压缩浪费 CPU。

---

## 九、CORS 跨域配置

### 9.1 配置方式

```yaml
goboot:
  server:
    cors:
      enable: true
      allowAllOrigins: true
      allowOrigins:
        - http://localhost/
      allowMethods:
        - GET
        - PUT
        - DELETE
        - POST
        - PATCH
        - OPTIONS
      allowHeaders:
        - token
        - Origin
        - secure
        - Auth
      exposeHeaders:
        - Content-Length
      allowCredentials: true
      maxAgeMinutes: 0
```

### 9.2 配置说明

| 配置项 | 类型 | 说明 |
|--------|------|------|
| `enable` | bool | 是否启用跨域配置 |
| `allowAllOrigins` | bool | 是否允许所有来源（为 `true` 时下面的 `allowOrigins` 无效） |
| `allowOrigins` | []string | 允许的来源列表 |
| `allowMethods` | []string | 允许的请求方法列表 |
| `allowHeaders` | []string | 允许的请求头列表 |
| `exposeHeaders` | []string | 暴露给浏览器的响应头列表 |
| `allowCredentials` | bool | 是否允许携带凭证（Cookie 等） |
| `maxAgeMinutes` | int | 预检请求缓存时间（分钟），0 表示不缓存 |

### 9.3 常见场景

**开发环境允许所有来源：**

```yaml
cors:
  enable: true
  allowAllOrigins: true
```

**生产环境限定特定来源：**

```yaml
cors:
  enable: true
  allowAllOrigins: false
  allowOrigins:
    - https://www.example.com
    - https://app.example.com
  allowMethods:
    - GET
    - POST
  allowCredentials: true
  maxAgeMinutes: 60
```

---

## 十、Session 配置

goboot 支持 Session 功能，主要用于开发者使用。如果仅作为静态网站托管或文件服务器，通常无需开启。

```yaml
goboot:
  server:
    session:
      enable: false
      impl: cookie
      secretKey: 123456
      sessionKey: go-session
```

| 配置项 | 说明 |
|--------|------|
| `enable` | 是否启用 Session |
| `impl` | 存储实现方式，可选 `cookie` 或 `redis` |
| `secretKey` | Session 加密秘钥 |
| `sessionKey` | 客户端 Cookie 中的 Session 键名 |

选择 `redis` 实现时，需要同时启用 Redis 配置。

---

## 十一、Redis 配置

```yaml
goboot:
  server:
    redis:
      enable: false
      host: 127.0.0.1
      port: 6379
      password: ""
      database: 0
```

| 配置项 | 说明 |
|--------|------|
| `enable` | 是否启用 Redis |
| `host` | Redis 主机地址，默认 `127.0.0.1` |
| `port` | Redis 端口，默认 `6379` |
| `password` | Redis 访问密码 |
| `database` | 使用的 Redis 数据库编号 |

---

## 十二、Banner 自定义

goboot 启动时会输出一个 ASCII Art Banner，你可以自定义。

### 12.1 使用自定义 Banner 文件

```yaml
goboot:
  server:
    bannerPath: ./banner.txt
```

在 `banner.txt` 中写入自定义的 ASCII 文本内容即可。

### 12.2 在线生成 Banner

可使用在线工具生成 ASCII Art：
- https://www.bootschool.net/ascii

---

## 十三、常见部署场景

### 13.1 纯前端 SPA 站点

```yaml
goboot:
  application:
    name: my-vue-app
  server:
    port: 80
    staticResources:
      enable: true
      items:
        - urlPath: /
          filePath: ./dist
          tryFiles: index.html
    gzip:
      enable: true
      level: DefaultCompression
    cors:
      enable: true
      allowAllOrigins: true
```

### 13.2 前端 + 后端 API 代理

```yaml
goboot:
  application:
    name: fullstack-app
  server:
    port: 80
    staticResources:
      enable: true
      items:
        - urlPath: /
          filePath: ./dist
          tryFiles: index.html
    proxy:
      enable: true
      items:
        - name: api-server
          path: /api/
          redirect: http://127.0.0.1:9090/
    gzip:
      enable: true
      level: DefaultCompression
    cors:
      enable: true
      allowAllOrigins: true
```

### 13.3 文件共享服务器

```yaml
goboot:
  application:
    name: file-share
  server:
    port: 8080
    fileServer:
      enable: true
      rootPath: ./shared-files
      urlPath: /files
      disableUpload: false
      disableDownload: false
      disableBrowser: true
    gzip:
      enable: true
      level: DefaultCompression
```

### 13.4 HTTPS + 多路径静态站点

```yaml
goboot:
  application:
    name: secure-site
  server:
    port: 443
    https:
      enable: true
      pemPath: ./certs/server.pem
      keyPath: ./certs/server.key
    staticResources:
      enable: true
      items:
        - urlPath: /web
          filePath: ./web/
          tryFiles: index.html
        - urlPath: /app
          filePath: ./app/
          tryFiles: index.html
    gzip:
      enable: true
      level: DefaultCompression
    cors:
      enable: true
      allowAllOrigins: true
```

### 13.5 多环境部署

主配置 `goboot.yml`：
```yaml
goboot:
  application:
    name: my-app
  profiles:
    active: prod
  server:
    port: 8080
```

开发环境 `goboot-dev.yml`：
```yaml
goboot:
  server:
    port: 8080
    staticResources:
      enable: true
      items:
        - urlPath: /
          filePath: ./dist
          tryFiles: index.html
    proxy:
      enable: true
      items:
        - name: dev-api
          path: /api/
          redirect: http://127.0.0.1:9090/
```

生产环境 `goboot-prod.yml`：
```yaml
goboot:
  server:
    port: 80
    staticResources:
      enable: true
      items:
        - urlPath: /
          filePath: ./dist
          tryFiles: index.html
    proxy:
      enable: true
      items:
        - name: prod-api
          path: /api/
          redirect: http://backend-server:9090/
    https:
      enable: true
      pemPath: ./certs/server.pem
      keyPath: ./certs/server.key
    gzip:
      enable: true
      level: BestCompression
```

切换环境只需修改 `goboot.yml` 中的 `profiles.active` 值即可。

---

## 十四、配置项速查表

| 配置路径 | 类型 | 默认值 | 说明 |
|----------|------|--------|------|
| `goboot.application.name` | string | - | 应用名称 |
| `goboot.profiles.active` | string | - | 激活的环境配置 |
| `goboot.server.port` | int | `8080` | 服务监听端口 |
| `goboot.server.bannerPath` | string | - | 自定义 Banner 文件路径 |
| `goboot.server.staticResources.enable` | bool | `false` | 启用静态资源 |
| `goboot.server.staticResources.items[].urlPath` | string | - | URL 路径前缀 |
| `goboot.server.staticResources.items[].filePath` | string | - | 本地文件路径 |
| `goboot.server.staticResources.items[].tryFiles` | string | - | 尝试文件列表（空格分隔） |
| `goboot.server.templateResources.enable` | bool | `false` | 启用模板渲染 |
| `goboot.server.templateResources.filePath` | string | - | 模板文件匹配规则 |
| `goboot.server.fileServer.enable` | bool | `false` | 启用文件服务器 |
| `goboot.server.fileServer.rootPath` | string | - | 文件存储根目录 |
| `goboot.server.fileServer.urlPath` | string | `/file-server` | 文件服务 URL 前缀 |
| `goboot.server.fileServer.disableUpload` | bool | `false` | 禁止上传 |
| `goboot.server.fileServer.disableDownload` | bool | `false` | 禁止下载 |
| `goboot.server.fileServer.disableList` | bool | `false` | 禁止列出文件 |
| `goboot.server.fileServer.disableBrowser` | bool | `false` | 禁止网页浏览 |
| `goboot.server.fileServer.disableOffice` | bool | `false` | 禁止 Office 格式转换 |
| `goboot.server.fileServer.disableOfficeCom` | bool | `false` | 禁止 Windows COM 转换 |
| `goboot.server.https.enable` | bool | `false` | 启用 HTTPS |
| `goboot.server.https.pemPath` | string | - | PEM 证书路径 |
| `goboot.server.https.keyPath` | string | - | KEY 私钥路径 |
| `goboot.server.gzip.enable` | bool | `false` | 启用 GZIP |
| `goboot.server.gzip.level` | string | `DefaultCompression` | 压缩级别 |
| `goboot.server.gzip.excludeExtensions` | []string | - | 排除的文件扩展名 |
| `goboot.server.gzip.excludePaths` | []string | - | 排除的路径前缀 |
| `goboot.server.gzip.excludePathRegexes` | []string | - | 排除的路径正则 |
| `goboot.server.proxy.enable` | bool | `false` | 启用反向代理 |
| `goboot.server.proxy.items[].name` | string | - | 代理名称 |
| `goboot.server.proxy.items[].path` | string | - | 匹配路径前缀 |
| `goboot.server.proxy.items[].redirect` | string | - | 转发目标地址 |
| `goboot.server.cors.enable` | bool | `false` | 启用跨域配置 |
| `goboot.server.cors.allowAllOrigins` | bool | `false` | 允许所有来源 |
| `goboot.server.cors.allowOrigins` | []string | - | 允许来源列表 |
| `goboot.server.cors.allowMethods` | []string | - | 允许方法列表 |
| `goboot.server.cors.allowHeaders` | []string | - | 允许头列表 |
| `goboot.server.cors.exposeHeaders` | []string | - | 暴露头列表 |
| `goboot.server.cors.allowCredentials` | bool | `false` | 允许携带凭证 |
| `goboot.server.cors.maxAgeMinutes` | int | `0` | 预检缓存时间（分钟） |
| `goboot.server.session.enable` | bool | `false` | 启用 Session |
| `goboot.server.session.impl` | string | `cookie` | 存储方式（cookie/redis） |
| `goboot.server.session.secretKey` | string | - | 加密秘钥 |
| `goboot.server.session.sessionKey` | string | `go-session` | Cookie 键名 |
| `goboot.server.redis.enable` | bool | `false` | 启用 Redis |
| `goboot.server.redis.host` | string | `127.0.0.1` | Redis 主机 |
| `goboot.server.redis.port` | int | `6379` | Redis 端口 |
| `goboot.server.redis.password` | string | - | Redis 密码 |
| `goboot.server.redis.database` | int | `0` | Redis 数据库编号 |

---

## 十五、常见问题

### Q: 配置了根路径 `/` 的静态资源后，其他功能不生效？

当 `urlPath` 设为 `/` 时，它会匹配所有请求路径。此时请确保关闭 `proxy`、`mapping` 等基于路径前缀匹配的功能，或将它们配置为不冲突的路径。

### Q: Vue/React 项目刷新页面 404？

需要在静态资源配置中添加 `tryFiles: index.html`，这是 SPA 单页应用所必需的。

### Q: 文件服务器预览 Office 旧格式（.doc/.xls/.ppt）失败？

需要安装以下任一软件：
- Windows 系统：安装 Microsoft Office 或 WPS Office
- 跨平台：安装 LibreOffice

也可以通过 `disableOffice: true` 关闭旧格式转换支持。

### Q: 如何切换开发环境和生产环境？

修改 `goboot.yml` 中的 `goboot.profiles.active` 值，并创建对应的 `goboot-{环境名}.yml` 文件即可。

### Q: 启动后如何查看访问地址？

启动日志会输出本机所有可用网卡的 IP 地址及对应的访问 URL，可以直接复制使用。
