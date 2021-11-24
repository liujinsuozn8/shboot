#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh

import net/base

Net::SimpleDownload 

Net::SimpleDownload https://github.com/git/git/xxxxx "./git.zip" 5
case $? in
  0) echo success;;
  2) echo no command;;
  *) echo other;;
esac