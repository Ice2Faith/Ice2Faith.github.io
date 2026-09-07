# Golang 使用包管理 GMOD 管理项目
- 创建项目
    - 项目名：hello
    - 包名等于项目名：hello
```shell script
mkdir hello
cd hello
go mod init hello
```
- 创建入口文件
    - 名为：main.go
```shell script
touch main.go
```
- 写入以下内容
```go
package main

import (
	"fmt"
)
func main(){
	fmt.Println("hello golang")
}
```
- 文件结构如下
```shell script
hello
|---go.mod
|---main.go
```
- 运行
```shell script
go run main.go
```
- 编译成可执行文件
```shell script
go build main.go
```

## 下载依赖
- 查找包网站
```shell script
https://pkg.go.dev/
```
- 下面以使用gin框架为例
- 在网站中搜索gin
- 找到如下结果
```shell script
gin (github.com/gin-gonic/gin)
```
- 其中括号内的就是依赖包
- 下面将给出使用这个包
```shell script
github.com/gin-gonic/gin
```
### 直接下载方式
- 命令行下载依赖
```shell script
go get -u github.com/gin-gonic/gin
```
- 在项目中导入使用即可
```go
import (
    "github.com/gin-gonic/gin"
)
```
### 使用download一键下载
- 此方式类似于webpack中的npm-install方式
- 这种方式，一般是导入别人的项目时
- 一键安装所有依赖的方式
- 在项目中添加依赖
```go
import (
    "github.com/gin-gonic/gin"
)
```
- 在命令行中执行download
```shell script
go mod download
```
### 使用vendor方式
- 此方式和download方式类似
- 区别于download下载的依赖在公共MOD中
- 而vendor方式下载的依赖则直接在项目的vendor目录下
- 这样好处是，避免污染公共MOD
- 在项目中添加依赖
```go
import (
    "github.com/gin-gonic/gin"
)
```
- 在命令行中执行download
```shell script
go mod vendor
```