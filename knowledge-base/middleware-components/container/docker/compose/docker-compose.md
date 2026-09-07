# docker-compose 文档

- docker-compose 适用于对一组容器进行管理的docker插件
- 比如，对一个项目的mysql,redis,springboot微服务等系列容器，进行统一的启动、停止等管理操作的组件
- docker-compose是运行在一台宿主机上的
- 也就是说，这一组容器也是运行在一台主机上，不是分布在多台主机上
- 这一点要有清楚的认知

## 安装与验证

### 前置条件

- 已经安装了docker

### 安装

- 直接安装即可

```shell
yum install docker-compose-plugin
```

- 验证

```shell
docker compose version
```

- 能够看到正常输出版本信息即可

## 操作

- docker compose 的操作是依赖于一个叫做 docker-compose.yml 的配置文件的
- 这个配置文件的作用就是说明了这一组容器具体有哪些，各自的配置是怎么样的
- 简单来说，就是描述了一组 docker run 所需要的信息的配置文件

### docker-compose.yml 案例

- 下面来看一个简单的例子说明

```shell
vi docker-compose.yml
```

- 内容如下

```shell
version: "3.9" # 说明运行所需要的最低版本
services: # 说明有哪些容器需要进行管理
  nginx:  # 说明容器的名称
    image: nginx:alpine # 说明容器使用哪个镜像进行启动
    ports: # 说明容器启动时的端口映射
      - "80:80"
  redis:  
    image: redis:alpine
    ports:
      - "6379:6379"
```

- 这个实例非常简单，包含了两个nginx和redis两个容器

### 操作命令

- 所有的操作几乎都是基于 docker-compose.yml 文件进行的
- 所以，一般情况下，都需要先 cd 到 docker-compose.yml 文件所在的目录
- 然后在进行操作

- 上线服务
- 启动 -d 是指定后台运行(--detach)，一般情况也是这样的

```shell
docker compose up -d
```

- 当然，也可以前台启动，这样只适用于调试的时候，方便查看日志以及查看启动顺序
- 前台启动时，使用 Ctrl+C 终止，终止会停止并删除容器

```shell
docker compose up
```

- 当然，也可以只启动其中的几个容器，而不是全部容器

```shell
docker compose up nginx redis
```

- 其他启动参数
- 强制重新构建镜像(--build)

```shell
docker compose up -d --build
```

- 扩展服务实例数量(--scale)

```shell
docker compose up -d --scale redis=3
```

- 查看运行状态

```shell
docker compose ps
```

- 也可以只查看其中几个容器

```shell
docker compose ps redis
```

- 查看运行日志

```shell
docker compose logs
```

- 也可以只查看其中几个容器

```shell
docker compose logs redis
```

- 其他参数

```shell
# 和tail -f 一致的效果
docker compose logs -f

# 和tail -n 一样的效果
docker compose logs --tail 50 redis

# 显示带时间戳的日志
docker compose logs --timestamps
```

- 查看运行性能
- 和top命令类似

```shell
docker compose top
```

- 也可以只查看其中几个容器

```shell
docker compose top redis
```

- 仅构建不运行

```shell
docker compose build
```

- 其他参数

```shell
--no-cache 强制全新构建，不适用缓存
--pull 重新拉取基础进行的最新版本
```

- 仅拉取镜像不运行

```shell
docker compose pull
```

- 其他参数

```shell
--ignore-pull-failures 忽略拉取失败的项
```

- 停止服务
- 仅停止服务，不会删除相关的资源，可以重新启动服务

```shell
docker compose stop
```

- 也可以只停止其中几个容器

```shell
docker compose stop nginx redis
```

- 启动服务
- 对已经停止的服务，可以进行重新启动

```shell
docker compose start
```

- 也可以只启动其中几个容器

```shell
docker compose start nginx redis
```

- 重启服务
- 先停止再启动

```shell
docker compose restart
```

- 也可以只重启其中几个容器

```shell
docker compose restart nginx redis
```

- 下线服务
- 停止并删除容器、网络，默认保留存储卷

```shell
docker compose down
```

- 其他参数
- 同时删除存储卷：-v 或 --volumes
- 删除所有相关镜像：--rmi all

```shell
docker compose down -v --rmi all
```

- 验证配置

```shell
docker compose config
```

- 指定文件/多文件合并

```shell
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

- 遵循的原则是同名覆盖，后者覆盖前者

## docker-compose.yml 详解

- 详情可以查看：

```shell
./docker-compose.yml
```

- 这个文件中的实例配置及注释说明