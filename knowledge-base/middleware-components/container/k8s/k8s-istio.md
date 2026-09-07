# istio(ServiceMesh) 服务网格在 K8S 中的使用

- 详细可以查看这个博主的博客
```shell
https://www.cnblogs.com/vitochen/p/18934987#_lab2_1_1
```

## 基础概念

### 服务网格（ServiceMesh）是什么

- 服务网格是一个理念
- 这个理念描述了为支撑复杂的云原生应用服务自己拿的网络通信的基础设施层
- 承担起提供基础的服务间网络调用、限流、熔断、监控、路由、安全等功能
- 且对服务无感知的网络层面的基础设施
- 通常表现形式为轻量级的网络代理阵列
- 代理服务通常与应用服务部署在一起，代理应用服务的流量，对应用服务来说是无感知的，透明的
- 因此，是一个用来专门处理网络流量转发的基础设施

### istio是什么

- istio 是目前服务网格理念的代表作
- 也就是说，实现了服务网关理念的功能
- 实际上也是如此
- istio的工作模式就是使用Sidecar边车模式
- 将Envoy代理和应用服务部署在一起，代理应用服务的流量
- 对于应用服务来说是无感知透明的
- 提供了流量控制、转发、限流、重试等流量方面的操纵能力
- 应用服务实际上只与Envoy进行流量交互
- 而服务之间的流量交互，全部都交给了Envoy构建的代理层进行交互
- 所以，如果叫应用暂且剔除的话，整个集群实际上就是许多的Envoy之间的网络通信
- 此时就可以把Envoy看做是一个路由器，和其他网络进行交互
- 而应用服务只和路由器通信
- 实际上的工作流程也基本如此

### 在k8s中的工作原理

- 实际上是在容器中注入了启动容器，在服务的容器启动之前，调整了转发规则
- 使得流量都转发给Envoy代理容器
- 从而实现了透明代理
- 因为这一层面，发生在启动容器中，这时候服务的容器还未启动
- 其中发生的变更对服务来说是无感知的
- 修改的是主机中的转发规则，对应用程序来说也是无感知的
- 所以整体上，是无感知的，透明的

## 组成部分

### 控制平面

- 主要包括Mixer,Pilot,Citadel等组件
- 控制平面不直接解析数据包
- 主要是与控制平面中的代理通信，起到下发策略与应用配置的作用
- 另外还负责对网络行为的可视化
- 提供了 istioctl 等工具来控制配置信息

### 数据平面

- 主要包括Envoy等组件
- 主要按照无状态设计，因为实际上只是提供流量操作和控制
- 一般来说并不需要有状态的支持
- 另一方面，为了提高流量转发性能，也会有一些缓存策略加速
- 所以，也算是有状态
- 只不过这种状态的丢失是可以接受的
- 算是无状态的也没有问题
- 主要是处理进出口数据包，进行转发、路由、负载、认证等网络方面的操作
- 对应用服务来说是透明的，可以做到无感知

## 流量路径

### 南北流量（纵向流量/外部流量）

- 用户
- k8s Ingress 网关
- istio Gateway 进出口网关
- istio VirtualService 虚拟服务
- istio DestinationRule 转发规则
- k8s Service 服务
- 主机
- istio Envoy 代理
- Pod容器

### 东西流量（横向流量/内部流量）

- 微服务A
- k8s Service服务B
- istio VirtualService 虚拟服务B
- istio DestinationRule 转发规则B
- k8s Service 服务 B
- 主机
- istio Envoy 代理
- Pod容器 B
- 微服务B

## 组件介绍

### Envoy 代理

- Envoy代理实际上是一个独立的高性能代理服务
- 也就是说，是istio将Envoy集成进来
- 并修改了一些拓展特性
- Envoy代理提供了更加强大的代理能力，相比较于传统的HTTP代理
- 还提供了，HTTP，RPC，gPRC,WebSocket,TCP,UDP等层面的代理
- 提供更加细粒度的网络控制
- 提供自定义的流量路由规则和控制规则
- 提供诸如熔断、重试、负载、降级、故障转移等能力
- 还有拓展的安全、认证、流控等方面的能力

### Istiod 控制器

