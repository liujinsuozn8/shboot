# shboot

# 参考
- https://github.com/niieani/bash-oo-framework
    - import 加载系统的来源
        - 只保留了 `import` 一个加载函数
        - 暂时不考虑**面向对象的特性**。不提供偏向于整体性的功能，只提供更多的工具和方法
    - `try...catch...` 的来源
        - 实现上是通过 `alias` 定义了 `try` 与 `catch` 的行为
        - 在实现上进行了一定程度上的简化，减少了在多层 `try...catch...` 嵌套中，临时保存异常时与文件的交换次数
            - 因为 `try...catch...` 的实现涉及到启动子进程，并且 `alias` 不能包含 `parameter=$(` 这种父子进程交互的操作，所以多层 `try...catch...` 存储上一层的异常时，只能暂存到临时文件中

- https://github.com/tomas/skull
- https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh
- https://github.com/dylanaraps/pure-bash-bible
    - 一些基础方法的实现
    - 中文版本：https://gitee.com/bingios/pure-bash-bible-zh_CN

# 注意事项
1. shboot 的很多功能无法在**子shell**中使用，只能通过 `source` 来引入。如果需要启动**子shell**，需要在子shell内部重新引入 shboot
2. 因为 1 的原因，对 shboot 的所有改动的**第一原则**是启动要足够快

# 系统中必须要包含指令
- stat
- awk
- grep
- date

# 开发过程中需要注意的问题
- [/shboot/memo/zh](/shboot/memo/zh)

# 使用 shboot
## 在自定义 shell 中引入 shboot
1. 使用当前工程，作为启动工程。或者将 `lib` 目录拷贝到自定义目录下
2. 在 `lib` 的同级目录下创建自定义 shell
3. 在自定义 shell 中引入 `shboot`
    ```sh
    # 这里将自定义 shell 保存到了 lib 的同级目录下！！！
    source "$(cd `dirname $0`; pwd)/boot.sh"
    ```

## 启动方式
- `bash <自定义shell文件名>.sh`
- **必须通过 `bash` 来启动**
- 如果直接用 `./<自定义shell文件名>.sh` 来启动，则需要在shell开头添加 `#!/bin/bash`
- 不能通过 `sh` 启动，因为有些语法 `sh` 无法识别

# 内置功能
## import 导入其他 shell
- 导入方式
    ```sh
    source "$(cd `dirname $0`; pwd)/boot.sh"

    # 如果 shell 的扩展名是 .sh，导入时可以不写
    # 导入 shboot/lib 包下的shell
    import 'string/base'
    import 'string/regex.sh'

    # 导入与 shboot/lib 同级的其他目录下的 shell
    import 'ext/xxx'

    # 导入当前shell同级目录下的其他 shell，可以不写 .sh
    import ./xxx/yyy

    # 使用绝对路径导入，可以不写 .sh
    import /aa/bb
    ```

- 如果导入的目标不存在，将会抛出异常
- 捕获 `import` 的异常
    - 无法通过 `try...catch...` 来执行 `import`
        - 因为 `try{...}` 内部会开启子进程，所以 `import` 操作虽然会成功，但是导入的内容对于 `try` 外部来说是无效的
    - `import` 方法抛出异常的实现方式
        ```sh
        kill -TERM "$$"
        ```
    - 捕获异常的方式
        ```sh
        # 处理异常
        trap 'import异常处理函数' TERM
        
        import 'xxx'

        # 或者忽略
        trap '' TERM
        ```

- 可以导入的内容
    1. lib 包下的 shell
    2. 与 lib 包同级的其他目录下的 shell

- 注意事项
    1. **同样的 shell 只会导入一次**
    2. `lib/system` 下的包在引入 shboot 时，已经导入了，不要重复导入
    3. 如果 shell 的扩展名是 `.sh`，导入时可以不写。否则，**必须标注扩展名**
    4. `import` 实际上执行的是 `source` 处理

## 内置变量
- `SHBOOT_ROOT`, shboot 的目录
- `SHBOOT_PID`, 启动 shell 的进程 ID
- `START_SHEEL_DIR`, 启动 shell 所在的目录
- `START_SHEEL_PATH`, 启动 shell 的路径

## addTrap 添加信号处理函数
- 默认的 `trap` 指令对于**同一个信号**只有最后一次设置的操作会生效，无法设置多个
- 可以通过 `addTrap` 将**函数名**添加到内部的列表中，在 shell 结束时按照添加的顺序执行
- 使用 `$exitCode` 来获得shell结束时的状态码
    - 因为所有被添加的函数，最终会被内置的方法调用，所以 `$?` 已经无法表示原始的状态码了，只能通过内部提供的变量来获取
