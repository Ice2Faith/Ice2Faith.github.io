# redis 入门

## 简介
- redis是一个高效的缓存中间件

## 依赖环境
- 无

---
## 环境搭建
- 下载
```shell script
wget -c https://download.redis.io/releases/redis-6.2.1.tar.gz
```
- 解压:
```shell script
tar -zxvf redis-6.2.1.tar.gz
```
- 更改配置文件
```shell script
cd redis-6.2.1
```
- 编译安装
```shell script
make
```
- 编辑配置文件
```shell script
vi redis.conf
```
### 配置
- 新增或修改项，主要是添加访问密码与后台运行
    - 密码为：12315
```shell script
#设置连接密码
requirepass 12315
#设置后台进程守护，能够在后台运行
daemonize yes
#开启远程访问权限
bind 0.0.0.0
#关闭保护模式
protected-mode no
```
- 编写启动文件
```shell script
vi start.sh
```
```shell script
chmod a+x ./src/redis-server
./src/redis-server redis.conf
echo done.
ps -ef | grep -v grep | grep redis
```
- 编写停止脚本
```shell script
vi stop.sh
```
```shell script
PID=`ps -ef | grep -v grep | grep redis | awk '{print $2}'`
echo redis pid=$PID
kill -9 $PID
echo done.
```
- 添加执行权限
```shell script
chmod a+x *.sh
```

## 启动服务
```shell script
./start.sh
```

## 验证
```shell script
redis-cli -h [主机] -a [密码]

./src/redis-cli -a 12315
```
- 输入命令
```shell script
keys *
```
- 有响应则正确
- 退出客户端
```shell script
quit
```



