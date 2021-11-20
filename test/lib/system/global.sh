
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
# author: liujinsuozn8
#---------------------------------------

source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh

test(){
    echo 'this is test'
}

# 外部可以不使用 var，
# 直接声明: a=1234
global a=1234
try {
  echo "a1=$a" #a1=1234
  a=5678

  try {
    echo "a2=$a" #a2=5678
    a=910
  } catch {
    printStackTrace "$___EXCEPTION___"
  }

  global testStr="$(test)"
} catch {
  printStackTrace "$___EXCEPTION___"
}
echo $a #910
echo $testStr #this is tetst