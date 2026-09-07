# docker usage

---

## intro
- docker 依赖于Linux内核，因此要运行docker就必须要有一个Linux内核
- 什么是Linux内核？和常说的Linux系统什么关系？
- Linux kernel(linux内核)是Linux系统的核心
- 提供了最基本的内核管理（作业调度、进程调度、网络调度、文件调度等）
- 在其基础上，推展除了各种Linux发行版（redhat,centos,deepin,ubuntu...）
- 也就是说，centos系统=Linux内核+centos发行版
- 类比来说：
- android 系统，提供了最核心的功能
- 其他android开发商基于android拓展出了flyme,miui,colorOs...
- docker 通过Linux内核提供的隔离能力
- 采用多层文件系统，分离出每一层
- 最底层，当然是Linux内核
- 一般的第二次就是一个Linux发行版
- 下面依次叠加更高的层

## docker的分层
- 首选举个例子来看一下
- 0.linux内核层（操作系统提供，docker共享内核）
- 1.centos发行版（docker提供，借助共享的内核）
- 2.jdk/jre/jvm层（docker提供，用于提供java开发或运行的环境）
- 3.tomcat层（docker提供，用于运行java的web程序）
- 4.web程序层（用户提供，将其放入上一层的tomcat中运行）
- 每一层，都是独立的层，也就是如此
- 在docker镜像下载时，会分别下载每一层
- 如果本地已经存在这一层了，那么直接使用，不再重复下载
- 也就是如此，每一层只需要下载一次
- 所以，就算docker镜像看起来那么大，但是实际上，重复的层是复用的
- 实际占用空间并没有那么大

## 固件层和读写层
- 上面的例子中，是一个典型的场景，每一层都依赖于上一层的基础运行
- 其中0-3层可以是一个固定的镜像层，不需要进行改动
- 而，第4层则是用户自己进行交互的层
- 但是，不可避免的会遇到需要修改底层参数的情况，例如修改tomcat配置，修改centos配置等
- 这些修改都不会直接修改底层固有的配置
- 底层的配置都是只读的
- docker采用了分层的方式，将每一层的修改记录保存下来，在运行时覆盖的方式，达到可以修改
- 对于特殊的，删除配置文件这些方式，也是作为修改记录保存下来，这样的被标记为删除，运行时不再加载
- 因此，镜像是固定的，而镜像运行生成的容器示例是可变的

---

## docker的基本操作

### 安装docker
- 这部分比较简单，如果是centos7,提供了一份脚本，在./install/centos7/docker-install.sh
- 按照脚本执行即可

### docker的运行原理
- 可以参考git的使用原理
- 在dockerhub中search需要的镜像

```shell
docker search nginx
```

- 将需要的镜像pull到本地

```shell
docker pull nginx
```

- 检查本地有哪些镜像images

```shell
docker images
```

-
- 运行一个指定的镜像run生成一个容器container
- 参数解析
    - -d 指定为后台运行
    - --rm 指定运行结束之后，删除容器，注意是容器，而不是镜像
    - -it 提供一个交互式的终端-i,-t
    - -p 指定将主机的8080端口映射到容器的80端口
    - -v 指定将主机的/data/nginx映射为容器的/data
    - nginx 镜像名称
    - /bin/bash 进入容器后运行的命令
- 因此，这条命令就是运行nginx，并以终端进入，使用的bash终端
- 同时，需要注意的是，容器内必须有一个前台进程在运行，否则容器会自动关闭

```shell
docker run -d --rm -it -p 8080:80 -v /data/nginx:/data nginx /bin/bash
```

- 最简单的后台运行方式

```shell
docker run -d nginx
```

- 最简单的方式

```shell
docker run nginx
```

- 其他的启动参数
    - --name 指定容器名称，在ps中更好看
    - -P 大P表示随机端口映射
    - -p :80 将容器中的80端口随机映射到主机端口
- 查看正在运行的容器ps

```shell
docker ps
```

- 对于已经关闭的容器，查看需要带上-a参数

```shell
docker ps -a
```

- 如果想要看完整的docker的启动命令
- 也就是在 DOckerfile 中写的 ENTRYPOINT 的实际运行值的话
- 可以这样看，不截断命令，并使用JSON格式输出

```shell
docker ps --no-trunc --format json
```

