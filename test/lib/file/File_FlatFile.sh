#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh
import file/base

a=$(File::FlatFile "$START_SHEEL_DIR/File_FlatFile_Test.txt" ',')
echo $a