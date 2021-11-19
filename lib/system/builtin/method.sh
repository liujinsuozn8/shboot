
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
# author: liujinsuozn8
#---------------------------------------

#=======================================
# Trap
#=======================================
addTrap(){
  local target="$1"
  shift 1

  local e
  for e in $@; do
    # use var from [shboot/lib/system/keyword/exception.sh]
    local tlname="__boot_trap_${___in_try_catch___}_$e"
    # if [ -z "$__boot_trap_1_EXIT" ]; then
    #   __boot_trap_1_EXIT=()
    # fi
    # __boot_trap_1_EXIT=($target)
    eval [ -z "\$$tlname" ] \&\& $tlname\=\(\) \&\& trap \'__execTrap $e\' $e \; $tlname+=\($target\)
  done
}
export -f addTrap

__execTrap(){
  local exitVal=$?

  local tlname="__boot_trap_${___in_try_catch___}_$1"
  # echo "$tlname"
  # for m in ${$tln__boot_trap_1_EXITame[@]};do
  #   eval $m
  # done
  eval for m in \${$tlname[@]}\;do eval \$m\; done

  exit $exitVal
}
export -f __execTrap

#=======================================
#=======================================