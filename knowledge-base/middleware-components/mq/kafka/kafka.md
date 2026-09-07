# kafka 入门

## 简介
- kafka是一个可靠的消息确认可重放的高性能消息队列中间件
- 主打的是性能与大数据传输，可能会丢失一些数据
- 主要用于物联网设备信息采集、日志采集等场景
- 这类场景的数据量大、要求处理速度快
- 但是对于丢失几条数据是没什么影响的场景
- 就很适合kafka来做

## 依赖环境
- java
- zookeeper

---
## 环境搭建
- 下载
```shell script
wget -c https://downloads.apache.org/kafka/3.3.1/kafka_2.12-3.3.1.tgz
```
- 解压:
```shell script
tar -zxvf kafka_2.12-3.3.1.tgz
```
- 更改配置文件
```shell script
cd kafka_2.12-3.3.1
```
- 编辑配置文件
```shell script
vi ./config/server.properties
```
### 单机配置
- 修改或添加一下配置，主要是指定zookeeper的服务
- 这里指向了本机的zookeeper2181端口，并且指定kafka的数据都放在zk的/kafka节点下
```shell script
log.dirs=../kafka-datas/logs

zookeeper.connect=localhost:2181/kafka
```
- 编写启动文件
- 如果启动失败，去掉 -daemon 参数，重新启动查看错误日志
```shell script
vi start.sh
```
```shell script
./bin/kafka-server-start.sh -daemon ./config/server.properties
sleep 2
ps -ef | grep -v grep | grep kafka
echo done.
```
- 编写停止脚本
```shell script
vi stop.sh
```
```shell script
./bin/kafka-server-stop.sh
sleep 2
echo done.
```

## 启动服务
```shell script
./start.sh
```

## 验证是否可用
- 先构造一个topic,向其中写入一些数据 test_topic
```shell script
./bin/kafka-console-producer.sh --topic test_topic --broker-list localhost:9092
```
- 随便输入一些什么内容
- Ctrl+C关闭生产者
- 打开消费者，消费 test_topic 的数据
```shell script
./bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test_topic
```
- 如果看到前面输入的内容，则服务成功安装