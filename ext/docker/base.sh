
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------
import file/base

Docker::LocalImgExist(){
  # Usage: Docker::LocalImgExist 'imgName'
  if [ -z "$(docker images -q $1 )" ]; then
    return 1
  else
    return 0
  fi
}

Docker::LocalImgTagExist(){
  # Usage: Docker::LocalImgTagExist 'imgName' 'tag'
  if [ -z "$(docker images -q $1:$2 )" ]; then
    return 1
  else
    return 0
  fi
}

Docker::CreateContainerSimple(){
  # Usage: Docker::CreateContainerSimple 'containsName' 'imgName' 'tag' 'volumeOutterPath' 'volumeInnerPath'
  local containsName="$1"
  local imgName="$2"
  local tag="$3"
  local volumeOutterPath="$4"
  local volumeInnerPath="$5"

  if ! Docker::LocalImgTagExist "$imgName" "$tag"; then
    throw "Image ${imgName}:${tag} is not exist"
  fi

  if [ ! -e "$volumeOutterPath" ];then
    mkdir -p "$volumeOutterPath"

    if [ $? -ne 0 ];then
      throw "Can not create container. Directory: $volumeouterpath  could not be created"
    fi
  elif [ ! -d "$volumeOutterPath" ];then
    throw "Can not create container: ${containsName}. Because volumeOutterPath already exists, but it is not a directory.\nvolumeOutterPath=${volumeOutterPath}"
  fi

  docker run -d -t --name "$containsName" -v "$volumeOutterPath":"$volumeInnerPath" "$imgName":"$tag"
}