#!/bin/bash

# ##################################################################################################################
# 常量定义区
# ##################################################################################################################
BOOL_TRUE=1
BOOL_FALSE=0
# ##################################################################################################################

# 菜单选项
Option=$1

# 应用名称，用于表示应用名称，仅显示使用
APP_NAME=grafana

# 进程名称，用于ps查找进程的关键字
PROCESS_NAME=grafana-server
# 进程绑定的端口，用于netstat查找进程
BIND_PORT=9200

# 工作路径，脚本开始运行时候，将会先cd进入此路径
WORK_DIR=

# 启动与停止命令
# 安装路径
export GRAFANA_HOME=`realpath ../`
# WEB端口
export GF_SERVER_HTTP_PORT=$BIND_PORT
#定义用户，我最开始使用grafana，不知道哪个文件授权有问题导致服务没法启动
export GRAFANA_USER=root
#定义组
export GRAFANA_GROUP=root
#grafana的日志文件，最好自己手动建好
export GF_PATHS_LOGS=logs
#grafana的数据存储路径，最好自己手动建好
export GF_PATHS_DATA=data
#grafana的组件目录，自己手动建好
export GF_PATHS_PLUGINS=plugins
#grafana的provisioning的路径，tar包解压出来就有
export GF_PATHS_PROVISIONING=conf/provisioning

CONFIG_FILE=$GRAFANA_HOME/conf/defaults.ini
START_CMD="./grafana-server --config=$CONFIG_FILE --homepath=$GRAFANA_HOME --pidfile=metas/pid.grafana-server"
STOP_CMD=

# 是否使用nohup后台运行启动命令
ENABLE_NOHUP=$BOOL_TRUE

# 是否具有专门的停止命令
ENABLE_STOP_CMD=$BOOL_FALSE

# 在执行启动或者停止命令之前执行的内容
function beforeStart(){
  echo grafana started on web : http://localhost:$BIND_PORT/
  echo "starting ..."
}

function beforeStop(){
  echo "stopping .."
}

# 是否使用CALL函数
ENABLE_START_CALL=$BOOL_FALSE
ENABLE_STOP_CALL=$BOOL_FALSE

# 启动命令复杂时，可使用函数
function startCall() {
  echo 'start shell ...'
}

# 停止命令复杂时，可使用函数
function stopCall() {
  echo 'stop shell ...'
}

# 查询日志的最后多少行
TAIL_LOG_LINES=2000

# ###################################################################################################################

# 元数据信息路径，一般不需要修改
META_DIR=metas
LOG_DIR=logs

# 以下配置，将在运行时，根据实际情况变更，不是此处的值
PID_FILE=$META_DIR/pid.${APP_NAME}.txt
BOOT_META_FILE=$META_DIR/meta.${APP_NAME}.txt
LOG_FILE=$LOG_DIR/${APP_NAME}.log


# ###################################################################################################################
# 内部函数定义区
# ##################################################################################################################

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


# 根据端口号查询进程号
# 入参：端口号
# 返回值：PID
function findPidByPort() {
  _p_port=$_func_arg1
  _func_ret=

  _p_pid=`netstat -nlp | grep -v grep | grep :${_p_port} | awk '{print $7}' | awk -F '[ / ]' '{print $1}'`
  _func_ret=$_p_pid
}

# 根据进程名，查找进程号
# 入参：jar文件名
# 返回值：PID
function findPidByProcessName() {
  _p_process_name=$_func_arg1
  _func_ret=

  _p_pid=`ps -ef | grep -v grep | grep ${_p_process_name} | awk '{print $2}'`
  _func_ret=$_p_pid
}

# 根据进程名，查找进程号
# 入参：jar文件名
# 返回值：PID
function findPidByPidFile() {
  _p_pid_file=$_func_arg1
  _func_ret=

  _p_pid=$(cat ${_p_pid_file})
  _func_ret=$_p_pid
}

