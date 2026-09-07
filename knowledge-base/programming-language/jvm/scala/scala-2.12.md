# scala-2.12 环境安装

## 简介
- scala是运行于jvm之上的一门与java互操作的语言
- 其拓展和简化了java的开发
- 大量应用于计算领域和大数据领域
- 例如：flink/spark

## 依赖环境
- java

## 安装
- 下载
```shell script
wget -c https://downloads.lightbend.com/scala/2.12.17/scala-2.12.17.tgz
```
- 解包
```shell script
tar -xzvf scala-2.12.17.tgz
```
- 添加环境变量
```shell script
vi /etc/profile.d/env_conf.sh
```
```shell script
export SCALA_HOME=/root/env/scala-2.12.17
export PATH=$PATH:${SCALA_HOME}/bin
```
```shell script
source /etc/profile
```
- 验证
```shell script
scala -version
```