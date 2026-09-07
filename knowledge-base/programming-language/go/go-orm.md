# Golang 的数据库 ORM 操作
- 在go中，数据库的操作，都在database/sql包中定义
- 这个包是go定义的标准数据库操作包
- 具体实现由个个具体的数据库驱动实现
- 例如mysql的驱动
- 在此层面上，go目前比较主流的几个ORM框架中
- GORM由于其基于结构和TAG的方式
- 以及具有一些MybatisPlus的影子
- 因而，在国内比较收到欢迎

## GORM
- 官网
```shell script
https://gorm.io/zh_CN/docs/index.html
```
### 简单使用
- 直接上代码
```go
package main

import (
	"fmt"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)

/*

create table sys_user
(
 id bigint auto_increment primary key comment 'ID',
 username varchar(300) not null comment '用户名',
 age tinyint comment '年龄',
 high decimal(5,2) comment '升高'
) comment '用户表';

*/

type SysUser struct {
	Id       int     `gorm:"column:id;primaryKey"`
	Username string  `gorm:"column:username"`
	Age      int     `gorm:"column:age"`
	High     float32 `gorm:"column:high"`
}

func (su *SysUser) TableName() string {
	return "sys_user"
}

func main() {
	// 参考 https://github.com/go-sql-driver/mysql#dsn-data-source-name 获取详情
	// dsn := "user:pass@tcp(127.0.0.1:3306)/dbname?charset=utf8mb4&parseTime=True&loc=Local"
	dsn := "root:123456@tcp(127.0.0.1:3306)/test_db?charset=utf8mb4&parseTime=True&loc=Local"
	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
	if err != nil {
		panic(err)
	}

	// 根据条件查询
	eu := SysUser{}
	db.Where("username = ?", "root").Find(&eu)
	fmt.Println("是否存在root:", eu)

	if eu.Id > 0 {
		// 删除
		db.Where("id = ?", eu.Id).Delete(&SysUser{})
		fmt.Println("删除已存在的root:", eu)
		eu.Id = 0
	}

	if eu.Id == 0 {
		// 插入
		su := SysUser{
			Username: "root",
			Age:      22,
			High:     1.73,
		}
		db.Save(&su)
		fmt.Println("不存在root，插入：", su)
	}

	// 查询所有
	list := []SysUser{}
	db.Find(&list)

	fmt.Println("查询所有：")
	fmt.Println(list)

	// 更新
	// 单列更新
	db.Model(&SysUser{}).Where("username = ?", "root").Update("age", 23)
	// 多列更新
	db.Model(&SysUser{}).Where("username = ?", "root").Updates(map[string]interface{}{
		"age":  23,
		"high": 1.75,
	})

	// 查询所有
	list = []SysUser{}
	db.Find(&list)

	fmt.Println("查询所有：")
	fmt.Println(list)
}

```
### 代码解析
- 首先，导入gorm包和mysql的驱动包
```go
import (
	"fmt"

	"gorm.io/driver/mysql"
	"gorm.io/gorm"
)
```
- 可能需要下载依赖
```shell script
go get gorm.io/gorm
go get gorm.io/driver/mysql
```
- 由于gorm基于结构进行的表映射
- 我们在数据库建立一张表
```sql
create table sys_user
(
 id bigint auto_increment primary key comment 'ID',
 username varchar(300) not null comment '用户名',
 age tinyint comment '年龄',
 high decimal(5,2) comment '升高'
) comment '用户表';

```
- 因此，建立结构
```go
type SysUser struct {
	Id       int     `gorm:"column:id;primaryKey"`
	Username string  `gorm:"column:username"`
	Age      int     `gorm:"column:age"`
	High     float32 `gorm:"column:high"`
}

func (su *SysUser) TableName() string {
	return "sys_user"
}
```
- 定义了和数据库对应的结构
- 上面的结构TAG中使用gorm指定了列的一些属性
- 例如，使用column指定了数据库的列名
- 使用primaryKey指定了是数据库的主键
- 使用结构方法TableName来指定数据库中对应的表名
- 在默认情况下，表名=结构名变为下划线形式+s
- 也就是默认情况下，SysUser对应的表为sys_users
- 同时，属性也变为对应的下划线形式
- 例如，UserName对应表的列user_name
- 其他常用的标签
    - autoIncrement 指定列自增长
    - -:migration 指定忽略该属性
- 其他更多的标签，参见官网
```shell script
https://gorm.io/zh_CN/docs/models.html
```
- 获取gorm的操作实体db
```go
// 参考 https://github.com/go-sql-driver/mysql#dsn-data-source-name 获取详情
// dsn := "user:pass@tcp(127.0.0.1:3306)/dbname?charset=utf8mb4&parseTime=True&loc=Local"
dsn := "root:123456@tcp(127.0.0.1:3306)/test_db?charset=utf8mb4&parseTime=True&loc=Local"
db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{})
if err != nil {
    panic(err)
}
```
- 之后，所有的数据库操作
- 都是基于db来进行的
- 所有的操作，都需要提供结构的指针
- 这是为了gorm通过反射得到真实的数据库表名
- 也就是查找TableName方法或者按照结构名转换得到表名
- 因此，如果使用db的过程中，没有涉及到结构指针
- 则极大可能情况下，写法是错误的
- 增加记录
```go
// 插入
su := SysUser{
    Username: "root",
    Age:      22,
    High:     1.73,
}
db.Save(&su)
```
- 使用save方法进行保存记录
- 当save方法操作的结构的主键列不为默认值时
- 则save方法执行更新操作
- 删除记录
```go
// 删除
db.Where("username = ?", "root").Delete(&SysUser{})
fmt.Println("删除已存在的root:", eu)
```
- 通过使用where子句，自定删除的条件之后
- 调用delete方法实现删除
- 前面说了，使用db时，都要指定结构指针
- 因此delete方法需要传入结构的指针
- 更新记录
```go
// 更新
// 单列更新
db.Model(&SysUser{}).Where("username = ?", "root").Update("age", 23)
// 多列更新
db.Model(&SysUser{}).Where("username = ?", "root").Updates(map[string]interface{}{
    "age":  23,
    "high": 1.75,
})
```
- 前面说过，save方法当主键属性不为默认值时，执行的是更新操作
- 这里就不赘述了
- 更新，通过update方法更新单列
- 通过updates方法更新多列，接受map或者struct
- 同时，更新需要指定条件，使用where方法指定
- 同时，更新需要指定列名，使用model方法传入结构指针指定
- 查询记录
```go
// 根据条件查询
eu := SysUser{}
db.Where("username = ?", "root").Find(&eu)
fmt.Println("是否存在root:", eu)

// 查询所有
list = []SysUser{}
db.Find(&list)

fmt.Println("查询所有：")
fmt.Println(list)
```
- 查询使用的是find方法
- 可以加where方法指定查询的条件
- 当传入是单个结构时，返回单条数据
- 当传入是切片时，返回多条数据

### 使用总结
- 定义和数据库表对应的结构
- 并且按需指定结构的TAG和结构方法TableName
- 实例化连接对象db
- 使用db的相应方法实现对应的操作
- 常用的db方法
    - model 指定结构，用来获取表名
    - where 指定条件
    - update/updates 指定更新的列
    - delete 执行删除
    - save 执行增加或者更新操作
- 更多其他使用，相见官网