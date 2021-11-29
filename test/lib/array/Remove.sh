#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh

import array/base


a=( aaa bbb ccc )
a=( $(Array::Remove 'aaa' "${a[@]}") )

for i in ${a[@]};do
  echo $i
done

echo '----------'

IFS=$'\n'
a='aaa'$IFS'bbb'$IFS'ccc'$IFS'ddd'
a=$(Array::Remove 'aaa' $a)

for i in ${a[@]};do
  echo $i
done

echo '----------'

a=$(Array::Remove 'ccc' "$a")

for i in ${a[@]};do
  echo $i
done

echo '----------'