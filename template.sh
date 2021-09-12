#!/bin/bash

#----------------------------
# Copyright (c) 2021 liujinsuozn8
#
# https://github.com/liujinsuozn8/shboot
#
# LICENSE: MIT License
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

#---------------------
# main
#---------------------
source "$(cd `dirname $0`; pwd)/lib/boot.sh"

# log
import log/log

Log::DEBUG 'aaa'

Log::INFO 'bbb'

Log::WARN 'ccc'

Log::ERROR 'ddd'

Log::FATAL 'eee'

# try...catch
test(){
  try { 
    # throw 'throw test1'
    return 10
    # ddd
  } catch {
    echo xxx
    printStackTrace "$___EXCEPTION___"
    return 3
  }
}

test
echo "result=$?"

try { 
  try {
    throw 'throw test2'
  } catch {
    throw 'abcd'
    # echo 1234
  }
} catch {
  printStackTrace "$___EXCEPTION___"
}


throw 'out throw'
echo "not print"