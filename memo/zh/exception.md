
- 实现位置
    - shboot/lib/system/keyword/exception.sh
    - shboot/lib/system/cache/process.sh

- 实现参考
    - https://github.com/niieani/bash-oo-framework/blob/master/lib/util/tryCatch.sh

- try...catch 的实现方式
    ```sh
    # ############### try 的实现，以下全部是别名的实现 ##############
    #---------------------------------------------------------
    # 1. 通过变量 ___in_try_catch___ 来标识当前是否进入的 try...catch
    if [ -z "$___in_try_catch___" ]; then
      # 如果是第一次进入，将该变量设为 0, 后面会进行自增
      export ___in_try_catch___=0
      # 初始化异常缓存文件，`try{}` 的本质是子进程，为了能够在父进程中执行 catch
      # 只能通过写入缓存文件的方式在两个进程之间进行交互
      __init_exception_cache
    fi
    # 自增该变量，表示进入了 try
    ((___in_try_catch___+=1))

    # 2. 保存当前 shell 的环境设置。等到退出子进程时，再复原
    export ___setOps___="$-"
    set +e # 关闭配置：出现异常时，自动退出

    # 3. 打开一个子进程
    (
      # 进行子进程的配置
      # 3.1 如果出现执行异常，则立刻退出这个子进程，包括: throw, exit, 指令异常
      set -e;
      # 3.2 在子进程结束时，如果是异常退出，则收集发生异常的代码位置 + 行号，并写入缓存文件
      addTrap "__getErrorInfoInTrap" EXIT
      # 3.3 处理 `global` 关键字，将数据写入 global 的缓存文件中
      addTrap "__saveGlobalVar" EXIT INT ABRT
      # 3.4 收集执行过程中的异常到异常缓存中
      exec 2> "$__boot_exception_cache"
    #---------------------------------------------------------

    # 4. 这里接实际 shell 中的 try{...} 内的内容
    #---------------------------------------------------------
    # ############### catch 的实现，以下全部是别名的实现 ##############

    ) # 到这里【子进程结束】

    # 5
    # 5.1 收集子进程的状态码
    ___exitCode___=$?
    # 5.2 如果子进程发生了异常，则从缓存文件中获取异常
    #     异常信息会在退出 try{...} 的子进程时，输出到异常的缓存文件中
    #     所以这里只是从文件中获取异常，不会执行其他处理
    if [ $___exitCode___ -ne 0 ]; then
      ___EXCEPTION___=$(Exception::GetException $___exitCode___)
    fi

    # 5.3 退出后，try...catch 的层数 - 1
    ((___in_try_catch___-=1))

    # 5.4 如果 ___in_try_catch___ 已经变成 0，则说明 最外层的 try 已经执行完成，则删除该变量
    if [ $___in_try_catch___ -eq 0 ];
      unset ___in_try_catch___
    fi

    # 5.5 复原 global 变量的值
    __recoverGlobalVar

    # 5.6 复原当前shell 的环境设置
    set -"$___setOps___"

    if [ $___exitCode___ -eq 0 ]; then
      # 5.7 如果没有异常，则直接退出
      unset ___exitCode___
    else
      # 5.8 如果有异常，则执行 catch {...} 部分的代码
    #---------------------------------------------------------
    # 6. 这里接实际 shell 中的 catch{...} 内的内容
    ```

- throw 的处理
    ```sh
    throw() {
      # make error
      if [ ! -z "$___in_try_catch___" ]; then
        # 如:
        # try {
        #   throw 'xxx'
        # } catch {
        #   ...
        # }
        # 1. 如果是在 try{...} 内部使用 throw，则将 throw 抛出的异常信息暂时保存到变量 ___EXCEPTION___，并以 255 的状态码退出
        # 2. 保存的异常信息，会在 trap 函数 __getErrorInfoInTrap 中进行处理
        ___EXCEPTION___="$*"
        exit 255
      else
        # 如: throw 'xxxxxx'
        # 如果是在 try...catch 外部，使用 throw 直接抛出异常，则
        # 1. 在这里将异常信息传给 Exception::makeExceptionMsg 函数，来创建完整的异常
        #     （主要是在异常中附加异常代码的路径 + 行号）
        # 2. 将异常信息输出到控制台
        printStackTrace "$(Exception::makeExceptionMsg $*)"
        # 3. 直接停止整个 shell 的进程
        kill -TERM "$$"
      fi
    }
    ```

- trap 函数 `__getErrorInfoInTrap`，处理 `try` 内的异常
    ```sh
    # 如果是 try{...} 内部的 throw、或者执行执行异常，将会在这里拼接异常信息，并写入异常缓存文件中
    __getErrorInfoInTrap(){
      # 如果没有异常，则直接返回
      if [ $exitCode -eq 0 ]; then
        return
      fi


      if [ $exitCode -ne 255 ]; then
        if [ $exitCode -eq 127 ]; then
          # 如果是以 127 退出，则可能是指令不存在
          Exception::makeExceptionMsg "exitCode=127; Command not find" >> "$__boot_exception_cache"
        else
          # 如果是其他的状态码，暂时无法分析，直接输出状态码值到文件
          Exception::makeExceptionMsg "exitCode=$exitCode" >> "$__boot_exception_cache"
        fi
      else
        # 如果是以 255 退出的，则将 throw() 函数保存在 ___EXCEPTION___ 变量中的异常信息取出，并保存
        Exception::makeExceptionMsg "$___EXCEPTION___" >> "$__boot_exception_cache"
      fi
    }
    ```

- `Exception::makeExceptionMsg`, 如何创建异常信息
    ```sh
    Exception::makeExceptionMsg(){
      # Usage: Exception::makeException 'a' 'b' 'c' ....
      local msg="Exception: $*"

      # 收集发生异常的 shell + 代码位置
      # 需要跳过两个 shell
      #     1. lib/system/keyword/exception.sh # exception.sh 自身
      #     2. lib/system/builtin/method.sh    # 有可能会在 __getErrorInfoInTrap 中调用，所以需要跳过这个 shell
      local skip='.*lib/system/(keyword/exception.sh|builtin/method.sh)$'
      for (( i=1; i<${#BASH_SOURCE[@]}; i++));do
        if [[ "${BASH_SOURCE[i]}" =~ $skip ]]; then
          continue
        else
          msg="${msg}\n    at ${BASH_SOURCE[i]} (${FUNCNAME[i]}:${BASH_LINENO[i - 1]})"
        fi
      done

      echo "$msg"
    }
    export -f Exception::makeExceptionMsg
    ```