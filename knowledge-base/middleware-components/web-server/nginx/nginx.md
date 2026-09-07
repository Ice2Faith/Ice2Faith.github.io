## 安装 nginx
- 安装依赖环境
```shell script
yum install gcc-c++
yum install -y pcre pcre-devel
yum install -y zlib zlib-devel
yum install -y openssl openssl-devel
```
- 下载nginx
```shell script
echo http://nginx.org/en/download.html
wget -c https://nginx.org/download/nginx-1.22.1.tar.gz
```
- 解包
```shell script
tar -zxvf nginx-1.22.1.tar.gz
```
- 检查依赖
    - 没有ERROR则可以进行下一步
```shell script
cd nginx-1.22.1
./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_sub_module --with-http_ssl_module
```
- 编译并安装
```shell script
make && make install
```
- 查看nginx路径
    - 其实上面配置的时候，已经指定路径了
    - /usr/local/nginx
```shell script
whereis nginx
```
- 进入nginx路径
```shell script
cd /usr/local/nginx
```
- 编写启动脚本
```shell script
vi start.sh
```
```shell script
./sbin/nginx -c ./conf/nginx.conf
```
- 编写停止脚本
```shell script
vi stop.sh
```
```shell script
./sbin/nginx -s stop
```
- 编写刷新配置脚本
```shell script
vi reload.sh
```
```shell script
./sbin/nginx -s reload
```
- 编写验证配置脚本
```shell script
vi verify.sh
```
```shell script
./sbin/nginx -t
```
- 给脚本添加执行权限
```shell script
chmod a+x *.sh
```
- 更改nginx配置
```shell script
vi ./conf/nginx.conf
```
```shell script
# set work user
user  root;
# set woker count as cpu core count * 2
worker_processes  4;

# open error log
error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

# open pid store
pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    # open log format
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
   
    # open access log
    access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    # modify timeout
    keepalive_timeout  300;

    # open gzip support
    gzip on;
    gzip_min_length 2k;
    gzip_comp_level 9;
    gzip_types text/html text/xml text/plain text/css text/javascript application/javascript application/x-javascript application/xml image/jpeg image/gif image/png image/svg+xml;
    gzip_vary on;
    gzip_disable "(MSIE [1-6]\.)|(gozilla)|(traviata)";
    
    # set 8080 as an static  web server
    server {
        listen 8080;
        server_name localhost;

        charset utf-8;

        location / {
           autoindex on;
           root /root/apps/demo/dist;
           index index.html index.htm =404;
           try_files   $request_uri $request_uri/ /index.html;
        }

    }

    # ---------------------------------------------------------
    # after this line could be delete
    
    # default 80 config
    server {
        listen       80;
        server_name  localhost;

        charset utf-8;

        access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }
		
		# proxy api
		#location /dev-api/ {
		#	proxy_pass http://127.0.0.1:8888/api/;
		#}

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}
      # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

    # ---------------------------------------------------------
    # before this line cloud be delete

}

```
- 启动nginx
    - 这里使用创建的启动脚本
```shell script
./start.sh
```

- 编辑配置相关问题
    - 不要使用tab键进行对齐，否则可能有问题
    - 编辑完配置之后，最好先验证配置没有问题verify.sh
    - 再重载配置使得配置生效reload.sh
	
## 反向代理
```shell script
http {
    ...
    server {
        listen       80;
        server_name  localhost;

        charset utf-8;

        # 本机转发，共享端口的一种形式
        # 将访问到本服务器的 :80/dev-api/ 的请求转发到本机的 :8888/api/
        # 例如： http://ip:80/dev-api/hello 转发到 http://ip:8888/api/hello
        location /dev-api/ {
        	proxy_pass http://127.0.0.1:8888/api/;
        }

        # 他机转发，避免机器直接暴露的一种形式
        # ip:80/svc/ 转发到内网的 102:8080/
        # 例如： http://ip/svc/login 转发到 http://192.168.1.102:8080/login
        location /svc/ {
            proxy_pass http://192.168.1.102:8080/;
            
            # 当转发到其他组主机时，一般需要携带如下的头，否则可能丢失客户端的HTTP信息
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Origin $scheme://$host;
            proxy_redirect off;
            
            # 其他的一些参数
            proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
            proxy_max_temp_file_size 0;
			client_max_body_size 300m;
			proxy_set_header Connection "";
            proxy_connect_timeout      60s;
            proxy_send_timeout         300s;
            proxy_read_timeout         300s;
            proxy_buffer_size          4k;
            proxy_buffers              4 32k;
            proxy_busy_buffers_size    64k;
            proxy_temp_file_write_size 64k;
        }
    }
}
```

