# Mybatis 常用的XML语法

## 简介
- mybatis作为目前经典的SSM(spring-springMvc+mybatis)体系中的一员
- 是在java开发中及其常见的，尤其是javaweb开发
- 现今，springboot将SS拆分成为springboot-starter，spring-boot-starter-web
- mybatis也有了自己的starter，就是mybatis-spring-boot-starter

## springboot+mybatis
- web开发经典三个依赖，构建SSM环境
- 配置pom.xml依赖
- springboot-starter
    - 这个依赖，一般都已经有了
    - 也就是指定parent的时候包含了
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter</artifactId>
    <version>2.3.7.RELEASE</version>
</dependency>
```
- springboot-starter-web
    - 也就是springMVC的依赖
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```
- mybatis-starter
    - 也就是mybatis的依赖
```xml
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>2.1.0</version>
</dependency>
```
- 配置application.properties
- 配置xml文件扫描路径
    - 这里就配置了扫描resources/mapper下面的所有xml,类文件中的mapper和dao包下面的xml包下面的所有xml文件
    - 这个扫描，包含了大多数开发的mapper书写习惯场景，非常通用
    - 其次，在springboot环境中，已经具有slf4j环境，因此mybatis也是用slf4j作为日志输出即可
```properties
mybatis.mapper-locations=classpath*:/mapper/**/*.xml,classpath:**/mapper/xml/*Mapper.xml,classpath:**/dao/xml/*Mapper.xml
mybatis.configuration.log-impl=org.apache.ibatis.logging.slf4j.Slf4jImpl
```
- 配置数据源
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/test_db?useAffectedRows=true&useUnicode=true&characterEncoding=UTF-8&serverTimezone=Asia/Shanghai
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.username=root
spring.datasource.password=xxx
```
- 配置启动类
- 添加注解，扫描所有的mapper包和dao包下面的接口
```java
@MapperScan(basePackages = {
        "com.**.mapper"
        , "com.**.dao"
})
```
- 后续编写相应的mapper接口和mapper文件，启动项目即可

## mybatis的XML文件结构
- 和常规的XML文件一样
- 第一行，包含XML的版本声明，字符编码声明
```xml
<?xml version="1.0" encoding="UTF-8" ?>
```
- 第二行，包含了本XML支持的格式规范的约束协议DTD
```xml
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >
```
- 接着，就是整个XML的根元素或者根节点mapper
- 他需要一个namespace，指向我们的mapper接口的全限定类名
```xml
<mapper namespace="com.test.mapper.SysUserMapper">

</mapper>
```
- 这个例子中，知道是指向如下的接口
```java
package com.test.mapper;

public interface SysUserMapper{

}
```
- 因此，一个完整的XML基本框架如下
```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >
<mapper namespace="com.test.mapper.SysUserMapper">

</mapper>
```
- 由于XML是遵从XML文件格式规范的
- 因此一些符号是需要转义的
- 例如SQL中的大于小于符号
- 转义规则和XML的规则一致
```shell script
> ===> &gt;
< ===> &lt;

>= ===> &gt;=
<= ===> &lt;=
```
- 特别注意，转义之后的大于等于之间是没有空格的

## 节点的规范
- 向常规的XML规范一样
- 一个节点允许具有，属性和节点体
- Mybatis中，最常见的属性就是id
- 因此格式大概是这样的
```xml
<[节点名] id="节点ID">
    [节点体]
