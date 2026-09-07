#!/bin/bash

# 告警的应用名称
ALARM_APP_NAME=test-app
# 告警邮件接收人
ALARM_MAIL_TO="test@qq.com admin@163.com"
# 工作路径
WORK_DIR="/home/apps/test"

# 服务器名称
# 不设置则自动获取
SERVER_NAME=

# 验证部分，只有有值才会进行对应的校验
# 当多个条件都有值时，需要多个条件都满足才算通过验证
# 验证本机端口是否占用
VERIFY_PORT=8080
# 验证指定名称的进程是否存活
VERIFY_PROCESS_NAME="test.jar"
# 验证PID文件的进程是否存活
VERIFY_PID_FILE="./test.jar.pid"
# 验证指定的PID是否存活
VERIFY_PID=
# 验证指定的HTTP链接是否可联通
VERIFY_HTTP_URL="http://localhost:8080/sys/login"
# 验证指定的套接字是否可联通
VERIFY_SOCK_HOST=localhost
VERIFY_SOCK_PORT=8080
# 验证主机是否可联通
VERIFY_HOST=localhost


# 启动脚本
BASH_START="./start.sh"
# 停止脚本
BASH_STOP="./stop.sh"
# 强杀脚本，将会在最后1次尝试时使用强杀
# 这样可以避免正常的停止脚本无法停止的问题
BASH_KILL="./jarctrl.sh stop"

# 日志文件
LOG_FILE="./log.keepalived"
# 日志文件最大保留行数
LOG_FILE_KEEP_LINES=3000


# 最大失败次数
FAIL_MAX_COUNT=6
# 失败等待重启时间
FAIL_SLEEP=30
# 停止脚本等待时间
STOP_SLEEP=5

# 定义常量
BOOL_TRUE=1
BOOL_FALSE=0

# 定义函数的入参和返回值
# 公共变量，在函数调用时使用
# 自行控制堆栈变量
_func_arg1=
_func_arg2=
_func_arg3=
_func_arg4=
_func_ret=

# 清空函数的入参和返回值
# 用在准备调用函数之前执行
function cleanFuncParams() {
    _func_arg1=
    _func_arg2=
    _func_arg3=
    _func_arg4=
    _func_ret=
}

# 根据端口号查询进程号，仅针对java进程
# 入参：端口号
# 返回值：PID
function findPidByPort() {
  _p_port=$_func_arg1
  _func_ret=

  _p_pid=`netstat -nlp | grep -v grep | grep :${_p_port} | awk '{print $7}' | awk -F '[ / ]' '{print $1}'`
  _func_ret=$_p_pid
}

# 根据进程名，查找进程号
# 入参：进程名
# 返回值：PID
function findPidByName() {
  _p_name=$_func_arg1
  _func_ret=

  _p_pid=`ps -ef | grep -v grep | grep "${_p_name}" | awk '{print $2}' | head -1`
  _func_ret=$_p_pid
}

# 根据PID文件名，查找进程号
# 入参：PID文件名
# 返回值：PID
function findPidByPidFile() {
  _p_file_name=$_func_arg1
  _func_ret=

  _p_pid=

  _p_chk_pid=`cat ${_p_file_name} | head -1 | awk '{print $1}'`
  if [[ -n "${_p_chk_pid}" ]]; then
    _p_pid=`ps -ef | grep -v grep | awk '{print $2}' | grep ${_p_chk_pid}`
  fi
  _func_ret=$_p_pid
}

# 根据PID，查找进程号
# 入参：PID
# 返回值：PID
function findPidByPid() {
  _p_chk_pid=$_func_arg1
  _func_ret=

  _p_pid=`ps -ef | grep -v grep | awk '{print $2}' | grep ${_p_chk_pid}`
  _func_ret=$_p_pid
}

# 根据HTTP链接，获取HTTP响应码
# 入参：HTTP链接
# 返回值：HTTP响应码，其中000为不可访问或无法连接，其他的就是404,500等响应码
function findHttpCodeByUrl() {
  _p_http_url=$_func_arg1
  _func_ret=

  _p_http_code=`curl -o /dev/null -s -w "%{http_code}" "${_p_http_url}"`
  _func_ret=$_p_http_code
}