- 使用方法
    ```sh
    # 只需要引入 shboot 本身即可，不需要引入其他组件
    source "$(cd `dirname $0`; pwd)/boot.sh"
    testM1(){
      echo 'this is testM1'
    }
    testM2(){
      echo "this is testM2, param1=$1"
    }
    testM3(){
      # 如果没有异常将会退出该方法
      if [ $exitCode -eq 0 ]; then
        return
      fi
      echo "this is testM3"
    }

    # 使用方法和原始的 trap 相同
    # 第一个参数需要设置函数名
    # 从第二个参数开始，设置信号
    addTrap 'testM1' EXIT
    # 如果函数不存在，将会自动忽略
    addTrap 'other' EXIT
    # 如果函数需要参数，可以进行添加
    # !!!通过 $ 标注的变量，值是执行 addTrap 时的值，不会使用最终的变量值
    x='XXX'
    addTrap "testM2 $x" EXIT
    # !!!通过 \$ 标注的变量，值最终的变量值
    x='YYYY'
    addTrap "testM2 \$x" EXIT
    # 正常退出时，不会产生任何输出
    addTrap "testM3" EXIT

    # this is testM1
    # this is testM2, param1=XXX
    # this is testM2, param1=YYYY
    ```

## 异常处理
### 注意事项
1. try...catch 是通过子进程的方式实现的，会产生一定的临时文件来完成进程间数据的交互，所以不要在 `for`、`while` 等循环中使用
2. 如果只是为了处理，或者防止某一条指令异常，**不推荐使用**，可以使用如下的方式
    ```sh
    # 指令执行后，捕获异常
    you-command
    [ $? -ne 0 ] && throw "error message"
    ```
3. 使用 `global` 之后，会在整个环境中产生额外的开销，需要按需使用
4. try...catch 比较适合的使用场景
    ```sh
    # 批量执行大量指令，不确定哪个指令会出现异常，并且异常的处理方式相同
    try {
      command--1
      command--2
      command--3
      ...
      command--N
    } catch {
      ...
    }
    ```

### 抛出异常
- 通过 `throw` 函数抛出异常。执行后，会直接停止调用的该方法shell
- 内部通过 `kill` 来停止进程，即使是 `result=$(throw '...')` 的方式调用，也可以停止，不会受到子进程的影响

### 捕获异常
- 可以捕获的异常 
    - `throw` 方法抛出的异常
    - `return`、`exit` 返回非 0 值
    - 指令不存在的异常
- 需要注意
    - `return`、`exit`
        - 在`try{}`内部，`return`、`exit` 如果返回了非 0 值，会立刻停止
        - 可以在`try{}`内部，通过 `if method; then` 的方式来判断指令的结果，防止被当作异常抛出
    - **try 内部会开启子进程，所以不应该在 try 内部执行 `import`。或者在try 外部使用内部的变量，或者在 try 内部修改外部的变量**
- 一层 `try...catch`
    ```sh
    source "$(cd `dirname $0`; pwd)/boot.sh"

    # 在函数中使用 try...catch
    test(){
      # 通过 try...catch...来捕获异常
      # 可以捕获 throw 的异常
      # 也可以捕获非 0 的返回值
      try { 
        echo aaa
        # throw 'throw test'
        exit 10
      } catch {
        echo xxx
        
        # 通过变量 ___EXCEPTION___ 可以获取到捕获的异常
        # 可以通过printStackTrace来输出异常，如果导入了 log 会按照配置输出。否则会输出到控制台
        # 如果不需要输出可以省略
        printStackTrace "$___EXCEPTION___"
        
        # 这里的 return 非 0 值后的处理方式，需要根据 `set`,`$-` 的设置来处理
        # 如果设置了 `set -e` 将会立刻停止当前 shell
        # 否则会继续执行
        return 3
      }
    }

    # 执行 test 函数，内部将会捕获异常，并进行处理
    test
    echo "result=$?" # 将会输出 3。(如果没有设置 set -e)
    
    # 如果没有 try...catch 将会直接终止程序的运行
    throw 'out throw'
    echo "not print"
    ```

- 多层 `try...catch...`
    ```sh
    try { 
      try {
        throw 'throw test2'
      } catch {
        # 1. 上一层的异常将会被捕获，可以通过：printStackTrace "$___EXCEPTION___" 输出 'throw test2' 的信息
        # 2. 这里抛出新的异常
        throw 'abcd'

        # 3. 如果改成 echo 1234，后续将不会输出任何异常
        # echo 1234
      }
    } catch {
      # 3. 这里会输出第二层的 'abcd' 异常
      printStackTrace "$___EXCEPTION___"
    }
    ```

### try...catch 关键字的使用
- 关键字和 `{`，`}` 之间必须有空格，否则会产生异常
    ```sh
    try {
        ...
    } catch {
        ...
    }
    ```

### 通过关键字 global 声明在 try...catch 内外都可以使用的变量
- `try {...}` 内部的代码实际上会在一个**子进程**中执行
- `try {...}` 的内部可以获取到外部的变量，但是外部无法获取到内部的（因为是**子进程**）
- 可以通过关键字 global 声明在 try...catch 内外都可以使用的变量
    ```sh
    test(){
        echo 'this is tetst'
    }

    # 外部可以不使用 var，
    # 直接声明: a=1234
    global a=1234
    try {
      echo "a1=$a" #a1=1234
      a=5678   #使用 var 设置变量值

      try {
        echo "a2=$a" #a2=5678
        a=910    #使用 var 设置变量值
      } catch {
        printStackTrace "$___EXCEPTION___"
      }

      global testStr="$(test)"
    } catch {
      printStackTrace "$___EXCEPTION___"
    }
    echo $a #910
    # 可以直接在外部访问 try...catch 内部的变量
    echo $testStr #this is tetst
    ```

