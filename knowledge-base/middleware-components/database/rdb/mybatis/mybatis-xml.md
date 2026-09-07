# Mybatis 语法集锦
---

# 查询
- where 语句
```xml
<where>
    <if test="userId!=null and userId!=''">
        and a.user_id=#{userId}
    </if>

    <if test="userName!=null and userName!=''">
        and a.user_name like concat(concat('%',#{userName}),'%')
    </if>

    <if test="status!=null and status!=''">
        and a.status in
        <foreach collection="status.split(',')" item="item" open="(" separator="," close=")">
            #{item}
        </foreach>
    </if>
</where>
```
- 查询列
```sql
a.status status,
case
    when a.status=1 then '启用'
    when a.status=2 then '禁用'
    else ''
end statusDesc,
```
- 选择插入
```xml
insert into tb_user
(
<trim prefixOverrides="," suffixOverrides=",">
    <if test="id!=null and id!=''">
        ,id
    </if>
    <if test="status!=null and status!=''">
        ,status
    </if>
    <if test="name!=null and name!=''">
        ,name
    </if>
    
    <if test="createUserId!=null and createUserId!=''">
        ,CREATE_USER_ID
    </if>
    <choose>
        <when test="createTime!=null and createTime!=''">
            ,CREATE_TIME
        </when>
        <otherwise>
            ,CREATE_TIME
        </otherwise>
    </choose>

    <!--
    <if test="modifyUserId!=null and modifyUserId!=''">
        ,MODIFY_USER_ID
    </if>
    <if test="modifyTime!=null and modifyTime!=''">
        ,MODIFY_TIME
    </if>
    -->
</trim>
)
values
(
<trim prefixOverrides="," suffixOverrides=",">
    <if test="id!=null and id!=''">
        ,#{id,jdbcType=NUMERIC}
    </if>
    <if test="status!=null and status!=''">
        ,#{status,jdbcType=NUMERIC}
    </if>
    <if test="name!=null and name!=''">
        ,#{name,jdbcType=VARCHAR}
    </if>
    
    <if test="createUserId!=null and createUserId!=''">
        ,#{createUserId}
    </if>
    <choose>
        <when test="createTime!=null and createTime!=''">
            ,to_date(#{createTime,jdbcType=VARCHAR},'yyyy-MM-dd hh24:mi:ss')
        </when>
        <otherwise>
            ,sysdate
        </otherwise>
    </choose>
    <!--
    <if test="modifyUserId!=null and modifyUserId!=''">
        ,MODIFY_USER_ID = #{modifyUserId}
    </if>
    <if test="modifyTime!=null and modifyTime!=''">
        ,MODIFY_TIME = to_date(#{modifyTime,jdbcType=VARCHAR},'yyyy-MM-dd hh24:mi:ss')
    </if>
    -->
</trim>
)
```
- 选择更新
```xml
update tb_user
set
<trim prefixOverrides="," suffixOverrides=",">
<!--            <if test="id!=null and id!=''">-->
<!--                ,#{id}-->
<!--            </if>-->
    <if test="status!=null and status!=''">
        ,status=#{status,jdbcType=NUMERIC}
    </if>
    <if test="name!=null and name!=''">
        ,name=#{name,jdbcType=VARCHAR}
    </if>
    
    <!--
    <if test="createUserId!=null and createUserId!=''">
        ,CREATE_USER_ID = #{createUserId}
    </if>
    <if test="createTime!=null and createTime!=''">
        ,CREATE_TIME =to_date(#{createTime,jdbcType=VARCHAR},'yyyy-MM-dd hh24:mi:ss')
    </if>
    -->
    <if test="modifyUserId!=null and modifyUserId!=''">
        ,MODIFY_USER_ID = #{modifyUserId}
    </if>
    <choose>
        <when test="modifyTime!=null and modifyTime!=''">
            ,MODIFY_TIME = to_date(#{modifyTime,jdbcType=VARCHAR},'yyyy-MM-dd hh24:mi:ss')
        </when>
        <otherwise>
            ,MODIFY_TIME = sysdate
        </otherwise>
    </choose>
</trim>
where id=#{id,jdbcType=NUMERIC}
```
- 构造最近几天的左表
```sql
<foreach collection='"0,1,2,3,4,5,6".split(",")' item="item" separator="union all">
    select  substr(date_sub(
    <choose>
        <when test="today!=null and today!=''">
            #{today}
        </when>
        <otherwise>
            now()
        </otherwise>
    </choose>
    ,interval ${item} day),1,10) v_mon
</foreach>
```
