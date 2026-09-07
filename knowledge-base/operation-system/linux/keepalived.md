## 安装 keepalived
- 安装依赖环境
```shell script
yum install gcc-c++
yum install openssl-devel
yum -y install libnl libnl-devel
```
- 下载nginx
```shell script
echo https://www.keepalived.org/download.html
wget -c https://www.keepalived.org/software/keepalived-2.0.18.tar.gz
```
- 解包
```shell script
tar -zxvf keepalived-2.0.18.tar.gz
```
- 检查依赖
    - 没有ERROR则可以进行下一步
```shell script
cd keepalived-2.0.18
./configure --prefix=/usr/local/keepalived --sysconf=/etc
```
- 编译并安装
```shell script
make && make install
```
- 查看keepalived路径
    - 其实上面配置的时候，已经指定路径了
    - /usr/local/keepalived
```shell script
whereis keepalived
```
- 进入nginx路径
```shell script
cd /usr/local/keepalived
```
- keepalived 其实是一个服务
- 因此启停，实际就是服务的启停方式即可
- 编写启动脚本
```shell script
vi start.sh
```
```shell script
systemctl start keepalived.service
sleep 2
tail -n 300 /var/log/messages
ip addr
```
- 编写停止脚本
```shell script
vi stop.sh
```
```shell script
systemctl stop keepalived.service
```
- 查看日志
```shell script
vi log.sh
```
```shell script
tail -300f /var/log/messages
```
- 可以直接使用sbin的keepalived进行启动
- 带上-D参数显示更详细的日志
```shell script
cd sbin
./keepalived -D
```
- 给脚本添加执行权限
```shell script
chmod a+x *.sh
```
- 更改keepalived配置
    - 这里给出的配置是通常一般使用的简单配置
    - 因此我们先把原始配置复制一份
- 复制原始配置
```shell script
mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.default
cp /etc/keepalived/keepalived.conf.default /etc/keepalived/keepalived.conf
echo "" > /etc/keepalived/keepalived.conf
```
- 更改配置
    - 这就是在101这台机器上虚拟110的keepalived主机成为master节点的配置
    - 这是主节点的配置
    - 后面会给出backup节点的配置和检测脚本
- 主节点配置
```shell script
vi /etc/keepalived/keepalived.conf
```
```shell script
! Configuration File for keepalived

global_defs {
   #路由id：当前安装keepalived节点主机的标识符，全局唯一
   # 建议就使用本机IP即可
   router_id keep_101
}

vrrp_script check_nginx_alive {
   script "/etc/keepalived/check_nginx_alive.sh"
   interval 10  #每隔10秒运行上一行的脚本
   weight -10 # 如果脚本运行成功，则权重-10
}

vrrp_instance VI_1 {
    # 表示的状态，当前的101服务器为nginx的主节点，MASTER/BACKUP
    state MASTER
    # 当前实例绑定的网卡
    interface ens0
    # 保证主备节点一致，建议和虚拟IP地址部分一样，方便记忆
    virtual_router_id 110
    # 优先级/权重，谁的优先级高，在MASTER挂掉以后，就能成为MASTER
    priority 100
    # 主备之间同步检查的时间间隔，默认1s
    advert_int 1
    # 认证授权的密码，防止非法节点的进入
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    track_script {
		check_nginx_alive # 追踪 nginx脚本
    }
    virtual_ipaddress {
        192.168.1.110 # 虚拟IP地址
    }
}

```
- 备份节点配置
```shell script
! Configuration File for keepalived

global_defs {
   #路由id：当前安装keepalived节点主机的标识符，全局唯一
   router_id keep_102
}

vrrp_instance VI_1 {
    # 表示的状态，当前的102服务器为nginx的主节点，MASTER/BACKUP
    state BACKUP
    # 当前实例绑定的网卡
    interface ens0
    # 保证主备节点一致
    virtual_router_id 110
    # 优先级/权重，谁的优先级高，在MASTER挂掉以后，就能成为MASTER
    priority 80
    # 主备之间同步检查的时间间隔，默认1s
    advert_int 1
    # 认证授权的密码，防止非法节点的进入
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        192.168.1.110
    }
}
```
- 检查nginx存活脚本
```shell script
vi /etc/keepalived/check_nginx_alive.sh
```
```shell script
#!/bin/bash
A=`ps -C nginx --no-header |wc -l`
#判断nginx是否宕机，如果宕机了，尝试重启
if [ $A -eq 0 ]; then
   /usr/local/nginx/sbin/nginx
   #等待一小会再次检查nginx，如果没有启动成功，则停止keepalived，使其启动备用机
   sleep 3
   if [ `ps -C nginx --no-header |wc -l` -eq 0 ];then
	killall keepalived
   fi
fi
```

