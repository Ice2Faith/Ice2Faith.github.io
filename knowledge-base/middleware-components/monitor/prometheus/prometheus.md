# prometheus 运维监控告警平台

- 是一款开源的运维监控指标采集平台
- 常常与其他可视化软件（如grafana）结合
- 构建可视化的运维监控告警一体化平台
- 其中依托prometheus强大的采集插件(exporter)进行指标数据的采集
- 但是自身提供的可视化能力有限
- 因此，常常与grafana这个可视化软件结合
- grafana提供了强大的数据介入能力与可视化配置能力
- 能够丰富的展示各类数据指标

----------------------------------------------------------------------------

## 安装

- 官网

```shell
https://prometheus.io/
```

- 地址

```shell
https://prometheus.io/download/
```

- 下载

```shell
wget https://github.com/prometheus/prometheus/releases/download/v3.0.0/prometheus-3.0.0.linux-amd64.tar.gz
```

- 解压

```shell
tar -xzvf prometheus-3.0.0.linux-amd64.tar.gz
```

- 重命名

```shell
mv prometheus-3.0.0.linux-amd64 prometheus-3.0.0
```

- 进入路径

```shell
cd prometheus-3.0.0
```

- 查看配置文件

```shell
cat prometheus.yml
```

- 将会以中文描述添加说明到配置文件中

```yml
# my global config
# 全局配置
global:
  # 数据抓取频率，每隔多长时间从scrape_configs配置的exporter节点中抓取指标数据
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  # 规则检查频率，每隔多长时间从rule_files配置的规则中，判断是否要触发规则执行
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
# 告警配置
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
# 规则配置
rule_files:
# - "first_rules.yml"
# - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
# 抓取配置，后面加的各种exporter端点，要接入prometheus,就要配置在这边，让prometheus去抓取数据
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  # 这是一个列表配置，可以配置多个，job_name唯一即可
  # 一般，job_name表示一类相同属性的端点，比如，干同一件事的服务器，同一个服务
  # 默认配置，就会有一个prometheus服务
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      # 在target中添加具体的端点实例，比如某个service在三台服务器以负载均衡的模式部署
      # 则，这里就可以添加三台主机的地址
      - targets: [ "localhost:9090" ]
```

- 统一启停脚本
  - 对应变更以下内容
  - 使用
  - 启动： ./processctl.sh start
  - 停止： ./processctl.sh stop

```shell
vi processctl.sh
```

```shell

# 应用名称，用于表示应用名称，仅显示使用
APP_NAME=prometheus

# 进程名称，用于ps查找进程的关键字
PROCESS_NAME=prometheus
# 进程绑定的端口，用于netstat查找进程
BIND_PORT=9090

# 工作路径，脚本开始运行时候，将会先cd进入此路径
WORK_DIR=

# 启动与停止命令
CONFIG_FILE=./prometheus.yml
START_CMD="./prometheus --web.enable-lifecycle --web.listen-address=:$BIND_PORT --config.file=$CONFIG_FILE"
STOP_CMD=

# 是否使用nohup后台运行启动命令
ENABLE_NOHUP=$BOOL_TRUE

# 是否具有专门的停止命令
ENABLE_STOP_CMD=$BOOL_FALSE

# 在执行启动或者停止命令之前执行的内容
function beforeStart(){
  echo prometheus started on web : http://localhost:$BIND_PORT/
  echo "starting ..."
}

function beforeStop(){
  echo "stopping .."
}
```

- 添加执行权限

```shell
chmod +x *.sh
```

- 启动

```shell
./processctl.sh restart
```

- 浏览器访问

```shell
http://localhost:9090/
```

----------------------------------------------------------------------------

## 插件安装

- 地址

```shell
https://prometheus.io/docs/instrumenting/exporters/
```

- 示例配置文件参考

