#!/bin/bash

Option=$1

SERVER=192.168.1.101:8080

# 如果有第二个参数，则第二个参数就是server的值
# 将会覆盖默认的值
if [[ -n "$2" ]]; then
  SERVER=$2
fi

CONFIG_FILE=conf/nginx.conf

function help()
{
    echo -e "\033[0;31m please input 1st arg:Option \033[0m"
    echo -e "    options: \033[0;34m {up|u|down|d|status|t} \033[0m"
    echo -e "\033[0;34m up/u    \033[0m : up server $SERVER"
    echo -e "\033[0;34m down/d     \033[0m : down server $SERVER"
    echo -e "\033[0;34m status/t     \033[0m : status for $SERVER"

    exit 1
}

function up(){
  cp $CONFIG_FILE $CONFIG_FILE.bak
  sed -i "/^[[:space:]]*#[[:space:]]*server[[:space:]]*$SERVER/s/^[[:space:]]*#[[:space:]]*/        /" $CONFIG_FILE
  _p_ok=`./sbin/nginx -t 2>&1 | grep -v grep | grep "syntax is ok" | wc -l`
  if [ "$_p_ok" = "0" ]; then
     echo -e "\033[0;31m config file is invalid! \033[0m"
     ./sbin/nginx -t
     mv $CONFIG_FILE.bak $CONFIG_FILE
  else
      ./sbin/nginx -s reload
      echo -e "up server \033[0;34m $SERVER    \033[0m"
      rm -rf $CONFIG_FILE.bak
  fi
}

function down(){
  cp $CONFIG_FILE $CONFIG_FILE.bak
  sed -i "/^[[:space:]]*server[[:space:]]*$SERVER/s/^[[:space:]]*/       # /" $CONFIG_FILE
  if [ "$_p_ok" = "0" ]; then
     echo -e "\033[0;31m config file is invalid! \033[0m"
     ./sbin/nginx -t
     mv $CONFIG_FILE.bak $CONFIG_FILE
  else
      ./sbin/nginx -s reload
      echo -e "down server \033[0;34m $SERVER    \033[0m"
      rm -rf $CONFIG_FILE.bak
  fi
}

function status(){
  _p_ok=`cat conf/nginx.conf | grep -e "[[:space:]]*#[[:space:]]*server[[:space:]]$SERVER" | wc -l`
  if [ "$_p_ok" = "0" ]; then
     echo -e "up server \033[0;34m $SERVER    \033[0m"
  else
      echo -e "down server \033[0;34m $SERVER    \033[0m"
  fi
}

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: config file not found : $CONFIG_FILE"
    exit 1
fi

case $Option in
  up)
  up;;
  u)
  up;;
  down)
  down;;
  d)
  down;;
  status)
  status;;
  t)
  status;;
  *)
  help;;
esac
