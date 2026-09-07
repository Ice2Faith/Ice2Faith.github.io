create table sys_article
(
 id bigint auto_increment primary key comment 'ID',
 group_key int comment '分组KEY',
 type_key int comment '类型KEY',

 title varchar(300) comment '标题',
 subtitle varchar(1024) comment '副标题',
 head_media bigint comment '主媒体，见：sys_media.id',

 author bigint comment '作者，见：sys_user.id',
 access_perm int comment '访问权限：0 仅自己可见，1 公开可见',

 content_type int comment '内容类型：0 文本，1 HTML，2 Markdown',
 content blob comment '内容',

 create_time datetime default now() comment '创建时间',
 create_user varchar(300) comment '创建人',
 update_time datetime comment '更新时间',
 update_user varchar(300) comment '更新人'
) comment '文章表';

create index idx_group_type_author
on sys_article(group_key,type_key,author);

create index idx_group_type_title
on sys_article(group_key,type_key,title);

create table sys_label
(
 id bigint auto_increment primary key comment 'ID',
 name varchar(300) comment '名称',
 create_time datetime default now() comment '创建时间',
 create_user varchar(300) comment '创建人'
) comment '标签表';

create unique index unq_name
on sys_label(name);

create table sys_article_label
(
 id bigint auto_increment primary key comment 'ID',
 article_id bigint comment '文章ID，见：sys_article.id',
 label_id bigint comment '标签ID，见：sys_label.id',
 create_time datetime default now() comment '创建时间',
 create_user varchar(300) comment '创建人'
) comment '文章-标签表';

create index idx_article
on sys_article_label(article_id);

create index idx_label
on sys_article_label(label_id);

create table sys_article_media
(
 id bigint auto_increment primary key comment 'ID',
 article_id bigint comment '文章ID，见：sys_article.id',
 media_id bigint comment '媒体ID，见：sys_media.id',
 create_time datetime default now() comment '创建时间',
 create_user varchar(300) comment '创建人'
) comment '文章-附件表';


create index idx_article
on sys_article_media(article_id);

