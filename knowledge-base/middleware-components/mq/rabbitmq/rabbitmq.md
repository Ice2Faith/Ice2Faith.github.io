# rabbit mq

- rabbitmq是由erlang编写的mq服务
- 因此使用时需要erlang环境
- 也就是需要先安装erlang
- 注意，rabbitmq因为是erlang环境
- 所以，rabbitmq的版本就需要特定的erlang版本对应才行
- 从下面地址从查找版本关系

```shell
https://www.rabbitmq.com/docs/which-erlang
```

## windows安装

### 安装erlang

- 前面说了，因为是使用erlang编写的
- 所以，需要先安装erlang环境
- 官网

```shell
https://www.erlang.org/
```

- 下载

```shell
https://github.com/erlang/otp/releases/download/OTP-24.0/otp_win64_24.0.exe
```

- 安装
- 双击安装即可，路径尽量不要包含空格和中文符号
- 我的安装路径如下

```shell
C:\erl-24.0
```

- 勾选要安装的内容时
- 全部勾选即可
- 配置环境变量

```shell
ERLANG_HOME
C:\erl-24.0

Path
%ERLANG_HOME%\bin
```

- 验证安装
- 打开cmd

```shell
erl -version
```

### 安装rabbitmq

- 官网

```shell
https://www.rabbitmq.com/
```

- 下载地址

```shell
https://github.com/rabbitmq/rabbitmq-server/releases
```

- 下载

```shell
https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.9.5/rabbitmq-server-3.9.5.exe
```

- 安装
- 双击安装即可
- 需要勾选安装的组件时
- 全部勾选即可
- 安装配置管理项
- 进入安装目录

```shell
cd sbin
```

- 启动管理插件

```shell
rabbitmq-plugins enable rabbitmq_management
```

- 检查服务状态

```shell
rabbitmqctl status
```

- 没有启动的话，可以自己启动一下

```shell
rabbitmq-server.bat
```

- 浏览器访问

```shell
http://localhost:15672
```

- 用户名密码

```shell
guest
guest
```

## Linux安装

### 安装erlang

- 前面说了，因为是使用erlang编写的
- 所以，需要先安装erlang环境
- 官网

```shell
https://www.erlang.org/
```

- 下载

```shell
https://github.com/erlang/otp/releases/download/OTP-24.0/otp_src_24.0.tar.gz
```

- 解压

```shell
tar -xzvf otp_src_24.0.tar.gz
```

- 进入路径

```shell
cd otp_src_24.0
```

- 以下操作需要root权限

- 先安装依赖

```shell
yum install ncurses-devel
```

- 编译并安装

```shell
./configure && make && make install
```

- 验证安装

```shell
erl -version
```

### 安装rabbitmq

- 官网

```shell
https://www.rabbitmq.com/
```

- 下载地址

```shell
https://github.com/rabbitmq/rabbitmq-server/releases
```

- 下载

```shell
https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.9.5/rabbitmq-server-generic-unix-3.9.5.tar.xz
```

- 解压

```shell
xz -d rabbitmq-server-generic-unix-3.9.5.tar.xz
tar -xvf rabbitmq-server-generic-unix-3.9.5.tar 
```

- 进入路径

```shell
cd rabbitmq_server-3.9.5
```

- 安装配置管理项
- 进入安装目录

```shell
cd sbin
```

- 编写启停脚本

```shell
vi processctl.sh
```

- 修改以下内容

```shell

# 应用名称，用于表示应用名称，仅显示使用
APP_NAME=rabbitmq

# 进程名称，用于ps查找进程的关键字
PROCESS_NAME=rabbitmq_server
# 进程绑定的端口，用于netstat查找进程
BIND_PORT=15672

# 工作路径，脚本开始运行时候，将会先cd进入此路径
WORK_DIR=

# 启动与停止命令
START_CMD="./rabbitmq-server"
STOP_CMD=

# 是否使用nohup后台运行启动命令
ENABLE_NOHUP=$BOOL_TRUE

# 是否具有专门的停止命令
ENABLE_STOP_CMD=$BOOL_FALSE

# 在执行启动或者停止命令之前执行的内容
function beforeStart(){
  echo rabbitmq started on web : http://localhost:$BIND_PORT/
  echo "starting ..."
}

function beforeStop(){
  echo "stopping .."
}
```

- 启动管理插件

```shell
./rabbitmq-plugins enable rabbitmq_management
```

- 检查服务状态

```shell
./rabbitmqctl status
```

- 没有启动的话，可以自己启动一下

```shell
./processctl.sh restart
```

- 浏览器访问

```shell
http://localhost:15672
```

- 用户名密码

```shell
guest
guest
```

- 如果出现登录报错

```shell
User can only log in via localhost
```

- 就是该用户没有远程访问权限
- 可以根据下面的远程访问用户设置来调整


- [可选]添加远程访问用户
- 添加用户admin,密码123456

```shell
./rabbitmqctl add_user admin 123456
```

- 授予管理员角色

```shell
./rabbitmqctl set_user_tags admin administrator
```

- 授予远程访问权限

```shell
./rabbitmqctl set_permissions -p "/" admin ".*" ".*" ".*"
```

- 查看用户列表

```shell
./rabbitmqctl list_users
```

- 如果没有生效
- 请重启服务

```shell
./processctl.sh restart
```