# Golang 实现 WEB 开发
- Golang的web开发
- 常用的有gin框架和iris框架
- 这里以使用gin框架
- 官网地址
```shell script
https://gin-gonic.com/
```

## 准备工作
- 使用go-mod创建一个项目
- 项目名假如为hello
- 则文件结构如下
```shell script
hello
|---go.mod
|---main.go
```
- 编写第一个服务
- 搜索gin依赖
- 找到如下
```shell script
gin (github.com/gin-gonic/gin)
```
- 下载依赖
```shell script
go get github.com/gin-gonic/gin
```
- 修改 main.go
```go
package main

import (
	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	r.GET("/", func(c *gin.Context) {
		c.String(200, "hello gin.")
	})

	r.Run()
}
```
- 编译运行
```shell script
go run main.go
```
- 在浏览器查看
```shell script
http://localhost:8080/
```
- 浏览器中看到如下
```shell script
hello gin
```

## 快速入门
- 遇事不决，上官网示例
```shell script
https://gin-gonic.com/zh-cn/docs/examples/
```
### 基础部分
- 实例化引擎
- 也被称作路由
```go
engine := gin.Default()
```
- 这是最常用的方式
- 接着，就可以启动这个引擎
- 也就是运行
```go
engine.Run()
```
- 完整代码
```go
package main

import "github.com/gin-gonic/gin"

func main() {
	engine := gin.Default()

	engine.Run()
}
```
### 路由部分
- 路由，也就是处理URL请求
- 给请求分配处理函数
- 原生上支持RESTful风格接口
- 一个路由的基本形式是这样的
- 是基于 gin.Engine 定义的，也就是下面的 engine 结构
```go
engine.GET("/user/name",func (c * gin.Context)  {
	c.JSON(200,gin.H{
		"data":"admin"
	})
})
```
- 第一个参数，是URL的Path部分，也称作路径
- 第二个参数，是gin.HandlerFunc类型的函数，原型就是：func (c * gin.Context)
- 有时候，也分开写
```go
func getUserInfo(c *gin.Context){
	c.JSON(200,gin.H{
		"name":"user",
	})
}

engine.GET("user/info", getUserInfo)
```
- 类似的函数，大概有：GET，PUT，DELETE，POST，Any
- 完整代码如下
```go
package main

import "github.com/gin-gonic/gin"

func getUserInfo(c *gin.Context) {
	c.JSON(200, gin.H{
		"name": "user",
	})
}

func main() {
	engine := gin.Default()

	engine.GET("/user/name", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"data": "admin",
		})
	})

	engine.GET("user/info", getUserInfo)

	engine.POST("/user/add", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"msg": "ok",
		})
	})

	engine.PUT("/user/edit", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"msg": "ok",
		})
	})

	engine.DELETE("/user/delete", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"msg": "ok",
		})
	})

	engine.Any("/user/list", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"data": []string{"root", "admin"},
		})
	})
	
	engine.Run()
}

```

## 分组路由
- 分组路由，实际上是一种垂直划分方式
- 将路由按照模块划分
- 每个模块有自己的固定基础前缀路径
- 这样，将相同前缀的路由合并在一起的用法
- 就是分组路由
- 比如：/api/getUserInfo 和 /api/getPermissions
- 这两个路由，都具有公共前缀 /api
- 则，可以合并成为一个分组路由 /api
- 用法实例
```go
engine := gin.Default()

apiRouters := engine.Group("/api")
{
	apiRouters.GET("/getUserInfo", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"msg": "ok",
		})
	})
	apiRouters.GET("/getPermissions", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"msg": "ok",
		})
	})
}
```

## 参数获取
- 在web请求中
- 获取请求参数是一个必须的过程
- 这一部分指的是，手动获取参数
- 自动绑定到结构上的方式，在下一点【参数绑定】中给出
- 
### 获取URL参数
- 这个一般是在GET请求等不含有请求体的情况下，常用的方式
- URL参数也叫做QueryString
- 在gin中，也就是使用Query方法来获取参数
- 同时，对于一些有默认值的参数，可以使用DefaultQuery来伴随默认值
- 用法如下
```go
engine := gin.Default()

engine.GET("/getUserInfo", func(c *gin.Context) {
	userId := c.Query("userId")
	userType := c.DefaultQuery("userType", "0")
	c.JSON(200, gin.H{
		"userId":   userId,
		"userType": userType,
	})
})
```

