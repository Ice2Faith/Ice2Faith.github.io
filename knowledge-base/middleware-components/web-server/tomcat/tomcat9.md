# tomcat 入门

## 简介
- tomcat是一个java的web应用服务器
- 用于提供java-web站点的构建

## 依赖环境
- java

---
## 环境搭建
- 下载
```shell script
wget https://mirror.bit.edu.cn/apache/tomcat/tomcat-9/v9.0.44/bin/apache-tomcat-9.0.44.tar.gz
```
- 解压:
```shell script
tar -zxvf apache-tomcat-9.0.44.tgz
```
- 更改配置文件
```shell script
cd apache-tomcat-9.0.44
```
- 为脚本增加执行权限
```shell script
chmod a+x ./bin/*.sh
```
- 编辑配置文件
```shell script
vi ./conf/server.xml
```
### 配置
- 其实没什么内容需要修改，这里给上一个启用8080端口的gzip为例
```shell script
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443"

           useSendfile="false"
           compression="on"
           compressionLevel="9"
           compressionMinSize="2048"
           noCompressionUserAgents="gozilla,traviata,MSIE 6.,MSIE 5.,MSIE 4.,MSIE 3."
           compressableMimeType="text/html,text/xml,text/plain,text/css,text/javascript,application/javascript,application/x-javascript,application/xml,image/jpeg,image/gif,image/png,image/svg+xml"
    />
```
- 注意，一开始的这个配置是用来关闭tomcat使用的
- 如果tomcat无法启动，可能是这里的被端口占用了
- 换一个端口即可
```shell script
<Server port="8005" shutdown="SHUTDOWN">
```
- 编写启动文件
```shell script
vi start.sh
```
```shell script
chmod a+x ./bin/*.sh
./bin/startup.sh
sleep 3
echo ---------------------------
tail -300f ./logs/catalina.out
```
- 编写停止脚本
```shell script
vi stop.sh
```
```shell script
chmod a+x ./bin/*.sh
./bin/shutdown.sh
sleep 3
echo stop down.
```
- 编写重启脚本
```shell script
vi reboot.sh
```
```shell script
./stop.sh
./start.sh
```

## 启动服务
```shell script
./start.sh
```

## 部署war包
- 上传war包
```shell script
app.war
```
- 将war包放到如下目录
```shell script
webapps/app.war
```
- 重启tomcat
- 浏览器访问
```shell script
http://[IP]:8080/app
```
- 使用配置方式
    - 修改 conf/server.xml
    - 同样需要重启tomcat
```shell script
<Context path="[context-path]" docBase="[项目相对webapps的路径或绝对路径]" reloadable="true" />

<Context path="" docBase="myproject" reloadable="true" />
```

## 部署静态web（vue）
- 上传dist.zip
- 将dist放到webapps/ROOT下面
```shell script
webapps/ROOT/dist.zip
```
- 解压dist.zip
```shell script
unzip dist.zip -d dist
```
- 检查dist目录是否是web文件
```shell script
dist
    index.html
    ...
```
- 静态文件，可以不用重启tomcat
- 浏览器访问
```shell script
http://[IP]:8080/dist
```


