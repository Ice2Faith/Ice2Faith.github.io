# Goboot 配置化Web开发

## 简介
- 启动日志预览
```shell script
________  ________  ________  ________  ________  _________   
|\   ____\|\   __  \|\   __  \|\   __  \|\   __  \|\___   ___\ 
\ \  \___|\ \  \|\  \ \  \|\ /\ \  \|\  \ \  \|\  \|___ \  \_| 
 \ \  \  __\ \  \\\  \ \   __  \ \  \\\  \ \  \\\  \   \ \  \  
  \ \  \|\  \ \  \\\  \ \  \|\  \ \  \\\  \ \  \\\  \   \ \  \ 
   \ \_______\ \_______\ \_______\ \_______\ \_______\   \ \__\
    \|_______|\|_______|\|_______|\|_______|\|_______|    \|__|

[INFO] app [ go-server ] on [ dev ] run at port [ 8080 ] on time 2023-02-10 16:48:51
[INFO] local: http://localhost:8080/
```
- Goboot
- 是基于 Golang 的 web 开发框架 gin 实现的
- 一个二次包装的配置化开发模板
- 结合和部分Springboot的开发特性
- 在 Go 支持的情况下
- 实现配置化开发
- 实现常见配置支持
- 实现自动路由匹配

## 快速入门
- 第一步，安装GO环境
- 第二步，使用gomod初始化自己的项目
- 下面以项目名hello为例
- 新建项目 hello
```shell script
mkdir hello
```
- 进入项目
```shell script
cd hello
```
- 初始化gomod项目
- 注意，项目名要和创建的文件夹名称一致
```shell script
go mod init hello
```
- 第三步，拷贝goboot到项目中
- 这是目前的项目结构
```shell script
hello
|---goboot
    |---goboot.go
|---go.mod
```
- 第四步，编写自己的入口文件
- 也就是main.go
```shell script
vi main.go
```
```go
package main

import (
	"fmt"
	"hello/goboot"
	"time"

	"github.com/gin-gonic/gin"
)

// 定义API处理结构体
type Api struct {
}

// 给结构体绑定函数
// 这里的函数名为Hello
// 在后面会仔细讲解函数名的问题
func (api *Api) Hello(c *gin.Context) {
	c.JSON(200, gin.H{
		"hello": "hello",
	})
}

// 定义主函数
func main() {
	// 获得默认的应用对象
    app := goboot.GetDefaultApplication()
    // 添加mapping处理对象，注意是指针
	app.AddHandlers(&Api{})
    // 添加默认主页的GET请求处理
	app.App.GET("/", func(c *gin.Context) {
		stime := time.Now().Format("2006-01-02 15:04:05")
		c.String(200, fmt.Sprintf("现在是北京时间：%v",stime))
	})
    // 运行应用
	app.Run()
}
```
- 第四步，编写配置文件
- 也就是 goboot.yml
```shell script
vi goboot.yml
```
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
      disablePreCompressGzip: false
      items:
        - urlPath: /dist
          filePath: ./dist
          tryFiles: index.htm index.html
        - urlPath: /static
          filePath: ./static
          tryFiles: index.htm index.html
    templateResources:
      enable: false
      filePath: ./templates/**/*.html
    session:
      enable: true
      # cookie/redis
      impl: cookie
      secretKey: 123456
      sessionKey: go-session
    redis:
      enable: false
      host: 127.0.0.1
      port: 6379
      password: ltb12315
      database: 0
    datasource:
      enable: false
      # mysql/postgres
      driver: mysql
      host: 127.0.0.1
      port: 6379
      # url: user:password@tcp(localhost:5555)/dbname?tls=skip-verify&autocommit=true
      url: root:123456@tcp(127.0.0.1:3306)/test_db?charset=utf8mb4&parseTime=True&loc=Local
      username: root
      password: 123456
      database: test_db
    gorm:
      enable: false
    https:
      enable: false
      pemPath: ./https/server.pem
      keyPath: ./https/server.key
    gzip:
      enable: false
      # BestCompression/BestSpeed/DefaultCompression/NoCompression
      level: DefaultCompression
      excludeExtensions:
        - .mp4
      excludePaths:
        - /api/
      excludePathRegexes:
        - "*download"
    proxy:
      enable: false
      items:
        - name: github.com
          path: /github/
          redirect: http://github.com/
          upstream:
            enable: false
            algo: round
            headers: []
            backends:
              - backend: http://127.0.0.1:9090/
                weight: 1
              - backend: http://127.0.0.1:9091/
                weight: 2
    mapping:
      enable: false
      items:
        - /api/
    rateLimit:
      enable: false
      countPerSecond: 30
      bucketSize: 100
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
- 第五步，下载依赖
```shell script
go get github.com/gin-gonic/gin
go get github.com/gin-contrib/gzip
go get github.com/gin-contrib/cors
go get github.com/gin-contrib/sessions
go get github.com/go-yaml/yaml
go get github.com/redis/go-redis/v9
go get github.com/gin-contrib/sessions/redis@v0.0.5
go get github.com/google/uuid
go get github.com/go-sql-driver/mysql
go get github.com/lib/pq
go get gorm.io/gorm
go get gorm.io/driver/mysql
go get gorm.io/driver/postgres
```
- 第六步，启动运行
```shell script
go run main.go
```
- 第七步，浏览器访问查看
```shell script
http://localhost:8080/
http://localhost:8080/hello
```
- 这是最终的文件结构
```shell script
hello
|---goboot
    |---goboot.go
|---go.mod
|---goboot.yml
|---main.go
```


