# mysql8 环境安装

## 简介
- mysql是中小型项目中常用的数据库
- 目前mysql8已经成为主流版本

## 依赖环境
- 无

## 安装
- 下载yum
```shell script
curl https://repo.mysql.com//mysql80-community-release-el7-3.noarch.rpm > centos7.mysql.rpm

-- centos8
curl https://repo.mysql.com/mysql80-community-release-el8-2.noarch.rpm  > centos8.mysql.rpm
```
- 安装rpm
```shell script
yum install centos7.mysql.rpm -y

-- centos8
yum install centos8.mysql.rpm -y
```
- 禁用已有mysql
```shell script
yum module disable mysql

确认禁用,输入
y
```
- 升级GPTkey
```shell script
rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
```
- 安装mysql
```shell script
yum install mysql-community-server -y
```
- 启动mysql
```shell script
systemctl start mysqld
```
- 设置开机启动
```shell script
systemctl enable mysqld
```
- 查看初始密码
```shell script
grep "password" /var/log/mysqld.log
```
- 使用初始密码登录
```shell script
mysql -uroot -p
```
- 修改默认密码
    - 下面密码设置为： xxx123456
```shell script
set global validate_password.policy=0;  #修改密码安全策略为低（只校验密码长度，至少8位）。
set global validate_password.length=1;

-- 如果上面这两句报错，换成下面这两句
set global validate_password_policy=0;  #修改密码安全策略为低（只校验密码长度，至少8位）。
set global validate_password_length=1;

ALTER USER 'root'@'localhost' IDENTIFIED BY 'xxx123456';
```
- 授予远程权限
```shell script
create user root@'%' identified by 'xxx123456';
grant all privileges on *.* to root@'%' with grant option;
```
- 更改加密方式，防止navicat 出现 2059 错误
```shell script
# 使用系统库
use mysql;
# 更改加密方式
ALTER USER 'root'@'%' IDENTIFIED BY 'xxx123456' PASSWORD EXPIRE NEVER;
# 更改用户密码
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'xxx123456';
# 刷新权限
flush privileges;
```
- 退出mysql命令行
```shell script
exit
```
- 更改配置，防止远程连接出现 2013 错误
```shell script
vim /etc/my.cnf
```
- 修改[mysqld]节点下的内容
```shell script
[mysqld]
# 远程数据库连接错误2013-Lost Connection...
skip-name-resolve
# bind-address = 127.0.0.1
```
- 保存并退出
- 重启mysql
```shell script
systemctl stop mysqld
systemctl start mysqld
```
- 验证
```shell script
sudo netstat -tap | grep mysql
```


## 卸载
- 关闭服务
```shell script
systemctl stop mysqld
```
- 移除rpm
```shell script
rpm -qa|grep -i mysql
rpm -ev -mysql-community-libs-8.0.23-1.el7.x86_64 --nodeps
rpm -ev mysql80-community-release-el7-3.noarch --nodeps
rpm -ev mysql-community-common-8.0.23-1.el7.x86_64 --nodeps
rpm -ev mysql-community-client-8.0.23-1.el7.x86_64 --nodeps
rpm -ev mysql-community-client-plugins-8.0.23-1.el7.x86_64 --nodeps
rpm -ev mysql-community-server-8.0.23-1.el7.x86_64 --nodeps
```
- 删除文件
```shell script
rm -rf /var/lib/selinux/targeted/active/modules/100/mysql
rm -rf /var/lib/selinux/targeted/tmp/modules/100/mysql
rm -rf /var/lib/mysql
rm -rf /var/lib/mysql/mysql
rm -rf /usr/lib64/mysql
rm -rf /usr/share/bash-completion/completions/mysql
rm -rf /usr/share/selinux/targeted/default/active/modules/100/mysql
rm -rf /etc/my.cnf*
```
- 检查残留
```shell script
rpm -qa|grep -i mysql
```


