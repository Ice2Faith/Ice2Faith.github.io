# linux 常用命令
---
## 重启无法启动
- 慎用命令
    - 可能导致主机无法启动
```shell script
yum update
```
- 这条命令会升级软件包
- 但是也会升级系统内核
- 因此，如果升级了系统内核，可能出现多个系统引导项
- 如果恰好，你的系统不支持新的系统内核或者出现兼容性问题
- 那么，在你重启系统之后
- 将会出现无法启动
- 因为，第一个启动项默认是新的这个系统内核
- 而这个系统内核又无法启动
- 导致系统无法启动
- 因此，为评估升级影响之前
- 禁止或谨慎使用 update
- 升级软件包，请使用
    - 它只升级软件包，不升级系统内核
```shell script
yum upgrade -y
```
---------------------------------------------------------------------------------------

---
- 常见的参数
```shell script
--help 查看命令的帮助
-r/-R 递归 recursive
-f 强制 force
-h 人类友好 human
\ 命令中进行换行
&& 前一个命令正常运行之后，再运行后一个命令
|| 前一个命令运行完，运行后一个命令
```

---
## 目录
- 列出目录
```shell script
-h 人类可读
-a 所有
-l 详细列表
-S 根据文件大小排序，最大在上
-t 根据最后修改排序，最后在上
```
```shell script
ls -alh
ls -al
ls -a
ll
```
- 自定义日期格式
```shell script
ls -alh --time-style="+%Y-%m-%d %H:%M:%S"
```
- 查询最后一个日志文件
```shell script
ls -at | head -n 1
```
- 查看最后一个日志文件
```shell script
tail -300f `ls -at | head -n 1`
tail -300f logs/`ls -at  logs | head -n 1`
```
- 创建目录
```shell script
mkdir [目录名称]
mkdir apps
```
- 切换目录
```shell script
cd [目录]
cd /root
cd apps

几个特殊的目录
. 当前目录
cd .
.. 上一级目录
cd ..
~ 用户的家目录
cd ~
- 用户上一次访问的目录
cd -
```
- 删除文件/目录
```shell script
rm [文件名]
rm hello.txt

-f 选项，强制删除，不需要确认
rm -f hello.txt

-r 选项，递归删除，用于删除目录
rm -r test

结合使用，删除任意文件/目录
注意，此命令，谨慎使用，否则删除错误，
将导致系统不可用，无法开机，
因此，不建议在 / 目录执行
建议使用时，使用相对路径 . 限定当前目录下
rm -rf ./test
```

---
## 文件
- 创建文件
```shell script
touch [文件名]
touch readme.txt

echo [文件内容] > [文件名]
echo "hello" > hello.txt
```
- 查看文件
```shell script
cat [文件名]
cat hello.txt
```
- 查看文件末尾
```shell script
tail -n [行数] [文件名]
tail -n 50 hello.txt

-f 自动刷新末尾，一般用来看日志
tail -f -n 300 app.log
tail -300f app.log
```
- 查看文件头部
```shell script
head -n [行数] [文件名]
head -n 50 hello.txt
```
- 编辑文件
```shell script
vi [文件名]
vi app.conf

编辑模式按 i/Insert 按键
此模式，编辑器下方会显示 --insert--

预览模式按 esc 按键
预览模式下 输入 :q 退出编辑，前提是没改过文件
预览模式下 输入 :q! 退出编辑，并不保存修改
预览模式下 输入 :wq 保存并退出
预览模式下 输入 / 开头，加上需要查找的内容，进行查找内容
/username
```

---
## 行规则编辑
- sed 是一个基于行扫描匹配编辑的工具
- 适用于脚本中修改指定的配置内容
- 而不用借助vi等工具导致的人工干预过程
- 命令格式
```shell script
sed [选项] [命令] [文件]

[选项] 可选值
    -e 脚本命令，将命令添加到已有命令中
    -f 脚本命令，将文件内容添加到已有命令中
    -n 屏蔽启动输出，需要使用print命令完成输出
    -i 直接修改源文件
```
- 行内替换命令
```shell script
替换一行中所有匹配项
s 替换命令
  [address]s/pattern/replacement/flags
  flags 标记
    n 第几次匹配才替换
    g 首次匹配替换
    p 打印匹配的行，一般结合n使用
    w 将内容写到指定文件
    & 用正则表达式配
    \n 匹配第n个子串
    \ 转义符号
```
```shell script
# 替换第一个匹配
sed 's/test/hello/1' test.txt
# 替换第一个匹配
sed 's/test/hello/g' test.txt
# 输出修改行
sed -n 's/test/hello/p' test.txt
# 路径转义
sed 's/\root/\home/g' test.txt
```
- 删除行
```shell script
# 删除第一行
sed '1d' test.txt

# 删除第二三行
sed '2,3d' test.txt

# 删除1-3行区间
sed '/1/,/3/d' test.txt

# 删除第2行到文件尾部
sed '2,$d' test.txt
```
- 添加行
```shell script
a 在行后面附加
i 在行前面附加

sed '1a\
hello' test.txt

sed '2i\
hello' test.txt
```
- 整行替换
```shell script
c 替换整行

sed '2c\
hello' test.txt
```
- 逐字符映射替换
```shell script
y 按字符转换

# 1-4 2-5 3-6
sed 'y/123/456/' test.txt
```
- 打印行
```shell script
p 打印内容

sed -n '/number 3/p' test.txt
```