- 启动nginx
    - 这里使用创建的启动脚本
```shell script
./start.sh
```

	
## 双主热备方案
- 双主热备，也就是使得两台主机互为主备
- 这样的话就会产生两个虚拟IP
- 因此，这两个虚拟IP就需要考虑进行负载均衡
- 可以使用DNS或者再加一个nginx做负载均衡
- 这里就以两个keepalived和三个nginx实现负载均衡下的双主热备为例
- 配置101
```shell script
! Configuration File for keepalived

global_defs {
   #路由id：当前安装keepalived节点主机的标识符，全局唯一
   router_id keep_101
}

vrrp_instance VI_1 {
    # 表示的状态，当前的101服务器为nginx的主节点，MASTER/BACKUP
    state MASTER
    # 当前实例绑定的网卡
    interface ens0
    # 保证主备节点一致
    virtual_router_id 110
    # 优先级/权重，谁的优先级高，在MASTER挂掉以后，就能成为MASTER
    priority 100
    # 主备之间同步检查的时间间隔，默认1s
    advert_int 1
    # 认证授权的密码，防止非法节点的进入
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        192.168.1.110
    }
}

vrrp_instance VI_2 {
    # 表示的状态，当前的101服务器为nginx的主节点，MASTER/BACKUP
    state BACKUP
    # 当前实例绑定的网卡
    interface ens0
    # 保证主备节点一致
    virtual_router_id 120
    # 优先级/权重，谁的优先级高，在MASTER挂掉以后，就能成为MASTER
    priority 80
    # 主备之间同步检查的时间间隔，默认1s
    advert_int 1
    # 认证授权的密码，防止非法节点的进入
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        192.168.1.120
    }
}
```
- 配置102
```shell script
! Configuration File for keepalived

global_defs {
   #路由id：当前安装keepalived节点主机的标识符，全局唯一
   router_id keep_102
}

vrrp_instance VI_1 {
    # 表示的状态，当前的102服务器为nginx的主节点，MASTER/BACKUP
    state BACKUP
    # 当前实例绑定的网卡
    interface ens0
    # 保证主备节点一致
    virtual_router_id 110
    # 优先级/权重，谁的优先级高，在MASTER挂掉以后，就能成为MASTER
    priority 80
    # 主备之间同步检查的时间间隔，默认1s
    advert_int 1
    # 认证授权的密码，防止非法节点的进入
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        192.168.1.110
    }
}

vrrp_instance VI_2 {
    # 表示的状态，当前的102服务器为nginx的主节点，MASTER/BACKUP
    state MASTER
    # 当前实例绑定的网卡
    interface ens0
    # 保证主备节点一致
    virtual_router_id 120
    # 优先级/权重，谁的优先级高，在MASTER挂掉以后，就能成为MASTER
    priority 100
    # 主备之间同步检查的时间间隔，默认1s
    advert_int 1
    # 认证授权的密码，防止非法节点的进入
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        192.168.1.120
    }
}
```
- 配置103的nginx进行负载均衡
```shell script
http {
    # 定义均衡的虚拟主机，名为：virtual-host
    # 这个名称，在下面转发配置的时候使用
    # 轮询方式
    upstream virtual-host {
        server 192.168.1.101:8080;
        server 192.168.1.102:8080;
    }

    server {
        listen       80;
        server_name  localhost;

        charset utf-8;

        # 负载均衡到 virtual-host 的三台主机
        # 将访问到本服务器的 :80/dev-api/ 的请求转发到本机的 :8888/api/
        # 例如： http://ip:80/dev-api/hello 转发到 http://ip:8888/api/hello
        location /dev-api/ {
        	proxy_pass http://virtual-host/api/;
        }

    }
}
```