# 验证指定的进程号是否在运行
# 入参：pid
# 返回值：定义的BOOL值
function verifyPidIsRunning() {
  _p_pid=$_func_arg1
  _func_ret=$BOOL_FALSE

  for _p_item in $(ps -ef | grep -v grep | awk '{print $2}' | xargs echo)
  do
    if [ x"$_p_item" == x"$_p_pid" ]; then
       _func_ret=$BOOL_TRUE
       break
    fi
  done
}

# 根据PID_FILE,APP_PORT,PROCESS_NAME，查找进程号
function getPid() {
    _p_pid_file=$_func_arg1
    _p_port=$_func_arg2
    _p_proces_name=$_func_arg3

    _p_pid=

    # 从PID文件查找PID
    if [[ -n "${_p_pid_file}" ]]; then
      _p_pid=$(cat ${_p_pid_file})
      echo -e "\033[0;34m pid file \033[0m  find pid= \033[0;34m $_p_pid \033[0m "
    fi

    # 检查PID是正在运行，在运行则退出
    if [[ -n "${_p_pid}" ]]; then
      cleanFuncParams
      _func_arg1=$_p_pid
      _func_ret=$BOOL_FALSE
      verifyPidIsRunning
      _p_running=$_func_ret
      if [ $_p_running == $BOOL_TRUE ];then
        _func_ret=$_p_pid
        return
      fi
    fi

    _p_pid=

    # 如果指定了端口
    # 根据端口查找PID
    if [[ -n "${_p_port}" ]]; then
      cleanFuncParams
      _func_arg1=$_p_port
      _func_ret=
      findPidByPort
      _p_pid=$_func_ret
      echo -e "\033[0;34m port \033[0m find pid= \033[0;34m $_p_pid \033[0m"
    fi

    # 检查PID是正在运行，在运行则退出
    if [[ -n "${_p_pid}" ]]; then
      cleanFuncParams
      _func_arg1=$_p_pid
      _func_ret=$BOOL_FALSE
      verifyPidIsRunning
      _p_running=$_func_ret
      if [ $_p_running == $BOOL_TRUE ];then
        _func_ret=$_p_pid
        return
      fi
    fi

    _p_pid=

    # 如果还是没有PID，则直接使用进程名称查找PID
    # 根据端口查找PID
    if [[ -n "${_p_proces_name}" ]]; then
        cleanFuncParams
        _func_arg1=$_p_proces_name
        _func_ret=
        findPidByProcessName
        _p_pid=$_func_ret
        echo -e "\033[0;34m process name \033[0m find pid= \033[0;34m $_p_pid \033[0m"
    fi

    # 检查PID是正在运行，在运行则退出
    if [[ -n "${_p_pid}" ]]; then
      cleanFuncParams
      _func_arg1=$_p_pid
      _func_ret=$BOOL_FALSE
      verifyPidIsRunning
      _p_running=$_func_ret
      if [ $_p_running == $BOOL_TRUE ];then
        _func_ret=$_p_pid
        return
      fi
    fi

    _func_ret=
}

# # ##################################################################################################################
# 脚本功能区
# ##################################################################################################################

# 打印帮助信息
function help()
{
    echo -e "\033[0;31m please input 1st arg:Option \033[0m"
    echo -e "    options: \033[0;34m {start|stop|restart|status|log} \033[0m"
    echo -e "\033[0;34m start    \033[0m : to run process $APP_NAME"
    echo -e "\033[0;34m stop     \033[0m : to stop process $APP_NAME"
    echo -e "\033[0;34m restart  \033[0m : to stop and run process $APP_NAME"
    echo -e "\033[0;34m status   \033[0m : to check run status for process $APP_NAME"
    echo -e "\033[0;34m log      \033[0m : to lookup the log for process $APP_NAME"

    exit 1
}