- istiod 控制器将Pilot，Galley，Citadel等功能统一封装在一起
- 负责将控制平面的流量控制规则转发给Envoy代理
- 从而使得流控规则的实时生效

### Gateway 进出口网关

- 在安装istio的时候
- 就会安装 istio-ingressgateway(进口网关)
    - 负责接收入站流量，转发到集群内部
- 还有 istio-egressgateway(出口网关)
    - 负责将集群内部的流量，转发到集群外部
- 实际上的作用和k8s原本的Ingress网关类似
- 主要就是起到一个负载均衡转发的功能
- 将流量转发到对应的hosts的VirtualService上去
- 也许，你会有个疑问，都有了Ingress了，还要这个Gateway干嘛
- 其实，istio是对k8s的拓展
- 并不是替代k8s的功能
- 所以，Gateway的作用就是
- 用ingressgateway将流量转入istio构建的ServiceMesh服务网格中
- 用egressgateway将流量从ServiceMesh服务网格中转出
- 怎么理解了？也就是说，如果不流入服务网格
- 那么久还是原来的k8s功能
- 流入了服务网格，那么久进入了istio构建的体系中
- 也就是，istio在k8s的基础上拓展出了一层

```yaml
 apiVersion: networking.istio.io/v1alpha3
 kind: Gateway
 metedata:
   namespace: default
   name: istio-gateway
 spec:
   selector:
     istio: ingressgateway
   servers:
     - port:
         name: http
         protocol: HTTP
         number: 8080
       hosts:
         - dev.sample.com # 对应了 istio VirtualService 中的 host
         - test.sample.com
```

### VirtualService 虚拟服务（DestinationRule 转发规则）

- VirtualService 和 DestinationRule 是两个重要的配置资源
- 定义了服务间的通信规则和路由转发规则
- VirtualService 定义了路由规则，描述满足条件的请求分配到哪里去
    - 包括，金丝雀发布，URL等的路由规则，超时，成功时，流量镜像，流量切分等
- DestinationRule 定义了VirtualService虚拟服务路由的目标的真实地址
    - 包括负载均衡，熔断等
- 编写 VirtualService

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metedata:
  namespace: default
  name: service-b
spec:
  hosts:
    - dev.sample.com # 对应 istio Gateway 中配置的 host
    - test.sample.com
  http:
    - route:
        - destination: # 目标服务，一般对应的就是 k8s Service，与 DestinationRule 中的host和subset一致
            host: service-b # 就是 k8s Service 的名称，也就是 service-b.default.svc.cluster.local
            subset: v1 # subset 在 DestinationRule 中使用
```

- 编写 DestinationRule

```yaml
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  namespace: default
  name: service-b
spec:
  host: service-b # 这个和 VirtualService 中的 destination.host 一致
  trafficPolicy:
    loadBalancer:
      simple: RANDOM
  subsets:
    - name: v1 # 这个名称和VirtualService中的subset一致
      labels:
        version: v1
    - name: v2
      labels:
        version: v2
```

### ServiceEntry 服务入口

- 实际功能和k8s中的Service类似
- 不同的是，ServiceEntry 可以指向外部地址
- 下面以定义到百度的配置为例
- 编写 VirtualService

```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  namespace: default
  name: baidu-vs
spec:
  hosts:
    - www.baidu.com
  http:
    - route:
        - destination:
            host: www.baidu.com
            port:
              number: 80
      timeout: 1ms
```

- 编写 ServiceEntry

```yaml
apiVersion: networking.istio.io/v1beta1
kind: ServiceEntry
metadata:
  name: baidu-se
spec:
  hosts:
    - www.baidu.com
  location: MESH_EXTERNAL
  ports:
    - name: http
      number: 80
      protocol: HTTP
  resolution: DNS 
```

- 编写 DestinationRule

```yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: baidu-dr
spec:
  host: www.baidu.com
  trafficPolicy: # 流量策略,包括：负载平衡策略、连接池大小、异常检测
    loadBalancer: # 默认LB策略
      simple: ROUND_ROBIN # ROUND_ROBIN-循环,LEAST_CONN-最小连接,RANDOM-随机,PASSTHROUGH-只连
```