## 配置文件
- 配置文件，直接在配置文件中
- 加注释给出说明
- 注意，在此处的配置环境中
- 不同于springboot配置
- 这里是区分大小写，严格匹配的
- 这个java同学需要注意
```yaml
# 配置根节点
goboot:
  # 应用配置      
  application:
    # 应用名称
    name: go-server
  # 多环境配置
  profiles:
    # 激活的环境，找不到指定配置就是默认配置文件
    # 查找规则：goboot.yml goboot-${goboot.prfiles.active}.yml
    # 比如这里，就查找goboot-dev.yml
    active: dev
  # 服务配置
  server:
    # 服务的启动端口    
    port: 8080
    # 也可以配置自己的启动banner
    bannerPath: ./banner.txt
    # 静态资源配置  
    staticResources:
      # 是否启用
      enable: true
      # 是否禁用预压缩gzip(.gz)文件的支持，默认false即启用，需要自行提供同名.gz文件
      disablePreCompressGzip: false
      # url中的路径
      urlPath: /static
      # 解析为静态资源的路径
      filePath: ./static
    # 模板文件配置
    templateResources:
      # 是否启用    
      enable: true
      # 模板文件的匹配规则  
      filePath: ./templates/**/*.html
    # session 配置部分
    session:
      # 是否开启session
      enable: true
      # 使用的session存储类型，目前有以下两种可选
      # 当选redis时，必须配置redis
      # cookie/redis
      impl: cookie
      # session存储的加密秘钥
      secretKey: 123456
      # session在客户端的cookie键名称
      sessionKey: go-session
    # redis 配置
    redis:
      # 是否开启redis
      enable: true
      # redis 主机
      host: 127.0.0.1
      # redis 端口
      port: 6379
      # redis 访问密码
      password: ltb12315
      # redis 使用的数据库
      database: 0
    # 数据源配置
    datasource:
      # 是否启用数据源
      enable: true
      # 数据源驱动类型，支持以下类型
      # mysql/postgres
      driver: mysql
      # 数据源主机
      host: 127.0.0.1
      # 数据源端口
      port: 3306
      # 当url有配置时，按照url配置进行，其他数据源参数无效
      # 没有配置时，使用其他参数解析
      url: user:password@tcp(localhost:5555)/dbname?tls=skip-verify&autocommit=true
      # 数据源用户名
      username: root
      # 数据源密码
      password: 123456
      # 数据源数据库
      database: test_db
    # ORM 配置
    gorm:
      # 是否启用 ORM
      enable: true
    # HTTPS的配置部分
    https:
      # 是否启用
      enable: false
      # 分别配置HTTPS的pem文件和key文件
      pemPath: ./https/server.pem
      keyPath: ./https/server.key
    # gzip响应压缩配置
    gzip:
      # 是否启用
      enable: false
      # 压缩级别：BestCompression，BestSpeed，DefaultCompression，NoCompression
      level: DefaultCompression
      # 排除的后缀列表
      excludeExtensions:
        - .mp4
      # 排除的路径前缀列表
      excludePaths:
        - /api/
      # 排除的路径匹配正则列表
      excludePathRegexes:
        - "*download"
    # 代理配置
    proxy:
      enable: false
      # 可以配置多个代理配置
      # 代理的名称，可以随意  
      items:
        - name: github.com
          # 代理的路径
          path: /github/
          # 目标跳转路径（未启用upstream时生效）
          redirect: http://github.com/
          # upstream负载均衡配置（启用后redirect将被忽略）
          upstream:
            # 是否启用负载均衡
            enable: false
            # 负载均衡算法：round(轮询)/random(随机，默认)/ip_hash(IP哈希)/weight(加权随机)/header_hash(请求头哈希)/path_hash(路径哈希)
            algo: round
            # 参与哈希计算的请求头列表（仅header_hash算法时使用）
            headers: []
            # 后端服务列表
            backends:
              - backend: http://127.0.0.1:9090/
                weight: 1
              - backend: http://127.0.0.1:9091/
                weight: 2
    # 自动路径映射配置
    mapping:
      enable: true
      # 可以配置多个进行按照匹配规则自动路由  
      items:
        - /api/
    # 全局限流配置（令牌桶算法）
    rateLimit:
      # 是否启用全局限流
      enable: false
      # 每秒生产的令牌数（float64类型，可以是小数，如0.5表示每2秒1个令牌）
      countPerSecond: 30
      # 令牌桶最大容量
      bucketSize: 100
    # 文件服务器配置
    fileServer:
      # 是否启用文件服务器
      enable: false
      # 文件存储的本地根目录
      rootPath: ./file-server
      # 文件服务的URL路径前缀
      urlPath: /file-server
      # 是否禁止上传功能
      disableUpload: true
      # 是否禁止下载功能
      disableDownload: false
      # 是否禁止列出文件列表API
      disableList: false
      # 是否禁止网页浏览功能
      disableBrowser: false
      # 是否禁止Office旧格式自动转换预览
      disableOffice: false
      # 是否禁止使用Windows COM组件进行Office转换
      disableOfficeCom: false
    # 跨域配置
    cors:
      # 是否启用
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

### 配置占位符
- 配置文件支持 `${key:default}` 形式的占位符
- 在解析YAML之前，会先对配置文件内容进行占位符替换
- 因此占位符可以出现在配置文件的任意位置
- 替换取值的优先级，从高到低
    - 命令行 `-D` 参数：`-Dkey=value`
    - 环境变量：名称为 key 的环境变量
    - 默认值：`default`，未提供默认值时，替换为空串
- 按第一个冒号切分 key 和默认值，因此默认值中允许包含冒号
- 使用示例
```yaml
goboot:
  server:
    port: ${goboot.server.port:8080}
    session:
      secretKey: ${goboot.session.secret-key:123456}
    redis:
      password: ${goboot.redis.password:123456}
