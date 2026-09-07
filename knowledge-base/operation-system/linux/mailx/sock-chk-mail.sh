remoteHost=$1
remotePort=$2

ServerName=`hostname`
TimeNow=$(date "+%Y-%m-%d %H:%M:%S")

echo server socket on $ServerName checking...

ts=$(date "+%Y%m%d-%H%M%S")
tmpFile="/tmp/sock-chk-${remotePort}-${ts}.dat"
nc -zv $remoteHost $remotePort > $tmpFile 2>&1
ncResult=`cat $tmpFile`
okCount=`cat $tmpFile | grep Connected | wc -l`
rm -rf $tmpFile


if [ $okCount -eq 0 ];then
    # send email
    for sendto in x123@qq.com x456@139.com;
    do
        echo ------------------- send mail to $sendto -------------------
        echo -e "\
your server $ServerName cannot connected to $remoteHost:$remotePort at $TimeNow, please check it!

nc output is:
------------------------------------------------------------------
$ncResult

" | mail -s "[Alarm] server $ServerName cannot connected to $remoteHost:$remotePort " $sendto
    done
fi
