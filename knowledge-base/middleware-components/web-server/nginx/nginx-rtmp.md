# nginx 配置 rtmp 服务器

## 前提介绍
- 已经安装nginx
- 如果没有安装，提前安装
- 建议安装版本为1.20+及以上版本的nginx
- 下载nginx
    - 选择一个版本下载
```shell script
http://nginx.org/en/download.html
```
- 下载nginx的rtmp模块
    - 选择一个tag下载
```shell script
https://github.com/arut/nginx-rtmp-module/tags

wget -c https://codeload.github.com/arut/nginx-rtmp-module/tar.gz/refs/tags/v1.2.2
mv v1.2.2 nginx-rtmp-module-1.2.2.tar.gz
```

## 配置
- 进入路径
```shell script
cd /root/env
```
- 文件路径
```shell script
ls
```
```shell script
nginx-1.22.1.tar.gz
nginx-rtmp-module-1.2.2.tar.gz
```
- 解压nginx和rtmp模块
```shell script
tar -xzvf nginx-1.22.1.tar.gz
tar -xzvf nginx-rtmp-module-1.2.2.tar.gz
```
- 文件路径
```shell script
ls
```
```shell script
nginx-1.22.1
nginx-1.22.1.tar.gz
nginx-rtmp-module-1.2.2
nginx-rtmp-module-1.2.2.tar.gz
```
- 注意上面的相对路径，nginx源码包和rtmp源码包同级
- 进入nginx源码包
```shell script
cd nginx-1.22.1
```
- 配置nginx,带上rtmp模块
```shell script
./configure --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_sub_module --with-http_ssl_module --add-module=../nginx-rtmp-module-1.2.2
```
- 编译nginx
- 注意，因为nginx已经编译安装过了
- 因此，只要重新编译nginx即可，不要安装
- 因此，只有make,没有install
```shell script
make
```
- 如果没有安装过nginx
- 则使用如下命令，编译并安装
```shell script
make & make install
```
- 查看已安装的nginx的位置
```shell script
whereis nginx
```
```shell script
/usr/local/nginx
```
- 进入nginx路径
```shell script
cd /usr/local/nginx/sbin/
```
- 如果nginx是启动状态的，先关闭nginx进程
- 备份nginx可执行文件
```shell script
cp nginx nginx.bak
```
- 返回编译目录
```shell script
cd /root/env/nginx-1.22.1
```
- 进入编译结果目录
```shell script
cd objs
```
- 复制新的可执行文件进行覆盖
- 需要输入y确认覆盖
```shell script
cp ./nginx /usr/local/nginx/sbin/
```
- 进入nginx路径
```shell script
cd /usr/local/nginx
```
- 进入配置路径
```shell script
cd conf/
```
- 备份原来的nginx配置
```shell script
cp nginx.conf nginx.conf.bak
```

## 配置rtmp配置
- 编辑nginx配置
```shell script
vi nginx.conf
```
- 添加如下配置
- 注意，默认情况下，一般都已经有http节点了
- 因此，http节点中的内容，对应添加到http节点下即可
- 默认是没有rtmp节点的，直接在配置最后添加整个节点即可
- 其中几个注意点
```shell script
# 这是rtmp解压的路径
/root/env/nginx-rtmp-module-1.2.2/

# 这是hls的存放地址
/root/rtmp/live/hls

# 这是点播路径
/root/rtmp/vod/flvs/
```
- 下面是完整配置
    - 由于，本人测试时，端口已被占用，使用了其他端口
    - 默认的11935对应为1935
    - 也就是在端口前加1了
