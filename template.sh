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
# static paramter & init
#----------------------------
SHELL_EXEC_DIR=$(pwd)
LOG_DATE="on"

#----------------------------
# import
#----------------------------
. ./bin/logger.sh

#----------------------------
# public paramter
#----------------------------

#----------------------------
# function
#----------------------------

#----------------------------
# main
#----------------------------

# param analyze
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
# memos
#----------------------------
# IFS=$(echo -en "\n\b")
# : $((n = $n + 1))
# echo $((n = $n + 1))
# for line in ${xxx[@]};do
# for (( i=0; i<${count}; i++));do