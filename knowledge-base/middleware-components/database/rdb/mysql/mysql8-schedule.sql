
-- 查看事件变量
show variables like '%event%sche%'; 

-- 查看所有事件
show events;
       
-- 开启事件支持
set global event_scheduler=1;
       
-- 创建存储过程
CREATE PROCEDURE proc_sync_his()
insert into his_sys_user
(
id,username,password,create_time,
his_date,his_desc,his_oper
)
select
id,username,password,create_time
create_time as his_date,'定时刷新历史表','admin'
from sys_user
where create_time >= date_sub(now(),interval 2 HOUR);

-- 创建定时事件
create event if not EXISTS event_proc_sync_his
on schedule every  1 HOUR STARTS now()
on completion preserve  do call proc_sync_his(); 


-- 删除事件
drop event event_proc_sync_his;

-- 关闭事件
alter event event_proc_sync_his on COMPLETION PRESERVE DISABLE;  

-- 开启事件
alter event event_proc_sync_his on COMPLETION PRESERVE ENABLE; 