## 下载包手动安装方式
- 下载
```shell script
echo https://dev.mysql.com/downloads/
wget xxx
```
- 我的pwd是这样的
```shell script
/home/env/mysql8
```
- 得到包
```shell script
mysql-8.0.32-linux-glibc2.12-x86_64.tar.xz
```
- 解包
```shell script
xz -d mysql-8.0.32-linux-glibc2.12-x86_64.tar.xz
tar -xvf mysql-8.0.32-linux-glibc2.12-x86_64.tar
```
- 重命名
```shell script
mv mysql-8.0.32-linux-glibc2.12-x86_64 mysql-8.0.32
```
- 创建用户组
```shell script
groupadd mysql
useradd -g mysql mysql
```
- 创建数据存储目录
```shell script
mkdir -p /opt/env/mysql8/conf
mkdir -p /opt/env/mysql8/data
mkdir -p /opt/env/mysql8/logs
mkdir -p /opt/env/mysql8/log
mkdir -p /opt/env/mysql8/temp
```
- 更改目录所有者
```shell script
chown -R mysql:mysql mysql-8.0.32
chown -R mysql:mysql /opt/env/mysql8
chmod -R a+rwx mysql-8.0.32
chmod -R a+rwx /opt/env/mysql8
```
- 编辑配置文件
```shell script
vi /opt/env/mysql8/conf/my.cnf
```
```shell script
[mysqld]
bind-address=0.0.0.0
port=3306
user=mysql
basedir=/home/env/mysql8/mysql-8.0.32
datadir=/opt/env/mysql8/data
tmpdir=/opt/env/mysql8/temp
socket=/tmp/mysql.sock
log-error=/opt/env/mysql8/logs/mysql.err
pid-file=/opt/env/mysql8/mysql.pid
#character config
character_set_server=utf8mb4
collation-server=utf8mb4_general_ci
symbolic-links=0
explicit_defaults_for_timestamp=true

# 开启 Binlog 并写明存放日志的位置
#log_bin = /opt/env/mysql8/log/binlog

# 指定索引文件的位置
#log_bin_index = /opt/env/mysql8/log/mysql-bin.index

#删除超出这个变量保留期之前的全部日志被删除
expire_logs_days = 14

# 指定一个集群内的 MySQL 服务器 ID，如果做数据库集群那么必须全局唯一，一般来说不推荐 指定 server_id >等于 1。
server_id = 1

max_connections=2000
connect_timeout=20000
max_connect_errors=500

# 指定执行器数量
innodb_buffer_pool_instances=4
```
- 初始化
    - 注意，这一步最后会输出随机的密码
    - 后面要使用，记得保存
```shell script
./bin/mysqld --defaults-file=/opt/env/mysql8/conf/my.cnf --user=mysql --initialize
```
- 获取初始化密码
    - 最后一行就是
```shell script
tail -300f /opt/env/mysql8/logs/mysql.err
```
- 编写启动脚本
```shell script
vi start.sh
```
```shell script
#!/bin/sh -e

cd /home/env/mysql8/mysql-8.0.32
nohup ./bin/mysqld --defaults-file=/opt/env/mysql8/conf/my.cnf --user=mysql 2>&1 > mysql.log & echo $! > mysql.pid
```
- 启动mysql
```shell script
./start.sh
```
- 登录客户端
```shell script
./bin/mysql -u root -p
```
- 修改默认密码
    - 这些和默认安装的一致
    - 不再赘述
- 添加服务到系统
```shell script
vi /etc/systemd/system/mysqld.service
```
```shell script
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
After=network.target
After=syslog.target

[Service]
Type=forking
ExecStart=/home/env/mysql8/mysql-8.0.32/start.sh
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
```
- 使能服务
```shell script
systemctl enable mysqld
```
- 之后的初始化过程和rpm自动安装的过程一致
- 不再赘述


