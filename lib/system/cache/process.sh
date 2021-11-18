
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
else
  __createTmpFile(){
    # Usage:
    #   __createTmpFile 'fileName'
    mktemp -t "$1"
  }
  export -f __createTmpFile
fi

# ====================
# global
# ====================
__init_global_cache() {
  if [[ -z "$__boot_global_cache" ]]; then
    export __boot_global_cache="$(__createTmpFile global_cache.$SHBOOT_PID.XXXXXXXX)"
  fi
}
export -f __init_global_cache

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
  local exitVal=$?

  rm -f "$__boot_global_cache" "$__boot_exception_cache" || \
  exit 1

  exit $exitVal
}
export -f __clear_process_cache

addTrap '__clear_process_cache' EXIT INT TERM HUP QUIT ABRT