# canal 增量数据监听中间件

- canal是用于监听MySQL的binlog的一个中间件客户端
- 角色就是一个模拟的MySQL从库客户端
- 因此，只支持进行MySQL数据库（或者兼容MySQL）的数据变更监听
- 一般用于增量数据同步，数据变动监听等场景
- 结合其他业务和中间件
- 可以实现将字典实时同步到Redis中进行缓存
- 也可以用于跨库数据同步

## MySQL主从概念

- 因为canal是作为一个从库客户端，因此就需要MySQL开启binlog
- 由于MySQL的binlog格式有以下三种
    - statement，语句级别，记录的是执行的SQL
        - 因为是SQL，所以，同样的SQL，在主库和从库上执行的结果可能不同，比如有使用一些例如now()等函数
        - 优点是，记录的数据量少，毕竟只记录SQL就行
        - 缺点是，不能保证主库从库的数据一致性
    - row，数据行级别，记录的是变更的数据行
        - 因为是数据行，所以，例如一条SQL语句导致大量数据发生变更时，就会导致大量数据更新，影响大量数据行
        - 优点是，能保证数据的一致性，因为记录的是变更的数据行
        - 缺点是，变动的数据行大，记录的binlog就大，数据量就大
    - mixed，混合级别，由MySQL决定执行一条SQL之后，应该采用statement保存执行的SQL，还是采用row保存变动的数据行
        - 因为是MySQL来决定，所以大多数情况下，采取了statement和row的优点，能够取得一个比较好的结果
        - 优点是，能够同时兼具尽量少的binlog大小
        - 缺点是，并不能保证数据的一致性，因为MySQL也有不能识别到的例外情况，导致一些数据不一致性

## canal工作原理

- 现在已知MySQL的binlog的格式有三种
- 因此，使用于canal的场景，就应该是row格式
- 因为只有row格式能够保证数据一致性
- 同时也能够监听到所有的数据变更
- canal作为从库客户端从MySQL中读取binlog记录到本地
- canal同时也作为服务端，向其他的canal客户端提供数据读取的能力

## canal客户端数据读取流程

- 为了减少网络IO的开销
- canal客户端每次允许读取最大一个batchSize的变更记录封装到Message对象中
- 每个Message对象中包含多个Entry对象，每个Entry对象就是一条SQL的执行的结果
- 包含了变更类型（update/delete/insert...）以及影响的数据行rowDatasList
- 因此，在客户端中需要做的就是根据自己的需求，根据变更类型来处理rowDatasList中的每一个rowData

## 开启MySQL的binlog

- 编辑MySQL配置文件
    - MySQL的配置文件，一般名为
        - my.cnf
        - my.ini
    - 在linux中默认安装的情况下
        - 在以下路径
        - /etc/my.cnf

```shell
vi /etc/my.cnf
```

- 编辑或者修改[mysqld]节点以下内容

```shell
# 集群ID，唯一即可，值可以自己定义，一般情况下可能使用IP作为标识
server-id=1
# binlog的日志文件名称，可以带路径，不带路径的话会放在默认数据路径下
log-bin=mysql-binlog
# binlog的日志格式，上面已经介绍过了
binlog_format=row
# binlog需要记录哪些数据库，不配置的话就是全部数据库，多个数据库的话，多行配置就行
#binlog-do-db=test_db
#binlog-do-db=biz_db
```

- 保存配置
- 重启MySQL

```shell
systemctl restart mysqld
```

- 验证是否成功开启binlog
- 登录MySQL客户端

```shell
mysql -u root -p
```

- 查看binlog变量

```sql
show
variables like '%log_bin%';
```

- 看到如下log_bin为ON即可

```shell
+---------------------------------+-----------------------------------+
| Variable_name                   | Value                             |
+---------------------------------+-----------------------------------+
| log_bin                         | ON                                |
| log_bin_basename                | /var/lib/mysql/mysql-binlog       |
| log_bin_index                   | /var/lib/mysql/mysql-binlog.index |
| log_bin_trust_function_creators | OFF                               |
| log_bin_use_v1_row_events       | OFF                               |
| sql_log_bin                     | ON                                |
+---------------------------------+-----------------------------------+
```

- 可以通过如下，查看其他相关配置

```sql
show
variables like '%binlog%';
```

- 看到如下binlog_format为ROW即可

