# python3 环境安装

## 简介
- python3 是python的第三个版本，类似于java8
- 但是python3和python2并不是向下兼容的

## 依赖环境
- 无

## 安装
- 更新yum
```shell script
yum update -y
```
- 检查基础GCC环境
```shell script
yum install gcc gcc-c++
yum -y install gcc automake autoconf libtool make
yum groupinstall -y 'Development Tools'
yum install -y gcc openssl-devel bzip2-devel libffi-devel
```
- 下载
```shell script
wget -c https://www.python.org/ftp/python/3.9.7/Python-3.9.7.tgz
```
- 解包
```shell script
tar -zxvf Python-3.9.7.tgz 
```
- 配置
```shell script
cd python-3.9.7
./configure prefix=/usr/local/python3 --enable-optimizations
```
- 编译安装
```shell script
make && make install
```
- 添加环境变量
```shell script
vi /etc/profile.d/env_conf.sh
```
```shell script
export PATH=$PATH:/usr/local/python3/bin/
```
```shell script
source /etc/profile
```
- 安装PIP
```shell script
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3.9 get-pip.py
```
- 验证
```shell script
python3 -V
```