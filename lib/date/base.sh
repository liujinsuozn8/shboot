
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

import string/regex

Date::NowSecond(){
  # Usage: Date::NowSecond
  date '+%s'
}
export -f Date::NowSecond


if [ "$(uname)" == 'Darwin' ]; then
  # for Mac
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
    format=${format//a/%p}

    # z zone %Z 
    format=${format//z/%Z}

    echo "$format"
  }
  export -f Date::ToShellDateFormat

  Date::NowTimestamp(){
    # Usage: Date::NowTimestamp
    # can not get nanoseconds in mac
    date '+%s000000000'
  }
  export -f Date::NowTimestamp

  Date::TodayZeroAMSecond(){
    # Usage: Date::TodayZeroAMSecond
    date -j -f "%Y%m%d%H%M%S" "$(date +%Y%m%d)000000" +%s
  }
  export -f Date::TodayZeroAMSecond

  Date::ZeroAMSecond(){
    # Usage: Date::ZeroAMSecond 'timestamp'
    # timestamp --> date ---> zero timestamp

    # $(date -r ${a:0:10} '+%Y%m%d')   timestamp --> date
    # date ---> 00:00:00 ---> zero timestamp
    date -j -f "%Y%m%d%H%M%S" "$(date -r ${1:0:10} '+%Y%m%d')"'000000' +%s
  }
  export -f Date::ZeroAMSecond

  Date::Format(){
    # Usage Date::Format timestamp format
    # need handler SSS !!!
    local seconds="${1:0:10}"
    local nano="${1:10}"
    nano=${nano:-'00000000'}

    local format=$(Date::ToShellDateFormat "$2")
    
    # Format for Mac:second --> result
    local result=$( date -r "$seconds" '+'"$format")

    # handler SSS
    local nanoStr=$(Regex::Matcher "$result" '(S+)' 1)
    if [ ! -z "$nanoStr" ];then
      local nanoNum=${nano:0:${#nanoStr}}
      result="${result/$nanoStr/$nanoNum}"
    fi

    echo "$result"
  }
  export -f Date::Format

else
  # for Linux

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
  export -f Date::ToShellDateFormat

  Date::NowTimestamp(){
    # Usage: Date::NowTimestamp
    date '+%s%N'
  }
  export -f Date::NowTimestamp

  Date::TodayZeroAMSecond(){
    # Usage: Date::TodayZeroAMTimestamp
    date -d "$(date +%F)" +%s
  }
  export -f Date::TodayZeroAMSecond

  Date::ZeroAMSecond(){
    # Usage: Date::ZeroAMSecond 'timestamp/second'
    # timestamp --> date ---> zero timestamp
    date -d $(date -d @"${1:0:10}" '+%Y%m%d') +%s
  }
  export -f Date::ZeroAMSecond

  Date::Format(){
    # Usage Date::Format timestamp format
    # need handler SSS !!!
    local seconds="${1:0:10}"
    local nano="${1:10}"
    local format=$(Date::ToShellDateFormat "$2")
    
    # Format for Linux:second --> result
    local result=$( date -d @"$seconds" '+'"$format")

    # handler SSS
    local nanoStr=$(Regex::Matcher "$result" '(S+)' 1)
    if [ ! -z "$nanoStr" ];then
      local nanoNum=${nano:0:${#nanoStr}}
      result="${result/$nanoStr/$nanoNum}"
    fi

    echo "$result"
  }
  export -f Date::Format
fi


Date::FormatNow() {
  # Usage Date::FormatNow foramt
  local timestamp=$(Date::NowTimestamp)
  Date::Format "$timestamp" "$1"
}
export -f Date::FormatNow


Date::ZeroAMTimestamp(){
  # Usage: Date::ZeroAMSecond 'timestamp/second'
  echo "$(Date::ZeroAMSecond $1)000000000"
}
export -f Date::ZeroAMTimestamp

Date::TodayZeroAMTimestamp(){
  # Usage: Date::TodayZeroAMTimestamp
  echo "$(Date::TodayZeroAMSecond)000000000"
}
export -f Date::TodayZeroAMTimestamp

Date::TimeUnitStrToSecond(){
  # Usage Date::TimeUnitStrToSecond 'timeString'
  local unit=${1: -1}
  local long=${1%?}
  local base=0

  # 10d
  # 10H
  # 10m
  # 10s
  case "$unit" in
    d)
      # base=60 * 60 * 24
      base=86400
    ;;
    H)
      base=3600
    ;;
    m)
      base=60
    ;;
    s)
      base=1
    ;;
  esac
  awk 'BEGIN{print "'$long'" * "'$base'"}'
}
export -f Date::TimeUnitStrToSecond