---
## 进程
- 查询进程
```shell script
ps -ef
ps -ef | grep java
```
- 强制结束进程
```shell script
kill -9 [PID]
kill -9 555
```
- 进程资源占用
```shell script
top -c
```
- 内存占用
```shell script
free -m
free -h
```
- 不阻塞终端
```shell script
nohup [命令]
nohup java -jar app.jar
```
- 后台执行
```shell script
[命令] &
java -jar app.jar &
```
- 不阻塞后台执行
```shell script
nohup [命令] &
nohup java -jar app.jar &
```
- 标准错误stderr重定向到标准输出stdout
```shell script
2>&1
java -jar app.jar 2>&1
nohup java -jar app.jar 2>&1 &
```
- 输出控制台日志到文件中
```shell script
 > app.log
java -jar app.jar 2>&1 > app.log
nohup java -jar app.jar 2>&1 > app.log &
```
- 将后台启动的进程的PID输出到文件
    - 这种方式，将PID直接输出到文件中，方便存在同名文件时，ps -ef | grep 时出现多个结果，导致进程kill -9误杀
```shell script
echo $! > app.pid
nohup java -jar app.jar 2>&1 > app.log & echo $! > app.pid
```
- 不需要任何日志输出
    - 也就是将日志输出。指向linux的黑洞文件
```shell script
> /dev/null
java -jar app.jar 2>&1 > /dev/null
nohup java -jar app.jar 2>&1 > /dev/null &
```

---
## 查找
- 查找文件
```shell script
find [目录] -name [名称]
find / -name mysql
find /usr -name redis
```
- 查找文件
```shell script
whereis [名称]
whereis mysql
```

---
## 过滤结果
- 排除
```shell script
grep -v [关键字]
grep -v grep
```
- 包含
```shell script
grep  [关键字]
grep java
```
- 忽略大小写
```shell script
grep -i [关键字]
grep -i exception
```
- 显示行号
```shell script
grep -n
```
- 后续N行
```shell script
grep -A [行数]
grep -A 50
```
- 查询异常日志
```shell script
grep -inA 50 exception
tail -300f app.log | grep -inA 50 exception
```
- 分隔输出
```shell script
awk -F [分隔符] [操作]
awk '{print $2}'
awk -F ":" '{print $2}'
```
- 获取目标名称进程PID号
```shell script
ps -ef | grep -v grep | grep [进程名称] | awk '{print $2}'
ps -ef | grep -v grep | grep app.jar | awk '{print $2}'
```

---
## 网络
- 显示端口占用
```shell script
netstat -ano
```
- 查询占用端口状态
```shell script
netstat -lnp | grep [端口]
netstat -lnp | grep 3306
```
- 查询占用端口的进程
```shell script
netstat -lnp | grep [端口] | awk '{print $7}'
netstat -lnp | grep 3306 | awk '{print $7}'
```
- 查询占用端口的PID
```shell script
netstat -lnp | grep [端口] | awk '{print $7}' | awk -F "/" '{print $1}'
netstat -lnp | grep 3306 | awk '{print $7}' | awk -F "/" '{print $1}'
```
- 查询占用端口的进程信息
```shell script
ps -ef | grep -v grep | grep `netstat -lnp | grep [端口] | awk '{print $7}' | awk -F "/" '{print $1}'`
ps -ef | grep -v grep | grep `netstat -lnp | grep 3306 | awk '{print $7}' | awk -F "/" '{print $1}'`
```
- 判断目标网络端口是否开启
```shell script
telnet [IP] [端口]
telnet 192.168.1.123 8080
telnet www.baidu.com 80

# 其他可选的方案，适用于linux没有安装telnet时使用
nc -vz 192.168.1.123 8080
curl -I 192.168.1.123:8080
wget -q --spider 192.168.1.123:8080

# 下面这种只适用于TCP通信
echo > /dev/tcp/192.168.1.123/8080
```
- 获取本机IP地址
```shell script
ifconfig -a
```
- 检查目标网络连通性
```shell script
ping [IP]
ping 114.114.114.114
ping www.baidu.com
```
- 检查到达目标网络的路由
```shell script
yum install -y  traceroute
traceroute [IP]
traceroute www.baidu.com
```
- 接口可用性调试
```shell script
curl [选项] [地址]
[选项]
-X 指定http请求方式 GET POST PUT DELETE
-H 指定请求头，需要用引号包起来
-d 指定请求参数，也就是请求体，需要用引号包起来
-O 指定响应输出到文件
```
- GET 请求
```shell script
curl www.baidu.com
curl http://www.baidu.com
curl http://www.baidu.com/s?wd=hello
```
- FORM表单请求
```shell script
curl -X POST -d 'username=admin&age=23' http://localhost:8080/api/form
```
- JSON请求
```shell script
curl -X POST -H "content-type: application/json" -d '{"username":"admin","age":23}' http://localhost:8080/api/json
```
- 下载文件
```shell script
curl -o ./baidu-index.html http://www.baidu.com
```

