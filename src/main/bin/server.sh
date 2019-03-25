#!/bin/bash
# Auto-starts boot
# 任何目录下执行此脚本都可以

JAVA_HOME=`echo ${JAVA_HOME}`
# 默认 dev 环境
ENV="dev"
# 默认为启动
FUNC="start"
# 默认 debug 关闭
DEBUG_PORD="-1"
# 默认启动后 tail 日志
SHOW_LOG="off"
# 自定义参数, 先设置变量
while getopts "s:r:Sd:cHlh:" opt; do
	case ${opt} in
		# 启动应用, 跟环境变量
		s)
			ENV=${OPTARG}
			FUNC="start"
			;;
		# 重启应用 跟环境变量
		r)
			ENV=${OPTARG}
			FUNC="restart"
			;;
		c)
			FUNC="status"
			# 这里只是随意设置一个环境, 防止查看应用状态时脚本报错
			ENV="local"
			;;
		# 关闭应用
		S)
			FUNC="stop"
			# 这里只是随意设置一个环境, 防止关闭应用时脚本报错
			ENV="local"
		  ;;
		# 使用 debug 模式 跟监听端口
		d)
			DEBUG_PORD=${OPTARG}
		  ;;
		l)
			SHOW_LOG="on"
		  ;;
		h)
			FUNC="helper"
			ENV=${OPTARG}
		  ;;
		H)
			echo -e "\033[0;31mHELP
