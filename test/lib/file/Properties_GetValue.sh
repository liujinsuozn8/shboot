#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh
import file/properties

# 1. 能够搜索到，返回字符串
v=$(Properties::GetValue './resources/log.properties' 'appender.RF')
echo $v
# RollingFile

# 2. 不能搜索到，返回空字符
v=$(Properties::GetValue './resources/log.properties' 'xxxxxx')
echo $v
# 显示空