```shell
+--------------------------------------------+----------------------+
| Variable_name                              | Value                |
+--------------------------------------------+----------------------+
| binlog_cache_size                          | 32768                |
| binlog_checksum                            | CRC32                |
| binlog_direct_non_transactional_updates    | OFF                  |
| binlog_error_action                        | ABORT_SERVER         |
| binlog_format                              | ROW                  |
| binlog_group_commit_sync_delay             | 0                    |
| binlog_group_commit_sync_no_delay_count    | 0                    |
| binlog_gtid_simple_recovery                | ON                   |
| binlog_max_flush_queue_time                | 0                    |
| binlog_order_commits                       | ON                   |
| binlog_row_image                           | FULL                 |
| binlog_rows_query_log_events               | OFF                  |
| binlog_stmt_cache_size                     | 32768                |
| binlog_transaction_dependency_history_size | 25000                |
| binlog_transaction_dependency_tracking     | COMMIT_ORDER         |
| innodb_api_enable_binlog                   | OFF                  |
| innodb_locks_unsafe_for_binlog             | OFF                  |
| log_statements_unsafe_for_binlog           | ON                   |
| max_binlog_cache_size                      | 18446744073709547520 |
| max_binlog_size                            | 1073741824           |
| max_binlog_stmt_cache_size                 | 18446744073709547520 |
| sync_binlog                                | 1                    |
+--------------------------------------------+----------------------+
```

- 这样，MySQL就已经开启了binlog
- 一般情况下，推荐使用专门的用户来读取binlog，而不是使用root
- 实在要使用root也可以，但是不推荐
- 创建从库的读取账号
- 添加从库从主库读取binlog的用户slave
- 使用管理库

```sql
use
mysql;
```

- 创建用户

```sql
create
user 'slave'@'%' identified with mysql_native_password by 'xxx123456';
```

- 为用户赋权

```sql
GRANT
SELECT, REPLICATION SLAVE, REPLICATION CLIENT
ON *.* TO 'slave'@'%';
```

- 刷新权限

```sql
flush
privileges;
```

- 退出mysql客户端

```sql
exit
```

## 安装

- 官网

```shell
https://github.com/alibaba/canal
```

- 下载

```shell
https://github.com/alibaba/canal/releases
```

- 下载安装包

```shell
wget https://github.com/alibaba/canal/releases/download/canal-1.1.8-alpha-3/canal.deployer-1.1.8-SNAPSHOT.tar.gz
```

- 创建存储目录

```shell
mkdir canal-1.1.8
```

- 解压

```shell
tar -xzvf canal.deployer-1.1.8-SNAPSHOT.tar.gz -C canal-1.1.8
```

- 进入

```shell
cd canal-1.1.8
```

- 编辑canal配置

```shell
vi conf/canal.properties
```

- 添加或修改以下内容

```properties
# canal服务端口
canal.port=11111
# canal服务格式，tcp,kafka,rocketMQ,rabbitMQ,pulsarMQ
# tcp就需要自己编写客户端自己来实现自己的逻辑
# 其他的例如kafaka等MQ配置的话，旧需要配置相应的MQ配置
# 这里先配置tcp自己实现一个客户端自己处理
canal.serverMode=tcp
# 用户密码配置，默认都为空
canal.user=canal
# 这里的密码是需要加密的
# 这个密码，其实和canal-admin的规则一致，也就是说，可以用相同的方式生成admin的密码
# mysql8以下版本，这样获取密码
# select replace(PASSWORD('xxx123456'),'*','')
# mysql8及以上，这样获取密码
# select upper(sha1(unhex(sha1('xxx123456'))))
# 这里是mysql8
canal.passwd=8B2C58BFDB0DA7C4F47AABC73AC1FDF692B6F140
# 开启读取哪些MySQL实例，多个用逗号隔开,example是默认的一个配置
# 也就是说，canal可以同时监听多个MySQL数据库
# 一个MySQL数据库实例，旧对应一个conf目录下的一个例如example的目录
# 在这个目录中配置instance实例的信息，来监听对应的MySQL数据库
# 假如，连接两个MySQL数据库，分别是192.168.1.100和192.168.1.101
# 就可以复制出来两个example文件夹，分别名为mysql-100,mysql-101
# 分别对应100和101及其的mysql
# 则这里的配置就是，canal.destinations=mysql-100,mysql-101
canal.destinations=example
```