## 服务
- 查看状态
```shell script
systemctl status [服务名]
```
- 停止
```shell script
systemctl stop [服务名]
```
- 启动
```shell script
systemctl start [服务名]
```
- 重启
```shell script
systemctl restart [服务名]
```
- 开机启动
```shell script
systemctl enable [服务名]
```
- 开机不启动
```shell script
systemctl disable [服务名]
```

## 防火墙 firewalld
- 查看防火墙状态
```shell script
systemctl status firewalld
```
- 停止防火墙
```shell script
systemctl stop firewalld
```
- 启动防火墙
```shell script
systemctl start firewalld
```
- 重启防火墙
```shell script
systemctl restart firewalld
```
- 开机启动
```shell script
systemctl enable firewalld
```
- 开机不启动
```shell script
systemctl disable firewalld
```
- 基本语法
```shell script
firewall-cmd [选项1] [选项2] [...N]
```
- 查看默认区域
```shell script
firewall-cmd --get-default-zone
```
- 查看支持的区域
```shell script
firewall-cmd --get-zones
```
- 查看规则列表
```shell script
firewall-cmd --list-all
```
- 查看所有区域的规则列表
```shell script
firewall-cmd --list-all-zones
```
- 重载配置
```shell script
firewall-cmd --reload
```
- 将服务允许通过
```shell script
firewall-cmd --zone=public --add-service=[服务的名称]

firewall-cmd --zone=public --add-service=http

--premanent 指定永久模式
需要配合重载配置使用

firewall-cmd --zone=public --add-service=http --premanent
firewall-cmd --reload
```
- 将端口允许通过
```shell script
firewall-cmd --zone=public --add-port=端口号/tcp

firewall-cmd --zone=public --add-port=80/tcp

--premanent 指定永久模式
需要配合重载配置使用

firewall-cmd --zone=public --add-port=80/tcp --premanent
firewall-cmd --reload
```

- 案例
- 开放 8080 端口号

```shell
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --reload
```

- 关闭 8080 端口

```shell
firewall-cmd --zone=public --remove-port=8080/tcp --permanent
firewall-cmd --reload
```

- 只允许指定网段访问 8080 端口

```shell
# 删除所有来源
firewall-cmd --zone=public --remove-port=8080/tcp --permanent

# 仅允许指定网段，富规则，优先级比普通规则高
firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" port protocol="tcp" port="8080" accept' --permanent

firewall-cmd --reload
```

- 只限制指定网段访问 8080 端口

```shell
# 一般还要添加普通规则允许其他网段访问
firewall-cmd --zone=public --remove-port=8080/tcp --permanent

firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.2.0/24" port protocol="tcp" port="8080" reject' --permanent

firewall-cmd --reload
```


---
## 防火墙 iptables
- iptables 是一个包过滤防火墙
- 使用前可能需要关闭 firewalld
- 并且安装iptables
```shell script
systemctl stop firewalld
systemctl disable firewalld
yum install iptables
```
- 具备四种类型的过滤表：
    - filter(默认过滤表)
    - nat(地址转换表)
    - mangle(报文标志修改表)
    - raw(跟踪数据表)
- 语法格式
```shell script
iptables -t [转换表] [命令] [链表] [参数] -j [动作]

-t [转换表] 可以省略，默认为 filter
[转换表] 可选值
    filter
    nat
    mangle
    raw
[命令] 可选值
    -A 添加规则
    -D 删除规则
    -I 插入规则
    -F 清空规则
    -L 列出规则
    -R 替换规则
    -Z 清空统计信息
    -P 设置默认规则
[参数] 可选值
    前面加上!表示取反
    -p 匹配协议 tcp udp icmp all
    !-p 不匹配协议
    -s 匹配源地址
    -d 匹配目标地址
    -i 匹配入站网卡接口 eth0
    -o 匹配出站网卡接口
    --sport 匹配源端口
    --dport 匹配目标端口
    --src-range 匹配源地址范围,连续地址，格式：192.168.1.1-192.168.1.100
    --dst-range 匹配目标地址范围
    --limit 匹配数据表速率
    --mac-source 匹配源MAC地址
    --sports 匹配源端口,连读端口，格式：20:80
    --dports 匹配目标端口
    --stste 匹配状态（INVALID/ESTABLISHED/NEW/RELATED）
    --string 匹配应用层字符串
[动作] 可选值
    ACCEPT 允许通过
    DROP 丢弃
    REJECT 拒绝通过
    LOG 记录到syslog日志
    DNAT 目标地址转换
    SNAT 源地址转换
    MASQUERADE 地址欺骗
    REDIRECT 重定向
```
- 查看规则表
```shell script
iptables -nvL
iptables -nvL --line-number

-L 查看列表
-n 不对IP地址反查
-v 输出详细信息
--line-number 显示行号
-t 有需要可以加上-t查看具体的表，默认filter表
```
- 添加规则
```shell script
# 丢弃来自192.168.1.4的数据包
iptables -A INPUT -s 192.168.1.4 -j DROP

iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
```
- 修改规则
```shell script
# 需要用到行号,假设查询出来是2
iptables -R INPUT 2 -s 192.168.1.4 -j ACCEPT
```
- 删除规则
```shell script
iptables -D INPUT 2
iptables -D INPUT 2 -s 192.168.1.4 -j ACCEPT
```
- 保存配置
```shell script
service iptables save
```
- 备份规则
```shell script
iptables-save > [文件]

iptables-save > /etc/sysconfig/iptables
```
- 恢复规则
```shell script
iptables-restore < [文件]

iptables-restore < /etc/sysconfig/iptables
```

