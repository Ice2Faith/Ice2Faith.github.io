#!/bin/bash

PsName=$1
AppName=$2
ServerName=`hostname`

ThisName=`basename $0`
TimeNow=$(date "+%Y-%m-%d %H:%M:%S")

echo $PsName for $AppName on $ServerName checking...

PID=`ps -ef | grep -v grep| grep -v $ThisName | grep $PsName | awk '{print $2}'`

if [[ -n "$PID" ]]; then
      echo -e "\033[0;31m $PsName  process has running ... \033[0m"
      exit 0
fi

PsResult=`ps -ef | grep -v grep| grep -v $ThisName | grep $PsName`
TopResult=`top -c -b -n 1 | head -n 12`
FreeResult=`free -h`
DfResult=`df -h`
IostatResult=`iostat -dmx`
PingResult=`ping www.baidu.com -c 3`
WhoResult=`who -ablu`
WResult=`w -ui`

# send email
for sendto in x123@qq.com x456@139.com;
do
   echo ------------------- send mail to $sendto -------------------
   echo -e "\
your application $AppName on $ServerName has died at $TimeNow, witch ps-grep called $PsName, please check it!

ps output is:
------------------------------------------------------------------
$PsResult

top output is:
------------------------------------------------------------------
$TopResult

free output is:
------------------------------------------------------------------
$FreeResult

df output is:
------------------------------------------------------------------
$DfResult

iostat output is:
------------------------------------------------------------------
$IostatResult

ping output is:
------------------------------------------------------------------
$PingResult

who output is:
------------------------------------------------------------------
$WhoResult

w output is:
------------------------------------------------------------------
$WResult
" | mail -s "[Alarm] host $ServerName app $AppName process died" $sendto
done
