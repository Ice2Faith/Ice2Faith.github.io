warnRate=90


ServerName=`hostname`
TimeNow=$(date "+%Y-%m-%d %H:%M:%S")

echo server memory use exceed warn rate on $ServerName checking...

tmpFile="/tmp/mem-chk.dat"
free -k > $tmpFile
freeResult=`cat $tmpFile`
totalKb=`cat $tmpFile | grep "Mem:" | awk '{print $2}'`
useKb=`cat $tmpFile | grep "Mem:" | awk '{print $3}'`
useKb="${useKb}00"
rate=`expr $useKb / $totalKb`
rm -rf $tmpFile

if [ $rate -gt $warnRate ];then
    # send email
    for sendto in x123@qq.com x456@139.com;
    do
        echo ------------------- send mail to $sendto -------------------
        echo -e "\
your server memory on $ServerName has use exceed warn rate $warnRate % and current is $rate % at $TimeNow, please check it!

free kb output is:
------------------------------------------------------------------
$freeResult

" | mail -s "[Alarm] server $ServerName memory use exceed rate $warnRate % and current is $rate %" $sendto
    done
fi
