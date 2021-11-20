#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
# author: liujinsuozn8
#---------------------------------------

# source $(cd ${BASH_SOURCE[0]%/*}; pwd)/../../../boot.sh
source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh

testM1(){
  echo 'this is testM1'
}
testM2(){
  echo "this is testM2, param1=$1"
}

addTrap 'testM1' EXIT
addTrap 'other' EXIT
x='XXX'
addTrap "testM2 $x" EXIT
x='YYYY'
addTrap "testM2 \$x" EXIT

# this is testM1
# this is testM2, param1=XXX
# this is testM2, param1=YYYY