1. 在任何目录下执行此脚本都可以.
2. 最简单的命令就是不输入任何参数 (./server.sh 即以${ENV}环境启动应用).
3. 输入 -s 和 -r 参数, 后面必须跟环境变量 (dev/test/prod);
4. -d 和 -l 参数不能单独存在, 且必须跟在 -s 或者 -r 后面;
5. -h 参数不需要手动调用, 是程序自动调用, 用于启动 helper 进程来对主应用进行重启操作.\033[0m  \033[0;34m
-s:启动应用		exp: ./server.sh 			(默认以 ${ENV} 环境启动应用, 不需要输入任何参数)
-s:启动应用		exp: ./server.sh -s test 		(以 dev 环境启动应用)
-r:重启应用		exp: bin/server.sh -r prod 		(以 prod 环境重启应用)
-S:关闭应用		exp: bin/server.sh -S 			(关闭应用)
-c:查看状态		exp: bin/server.sh -c 			(查看应用状态)
-l:查看日志		exp: bin/server.sh -s dev -l 	(启动时自动 tail 全量日志)
-d:debug模式 		exp: bin/server.sh -s dev -d 5005 	(以 dev 环境启动应用, 并且开启 debug 模式, 用于 idea 远程调试)
-d:debug模式 		exp: bin/server.sh -s dev -d 5005 -l 	(增加自动 tail 全量日志)
\033[0m"
			exit 1
		  ;;
		\?)
			echo -e "\033[0;31m参数列表错误 使用 -H 查看帮助"
			exit 1
		  ;;
  	esac
done

if [ ${FUNC} = "start" -o ${FUNC} = "restart" ];then
	if [ ${ENV} != "local" -a ${ENV} != "dev" -a ${ENV} != "test" -a ${ENV} != "prod" ];then
		echo -e "\033[0;31m环境变量错误 \033[0m  \033[0;34m {dev|test|prod}"
		exit 1
	fi
fi

# 是否开始远程调试
#DEBUG_SWITCH=$3
# debug 模式 用于远程调试
if [ ${DEBUG_PORD} != "-1" ];then
	expr ${DEBUG_PORD} "+" 10 &> /dev/null
	if [ $? -eq 0 ];then
	  	DEBUG_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=$DEBUG_PORD"
		echo -e "\033[0;34mopen debug mode: DEBUG_OPTS=$DEBUG_OPTS"
	else
		echo -e "\033[0;31m请输入正确的端口号"
		exit 1
	fi
fi

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

#echo "app_home = $APP_HOME"
DEPLOY_DIR=$(dirname "$APP_HOME")
APP_NAME=`awk -F '=' '{if($1~/artifactId/) printf $2}' ${DEPLOY_DIR}/config/pom.properties`
#echo "app_name = ${APP_NAME}"
JAR_FILE=${DEPLOY_DIR}/${APP_NAME}.jar

PID=0
PORT=`awk -F '=' '{if($1~/server.port/) printf $2}' ${DEPLOY_DIR}/config/application.properties`
if [ ! -n ${PORT} ]; then
	PORT="8080"
fi

# 设置 gc 日志, service-meeting/bin/loggc/gc-service-meeting-xxxxxxxxxxxxx.log
ADATE=`date +%Y%m%d%H%M%S`
GC_LOG_PATH=${APP_HOME}/loggc
if [ ! -d ${GC_LOG_PATH} ];then
	mkdir ${GC_LOG_PATH}
fi
GC_LOG=${GC_LOG_PATH}/gc-${APP_NAME}-${ADATE}.log
# JMX监控需用到
JMX="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=1091 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"
# JVM参数
JVM_OPTS="-Dname=${APP_NAME} -Duser.timezone=Asia/Shanghai -Xms512M -Xmx512M -XX:PermSize=256M -XX:MaxPermSize=512M -XX:+HeapDumpOnOutOfMemoryError -XX:+PrintGCDateStamps -Xloggc:${GC_LOG} -XX:+PrintGCDetails -XX:NewRatio=1 -XX:SurvivorRatio=30 -XX:+UseParallelGC -XX:+UseParallelOldGC"

# 启动命令
# 执行后启动app, 等待 1s 后查看 nohup.out 启动日志
# 加载 /config 下的配置文件(优先级最高, 所以不配置也可以) 加载配置的优先级 file:./config/ > file:./ > classpath:/config/ > classpath:/
# 设置一个自定义参数, 用于区分一台服务器上多个不同的实例
function start(){
	check_port
	check_pid
	if [ ! -n "$PID" ]; then
		if [ ! -d ${LOG_PATH}  ];then
			mkdir ${LOG_PATH}
		fi
		nohup ${JAVA_HOME}/bin/java -jar \
		${JVM_OPTS} \
		-Ddeploy.path=${DEPLOY_DIR} \
		-Dinstance.id=${APP_NAME}.${PORT} \
		-Dstart.type=shell \
		-Dconfig.path=${DEPLOY_DIR}/config/ \
		${DEBUG_OPTS} \
		${JAR_FILE} \
		--spring.config.location=${DEPLOY_DIR}/config/ &
		echo -e "\033[0;34m--------------------------------------"
		echo -e "\033[0;34m starting ${APP_NAME} on ${PORT} port "
		echo -e "\033[0;34m--------------------------------------"

		# 干掉 helper 进程
		HELPER_PID=`ps -ef | grep -v grep | grep ${APP_NAME}.helper.${PORT} | grep java | awk '{print $2}'`
		if [ -n "${HELPER_PID}" ];then
			echo -e "\033[0;31mkill ${APP_NAME}.${PORT} helper"
			kill ${HELPER_PID} > /dev/null 2>&1
		fi
	else
		echo -e "\033[0;31m$APP_NAME is runing, pid: $PID"
	fi
}

# 查看应用状态
function status(){
	check_pid
	if [ ! -n "$PID" ]; then
		echo -e "\033[0;31m$APP_NAME not runing"
	else
		echo -e "\033[0;34m$APP_NAME runing, pid: $PID"
	fi
}

# 检查端口是否被占用
function check_port() {
	PORT=`awk -F '=' '{if($1~/server.port/) printf $2}' ${DEPLOY_DIR}/config/application.properties`
	is_exist=`netstat -tlpn | grep "\b${PORT}\b"`
	if [ ! -n is_existence ]; then
		echo -e "\033[0;31mport exists"
		exit 1
	fi
}

# 获取 pid
function check_pid(){
	PID=`ps -ef | grep -v grep | grep ${APP_NAME}.${PORT} | grep java | awk '{print $2}'`
}

# 停止 app
# 使用 kill app 命令
# 循环检查是否停止应用
function stop(){
	check_pid
	if [ ! -n "$PID" ]; then
		echo -e "\033[0;31mThe $APP_NAME does not started!"
	else
		echo -e "\033[0;31mshudown the $APP_NAME"
		kill ${PID} > /dev/null 2>&1
		COUNT=0
		KILL_COUNT=0
		# COUNT 小于 1
		while [ ${COUNT} -lt 1 ]; do
			echo -e ".\c"
			KILL_COUNT=$(($KILL_COUNT+1))
			if [ ${KILL_COUNT} -gt 11 ]; then
				echo -e "\n"
				kill -9 ${PID} > /dev/null 2>&1
			fi
			# 检查是否干掉 app
			PID_EXIST=`ps -ef | grep -v grep | grep ${APP_NAME}.${PORT} | grep java | awk '{print $2}'`
			# 如果为空, 则退出循环
			if [ ! -n "$PID_EXIST" ]; then
			 	COUNT=1
			fi
			sleep 1s
		done
		echo
		echo -e "\033[0;34m$APP_NAME shudown success, pid = $PID"
	fi
}

function restart(){
	stop
	sleep 1s
	start
}

# 启动 helper 应用
function helper(){
	nohup ${JAVA_HOME}/bin/java -jar \
	-Ddeploy.path=${DEPLOY_DIR} \
	-Dinstance.id=${APP_NAME}.helper.${PORT} \
	-Dstart.type=shell \
	-Denv=${ENV} \
	${DEPLOY_DIR}/ms-helper.jar \
	--logging.file=${LOG_PATH}/${APP_NAME}/error.log  &
}

# 通过 func 来执行具体方法
case ${FUNC} in
	start)		start;;
	stop)		stop;;
	restart)	restart;;
	status)		status;;
	helper)		helper;;
	*)			echo -e "\033[0;31m参数错误 \033[0;34m require -s|-r|-S|-c";;
esac