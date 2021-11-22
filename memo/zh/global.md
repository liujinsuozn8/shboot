
- 实现位置
    - shboot/lib/system/keyword/global.sh
    - shboot/lib/system/cache/process.sh
    - shboot/lib/system/keyword/exception.sh
        - 在 try...catch 中向缓存中写入 global 变量的数据

- global 是为了解决 `try{...}` 或者其他子进程中无法共享变量的问题
- global 的处理方式
    1. 初始化 global 缓存文件名
        ```sh
        # shboot/lib/system/cache/process.sh
        # 1. 启动后，创建 global 的缓存文件的【文件名】
        # !!! create filename of global_cache when shboot init
        # !!! create real file of global_cache when `global` be used
        export __boot_global_cache=$(__createTmpFileName global_cache.$SHBOOT_PID.XXXXXXXX)
        ```
    2. 使用变量保存所有的 global 变量
        ```sh
        # shboot/lib/system/keyword/global.sh
        # 2. 使用变量保存所有使用 global 标识的变量
        #    因为这个变量也会在子进程中发生变化(如在 try{...} 中使用 global)，所以也需要导出到缓存文件
        #    为了加速 __boot_global_varnames 导入导出的速度，使用字符串，用 ` ` 进行分割
        export __boot_global_varnames='__boot_global_varnames'

        # 3. 使用 global 时的操作
        global(){
          # 3.1 如果是第一次使用 global，创建缓存文件。
          # 通过这种方式减少与磁盘的交互。如果没有使用过 global，则不会创建缓存文件
          __init_global_cache

          if [[ "$1" == *"="* ]]; then
            # 3.2 如果是 global k=v 的形式，则创建改变量
            local pname=${1%%=*}
            local pval=${1#*=}
            eval "$pname='$pval'"

            # 使用 ` ` 做分隔符来连接所有的 global 变量名
            __boot_global_varnames="$__boot_global_varnames $pname"
          else
            # 3.3 如果是 global k 的形式，则创建该变量，值为空字符串
            eval "$1=''"
            # 使用 ` ` 做分隔符来连接所有的 global 变量名
            __boot_global_varnames="$__boot_global_varnames $1"
          fi
        }
        ```
    3. 在 try...catch... 中(父子进程中交互 global 变量)
        ```sh
        # shboot/lib/system/keyword/exception.sh
        #---------------------------------------------------------
        # ############### try 的实现 ##############
        if [ -z "$___in_try_catch___" ]; then
          export ___in_try_catch___=0
          __init_exception_cache
        fi
        ((___in_try_catch___+=1))
        export ___setOps___="$-"
        set +e
        (
          set -e;
          addTrap "__getErrorInfoInTrap" EXIT

          # 4.1 在子进程结束时，处理 `global` 关键字，将数据写入 global 的缓存文件中
          addTrap "__saveGlobalVar" EXIT INT ABRT

          exec 2> "$__boot_exception_cache"
        #---------------------------------------------------------
        # global k=v
        #---------------------------------------------------------
        # ############### catch 的实现 ##############
        )
        ___exitCode___=$?
        if [ $___exitCode___ -ne 0 ]; then
          ___EXCEPTION___=$(Exception::GetException $___exitCode___)
        fi
        ((___in_try_catch___-=1))
        if [ $___in_try_catch___ -eq 0 ];
          unset ___in_try_catch___
        fi

        # 4.2 回到父进程之后，从 global 缓存文件中复原 global 变量的值
        __recoverGlobalVar

        set -"$___setOps___"
        if [ $___exitCode___ -eq 0 ]; then
          unset ___exitCode___
        else
        #---------------------------------------------------------
        ```
    4. 通过缓存文件，在进程间交互 global 变量
        ```sh
        # shboot/lib/system/keyword/global.sh

        # 5.1 将 global 变量的数据导出到缓存文件
        __saveGlobalVar(){
          # 如果还没有添加 global 变量，则直接结束，不创建文件，减少与磁盘的交互
          if [ "$__boot_global_varnames" == '__boot_global_varnames' ]; then
            return
          fi

          # 如果有 global 变量，则将分隔符变成 ` `，并遍历每一个变量，并将值写入缓存文件
          # 如果在 try 外部通过 global 定义变量，在 try 内部无法直接跟踪是否发生了变化
          # 所以每次都将 global 变量全部导出，不检查是否发生了变化
          IFS=$' '
          local k
          for k in $__boot_global_varnames; do
            eval "echo $k=\'\$$k\'" >> "$__boot_global_cache"
          done

          IFS=$'\n'
        }
        export -f __saveGlobalVar

        # 5.2 从 global 缓存文件中将所有变量导入到当前进程内
        __recoverGlobalVar(){
          # 如果缓存文件不存在，则说明还没有使用过 global，则直接跳过处理
          if [ ! -e "$__boot_global_cache" ];then
            return
          fi

          # 遍历每一行，并将变量值导入到当前进程中
          while read -r line || [[ -n ${line} ]]; do
            if [[ -z ${line} ]]; then
              continue
            fi
            eval "$line"
          done < "$__boot_global_cache"

          # 导入完成后，情况缓存文件
          > "$__boot_global_cache"
        }
        export -f __recoverGlobalVar
        ```

- TODO
    - 当前 global 缓存文件中是按照行保存的，如果变量值中包含**换行符**，则重新导入的时候无法处理