# grafana 数据可视化平台

- 是一款开源的数据可视化平台
- 常常与其他数据采集软件（如prometheus）使用

----------------------------------------------------------------------------

## 安装

- 官网

```shell
https://grafana.com/
```

- 下载

```shell
wget https://dl.grafana.com/oss/release/grafana-11.3.0.linux-amd64.tar.gz
```

- 解压

```shell
tar -xzvf grafana-11.3.0.linux-amd64.tar.gz
```

- 进入路径

```shell
cd grafana-v11.3.0
```

- 创建目录

```shell
mkdir logs
mkdir data
mkdir plugins
```

- 进入目录

```shell
cd bin
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
APP_NAME=grafana

# 进程名称，用于ps查找进程的关键字
PROCESS_NAME=grafana-server
# 进程绑定的端口，用于netstat查找进程
BIND_PORT=9200

# 工作路径，脚本开始运行时候，将会先cd进入此路径
WORK_DIR=

# 启动与停止命令
# 安装路径
export GRAFANA_HOME=`realpath ../`
# WEB端口
export GF_SERVER_HTTP_PORT=$BIND_PORT
#定义用户，我最开始使用grafana，不知道哪个文件授权有问题导致服务没法启动
export GRAFANA_USER=root
#定义组 
export GRAFANA_GROUP=root
#grafana的日志文件，最好自己手动建好
export GF_PATHS_LOGS=logs
#grafana的数据存储路径，最好自己手动建好
export GF_PATHS_DATA=data
#grafana的组件目录，自己手动建好
export GF_PATHS_PLUGINS=plugins
#grafana的provisioning的路径，tar包解压出来就有
export GF_PATHS_PROVISIONING=conf/provisioning

CONFIG_FILE=$GRAFANA_HOME/conf/defaults.ini
START_CMD="./grafana-server --config=$CONFIG_FILE --homepath=$GRAFANA_HOME --pidfile=metas/pid.grafana-server"
STOP_CMD=

# 是否使用nohup后台运行启动命令
ENABLE_NOHUP=$BOOL_TRUE

# 是否具有专门的停止命令
ENABLE_STOP_CMD=$BOOL_FALSE

# 在执行启动或者停止命令之前执行的内容
function beforeStart(){
  echo grafana started on web : http://localhost:$BIND_PORT/
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

- 启动服务

```shell
./processctl.sh restart
```

- 访问链接

```shell
http://localhost:9200/
```

- 默认第一次登录进去
- 要求更改密码

----------------------------------------------------------------------------

## 配置prometheus数据源

- 点击，菜单-Connections-Data Source
- 点击，Add Data Source
- 选择，Prometheus
- 填写名称，prometheus
- 填写prometheus的服务地址，http://localhost:9090
- 看下其他有没有需要特别配置的
- 没有的话，直接拿到最后
- 点击，Save & Test
- 会弹出一个提醒
- 点击，Explore View
- 现在prometheus数据源就配置完成了

- images/grafana/01-grafana-add-datasource.png

![01-grafana-add-datasource.png](images%2Fgrafana%2F01-grafana-add-datasource.png)

- images/grafana/02-grafana-prometheus-datasource.png

![02-grafana-prometheus-datasource.png](images%2Fgrafana%2F02-grafana-prometheus-datasource.png)

- images/grafana/03-grafana-prometheus-datasource-config.png

![03-grafana-prometheus-datasource-config.png](images%2Fgrafana%2F03-grafana-prometheus-datasource-config.png)

----------------------------------------------------------------------------

## 添加监控面板

- 点击，菜单-Dashboards
- 点击按钮，New
- 点击按钮的下拉选项，Import
- 会显示一个填写页面，找到按钮，Load
- 提示可以输入URL或者ID
- 上方有一个链接，grafana.com/dashboards
- 新页面访问这个链接
- 或者也可以访问这个链接

```shell
https://grafana.com/grafana/dashboards/
```

- 下面以添加node_exporter的面板为例
- 在新打开的页面，搜索node
- 找到面板，Node Exporter Full
- 点击进入
- 此时，浏览器URL路径变成了这个

```shell
https://grafana.com/grafana/dashboards/1860-node-exporter-full/
```

- 直接复制这个URL
- 回到Import的页面，粘贴这个URL到Load按钮的输入框
- 点击按钮，Load
- 此时，会显示几个内容，Name,Folder,Prometheus三个输入框
- 可以根据需要，改个Name名字
- 最后，一定要记得，选择一个Prometheus数据源
- 也就是上面刚配置的数据源
- 点击按钮，Import
- 完成配置面板
- 这样，就可以在菜单[Dashboard]中查看到刚才的名字面板了

- images/grafana/04-grafana-add-import-dashboard.png

![04-grafana-add-import-dashboard.png](images%2Fgrafana%2F04-grafana-add-import-dashboard.png)

- images/grafana/05-grafana-import-dashboard-by-url.png

![05-grafana-import-dashboard-by-url.png](images%2Fgrafana%2F05-grafana-import-dashboard-by-url.png)

- images/grafana/06-grafana-import-dashboard-search.png

![06-grafana-import-dashboard-search.png](images%2Fgrafana%2F06-grafana-import-dashboard-search.png)

- images/grafana/07-grafana-import-dashboard-search-copy.png

![07-grafana-import-dashboard-search-copy.png](images%2Fgrafana%2F07-grafana-import-dashboard-search-copy.png)

- images/grafana/08-grafana-import-dashboard-load-url.png

![08-grafana-import-dashboard-load-url.png](images%2Fgrafana%2F08-grafana-import-dashboard-load-url.png)

- images/grafana/09-grafana-import-dashboard-load-url-confirm.png

![09-grafana-import-dashboard-load-url-confirm.png](images%2Fgrafana%2F09-grafana-import-dashboard-load-url-confirm.png)

- images/grafana/10-grafana-dashboard-list.png

![10-grafana-dashboard-list.png](images%2Fgrafana%2F10-grafana-dashboard-list.png)

----------------------------------------------------------------------------

## 告警配置

- 这里介绍email邮件告警的配置

### 邮箱开通SMTP服务

- 需要准备一个已经开通了SMTP的邮箱账号
- 用来充当邮件的发送人
- 下面以网易163邮箱为例
- 打开163官网

```shell
https://mail.163.com/
```

- 登录后，上方找到[设置]-[POP3/SMTP/IMAP]
- 找到[开启服务]-[POP3/SMTP服务]
- 点击开启，继续按照流程完成
- 最后，你会得到一个授权码
- 这个授权码就是后面要用的密码
- 先保存下来，后面使用
- 最下面写明了基本配置

```text
服务器地址：
  POP3服务器: pop.163.com
  SMTP服务器: smtp.163.com
  IMAP服务器: imap.163.com
