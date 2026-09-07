# Mybatis for MySQL
---

# insert selectKey
- 在插入后获取插入的自增ID
```xml
<selectKey keyProperty="id" order="AFTER" resultType="java.lang.string">
    select LAST_INSERT_ID()
</selectKey>
```
