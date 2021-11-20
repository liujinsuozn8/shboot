
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

if [ "$(uname)" == 'Darwin' ]; then
  __createTmpFile(){
    # Usage:
    #   __createTmpFile 'fileName'
    mktemp "/tmp/$1"
  }
  export -f __createTmpFile

  __createTmpFileName(){
    # Usage:
    #   __createTmpFile 'fileName'
    mktemp -u "/tmp/$1"
  }
  export -f __createTmpFileName
else
  __createTmpFile(){
    # Usage:
    #   __createTmpFile 'fileName'
    mktemp -t "$1"
  }
  export -f __createTmpFile

  __createTmpFileName(){
    # Usage:
    #   __createTmpFile 'fileName'
    mktemp -t -u "$1"
  }
  export -f __createTmpFileName
fi

# ====================
# global
# ====================
__init_global_cache() {
  if [ ! -e "$__boot_global_cache" ]; then
    > "$__boot_global_cache"
  fi
}
export -f __init_global_cache

# !!! create filename of global_cache when shboot init
# !!! create real file of global_cache when `global` be used
export __boot_global_cache=$(__createTmpFileName global_cache.$SHBOOT_PID.XXXXXXXX)

# ====================
# exception
# ====================
__init_exception_cache() {
  if [[ -z "$__boot_exception_cache" ]]; then
    export __boot_exception_cache="$(__createTmpFile exception_cache.$SHBOOT_PID.XXXXXXXX)"
  fi
}
export -f __init_exception_cache


# ====================
# clear cache
# ====================
__clear_process_cache() {
  rm -f "$__boot_global_cache" "$__boot_exception_cache" || \
  exit 1
}
export -f __clear_process_cache

addTrap '__clear_process_cache' EXIT INT TERM HUP QUIT ABRT