### 获取表单参数
- 表单参数，也就是常说的form参数
- 一般通过POST或PUT提交
- 也就是Content-Type为以下两种的表单
	- application/x-www-form-urlencoded
	- multipart/form-data
- 一般也被叫做Form参数或者PostForm参数
- 在gin中，也就是使用PostForm来获取参数
- 同样，带有默认值获取的有 DefaultPostForm
- 用法如下
```go
engine := gin.Default()

engine.POST("/addUser", func(c *gin.Context) {
	username := c.PostForm("username")
	realname := c.DefaultPostForm("realname")
	c.JSON(200, gin.H{
		"username": username,
		"realname": realname,
	})
})
```

### 获取路径变量
- 路径变量，也就是作为URL路径中的一部分出现的变量
- 例如：/deleteUser/1001
- 这里，这是一个路径，并不带有请求参数
- 而是有1001这一级作为路径的一部分
- 业务上被视为要删除的用户的ID
- 这样的，出现在路径中的参数，被叫做路径变量
- 在gin中的用法，需要配合路由的路径配置来获取
- 通过 : 定义路由中的路径变量
- 通过 Param 方法，获取对应的路径变量
- 用法如下
```go
engine := gin.Default()

engine.DELETE("/deleteUser/:userId", func(c *gin.Context) {
	userId := c.Param("userId")
	c.JSON(200, gin.H{
		"userId": userId,
	})
})
```
- 特殊的路径变量
- 也就是多级匹配
- 一般用来匹配某级路由之后的所有路径
- 常用的场景包含，下载文件，动态查找资源等
- 在gin中，使用 * 定义路由
- 同样使用 Param 方法获取路径变量
- 用法如下
```go
engine := gin.Default()

engine.GET("/fileExists/*filePath", func(c *gin.Context) {
	filePath := c.Param("filePath")
	_, err := os.Stat(filePath)
	c.JSON(200, gin.H{
		"data": err == nil,
	})
})
```

### JSON/XML请求
- 对于这种方式，gin没有直接获取参数的方式
- 更推荐直接使用【参数绑定】到结构体的方式来获取
- 当然，这里还是会讲解自己手动获取JSON/XML的方式
- 在http中，并没有支持JSON/XML数据的解析和获取
- 因此只能获取原始数据 raw-data
- 使用gin的GetRawData获取原始的字节切片
- 再通过对应的json/xml解析包来解析为结构体
- 下面，先定义一个结构体，同时支持JSON和XML的Unmarshal解析
```go
type RawJsonXml struct {
	UserId   string `json:"userId" xml:"userId"`
	UserName string `json:"userName" xml:"userName"`
}
```
- 下面就是解析为struct示例
```go
engine := gin.Default()

engine.POST("/raw", func(c *gin.Context) {
	bytes, err := c.GetRawData()
	if err == nil {
		bean := &RawJsonXml{}
		json.Unmarshal(bytes, bean)
		// xml.Unmarshal(bytes, bean)
		c.JSON(200, gin.H{
			"msg": "ok",
		})
	} else {
		c.JSON(200, gin.H{
			"msg": "error",
		})
	}
})
```