```
- 通过命令行 `-D` 参数覆盖，形式与java保持一致
```shell script
./goboot.elf -Dgoboot.server.port=9090
```
- 通过环境变量覆盖
```shell script
# Linux
env 'goboot.server.port=9090' ./goboot.elf
```
- 该特性主要用于适配容器化环境下的配置注入

## 接口开发
- 接口开发，可以使用gin框架自己的方式
- 也可以使用配置中的mapping自动映射两种模式
- 也可以实现GobootController接口定义分组路由
- 三种种模式，都是基于封装的goboot

### gin模式接口开发
- gin模式，就是通过应用实例，获取App属性，得到gin.Engine实现
- 得到 boot 对象
```go 
boot := goboot.GetDefaultApplication()
```
- 拿到 gin.Engine 对象
```go
engine := boot.App
```
- 然后，就可以和原始的gin开发一样开发了
```go
engine.GET("/", func(c *gin.Context) {
    stime := time.Now().Format("2006-01-02 15:04:05")
    c.String(200, fmt.Sprintf("现在是北京时间：%v",stime))
})
```


### mapping自动映射模式接口开发
- 此模式，首先，你得知道工作原理
- 工作原理
    - 首先，需要在配置中 goboot.server.mapping 配置上自动映射的路径
    - 例如，举例配置中的 /api/ 这个路径
    - 则，如果请求路径为：http://localhost:8080/api/hello/go
    - 则 /api/hello/go 就是符合mapping配置的一个路径
    - 则，去除 /api/ 这一层之后，得到的路径为 hello/go
    - 在对boot的代码中，将一个带有方法的结构体，添加到 handlers 中
    - 则，表示这些对象的方法，都具备可以自动映射的能力
    - 假设，结构体为 Api , 具有一个 Hello_Go 方法
    - 那么，对于路径 hello/go 就被映射到 Hello_Go 方法上
    - 具体的映射规则如下：
        - URL路径: /gin-web/hello-goboot
        - 将URL路径按照每层路径分隔
        - 得到：gin-web，hello-goboot
        - 对每一级，按照横向分隔
        - 得到：gin,web和hello,goboot
        - 按照每一级内使用大驼峰（Capital）组合
        - 得到：GinWeb，HelloGoboot
        - 对每一级使用下划线组合
        - 得到：GinWeb_HelloGoboot
        - 这个就是这个路径对应要映射的方法名
        - 那么，将会在注册的 handlers 中，查找名称为这样的一个方法来处理请求
        - 下面给出一些映射案例：
        - 一： hello ---> Hello
        - 二： helloWorld --> HelloWorld
        - 三： hello-world --> HelloWorld
        - 四： hello-go/hello-gin --> HelloGo_HelloGin
    - 针对restful类型接口，限制请求方式的适配
        - 在映射函数的定义上
        - 如果是X*_开头的函数，将限定为指定规则对应的请求方式
        - 具体的关系如下
            - XG_ --> GET
            - XU_ --> PUT
            - XP_ --> POST
            - XD_ --> DELETE
            - XH_ --> PATCH
            - XA_ --> ANY
        - 对于包含这些前缀的函数
        - 映射的路径匹配的函数名
        - 将去除这些后缀后进行匹配
        - 举例：
            - 方法名：XP_Get_User
            - 则对应的请求：POST /get/user
            - 当使用其他请求类型时，将404：GET /get/user
    - 映射函数的要求：
        - 入参可以有多个
        - 顺序可以任意
        - 也可以无参数
        - 支持的参数如下
            - c *gin.Context
            - boot * goboot.GobootApplication
            - engine * gin.Engine
            - request * http.Request
            - resp * goboot.ApiResp
            - ctxResp * goboot.CtxResp
            - redis * redis.Client
            - redisCli * goboot.RedisCli
            - session sessions.Session
            - db *sql.DB
            - gormDb * gorm.DB
            - 自定义绑定请求参数的结构体
                - 注意，必须是结构体类型
                - 结构体支持值类型或指针类型
        - 方法案例
            - 一：func (api *Api) Hello()
            - 二：func (api *Api) Hello(c *gin.Context)
            - 三：func (api *Api) Hello(boot *goboot.GobootApplication,c *gin.Context)
            - 四：func (api *Api) Hello(c *gin.Context, post User, boot *goboot.GobootApplication, engine *gin.Engine, request *http.Request)
- 使用代码示例
```go
package main

import (
	"hello/goboot"

	"github.com/gin-gonic/gin"
)

// 定义API处理结构体
type Api struct {
}

// 给结构体绑定函数
// 这里的函数名为Hello
// 在后面会仔细讲解函数名的问题
func (api *Api) Hello(c *gin.Context) {
	c.JSON(200, gin.H{
		"hello": "hello",
	})
}