```shell script
http {
     server {
        listen 11934;
        # 配置RTMP状态一览HTTP页面=========================================
        location /stat {
            rtmp_stat all;
            rtmp_stat_stylesheet stat.xsl;
        }
        location /stat.xsl {
            root /root/env/nginx-rtmp-module-1.2.2/;
        }
        # 配置RTMP状态一览界面结束==========================
        
        # HTTP协议访问直播流文件配置
        location /hls {  # 添加视频流存放地址。
                types {
                    application/vnd.apple.mpegurl m3u8;
                    video/mp2t ts;
                }
                # 访问权限开启，否则访问这个地址会报403
                autoindex on;
                alias /root/rtmp/live/hls; # 视频流存放地址，与下面的hls_path相对应，这里root和alias的>区别可自行百度
                expires -1;
                add_header Cache-Control no-cache;
                # 防止跨域问题
                add_header 'Access-Control-Allow-Origin' '*';
                add_header 'Access-Control-Allow-Credentials' 'true';
                add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
                add_header 'Access-Control-Allow-Headers' 'DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
            }
    }
}

# 点播/直播功能实现配置rtmp协议
rtmp {
    server {
        listen 11935;
        chunk_size 4000;
        application vod {
            play /root/rtmp/vod/flvs/; # 点播媒体存放目录
        }
        application live {
            live on;
        }
        # HLS直播配置
        application hls {
            live on;
            hls on;
            hls_path /root/rtmp/live/hls; # 视频流存放地址
            hls_fragment 5s;
            hls_playlist_length 15s;
            hls_continuous on; # 连续模式。
            hls_cleanup on;    # 对多余的切片进行删除。
            hls_nested on;     # 嵌套模式。
        }
    }
}
```
- 创建对应的目录
```shell script
mkdir -p /root/rtmp/live/hls
mkdir -p /root/rtmp/vod/flvs
```
- 添加完全访问权限
```shell script
chmod -R a+rwx /root/rtmp/
```
- 启动nginx
- 这里直接启动的原因是，前面已经说了，需要停止nginx

## 使用rtmp
- 浏览器查看服务器状态
    - 看到页面有内容即可
```shell script
http://[IP]:11934/stat
```
### 点播测试
- 前面有建立一个文件目录
```shell script
/root/rtmp/vod/flvs
```
- 准备一个flv文件
    - 可以下载一个flv文件
    - 或者使用ffmpeg转换一个现有的mp4文件
    - 后面给出ffmpeg的下载和使用
- 上传到这个目录
```shell script
/root/rtmp/vod/flvs/test.flv
```
- 准备一个支持流播放的播放器
    - 可以使用VLC player
    - 使用方式为：菜单-媒体-打开网络串流-输入如下的访问地址
```shell script
rtmp://[IP]:11935/vod/test.flv
```
- 这里说一下，为什么是这个地址
    - 协议rtmp,IP,端口是上面我们添加的11935
    - 应用是vod,指向了我们配置中的那个路径
    - 我们在路径下面放了一个test.flv
    - 因此就是这个完整的路径
- 还可以使用ffplay播放
```shell script
ffplay "rtmp://[IP]:11935/vod/test.flv"
```
### 直播测试
- 前面有建立一个文件目录
```shell script
/root/rtmp/live/hls
```
- 准备一个m3u8视频包
    - 或者使用ffmpeg转换一个现有的mp4文件
    - 后面给出ffmpeg的下载和使用
- 上传到这个目录
```shell script
/root/rtmp/live/hls/test.zip
```
- 解压这个视频包
```shell script
unzip test.zip -d test
```
- 得到例如如下的关系
```shell script
[root@i2fServer hls]# tree
.
├── test
│   ├── index0.ts
│   ├── index1.ts
│   ├── index2.ts
│   ├── index3.ts
│   └── index.m3u8
└── test.zip
```
- 和上面点播一样
- 使用VLC或者ffplay播放即可
```shell script
http://[IP]:11934/hls/test/index.m3u8
```
- [注意]在上面的配置中，我们配置了对多余的ts进行删除
- 也就是说，这个m3u8如果播放完毕了，那就删除了，不能再次播放了
- 这也是符合直播的特点的
- 但是，如果现在是测试，需要能够反复播放
- 将如下配置改为off即可
```shell script
hls_cleanup off;
```

## 推流实现直播

### 直接使用rtmp协议进行推流和拉流
- 这种方式优点是延迟较低
- 缺点是需要flash的支持
- 也就是说只能在web端开启flash支持才行
- 或者是使用支持rtmp协议的视频播放客户端
    - 例如：PotPlayer,VlcPlayer,ffplay
- 这里介绍一个示例
- 推流本地的一个文件作为直播流进行直播
- 使用ffmpeg进行推流
- 开启推流
    - 将test.mp4文件推流到hello这个直播频道
    - 这里以flv方式进行推流转码
    - 注意，根据nginx的配置
    - rtmp协议访问的是/live这个应用
    - 因此，推流和拉流都是/live这个应用
    - 后面是通道名称hello
```shell script
ffmpeg.exe -re -i test.mp4 -f flv rtmp://[IP]:11935/live/hello
```
- 拉流播放，VLC和ffplay一样
```
rtmp://[IP]:11935/live/hello
```

