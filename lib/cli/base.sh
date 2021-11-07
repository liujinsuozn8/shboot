
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------
import string/base

CLI::StartWithHandlerFunction(){
  # Usage: CLI::StartWithHandlerFunction 'cliName' handlerFunction
  local input=''
  while [ "$input" != "exit" ] 
  do
    if [ -z "$CLI_TITLE" ]; then
      echo -n "$1> " && read input
    else
      echo -n "$1($CLI_TITLE)> " && read input
    fi

    input=$(String::Trim "$input")
    $2 "$input"
  done 
}
export -f CLI::StartWithHandlerFunction

CLI::LoopAskYesOrNo(){
  # Usage
  #   result=`CLI::LoopAskYesOrNo 'msg'`
  #   if CLI::LoopAskYesOrNo 'msg'; then
  # Return
  #   0: yes
  #   1: no
  result=''
  while [[ "$result" != "y" && "$result" != "n" ]]
  do
    printf "$1"
    read result
  done

  if [[ "$result" == "y" ]]; then
    return 0
  else
    return 1
  fi
}