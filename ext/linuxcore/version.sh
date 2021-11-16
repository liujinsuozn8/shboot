
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

import string/regex
import number/base

LinuxCore::GetVersionStr(){
  # Usage: 
  #   LinuxCore::GetVersionStr
  # Return:
  #   example: 5.4.157-1.el7.elrepo.x86_64
  try {
    echo $(uname -r)
  } catch {
    try {
      local verStr=`cat /proc/version`
      echo $(Regex::Matcher "$verStr" 'Linux version \(?([^ ]+).*' 1)
    } catch {
      throw 'can not get version of linux core. Because can not use command `uname -r` or can not find file: `/proc/version`'
    }
  }
}

LinuxCore::GetVersionNum(){
  # Usage: 
  #   LinuxCore::GetVersionNum subVersionCount
  # Parameter
  #   $1: subVersionCount
  #             0 or 1 or 2.
  #             default is 1.
  #             if greater than 2, 2 will be used 
  # Return:
  #   example: 5 (subVersionCount=0)
  #   example: 5.4 (subVersionCount=1)
  #   example: 5.4.157 (subVersionCount=2)
  local subVersionCount
  if [[ $# -eq 0 ]];then
    subVersionCount=1
  elif [[ $1 -gt 2 ]]; then
    subVersionCount=2
  else
    subVersionCount=$1
  fi

  local verStr=$(LinuxCore::GetVersionStr)
  local regexStr="([0-9]+(\.[0-9]+){$subVersionCount}).*"
  echo $(Regex::Matcher "$verStr" "$regexStr" 1)
}

LinuxCore::GetMaxCoreVersionStrFromGrub(){
  # Usage: 
  #   LinuxCore::GetMaxCoreVersionStrFromGrub
  local maxVerNum='0'
  local maxVerstr=''
  local line
  for line in $(awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg);do
    local curVarNum=$(Regex::Matcher "$line" 'Linux \(?([0-9]+(\.[0-9]+)*).*' 1)
    maxVerNum=$(Number::Max $maxVerNum $curVarNum)

    if [[ "$maxVerNum" == "$curVarNum" ]]; then
      maxVerstr=$(Regex::Matcher "$line" 'Linux \(?([^ )]+).*' 1)
    fi
  done

  echo $maxVerstr
}

LinuxCore::GetMaxCoreVersionNumFromGrub(){
  # Usage: 
  #   LinuxCore::GetMaxCoreVersionNumFromGrub 'subVersionCount'
  # Parameter
  #   $1: subVersionCount
  #             0 or 1 or 2.
  #             default is 1.
  #             if greater than 2, 2 will be used 
  # Return:
  #   example: 5 (subVersionCount=0)
  #   example: 5.4 (subVersionCount=1)
  #   example: 5.4.157 (subVersionCount=2)
  local subVersionCount
  if [[ $# -eq 0 ]];then
    subVersionCount=1
  elif [[ $1 -gt 2 ]]; then
    subVersionCount=2
  else
    subVersionCount=$1
  fi

  local maxVerStr=$(LinuxCore::GetMaxCoreVersionStrFromGrub)
  local regexstr="([0-9]+(\.[0-9]+){$subVersionCount})"
  local maxVerNum=$(Regex::Matcher "$maxVerStr" "$regexstr" 1)

  echo $maxVerNum
}

LinuxCore::GetMaxCoreVersionIndexFromGrub(){
  # Usage: 
  #   LinuxCore::GetMaxCoreVersionIndexFromGrub
  local maxVerNum='0'
  local maxVerIndex=0
  local index=0
  local line
  for line in $(awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg);do
    local curVarNum=$(Regex::Matcher "$line" 'Linux \(?([0-9]+(\.[0-9]+)*).*' 1)
    maxVerNum=$(Number::Max $maxVerNum $curVarNum)

    if [[ "$maxVerNum" == "$curVarNum" ]]; then
      maxVerIndex=$index
    fi

    ((index=index+1))
  done

  echo $maxVerIndex
}
