#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------
source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh

try {
  try {
    echo '001'
    throw 'error--1'
  } catch {
    # echo 'catch'
    printStackTrace "$___EXCEPTION___"
  }

  echo 002
  exit 234
  echo 003
} catch {
  printStackTrace "$___EXCEPTION___"
}
echo 004

throw 'error--2'

echo 005

# 001
# error--1
# 002
# error--exit 234
# 004
# error--2
