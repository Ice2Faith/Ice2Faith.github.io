# nginx 实现代理任意网址的转发

## 实现原理
- 通过nginx开放一个动态的proxy_pass
- proxy_pass的目标通过URL参数指定
- 现在拟定如下的规范
```shell script
使用nginx开放如下路径
/cors

需要接受一个参数
href


则转发请求为
http://192.168.1.10:12345/cors?href=http%3A%2F%2F192.168.1.11%3A8080%2Ffavicon.ico&time=123

在这个示例中
nginx的路径为
http://192.168.1.10:12345/cors
需要转发的请求路径为
http://192.168.1.11:8080/favicon.ico

则这个URL在JS中可以这样拼接

let href=encodeURIComponent('http://192.168.1.11:8080/favicon.ico')
let url='http://192.168.1.10:12345/cors?href='+href+'&time=123'

则，得到的url即为代理之后的连接
```

## 问题解决
- 由于是URL参数，必定进行了url-escape转义了
- 但是nginx默认没有提供url-unescape的操作
- 就需要第三方的模块提供 set_unescape_uri 进行实现
- 因此就需要重新编译nginx添加 set-misc-nginx-module 模块

## nginx实现的安装
- 安装nginx前置依赖
```shell script
yum install gcc-c++
yum install -y pcre pcre-devel
yum install -y zlib zlib-devel
yum install -y openssl openssl-devel
```
- 创建安装路径
```shell script
mkdir -p /home/env/nginx
```
- 进入安装路径
```shell script
cd /home/env/nginx
```
- 上传文件
- 文件如下
```shell script
nginx-1.22.1.tar.gz
ngx_devel_kit-0.3.3.tar.gz 
set-misc-nginx-module-0.32.tar.gz 
```
- 也可以在线下载
```shell script
wget -c https://nginx.org/download/nginx-1.22.1.tar.gz
wget -c https://github.com/vision5/ngx_devel_kit/archive/refs/tags/v0.3.3.tar.gz -O ngx_devel_kit-0.3.3.tar.gz 
wget -c https://github.com/openresty/set-misc-nginx-module/archive/refs/tags/v0.32.tar.gz -O set-misc-nginx-module-0.32.tar.gz 
```
- 解压文件
```shell script
tar -xzvf nginx-1.22.1.tar.gz
tar -xzvf ngx_devel_kit-0.3.3.tar.gz 
tar -xzvf set-misc-nginx-module-0.32.tar.gz 
```
- 查看目录文件
```shell script
ls -al
```
- 列表如下
```shell script
nginx-1.22.1
nginx-1.22.1.tar.gz
nginx-rtmp-module-1.2.2
nginx-rtmp-module-1.2.2.tar.gz
ngx_devel_kit-0.3.3
ngx_devel_kit-0.3.3.tar.gz
set-misc-nginx-module-0.32
set-misc-nginx-module-0.32.tar.gz
```
- 进入nginx编译目录
```shell script
cd nginx-1.22.1
```
- 配置nginx编译信息
```shell script
./configure --prefix=/usr/local/nginx\
 --with-http_stub_status_module\
 --with-http_sub_module\
 --with-http_ssl_module\
 --add-module=../ngx_devel_kit-0.3.3\
 --add-module=../set-misc-nginx-module-0.32
```
- 注意， set-misc-nginx-module 依赖 ngx_devel_kit
- 因此 add_module 顺序必须在之前
- 编译
	- 如果已经有安装过nginx
	- 则只进行make编译即可
	- 如果没有安装过，则可以添加install编译并安装
- 只是编译
```shell script
make
```
- 编译并安装
```shell script
make && make install
```
- 如果已经安装过nginx的情况
- 则将 ./objs/nginx 复制替换原来的 nginx 可执行文件
- 复制替换已有nginx
	- 再此之前，注意先停止nginx进程才能替换成功
	- 输入y确认替换
```shell script
cp ./objs/nginx /usr/local/nginx/sbin/
```
- 进入nginx路径
```shell script
cd /usr/local/nginx
```

# nginx 配置一个任意网址的跨域转发
server {
	listen 12345;
	server_name localhost;

	charset utf-8;

	
	location /cors {
		set_unescape_uri $href $arg_href;
		proxy_pass $href;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto $scheme;
		proxy_redirect off;

 }

}