# 根据HOST和端口，获取链接成功的计数
# 入参：HOST主机名或IP地址
# 入参：PORT端口
# 返回值：0表示无法连接，否则表示可连接
function findCountByHostPort() {
  _p_host=$_func_arg1
  _p_port=$_func_arg2
  _func_ret=

  _p_count=`nc -c xxx -v ${_p_host} ${_p_port} 2>&1 | grep -v grep | grep Connected | wc -l`
  _func_ret=$_p_count
}

# 根据HOST主机，获取链接的丢包率
# 入参：HOST主机或者IP地址
# 返回值：丢包率，不为0则表示存在丢包
function findLostRateByHost() {
  _p_host=$_func_arg1
  _func_ret=

  _p_lost_rate=`ping -c 3 ${_p_host} | grep -v grep | grep transmitted | awk -F "," '{print $3}' | awk -F "%" '{print $1}'`
  _func_ret=$_p_lost_rate
}

# 日志部分
_p_log_out=
function logInfo(){
  if [[ -n "${LOG_FILE}" ]]; then
    echo "`date '+%Y-%m-%d %H:%M:%S'` [INFO] $_p_log_out" >> $LOG_FILE
  else
    echo "`date '+%Y-%m-%d %H:%M:%S'` [INFO] $_p_log_out"
  fi
}
function logWarn(){
  if [[ -n "${LOG_FILE}" ]]; then
    echo "`date '+%Y-%m-%d %H:%M:%S'` [WARN] $_p_log_out" >> $LOG_FILE
  else
    echo "`date '+%Y-%m-%d %H:%M:%S'` [WARN] $_p_log_out"
  fi
}
function logError(){
  if [[ -n "${LOG_FILE}" ]]; then
    echo "`date '+%Y-%m-%d %H:%M:%S'` [ERROR] $_p_log_out" >> $LOG_FILE
  else
    echo "`date '+%Y-%m-%d %H:%M:%S'` [ERROR] $_p_log_out"
  fi
}

# 减小日志大小
# 仅在凌晨1点这一个小时进行操作
function tinyLogFile(){
  _p_hour=`date '+%H'`
  if [[ ${_p_hour} == 1 ]]; then
      if [[ -n "${LOG_FILE}" ]]; then
        if [[ -n "${LOG_FILE_KEEP_LINES}" ]]; then
            _p_lines=`cat $LOG_FILE | wc -l`
            _p_log_out="log file lines : ${_p_lines}"
            logInfo
            if [[ ${_p_lines} -gt $LOG_FILE_KEEP_LINES ]]; then
                _p_del_lines=`expr $_p_lines - $LOG_FILE_KEEP_LINES`
                _p_log_out="del log file lines : ${_p_del_lines}"
                logInfo
                _p_sed_cmd="sed -i '1,${_p_del_lines}d' $LOG_FILE"
                nohup bash -c "$_p_sed_cmd" 2>&1 &
            fi
        fi
      fi
  fi
}

# 保活失败，发送告警邮件
function alarmFailKeepAlived(){
    _p_log_out="################# alarm #######################"
    logInfo

    if [[ -z "${SERVER_NAME}" ]]; then
        SERVER_NAME=`hostname`
    fi

    ThisName=`basename $0`
    TimeNow=$(date "+%Y-%m-%d %H:%M:%S")

    PsResult=
    if [[ -n "${VERIFY_PROCESS_NAME}" ]]; then
        PsResult=`ps -ef | grep -v grep| grep -v $ThisName | grep ${VERIFY_PROCESS_NAME} | head -n 12`
    else
        PsResult=`ps -ef | grep -v grep| grep -v $ThisName | head -n 12`
    fi
    TopResult=`top -c -b -n 1 | head -n 12`
    FreeResult=`free -h`
    DfResult=`df -h`
    IostatResult=`iostat -dmx`
    PingResult=`ping www.baidu.com -c 3`
    WhoResult=`who -ablu`
    WResult=`w -ui`
    for item in `echo ${ALARM_MAIL_TO}`
    do
      _p_log_out="alarm mail to [${item}] ..."
      logInfo

      echo -e "\
your application $ALARM_APP_NAME on $SERVER_NAME has died at $TimeNow, please check it!

ps output is:
------------------------------------------------------------------
$PsResult

top output is:
------------------------------------------------------------------
$TopResult

free output is:
------------------------------------------------------------------
$FreeResult

df output is:
------------------------------------------------------------------
$DfResult

iostat output is:
------------------------------------------------------------------
$IostatResult

ping output is:
------------------------------------------------------------------
$PingResult

who output is:
------------------------------------------------------------------
$WhoResult

w output is:
------------------------------------------------------------------
$WResult
" | mail -s "[Alarm] host $SERVER_NAME app $ALARM_APP_NAME process died" $item

    done
}