安全支持：
  POP3/SMTP/IMAP服务全部支持SSL连接
```

- 一会儿就要使用SMTP服务器
- 上面，就完成了开通一个SMTP的邮箱账号

### 配置Grafana发件信息

- 下面，开始配置grafana的发件配置
- 进入安装路径

```shell
cd grafana-v11.3.0
```

- 编辑配置文件

```shell
vi conf/defaults.ini
```

- 找到[smtp]节点并修改以下配置
- 注意，此类ini文件用井号或分好座位注释符号

```shell
[smtp]
enabled = true # 开启配置
host = smtp.163.com:25 # 163的SMTP服务器，默认25端口
user = xxx@163.com # 你的邮箱账号
password = "授权码" # 前面获得的邮箱授权码
cert_file =
key_file =
skip_verify = false # 关闭校验
from_address = xxx@163.com # 发件人，一般就用邮箱账号
from_name = Grafana # 发件人名，自己定义就行
ehlo_identity =
startTLS_policy =
enable_tracing = false
```

- 重启

```shell
cd bin
./processctl.sh restart
```

- 到这里，就完成了告警发件邮箱的配置

### 完善Email发件联系点

- 下面，开始配置邮件告警
- 进入grafana浏览器页面

```shell
http://localhost:9200/
```

- 点击告警菜单[Alerting]
- 点击联系点子菜单[Contact points]
- 默认有一条名为[Email]的联系点
- 点击这条记录右上角[Edit]进行编辑
- 找到[Address]输入框，添加一个接受告警邮件的邮箱地址，例如：xxx@qq.com
- 点击右侧的[Test]按钮进行测试
- 直接使用默认的[Predefined]类型
- 点击[Send test notification]按钮，发送邮件
- 弹出成功提示，同时接受邮箱收到邮件即为成功
- 如果出现发送失败，则有可能被邮箱公司判定为垃圾邮件拦截了
- 或者这个IP被封禁了，需要注意
- 最后，点击下方的[Save Contact points]保存即可
- 接下来，选择合适的指标，进行设置告警

- images/grafana/11-grafana-edit-default-email-contact.png

![11-grafana-edit-default-email-contact.png](images%2Fgrafana%2F11-grafana-edit-default-email-contact.png)

- images/grafana/12-grafana-edit-default-email-contact-address.png

![12-grafana-edit-default-email-contact-address.png](images%2Fgrafana%2F12-grafana-edit-default-email-contact-address.png)

- images/grafana/13-grafana-edit-default-email-contact-test.png

![13-grafana-edit-default-email-contact-test.png](images%2Fgrafana%2F13-grafana-edit-default-email-contact-test.png)

### 对面板指标配置告警

- 点击菜单，进入面板[Dashboards]
- 选择任意一个已经配置的面板，比如[Node Exporter]的面板
- 鼠标悬浮在想要监控告警的图表上
- 我这里选择[Cpu Busy]为例
- 这个图标的右上角就会出现三个点的更多图标
- 点击这个图标
- 点击[More]，点击[New alert rule]
- 第一步，填写规则名称
- 这里，演示就使用[Cpu Busy]
- 第二步，配置指标和告警条件
- 注意，这里的板块，都是用A,B,C等符号来表示输入输出或者变量的
- 一般情况下，A就是刚才选择的图表的指标，也叫做[Query]
- 点击[A]栏右侧的[Run queries]就能够得到这个指标当前的值
- 下面会有[Expressions]板块，也就是配置表达式
- 其中[B]为[Reduce],表示规约策略
- 也就是对输入[input]为[A]的应用[Function]进行取值来进行判断
- 一般情况下，[Function]就取[Last]最后一条
- 右侧[C]为[Threshold],表示阈值限定
- 这里默认就是[Alert condition]告警条件
- 就是对[input]为刚才规约的值[B]进行[IS ABOVE]条件判定
- 这个设置为，B大于4时触发
- 点击下方的[Preview]按钮进行预览当前是否会触发告警
- 右侧显示为[Firing]表示触发告警，[Normal]表示正常，不触发
- 【特殊说明】
- 因为我选择的这只指标，只有一个值，不需要进行[Reduce]规约
- 因此，这里删除[B]的[Reduce]板块
- 将原来的[C]的[input]改为直接从[A]进行判断即可
- 第三部，设置计算偏好
- 也就是设置一个告警抑制时间，避免连续性告警
- 随便新建一个规则即可
- 这里设置为：
- Folder=Alarm
- Evaluation group and interval=AlarmGroup
- Pending period=1m
- 也就是，告警触发一次，至少等1m之后，采用重新打开告警开关
- 第四部，配置标签和通知
- 这里，只配置前面完善好的默认邮箱即可
- 第五步，配置通知信息
- 也就是配置，这条告警要发送什么内容
- 这里简单配置一下
- Summary=Cpu Busy
- Description=1
- Runbook URL=
- 到这里，就配置完毕了
- 点击右上角的[Save rule and exit]保存并退出即可
- 在菜单[Alerting]-[Alert rules]可以看到刚才新增的一条告警规则
- 如有需要，可以展开点击[More]按钮，点击[Pause evaluation]暂停触发规则

- images/grafana/14-grafana-add-alert-rule.png

![14-grafana-add-alert-rule.png](images%2Fgrafana%2F14-grafana-add-alert-rule.png)

- images/grafana/15-grafana-add-alert-rule-2-condition.png

![15-grafana-add-alert-rule-2-condition.png](images%2Fgrafana%2F15-grafana-add-alert-rule-2-condition.png)

- images/grafana/16-grafana-add-alert-rule-2-condition-result.png

![16-grafana-add-alert-rule-2-condition-result.png](images%2Fgrafana%2F16-grafana-add-alert-rule-2-condition-result.png)

- images/grafana/17-grafana-add-alert-rule-3-behavior.png

![17-grafana-add-alert-rule-3-behavior.png](images%2Fgrafana%2F17-grafana-add-alert-rule-3-behavior.png)

- images/grafana/18-grafana-add-alert-rule-4-notification.png

![18-grafana-add-alert-rule-4-notification.png](images%2Fgrafana%2F18-grafana-add-alert-rule-4-notification.png)

- images/grafana/19-grafana-alert-rule-list.png

![19-grafana-alert-rule-list.png](images%2Fgrafana%2F19-grafana-alert-rule-list.png)


---------------------------------------------------------------------------------------------------------------

## 其他配置

### 配置二级URL路径，用于反向代理等需求

- 编辑配置文件

```shell
vi conf/defaults.ini
```

- 编辑[server]节点下的如下内容

```shell

# 不强制域名
enforce_domain = false

# 添加二级路径，两种方式都可以，官方推荐第二种
root_url = /grafana
#root_url = %(protocol)s://%(domain)s:%(http_port)s/grafana

# 开启二级路径
serve_from_sub_path = true
```