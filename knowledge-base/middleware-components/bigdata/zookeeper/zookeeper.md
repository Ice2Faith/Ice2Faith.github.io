# zookeeper 入门

## 简介
- zookeeper是一个资源管理框架
- 资源以树的形式管理
- 因此就像是一个文件管理系统一样
- 负责其他组件的协调工作

## 依赖环境
- java

---
## 环境搭建
- 下载zk: https://www.apache.org/dyn/closer.cgi/zookeeper/
- 解压zk:
```shell script
tar -xzvf zookeeper-3.4.10.tar.gz
```
- 更改配置文件
```shell script
cd ./zookeeper-3.4.10/conf
```
- 复制样例配置文件
```shell script
cp zoo_sample.cfg zoo.cfg
```
- 编辑配置文件
```shell script
vi zoo.cfg
```
### 单机配置
- 修改或添加一下配置，主要是指定数据文件和日志文件的存放位置
- 这样的配置下，数据文件将会被存放在：/zookeeper-3.4.10/datas目录下
```shell script
dataDir=../datas/data
dataLogDir=../datas/logs
```
### 集群配置
- 基于单机的配置
- 需要新增集群中zk服务的识别
- 下面假设有.11，.12，.13三台及其
- 表示格式为：server.{服务ID}={主机}:{消息通信端口}:{leader选举端口}
```shell script
server.1=192.168.1.11:2888:3888
server.2=192.168.1.12:2888:3888
server.3=192.168.1.13:2888:3888
```
- 另外，上面已经写了服务ID了，因此还要指定他们的服务ID
- 在指定的{dataDir}/myid中填写对应的服务ID
- 注意，上面示例给出了3台，则3台都要有各自的myid
### 启动服务
```shell script
cd ./zookeeper-3.4.10/bin
```
- 一般是以后台方式启动
```shell script
./zkServer.sh start
```
- 如果是有问题的时候，可以用前台方式启动，方便查看日志
```shell script
./zkServer.sh start-foreground
```
### 停止服务
```shell script
./zkServer.sh stop
```
### 集群下的启停
- 需要分别把集群中的每个zk服务进行启停
### 连接与测试
```shell script
cd ./zookeeper-3.4.10/bin
```
- 单击模式下，直接连接即可
```shell script
./zkCli.sh
```
- 如果是远程主机，需要带上服务地址
```shell script
./zkCli.sh -server 192.168.1.6:2181
```
- 集群模式下连接，需要指定集群
```shell script
./zkCli.sh -server 192.168.1.11:2181,192.168.1.12:2181,192.168.1.13:2181
```
- 测试
- 进入zkClient之后，就可以使用提供的命令了
```shell script
help
```
- 最简单的查看拥有的资源，应该默认有一个/zookeeper资源
```shell script
ls /
```
- 使用quit退出zkCli
```shell script
quit
```


