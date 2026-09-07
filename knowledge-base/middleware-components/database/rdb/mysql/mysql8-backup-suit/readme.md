# 关键表备份
---
- linux 环境 
    - 借助MySQL提供的 mysqldump+crontable 进行定期的关键表备份
- windows 环境
    - 借助MySQL提供的mysqldump+任务计划程序 进行定期的关键表备份

---
## 脚本路径
- 案例
    - 放在Windows下进行dump
        - 路径为： G:\mysql8-backup-suit
        - dump的数据路径： G:\db_backup
    - 放在linux下进行dump
        - 路径为：/home/mysql8-backup-suit
        - dump的数据路径：/home/db_backup

---
## 使用方式
- 解压本压缩包
- 你将会得到如下文件树
```shell script
mysql8-backup-suit
│  backups.bat # windows 备份脚本
│  backups.sh # linux 备份脚本
│  recoverys.bat # windows 恢复脚本
│  recoverys.sh # linux 恢复脚本
|  recoverys-all.bat # windows 按照目录批量恢复脚本
|  recoverys-all.sh # linux 按照目录批量恢复脚本
│  readme.md # 使用说明
│  schedule_config.bat # windows 定时备份配置引导
│  schedule_config.sh # linux 定时备份配置引导
│
└─mysql8 # mysql8 的备份与恢复支持
    ├─bin # 简化的脚本，配置信息从 conf 文件夹中读取
    │      bak.bat # windows 备份脚本
    │      bak.sh # linux 备份脚本
    │      rec.bat # windows 恢复脚本
    │      rec.sh # linux 恢复脚本
    │
    ├─conf # 配置信息，也就是mysql的连接信息，每个文件仅保存一行信息
    │      database.conf # 数据库名
    │      host.conf # 主机名
    │      password.conf # 密码
    │      user.conf # 用户名
    │
    ├─lib # 二进制依赖，就是mysql脚本依赖的核心，这些在mysql的安装路径下都有，需要版本替换时，替换以下文件即可
    │  ├─linux # linux的二进制依赖
    │  │      mysql # 进行恢复使用
    │  │      mysqldump # 进行备份使用
    │  │
    │  └─windows # windows的二进制依赖
    │          libeay32.dll # 依赖dll
    │          mysql.exe # 进行恢复使用
    │          mysqldump.exe # 进行备份使用
    │          ssleay32.dll # 依赖dll
    │
    └─sbin # 原始的脚本，需要提供完整的连接参数，不从配置读取
            backup.bat # windows备份脚本
            backup.sh # linux备份脚本
            recovery.bat # windows恢复脚本
            recovery.sh # linux恢复脚本
```
- 常用的脚本
    - 一般情况下，我们需要进行备份和恢复时，对应的数据库连接一般是不会变的
    - 因此，直接使用bin下面的脚本即可
    - 如果需要随时变化数据库连接信息，则推荐使用sbin下面的脚本
    - 此处仅介绍大多数的场景，也就是bin下面脚本的使用
    - 因此需要在conf目录中，修改四个配置文件，完成连接信息的配置
- 配置连接
    - 在conf目录中，存放着四个文件，这四个文件均只存放一行数据
    - 这一行数据就是文件名表示的连接的部分
    - 请注意，只能有一行数据
    - 并且不要有多余的符号
    - 否则脚本运行可能不正确
- 备份
```shell script
./bin/bak.sh [表名] [输出路径]
```
```shell script
./bin/bak.sh sys_user /home/db_backup
```
- 恢复
```shell script
./bin/rec.sh [脚本路径]
```
```shell script
./bin/rec.sh /home/db_backup/sys_user.sql
```
- 这种情况适用于单个表进行操作
- 如果需要进行一组表的操作
- 建议使用批量执行模板

## 批量执行模板
- 一般来说，都不是单表备份
- 因此，提供一个批量备份的模板
- 根据模板编写自己的备份脚本即可
```shell script
backups.bat
backups.sh
```

## 注意事项
- 命令中的转义字符
    - windows环境
        - 符号%是需要转义的，使用%%表示
        - 其他符号转义，通过^前缀符引导，例如：<符号对应为^<
    - linux环境
        - linux环境转义比较统一
        - 都是使用\作为前缀符引导，例如：<符号对应为\<
- 常出现的场景包含
    - 命令中的密码或者文件名部分
    - 如果密码包含特定平台的特殊命令字符
    - 需要在配置文件中，使用转义之后的表达方式
    - 或者运行之后查看[script exec]标记的实际执行命令
    - 检查是否是由于特殊字符没有转义导致失败
    - 举例说明：
        - 假如数据库密码为：admin%123
        - 在windows下，配置的密码应为：admin%%123
        - 在linux下，配置的密码应为：admin%123

---
## mysqldump 使用简介
### 备份数据库
```shell script
mysqldump [-u 用户名] [-p 密码] 数据库名 [... 表名] > 文件名
```
- 其中[]包含的参数为可选参数
- 使用示例
```shell script
mysqldump -u root -p 123456 test_db sys_user sys_role > user_role.sql
```
- 需要注意的点
- mysqldump 使用的时候，可能会导致锁表
- 因此常常结合其他几个参数一起使用
- 导出数据结构：-d
```shell script
-d 仅导出结构，如果只有数据库，则导出数据库的结构，如果指定了表，则导出表结构
```
```shell script
mysqldump [-u 用户名] [-p 密码] -d 数据库名 [... 表名] > 文件名
```
- 备份数据启用事务，不锁表 --single-transaction
```shell script
--single-transaction 使用事务，不锁表，前提是表的引擎支持事务，这样能尽可能的避免备份时锁表，导致应用卡死
```
```shell script
mysqldump [-u 用户名] [-p 密码] --single-transaction 数据库名 [... 表名] > 文件名
```
- 取数据的时候，只取一行，不一次性直接到内存中 --quick
```shell script
--quick 一次只取一行数据，不一次性直接到内存中
```
```shell script
mysqldump [-u 用户名] [-p 密码] --quick 数据库名 [... 表名] > 文件名
```
- 忽略表空间统计
```shell script
--no-tablespaces
```
- 多行显示insert语句，方便修改
```shell script
--skip-extended-insert
```
- 一般情况下推荐的命令
```shell script
mysqldump [-u 用户名] [-p 密码] --single-transaction --quick 数据库名 [... 表名] > 文件名
```

---
### 恢复数据库
```shell script
mysql [-u 用户名] [-p 密码] 数据库名 < 文件名
```
- 从使用上来说，恢复与备份的命令基本一致，区别在于定向符方向
```shell script
mysql -uroot -p123456 test_db < ./sys_user.sql
```
- 另外一种方式，是使用mysql直接运行SQL脚本的方式
```shell script
# 进入MySQL终端
mysql -u root -p 
# 输入密码
# 切换数据库
use test_db
# 执行SQL脚本
source /home/sys_user.sql
```
