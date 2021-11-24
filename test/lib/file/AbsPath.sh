#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh
import file/base

# echo $(File::AbsPath ./../system/addtrap.sh)
File::AbsPath /system/addtrap.sh
File::AbsPath ./../system/addtrap.sh
File::AbsPath system/addtrap.sh