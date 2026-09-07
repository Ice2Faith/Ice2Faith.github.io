# hadoop3 环境安装

## 简介
- hadoop3 版本虽然向下兼容
- 但是其他的依赖于hadoop3的组件，有的存在版本依赖

## 依赖环境
- java

## 安装
- 下载
```shell script
wget -c https://mirrors.tuna.tsinghua.edu.cn/apache/hadoop/common/hadoop-3.2.3/hadoop-3.2.3.tar.gz
```
- 解包
```shell script
tar -zxvf hadoop-3.2.3.tar.gz
```
- 进入
```shell script
cd hadoop-3.2.3
```
- 添加执行权限
```shell script
chmod a+x ./bin/hadoop
```
- 检查版本
```shell script
./bin/hadoop version
```
- 复制路径
```shell script
pwd
```
- 添加环境变量
```shell script
vi /etc/profile
```
```shell script
export HADOOP_HOME=
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
```
- 刷新环境变量
```shell script
source /etc/profile
```
- 检查环境
```shell script
hadoop version
```

## 单机部署
- 进入hadoop路径
```shell script
cd hadoop-3.2.3
```
- 编辑hadoop配置
```shell script
vi ./etc/hadoop/core-site.xml
```
```xml
<property>
    <name>fs.defaultFS</name>
    <value>hdfs://[HOST]:9000</value>
</property>
```
- 创建hadoop目录
```shell script
# 创建数据目录
mkdir -p /home/hadoop3/data/buf
# 创建临时目录
mkdir -p /home/hadoop3/data/tmp
# 创建name-node数据目录
mkdir -p /home/hadoop3/nm/localdir
```
- 为目录添加权限
```shell script
chmod -R a+rwx /home/hadoop3/data
chmod -R a+rwd /home/hadoop3/nm
```
- 编辑hdfs配置
```shell script
vi ./etc/hadoop/hdfs-site.xml
```
```xml
<!--指定hdfs中namenode的存储位置-->
<property>
 <name>dfs.namenode.name.dir</name> 
 <value>/home/hadoop3/nm/localdir</value>
</property>
<!--指定hdfs中datanode的存储位置-->
<property>
 <name>dfs.datanode.data.dir</name>
 <value>/home/hadoop3/data/buf</value>
</property>
```
- 格式化nm
```shell script
hadoop namenode -format
```
- 编辑hdfs启动脚本和停止脚本
```shell script
vi ./sbin/start-dfs.sh
vi ./sbin/stop-dfs.sh
```
```shell script
HDFS_DATANODE_USER=root
HADOOP_SECURE_DN_USER=hdfs
HDFS_NAMENODE_USER=root
HDFS_SECONDARYNAMENODE_USER=root
```
- 编辑yarn启动脚本和停止脚本
```shell script
vi ./sbin/start-yarn.sh
vi ./sbin/stop-yarn.sh
```
```shell script
YARN_RESOURCEMANAGER_USER=root
HADOOP_SECURE_DN_USER=yarn
YARN_NODEMANAGER_USER=root
```
- 创建hadoop用户
```shell script
useradd hdfs
```
- 设置hadoop用户的密码
```shell script
passwd hdfs
```
- 生成rsa密钥对
```shell script
ssh-keygen -t rsa
```
- 配置自身的可信
```shell script
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

ssh-copy-id -i ~/.ssh/id_rsa.pub hdfs@localhost
```
- 需要输入刚才的hadoop用户的密码
- 启动hdfs
```shell script
./sbin/start-dfs.sh
```
- 查看进程
```shell script
jps
```
- 看到以下三个进程，表示启动成功
```shell script
DataNode
NameNode
SecondaryNameNode
```



## 配置集群
- 环境准备
    - 准备三台主机
    - 分别为01,02,03
    - 其中01作为管理节点，也就是namenode，resourcemanager
    - 03作为备用namenode
