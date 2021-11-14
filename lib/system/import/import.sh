
##########################################################################
# from: https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh #
##########################################################################

###########################################################################
# If you modify the path of the package, you must locate the path to lib/ #
###########################################################################
# lib/
declare -x __boot__libPath="$( cd "${BASH_SOURCE[0]%/*}/../.." && pwd )"
# lib/..
declare -x  __boot__path="$( cd "${__boot__libPath}/.." && pwd )"
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
    System::WrapSource "$libPath" "$@"
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
  local requestedPath="$libPath"
  shift

  if [[ "$requestedPath" == './'* ]]; then
    local p
    local pathPrefix=''
    for p in ${BASH_SOURCE[@]}; do
      if [[ "$p" != *"lib/system/import/import.sh" ]];then
        pathPrefix="${p%/*}"
        break;
      fi
    done
    requestedPath="${pathPrefix}/${requestedPath:2}"
  fi

  # 1. try shboot/lib/**
  # 2. try shboot/**
  # 3. try with ./
  # 4. try with libPath
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