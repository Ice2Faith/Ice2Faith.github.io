# Mybatis-Plus 常用语法

## 简介
- Mybatis-Plus是基于Mybatis之上开发包装的快速应用开发的ORM层
- 其原则是只做增强不做变更
- 因此Mybatis中能用的Mybatis-Plus都一样的能用
- 换句话说，Mybatis中能怎么写，Mybatis-Plus中就能怎么写
- 也就是因为如此，Mybatis-Plus的讲解中，涉及到Mybatis内容本身的
- 就不再这里讲解了
- 主要讲解Mybatis-Plus中的wrapper方法

## springboot+mybatis-plus
- 和mybatis的使用一样，只不过把mybatis的依赖替换为mybatis-plus的依赖即可
- 添加依赖pom.xml
```xml
<dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>mybatis-plus-boot-starter</artifactId>
    <version>3.4.1</version>
</dependency>
```
- 其他和mybatis一样的配置
- 也不再给出
- 给出Mybatis-Plus的配置application.properties
```properties
mybatis-plus.mapper-locations=classpath*:/mapper/**/*.xml,classpath:**/mapper/xml/*Mapper.xml,classpath:**/dao/xml/*Mapper.xml
mybatis-plus.global-config.db-config.table-underline=true
mybatis-plus.configuration.call-setters-on-nulls=true
mybatis-plus.configuration.log-impl=org.apache.ibatis.logging.slf4j.Slf4jImpl
```
- 配置解析
    - 第一行，指定扫描xml的路径
    - 第二行，指定自动将数据库中的下划线转换为驼峰形式到实体类中
    - 第三行，自定需要对null调用setter
    - 第四行，指定日志为slf4j
- 一般使用mybatis-plus还使用他自带的分页插件
- 如果需要使用，就配置插件
```java
package com.test.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Bean;
import com.baomidou.mybatisplus.extension.plugins.PaginationInterceptor;

@Configuration
public class MybatisPlusConfig{

    @Bean
    public PaginationInterceptor paginationInterceptor() {
        PaginationInterceptor paginationInterceptor = new PaginationInterceptor().setLimit(-1);
        return paginationInterceptor;
    }
}
```

## mybatis-plus 代码组织形式
- 在常规的开发场景中，都需要编写几乎相同的代码
- 做着重复的事情，也就是换一张表，换一些字段
- 对于这样的操作，mybatis-plus提供了简化的操作
- 将bean直接与table相关联
- 实现了常见的增删改查操作
- 因此，部分类就发生了变化

### bean实体类
- 前面说了，他实现了bean和实体的相关联
- 怎么实现相关联的，那就是在bean实体类的基础上
- 增加注解，使得实体类具有数据库的部分信息
- 能够进行相关联
- 因此，在实体类上加注解即可
```java
package com.test.model;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.annotation.TableField;
import lombok.Data;

@Data
@TableName("sys_user")
public class SysUser {
    @TableId
    protected Long id;

    protected String username;

    protected String password;

    @TableField("role_id")
    protected Long roleId;

    @TableField(exist = false)
    protected String keyword;
}
```
- 通过@TableName注解指定表名
- 通过@TableId注解指定主键列
- 通过@TableField执行列，不过这个通常不用指定，默认所有字段都是
- 特殊的，字段名和列名不一致，例如上面的roleId，就使用@TableField指定了字段名
- 特殊的，实体类中，多加了数据库中不存在的列，需要排除掉，例如上面的keyword，使用@TableField指定exist=false
- 前面的配置中，已经配置了自动驼峰下划线转换，因此没有指定TableField的属性
- 自动按照转下划线与数据库列匹配

### service类
- mybatis-plus提供了泛型基类，提供了常见的数据库操作能力
- 因此自己的service类继承接口即可，第一个泛型是实体bean
```java
package com.test.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import org.apache.ibatis.annotations.Param;

public interface ISysUserService extends IService<SysUser> {

}
```

### service-impl类
- 实现类也做相应的变更
    - 继承ServiceImpl，第一个泛型是对应的Mapper，第二个泛型是实体bean
    - 实现自己的接口
    - 特殊的说明，在ServiceImpl中，定义了一个protected的变量baseMapper
    - 因此可以在实现类中直接使用baseMapper，其实就是mapper接口对象
    - 换句话说，不需要再自己注入mapper对象了
```java
package com.test.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

public class SysUserServiceImpl extends ServiceImpl<SysUserMapper,SysUser> implements ISysUserService {

}
```

### mapper类
- mapper接口也做响应的变更
    - 继承BaseMapper，第一个泛型是实体bean
```java
package com.test.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.apache.ibatis.annotations.Param;

public interface SysUserMapper extends BaseMapper<SysUser>{

}
```

### mapper-xml文件是可选的
- 也就是说，可以不用xml文件里
- 如果Mybatis-Plus提供的基础方法够用
- 或者能用wrapper解决的情况下
- xml就是多余的，可以不要
- 要也可以，和mybatis的一样使用即可


## wrapper 包装器
- 由于很多操作，可能只是进行简单的操作
- 并不需要复杂的SQL就能完成
- 这部分操作单独去写一个Mapper文件，又没有什么必要
- wrapper包装器就是将SQL与代码结合
- 在代码中写SQL的一种写法
- 写起来虽然简单，但是运维上却有争论
- 一般来说，限制wrapper进行复杂操作
- wrapper在ServiceImpl中使用
- serviceImpl中使用baseMapper获取到mapper接口对象
- 使用其带有的方法即可