// 定义主函数
func main() {
	// 获得默认的应用对象
    app := goboot.GetDefaultApplication()
    // 添加mapping处理对象，注意是指针
	app.AddHandlers(&Api{})
    // 运行应用
	app.Run()
}
```
- 因此，如果使用mapping模式开发
- 分三步走
- 第一步，确认配置文件中的mapping有添加
- 第二步，编写一个符合mapping要求的结构体，也就是具有方法
- 第三步，调用boot对象的AddHandles方法，添加处理的所有结构体

### GobootController 路由分组模式
- 这个模式，其实也是自动路由的一种变体
- 之前的mapping模式相当于全局自动映射
- 而controller模式，则是分组的自动映射模式
- 使用上和mapping一样，只不过处理的结构体
- 也就是说，定义的处理函数，和mapping模式一样定义即可
- 需要实现接口 GobootController
    - 关于实现接口，在Golang中，接口的实现，不需要什么implements/extends等关键字
    - 只需要将接口中的每个方法在结构体中实现即可
- 下面就以一个示例来说明
- 首先，定义自己的mapping结构体
- 实现接口中定义个path方法
```go
// 定义处理结构
type AdminController struct {
}
// 实现接口方法，返回这个分组路由为 /admin/
func (con *AdminController) Path() string {
	return "/admin/"
}
// 添加自己的路径映射处理函数
func (admin *AdminController) XP_Get(ctx *goboot.CtxResp) any {
	return ctx.ApiJsonOk("ok")
}
```
- 将controller添加到路由中
```go
// 拿到应用对象
app := goboot.GetDefaultApplication()
// 添加controller
app.AddControllers(&AdminController{})
// 运行应用
app.Run()
```

## 自动映射函数
- 上面说了mapping模式的自动映射函数
- 只是简单的介绍了映射函数
- 下面就来详细的说明映射函数
- 以及自动注入的入参的作用或设计初衷
- 下面讲解映射函数，绑定的结构体，都以 Api 讲解
- 配置的mapping 为 /api/
```go
type Api struct{
}
```
### 需要手动指定路径
- 缺少像springmvc的注解声明方式
- 则取而代之，使用函数名作为路径匹配规则
- 原始写法
```go
engine.GET("/api/hello",func(c *gin.Context){
  c.JSON(200,gin.H{
    "data":"hello",
  })
})
```
- 使用Goboot之后
- 则可以改写为如下方式
```go
func (api * Api) Hello(c * gin.Context){
  c.JSON(200,gin.H{
    "data":"hello",
  })
}
```
- 按照匹配规则，Hello函数名进行匹配请求路径
- 这样，避免了两个问题
- 直接使用engine对象
- 写明请求路径
- 这两个问题，都极大的增大了耦合性

### 数据响应之后，必须自行return
- 在使用gin进行响应数据时
- 需要明确的指定return
- 即时是abort也必须进行返回
- 否则如果后续有其他响应逻辑
- 则会连带执行其他响应
- 导致两个响应结合再一起
- 问题如下
```go
engine.GET("/api/hello", func(c *gin.Context) {
  c.AbortWithStatusJSON(200, gin.H{
    "data": "error",
  })
  // 如果此处没有return
  // 则下面的正常响应将会继续响应
  // return
  c.JSON(200, gin.H{
    "data": "hello",
  })
})
```
- 这里演示的这种情况实际中是很常见的
- 只不过，实际中对于abort是有条件的
- 但是依旧不能避免return
- 下面，在goboot中
- 封装了两个结构，来解决此问题
- 这都是基于自动映射实现的
- 因为自动映射，不关心返回值，返回值不会被处理
- 方法一，使用goboot.ApiResp结合gin.Context实现直接返回
```go
func (api *Api) Hello(resp *goboot.ApiResp, c *gin.Context) *goboot.ApiResp {
	return resp.GinOk(c, "hello")
}
```
- 这种方式，通过自动注入goboot.ApiResp结合gin.Context实现
- 方式二，和方法一一致，只不过自己实例化goboot.ApiResp指针
```go
func (api *Api) Hello(c *gin.Context) *goboot.ApiResp {
	return (&goboot.ApiResp{}).GinOk(c, "hello")
}
```
- 这种方式，只需要注入gin.Context即可
- 方式三，和方法二类似，只不过通过方法实例化goboot.ApiResp指针
```go
func (api *Api) Hello(c *gin.Context) *goboot.ApiResp {
	return goboot.ApiOk(nil).GinOk(c, "hello")
}
```
- 这种方式，比较起来容易接受
- 方式四，推荐方式，直接使用goboot.CtxResp实现
```go
func (api *Api) Hello(resp *goboot.CtxResp) *goboot.CtxResp {
	return resp.ApiJsonOk("hello")
}
```
- 这种方式，最为简单实用
- 一般业务场景中，这种模式，在加上自动解析请求参数注入
- 就是一般的使用模式
- 如下
```go
func (api *Api) Login(resp *goboot.CtxResp,user * User) *goboot.CtxResp {
	return resp.ApiJsonOk("ok")
}
```

## 主要函数或结构
- 常量：DefaultConfigFile ，指定了默认的配置文件的名称 为 ./goboot.yml
- 常量：DefaultBannerText ，指定了默认的应用banner的文本值
- 结构：ApiResp ，定义了标准的接口返回结构，code，msg，data
    - 以及包含了常用的填值结构方法
    - 以及包含了针对gin的JSON返回的结构方法Gin*系列
    - 以及全局静态方法Api*系列
- 常量：ApiCodeOk ，指定了默认的ApiResp返回正常时的code值
- 常量：APiCodeErr ，指定了默认的ApiResp异常返回时的code值
- 结构：Tokens ，定了了几个结构方法，用于获取UUID和从请求中获取token的结构方法
- 结构：CtxResp ，是最常用的mapping系列自动映射函数中最常用的一个入参，包含了context,session,app
    - 以及包含了对ApiResp结构响应JSON的ApiJson*系列结构函数
    - 以及包含了原始gin响应的Json/string/html函数
    - 以及包含了对session设置获取的Session*系列函数
- 函数：Log* 系列全局函数，使用自定义的控制台数据日志
- 结构：GobootConfig 定义了解析配置文件的根配置结构
    - 此结构包含了整个配置文件中的配置信息
    - 如有需要，可以进行获取
- 结构：GobootApplication 是封装的goboot的应用实例结构
    - 整个goboot的上下文，引擎等都在此结构中进行包含
    - 其中包含了，gin.Engine,GobootConfig,Handlers,GobootLifecycleListener,RedisCli,GobootController,sql.DB,gorm.DB
    - 此实例，通过Get*Application系列函数进行初始化获取
    - 最终设置完毕之后，使用结构函数 Run 来启动一个应用
- 接口：GobootController 是针对 GobootApplication 中Controllers定义的接口
    - 用于定义分组路由的自动映射
    - 其中包含一个 Path 方法，用于获取分组路由的路径
- 结构：RedisCli 是对 redis.Client 的简单封装
    - 主要是为了简化原来的redis.Client的使用
    - 目前提供了简单的GET和set方法
- 函数类型： GobootListener 定义了在应用初始化和启动的各个生命周期进行监听的接口函数
    - 可以用于监听对应周期应用的状态
    - 或者在对应的周期进行修改应用配置的目的
- 结构：GobootLifecycleListener 定义了一组声明周期各个环节的监听集合
    - 用来组装 GobootListener
- 函数：GetDefaultApplication 用来获取一个默认配置文件配置的应用实例
    - 实际上是使用默认配置 goboot.yml 调用 GetApplication 来获取应用实例
    - 这也是最常用的一个函数
- 函数：GetApplication 支持监听器的根据指定配置文件获取应用实例
    - 实际上是使用 ResolveGobootConfig 来获取配置结构，调用 GetConfigApplication 来获取应用实例
- 函数：GetConfigApplication 直接根据配置结构获取应用实例
- 函数：ReadGobootConfig 将指定的配置文件，解析为配置结构，解析前会进行 ${key:default} 占位符替换
- 函数：ResolveGobootConfig 读取指定的配置文件，并根据Profiles重定向读取配置
- 函数：ResolvePlaceholders 处理配置内容中的 ${key:default} 占位符
    - 替换取值的优先级：-D命令行参数 > 环境变量 > 占位符默认值
- 函数：GetCommandDashDefArgsMap 获取命令行 -D 参数映射（带全局缓存）
- 函数：ParseCommandDashDefArgsMap 从命令行参数中解析 -D 形式的参数
- 函数：MappingHandler 负责进行结构的路径自动映射，实现函数调用的处理方法
    - 这个方法服务于自动映射mapping和GobootController
    - 实现将请求按照规则，调用目标函数的过程
- 函数：HandleMappingMethodArg 负责实现参数类型的实际参数的自动绑定
    - 是为 MappingHandler 实现自动注入函数调用入参的核心函数调用
- 函数：ProxyHandler 负责进行实现proxy配置进行自动代理的处理函数
    - 代理转发时，会自动从请求中提取客户端真实IP（按Forwarded/X-Forwarded-For/X-Real-IP/X-Client-IP/True-Client-IP/RemoteAddr降级链）
    - 自动设置 X-Forwarded-For 头（已有则追加，否则新建）和 X-Real-IP 头，将客户端IP传递给后端
- 结构：ProxyUpstreamItem 定义了负载均衡中单个后端服务的配置
    - Backend：后端服务地址
    - Weight：后端服务权重（用于weight算法，启动时会进行归一化处理）
- 结构：ProxyUpstream 定义了代理的负载均衡配置
    - Enable：是否启用负载均衡
    - Algo：负载均衡算法，支持 ip_hash/round/random/weight/header_hash/path_hash
    - Headers：参与哈希计算的请求头列表（用于header_hash算法）
    - Current：当前轮询或选中的后端索引（运行时状态）
    - Backends：后端服务列表（[]ProxyUpstreamItem）
- 函数：GetClientIP 从请求上下文中按降级链提取客户端真实IP
    - 依次检查 Forwarded、X-Forwarded-For、X-Real-IP、X-Client-IP、True-Client-IP 头和 RemoteAddr
- 函数：GetHash 使用FNV-1a算法计算字符串的哈希值（用于ip_hash负载均衡）
- 结构：RateLimit 定义了全局限流的配置结构（令牌桶算法）
    - Enable：是否启用全局限流
    - CountPerSecond：每秒生产的令牌数，类型为float64，可以是小数
    - BucketSize：令牌桶最大容量
- 函数：RateLimitMiddleware 负责生成全局限流中间件
    - 基于令牌桶算法（token bucket）实现全局限流
    - 当令牌桶中没有令牌时，返回 HTTP 429 Too Many Requests，响应体为 `{"status": 429, "message": "Too many requests, please retry later!"}`
- 结构：StaticResources 定义了静态资源的配置结构
    - Enable：是否启用静态资源
    - DisablePreCompressGzip：是否禁用预压缩gzip(.gz)文件支持（默认false即启用）
    - Items：静态资源映射列表（[]StaticResourcesItem）
- 函数：PreCompressGzipFileResponseMiddleware 负责生成预压缩gzip(.gz)文件的响应中间件
    - 客户端支持gzip且存在对应的.gz文件时，直接返回.gz文件，并设置 Content-Encoding: gzip
    - 仅处理 GET/HEAD 请求，跳过 Range 请求，未命中.gz文件时交由后续静态资源处理
    - 该中间件注册在通用gzip动态压缩之前，由 StaticResources.DisablePreCompressGzip 控制是否启用
- 结构：FileServer 定义了文件服务器的配置结构
    - 包含了文件根目录、URL路径、嵌入静态文件系统等信息
    - 以及多个禁用开关：禁用上传、禁用下载、禁用列出、禁用浏览、禁用Office转换等
    - 其中 EmbedStaticFs 字段用于设置Go embed嵌入的静态文件系统
- 结构：FileInfoItem 定义了文件服务器返回的文件信息结构
    - 包含了文件名、相对路径、大小、大小描述、是否目录、修改时间
- 函数：FileServerMiddleware 负责生成文件服务器的中间件
    - 实现了文件浏览、上传、下载、列表等功能
    - 同时处理嵌入静态资源的访问
- 函数：ConvertOfficeFile 负贙Office旧格式文件转换为新格式
    - 支持 .doc -> .docx, .xls -> .xlsx, .ppt -> .pptx
    - 支持Windows COM组件和LibreOffice两种转换方式
- 函数：FindLibreOfficePath 动态探测LibreOffice的安装路径
    - 支持环境变量指定、Windows注册表探测、常见路径遍历
- 函数：GetPreferredIp 获取系统当前正在使用的出口IP
- 函数：GetAllIpList 获取所有网卡IPv4地址列表

## 生命周期监听器
- goboot提供了应用初始化和启动的各个生命周期的监听能力
- 可以通过监听器在特定阶段执行自定义逻辑
- 或者在特定阶段修改应用配置

### 监听器类型
- 监听器的函数类型定义如下
```go
type GobootListener func(boot *goboot.GobootApplication)
```

### 生命周期阶段
- goboot提供了以下生命周期监听点

| 监听点 | 触发时机 |
|--------|----------|
| `OnConfiged` | 配置加载完成后 |
| `OnBeforeUse` | 开始配置中间件之前（redis/数据源已初始化） |
| `OnBeforeStaticResources` | 配置静态资源之前 |
| `OnBeforeTemplatesResources` | 配置模板资源之前 |
| `OnBeforeProxy` | 配置代理之前 |
| `OnBeforeMapping` | 配置自动映射之前 |
| `OnPrepared` | 所有配置准备完成，应用返回之前 |
| `OnBeforeBanner` | 打印Banner之前（Run阶段） |
| `OnBeforeRun` | 启动服务之前（Run阶段） |

### 使用示例
```go
// 创建监听器
listener := &goboot.GobootLifecycleListener{
    // 配置加载完成后，修改配置
    OnConfiged: []goboot.GobootListener{
        func(boot *goboot.GobootApplication) {
            goboot.LogInfo("config loaded, app name: %v", boot.Config.Goboot.Application.Name)
            // 可以在此修改配置
            boot.Config.Goboot.Server.Port = 9090
        },
    },
    // 所有配置准备完成后，注册自定义路由
    OnPrepared: []goboot.GobootListener{
        func(boot *goboot.GobootApplication) {
            goboot.LogInfo("application prepared, registering custom routes")
            boot.App.GET("/custom", func(c *gin.Context) {
                c.JSON(200, gin.H{"msg": "custom route"})
            })
        },
    },
}