- 案例
- 开放 8080 端口号

```shell
iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
service iptables save
```

- 关闭 8080 端口

```shell
iptables -D INPUT -p tcp --dport 8080 -j ACCEPT
service iptables save
```

- 只允许指定网段访问 8080 端口

```shell
# 删除所有来源
iptables -D INPUT -p tcp --dport 8080 -j ACCEPT

# 仅允许指定网段，富规则，优先级比普通规则高
iptables -A INPUT -p tcp --dport 8080 -s 192.168.1.0/24 -j ACCEPT

# 补充默认拒绝策略
iptables -A INPUT -p tcp --dport 8080 -j REJECT

service iptables save
```

- 只限制指定网段访问 8080 端口

```shell
iptables -I INPUT -p tcp --dport 8080 -s 192.168.2.0/24 -j REJECT

service iptables save
```

---
## 磁盘
- 查看磁盘挂载
```shell script
df -h
```
- 查看所有，包含特殊设备
```shell script
df -aT
```
- 查询某个路径的磁盘
```shell script
df -h [路径]

df -h /etc
```
- 查看目录大小
```shell script
du -sh [目录]
du -sh
du -sh /usr
```
- 列出所有分区
```shell script
fdisk -l
```
- 磁盘格式化
```shell script
mkfs -t [文件系统格式] [装置名]

mkfs /root/swapfile
mkfs -t ext3 /root/sddisk

查看支持校验的文件系统格式
mkfs[tab][tab]
```
- 磁盘检验
```shell script
fsck -Cf -t [文件系统格式] [装置名]

fsck -Cf -t ext3 /dev/hdc2

查看支持校验的文件系统格式
fsck[tab][tab]
```
- 磁盘挂载
```shell script
mount -t [文件系统格式] [装置名] [挂载点]

mount /mnt/hdc2 /root/disk2
mount -t ext3 /mnt/hdc3 /root/disk3
```
- 磁盘卸载
```shell script
unmount -df [挂载点]

unmount -df /mnt/hdc2
unmount -df /root/disk3
```

## 新磁盘初始化及挂载
- 查看所有磁盘
```shell script
lsblk
```
- 得到如下结果
    - 可以看到多了一个设备 vdb
    - 没有任何分区
```shell script
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINTS
vda    253:0    0  40G  0 disk 
└─vda1 253:1    0  40G  0 part /
vdb    253:16   0   1T  0 disk 
```
- 分区及类型设置
```shell script
fdisk /dev/vdb
```
- 按照顺序输入完成
    - 注意，下方内容有添加注释部分，实际输出不会有
```shell script
Welcome to fdisk (util-linux 2.37.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x306c6efa.

Command (m for help): n # 输入n选择命令
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p # 输入p进行分区操作
Partition number (1-4, default 1): 1 # 输入1选择第一个分区
First sector (2048-2147483647, default 2048):  # 直接回车，使用默认设置
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-2147483647, default 2147483647): # 直接回车，使用默认设置

Created a new partition 1 of type 'Linux' and of size 1024 GiB.

Command (m for help): t # 输入t指定类型
Selected partition 1
Hex code or alias (type L to list all): 83 # 输入83指定为linux类型
Changed type of partition 'Linux' to 'Linux'.

Command (m for help): w # 输入w保存操作
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```
- 重新查看磁盘情况
```shell script
fdisk -l
```
- 得到如下结果
    - 可以看到在vdb磁盘下面多个一个设备 /dev/vdb1