- 进入一个正在运行的容器exec
    - 使用docker ps之后，会方辉container id容器ID
    - 在后续对容器进行操作都是基于这个容器ID的
    - 容器ID完整的是SHA256的值，ps显示的是前面的一部分
    - 但是基于操作上来说，一般使用容器ID的前3位即可
    - 其他的参数，和run基本一致
    - 一般来说，进入容器是想要进行操作的，因此指定-it和指定一个终端bash/sh是必要的

```shell
docker exec -it 容器ID bash
```

- 停止指定的容器stop

```shell
docker stop 容器ID
```

- 启动已经停止的容器start

```shell
docker start 容器ID/容器名
```

- 重启容器start

```shell
docker restart 容器ID/容器名
```

- 删除指定的容器rm
    - 在镜像还有使用他的容器时，镜像不允许删除

```shell
docker rm 容器ID
```

- 删除指定的镜像rmi

```shell
docker rmi 镜像名称
```

- 提交自己对镜像的修改commit
    - 将容器中的修改提交成为一个镜像
    - 通过-t指定镜像名称，否则默认只有容器ID，在docker images中

```shell
docker commit 容器ID -t 镜像名称
```

- 保存自己的镜像save

```shell
docker save 镜像名称 -o 保存的镜像文件名
```

- 载入别人分享的镜像load

```shell
docker load -i 加载的镜像文件名称
```


- 同时，你也可以在dockerhub上注册自己的账号，将自己创建的镜像，提交到远程
- 这里不给出

### 普通用户使用docker

- 默认情况下，docker是运行在docker组的
- 使用root用户访问是正常的
- 但是使用普通用户访问时，可能会提示权限不足
- 这种情况下，只需要将用户添加到docker组中即可
- 下面这条命令就将app用户添加到docker组中了

```shell
usermod -aG docker app
```

### 容器的开机自启动

- 配置单个容器

```shell
docker update --restart=unless-stopped 容器名称
```

- 举例

```shell
docker update --restart=unless-stopped jenkins
```

- 验证配置

```shell
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' 容器名称
```

- 举例

```shell
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' jenkins
```

- 应该输出看到如下的关键字

```shell
unless-stopped
```

- 配置所有容器都默认自启动
- 编辑配置文件

```shell
vi /etc/docker/daemon.json
```

- 添加如下配置

```json
{
  "default-restart-policy": "unless-stopped"
}
```

- 需要重启docker

```shell
systemctl restart docker
```

### 清理docker空间

- 使用命令进行一键清除未使用的镜像，容器，缓存

```shell
docker system prune
```

- 会提示是否进行删除
- 确认删除即可
- 也可以使用静默删除

```shell
docker system prune -a
```

### Dockerfile 自定义镜像
- 上面说了，可以使用commit+save+load方式实现自定义镜像
- 但是这种操作可能还是比较麻烦
- 因此，借助Dockerfile就能够生成一个镜像
- 使用上类似Makefile
- 在Dockerfile所在路径执行docker build .即可
- Dockerfile因为docker的分层原理，因此也是根据层进行的
- 使用上类似maven，需要指定一个FROM，也就是基本层parent
- 至少有一个FROM，毕竟至少得有一个Linux发型版吧，特殊情况除外
- 几个主要组成部分
    - FROM 制定一个父镜像
    - RUN 执行一个Linux命令
    - COPY 将主机中的文件拷贝到容器中
    - CMD 指定要运行的程序或者命令
        - 当ENTRYPOINT指定时，退化为ENTRYPOINT的参数
        - 同时CMD能够在容器运行时，被运行参数覆盖，因此可以作为默认参数使用
    - ENTRYPOINT 指定容器的入口点，也就是要运行的程序或命令
- 下面给出一个，运行指定jar包的Dockerfile的编写内容

```shell
# 指定父层，为一个具有openjdk8的基础层，因此，这一步就已经具有java8的环境了
FROM openjdk:8-jdk-alpine

# 在主机中用一个匿名的文件夹挂载为容器中的/tmp
VOLUME /tmp

# 将主机中的app.jar拷贝到容器中的/apps/app.jar
COPY app.jar /apps/app.jar

# 这里同时指定了CMD和ENTRYPOINT，因此CMD退化为ENTRYPOINT的参数
CMD ["--boot.env=docker"]

# 容器的入口点，因此在容器启动时，就运行了这条命令
ENTRYPOINT ["java","-jar","/apps/app.jar"]
```

