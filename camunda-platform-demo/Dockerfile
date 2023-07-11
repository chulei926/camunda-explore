FROM openjdk:8-jre-alpine
COPY ./target/camunda-platform-demo.jar  /usr/local/
WORKDIR /usr/local/

# 修改docker时区为东八区，规避应用运行时间与北京时间相差8小时问题
ENV TZ=Asia/Shanghai
CMD ["nohup", "java", "-jar", "camunda-platform-demo.jar", "&"]