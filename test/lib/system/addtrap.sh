#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

# source $(cd ${BASH_SOURCE[0]%/*}; pwd)/../../../boot.sh
source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh

testM1(){
  echo 'this is testM1'
}
testM2(){
  echo "this is testM2, param1=$1"
}
testM3(){
  if [ $exitCode -eq 0 ]; then
    return
  fi
  echo "this is testM3"
}

addTrap 'testM1' EXIT
addTrap 'other' EXIT
x='XXX'
addTrap "testM2 $x" EXIT
x='YYYY'
addTrap "testM2 \$x" EXIT

addTrap "testM3" EXIT

# exit 0
# this is testM1
# this is testM2, param1=XXX
# this is testM2, param1=YYYY

# ------------------------

exit 1
# this is testM1
# this is testM2, param1=XXX
# this is testM2, param1=YYYY
# this is testM3