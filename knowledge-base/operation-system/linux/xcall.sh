#!/bin/bash 

# 获取控制台指令

cmd=$*

# 判断指令是否为空
if [ ! -n "$cmd" ]
then
  echo "command can not be null !"
  exit
fi

# 获取当前登录用户
user=`whoami`

#5 循环
for host in nl-bd-0004 nl-bd-0005 nl-bd-0006;
do
   echo ------------------- $host -------------------
   ssh $user@$host $cmd
done