# rocket 入门

## 简介

- rocketmq 是一个高性能金融级别保障的消息队列
- 主要用来提供金融级别的一致性保障
- 并且提供例如死信队列、延迟队列、消息事务等高级功能
- 并且能够保证消息的一致性、不丢失性
- 能够用于金融级别对账、支付等高一致性场景

## 依赖环境

- java

---

## 环境搭建

- 下载地址

```shell
https://rocketmq.apache.org/download/
```

- 下载

```shell script
wget -c https://dist.apache.org/repos/dist/release/rocketmq/5.3.3/rocketmq-all-5.3.3-bin-release.zip
```

- 解压:

```shell script
unzip rocketmq-all-5.3.3-bin-release.zip
```

- 进入目录

```shell script
cd rocketmq-all-5.3.3-bin-release
```

- 目录下应该是这样的结构

```shell
bin
conf
lib
```

- 复制当前路径，并添加到环境变量中

```shell
ROCKETMQ_HOME
D:\rocketmq\rocketmq-all-5.3.3-bin-release
```

- 进入bin目录

```shell
cd bin
```

- 【可选】调整name-server管理节点的jvm堆大小
- 默认情况下，jvm堆大小是4G，如果内存不足，启动不了
- 所以，自己的机器上可以调小一点
- 编辑文件

```shell
vi runserver.cmd
```

- 编辑如下行
- 这里他判断你的jdk版本是否小于17
- 然后再分支里面设置jvm参数
- 我们只需要根据他原来的配置等比例缩放大小即可
- 可以看到，最小堆=最大堆=512m
- 并且年轻代大小为256m刚好占堆的一半
- 这样的分配下，对于mq这种高并发，快速处理的java应用来说
- 可以提高GC速度，避免大量并发对象进入survive幸存区，或者直接进入old老年代，最终导致full GC
- jvm 优化调优，就可以跟着学起来了，照着抄就完了

```shell
if %JAVA_MAJOR_VERSION% lss 17 (
   set "JAVA_OPT=%JAVA_OPT% -server -Xms512m -Xmx512m -Xmn256m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"
   :: ...
) else (
   set "JAVA_OPT=%JAVA_OPT% -server -Xms512m -Xmx512m -Xmn256m -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m"
   :: ...
)
```

- 保存修改
- 启动name-server管理节点

```shell
mqnamesrv.cmd
```

- 看到输出这样的日志，就完成了

```shell
The Name Server boot success. serializeType=JSON, address 0.0.0.0:9876
```

- 【可选】编辑broker工作节点的配置
- 和name-server一样，根据自己机器的性能，决定要不要修改jvm堆即可
- 编辑文件

```shell
vi runbroker.cmd
```

- 编辑如下行

```shell
if %JAVA_MAJOR_VERSION% lss 17 (
   set "JAVA_OPT=%JAVA_OPT% -server -Xms512m -Xmx512m"
   :: ...
) else (
   set "JAVA_OPT=%JAVA_OPT% -server -Xms512m -Xmx512m"
   :: ...
)
```

- 保存修改
- 【可选】如果你的C盘或者磁盘空间占比比较高
- 也就是磁盘占比高于80%，默认情况下broker节点会触发磁盘告警
- 不工作，所以，可以选择更改这个占比值，让他不告警，正常工作
- 编辑文件

```shell
vi ../conf/broker,conf
```

- 添加或者修改这个配置
- 我这里直接设置为99%

```shell
diskMaxUsedSpaceRatio=99
```

- 保存修改
- 启动broker工作节点

```shell
mqbroker.cmd -n 127.0.0.1:9876 autoCreateTopicEnable=true
```

- 看到如下的日志即可

```shell
The broker[xxx, 192.168.x.x:10911] boot success. serializeType=JSON and name server is 127.0.0.1:9876
```

- 【可选】验证producer生产者发送消息
- 安装完毕，就先测试一下发送消息
- 直接使用脚本测试即可

```shell
tools.cmd org.apache.rocketmq.example.quickstart.Producer
```

- 看到很快刷新了很多发送消息的日志即可
- 表明发送没有问题
- 【可选】验证consumer消费者接受消息
- 可以把前面的测试发送的消息接收消费
- 这样，发送和接收都进行了测试
- 验证了rocketmq的工作是正常的

```shell
tools.cmd org.apache.rocketmq.example.quickstart.Consumer
```

## 安装dashboard面板

- 这个是可选的，提供一个可视化的界面
- 可以用来查看一些统计信息
- 下载地址

```shell
https://rocketmq.apache.org/download/
```

- 下拉到最后，有dashboard，目前还是只提供源码下载方式
- 因此就需要下载下来编译启动
- 这是一个maven的java项目
    - 实际上，内部会自动下载node进行前端编译
    - 因此，不用管，直接当一个maven项目运行即可
- 因此，作为一个java开发者，这个就不做说明了
- 源码下载下来之后
- 修改一下application.yml中的name-server的指向

```shell
rocketmq:
  config:
    namesrvAddrs:
      - 127.0.0.1:9876
```

- 启动项目运行即可
- 然后再浏览器中查看即可

```shell
http://localhost:8080/#/
```