### 通过 ___exitCode___ 在 catch 中处理不同的异常
```sh
try {
    ...
} catch {
    if [[ $___exitCode___ -eq 1 ]]; then
        echo 1...
    elif [[ $___exitCode___ -eq 2 ]]; then
        echo 2...
    else
        echo 3...
    fi
}
```

# 日志
## 导入并使用日志
- 日志级别，及其大小关系
    ```
    DEBUG < INFO < WARN < ERROR < FATAL
    ```
- 导入并使用
    ```sh
    source "$(cd `dirname $0`; pwd)/boot.sh"

    import log/log

    Log::DEBUG 'test debug'
    Log::INFO 'test info'
    Log::WARN 'test warn'
    Log::ERROR 'test error'
    Log::FATAL 'test fatal'
    ```

## 自动加载log输出器
### 自动加载默认的控制台log输出器
- 使用方式
    - 使用默认
    ```sh
    source "$(cd `dirname $0`; pwd)/boot.sh"

    # 加载默认控制台log输出器
    import log/logger/console

    Log::DEBUG 'aaa'
    Log::INFO 'bbb'
    Log::WARN 'ccc'
    Log::ERROR 'ddd'
    Log::FATAL 'eee'
    ```

- 默认log输出器的log模版
    ```sh
    ${time} [${level}] Method:[${shell} ${method}] msg:${msg}
    ```

- `time` 参数的格式化字符串: `yyyy/MM/dd HH:mm:ss`

- 可显示的日志级别: `DEBUG`

## 自动加载 log.properties 配置，并生成log输出器
- 使用方式和 `log4j` 类似
    1. 需要添加配置文件：`resources/log.properties`
    2. 配置log输出器，可以配置多个
    3. 在shell中调用 `Log::DEBUG` 等方法，就可以将日志输出到配置好的 log 输出器中

- 配置文件的搜索过程
    1. 优先加载与 **启动 shell** 在同级目录下的 `resources/log.properties`
    2. 如果 1 没有找到，则使用默认的配置文件 `shboot/resources/log.properties`
    3. 如果 2 也没有找到，将会自动加载默认的控制台log输出器

- 使用方式
    ```sh
    source "$(cd `dirname $0`; pwd)/boot.sh"

    import log/logger/auto

    Log::DEBUG 'aaa'
    Log::INFO 'bbb'
    Log::WARN 'ccc'
    Log::ERROR 'ddd'
    Log::FATAL 'eee'
    ```

- 默认log输出器的log模版
    ```sh
    ${time} [${level}] Method:[${shell} ${method}] msg:${msg}
    ```

- `time` 参数的格式化字符串: `yyyy/MM/dd HH:mm:ss`

- 可显示的日志级别: `DEBUG`

## log.properties 配置方法
### 默认log输出器的配置
- 现在只提供三种
    1. `Console`，在控制台打印日志
    2. `RandomAccessFile`，输出到指定文件
    3. `RollingFile`，滚动日志，需要手动配置滚动策略
- 配置说明
    ```sh
    ### 设置 ###
    # rootLogger = 日志级别, appenderName1,appenderName2...
    rootLogger = debug,stdout,RAF
    # 1. 这里配置了 stdout,RAF，加载时，将会忽略下面的 RF

    # 2. 以下所有 appender，如果设置了 Threshold，
    # 将会覆盖 rootLogger 中的日志级别
    
    ######################## Console ########################
    # 1. 配置输出器类型，需要注意大小写
    appender.stdout = Console
    # 2. 输出目标：标准输出+标准异常，现在只提供这一个输出目标。
    # 默认的输出目标，可以不配置
    appender.stdout.Target = STDERR
    # 3. 日志输出的最小级别
    appender.stdout.Threshold = DEBUG
    # 4. 日志输出内容的模版字符串
    appender.stdout.LogPattern = ${time}{%Y/%m/%d %H:%M:%S} [${level}] Method:[${shell}--${method}] msg:${msg}

    ######################## RandomAccessFile ########################
    # 1. 配置输出器类型，需要注意大小写
    appender.RAF = RandomAccessFile
    # 2. 配置log文件路径
    appender.RAF.FileName = /logstest/${yyyy}/${MM}/${dd}/log-${time}{yyyy-MM-dd}.log
    # 3. 启动时，文件的处理方式
    # true: 不做处理，输出的 log 添加到文件末尾
    # false: 启动后，将文件内容清空。输出的 log 添加到文件末尾
    appender.RAF.Append = true
    # 4. 日志输出的最小级别
    appender.RAF.Threshold = DEBUG
    # 5. 日志输出内容的模版字符串
    appender.RAF.LogPattern = ${time}{yyyy/MM/dd HH:mm:ss.SSS} [${level}] Method:[${shell}--${method}] Message:${msg}

    ######################## RollingFile ########################
    # 1. 配置输出器类型，需要注意大小写
    appender.RF = RollingFile
    # 2. 配置log文件路径
    appender.RF.FileName = /logstest/${yyyy}/${MM}/${dd}/log-${time}{yyyy-MM-dd}.log
    # 3. 日志滚动时，旧日志的保存路径
    appender.RF.FilePattern = /logstest/${yyyy}/${MM}/${dd}/log-${time}{yyyy-MM-dd}-${i}.log
    # 4. 日志输出的最小级别
    appender.RF.Threshold = DEBUG
    # 5. 日志输出内容的模版字符串
    appender.RF.LogPattern = ${time}{yyyy/MM/dd HH:mm:ss.SSS} [${level}] Method:[${shell}--${method}] Message:${msg}
    # 6. 日志滚动的策略
    # 6.1-6.3 必须设置一个，否则无法启动。并且，如果设置了6.3值只能是 true

    # 6.1 日志大小
    appender.RF.Policies.SizeBasedTriggeringPolicy = 20MB
    # 6.2 滚动日志的时间
    appender.RF.Policies.TimeBasedTriggeringPolicy = 10h
    # 6.3 是否按天执行日志滚动
    appender.RF.Policies.DailyTriggeringPolicy = true
    # 6.4 是否在启动时执行滚动策略
    appender.RF.Policies.OnStartupTriggeringPolicy   = true
    ```

