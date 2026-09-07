## 启停 jar
- 推荐使用脚本的方式进行启停
- 一般准备三个脚本：启动、停止、重启
- 启动脚本
```shell script
vi start.sh
```
```shell script
# 获取当前目录下的.jar文件
APP=`ls -a | grep -v grep | grep .jar | head -1`
# 设置虚拟机启动参数
JVM_OPS="-Xms64m -Xmx256m -XX:PermSize=32M -XX:MaxPermSize=125M"
# 设置文件路径
META_PATH=meta
# 创建文件路径
mkdir $META_PATH
# 指定日志文件
LOG_FILE=$META_PATH/$APP.log
# 指定PID文件
PID_FILE=$META_PATH/$APP.pid
# 后台启动方式启动jar,并输出log文件，pid文件
nohup java -jar $JVM_OPS $APP 2>&1 > $LOG_FILE & echo $! > $PID_FILE
# 等待一秒
sleep 1
# 打印日志
tail -300f $LOG_FILE
```
- 停止脚本
```shell script
vi stop.sh
```
```shell script
# 获取当前目录下的.jar文件
APP=`ls -a | grep -v grep | grep .jar | head -1`
# 获取jar对应的进程PID
PID=`ps -ef | grep -v grep | grep $APP | awk '{print $2}'`
echo $APP PID=$PID
# 杀死PID进程
kill -9 $PID
sleep 1
echo done.
```
- 重启脚本
```shell script
vi reboot.sh
```
```shell script
./stop.sh
./start.sh
```
