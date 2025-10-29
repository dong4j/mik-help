#!/bin/bash
# 应用启动脚本

# 获取应用部署路径
APP_HOME=`pwd`
dirname $0 | grep "^/" >/dev/null
if [ $? -eq 0 ];then
	APP_HOME=`dirname $0`
else
	dirname $0 | grep "^\." >/dev/null
	retval=$?
	if [ ${retval} -eq 0 ];then
		APP_HOME=`dirname $0|sed "s#^.#$APP_HOME#"`
	else
		APP_HOME=`dirname $0|sed "s#^#$APP_HOME/#"`
	fi
fi

DEPLOY_DIR=$(dirname "$APP_HOME")
APP_NAME=`awk -F '=' '{if($1~/artifactId/) printf $2}' ${DEPLOY_DIR}/config/pom.properties`
JAR_FILE=${DEPLOY_DIR}/${APP_NAME}.jar

# 启动应用
nohup /usr/bin/java -jar \
--add-opens java.base/java.lang=ALL-UNNAMED \
-Dconfig.path=${DEPLOY_DIR}/config/ \
mik-help-0.0.1.jar \
--spring.config.location=${DEPLOY_DIR}/config/ &
