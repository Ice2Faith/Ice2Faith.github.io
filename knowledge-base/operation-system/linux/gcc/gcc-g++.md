# gcc g++ 环境

## 简介
- gcc g++ 环境，为编译c/c++提供了环境
- 在大多数编译安装的程序中，都必须依赖该环境才能安装

## 安装
- 更新yum
```shell script
yum update -y
```
- 安装
```shell script
yum install gcc gcc-c++
yum -y install gcc automake autoconf libtool make
yum groupinstall -y 'Development Tools'
yum install -y gcc openssl-devel bzip2-devel libffi-devel
```