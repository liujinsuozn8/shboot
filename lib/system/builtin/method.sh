
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
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
    # eval [ -z "\$$tlname" ] \&\& $tlname\=\(\) \&\& trap \'__execTrap $e\' $e \; $tlname+=\($target\)
    eval "[ -z \"\$$tlname\" ] && $tlname='' && trap '__execTrap $e' $e; $tlname=\"\${$tlname}${IFS}\${target}\""
  done
}
export -f addTrap

__execTrap(){
  local exitCode=$?

  local tlname="__boot_trap_${___in_try_catch___}_$1"

  # for m in ${__boot_trap_1_EXIT[@]};do
  # or
  # for m in ${__boot_trap__EXIT[@]};do
  #  [[ $(type -t "${m% *}") == 'function' ]] && eval $m
  # done

  eval "for m in \${$tlname[@]};do [[ \$(type -t \"\${m% *}\" ) == 'function' ]] && eval \$m; done"

  exit $exitCode
}
export -f __execTrap

#=======================================
#=======================================