### 文件上传
- 文件上传，其实也是走PostForm方式
- 但是由于是文件，因此获取文件的方式有一点差异
- 在实际使用之前，首先说一下，常用的配置
- 也就是上传文件大小限制的配置
```go
engine := gin.Default()

engine.MaxMultipartMemory = 8 << 20
```
- 通过 FormFile 获取指定表单名称的文件头信息
- 通过 SaveUploadedFile 将指定头的文件保存到指定路径
- 下面给出一个示例
- 示例中，文件按照上传日期分组存放到不同的文件夹中
- 上传的表单名为 file
```go
engine := gin.Default()

engine.POST("/upload", func(c *gin.Context) {
	multipartFile, err := c.FormFile("file")
	if err == nil {
		fileName := multipartFile.Filename
		fileSize := multipartFile.Size
		day := time.Now().Format("2006-01-02")
		savePath := path.Join("./upload", day, fileName)
		c.SaveUploadedFile(multipartFile, savePath)
		c.JSON(200, gin.H{
			"msg":  savePath,
			"size": fileSize,
		})
	} else {
		c.JSON(200, gin.H{
			"msg": "upload error",
		})
	}
})
```
- 上面的示例中，适用于单个文件上传
- 或者多个文件上传，但是表单名不一样的情况
- 如果表单名字一样的多文件上传
- 则需要使用 MultipartForm 来获取整个上传的表单
- 通过表单的 File 或 Value 字典获取对应的值
- 多文件同名时，值为表单名称+[]
- 下面直接给出示例
```go
engine := gin.Default()

engine.POST("/upload", func(c *gin.Context) {
	multipartForm, err := c.MultipartForm()
	multipartFiles := multipartForm.File["file[]"]
	if err == nil {
		for _, multipartFile := range multipartFiles {
			fileName := multipartFile.Filename
			day := time.Now().Format("2006-01-02")
			savePath := path.Join("./upload", day, fileName)
			c.SaveUploadedFile(multipartFile, savePath)
		}
		c.JSON(200, gin.H{
			"msg": "ok",
		})
	} else {
		c.JSON(200, gin.H{
			"msg": "upload error",
		})
	}
})
```

## 参数绑定
- 将请求参数绑定到结构上
- 是开发中常用的手段
- 因为结构在开发中更方便使用
- 在gin中，是基于 gin.Context 结构使用的
- 绑定参数使用 c 的Bind系列函数实现
- 首先，需要定义结构
```go
type User struct {
	Username string `form:"username"`
	Age      int    `form:"age"`
}
```
- 注意，因为绑定参数，gin底层使用的是反射实现的
- 因此，结构和结构的字段都需要是共有的
- 反射才能够获取得到
- 但是，如果直接定义结构，结构一旦需要公有
- 在Go中，首字母大写被视为公有，首字母小写被视为私有
- 因此，反射，就必须首字母大写
- 但是一般表单或者JSON数据，都是使用小驼峰的
- 也就是说，首字母是小写的
- 这样，就需要借助GO的TAG标签来实现
- 也就是上面，结构定义最后的字符串
- 其中form这个TAG就对应了gin框架实现参数绑定所查找的TAG
- form:"username"就可以理解为，让gin按照username这个形式的参数进行绑定
- 这样就解决了驼峰和Go访问性的问题
- 下面，来绑定参数
```go
engine.POST("/user/add", func(c *gin.Context) {
	var user User
	c.ShouldBind(&user)
	c.JSON(200, gin.H{
		"data": user.Username,
	})
})
```
- 这里使用，ShouldBind进行参数绑定
- 接受一个参数，需要为指针类型
- 由于声明的是值类型，因此取地址
- 当然，也可以直接声明初始化一个指针类型的
- 如下
```go
engine.POST("/user/add", func(c *gin.Context) {
	user := &User{}
	c.ShouldBind(user)
	c.JSON(200, gin.H{
		"data": user.Username,
	})
})
```
- 为什么需要为指针类型
- 因为，在Go中，结构体传参，是值传递
- 也就是说，如果不传地址，则实参和形参操作的数据就不是一个
- 就会出现，函数内修改了结构的值，函数外不受影响
- 重新回来
- ShouldBind函数，会自动根据请求的Method和ContentType自动解析请求参数
- 因此，大部分的场景都是可以使用的
- 如果，明确的知道需要绑定参数的来源和格式
- 则可以使用，明确的函数：ShouldBindJSON,ShouldBindQuery,ShouldBindXML等函数
- 完整代码，如下
```go
package main

import "github.com/gin-gonic/gin"

type User struct {
	Username string `form:"username"`
	Age      int    `form:"age"`
}

func main() {
	engine := gin.Default()

	engine.POST("/user/add", func(c *gin.Context) {
		// var user User
		// c.ShouldBind(&user)
		user := &User{}
		c.ShouldBind(user)
		c.JSON(200, gin.H{
			"data": user.Username,
		})
	})

	engine.Run()
}

```

