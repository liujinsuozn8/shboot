import string/regex

Date::ToShellDateFormat(){
  # Usage Date::ToShellDateFormat 'yyyy/MM/dd'
  # yyyy/MM/dd ---> %Y%m%d
  local format="$1"

  # y year, yyyy=%Y, yy=%y
  format=${format//yyyy/%Y}
  format=${format//yy/%y}

  # M month MM=%m
  format=${format//MM/%m}

  # d day dd=%d
  format=${format//dd/%d}

  # h hour (1~12) hh=%l
  format=${format//hh/%l}

  # H hour (0~23) HH=%H
  format=${format//HH/%H}

  # m minute mm=%M
  format=${format//mm/%M}

  # s second ss=%S
  format=${format//ss/%S}

  # S milli second --> handler by Date::Format
  
  # F day of week %w
  format=${format//F/%w}
  
  # E week of year    len=1   %A
  format=${format//E/%A}
  
  # D day of year  %j
  format=${format//D/%j}

  # w week of year %U
  format=${format//w/%U}

  # a AM./PM. %P
  format=${format//a/%P}

  # z zone %Z 
  format=${format//z/%Z}

  echo "$format"
}

Date::NowTimestamp(){
  # Usage: Date::NowTimestamp
  date '+%s%N'
}

Date::FormatNow() {
  # Usage Date::FormatNow foramt
  local timestamp=$(Date::NowTimestamp)
  Date::Format "$timestamp" "$1"
}

Date::Format(){
  # Usage Date::Format timestamp format
  # need handler SSS !!!
  local seconds="${1:0:10}"
  local nano="${1:10}"
  local format=$(Date::ToShellDateFormat "$2")
  
  local result=$( date -d @"$seconds" '+'"$format")

  # handler SSS
  local nanoStr=$(Regex::Matcher "$result" '(S+)' 1)
  if [ ! -z "$nanoStr" ];then
    local nanoNum=${nano:0:${#nanoStr}}
    result="${result/$nanoStr/$nanoNum}"
  fi

  echo "$result"
}

Date::ZeroAMTimestramp(){
  # Usage: Date::ZeroAMTimestramp
  date -d "$(date +%F)" +%s
}