#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

source $( cd $([[ "${BASH_SOURCE[0]}" != *"/"* ]] && echo "." || echo "${BASH_SOURCE[0]%/*}"); pwd )/../../../boot.sh

import net/base

Net::TrySimpleDownload https://github.com/git/git/archive/refs/tags/v2.34.0.zip "./git.zip" 5
case $? in
  0) echo success;;
  2) echo no command;;
  *) echo other;;
esac