- 因此这个容器默认启动运行的命令为：

```shell
java -jar /apps/app.jar --boot.ent=docker
```

- 又因为，CMD能够被启动参数覆盖
- 假定启动命令为

```shell
docker run -d --rm test-jar-img --server.port=8080
```

- 则实际执行的命令是

```shell
java -jar /apps/app.jar --server.port=8080
```

- 现在Dockerfile文件编写好了
- 主要注意的是，Dockerfile的这个文件名，必须是这个，大小写也要一致
- 除非某些Linux对于文件大小写文件名不敏感，则大小写可以不一致
- 为了保证纯净，单独放到一个干净的文件夹中
- 另外，Dockerfile中，指定了，需要一个app.jar
- 这里随便准备一个springboot的jar
- 一并放进去

```shell
/jar8env
    Dockerfile
    app.jar
```

- 进入此路径并构建得到镜像

```shell
cd jar8env
docker build . -t test-jar-img
```

- 这样，就得到了一个叫做test-jar-img的镜像
- 可以在镜像中看到

```shell
docker images
```

- 现在就可以运行这个镜像了
- 指定CMD镜像覆盖，从而指定了端口，同时将主机的80端口，映射为容器的8080端口
- 为了方便查看，并未指定-d后台运行，因此，这里就直接可以看到springboot的启动日志了，并且也在8080端口启动了
- 由于指定了--rm,因此在终止运行之后，容器也随之删除
- 如果想要验证端口映射，则加上-d后台运行，然后通过docker ps 查看端口映射信息

```shell
docker run --rm -p 80:8080 test-jar-img --server.port=8080
```

- 查看镜像构建的历史
- 将会以不截断命令的方式，用JSON格式输出这个镜像的构建过程
- 也就是相当于查询其DOckerfile是怎么编写的
- 虽然有一些差异

```shell
docker image history --no-trunc --format json [镜像名]

docker image history --no-trunc --format json redis
```

## 完结
- 基础的docker使用和Dockerfile的编写及构建，就已经结束了
- 部分基础参考在jar8env文件夹下面给出
- 剩下的就可以自行探索更高级的使用方式
- 基于docker构建集群，结合k8s做容器编排

## 在maven中使用插件操作docker

- 在maven中使用插件操作docker
- 能够实现 镜像生成、推送仓库、运行容器

### 配置Docker远程管理

- 镜像生成，推送这些操作都是需要Docker环境的
- 一般的情况下，我们都是使用自己的电脑开发
- 然后放到服务器的Docker中运行
- 也就是说，Docker和开发环境是分开的
- 这种情况下，就要开启Docker的远程主机
- 允许远程操作Docker，实现Docker的管理
- 在此之前，需要对已经安装的docker进行一些配置
- 这样，就可以在没有docker的机器上，使用已经安装了docker的远程机器完成以上的操作
- 修改docker服务配置，开通TCP端口监听
- 编辑服务文件

```shell
vi /usr/lib/systemd/system/docker.service
```

- 某些低版本则是这个文件

```shell
vi /etc/systemd/system/docker.service
```

- 修改如下行
- 在 [Service] 节点下面
- 总体内容差不多就是这样，各个版本之间略有差异

```shell
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```

- 某些低版本则是这样的

```shell
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix://var/run/docker.sock
```

- 将这行添加参数

```shell
-H tcp://0.0.0.0:2375
```

- 最终效果

```shell
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375 --containerd=/run/containerd/containerd.sock
```

- 重新加载配置并重启

```shell
systemctl daemon-reload
systemctl restart docker
```

- 添加仓库镜像配置

```shell
vi /etc/docker/daemon.json
```

- 添加国内的镜像仓库

