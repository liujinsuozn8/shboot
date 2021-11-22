
- 实现位置
    - shboot/lib/system/keyword/import.sh
- 实现参考
    - https://github.com/niieani/bash-oo-framework/blob/master/lib/oo-bootstrap.sh
- import 函数
    ```sh
    # 使用函数替代别名实现

    # alias import="__boot__allowFileReloading=false System::Import"
    import(){
      __boot__allowFileReloading=false
      System::Import "$@"
    }
    export -f import
    ```

- 如何存储导入的路径
    ```sh
    # 通过字符串的方式保存，保证在子shell中也可以使用
    export __boot__importedFiles=''
    # 保存方式。通过 `\n` 来分割
    __boot__importedFiles="$__boot__importedFiles"${IFS}"$libPath"
    ```

- 导入的具体流程
    ```sh
    # 1. 导入 import 后的所有shell
    # 如 import aaaa/bbbb xxxx/yyyy
    System::Import() {
      local libPath
      # 循环所有需要引入的目标，一个一个引入
      for libPath in "$@"; do
        System::ImportOne "$libPath"
      done
    }

    # 2. 提前准备两个默认的路径前缀
    # 2.1 shboot/lib
    declare -x __boot__libPath="$( cd "${BASH_SOURCE[0]%/*}/../.." && pwd )"
    # 2.3 shboot/
    declare -x  __boot__path="$( cd "${__boot__libPath}/.." && pwd )"

    # 3. 引入一个指定的 shell
    System::ImportOne() {
      # 3.1 将 $1 保存到两个变量中。如果不是绝对路径，会修改【requestedPath】
      local libPath="$1"
      local requestedPath="$libPath"
      shift

      # 3.2 如果是 ./ 开头相对路径，如: import ./aaa
      # 这种情况有是执行【import ./aaa】这条指令的 shell 的相对路径，所以需要先找到这个 shell
      if [[ "$requestedPath" == './'* ]]; then
        local p
        local pathPrefix=''
        # 3.3 遍历 shell 的调用链，import.sh 会在前面，将 import.sh 过滤掉之后，遇到的第一个 shell 就是目标shell
        # 找到后获取目标 shell 所在的目录
        for p in ${BASH_SOURCE[@]}; do
          if [[ "$p" != *"lib/system/keyword/import.sh" ]];then
            pathPrefix="${p%/*}"
            break;
          fi
        done

        # 将 import 引入的路径开头的 ./ 去掉，并在前面拼接搜索到的目录，形成一个绝对路径
        requestedPath="${pathPrefix}/${requestedPath:2}"
      fi

      # 3.4. 开始尝试引入指定的shell
      # 尝试 4 种导入路径
      # 3.4.1 shboot/lib/**
      # 3.4.2 shboot/**
      # 3.4.3 尝试使用 3.2 中拼接的路径
      # 3.4.4 前面都找不到的话，直接尝试导入 libPath，如果还还没找到则抛出异常
      System::SourcePath "${__boot__libPath}/${libPath}" "$@" || \
      System::SourcePath "${__boot__path}/${libPath}" "$@" || \
      System::SourcePath "${requestedPath}" "$@" || \
      System::SourcePath "${libPath}" "$@" || throw "Cannot import $libPath"
    }


    # 4. 导入目标 shell 前，做一些处理
    System::SourcePath() {
    local libPath="$1"
    shift

    if [[ -d "$libPath" ]]; then
        # 4.1 如果是一个目录，这遍历并导入该目录下的所有 shell
        # If $libPath is a directory, all *.sh in the directory will be imported
        local file
        for file in "$libPath"/*.sh; do
        System::SourceFile "$file" "$@"
        done
    elif [[ "$libPath" != *'sh' ]]; then
        # 4.2 如果不是目录，则作为一个文件导入
        # 如果不是以 sh 结尾，如 import aaa/bbb
        # 则在路径后面添加 .sh 的文件后缀

        # example: import xxx/yyy
        System::SourceFile "${libPath}.sh" "$@"
    else
        # 4.3 如果是以 .sh 结尾则直接导入
        System::SourceFile "$libPath" "$@"
    fi
    }
    export -f System::SourcePath

    # 5. 进行导入，如果有异常则返回 1
    System::SourceFile() {
      local libPath="$1"
      shift

      if [[ -f "$libPath" ]]; then
        ## if already imported, return
        # if declare -f "Builtin::ArrayContains" &> /dev/null &&
        if [[ "${__boot__allowFileReloading-}" != true ]] && \ # 当前版本默认【不允许重复导入】
           [[ ! -z "${__boot__importedFiles}" ]] && \          # 检查当前的路径是否已被导入
           Builtin::ArrayContains "$libPath" ${__boot__importedFiles}; then
          return 0  # 如果已经导入，则跳过
        fi

        # 先保存导入的路径，然后进行导入
        # compatible bash3
        # __boot__importedFiles+=( "$libPath" )
        __boot__importedFiles="$__boot__importedFiles"${IFS}"$libPath"
        System::WrapSource "$libPath" "$@"
      else
        return 1
      fi
    }
    export -f System::SourceFile

    # 6. 真正的导入操作
    System::WrapSource() {
      local libPath="$1"
      shift

      # 通过  source 指令导入其他 shell
      builtin source "$libPath" "$@" || throw "Unable to load $libPath"
    }
    export -f System::WrapSource
    ```