</[节点名]>
```

## 节点的ID
- 同一个namespace中，ID属性是具有唯一性的
- 因此，ID属性是不能够重复的
- 注意，这里说得是同一个namespace，而不是同一个mapper文件
- 因为，不同的mapper文件，允许namespace相同
- 但是这种做法一般不常见，也不推荐这种做法出现
- 因此，一般情况下，可以理解为，一个mapper文件，对应一个mapper接口，对一个namespace
- 也就是，一个mapper文件中，ID不能重复
- 同时，对于ID还有一个特别的点，那就是可能对应了接口中的方法名
- 也就是说，接口中的方法不能重载，否则ID将会发生重复

## 与JAVA的取值
- xml文件中，一般都是取用java传过来的bean的值
- 因此，就需要一种取值方式
- 在mybatis中，取值方式有两种，即${}方式和#{}方式
- 下面说一下区别
- 方式一：#{}
    - 这种方式时最常见的使用方式
    - 这种方式下，mybatis会自动的根据数据类型进行转换为SQL中合适的语句
    - 例如，字符类型自动加上字符引号等
    - 同时，最重要的是，能够防止SQL注入攻击
- 方式二：${}
    - 这种方式不太常用
    - 作用是单纯的直接拼接出SQL，不进行任何处理
    - 缺点很明显，不能够防止SQL注入攻击
    - 因此，他只能用于系统内部使用，而不能够作为接受外部数据的使用方式
    - 内部使用，比如程序员自身确认的字符串，不可能造成SQL注入攻击时
    - 比如，动态的字段名，动态的表名等，这些系统内部产生，内部消化的场景下可以使用
    - WEB前端传递过来的，或者其他外部系统传递过来的，或者不确定安全性来源的，都不能使用这种方式
- 讲了区别，下面说一下用法
```xml
#{bean.username}
#{bean.roles[0].id}
#{webVo.keyword}
```

## 最常见的基本节点
- 当然是增删改查（CRUD[Create,Read,Update,Delete]）
- 假设定义的接口如下
```java
package com.test.mapper.SysUserMapper;

import org.apache.ibatis.annotations.Param;

public interface SysUserMapper{
    int insertOne(@Param("bean")SysUser user);
}
```
- 对应的实体如下
```java
package com.test.model;

import java.util.Date;

