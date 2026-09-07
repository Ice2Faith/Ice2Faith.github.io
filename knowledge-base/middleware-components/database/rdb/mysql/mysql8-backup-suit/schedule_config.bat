@echo off
echo [task scheduled manager] will be open after you read below line ...
echo 1.expand [task scheduled program]
echo 2.choice [task scheduled program library]
echo 3.click [create task ...]
echo 4.tab to [normal]
echo 5.input [name]
echo 6.choice [run at whenever user login]
echo 7.tab to [trigger]
echo 8.click [create]
echo 9.select [with plan]
echo 10.choice [every day/every week/...]
echo 11.confirm trigger
echo 12.tab to [operation]
echo 13.click [create]
echo 14.select [start program]
echo 15.browser shell file [batch-backup.bat]
echo 16.set start from is [the batch-backup.bat file location directory]
echo 17.confirm operation
echo 18.tab to [setting]
echo 19.check [allow run on needed]
echo 20.check [right now start task when exceed plan time]
echo 21.confirm task configuration.
echo ------------------------------------
echo press any key to open [task scheduled manager]
pause
start taskschd.msc