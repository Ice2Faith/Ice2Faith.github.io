# i2f-turbo-knowledge

- 知识库文档索引，涵盖编程语言、中间件组件、操作系统等方面的技术文档
- github仓库：[github](https://github.com/Ice2Faith/i2f-turbo-knowledge)
- gitee仓库：[gitee](https://gitee.com/Ice2Faith/i2f-turbo-knowledge)

---

# 中间件组件（middleware-components）

- 中间件组件相关的文档，包括大数据、容器、数据库、消息队列、监控、对象存储等

## 大数据（bigdata）

- 大数据相关的组件，包括数据采集、流计算、分布式存储、资源协调等

### Canal

- MySQL binlog增量数据监听与同步中间件

- 详细文档：[canal.md](middleware-components/bigdata/canal/canal.md)
  - Canal增量数据监听中间件的原理、安装配置与使用，包括MySQL binlog开启、主从概念、工作原理等

### Flink

- 实时流计算引擎

- 详细文档：[flink-1.13.5.md](middleware-components/bigdata/flink/flink-1.13.5.md)
  - Flink 1.13.5环境安装与配置，包括local模式、standalone模式、standalone-HA高可用模式的部署

### Hadoop

- 分布式存储与计算框架

- 详细文档：[hadoop-3.md](middleware-components/bigdata/hadoop/hadoop-3.md)
  - Hadoop3环境安装，包括单机部署与集群部署配置、HDFS/YARN的启动与管理

### Zookeeper

- 分布式资源管理与协调框架

- 详细文档：[zookeeper.md](middleware-components/bigdata/zookeeper/zookeeper.md)
  - Zookeeper入门指南，包括单机配置、集群配置、启停服务、客户端连接与基本操作

---

## 容器（container）

- 容器化相关的组件，包括Docker容器引擎、K8S容器编排平台等

### Docker

- 容器引擎，提供应用的虚拟化与隔离运行能力

- 详细文档：[docker-usege.md](middleware-components/container/docker/docker-usege.md)
  - Docker使用指南，包括分层原理、基本操作（镜像/容器管理）、Dockerfile、数据卷、网络等

- 详细文档：[docker-compose.md](middleware-components/container/docker/compose/docker-compose.md)
  - Docker Compose文档，用于统一管理一组容器的启动、停止、日志查看等操作

- 详细文档：[readme.md](middleware-components/container/docker/jar8env/readme.md)
  - Jar8env Docker使用指南，对给定的jar文件构建基于openjdk8的Docker镜像

- 详细文档：[uninstall-docker.md](middleware-components/container/docker/uninstall/uninstall-docker.md)
  - Docker的完整卸载流程，包括停止服务、移除网卡、删除安装包与残留文件

### K8S（Kubernetes）

- 容器编排平台，实现跨主机多容器的弹性编排部署

- 详细文档：[k8s.md](middleware-components/container/k8s/k8s.md)
  - K8S容器编排平台详解，包括基础概念（宿主机/虚拟机/虚拟化/微服务/容器化）、基础组件（Ingress/Service/Deployment/Pod/ConfigMap）等

- 详细文档：[k8s-install.md](middleware-components/container/k8s/k8s-install.md)
  - K8S集群安装部署指南

- 详细文档：[k8s-istio.md](middleware-components/container/k8s/k8s-istio.md)
  - Istio服务网格在K8S中的使用，包括Sidecar代理、Gateway网关、VirtualService虚拟服务、DestinationRule转发规则等

- 详细文档：[devops.md](middleware-components/container/k8s/devops.md)
  - DevOps开发运维一体化流程，包括Jenkins流水线编排、各参与组件（Gitlab/Maven/Nexus/Harbor等）的协作

---

## 数据库（database）

- 数据库相关的组件与ORM框架，包括关系型数据库、NoSQL数据库、ORM映射框架等

### Mybatis

- Java持久层ORM框架

- 详细文档：[mybatis.md](middleware-components/database/mybatis/mybatis.md)
  - Mybatis常用XML语法详解，包括springboot+mybatis集成、XML文件结构、CRUD节点、动态SQL等

### Mybatis-Plus

- 基于Mybatis增强的快速开发ORM框架

- 详细文档：[mybatis-plus.md](middleware-components/database/mybatis-plus/mybatis-plus.md)
  - Mybatis-Plus常用语法，包括代码组织形式（bean/service/mapper）、wrapper/lambda-wrapper包装器等

### NoSQL数据库

- 非关系型数据库，包括MongoDB文档数据库、Redis缓存数据库

- 详细文档：[mongodb5.md](middleware-components/database/nosql/mongodb/mongodb5.md)
  - MongoDB5入门，包括环境搭建、配置认证、副本集配置等

- 详细文档：[mongodb6.md](middleware-components/database/nosql/mongodb/mongodb6.md)
  - MongoDB6入门，包括环境搭建、客户端安装（mongosh）、认证配置、数据备份恢复等

- 详细文档：[redis6.md](middleware-components/database/nosql/redis/redis6.md)
  - Redis6入门，包括环境搭建、配置密码、后台运行、客户端验证等

### 关系型数据库（RDB）

- 关系型数据库及其相关工具

#### MySQL

- 中小型项目常用的关系型数据库

- 详细文档：[mysql8.md](middleware-components/database/rdb/mysql/mysql8.md)
  - MySQL8环境安装，包括yum安装、手动安装、卸载、远程权限配置等

- 详细文档：[mysql-gram.md](middleware-components/database/rdb/mysql/mysql-gram.md)
  - MySQL语法集锦，包括日期函数、DDL操作、查询语法、批量操作等

- 详细文档：[mysql-procedure.md](middleware-components/database/rdb/mysql/mysql-procedure.md)
  - MySQL存储过程，包括自动备份表到历史表、自动创建历史表结构等

- 详细文档：[readme.md](middleware-components/database/rdb/mysql/mysql8-backup-suit/readme.md)
  - MySQL关键表备份工具集，包括mysqldump备份恢复脚本、定时备份配置等

#### Oracle

- 企业级关系型数据库

- 详细文档：[oracle-gram.md](middleware-components/database/rdb/oracle/oracle-gram.md)
  - Oracle语法集锦，包括日期函数、DDL操作、序列、递归查询、批量更新（merge into）等

- 详细文档：[oracle-perf.md](middleware-components/database/rdb/oracle/oracle-perf.md)
  - Oracle执行分析，包括执行计划解析、锁查询等

#### Mybatis数据库适配

- Mybatis针对不同数据库的适配技巧

- 详细文档：[mybatis-mysql.md](middleware-components/database/rdb/mybatis/mybatis-mysql.md)
  - Mybatis for MySQL，插入后获取自增ID的selectKey配置

- 详细文档：[mybatis-oracle.md](middleware-components/database/rdb/mybatis/mybatis-oracle.md)
  - Mybatis for Oracle，插入前获取序列号作为ID的selectKey配置

- 详细文档：[mybatis-xml.md](middleware-components/database/rdb/mybatis/mybatis-xml.md)
  - Mybatis语法集锦，包括动态where、选择插入、选择更新、构造日期左表等

---

## Doris

- 实时分析MPP分布式查询框架

- 详细文档：[doris-1.2.md](middleware-components/doris/doris-1.2.md)
  - Apache Doris 1.2实时分析MPP框架，包括架构介绍（FE/BE/Blocker）、单机部署与集群部署配置

---

## Gzip

- 数据压缩配置

- 详细文档：[gzip.md](middleware-components/gzip/gzip.md)
  - Gzip压缩配置，包括Tomcat、Nginx、SpringBoot三种场景下的Gzip压缩开启与参数配置

---

## 监控（monitor）

- 运维监控与可视化平台

### Prometheus + Grafana

- 运维监控指标采集与数据可视化平台

- 详细文档：[prometheus.md](middleware-components/monitor/prometheus/prometheus.md)
  - Prometheus运维监控告警平台，包括安装配置、各类Exporter插件安装（node/mysql/redis/kafka/nginx/mongodb/jmx等）

- 详细文档：[grafana.md](middleware-components/monitor/prometheus/grafana.md)
  - Grafana数据可视化平台，包括安装配置、Prometheus数据源配置、监控面板导入与告警规则配置

---

## 消息队列（mq）

- 消息队列中间件，用于异步通信与解耦

### Kafka

- 高性能消息队列，主打大数据传输

- 详细文档：[kafka.md](middleware-components/mq/kafka/kafka.md)
  - Kafka入门，包括环境搭建、单机配置、生产者与消费者验证

### RabbitMQ

- 基于Erlang的消息队列服务

- 详细文档：[rabbitmq.md](middleware-components/mq/rabbitmq/rabbitmq.md)
  - RabbitMQ安装与配置，包括Windows和Linux环境下Erlang与RabbitMQ的安装、管理插件启用等

### RocketMQ

- 金融级别高性能消息队列

- 详细文档：[rocketmq.md](middleware-components/mq/rocketmq/rocketmq.md)
  - RocketMQ入门，包括NameServer与Broker的启动配置、JVM调优、Dashboard面板安装等

---

## 对象存储（oss）

- 对象存储服务

### Ceph

- 分布式统一存储系统

- 详细文档：[ceph.md](middleware-components/oss/ceph/ceph.md)
  - Ceph分布式存储简介，包括组件组成（Monitor/Manager/OSD/MDS）与基本运维命令

### MinIO

- 轻量级对象存储服务

- 详细文档：[minio.md](middleware-components/oss/minio/minio.md)
  - MinIO入门指南，包括环境搭建、启停脚本编写、Web控制台访问等

---

## 其他（others）

- 其他工具与规范

### Git工作流

- Git版本控制的工作流规范

- 详细文档：[git-flow.md](middleware-components/others/git/git-flow.md)
  - Git工作流规范，包括敏捷开发(Scrum)流程、分支模型（release/test/request/feature/hotfix/publish）、使用准则等

### GitHub

- GitHub相关工具与使用

- 详细文档：[github.io.md](middleware-components/others/github/github.io.md)
  - GitHub Pages的使用，用于托管静态网站、个人主页搭建

---

## Web服务器（web-server）

- Web应用服务器与反向代理

### Jar

- Java Jar包的运行管理

- 详细文档：[jar.md](middleware-components/web-server/jar/jar.md)
  - Jar包启停脚本，包括启动、停止、重启三个脚本的编写

### Nginx

- 高性能反向代理与Web服务器

- 详细文档：[nginx.md](middleware-components/web-server/nginx/nginx.md)
  - Nginx安装与配置，包括编译安装、启停脚本、反向代理、负载均衡、Gzip压缩等配置

- 详细文档：[nginx-rtmp.md](middleware-components/web-server/nginx/nginx-rtmp.md)
  - Nginx配置RTMP直播/点播服务器，包括rtmp模块编译、直播/点播/HLS配置

- 详细文档：[install-nginx.md](middleware-components/web-server/nginx/pkgs/install-nginx.md)
  - Nginx实现代理任意网址的转发，包括set-misc-nginx-module模块安装与跨域转发配置

### Tomcat

- Java Web应用服务器

- 详细文档：[tomcat9.md](middleware-components/web-server/tomcat/tomcat9.md)
  - Tomcat9入门，包括环境搭建、Gzip配置、war包部署、静态Web（Vue）部署等

---

# 操作系统（operation-system）

- 操作系统相关的文档，包括Linux和Windows系统的常用命令与配置

## Linux

- Linux操作系统常用命令与服务配置

- 详细文档：[linux.md](operation-system/linux/linux.md)
  - Linux常用命令集锦，包括目录操作、文件操作、行编辑(sed/awk)、权限管理、进程管理、网络管理、软件包管理等

- 详细文档：[shell.md](operation-system/linux/shell.md)
  - Shell脚本编写指南，包括变量定义、if/for/while/case分支、函数等

- 详细文档：[ssh.md](operation-system/linux/ssh.md)
  - SSH免密登录配置，包括RSA密钥生成、多主机免密配置、远程复制(scp)、多主机同步操作脚本(xsync/xcall)

- 详细文档：[email.md](operation-system/linux/email.md)
  - Linux邮件发送配置，包括mailx安装配置、定时监控报警脚本（磁盘/内存/网络/进程/套接字/用户数监控）

- 详细文档：[keepalived.md](operation-system/linux/keepalived.md)
  - Keepalived高可用配置，包括安装、主备配置、双主热备方案、Nginx存活检测脚本等

- 详细文档：[swap.md](operation-system/linux/swap.md)
  - Linux虚拟内存（交换分区）配置，包括创建swap文件、设置开机自启、调整swappiness参数

- 详细文档：[ftp.md](operation-system/linux/ftp/ftp.md)
  - FTP(vsftpd)环境安装，包括安装配置、用户管理、被动模式配置等

- 详细文档：[gcc-g++.md](operation-system/linux/gcc/gcc-g++.md)
  - GCC/G++编译环境安装，为编译C/C++程序提供必要的编译工具依赖

- 详细文档：[gitlab-ce.md](operation-system/linux/gitlab/gitlab-ce.md)
  - GitLab CE入门，包括安装配置、服务管理、Docker构建CentOS7环境

- 详细文档：[processctl.sh](operation-system/linux/processctl.sh)
  - 统一进程启停控制脚本

- 详细文档：[xsync.sh](operation-system/linux/xsync.sh)
  - 多主机文件同步脚本

- 详细文档：[xcall.sh](operation-system/linux/xcall.sh)
  - 多主机命令批量执行脚本

## Windows

- Windows操作系统常用命令与工具

- 详细文档：[windows.md](operation-system/windows/windows.md)
  - Windows常用命令，包括网络相关命令（WIFI查看、密码获取等）

- 详细文档：[cygwin.md](operation-system/windows/cygwin.md)
  - Cygwin安装与配置，在Windows环境中使用Linux命令，包括环境变量配置、apt-cyg包管理

---

# 编程语言（programming-language）

- 编程语言直接相关的文档

## Git

- Git版本控制工具

- 详细文档：[git.md](programming-language/git/git.md)
  - Git的安装与配置

---

## Go语言

- Go语言（Golang）相关文档，一门简洁高效的编程语言

- 详细文档：[go-install.md](programming-language/go/go-install.md)
  - Golang安装和配置，包括Windows/Linux环境安装、VSCode开发环境配置、国内镜像配置

- 详细文档：[go-grammer.md](programming-language/go/go-grammer.md)
  - Go语法简介，包括数据类型、变量常量、流程控制、函数、数组/切片/映射、结构体、接口、并发(goroutine/channel)等

- 详细文档：[go-mod.md](programming-language/go/go-mod.md)
  - Golang包管理(Go Mod)，包括项目创建、依赖下载（go get/download/vendor）等

- 详细文档：[go-orm.md](programming-language/go/go-orm.md)
  - Golang数据库ORM操作，基于GORM框架的增删改查、结构映射、标签配置等

- 详细文档：[go-web.md](programming-language/go/go-web.md)
  - Golang实现WEB开发，基于Gin框架的路由、参数获取、参数绑定、中间件、分组路由、文件上传、JWT等

---

## JVM生态

- 运行于JVM之上的语言与工具

### Java

- Java开发相关文档

- 详细文档：[java8.md（安装）](programming-language/jvm/java/java8/install/java8.md)
  - Java8环境安装，包括Linux yum安装、手动安装、Windows安装与环境变量配置

- 详细文档：[java8.md（开发）](programming-language/jvm/java/java8/use/java8.md)
  - Java开发指南，包括语言构成、开发规范（命名规范、代码组织、面向抽象设计）等

### Maven

- Java项目依赖管理器

- 详细文档：[maven.md](programming-language/jvm/maven/maven.md)
  - Maven依赖管理器，包括安装配置、IDEA集成、命令行使用（clean/package/install/deploy）、pom.xml编写等

### Scala

- JVM上的函数式编程语言

- 详细文档：[scala-2.12.md](programming-language/jvm/scala/scala-2.12.md)
  - Scala 2.12环境安装，应用于大数据与计算领域（Flink/Spark等）

---

## Python

- Python编程语言

- 详细文档：[python3.md](programming-language/python/python3.md)
  - Python3环境安装，包括编译安装、PIP安装、环境变量配置

---

## SQL

- SQL数据库相关

- 详细文档：[sql-inject.md](programming-language/sql/sql-inject.md)
  - SQL注入攻击与防护，包括字符型注入、union注入、曝库/曝表/曝字段/曝数据等攻击方式与防护策略

---

## Web前端

- Web前端开发相关

- 详细文档：[nodejs.md](programming-language/web/nodejs/nodejs.md)
  - Node.js安装与配置，包括Windows安装、npm配置、国内镜像源、常用全局工具安装（vite/vue-cli/yarn/pnpm等）

- 详细文档：[vue-cli.md](programming-language/web/vuecli/vue-cli.md)
  - Vue CLI安装与使用，包括项目创建、自定义配置（Router/Vuex/Sass/ESLint等）、项目运行

- 详细文档：[web-cdn-import.md](programming-language/web/web-cdn-import.md)
  - WEB资源的CDN引入方式，包括静态引入、公共CDN源、国内镜像CDN替换、常用库CDN引用（Vue/Element-UI/Vant/Axios等）
