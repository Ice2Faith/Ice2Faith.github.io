# Mybatis for Oracle
---

# insert selectKey
- 在执行插入之前获取序列号作为ID
```xml
<selectKey keyProperty="id" order="BEFORE" resultType="java.lang.string">
    select SEQ_COM_ID.nextval from dual
</selectKey>
```