// 使用监听器获取应用
app := goboot.GetApplication(goboot.DefaultConfigFile, listener)
app.Run()
```

## 高级启动方式
- 除了使用 `GetDefaultApplication` 和 `GetApplication` 之外
- goboot还支持更灵活的启动方式

### 方式一：默认启动（最常用）
```go
app := goboot.GetDefaultApplication()
app.AddHandlers(&Api{})
app.Run()
```

### 方式二：指定配置文件+监听器
```go
app := goboot.GetApplication("./my-config.yml", listener)
app.AddHandlers(&Api{})
app.Run()
```

### 方式三：手动解析配置+自定义配置（支持embed嵌入文件）
- 这种方式适用于需要将前端资源打包到可执行文件中的场景
- 通过 `ResolveGobootConfig` 解析配置
- 然后修改配置结构，设置嵌入的静态文件系统
- 最后通过 `GetConfigApplication` 创建应用
```go
package main

import (
	"embed"
	"goboot/goboot"
	"io/fs"
)

// 使用go:embed将public目录嵌入到可执行文件中
//go:embed public/*
var staticFiles embed.FS

func main() {
	// 1. 解析配置文件
	cfgFile := goboot.DefaultConfigFile
	config := goboot.ResolveGobootConfig(cfgFile)

	// 2. 设置嵌入的静态文件系统
	distFS, _ := fs.Sub(staticFiles, "public")
	config.Goboot.Server.FileServer.EmbedStaticFs = distFS

	// 3. 创建应用实例
	app := goboot.GetConfigApplication(config, nil)

	// 4. 运行应用
	app.Run()
}
```
- 其中，嵌入的静态资源可通过 `/file-server/public/` 路径访问
- 例如：`public/lib/vue.js` 可通过 `/file-server/public/lib/vue.js` 访问
- `/lib/` 或 `/libs/` 路径下的资源自动设置7天缓存，其他资源设置1天缓存

### 测试Demo
- 文件结构
```shell script
hello
|---goboot
    |---goboot.go
