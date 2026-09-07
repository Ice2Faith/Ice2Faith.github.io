FROM nginx:alpine as sys-base

# 定义时区
# 定义运行用户
ENV TZ=PRC \
    APP_HOME=/app \
    APP_USER=app


RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    ; echo $TZ > /etc/timezone \
    ; addgroup -S -g 2779 $APP_USER \
    ; adduser -S -G $APP_USER -u 2770 $APP_USER \
    ; mkdir -p $APP_HOME  \
    ; chown -R $APP_USER:$APP_USER $APP_HOME \
    ; apk add --no-cache bash curl net-tools bind-tools procps wget busybox openssh-client

WORKDIR $APP_HOME

RUN mkdir -p /var/cache/nginx && chown -R $APP_USER:$APP_USER /var/cache/nginx && chmod -R 777 /var/cache/nginx && \
    mkdir -p /var/log/nginx  && chown -R $APP_USER:$APP_USER /var/log/nginx && chmod -R 777 /var/log/nginx && \
    mkdir -p /run/nginx  && chown -R $APP_USER:$APP_USER /run/nginx && chmod -R 777 /run/nginx && \
    mkdir -p /var/lib/nginx  && chown -R $APP_USER:$APP_USER /var/lib/nginx && \
    chown -R $APP_USER:$APP_USER /etc/nginx && chmod -R 777 /etc/nginx

FROM sys-base

# 元数据规范
LABEL maintainer="app" \
      description="app-web"

# 可选配置项
ENV SERVER_PORT=8080 \
  PARAMS=""

# 暴露端口
EXPOSE $SERVER_PORT

# 添加资源
COPY dist ./dist
COPY nginx-@build.env@.conf /etc/nginx/nginx.conf

# 执行最终降权运行
RUN chown -R $APP_USER:$APP_USER $APP_HOME && \
    chown -R $APP_USER:$APP_USER /etc/nginx

USER 2770


ENTRYPOINT ["sh","-c","nginx -g 'daemon off;master_process on;' $PARAMS"]
