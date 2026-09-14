# termux

- termux，服务于 android 的 linux 系统应用程序
- 本质上是实现的一个运行了类似alpine的linux内核虚拟程序

## 安装

- 官方地址

```shell
https://github.com/termux/termux-app/releases
```

- 如果知道自己的手机架构，可以选择具体架构的安装包
- 如果不知道具体架构，可以选择通用 universal 安装包

```shell
wget https://github.com/termux/termux-app/releases/download/v0.118.3/termux-app_v0.118.3+github-debug_universal.apk
```

- 安装即可
- 授予文件访问权限、网络权限
- 如果经常使用或者作为一个小型服务器使用
- 可以基于自动启动、后台防杀白名单

## 基础概念

- 用户
    - 用户是安装之后，android 自动分配的，非 root 用户
    - 而且也更改不了
- 存储
    - 你的 sdcard 外部存储，将会挂载到 /mnt/sdcard 下面
    - 因此，你可以通过这个挂载点，访问你的 sdcard 中的图片等内容
- 权限
    - 由于 android 的权限管控，sdcard 下面的都是 no-exec 没有可执行权限的
    - 因此，你不能直接对 sdcard 下面的文件添加可执行权限
    - 因此，如果你要运行程序，需要复制文件到你的 home 目录下去
    - 再添加可执行权限才行
- 网络
    - 默认没有任何的限制
    - 也就是你如果启动了一个WEB服务
    - 那么这个端口默认就是开放的
    - 局域网内是可以连接的
    - 可以通过 `ifconfig` 命令查看IP地址
    - 如果是在手机本机上访问，可以直接通过 `localhost` 访问
- 软件包安装
    - 因为使用的不是标准的 `libc` 库，因此有些软件不能直接使用
    - 因此，使用 `pkg install` 来进行安装
    - 使用 `pkg search` 来查找软件包

## 配置

- 直接打开 App 即可进入终端
- 只有一个用户，这个用户是非 root 用户
- 而且也修改不了用户，是自动生成的
- 下面开始基础配置

### 配置 ll 别名

- 默认是没有 ll 命令别名的
- 用起来比较别扭，所以我们先添加一个别名

```shell
echo "alias ll='ls -alh'" >> ~/.bashrc
```

- 加载配置

```shell
source ~/.bashrc
```

### 存储目录挂载

- 初始化存储挂载
- 直接输入以下命令
- 这样会在 `~/storage` 下面创建出来一个存储目录
- 可以方便进入图片、下载等android目录

```shell
termux-setup-storage
```

- 我的习惯是，直接创建一个软连接，放到 home 目录下面更加方便
- 因此，我们创建一个软连接
- 这样，就可以通过 `~/sdcard` 直接访问到sdcard了
- 因为权限的问题，这样添加软连接后，自己的软件可以放在 home 目录下面运行
- 直接通过相对路径找到sdcard，也比较方便

```shell
cd ~
ln -s /mnt/sdcard $(pwd)/sdcard
```

### 更换国内镜像源

- 执行命令后，选择中国的镜像源即可

```shell
termux-change-repo
```

### 后台保活

- 防止息屏的时候进程被杀
- 导致部署在其中的服务中断
- 可以手动执行锁定进程、防止后台被杀

```shell
termux-wake-lock
```

### 确认架构

- 如果你要编译自己的软件包到这个环境运行
- 那么，你需要先确定自己手机的架构类型
- 虽然android手机一般都是 ARM 架构
- 但也不排除其他可能
- 因此最好是看一眼，否则运行不了

- 查看系统架构

```shell
uname -a
```

- 查看具体的版本
- 这个可以知道你是 `arm64-v8a` 还是其他

```shell
getprop ro.product.cpu.abi
```

## 安装常用软件包

- 更新源

```shell
pkg update && pkg upgrade
```

- 安装基础环境

```shell
pkg install cronie -y
pkg install iproute2 -y
pkg install clang make -y
pkg install curl wget vim nano unzip zip htop tree neofetch -y
pkg install openssh -y
pkg install build-essential pkg-config cmake binutils libtool -y
```

### 安装 java (可选)

```shell
pkg install openjdk-17
```

- 检查安装

```shell
java -version
javac -version
```

### 安装 python (可选)

```shell
pkg install python
```

- 检查安装

```shell
python --version
pip --version
```

- 配置国内镜像源

```shell
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
pip config set global.trusted-host pypi.tuna.tsinghua.edu.cn
```

### 安装 ffmpeg (可选)

```shell
pkg install ffmpeg -y
```

- 检查安装

```shell
ffmpeg -version
```

### 安装 pandoc (可选)

```shell
pkg install pandoc -y
```

- 检查安装

```shell
pandoc --version
```

## 运行自己的程序

- 前面说了，android 的 sdcard 下面都是 no-exec 的
- 也就是说，如果你的软件放在 sdcard 下面
- 执行 `chmod +x` 添加可执行权限是没用的
- 也不会报错，但是添加不了可执行权限
- 所以，你的程序如果需要添加可执行权限
- 就需要复制到 home 目录下面去才行
- 下面我们以下面两个程序为例
    - app.jar 是 java 程序
    - app.elf 是 linux 的可执行程序
- 也就是分别演示，不需要可执行权限，与需要可执行权限的情况
- 这两个文件，我们先传输到手机的 sdcard 目录下的 `01dev` 文件夹中

```shell
01dev
  app.jar
  app.elf
```

- 我们先在 home 目录下面规划几个路径
    - apps 用来存放应用
    - env 用来存放中间件（非应用）

```shell
mkdir -p ~/apps
mkdir -p ~/env
```

### 运行java程序

- 我们为每个应用，创建单独的目录，方便管理

```shell
mkdir -p ~/apps/java-app
```

- 先复制到home目录下
    - 虽然jar程序不需要可执行权限
    - 但是为了统一习惯
    - 我们都先复制到home目录下

```shell
cp ~/sdcard/01dev/app.jar ~/apps/java-app/
```

- 然后进入启动运行程序

```shell
cd ~/apps/java-app
```

- 启动程序
    - 至于什么后台运行之类的，就直接对应 linux 内容了
    - 这里不重复讲

```shell
java -jar app.jar
```

### 运行可执行程序

- 我们为每个应用，创建单独的目录，方便管理

```shell
mkdir -p ~/apps/exe-app
```

- 先复制到home目录下
    - 虽然jar程序不需要可执行权限
    - 但是为了统一习惯
    - 我们都先复制到home目录下

```shell
cp ~/sdcard/01dev/app.elf ~/apps/exe-app/
```

- 然后进入启动运行程序

```shell
cd ~/apps/exe-app
```

- 因为是可执行程序
- 所以，就需要先添加可执行权限
- 这里直接 `chmod +x` 了，而不是 `a+x`
- 因为，实际上，termux 只有一个用户，也建立不了其他用户，也没有 root
- 所以，a 就是只有自己一个用户

```shell
chmod +x app.elf
```

- 启动程序
    - 至于什么后台运行之类的，就直接对应 linux 内容了
    - 这里不重复讲

```shell
./app.elf
```