### lambda-wrapper 包装器
- lambda-wrapper包装器是在wrapper的基础上形成的
- 目的是使用lambda的方法引用，得到列名
- 从而避免由于直接写列名字符串导致的列名错误等问题
- 导致引发SQL错误
- 知识点：lambda，方法引用
- 下面的例子中，将会同时使用三种模式进行比对讲解
- 分别是wrapper模式，lambda-wrapper模式，SQL模式

### insert 插入
- 直接操作
```java
SysUser user=new SysUser();
user.setUsername("admin");

// 直接插入
this.baseMapper.insert(user);

// 插入或更新
this.baseMapper.save(user);
```
- 等价SQL
```sql
insert into sys_user(username) 
values ('admin');
```
- 插入相对来说，简单
- 没有wrapper的插入包装器


### update 更新
```java
SysUser user=new SysUser();
user.setId(101);
user.setUsername("admin");

this.baseMapper.updateById(user);
```
- 使用包装器
    - 使用set来进行设置列，
    - 使用其他的条件操作函数来设置更新条件
    - update函数第一个参数为实体bean，第二个为wrapper
    - 怎么理解呢？
    - 第一个参数理解为set部分，wrapper理解为条件部分
    - wrapper中也可以包含set部分
    - 因此有两种写法
- 写法一，直接在wrapper中加入set部分
```java
UpdateWrapper<SysUser> wrapper = new UpdateWrapper<SysUser>()
        .set("username","admin")
        .eq("id",101);

this.baseMapper.update(null,wrapper);
```
- 写法二，分开set部分和条件部分
```java
SysUser user=new SysUser();
user.setUsername("admin");

this.baseMapper.update(user,new UpdateWrapper<SysUser>().eq("id",101));
```
- 等价的SQL
```sql
update sys_user
set username='admin'
where id=101
```
- 使用lambda方式
```sql
LambdaUpdateWrapper<SysUser> wrapper = new UpdateWrapper<SysUser>()
        .lambda()
        .set(SysUser::getUsername, "admin")
        .eq(SysUser::getId, 101);

this.baseMapper.update(null,wrapper);
```
- 可以看到，主要的区别是
- wrapper使用.lambda()方法转换为了lambda模式
- 使用方法引用::getUsername方式替换了原来直接写列名的方式
- 其余的使用上不变
- 因此，对于简单的SQL，一般的写法是这样的
```java
this.baseMapper.update(null,
        new UpdateWrapper<SysUser>()
        .lambda()
        .set(SysUser::getUsername, "admin")
        .eq(SysUser::getId, 101));
```
- 到这里，基本应该就能理解wrapper是怎么回事
- 还有lambda是怎么回事了，下面的基本类似
- 就不那么详细的讲解
- 同时，对于wrapper的部分，也只提供lambda-wrapper的方式
- 因为，更推荐这种方式，这种方式避免了列名错写的问题
- 还有当重命名列的时候，能够即时发现语法问题

### delete 删除
- 根据ID删除
```java
this.baseMapper.removeById(101);
this.baseMapper.deleteById(101);
```
- 等价SQL
```sql
delete from sys_user
where id=101
```
- 使用wrapper构造器
```java
LambdaQueryWrapper<SysUser> wrapper = new QueryWrapper<SysUser>()
        .lambda()
        .eq(SysUser::getId, 101);

this.baseMapper.delete(wrapper);
```
- 这里也许你会存在一个疑惑
- 为什么这里不叫DeleteWrapper
- 因为没必要，删除实际上就是一个条件语句
- 条件语句在查询的时候，查询也包含了条件语句
- 因此这里通用包含了

## select 查询
- 根据ID查询
```java
SysUser user=this.baseMapper.getById(101);
```
- 等价SQL
```sql
select *
from sys_user 
where id=101
```
- 使用wrapper
```java
LambdaQueryWrapper<SysUser> wrapper = new QueryWrapper<SysUser>()
        .lambda()
        .select(SysUser::getId, SysUser::getUsername)
        .like(SysUser::getUsername, "admin")
        .in(SysUser::getRoleId, 1, 2, 3);

List<SysUser> list = this.baseMapper.selectList(wrapper);
```
- 等价SQL
```sql
select
id,username
from sys_user
where username like '%admin%'
and role_id in (1,2,3)
```
- 到这里，你的Mybatis-Plus就是是学会了
- 但是前面说到了一个，Mybatis的分页插件，至今还没用
- 怎么用呢？下面讲解

## 分页插件
- 这里说得分页插件，是指Mybatis-Plus自带的分页插件
- 而不是第三方的插件
- 使用方式
- 在Mapper接口中，添加Page参数即可，返回值改为IPage类型
- 下面是示例代码
- service-impl中
    - 注意，Mybatis-Plus的分页是从1开始算的
```java
int pageIndex=1;
int pageSize=100;
SysUserVo webVo=new SysUserVo();

Page<SysUserVo> page = new Page<>(pageIndex, pageSize);
IPage<SysUserVo> list =  this.baseMapper.pageList(page, webVo);
```
- mapper中
    - 只需要在mapper接口中，添加page参数即可，Mybatis-Plus的插件会自动检测
    - 对带有Page参数的调用，自动进行分页调用
```java
IPage<SysUserVo> pageList(Page<SysUserVo> page, @Param("post") SysUserVo post);
```
- 注意分页page所在的包，不要导入错误即可
```java
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
```