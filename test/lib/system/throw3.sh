#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------
source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh
test(){
  test1
}
test1(){
  exit 255
}

try {
  echo 111
  test
  echo 222
} catch {
  # echo 'catch'
  printStackTrace "$___EXCEPTION___"
}
echo 333