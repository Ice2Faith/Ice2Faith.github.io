# Oracle 语法集锦
---
## 日期
- 当前时间
```sql
select 
    sysdate
from dual;
```
- 格式化日期时间
```sql
select 
    to_char(sysdate,'yyyy-MM-dd hh24:mi:ss')
from dual;
```
- 转换为日期时间
```sql
to_date(#{createTime,jdbcType=VARCHAR},'yyyy-MM-dd hh24:mi:ss')
```
- 时间加减
- {date} [+|-] INTERVAL {value} [ YEAR | MONTH | DAY | HOUR | MINUTE | SECODE ]
```sql
select 
    sysdate + INTERVAL '1' day
from dual;
select 
    sysdate - INTERVAL '2' hour
from dual;
```
- group concat
```sql
select a.qu_id , count(*) repo_cnt,
        LISTAGG( b.title, ',') WITHIN GROUP(ORDER BY b.title asc) AS repo_strs
        from exam_qu_repo_ref a
        left join exam_qu_repo b on b.id =a.repo_id
        group by a.qu_id
```
- random order
```sql
ORDER BY dbms_random.value()
```
- linenumber
    - 没有对应的函数或者关键字
    - 使用自定义变量方式实现
```sql
select (@rownum:=@rownum+1) rownum,a.*
from sys_user a,
(select @rownum:=0) b
```

- 如果空则取第二个

```sql
select coalesce(a.name, '无')
from sys_user a

select nvl(a.name, '无')
from sys_user a
```
- page
```sql
select *
from (
    select tmp.*,rownum row_id
    from (
            select a.*
            from sys_user a
    ) tmp
    where rownum<= 20
) tmp
where row_id > 0
```
- insert-batch
```sql
insert into sys_user
(
ID,
name
)

select SEQ_SYS_USER_ID.nextval,tmp.*
from (

	select 'admin' AS name from dual
	
	union all 
	
	select 'logger' AS name from dual

) tmp 

```
- 递归查询路径
```sql
-- 递归查询路径
SELECT * FROM SYS_AREA a
START WITH a.ID = 101010
CONNECT BY PRIOR a.PARENT_ID = a.ID
```
- 递归查询所有子节点
```sql
SELECT * FROM SYS_AREA a
START WITH a.ID = 101010
CONNECT BY PRIOR a.ID = a.PARENT_ID
```
- 随机排序
```sql
select *
from SYS_AREA a 
order by dbms_random.value()
```
- 查询时带出整个路径
```sql
SELECT 
(
	SELECT LISTAGG(p.NAME,'/') WITHIN GROUP(ORDER BY ROWNUM desc) AS NAME_PATH -- 这里因为是找路径，递归层数越大的应该是越顶层，因此对行号 rownum 进行降序
	FROM SYS_AREA p
	START WITH p.ID=a.ID
	CONNECT BY PRIOR p.PARENT_ID = p.ID -- 因为带了 PRIOR 参数，因此默认排序就是递归层数排序
) AS AREA_PATH
FROM SYS_AREA a
```
- 批量更新
```sql
merge into SYS_USER t
USING (
	-- 批量更新的表查询，或者union all 进来数据也可以
    select 
        USER_NAME,
        PHONE,
        BIRTH_DAY,
        REMARK
    from SYN_SYS_USER
    where UPDATE_TIME > SYSDATE - INTERVAL '1' DAY
    
) tmp
ON (t.USER_NAME=tmp.USER_NAME
AND t.PHONE=tmp.PHONE
)
WHEN MATCHED THEN
	UPDATE SET t.BIRTH_DAY =tmp.BIRTH_DAY,
	t.REMARK =tmp.REMARK
WHEN NOT MATCHED THEN
    INSERT (USER_NAME, PHONE, BIRTH_DAY,REMARK)
    VALUES (tmp.USER_NAME, tmp.PHONE, tmp.BIRTH_DAY, tmp.REMARK)
```

---
## DDL
- 创建表
```sql
create table tb_user
(
    user_id bigint primary key ,
    login_name varchar(50) unique not null ,
    password varchar(50) ,
    status char(1) default 1,
    create_time date default sysdate
) ;
```
- 添加注释
```sql
comment on table tb_user 
is '用户表';

comment on column tb_user.login_name
is '登录名';
```
- 创建序列
```sql
create sequence SEQ_TB_USER_USER_ID
    increment by 1
    start with 1
    maxvalue 9999999999999;
```
- 使用序列
```sql
select 
    SEQ_TB_USER_USER_ID.nextval 
from dual
```
- 批量取序列
```sql
SELECT 
	SEQ_TB_USER_USER_ID.nextval
FROM (
	select level
	from dual
	connect by level <= 5 -- 取序列的个数
) a
```
- 创建索引
```sql
create index idx_login_name_status
on tb_user(login_name,status);
```
- 修改表字段类型
    - 原理就是，使用中间列做转换
```sql
alter table tb_user
rename column tar_col to tmp_col;

alter table tb_user
add tar_col Long;

update tb_user
set tar_col=tmp_col
where 1=1;

alter table tb_user
drop column tmp_col;
```
- 查看表的建表语句
```sql
select dbms_metadata.get_ddl('tb_user','a') 
from dual;
```
- 重命名列
```sql
alter table tb_user
rename column col_age to col_age_new;
```
- 添加列
```sql
alter table tb_user
add col_fav varchar2(30);
```
- 删除列
```sql
alter table tb_user
drop column col_fav;
```

---

## 杂项

- oracle的varchar2类型
- 具体分为：varchar2(10 byte) 表示使用字节计算长度，表示10字节长度
- varchar2(10 char) 表示使用字符计算长度，表示10字符长度
- varchar2(10) 不携带单位，这默认就是byte
- 所以，在这种情况下，数据库的字符集不同，一个中文占用的字节长度就不同
- 这就需要注意了
- 查询数据库字符集

```sql
SELECT *
FROM v$nls_parameters
WHERE PARAMETER = 'NLS_CHARACTERSET';
```

- 查询一个中文占用多少字节

```sql
select lengthb('中国')
from dual;
```