# 启动进程
function start() {
  mkdir -p $META_DIR
  mkdir -p $LOG_DIR

  if [ ! -d ${PID_FILE} ]; then
    echo "not pid file,create..."
    touch ${PID_FILE}
  fi

  cleanFuncParams
  _func_arg1=$PID_FILE
  _func_arg2=$BIND_PORT
  _func_arg3=$PROCESS_NAME
  getPid
  _p_pid=$_func_ret

  if [[ -n "$_p_pid" ]]; then
      echo -e "\033[0;31m process has running ... \033[0m"
      return
  fi

  _p_now=$(date "+%Y-%m-%d %H:%M:%S")

  echo -e "\033[0;34m APP_NAME  \033[0m : $APP_NAME"
  echo -e "\033[0;34m PROCESS_NAME   \033[0m : $PROCESS_NAME"
  echo -e "\033[0;34m BIND_PORT   \033[0m : $BIND_PORT"
  echo -e "\033[0;34m PID_FILE   \033[0m : $PID_FILE"
  echo -e "\033[0;34m START_TIME \033[0m : $_p_now"

  echo "" > $PID_FILE

  beforeStart

  _p_called=$BOOL_FALSE
  if [ $_p_called == $BOOL_FALSE ];then
    if [ $ENABLE_START_CALL == $BOOL_TRUE ];then
        _p_called=$BOOL_TRUE
        startCall
        echo -e "\033[0;34m call \033[0m start ..."
    fi
  fi

  if [ $_p_called == $BOOL_FALSE ];then
    if [ $ENABLE_NOHUP == $BOOL_TRUE ];then
      _p_called=$BOOL_TRUE
      nohup $START_CMD > $LOG_FILE 2>&1 & echo $! > $PID_FILE
      echo -e "\033[0;34m nohup \033[0m start ..."
    fi
  fi

  if [ $_p_called == $BOOL_FALSE ];then
      _p_called=$BOOL_TRUE
      $START_CMD
      echo -e "\033[0;34m direct \033[0m start ..."
  fi

  echo "USER       : $(who)" > $BOOT_META_FILE
  echo "START_TIME : $_p_now" >> $BOOT_META_FILE

  chmod a+r $LOG_DIR/*.log
  chmod a+r $META_DIR/*.txt

  _p_pid=`cat $PID_FILE`
  echo -e "start \033[0;34m $APP_NAME \033[0m success on pid \033[0;34m $_p_pid \033[0m ..."
}


# 停止进程
function stop() {

    cleanFuncParams
    _func_arg1=$PID_FILE
    _func_arg2=$BIND_PORT
    _func_arg3=$PROCESS_NAME
    getPid
    _p_pid=$_func_ret

   if [ "$_p_pid" = "" ];then
      echo -e "\033[0;31m not pid found, app already stopped. \033[0m"
      return
    fi

    beforeStop

    _p_called=$BOOL_FALSE
    if [ $_p_called == $BOOL_FALSE ];then
      if [ $ENABLE_STOP_CALL == $BOOL_TRUE ];then
          _p_called=$BOOL_TRUE
          stopCall
          echo -e "\033[0;34m call \033[0m stop ."
      fi
    fi

    if [ $_p_called == $BOOL_FALSE ];then
      if [ $ENABLE_STOP_CMD == $BOOL_TRUE ];then
        _p_called=$BOOL_TRUE
        $STOP_CMD
        echo -e "\033[0;34m cmd \033[0m stop ."
      fi
    fi

    if [ $_p_called == $BOOL_FALSE ];then
        _p_called=$BOOL_TRUE
        kill -5 $_p_pid
        echo -e "\033[0;34m kill pid is $_p_pid \033[0m ."
    fi

    sleep 2

    cleanFuncParams
    _func_arg1=$PID_FILE
    _func_arg2=$BIND_PORT
    _func_arg3=$PROCESS_NAME
    getPid
    _p_pid=$_func_ret

    if [[ -n "$_p_pid" ]]; then
        _p_called=$BOOL_TRUE
        echo -e "force kill pid is: \033[0;34m $_p_pid \033[0m"
        kill -9 $_p_pid
        echo "" > $PID_FILE
    fi
}

# 重启进程
function restart() {
    stop
    sleep 3
    start
}

# 查看应用状态
function status() {
    cleanFuncParams
    _func_arg1=$PID_FILE
    _func_arg2=$BIND_PORT
    _func_arg3=$PROCESS_NAME
    getPid
    _p_pid=$_func_ret

    if [[ -n "$_p_pid" ]]; then
        echo -e "app is \033[0;34m running \033[0m on pid: \033[0;34m $_p_pid \033[0m"
    else
      echo -e "app was \033[0;31m stopped \033[0m ."
    fi
}


function findLogFile() {
      _func_ret=

      _p_log_file=`ls -t ${LOG_DIR} | grep .log | grep -v grep | grep ${APP_NAME} | head -n 1`
      if [[ "${_p_log_file}" = "" ]]; then
        echo -e "\033[0;31m not found ${APP_NAME}*.log , try find most newest log file... \033[0m"
        _p_log_file=`ls -t ${LOG_DIR} | grep .log | grep -v grep | head -n 1`
      fi

      _func_ret=$_p_log_file
}

# 查看应用日志
function log() {
    cleanFuncParams
    findLogFile
    _p_log_file=$_func_ret

    if [[ -n "$_p_log_file" ]]; then
        echo -e "\033[0;34m found log file ${LOG_DIR}/$_p_log_file \033[0m"
        tail -f -n $TAIL_LOG_LINES ${LOG_DIR}/$_p_log_file
    else
      echo -e "\033[0;31m not found log file like ${APP_NAME}*.log. \033[0m"
    fi
}


# ##################################################################################################################
# 脚本正式处理逻辑
# ##################################################################################################################

# 准备运行的上下文
function prepareContext(){

      # 如果依旧没有jar文件，则失败退出
      if [ "$APP_NAME" = "" ];
      then
          echo -e "\033[0;31m please setting APP_NAME \033[0m"
          exit 1
      fi

      if [[ -n "$WORK_DIR" ]]; then
        cd $WORK_DIR
      fi

      # 初始化工作路径以及相关的路径
      WORK_DIR=`pwd`

      META_DIR=${WORK_DIR}/${META_DIR}
      LOG_DIR=${WORK_DIR}/${LOG_DIR}

      PID_FILE=${META_DIR}/pid.${APP_NAME}.txt
      BOOT_META_FILE=$META_DIR/meta.${APP_NAME}.txt
      LOG_FILE=${LOG_DIR}/${APP_NAME}.log

      cleanFuncParams
      findLogFile
      _p_log_file=$_func_ret

      if [[ -n "$_p_log_file" ]]; then
        LOG_FILE=${LOG_DIR}/$_p_log_file
      fi
}

# 打印运行上下文
function printContext(){
      # 打印基本配置信息
      echo "-----------------------"
      echo -e "\033[0;34m AppName     \033[0m : $APP_NAME"
      echo -e "\033[0;34m Option      \033[0m : $Option"
      echo -e "\033[0;34m WorkDir     \033[0m : $WORK_DIR"
      echo -e "\033[0;34m LogDir      \033[0m : $LOG_DIR"
      echo -e "\033[0;34m LogFile     \033[0m : $LOG_FILE"
      echo -e "\033[0;34m PidFile     \033[0m : $PID_FILE"
      echo -e "\033[0;34m BootFile    \033[0m : $BOOT_META_FILE"
      echo "-----------------------"
}



# ##################################################################################################################
# 函数分配区
# ##################################################################################################################

function mainApp(){
  # 如果没有指定选项，给出帮助并退出
  if [ "$Option" = "" ]; then
      help
      exit 1
  fi

  prepareContext
  printContext

  case $Option in
    start)
    start;;
    stop)
    stop;;
    restart)
    restart;;
    status)
    status;;
    log)
    log;;
    *)
    help;;
  esac
}

mainApp
