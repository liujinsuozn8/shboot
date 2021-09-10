
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

# docker run -it -v /宿主机绝对路径:/容器内目录 镜像名
# docker run -it -v 

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
