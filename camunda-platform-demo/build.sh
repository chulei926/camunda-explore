#!/bin/sh

cur_path=$(
   cd "$(dirname "$0")"
   pwd
)
cur_date=$(date '+%Y%m%d')

APP_NAME=$(mvn -Dexec.executable='echo' -Dexec.args='${project.artifactId}' --non-recursive exec:exec -q)
APP_VERSION=$(mvn -Dexec.executable='echo' -Dexec.args='${project.version}' --non-recursive exec:exec -q)

APP_PKG=${APP_NAME}-${APP_VERSION}
APP_VERSION_IMG=$(echo $APP_VERSION | tr '.' '_')
TAR_NAME=${APP_NAME}-${cur_date}_${APP_VERSION_IMG}.tar
echo "获取到当前项目名称：${APP_NAME}, 当前版本号：${APP_VERSION}, 镜像版名：${TAR_NAME}, 开始执行Maven构建。"

mvn clean package -Dmaven.test.skip=true
echo "Maven构建完成，开始构建Docker镜像"

docker rm -f $(docker ps -a|grep $APP_NAME|awk '{print $1}')
#
cd $cur_path/target &&  ls -al &&
 docker build --rm -t ${APP_NAME}:${cur_date}.${APP_VERSION} --platform=linux/x86_64 . &&
 echo "镜像已构建" &&
 docker images|grep ${APP_NAME} &&
 docker save -o ${TAR_NAME} ${APP_NAME}:${cur_date}.${APP_VERSION} &&
 echo "镜像已保存" &&
 mkdir -p $cur_path/pkg && cp ${TAR_NAME} $cur_path/pkg && cd $cur_path/pkg && ls -al;

# 动态修改版本号
increment_version ()
{
  declare -a part=( ${1//\./ } )
  declare    new
  declare -i carry=1
  CNTR=${#part[@]}-1
  len=${#part[CNTR]}
  new=$((part[CNTR]+carry))
  part[CNTR]=${new}
  new="${part[*]}"

  echo "${new// /.}"
}
new_version=$(increment_version $APP_VERSION)
cd $cur_path && mvn versions:set -DnewVersion=$new_version && mvn versions:commit
echo "构建完成，新的版本号: ${new_version}"