```yml
# my global config
global:
  scrape_interval: 15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  # scrape_timeout is set to the global default (10s).

# Alertmanager configuration
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          # - alertmanager:9093

# Load rules once and periodically evaluate them according to the global 'evaluation_interval'.
rule_files:
# - "first_rules.yml"
# - "second_rules.yml"

# A scrape configuration containing exactly one endpoint to scrape:
# Here it's Prometheus itself.
scrape_configs:
  # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
  - job_name: "prometheus"

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.

    static_configs:
      - targets: [ "localhost:9090" ]

  - job_name: "node_exporter"
    static_configs:
      - targets: [ "localhost:9101" ]

  - job_name: "redis_exporter"
    static_configs:
      - targets: [ "localhost:9102" ]

  - job_name: "mysql_exporter"
    static_configs:
      - targets: [ "localhost:9103" ]

  - job_name: "oracledb_exporter"
    static_configs:
      - targets: [ "localhost:9104" ]

  - job_name: "nginx_exporter"
    static_configs:
      - targets: [ "localhost:9113" ]

  - job_name: "grafana"
    static_configs:
      - targets: [ "localhost:9200" ]

  - job_name: "jmx"
    static_configs:
      - targets: [ "localhost:12345" ]
        labels:
          instance: 'svc-biz'
      - targets: [ "localhost:12346" ]
        labels:
          instance: 'svc-sys'
      - targets: [ "localhost:12347" ]
        labels:
          instance: 'svc-job'
      - targets: [ "localhost:12348" ]
        labels:
          instance: 'svc-gateway'
```
----------------------------------------------------------------------------

### 服务器监控(node_exporter)

- 需要部署在被检测的主机上
- 可以观测内存、CPU、网络、磁盘等资源情况
- 地址

```shell
https://prometheus.io/download/#node_exporter
```

- 下载

```shell
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
```

- 解压

```shell
tar -xzvf node_exporter-1.8.2.linux-amd64.tar.gz
```

- 重命名

```shell
mv node_exporter-1.8.2.linux-amd64 node_exporter-1.8.2
```

- 进入路径

```shell
cd node_exporter-1.8.2
```

- 统一启停脚本
  - 对应变更以下内容
  - 使用
  - 启动： ./processctl.sh start
  - 停止： ./processctl.sh stop

```shell
vi processctl.sh
```

```shell

# 应用名称，用于表示应用名称，仅显示使用
APP_NAME=node_exporter

# 进程名称，用于ps查找进程的关键字
PROCESS_NAME=node_exporter
# 进程绑定的端口，用于netstat查找进程
BIND_PORT=9101

# 工作路径，脚本开始运行时候，将会先cd进入此路径
WORK_DIR=

# 启动与停止命令
START_CMD="./node_exporter --web.listen-address=:$BIND_PORT"
STOP_CMD=

# 是否使用nohup后台运行启动命令
ENABLE_NOHUP=$BOOL_TRUE

# 是否具有专门的停止命令
ENABLE_STOP_CMD=$BOOL_FALSE

# 在执行启动或者停止命令之前执行的内容
function beforeStart(){
  echo node_exporter started on web : http://localhost:$BIND_PORT/
  echo "starting ..."
}

function beforeStop(){
  echo "stopping .."
}
```

- 添加执行权限

```shell
chmod +x *.sh
```

- 启动

```shell
./processctl.sh restart
```

- 浏览器访问

```shell
http://localhost:9101/metrics
```

- 将实例添加到prometheus中
- 编辑prometheus配置文件

```shell
vi prometheus.yml
```

- 在 scrape_configs 节点中添加

```yml
scrape_configs:
  # ...
  - job_name: "node_exporter"
      static_configs:
        - targets: [ "localhost:9101" ]
```

- 保存后，重启prometheus即可

- 配置grafana面板
- 直接从URL导入面板

```shell
https://grafana.com/grafana/dashboards/1860-node-exporter-full/
```

- 也可拖入文件

```shell
node_exporter/Node-xxx.json
```

- 无需其他配置，直接使用即可

----------------------------------------------------------------------------

### Redis监控(redis_exporter)

- 需要配置被监控的Redis的连接信息
- 可以统计Redis的状态信息
- 地址

```shell
https://github.com/oliver006/redis_exporter/releases
```

- 下载

```shell
wget https://github.com/oliver006/redis_exporter/releases/download/v1.66.0/redis_exporter-v1.66.0.linux-amd64.tar.gz
```

- 解压

```shell
tar -xzvf redis_exporter-v1.66.0.linux-amd64.tar.gz
```

