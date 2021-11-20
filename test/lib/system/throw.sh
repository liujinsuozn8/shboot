#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
# author: liujinsuozn8
#---------------------------------------
source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh

try {
  throw 'error--1'
} catch {
  # echo 'catch'
  printStackTrace "$___EXCEPTION___"
}
echo 001

throw 'error--2'

echo 002

# error--1
# 001
# error--2
