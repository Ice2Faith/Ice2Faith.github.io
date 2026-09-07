# build an env for run an jar
# author : i2f

# base from jdk8
FROM openjdk:8-jdk-alpine

# mount any docker template path to /tmp
VOLUME /tmp

# copy app.jar
COPY app.jar /apps/app.jar

CMD ["--boot.env=docker"]

# run jar
ENTRYPOINT ["java","-jar","/apps/app.jar"]

