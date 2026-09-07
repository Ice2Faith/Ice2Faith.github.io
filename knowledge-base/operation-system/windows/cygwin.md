# cygwin 安装

---

## 简介
- 这是一个能够在windows环境中使用linux命令的工具
- 这样，对于习惯使用linux命令的群体来说
- 在windows环境中，也能够熟悉的使用linux命令进行操作
- 但是，不是什么linux命令都支持
- 毕竟这是模拟命令
- 不是真实的linux系统

## 安装
- 下载
    - 选择 setup-x86_64.exe 下载即可
```shell script
https://www.cygwin.com/install.html
```
- 运行安装，进行安装向导
- 下面是一些需要设置的向导项
- 选择下载源
```shell script
Choose A Download Source 
选择一个下载源

Install from Internet
从网络下载
```
- 安装路径
```shell script
Select Root Install Directory
选择安装根目录

我选择的目录，后面配置环境变量要用
D:\cygwin64
```
- 软件包下载路径
```shell script
Select Local Package Directory
选择本地包路径

我选择的目录
D:\cygwin64\pkgs
```
- 选择下载站点
```shell script
Choose A Download Site
选择一个下载站

从选框中选择一个国内的即可
没有国内的话，可以添加一个网易的镜像
https://mirrors.163.com/
或者阿里的镜像
https://mirrors.aliyun.com
```
- 选择几个基本软件包
```shell script
Select Packages
选择包

选择下面这些包
注意，
wget,tar,zip,unzip,curl,gawk,bzip2
```
- 安装完成

## 添加环境变量
- 添加家变量
```shell script
CYGWIN_HOME
D:\cygwin64
```
- 添加Path变量
```shell script
Path
%CYGWIN_HOME%\bin

Path
%CYGWIN_HOME%\sbin

Path
%CYGWIN_HOME%\usr\local\bin
```

## 测试
- 打开CMD
- 测试基本命令是否可用
```shell script
ls -al
```
- 基本安装完毕

## 配置软件包下载
- 不管是在linux中使用yum还是apt-get
- 都习惯了直接安装
- 而不是在windows中，再次使用安装向导 setup-x86_64.exe 进行添加需要的软件包
- 下载脚本
    - 里面有一个 apt-cyg 的 shell 脚本
    - 下载这个脚本
```shell script
https://github.com/transcode-open/apt-cyg
```
- 将这个脚本移动到目录下去
```shell script
D:\cygwin64\bin
```
- 测试安装
    - 注意，这个需要在 Cygwin64 Terminal 中执行
    - 不能在CMD中执行
    - 因为这实际上是一个 shell 脚本
    - 如果你正确的配置了环境变量
    - 则可以在CMD中直接打开这个terminal
    - 使用这个命令 mintty
```shell script
apt-cyg install nano
```
