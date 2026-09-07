# oracle 执行分析

## 分析过程
- 执行解析计划
- 语法
```sql
explain plan for
${sql-body}
```
- 举例
```sql
explain plan for
select * from sys_user
```
- 查看解析计划
```sql
SELECT * 
FROM table(dbms_xplan.display)
```


## 查询锁
- 查询所有锁
```sql
SELECT  
'ALTER SYSTEM KILL SESSION '''||b.SID||','||b.SERIAL#||''';' AS KILL_SQL,
a.ORACLE_USERNAME,a.OS_USER_NAME,
a.SESSION_ID ,b.SERIAL#,
(sysdate-b.PREV_EXEC_START)*24*60*60 AS EXEC_SECONDS,
(sysdate-b.PREV_EXEC_START)*24*60*60 AS EXEC_MINUTES,
c.SQL_FULLTEXT,
d.SQL_FULLTEXT AS PREV_SQL_FULLTEXT,
a.PROCESS,a.LOCKED_MODE,
b.USERNAME,b.COMMAND,b.STATUS,b.SERVER,b.SCHEMANAME,b.OSUSER,b.PROCESS,b.MACHINE,
b.TERMINAL,b.PROGRAM,b.PREV_EXEC_START,b.MODULE
FROM   V$LOCKED_OBJECT a
LEFT JOIN V$SESSION b ON b.SID=a.SESSION_ID 
LEFT JOIN gv$sql c ON c.SQL_ID=b.SQL_ID 
LEFT JOIN gv$sql d ON d.SQL_ID =b.PREV_SQL_ID 
ORDER BY  EXEC_SECONDS DESC
```
