# doris 实时分析MPP框架

## 简介
- doris 这里指 apache-doris
    - 而不是dorisdb(StarRocks)数据库
- doris 是一个MPP分布式集群实时分析框架
- 支持PB级数据的亚秒级查询
- 支持横向拓展
- 使用MySQL通信协议
- 兼容标准SQL语法和MySQL方言
- 不依赖其他大数据组件
- 自成一个体系
- 给出官网
```bash
https://doris.apache.org/zh-CN/
```
- 官网简介
    - 简单易用
        - 部署只需两个进程，不依赖其他系统；
        - 在线集群扩缩容，自动副本修复；
        - 兼容 MySQL 协议，并且使用标准 SQL
    - 高性能
        - 依托列式存储引擎
        - 现代的 MPP 架构
        - 向量化查询引擎
        - 预聚合物化视图
        - 数据索引的实现
        - 在低延迟和高吞吐查询上
        - 都达到了极速性能
    - 统一数仓
        - 单一系统
        - 可以同时支持
        - 实时数据服务
        - 交互数据分析
        - 离线数据处理
    - 联邦查询
        - 支持对 Hive、Iceberg
        - Hudi 等数据湖
        - MySQL
        - Elasticsearch 等数据库的
        - 联邦查询分析
    - 多种导入
        - 支持从 HDFS/S3 等批量拉取导入
        - 和 MySQL Binlog/Kafka 等流式拉取导入；
        - 支持通过HTTP接口进行微批量推送写入
        - 和 JDBC 中使用 Insert 实时推送写入
    - 生态丰富
        - Spark 利用 Spark Doris Connector 读取和写入 Doris；
        - Flink Doris Connector 配合 Flink CDC 实现数据 Exactly Once 写入 Doris；
        - 利用 DBT Doris Adapter，可以很容易的在 Doris 中完成数据转化

--------------------------------------------------------------------
## 架构
- 组成
    - fe(frontend) 前端
        - 负责接受用户输入，负责进行调度后端进行数据处理
        - 使用java编写，因此需要java环境
        - 其中，有 Follower 和 Observer
        - Follower 进行读写，其中会有一个是 Leader
        - Observer 进行只读，不参与 Leader 选举
        - 因此，当只有一个 Follower ，他就是 Leader，只能保证读写可用
        - 当 一个 Follower + 一个 Observer，保证读高可用
        - 当两个及以上 Follower 时，即可保证读写高可用
        - 一台主机只能有一个fe
    - be(backend) 后端
        - 负责处理fe的调度，负责处理和存储数据
        - 使用c++编写，因此需要gcc环境
        - 一台主机可以有多个be
    - blocker 数据导入
        - 负责提升外部数据的导入同步能力
        - 独立存在，不依赖fe或be
        - 一般一台主机部署一个即可
- 因为具有水平拓展的能力
- 所以，fe和be的数量，可以根据需求逐渐增加
- 一般小规模建议（保证读写高可用RWHA）
    - fe四个，三个Follower（其中一个为Master）+一个Observer
    - be三个
    - blocker三个