### 各种模版中的${time}
- 如果只写了 `${time}`，打印日志时，会默认将当前时间格式化为: `yyyyMMdd-HHmmss` 的格式
- `${time}{}`，如果第二个 `{}` 内没有写日期格式字符串，将会使用默认值
- 日期格式字符串的可用内容，请参照: [日期格式化字符串](#日期格式化字符串)

### LogPattern 中提供的可用参数
- 可用参数

    |参数|内容|默认值|
    |-|-|-|
    |`${time}`, 或`${time}{日期格式字符串}`|日期|`yyyyMMdd-HHmmss`|
    |`${level}`|日志级别|DEBUG|
    |`${shell}`|执行输出日志操作的 shell||
    |`${method}`|执行输出日志操作的 method||
    |`${msg}'`|日志内容||

- 每个参数，在 `LogPattern` 配置中都可以重复使用
    - 填充 `LogPattern` 之前，会在环境中先创建好这些参数，然后通过 `eval` 实现填充

### FileName 中提供的可用参数
- 可用参数

    |参数|内容|默认值|
    |-|-|-|
    |`${time}`, 或`${time}{日期格式字符串}`|日期|`yyyyMMdd-HHmmss`|
    |`${yyyy}`|4 位年||
    |`${yy}`|2 位年||
    |`${MM}`|2 位月||
    |`${dd}'`|2 位日期||

- 每个参数，在 `FileName` 配置中都可以重复使用
    - 填充 `FileName` 之前，会在环境中先创建好这些参数，然后通过 `eval` 实现填充

### FilePattern 中提供的可用参数
- 可用参数

    |参数|内容|默认值|
    |-|-|-|
    |`${time}`, 或`${time}{日期格式字符串}`|日期|`yyyyMMdd-HHmmss`|
    |`${yyyy}`|4 位年||
    |`${yy}`|2 位年||
    |`${MM}`|2 位月||
    |`${dd}'`|2 位日期||
    |`${i}'`|日志滚动的数量||

- 对于 `${i}'` 以外的参数，在 `FilePattern` 配置中都可以重复使用
    - 填充 `FilePattern` 之前，会在环境中先创建好这些参数，然后通过 `eval` 实现填充

- 内置变量 `${i}`，**只能使用在文件上，不能使用在路径中。**如果使用在路径中，将会抛出异常并强制停止

## 注册与清除
### 清除所有已注册的 Appender
```sh
source "$(cd `dirname $0`; pwd)/boot.sh"

import log/registry

Log::ClearAllAppenders
```

### 清除指定名称的 Appender
```sh
source "$(cd `dirname $0`; pwd)/boot.sh"

import log/registry

# 清除名称为 xx 的 appender
Log::RemoveAppender 'xx'
```

### 执行过程中重新加载
```sh
source "$(cd `dirname $0`; pwd)/boot.sh"

import log/log
import log/load

Log::INFO 'msg1'

Log::ReLoadAppender

Log::INFO 'msg2'
```

### 注册 Console
```sh
source "$(cd `dirname $0`; pwd)/boot.sh"

import log/base
import log/registry

Log::AppenderRegistry 'name' 'Console' \
  -LogPattern='${time}{yyyy/MM/dd HH:mm:ss.SSS}--${time} [${level}] Method:[${shell}--${method}] Message:${msg}' \
  -Threshold='INFO'

Log::DEBUG 'test'
```

### 注册 RandomAccessFile
```sh
source "$(cd `dirname $0`; pwd)/boot.sh"

import log/base
import log/registry

Log::AppenderRegistry 'name' 'RandomAccessFile' \
  -logPattern='${time}{yyyy/MM/dd HH:mm:ss.SSSS} [${level}] Method:[${shell}--${method}] Message:${msg}' \
  -threshold='DEBUG' \
  -fileName='/logtest/${yyyy}/${MM}/${dd}/log-${time}{yyyy-MM-dd}.log' \
  -append='true'

Log::DEBUG 'test'
```

### 注册 RollingFile
```sh
source "$(cd `dirname $0`; pwd)/boot.sh"

import log/base
import log/registry

Log::AppenderRegistry 'name' 'RollingFile' \
  -LogPattern='${time}{yyyy/MM/dd HH:mm:ss.SSSS} [${level}] Method:[${shell}--${method}] Message:${msg}' \
  -Threshold='DEBUG' \
  -FileName='/logtest/${yyyy}/${MM}/${dd}/log-${time}{yyyy-MM-dd}.log' \
  -FilePattern='/logtest/${yyyy}/${MM}/${dd}/log-${time}{yyyy-MM-dd}-${i}-${i}.log' \
  -PoliciesOnStartupTriggeringPolicy=true \
  -PoliciesSizeBasedTriggeringPolicy=20MB \
  -PoliciesTimeBasedTriggeringPolicy=20m \
  -PoliciesDailyTriggeringPolicy=true

Log::DEBUG 'test'

```

# 日期处理
## 实现方式
因为 `strftime` 不支持毫秒以后的时间单位，所以全部使用外部指令 `date` 实现

## 日期格式化字符串
- 可以使用现代的日期格式化字符串，底层会自动将这些字符串转换成 `date` 指令可以识别的参数

- 内置提供的日期格式化字符串，及其与 `date` 指令参数的对应关系

    |格式化字符串|date指令|含义|
    |-|-|-|
    |yyyy|%Y|4 位年|
    |yy|%y|2 位年|
    |MM|%m|2 位月|
    |dd|%d|2 位日期|
    |hh|%l|12小时制的小时，表示范围:`1-12`|
    |HH|%H|24小时制的小时，表示范围:`0-23`|
    |mm|%M|分钟|
    |ss|%S|秒|
    |S|%N|纳秒。n位S将会显示n位的纳秒数值。最多支持**9位**|
    |F|%w|星期，表示范围:`0-6`，`0`表示周日|
    |E|%A|星期(全称)|
    |D|%j|一年中的第几天|
    |w|%U|一年中第几个星期|
    |a|%P|`AM`、`PM` 标记符|
    |z|%Z|时区|

# CLI
## 使用 shboot 提供的默认 CLI
- 启动 CLI
    ```sh
    bash boot/cli.sh
    ```
- 启动后可以使用 `import` 来导入 `lib`，或者其他的功能
- 导入后可以执行相关的函数
- 通过输入 `exit` 或者 `CTRL + C` 来停止 CLI

## 自定义 CLI 程序
- 使用方法
    ```sh
    source "$(cd `dirname $0`; pwd)/boot.sh"

    # 导入CLI启动函数
    import cli/base

    # 自定输入内容的处理函数，第一个参数需要用来接收控制台的输入内容
    flow(){
        # flow 'input'
        ...
    }

    CLI::StartWithHandlerFunction 'cli的名字' flow
    ```
- cli 每次的显示显示内容为: `cli的名字> `，如果需要设置与当前状态相关的内容可以设置全局变量 `CLI_TITLE`
    - 使用方式
        ```sh
        source "$(cd `dirname $0`; pwd)/boot.sh"
        import cli/base

        export CLI_TITLE='1234'
        CLI::StartWithHandlerFunction 'mycli' flow
        # 控制台将会显示 mycli(1234)>
        ```
    - 可以在自定义实现的全局范围中设置 `CLI_TITLE`，也可以根据输入内容，**在自定义处理函数中设置** `CLI_TITLE`

# 工具函数 lib/
## lib/array
- `import array/base`
    - `Array::Contains "target" "${list[@]}"`
        - 检查集合 `list` 中是否包含 `target`
        - 如果 list 是用 `IFS` 连接的字符串时的调用方法
            ```sh
            IFS=$'\n'
            a='aaa'$IFS'bbb'$IFS'ccc'$IFS'ddd'
            # $a 两边不能添加双引号，否则会被识别成一个字符串
            Array::Contains 'aa' $a
            ```
    - `Array::Remove "target" "${list[@]}"`
        - 从 `list` 中删除 `target`，并返回新的数组
        - 数组的调用方式
            ```sh
            a=( aaa bbb ccc )
            a=( $(Array::Remove 'aaa' "${a[@]}") )
            ```
        - `IFS` 连接的字符串的调用
            ```sh
            IFS=$'\n'
            a='aaa'$IFS'bbb'$IFS'ccc'$IFS'ddd'
            # $a 两边不能添加双引号，否则会被识别成一个字符串
            a=$(Array::Remove 'aaa' $a)
            ```
    - `Array::Join 'joinStr' "${array[@]}"`
        - 用 `joinStr` 连接数组的每一个元素，并返回连接结果
        - 其他调用方式: `Array::Join 'joinStr' 'aaa' 'bbb' 'ccc'`
    - `Array::Remove "target" "${array[@]}"`
        - 从数组中删除指定元素，**并返回新的数组**

## lib/date
- `import date/base`
    - `Date::ToShellDateFormat 'yyyy/MM/dd'`
        - 将日期格式字符串转化为 `date` 指令的参数
    - `Date::NowTimestamp`
        - 获取当前时间的时间戳
        - 时间戳的组成: `seconds(10位) + nanos(9位)`
        - 如：`1630735380012620800`
    - `Date::NowSecond`
        - 获取从 Epoch 到当前时间的秒数
    - `Date::FormatNow 'foramt'`
        - 格式化当前日期
        - `format` 可以是：日期格式化字符串，或者 `date` 指令的参数
    - `Date::Format 'timestamp/second' 'format'`
        - 格式化指定时间戳
        - `format` 可以是：日期格式化字符串，或者 `date` 指令的参数
    - `Date::TodayZeroAMTimestamp`
        - 获取当前日期的 0 点时间戳
    - `Date::TodayZeroAMSecond`
        - 获取从 Epoch 到当前日期的 0 点经过的秒数
    - `Date::ZeroAMTimestamp 'timestamp/second'`
        - 获取到**指定时间戳对应的那一天的** 0 点的时间戳
    - `Date::ZeroAMSecond 'timestamp/second'`
        - 获取从 Epoch 到**指定时间戳对应的那一天的** 0 点的秒数
    - `Date::TimeUnitStrToSeconds 'timeUnitStr'`
        - 将日期字符串转换成**秒数**
        - 支持的单位
            - d, 天
            - H, 小时
            - m, 分钟
            - s, 秒
        - 不支持的单位将会返回 0
        - 目前只支持**使用一个单位的数值**，如：`10d`, `5H`

## lib/file
- `import file/base`
    - `File::TryTouch 'filePath'`
        - 创建一个文件
            - 将会先创建目录，然后在创建文件
        - 如果无法创建，将会返回对应的 exitCode
    - `File::IsFilePathStr 'path'`
        - 检查一个路径是不是文件路径
        - 如果结尾不是 `/` 或者 `..`，将会 `return 0`
        - 执行判断：`if ! File::IsFilePathStr "$path"; then`

    - `File::ClearFile 'filePath'`
        - 清空一个文件
    - `File::ATime 'filePath'`
        - 获取一个文件的 `Access Time`
        - 返回从 Epoch 到 `Access` 的秒数

    - `File::MTime 'filePath'`
        - 获取一个文件的 `Modify Time`
        - 返回从 Epoch 到 `Modify` 的秒数

    - `File::CTime 'filePath'`
        - 获取一个文件的 `Change Time`
        - 返回从 Epoch 到 `Change` 的秒数

    - `File::Basename 'path'`
        - 使用内置方法，从路径中获取 basename
    - `File::Dirname 'path'`
        - 使用内置方法，获取一个路径的目录
    - `File::AbsPath 'relative filename'`
        - 获取一个文件路径的绝对路径
        - 返回值
            - 如果 `filename` 是一个以 `/` 开头的绝对路径，则直接返回原始值
            - 如果 `filename` 是一个以 `./` 开头的相对路径，将会自动**去掉`./`，并在前面拼接调用位置所在的目录**
            - 如果是其他的情况，直接在**前面拼接调用位置所在的目录**，这种情况获取的绝对路径**可能不正确**
    - `File::CanCreateFileInDir 'dir'`
        - 检查能否在指定的路径下创建文件
        - 执行判断: `if File::CanCreateFileInDir 'dir'; then`
    - `File::GrepCountFromDir 'path' 'regexOfFilename'`
        - 在指定路径下，检查符合规则的文件数量
        - 如果 `path` 不存在，默认返回 `0`
    - `File::GrepCountFromFilePath 'filePathRegex'`
        - 检查符合 `filePathRegex` 规则的文件数量
    - `File::FileSize 'filePath'`
        - 获取文件的大小，单位 `B`
    - `File::SizeUnitStrToSize 'sizeUnitStr'`
        - 将存储容量字符串转换成**Byte单位**
        - 支持的单位
            - B, b
            - KB, kb
            - MB, mb
            - GB, gb
            - TB, tb
            - PB, pb
    - `File::TryWrite 'text' 'filePath'`
        - 将 `text` 写入文件。如果文件中已经存在 `text`，则不写入
    - `File::TryAppendFileTo 'f1Path' 'f2Path'`
        - 将 `f1Path` 文件中的内容写入 `f2Path`

- `import file/properties`
    - `Properties::Read 'filePath'`
        - 读取 `*.properties` 文件，返回一个数组
        - 返回内中，只返回非空行，非 `#` 开头的行
        - 返回之后会变成一个字符串，需要在调用的位置重新转换成数组
            ```sh
            local a=( $(Properties::Read 'xxx/yyy.properties') )
            ```
        - 返回结果也可以不做转换，直接进行迭代
            ```sh
            local a=$(Properties::Read 'xxx/yyy.properties')

            local b
            for b in ${a[@]}; do
              echo "$b"
            done
            ```
    - `Properties::GetKeyAndValue 'filePath'`
        - 读取 properties 文件，并按顺序返回文件中的 key + value
            - 如果没有设置 value，将会抛出异常
            - **方法内部抛出的异常将会终止整个shell 的运行，所以应该在 shell 的启动阶段执行，不应该在持续执行的阶段执行**
        - 返回的数组中，每两个为一组，第一个是 key，第二个是 value
            - 使用时，可以配合 `shift 2` 来使用
            - 结果示例
                ```sh
                # properties 文件示例
                a=aaa
                b=bbb
                ```
                ```sh
                # 解析结果
                result=( 'a' 'aaa' 'b' 'bbb')
                ```


## lib/relect
- `import relect/base`
    - `Reflect::isFunction 'functionName'`
        - 检查字符串是不是函数
        - 执行判断 `if Reflect::isFunction 'functionName';then`
    - `Reflect::isCommand`
        - 检查指定命令是否存在
        - 返回值
            - 0: 存在
            - 1: 不存在
        - 使用方法
            ```sh
            # 输出:is command
            if Reflect::isCommand grep; then
                echo 'is command'
            else
                echo 'is not command'
            fi

            # 输出:is not command
            if Reflect::isCommand xxx; then
                echo 'is command'
            else
                echo 'is not command'
            fi
            ```

## lib/string
- `import string/base`
    - `String::Trim ' xxx '`
        - 去除字符串前后的空格
    - `String::StartsWith "source" "target"`
        - 检查字符串 `source` 是否以 `target` 开头
        - 执行检查: `if String::StartsWith "abc" "ab"`
    - `String::EndsWith "source" "target"`
        - 检查字符串 `source` 是否以 `target` 结尾
        - 执行检查: `if String::EndsWith "abc" "ab"`
    - `String::Contains "source" "target"`
        - 检查字符串 `source` 中是否包含 `target`
        - 执行检查: `if String::Contains "abcd" "bc"`
    - `String::LJust 'width' 'string' 'fillchar'`
        - 字符串左对齐，并在右侧使用指定字符填充到指定长度
        - 参数
            - width，对齐后的长度
            - string，字符串
            - fillchar，填充字符
    - `String::LJust 'width' 'string'`
        - 字符串左对齐，并在右侧使用**空格**填充到指定长度
        - 参数
            - width，对齐后的长度
            - string，字符串

- `import string/regex`
    - `Regex::Matcher "source" "pattern" num`
        - 使用正则表达式匹配，并返回第 `num` 个匹配结果
    - `Regex::Matcher "source" "pattern"`
        - 使用正则表达式匹配，并返回**所有的**匹配结果
    - `Regex::IsInteger 'string'`
        - 检查 `string` 是不是一个整数，开头可以是正负号:`+`, `-`

## lib/console
- `import console/base`
    - `Console::EchoWithColor 'Color_Background' 'Color_Text' 'text'`
        - 输出文字到控制台，需要手动设置背景色 + 文字颜色
    - `Console::EchoRed "text"`
        - 输出文字到控制台，背景色: 黑，文字颜色: 红
    - `Console::EchoGreen "text"`
        - 输出文字到控制台，背景色: 黑，文字颜色: 绿
    - `Console::EchoYellow "text"`
        - 输出文字到控制台，背景色: 黑，文字颜色: 黄
    - `Console::EchoBule "text"`
        - 输出文字到控制台，背景色: 黑，文字颜色: 蓝
    - `Console::EchoPurple "text"`
        - 输出文字到控制台，背景色: 黑，文字颜色: 紫
    - `Console::EchoLightBlue "text"`
        - 输出文字到控制台，背景色: 黑，文字颜色: 浅蓝
    - `Console::EchoWhite "text"`
        - 输出文字到控制台，背景色: 黑，文字颜色: 白
- `import console/color`
    - 信息输出到控制台时，可以使用的背景色
        ```sh
        Color_BG_Black
        Color_BG_Red
        Color_BG_Green
        Color_BG_Yellow
        Color_BG_Bule
        Color_BG_Purple
        Color_BG_LightBlue
        Color_BG_White
        # 黑色
        Color_BG_Default
        ```
    - 信息输出到控制台时，可以使用的文字颜色
        ```sh
        Color_Text_Black
        Color_Text_Red
        Color_Text_Green
        Color_Text_Yellow
        Color_Text_Bule
        Color_Text_Purple
        Color_Text_LightBlue
        Color_Text_White
        # 白色
        Color_Text_Default
        ```

## lib/number
- `import number/base`
    - `Number::Compare 'num1' 'num2'`
        - 返回两个数值(整数或小数) num1、num2 的大小关系
        - 返回值
            ```
            1 num1 > num2
            0 num1 == num2
            -1 num1 < num2
            ```
    - `Number::Max 'num1' 'num2'`
        - 返回两个数值(整数或小数) num1、num2 中的最大值
    - `Number::Eq 'num1' 'num2'`
        - 检查 `num1 == num2`
        - 返回值，`true` 返回 `0`，`false` 返回 `1`
    - `Number::Ne 'num1' 'num2'`
        - 检查 `num1 != num2`
        - 返回值，`true` 返回 `0`，`false` 返回 `1`
    - `Number::Gt 'num1' 'num2'`
        - 检查 `num1 > num2`
        - 返回值，`true` 返回 `0`，`false` 返回 `1`
    - `Number::Lt 'num1' 'num2'`
        - 检查 `num1 < num2`
        - 返回值，`true` 返回 `0`，`false` 返回 `1`
    - `Number::Ge 'num1' 'num2'`
        - 检查 `num1 >= num2`
        - 返回值，`true` 返回 `0`，`false` 返回 `1`
    - `Number::Le 'num1' 'num2'`
        - 检查 `num1 <= num2`
        - 返回值，`true` 返回 `0`，`false` 返回 `1`

## lib/cli
- `import cli/base`
    - `CLI::StartWithHandlerFunction 'cli的名字' flow`
        - 启动自定义控制台程序
    - `CLI::LoopAskYesOrNo 'msg'`
        - 循环询问 yes 或者 no
        - 输入 `y` 返回 `0`，输入 `n` 返回 `1`
        - 使用方式
            ```sh
            result=`CLI::LoopAskYesOrNo 'msg'`

            if CLI::LoopAskYesOrNo 'msg'; then
            fi
            ```

# 扩展工具 ext/

## ext/linuxcore
- `import ext/linuxcore/version`
    - `LinuxCore::GetVersionStr`
        - 获取当前 linux 核心的版本的字符串，如: `5.4.157-1.el7.elrepo.x86_64`
        - 使用方法
            ```sh
            verStr=$(LinuxCore::GetVersionStr)
            ```

    - `LinuxCore::GetVersionNum`
        - 参数
            - `$1`:`subVersionCount`，小版本的数量
                - 可以使用 0、1、2
                - 默认值为 1
                - 如果大于 2，将会使用2
        - 返回值（示例）
            - 5 (subVersionCount=0)
            - 5.4 (subVersionCount=1)
            - 5.4.157 (subVersionCount=2)
        - 使用方法
            ```sh
            verNum=$(LinuxCore::GetVersionNum)
            verNum=$(LinuxCore::GetVersionNum 0)
            verNum=$(LinuxCore::GetVersionNum 1)
            verNum=$(LinuxCore::GetVersionNum 2)
            # 超过 2 时，将会自动使用 2
            verNum=$(LinuxCore::GetVersionNum 3)
            ```

    - `LinuxCore::GetMaxCoreVersionStrFromGrub`
        - 从 `/etc/grub2.cfg` 中获取当前机器内最大的 linux 核心版本的版本字符串
        - 使用方法
            ```sh
            verStr=$(LinuxCore::GetMaxCoreVersionStrFromGrub)
            echo $verStr # 如:5.4.157-1.el7.elrepo.x86_64
            ```

    - `LinuxCore::GetMaxCoreVersionNumFromGrub`
        - 从 `/etc/grub2.cfg` 中获取当前机器内最大的 linux 核心版本的版本号
        - 参数
            - `$1`:`subVersionCount`，小版本的数量
                - 可以使用 0、1、2
                - 默认值为 1
                - 如果大于 2，将会使用2
        - 返回值（示例）
            - 5 (subVersionCount=0)
            - 5.4 (subVersionCount=1)
            - 5.4.157 (subVersionCount=2)
        - 使用方法
            ```sh
            verNum=$(LinuxCore::GetMaxCoreVersionNumFromGrub 0)
            echo $verNum # 如:5
            verNum=$(LinuxCore::GetMaxCoreVersionNumFromGrub 1)
            echo $verNum # 如:5.4
            verNum=$(LinuxCore::GetMaxCoreVersionNumFromGrub 2)
            echo $verNum # 如:5.4.157
            verNum=$(LinuxCore::GetMaxCoreVersionNumFromGrub)
            echo $verNum # 如:5.4
            ```
    - `LinuxCore::GetMaxCoreVersionIndexFromGrub`
        - 从 /etc/grub2.cfg 中获取当前机器内最大的 linux 核心版本的索引
        - 返回值
            - 索引值，从 0 开始
        - 使用方法
            ```sh
            maxVerIdx=$(LinuxCore::GetMaxCoreVersionIndexFromGrub)
            ```

## docker
- 需要系统中存在 `docker` 指令
- `import docker/base`
    - `Docker::LocalImgExist 'imgName'`
        - 检查**本地存储**中是否存在指定镜像
        - 参数 `repositoryName` 中可以包含 `tag`, 如`xxx:latest`
    - `Docker::LocalImgTagExist 'imgName' 'tag'`
        - 检查存储中是否存在指定镜像的某个 `tag` 版本
    - `Docker::CreateContainerSimple 'containsName' 'imgName' 'tag' 'volumeOutterPath' 'volumeInnerPath'`
        - 创建一个镜像，需要提供镜像的 tag 和volume