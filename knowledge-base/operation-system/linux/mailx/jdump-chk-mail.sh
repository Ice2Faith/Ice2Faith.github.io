rootPath="/"

ServerName=`hostname`
TimeNow=$(date "+%Y-%m-%d %H:%M:%S")

echo server java oom dump file on $ServerName checking...

tmpFile="/tmp/jdump-chk.dat"
midFile="$tmpFile.tmp"
find $rootPath -name "*.hprof" > $midFile 2>&1
cat $midFile | grep -v denied > $tmpFile
rm -rf $midFile
hprofResult=`cat $tmpFile`


i=0
cat $tmpFile | while read item;
do
    fileName=`basename $item`
    pid=`echo $fileName | awk -F "java_pid" '{print $2}' | awk -F "." '{print $1}'`
    pidPsCount=`ps -ef | awk '{print $2}' | grep $pid | wc -l`
    warnFile="/tmp/jdump-warn-${pid}.log"
    if [[ -f "$warnFile" ]]; then
        echo -e "alarmed line:$i pid:$pid process:$pidPsCount item:$item"
    else
	    echo -e "line:$i pid:$pid process:$pidPsCount item:$item" > $warnFile
      # send email
      for sendto in x123@qq.com x456@139.com;
      do
        echo ------------------- send mail to $sendto -------------------
        echo -e "\
your server $ServerName has java oom dump file $fileName at $TimeNow, please check it!

java oom dump file:
line:$i pid:$pid process:$pidPsCount item:$item

find hprof output is:
------------------------------------------------------------------
$hprofResult

" | mail -s "[Alarm] server $ServerName has java oom dump file $fileName " $sendto
    done
  fi
  i=`expr $i + 1`
done
rm -rf $tmpFile
