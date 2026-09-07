warnCount=1


ServerName=`hostname`
TimeNow=$(date "+%Y-%m-%d %H:%M:%S")

echo server online user exceed warn count on $ServerName checking...

userCount=`who | wc -l`
whoResult=`who`
lastResult=`last -10`
historyResult=`history | tail -10`

if [ $userCount -ge $warnCount ];then
    # send email
    for sendto in x123@qq.com x456@139.com;
    do
        echo ------------------- send mail to $sendto -------------------
        echo -e "\
your server $ServerName online user has exceed warn count $warnCount and current is $userCount at $TimeNow, please check it!

online user count: $userCount

who output is:
------------------------------------------------------------------
$whoResult

last output is:
------------------------------------------------------------------
$lastResult

history output is:
------------------------------------------------------------------
$historyResult

" | mail -s "[Alarm] server $ServerName online user exceed count $userCount and current is $warnCount " $sendto
    done
fi

