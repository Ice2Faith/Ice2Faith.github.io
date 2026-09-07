# golang 安装和配置

## 简介
- golang 也称为 go 语言
- go 因为简介的语法，和面向过程的编程
- 还有在并发领域的流畅性和易开发性
- 以及直接生成可执行文件的原生性
- 都在性能和并发方面有着出色的表现
- 同时go的基础开发库功能全面
- go的生态也由Google的带领，逐步完善
- 已经在云原生和微服务领域中，有着一席之地
- 不少公司选择go作为web开发后端的首选语言

## 安装
- 下载
- 官方下载地址
```shell script
https://go.dev/dl/
```
- 目前版本的go下载直连
```shell script
https://go.dev/dl/go1.19.5.windows-amd64.msi
```
- 直接安装即可
- 为了不出现其它问题，选择安装路径如下
```shell script
C:\Go
```
- 安装完毕之后，配置环境变量
```shell script
GOPATH
C:\Go
```
```shell script
Path
%GOPATH%\bin
```
- 检查安装是否成功
```shell script
go version
```

## 配置国内镜像
- 打开命令行
- 配置镜像
```shell script
go env -w GOPROXY=https://mirrors.aliyun.com/goproxy/,direct
```
- go从11版本之后，就支持了模块
- 配置打开模块
```
go env -w GO111MODULE=on
```
- 查看配置是否成功
```shell script
go env
```
- 看到刚才配置的值没错
- 那就OK了

## 编写第一个go程序
- 新建文本文件 hello.go
- 写入以下内容
```go
package main

import "fmt"

func main(){
    fmt.Println("hello")
}
```
- 保存文件
- 在文件所在路径打开命令行
- 运行go
```shell script
go run hello.go
```
- 看到输出即可
- 生成exe程序
```shell script
go build hello.go
```
- 可以看到生成文件
```shell script
hello.exe
```

## go的开发IDE
- Goland (Jetbrains)
- Visual Studio Code (Microsoft)
- liteide (open source)

## 配置VSCode
- 这里以VSCode作为Go的开发IDE
- 下载VSCode
- 官网地址
```shell script
https://code.visualstudio.com/
```
- 打开VSCode
- 选择插件（左侧菜单栏，多个集装箱/窗格图标那个）
- 搜索 chinese
- 找到中文汉化插件
```shell script
Chinese (Simplified) (简体中文) Language Pack for Visual Studio Code
```
- 点击 install 安装插件
- 安装之后重启VsCode
- 安装go插件
- 搜索 go
- 找到 go 插件
```shell script
Go
Go Doc
```
- 安装这两个插件
- 重启VsCode
- 创建一个go源代码文件
- 比如上面的hello.go
- 用VsCode打开hello.go
- 右下角应该会提示安装go的相关插件
- 选择全部安装（Install All）
- 等待插件全部安装完毕（Successed）
- 接下来正常开发即可

## linux 下安装GO环境
- 下载安装包
```shell script
wget https://golang.google.cn/dl/go1.19.linux-amd64.tar.gz
```
- 解包
```shell script
tar -xzvf go1.19.linux-amd64.tar.gz
```
- 重命名
```shell script
mv go go-1.19
```
- 进入路径，获取完整路径
```shell script
cd go-1.19
```
```
pwd
```
- 添加环境变量
```shell script
vi /etc/profile
```
```shell script
export PATH=$PATH:/root/env/go-1.19/bin
```
- 应用环境变量
```shell script
source /etc/profile
```
- 测试安装情况
```shell script
go version
```
- 配置go的环境变量
- 和windows环境一样
