# ceph 分布式存储

## 简介
- 统一存储
- 支持块、对象、文件的所有存储形态
- 开源、免费
- 对云计算项目的支持很好
- 数据的组织使用MDS进行管理和存储
- MDS支持多节点存活
- 集群也被称为RADOS(reliable automatic distributed object store)
- librados是其api，提供了各种编程语言的客户端

## 组成
- Monitor 监视器，维护集群状态以及认证
- Manager 守护进程，跟踪运行指标
- OSD 处理数据的存储和复制
- MDS 存储元数据

## 安装
- 环境准备
```shell script

```
- 配置下载源
```shell script

```
- 创建用户
```shell script

```
- 配置免密登录
```shell script

```
- 安装
```shell script

```
- 初始化MON节点
```shell script

```

## 运维
- 查看版本
```
ceph -v
```
- 查看状态
```
ceph -s
```
- 查看节点
```
ceph osd tree
```
- 查看时延
```
ceph osd perf
```
- 查看数据分布
```
ceph pg dump
```
