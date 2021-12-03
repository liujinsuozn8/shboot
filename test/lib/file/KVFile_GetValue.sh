#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh
import file/kvfile

# 1. 能够搜索到，返回字符串
v=$(KVFile::GetValue './resources/log.conf' 'appender.RF')
echo $v
# RollingFile

# 2. 不能搜索到，返回空字符
v=$(KVFile::GetValue './resources/log.conf' 'xxxxxx')
echo $v
# 显示空