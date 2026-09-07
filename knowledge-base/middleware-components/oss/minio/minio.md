# minio 入门

## 简介
- minio是一个支持分布式容灾校验的文件对象存储服务
- 是一个由go编写的原生应用

## 依赖环境
- 无

---
## 环境搭建
- 下载，这里省略
- 编写启动文件
    - 访问的用户名和密码在脚本中给出
```shell script
vi start.sh
```
```shell script
echo minio server starting...
# MINIO_ACCESS_KEY=root
# MINIO_SECRET_KEY=12315
chmod a+x ./minio
export MINIO_ROOT_USER=root
export MINIO_ROOT_PASSWORD=12315
nohup ./minio server ./minio-data --console-address ":9001" --address ":9000" 2>&1 > minio.log &
sleep 2
echo done.
```
- 编写停止脚本
```shell script
vi stop.sh
```
```shell script
PID=`ps -ef | grep -v grep | grep minio | awk '{print $2}'`
echo minio PID=$PID
kill -9 $PID
sleep 2
echo done.
```
- 编写重启脚本
```shell script
vi reboot.sh
```
```shell script
./stop.sh
./start.sh
```
- 添加权限
```shell script
chmod a+x *.sh
```

## 启动服务
```shell script
./start.sh
```

## 验证
- 在浏览器访问
```shell script
http://[IP]:9001
```


