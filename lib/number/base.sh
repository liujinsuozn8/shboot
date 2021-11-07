
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

Number::Compare(){
  # Usage: 
  #      Number::Compare 'num1' 'num2'
  # Return 
  #      1 num1 > num2
  #      0 num1 == num2
  #     -1 num1 < num2
  awk 'BEGIN {
    num1="'$1'"
    num2="'$2'"
    if (num1>num2) { 
      print 1
    } else if (num1==num2) {
      print 0
    } else {
      print -1
    }
  }'
}

Number::Max(){
  # Usage: 
  #      Number::Max 'num1' 'num2'
  result=`Number::Compare "$1" "$2"`
  if [[ $result -eq 1 || $result -eq 0 ]]; then
    echo $1
  else
    echo $2
  fi
}

Number::Eq(){
  # Usage: 
  #      Number::Eq 'num1' 'num2'
  result=`Number::Compare "$1" "$2"`

  if [[ $result -eq 0 ]]; then
    return 0
  else
    return 1
  fi
}

Number::Ne(){
  # Usage: 
  #      Number::Ne 'num1' 'num2'
  result=`Number::Compare "$1" "$2"`

  if [[ $result -ne 0 ]]; then
    return 0
  else
    return 1
  fi
}

Number::Gt(){
  # Usage: 
  #      Number::Gt 'num1' 'num2'
  result=`Number::Compare "$1" "$2"`

  if [[ $result -eq 1 ]]; then
    return 0
  else
    return 1
  fi
}

Number::Lt(){
  # Usage: 
  #      Number::Lt 'num1' 'num2'
  result=`Number::Compare "$1" "$2"`

  if [[ $result -eq -1 ]]; then
    return 0
  else
    return 1
  fi
}

Number::Ge(){
  # Usage: 
  #      Number::Ge 'num1' 'num2'
  result=`Number::Compare "$1" "$2"`

  if [[ $result -eq 1 || $result -eq 0 ]]; then
    return 0
  else
    return 1
  fi
}

Number::Le(){
  # Usage: 
  #      Number::Le 'num1' 'num2'
  result=`Number::Compare "$1" "$2"`

  if [[ $result -eq -1 || $result -eq 0 ]]; then
    return 0
  else
    return 1
  fi
}