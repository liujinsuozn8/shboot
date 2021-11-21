#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
# author: liujinsuozn8
#---------------------------------------
source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh

try {
  echo 111
  exit 255
  echo 222
} catch {
  # echo 'catch'
  printStackTrace "$___EXCEPTION___"
}
echo 333