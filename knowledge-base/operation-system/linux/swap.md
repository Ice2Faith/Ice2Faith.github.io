## 虚拟内存
- 创建虚拟内存文件
    - 大小=bs*count
```shell script
dd if=[输入源] of=[输出源] bs=[数据块大小] count=[数据块个数]
dd if=/dev/zero of=/root/swap/swapfile bs=1M count=4096
```
- 更改权限，防止别人修改
```shell script
chmod 0600 /root/swap/swapfile
```
- 创建为交换分区文件
```shell script
mkswap /root/swap/swapfile
```
- 指定为交换分区
```shell script
swapon /root/swap/swapfile
```
- 指定开机自启动
```shell script
echo "/root/swap/swapfile swap swap defaults 0 0" >> /etc/fstab
```
- 查看交换分区结果
```shell script
free -h
```
- 查看交换分区使用时机
    - 是一个百分比值，表示物理内存还剩多少时，使用交换内存
```shell script
cat /proc/sys/vm/swappiness
```
- 设置交换时机
    - 使用达到75%=100%-%25时使用交换内存
```shell script
echo "vm.swappiness=25" >> /etc/sysctl.conf
sysctl -p
```
