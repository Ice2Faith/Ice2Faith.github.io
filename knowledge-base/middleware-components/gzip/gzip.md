# Gzip 压缩配置

--- 
## tomcat 篇
- 配置文件 {TOMCAT_HOME}/conf/server.xml
- 更改节点： Server/Service/Connector
- 添加如下配置
```xml
useSendfile="false"
compression="on"
compressionLevel="9"
compressionMinSize="2048"
noCompressionUserAgents="gozilla,traviata,MSIE 6.,MSIE 5.,MSIE 4.,MSIE 3."
compressableMimeType="text/html,text/xml,text/plain,text/css,text/javascript,application/javascript,application/x-javascript,application/xml,image/jpeg,image/gif,image/png,image/svg+xml"
```
- 重启tomcat即可生效
```shell script
./bin/shutdown.sh
./bin/startup.sh
```
- 配置示例
```xml
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443"

           useSendfile="false"
           compression="on"
           compressionLevel="9"
           compressionMinSize="2048"
           noCompressionUserAgents="gozilla,traviata,MSIE 6.,MSIE 5.,MSIE 4.,MSIE 3."
           compressableMimeType="text/html,text/xml,text/plain,text/css,text/javascript,application/javascript,application/x-javascript,application/xml,image/jpeg,image/gif,image/png,image/svg+xml"
/>
```
- 参数解释：
    - useSendfile 参数与gzip配置冲突，二选一
    - compression 开启gzip,默认false
    - compressionLevel 压缩级别，1-9
    - compressionMinSize 最小压缩起点，单位byte
    - noCompressionUserAgents 不进行压缩的浏览器代理，这里特别排除MSIE(IE6/5/4/3)
    - compressableMimeType 进行压缩的mimeType列表，这里默认配置上了HTML+CSS+JS文件，和常见的图片文件
  
  
---  
## nginx 篇
- 配置文件： {NGINX_HOME}/conf/nginx.conf
- 配置节点： server
- 添加如下配置：
```shell script
gzip on;
gzip_min_length 2k;
gzip_comp_level 9;
gzip_types text/html text/xml text/plain text/css text/javascript application/javascript application/x-javascript application/xml image/jpeg image/gif image/png image/svg+xml;
gzip_vary on;
gzip_disable "(MSIE [1-6]\.)|(gozilla)|(traviata)";
```
- 重载nginx即可生效
```shell script
./sbin/nginx -s reload
```
- 配置示例
```shell script
server {
    listen 80;
    # gzip config
    gzip on;
    gzip_min_length 1k;
    gzip_comp_level 9;
    gzip_types text/plain application/javascript application/x-javascript text/css application/xml text/javascript application/x-httpd-php image/jpeg image/gif image/png;
    gzip_vary on;
    gzip_disable "MSIE [1-6]\.";
 
    root /home/web/html;
 
    location / {
        # 用于配合 browserHistory使用
        try_files $uri $uri/ /index.html;
 
        # 如果有资源，建议使用 https + http2，配合按需加载可以获得更好的体验
        # rewrite ^/(.*)$ https://preview.pro.ant.design/$1 permanent;
 
    }
    location /api {
        proxy_pass https://preview.pro.ant.design;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_set_header   Host              $http_host;
        proxy_set_header   X-Real-IP         $remote_addr;
    }
}


```
- 参数解释
    - gzip 开启gzip
    - gzip_min_length 最小压缩起点
    - gzip_comp_level 压缩级别
    - gzip_types 压缩的mime类型
    - gzip_vary 添加gzip头
    - gzip_disable 禁用gzip的浏览器代理

---
## springboot 篇
- 直接在配置文件中配置即可
```yaml
server:
  compression:
    enabled: true
    mime-types:
      - text/xml
      - application/json
      - text/plain 
      - application/javascript 
      - application/x-javascript 
      - text/css 
      - application/xml 
      - text/javascript 
      - application/x-httpd-php 
      - image/jpeg 
      - image/gif 
      - image/png
    excluded-user-agents:
      - gozilla
      - traviata
      - MSIE 6.
      - MSIE 5.
      - MSIE 4.
      - MSIE 3.
    min-response-size: 1KB
```