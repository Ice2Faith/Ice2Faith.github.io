# gitlab-ce 入门

## 简介
- gitlab 是一个使用git的仓库管理工具
- 常常用于搭建私有仓库
- 使用上和GitHub类似

## 安装
- 需要centos7环境
- 需要至少4G内存，否则运行起来也是500报错页面

- 没有环境，可以看后面的使用docker构建centos7环境
- 添加清华源
```shell script
vi /etc/yum.repos.d/gitlat-ce.repo
```
```shell script
[gitlab-ce]
name=Gitlab CE Repository
baseurl=https://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7/
gpgcheck=0
enabled=1
```
- 刷新yum
```shell script
yum makecache
```
- 安装gitlab
```shell script
yum install -y gitlab-ce
```
- 修改外部访问地址
```shell script
vi /etc/gitlab/gitlab.rb
```
```shell script
external_url=http://...
```
- 重新配置
```shell script
gitlab-ctl reconfigure
```
- 重新启动
```shell script
gitlab-ctl restart
```
- 浏览器访问
    - 就是前面定义的外部访问地址
```shell script
http://...
```

## 服务管理
- 启动
```shell script
gitlab-ctl start
```
- 停止
```shell script
gitlab-ctl stop
```
- 重启
```shell script
gitlab-ctl restart
```
- 状态
```shell script
gitlab-ctl status
```

## docker构建centos7环境
```shell script
- 这里使用docker提供该环境
```shell script
docker pull centos:centos7
```
- 运行容器
- 容器内，将容器的8080端口
- 也就是配置的gitlab端口，映射出来作为外部端口9977
- 这里提前开通了9977到8080的端口映射，方便直接重新运行容器
```shell script
docker run -itd --name centos-7 -p 17022:22 -p 9977:8080  --privileged centos:centos7 /usr/sbin/init 
```
- 进入容器
```shell script
docker exec -it centos-7 /bin/bash
```
- 退出容器
```shell script
exit
```
- 查看运行的容器
```shell script
docker ps
```
- 如果停止了，需要重新运行容器
```shell script
docker run [容器ID]
```
- 还可以将刚才的容器提交为自己的镜像
```shell script
docker commit [容器ID] [镜像名]

docker commit 624 centos7-gitlab-8080
```
- 将自己的镜像导出保存
```shell script
docker save [镜像名] -o [文件名]

docker save centos7-gitlab-8080 -o ./centos7-gitlab-8080.dimg
```
- 将dimg发送给其他人即可
- 其他人加载该镜像即可
```shell script
docker load -i [文件名] 

docker load -i ./centos7-gitlab-8080.dimg
```