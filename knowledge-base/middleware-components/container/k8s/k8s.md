# k8s (kubernetes) 容器编排平台

- k8s 是一个容器编排平台，能够进行在多台linux主机上实现弹性编排部署容器
- 实现自动扩容、缩容、配置管理、流量网关、负载均衡、熔断、重试、监控等系列操作
- 请记住一点，k8s主要管理的就容器，因此，很多内容都是为了更好的管理容器

- 中文官方文档

```shell
https://kubernetes.io/zh-cn/docs/home/
```

- 本文主要参考教学视频

```shell
【完整版Kubernetes（K8S）全套入门+微服务实战项目，带你一站式深入掌握K8S核心能力】 
https://www.bilibili.com/video/BV1MT411x7GH/?p=39&share_source=copy_web&vd_source=d1585431b7321cc3953866535fa8c067
```

## 基础概念

### 宿主机

- 宿主机的概念，这是相对的
- 简单说就是，如果一个系统A运行在另一个系统B内部，依赖于另一个系统B的运行才能运行
- 那么，这时候，被依赖的系统B就是宿主机

### 虚拟机

- 虚拟机，也就是虚拟主机，留存最广的就是 VmWare , VirtualBox 等虚拟机软件
- 虚拟机的本质就是，在宿主机内部运行一个真实的操作系统
- 虚拟机通过模拟真实的硬件（虚拟CPU，虚拟网卡，虚拟内存，虚拟磁盘）来提供给一个完整的操作系统运行
- 也就是说，虚拟机几乎包含了真实机器的每个硬件部分
- 当然，实际的虚拟机中，大都是基于 HAL （hardware adapter layer, 硬件适配层）来实现的
- 也就是将硬件层面的调用转换为内部宿主机的硬件调用
- 进行了桥接、适配、转换工作
- 这样的好处是，系统几乎是真实的系统
- 坏处是，这样因为运行了完整的系统，消耗的资源（CPU、内存、磁盘）等就比较大
- 比如，虚拟机，要预先分配磁盘、内存
- 就算虚拟机内部系统不使用这些资源，也占用着这些资源
- 导致宿主机无法使用这些资源

### 虚拟化

- 虚拟化，其实是很早就有的一个概念，只不过后面伴随云服务才慢慢发展起来
- 前面，因为【虚拟机】的资源占用和预分配问题
- 就有了虚拟化作为替换
- 虚拟化是从操作系统内核的层面进行划分
- 划分出独立的用户空间/内核空间
- 这样，内部运行的系统，就不需要运行完整的操作系统
- 而是可以共享一部分操作系统能力
- 大大减少了资源的开销
- 虚拟化，也是由Linux内核中提出来的概念
- 并且，因为Linux可以说是，都是一脉相承，内核几乎都是一样的
- 因此，绝大部分的内核功能直接共享宿主机的即可
- 这样，几乎内核层面的调用和一部分的用户调用，都和宿主机共享
- 只需要隔离一些环境即可
- 同时，因为共享，就不需要预先分配资源，可以做到动态调节
- 因此，慢慢的就衍生出了 docker 这样的虚拟化产品
- 一时间，docker 就成为了虚拟化的代名词
- 伴随着时间的发展，越来越多的应用进行了虚拟化
- 这样就脱离了基础环境的构建，也不会出现，不同的机器运行同样的代码
- 但是有的能运行，有的运行不了的情况，避免了跟多因为主机环境问题导致的项目问题
- 但是，此时的虚拟化慢慢的发现了几个问题
- 当应用比较多的时候，不能够一次性的构建并运行需要的容器
- 比如，10个应用，就要单独控制10个容器进行运行，每个容器的声明周期都要手动管理
- 很不方便
- 同时，因为docker是在主机上的，不方便在多台主机之间操作
- 某种程度上，反而感觉更麻烦了
- 尽管后面出现了 docker-compose 这样的批量容器管理的方案
- 但是，docker-compose 这种方案，虽然能够批量管理容器
- 但是，却限制在了一台主机上，不能够跨主机进行管理
- 也造成了一定的不便

### 微服务

- 微服务，从概念上来说，就是讲一个庞大的系统（大而杂），按照功能和相关性
- 划分为多个自治的微小服务（微而精）
- 让各个服务只负责自身的业务逻辑，尽量少的参与到其他服务中
- 同时，拆分之后，方便了分布式部署，原本庞大的系统需要非常高配置的主机才能运行
- 现在，拆分之后，几个相对经济的主机，就能够满足需求
- 同时，因为服务自治，某种程度上也提升了项目的可维护性和项目质量
- 并且，因为相对自治隔离，就算其中一些服务挂掉，也不一定会导致整个系统不可用
- 某种程度上，也提升了系统的稳定性
- 另外，因为服务自治的关系，也就不要求都是用相同的框架或者开发语言进行项目的开发
- 各个微服务可以选择自己的框架或者开发语言进行开发
- 比如，golang,java,python等都可以混合使用，通信可以基于Http通信，也可以使用RPC进行通信
- 但是，因为拆分的关系，就带来了一些其他的问题
- 主要的就是分布式问题
- 例如，统一配置、流量控制、统一入口网关、流量熔断、负载均衡、注册中心、服务发现等等问题
- 因此，spring-cloud 这一套的微服务体系在Java领域就成为了主流
- 另外，也有 dubbo，以及后来发展起来的 spring-cloud-alibaba 这套微服务系统
- 还有就是一些额外的问题
- 例如，当多个项目都是微服务时
- 例如，配置中心，负载均衡，流量网关等这些都需要重复的构建
- 使得开发者不能专注自身的业务逻辑
- 而需要额外处理一些微服务框架的问题

### 容器化

- 容器化，也叫容器云，这一部分就要就是说 k8s 的内容
- 虽然，也有一些和 k8s 类似的产品
- 但是，基本的运行原理都是一致的
- 前面说了，虚拟化解决了环境不一致的问题
- 但是对于批量管理和跨节点编排的能力不足
- k8s 的出现就是为了解决这两个主要问题的
- 同时，k8s 出现时微服务的概念已经相当成熟
- 因此，k8s 也把微服务中出现的问题
- 一些公共的例如流量网关、负载均衡、配置中心、注册中心、服务发现等的功能都进行了整合
- 早期的 k8s 主要是基于 docker 进行构建的
- 随着越来越多的类似docker的产品出现，例如 containerd,podman等
- 于是，k8s 和相关这些容器的人员
- 牵头达成了CRI（container runtime interface，容器运行时接口）更高级抽象的统一接口
- 只要实现了CRI的容器都可以在k8s中运行，也就是慢慢出现了相对统一的行业标准
- 因此，k8s 也不在和 docker 强行绑定了
- 但是，docker 因为出现的比较早，一直没有实现CRI，在后期后，k8s 逐渐放弃了将 docker 作为默认运行时
- 即使还保留了一个兼容 docker 的插件
- 因此，k8s 的目标就是实现 跨节点多容器具备微服务基础设施的容器编排管理平台
- 能够实现，容器的跨节点部署，多容器的统一管理，自动扩缩容，自动恢复
- 统一的微服务基础设施（网关、服务注册、服务发现、配置中心、负载均衡、流量熔断）

