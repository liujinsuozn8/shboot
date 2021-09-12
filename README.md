# shboot

# 参考
- https://github.com/niieani/bash-oo-framework
    - import 加载系统，基本上都是从这里借鉴的
    - 只保留了 `import` 一个加载函数
    - 暂时不考虑**面向对象的特性**，虽然很好用，但是我更倾向于面向过程，并提供更多的工具方法
- https://github.com/tomas/skull
- https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh
- https://github.com/dylanaraps/pure-bash-bible
    - 一些基础方法的实现
    - 中文版本：https://gitee.com/bingios/pure-bash-bible-zh_CN

# 系统中必须要包含指令
- stat
- awk
- grep
- date

# 开发过程中需要注意的问题
- [/shboot/memo/zh](/shboot/memo/zh)

# 在自定义 shell 中引入 shboot
1. 使用当前工程，作为启动工程。或者将 `lib` 目录拷贝到自定义目录下
2. 在 `lib` 的同级目录下创建自定义 shell
3. 在自定义 shell 中引入 `shboot`
    ```sh
    # 这里将自定义 shell 保存到了 lib 的同级目录下！！！
    source "$(cd `dirname $0`; pwd)/lib/boot.sh"
    ```

# import 导入其他 shell
- 导入方式
    ```sh
    source "$(cd `dirname $0`; pwd)/lib/boot.sh"

    # 如果 shell 的扩展名是 .sh，导入时可以不写
    # 导入 lib 包下的shell
    import 'string/base'
    import 'string/regex.sh'

    # 导入与 lib 同级的其他目录下的 shell
    import 'ext/xxx'

    ```

- 可以导入的内容
    1. lib 包下的 shell
    2. 与 lib 包同级的其他目录下的 shell
    3. `http://`, `https://` 开头的路径，会从网络上下载，并导入
        - 为了提高启动速度，不推荐这样导入

- 注意事项
    1. **同样的 shell 只会导入一次**
    2. `lib/system` 下的包在引入 shboot 时，已经导入了，不要重复导入
    3. 如果 shell 的扩展名是 `.sh`，导入时可以不写。否则，**必须标注扩展名**
    4. `import` 实际上执行的是 `source` 处理

# 启动方式
- `bash <自定义shell文件名>.sh`
- 必须通过 `bash` 来启动
- 如果直接用 `./<自定义shell文件名>.sh` 来启动，则需要在shell开头添加 `#!/bin/bash`
- 不能通过 `sh` 启动，因为有些语法 `sh` 无法识别

# 异常处理
## 导入
- 导入 `lib/boot.sh` 后就可以使用异常处理

## 抛出异常
- 通过 `throw` 函数抛出异常。执行后，会直接停止调用的该方法shell
- 内部通过 `kill` 来停止进程，即使是 `result=$(throw '...')` 的方式调用，也可以停止，不会收到子进程的影响

## 捕获异常
- 可以捕获的异常 
    - `throw` 方法抛出的异常
    - `return`、`exit` 返回非 0 值
    - 指令不存在的异常
- 需要注意
    - 在`try{}`内部，`return`、`exit` 如果返回了非 0 值，会立刻停止
    - 可以在`try{}`内部，通过 `if method; then` 的方式来判断指令的结果，防止被当作异常抛出
- 一层 `try...catch`
    ```sh
    source "$(cd `dirname $0`; pwd)/lib/boot.sh"

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
        
        # 如果 catch 中有 return，则执行结果是 return 的结果
        # 如果 catch 中没有 return，则以最后一条指令的结果作为执行结果
        return 3
      }
    }

    # 执行 test 函数，内部将会捕获异常，并进行处理
    test
    echo "result=$?" # 将会输出 3
    
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


# 日志
## 导入并使用日志
- 日志级别，及其大小关系
    ```
    DEBUG < INFO < WARN < ERROR < FATAL
    ```
- 导入并使用
    ```sh
    source "$(cd `dirname $0`; pwd)/lib/boot.sh"

    import log/log

    Log::DEBUG 'test debug'
    Log::INFO 'test info'
    Log::WARN 'test warn'
    Log::ERROR 'test error'
    Log::FATAL 'test fatal'
    ```

## 自动加载log输出器
### 自动加载默认的控制台log输出器
- **如果没有添加配置文件:** `resources/log.properties`，将会自动加载默认的控制台log输出器
- 使用方式
    ```sh
    source "$(cd `dirname $0`; pwd)/lib/boot.sh"

    import log/log

    Log::DEBUG 'aaa'
    Log::INFO 'bbb'
    Log::WARN 'ccc'
    Log::ERROR 'ddd'
    Log::FATAL 'eee'
    ```

- 默认log输出器的log模版
    ```sh
    ${time} [${level}] Method:[${shell}--${method}] Message:${msg}
    ```

- `time` 参数的格式化字符串: `yyyyMMdd-HHmmss`

- 可显示的日志级别: `DEBUG`

### 自动加载 log.properties
- 使用方式和 `log4j` 类似
    1. 需要添加配置文件：`resources/log.properties`
    2. 配置log输出器，可以配置多个
    3. 在shell中调用 `Log::DEBUG` 等方法，就可以将日志输出到配置好的 log 输出器中

- 使用方式
    ```sh
    source "$(cd `dirname $0`; pwd)/lib/boot.sh"

    import log/log

    Log::DEBUG 'aaa'
    Log::INFO 'bbb'
    Log::WARN 'ccc'
    Log::ERROR 'ddd'
    Log::FATAL 'eee'
    ```

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
source "$(cd `dirname $0`; pwd)/lib/boot.sh"

import log/registry

Log::ClearAllAppenders
```

### 清除指定名称的 Appender
```sh
source "$(cd `dirname $0`; pwd)/lib/boot.sh"

import log/registry

# 清除名称为 xx 的 appender
Log::RemoveAppender 'xx'
```

### 执行过程中重新加载
```sh
source "$(cd `dirname $0`; pwd)/lib/boot.sh"

import log/log
import log/load

Log::INFO 'msg1'

Log::ReLoadAppender

Log::INFO 'msg2'
```

### 注册 Console
```sh
source "$(cd `dirname $0`; pwd)/lib/boot.sh"

import log/base
import log/registry

Log::AppenderRegistry 'name' 'Console' \
  -LogPattern='${time}{yyyy/MM/dd HH:mm:ss.SSS}--${time} [${level}] Method:[${shell}--${method}] Message:${msg}' \
  -Threshold='INFO'

Log::DEBUG 'test'
```

### 注册 RandomAccessFile
```sh
source "$(cd `dirname $0`; pwd)/lib/boot.sh"

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
source "$(cd `dirname $0`; pwd)/lib/boot.sh"

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

# 内置变量
- `$PROJECT_ROOT`，`lib`所在的目录
- `$PROJECT_PID`，导入 shboot 的 shell 的进程ID

# 工具函数
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
    