## 响应数据
- 响应数据，在当下，最流行的就是JSON格式
- 但是gin还是保留了拓展
- 主要分为三种：JSON，String，Html
- 响应数据，还是基于 gin.Context 结构
### 响应JSON数据
```go
engine.POST("/user/add", func(c *gin.Context) {
	c.JSON(200, gin.H{
		"data": 12,
	})
})
```
- 通过JSON方法，直接返回JSON数据即可
- 第一个参数，表示HTTP状态码，可以使用net/http包下面定义的Status系列常量表示
- 第二个参数，是一个任意数据类型
- 常见的有以下几种使用示例
- 其中，使用结构体是，需要借助json这个TAG转换为小驼峰
- 和上面说得绑定参数使用form这个TAG的原因一致
- go进行转换为JSON时，也是反射
- JSON响应完整示例
```go
package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
)

type User struct {
	Username string `json:"username"`
	Age      int    `json:"age"`
}

func main() {
	engine := gin.Default()

	engine.POST("/user/info", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"data": 12,
		})
	})

	engine.POST("/user/info", func(c *gin.Context) {
		c.JSON(200, map[string]interface{}{
			"data": 12,
		})
	})

	engine.POST("/user/info", func(c *gin.Context) {
		c.JSON(200, User{
			Username: "admin",
			Age: 22,
		})
	})

	engine.Run()
}
```
### 响应String数据
- 也就是直接响应TEXT文本
- 这种目前的使用比较少
- 部分还是有使用到
```go
engine.GET("/", func(c *gin.Context) {
	c.String(200,"hello gin")
})

engine.GET("/", func(c *gin.Context) {
	c.String(200,"hello %v","gin")
})
```
- String方法，也是接受两个参数
- 第一个参数，还是HTTP状态码
- 第二个参数，是字符串或格式化模板字符串
- 第三个参数，是变长参数，用于给参数二作为格式化参数

### 响应HTML渲染页面
- 这里，响应的HTML页面
- 不是存粹的WEB页面
- 而是后端渲染的模板页面
- 在Java中，等价于JSP
- 在springMVC中，等价于View
- 这个示例，先给完整代码
```go
package main

import (
	"github.com/gin-gonic/gin"
)


func main() {
	engine := gin.Default()

	engine.LoadHTMLGlob("./templates/*.html")

	engine.GET("/", func(c *gin.Context) {
		c.HTML(200, "index.html", gin.H{
			"title": "首页",
		})
	})

	engine.Run()
}

```
- 使用HTML方法，响应模板
- 方法有三个参数
- 第一个参数，HTTP状态码
- 第二个参数，模板文件ID，注意，我没有说是文件名称
- 第三个参数，模板渲染的绑定参数，是任意类型
- 要使用模板，必须调用 LoadHTMLGlob 方法，指定模板的路径
- 上面的实例中，匹配了templates目录下的*.html作为模板
- 并且，LoadHTMLGlob 必须在路由方法之前调用，也就是在 GET POST 等方法之前调用
- 准备模板文件
```shell script
templates/index.html
```
```html
{{ define "index.html" }}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>首页</title>
</head>
<body>
    <h2>这是后端标题 {{.title}}</h2>
</body>
</html>
{{ end }}
```
- 在模板中，使用 {{ }} 来表示服务端标记
- 使用 {{ define 模板ID }} 来指定模板ID
- 只是，一般情况下，模板ID就写为路径文件名
- 因此，可能会带来一定的混淆
- 但是，记住，使用HTML方法，使用的是模板ID，不是模板文件路径
- 在模板中，使用 {{.title}}来取的了HTML函数的渲染参数中的title字段
- 【模板方法】
- 在模板中，可以使用预定义的模板方法
- 使用方法如下
- 假如方法为
```go
func Add(num1,num2 int) int{
	return num1+num2
}
```
- 在模板中调用格式为
```html
{{Add .num1 .num2}}
```
- 实际上就是将参数和函数分离，去掉了圆括号
- 那么，首先，肯定是没有Add方法的，在模板中
- 因此，就需要定义这个方法到模板映射中
- 让gin能够识别这个方法
- 定义方式如下
```go
engine.SetFuncMap(template.FuncMap{
	"Add",Add
})
```
- 这样，就把Add方法，映射为模板中的Add方法了
- 一般建议，映射的名称和实际的名称一致