--------------------------------------------------------------------
## 部署
- 官网快速开始向导
```bash
https://doris.apache.org/zh-CN/docs/dev/get-starting/
```
- 在早期版本中，官网没有提供已编译的包
- 需要我们自己拉取官网的docker环境进行编译
- 但是在这里，官网已经有了编译包
- 直接下载部署即可
- 下载地址
```bash
https://doris.apache.org/zh-CN/download/
```
- 这里案例以1.2.3版本为例部署
- 下载地址
```bash
https://archive.apache.org/dist/doris/1.2/1.2.3-rc02/
```
- 下载文件列表
```bash
apache-doris-be-1.2.3-bin-x86_64.tar.xz
apache-doris-fe-1.2.3-bin-x86_64.tar.xz
apache-doris-dependencies-1.2.3-bin-x86_64.tar.xz
```
### 单机部署
- 创建目录
```shell script
mkdir doris-1.2.3
cd doris-1.2.3
```
- 下载编译包
```shell script
wget https://archive.apache.org/dist/doris/1.2/1.2.3-rc02/apache-doris-be-1.2.3-bin-x86_64.tar.xz
wget https://archive.apache.org/dist/doris/1.2/1.2.3-rc02/apache-doris-fe-1.2.3-bin-x86_64.tar.xz
wget https://archive.apache.org/dist/doris/1.2/1.2.3-rc02/apache-doris-dependencies-1.2.3-bin-x86_64.tar.xz
```
- 解压
```shell script
xz -d apache-doris-be-1.2.3-bin-x86_64.tar.xz
xz -d apache-doris-fe-1.2.3-bin-x86_64.tar.xz
xz -d apache-doris-dependencies-1.2.3-bin-x86_64.tar.xz
```
- 解包
```shell script
tar -xvf apache-doris-be-1.2.3-bin-x86_64.tar
tar -xvf apache-doris-fe-1.2.3-bin-x86_64.tar
tar -xvf apache-doris-dependencies-1.2.3-bin-x86_64.tar
```
- 重命名目录
```shell script
mv apache-doris-be-1.2.3-bin-x86_64 doris-be
mv apache-doris-fe-1.2.3-bin-x86_64 doris-fe
mv apache-doris-dependencies-1.2.3-bin-x86_64 doris-de
```
- 查看本机ip地址
```shell script
ifconfig
```
```bash
一般都是eth0的IPV4地址
例如: 192.168.1.5
复制这个地址，后面配置要用
```
#### 部署fe
- 配置fe
```shell script
cd doris-fe
vi conf/fe.conf
```
- 更新或添加配置项
```shell script
# 绑定网卡，一定要改，特别是多个网卡时
priority_networks = 192.168.1.5
# 元数据存放目录，测试时，也可以不改这个配置
# 建议是更改路径，同时这个目录需要手动创建好
meta_dir = ${DORIS_HOME}/doris-meta
```
- 其他关键配置简介
```shell script
# 网页的访问端口
# 这个访问页面的时候要记住
http_port = 8030
# RPC内部通信端口
rpc_port = 9020
# SQL客户端连接端口
# 这个使用MySQL客户端连接的时候要记住
query_port = 9030
# 审计日志端口
edit_log_port = 9010
```
- 前台启动
    - 方便看启动日志
```shell script
./bin/start_fe.sh
```
- 后台启动
    - 一般方式
```shell script
./bin/start_fe.sh --deamon
```
- 默认用户名密码
    - 用户名：root
    - 密码：无
- MySQL客户端访问
    - 也可以用其他的客户端进行连接
    - 指定端口为9030端口即可
    - 默认无密码，不用指定-p
```shell script
mysql -uroot -P9030 -h127.0.0.1
```
- 浏览器访问
    - 输入用户名，不输入密码登录即可
```bash
http://[IP]:8030
```
#### 部署be
- 配置be
```shell script
cd doris-be
vi conf/be.conf
```
- 更新或添加配置项
```shell script
# 绑定网卡，一定要改，特别是多个网卡时
priority_networks = 192.168.1.5
# 数据存放目录
# 格式：路径.介质类型,最大存储GB
# 其中，介质类型和最大存储可以不指定
# 多个路径使用;分隔
# 测试配置，也可以不配置此项
storage_root_path = /home/disk1/doris.HDD,50;/home/disk2/doris.SSD,1
```
- 其他关键配置简介
```shell script
# 后端端口
be_port = 9060
# web服务端口
webserver_port = 8040
# 心跳检测端口，后面将fe和be关联时，需要使用此端口，要记住
heartbeat_service_port = 9050
# 后端的RPC通信端口
brpc_port = 8060
```
- 变更服务器配置
```shell script
sysctl -w vm.max_map_count=2000000
```
- 将依赖包拷贝到be路径中
```shell script
cp ../doris-de/java-udf-jar-with-dependencies.jar ./lib/
```
- 前台启动
    - 方便看启动日志
```shell script
./bin/start_be.sh
```
- 后台启动
    - 一般方式
```shell script
./bin/start_be.sh --deamon
```
#### 将be添加到fe中
- 使用MySQL客户端连接
```shell script
mysql -uroot -P9030 -h127.0.0.1
```
- 查看后端
```sql
show backends\G
```
- 添加后端
```sql
alter system add backend "192.168.1.5:9050";
```
- 查看后端alive状态
    - alive为true即可
```sql
show backends\G
```
- 删除后端
    - 这步是如果配置错了后端
    - 可以使用此方式删除