public class SysUser{
    private Long id;
    private String username;
    private String password;
    private Long roleId;
    private Date createTime;
    private Date updateTime;
}
```
- 他们四种操作，对应的节点属性ID就对应了接口中的方法名
### 增加 insert
```xml
<insert id="insertOne">
    insert into sys_user
    (username,password,role_id,create_time)
    values
    (#{bean.username},#{bean.password},#{bean.roleId},now())
</insert>
```
- 以增加做一个详细的介绍，其他的类似，就不仔细介绍了
- 首先，是节点，节点名为insert，节点ID为insertOne
```xml
<insert id="insertOne">
   
</insert>
```
- 表示执行的是insert操作，对应的接口的方法名为insertOne
- insert，update,delete类型的节点的返回值，都为int或者long
- 因此对应的接口声明应该如下
```java
int insertOne();
```
- 对于节点体中，就是一条常规的插入SQL语句
```sql
insert into sys_user
(username,password,role_id,create_time)
values
(#{bean.username},#{bean.password},#{bean.roleId},now())
```
- 前面说了取值方式，因此上面可以看到，是从bean里面取值的
- 这个bean从哪里来？
- 从接口传递的参数来
- 因此接口中，必须有一个参数叫做bean
- 因此，可以推断这个接口应该是这样的
```java
int insertOne(SysUser bean);
```
- 但是，在java中，编译之后，参数名可能会丢失，最后实际运行的时候变成了arg0,arg1...
- 因此，需要一定的手段，防止代码和实际的变量名不符合
- 就需要注解来帮助
- 拥有注解时，优先根据注解名称作为变量名，没有注解时，运行时拿到什么名称就是什么名称
- 因此，就得到了一开始的接口定义
```java
int insertOne(@Param("bean")SysUser user);
```
- 那这里，参数名佳作user，注解名叫做bean
- 怎么理解呢？
- 刚说了，有注解按照注解来，因此就叫做bean
- 这也就和SQL中的使用一致了
- 但是有个特殊的，在mybatis中，如果接口参数只有一个，那么叫什么都无所谓
- 写不写注解也无所谓，SQL中也可以直接不要名称
- 因此，这种也是可以的
```sql
insert into sys_user
(username,password,role_id,create_time)
values
(#{username},#{password},#{roleId},now())
```

### 更新 update
- java接口
```java
int updateById(SysUser user);
```
- xml
```xml
<update id="updateById">
update sys_user
set username=#{username},
password=#{password},
role_id=${roleId},
update_time=now()
where id=#{id}
</update>
```
- 在看过上面的insert部分的讲解之后
- 相信这部分应该很好理解

### 删除 delete
- java接口
```java
int deleteById(Long id);
```
- xml
```xml
<delete id="deleteById">
delete from sys_user
where id=#{id}
</delete>
```

### 查询 select
- 查询比其他的更新类操作要复杂一些
- 节点的属性，需要指定返回的类型resultType
- 也就是，最终查询的结果，怎么保存成为java实体bean
- 下面给出最简单的一个示例
```java
SysUser queryById(Long id);
```
```xml
<select id="queryById" resultType="com.test.model.SysUser">
select 
id,
username,
password,
role_id roleId,
create_time as createTime,
update_time updateTime
from sys_user
where id=#{id}
</select>
```
- 需要注意的点
- 第一，resultType一定要指定，并且是指定类的全限定类名
- 第二，一般数据库中是下划线命名，java实体中是驼峰命名，因此需要手动的转命名
    - 也就是给列取别名的方式，例如上面的role_id，create_time就是如此
    - 看到这里，是不是感觉每次写转驼峰的别名，很闹心
    - 别急，resultType的情况下，需要每次都自己转驼峰别名
    - 但是，支持使用resultMap的方式，一次map编写，多次使用
    - 下面进行介绍
    
### 批量查询 select
- 其实，批量查询，xml部分是一样的，不用变化
- 而是接口需要发生变化
- 下面给一个例子，根据用户名模糊查询，加角色ID查询的例子
- java接口
```java
List<SysUser> queryList(@Param("username")String username,@Param("roleId")Long roleId);
```
- xml
```xml
<select id="queryList" resultType="com.test.model.SysUser">
select 
id,
username,
password,
role_id roleId,
create_time as createTime,
update_time updateTime
from sys_user
where username like concat('%',concat(#{username},'%'))
and role_id = #{roleId}
</select>
```
- 这个例子中，接口参数有多个，为了防止变量名丢失，都加了@Param注解
- 返回值是SysUser类型的一个List
- 但是xml中，resultType的值是SysUser,并不是List，这个是需要也别注意的
    
### 结果映射 resultMap
- 前面说了，数据库的下划线和java实体的驼峰之间，需要每次都进行别名转换
- 非常的让人闹心
- 现在使用resultMap的方式改善一下
- 先来编写resultMap
```xml
<resultMap id="baseResultMap" type="com.test.model.SysUser">
    <id column="id" property="id"/>
    <result column="username" property="username"/>
    <result column="password" property="password"/>
    <result column="role_id" property="roleId"/>
    <result column="create_time" property="createTime"/>
    <result column="updateTime" property="updateTime"/>
</resultMap>
```
- 现在，有个resultMap，那么可以改写select语句了
- 第一步，将resultType换为resultMap
- 第二步，将resultMap的属性值，指向刚才resultMap的ID
- 第二步，去除原来的自己别名的方式
```xml
<select id="queryById" resultMap="baseResultMap">
select 
*
from sys_user
where id=#{id}
</select>
```

## 动态SQL
- 动态SQL是最常用的，也是最实用的开发技能
- 因为，常见的开发中，一般一条SQL不是固定的几个参数
- 而是根据实际需要，使用不同的参数，构建出不同的SQL执行
- 例如，多个查询条件，前端有给值这个查询条件就生效，否则就不生效
- 这就是动态SQL
- 动态SQL几个主要的标签节点：
- if,choose
- foreach
- trim,where,set
- sql,include

### if 节点
- if节点，改节点具有一个test属性，当test属性的结果为真的时候，if节点中的节点体才会拼接到SQL中
- 下面是定义
```xml
<if test="[表达式]">
  [节点体]    
</if>
```
- 最常见的使用方式就是动态的判断值，不为空的时候添加这部分SQL
- 例如查询条件中
```xml
select *
from sys_user
where 1=1
<if test="username!=null and username!=''">
    and instr(username,#{username}) > 0
</if>
<if test="roleId!=null">
    and role_id=#{roleId}    
</if>
```
- 可以看到，分别判定了username不为null，并且不等于空串的时候
- 还判定了roleId不为null的时候
- 这里特别提醒，这种拼接中的and别忘了加
- 为了保证SQL正确性，where之后的1=1别忘了加
- 如果要判断字符串不等于某个非空串的值
- 应该使用双引号包裹字符串，使用单引号作为test包裹
- 否则将不会按照你预期的执行
- 如下
```xml
<if test='username!=null and username!="root"'>
    and instr(username,#{username}) > 0
</if>
```
- 可以看到，这种方式有个缺点
- 那就是where之后的1=1不能少
- 改进方式就是使用where标签

### where 节点
- 前面说了，where之后1=1这种方式非常的不好
- 那么where节点的作用就是
- 自动的将where之后多余的and和or去掉
- 当where体为空的时候，不添加where
- 因此上面的例子可以如下改下
```xml
select *
from sys_user
<where>
    <if test="username!=null and username!=''">
        and instr(username,#{username}) > 0
    </if>
    <if test="roleId!=null">
        and role_id=#{roleId}    
    </if>
</where>
```
- 这样，每个if之前，只需要都加上and或者or即可
- where之后也不需要使用1=1来保证SQL不发生错误
- 这里提前说一下，实际上where是trim节点的一个特例

### choose 节点
- if 几点虽然已经够用了
- 但是某些情况下，需要if-else这样的多分支判定的支持
- 因此choose节点就是这样的一个结构
- 实际上是一个switch分支的形式
- 结构
```xml
<choose>
    <when test="[条件1]">
        [条件1的条件体]
    </when>    
    <when test="[条件2]">
        [条件2的条件体]
    </when>   
    <otherwise>
        [其他情况的条件体]
    </otherwise>
</choose>
```
- 举例
- 假如，还有一个状态，有传值就按照值查询，没传值就按照默认查询
```xml
select *
from sys_user
<where>
    <if test="username!=null and username!=''">
        and instr(username,#{username}) > 0
    </if>
    <if test="roleId!=null">
        and role_id=#{roleId}    
    </if>
    <choose>
        <when test="status!=null">
            and status=#{status}
        </when>
        <otherwise>
            and status!=99
        </otherwise>
    </choose>        
</where>
```

### foreach 节点
- 在开发中，常常会遇到，根据一些列的某个值，构造SQL的情况
- 比如，用户多选了某些角色ID，你要进行一个in查询的情况
- 亦或者，要进行批量插入的情况
- 都需要使用foreach标签
- 语法
```xml
<foreach collection="[集合]" item="[迭代名称]" open="[开始符号]" separator="[分隔符号]" close="[结束符号]">
    [迭代体]
</foreach>
```
- 情景一，传递过来了一个角色ID的list，需要进行IN查询
```xml
<if test="roleIdList!=null and roleIdList.size>0">
    and role_id in    
    <foreach collection="roleIdList" item="item" open="(" separator="," close=")">
        #{item}
    </foreach>
</if>
```
- 在这个情景中，迭代集合就是roleIdList，迭代对象名称就是item，迭代开始和结束用(),每一个迭代对象用,分隔
- 最终形成这样的SQL
```sql
and role_id in (1,2,3)
```
- 情景二，传递过来的是一个字符串，是角色ID，用逗号分隔
- 第一种，提前JAVA里面分隔（不介绍）
- 第二种，直接使用表达式分隔
```xml
<if test="roleIdList!=null and roleIdList!=''">
    and role_id in    
    <foreach collection="roleIdList.split(',')" item="item" open="(" separator="," close=")">
        #{item}
    </foreach>
</if>
```
- 和上面的效果是一样的
- 下面是通用的批量插入，适用于任何数据库
- 实际上就是使用insert...select...union all select ... 方式
```xml
insert into sys_user(username,password,role_id)
<foreach collection="list" item="item" open=" select " separator=" union all select " >
    #{item.username},#{item.password},#{item.roleId} from dual
</foreach>
```

### set 节点
- set，这个词，在SQL中，也就是应用在update...set环境中的
- 实际上，set节点也是应用在update语句的set中
- 作用和where节点类似
- 自动添加set关键字，自动去除收尾多余的逗号
- 常见用法
```xml
update sys_user
<set>
  username=#{username},
  password=#{password},        
</set>
where id=#{id}
```
- 上面的例子中，故意多谢了一个逗号
- 这样是没有问题的
- set标签的作用之一就是去除多余的逗号
- 实际上，这也是trim标签的一种特例

### trim 节点
- 前面提到了where和set标签
- 都说是trim标签的特例
- 那么trim标签的作用是什么？
- trim标签可以提供添加指定前缀，指定后缀
- 去除指定前缀，指定后缀的作用
- 对于where的场景，添加指定前缀where，去除指定前缀and|or
- 对于set的场景，添加指定前缀set，去除指定后缀,
- 语法格式
```xml
<trim prefix="[添加指定前缀]" suffix="[添加指定后缀]" prefixOverrides="[去除指定前缀]" suffixOverrides="[去除指定后缀]">
  [标签体]    
</trim>
```
- 对应的where写法就为
```xml
<trim prefix="where" prefixOverrides="and|or">

</trim>
```
- 对应的set写法就为
```xml
<trim prefix="set" suffixOverrides=",">

</trim>
```
- 一般的应用场景中
- 多倾向于去除前缀后者后缀

### sql/include 标签
- sql标签是为了增加SQL复用性而添加的
- 例如一段SQL会被重复使用到时，重复的复制一段SQL
- 对于需要进行升级改造语句的时候，往往得修改多出SQL
- 容易造成遗漏
- 因此SQL标签用于包裹一段SQL
- 提供复用性
- SQL标签就类似于声明了一个函数
- 搭配include标签嵌入一个SQL标签的内容
- 达到SQL复用的目的
- 语法格式
```xml
<sql id="[sql的ID]">
   [节点体]    
</sql>
```
- include标签则是为了引入SQL标签
- 语法格式
```xml
<include refid="[sql标签的ID]" />
```
- 一般的使用场景
- 例如，同样的查询，查询出的结果列和表都是固定的
- 只是查询的条件不一样
- 那么查询的列部分就可以包装为一个SQL标签
- 例如：
```xml
<sql id="baseQueryBody">
    select *
    from sys_user
</sql>

<select id="selectById" resultType="com.test.model.SysUser">
  <include refid="baseQueryBody"></include>
  where id=#{id}
</select>

<select id="selectList" resultType="com.test.model.SysUser">
   <include refid="baseQueryBody"></include>
   <where>
       <if test="username!=null and username!=''">
            and instr(username,#{username}) > 0
        </if>
    </where>
</select>
```
- 在这个示例中
- sql 标签就作为selectById和selectList两个SQL共同的查询列部分
- 包含了查询出的列和查询使用到的表
- 这样，从xml层面来看，仅需要编写一份代码，就实现了根据ID查询和常规的列表查询两个功能

## 规范化xml
- 什么是规范化？
- 规范化的目的是什么？
- 规范化的目的是为了无脑开发
- 不用思考的按部就班的开发就是最好的开发
- 能够很好程度的避免个性化定制开发带来的麻烦
- 例如，很常见的遗漏和概念混淆
- 怎么规范？
- 规范其实就是一个抽象过程
- 将明确的过程抽象化，归一化的过程

### 规范化接口
- 一般基础操作定义
- 这里还是以SysUser为例
- 一般项目中，还会有例如Vo,Dto等DDD模式下的java实体类
- 他们一般都继承至SysUser,或者间接继承
- 例如：SysUserVo extends SysUser,SysUserDto extends SysUser
- 那么当我们想直接用SysUserVo进行更新插入操作的时候，mapper接口的类型却不匹配
- 这个时候，就应该面向抽象，开放化编程
- 使用实体交互，不限定具体的实体类型
- 而应该是一类实体类型，使用泛型：
```java
<T extends SysUser>
```
- 指定了，只要是SysUser的类型或者子类型都行
- 那么对于直接使用Vo或者Dto进行更新插入操作就很友好了
- 首先明确一点，Vo表示页面与后台交互的交互实体
- 那么对于查询而言，Vo包含的数据应该是比较全的
- 最常见的就是包含字典值的翻译值等
```java
<T extends SysUser> int insert(@Param("post")T user);

<T extends SysUser> int insertSelective(@Param("post")T user);

<T extends SysUser> int updateByKey(@Param("post")T user);

<T extends SysUser> int updateSelectiveByKey(@Param("post")T user);

int deleteByKey(Long id);

<T extends SysUser> int deleteSelective(@Param("post")T user);

SysUserVo queryByKey(Long id);

<T extends SysUser>List<SysUserVo> queryList(@Param("post")T user);

<T extends SysUser> int insertBatch(@Param("list")Collection<T> user);
```
- 上面的例子中
- 对于更新updateByKey和插入insert操作
- 都是用了T extends SysUser的方式，方便子类作为参数
- 对于实体类的入参，都是用post作为名称
- 对于批量插入insertBatch则使用list作为名称
- 同时，list不限定为具体的List，Set这些子类型
- 而是直接使用Collection接口类型
- 方便传递List，Set等明确的类型进行批量插入
- 上面的ByKey是明确的说明是根据主键进行的操作
- 一般来说，在MYSQL中，主键都叫做ID，都是bigint类型
- 其中Selective表示对应的字段有值，才进行字段的操作
- 一般来说，一个mapper接口，具有上面的这些接口定义
- 就已经能够满足绝大多数的需求了
- 下面，分别来说一下，这些接口对应的xml的实现

### 规范化XML实现

- 直接插入接口
    - 直接无论是否为空都插入
```java
<T extends SysUser> int insert(@Param("post")T user);
```
```xml
<insert id="insert">
    insert into sys_user
    (
    username,password,role_id,create_time
    )
    values
    (
    #{post.username},#{post.password},#{post.roleId},now()
    )
</insert>
```
- 选择性插入接口
    - 选择性插入，也就是只插入不为空的字段
```java
<T extends SysUser> int insertSelective(@Param("post")T user);
```
```xml
<insert id="insertSelective">
    insert into sys_user
    (
    <trim suffixOverrides=",">
        <if test="post.username!=null and post.username!=''">
            username,
        </if>
        <if test="post.password!=null and post.password!=''">
            password,
        </if>
        <if test="post.roleId!=null and post.roleId!=''">
            role_id,
        </if>
        create_time,
    </trim>
    )
    values
    (
    <trim suffixOverrides=",">
        <if test="post.username!=null and post.username!=''">
            #{post.username},
        </if>
        <if test="post.password!=null and post.password!=''">
            #{post.password},
        </if>
        <if test="post.roleId!=null and post.roleId!=''">
            #{post.roleId},
        </if>
        now(),
    </trim>
    )
</insert>
```
- 直接更新接口
    - 直接更新全部字段，无论是否为空
```java
<T extends SysUser> int updateByKey(@Param("post")T user);
```
```xml
<update id="updateByKey">
    update sys_user
    set username=#{post.username},
    password=#{post.password},
    role_id=#{post.roleId},
    update_time=now()
    where id=#{post.id}
</update>
```
- 选择性更新接口
    - 只更新不为null的字段
```java
<T extends SysUser> int updateSelectiveByKey(@Param("post")T user);
```
```xml
<update id="updateSelectiveByKey">
    update sys_user
    <set>
      id=#{post.id},
      <if test="post.username!=null and post.username!=''">
         username=#{post.username},
      </if>   
      <if test="post.password!=null and post.password!=''">
         password=#{post.password},
      </if>
      <if test="post.roleId!=null and post.roleId!=''">
         role_id=#{post.roleId},
      </if>
      update_time=now(),
    </set>
    where id=#{id}
</update>
```
- 根据主键删除接口
```java
int deleteByKey(Long id);
```
```xml
<delete id="deleteByKey">
    delete from sys_user
    where id=#{id}
</delete>
```
- 选择性删除
    - 根据不为空的字段相等删除
```java
<T extends SysUser> int deleteSelective(@Param("post")T user);
```
```xml
<delete id="deleteSelective">
    delete from sys_user
    <where>
      <if test="post.id!=null">
          and id={post.id},
       </if>
      <if test="post.username!=null and post.username!=''">
         and username=#{post.username},
      </if>   
      <if test="post.password!=null and post.password!=''">
         and password=#{post.password},
      </if>
      <if test="post.roleId!=null and post.roleId!=''">
         and role_id=#{post.roleId},
      </if>
    </where>
</delete>
```
- 根据ID查询
```java
SysUserVo queryByKey(Long id);
```
- 提炼公共部分
```xml
<sql id="sqlBaseQueryBody">
    select
    a.id,
    a.username,
    a.password,
    a.role_id roleId
    from sys_user a
    left join sys_role b on a.role_id=b.id   
</sql>
```
```xml
<select id="queryByKey" resultType="com.test.vo.SysUserVo">
    <include refid="sqlBaseQueryBody"></include>
    where id=#{post.id}
</select>
```
- 查询列表
```java
SysUserVo queryByKey(Long id);
```
```xml
<select id="queryList" resultType="com.test.vo.SysUserVo">
    <include refid="sqlBaseQueryBody"></include>
    <where>
      <if test="post.id!=null">
          and a.id={post.id},
       </if>
      <if test="post.username!=null and post.username!=''">
         and a.username=#{post.username},
      </if>   
      <if test="post.password!=null and post.password!=''">
         and a.password=#{post.password},
      </if>
      <if test="post.roleId!=null and post.roleId!=''">
         and a.role_id=#{post.roleId},
      </if>
    </where>
</select>
```
- 批量插入
```java
<T extends SysUser> int insertBatch(@Param("list")Collection<T> user);
```
```xml
<insert id="insertBatch">
    insert into sys_user
    (username,password,role_id,create_time)
    <foreach collection="list" item="item" open=" select " separator=" union all select ">
        #{item.username},#{item.password},#{item.roleId},now() from dual
    </foreach>
</insert>
```
- 至此，常见的Mybatis中操作数据库就已经结束了
- 从上面规范化的例子中来看
- 可以应用到任意的表中，进行单表的操作
- 总结一下：
- 入参命名统一，这里是post，也可以是webVo，bean,model,param等
- 方法名简单易懂，这里是insert，selective，byKey，query
- 宽泛的泛型继承接口定义，方便使用，这里是Collection代理List，T代替SysUser
- 避免了哪些问题？
- 避免了每个mapper的入参名称不同，导致如果需要修改不同mapper时，可能名称不一样，导致出错
- 避免了复杂的命名，导致记忆力不够不能直接想到接口名称
- 避免了明确的类型限定，知道某些场景下，不能直接调用接口

## 其他的Mybatis使用技巧

### like 语法的跨数据库
- 尽量使用夸数据库支持的语法
- 避免因为迁移数据库带来大量的修改操作
- 例如：concat函数，在mysql中支持多个参数，在oracle中只支持两个参数
- 例如：like中%分号的拼接，mysql中可以直接拼接，oracle中可以使用||拼接
```sql
-- mysql
username like '%' #{username} '%'
username like concat('%',#{username},'%')

-- oracle
username like '%'||#{username}||'%'

-- 统一化的写法
username like concat('%',concat(#{username},'%'))

-- 或者更加推荐采用instr方式
instr(username,#{username}) > 0
```

### insert 批量插入的夸数据库
- 批量插入的差异
- mysql中，直接使用values之后，接多个行即可
- oracle中，需要借助insert all 语法
- 统一为标准SQL的写法
```sql
insert into [表名]
select [列] from dual
unoin all 
select select [列] from dual
```

### 查询结果为 Map
- 直接查询成为一个Map，不要使用实体
- 这种一般适用于直接查询给页面，不需要再进行处理的的场景
- 也就是只读的场景
- java接口
```java
List<Map<String,Object>> queryReport(@Param("post")SysUserVo post);
```
- xml定义
    - 只需要把resultType指定为Map即可
```xml
<select id="queryReport" resultType="java.util.Map">
 ...
</select>
```

### 获取插入的主键
- 核心selectKey标签
- 其实就是一个类似AOP的作用
- 用在insert标签内
- 语法结构
```xml
<selectKey keyProperty="[值存放的实体类字段]" order="[在insert之前还是之后]" resultType="[值的数据类型]">
    [获取值的SQL]
</selectKey>
```
- order的取值为BEFORE和AFTER，也及时之前和之后
- 场景一，mysql中，插入自增主键，并获取自增主键的值到实体bean中
    - 注意点，插入之后，所以应该是AFTER
    - 完成的是将插入的ID回填到实体bean的对应字段中
- 下面的例子中是mysql的适用场景
```xml
<insert id="insert">
    insert sys_user(username,password)
    values
    (#{username},#{password})
    <selectKey keyProperty="id" order="AFTER" resultType="java.lang.Long">
        SELECT LAST_INSERT_ID()
    </selectKey>
</insert>
```
- 场景二，生成主键之后，再进行插入
    - 注意点，插入之前，所以应该是BEFORE
    - 完成的是，在插入之前，先获取主键，填入bean中，再执行插入语句
- 下面的场景中，是oracle的使用场景
    - 也就是序列作为自增主键的应用
```xml
<insert id="insert">
    <selectKey keyProperty="id" order="BEFORE" resultType="java.lang.string">
        select SEQ_SYS_USER_ID.nextval from dual
    </selectKey>
    insert sys_user(id,username,password)
    values
    (#{id},#{username},#{password})
</insert>
```
- 这里，需要注意的点
- 对于批量插入，如果使用内嵌子查询查询ID的方式
- 和上面的使用无关，纯粹的批量插入场景
- 可能会导致一些问题
- 例如，同一批插入的都是同一个ID
- 也就是说，实际执行的的查询ID的只执行了一次
- 这种情况，建议提前JAVA中查询好ID或者生成好ID