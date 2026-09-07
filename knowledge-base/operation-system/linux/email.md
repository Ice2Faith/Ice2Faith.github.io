# linux 发送邮件

---

## 安装

```shell script
yum install mailx -y
```
- 配置发送账号信息
```shell script
#未加密的发送方式通过25端口,会被公有云封掉.
cat >>/etc/mail.rc <<EOF
set from=xxx@163.com
set smtp=smtp.163.com
set smtp-auth-user=xxx@163.com
set smtp-auth-password=xxx123
set smtp-auth=login
EOF

#加密的方式465端口
cat >>/etc/mail.rc <<EOF
set nss-config-dir=/etc/pki/nssdb/          #加密方式配置
set smtp-user-starttls                      #加密方式配置
set ssl-verify=ignore                       #加密方式配置
set from=xxx@163.com                #配置发件人
set smtp=smtps://smtp.163.com:465            #配置使用163邮箱发送邮件，不加密方式参考上面
set smtp-auth-user=xxx@163.com      #邮箱名
set smtp-auth-password=xxx123             #授权码
set smtp-auth=login                         #认证形式
EOF
```
- 如果想要右键显示自定义发件人名称
- 则变更为如下配置
```shell script
# format
set from="发送邮箱账号(自定义名称)"

# example
set from="xxx@163.com(Server-Alarm)"
```
- 发送
```shell script
echo "内容" | mail -s [标题] [接受账号]
```
- 或者
```shell script
mail -s [标题] [接受账号] < [正文文件路径]
```

---

## 应用
- 常见的使用方式就是结合crontab做定时监控
- 进行服务或者服务器的监控与邮件报警操作
- 这里，准备了一些检测的脚本
```shell script
cd ./mailx
```
- 文件介绍
```shell script
# crontab的举例说明
crontab.sample
# 进行磁盘占用率监控
disk-chk-mail.sh
# 进行内存使用率监控
mem-chk-mail.sh
# 进行网络连通性监控
net-chk-mail.sh
# 进行进程存活性监控
ps-chk-mail.sh
# 进行套接字连接性监控
sock-chk-mail.sh
# 进行在线用户数监控
user-chk-mail.sh
```
- 使用方式
- 放到系统目录中
```shell script
cd /home/env/mailx
```
- 更改需要接受告警的邮箱地址
    - 找到此行
    - 根据格式，添加接受者邮箱地址即可
    - 修改完毕，报错
```shell script
for sendto in x123@qq.com x456@139.com;
```
- 编辑crontab
```shell script
crontab -e
```
- 保存crontab即可
