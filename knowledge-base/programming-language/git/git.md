# Git 使用

## 配置安装

- 常规配置
```shell
git config --global user.name "用户名"
git config --global user.email "邮箱"
```

- 配置允许长路径
```shell
git config --system core.longpaths true 
```

- 检出代码转换为CRLF(\r\n),提交为LF(\n)
```shell
git config --global core.autocrlf true
```

- 配置SSH-KEY
- 生成SSH-KEY
	- 一路默认回车下去即可
```shell
ssh-keygen -t rsa -b 4096 -C "邮箱"
```

- 获取生成的SSH公钥
```shell
cat ~/.ssh/id_rsa.pub
```

- 将这个公钥配置到 github/gitlab/gitee 等代码仓库中即可


## Git 仓库瘦身

- 下载 BFG
```shell
wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar
```

- 进入代码仓库
	- 也就是你的代码路径
	- 路径下面应该有一个 .git 的隐藏目录

- 运行 BFG 删除大文件
- 命令示例

```shell
# 直接删除已知的最大文件
java -jar bfg-1.14.0.jar --delete-files largest-file1.zip largest-file2.zip ... 

# 删除所有超过特定大小的文件（例如100MB）
java -jar bfg-1.14.0.jar --strip-blobs-bigger-than 100M

# 删除所有名为"archive.zip"的文件的历史记录
java -jar bfg-1.14.0.jar --delete-files archive.zip

# 仅保留最近N次提交中的文件，早期历史中的删除
java -jar bfg-1.14.0.jar --keep 10 --strip-blobs-bigger-than 50M

# 按照文件名进行通配符匹配的所有
java -jar bfg-1.14.0.jar --delete-files "i2f-*.jar" .
```

- 清理 Git

```shell
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

- 查看清理之后的大小

```shell
git count-objects -vH
```

- 强制推送分支以及所有tags

```shell
git push origin --force --all
git push origin --force --tags
```