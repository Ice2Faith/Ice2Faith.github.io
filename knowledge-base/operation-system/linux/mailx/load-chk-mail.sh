warnRate=0.8

# load=1 mean is full usage,load>1 mean is busy,load<1 mean is free.
# load=single_core_value*core_count
# so,average core load is load/core_count
warnRatePer=`echo $warnRate | awk '{print $1*100}' | awk -F "." '{print $1}'`

ServerName=`hostname`
TimeNow=$(date "+%Y-%m-%d %H:%M:%S")

echo server load exceed warn rate on $ServerName checking...

coreCount=`cat /proc/cpuinfo | grep processor | wc -l`

loadLine=`w | head -1 | awk -F "average:" '{print $2}'`

load5=`echo $loadLine | awk -F "," '{print $1}'`
load5=`echo $load5 $coreCount | awk '{print $1*100/$2}' | awk -F "." '{print $1}'`
load10=`echo $loadLine | awk -F "," '{print $2}'`
load10=`echo $load10 $coreCount | awk '{print $1*100/$2}' | awk -F "." '{print $1}'`
load15=`echo $loadLine | awk -F "," '{print $3}'`
load15=`echo $load15 $coreCount | awk '{print $1*100/$2}' | awk -F "." '{print $1}'`

tmpFile="/tmp/load-chk.dat"
echo -e "\
load-5 $load5
load-10 $load10
load-15 $load15" > $tmpFile

echo warn $warnRatePer, core $coreCount, load5 $load5, load10 $load10, load15 $load15

i=0
cat $tmpFile | while read item;
do
    loadName=`echo $item | awk '{print $1}'`
    loadValuePer=`echo $item | awk '{print $2}'`
    echo name $loadName, value $loadValuePer
    if [ $loadValuePer -gt $warnRatePer ];then
        # send email
        for sendto in x123@qq.com x456@139.com;
        do
          echo ------------------- send mail to $sendto -------------------
          echo -e "\
your server load on $ServerName has exceed warn rate $warnRatePer % and current is $loadValuePer % at $TimeNow, please check it!

load:
name:$loadName value:$loadValuePer

load output is:
------------------------------------------------------------------
$loadLine

" | mail -s "[Alarm] server $ServerName load exceed rate $warnRatePer % and current is $loadValuePer %" $sendto
       done
  fi
  i=`expr $i + 1`
done
rm -rf $tmpFile