### 使用hls协议进行推流和拉流
- 这种方式的优点是支持浏览器直接访问
- 浏览器使用hls.js,video.js,flv.js等即可直接播放
- 不依赖flash
- 缺点是，延迟高
- 这里介绍一个示例
- 推流本地的一个文件作为直播流进行直播
- 使用ffmpeg进行推流
- 开启推流
    - 将test.mp4文件推流到hello这个直播频道
    - 这里以flv方式进行推流转码
    - 注意，根据nginx的配置
    - hl协议访问的是/hls这个应用
    - 因此，推流和拉流都是/hls这个应用
    - 后面是通道名称hello
```shell script
ffmpeg.exe -re -i test.mp4 -f flv rtmp://[IP]:11935/hls/hello
```
- 拉流播放，VLC和ffplay一样
    - 注意区别
    - 使用的是http协议
    - 访问的端口是11934的web端口
    - 走的是/hls这个应用
    - 访问的是/hello通道
    - 入口文件是index.m3u8
```
http://[IP]:11934/hls/hello/index.m3u8
```

## 直接使用工具进行直播
- 推流工具
    - 选用：OBS Studio
    - 下载地址：https://obsproject.com/
    - 这是一个开源免费的推流软件
    - 支持多种预设推流，以及自定义推流
    - 我们这里使用的就是自定义推流
- 拉流工具
    - 选用：VlcPlayer/PotPlayer
    - VLC下载地址：https://www.videolan.org/
    - POT下载地址：https://potplayer.org/category-3.html
    - 其实是支持播放直播流/网络流的播放器都行
- 配置推流
    - 打开 OBS Studio
    - 根据向导创建即可
    - 名词解释：
        - 场景：就是你可以准备多个场景方便切换，默认添加一个就行
        - 来源：也就是你要推流的视频的来源，是摄像头，还是屏幕等
- 方式一：直接推送rtmp协议流
    - 配置服务器
        - 服务器：rtmp://[IP]:11935/live/
        - 推流码：hello?token=123456
    - 实际上就是配置了：rtmp://[IP]:11935/live/hello?token=123456
        - 这里为了演示可能会有授权验证的需求
        - 添加了token作为授权验证参数
        - 因此推流码，实际上就是一层路径
        - 加上你需要携带的参数
    - 播放
        - 直接播放器填入地址即可
        - 访问地址：rtmp://[IP]:11935/live/hello?token=123456
        - 因此，rtmp协议下，推流和拉流的地址配置是一样的
        - 这里也同样添加参数用以授权验证
- 方式二：推送hls协议流
    - 配置服务器
            - 服务器：rtmp://[IP]:11935/hls/
            - 推流码：hello?token=123456
    - 实际上就是配置了：rtmp://[IP]:11935/hls/hello?token=123456
        - 这里为了演示可能会有授权验证的需求
        - 添加了token作为授权验证参数
        - 因此推流码，实际上就是一层路径
        - 加上你需要携带的参数
    - 播放
        - 直接播放器填入地址即可
        - 访问地址：http://[IP]:11934/hls/hello/index.m3u8
        - 因此，hls协议下，推流和拉流的地址是不一样的，用的协议和端口也不一样
        - 由于是http协议，因此如果需要鉴权，就需要自己实现鉴权逻辑

## 直接将本地的摄像头和麦克风采集并推流
- 这里，需要知道两个参数
- 一个是摄像头名称
- 另一个是麦克风名称
- 这两个的获取，在后面给出
- 这里只介绍，推流
- 假设，摄像头名称为[Camera]占位符
- 麦克风名称为[MIC]占位符
- 推流
    - 使用-r指定帧率
    - 使用-s指定分辨率
    - 使用-bufsize指定缓冲区大小
    - 如果出现too full or near too full的错误导致丢包，适当调小分辨率和帧率或者适当增大缓冲区大小
    - 如果带宽不够，可以只采集视频，不要音频，去掉:audio参数即可
```shell script
ffmpeg -f dshow -i video="[Camera]" audio="[MIC]" -vcodec libx264 -s 720*480 -r 25 -bufsize 1000000k -preset:v ultrafast -tune:v zerolatency -f flv rtmp://[IP]:11935/live/cam
```
- 下面是我测试的推流参数
```shell script
ffmpeg -f dshow -i video="BisonCam,NB Pro" -vcodec libx264 -s 200*200 -r 5 -preset:v ultrafast -tune:v zerolatency -f flv rtmp://[IP]:11935/live/aaa
```