- 重命名

```shell
mv redis_exporter-v1.66.0.linux-amd64 redis_exporter-v1.66.0
```

- 进入路径

```shell
cd redis_exporter-v1.66.0
```

- 统一启停脚本
  - 对应变更以下内容
  - 使用
  - 启动： ./processctl.sh start
  - 停止： ./processctl.sh stop

```shell
vi processctl.sh
```

```shell

# 应用名称，用于表示应用名称，仅显示使用
APP_NAME=redis_exporter

# 进程名称，用于ps查找进程的关键字
PROCESS_NAME=redis_exporter
# 进程绑定的端口，用于netstat查找进程
BIND_PORT=9102

# 工作路径，脚本开始运行时候，将会先cd进入此路径
WORK_DIR=

# 启动与停止命令
REDIS_ADDR=redis://localhost:6379
export REDIS_PASSWORD=""
# --redis.password=
START_CMD="./redis_exporter --redis.addr=$REDIS_ADDR --web.listen-address=:$BIND_PORT"
STOP_CMD=

# 是否使用nohup后台运行启动命令
ENABLE_NOHUP=$BOOL_TRUE

# 是否具有专门的停止命令
ENABLE_STOP_CMD=$BOOL_FALSE

# 在执行启动或者停止命令之前执行的内容
function beforeStart(){
  echo redis_exporter started on web : http://localhost:$BIND_PORT/
  echo "starting ..."
}

function beforeStop(){
  echo "stopping .."
}
```

- 添加执行权限

```shell
chmod +x *.sh
```

- 启动

```shell
./processctl.sh restart
```

- 浏览器访问

```shell
http://localhost:9102/metrics
```

- 将实例添加到prometheus中
- 编辑prometheus配置文件

```shell
vi prometheus.yml
```

- 在 scrape_configs 节点中添加

```yml
scrape_configs:
  # ...
  - job_name: "redis_exporter"
      static_configs:
        - targets: [ "localhost:9102" ]
```

- 保存后，重启prometheus即可

- 配置grafana面板
- 直接从URL导入面板

```shell
https://grafana.com/grafana/dashboards/11835-redis-dashboard-for-prometheus-redis-exporter-helm-stable-redis-ha/
```

- 也可拖入文件

```shell
redis_exporter/Redis-xxx.json
```

- 无需其他配置，直接使用即可

----------------------------------------------------------------------------

### MySQL监控(mysqld_exporter)

- 需要配置被监控的数据库的连接信息
- 可以统计数据库的状态信息
- 地址

```shell
https://prometheus.io/download/#mysqld_exporter
```

- 下载

```shell
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.16.0/mysqld_exporter-0.16.0.linux-amd64.tar.gz
```

- 解压

```shell
tar -xzvf mysqld_exporter-0.16.0.linux-amd64.tar.gz
```

- 重命名

```shell
mv mysqld_exporter-0.16.0.linux-amd64 mysqld_exporter-0.16.0
```

- 链接数据库，先添加一个用户，专用于检测
- 进入mysql命令行

```shell
mysql -u root -p
```

- 切换到mysql数据库

```sql
use
mysql
```

```sql
CREATE
USER 'mysql_exporter'@'localhost' IDENTIFIED BY 'xxx123456' WITH MAX_USER_CONNECTIONS 3;
GRANT PROCESS, REPLICATION
CLIENT,
SELECT
ON *.* TO 'mysql_exporter'@'localhost';
```

- 退出mysql客户端

```sql
exit
```

- 进入路径

```shell
cd mysqld_exporter-0.16.0
```

- 添加数据库用户配置文件

```shell
vi my.cnf
```

```shell
[client]
user=mysql_exporter
password=xxx123456
```

- 统一启停脚本
  - 对应变更以下内容
  - 使用
  - 启动： ./processctl.sh start
  - 停止： ./processctl.sh stop

```shell
vi processctl.sh
```