```shell script
Disk /dev/vda: 40 GiB, 42949672960 bytes, 83886080 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x74ef0e45

Device     Boot Start      End  Sectors Size Id Type
/dev/vda1  *     2048 83886079 83884032  40G 83 Linux


Disk /dev/vdb: 1 TiB, 1099511627776 bytes, 2147483648 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x306c6efa

Device     Boot Start        End    Sectors  Size Id Type
/dev/vdb1        2048 2147483647 2147481600 1024G 83 Linux
[root@ecs-6f86 ~]# mkfs -t ext4 /dev/vdb1
mke2fs 1.46.4 (18-Aug-2021)
Creating filesystem with 268435200 4k blocks and 67108864 inodes
Filesystem UUID: 1508277e-1fc9-4160-98e1-92daef1e7040
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968, 
        102400000, 214990848

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (262144 blocks): done
Writing superblocks and filesystem accounting information: done  
```
- 格式化磁盘
```shell script
mkfs -t ext4 /dev/vdb1
```
- 得到如下结果
```shell script
mke2fs 1.46.4 (18-Aug-2021)
Creating filesystem with 268435200 4k blocks and 67108864 inodes
Filesystem UUID: 1508277e-1fc9-4160-98e1-92daef1e7040
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
        4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968, 
        102400000, 214990848

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (262144 blocks): done
Writing superblocks and filesystem accounting information: done   
```
- 创建目标挂载路径
```shell script
mkdir -p /opt/disk
```
- 挂载磁盘到目录
```shell script
mount /dev/vdb1 /opt/disk
```
- 查看磁盘挂载
```shell script
df -h
```
- 得到如下结果
    - 可以看到设备已经挂载到 /opt/disk
```shell script
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        4.0M     0  4.0M   0% /dev
tmpfs            16G     0   16G   0% /dev/shm
tmpfs            16G   17M   16G   1% /run
tmpfs           4.0M     0  4.0M   0% /sys/fs/cgroup
/dev/vda1        40G   16G   22G  42% /
tmpfs            16G   58M   16G   1% /tmp
/dev/vdb1      1007G   28K  956G   1% /opt/disk
```
- 建立开机自动挂载
    - 含义：
    - 将设备 /dev/vdb1 挂载到 /opt/disk
    - 格式是ext4
    - 使用默认配置defaults
    - 不进行备份0（0不开启，1开启）
    - 开启磁盘检查2（0不开启，1最高优先级开启，2普通开启）
```shell script
echo '/dev/vdb1 /opt/disk ext4 defaults 0 2' >> /etc/fstab
```

---
## 归档
- tar解包(.tar)
```shell script
tar -xvf [tar包名]
tar -xvf app.tar
```
- tar解包指定路径
```shell script
tar -xvf [tar包名] -C [路径]
tar -xvf app.tar -C app-unpack
```
- tar打包
```shell script
tar -cvf [tar包名] [文件列表]
tar -cvf app.tar app-unpack
tar -cvf app.tar com mapper
```
- tgz解包(.tar.gz/.tgz)
```shell script
tar -zxvf [tgz包名]
tar -zxvf app.tar.gz
tar -zxvf app.tgz -C app-unpack
```
- tgz打包
```shell script
tar -zcvf [tgz包名] [文件列表]
tar -zcvf app.tgz app-unpack
tar -zcvf app.tgz com mapper
```
- zip解包
```shell script
unzip [zip包名]
unzip app.zip
```
- zip解包到指定路径
```shell script
unzip [zip包名] -d [目录]
unzip app.zip -d app
```
- zip打包
```shell script
zip [zip包名] [文件列表]
zip app.zip app
zip app.zip com mapper
```

- xz格式压缩

```shell script
xz -z [...文件名列表]
xz -z app.log
```
- xz格式解压
```shell script
xz -d app.xz
```
- 结合tar时，逐步解包
```shell script
xz -d app.tar.xz
tar -xvf app.tar
```
- 也可以一键解包
```shell script
tar xvJf app.tart.xz
```

---
## 权限
- 更改权限
```shell script
chmod == change modifier
a+rwx
a 所有人
rwx 读写执行权限
```
```shell script
chmod [权限描述] [目标文件]
chmod 744 app.jar
chmod a+rx app.jar
chmod +rx app.jar
```
- 递归修改
```shell script
chmod -R a+rx /app
```
- 更改所有者
```shell script
chown == change owner
```
```shell script
chown [用户]:[组] 目标文件
chown root:root app.jar
```
- 递归修改
```shell script
chown -R root:root /app
```


## 环境变量
- 配置环境变量
- 以JAVA_HOME为例
- 环境变量，在linux配置中
```shell script
cat /etc/profile
```
- 但是此配置文件，涉及到系统初始化
- 不建议直接修改此文件
- 一般是建议在此目录下建立初始化脚本形式
```shell script
mkdir /etc/profile.d
```
- 建立java的初始化文件
```shell script
vi /etc/profile.d/java.sh
```
- 添加环境配置
```shell script
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.131-11.b12.el7.x86_64
export PATH=$JAVA_HOME/bin:$PATH

export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
```
- 保存修改即可
- 重新应用配置
```shell script
source /etc/profile
```
- 当然，你也可以直接操作系统配置文件
- 如果确认没问题的话
- [解释]为什么能建立profile.d下面任意脚本
```shell script
for i in /etc/profile.d/*.sh ; do
    if [ -r "$i" ]; then
        if [ "${-#*i}" != "$-" ]; then 
            . "$i"
        else
            . "$i" >/dev/null
        fi
    fi
done
```
- 这是profile文件中的一段脚本
- 可以看到，此脚本扫描了profile.d下面的所有sh脚本进行执行
- 因此可以这样做