|---templates
    |---index
        |---index.html
|---main.go
|---go.mod
|---goboot.yml
```
- 入口程序
- main.go
```go
package main

import (
	"hello/goboot"
	"net/http"
	"time"

	"github.com/gin-contrib/sessions"
	"github.com/gin-gonic/gin"
)

type Api struct {
}

func (api *Api) Hello(c *gin.Context) {
	c.JSON(200, gin.H{
		"hello": "hello",
	})
}

func (api *Api) ApiResp(resp *goboot.ApiResp, c *gin.Context) {
	c.JSON(200, resp.Ok(gin.H{
		"hello": "hello",
	}))
}

func (api *Api) GinResp(resp *goboot.ApiResp, c *gin.Context) *goboot.ApiResp {
	return resp.GinOk(c, "hello")
}

func (api *Api) GinApiResp(c *gin.Context) *goboot.ApiResp {
	return goboot.ApiOk(nil).GinOk(c, "hello")
}

func (api *Api) CtxResp(resp *goboot.CtxResp) *goboot.CtxResp {
	return resp.ApiJsonOk("hello")
}

func (api *Api) Login(resp *goboot.CtxResp, user *User) *goboot.CtxResp {
	return resp.ApiJsonOk("ok")
}

type User struct {
	Username string `form:"username"`
}

func (user *User) User_Info(c *gin.Context, post User, boot *goboot.GobootApplication, engine *gin.Engine, request *http.Request) {
	c.JSON(200, gin.H{
		"user": post.Username,
		"boot": boot.Config.ConfigFile,
	})

}

func (user *User) Session_Set(ctx *goboot.CtxResp) any {
	ctx.SessionSet("user", "admin")
	return ctx.ApiJsonOk("ok")
}

func (user *User) Session_Get(ctx *goboot.CtxResp, session sessions.Session) any {
	val := ctx.SessionGet("user")
	val = session.Get("user")
	return ctx.ApiJsonOk(val)
}

func (user *User) Redis_Set(ctx *goboot.CtxResp, redis *goboot.RedisCli) any {
	redis.Set("user", "root")
	return ctx.ApiJsonOk("ok")
}

func (user *User) Redis_Get(ctx *goboot.CtxResp, redis *goboot.RedisCli) any {
	val := redis.Get("user")
	return ctx.ApiJsonOk(val)
}

type AdminController struct {
}

func (con *AdminController) Path() string {
	return "/admin/"
}

func (admin *AdminController) XP_Get(ctx *goboot.CtxResp) any {
	return ctx.ApiJsonOk("ok")
}

func main() {
	app := goboot.GetDefaultApplication()

	app.AddHandlers(&Api{}).
		AddHandlers(&User{})

	app.AddControllers(&AdminController{})

	app.App.GET("/", func(c *gin.Context) {
		stime := time.Now().Format("2006-01-02 15:04:05")
		c.HTML(200, "index/index.html", gin.H{
			"now": stime,
		})
		// c.String(200, stime)
	})

	app.Run()
}


```
- 模板文件
- templates/index/index.html
```html
{{ define "index/index.html" }}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>首页</title>
</head>
<body>
    <h2>现在是北京时间 {{.now}}</h2>
</body>
</html>
{{ end }}
```
- 配置文件
- goboot.yml
```yml
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
      disablePreCompressGzip: false
      urlPath: /static
      filePath: ./static
    templateResources:
      enable: true
      filePath: ./templates/**/*.html
    session:
      enable: true
      # cookie/redis
      impl: cookie
      secretKey: 123456
      sessionKey: go-session
    redis:
      enable: true
      host: 127.0.0.1
      port: 6379
      password: ltb12315
      database: 0
    datasource:
      enable: true
      # mysql/postgres
      driver: mysql
      host: 127.0.0.1
      port: 6379
      url: user:password@tcp(localhost:5555)/dbname?tls=skip-verify&autocommit=true
      username: root
      password: 123456
      database: test_db
    gorm:
      enable: true
    https:
      enable: false
      pemPath: ./https/server.pem
      keyPath: ./https/server.key
    gzip:
      enable: false
      # BestCompression/BestSpeed/DefaultCompression/NoCompression
      level: DefaultCompression
      excludeExtensions:
        - .mp4
      excludePaths:
        - /api/
      excludePathRegexes:
        - "*download"
    proxy:
      enable: true
      items:
        - name: github.com
          path: /github/
          redirect: http://github.com/
          upstream:
            enable: false
            algo: round
            headers: []
            backends:
              - backend: http://127.0.0.1:9090/
                weight: 1
              - backend: http://127.0.0.1:9091/
                weight: 2
    mapping:
      enable: true
      items:
        - /api/
    rateLimit:
      enable: false
      countPerSecond: 30
      bucketSize: 100
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

