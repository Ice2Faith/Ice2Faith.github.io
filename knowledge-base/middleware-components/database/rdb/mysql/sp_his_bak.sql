-- 将数据表的数据根据条件备份到历史表的存过
-- 入参
--      tb_name 数据表的表名
--      where_cond 备份的where条件语句
--      his_remark 备份的描述字段
--      his_oper 备份的操作人
--      his_type 备份的类型，可以定义为 0 新增，1 更新，2 删除
-- 出参
--      bak_sql 最终执行的完整SQL
-- 调用示例
--      call sp_his_bak('sys_user','id=1001','新增测试','admin',0,@bak_sql);
--      select @bak_sql;

CREATE PROCEDURE sp_his_bak(
in tb_name varchar(300),
in where_cond varchar(300),
in his_remark varchar(300),
in his_oper varchar(300),
in his_type int,
out bak_sql varchar(3000)
)
begin


select
concat(
'insert into his_',tb_name,'(his_date,his_remark,his_oper,his_type,',cols,') select now(),''',his_remark,''',''',his_oper,''',',his_type,',',cols,' from ',tb_name,' where ',where_cond
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