- 添加host映射
```shell script
vi /etc/hosts
```
```shell script
192.168.1.100 hadoop-01
192.168.1.101 hadoop-02
192.168.1.102 hadoop-03
```
- 创建hadoop目录
```shell script
# 创建数据目录
mkdir -p /home/hadoop3/data/buf
# 创建临时目录
mkdir -p /home/hadoop3/data/tmp
# 创建name-node数据目录
mkdir -p /home/hadoop3/nm/localdir
```
- 进入hadoop路径
```shell script
cd hadoop-3.2.3
```
- 编辑hadoop配置
```shell script
vi ./etc/hadoop/core-site.xml
```
- 新增或修改以下配置
```xml
<property>
    <name>fs.defaultFS</name>
    <value>hdfs://hadoop-01:9000</value>
</property>
<property>
    <name>hadoop.tmp.dir</name>
    <value>/home/hadoop3/data/tmp</value>
</property>

<property>
    <name>fs.obs.buffer.dir</name>
    <value>/home/hadoop3/data/buf</value>
</property>
```
- 编辑env配置
```shell script
vi ./etc/hadoop/hadoop-env.sh
```
- 新增或修改以下配置
```shell script
export JAVA_HOME=
```
- 编辑hdfs配置
```shell script
vi ./etc/hadoop/hdfs-site.xml
```
- 新增或修改以下配置
```shell script
<property>
    <name>dfs.replication</name>
    <value>3</value>
</property>

<property>
    <name>dfs.namenode.secondary.http-address</name>
    <value>hadoop-03:5090</value>
</property>
```
- 编辑yarn配置
```shell script
vi ./etc/hadoop/yarn-site.xml
```
- 新增或修改以下配置
```shell script
<property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shffle</value>
</property>

<property>
    <name>dyarn.resourcemanager.hostname</name>
    <value>hadoop-01</value>
</property>
```
- 编辑yarn-env配置
```shell script
vi ./etc/hadoop/yarn-env.sh
```
- 新增或修改以下配置
```shell script
export JAVA_HOME=
```
- 编辑MapReduce配置
```shell script
vi ./etc/hadoop/mapred-site.xml
```
- 新增或修改以下配置
```shell script
<property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
</property>
```
- 编辑MapReduce-env配置
```shell script
vi ./etc/hadoop/mapred-env.sh
```
- 新增或修改以下配置
```shell script
export JAVA_HOME=
```
- 编辑slaves配置
```shell script
vi ./etc/hadoop/slaves
```
- 新增或修改以下配置
```shell script
hadoop-01
hadoop-02
hadoop-03
```
- 将本机的hadoop整个复制到其他两台主机
- 也就是说，三台的配置都一样

## 启动
- 启动namenode
- 在hadoop-01上执行
```shell script
hdfs namenode -format
```
- 启动hdfs
```shell script
start-dfs.sh
```
```shell script
jps
```
- 创建目录
```shell script
hdfs dfs -makedir /bigdata
```
```shell script
hdfs dfs -ls /
```
- 启动yarn
```shell script
start-yarn.sh
```
```shell script
jps
```
- 分别在02,03及其上查看进程
```shell script
jps
```



## 调优
- CPU使用情况
    - 命令：nmon,dstat,top
    - CPU利用率低于30%
        - 增加并发数
    - CPU利用率过高75%
        - NUMA 绑核，优化热点函数
- 内存使用情况
    - 命令：nmon,top
    - 内存使用过高，但CPU空闲
        - 减少每个任务的内存占用
- 磁盘使用情况
    - 命令：iostat,nmon
    - IO占用过高大于70%，IO-wait高
        - 使用RAID0,开启Cache
        - 修改块设备配置
- 网络使用情况
    - 命令：nmon,sar
    - 网络IO占用率高
        - NUMA绑核
        - 聚合中断
        
## HBase调优
- 简介
    - 基于HDFS的列存储数据库管理系统
- 任务下发
    - Client下发任务给HMaster
    - HMaster分发任务给HRegionServer
    - HRegionServer执行类SQL任务
- 节点简介
    -HMaster
        - 协调RegionServer
        - 监控，平衡负载，分配任务给RegionServer
    - HRegionServer
        - 实际处理任务的节点
        - 执行SQL的读写操作
    - HRegion
        - 实际存储的表逻辑层
    - Store
        - 存储数据的物理层
    - HLog
        - 存储执行日志和数据操作日志
        - 类似binlog,用于可靠性保证
- 写入流程
    - Client发送PUT请求到RegionServer
    - 依据RowKey将数据写入不同的Region的缓存MemStore
    - Region构造WAL写入HLog
    - WAL落盘之后，请求完成，结果返回Client
    - MemStore达到存盘条件，数据落盘HFile
    - 若异常宕机，可以从HLog恢复
    - 写入实际上是Bulkload批量方式
- 计算流程
    - 从HDFS加载数据源
    - 读取HDFS数据，运行MapReduce
    - Map阶段，将HBASE的RowKey的KeyValue传入map,排序到Reduce
    - Reduce阶段，汇总到Reduce，为每一个Region生成HFile
    - 通过completeBulkload加载到HBase
- 调优背景
    - 以Bulkload切入
    - 提升磁盘IO速度
- 调优
    - 吞吐量小
    - CPU、内存过低
        - 修改客户端配置
        - 提高cpu-vcores配置
        - 将除了保留内存外全部分配给yarn
    - reduce 任务数低，占用时间长
        - 多建立几个region进行分区
        - 实现增大并发度
    - 内存用完，但是CPU利用率不高
        - 同时运行的任务数少
        - 说明单个任务的内存占用过高
        - 降低任务的内存memory.mb
    - 磁盘和IO的占用高，IO-wait高
        - 修改output.compress和compress.codec
        - 开启Map输出阶段压缩
        - 减低IO压力
    
        
    
    
       
