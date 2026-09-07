## shell脚本
- 变量定义、变量赋值
```shell script
[变量名]=[变量值]
APP=app.jar
```
- 变量引用
```shell script
$[变量名]
${变量名}

APP=app.jar
APP_PATH=apps/$APP
APP_LOG=logs/${APP}log
```
- 字符串拼接
    - 直接连接即可
```shell script
APP_NAME=app
APP_SUFFIX=.jar
APP=$APP_NAME$APP_SUFFIX
APP_PATH=apps/$APP
```
- if-else 分支判断
```shell script
if [条件] then
    [条件体]
elif [条件] then
    [条件体]
else 
    [条件体]
fi
```
- [条件]部分，有几种变形
- [...]形式，相等==，大于 -gt,小于 -lt
```shell script
a=10
b=20
if [ $a == $b ]
then
   echo "a 等于 b"
elif [ $a -gt $b ]
then
   echo "a 大于 b"
elif [ $a -lt $b ]
then
   echo "a 小于 b"
else
   echo "没有符合的条件"
fi
```
- ((...))形式，大于小于可以直接写
```shell script
a=10
b=20
if (( $a == $b ))
then
   echo "a 等于 b"
elif (( $a > $b ))
then
   echo "a 大于 b"
elif (( $a < $b ))
then
   echo "a 小于 b"
else
   echo "没有符合的条件"
fi
```
- for 循环语句
```shell script
for [循环变量] in [被迭代变量]
do
    [循环体]
done
```
```shell script
for item in 1 2 3 4 5
do
    echo "The value is: $item"
done

#!/bin/bash

for str in This is a string
do
    echo $str
done
```
- while 循环
```shell script
while [条件]
do
    [循环体]
done
```
```shell script
int=1
while(( $int<=5 ))
do
    echo $int
    let "int++"
done
```
- case 分支
```shell script
case [分支值] in
    [匹配值])
    [匹配体]
    ;;
    *)
    [默认体]
    ;;
esac
```
```shell script
case $1 in
    start)
    echo start
    ;;
    stop)
    echo stop
    ;;
    *)
    echo stop
    ;;
esac
```
- 函数
    - 函数中，不具备return和入参的能力
    - 因此，使用全局变量代替
    - 函数的调用，直接使用函数名即可，不需要带括号
```shell script
function [函数名]()
{
   [函数体]
}
```
```shell script
function hello()
{
    echo "func hello"
}

hello
```
