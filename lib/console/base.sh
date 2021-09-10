
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
#---------------------------------------

import console/color

Console::EchoWithColor(){
  # Usage: Console::EchoWithColor 'Color_Background' 'Color_Text' 'text'
  echo -e "\033[$1;$2m$3 \033[0m"
}
export -f Console::EchoWithColor

Console::EchoRed(){
  # Usage: Console::EchoRed "text"
  Console::EchoWithColor $Color_BG_Default $Color_Text_Red "$1"
}
export -f Console::EchoRed

Console::EchoGreen(){
  # Usage: Console::EchoGreen "text"
  Console::EchoWithColor $Color_BG_Default $Color_Text_Green "$1"
}
export -f Console::EchoGreen

Console::EchoYellow(){
  # Usage: Console::EchoYellow "text"
  Console::EchoWithColor "$Color_BG_Default" "$Color_Text_Yellow" "$1"
}
export -f Console::EchoYellow

Console::EchoBule(){
  # Usage: Console::EchoBule "text"
  Console::EchoWithColor "$Color_BG_Default" "$Color_Text_Bule" "$1"
}
export -f Console::EchoBule

Console::EchoPurple(){
  # Usage: Console::EchoPurple "text"
  Console::EchoWithColor "$Color_BG_Default" "$Color_Text_Purple" "$1"
}
export -f Console::EchoPurple

Console::EchoLightBlue(){
  # Usage: Console::EchoLightBlue "text"
  Console::EchoWithColor "$Color_BG_Default" "$Color_Text_LightBlue" "$1"
}
export -f Console::EchoLightBlue

Console::EchoWhite(){
  # Usage: Console::EchoWhite "text"
  Console::EchoWithColor "$Color_BG_Default" "$Color_Text_White" "$1"
}
export -f Console::EchoWhite
