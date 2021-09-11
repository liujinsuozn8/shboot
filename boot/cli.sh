#!/bin/bash

source "$(cd `dirname $0`; pwd)/../lib/boot.sh"
import cli/base
import string/base

flow(){
  local input="$1"
  if String::StartsWith "$input" 'import '; then
    eval "$input"
    echo "imported"
  else
    eval "$input"
  fi
}

CLI::StartWithHandlerFunction 'shboot-CLI' flow