## 负载均衡
```shell script
http {
    ...
    # 定义均衡的虚拟主机，名为：virtual-host
    # 这个名称，在下面转发配置的时候使用
    # 轮询方式
    upstream virtual-host {
        server 192.168.1.101:8080;
        server 192.168.1.102:8080;
        server 192.168.1.103:8080;
    }

    # 使用权重方式
    # 这种方式用于机器性能方面考虑
    upstream virtual-host {
        server 192.168.1.101:8080 weight = 6; # 60% 转发到这台
        server 192.168.1.102:8080 weight = 3; # 30%
        server 192.168.1.103:8080 weight = 1; # 10%
    }

    # 按照客户端IP进行hash方式
    # 这种方式用于固定客户端访问，客户端一直会在一台主机上服务
    # 可用于解决session问题
    upstream virtual-host {
        ip_hash;
        server 192.168.1.101:8080;
        server 192.168.1.102:8080;
        server 192.168.1.103:8080;
    }

    # 按低响应时间优先方式
    upstream virtual-host {
        fair;
        server 192.168.1.101:8080;
        server 192.168.1.102:8080;
        server 192.168.1.103:8080;
    }

    server {
        listen       80;
        server_name  localhost;

        charset utf-8;

        # 负载均衡到 virtual-host 的三台主机
        # 将访问到本服务器的 :80/dev-api/ 的请求转发到本机的 :8888/api/
        # 例如： http://ip:80/dev-api/hello 转发到 http://ip:8888/api/hello
        location /dev-api/ {
        	proxy_pass http://virtual-host/api/;
        }

    }
}
```

## 前端部署
```shell script
http {
    ...
    # 直接顶级URL部署
    server {
        listen 8080;
        server_name localhost;

        charset utf-8;

        # 漏洞，非法文件访问，修复：url必须以/结尾，防止访问到其他路径
        location / {
           # 漏洞，目录遍历，修复：关闭此选项
           autoindex off;
           # 漏洞，非法文件访问，修复：路径必须以/结尾，防止访问到其他路径
           root /home/apps/web/dist/;
           index index.html index.htm =404;
           # 漏洞，CRLF漏洞，使用 $request_uri 替换 $uri
		   # 但是如果在vue等单页应用中出现问题，可使用$uri 
		   # CRLF 漏洞原理是在 302 redirect 的location 字段才有效
		   # 在try_files中可忽略
           try_files   $uri $uri/ /index.html;
        }

    }
 
    # 二级URL路径部署
    server {
       listen 8081;
       server_name localhost;
  
       charset utf-8;
  
       location /app/ {
          autoindex off;
          # 其实alias和root一样
          alias /home/apps/app/dist/;
          index index.html index.htm =404;
          # 二级路径时，需要带上二级路径的尝试/app/
          try_files  $uri $uri/ /app/index.html;
       }
    }
}
```

## 常见配置
- 文件上传大小限制
```shell script
http{
  server {
    ...
    client_max_body_size 200m;
    client_body_buffer_size 1m;
    ...
  }
}
```
- 请求头长度限制
```shell script
http{
  server {
    ...
    client_header_buffer_size 2k;
    large_client_header_buffers 4 16k;
    ...
  }
}
```
- 跨域配置
```shell script
http{
  server{
    ...
    # *星号代表任意跨源请求都支持
    add_header Access-Control-Allow-Origin '*';  
    add_header Access-Control-Allow-Credentials "true";
    add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
    add_header Access-Control-Allow-Headers  'token,DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,XRequested-With';
    if ($request_method = 'OPTIONS') {
        return 200;
    }
    ...
  }
}
```
- 动态匹配的跨域控制
```shell script
# 设置变量 $cors_origin
set $cors_origin "";
# 请求地址匹配格式  用来控制http请求地址 设置跨域白名单
if ($http_origin ~ "http://(.*).baidu.com$") {
    set $cors_origin $http_origin;              
}

add_header Access-Control-Allow-Origin '$cors_origin';  
```

- 获取URL参数
```shell script
$arg_xxx

也就是$arg_加上你的变量名
比如要获取名为name的变量
注意，变量名不区分大小写

$arg_name

下面举例说明：

location /dispatcher {
   # 获取URL参数system到sub_path变量中
   set $sub_path $arg_system;
   # 根据变量动态的进行proxy_pass
   proxy_pass http://localhost:8080/gateway/$sub_path;
}
```

