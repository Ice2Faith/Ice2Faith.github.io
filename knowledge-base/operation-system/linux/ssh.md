# ssh 免密登录
---

## 简介
- 其实也就是在目标主机的目标用户给定本机的授权key
- 这样就是认证了本机的登录
- 因此本机可以免密登录

## 配置
- 安装openssh
```shell script
yum install -y openssh
yum -y install openssh-clients
```
## 配置免密
- 免密登录
- 其实就是将自己的密码发送给别人
- 别人有了你的秘钥，就可以实现免密登录你的主机
- 因此，要实现免密，就需要得到对方的秘钥
- 双向免密就需要双方互换秘钥
### 生成RSA秘钥
- 本机创建RSA秘钥
```shell script
ssh-keygen -t rsa
```
- 一路回车即可，不要设置密码
- 否则免密登录时需要输入RSA的密码

### 方式一：自行拷贝
- 复制刚创建的秘钥公钥
```shell script
cat ~/.ssh/id_rsa.pub
```
- 在需要免密的目标机上编辑文件
```shell script
vi ~/.ssh/authorized_keys
```
- 将刚才复制的秘钥追加到后面
- 注意如果之前已经有内容了
- 需要先换行，起一个新行

### 方式二：使用命令
- 将自己的密码发送到指定的主机指定的用户
```shell script
ssh-copy-id 用户@主机
```
- 使用示例
```shell script
ssh-copy-id localhost
ssh-copy-id 192.168.0.10
ssh-copy-id root@192.168.0.11
```
- 如果出现使用不了ssh-copy-id的情况
- 可以使用以下语句替换
```shell script
cat ~/.ssh/id_*.pub|ssh 用户@主机 'cat >> .ssh/authorized_keys'
```
- 注意，如果ssh端口不是默认22
- 需要使用-p参数指定端口
```shell script
cat ~/.ssh/id_*.pub|ssh root@127.0.0.1 -p 2022 'cat >> .ssh/authorized_keys'
```
### 免密登录案例
- 以下操作，都使用 root 用户操作
- 其他用户，请带上用户操作，主要是ssh-copy-id时
- 主机列表
```shell script
cat /etc/hosts
```
```shell script
192.168.0.10 server-001 server-001
192.168.0.11 server-002 server-002
192.168.0.12 server-003 server-003
```
- 分别在三台主机，生成秘钥
- 一路直接回车即可
```shell script
ssh-keygen -t rsa
```
- 免密，可能需要自己登录自己的情况
- 也就是3台主机需要免密
- 分别在三台主机，复制秘钥到三台主机
```shell script
ssh-copy-id localhost
ssh-copy-id server-001
ssh-copy-id server-002
ssh-copy-id server-003
```
- 执行这四条命令
- 需要对应输入四台主机的登录密码
- 分别在三台主机，验证免密登录
```shell script
ssh localhost
ssh server-001
ssh server-002
ssh server-003
```
- 如果都不需要输入密码登录
- 那么三台主机之间的免密登录配置完毕
- 使用ssh登录主机之后，使用 exit 命令退出登录的主机
```shell script
exit
```


## 使用
- 远程复制
```shell script
scp [本机路径] [目标主机免密用户]@[远程主机]:[远程主机路径] 

scp /root/apps/app.jar root@192.168.1.100:/root/apps/
```

## 多台主机同步操作
### 同步文件
- 编写脚本
```shell script
vi xsync
```
- 写入如下内容
```shell script
#!/bin/bash 
#1 获取输入参数个数，如果没有参数，直接退出 
pcount=$#
if((pcount==0)); then
  echo no args;
  exit;
fi

#2 获取文件名称 
p1=$1
fname=`basename $p1`
echo fname=$fname

#3 获取上级目录到绝对路径
pdir=`cd -P $(dirname $p1); pwd`
echo pdir=$pdir

#4 获取当前用户名称
user=`whoami`

#5 循环
for host in server-001 server-002 server-003;
do
   echo ------------------- $host -------------------
   rsync -rvl $pdir/$fname $user@$host:$pdir
done
```
- 使用方式
```shell script
./xsync /root/readme.md
```
- 如果ssh不是默认22端口
- 更改下此语句即可
```shell script
rsync -rvl -e 'ssh -p 2022' $pdir/$fname $user@$host:$pdir
```
- 如果找不到命令，请安装
```shell script
yum install rsync -y
```

### 同时执行命令
- 编写脚本
```shell script
vi xcall
```
- 写入如下内容
```shell script
#!/bin/bash 

# 获取控制台指令

cmd=$*

# 判断指令是否为空
if [ ! -n "$cmd" ]
then
  echo "command can not be null !"
  exit
fi

# 获取当前登录用户
user=`whoami`

#5 循环
for host in server-001 server-002 server-003;
do
   echo ------------------- $host -------------------
   ssh $user@$host $cmd
done
```
- 使用方式
```shell script
./xcall free -h
```
- 如果ssh不是默认22端口
- 更改下此语句即可
```shell script
ssh -p 2022 $user@$host $cmd
```