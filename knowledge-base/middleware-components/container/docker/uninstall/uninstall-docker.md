# docker 的卸载

- 查看docker
```shell script
systemctl status docker
```
- 停止docker
```shell script
systemctl stop docker
```
- 禁用docker服务
```shell script
systemctl disable docker
```
- 移除docker0网卡
```shell script
ip addr
```
- 下线docker0网卡
```shell script
ifconfig docker0 down
```
- 安装网络工具进行卸载网卡
```shell script
yum -y install bridge-utils
```
- 卸载网卡
```shell script
brctl delbr docker0
```
- 查看已安装的docker
```shell script
yum list installed | grep docker
```
- 查看安装docker
```shell script
rpm -qa | grep docker
```
- 删除相关安装
```shell script
yum -y remove xxx
```
- 如果主机只有一个docker安装
- 可以一键删除所有
```shell script
rpm -qa | grep docker | xargs yum -y remove
```
- 删除残留文件
    - 这是默认路径，如果有修改为其他路径
    - 自行删除
```shell script
ll /var/lib/docker/
```
- 删除文件
```shell script
rm -rf /var/lib/docker
```
- 完成卸载