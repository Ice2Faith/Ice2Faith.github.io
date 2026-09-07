# flink-1.13.5 环境安装

## 简介
- flink 是一个提供了实时流计算能力的引擎
- 对于大数据量，时间语义，窗口语义的处理非常有力
- 基于集群的分布式计算能力，让实时处理能力提升数倍
- 处理速度由于 spark hadoop


## 依赖环境
- java
- scala

## 安装
- 下载
```shell script
wget -c https://archive.apache.org/dist/flink/flink-1.13.5/flink-1.13.5-bin-scala_2.12.tgz
```
- 解包
```shell script
tar -xzvf flink-1.13.5-bin-scala_2.12.tgz
```
- 进入目录
```shell script
cd flink-1.13.5
```
- 启动flink
- 这里实际上是local模式启动的
- 任务和资源都是flink自己进行管理的
```shell script
./bin/start-cluster.sh
```
- 浏览器访问
```shell script
http://[IP]:8081
```
- 查看进程
    - 看到Entrypoint和TaskManager即可
```shell script
jps
```
- 停止flink
```shell script
./bin/stop-cluster.sh
```

## 配置项
- flink配置
```shell script
ll conf
```
```shell script
flink-conf.yaml flink的配置文件
workers 工作主机列表
masters 管理主机列表
```
- 配置flink可用资源
```shell script
vi ./conf/flink-conf.yaml
```
- 注意下面项即可
```shell script
# 管理机器信息
# 如果是集群模式，需要指向主节点
jobmanager.rpc.address: localhost
jobmanager.rpc.port: 6123

# 两种身份下的内存使用控制
jobmanager.memory.process.size: 1600m
taskmanager.memory.process.size: 1728m

# 可用的资源数量，一般设置为核心数
taskmanager.numberOfTaskSlots: 4

# 默认作业的并行度
parallelism.default: 1

# web 监控页面的端口
#rest.port: 8081

# 开启允许web页面方式提交作业
web.submit.enable: true
```



## 运行模式
### local 模式
- 本地模式，只有一个flink进程
- 是一个单体flink模型
- 实际上flink自身模拟了一个集群环境
- 本身既是jobmanager,也是taskmanager
- 此模式，一般适用于开发阶段
- 进入flink
```shell script
cd flink-1.13.5
```
- 启动flink
```shell script
./bin/start-cluster.sh
```
- 停止flink
```shell script
./bin/stop-cluster.sh
```
- 提交任务
```shell script
./bin/flink run app.jar
```


### standalone 模式
- 独立运行模式
- 由flink自身管理集群和资源
- 由flink的多个节点自身组成集群
- 此模式一般用于不想引入hadoop等组件的情况
- 这种配置下，拥有一个主节点，和其他多个作业节点
- 假设如下配置环境
```shell script
192.168.1.100 作为master JobManager

192.168.1.101,192.168.1.102,192.168.1.103 作为从节点 TaskManager
```
- 进入flink
```shell script
cd flink-1.13.5
```
- 编辑flink配置
```shell script
vi ./conf/flink-conf.yaml
```
- 新增或修改如下配置
```yaml
jobmanager.rpc.address: 192.168.1.100
```
- 编辑master列表
```shell script
vi ./conf/masters
```
- 修改为主节点
```shell script
192.168.1.100:8081
```
- 编辑worker列表
```shell script
vi ./conf/workers
```
- 添加所有的工作节点
```shell script
192.168.1.101
192.168.1.102
192.168.1.103
```
- 将本机修改好的配置，分发到其他三台主机
- 也就是说，他们的masters/workers配置都是一致的
- 除了flink-conf.yaml中对于资源数量的定义等可能有差异
- 启动flink
```shell script
./bin/start-cluster.sh
```
- 停止flink
```shell script
./bin/stop-cluster.sh
```
- 提交任务
```shell script
./bin/flink run app.jar
```


