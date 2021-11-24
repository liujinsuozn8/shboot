
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

Net::SimpleDownload(){
  # Usage
  #   Net::SimpleDownload 'url' 'localPath' 'retryCount'
  # Parameter
  #   $3: retryCount
  #       default is 0
  #       The count of downloads is retryCount + 1
  if [ -z "$3" ]; then
    local dlCount=1
  else
    local dlCount=$3
    ((dlCount=dlCount + 1))
  fi

  local dlType=''
  if Reflect::isCommand wget; then
    dlType='wget'
  elif Reflect::isCommand curl; then
    dlType='curl'
  else
    return 2
  fi

  local shOps="$-"
  set +e

  for (( i=0; i<$dlCount; i++ ));do
    if [ "$dlType" == 'wget' ]; then
      wget "$1" -O "$2" 
    else
      curl -L "$1" -o "$2"
    fi

    local cmdCode=$?
    case $cmdCode in
      0) break;;
      4) continue;;
      *)
        set -"$shOps"
        rm -f "$2"
        return $cmdCode
      ;;
    esac
  done

  set -"$shOps"
}
