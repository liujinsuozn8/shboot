
#---------------------------------------
# https://github.com/liujinsuozn8/shboot
# LICENSE: MIT License
#---------------------------------------

alias try='
  if [ -z "$___in_try_catch___" ]; then
    export ___in_try_catch___=0
    export ___EXCEPTION___=""
    > "$PROJECT_ROOT/.exception"
  fi
  ((___in_try_catch___+=1))

  export ___setOps___=$(echo $-); set +e; (set -e;'

alias catch='); ___result___=$?; ___EXCEPTION___=$(Exception::GetException $___result___); ((___in_try_catch___-=1)); [ $___in_try_catch___ -eq 0 ] && unset ___in_try_catch___; set -"$___setOps___"; [ $___result___ -eq 0 ] && unset ___result___ ||'