## 通过docker安装mysql
- 拉取镜像
```shell script
docker pull mysql:8.0.30
```
- 查看镜像
```shell script
docker images
```
- 编写启动脚本
```shell script
docker-mysql.sh
```
```shell script
docker run -d \
  --name mysql-8.0.30 \
  --restart=always \
  --privileged=true \
  -p 3306:3306 \
  -v /opt/env/mysql/conf/my.cnf:/etc/mysql/my.cnf \
  -v /opt/env/mysql/logs:/logs \
  -v /opt/env/mysql/data:/var/lib/mysql \
  -e MYSQL_ROOT_PASSWORD=123456 \
  mysql:8.0.30
```
- 添加对应的目录
```shell script
mkdir -p /opt/env/mysql/conf
mkdir -p /opt/env/mysql/logs
mkdir -p /opt/env/mysql/data
chmod -R a+rwx /opt/env/mysql
```
- 添加配置文件
```shell script
vi /opt/env/mysql/conf/my.cnf
```
```shell script
[client]
default-character-set = utf8mb4

[mysqld]
pid-file        = /var/run/mysqld/mysqld.pid
socket          = /var/run/mysqld/mysqld.sock
datadir         = /var/lib/mysql
secure-file-priv= NULL

# Custom config should go here
# 字符集
character_set_server=utf8mb4
collation-server=utf8mb4_unicode_ci
# 创建新表时将使用的默认存储引擎
default-storage-engine=INNODB

symbolic-links=0
explicit_defaults_for_timestamp=true
skip-name-resolve

# 是否对sql语句大小写敏感，0:大小写敏感,1:忽略大小写区别。，只能在初始化服务器时配置。禁止在服务器初始化后更改
# 设置为2时，表名和数据库名按声明存储，但以小写形式进行比较
lower_case_table_names = 1

# 最大连接数，连接配置
max_connections=8192
connect_timeout=30
max_connect_errors=300

# 指定执行器数量
innodb_buffer_pool_instances=4

# 指定最大请求包大小
max_allowed_packet = 32M

# 指定binlog的缓存大小
binlog_cache_size = 64M

# 指定排序使用的线程缓存大小
sort_buffer_size = 64M

# 指定进行连接操作的缓存大小
join_buffer_size = 64M

# 缓存的线程池大小
thread_cache_size = 128

# 指定rnd读取缓存大小
read_rnd_buffer_size = 64M

# 指定innodb缓存池大小
innodb_buffer_pool_size = 16G

# 指定innodb的并发线程数
innodb_thread_concurrency = 128

# 指定innodb的日志缓存大小
innodb_log_buffer_size = 64M


!includedir /etc/mysql/conf.d/
```
- 启动docker镜像
```shell script
./docker-mysql.sh
```
- 查看进程
```shell script
docker -ps
```

# 主从配置
- 主从，实际上就是一台主库+N个从库的配置
- 同时从库也可以作为其他从库的主库，实现链式复制
- 工作原理
    - 主库开启binlog日志
    - 从库指向主库，使用iothread从主库拉取binlog保存到本地的relaylog
    - 从库使用SQLthread从relaylog执行日志，从而实现同步
- 现在101作为主库，102作为从库
## 主库配置
- 修改配置文件
    - 在[mysqld]节点下添加
```shell script
vi /etc/my.cnf
```
```shell script
# 服务ID，在整个集群环境唯一即可，一般使用服务器IP即可
server-id=101
# 是否只读，1 只读，0 读写
read-only=0
# 启用binlog
log_bin=/var/log/mysql/mysql-bin
# 下面两项可以不配置，默认是所有库开启binlog
# 忽略哪些库的binlog
#binlog-ignore-db=mysql
# 指定那些库需要进行binlog
#binlog-do-db=test_db
```
- 重启mysql
```shell script
systemctl restart mysqld
```
- 登录客户端
```shell script
mysql -uroot -p
```
- 添加从库从主库读取binlog的用户
```sql
create user 'slave'@'%' identified with mysql_native_password by 'xxx123456';
```
- 为用户赋权
```sql
grant replication slave on *.* to 'slave'@'%';
```
- 刷新权限
```sql
flush  privileges;
```
- 查看此时的binlog日志信息
```shell script
show master status\G
```
- 关注两个信息，从库需要使用
    - file binlog 日志文件的文件名
    - position binlog 日志的当前位置
    - 假设值分别为：
        - file: binlog.00001
        - position: 500

## 从库配置
- 修改配置文件
    - 在[mysqld]节点下添加
```shell script
vi /etc/my.cnf
```
```shell script
# 服务ID，在整个集群环境唯一即可，一般使用服务器IP即可
server-id=102
# 是否只读，1 只读，0 读写
read-only=1
```
- 重启mysql
```shell script
systemctl restart mysqld
```
- 登录客户端
```shell script
mysql -uroot -p
```
- 将从库指向主库
```sql
-- >= 8.0.23
change replication source to source_host='192.168.1.101:3306',source_user='slave',source_password='xxx123456',source_log_file='binlog.00001',source_log_position=500;

-- < 8.0.23
change master to master_host='192.168.1.101:3306',master_user='slave',master_password='xxx123456',master_log_file='binlog.00001',master_log_position=500;
```
- 开启同步
```sql
-- >= 8.0.22
start replica;

-- < 8.0.22
start slave;
```
- 查看同步状态
```sql
-- >= 8.0.22
show replica status;

-- < 8.0.22
show slave status;
```
- 确认状态为YES即可

