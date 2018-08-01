#!/bin/bash

#server.sh 逻辑：
##启动: 检查bin目录的pid文件，文件存在，根据pid检查程序是否在运行，在提示。不在调用程序启动命令，
##      并更新pid，控制台信息输出到logs目录的project_console.log。
##      sleep 10秒后检查进程号，在则表示启动成功，不在启动失败
##停止: 检查bin目录的pid文件，文件存在，根据pid检查程序是否在运行，在kill进程号，不在提示；
##      kill进程后sleep 5秒后检查进程号，不在停止成功，在提示停止失败
##状态: 检查bin目录的pid文件，文件存在，根据pid检查程序是否在运行，在提示已运行，不在提示进程不在
##重启：先调用stop，再调用start


###################初始化###############################
cd $(cd "$(dirname "$0")"; pwd)/../
SHELL_PROG=./server.sh
JAR_NAME=chatroom-0.0.1-SNAPSHOT.jar
#判断程序启动成功的标志（在MAIN_CLASS中输出的），如未输出就认为启动失败
START_FLAG='Started TreeNewBeeChatRoomApplication'
#启动的超时时间，单位：秒。超时就认为启动失败
START_TIMEOUT=60
#停止的超时时间，单位：秒。超时就认为停止失败
STOP_TIMEOUT=60

##HOMES
CLASSPATH=$PWD
PROJECT=$(basename $PWD)
BIN_HOME=$PWD/bin
LOG_HOME=$PWD/logs
PIDFILE=$BIN_HOME/server.pid
CONSOLE=$LOG_HOME/${PROJECT}-console.log
SPLIT_PREFIX=${CONSOLE%.log}_`date +%Y-%m-%d`

#启动自动检测目录是否存在
test -d $BIN_HOME || { echo "$BIN_HOME not exits" ; exit 1; }
#第一次部署启动时，自动创建logs目录
test -d $LOG_HOME || mkdir -p $LOG_HOME

#######################################################

function getlogseq(){
    seq=0
    if [ -d ${LOG_HOME} ] && ls ${SPLIT_PREFIX}.*.log >/dev/null 2>&1; then
        seq=$(ls -l ${SPLIT_PREFIX}.*.log | awk -F. '{print $(NF-1)}' | sort -n | tail -1)
        seq=`expr ${seq} + 1`
    fi
    echo ${seq}
}

function getpid(){
    if [[ -f $PIDFILE ]]
    then
        pid=$(cat $PIDFILE|awk '{print $1}')
        #java程序启动带家目录
        num=$(ps aux|grep -v grep|awk '{print $2}'|grep -w $pid|wc -l)
        #根据文件pid检查是否程序正在运行，如果一致，则正在运行
        if [[ $num -eq 1 ]]
        then
            echo $pid
        else
            echo "-1"
        fi
    else
         echo "-1"
    fi
}

#程序启动,开发可以自动启动与程序判断内容
function startserver(){
    #cd $LIB_HOME
    test -f ${CONSOLE} && mv ${CONSOLE} ${SPLIT_PREFIX}.$(getlogseq).log
    nohup java -jar $JAR_NAME >$CONSOLE 2>&1  &
    pid=$!
    echo $pid > $PIDFILE

    #启动后每秒检查一次START_FLAG, 找到则表示启动成功
    started=0
    for i in `seq ${START_TIMEOUT}`; do
        sleep 1
        #num=$(ps aux|grep -v grep|awk '{print $2}'|grep -w $pid|wc -l)
        #if  [[ $num -gt 0 ]]
        if grep "${START_FLAG}" ${CONSOLE} >/dev/null 2>&1
        then
            started=1
            break
        fi
    done
    if [[ ${started} -eq 1 ]]; then
        echo $pid
    else
        echo "-1"
    fi
}

function start(){
    #根据pid检查程序是否在运行，进程号小于0(0代表进程没启动)，则启动程序
    #否则，程序已运行，保留现状，返回提示
    oldpid=$(getpid)
    if [[ $oldpid -lt 0 ]]
    then
        echo "[$(date '+%Y-%m-%d %T')] $PROJECT Starting..."
        pid=$(startserver)
        if [[ $pid -gt 0 ]]
        then
            echo "[$(date '+%Y-%m-%d %T')] Startup $PROJECT success.( pid: $pid )"
        else
            echo "[$(date '+%Y-%m-%d %T')] Startup $PROJECT fail, check detailed information in $CONSOLE"
        fi
    else
        echo "[$(date '+%Y-%m-%d %T')] $PROJECT is running aleady. ( pid: $oldpid )"

    fi
}

function stop(){
    pid=$(getpid)
    #pid存在，则kill，不存在，提示
    if [[ $pid -gt 0 ]]
    then
        printf "[$(date '+%Y-%m-%d %T')] $PROJECT stoping."
        kill $pid
        stopped=0
        for i in `seq ${STOP_TIMEOUT}`; do
            sleep 1
            printf '.'
            num=$(ps aux|grep -v grep|awk '{print $2}'|grep -w $pid|wc -l)
            #根据pid检查进程数量，0停止成功,大于0停止失败
            if [[ $num -eq 0 ]]
            then
                stopped=1
                printf "\n[$(date '+%Y-%m-%d %T')] Stop $PROJECT success.\n"
                # 不用删除每次的控制台输出
                #rm -f $CONSOLE
                break
            fi
        done
        if [[ ${stopped} -eq 0 ]]; then
            echo "[$(date '+%Y-%m-%d %T')] Stop $PROJECT fail.( pid:$pid )"
        fi
    else
        echo "[$(date '+%Y-%m-%d %T')] $PROJECT is not running"
        # exit 0;
    fi
}


function restart(){
    stop
    start
}

function status() {
    pid=$(getpid)

    if [[ $pid -gt 0 ]]
    then
        echo "[$(date '+%Y-%m-%d %T')] $PROJECT is running.( pid:$pid )"
    else
        echo "[$(date '+%Y-%m-%d %T')] $PROJECT is not running"
    fi
}


case "$1" in
    start)
       start
       exit $?
       ;;
    stop)
        stop
        exit $?
        ;;
    restart)
        stop
        start
        exit $?
        ;;
    status)
        status
        exit $?
        ;;
    *)
        echo "Usage: bash $SHELL_PROG {start|status|stop|restart}"
        exit 1
        ;;
esac
exit 0

