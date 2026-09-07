echo [crontab] will be open after you read below line ...
echo 1.edit crontab with vi/vim
echo 2.add one line like next line
echo 0 0 1 * * cd /home;sh batch-backup.sh
echo 3.explain for this line
echo [0 0 1 * *] is cron expression
echo [cd /home;sh batch-backup.sh] is execute command line
echo [cd /home;] right run batch-backup.sh need before change directory to batch-backup.sh location
echo 4.maybe you need reload cron [service crond reload]
echo 5.maybe you need start crontab [service crond start]
echo 6.maybe you need view crontab status [service cdond status]
echo ------------------------------------
read -p press any key to open [crontab]
crontab -e