## k8s 简介

- k8s 在前面的【容器化】概念中也说明了一些基础的概念
- 简单说，k8s 就是统一了多容器跨节点编排的具有微服务基础设施支撑的平台

### k8s 具有哪些能力

- 多租户/命名空间隔离：可以实现多个命名空间的隔离，比如：开发环境，测试环境，或者按照项目划分的命名空间
- 多容器管理：提供了对多个容器的统一管理能力
- 跨节点编排：支持跨多个主机节点进行编排容器运行
- 自动恢复：支持对容器异常停止的自动回复运行机制
- 自动扩缩容：支持对容器自动添加或者减少运行的实例数量
- 流量网关：统一了服务的流量入口
- 服务注册/发现：自动管理整个集群的服务，基于DNS进行服务的注册和发现
- 负载均衡/流量熔断：自动将流量负载到具体的服务实例上，异常的服务实例自动排除

### k8s 基础概念

- 在k8s中，认为一切皆资源
- 使用资源类型划分
- 动态编排，简单来说就是，要启动一个容器，集群自动分配到一台主机上
- 如果容器重新启动了，也许会分配到不同的主机上
- 因此，主要就是无状态容器
- 无状态容器，也就是可以再任意一台主机运行，即使任意换一台主机继续运行也能够正常工作
- 也就是说，一般的依赖磁盘记录数据的，或者依赖内存长期存储数据的，都不是无状态的
- 举个例子来说，一个Nginx程序，他不依赖磁盘，换一个主机运行也完全没有问题
- 运行结果也是一样的，同样的镜像，不管怎样运行，结果都一样，那就是无状态的
- 但是，例如Redis，数据库等，这种需要使用磁盘或者长期使用内存记录数据的
- 换一台主机重新启动，数据就没了，比如Redis记录了用户登录凭证
- 但是重新启动了一台，新的这个Redis就没有之前的用户登录凭证
- 这样，用户就变成了没登录的状态，这样是不对的，这种就是有状态的
- 虽然，k8s已经支持有状态服务的部署，但是实际上不建议有状态的服务部署到k8s中

## 基础组件

### 网关：Ingress
- 实际上就是基于nginx封装（后来随着标准制定，也有其他方案替换）的一个入口网关
- 实现南北流量控制
- 用户的访问，外部系统的访问，都经过网关才能访问到系统内部
- 因此，用户访问网关，网关转发到Service服务，服务负载到容器Pod

### 服务：Service
- 也就是将运行相同内容的多个容器（Pod）归并为一个Service服务
- 使得这些容器的流量入口统一，都统一从Service进行访问
- 这样，Service内部实现负载均衡和熔断机制
- 同时容器Pod自动被对应的Service管理
- 也就实现了服务注册和服务发现（这里主要是容器Pod的注册和发现）
- 同时，k8s也实现了对Service服务的注册和发现
- 因此，从整个集群的角度来说，也就实现了服务的注册和发现
- 实现东西流量控制
- 这样，微服务之间的调用，就可以通过服务名方式访问
- 实际上，每个服务都会被集群解析为一个服务名的DNS
- 因此，微服务之间的访问，实际上需要同通过服务名作为DNS名访问即可
- 不需要考虑负载均衡和熔断等
- 对微服务而言，就像访问一台固定的主机即可
- 通过DNS的方式屏蔽了负载均衡这些细节

### 部署：Deployment
- 其实就是管理容器如何生成、运行、停止的描述性信息
- 主要作用就是记录了镜像时怎么变成容器的Pod的
- 这样，k8s就能够知道如何去管理容器Pod了
- 一个Deployment管理了一组容器
- 也就是说，其实类似 docker-compose
- 又因为要支持版本回滚，滚动升级这些能力
- 因此，就有了这一组容器版本的概念
- 这个概念被称作 ReplicaSet 副本集
- 每次部署升级，都会产生一个 ReplicaSet
- 也就是产生一个版本
- 每个 ReplicaSet 中就管理了多个容器Pod

### 容器节点：Pod
- 是k8s运行的最小单位
- 也就是一组容器，运行了具体的应用
- 但是通常情况下，一个Pod中值运行一个容器
- 因为是最小单位，所以k8s主要就是管理这些Pod
- 所以，大多数的操作都是为了更好的管理和控制这些Pod

### 配置：ConfigMap/Secret
- 用户记录一些简单的配置或者配置文件
- 可以分发这些配置文件到具体的Pod中，实现配置的动态更新
- 也就是一个配置中心的概念

### 持久卷：PV/PVC
- 也就是提供了一个持久存储的存储卷，能够给容器进行挂载
- 方便存储持久化的数据

### 域名解析，CoreDNS
- 主要的作用就是将每个Service都转换为一个DNS路由规则
- 使得能够通过Service服务名访问到这个Service
- 也就是说，k8s内部实现微服务之间的访问，通过DNS就行
- 注意，这个DNS信息是同步到Pod里面的容器的
- 在Pod所在的宿主机上，是没有这份DNS的
- 所以，如果直接在宿主机上使用服务名访问
- 是访问不到的，除非进行了一些额外的配置

### 流量路径

#### 南北流量/纵向流量

- 用户
- Ingress网关
- Service服务
- 主机
- KubeProxy代理
- Pod容器

#### 东西流量/横向流量

- 微服务A
- Service服务B
- 主机
- KubeProxy代理
- Pod容器B
- 微服务B

#### 流量IP地址/DNS

- k8s中，因为动态编排的原因
- IP地址就变得不可靠了
- 因此，一旦扩缩容或者容器升级重启等出现，IP极大可能会被重新分配
- 因此，在k8s中不使用IP进行访问
- 而是使用DNS进行访问
- DNS的规则如下

```shell
服务名.命名空间.svc.集群名
```

- 一般情况下
- 默认的命名空间为：default
- 默认的集群名为：cluster.local
- 因此，默认情况下就是这样

```shell
服务名.default.svc.cluster.local
```

- 当出在同一个集群的时候，可以省略后面的部分
- 就像下面这样

```shell
服务名.default
```

- 如果命名空间也相同
- 命名空间也可以省略
- 就像下面这样

```shell
服务名
```

- 因此，如果一个 Service 服务的名称为 app-gateway
- 开放的端口为8080的话
- 下面这些地址都能够访问到

```shell
http://app-gateway.default.svc.cluster.local:8080

http://app-gateway.default:8080

http://app-gateway:8080
```

- 对比一下 spring-cloud 中的，也是通过服务名进行访问
- 其实是一样的
- 都不用关系具体的地址，而是直接通过服务名访问即可

## k8s 基础命令

### 常用参数

- 指定命名空间

