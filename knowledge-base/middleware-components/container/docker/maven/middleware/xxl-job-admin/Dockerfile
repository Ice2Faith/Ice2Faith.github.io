FROM openjdk:8-jre-alpine as sys-base

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

FROM sys-base

# 元数据规范
LABEL maintainer="app" \
      description="app-xxl-job-admin"


# 可选配置项
ENV SERVER_PORT=8080 \
    PARAMS="" \
    JVM_OPTS="-Xms64m -Xmx1024m" \
    SPRING_ENV=@spring.env@ \
    LOGBACK_ENV=@logback.env@ \
    APP_NAME="xxl-job-admin" \
    TAR_NAME="xxl-job-admin-all.tar.gz" \
    JAR_NAME="xxl-job-admin.jar"

# 暴露端口
EXPOSE $SERVER_PORT

# 添加资源
ADD assets/$TAR_NAME .
COPY assets/resources/* ./$APP_NAME/resources/

WORKDIR $APP_HOME/$APP_NAME

# 执行最终降权运行
RUN chown -R $APP_USER:$APP_USER $APP_HOME

USER 2770

ENTRYPOINT ["sh","-c","java -jar \
                    -Dlogback.app.env=$LOGBACK_ENV \
                    -Dspring.profiles.active=$SPRING_ENV \
                    -Dserver.port=$SERVER_PORT \
                    $JVM_OPTS \
                    $JAR_NAME \
                    $PARAMS"]