### 响应文件
- 响应文件，也就是文件下载
- 在gin中，文件下载通过File方法实现
- 另外，更常见的应该是作为附件下载，附件需要指定附件名称
- 也就是使用 FileAttachment 方法
- 用法如下
```go
engine := gin.Default()

engine.GET("/download/*filePath", func(c *gin.Context) {
	filePath := c.Param("filePath")
	fileName := path.Join("./upload", filePath)
	// c.File(fileName)
	c.FileAttachment(fileName, path.Base(fileName))
})
```

## cookie 操作
- cookie在当前的无状态token盛行的时代
- 虽然已经没什么用了
- 但是，如果还有使用cookie的场景
- 也是需要知道的
- 对于cookie的操作，就是两个函数的使用 Cookie 和 SetCookie
- 下面给出设置localhost/下一个30分钟的cookie为例
- 下面直接给出示例
```go
engine := gin.Default()

engine.POST("/cookie/get", func(c *gin.Context) {
	userStr, err := c.Cookie("user")
	if err == nil {
		c.JSON(200, gin.H{
			"msg": userStr,
		})
	}
})

engine.POST("/cookie/set", func(c *gin.Context) {
	c.SetCookie("user", "admin", 30*60, "/", "localhost", true, false)
	c.JSON(200, gin.H{
		"msg": "ok",
	})
})
```

## session 操作
- 同样，对于session，在当前的无状态token盛行的时代
- session的使用范围已经大幅度降低了
- 但是，还是有部分还是使用session的
- 在gin中，默认没有提供session，需要借助第三方的中间件的实现
- 首先，下载中间件
```shell script
go get github.com/gin-contrib/sessions
```
- 然后配置并使用中间件
- 这里，session有多重存储模式
- 下面就是使用cookie的存储模式
- 也就是 cookie.NewStore
- 这个方法接受一个byte切片，也就是存储的秘钥
- 然后通过sessions.Sessions配置一个中间件
- 第一个参数为存储到客户端cookie中的签名名称
- 第二个参数就为session的存储
```go
engine := gin.Default()

store := cookie.NewStore([]byte("123456"))
engine.Use(sessions.Sessions("gin-session", store))
```
- 使用session
- 首先通过sessions.Default用gin.Context构造出session
- 然后基于session进行获取和保存操作
- 需要注意的是，session的保存，必须进行save操作
- 否则不会保存session
- 下面给出使用例子
```go
engine := gin.Default()

engine.POST("/session", func(c *gin.Context) {
	session := sessions.Default(c)

	session.Set("userId", "1001")
	session.Save()

	userId, ok := session.Get("userId").(string)
	if ok {
		c.JSON(200, gin.H{
			"msg": userId,
		})
	} else {
		c.JSON(200, gin.H{
			"msg": "bad session",
		})
	}
})
```
- 如果，在进行分布式服务的时候
- session中间件，也提供了基于redis存储的session
- 使用上一致，也就是配置session不一样
- 下面给出配置
- 使用redis.NewStore构造redis的session存储
- 返回两个值，一个是store，另一个就是error
- 接受的参数如下
- 第一个参数，也就是redis-database
- 第二个参数，默认就是tcp
- 第三个参数，也就是host:port
- 第四个参数，也就是redis的访问密码
- 第五个参数，是session存储的秘钥
```go
store, err := redis.NewStore(0, "tcp", "127.0.0.1:6379", "123456", []byte("123456"))
	if err != nil {
		panic(err)
	}
	engine.Use(sessions.Sessions("gin-session", store))
```

## 热加载
- 热加载需要借助第三方工具
- 并且要求自己的项目入口文件为 main.go
- 工具使用 fresh
- 安装
```shell script
go install github.com/pilu/fresh@latest
```
- 在项目中执行
```shell script
go get github.com/pilu/fresh
```
- 使用热加载运行项目
```shell script
fresh
```