```shell
-n 指定命名空间，不指定则为默认的default命名空间
```

- 例如

```shell
-n mysql
```

- 指定容器

```shell
-c 指定容器
```

- 例如

```shell
-c app-gateway
```

### 查看版本

```shell
kubectl version
```

### 查看集群信息

```shell
kubectl cluster-info
```

### 查看资源

```shell
kubectl get 资源类型 -n 命名空间
```

- 当命名空间为默认的 default 时，可以不带命名空间
- 资源类型如下

```shell
nodes 集群主机节点Node
po 容器Pod
  别名：pod
svc 服务实例Service
  别名：service
deploy 部署实例Deployment
  别名：deployment
rs 副本集ReplicaSet
  别名：replicaset
cm 配置ConfigMap
 别名：configmap
secret 编码配置Secret
```

- 举例
- 查看mysql命名空间的Pod

```shell
kubectl get po -n mysql
```

- 可以带上wide参数，提供更多详细信息输出

```shell
kubectl get pod -n mysql -o wide
```

- 查看mysql命名空间的服务Svc

```shell
kubectl get svc -n mysql
```

- 查看mysql命名空间的部署实例

```shell
kubectl get deploy -n mysql
```

- 更多例子

```shell
kubectl get rs -n mysql
kubectl get cm -n mysql
kubectl get po
```

### 进入pod容器

- 这个和docker的exec基本是一样的用法
- 格式

```shell
kubectl exec -it Pod名称 -n 命名空间 -- 要执行的入口命令
```

- 举例

```shell
kubectl exec -it mysql-0 -n mysql -- bash
kubectl exec -it nacos -- bash
```

- 一般情况下
- 是先查询有哪些Pod得到Pod名称的
- 也就是这样

```shell
kubectl get po
kubectl exec -it 得到的名称 --bash
```

### 查看Pod日志

- 格式

```shell
kubectl logs Pod名称 -c 容器名称 -n 命名空间
```

- 常用的其他参数

```shell
-f 实时跟踪，和tail -f的含义一样
--tail=N 显示最后的N行，和 tail -n 的含义一样
```

- 举例
- 查看Pod的日志，因为一般情况下，一个Pod只运行一个容器
- 所以，查看Pod日志也就相当于查看容器的日志
- 所以，-c 指定容器是可选的

```shell
kubectl logs nacos
kubectl logs nacos -n nacos-ns
kubectl logs nacos -c nacos-server -n nacos-ns
kubectl logs -f --tail=300 nacos 
```

### 查看Pod描述信息

- 当Pod启动出现异常时，可以查看描述信息
- 判断是在启动的哪个阶段出现的问题
- 用以辅助检查容器的启动状态

```shell
kubectl describe 资源类型 资源名称
```

- 举例

```shell
# 显示某个节点的信息
kubectl describe nodes k8s-node1

# 显示某个POD的信息
kubectl describe po mysql-0

# 也可以这样写
kebuctl describe pods/mysql-0
```

### 创建资源

- 格式

```shell
kubectl create -f 资源配置文件.yaml
```

- 举例

```shell
kubectl create -f app.yaml
```

### 应用资源/更新资源/创建资源

- 这个和create的区别在于自动创建或者更新
- 也就是存在则更新
- 因此也是最常用的一种方式
- 格式

```shell
kubectl apply -f 资源配置文件.yaml
```

- 举例

```shell
kubectl apply -f app.yaml

# 当前目录下的所有yaml配置文件都进行创建
# 这种情况下，因为可能存在某些资源的依赖性
# 一般多执行几次即可
# 逻辑就是，总会有能启动的一些资源
# 当再次应用的时候，之前依赖的资源总有一部分能够启动了
# 多应用几次，就能都全部启动起来了
kubectl apply -f .
```

### 删除资源

- 格式

```shell
kubectl delete 资源类型 资源名称
```

- 举例

```shell
kubectl delete po redis
kubectl delete po redis -n redis-ns
```

## k8s 资源管理（应用管理，服务管理，持久卷管理）

- k8s 的资源管理都是通过RESTful风格的HTTP接口进行管理的
- 也就是在 k8s 的 master 节点中的 api-server 进行处理
- 不过，也提供了命令行接入工具 kubectl 和一些 Web-UI 的管理工具
- 不过，实际上都是和 api-server 进行交互
- 在使用 kubectl 的时候，通常使用 yaml 格式的配置文件进行操作

```shell
kubectl apply -f app.yaml
```

- 所以，当k8s集群搭建完毕之后
- 几乎都是在编写和修改yaml文件
- 实现应用的部署，服务的创建，扩缩容，持久卷的创建等等操作
- 因为万物皆资源，而 yaml 就是管理资源的配置文件
- 所以，说运维 yaml 也没太大问题

## k8s 资源管理的解耦核心（label标签与selector选择器）
- label标签和selector是k8s进行资源关联的核心
- 是为了解决资源关系复杂性而提出来的一种解耦的思想
- 通过给资源添加label标签进行属性划分
- 在通过selector选择器选择一类具备相同label的资源
- 这样就完成了资源关联性的解决
- 这个思想在进行资源配置的时候进行了广泛的使用
- 因此，很有必要了解这个规则

### 引出原因
- 因为k8s中的资源很多，但是主要的资源是Pod
- 但是这么多种类的资源，极大可能都和Pod相关
- 因此，如果每个资源都像数据库一样，使用外键这种方式关联到Pod
- 那这样的管理成本和复杂度就非常高
- 甚至于变得难以维护这种关系
- 举个例子来说
- Service要记录自身关联了哪些Pod，用于流量的转发
- Deployment要记录自身管理了哪些Pod，用于版本管理或者更新操作
- ReplicaSet要记录自己管理了哪些Pod，用于版本管理和更新操作
- 光是这个例子，就不难看出，这是一个多对多的关系
- 最终形成一个图，维护和管理这样的一个图关系非常复杂
- 同时，因为Pod的自恢复，自动扩容等特性
- Pod是不稳定的，可能随时发生变化
- 这样的情况下，维护这个关系，就非常复杂

### 解决方案
- 既然维护这个图关系非常复杂
- 那就不维护这个关系了
- 转而为每种资源提供标签属性(label)
- 这样，各个资源都能有自己的标签划分
- 那怎么获取某一类资源呢
- 实际上，只需要根据标签来获取就行，也就是选择
- 这就是选择器(selector)
- 拥有某一类标签的资源，就是我要管理的资源
- 举个例子来说
- Service是需要知道流量都能够转发到哪些Pod上的
  - 那只需要有一些Pod具有一些指定的标签label
  - 比如：Pod具有这样的一个标签：app=app-auth
  - Service就只需要找到拥有这些指定标签的Pod即可
  - 比如Service选择器（selector）就只需要找到带有app=app-auth标签的Pod即可
- 同样，这也适用于Deployment找到管理的Pod
- ReplicaSet找到管理的Pod

