#!/bin/bash

#----------------------------
# Copyright (c) 2021 liujinsuozn8
#
# https://github.com/liujinsuozn8/shboot
#----------------------------

#----------------------------
# Usage:
#   1. evn setting of logger.sh
#       LOG_FILE="....."
#   2. import logger.sh
#       . ./bin/logger.sh
#
# Setting:
#   NO setting  :"yyyy-mm-dd HH:MM:SS [xxxxxx]:...."
#   LOG_FILE    :"yyyy-mm-dd HH:MM:SS [xxxxxx]:...." >> <filepath>
#
# Available Function:
#   loginfo
#   logerr
#   logwarn
#   errend
#----------------------------

#----------------------------
# import check
#----------------------------
if [ -n "$___MODULE_BIN_LOGGER___" ];then
    return
fi

___MODULE_BIN_LOGGER___='bin/logger.sh'

#----------------------------
# import other
#----------------------------
# none

#----------------------------
# main-function
#----------------------------
if [ -n "$LOG_FILE" ];then
    # 1. LOG_DATE + LOG_FILE
    loginfo(){
        echo "`date +'%Y-%m-%d %H:%M:%S'` [ INFO ]:$@" >> ___LOG_FILE___
    }

    logerr(){
        echo "`date +'%Y-%m-%d %H:%M:%S'` [ERROR ]:$@" >> ___LOG_FILE___
    }

    logwarn(){
        echo "`date +'%Y-%m-%d %H:%M:%S'` [WARING]:$@" >> ___LOG_FILE___
    }
else
    # 2. LOG_DATE
    loginfo(){
        echo "`date +'%Y-%m-%d %H:%M:%S'` [ INFO ]:$@"
    }

    logerr(){
        echo "`date +'%Y-%m-%d %H:%M:%S'` [ERROR ]:$@" 1>&2
    }

    logwarn(){
        echo "`date +'%Y-%m-%d %H:%M:%S'` [WARING]:$@"
    }
fi

# $1 exit code
errend(){
    logerr "shell end, exit code: $1"
    exit $1
}