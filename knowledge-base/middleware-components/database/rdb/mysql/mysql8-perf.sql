-- mysql8 卡顿分析

-- ----------------------------------------------------
-- 查看连接进程
select 
concat('kill ',a.ID,';') kill_sql,
a.`USER`,
substring_index(a.HOST ,':' ,1) as ip,
a.DB,
a.COMMAND,
a.`TIME`,
a.STATE,
a.INFO
from information_schema.PROCESSLIST a
where a.`USER` !='event_scheduler'
order by a.`TIME` desc;


-- 查看IP连接进程排行
select ip,DB,count(*) as cnt
from (
	select a.`USER`,
	substring_index(a.HOST ,':' ,1) as ip,
	a.DB,
	a.COMMAND,
	a.`TIME`,
	a.STATE,
	a.INFO
	from information_schema.PROCESSLIST a
	where a.`USER` !='event_scheduler'
) a
group by ip,DB
order by cnt desc;

-- 查看IP的cmd排行
select ip,DB,command,count(*) as cnt
from (
	select a.`USER`,
	substring_index(a.HOST ,':' ,1) as ip,
	a.DB,
	a.COMMAND,
	a.`TIME`,
	a.STATE,
	a.INFO
	from information_schema.PROCESSLIST a
	where a.`USER` !='event_scheduler'
) a
group by ip,DB,command
order by cnt desc;

-- 查看大于30s占用时长排行
select 
concat('kill ',a.ID,';') kill_sql,
a.`USER`,
substring_index(a.HOST ,':' ,1) as ip,
a.DB,
a.COMMAND,
a.`TIME`,
a.STATE,
a.INFO
from information_schema.PROCESSLIST a
where a.`USER` !='event_scheduler'
and a.COMMAND !='Sleep'
and a.`TIME` > 30
order by `TIME` desc;



-- ----------------------------------------------------
-- 执行资源分析
-- 开启分析
set profiling=1;

-- 执行你的语句
select * from sys_user;

-- 列出语句列表，带有序号
show profiles;

-- 显示对应序号的资源使用情况，带all展示详细，不带all则展示简要
show profile all for query 4;

-- 关闭执行分析
set profiling=0;

-- ----------------------------------------------------
-- 查看等待的事务
SELECT concat('kill ',a.trx_mysql_thread_id,';') as kill_sql,
time_to_sec(now())-time_to_sec(a.trx_started) as trx_duration,
a.* 
FROM information_schema.INNODB_TRX a
order by trx_duration desc;

-- ----------------------------------------------------
-- 查询死锁表
select concat('kill ',a.THREAD_ID,';') as kill_sql,
a.* 
from performance_schema.data_locks a;

-- 查询表锁
select concat('kill ',a.THREAD_ID,';') as kill_sql,
a.* 
from performance_schema.data_locks a
where a.LOCK_TYPE = 'TABLE';


-- 查询死锁等待时间
select concat('kill ',a.BLOCKING_THREAD_ID,';') as kill_blk_sql,
concat('kill ',a.REQUESTING_THREAD_ID ,';') as kill_req_sql,
a.* 
from performance_schema.data_lock_waits a;

-- ----------------------------------------------------
-- 查看缓存池大小
show variables like '%buffer_pool%';

-- 查看文件
show variables like '%file%';

-- 查看连接
show variables like '%connect%';

-- 修改最大连接错误数
set global max_connect_errors=300;
flush hosts;

-- 修改最大连接数
set global max_connections=5120;


-- 查看缓存
show variables like '%cache%';

-- 修改线程缓存大小
set global thread_cache_size=60;

-- 修改缓存池大小
set global innodb_buffer_pool_size=8388608;

-- 查看线程
show variables like '%hread%';

-- 查看线程数
show global status like '%hread%';

-- 查看读取IO
show global status like 'i%read%';

-- 1、Innodb_buffer_pool_reads：物理读次数
-- 2、Innodb_data_read：物理读数据字节量
-- 3、Innodb_data_reads：物理读IO请求次数
-- 4、Innodb_pages_read：物理读数据页数
-- 5、Innodb_rows_read：物理读数据行数


-- 查看引擎状态
show engine innodb status;

-- 查看磁盘排序
show status like 'Sort_merge_passes';

-- 查看写线程
show variables like 'innodb_write_io_threads';

-- 日志写性能
show global status like 'Innodb_log_waits';

-- 日志每秒吞吐量
show global status like 'Innodb_os_log_written';

-- 日志每秒写入次数
show global status like 'Innodb_log_writes';

-- 查看日志缓存
show variables like '%log_buffer%';

-- 查询连接次数
SHOW STATUS LIKE 'Connections';

-- 查询慢查询
SHOW STATUS LIKE 'Slow_queries';


