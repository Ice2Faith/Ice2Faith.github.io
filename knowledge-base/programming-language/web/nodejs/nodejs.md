# Node-Js 安装

---

## 安装（windows）
- 下载
```shell script
https://nodejs.cn/download/
```
- 按照安装向导安装即可
- 这里我以安装在以下路径为例
```shell script
D:\nodejs
```
- 安装选择路径
- 直接更改为上述路径
- 然后勾选上PATH环境变量
- 最后的安装必要组件
- 根据自己需要决定是否安装
- 我是安装了
- 这个勾选了之后，会自动启动PowerShell
- 自动安装VC-Redistribute(VisualStudio分发组件依赖)
- 和Python环境
- 检查安装是否成功
```shell script
node -v
npm -v
```
- 能够显示版本信息即可

## 配置
- 进入安装路径
```shell script
cd D:\nodejs
```
- 查看目录是否正确
    - 能够看到 node.exe 才对
```shell script
dir
```
- 创建全局目录和缓存目录
    - 可能无法创建
    - 需要管理员权限
```shell script
mkdir node_global
mkdir node_cache
```
- 配置目录
```shell script
npm config set prefix "D:\nodejs\node_global"
npm config set cache "D:\nodejs\node_cache"
```
- 配置环境变量
```shell script
NODE_HOME
C:\nodejs

NODE_PATH
%NODE_HOME%\node_modules

Path
%NODE_HOME%\node_global

Path
%NODE_HOME%
```
- 配置完环境变量
    - 之前的cmd窗口不会刷新环境变量
    - 从新打开新的cmd窗口即可
- 查看镜像源
    - 默认是国外的，连不上或者慢
```shell script
npm config get registry
```
- 配置国内镜像源
```shell script
npm config set registry https://registry.npm.taobao.org/
```
- 安装cnpm
```shell script
npm install -g cnpm
```
- 检查cnpm
```shell script
cnpm -v
```
- 确认所有配置
```shell script
npm config list
```

## 测试
- 其实上面安装cnpm没问题就已经OK了
- 但是还是再安装一个吧
- 安装express
```shell script
npm install express -g
```

## 可选命令安装
- 安装vite
```shell script
npm install -g vite
vite -v
```
- 安装vue-cli
```shell script
npm install -g @vue/cli
vue -v
```
- 安装create-react-app
```shell script
npm install -g create-react-app
create-react-app -v
```
- 安装yarn
```shell script
npm install -g yarn
yarn -v
```
- 安装pnpm
```shell script
npm install -g pnpm
pnpm -v
```
- 安装rimraf
```shell script
npm install -g rimraf
```
- 安装cross-env
```shell script
npm install -g cross-env
```
- 安装prettier
```shell script
npm install -g prettier
```
- 安装parcel
```shell script
npm install -g parcel
```
