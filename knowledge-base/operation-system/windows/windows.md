# windows 常用命令
---
- 常见的参数
```shell script
/? 查看命令的帮助
help 查看指定命令的帮助
```

---
## 网络
- 查看已连接的WIFI列表
```shell script
netsh wlan show profiles
```
- 查看WIFI密码
```shell script
netsh wlan show profiles Xiaomi-Wifi key=clear
```