```shell
{
  "registry-mirrors": [
    "https://mirror.aliyuncs.com",
    "https://mirror.baidubce.com",
    "https://mirror.baidubce.com",
    "https://docker.m.daocloud.io",
    "https://hub-mirror.c.163.com",
    "https://2a6bf1988cb6428c877f723ec7530dbc.mirror.swr.myhuaweicloud.com",
    "https://your_preferred_mirror",
    "https://dockerhub.icu",
    "https://docker.registry.cyou",
    "https://docker-cf.registry.cyou",
    "https://dockercf.jsdelivr.fyi",
    "https://docker.jsdelivr.fyi",
    "https://dockertest.jsdelivr.fyi",
    "https://dockerproxy.com",
    "https://docker.m.daocloud.io",
    "https://docker.nju.edu.cn",
    "https://docker.mirrors.sjtug.sjtu.edu.cn",
    "https://docker.mirrors.ustc.edu.cn",
    "https://mirror.iscas.ac.cn",
    "https://docker.rainbond.cc"
  ]
}
```

### 配置maven插件

- 详细配置
  - Java 端： ./maven/java
    - [pom.xml](maven%2Fjava%2Fpom.xml)
  - Npm 端： ./maven/npm
    - [pom.xml](maven%2Fnpm%2Fpom.xml)
- 如果没有私服可以用，可以选择使用官方的 DockerHub
- 也可以选择使用Docker启动一个自己的私服，用于进行功能验证
- 详情请查看【安装docker镜像私服】章节
- 添加插件到 pom.xml 中
- 添加如下属性

```shell
<properties>
    <spring.env>dev</spring.env>

    <docker.remote.host>192.168.x.x:2375</docker.remote.host>
    <docker.registry.host>192.168.x.x:5000</docker.registry.host>
    <docker.registry.prefix></docker.registry.username>
    <docker.run.port>8080:8080</docker.run.port>
  </properties>
```

- 在 project/build/plugins 节点下

```xml

<plugin>
  <groupId>io.fabric8</groupId>
  <artifactId>docker-maven-plugin</artifactId>
  <version>0.46.0</version>
  <configuration>
    <!-- Docker 远程管理地址 -->
    <dockerHost>http://${docker.remote.host}</dockerHost>
    <!-- Docker 推送镜像仓库地址 -->
    <pushRegistry>http://${docker.registry.host}</pushRegistry>
    <!-- 大部分情况下，镜像仓库都是需要认证的，但是如果是自己的私服，可能不需要认证信息 -->
    <authConfig>
      <push>
        <username>${docker.registry.username}</username>
        <password>${docker.registry.password}</password>
      </push>
    </authConfig>
    <!-- 允许配置多个镜像 -->
    <images>
      <image>
        <!--
        由于推送到私有镜像仓库，镜像名需要添加仓库地址
        还有一些支持多租户的镜像仓库，格式可能是：主机:端口/租户名/镜像名:版本
         -->
        <name>${docker.registry.host}${docker.registry.prefix}/${pom.artifactId}:${pom.version}</name>
        <!--定义镜像构建行为-->
        <build>
          <!-- 
          我们的Dockerfile的文件，这样可以更加精细化的定制镜像的构建过程
           这里就放在和pom.xml同级的位置
           默认情况下，Dockerfile所在的目录就是工作目录contextDir，所以可以不用配置contextDir
           因此，可以使用Dockerfile所在目录下的文件（以及子目录下的）
           当然，可以把Dockerfile所在与工作目录分开
           实际上，下面这个配置就是默认配置
           你也可以根据实际需要，分别更改这两个值，使得各自在不同的路径
           -->
          <contextDir>${pom.basedir}</contextDir>
          <dockerFile>${pom.basedir}/Dockerfile</dockerFile>
          <!--定义维护者 -->
          <maintainer>test</maintainer>
          <!-- 
          配置是否启用配置参数过滤
          如果值为false，则不替换maven参数
          如果为@等单个字符，就进行替换形如 @xxx.xxx@ 这样被@包裹的maven属性变量
          默认值是 ${*} , 也就是替换 ${xxx.xxx} 这样的占位符的maven属性变量
          这些属性变量适用于resources资源文件
          也就是说，对application.yml这些是生效的
          同时，也对Dockerfile生效
          -->
          <filter>@</filter>
          <!--
          默认情况下，插件会将contextDir下面的所有文件都复制到docker的运行上下文中
          这个过程实际上会复制这些文件，打包为一个tar包，将这个tar包通过网络传输给 dockerHost
          所以，对于一般的项目来说，除非使用源码构建docker镜像，负责一般都是直接使用生成的jar包等编译产物构建镜像
          在这种前提下，把src等源码文件传输过去，就显得没那么必要了
          因此，可以使用这里的assemblies配置哪些文件需要添加到contextDir
          注意，这个配置是追加配置，在默认行为的基础上，添加这里配置的文件
          所以，到目前为止，src等源码还是会被传输的
          还需要再contextDir添加 .maven-dockerexclude 文件，排除所有文件
          这样，默认情况下所有文件都被排除，只有在这里配置的文件才被添加到传输列表
          -->
          <assemblies>
            <assembly>
              <!-- 将这些文件直接放到contextDir的根目录下 -->
              <name>/</name>
              <inline>
                <fileSets>
                  <!-- 只包含打包生成的jar/war/tar包等产物 -->
                  <fileSet>
                    <directory>${project.build.directory}</directory>
                    <outputDirectory>target</outputDirectory>
                    <filtered>false</filtered>
                    <includes>
                      <include>*.jar</include>
                      <include>*.tar</include>
                      <include>*.war</include>
                      <include>*.tar.gz</include>
                      <include>*.tgz</include>
                      <include>*.zip</include>
                    </includes>
                  </fileSet>
                  <!-- 
                  只包含resources下面的配置文件，打包的时候可能需要，
                  并且这类文件不会太大，传输也没事，不用那么严格的控制
                   -->
                  <fileSet>
                    <directory>${project.basedir}/src/main/resources</directory>
                    <outputDirectory>resources</outputDirectory>
                  </fileSet>
                </fileSets>
              </inline>
            </assembly>
          </assemblies>
        </build>
        <!--定义容器启动行为-->
        <run>
          <!--设置容器名，可采用通配符-->
          <containerNamePattern>${project.artifactId}</containerNamePattern>
          <!--设置端口映射-->
          <ports>
            <port>8080:8080</port>
          </ports>
          <!--设置容器间连接-->
          <links>
            <link>mysql:db</link>
          </links>
          <!--设置容器和宿主机目录挂载-->
          <volumes>
            <bind>
              <volume>/etc/localtime:/etc/localtime</volume>
              <volume>/mydata/app/${project.artifactId}/logs:/var/logs</volume>
            </bind>
          </volumes>
        </run>
      </image>
    </images>
  </configuration>
  <executions>
    <!--如果想在项目打包时构建镜像添加，如果不想要和maven的声明周期挂钩，就不需要这个配置 -->
    <execution>
      <id>build-image</id>
      <!--
      在maven的标准生命周期的package阶段，触发执行本插件的build和push两个执行目标goals
      因此，在打包的时候就会触发构建镜像，推送到镜像仓库
      -->
      <phase>package</phase>
      <goals>
        <goal>build</goal>
        <goal>push</goal>
      </goals>
    </execution>
  </executions>

</plugin>
```