## 从库同步失败处理方法
- 查询从库状态
```sql
show replica status;
```
- 检查Replica_IO_Running和Replica_SQL_Running是否都是为YES
	- 如果出现如下的情况
	- 说明，数据从主库同步到了从库，IO正常
	- 但是，从库在执行的过程中出现了错误，SQL异常
```shell
Replica_IO_Running	Replica_SQL_Running
YES					NO
```
- 查看失败原因
	- 首先，查看这两个字段
	- 可以得到，出现了错误码1032
```shell
Last_Errno	Last_Error
1032		xxx
```
- 查看导致错误的原因
```sql
select * from performance_schema.replication_applier_status_by_worker;
```
- 通过结果查看，可以知道是什么操作在哪张表上出现了问题
- 这时候，原因就知道了
- 就可以介入处理了
- 这时候分几种情况
	- 整库数据量不大，可以直接整库dump，整个dump到恢复的过程很快，并且不会影响生产使用
	- 不能停止数据写入，或者dump时间长，恢复数据时间也长，会影响生产使用
- 针对这些情况，也就是两个处理思路
	- 数据非常重要，只能通知客户，需要停机运维
	- 数据丢失一部分不太重要，或者数据能够重新生成，丢失也没关系，可以忽略掉丢失的数据
- 所以，处理方式如下：
	- 跳过事务：错误比较少，直接跳过这个错误
	- 重建主从：丢失了大量数据，或者错误很多，数据也很重要，就只能重建主从
	- 忽略错误：错误较多，数据丢失一些没关系，不追求数据的强一致性
### 跳过事务
- 适用场景
	- 错误比较少，直接跳过这个错误
	- 实际上跳过的是一个事务，而不是一条语句
	- 也就是说，可能跳过的是多条语句组成的一个事务
- 方式
	- sql_slave_skip_counter=1
	- 这里的1就是要跳过的事务数量
	- 一般来说就是跳过失败的1个事务即可
	- 也可以跳过多个事务
	- 例如：sql_slave_skip_counter=1
	- 注意，这是跳过事务，而不是只跳过失败的事务
	- 所以，如果值大了，就会把正常的事务也跳过了
```sql
stop replica;

set global sql_slave_skip_counter=1;

start replica;
```
- 这时，重新检查从库状态
- 反复进行验证和跳过，直到从库恢复正常状态为止

### 重建主从
- 使用场景
	- 丢失了大量数据，或者错误很多，数据也很重要，就只能重建主从
	- 这个操作，实际上就是属于停机运维
	- 主要就是，停止所有写入操作，将主库进行dump，完整的恢复到从库
	- 然后重新建立主从关系
	- 由于dump和恢复的过程一般比较漫长
	- 所以，这种方式进行时，需要考虑各方因素
- 方式
- 【主库执行】停止主库的写入操作
	- 注意，后面需要释放写入锁，否则就是整库都被锁住
	- 是非常严重的，一定不要忘记
```sql
flush table with read lock;
```
- 【主库执行】获取主库的binglog状态
```sql
show master status;
```
- 【从库执行】从新建立主从关系
	- 注意，log_file和log_pos更改为刚主库查询的结果
```sql

stop replica;

reset replica;

change replication source to source_host='192.168.1.101',
source_user='slave',
source_password='xxx123456',
source_log_file='binlog.000012',
source_log_pos=6652;

start replica;

```
- 使用dump工具对主库整库进行dump
- 并且在从库进行恢复dump的整库
- 进行这个操作之后，主库和从库因为dump恢复
- 主库从库完全一致了
- 【重要】释放主库的写入
```sql
unlock tables;
```
- 这时候，由于dump与恢复，数据完全一致
- 并且重新建立主从关系
- 一般来说，从库是没有任何为题的

### 忽略错误
- 适用场景
	- 错误较多，数据丢失一些没关系，不追求数据的强一致性
	- 这种方式，需要更改从库配置文件，重启从库
	- 一般来说，这种操作不影响主库的正常使用
- 方式
- 停止从库的mysql进程
```shell
systemctl stop mysqld
```
- 添加忽略错误
```shell
vi /etc/my.cnf
```
- 注意配置在mysqld节点下
	- 其中的1032,1048等是要忽略的错误码
	- 可以根据上面查看到的错误码，决定是否是可以进行忽略的
	- 加入到配置中
