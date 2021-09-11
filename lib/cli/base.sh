
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
      echo -n "$1> " && read input
      input=$(String::Trim "$input")
      $2 "$input"
  done 
}
export -f CLI::StartWithHandlerFunction