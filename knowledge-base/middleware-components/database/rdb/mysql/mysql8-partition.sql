-- ------------------------------------------------------------------------------

-- 日分区表
-- 按照create_time进行分区
-- 分区名：p+format(create_time,yyyyMMdd)
-- 分区range：<= (create_time,yyyyMMdd)
-- 举例：p20230331 --> 20230401
CREATE TABLE biz_table_name_day (
  id bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  
  create_time datetime not null  COMMENT '时间',
  
  PRIMARY KEY (`id`,`create_time`) -- 分区字段必须是主键的一部分
) COMMENT='分区表'
PARTITION BY RANGE ((year(create_time)*100+month(create_time))*100+day(create_time)) (
PARTITION p20230331 VALUES LESS THAN (20230401)
-- ,PARTITION p1 VALUES LESS THAN (MAXVALUE) -- 想要增加分区，必须去掉此句
);

-- 增加日分区
ALTER TABLE biz_table_name_day
ADD PARTITION (
PARTITION p20230401 VALUES LESS THAN (20230402),
PARTITION p20230402 VALUES LESS THAN (20230403)
);

-- 查询表的分区
SELECT PARTITION_NAME,TABLE_ROWS
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_NAME = 'biz_table_name_day';

-- 插入数据到分区表
insert into biz_table_name_day (create_time)
select create_time 
from biz_data 
where create_time >= '2023-03-31'
and create_time < '2023-04-01';


-- ------------------------------------------------------------------------------

-- 月分区表
-- 按照create_time进行分区
-- 分区名：p+format(create_time,yyyyMM)
-- 分区range：<= (create_time,yyyyMM)
-- 举例：p202303 --> 202304
CREATE TABLE biz_table_name_month (
  id bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  
  create_time datetime not null  COMMENT '时间',
  
  PRIMARY KEY (`id`,`create_time`) -- 分区字段必须是主键的一部分
) COMMENT='分区表'
PARTITION BY RANGE (year(create_time)*100+month(create_time)) (
PARTITION p202303 VALUES LESS THAN (202304)
-- ,PARTITION p1 VALUES LESS THAN (MAXVALUE) -- 想要增加分区，必须去掉此句
);


-- 增加月分区
ALTER TABLE biz_table_name_month
ADD PARTITION (
PARTITION p202304 VALUES LESS THAN (202305),
PARTITION p202305 VALUES LESS THAN (202306)
);

-- 查询表的分区
SELECT PARTITION_NAME,TABLE_ROWS
FROM INFORMATION_SCHEMA.PARTITIONS
WHERE TABLE_NAME = 'biz_table_name_month';

-- 插入数据到分区表
insert into biz_table_name_month (create_time)
select create_time 
from biz_data 
where create_time >= '2023-03-01'
and create_time < '2023-04-01';