## 用户
- 查看所有用户
```shell script
cat /etc/passwd | cut -d : -f 1
```
- 用户信息都存放在这个文件中
```shell script
cat /etc/passwd
```
```shell script
每一行格式
按照:分隔
分别为
用户名:密码:UID(用户ID):GID(组ID):描述:主目录:默认shell

root:x:0:0:root:/root:/bin/bash
ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
```
- 添加用户
```shell script
useradd [用户名]

useradd ftp

-d 参数指定home目录
-G 参数指定用户组
-c 参数指定注释信息
useradd ftp -d /var/ftp/pub -G ftp -c FTP
```
- 设置用户密码
```shell script
passwd [用户名]

passwd ftp
# 这里输入密码
```
- 切换用户
```shell script
su [用户名]

su ftp
```
- 删除用户
```shell script
userdel [用户名]

userdel ftp

--remove 选项，附加删除用户的home目录

userdel --remove ftp
```
- 查看用户是否登录
```shell script
who
```
- 查看账号是否被锁定
     - 也就是账号后，是否有 !! 在密码之前
```shell script
sudo awk -F: '/[用户名]/ {print $1,$2}' /etc/shadow

sudo awk -F: '/ftp/ {print $1,$2}' /etc/shadow
```
- 锁定账号
```shell script
sudo passwd -l [用户名]

sudo passwd -l ftp
```
- 杀死用户进程
```shell script
sudo pkill -KILL -u [用户名]

sudo pkill -KILL -u ftp
```

- 为用户添加组

```shell
usermod -aG [用户组] [用户名]

usermod -aG docker app
```

- 添加软连接

```shell
ln -sf [源路径] [目标路径]
ln -sf /home/web/apps /opt/apps
```

## 组
- 添加组
```shell script
groupadd [组名]

groupadd test
```
- 删除组
```shell script
groupdel [组名]

groupdel test
```
- 修改组
```shell script
groupmod -n [旧组名] [新组名]

groupmod -n test dev
```

## 杂项
- 修改主机名
```shell script
vim /etc/hostname
```
- 编辑host文件
```shell script
vim /etc/hosts
```
```shell script
192.168.131.100	master
192.168.131.101	slave
```
- 查看CPU
```shell script
lscpu
```
- 查看内存
```shell script
lsmem
```
- 查看登录用户
```shell script
lslogins
```
- 查看块设备
```shell script
lsblk
```
- 查看USB
```shell script
lsusb
```
- 查看版本
```shell script
cat /proc/version
```
- 查看CPU信息
```shell script
cat /proc/cpuinfo
```
- 查看内存信息
```shell script
cat /proc/meminfo
```
- 查看虚拟内存
```shell script
cat /proc/swaps
```
- 时间同步
```shell script
yum -y install ntp
systemctl enable ntpd
systemctl start ntpd
timedatectl set-ntp yes
ntpdate -u cn.pool.ntp.org
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime   
watch -n 1 'date`
```

- 设置系统时间

```shell
date -s "2024-11-20 16:28:21"
```
- 性能查看
```shell script
sar
top
iostat
vmstat
perf

yum install -y perf
```
- 查看CPU型号和主频
```shell script
cat /proc/cpuinfo | grep name | cut -f2 -d:
```
- 查看PID的执行文件路径
```shell script
lsof -p ${pid} | grep cmd
```

- 编辑DNS主机

```shell
vi /etc/resolv.conf
```

```shell
nameserver 114.114.114.114
nameserver 8.8.8.8
nameserver 8.8.4.4
```

## too many open files (打开的文件数过多)
- 检查打开文件数限制
```shell script
ulimit -a
```
- 查看open files 项的值
- 检查指定进程打开的文件数
```shell script
lsof -p ${pid} | wc -l
```
- 临时修改最大文件数
- 非root用户只能4096，root用户可以65535
- 这种修改方式，主机重启就失效了
```shell script
ulimit -n 4096
```
- 永久修改最大文件数
- 编辑文件，末尾添加
```shell script
vi /etc/security/limits.conf
```
```shell script
# 在最后加入
* soft nofile 65535
* hard nofile 65535
```
- 同时，为了使得当前运行的生效
- 也是用临时修改方式修改一下
- 重新查看文件限制即可

## 性能监控
- 推荐工具安装(iostat,vmstat)
```shell script
yum -y install sysstat
```
- 查看磁盘IO情况
```shell script
iostat -dmx 1
```
- 查看CPU情况
```shell script
top -c
按键：1 t t H m m
```
- 总览
```shell script
vmstat -t -a 1 5
```
- 磁盘总览
```shell script
vmstat -d
```
- 查看磁盘IO情况
```shell script
sar -u
```
- 性能工具
```shell script
yum -y install perf
```
- 统计运行情况
	- 一段事件之后Ctrl+C终止即可出结果
```shell script
perf stat
```
- 统计指定PID的运行情况
```shell script
perf stat -p [PID]
```
- 实时性能监控
```shell script
perf top -g
```
- 组合监控报表
```shell script
perf record -F 99 -a -g -- sleep 60
perf report -n
perf report -n --stdio
```
- 磁盘读写速度
```shell script
# 写入速度（使用dd命令，测试到/opt/test这个路径所在磁盘的写入速度）
time dd if=/dev/zero of=/opt/test/test.dbf bs=8k count=300000

