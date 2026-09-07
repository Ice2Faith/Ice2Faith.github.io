-- 创建历史表存过
-- 入参，需要创建历史表的表名
-- 调用示例
--      call sp_his_make('sys_user');

CREATE PROCEDURE sp_his_make(
in tb_name varchar(300)
)
begin

declare done boolean default 0;

declare exec_sql varchar(3000);

declare cur cursor for 
select  concat('create table his_',tb_name,' as select * from ',tb_name,' where 1=2;') from dual
union all select concat('alter table his_',tb_name,' add column his_id int auto_increment primary key;') from dual
union all select concat('alter table his_',tb_name,' add column his_date datetime default now();') from dual
union all select concat('alter table his_',tb_name,' add column his_remark varchar(300);') from dual
union all select concat('alter table his_',tb_name,' add column his_oper varchar(300);') from dual
union all select concat('alter table his_',tb_name,' add column his_type int;') from dual;

declare continue HANDLER for SQLSTATE '02000' set done=1;

open cur;

repeat
fetch cur into exec_sql;
	set @pre_sql=exec_sql;
	prepare stat from @pre_sql;
	execute stat;
	deallocate prepare stat;
    set exec_sql='';
until done end repeat;
close cur;


end