## 静态文件服务器
- 在goboot中，已经内置了静态资源的访问方式定义
- 下面以几个常见的场景描述将goboot作为静态文件服务器
- 部署一些纯前端的项目
### 部署webpack项目
- 这里以部署vue项目为例
- 首先给出文件结构
```shell
goboot.exe
goboot.elf
goboot.yml
dist
  - index.html
  - app.js
  - ...
```
- 那么改写部署配置文件
- goboot.yml
```yaml
goboot:
  application:
    name: go-server
  profiles:
    active: dev
  server:
    # 这里定义端口
    port: 8080
    bannerPath: ./banner.txt
    staticResources:
      # 开启静态资源
      enable: true
      disablePreCompressGzip: false
      items:
        # 添加一个以根目录解析dist的静态资源
        - urlPath: /
          filePath: ./dist
          # 对于现在流行的单文件网站来说，需要使用tryFiles配合前端重定向，这也是部署Vue项目所必须的
          tryFiles: index.htm index.html
```
- [注意]在使用根路径解析静态资源时，其他映射类节点必须关闭
- 当需要进行二级路径映射时
  - 下面这个例子中，就使用了相对路径，并且指定为二级路径
```yaml
staticResources:
  enable: true
  disablePreCompressGzip: false
  items:
    - urlPath: /app
      filePath: ../dist
      tryFiles: index.htm index.html
```
- 下面是通用配置
  - 开始了gzip和cors
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
      disablePreCompressGzip: false
      items:
        - urlPath: /
          filePath: ../dist
          tryFiles: index.htm index.html
    templateResources:
      enable: false
      filePath: ./templates/**/*.html
    session:
      enable: true
      # cookie/redis
      impl: cookie
      secretKey: 123456
      sessionKey: go-session
    redis:
      enable: false
      host: 127.0.0.1
      port: 6379
      password: ltb12315
      database: 0
    datasource:
      enable: false
      # mysql/postgres
      driver: mysql
      host: 127.0.0.1
      port: 6379
      # url: user:password@tcp(localhost:5555)/dbname?tls=skip-verify&autocommit=true
      url: root:123456@tcp(127.0.0.1:3306)/test_db?charset=utf8mb4&parseTime=True&loc=Local
      username: root
      password: 123456
      database: test_db
    gorm:
      enable: false
    https:
      enable: false
      pemPath: ./https/server.pem
      keyPath: ./https/server.key
    gzip:
      enable: true
      # BestCompression/BestSpeed/DefaultCompression/NoCompression
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
        - name: github.com
          path: /github/
          redirect: http://github.com/
          upstream:
            enable: false
            algo: round
            headers: []
            backends:
              - backend: http://127.0.0.1:9090/
                weight: 1
              - backend: http://127.0.0.1:9091/
                weight: 2
    mapping:
      enable: false
      items:
        - /api/
    rateLimit:
      enable: false
      countPerSecond: 30
      bucketSize: 100
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

### 预压缩gzip支持
- 在前端项目构建时，可以对静态资源进行预压缩生成 `.gz` 文件
- 例如 `app.js` 对应生成 `app.js.gz`，两者放在同一目录
- 请求静态资源时，如果客户端支持gzip并且存在对应的 `.gz` 文件
- 则直接返回 `.gz` 文件，并自动设置 `Content-Encoding: gzip`
- 并且 `Content-Type` 仍然按照原文件的扩展名进行设置
- 这样可以避免运行时的动态压缩开销，提升响应速度
- 此功能默认开启，可通过静态资源配置中的 `disablePreCompressGzip: true` 关闭
- 生成 `.gz` 文件示例
```shell script
# Linux/macOS：-k 保留原文件
gzip -k -9 app.js

# 压缩dist目录下的所有文件
find ./dist -type f ! -name "*.gz" -exec gzip -k -9 {} \;
```
- 也可以使用构建工具的插件自动生成
    - vite项目：vite-plugin-compression
    - webpack项目：compression-webpack-plugin
- 配置示例
```yaml
goboot:
  server:
    staticResources:
      enable: true
      # 默认false，即默认启用预压缩
      disablePreCompressGzip: false
      items:
        - urlPath: /
          filePath: ./dist
          tryFiles: index.htm index.html
```
- 工作原理说明
    - 仅处理 GET/HEAD 请求
    - 带有 `Range` 请求头的请求（如视频拖动）不会使用预压缩文件
    - 客户端 `Accept-Encoding` 不包含 gzip 时不会使用预压缩文件
    - 预压缩未命中时，自动降级为普通静态资源响应
    - 预压缩命中时，不会再经过通用的 gzip 动态压缩中间件
- 注意：源文件更新后，需要重新生成对应的 `.gz` 文件

## 文件服务器
- 在goboot中，除了静态资源托管之外
- 还内置了一个功能丰富的文件服务器
- 支持文件上传、下载、目录浏览、在线预览等能力
- 通过配置 `goboot.server.fileServer` 即可启用

### 基础配置
- 最简配置如下
```yaml
goboot:
  server:
    fileServer:
      enable: true
      rootPath: ./file-server
      urlPath: /file-server
```
- 启动后，文件服务器将在 `/file-server` 路径下提供服务
- `rootPath` 指定了文件存储的本地根目录

