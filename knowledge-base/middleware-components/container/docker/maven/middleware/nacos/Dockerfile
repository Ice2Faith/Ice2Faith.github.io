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
      description="app-nacos"

# 可选配置项
ENV SERVER_PORT=8848 \
    GRPC_CLIENT_PORT=9848 \
    GRPC_SERVER_PORT=9849 \
    JRAFT_PORT=7848 \
    PARAMS="" \
    JVM_OPTS="-Xms1g -Xmx1g -Xmn512m \
       -XX:MetaspaceSize=128m -XX:MaxMetaspaceSize=320m \
       -XX:+UseConcMarkSweepGC -XX:+UseCMSCompactAtFullCollection -XX:CMSInitiatingOccupancyFraction=70 -XX:+CMSParallelRemarkEnabled -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+CMSClassUnloadingEnabled -XX:SurvivorRatio=8 \
       -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:+UseGCLogFileRotation -XX:NumberOfGCLogFiles=10 -XX:GCLogFileSize=100M " \
    SPRING_ENV=@spring.env@ \
    TAR_NAME="nacos-server-2.3.2.tar.gz"

# 暴露端口
EXPOSE $SERVER_PORT \
    $GRPC_CLIENT_PORT \
    $GRPC_SERVER_PORT \
    $JRAFT_PORT

# 添加资源
# 添加资源
ADD assets/$TAR_NAME .
COPY assets/resources/ ./nacos/

WORKDIR $APP_HOME/nacos/bin

# 执行最终降权运行
RUN chown -R $APP_USER:$APP_USER $APP_HOME

USER 2770


ENTRYPOINT ["sh","-c","java \
                          -Dnacos.standalone=true \
                          -Dnacos.member.list= \
                          -Dloader.path=../plugins \
                          -Dnacos.home=../ \
                          -Dspring.profiles.active=$SPRING_ENV \
                          -Dserver.port=$SERVER_PORT \
                          $JVM_OPTS \
                          -jar ../target/nacos-server.jar  \
                          --spring.config.additional-location=file:../conf/ \
                          --logging.config=../conf/nacos-logback.xml \
                          --server.max-http-header-size=524288 \
                          $PARAMS "]