```sql
alter system dropp backend "192.168.1.5:9050";
```
- 此时，在浏览器中，也能看到后端状态alive为true
```bash
http://[IP]:8030
```
#### 更改访问密码
- 默认情况下，是没有密码的
- 实际情况中，不允许这样的情况出现
- 因此，更改密码也是一个常用操作
- 使用MySQL客户端连接
```shell script
mysql -uroot -P9030 -h127.0.0.1
```
- 更改密码为123456
```sql
set password for 'root' = password("123456");
```
- 此时重新进入客户端
```shell script
exit
mysql -uroot -P9030 -h127.0.0.1 -p
```
- 浏览器访问的密码也变为123456
```bash
http://[IP]:8030
```
### 集群部署
- 环境简介
--------------------------------
| 主机 |  101 | 102 | 103 |
| --- | --- | --- | --- |
| fe | master | follower | follower |
| be | 1 | 1 | 1 | 
--------------------------------
- 因为要求follower的个数为奇数个
- 因此三台主机的情况下，只能三个follower
- 因为master实际上也是一个follower
- 首先在101上按照单机部署方式部署fe和be
- 同时将fe和be复制到102和103
- 启动101的fe和be，此时101第一个启动，自动成为master
- 更改102和103的fe和be的配置（也就是绑定网卡）
- 在102和103上启动fe
- 第一次启动
    - 使用--helper指定master
    - 也就是规划的101
```shell script
./bin/start_fe.sh --helper 192.168.1.101:9010 --daemon
```
- 非第一次启动
    - 就不用再指定helper了
```shell script
./bin/start_fe.sh --daemon
```
- 在101上使用MySQL客户端添加102和103到集群中
```sql
ALTER SYSTEM ADD FOLLOWER "192.168.1.102:9010";
ALTER SYSTEM ADD FOLLOWER "192.168.1.103:9010";
```
- 查看fe
```sql
show frontends\G
```
- 在102和103上启动be
- 在101上使用MySQL客户端添加102和103到集群中
```sql
ALTER SYSTEM ADD BACKEND "192.168.1.102:9050";
ALTER SYSTEM ADD BACKEND "192.168.1.103:9050";
```
- 查看fe
```sql
show backends\G
```

## 简单使用
- 使用客户端连接
```shell script
mysql -uroot -P9030 -h127.0.0.1 -p
```
- 创建数据库
```sql
create database test_db;
```
- 使用数据库
```sql
use test_db;
```
- 以后的步骤，可以在浏览器页面中执行对应的SQL进行操作
    - 在浏览器中，先选择数据库，再执行
- 创建表
```sql
CREATE TABLE IF NOT EXISTS example_tbl
(
    `user_id` LARGEINT NOT NULL COMMENT "用户id",
    `date` DATE NOT NULL COMMENT "数据灌入日期时间",
    `city` VARCHAR(20) COMMENT "用户所在城市",
    `age` SMALLINT COMMENT "用户年龄",
    `sex` TINYINT COMMENT "用户性别",
    `last_visit_date` DATETIME REPLACE DEFAULT "1970-01-01 00:00:00" COMMENT "用户最后一次访问时间",
    `cost` BIGINT SUM DEFAULT "0" COMMENT "用户总消费",
    `max_dwell_time` INT MAX DEFAULT "0" COMMENT "用户最大停留时间",
    `min_dwell_time` INT MIN DEFAULT "99999" COMMENT "用户最小停留时间"
)
AGGREGATE KEY(`user_id`, `date`, `city`, `age`, `sex`)
DISTRIBUTED BY HASH(`user_id`) BUCKETS 1
PROPERTIES (
"replication_allocation" = "tag.location.default: 1"
);
```
- 添加数据
```sql
insert into example_tbl values
(10000,"2017-10-01","北京",20,0,"2017-10-01 06:00:00",20,10,10),
(10000,"2017-10-01","北京",20,0,"2017-10-01 07:00:00",15,2,2),
(10001,"2017-10-01","北京",30,1,"2017-10-01 17:05:45",2,22,22),
(10002,"2017-10-02","上海",20,1,"2017-10-02 12:59:12",200,5,5),
(10003,"2017-10-02","广州",32,0,"2017-10-02 11:20:00",30,11,11),
(10004,"2017-10-01","深圳",35,0,"2017-10-01 10:00:15",100,3,3),
(10004,"2017-10-03","深圳",35,0,"2017-10-03 10:20:22",11,6,6);
```
- 常规SQL查询
```sql
SELECT city,count(*) cnt
FROM test_db.example_tbl
group by city
order by cnt desc
limit 3
```