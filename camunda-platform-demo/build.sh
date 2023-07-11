#!/bin/sh

cur_path=$(
   cd "$(dirname "$0")"
   pwd
)
CUR_DATE=$(date '+%Y%m%d')
APP_NAME=camunda-platform-demo
APP_VERSION=3
TAR_NAME="${APP_NAME}.tar"

mvn clean package -Dmaven.test.skip=true
echo "Maven构建完成，开始构建Docker镜像"

cd $cur_path &&  ls -al &&
 docker build --rm -t ${APP_NAME}:${CUR_DATE}.${APP_VERSION} --platform=linux/x86_64 . &&
 echo "镜像已构建" &&
 docker images|grep ${APP_NAME} &&
 docker save -o ${TAR_NAME} ${APP_NAME}:${CUR_DATE}.${APP_VERSION} &&
 echo "镜像已保存" &&
 mkdir -p $cur_path/pkg && mv ${TAR_NAME} $cur_path/pkg && cd $cur_path/pkg && ls -al;


# 自动修改版本号
((NEW_APP_VERSION=$APP_VERSION+1))
sed -i "" "s/APP_VERSION=${APP_VERSION}/APP_VERSION=${NEW_APP_VERSION}/g" $cur_path/build.sh