```shell

# 应用名称，用于表示应用名称，仅显示使用
APP_NAME=mysqld_exporter

# 进程名称，用于ps查找进程的关键字
PROCESS_NAME=mysqld_exporter
# 进程绑定的端口，用于netstat查找进程
BIND_PORT=9103

# 工作路径，脚本开始运行时候，将会先cd进入此路径
WORK_DIR=

# 启动与停止命令
MYSQL_ADDRESS=localhost:3306
MYSQL_CONF=./my.cnf
START_CMD="./mysqld_exporter --mysqld.address=$MYSQL_ADDRESS --config.my-cnf=$MYSQL_CONF --web.listen-address=:$BIND_PORT"
STOP_CMD=

# 是否使用nohup后台运行启动命令
ENABLE_NOHUP=$BOOL_TRUE

# 是否具有专门的停止命令
ENABLE_STOP_CMD=$BOOL_FALSE

# 在执行启动或者停止命令之前执行的内容
function beforeStart(){
  echo mysqld_exporter started on web : http://localhost:$BIND_PORT/
  echo "starting ..."
}

function beforeStop(){
  echo "stopping .."
}
```

- 添加执行权限

```shell
chmod +x *.sh
```

- 启动

```shell
./processctl.sh restart
```

- 浏览器访问

```shell
http://localhost:9103/metrics
```

- 将实例添加到prometheus中
- 编辑prometheus配置文件

```shell
vi prometheus.yml
```

- 在 scrape_configs 节点中添加

```yml
scrape_configs:
  # ...
  - job_name: "mysqld_exporter"
      static_configs:
        - targets: [ "localhost:9103" ]
```

- 保存后，重启prometheus即可


- 配置grafana面板
- 直接从URL导入面板

```shell
https://grafana.com/grafana/dashboards/14057-mysql/
```

- 也可拖入文件

```shell
mysqld_exporter/MySQL-xxx.json
```

- 无需其他配置，直接使用即可

----------------------------------------------------------------------------

### Oracle监控(oracledb_exporter)

- 需要配置被监控的Oracle的连接信息
- 可以统计Oracle的状态信息
- 地址

```shell
https://github.com/iamseth/oracledb_exporter/releases
```

- 下载

```shell
wget https://github.com/iamseth/oracledb_exporter/releases/download/0.6.0/oracledb_exporter-0.6.0.linux-amd64.tar.gz
```

- 解压

```shell
tar -xzvf oracledb_exporter-0.6.0.linux-amd64.tar.gz
```

- 重命名

```shell
mv oracledb_exporter-0.6.0.linux-amd64 oracledb_exporter-0.6.0
```

- 进入路径

```shell
cd oracledb_exporter-0.6.0
```

- 统一启停脚本
  - 对应变更以下内容
  - 使用
  - 启动： ./processctl.sh start
  - 停止： ./processctl.sh stop

```shell
vi processctl.sh
```

```shell

# 应用名称，用于表示应用名称，仅显示使用
APP_NAME=oracledb_exporter

# 进程名称，用于ps查找进程的关键字
PROCESS_NAME=oracledb_exporter
# 进程绑定的端口，用于netstat查找进程
BIND_PORT=9104

# 工作路径，脚本开始运行时候，将会先cd进入此路径
WORK_DIR=

# 启动与停止命令
# 注意事项，密码部分如果包含特殊符号，需要进行urlEncoded转码
# 同时，因为命令在Linux命令行环境，如有特殊符号，也要对命令行环境转义
export DATA_SOURCE_NAME=oracle://admin:xxx123456@localhost:1521/orcl
START_CMD="./oracledb_exporter --log.level error --web.listen-address 0.0.0.0:$BIND_PORT"
STOP_CMD=

# 是否使用nohup后台运行启动命令
ENABLE_NOHUP=$BOOL_TRUE

# 是否具有专门的停止命令
ENABLE_STOP_CMD=$BOOL_FALSE

# 在执行启动或者停止命令之前执行的内容
function beforeStart(){
  echo oracledb_exporter started on web : http://localhost:$BIND_PORT/
  echo "starting ..."
}

function beforeStop(){
  echo "stopping .."
}
```

- 添加执行权限

```shell
chmod +x *.sh
```

- 启动

```shell
./processctl.sh restart
```

- 浏览器访问

```shell
http://localhost:9103/metrics
```

- 将实例添加到prometheus中
- 编辑prometheus配置文件

```shell
vi prometheus.yml
```

- 在 scrape_configs 节点中添加

