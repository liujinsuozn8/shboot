
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
# author: liujinsuozn8
#---------------------------------------

# use global in try...catch
source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh

test(){
    echo 'this is test'
}

# 外部可以不使用 var，
# 直接声明: a=1234
try {
  try {
    global testStr="this is test str"
    global a=123
  } catch {
    printStackTrace "$___EXCEPTION___"
  }

  echo $testStr #this is test str
  echo $a #123
  testStr='this is test str2'
  a=456
} catch {
  printStackTrace "$___EXCEPTION___"
}
echo $testStr #this is test str2
echo $a #456