function keepalivedMain(){
    # 进入工作路径
    if [[ -n "${WORK_DIR}" ]]; then
      cd "${WORK_DIR}"
    fi

    _p_log_out="-------------- keepalived -------------------"
    logInfo

    # 减少日志文件大小
    tinyLogFile

    _p_last_count=`expr ${FAIL_MAX_COUNT} - 1`
    # 开始循环检测
    CURR_FAIL_COUNT=0
    for ((i=0;i<$FAIL_MAX_COUNT;i++))
    do
      CHK_RESULT=$BOOL_TRUE

      # 是否最后一次检测
      _p_last_once=$BOOL_FALSE
      if [ $i == $_p_last_count ];then
        _p_last_once=$BOOL_TRUE
      fi

      # 判断端口是否占用
      if [[ -n "${VERIFY_PORT}" ]]; then
        if [ $CHK_RESULT == $BOOL_TRUE ];then
           _p_log_out="verify pid by port [${VERIFY_PORT}] ..."
           logInfo
           cleanFuncParams
           _func_arg1=$VERIFY_PORT
           findPidByPort
           _p_log_out="verify pid by port : ${_func_ret}"
           logInfo
           if [[ -z "${_func_ret}" ]]; then
              _p_log_out="verify pid by port failure."
              logWarn
              CHK_RESULT=$BOOL_FALSE
           fi
        fi
      fi

      # 判断进程名称是否存活
      if [[ -n "${VERIFY_PROCESS_NAME}" ]]; then
        if [ $CHK_RESULT == $BOOL_TRUE ];then
           _p_log_out="verify pid by process name [${VERIFY_PROCESS_NAME}] ..."
           logInfo
           cleanFuncParams
           _func_arg1=$VERIFY_PROCESS_NAME
           findPidByName
           _p_log_out="verify pid by process name : ${_func_ret}"
           logInfo
           if [[ -z "${_func_ret}" ]]; then
              _p_log_out="verify pid by process name failure."
              logWarn
              CHK_RESULT=$BOOL_FALSE
           fi
        fi
      fi

      # 判断进程PID文件的进程是否存活
      if [[ -n "${VERIFY_PID_FILE}" ]]; then
        if [ $CHK_RESULT == $BOOL_TRUE ];then
           _p_log_out="verify pid by pid file [${VERIFY_PID_FILE}] ..."
           logInfo
           cleanFuncParams
           _func_arg1=$VERIFY_PID_FILE
           findPidByPidFile
           _p_log_out="verify pid by pid file : ${_func_ret}"
           logInfo
           if [[ -z "${_func_ret}" ]]; then
              _p_log_out="verify pid by pid file failure."
              logWarn
              CHK_RESULT=$BOOL_FALSE
           fi
        fi
      fi

      # 判断进程PID是否存活
      if [[ -n "${VERIFY_PID}" ]]; then
        if [ $CHK_RESULT == $BOOL_TRUE ];then
           _p_log_out="verify pid by pid [${VERIFY_PID}] ..."
           logInfo
           cleanFuncParams
           _func_arg1=$VERIFY_PID
           findPidByPid
           _p_log_out="verify pid by pid : ${_func_ret}"
           logInfo
           if [[ -z "${_func_ret}" ]]; then
               _p_log_out="verify pid by pid failure."
               logWarn
              CHK_RESULT=$BOOL_FALSE
           fi
        fi
      fi

      # 判断HTTP链接是否可以连通
      if [[ -n "${VERIFY_HTTP_URL}" ]]; then
        if [ $CHK_RESULT == $BOOL_TRUE ];then
           _p_log_out="verify http link status [${VERIFY_HTTP_URL}] ..."
           logInfo
           cleanFuncParams
           _func_arg1=$VERIFY_HTTP_URL
           findHttpCodeByUrl
           _p_log_out="verify http link status : ${_func_ret}"
           logInfo
           if [[ "${_func_ret}" == "000" ]]; then
              _p_log_out="verify http link status failure."
              logWarn
              CHK_RESULT=$BOOL_FALSE
           fi
        fi
      fi

      # 判断Sock是否可以连通
      if [[ -n "${VERIFY_SOCK_HOST}" ]]; then
          if [[ -n "${VERIFY_SOCK_PORT}" ]]; then
            if [ $CHK_RESULT == $BOOL_TRUE ];then
               _p_log_out="verify sock connection status [${VERIFY_SOCK_HOST} ${VERIFY_SOCK_PORT}] ..."
               logInfo
               cleanFuncParams
               _func_arg1=$VERIFY_SOCK_HOST
               _func_arg2=$VERIFY_SOCK_PORT
               findCountByHostPort
               _p_log_out="verify sock connection status : ${_func_ret}"
               logInfo
               if [[ "${_func_ret}" == "0" ]]; then
                  _p_log_out="verify sock connection status failure."
                  logWarn
                  CHK_RESULT=$BOOL_FALSE
               fi
            fi
          fi
      fi

      # 判断主机是否可以连通
      if [[ -n "${VERIFY_HOST}" ]]; then
        if [ $CHK_RESULT == $BOOL_TRUE ];then
           _p_log_out="verify host connection status [${VERIFY_HOST}] ..."
           logInfo
           cleanFuncParams
           _func_arg1=$VERIFY_HOST
           findLostRateByHost
           _p_log_out="verify host connection status : ${_func_ret}"
           logInfo
           if [[ -z "${_func_ret}" ]]; then
              _p_log_out="verify host connection status failure."
              logWarn
              CHK_RESULT=$BOOL_FALSE
           elif [[ ${_func_ret} -ge 50 ]]; then
              _p_log_out="verify host connection status failure."
              logWarn
              CHK_RESULT=$BOOL_FALSE
           fi
        fi
      fi

      # 如果检测通过，则退出
      if [ $CHK_RESULT == $BOOL_TRUE ];then
           _p_log_out="verify success."
           logInfo
           exit 0
      fi

      # 检测失败，则尝试重新启动
      if [ $CHK_RESULT == $BOOL_FALSE ];then
        CURR_FAIL_COUNT=`expr ${CURR_FAIL_COUNT} + 1`
        _p_log_out="verify failure,retry count ${CURR_FAIL_COUNT} ..."
        logWarn
        _p_kill_flag=$BOOL_FALSE
       if [ $_p_last_once == $BOOL_TRUE ];then
           if [[ -n "${BASH_KILL}" ]]; then
             _p_log_out="kill shell exec ..."
             logInfo
             if [[ -n "${LOG_FILE}" ]]; then
                 nohup bash -c "$BASH_KILL" 2>&1 >> $LOG_FILE &
             else
                 nohup bash -c "$BASH_KILL" 2>&1 &
             fi
             _p_kill_flag=$BOOL_TRUE
             sleep $STOP_SLEEP
          fi
        fi
        if [ $_p_kill_flag == $BOOL_FALSE ];then
          if [[ -n "${BASH_STOP}" ]]; then
              _p_log_out="stop shell exec ..."
              logInfo
              if [[ -n "${LOG_FILE}" ]]; then
                  nohup bash -c "$BASH_STOP" 2>&1 >> $LOG_FILE &
              else
                  nohup bash -c "$BASH_STOP" 2>&1 &
              fi
              sleep $STOP_SLEEP
          fi
        fi
        _p_log_out="start shell exec ..."
        logInfo
        if [[ -n "${LOG_FILE}" ]]; then
            nohup bash -c "$BASH_START" 2>&1 >> $LOG_FILE &
        else
            nohup bash -c "$BASH_START" 2>&1 &
        fi
        _p_log_out="wait for next check ..."
        logInfo
        sleep $FAIL_SLEEP
      fi
    done

    # 如果程序走到这里，说明保活失败了
    if [ $CURR_FAIL_COUNT == $FAIL_MAX_COUNT ];then
      _p_log_out="verify failure, alarm sending ..."
      logError
      alarmFailKeepAlived
      _p_log_out="verify failure."
      logError
      exit 0
    fi
}

# 进入主程序
keepalivedMain
