create table sys_user
(
 id bigint auto_increment primary key comment 'ID',
 username varchar(300) not null comment '登录用户名',
 password varchar(300) not null comment '登录密码',
 realname varchar(300) comment '用户名',
 phone varchar(50) comment '电话号码',
 email varchar(300) comment '电子邮箱',
 reg_date datetime default now() comment '注册时间',
 del_flag tinyint default 1 comment '是否可删除：0 不可，1 可以',
 sys_flag tinyint default 0 comment '是否系统：0 否，1 是',
 status int default 1 comment '状态：0 禁用，1 启用，99 删除',
 create_time datetime default now() comment '创建时间',
 create_user varchar(300) comment '创建人',
 update_time datetime comment '更新时间',
 update_user varchar(300) comment '更新时间'
) comment '用户表';

create index idx_status_username_password
on sys_user(status,username,password);

create index idx_status_phone_password
on sys_user(status,phone,password);

create index idx_status_email_password
on sys_user(status,email,password);

create table sys_role
(
 id bigint auto_increment primary key comment 'ID',
 role_key varchar(300) comment '角色键',
 role_name varchar(300) comment '角色名称',
 status int default 1 comment '状态：0 禁用，1 启用，99 删除',
 del_flag tinyint default 1 comment '是否可删除：0 不可，1 可以',
 sys_flag tinyint default 0 comment '是否系统：0 否，1 是',
 create_time datetime default now() comment '创建时间',
 create_user varchar(300) comment '创建人',
 update_time datetime comment '更新时间',
 update_user varchar(300) comment '更新时间'
) comment '角色表';

create index idx_status_rkey
on sys_role(status,role_key);

create table sys_user_role
(
 id bigint auto_increment primary key comment 'ID',
 user_id bigint not null comment '用户ID，见：sys_user.id',
 role_id bigint not null comment '角色ID，见：sys_role.id',
 create_time datetime default now() comment '创建时间',
 create_user varchar(300) comment '创建人'
) comment '用户-角色表';

create unique index unq_user_role
on sys_user_role(user_id,role_id);

create table sys_resources
(
 id bigint auto_increment primary key comment 'ID',
 name varchar(300) comment '名称',
 menu_key varchar(300) comment '菜单键',
 type int not null default 0 comment '类型：0 菜单，1 接口，2 按钮，3 权限',
 url varchar(4096) comment 'URL',
 perm_key varchar(300) comment '权限键',
 remark varchar(300) comment '备注',
 parent_id bigint comment '父资源ID，见：sys_resources.id',
 status int default 1 comment '状态：0 禁用，1 启用，99 删除',
 create_time datetime default now() comment '创建时间',
 create_user varchar(300) comment '创建人',
 update_time datetime comment '更新时间',
 update_user varchar(300) comment '更新时间'
) comment '资源表';

create index idx_status_type
on sys_resources(status,type);

create table sys_role_resources
(
 id bigint auto_increment primary key comment 'ID',
 role_id bigint not null comment '角色ID，见：sys_role.id',
 res_id bigint not null comment '资源ID，见：sys_resources.id',
 create_time datetime default now() comment '创建时间',
 create_user varchar(300) comment '创建人'
) comment '角色-资源表';

create unique index unq_role_res
on sys_role_resources(role_id,res_id);

