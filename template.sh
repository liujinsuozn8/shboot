#!/bin/bash

#----------------------------
# Copyright (c) 2021 liujinsuozn8
#
# https://github.com/liujinsuozn8/shboot
#----------------------------

#---------------------
# usage
#---------------------
usage()
{
    cat << USAGE >&1
Usage:
    <xxx>.sh

Options:

Exit Code:
    0   normal end
USAGE
}

#----------------------------
# static paramter
#----------------------------
SHELL_EXEC_DIR=$(pwd)

#----------------------------
# import
#----------------------------
. ./bin/logger.sh

#----------------------------
# function
#----------------------------

#----------------------------
# param
#----------------------------
# 1. param define
# 2. param analyze
while [ $# -gt 0 ];do
    case "$1" in
        --help)
            usage
            exit 0
        ;;
        *)
            echoerr "$1 can not analyze !!! please get help by [ --help ]"
            errend
        ;;
    esac
    shift 2
done

loginfo "$SHELL_EXEC_DIR"
logerr "$SHELL_EXEC_DIR"


#----------------------------
# main
#----------------------------
# 1. process1
# 2. process2
# .....
# n. processn