## Pod的探针(Probe) 与 生命周期(Lifecycle)
- Pod 提供了启动探针(startupProbe)、就绪探针(readinessProbe)、存活探针(livenessProbe)
- 提供了初始化容器(initContainer)、容器启动钩子(postStart)、容器关闭钩子(preStop)
- 关于具体的使用，请查看 Deployment/Pod 资源编写章节

### 探针(Probe)
- 可以通过执行命令或者发送HTTP请求的方式
- 确认容器运行的状态
- 启动探针(startupProbe)
  - 在 kind=Deployment 的 spec.template.spec.containers[i].startupProbe 属性中配置
  - 或者 kind=Pod 的 spec.containers[i].startupProbe 属性中配置
  - 用于检测容器是否启动完成
  - 只在容器启动后执行一个探测周期
  - 也就是，探测成功或者失败
  - 探测成功，容器继续运行
  - 探测失败，销毁容器，重新构建新的Pod进行运行
- 就绪探针(readinessProbe)
  - 在 kind=Deployment 的 spec.template.spec.containers[i].readinessProbe 属性中配置
  - 或者 kind=Pod 的 spec.containers[i].readinessProbe 属性中配置
  - 用于检测容器是否已经可以向外提供服务
  - 和启动探针的区别是这样的
  - 举个例子解释下
  - 就比如一个java-web程序
  - 虽然程序已经启动成功了
  - 但是还不能接受HTTP请求
  - 这就能体现二者的区别了
  - 启动探针是用于判断是否启动了
  - 就绪探针适用于判断是否可以向外提供服务了
  - 一般情况下，会留一些时间给启动探针检测启动完成
  - 默认情况下，如果配置了启动探针，在启动探针执行期间，不会运行就绪探针和存活探针
  - 在判断是否就绪
  - 同样在启动后执行一个探测周期
  - 同样，成功继续运行，失败重新启动一个新的Pod运行
- 存活探针(livenessProbe)
  - 在 kind=Deployment 的 spec.template.spec.containers[i].livenessProbe 属性中配置
  - 或者 kind=Pod 的 spec.containers[i].livenessProbe 属性中配置
  - 用于在整个容器运行期间定时的判断容器是否存活可用
  - 一般会等待启动探针、就绪探针完毕之后再开始存活探针
  - 默认情况下，如果配置了启动探针、就绪探针，在启动探针、就绪探针执行期间，不会运行存活探针
  - 同样，在一个探测周期中
  - 探测结果，成功继续运行，失败重新启动一个新的Pod运行

### 生命周期(Lifecycle)
- 初始化容器(initContainer)
  - 在 kind=Deployment 的 spec.template.spec.initContainers 属性中配置
  - 或者 kind=Pod 的 spec.initContainers 属性中配置
  - 在容器运行之前运行，可以限于容器的启动命令执行一些初始化操作
  - 可以有多个初始化容器
  - 多个初始化容器时，按照顺序依次执行
  - 不会并行执行

- 容器启动钩子(postStart)
  - 在 kind=Deployment 的 spec.template.spec.containers[i].lifeCycle.postStart 属性中配置
  - 或者 kind=Pod 的 spec.containers[i].lifeCycle.postStart 属性中配置
  - 在容器启动的同时，异步的并行执行一系列的操作
  - 因此，执行的操作和容器的启动命令是同时运行的
  - 并不能保证二者的先后执行顺序
  - 如果要在启动命令之前执行的话
  - 应该使用初始化容器，而不是启动钩子

- 容器关闭钩子(preStop)
  - 在 kind=Deployment 的 spec.template.spec.containers[i].lifeCycle.preStop 属性中配置
  - 或者 kind=Pod 的 spec.containers[i].lifeCycle.preStop 属性中配置
  - 在容器停止的时候，先执行一系列的操作在关闭容器
  - 容器默认会有一个关闭超时窗口期
  - 允许在这个超时时间内进行一些操作
  - 如果达到了超时时间，关闭钩子依旧没有执行完毕
  - 那么也不会等待关闭钩子执行完毕
  - 这个超时时间由 terminationGracePeriodSeconds 参数决定
  - 默认是 30s
  - 实际上也是异步的并行执行这些钩子

## k8s 资源配置 Yaml 文件编写

- 配置文件就是一个Yaml格式的文件
- 所以也就要求满足Yaml语法格式
- 基础格式

```yaml
# 使用的API版本，各种资源不太一样
apiVersion: v1
# 资源类型，例如：Service,Deployment,Pod,Ingress,ConfigMap,Secrets等等
kind: Service
# 元数据信息，用于描述这个资源的基础属性
metadata:
  # 所属的命名空间，可以不写，不写就是默认的default命名空间
  namespace: app-ns
  # 资源的名称
  name: app
  # 资源有哪些标签，这些标签可以自己随便定义，如果是官方提供的资源，会有一些固定的标签
  labels:
    # 其实就是一些列的键值对，爱怎么写怎么写就行
    k8s-app: app 
    # 可以定义其他的标签，喜欢怎么定义怎么定义
    # 常见的有：
    # tier 前后端类型划分: backend,frontend
    # profile/environment 环境：dev,test,uat,prod
    # version 版本： v1,v2
    xxx: xxx
# 资源的定义，描述了这个资源的内部信息，各种资源的都不一样
spec:
  # 资源的选择器，决定了k8s如果选择哪些资源进行关联
  selector:
    # 有的selector有多种方式，有的就是固定的使用label标签，这里的就是固定label标签的形式，根据资源类型有所差异
    k8s-app: app
  # 其他的资源描述定义属性
  xxx: xxx 
```

- 但是，也有一定的区别
- 允许将多个Yaml文件内容放在同一个Yaml中
- 并且使用三减号分隔
- 例如

```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-svc
spec:
  selector:
    k8s-app: app
# 这里就使用三减号进行分割
---
apiVersion: v1
kind: Deployment
metadata:
  name: app-deploy
spec:
  selector:
    k8s-app: app-deploy
```

- 这样的方式，就方便我们将相关度高的内容
- 都写到一份Yaml中进行描述
- 例如，常见的：Service和Deployment一般就放在一起定义

### Namespace 资源（命名空间配置）

- 命名空间是用来做环境隔离的
- 比如，按照项目隔离，按照环境隔离等
- 下面给出一个案例，结合注释进行说明

```yaml
# 使用的API版本，当前都是固定v1
apiVersion: v1
# 类型，命名空间
kind: Namespace 
metadata:
  # 给定一个命名空间名称就行
  # 可以考虑以 -ns 结尾，或者以 ns- 开头
  # 用以从名称看出资源类型
  name: env-dev-ns 
```

### Secret 资源（配置私有镜像仓库登录信息）

- 主要用于配置私有镜像仓库的登录信息
- 用于能够从私有仓库拉取镜像

- 官网文档

```shell
https://kubernetes.io/zh-cn/docs/concepts/configuration/secret/
```

- 实例配置仓库认证信息

