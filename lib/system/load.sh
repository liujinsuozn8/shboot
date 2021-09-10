
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

export PROJECT_ROOT=$( cd ${BASH_SOURCE[0]%/*}/../.. && pwd )
export PROJECT_PID="$$"

source "${PROJECT_ROOT}/lib/system/env/env.sh"
source "${PROJECT_ROOT}/lib/system/builtin/path.sh"
source "${PROJECT_ROOT}/lib/system/builtin/array.sh"
source "${PROJECT_ROOT}/lib/system/exception/exception.sh"

# Load import function to environment
source "${PROJECT_ROOT}/lib/system/import/import.sh"