```yml
scrape_configs:
  # ...
  - job_name: "oracledb_exporter"
      static_configs:
        - targets: [ "localhost:9104" ]
```

- 保存后，重启prometheus即可

- 配置grafana面板
- 直接从URL导入面板

```shell
https://grafana.com/grafana/dashboards/3333-oracledb/
```

- 也可拖入文件

```shell
oracledb_exporter/Oracledb-xxx.json
```

- 无需其他配置，直接使用即可

----------------------------------------------------------------------------

### Java进程监控(jmx_prometheus_javaagent)

- 以javaagent探针的方式实现jmx监控
- 因此以agent探针方式启动或者挂载探针都可以
- 地址

```shell
https://github.com/prometheus/jmx_exporter
```

- 仓库地址

```shell
https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent
```

- 下载

```shell
wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/1.0.1/jmx_prometheus_javaagent-1.0.1.jar
```

- 编辑配置文件

```shell
vi config.yaml
```

```yml
ssl: false
lowercaseOutputName: false
lowercaseOutputLabelNames: false
rules:
  - pattern: ".*"
```

- 以探针方式启动java进程
  - 下面的12345即为暴露指标的端口
  - config.yml即为配置文件

```shell
java -javaagent:./jmx_prometheus_javaagent-1.0.1.jar=12345:config.yaml -jar app.jar
```

- 以挂载方式

```shell
java -jar jmx_prometheus_httpserver-1.0.1.jar 12345 config.yaml
```

- 将实例添加到prometheus中
- 编辑prometheus配置文件

```shell
vi prometheus.yml
```

- 在 scrape_configs 节点中添加

```yml
scrape_configs:
  # ...
  - job_name: "jmx"
      static_configs:
        - targets: [ "localhost:12345" ]
          labels:
            instance: 'java-app'
        - targets: [ "localhost:12346" ]
          labels:
            instance: 'java-svc'
        - targets: [ "localhost:12347" ]
          labels:
            instance: 'java-gateway'
```

- 保存后，重启prometheus即可

- 配置grafana面板
- 直接从URL导入面板

```shell
https://grafana.com/grafana/dashboards/14845-jmx-dashboard-basic/
```

- 也可拖入文件

```shell
jmx_prometheus_javaagent/JMX-xxx.json
```

- 进入面板后，点击[job]输入框，输入jmx即可
- 下面介绍，永久修改此面板默认值为jmx
- 进入面板
- 点击右上角[Edit]按钮
- 点击右上角刚变成的[Settings]按钮
- 切换到[Variables]页面
- 点击第一行[job]
- 找到[Query options]板块
- 找到[Metric]表单项
- 修改为[jvm_runtime_info]
- 找到[Label filters]表单项
- 填写等号左边为[job]
- 填写等号右边为[jmx]
- 拉倒最下面，点击[Back to list]
- 点击右上角[Back to dashboard]
- 可以看到，job的默认值已经变成了[jmx]
- 点击右上角[Save dashboard]
- 在弹出框中，点击[Save]
- 完成配置

----------------------------------------------------------------------------

### Nginx监控(nginx-prometheus-exporter)

- 需要配置被监控的Nginx的连接信息
- 可以统计Nginx的状态信息

- 前提条件
- nginx有启用http_stub_status_module
- 此条命令执行有输出，则已经启用了

```shell
./nginx -V 2>&1 | grep -o with-http_stub_status_module
```

- 如果没有输出，则没有启用，需要重新编译nginx
- 这部分，详细细节参考 nginx.md

```shell
./configure --prefix=/usr/local/nginx --with-http_stub_status_module
# 如果已经有了nginx，那就下面这句，只编译不安装，手动覆盖nginx文件
make
# 如果是全新安装，则可以编译并安装
make & make install
```

- 就当已经具备条件了，那继续往下进行

- 查找nginx所在路径

```shell
ps -ef | grep nginx
lsof -p 刚查到的进程PID | grep cwd
cd 刚查到的nginx路径
```

- 编辑nginx配置文件，添加一个location
- 其中，location的地址无所谓
- 但是location内部的stub_status不能改变

```shell
vi conf/nginx.conf
```