```shell
apiVersion: v1
# 类型 Secret 加密配置，实际上，默认情况下，只是通过base64编码保存而已
kind: Secret 
metadata:
  # 指定资源归属的命名空间，不指定的话默认就是default
  # 一般情况下，在公司内部使用k8s时，都不会使用default
  # 一般都是根据项目划分或者根据环境划分命名空间的
  # 所以，一般建议加上命名空间
  namespace: env-dev-ns 
  # 指定资源名称，记住这个名称，后面在编写Deployment的时候，会在 imagePullSecrets 字段中使用，以完成登录私有镜像仓库，以进行拉取镜像
  # 可以考虑以 -secret 结尾，或者以 secret- 开头
  name: harbor-registry-secret 
# 这里就是固定的，应用在镜像仓库认证信息的这种环境下的时候
type: kubernetes.io/basic-auth 
# 根据type类型的值，这里的写法是多种多样的，在当前这个类型的情况下，就是固定这个格式
stringData: 
  # 一般镜像仓库会使用harbor仓库，这里就填写harbor仓库的用户名密码就行
  username: "admin" 
  password: "harbor12345"
```

### Ingress 资源（南北流量/纵向流量/外部到内部访问）

- 前面说了，Ingress资源使用于外部用户/系统访问到集群内部资源
- 提供了南北流量（纵向流量）的控制和转发
- 因此，如果想要在集群外部访问到集群中的资源服务的时候
- 就需要通过Ingress入口网关才能够访问

- 官网文档

```shell
https://kubernetes.io/zh-cn/docs/concepts/services-networking/ingress/
```

- 下面给出一个案例，结合注释进行说明

```yaml
# 版本是根据资源类型来的，像这里，Ingress的版本就得这样写
apiVersion: networking.k8s.io/v1
# 类型为 Ingress 入口网关
kind: Ingress 
metadata:
  namespace: env-dev-ns
  # 可以考虑以 -ingress 结尾，或者以 ingress- 开头
  name: ingress-gateway
  annotations:
    # 入口网关可以有多重实现，使用nginx实现就是其中的一种
    kubernetes.io/ingress.class: "nginx"
    # 这里路由我们根据路径前缀来进行路由划分，但是转发后的路由，我们需要去除掉前缀，就在这里实现路径重写，治理直接设置为/，这样就能够把前缀去掉
    nginx.ingress/kubernetes.io/rewrite-target: / 
spec:
  rules:
      # 虚拟主机域名，也可以不写这个HOST，直接些HTTP转发规则
    - host: api.project.io
      # 编写HTTP的转发规则
      http:
        # 按照路径进行转发的配置
        paths:
            # 如果以/api开头的，那就转发到app-gateway服务商的8080端口上
          - path: /api
            # 使用前缀模式，还有其他的模式
            pathType: Prefix
            # 指定转发到的端点信息
            backend:
              # 指定服务
              service:
                # 指定转到的目标服务名，这个就对应 kind=Service 的资源配置的 metadata.name 属性
                # 其实这也算是一种selector，只不过是专用在这种场景的
                # 属于按名称选择
                name: app-gateway-svc 
                port:
                  # 指定转到的目标端口
                  number: 8080 
          - path: /web
            pathType: Prefix
            backend:
              service:
                name: app-web-svc
                port:
                  number: 8080
```

### Service 资源（东西流量/横向流量/内部访问）

- 前面说了，Service资源使用于集群内部服务之间相互访问的
- 提供了东西流量（横向流量）的控制和转发
- 因此，如果一个服务A要访问到另一个服务B
- 那么，服务B就应该要提供自己的ServiceB
- 在微服务的体系下，一般都是一个Service和一个Deployment对应

- 官网文档

```shell
https://kubernetes.io/zh-cn/docs/concepts/services-networking/service/
```

- 下面给出一个案例，结合注释进行说明

```yaml
apiVersion: v1
kind: Service
metadata:
  namespace: env-dev-ns
  # 可以考虑以 -svc 结尾，或者以 svc- 开头
  name: app-gateway-svc
  labels:
    k8s-app: app-gateway
    component: gateway
spec:
  # 指定服务的选择器，也就是这个服务要关联到哪些资源，这里其实选择的就是Deployment中定义的资源
  selector:
    # 这里就是在其他资源上定义的标签，选择器的模式是and模式，也就是都要满足
    # 这里这种事labelSelector标签选择器
    # 这里因为是Service，而Service选择时的Pod
    # 所以，这里选择的就是具有这些标签的Pod
    # 对应的就是 kind=Pod 的 metadata.labels 标签
    # 另外，因为一般使用的是Deployment管理Pod
    # 所有，也就是对应 kind=Deployment 的 spec.template.metadata.labels 标签
    k8s-app: app-gateway 
    component: gateway
  # 会话的亲和性，可以用于定义转发的规则，比如实现优先转发到某些特征的Pod节点上
  sessionAffinity: None
  # 类型，NodePort 模式会在对应的Node主机上也开放一个端口，这样就能够直接在宿主机上访问到服务，默认是 ClusterIp, 只能在集群内访问到
  type: NodePort
  # 转发的端口信息
  ports:
      # 端口名称，这个名称可以再其他地方代替端口
    - name: http
      # 协议，默认就是TCP，也支持UDP
      protocol: TCP
      # 服务的暴露端口，所以，就可以通过（服务名：这个端口）访问
      port: 8080
      # 转发到的Pod的端口
      targetPort: 8080 
```

- 使用服务名映射到已有的域名上
- 这样做的好处是统一内部服务的调用逻辑
- 内部服务不必直接和外部服务相关
- 注意，这种方式就是 ExternalName ，只能是域名，不能是IP地址

```yaml
apiVersion: v1
kind: Service
metadata:
  namespace: env-dev-ns
  # 可以考虑以 -svc-ext 结尾，或者以 svc-ext- 开头
  name: app-database-svc-ext
spec:
  # 定义一个类型为外部域名的服务，这种服务映射的就是一个外部的域名主机
  type: ExternalName
  # 外部域名，不能是IP
  externalName: my.database.example.com 
```

- 如果要映射到固定的IP地址
- 那就要结合 endpoint 端点来定义服务
- 也就是 headless 的服务
- 就像下面这样

```yaml
apiVersion: v1
kind: Service
metadata:
  namespace: env-dev-ns
  # 可以考虑以 -svc-headless 结尾，或者以 svc-headless- 开头
  name: app-database-svc-headless
spec:
  # 定义一个无头服务
  clusterIP: None 
  selector:
    # 这种情况下，选择器选择的目标就是 Endpoint
    # 对应的就是 kind=EndpointSlice 的 metadata.labels 属性
    k8s-app: app-database
  ports:
    - protocol: TCP
      port: 1521
      # 这里对应的就是 Endpoint 的连接端口
      targetPort: 1521

---
apiVersion: discovery.k8s.io/v1
# 定义一个网络端点类型的资源
kind: EndpointSlice 
metadata:
  namespace: env-dev-ns
  # 可以考虑以 -es 结尾，或者以 es- 开头
  name: app-database-es
  labels:
    k8s-app: app-database
# 转发的地址类型为IPV4
addressType: IPv4
# 定义端点暴露的端口
ports: 
  - name: http
    protocol: TCP
    port: 1521
# 端点列表
endpoints:
    # 定义端点的IP列表，也就是说可以有多个，例如集群的情况
  - addresses: 
      - "192.168.1.103"
    # 可以编写一些规则来判断端点的可用性
    conditions: 
      ready: true
```

