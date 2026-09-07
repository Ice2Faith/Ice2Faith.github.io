# github.io 的使用

---

## 用途
- github.io 可以理解为自己的个人主页
- 可以用来托管web页面
- 换句话说，你可以把WEB项目丢上去
- 因此，也就可以作为web项目托管网站
- 一般情况下，常用于托管静态网站
- 如果你有自己的服务器
- 也可以结合自己的服务器
- 将web托管在github.io
- 而后端服务则在自己的服务器上

## 好处是什么？
- 对于个人开发者而言
- 建立自己的网站
- 域名和备案是非常让人头疼的
- 但是拥有自己的服务器是轻易的
- 因此，可以借助github.io得到一个免费的域名和网站入口
- 这点还是非常不错的
- 可以在此基础上，搭建一个自己的小网站
- 放放笔记啊，博客啊什么的都是可以的

## 坏处是什么？
- 国内环境经常访问不上github

## 前置条件
- 你得先有一个github账号
```shell script
https://github.com/
```

## 开始使用
- 其实使用非常简单
- 就是新建一个项目
- 项目名规则必须如下
```shell script
[github用户名].github.io
```
- 然后把这个项目克隆下来
```shell script
git clone https://xxx
```
- 把需要托管的内容push上去即可
- 当然，因为是网站托管
- 所以，默认是访问这个入口文件
```shell script
index.html
```
- 如果你只想要测试下是否正常
- 可以用如下的网页内容
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>home github.io</title>
</head>
<body>
    <h1>
        welcome to your home page on github.io
    </h1>
</body>
</html>
```
