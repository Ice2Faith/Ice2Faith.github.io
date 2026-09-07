
-- 如果存在则删除
drop procedure if exists sp_template;

-- 定义分隔符
delimiter $$
-- 创建存过
create procedure sp_template(
-- 存过的入参，出参定义
in task_time datetime, 
out ret_code int,
out ret_msg varchar(300)
)
begin
	-- 变量都在最开始声明
	-- -------------------------------------------------
	-- 声明变量
	declare fmt_task_time varchar(300);
	declare trace_step int;
	
	declare age int;
	declare i int;
   	declare content varchar(300);
	
	-- 声明异常变量
	declare except_code varchar(50);
	declare except_msg varchar(2048);
   	-- 游标变量
   -- 声明游标结束条件变量
	declare done int;
	declare row_id bigint;
	declare row_cur int;
	declare row_sum int;
   	-- 声明游标
	-- 游标变量必须在最后声明
	declare cur_test cursor for
	select * from tb_test order by id;
	-- 游标处理函数必须声明在游标之后
	declare continue handler for not found set done=1;
	
	-- 定义异常处理
	declare exit handler for sqlexception begin         
        -- 获取报错信息
		get diagnostics condition 1 except_code = returned_sqlstate, except_msg = message_text;        
       	-- 回滚操作
       	rollback;
        
       set ret_code=-1;
       set ret_msg=concat(
      		'exception',
      		' , last code=',ifnull(ret_code,''),
      		' , last message: ',ifnull(ret_msg,''),
      	    ' , exception code=',ifnull(except_code,''),
      	    ' , exception message: ',ifnull(except_msg,''));
        -- record error log
    end;
   
   -- 开启事务
   start transaction;
   
    -- -------------------------------------------------
	-- 更改变量
	set ret_code=0;
	set ret_msg='开始处理...';
	
	select date_format(task_time,'%Y-%m-%d %H:%i:%d') into fmt_task_time from dual;
	set trace_step=0;
	
    -- -------------------------------------------------
	-- 处理内容
	set trace_step=trace_step+1;
	SELECT concat(VERSION(),'@',fmt_task_time,'-',trace_step) into ret_msg from dual;
    
	-- -------------------------------------------------
    -- 条件判定
    set age = 12;
   	set content = '未知';
	if age < 18 then
        set content = '未成年人';
    elseif 18<= age and age <=65 then
        SET content = '青年人';
    elseif 66<= age and age <=79 then
        SET content = '中年人';
    else 
        SET content = '老年人';
	end if;

	set ret_msg=concat(ret_msg,'*',content,'<=',age);

	-- -------------------------------------------------
	-- 分支判定
    set age = 22;
   	set content = '未知';
	case
		when age < 18 then
        set content = '未成年人';
    when 18<= age and age <=65 then
        SET content = '青年人';
    when 66<= age and age <=79 then
        SET content = '中年人';
    else 
        SET content = '老年人';
	end case;

	set ret_msg=concat(ret_msg,'*',content,'<=',age);

	-- -------------------------------------------------
	-- 循环
	while age>0 
	do
	    set age=age-1;
	end while;

	set ret_msg=concat(ret_msg,'@age=',age);

	-- -------------------------------------------------
    -- 直到，do-while
    repeat
    	set age=age+1;
	until age>20 
	end repeat;

	set ret_msg=concat(ret_msg,'@age=',age);

	-- -------------------------------------------------
    -- 循环，跳出型，while(true)
	set i=0;
    set age=0;
    loop_label: loop
	    
	    if i>10 then
	        leave loop_label; -- break
	    end if;
	   
	   if mod(i,2)=0  then
	   		set i=i+1;
	   		iterate loop_label; -- continue
	   	end if;
	   
	   set age=age+i;
	   set i=i+1;
	end loop loop_label;

	set ret_msg=concat(ret_msg,'@age=',age,'@i=',i);

	-- -------------------------------------------------
	-- 创建表
	drop table if exists tb_test;
	create table tb_test(
		id bigint primary key auto_increment,
		cur_val int,
		sum_val int
	);

	insert into tb_test
	(cur_val)
	select 1 from dual
	union all
	select 2 from dual
	union all
	select 3 from dual
	union all
	select 4 from dual
	union all
	select 5 from dual;

	-- -------------------------------------------------
    -- 游标
	-- 游标声明见最开头
	
	-- 初始游标变量为未结束
	set done=0;
   
	-- 打开游标
	open cur_test;

	set age=0;
	-- 遍历游标
	cur_loop: loop
		-- 处理游标
		-- 获取游标中的行
		fetch cur_test into row_id,row_cur,row_sum;
		
		-- 判断是否结束
		-- 一定要注意，判断一定要在fetch之后
		if done=1 then
			leave cur_loop;
		end if;
		
		
		
		-- 逻辑处理
		set age=age+ifnull(row_cur,0);
		
		update tb_test
		set sum_val=age
		where id=row_id;
	
	end loop cur_loop;
	
	-- 关闭游标
	close cur_test;

	-- 保存结果
	select group_concat(row_text) into content
	from (
		select concat('#id=',id,',cur_val=',cur_val,',sum_val=',sum_val) row_text
		from tb_test 
		order by id
	) a;
	drop table if exists tb_test;

	set ret_msg=concat(ret_msg,'@rows=',content);
	
	
	commit;
	
	-- 返回响应
	set ret_code=200;
end $$


-- -------------------------------------------------
-- 调用存过
-- 使用用户变量@来接受存过的调用结果
call sp_template(now(),@ret_code,@ret_msg);
select @ret_code,@ret_msg;