```shell
[mysqld]
replica_skip_errors=1032,1048,1062
```
- 重启mysql
```shell
systemctl start mysqld
```
- 重新查看是否还有错误即可
- 此时，可以重新配置下主从，也就是【重建主从】
- 但是不用dump进行整库恢复了
- 这样，只要是1032,1048等配置的错误码的从库错误，都将会被忽略
- 从库即可正常工作


# keepalived+mysql主从实现HA
- 实现目标
    - 当主库宕机之后，自动切换为从库提供服务
    - 所以关键步骤如下
    - 两台都开启binlog
    - 当主库宕机后，设置从库为新的主库
## 两台都配置
- 修改配置文件
    - 在[mysqld]节点下添加
```shell script
vi /etc/my.cnf
```
```shell script
# 服务ID，在整个集群环境唯一即可，一般使用服务器IP即可
# 注意两台机器的id要不一样
server-id=101
# 启用binlog
log_bin=/var/log/mysql/mysql-bin
# 日志的做多保存日期
expire_logs_days = 10
# 下面两项可以不配置，默认是所有库开启binlog
# 忽略哪些库的binlog
#binlog-ignore-db=mysql
# 指定那些库需要进行binlog
#binlog-do-db=test_db
```
- 重启mysql
```shell script
systemctl restart mysqld
```
- 登录客户端
```shell script
mysql -uroot -p
```
- 添加从库从主库读取binlog的用户
```sql
create user 'slave'@'%' identified with mysql_native_password by 'xxx123456';
```
- 为用户赋权
```sql
grant replication slave on *.* to 'slave'@'%';
```
- 刷新权限
```sql
flush  privileges;
```
- 查看此时的binlog日志信息
```shell script
show master status\G
```
- 关注两个信息，从库需要使用
    - file binlog 日志文件的文件名
    - position binlog 日志的当前位置
    - 假设值分别为：
        - file: binlog.00001
        - position: 500
## 两台互相配置为从库
- 登录客户端
```shell script
mysql -uroot -p
```
- 将从库指向主库
    - 互相指向
```sql
-- >=8.0.32
change replication source to source_host='192.168.1.101:3306',source_user='slave',source_password='xxx123456',source_log_file='binlog.00001',source_log_pos=500;

-- >= 8.0.23
change replication source to source_host='192.168.1.101:3306',source_user='slave',source_password='xxx123456',source_log_file='binlog.00001',source_log_position=500;

-- < 8.0.23
change master to master_host='192.168.1.101:3306',master_user='slave',master_password='xxx123456',master_log_file='binlog.00001',master_log_position=500;
```
- 开启同步
```sql
-- >= 8.0.22
start replica;

-- < 8.0.22
start slave;
```
- 查看同步状态
```sql
-- >= 8.0.22
show replica status;

-- < 8.0.22
show slave status;
```
- 确认状态为YES即可