- 下面，我们来添加Dockerfile
- 放到和 pom.xml 同级的目录中
- 如果是多模块项目，那就每个需要打包为镜像的模块都添加

```shell
vi Dockerfile
```

- 内容如下

```shell
FROM openjdk:8-jre-slim
ENV JAR_NAME="app.jar"

ENV SERVER_PORT=8080

# 前面说了，配置了过滤的情况下，可以使用maven变量进行替换，这里就是典型案例
ENV SPRING_ENV=@spring.env@

ADD target/$JAR_NAME /

WORKDIR /

EXPOSE $SERVER_PORT

ENTRYPOINT ["sh","-c","java -jar  -Dserver.port=$SERVER_PORT -Dspring.profiles.active=$SPRING_ENV $JAR_NAME"]
```

- 简单说一下逻辑
- 使用 jdk8 的基础镜像
- 设置环境变量 JAR_NAME 为固定的名称
- 将 target/$JAR_NAME.jar 添加到根目录下
- 设置工作路径为根目录
- 暴露外部端口
- 启动运行JAR包

- 这样，就可以进行打包了

```shell
mvn clean package
```

- 这样，就完成了以下的步骤

```shell
mvn clean
mvn package
mvn docker:build
mvn docker:push
```

- 因为，配置了和maven的package极端挂钩，执行build,push两个阶段
- 所以，你也可以单独执行镜像构建与推送

```shell
mvn docker:build
mvn docker:push
```

- 如果在没有挂钩的情况下
- 下面的命令也是等效的

```shell
mvn clean package docker:build docker:push
```

## 安装docker镜像私服

