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
  echo "this is testM3"
}

# 1. 添加信号函数
addTrap 'testM1' EXIT

# !!!通过 $ 标注的变量，值是执行 addTrap 时的值，不会使用最终的变量值
x='XXX'
addTrap "testM2 $x" EXIT

# !!!通过 \$ 标注的变量，值最终的变量值
x='YYYY'
addTrap "testM2 \$x" EXIT

addTrap 'testM3' EXIT

# 2. 删除信号函数
# 删除无参数的信号函数
delTrap 'testM1' EXIT
# 删除有参函数。因为变量 x 已经发生了变化，所以无法删除!!!
delTrap "testM2 $x" EXIT
# 删除有参函数。通过 \$ 让然保持了变量名，所以可以删除
delTrap "testM2 \$x" EXIT

# this is testM2, param1=XXX
# this is testM3