```shell
http {
  ...
  server {
    ...
    location /nginx_status {
       stub_status;
    }
  }
}
```

- 保存并重载nginx

```shell
./sbin/nginx -s reload
```

- 访问链接

```shell
http://localhost:8080/nginx_status
```

- 页面显示结果应该大致如下

```text
Active connections: 1 
server accepts handled requests
 121 121 388 
Reading: 0 Writing: 1 Waiting: 0 
```

- 安装 exporter
- 地址

```shell
https://github.com/nginxinc/nginx-prometheus-exporter/releases
```

- 下载

```shell
wget https://github.com/nginxinc/nginx-prometheus-exporter/releases/download/v1.3.0/nginx-prometheus-exporter_1.3.0_linux_amd64.tar.gz
```

- 解压

```shell
mkdir nginx-prometheus-exporter_1.3.0
tar -xzvf nginx-prometheus-exporter_1.3.0_linux_amd64.tar.gz -C nginx-prometheus-exporter_1.3.0
```

- 进入目录

```shell
cd nginx-prometheus-exporter_1.3.0
```

- 统一启停脚本
  - 对应变更以下内容
  - 使用
  - 启动： ./processctl.sh start
  - 停止： ./processctl.sh stop

```shell
vi processctl.sh
```

```shell

# 应用名称，用于表示应用名称，仅显示使用
APP_NAME=nginx-prometheus-exporter 

# 进程名称，用于ps查找进程的关键字
PROCESS_NAME=nginx-prometheus-exporter 
# 进程绑定的端口，用于netstat查找进程
BIND_PORT=9113

# 工作路径，脚本开始运行时候，将会先cd进入此路径
WORK_DIR=

# 启动与停止命令
NGINX_URL=http://localhost:8080/nginx_status
START_CMD="./nginx-prometheus-exporter -nginx.scrape-uri=$NGINX_URL --web.listen-address=:$BIND_PORT"
STOP_CMD=

# 是否使用nohup后台运行启动命令
ENABLE_NOHUP=$BOOL_TRUE

# 是否具有专门的停止命令
ENABLE_STOP_CMD=$BOOL_FALSE

# 在执行启动或者停止命令之前执行的内容
function beforeStart(){
  echo nginx-prometheus-exporter started on web : http://localhost:$BIND_PORT/
  echo "starting ..."
}

function beforeStop(){
  echo "stopping .."
}
```

- 添加执行权限

```shell
chmod +x *.sh
```

- 启动

```shell
./processctl.sh restart
```

- 浏览器访问

```shell
http://localhost:9103/metrics
```

- 将实例添加到prometheus中
- 编辑prometheus配置文件

```shell
vi prometheus.yml
```

- 在 scrape_configs 节点中添加

```yml
scrape_configs:
  # ...
  - job_name: "nginx_exporter"
      static_configs:
        - targets: [ "localhost:9113" ]
```

- 保存后，重启prometheus即可

- 配置grafana面板
- 直接从URL导入面板

```shell
https://grafana.com/grafana/dashboards/14900-nginx/
```

- 也可拖入文件

```shell
nginx-prometheus-exporter/Nginx-xxx.json
```

- 无需其他配置，直接使用即可

----------------------------------------------------------------------------

### MongoDB监控(mongodb_exporter)

- 需要配置被监控的MongoDB的连接信息
- 可以统计MongoDB的状态信息
- 地址

```shell
https://github.com/percona/mongodb_exporter/releases
```

- 下载

```shell
wget https://github.com/percona/mongodb_exporter/releases/download/v0.42.0/mongodb_exporter-0.42.0.linux-amd64.tar.gz
```

- 解压

```shell
tar -xzvf mongodb_exporter-0.42.0.linux-amd64.tar.gz
```

- 重命名

```shell
mv mongodb_exporter-0.42.0.linux-amd64 mongodb_exporter-0.42.0
```

- 启动脚本

```shell
export MONGODB_USER=xxx
export MONGODB_PASSWORD=xxx
./mongodb_exporter --mongodb.uri=mongodb://127.0.0.1:17001 --web.listen-address=:9216
```

----------------------------------------------------------------------------

### 黑盒网络监控(blackbox_exporter)

