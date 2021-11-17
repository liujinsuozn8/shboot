
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------
# Avoid importing in subshell
if [ "$__boot__started" == true ]; then
  return 0
fi

START_SHEEL_DIR="${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}"
START_SHEEL_DIR="${START_SHEEL_DIR%/*}"
export START_SHEEL_DIR
export SHBOOT_ROOT=$( cd ${BASH_SOURCE[0]%/*}/../.. && pwd )
export SHBOOT_PID="$$"

source "${SHBOOT_ROOT}/lib/system/builtin/path.sh"
source "${SHBOOT_ROOT}/lib/system/builtin/array.sh"
# Load import function to environment
source "${SHBOOT_ROOT}/lib/system/import/import.sh"

source "${SHBOOT_ROOT}/lib/system/cache/process.sh"
source "${SHBOOT_ROOT}/lib/system/env/env.sh"
source "${SHBOOT_ROOT}/lib/system/global/global.sh"
source "${SHBOOT_ROOT}/lib/system/exception/exception.sh"

export __boot__started=true