- 编辑实例配置信息

```shell
vi conf/example/instance.properties
```

- 修改为mysql的连接信息

```properties
# 实例ID，前面说了，canal实际是作为一个从库的角色，也就是作为mysql集群的一个节点
# 前面主库我们配置了server-id=1，是需要整个集群唯一的，既然canal作为集群节点之一
# 也就需要和前面配置的server-id不重复，所以，这里设置为10
canal.instance.mysql.slaveId=10
# 下面就是连接信息
canal.instance.master.address=127.0.0.1:3306
# 因为，我们单独创建了从库的账号，就是用从库账号，没有配置从库账号，就是用root即可
canal.instance.dbUsername=slave
canal.instance.dbPassword=xxx123456
```

- 这样，现在canal就配置了使用默认的example配置了只监听一台mysql主库
- 进入脚本路径

```shell
cd bin
```

- 启动

```shell
./startup.sh
```

## java连接canal读取数据

- 创建一个maven项目
- 添加如下客户端依赖

```xml

<dependency>
    <groupId>com.alibaba.otter</groupId>
    <artifactId>canal.client</artifactId>
    <version>1.1.7</version>
</dependency>

<dependency>
<groupId>com.alibaba.otter</groupId>
<artifactId>canal.protocol</artifactId>
<version>1.1.7</version>
</dependency>
```

- 创建一个测试类

```java
package i2f.extension.canal.test;

import com.alibaba.otter.canal.client.CanalConnector;
import com.alibaba.otter.canal.client.CanalConnectors;
import com.alibaba.otter.canal.protocol.CanalEntry;
import com.alibaba.otter.canal.protocol.Message;
import com.google.protobuf.ByteString;

import java.net.InetSocketAddress;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * @author Ice2Faith
 * @date 2024/11/23 14:12
 */
public class TestCanal {
    public static void main(String[] args) throws Exception {
        CanalConnector connector = CanalConnectors.newSingleConnector(
                new InetSocketAddress("192.168.1.100", 11111),
                "example",
                "canal",
                "xxx123456"
        );

        try {

            connector.connect();

            connector.subscribe("test_db.*");

            System.out.println("listening ...");
            while (true) {

                Message message = connector.get(300);
                List<CanalEntry.Entry> entries = message.getEntries();
                if (entries.isEmpty()) {
                    System.out.println("idle ...");
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e) {

                    }
                    continue;
                }

                for (CanalEntry.Entry entry : entries) {
                    CanalEntry.Header header = entry.getHeader();
                    String tableName = header.getTableName();
                    CanalEntry.EntryType entryType = entry.getEntryType();

                    System.out.println("--------------------");
                    System.out.println("tableName:" + tableName);
                    System.out.println("entryType:" + entryType);
                    if (CanalEntry.EntryType.ROWDATA != entryType) {
                        continue;
                    }

                    ByteString storeValue = entry.getStoreValue();
                    CanalEntry.RowChange rowChange = CanalEntry.RowChange.parseFrom(storeValue);
                    CanalEntry.EventType eventType = rowChange.getEventType();
                    System.out.println("eventType:" + eventType);

                    if (eventType == CanalEntry.EventType.QUERY || rowChange.getIsDdl()) {
                        System.out.println("sql:\n" + rowChange.getSql());
                    }

                    List<CanalEntry.RowData> rowDatasList = rowChange.getRowDatasList();
                    if (rowDatasList.isEmpty()) {
                        continue;
                    }

                    for (CanalEntry.RowData rowData : rowDatasList) {
                        List<CanalEntry.Column> beforeColumnsList = rowData.getBeforeColumnsList();
                        Map<String, Object> before = new LinkedHashMap<>();
                        for (CanalEntry.Column column : beforeColumnsList) {
                            before.put(column.getName(), column.getValue());
                        }

                        List<CanalEntry.Column> afterColumnsList = rowData.getAfterColumnsList();
                        Map<String, Object> after = new LinkedHashMap<>();
                        for (CanalEntry.Column column : afterColumnsList) {
                            after.put(column.getName(), column.getValue());
                        }

                        System.out.println("before:\n" + before);
                        System.out.println("after:\n" + after);
                    }
                }
            }
        } finally {
            connector.disconnect();
        }

    }
}

```