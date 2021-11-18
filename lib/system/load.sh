
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------
# Avoid importing in subshell
if [ "$__boot__started" == true ]; then
  return 0
fi
export __boot__started=true

START_SHEEL_PATH="${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}"
export START_SHEEL_DIR=$( cd "${START_SHEEL_PATH%/*}" && pwd )
export START_SHEEL_PATH="${START_SHEEL_DIR}/${START_SHEEL_PATH##*/}"
export SHBOOT_ROOT=$( cd ${BASH_SOURCE[0]%/*}/../.. && pwd )
export SHBOOT_PID="$$"

source "${SHBOOT_ROOT}/lib/system/builtin/path.sh"
source "${SHBOOT_ROOT}/lib/system/builtin/array.sh"
# Load import function to environment
source "${SHBOOT_ROOT}/lib/system/import/import.sh"
source "${SHBOOT_ROOT}/lib/system/builtin/method.sh"
source "${SHBOOT_ROOT}/lib/system/env/env.sh"

source "${SHBOOT_ROOT}/lib/system/cache/process.sh"
source "${SHBOOT_ROOT}/lib/system/keyword/global.sh"
source "${SHBOOT_ROOT}/lib/system/keyword/exception.sh"