# 读取速度（使用dd命令，测试从/opt/test这个路径所在磁盘的读取速度）
time dd if=/opt/test/test.dbf bs=8k count=300000 of=/dev/null
```
- iostat与df等命令的对应关系
```shell script
ll /dev/mapper/
```

## 定时任务
- crontab
- 是linux中以cron管理的定时调度
- 在运维中，可以是用来做进程的存活性检测
- 配合mail等命令，时间进程死亡检测与邮件告警
- 查看crond服务的状态
```shell script
systemctl status crond
```
- 没有启动则启动
```shell script
systemctl start crond
```
- 编辑crontab
```shell script
crontab -e
```
- 编辑自己的定时任务
- 一般就是写一个脚本
```shell script
*/10 * * * * /home/env/mailx/ps-chk-mail.sh nginx nginx
```
- 一行就是一个定时任务
- 格式如下
```shell script
[cron] [command]
```
- 注意cron中，分别是：分 时 日 月 星期
- 因此，示例中给出的就是，每10分钟执行后面的命令
- 这个脚本的作用，就是检查指定的进程是否存活，不存活则发送邮件通知
- 关于使用到的mail命令，查看 email.md
- 下面给出这个脚本
```shell script
#!/bin/bash

PsName=$1
AppName=$2
ServerName=`hostname`

ThisName=`basename $0`
TimeNow=$(date "+%Y-%m-%d %H:%M:%S")

echo $PsName for $AppName on $ServerName checking...

PID=`ps -ef | grep -v grep| grep -v $ThisName | grep $PsName | awk '{print $2}'`

if [[ -n "$PID" ]]; then
      echo -e "\033[0;31m $PsName  process has running ... \033[0m"
      exit 0
fi

PsResult=`ps -ef | grep -v grep| grep -v $ThisName | grep $PsName`
TopResult=`top -c -b -n 1 | head -n 12`
FreeResult=`free -h`
DfResult=`df -h`
IostatResult=`iostat -dmx`
PingResult=`ping www.baidu.com -c 3`
WhoResult=`who -ablu`
WResult=`w -ui`

# send email
for sendto in user1@163.com user2@139.com user3@qq.com;
do
   echo ------------------- send alarm email to $sendto -------------------
   echo -e "\
your application [$AppName] on [$ServerName] has died at $TimeNow, witch ps-grep called [$PsName], please check it!

ps output is:
------------------------------------------------------------------
$PsResult

top output is:
------------------------------------------------------------------
$TopResult

free output is:
------------------------------------------------------------------
$FreeResult

df output is:
------------------------------------------------------------------
$DfResult

iostat output is:
------------------------------------------------------------------
$IostatResult

ping output is:
------------------------------------------------------------------
$PingResult

who output is:
------------------------------------------------------------------
$WhoResult

w output is:
------------------------------------------------------------------
$WResult
" | mail -s "[Alarm] host [$ServerName] app [$AppName] process died" $sendto
done
```

## 安装字体
- 在Linux中，通常只有拉丁字体
- 没有中文字体和特殊符号字体
- 因此在Linux中使用GDI进行显示文字
- 加水印/转换文档为PDF等包含字体的操作时
- 通常字体转换失败，都是空白格或者乱码
- 因此，就需要安装字体
- 这些字体，通常在我们的Windows系统中就有
- 因此，直接将我们系统中的字体文件拷贝到服务器上
- 安装字体即可
- Windows字体路径
```bash
C:\Windows\Fonts
```
- 可以只复制中文的
- 也可以全部复制这些文件
- 复制出来之后压缩为一个压缩包
```bash
fonts.zip
```
- 大概几百M的样子
- 上传到服务器
- 以下操作均需要root权限
- 进入服务器字体路径
```shell script
cd /usr/share/fonts
```
- 新建中文字体路径
```shell script
mkdir chinese
```
- 将字体解压到该目录
```shell script
unzip fonts.zip -d chinese
```
- 进入目录
- 此时应该要看到一些以ttf为后缀的文件才对
```shell script
cd  chinese
```
- 建立字体并立即刷新应用
```shell script
mkfontscale
mkfontdir
fc-cache -fv
```
- 至此，安装已经完毕
- 查看安装字体列表
```shell script
fc-list
```
- 如果此命令未找到
```shell script
yum install -y fontconfig
```

## 安装阿里国内yum镜像源
- 进入yum源路径
```shell script
cd /etc/yum.repos.d/
```
- 下载阿里源
```shell script
wget http://mirrors.aliyun.com/repo/Centos-7.repo
```
- 备份原始源
```shell script
mv CentOS-Base.repo CentOS-Base.repo.backup
```
- 替换为阿里源
```shell script
mv Centos-7.repo CentOS-Base.repo
```

- [可选]追加部分仓库配置

```shell
vi CentOS-Base.repo
```

```shell
[centos-sclo-rh]
name=CentOS-7 - SCLo rh
baseurl=http://vault.centos.org/centos/7/sclo/$basearch/rh/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo
 
