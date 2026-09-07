# MySQL procedure

## 自动将表添加到备份表
- 删除已有存过
```sql
drop procedure sp_his_bak;
```
- 重新建立存过
```sql

delimiter //
create procedure sp_his_bak(
in tb_name varchar(300),
in where_cond varchar(300),
in his_remark varchar(300),
in his_oper varchar(300),
out bak_sql varchar(3000)
)
begin


select 
concat(
'insert into his_',tb_name,'(his_date,his_remark,his_oper,',cols,') select now(),''',his_remark,''',''',his_oper,''',',cols,' from ',tb_name,' where ',where_cond
)
into bak_sql

from (

select group_concat(COLUMN_NAME separator ',') cols  
from information_schema.`COLUMNS` c 
where TABLE_NAME  = tb_name

) tmp;

set @pre_sql=bak_sql;
prepare stat from @pre_sql;
execute stat;
deallocate prepare stat;

end
//

delimiter ;
```
- 调用存过进行历史表备份
```sql
call sp_his_bak('sys_dict', 'id=1001','备份测试','管理员',@bak_sql);
select @bak_sql;
```

---
## 自动创建表的历史表
- 删除已有存过
```sql
drop procedure sp_his_make;
```
- 创建存过
```sql

delimiter //
create procedure sp_his_make(
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
union all select concat('alter table his_',tb_name,' add column his_oper varchar(300);') from dual;

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
//

delimiter ;
```
- 调用存过，创建对应的表
```sql
call sp_his_make('sys_dict');
```