## 配置keepalived
- 配置mysql的命令行免密验证
```shell script
mysql_config_editor set --login-path=local --user=root --port=3306 --password
mysql_config_editor print --all
```
- 基础环境配置
```shell script
vi mysqlenv.sh
```
```shell script
MYSQL=/usr/bin/mysql
MYSQL_CMD="--login-path=local"
#远端主机的IP地址，不同主机指向对方
REMOTE_IP=192.168.1.101
export mysql="$MYSQL $MYSQL_CMD "
```
- 检查mysql状态脚本
```shell script
vi mycheck.sh
```
```shell script
#!/bin/sh

##################################################
#File Name  : mycheck.sh
#Description: mysql is working MYSQL_OK is 1
#             mysql is down MYSQL_OK is 0
##################################################

BASEPATH=/home/mysql
LOGSPATH=$BASEPATH/logs
source $BASEPATH/.mysqlenv。sh

CHECK_TIME=3
MYSQL_OK=1
##################################################################
function check_mysql_health (){
  $mysql -e "show status;" >/dev/null 2>&1
  if [ $? == 0 ] 
  then 
    MYSQL_OK=1
  else
    MYSQL_OK=0
    #systemctl status keepalived
 fi
 return $MYSQL_OK
}

#check_mysql_helth
while [ $CHECK_TIME -ne 0 ] #不等于
do
    let "CHECK_TIME -= 1"
    check_mysql_health
    if [ $MYSQL_OK = 1 ] ; then
        CHECK_TIME=0
        echo "$(date "+%Y-%m-%d %H:%M:%S") The scripts mycheck.sh is running ..." >> $LOGSPATH/mysql_switch.log
        exit 0
    fi
    if [ $MYSQL_OK -eq 0 ] && [ $CHECK_TIME -eq 0 ] #等于
    then
        systemctl stop keepalived
        echo "$(date "+%Y-%m-%d %H:%M:%S") The mycheck.sh, mysql is down, after switch..." >> $LOGSPATH/mysql_switch.log
        exit 1
    fi
    sleep 1　　
done
```
- 切换为主库
```shell script
vi mymaster.sh
```
```shell script
#!/bin/sh

##################################################
#File Name  : mymaster.sh
#Description: First determine whether synchronous
#             replication is performed, and if no
#             execution is completed, wait for 1
#             minutes. Log logs and POS after
#             switching, and record files synchronously.
##################################################

BASEPATH=/home/mysql
LOGSPATH=$BASEPATH/logs
source $BASEPATH/.mysqlenv.sh

$mysql -e "show slave status\G" > $LOGSPATH/mysqlslave.states
Master_Log_File=`cat $LOGSPATH/mysqlslave.states | grep -w Master_Log_File | awk -F": " '{print $2}'`
Relay_Master_Log_File=`cat $LOGSPATH/mysqlslave.states | grep -w Relay_Master_Log_File | awk -F": " '{print $2}'`
Read_Master_Log_Pos=`cat $LOGSPATH/mysqlslave.states | grep -w Read_Master_Log_Pos | awk -F": " '{print $2}'`
Exec_Master_Log_Pos=`cat $LOGSPATH/mysqlslave.states | grep -w Exec_Master_Log_Pos | awk -F": " '{print $2}'`
i=1

while true
do
    if [ $Master_Log_File = $Relay_Master_Log_File ] && [ $Read_Master_Log_Pos -eq $Exec_Master_Log_Pos ];then
        echo "$(date "+%Y-%m-%d %H:%M:%S") The mymaster.sh, slave sync ok... " >> $LOGSPATH/mysql_switch.log
        break
    else
        sleep 1
        if [ $i -gt 60 ];then
            break
        fi
        continue
        let i++
    fi
done

$mysql -e "stop slave;"
$mysql -e "set global innodb_support_xa=0;"
$mysql -e "set global sync_binlog=0;"
$mysql -e "set global innodb_flush_log_at_trx_commit=0;"
$mysql -e "flush logs;GRANT ALL PRIVILEGES ON *.* TO 'replication'@'%' IDENTIFIED BY 'replication';flush privileges;"
$mysql -e "show master status;" > $LOGSPATH/master_status_$(date "+%y%m%d-%H%M").txt

# sync pos file
/usr/bin/scp $LOGSPATH/master_status_$(date "+%y%m%d-%H%M").txt root@$REMOTE_IP:$BASEPATH/syncposfile/backup_master.status
echo "$(date "+%Y-%m-%d %H:%M:%S") The mymaster.sh, Sync pos file sucess." >> $LOGSPATH/mysql_switch.log
```
- 切换为从库
```shell script
vi mybackup.sh
```
```shell script
#!/bin/sh

##################################################
#File Name  : mybackup.sh
#Description: Empty the slave configuration, retrieve
#             the remote log file and Pos, and open
#             the synchronization
##################################################

BASEPATH=/home/mysql
LOGSPATH=$BASEPATH/logs
source $BASEPATH/.mysqlenv.sh

$mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'replication'@'%' IDENTIFIED BY 'replication';flush privileges;"
$mysql -e "set global innodb_support_xa=0;"
$mysql -e "set global sync_binlog=0;"
$mysql -e "set global innodb_flush_log_at_trx_commit=0;"
$mysql -e "flush logs;"
$mysql -e "reset slave all;"

if [ -f $BASEPATH/syncposfile/backup_master.status ];then
        New_ReM_File=`cat $BASEPATH/syncposfile/backup_master.status | grep -v File |awk '{print $1}'`
        New_ReM_Position=`cat $BASEPATH/syncposfile/backup_master.status | grep -v File |awk '{print $2}'`
        echo "$(date "+%Y-%m-%d %H:%M:%S") This mybackup.sh, New_ReM_File:$New_ReM_File,New_ReM_Position:$New_ReM_Position" >> $LOGSPATH/mysql_switch.log
        $mysql -e "change master to master_host='$REMOTE_IP',master_port=3306,master_user='replication',master_password='replication',master_log_file='$New_ReM_File',master_log_pos=$New_ReM_Position;"
        $mysql -e "start slave;"
        $mysql -e "show slave status\G;" > $LOGSPATH/slave_status_$(date "+%y%m%d-%H%M").txt
        cat $LOGSPATH/slave_status_$(date "+%y%m%d-%H%M").txt >> $LOGSPATH/mysql_switch.log
        rm -f $BASEPATH/syncposfile/backup_master.status
else
    echo "$(date "+%Y-%m-%d %H:%M:%S") The scripts mybackup.sh running error..." >> $LOGSPATH/mysql_switch.log
fi
```
- 停止脚本
```shell script
vi mystop.sh
```
```shell script
#!/bin/sh

##################################################
#File Name  : mystop.sh
#Description: Set parameters to ensure that the data
#             is not lost, and finally check to see
#             if there are still write operations,
#             the last 1 minutes to exit

##################################################

BASEPATH=/home/mysql
LOGSPATH=$BASEPATH/logs
source $BASEPATH/.mysqlenv.sh

$mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'replication'@'%' IDENTIFIED BY 'replication';flush privileges;"
$mysql -e "set global innodb_support_xa=1;"
$mysql -e "set global sync_binlog=1;"
$mysql -e "set global innodb_flush_log_at_trx_commit=1;"
$mysql -e "show master status\G" > $LOGSPATH/mysqlmaster0.states
M_File1=`cat $LOGSPATH/mysqlmaster0.states | awk -F': ' '/File/{print $2}'`
M_Position1=`cat $LOGSPATH/mysqlmaster0.states | awk -F': ' '/Position/{print $2}'`
sleep 2
$mysql -e "show master status\G" > $LOGSPATH/mysqlmaster1.states
M_File2=`cat $LOGSPATH/mysqlmaster1.states | awk -F': ' '/File/{print $2}'`
M_Position2=`cat $LOGSPATH/mysqlmaster1.states | awk -F': ' '/Position/{print $2}'`

i=1

while true
do
    if [ $M_File1 = $M_File2 ] && [ $M_Position1 -eq $M_Position2 ];then
        echo "$(date "+%Y-%m-%d %H:%M:%S") The mystop.sh, master sync ok.." >> $LOGSPATH/mysql_switch.log
        exit 0
    else
        sleep 1
        if [$i -gt 60 ];then
            break
        fi
        continue
        let i++
    fi
done
echo "$(date "+%Y-%m-%d %H:%M:%S") The mystop.sh, master sync exceed one minutes..." >> $LOGSPATH/mysql_switch.log
```
- 主库的keepalived
```shell script
vi /etc/keepalived/keepalived.conf
```
```shell script
global_defs {
   router_id MySQL-HA
} 

vrrp_script check_run {
    script "/home/mysql/mycheck.sh"
    interval 10
}

vrrp_sync_group VG1 {
    group {
      VI_1
    }
}

vrrp_instance VI_1 {
    state MASTER
    #state BACKUP
    interface eth0 
    virtual_router_id 100
    priority 100
    advert_int 1
    #nopreempt
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    track_script {
      check_run
    }
    notify_master /home/mysql/mymaster.sh
    notify_backup /home/mysql/mybackup.sh
    notify_stop /home/mysql/mystop.sh
    
    virtual_ipaddress {
        192.168.1.100/24
    }

}
```
- 从库keepalived配置
```shell script
vi /etc/keepalived/keepalived.conf
```
```shell script
global_defs {
   router_id MySQL-HA
} 

vrrp_script check_run {
    script "/home/mysql/mycheck.sh"
    interval 10
}

vrrp_sync_group VG1 {
    group {
      VI_1
    }
}

vrrp_instance VI_1 {
    #state MASTER
    state BACKUP
    interface eth0 
    virtual_router_id 100
    priority 90
    advert_int 1
    #nopreempt
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    track_script {
      check_run
    }
    notify_master /home/mysql/mymaster.sh
    notify_backup /home/mysql/mybackup.sh
    notify_stop /home/mysql/mystop.sh
    
    virtual_ipaddress {
        192.168.1.100/24
    }
}
```


## 常见问题
- 复制的mysql应用
- 复制的mysql,必须删除${datadir}/auto.cnf 重新生成
