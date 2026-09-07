# jar8env docker 使用指南
---
## 作用
- 对给定的jar文件构建一个基于openjdk8的docker镜像
## 使用方式
- 将jar文件存放到这两个文件所在路径，例如test.jar

```shell
build.sh
Dockerfile
test.jar
```
- 执行创建脚本

```shell
./build.sh test.jar
```
- 同时，如果脚本所在目录只有一个jar时，可以简化

```shell
./build.sh
```
- 构建完毕之后，镜像就创建好了
- 镜像名称为jar名称+.dimg

```shell
test.jar.dimg
```
- 同时会生成三个辅助脚本
```
run-test.jar.sh 运行镜像
rmi-test.jar.sh 删除镜像及其容器
enter-test.jar.sh 进入容器
```
