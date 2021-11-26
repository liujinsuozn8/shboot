
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------
export SHBOOT_ROOT=$( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}")/../..; pwd )
export SHBOOT_PID="$$"

# add path method
source "${SHBOOT_ROOT}/lib/system/builtin/path.sh"
source "${SHBOOT_ROOT}/lib/system/builtin/array.sh"

START_SHEEL_PATH="${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}"
export START_SHEEL_DIR=$( cd $(Builtin::Dirname "$START_SHEEL_PATH"); pwd )
export START_SHEEL_PATH="${START_SHEEL_DIR}/$(Builtin::Basename "$START_SHEEL_PATH")"


source "${SHBOOT_ROOT}/lib/system/builtin/method.sh"
source "${SHBOOT_ROOT}/lib/system/env/env.sh"

source "${SHBOOT_ROOT}/lib/system/cache/process.sh"
source "${SHBOOT_ROOT}/lib/system/keyword/import.sh"
source "${SHBOOT_ROOT}/lib/system/keyword/global.sh"
source "${SHBOOT_ROOT}/lib/system/keyword/exception.sh"