## 采集桌面
- 使用 -f gdigrab 仅采集桌面图像
- 不采集声音
- 如果需要采集声音
- 配合 -f dshow 使用
```shell script
ffmpeg -f gdigrab -i desktop -vcodec libx264 -s 720*480 -r 30 -preset:v ultrafast -tune:v zerolatency -f flv rtmp://[IP]:11935/live/desktop
```

## 采集桌面+音频
- 方法1，采用gdigrab和dshow结合，实现推送音视频
```shell script
ffmpeg -f gdigrab -i desktop -f dshow -i audio="[MIC]" -vcodec libx264 -s 720*480 -r 25 -bufsize 1000000k -preset:v ultrafast -tune:v zerolatency -f flv rtmp://[IP]:11935/live/cam
```
- 方法2，借助第三方插件，使用固定的采集名称
- 下载安装
```shell script
https://sourceforge.net/projects/screencapturer/files/
```
- 安装之后，会得到两个固定的设备名称
    - 屏幕：screen-capture-recorder
    - 音频：virtual-audio-capturer
```shell script
ffmpeg -f dshow -i video="screen-capture-recorder" -f dshow -i audio="virtual-audio-capturer" -vcodec libx264 -s 480*320 -r 30 -acodec aac -ar 44100 -b:a 18000 -preset:v ultrafast -tune:v zerolatency -f flv rtmp://[IP]:11935/live/cam
```

## 采集默认摄像头
- 置顶摄像头名称
- 在命令行中不太好用
- 因此可以使用默认摄像头
```shell script
ffmpeg -f vfwcap -i 0  -vcodec libx264 -s 480*320 -r 30 -preset:v ultrafast -tune:v zerolatency -f flv rtmp://[IP]:11935/live/cam
```

## ffmpeg的简单使用
- 下载ffmpeg
```shell script
https://ffmpeg.org/download.html
```
- 选择windows
- 选择一个下载方gyan
- 选择稳定版release build
- 下载完整版
```shell script
ffmpeg-release-full.7z
```
- 或者使用其他地址
```
https://github.com/GyanD/codexffmpeg/releases
```
- 下载解压之后
- 进入bin路径
- 就会看到如下三个文件
```shell script
ffmpeg.exe
ffplay.exe
ffprobe.exe
```
- 常用的目前就两个
- ffmpeg 用来编解码，转换格式
    - 不同格式互转、剪裁、分离音视频、视频推流等
- ffplay 可以理解为万能播放器
    - 本地视频，网络视频，直播流都可以
- mp4转flv
```shell script
ffmpeg -i test.mp4 -c:v copy  -c:a copy test.flv
```
- mp4转m3u8
    - 由于，m3u8文件存在索引文件和多个ts文件
    - 因此，一般做法是，建立同名mp4的文件夹
    - 将m3u8整个输出到这个文件夹
```shell script
md test
ffmpeg -i test.mp4 -force_key_frames "expr:gte(t,n_forced*2)" -strict -2 -c:a aac -c:v libx264 -hls_time 2 -f hls test\index.m3u8
```
- 播放网络流
```shell script
ffplay test.mp4
ffplay test.flv
ffplay test.m3u8
```

## 使用ffmpeg获取摄像头和麦克风设备名
- 查看电脑设备
```shell script
ffmpeg -list_devices true -f dshow -i dummy
```
```shell script
[dshow @ 00000299f6377b00] "BisonCam,NB Pro" (video)
[dshow @ 00000299f6377b00]   Alternative name "@device_pnp_\\?\usb#vid_5986&pid_1112&mi_00#6&64c207b&0&0000#{65e8773d-xxxxx-9223196}\global"
[dshow @ 00000299f6377b00] "麦克风 (Realtek High Definition Audio)" (audio)
[dshow @ 00000299f6377b00]   Alternative name "@device_cm_{33D9A762-xxxx-911CE86}\wave_{E4D80E18-xxxx-49A39BC4CC}"
```
- 看到video和audio两个音视频设备
```shell script
"BisonCam,NB Pro" (video)
"麦克风 (Realtek High Definition Audio)" (audio)
```
- 测试摄像头可用
```shell script
ffplay -f dshow -i video="BisonCam,NB Pro"
```

