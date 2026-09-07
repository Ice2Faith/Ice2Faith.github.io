warnRate=75


ServerName=`hostname`
TimeNow=$(date "+%Y-%m-%d %H:%M:%S")

echo server disk use exceed warn rate on $ServerName checking...

tmpFile="/tmp/df-chk.dat"
df -h > $tmpFile

DfResult=`cat $tmpFile`


i=0
cat $tmpFile | while read item;
do
    rate=`echo $item | awk '{print $5}' | awk -F '%' '{print $1}'`
    if [ $i -eq 0 ]; then
      echo jump first line
    elif [ $rate -gt $warnRate ];then
        warnFile="/tmp/disk-warn-${i}-${warnRate}.log"
        if [[ -f "$warnFile" ]]; then
            echo -e "alarmed line:$i rate:$rate item:$item"
        else
	    echo -e "line:$i rate:$rate item:$item" > $warnFile
            # send email
            for sendto in x123@qq.com x456@139.com;
            do
            echo ------------------- send mail to $sendto -------------------
            echo -e "\
your server disk on $ServerName has use exceed warn rate $warnRate % and current is $rate % at $TimeNow, please check it!

disk:
line:$i rate:$rate item:$item

df output is:
------------------------------------------------------------------
$DfResult

" | mail -s "[Alarm] server $ServerName disk use exceed rate $warnRate % and current is $rate %" $sendto
           done
        fi
    fi
    i=`expr $i + 1`
done
rm -rf $tmpFile
