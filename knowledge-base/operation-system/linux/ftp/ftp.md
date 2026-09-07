# ftp(vsftpd) 环境安装

## 简介
- 服务器的安装部署，尝尝会用到ftp工具
- 因此，vsftpd基本上是每个linux服务器都需要的服务

## 依赖环境
- 无

## 安装
- 安装
```shell script
yum install -y vsftpd
```
- 设置自启动
```shell script
systemctl enable vsftpd.service
```
- 启动服务
```shell script
systemctl start vsftpd.service
```
- 添加ftp用户
```shell script
adduser ftp
passwd ftp
# 此处输入密码 xxx123456

mkdir /var/ftp/pub/
chown -R ftp:ftp /var/ftp/pub/
```
- 为ftp提供写权限
```shell script
chmod o+w /var/ftp/pub/
```
- 查看运行
```shell script
netstat -antup | grep ftp
```
- 配置ftp
```shell script
vi /etc/vsftpd/vsftpd.conf
```
- 新增或修改以下配置
```shell script
local_root=/root
chroot_local_user=YES
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd/chroot_list
allow_writeable_chroot=YES
pasv_enable=YES
pasv_address=0.0.0.0
pasv_min_port=40000
pasv_max_port=65535

listen=YES

#listen_ipv6=YES

anon_upload_enable=YES

anonymous_enable=NO

write_enable=YES

pam_service_name=vsftpd
userlist_enable=YES
```
- 解决root不能连接问题
    - 注释掉其中的root即可
```shell script
vi /etc/vsftpd/ftpusers
vi /etc/vsftpd/user_list
```
- 重新加载配置
```shell script
systemctl restart vsftpd.service
```
- 服务器需要开放的端口
```shell script
入端口：20,21
出端口：20000-65535
```
- 测试
```shell script
远程ftp连接测试即可
```