### Deployment 资源（部署管理Pod容器）

- 前面介绍过，Deployment使用于管理Pod容器的
- 提供了容器的部署，升级等操作
- 主要就是使用镜像构建容器进行运行
- 因此，内容也是大体如此的

- 官网文档

```shell
https://kubernetes.io/zh-cn/docs/concepts/workloads/controllers/deployment/
```

- 下面给出一个案例，结合注释进行说明

```yaml
# Deployment 类型的，默认都是 apps/v1
appVersion: apps/v1
# Deployment 类型的资源
kind: Deployment 
metadata:
  namespace: env-dev-ns
  # 可以考虑以 -deploy 结尾，或者以 deploy- 开头
  name: app-gateway-deploy
  labels:
    k8s-app: app-gateway
    component: gateway
spec:
  # 因为这个是Deployment类型的，内部实际上是需要管理Pod的，因此就需要定义管理哪些Pod，就通过这个选择器来决定
  # 这里要选择的目标就是一类Pod
  # 因此这里的selector就是为了选择出Pod的
  # 在资源定义中，对应 kind=Pod 的 metadata.labels 属性
  # 因为一般都是使用Deployment管理Pod
  # 所以，也就是对应 kind=Deployment 的 spec.template.metadata.labels 属性
  selector:
    # 使用标签进行匹配，这个匹配的其实就是本配置的 spec.template.metadata.labels 的内容
    matchLabels: 
      k8s-app: app-gateway
      component: gateway
  # 除了selector之外的其他属性，实际上都可以认为是为了给 ReplicaSet 使用的
  # 但是因为 ReplicaSet 是为了进行历史版本替换的，所以也就没有表现出来
  # 所有会有一种 ReplicaSet 与 Deployment 配置重叠的感觉
  # 定义副本数
  replicas: 3
  # 定义更新策略
  strategy:
    # 使用滚动更新，也就是必须保证服务的不间断，实现无感更新
    type: RollingUpdate
    # 滚动更新的配置
    rollingUpdate:
      # 配置替换了多少个Pod之后认为是可用的
      maxSurge: 100%
      # 配置任务多少个Pod未启动认为是不可用的
      maxUnavailable: 100%
  # 定义创建Pod的模版，也可以认为是创建 ReplicaSet 的模版，这部分就可以对比 docker-compose的配置了
  # 实际上，这个部分的配置内容，和 kind=Pod 类型的资源定义是一模一样的
  # 这里相当于内嵌了 Pod 的资源配置
  template: 
    # 所以来说，这个部分就是 kind=Pod 资源的配置
    metadata:
      labels:
        k8s-app: app-gateway
        component: gateway
    # 定义如何产生一个Pod
    spec:
      # 初始化容器
      # 可以不配置
      initContainers:
        - name: init-nginx
          image: nginx
          imagePullPolicy: IfNotPresent
          command: ["sh","-c","echo init ..."]
      # 指定拉取镜像使用的Secret认证信息
      imagePullSecrets: 
          # 这个就是前面定义的一个用于保存harbor私服镜像仓库的登录信息
        - name: harbor-registry-secret
      # 定义Pod内部的容器，我们说过，一般情况，一个Pod只放一个容器
      containers:
          # 容器的名称
        - name: app-gateway
          # 镜像名称
          # 例如这个镜像名称，就表示从 192.168.1.101:5000 主机的仓库
          # 拉取 env-dev/app-gateway:v1.0  镜像
          # 其中 env-dev 部分，可能是租户名称，或者项目名称
          # 每个仓库的概率不太一样，dockerhub就表示注册的用户名
          # harbor仓库就表示自定义的项目名
          image: 192.168.1.101:5000/env-dev/app-gateway:v1.0 
          # 镜像的更新策略，是否每次都重新拉取镜像
          # 如果管理上对版本控制相当好，保证每次操作都会产生一个新的镜像版本，那就可以使用默认值 IfNotPresent 如果不存在则拉取
          # 但是如果没有严格的镜像版本控制，建议使用 Always 始终拉取镜像
          # 可以不配置
          imagePullPolicy: Always
          # 定义容器暴露的端口
          # 可以不配置
          ports: 
            - name: http
              protocol: TCP
              # 容器暴露的端口
              containerPort: 8080
          # 定义容器运行终止之后保存终止消息的位置
          # 可以不配置
          terminationMessagePath: /dev/termination-log
          # 终止信息的策略类型
          # 可以不配置
          terminationMessagePolicy: File
          # 定义挂载的卷
          # 可以不配置
          volumeMounts:
              # 这里实际上是下面定义的卷的名称
            - name: app-yml
              # 定义挂载到的容器内的路径，这样整个路径都会被替换
              # 如果之前路径下有文件，会被完全替换，不会说有则覆盖无则保留
              mountPath: /app/resources/bootstrap.yml
              # 但是，这里要做的就是有则覆盖，无则保留，因此就要配合subPath定义哪些直接替换
              # 导致上面的mountPath也变为一个具体的文件名而不是目录名
              subPath: bootstrap.yml
          # 定义资源限制，用于进行自动扩缩容
          # 可以不配置
          resources:
            # 建议的初始资源或者一般情况下的资源
            requests:
              # 1000m表示一个CPU核心，300m就表示0.3个核心就够了
              cpu: 300m
              # 默认使用的内存大小，单位就是MB
              memory: 512Mi
            # 定义最大扩容允许使用的资源数量
            limits:
              # 按照这个配置，也就是说允许再扩容1个Pod，因为内存比默认的大1倍
              cpu: 1000m 
              memory: 1024Mi
          # 生命周期钩子
          # 可以不配置
          lifeCycle:
            # 启动钩子
            postStart:
              # 这里就简单给一个示例
              exec:
                command:
                  - sh
                  - "-c"
                  - "echo start ..."
            # 停止钩子
            preStop:
              exec:
                command:
                  - sh
                  - "-c"
                  - "echo stop ..."
          # 容器就绪探针配置，用于判断容器是否已经启动完毕
          # 可以不配置
          readinessProbe:
            # 通过发起HttpGet请求判断，如果相应的是200-400之间的HTTP状态码，则认为启动完毕
            # 比如，如果是springboot项目，可以集成actuator
            # 暴露 /heath 就可以达到目的
            httpGet:
              # 定义请求的路径和端口
              path: / 
              port: 8080
            # 容器启动后的60秒后开始检查是否就绪，如果在配置了启动探针的情况下，这个时间就相当于等待启动探针结束
            initialDelaySeconds: 60
            # 请求超时时间为5秒
            timeoutSeconds: 5
            # 最大失败次数为3，也就是说，如果三次都失败了，那么就认为容器启动失败，无法就绪，k8s就会销毁这个Pod，重新创建一个Pod替换
            failureThreshold: 3
            # 间隔时间，也就是从容器启动60秒之后，每隔10秒检查一次容器是否就绪
            # 如果3次失败，则无法就绪，重建Pod，否则任务已经就绪，后续不在进行就绪检查
            periodSeconds: 10 
          # 容器的存活探针配置，用于判断容器是否还存活，该探针如果在已经配置就绪探针的情况下，会等待就绪探针完毕之后才进行
          # 可以不配置
          livenessProbe: 
            httpGet:
              path: /
              port: 8080
            initialDelaySeconds: 60
            timeoutSeconds: 5
            failureThreshold: 3
            # 这里的配置就是，容器启动60秒后，等待就绪探针完毕，每隔10秒检查一次容器是否存活
            # 如果连续3次失败，则认为容器不再存活，将会进行重建Pod
            periodSeconds: 10 
          # 容器的启动探针配置，用于判断容器是否已经启动，这个探针是最先执行的，也是执行一次，不像存活探针，一直监听
          # 可以不配置
          startupProbe:
            httpGet:
              path: /
              port: 8080
            # 成功多少次就认为启动成功
            successThreshold: 1
            timeoutSeconds: 5
            failureThreshold: 3
            # 这里的配置就是，每隔10秒检查一次容器是否启动，只要成功检查一次，就认为启动成功
            # 如果连续3次失败，则认为容器不再存活，将会进行重建Pod
            periodSeconds: 10
      # 定义挂载卷
      # 可以不配置
      volumes:
          # 定义卷的名称，上面已经使用了这个卷名称挂载
        - name: app-yml
          # 这个卷是一个ConfigMap类型的
          configMap:
            # 这里就是ConfigMap资源的名称
            name: app-gateway-yml
            # 可以定义这个ConfigMap中的哪些资源添加到卷中，如果不写items，那就是默认全部
            items:
                # key 定义卷中的名称，Path定义ConfigMap中的资源名称，也就是实现了一个重命名
              - key: bootstrap.yml 
                path: bootstrap.yml
      # DNS策略，这里配置了 ClusterFirst 集群的DNS优先，也就是优先从集群的DNS查找，找不到在找NodePort主机的DNS
      # 可以不配置
      dnsPolicy: ClusterFirst
      # 重启策略，也就是当服务异常挂掉的时候，判断是否需要进行重启，这里配置 Always 也就是始终都要重启，一旦挂掉就重启
      # 可以不配置
      restartPolicy: Always
      # 在容器销毁的时候，是允许有一个关闭前的窗口的，允许进行一些操作在关闭容器，比如记录错误日志等
      # 可以不配置
      terminationGracePeriodSeconds: 30 
```