[centos-sclo-sclo]
name=CentOS-6.10 - SCLo sclo
baseurl=http://vault.centos.org/centos/7/sclo/$basearch/sclo/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo
```
- 清理源
```shell script
yum clean all
```
- 创建源
```shell script
yum makecache
```
- 更新源
  - 如非必要，请不要执行此行内容
  - 否则可能导致底层软件包/内核更新后与现有软件不兼容
```shell script
yum upgrade -y
```

## 编写服务-开机启动
- 创建服务文件
```shell script
vi /etc/systemd/system/my-boot.service
```
- 编写服务内容
```shell script
[Unit]
Description=/etc/my-boot.sh
ConditionPathExists=/etc/my-boot.sh

[Service]
Type=forking
ExecStart=/etc/my-boot.sh start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99

[Install]
WantedBy=multi-user.target
```
- 注意几个点
    - ExecStart 要执行的程序或者命令或者脚本
    - ConditionPathExists 判断条件，这里要求这个文件要存在
- 编写启动脚本内容
```shell script
vi /etc/my-boot.sh
```
- 编写内容
    - 因为我们只是需要尝试启动我们的应用
    - 因此nohup即可
```shell script
#!/bin/sh -e

# here add your boot shell, such as
# sh /root/boot.sh

nohup sh /root/start.sh > /dev/null &


exit 0
```
- 这个只是为了使用nohup
    - 因此中间的一个shell脚本
- 编写最终的启动脚本
```shell script
vi /root/start.sh
```
- 启动内容
```shell script
sleep 5

ENV_PATH=/root/env

cd $ENV_PATH
cd kafka_2.12-3.3.1
nohup ./start.sh > /dev/null  &
```
- 特别注意
    - 因为这是系统启动
    - 因此，最好建议先cd到目标应用所在路径
    - 否则应用的路径不对，可能无法启动
- 开启服务
```shell script
systemctl enable my-boot.service
```
- 其实就和正常服务一样使用即可
- 其他服务管理就不再赘述

## yum 离线安装
- 找一台同构的联网的机器
- 也就是操作系统相同（都是centos），系统版本相差不大，处理器架构相同（都是x86）
- 安装包下载工具
```shell script
yum install yum-utils
```
- 创建下载目录
```shell script
mkdir yum-packages
```
- 下载需要安装的包
- 下面这些是基础包，一般都会用到
- 包含gcc,pcre,ssh,mailx,rsync,unzip等常用工具集
```shell script
yumdownloader --resolve --destdir=yum-packages mpfr libmpc kernel-headers glibc-headers glibc-devel cpp gcc
yumdownloader --resolve --destdir=yum-packages autogen-libopts cpp gcc gcc-g++ glibc-devel glibc-headers kernel-headers keyutils-libs-devel
yumdownloader --resolve --destdir=yum-packages krb5-devel libcom_err-devel libmpc libselinux-devel libsepol-devel libstdc++-devel libverto-devel
yumdownloader --resolve --destdir=yum-packages mpfr ntp ntpdate openssl openssl098e openssl-devel openssl-libs pkgconfig tcl zlib zlib-devel
yumdownloader --resolve --destdir=yum-packages gcc gcc-c++ autoconf automake make pcre pcre-devel zlib zlib-devel openssl-devel openssh openssh-clients mailx rsync
yumdownloader --resolve --destdir=yum-packages tar unzip openssl-devel bzip2-devel expat-devel gdbm-devel readline-devel sqlite-devel psmisc libffi-devel
yumdownloader --resolve --destdir=yum-packages openssl-devel bzip2-devel expat-devel gdbm-devel readline-devel sqlite-devel psmisc libffi-devel zlib* libffi-devel
yumdownloader --resolve --destdir=yum-packages traceroute ntp perf sysstat fontconfig
```
- 打包下载目录
```shell script
tar -czvf yum-packages.tar.gz yum-packages
```
- 复制到没有网络的主机
- 解包
```shell script
tar -xzvf yum-packages.tar.gz
```
- 进入目录
```shell script
cd yum-packages
```
- 执行安装
```shell script
rpm -Uvh --force --nodeps *.rpm
```
- 安装完毕
- 可以删除目录了