### 配置项说明
- 完整的配置项如下
```yaml
goboot:
  server:
    fileServer:
      # 是否启用文件服务器
      enable: false
      # 文件存储的本地根目录
      rootPath: ./file-server
      # 文件服务的URL路径前缀
      urlPath: /file-server
      # 是否禁止上传功能
      disableUpload: true
      # 是否禁止下载功能
      disableDownload: false
      # 是否禁止列出文件列表API
      disableList: false
      # 是否禁止网页浏览功能
      disableBrowser: false
      # 是否禁止Office旧格式自动转换预览
      disableOffice: false
      # 是否禁止使用Windows COM组件进行Office转换
      disableOfficeCom: false
```
- 各配置项说明
    - `enable`：是否启用文件服务器
    - `rootPath`：文件存储的本地根目录路径
    - `urlPath`：文件服务的URL路径前缀，默认为 `/file-server`
    - `disableUpload`：禁止上传功能
    - `disableDownload`：禁止下载功能
    - `disableList`：禁止通过API列出文件列表
    - `disableBrowser`：禁止网页端浏览文件
    - `disableOffice`：禁止Office旧格式（.doc/.xls/.ppt）自动转换为新格式预览
    - `disableOfficeCom`：单独禁止Windows下使用Office/WPS COM组件转换，仅使用LibreOffice

### 功能接口
- 启用文件服务器后，提供以下四类接口
- 以下示例均以 `urlPath: /file-server` 为例

#### 网页浏览（Web UI）
- 访问路径
```
GET /file-server/browser/{子路径}
```
- 在浏览器中打开即可看到文件管理界面
- 支持浏览目录、上传文件、下载文件、在线预览
- 示例
    - `http://localhost:8080/file-server/browser/` 浏览根目录
    - `http://localhost:8080/file-server/browser/videos/` 浏览videos子目录
- 支持 `?sort_random=1` 参数进行随机排序

#### 文件列表 API
- 请求路径
```
GET /file-server/list/{子路径}
```
- 返回JSON格式的文件列表
- 示例
```
GET http://localhost:8080/file-server/list/
GET http://localhost:8080/file-server/list/videos/cat
```
- 响应示例
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
- 请求路径
```
POST /file-server/upload/{子路径}
```
- 使用 `multipart/form-data` 格式，字段名为 `file`
- 示例（curl）
```shell
curl -X POST -F "file=@dog.mp4" http://localhost:8080/file-server/upload/
```
- 响应示例
```json
{
  "code": 200,
  "msg": "",
  "data": "dog.mp4"
}
```

#### 文件下载
- 请求路径
```
GET /file-server/download/{子路径}/{文件名}
```
- 默认以附件形式下载
- 添加 `?type=inline` 可在浏览器中直接预览
- 示例
    - 下载文件：`GET http://localhost:8080/file-server/download/video/dog.mp4`
    - 在线预览：`GET http://localhost:8080/file-server/download/video/dog.mp4?type=inline`
- 支持断点续传（Range请求）

### 在线文件预览
- 文件服务器内置了丰富的在线预览能力
- 在网页浏览模式下点击文件即可自动预览
- 支持的文件类型

| 文件类型 | 支持格式 |
|----------|----------|
| 文本/代码 | `.txt` `.log` `.md` `.json` `.xml` `.yml` `.sql` `.java` `.py` `.go` `.js` `.css` `.html` 等 |
| 视频/音频 | `.mp4` `.avi` `.mkv` `.rmvb` `.flv` `.wav` |
| Word文档 | `.docx`，以及 `.doc` `.wps` `.rtf` `.odt` 等（需转换） |
| Excel表格 | `.xlsx`，以及 `.xls` `.csv` `.tsv` `.ods` 等（需转换） |
| PPT演示 | `.pptx`，以及 `.ppt` `.dps` `.odp` 等（需转换） |
| PDF | `.pdf` |
| OFD | `.ofd`（国产版式文档） |
| 3D模型 | `.glb` `.gltf` `.fbx` |
| HDR贴图 | `.hdr` |

### Office旧格式转换
- 对于 `.doc` `.xls` `.ppt` 等旧格式文件
- 系统会尝试自动转换为新版格式以便预览
- 转换方式按以下优先级尝试
    1. Windows下使用Office COM组件（需安装Microsoft Office）
    2. Windows下使用WPS COM组件（需安装WPS Office）
    3. LibreOffice（跨平台，需预先安装）
- 转换后的文件会缓存在源文件同级的 `.converted` 目录下
- 如果目标文件已存在，则跳过转换直接返回
- 可通过配置 `disableOffice: true` 禁止旧格式转换
- 可通过配置 `disableOfficeCom: true` 单独禁止Windows COM组件转换
- 也可以通过环境变量 `LIBREOFFICE_PATH` 指定LibreOffice的安装路径

### 内嵌静态资源
- 文件服务器还提供了内嵌静态资源服务
- 访问路径
```
GET /file-server/public/{文件路径}
```
- 此功能需要通过代码设置 `FileServer.EmbedStaticFs` 字段
- 用于将前端资源通过Go的embed打包到可执行文件中
- 其中 `/lib/` 或 `/libs/` 路径下的资源自动设置7天缓存
- 其他资源设置1天缓存
- 具体使用方式参见「高级启动方式」章节

### 配置示例
- 下面给出几个典型场景的配置

#### 只读文件共享服务
```yaml
goboot:
  server:
    fileServer:
      enable: true
      rootPath: ./shared-files
      urlPath: /files
      disableUpload: true
      disableBrowser: false
```

#### 搭配静态网站和代理的完整配置
```yaml
goboot:
  application:
    name: go-server
  profiles:
    active: dev
  server:
    port: 8080
    staticResources:
      enable: true
      disablePreCompressGzip: false
      items:
        - urlPath: /
          filePath: ./dist
          tryFiles: index.html
    fileServer:
      enable: true
      rootPath: ./file-server
      urlPath: /file-server
    proxy:
      enable: true
      items:
        - name: backend
          path: /api/
          redirect: http://127.0.0.1:9090/
          upstream:
            enable: false
            algo: round
            headers: []
            backends:
              - backend: http://127.0.0.1:9090/
                weight: 1
              - backend: http://127.0.0.1:9091/
                weight: 2
    gzip:
      enable: true
      level: DefaultCompression
    cors:
      enable: true
      allowAllOrigins: true
```