### Pod 资源（管理Pod容器）

- 前面介绍过，Deployment使用于管理Pod容器的
- 但是，我们也可以直接管理Pod资源
- 但是不建议这样使用
- 只建议在测试构建Pod的时候进行测试使用
- 因为直接使用Pod这种，可能会给集群资源管理造成一些混乱

- 官网文档

```shell
https://kubernetes.io/zh-cn/docs/concepts/workloads/pods/pod-lifecycle/
```

- 下面给出一个案例，结合注释进行说明
- 前面在 Deployment 资源中说了，kind=Deployment 的 spec.template 属性就是Pod的配置
- 因此，一些其他的配置，就在这边进行讲解了
- 不在添加到Deployment中进行说明

```shell
apiVersion: v1
kind: Pod
metadata:
  namespace: default
  name: nginx-pod
  lables:
    k8s-app: nginx
    version: 1.0
spec:
  containers:
    - name: nginx
      # 这里直接使用官网仓库拉取镜像
      image: nginx:1.7.9
      # 这里拉取镜像的策略是，本地没有就拉取，有就不再拉取
      imagePullPolicy: IfNotPresent
      # 定义了容器启动后执行的命令
      # 实际上就是执行： nginx -g 'daemon off;'
      # 用于将nginx进行前台运行
      command:
        - nginx
        - "-g"
        - "daemon off;"
      # 设置工作路径
      workingDir: /usr/share/nginx/html
      ports:
        - name: http
          protocol: http
          containerPort: 80
      # 设置容器的环境变量
      env:
        # 可以设置多个环境变量
        # 都以name-value键值对的方式定义
        - name: APP_ENV
          value: "dev"
      resources:
        requests:
          cpu: 100m
          memory: 128Mi
        limits:
          cpu: 500m
          memory: 512Mi
      restartPolicy: OnFailure
```

## spring-cloud 微服务部署到k8s
- 想要spring-cloud项目部署到k8s中
- 就需要了解基础的对应关系以及需要修改的点

### 体系对照
- Spring Gateway/Nginx 与 K8s Ingress
  - 都是作为流量入口
  - 都实现了负载均衡
  - 都是将流量转发都服务
  - spring-cloud 体系
    - 转发基于spring-cloud体系的服务注册与发现
  - k8s 体系
    - 转发基于k8s的服务注册与发现
    - 实际是基于DNS解析实现转发和负载均衡
- Spring Euraka/Spring Nacos 与 K8s 集群
  - 都是作为服务注册、服务发现的载体
  - spring-cloud 体系
    - 注册中心保存了应用名和HTTP端口的关系信息
    - 能够通过服务名称直接负载访问到对应的实例的IP和端口
  - k8s 体系
    - k8s 集群通过维护metadata元数据信息以及集群的DNS信息
    - 实现了将服务名转换为DNS名的转换
    - 能够通过服务名称直接负载访问到对应的IP
    - 因为是基于DNS解析的，因此，并不会维护端口的信息
- Spring Config/Spring Nacos 与 K8s ConfigMap/K8s Secrets
  - 都是作为环境变量，提供动态配置变更的能力
  - spring-cloud 体系
    - 是基于RPC/HTTP主动推送或者定时拉取配置的方式实现配置的更新
    - 与Spring的体系结合性好，可以实现不用重启应用就更新配置
  - k8s 体系
    - 是基于环境变量/配置文件挂载的方式实现配置的更新
    - 因此，对应运行在容器中的应用来说
    - 需要主动的判断环境变量或者配置文件变动的监听
    - 否则，并不能实现动态配置更新
    - 需要实现动态更新的效果，只能是通过更新 Deployment 资源
    - 利用滚动更新机制实现配置的更新
    - 虽然这样，但是因为滚动更新的机制
    - 对于用户来说是无感的
    - 因此，对于用户来说，也算是不用重启应用就更新配置了