- 获取header参数
```shell script
$http_xxx

也就是$http_加上你的变量名
比如要获取user-agent的请求头
注意，变量名不区分大小写

$http_user_agent

下面举例说明：

location /dispatcher {
   # 获取header参数token到user_token变量中
   set $user_token $http_token;
   # 如果没有token，则直接响应403
   if ($user_token ~ "\s+")
   { return 403; }
   # 根据变量动态的进行proxy_pass
   proxy_pass http://localhost:8080/api;
}
```

- 替换响应体的字符串
- 例如在进行代理转发的时候，可能有的URL地址是固定写死的原本主机的IP地址
- 代理转发之后，这个URL就是不可用的
- 这种情况下，就可以考虑将URL地址替换为代理后的地址
- 这样就可以实现URL地址的转换了

```shell
sub_filter_once off;  # optional, only replace once, default is off
sub_filter_types *; # replace mime-types, * means all
sub_filter '192.168.x.101:80' '192.168.x.102:9018'; # some replace strings
sub_filter '192.168.x.101:80/' '192.168.x.102:9018/';
sub_filter '192.168.x.101/' '192.168.x.102/';
sub_filter '192.168.x.101' '192.168.x.102';
```

## 漏洞解析
- $uri 引发的CRLF漏洞
```shell script
解析：
$uri $document_uri 都会 decode-uri
也就会导致解析出/r/n
导致XSS注入的可能
/r/n === %0d%0a

$request_uri 则是原始的uri，不会进行decode-uri

复现：
http://localhost/index.html%0d%0aSet-Cookie:%20user=admin

后果：
这样，就成功的设置了cookie
Set-Cookie: user=admin

修复：
使用 $request_uri 替换 $uri $document_uri
```
- 目录跨越漏洞
```shell script
解析：
可能发生的位置，将使用 [loc] 进行标记
以下是可能发生的位置
localtion [loc]
alias [loc]
root [loc]
proxy_pass [loc]
这些位置，如果配置的不是/结尾，将可能导致目录跨越

复现：
配置如下：
location /app {
   alias /home/app/;
}
由于，location配置的是/app
则就可以导致目录跨域
http://localhost/app../
而如果，alias没有以/结尾，将导致相同前缀的路径的跨越
http://localhost/app-wechat/index.html

修复：
配置中，尽量全部以/结尾，避免目录跨越
location /app/ {
  alias /home/app/;
}
```
- 头部覆盖漏洞
```shell script
解析：
在server节点中配置的add_header会被在location节点中配置的add_header覆盖
从而导致，在server节点中配置的全局header失效，从而导致头部覆盖，丢失原本应有的头部

复现：
配置如下：
server {
  add_header Content-Security-Policy "default-src 'self'";
  add_header X-Frame-Options DENY;
  
  location = /app {
      add_header Content-Security-Policy nosniff;
      rewrite ^(.*)$ /xss.html break;
  }
}
这里，location中配置了add_header头部
导致server中配置的头部被覆盖，从而导致这个配置丢失，这个头部原本是用来做XSS防御的
需要注意的是，一旦子节点中配置了add_header，则所有父节点的add_header都失效
而不是相同的header才会被覆盖
```
- XSS漏洞防范配置
    - 配置到 location 节点即可
```shell script
 #只允许本网站的frame嵌套
 add_header X-Frame-Options 'SAMEORIGIN';
 #开启XSS过滤器
 add_header X-XSS-Protection '1; mode=block';
 #禁止嗅探文件类型
 add_header X-Content-Type-Options 'nosniff';

  # 判断 referer
 if ($http_referer !~ ^(https?://(www.)?example.com))
 { return 403; }

 # 判断url和请求参数
 set $block_xss 0;

 if ($query_string ~ "base64_(en|de)code(.*)")
 { set $block_xss 1; }

 if ($request_uri ~ "base64_(en|de)code(.*)")
 { set $block_xss 1; }
 
 if ($query_string ~ "(<|%3C)*.script.*(/?>|%3E)")
 { set $block_xss 1; }

 if ($request_uri ~ "(<|%3C)*.script.*(/?>|%3E)")
 { set $block_xss 1; }

 if ($query_string ~ "(<|%3C)*.iframe.*(/?>|%3E)")
 { set $block_xss 1; }

 if ($request_uri ~ "(<|%3C)*.iframe.*(/?>|%3E)")
 { set $block_xss 1; }

 if ($query_string ~ "GLOBALS(=|[|%[0-9A-Z]{0,2})")
 { set $block_xss 1; }

 if ($query_string ~ "_REQUEST(=|[|%[0-9A-Z]{0,2})")
 { set $block_xss 1; }

 if ($block_xss = 1)
 { return 403; }
```

