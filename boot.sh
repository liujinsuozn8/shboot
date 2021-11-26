
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------
# Avoid importing in subshell
if [ "$__boot__started" == true ]; then
  return 0
fi

export __boot__started=true

# Load system
source "$( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/lib/system/load.sh"
import log/logger/console