create table sys_config
(
 id bigint auto_increment primary key comment 'ID',
 group_key int not null comment '分组KEY',
 group_name varchar(300) comment '分组名称',
 type_key int not null comment '类型KEY',
 type_name varchar(300) comment '类型名称',
 entry_id bigint not null comment '项ID',
 entry_key varchar(1024) comment '项键',
 entry_name varchar(1024) comment '项名称',
 entry_desc varchar(1024) comment '项描述',
 entry_order int comment '项排序',
 parent_entry_id bigint comment '父项ID，见：sys_config.entry_id',
 param_desc varchar(1024) comment '参数描述',
 param1 varchar(2048) comment '参数1',
 param2 varchar(2048) comment '参数2',
 param3 varchar(2048) comment '参数3',
 param4 varchar(2048) comment '参数4',
 param5 varchar(2048) comment '参数5',
 status int default 1 comment '状态：0 禁用，1 启用，99 删除',
 level int comment '层级',
 valid_time datetime default now() comment '生效时间',
 invalid_time datetime default '3000-01-01 00:00:00' comment '失效时间',
 mod_flag tinyint default 1 comment '是否可修改：0 不可，1 可以',
 del_flag tinyint default 1 comment '是否可删除：0 不可，1 可以',
 sys_flag tinyint default 0 comment '是否系统：0 否，1 是',
 create_time datetime default now() comment '创建时间',
 create_user varchar(300) comment '创建人',
 update_time datetime comment '更新时间',
 update_user varchar(300) comment '更新时间'
) comment '配置表';

create unique index unq_group_type_entry
on sys_config(group_key,type_key,entry_id);

create index idx_status_valid_invalid
on sys_config(status,valid_time,invalid_time);

create index idx_status_parent
on sys_config(status,parent_entry_id);

create table sys_dept
(
 id bigint auto_increment primary key comment 'ID',
 name varchar(300) comment '名称',
 remark varchar(1024) comment '备注',
 parent_id bigint comment '父资源ID，见：sys_dept.id',
 level int comment '层级',
 status int default 1 comment '状态：0 禁用，1 启用，99 删除',
 create_time datetime default now() comment '创建时间',
 create_user varchar(300) comment '创建人',
 update_time datetime comment '更新时间',
 update_user varchar(300) comment '更新时间'
) comment '部门表';

create index idx_status_parent_id
on sys_dept(status,parent_id);

create table sys_user_dept
(
 id bigint auto_increment primary key comment 'ID',
 user_id bigint not null comment '用户ID，见：sys_user.id',
 dept_id bigint not null comment '部门ID，见：sys_dept.id',
 create_time datetime default now() comment '创建时间',
 create_user varchar(300) comment '创建人'
) comment '用户-部门表';

create unique index unq_user_dept
on sys_user_dept(user_id,dept_id);

drop table if exists sys_log;
CREATE TABLE sys_log (
  id bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  src_system varchar(50)  COMMENT '来源系统',
  src_module varchar(50)  COMMENT '来源模块',
  src_label varchar(50)  COMMENT '来源标签',
  log_location varchar(500)  COMMENT '日志位置（className）',
  log_type int  COMMENT '日志类型：0 登录日志，1 登出日志，2 注册日志，3 注销日志，4 接口日志，5 输出日志，6 服务器状态，7 服务异常，8 调用日志，9 回调日志',
  log_content text COMMENT '日志内容',
  log_level int  COMMENT '日志级别：0 ERROR，1 WARN，2 INFO，3 DEBUG，4 TRACE',
  operate_type int  COMMENT '操作类型：0 查询，1 新增，2 修改，3 删除，4 申请，5 审批，6 导入，7 导出',
  log_key varchar(300)  COMMENT '日志键',
  log_val varchar(300)  COMMENT '日志值',
  trace_id varchar(64)  COMMENT '跟踪ID',
  trace_level int  COMMENT '跟踪层次',
  user_id varchar(64)  COMMENT '操作用户账号',
  user_name varchar(256)  COMMENT '操作用户名称',
  client_ip varchar(256)  COMMENT '客户端IP',
  java_method varchar(1024)  COMMENT '请求java方法',
  except_type int  COMMENT '异常分类，0 Exception,1 RuntimeException,2 Error,3 Throwable,4 SQLException',
  except_class varchar(500)  COMMENT '异常类',
  except_msg varchar(500)  COMMENT '异常信息',
  except_stack text COMMENT '异常堆栈',
  request_url varchar(2048)  COMMENT '请求路径',
  request_param text COMMENT '请求参数',
  request_type varchar(10)  COMMENT '请求类型',
  cost_time bigint  COMMENT '耗时，毫秒',
  create_time datetime  COMMENT '创建时间',
  PRIMARY KEY (id),
  KEY idx_system_module_label (src_system,src_module,src_label),
  KEY idx_log_type (log_type),
  KEY idx_log_level (log_level),
  KEY idx_operate_type (operate_type),
  KEY idx_user_id (user_id)
) ENGINE=MyISAM  COMMENT='系统日志表';

