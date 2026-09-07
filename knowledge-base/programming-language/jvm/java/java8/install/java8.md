# java8 环境安装

## 简介
- java8是目前使用最多的jdk版本

## 依赖环境
- 无

## 安装
- 检查yum
```shell script
yum list java*
```
- 安装
```shell script
yum -y install java-1.8.0-openjdk*
```
- 验证
```shell script
java -version
```

## 方式二
- 下载
```shell script
wget https://download.java.net/openjdk/jdk8u42/ri/openjdk-8u42-b03-linux-x64-14_jul_2022.tar.gz
```
- 解包
```shell script
tar -xzvf openjdk-8u42-b03-linux-x64-14_jul_2022.tar.gz
```
- 进入包
```shell script
cd openjdk-8u42-b03-linux-x64-14_jul_2022
```
- 复制路径
```shell script
pwd
```
- 添加环境变量
```shell script
vi /etc/profile
```
- 末尾添加以下配置
```shell script
export JAVA_HOME=
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin
```
- 退出并保存
- 重新应用环境变量
```shell script
source /etc/profile
```
- 验证环境
```shell script
java -version
```

## windows 安装
- 下载
  - 选择8u201版本
  - 这个版本及之前是商业免费的，避免版权纠纷
```shell
https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html
```
- 安装
- 双击运行此安装程序
```shell
jdk-8u201-windows-x64.exe
```
- 注意
- 安装路径不推荐包含空格，中文字符或者其他字符
- 建议安装路径
```shell
C:\Java\jdk1.8.0_201
```
- 勾选全部安装，包含JRE
- 一路安装下去
- 之后弹出提示安装JRE
- 此时进入刚才的安装路径
```shell
C:\Java
```
- 创建一个文件夹
```shell
C:\Java\jre1.8.0_201
```
- 将JRE的安装路径改为刚才新建的这个文件夹
```shell
C:\Java\jre1.8.0_201
```
- 继续安装
- 到此安装就完成了
- 接下来，配置环境变量
- 打开桌面
- 右键-我的电脑/此电脑
- 选择-属性
- 选择-高级系统设置
- 选择-环境变量
- 新增如下两个变量
    - 注意，JAVA_HOME的值，就是你的JDK安装目录
    - 这个目录里面应该至少包含bin,include,lib几个文件夹
    - 其中，bin目录下有java.exe,javac.exe
    - 请确保配置的路径正确
```shell
JAVA_HOME
C:\Java\jdk1.8.0_201

CLASSPATH
.;%JAVA_HOME%\jre\lib\rt.jar;%JAVA_HOME%\lib\dt.jar;%JAVA_HOME%\lib\tools.jar
```
- 给Path变量新增一行
```shell
Path
%JAVA_HOME%\bin
```
- 注意，默认情况下，你的电脑可能自带了一个java.exe
- 为了避免还是使用自带的java.exe导致的问题
- 建议将刚才新增的这行，上移到最上方的第一行去
- 一路保存/应用，完成环境变量配置
- 检查配置是否正确
- Win+R打开运行窗口
- 输入cmd回车
- 输入下面命令，查看是否回显了版本号
```shell
java -version
```
- 如果回显了版本号，则配置正确
- 完成JDK的安装