
if [ "$__boot__bootstrapped" == true ]; then
  return 0
fi

##########################################################################
# from: https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh #
##########################################################################

###########################################################################
# If you modify the path of the package, you must locate the path to lib/ #
###########################################################################
# lib/
declare -x __boot__libPath="$( cd "${BASH_SOURCE[0]%/*}/../.." && pwd )"
# lib/..
declare -x  __boot__path="${__boot__libPath}/.."
# /dev/fd
declare -x  __boot__fdPath=$(dirname <(echo))
declare -ix __boot__fdLength=$(( ${#__boot__fdPath} + 1 ))
# declare -ag __boot__importedFiles
# !!! Replace the array with a string that connected with IFS !!!
export __boot__importedFiles=''

System::WrapSource() {
  local libPath="$1"
  shift

  builtin source "$libPath" "$@" || throw "Unable to load $libPath"
}
export -f System::WrapSource

System::SourceFile() {
  local libPath="$1"
  shift

  [[ ! -f "$libPath" ]] && return 1

  libPath="$(Builtin::AbsPath "$libPath")"

  if [[ -f "$libPath" ]]; then

    ## if already imported let's return
    # if declare -f "Builtin::ArrayContains" &> /dev/null &&
    if [[ "${__boot__allowFileReloading-}" != true ]] && [[ ! -z "${__boot__importedFiles}" ]] && Builtin::ArrayContains "$libPath" ${__boot__importedFiles}; then
      return 0
    fi

    # __boot__importedFiles+=( "$libPath" )
    __boot__importedFiles="$__boot__importedFiles"${IFS}"$libPath"
    __boot__importParent=$(dirname "$libPath") System::WrapSource "$libPath" "$@"

  else
    :
  fi
}
export -f System::SourceFile

System::SourcePath() {
  local libPath="$1"
  shift
  
  if [[ -d "$libPath" ]]; then
    # If $libPath is a directory, all *.sh in the directory will be imported
    local file
    for file in "$libPath"/*.sh; do
      System::SourceFile "$file" "$@"
    done
  elif [[ "$libPath" != *'sh' ]]; then
    # example: import xxx/yyy
    System::SourceFile "${libPath}.sh" "$@"
  else
    System::SourceFile "$libPath" "$@"
  fi
}
export -f System::SourcePath

System::ImportOne() {
  local libPath="$1"
  # The default is empty
  local __boot__importParent="${__boot__importParent-}"
  local requestedPath="$libPath"
  shift

  if [[ "$requestedPath" == './'* ]]; then
    requestedPath="${requestedPath:2}"
  elif [[ "$requestedPath" == "$__boot__fdPath"* ]]; then
    # starts with /dev/fd
    requestedPath="${requestedPath:$__boot__fdLength}"
  fi

  # if source is from local, with parentPath
  if [[ "$requestedPath" != 'http://'* && "$requestedPath" != 'https://'* ]];then
    requestedPath="${__boot__importParent}/${requestedPath}"
  fi

  # source is from net
  if [[ "$requestedPath" == 'http://'* || "$requestedPath" == 'https://'* ]]
  then
    __boot__importParent=$(dirname "$requestedPath") System__SourceHTTP "$requestedPath"
    return
  fi

  # 1. try lib/**
  # 2. try lib/../**
  # 3. try with parent
  # 4. try without parent

  # {
  #   # try relative to parent script
  #   local localPath="$( cd "${BASH_SOURCE[1]%/*}" && pwd )"

  #   localPath="${localPath}/${libPath}"
  #   System::SourcePath "${localPath}" "$@"
  # } || \
  System::SourcePath "${__boot__libPath}/${libPath}" "$@" || \
  System::SourcePath "${__boot__path}/${libPath}" "$@" || \
  System::SourcePath "${requestedPath}" "$@" || \
  System::SourcePath "${libPath}" "$@" || throw "Cannot import $libPath"
}
export -f System::ImportOne

System::Import() {
  local libPath
  for libPath in "$@"; do
    System::ImportOne "$libPath"
  done
}
export -f System::Import

# alias import="__boot__allowFileReloading=false System::Import"
import(){
  __boot__allowFileReloading=false
  System::Import "$@"
}
export -f import
declare -x __boot__bootstrapped=true
