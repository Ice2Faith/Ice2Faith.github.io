warnRate=50


ServerName=`hostname`
TimeNow=$(date "+%Y-%m-%d %H:%M:%S")

echo server network lost packets exceed warn rate on $ServerName checking...

pingHost=$1

if [ -z "$pingHost" ];then
   pingHost="8.8.8.8"
fi

tmpFile="/tmp/net-chk.dat"
ping -c 3 $pingHost > $tmpFile
pingResult=`cat $tmpFile`
rate=`cat $tmpFile | grep packets | awk -F "," '{print $3}' | awk '{print $1}' | awk -F "%" '{print $1}'`
rm -rf $tmpFile

if [ $rate -gt $warnRate ];then
    # send email
    for sendto in x123@qq.com x456@139.com;
    do
        echo ------------------- send mail to $sendto -------------------
        echo -e "\
your server $ServerName network on connect $pingHost has lost packets exceed warn rate $warnRate % and current is $rate % at $TimeNow, please check it!

ping output is:
------------------------------------------------------------------
$pingResult

" | mail -s "[Alarm] server $ServerName network lost packets on connect $pingHost exceed rate $warnRate % and current is $rate %" $sendto
    done
fi