- 安装私服，需要更改docker的配置指向私服
- 然后需要重启docker，为了避免多次重启docker
- 我们先配置好docker，再安装私服

### 配置docker指向私服

- 下面使用后registry2进行演示
- 编辑docker配置，添加私有仓库
- 这是因为docker默认需要访问的是https的仓库
- 但是，我们这里的私有仓库是http的，也就是insecure不安全的
- 所以，需要单独配置这种不安全的仓库到docker配置中
- 编辑配置文件

```shell
vi /etc/docker/daemon.json
```

- 添加如下配置
- 下面的 192.168.x.x:5000 就是我们即将安装的 registry2 仓库的访问地址
- 这里，记住端口 5000 即可

```shell
"insecure-registries": ["192.168.50.132:5000"]
```

- 完整配置如下

```json
{
  "insecure-registries": ["192.168.50.132:5000"],
  "registry-mirrors": [
    "https://mirror.aliyuncs.com",
    "https://mirror.baidubce.com",
    "https://mirror.baidubce.com",
    "https://docker.m.daocloud.io",
    "https://hub-mirror.c.163.com",
    "https://2a6bf1988cb6428c877f723ec7530dbc.mirror.swr.myhuaweicloud.com",
    "https://your_preferred_mirror",
    "https://dockerhub.icu",
    "https://docker.registry.cyou",
    "https://docker-cf.registry.cyou",
    "https://dockercf.jsdelivr.fyi",
    "https://docker.jsdelivr.fyi",
    "https://dockertest.jsdelivr.fyi",
    "https://dockerproxy.com",
    "https://docker.m.daocloud.io",
    "https://docker.nju.edu.cn",
    "https://docker.mirrors.sjtug.sjtu.edu.cn",
    "https://docker.mirrors.ustc.edu.cn",
    "https://mirror.iscas.ac.cn",
    "https://docker.rainbond.cc"
  ]
}
```

- 重启docker以应用配置

```shell
systemctl daemon-reload
systemctl restart docker
```

### 安装registry2私服

- 拉取镜像

```shell
docker pull registry:2
```

- 运行registry2仓库
- 这里将容器的5000端口映射到主机的5000端口上，和上面的配置是对应的
- 需要注意

```shell
docker run -p 5000:5000 --name registry2
	--restart=always \
	-e REGISTRY_STORAGE_DELETE_ENABLED="true" \
	-d registry:2
```

### 安装registry-ui私服的UI界面

- 现在只有一个仓库的服务，没有UI界面，比较不方便
- 下面开始安装UI界面
- 拉取镜像

```shell
docker pull joxit/docker-registry-ui
```

- 启动容器
- 这里，将容器的80端口映射到主机的8280端口
- 并且启动了网络连接 --link 将registry2 固定到 registry2 容器
- 这样，即使registry2 容器重新启动了，IP即使发生了变化，也能够获取到正确的IP地址
- 换句话说，也就是将 registry2 固定作为 registry2 容器的固定IP名，类似DNS的作用
- 后面的 5000 端口，就是我们的私有仓库的端口，对应上就行

```shell
docker run -p 8280:80 --name registry-ui 
	--link registry2:registry2 \
	-e NGINX_PROXY_PASS_URL="http://registry2:5000" \
	-e DELETE_IMAGES="true" \
	-e REGISTRY_TITLE="Registry2" \
	-d joxit/docker-registry-ui
```

- 现在，通过浏览器访问，就能够看到仓库的信息了

```shell
http://192.168.x.x:8280/
```

### 验证私服

- 现在，你看到的页面里面应该是没有任何的镜像的
- 现在，我们尝试推送一个测试镜像到私有仓库中
- 以验证功能
- 这里以busybox为例
- 先拉取一个公共镜像

```shell
docker pull busybox
```

- 给公共镜像，重新打上标签
- 主要是添加私服的主机路径
- 按照规范格式来就行
  - 私服主机：私服端口/镜像名称:镜像版本
- 我们默认拉取镜像的时候，没有指定私服主机和端口
- 实际上是内部自动添加了官方镜像的前缀
- 这里的 5000 端口，对应上就行

```shell
docker tag busybox 192.168.x.x:5000/busybox:v1.0
```

- 将这个镜像推送到私服
- 因为重新打的标签，包含了私服的主机信息
- 因此直接推送，docker就知道往哪台主机推送了