### standalone-HA 模式
- 是standalone的高可用模式
- 原因是standalone模式中，只有一个主节点，
- 当主节点挂了之后，整个集群就挂了
- 高可用模式就是设置多个主节点
- 其中一个为实际主节点，其他为热备主节点
- 当实际主节点挂了之后。热备主节点将会尝试成为新的实际主节点
- 实现高可用
- 其依赖于zookeeper进行领导选举
- 也就是需要zk环境
- 假设如下配置环境
```shell script
192.168.1.99,192.168.1.100 作为master JobManager

192.168.1.101,192.168.1.102,192.168.1.103 作为从节点 TaskManager
```
- 进入flink
```shell script
cd flink-1.13.5
```
- 编辑flink配置
```shell script
vi ./conf/flink-conf.yaml
```
- 新增或修改如下配置
```yaml
jobmanager.rpc.address: 192.168.1.100

# 使用zk作为高可用管理
high-availability: zookeeper

# 高可用存储
high-availability.storageDir: hdfs:///flink/ha/

# 高可用的zk集群配置
high-availability.zookeeper.quorum: localhost:2181

# 启用状态后端
state.backend: filesystem

# 设置检查点保存
state.checkpoints.dir: hdfs://namenode-host:port/flink-checkpoints

# 设置保存点
state.savepoints.dir: hdfs://namenode-host:port/flink-savepoints


```
- 编辑master列表
```shell script
vi ./conf/masters
```
- 修改为主节点
```shell script
192.168.1.100:8081
192.168.1.99:8081
```
- 编辑worker列表
```shell script
vi ./conf/workers
```
- 添加所有的工作节点
```shell script
192.168.1.101
192.168.1.102
192.168.1.103
```
- 将本机修改好的配置，分发到其他四台主机
- 也就是说，他们的masters/workers配置都是一致的
- 除了flink-conf.yaml中对于资源数量的定义等可能有差异
- 不同点在于99和100都是主节点
- 因此他们二者的配置flink-conf.yaml中的jobmanager都是指向他们自己
```shell script
# 100 机器
jobmanager.rpc.address: 192.168.1.100

# 99 机器
jobmanager.rpc.address: 192.168.1.99
```
- 启动flink
```shell script
./bin/start-cluster.sh
```
- 停止flink
```shell script
./bin/stop-cluster.sh
```
- 提交任务
```shell script
./bin/flink run app.jar
```

### yarn 模式
- 资源的管理由yarn负责管理
- yarn作为Hadoop成员的一部分
- 此模式需要yarn集群的支持
- 也就是需要一个Hadoop集群环境支持
- 这也是官方推荐的模式
- 配置yarn
```shell script
vi hadoop/yarn-site.xml
```
- 关闭yarn内存检查
```xml
<property>
    <name>yarn.nodemanager.pmem-check-enabled</name>
    <value>false</value>
</property>
<property>
    <name>yarn.nodemanager.vmem-check-enabled</name>
    <value>false</value>
</property>
```
- 将修改后的配置应用到其他yarn集群机器
#### yarn session 模式提交
- 此模式，使用session预先向yarn申请资源
- session期间资源固定
- 启用session
```shell script
./bin/yarn-session.sh -n 2 -tm 800 -s 1 -d

参数解释
- -n 表示申请两个容器
- -tm 每个TaskManager的内存大小
- -s 每个TaskManager的slot数量
- -d 后台运行
```
- 关闭yarn-session
- 通过yarn管理页面的application_id杀死进程即可
```shell script
yarn application -kill [application_id]
```
- 提交任务
- 一般方式提交即可
```shell script
./bin/flink run app.jar
```

#### yarn per-job 分离模式
- 分离模式，每次提交任务都单独申请资源
- 任务之间隔离，相互独立
- 提交任务
```shell script
./bin/flink run -m yarn-cluster -yjm 1024 -ytm 1024 app.jar

参数解释
- -m jobManager的地址
- -yjm 指定jobmanager的内存大小
- -ytm 指定TaskManager的内存大小
```

