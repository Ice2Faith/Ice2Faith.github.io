FROM redis:alpine as sys-base

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

RUN mkdir -p  /usr/share/redis \
    ; mkdir -p /var/cache/redis \
    ; mkdir -p /var/log/redis \
    ; mkdir -p /etc/redis \
    ; mkdir -p /run \
    ; chown -R $APP_USER:$APP_USER /usr/share/redis \
    ; chown -R $APP_USER:$APP_USER /var/cache/redis \
    ; chown -R $APP_USER:$APP_USER /var/log/redis \
    ; chown -R $APP_USER:$APP_USER /etc/redis \
    ; chown -R $APP_USER:$APP_USER /run

FROM sys-base

# 元数据规范
LABEL maintainer="rwd" \
      description="rwd-redis"

# 可选配置项
ENV SERVER_PORT=6379 \
    PARAMS=""

# 暴露端口
EXPOSE $SERVER_PORT

# 添加资源
COPY assets/redis-@spring.env@.conf /etc/redis/redis.conf



# 执行最终降权运行
RUN chown -R $APP_USER:$APP_USER $APP_HOME && \
    chown -R $APP_USER:$APP_USER /etc/redis

USER 2770


ENTRYPOINT ["sh","-c","redis-server \
                /etc/redis/redis.conf \
                $PARAMS"]