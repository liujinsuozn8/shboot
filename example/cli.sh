#!/bin/bash

#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

source "$(cd `dirname $0`; pwd)/../lib/boot.sh"
import cli/base
import string/base

# handle import error
trap '' TERM

flow(){
  local input="$1"
  if String::StartsWith "$input" 'import '; then
    eval "$input"
  else
    eval "$input"
  fi
}

CLI::StartWithHandlerFunction 'shboot-CLI' flow