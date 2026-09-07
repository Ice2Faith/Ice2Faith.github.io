# mongodb6 入门

## 简介
- mongodb是一个NoSql数据库
- 基于bson存储json文档

## 依赖环境
- 无

---
## 环境搭建
- 下载
```shell script
wget -c https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel80-6.0.3.tgz
```
- 解压:
```shell script
tar -zxvf mongodb-linux-x86_64-rhel80-6.0.3.tgz
mv mongodb-linux-x86_64-rhel80-6.0.3 mongodb-6.0.3
```
- 更改配置文件
```shell script
cd mongodb-6.0.3
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
systemLog:
   #MongoDB发送所有日志输出的目标指定为文件
   # #The path of the log file to which mongod or mongos should send all diagnostic logging information
   destination: file
   #mongod或mongos应向其发送所有诊断日志记录信息的日志文件的路径
   path: "../mongo-datas/logs/mongo.log"
   #当mongos或mongod实例重新启动时，mongos或mongod会将新条目附加到现有日志文件的末尾。
   logAppend: true
storage:
   #mongod实例存储其数据的目录。storage.dbPath设置仅适用于mongod。
   ##The directory where the mongod instance stores its data.Default Value is "/data/db".
   dbPath: "../mongo-datas/data/db"
   journal:
      #启用或禁用持久性日志以确保数据文件保持有效和可恢复。
      enabled: true
processManagement:
   #启用在后台运行mongos或mongod进程的守护进程模式。
   fork: true
net:
   #服务实例绑定的IP，默认是localhost
   bindIp: 0.0.0.0
   #bindIp
   #绑定的端口，默认是27017
   port: 27017
security:             
  # 开启认证   
  authorization: enabled
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

## mongodb6 客户端安装
- mongodb6 之后，没有自带mongo命令
- 而是变成了mongosh命令
- 并且独立为单独的包
- 因此需要独立安装
- 安装路径无所谓，同一台机器上就行
- 下载
```shell script
wget https://downloads.mongodb.com/compass/mongosh-1.6.0-linux-x64.tgz
```
- 解包
```shell script
tar -xzvf mongosh-1.6.0-linux-x64.tgz
```
- 重命名
```shell script
mv mongosh-1.6.0-linux-x64 mongosh-1.6.0
```
- 进入使用
```shell script
cd mongosh-1.6.0
cd bin
```
- 使用
```shell script
./mongosh
```

## 配置认证
- 进入客户端
```shell script
./mongosh
```
- 使用认证数据库
```shell script
use admin
```
- 创建用户
```shell script
db.createUser({ user:"root", pwd:'root', roles:["root"] })
```
- 认证
```shell script
db.auth("root","root")
```
- 查看用户
```shell script
show users
```
- 查看数据库
```shell script
show databases
```
- 创建数据库
    - 实际上mongodb没有这个概念
    - 直接use即可，没有则创建
```shell script
use test_db
```
- 查看集合
```shell script
show collections
```
- 新建一个集合
```shell script
db.createCollection('test')
```
- 退出客户端
```shell script
exit
```
- 重新登录
```shell script
./mongosh
```
- 进行认证
    - 认证是使用admin这个数据库进行认证的
    - 所以需要先使用这个库
```shell script
use admin
```
```shell script
db.auth("root","root")
```

## 数据库的dump和restore
- mongodb6之后，这部分也是独立的包
- 安装路径也是无所谓
- 下载
```shell script
wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-rhel70-x86_64-100.7.3.tgz
```
- 解包
```shell script
tar -xzvf mongodb-database-tools-rhel70-x86_64-100.7.3.tgz
```
- 重命名
```shell script
mv mongodb-database-tools-rhel70-x86_64-100.7.3 mongo-tools
```
- 进入路径
```shell script
cd mongo-tools/
cd bin
```
- 备份数据库
    - 注意，output-directory会输出一个这样的路径：[output-directory]/[dump-database]
```shell script
./mongodump -h [host]:[port] -u [user] -p [password] --authenticationDatabase=[auth-database] -d [dump-database] -o [output-directory]
```
```shell script
./mongodump -h 127.0.0.1:27017 -u root -p root --authenticationDatabase=admin -d test_db -o dump_test_db
```
- 恢复数据库
    - 注意，restore-directory 下面就是包含了meta.json和bson的父目录
    - 如果对应dump时的路径，那就应该是[output-directory]/[dump-database]
```shell script
./mongorestore -h [host]:[port] -u [user] -p [password] --authenticationDatabase=[auth-database] -d [restore-database] [restore-directory]
```
```shell script
./mongorestore -h 127.0.0.1:27017 -u root -p root --authenticationDatabase=admin -d [restore-database] ./dump_test_db
```
