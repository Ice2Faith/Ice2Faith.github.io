# mongodb5 入门

## 简介
- mongodb是一个NoSql数据库
- 基于bson存储json文档
- 此文档部门内容，请参考mongodb6的文档

## 依赖环境
- 无

---
## 环境搭建
- 下载
```shell script
wget -c https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-5.0.9.tgz

-- centos8
wget -c https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel80-5.0.9.tgz
```
- 解压:
```shell script
tar -zxvf mongodb-linux-x86_64-rhel70-5.0.9.tgz
mv mongodb-linux-x86_64-rhel70-5.0.9 mongodb-5.0.9
```
- 更改配置文件
```shell script
cd mongodb-5.0.9
```
- 编辑配置文件
```shell script
mkdir conf
vi ./conf/mongo.conf
```
### 配置
- 主要指定日志目录，数据文件目录，fork守护进程
- 如果启动失败，将fork设置为false查看错误日志
```shell script
dbpath=../mongo-datas/data/db
logpath=../mongo-datas/logs/mongo.log
#以追加的方式记录日志
logappend = true
#端口号 默认为27017
port=27017
#以后台方式运行进程
fork=true
 #开启用户认证
auth=true

#mongodb所绑定的ip地址
bind_ip = 0.0.0.0
#启用日志文件，默认启用
journal=true
#这个选项可以过滤掉一些无用的日志信息，若需要调试使用请设置为false
quiet=true
```
- 编写启动文件
```shell script
cd bin
vi start.sh
```
```shell script
./mongod -f ../conf/mongo.conf
```
- 编写停止文件
```shell script
vi stop.sh
```
```shell script
./mongod -f ../conf/mongo.conf --shutdown
```
- 添加权限
```shell script
chmod a+x *.sh
```

## 启动服务
```shell script
./start.sh
```

## 验证
- 有信息输出即可
```shell script
./mongod
```

## 配置认证
- 进入客户端
```shell script
./mongo
```
- 本部分内容除了使用的命令为mongo
- 其余内容同mongodb6部分

## 数据库的dump和restore
- 本章节内容同mongodb6部分

# 副本集配置
- 副本集，是副本集群
- 每一个节点都拥有完整的数据
- 三种集群模式
    - 主从模式，实现读写分离，但是并不能实现HA
        - 也就是说，宕机就是宕机了，从库并不会继续提供服务
        - 而从库只提供读的能力，因此整个集群一旦master宕机
        - 就只能读，而不能写
    - 副本集模式，一般性的集群，能够实现HA
        - 集群中拥有master和replicate
        - master进行写，replicate进行读
        - 当master宕机之后，采用分布式选举协议
        - 重新选举一个新的master继续提供服务
    - 分片模式，实现数据分片，分散存储，每个节点保存一部分数据，能够实现HA
        - 这种就是使用机群战术换取性能的方式
        - 采用分布式存储、分布式计算
        - 实现大数据量的读写操作
- 遵从bully分布式协议，新版本使用raft协议
- 总所周知，分布式协议，都需要一个leader或者master
- 都需要选举这个leader或者master
- 因此必须半数通过
- 因此，最低起步3台主机
- 这里以101,102,103三台主机配置副本集为例
- 其中101作为master，102和103作为replicate副本
## 所有节点配置
- 配置文件
```shell script
vi mongo.conf
```
- 生成sslkey
```shell script
openssl rand -base64 128 > conf/mongo.key
```
- 更改权限
```shell script
chmod 600 conf/mongo.key
```
- 更改用户组
    - 和启动时使用的用户组一致
```shell script
chown root:root conf/mongo.key
```
```shell script
# 复制集名称，名称自定义，整个集群一样就行
replSet=mongo-cluster
# sslkey配置
keyFile=/home/env/mongodb-5.0.9/conf/mongo.key
```
- 重启mongodb

## 主节点配置
- 登录客户端
```shell script
./mongo
```
- 配置副本集初始化
```js
var config={
    _id: "mongo-cluster", // 集群名称，和配置文件中要一致
    members: [
        // id无所谓，唯一就行
        // host填写对应的主机端口即可
        {_id: 1, host: "192.168.1.101:27017"},
        {_id: 2, host: "192.168.1.102:27017"},
        {_id: 3, host: "192.168.1.103:27017"},
    ]
}

rs.initiate(config)
```
- 查看配置是否正常
```js
rs.conf()
```
- 其他的一些配置方式
```js
rs.add("192.168.1.104:27017")

rs.remove("192.168.1.104:27017")
```
## 副节点配置
- 登录客户端
```shell script
./mongo
```
- 授予查询权限
```js
rs.slaveOk()
```
