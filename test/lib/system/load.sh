
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
# author: liujinsuozn8
#---------------------------------------

source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh

echo "SHBOOT_ROOT=$SHBOOT_ROOT"
echo "SHBOOT_PID=$SHBOOT_PID"
echo "START_SHEEL_DIR=$START_SHEEL_DIR"
echo "START_SHEEL_PATH=$START_SHEEL_PATH"