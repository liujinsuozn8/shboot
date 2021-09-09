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

#---------------------
# main
#---------------------
source "$(cd `dirname $0`; pwd)/lib/boot.sh"

import log/load/autoload

Log::DEBUG 'aaa'

Log::INFO 'bbb'

Log::WARN 'ccc'

Log::ERROR 'ddd'

Log::FATAL 'eee'