## 综合搭建直播平台核心
- 直播部分
    - 使用ffmpeg或者OBS Studio推流到stmp服务器
    - 使用流媒体播放器播放视频流，比如VLC或者ffplay
- 点播部分
    - 将视频上传到服务器
    - 使用ffmepg重新转码为flv或者m3u8视频
    - 使用流媒体播放器播放视频流，比如VLC或者ffplay

## 更多内容参考
```shell script
https://www.cnblogs.com/zhangmingda/p/12638985.html
```

## 添加鉴权机制
- 为了防止被滥用，需要添加鉴权功能
- 原理是使用nginx-rtmp模块提供的回调能力
- 在推流时和在播放时，进行鉴权，鉴权通过之后，才进行推流或者播放

### 实现
- 更改nginx的rtmp配置
    - 也就是添加 on_publish 和 on_play 回调
    - 在 live 和 hls 两个节点下，都添加了鉴权的服务定向
```shell script
# 点播/直播功能实现配置rtmp协议
rtmp {
    server {
        listen 11935;
        chunk_size 4000;
        application vod {
            play /root/rtmp/vod/flvs/; # 点播媒体存放目录
        }
        application live {
            live on;
            on_publish http://127.0.0.1:11936/api/rtmp/auth;
            on_play http://127.0.0.1:11936/api/rtmp/auth;
        }
        # HLS直播配置
        application hls {
            live on;
            on_publish http://127.0.0.1:11936/api/rtmp/auth;
            on_play http://127.0.0.1:11936/api/rtmp/auth;
            hls on;
            hls_path /root/rtmp/live/hls; # 视频流存放地址
            hls_fragment 5s;
            hls_playlist_length 15s;
            hls_continuous on; # 连续模式。
            hls_cleanup on;    # 对多余的切片进行删除。
            hls_nested on;     # 嵌套模式。
        }
    }
    # 日志配置
    access_log logs/rtmp_access.log;

}
```
- 编写对应的鉴权服务
- nginx 会将URL参数和Nginx的内部参数
- 以POST的方式用application/x-www-form-urlencoded格式提交给回调接口
- 接口成功响应需要HTTP Status为2xx
- 响应失败为5xx,4xx等
- 并且响应的数据为JSON格式
- 格式如下：
    - 分别是成功和失败的响应报文
```json
{"code": 200,"detail": "SUCCESS"}
```
```json
{"code": 500,"detail": "ERROR"}
```
- 这里以JAVA的spring-mvc编写为例
- 我们需要给连接加上一个token作为访问令牌
- 也就是将推流或者拉流的URL变为如下形式，添加token参数
```
rtmp://[IP]:11935/live/aaa?token=123456
```
- 这个代码也包含在本项目中，模块为： itl-nginx-rtmp-auth-server
- controller代码
```java
package i2f.nginx.rtmp.auth.server.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletResponse;
import java.util.Map;

/**
 * @author i2f
 * @date 2023/1/14 20:47
 * @desc
 */
@Slf4j
@RestController
@RequestMapping("/api/rtmp")
public class RtmpAuthController {

    @Value("${rtmp.auth.access-token:}")
    private String accessToken;

    /**
     * nginxData字段介绍
     * call=play。
     * addr - 客户端 IP 地址。
     * app - application 名。
     * flashVer - 客户端 flash 版本。
     * swfUrl - 客户端 swf url。
     * tcUrl - tcUrl。
     * pageUrl - 客户端页面 url。
     * name - 流名。
     *
     * @param nginxData
     * @param token
     * @return
     */
    @PostMapping(value = "/auth")
    public Object auth(@RequestParam Map<String,Object> nginxData,
                           @RequestParam(value="token",required = false)String token,
                           HttpServletResponse response) {
        log.info("nginxData:"+nginxData);
        log.info("token:"+token);
        if(!StringUtils.isEmpty(accessToken)){
            if(!accessToken.equals(token)){
                log.error("auth failure!");
                response.setStatus(500);
                return "{\"code\":500,\"detail\":\"ERROR\"}";
            }
        }
        log.info("auth success!");
        return "{\"code\":200,\"detail\":\"SUCCESS\"}";
    }

}
```
- 对应的项目配置
```yaml
server:
  port: 11936

rtmp:
  auth:
    access-token: 123456
```
- 这个示例中，使用个固定的token
- 实际情况中，可以使用用户登录系统的token来做校验即可
- 并且这个token不能太长，因为在nginx-rtmp源码中，限定了URL的长度为512字节