create index idx_system_module_label
on sys_log(src_system,src_module,src_label);

create index idx_log_type
on sys_log(log_type);

create index idx_log_level
on sys_log(log_level);

create index idx_operate_type
on sys_log(operate_type);

create index idx_user_id
on sys_log(user_id);





-- ---------------------------------------------------------------------------------------------


INSERT INTO sys_config (group_key,group_name,type_key,type_name,entry_id,entry_key,entry_name,entry_desc,entry_order,parent_entry_id,param_desc,param1,param2,param3,param4,param5,status,level,valid_time,invalid_time,mod_flag,del_flag,sys_flag,create_time,create_user,update_time,update_user) VALUES
	 (1,'sys',1,'app',1,'app:name','开放平台',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2023-01-20 12:36:19','3000-01-01 00:00:00',1,0,1,'2023-01-20 12:36:19','1',NULL,NULL),
	 (1,'sys',1,'app',2,'app:icon','/app.icon',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2023-01-20 12:36:19','3000-01-01 00:00:00',1,0,1,'2023-01-20 12:36:19','1',NULL,NULL),
	 (1,'sys',1,'app',3,'app:admin:login:bgimg','/admin/login.png',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2023-01-20 12:36:20','3000-01-01 00:00:00',1,0,1,'2023-01-20 12:36:20','1',NULL,NULL),
	 (1,'sys',1,'app',4,'app:mobile:login:bgimg','/mobile/login.png',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,'2023-01-20 12:36:20','3000-01-01 00:00:00',1,0,1,'2023-01-20 12:36:20','1',NULL,NULL);

INSERT INTO sys_dept (name,remark,parent_id,level,status,create_time,create_user,update_time,update_user) VALUES
	 ('开放集团','根',NULL,0,1,'2023-01-20 11:47:54','1',NULL,NULL),
	 ('开放软件公司','一公司',1,1,1,'2023-01-20 12:37:32','1',NULL,NULL);

INSERT INTO sys_resources (name,menu_key,type,url,perm_key,remark,parent_id,status,create_time,create_user,update_time,update_user) VALUES
	 ('首页','home',0,'/home','home:index',NULL,NULL,1,'2023-01-20 11:52:57','1',NULL,NULL),
	 ('用户管理','admin:user',0,'/user','user:admin',NULL,NULL,1,'2023-01-20 11:56:48','1',NULL,NULL),
	 ('角色管理','admin:role',0,'/role','role:admin',NULL,NULL,1,'2023-01-20 11:56:48','1',NULL,NULL),
	 ('资源管理','admin:resources',0,'/resources','resources:admin',NULL,NULL,1,'2023-01-20 12:11:59','1',NULL,NULL),
	 ('部门管理','admin:dept',0,'/dept','dept:admin',NULL,NULL,1,'2023-01-20 11:56:48','1',NULL,NULL),
	 ('配置管理','admin:config',0,'/config','config:admin',NULL,NULL,1,'2023-01-20 11:56:48','1',NULL,NULL),
	 ('查看用户列表','list:user',1,'/user/list','user:list',NULL,2,1,'2023-01-20 12:03:14','1',NULL,NULL),
	 ('查看用户详情','detail:user',2,'/user/detail','user:detail',NULL,2,1,'2023-01-20 12:03:14','1',NULL,NULL),
	 ('变更用户状态','status:user',3,'/user/status','user:status',NULL,2,1,'2023-01-20 12:03:15','1',NULL,NULL),
	 ('新增用户','add:user',2,'/user/add','user:add',NULL,2,1,'2023-01-20 12:03:15','1',NULL,NULL),
	 ('更新用户','update:user',2,'/user/update','user:update',NULL,2,1,'2023-01-20 12:03:15','1',NULL,NULL),
	 ('删除用户','delete:user',2,'/user/delete','user:delete',NULL,2,1,'2023-01-20 12:03:15','1',NULL,NULL),
	 ('变更用户角色','change:user:role',2,'/user/role','user:role:change',NULL,2,1,'2023-01-20 12:16:03','1',NULL,NULL),
	 ('变更用户部门','change:user:dept',2,'/user/dept','user:dept:change',NULL,2,1,'2023-01-20 12:16:04','1',NULL,NULL),
	 ('查看角色列表','list:role',1,'/role/list','role:list',NULL,3,1,'2023-01-20 12:09:58','1',NULL,NULL),
	 ('查看角色详情','detail:role',2,'/role/detail','role:detail',NULL,3,1,'2023-01-20 12:09:58','1',NULL,NULL),
	 ('变更角色状态','status:role',3,'/role/status','role:status',NULL,3,1,'2023-01-20 12:09:58','1',NULL,NULL),
	 ('新增角色','add:role',2,'/role/add','role:add',NULL,3,1,'2023-01-20 12:09:58','1',NULL,NULL),
	 ('更新角色','update:role',2,'/role/update','role:update',NULL,3,1,'2023-01-20 12:09:59','1',NULL,NULL),
	 ('删除角色','delete:role',2,'/role/delete','role:delete',NULL,3,1,'2023-01-20 12:09:59','1',NULL,NULL);
INSERT INTO sys_resources (name,menu_key,type,url,perm_key,remark,parent_id,status,create_time,create_user,update_time,update_user) VALUES
	 ('变更角色资源','change:role:resources',2,'/role/resources','role:resources:change',NULL,3,1,'2023-01-20 12:16:04','1',NULL,NULL),
	 ('查看资源列表','list:resources',1,'/resources/list','resources:list',NULL,4,1,'2023-01-20 12:30:34','1',NULL,NULL),
	 ('查看资源详情','detail:resources',2,'/resources/detail','resources:detail',NULL,4,1,'2023-01-20 12:30:34','1',NULL,NULL),
	 ('变更资源状态','status:resources',3,'/resources/status','resources:status',NULL,4,1,'2023-01-20 12:30:34','1',NULL,NULL),
	 ('新增资源','add:resources',2,'/resources/add','resources:add',NULL,4,1,'2023-01-20 12:30:35','1',NULL,NULL),
	 ('更新资源','update:resources',2,'/resources/update','resources:update',NULL,4,1,'2023-01-20 12:30:35','1',NULL,NULL),
	 ('删除资源','delete:resources',2,'/resources/delete','resources:detele',NULL,4,1,'2023-01-20 12:30:35','1',NULL,NULL),
	 ('查看部门列表','list:dept',1,'/dept/list','dept:list',NULL,5,1,'2023-01-20 12:30:35','1',NULL,NULL),
	 ('查看部门详情','detail:dept',2,'/dept/detail','dept:detail',NULL,5,1,'2023-01-20 12:30:36','1',NULL,NULL),
	 ('变更部门状态','status:dept',3,'/dept/status','dept:status',NULL,5,1,'2023-01-20 12:30:36','1',NULL,NULL),
	 ('新增部门','add:dept',2,'/dept/add','dept:add',NULL,5,1,'2023-01-20 12:30:36','1',NULL,NULL),
	 ('更新部门','update:dept',2,'/dept/update','dept:update',NULL,5,1,'2023-01-20 12:30:36','1',NULL,NULL),
	 ('删除部门','delete:dept',2,'/dept/delete','dept:delete',NULL,5,1,'2023-01-20 12:30:36','1',NULL,NULL),
	 ('查看配置列表','list:config',1,'/config/list','config:list',NULL,6,1,'2023-01-20 12:30:37','6',NULL,NULL),
	 ('查看配置详情','detail:config',2,'/config/detail','config:detail',NULL,6,1,'2023-01-20 12:30:37','6',NULL,NULL),
	 ('变更配置状态','status:config',3,'/config/status','config:status',NULL,6,1,'2023-01-20 12:30:37','6',NULL,NULL),
	 ('新增配置','add:config',2,'/config/add','config:add',NULL,6,1,'2023-01-20 12:30:37','6',NULL,NULL),
	 ('更新配置','update:config',2,'/config/update','config:update',NULL,6,1,'2023-01-20 12:30:38','6',NULL,NULL),
	 ('删除配置','delete:config',2,'/config/delete','config:delete',NULL,6,1,'2023-01-20 12:30:39','6',NULL,NULL);

INSERT INTO sys_role (role_key,role_name,status,del_flag,sys_flag,create_time,create_user,update_time,update_user) VALUES
	 ('root','超级管理员',1,0,1,'2023-01-20 11:42:32','1',NULL,NULL),
	 ('dept:admin','部门管理员',1,0,1,'2023-01-20 11:45:09','1',NULL,NULL);

INSERT INTO sys_role_resources (role_id,res_id,create_time,create_user) VALUES
	 (1,1,'2023-01-20 12:39:38','1'),
	 (1,2,'2023-01-20 12:39:38','1'),
	 (1,3,'2023-01-20 12:39:38','1'),
	 (1,4,'2023-01-20 12:39:38','1'),
	 (1,5,'2023-01-20 12:39:38','1'),
	 (1,6,'2023-01-20 12:39:38','1'),
	 (1,2001,'2023-01-20 12:39:38','1'),
	 (1,3001,'2023-01-20 12:39:38','1'),
	 (1,4001,'2023-01-20 12:39:38','1'),
	 (1,5001,'2023-01-20 12:39:38','1'),
	 (1,6001,'2023-01-20 12:39:38','1'),
	 (1,2002,'2023-01-20 12:39:38','1'),
	 (1,2004,'2023-01-20 12:39:38','1'),
	 (1,2005,'2023-01-20 12:39:38','1'),
	 (1,2006,'2023-01-20 12:39:38','1'),
	 (1,2007,'2023-01-20 12:39:38','1'),
	 (1,2008,'2023-01-20 12:39:38','1'),
	 (1,3002,'2023-01-20 12:39:38','1'),
	 (1,3004,'2023-01-20 12:39:38','1'),
	 (1,3005,'2023-01-20 12:39:38','1');
INSERT INTO sys_role_resources (role_id,res_id,create_time,create_user) VALUES
	 (1,3006,'2023-01-20 12:39:38','1'),
	 (1,3007,'2023-01-20 12:39:38','1'),
	 (1,4002,'2023-01-20 12:39:38','1'),
	 (1,4004,'2023-01-20 12:39:38','1'),
	 (1,4005,'2023-01-20 12:39:38','1'),
	 (1,4006,'2023-01-20 12:39:38','1'),
	 (1,5002,'2023-01-20 12:39:38','1'),
	 (1,5004,'2023-01-20 12:39:38','1'),
	 (1,5005,'2023-01-20 12:39:38','1'),
	 (1,5006,'2023-01-20 12:39:38','1'),
	 (1,6002,'2023-01-20 12:39:38','1'),
	 (1,6004,'2023-01-20 12:39:38','1'),
	 (1,6005,'2023-01-20 12:39:38','1'),
	 (1,6006,'2023-01-20 12:39:38','1'),
	 (1,2003,'2023-01-20 12:39:38','1'),
	 (1,3003,'2023-01-20 12:39:38','1'),
	 (1,4003,'2023-01-20 12:39:38','1'),
	 (1,5003,'2023-01-20 12:39:38','1'),
	 (1,6003,'2023-01-20 12:39:38','1');


INSERT INTO sys_user (username,password,realname,phone,email,reg_date,del_flag,sys_flag,status,create_time,create_user,update_time,update_user) VALUES
	 ('root','123456','超级管理员','18011112222','ugex_savelar@163.com','2023-01-20 11:43:52',0,1,1,'2023-01-20 11:43:52','1',NULL,NULL),
	 ('dept_root','123456','集团董事长',NULL,NULL,'2023-01-20 11:50:51',1,0,1,'2023-01-20 11:50:51','1',NULL,NULL);

INSERT INTO sys_user_dept (user_id,dept_id,create_time,create_user) VALUES
	 (100,1,'2023-01-20 11:51:15','1');

INSERT INTO sys_user_role (user_id,role_id,create_time,create_user) VALUES
	 (1,1,'2023-01-20 11:45:54','1'),
	 (100,100,'2023-01-20 12:41:36','1');



-- ---------------------------------------------------------------------------------------------


-- 查询具有超级管理员权限的人员
select su.*
from sys_user su
left join sys_user_role sur on sur.user_id = su.id
left join sys_role sr on sur.role_id = sr.id
where sr.role_key ='root'
;

-- 保持超级管理员始终具有全部权限资源
insert into sys_role_resources(role_id,res_id,create_time,create_user)
select sr.id role_id,ss.id res_id,now(),1
from sys_resources ss
left join sys_role sr on sr.role_key = 'root'
where not exists (
select 1 from sys_role_resources srr
where srr.role_id =sr.id
and srr.res_id = ss.id
)
;


-- 查询用户资源列表
select su.id user_id,
su.username user_name,
su.password user_pass,
su.realname user_real,
su.phone user_phone,
su.email user_email,
sr.role_key,
sr.role_name,
sd.name dept_name,
sd.remark dept_remark,
ss.name res_name,
ss.perm_key res_perm
from sys_user su
left join sys_user_role ur on su.id =ur.user_id
left join sys_role sr on sr.id=ur.role_id
left join sys_role_resources rr on rr.role_id = sr.id
left join sys_resources ss on rr.res_id =ss.id
left join sys_user_dept ud on su.id=ud.user_id
left join sys_dept sd on sd.id =ud.dept_id
where (su.status !=99 or su.status is null)
and (sr.status !=99 or sr.status is null)
and (ss.status !=99 or ss.status is null)
and (sd.status !=99 or sd.status is null)
;

-- 查询指定用户的所有角色
select sr.*
from sys_role sr
left join sys_user_role ur on ur.role_id =sr.id
left join sys_user su on ur.user_id =su.id
where
-- 仅未删除
sr.status != 99
and su.status !=99
-- 仅已启用
and sr.status = 1
and su.status = 1
-- 仅目标人员
and su.id=1
;



-- 查询置顶用户的所有资源
select ss.*
from sys_resources ss
left join sys_role_resources srr on srr.res_id = ss.id
left join sys_user_role sur on sur.role_id =srr.role_id
left join sys_role sr on sur.role_id =sr.id
left join sys_user su on sur.user_id =su.id
where
-- 仅未删除
ss.status != 99
and sr.status != 99
and su.status != 99
-- 仅已启用
and ss.status =1
and sr.status =1
and su.status =1
-- 仅目标人员
and su.id=1
;


-- 查询配置
select sc.*
from sys_config sc
where
-- 仅未删除
sc.status !=99
-- 仅启用
and sc.status = 1
-- 仅在有效期内
and sc.valid_time <= now()
and sc.invalid_time >= now()
;