- Spring Boot 应用 与 K8s Service/K8s Deployment
  - 都是作为整个集群中的一个服务
  - 能够被其他服务进行访问，也可以访问其他服务
  - spring-cloud 体系
    - 依赖于注册中心，提供了应用名与应用实例的对应关系
    - 基于此能够实现基于负载均衡的服务间调用
  - k8s 体系
    - 依赖于 k8s 集群维护的 DNS 信息
    - 提供了服务名与Pod实例的对应关系
    - 基于此能够实现基于负载均衡的服务间调用

### 对应关系
- 一个微服务，就对应了k8s中的一个 Service 资源 和 一个 Deployment 资源
  - Deployment 负责部署微服务
  - Service 负责暴露内部调用的网络端点
  - 如果，这是一个定时任务性质的微服务，不存在微服务之间的调用
  - 那么就可以不需要 Service 资源
- 特殊的就是应用网关和前端
  - 这两个也可以看作是一个微服务
  - 但是区别是，这两个因为要保留给外部访问
  - 也就是提供给用户访问
  - 所以，还需要为他们建立一个 Ingress 资源
- 一般情况
  - 一个项目，前端和Spring Gateway 公用一个 k8s 的 Ingress 入口网关资源
  - 其他的每个SpringBoot微服务，都添加一个 k8s 的 Service 和 Deployment 资源
  - 前端也对应一个 k8s 的 Service 和 Deployment 资源
  - 依赖的中间件例如 Nacos,Redis,Seata,Xxl-Job-Admin 等这样的
    - 一般也是一个 k8s 的 Service 和 Deployment 资源
  - 但是，数据库，Redis，Kafka等这些，原则上不太建议使用k8s部署
  - 因为这些基本上都是有状态的应用
  - 硬要部署也是可以的

### 修改点
- 服务之间的调用地址的确定
  - 如果，在使用了例如 Euraka/Nacos 等这样的注册中心的情况下
  - 那么这些调用时可以不变的
  - 原来怎么用还是怎么用
  - 包括引用了例如：OpenFeign,LoadBalancer等的组件
  - 这些不需要变动
  - 因为注册中心会自动管理IP，即使k8s集群中的IP会动态变动
  - 但是，注册中心的目的就是为了管理动态变动的IP
  - 所以，这一点是不影响的
  - 还是通过spring的应用名来进行调用即可
    - spring.application.name 应用名
  - 举例说明：
    - lb://app-auth/user/info
    - http://app-system/dict/list
    - 注意，这里的 app-auth, app-system 是 spring.application.name
    - 这样的话，那走的就是 spring-cloud 的注册中心，进行的服务发现，进行的负载均衡的调用
    - 但是，如果是这样的
    - http://k8s-app-auth:8080/role/list
    - http://nacos.env-dev:8848/
    - 那么，这里的 k8s-app-auth 就可能是 k8s 的服务名
    - 这里的 nacos.env-dev 就是 k8s 的服务名和命名空间
    - 这种就走的是 k8s 的服务发现，进行的也是 k8s 的负载均衡的调用
    - 用的就是 k8s 的 DNS 解析
    - 为什么说，这种基本上是 k8s 的调用
    - 因为，spring-cloud调用的情况下，是不需要指定端口的
    - 但是，不是spring-cloud的情况下，也就是普通调用，是需要指定端口的
- 和中间件的调用地址的确定
    - 中间件因为一般都不会注册到spring-cloud这一套的注册中心上
    - 例如：Redis，kafka,RabbitMq等，甚至是mysql等的数据库
    - 这类的资源，一般情况下IP是固定的
    - 如果是部署在k8s集群里面的中间件
      - 那么，直接使用k8s的Service的名称作为DNS即可
      - 比如，假如 Redis 部署在k8s中，Service 资源的名称是 redis，所属的命名空间是 env-dev，Service 服务的的端口是 6379
      - 那么，访问地址就按照k8s访问的规则来就行
      - 也就是：服务名.命名空间.svc.集群名
      - 也就是说，这样的地址就是可以的：redis.env-dev.svc.cluster.local:6379
      - 根据k8s的DNS规则，这些也都是可以的，根据实际情况选择：redis.env-dev:6379 或者 redis:6379
    - 如果是集群外部的资源，可以直接使用IP访问或者域名访问
      - 但是，建议配置一个无头服务进行关联
      - 必要的情况下，配合上一个 Endpoint 端点进行配置
      - 这样的话，实际上，也还是基于k8s的服务名进行调用
    - 举例说明：
      - redis:6379
      - http://nacos.env-dev:8848/
      - http://nginx:8080/
      - 这样的，通过k8s的服务名，也就是k8s的DNS访问的
      
## Istio 服务网格（ServiceMesh）承担的角色及作用
- istio 是一个服务网格的实现
- 基于 Envoy 代理实现注入 Sidecar 代理服务的进出口流量
- 具体来说，Sidecar 模式下，istio将会自动在每个运行的Pod中注入一个 Envoy 代理
- 一个Pod里面不是可以包含多个容器吗，Sidecar模式下就是在Pod中添加了一个 Envoy 代理容器
- 让 Envoy 代理和业务容器一起部署
- 基于此，提供了对流量的一些列操作和控制
- 例如：负载均衡，熔断，重试，认证，灰度发布，蓝绿发布等系列的操作
- 因此，其作用就是一个流量代理分发的角色
- 对每个服务都进行了流量代理，因此进行的都是和流量相关的操作
- 也就是和网络相关的操作
- 同时提供了Filter，Listener这样的拓展
- 也就是说，能够基于流量处理的逻辑，都能够在istio中实现
- 其运行原理是启动了一个代理进程，实现透明代理进出口流量
- 可以更加细致的进行流量控制
- istio 并不是一定要在k8s中使用
- 它实际上可以脱离k8s独立使用
- 也具有自己的数据平面和控制平面

### 在k8s中的作用
- 在k8s中，模式是使用Kube-Proxy完成流量到容器内部的代理的
- 控制粒度比较粗，支持的协议也有限
- istio进入之后，Envoy代理就替代了Kube-Proxy的作用
- 所有的出入口流量都经过Envoy代理，因此Envoy可以对流量进行一系列的操作
- 能够提供更加细致的流量控制，支持的协议也更加的多
- 实际上，istio提供了一系列的资源，例如：VirtualService,DestinationRule,Gateway等
- 用于对原本k8s中的资源进行包装或者代理
- 使得原本的流量都通过istio代理之后进行路由
- 从这里也就能看出，虽然提供了更加细致化的流量控制
- 但是因为都要经过istio的代理，整个流量调用经过的节点就变多了
- 也就会带来一部分的网络传输开销

### 在k8s中使用istio
- 可以查看这篇讲解
- [k8s-istio.md](k8s-istio.md)
```shell
k8s-istio.md
```


## DevOps 体系中的应用
- 此章节，请查看如下文件
- [devops.md](devops.md)
```shell
devops.md
```