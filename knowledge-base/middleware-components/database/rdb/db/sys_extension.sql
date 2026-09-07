create table sys_asyn_send_msg
(
	id bigint auto_increment primary key comment '主键',
	type_key varchar(300) comment '消息类型',

	title varchar(1024) comment '标题',
	content text comment '内容',
	send_type varchar(300) comment '发送类型',

	receivers text comment '接受者',

	send_time datetime default now() comment '发送时间',

	status tinyint comment '处理状态：0 初始化，1 发送中，2 成功，3 失败，9 终止',

    failures text comment '接受失败的接受者',
	fail_cnt int comment '失败次数',
	fail_msg text comment '失败信息',
	max_fail_cnt int comment '最大失败次数',

	create_time datetime default now() comment '创建时间',
	create_by varchar(300) comment '创建人',
	update_time datetime comment '更新时间',
	update_by varchar(300) comment '更新人',

	task_time datetime comment '任务执行时间'

) comment '异步发送消息表';

create index idx_tkey_stime_status
on sys_asyn_send_msg(type_key,send_time,status);



create table sys_time_machine (
  id bigint auto_increment primary key comment '自增ID',
  type_key int not null comment '时间机类型',
  group_key varchar(300)  comment '此时间机的分组KEY，按需使用',
  curr_time datetime NOT NULL comment '时间机时间',
  next_time datetime  comment '下一时间机时间，按需使用',
  status int  comment '时间机状态，按需使用',
  param1 varchar(300)  comment '参数1，按需使用',
  param2 varchar(300)  comment '参数2，按需使用',
  param3 varchar(300)  comment '参数3，按需使用'
)  comment='时间机:时间机采用二级分类法，必要一级分类type_key,可以添加group_key二级分类';

create index idx_curr_next
on sys_time_machine(curr_time,next_time);

create index idx_group_type
on sys_time_machine(group_key,type_key);

create table sys_media
(
 id bigint auto_increment primary key comment 'ID',
 media_type int comment '媒体类型：0 图片，1 视频，2 音频，4 文档',
 store_type int comment '存储类型：0 默认，1 本地存储，2 MinIo',

 checksum varchar(512) comment '校验和',

 encrypt_type int comment '加密类型：0 不加密，1 快速异或',
 ecrypt_key varchar(300) comment '加密秘钥',

 file_name varchar(1024) comment '文件名',
 file_size bigint comment '文件大小，单位byte',

 url varchar(2048) comment '访问URL',
 server_path varchar(2048) comment '服务器路径',

 create_time datetime default now() comment '创建时间',
 create_user varchar(300) comment '创建人'
) comment '媒体表';

create index idx_checksum
on sys_media(checksum);