- 可以配置在任意主体上，针对目标主体的网络状态进行检测
- 主要统计网络状态信息
- 地址

```shell
https://prometheus.io/download/#blackbox_exporter
```

- 下载

```shell
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.25.0/blackbox_exporter-0.25.0.linux-amd64.tar.gz
```

- 解压

```shell
tar -xzvf blackbox_exporter-0.25.0.linux-amd64.tar.gz
```

- 重命名

```shell
mv blackbox_exporter-0.25.0.linux-amd64 blackbox_exporter-0.25.0
```

----------------------------------------------------------------------------

### ElasticSearch监控(elasticsearch_exporter)

- 需要配置被监控的ElasticSearch的连接信息
- 可以统计ElasticSearch的状态信息
- 地址

```shell
https://github.com/prometheus-community/elasticsearch_exporter/releases
```

- 下载

```shell
wget https://github.com/prometheus-community/elasticsearch_exporter/releases/download/v1.8.0/elasticsearch_exporter-1.8.0.freebsd-amd64.tar.gz
```

- 解压

```shell
tar -xzvf elasticsearch_exporter-1.8.0.freebsd-amd64.tar.gz
```

- 重命名

```shell
mv elasticsearch_exporter-1.8.0.freebsd-amd64 elasticsearch_exporter-1.8.0
```

- 启动脚本

```shell
./elasticsearch-exporter --es.uri=http://localhost:9200 --web.listen-address=:9114
```

----------------------------------------------------------------------------

### RabbitMQ监控(rabbitmq_exporter)

- 需要配置被监控的RabbitMQ的连接信息
- 可以统计RabbitMQ的状态信息
- 地址

```shell
https://github.com/kbudde/rabbitmq_exporter/releases
```

- 下载

```shell
wget https://github.com/kbudde/rabbitmq_exporter/releases/download/v1.0.0/rabbitmq_exporter_1.0.0_linux_amd64.tar.gz
```

- 解压

```shell
tar -xzvf rabbitmq_exporter_1.0.0_linux_amd64.tar.gz
```

- 重命名

```shell
mv rabbitmq_exporter_1.0.0_linux_amd64 rabbitmq_exporter_1.0.0
```

- 启动脚本

```shell
export RABBIT_URL=http://127.0.0.1:15672
export RABBIT_USER=guest
export RABBIT_PASSWORD=guest
./rabbitmq_exporter -config-file config.example.json
```

----------------------------------------------------------------------------

### Kafka监控(rabbitmq_exporter)

- 需要配置被监控的Kafka的连接信息
- 可以统计Kafka的状态信息
- 地址

```shell
https://github.com/danielqsj/kafka_exporter/releases
```

- 下载

```shell
wget https://github.com/danielqsj/kafka_exporter/releases/download/v1.8.0/kafka_exporter-1.8.0.freebsd-amd64.tar.gz
```

- 解压

```shell
tar -xzvf kafka_exporter-1.8.0.freebsd-amd64.tar.gz
```

- 重命名

```shell
mv kafka_exporter-1.8.0.freebsd-amd64 kafka_exporter-1.8.0
```

- 启动脚本

```shell
./kafka_exporter --kafka.server=kafka:9092 [...--kafka.server=xxx] --web.listen-address=:9308
```

----------------------------------------------------------------------------

### Postgres监控(postgres_exporter)

- 需要配置被监控的Postgres的连接信息
- 可以统计Postgres的状态信息
- 地址

```shell
https://github.com/prometheus-community/postgres_exporter/releases/
```

- 下载

```shell
wget https://github.com/prometheus-community/postgres_exporter/releases/download/v0.16.0/postgres_exporter-0.16.0.freebsd-amd64.tar.gz
```

- 解压

```shell
tar -xzvf postgres_exporter-0.16.0.freebsd-amd64.tar.gz
```

- 重命名

```shell
mv postgres_exporter-0.16.0.freebsd-amd64 postgres_exporter-0.16.0
```

- 启动脚本

```shell
export DATA_SOURCE_URI="localhost:5432/postgres?sslmode=disable"
export DATA_SOURCE_USER=postgres
export DATA_SOURCE_PASS=password
./postgres-exporter --web.listen-address=:9187
```