```shell
docker push 192.168.x.x:5000/busybox:v1.0
```

- 如果是使用harbor这样的具有认证的仓库
- 那么就需要先登录仓库

```shell
docker login 192.168.1.101:80 -u admin -p harbor12345
```

- 如果之前已经登录过了，也可以选择强制退出

```shell
docker logout 192.168.1.101:80
```

### 打包自己的镜像并推送

- 下面，我们进行一个简单的案例
- 来说明，手动打包并推送到私服的流程
- 下面，请先准备一个jar程序包
- 这里以 app.jar 为例讲解
- 这个jar包实际上是一个springboot的web程序
- 可以自行建立一个就行
- 还有，准备一个Dockerfile文件

```shell
vi Dockerfile
```

- 内容如下

```shell
FROM openjdk:8-jre-slim
ENV JAR_NAME="app.jar"

ENV SERVER_PORT=8080

ADD $JAR_NAME /

WORKDIR /

EXPOSE $SERVER_PORT

ENTRYPOINT ["sh","-c","java -jar  -Dserver.port=$SERVER_PORT $JAR_NAME"]
```

- 内容很简单
- 基础镜像为：openjdk:8-jre-slim
- 也就是使用jdk8作为基础运行环境
- 然后设置了启动的jar包名称 JAR_NAME="app.jar"
- 设置了启动的服务的web端口 SERVER_PORT=8080
- 然后，将当前目录下的 $JAR_NAME 添加到了容器的 / 根目录下 ADD $JAR_NAME /
- 然后，设置了容器的工作路径为根目录 WORKDIR /
- 接着，将容器的WEB端口给暴露了出来，允许外部访问 EXPOSE $SERVER_PORT
- 最后，定义了启动命令，用于启动这个jar的WEB程序 java -jar -Dserver.port=$SERVER_PORT $JAR_NAME
- 现在你的文件结构应该是这样的

```shell
test
	Dockerfile
	app.jar
```

- 也就是保证这两个文件在同一个目录下即可
- 现在，来打包生成镜像
- 需要先cd到有DOckerfile的路径下执行
- 下面，我们直接一步到位，直接打包带有私服主机信息的镜像
- 镜像就叫做 web-app ， 版本定位 v1.0

```shell
docker build -t 192.168.x.x:5000/web-app:v1.0 .
```

- 现在直接推送到私服

```shell
docker push 192.168.x.x:5000/web-app:v1.0
```

- 在浏览器中，刷新私服的UI
- 就能够看到镜像了

## nginx 转发私服配置

- 添加nginx转发配置
- 这里假定代理这台nginx的IP为 192.168.1.102
- 代理的源IP为 192.168.1.110

```shell
   server {
    listen       10080;
    server_name  localhost;

    client_max_body_size 2048M;

    location ^~/ {
         proxy_pass http://192.168.1.110:80/;
         proxy_connect_timeout      600s;
         proxy_send_timeout         600s;
         proxy_read_timeout         600s;
         proxy_set_header Host $host;
         proxy_set_header X-Real-IP $remote_addr;
         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
         proxy_set_header Connection "upgrade";
         proxy_set_header Upgrade $http_upgrade;
         proxy_set_header X-Forwarded-Proto $scheme;
      }
   }
```

- docker添加代理配置

```shell
mkdir -p /etc/systemd/system/docker.service.d/
vi /etc/systemd/system/docker.service.d/http-proxy.conf
```

- 添加如下配置
- 也就是将转发的地址改到nginx的代理端点

```shell
[Service]
Environment="HTTP_PROXY=http://192.168.1.102:10080"
Environment="HTTPS_PROXY=https://192.168.1.102:10080"
Environment="NO_PROXY=localhost,127.0.0.1"
```

- 我这里因为是使用IP访问，没有配置HTTPS
- 因此，后还需要添加这个配置，如果有HTTPS配置，那可以不用下面的配置
- 添加不安全的仓库配置

```shell
vi /etc/docker/daemon.json
```

- 添加insecure配置

```json
{
  "insecure-registries": [
    "192.168.1.102:10080",
    "192.168.1.110:80"
  ]
}
```

- 最后应用配置重启docker

```shell
systemctl daemon-reload
systemctl restart docker
```