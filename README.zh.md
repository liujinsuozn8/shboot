# shboot

# 参考
- https://github.com/niieani/bash-oo-framework
    - import 加载系统，基本上都是从这里借鉴的
    - 只保留了 `import` 一个加载函数
    - 暂时不考虑**面向对象的特性**，虽然很好用，但是我更倾向于面向过程变成，并提供更多的工具方法
- https://github.com/tomas/skull
- https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh
- https://github.com/dylanaraps/pure-bash-bible
    - 一些基础方法的实现
    - 中文版本：https://gitee.com/bingios/pure-bash-bible-zh_CN

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

# 日志
## 日志的使用
- 使用方式和 `log4j` 类似
    1. 需要添加配置文件：`resource/log.propertiess`
    2. 配置log输出器，可以配置多个
    3. 在shell中调用 `Log::DEBUG` 等方法，就可以将日志输出到配置好的 log 输出器中

- 日志级别，及其大小关系
    ```
    DEBUG < INFO < WARN < ERROR < FATAL
    ```

- 使用方式
    ```sh
    source "$(cd `dirname $0`; pwd)/lib/boot.sh"

    import log/

    Log::DEBUG 'test debug'
    Log::INFO 'test info'
    Log::WARN 'test warn'
    Log::ERROR 'test error'
    Log::FATAL 'test fatal'
    ```

## 日志的配置方法
### 默认log输出器的配追
- 现在只提供三种
    1. `Console`，在控制台打印日志
    2. `RandomAccessFile`，输出到指定文件
    3. `RollingFile`，滚动日志，需要手动配置滚动策略
- 配置说明
    ```sh
    ### 设置###
    rootLogger = debug,stdout,D,E
    
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
    appender.RF.FilePattern = /logstest/${yyyy}/${MM}/${dd}/log-${time}{yyyy-MM-dd}.log
    # 4. 启动时，文件的处理方式
    # true: 不做处理，输出的 log 添加到文件末尾
    # false: 启动后，将文件内容清空。输出的 log 添加到文件末尾
    appender.RF.Append = true
    # 5. 日志输出的最小级别
    appender.RF.Threshold = DEBUG
    # 6. 日志输出内容的模版字符串
    appender.RF.LogPattern = ${time}{yyyy/MM/dd HH:mm:ss.SSS} [${level}] Method:[${shell}--${method}] Message:${msg}
    # 7. 日志滚动的策略
    # 7.1-7.3 必须设置一个，否则无法启动。并且，如果设置了7.3值只能是 true

    # 7.1 日志大小
    appender.RF.Policies.SizeBasedTriggeringPolicy = 20MB
    # 7.2 滚动日志的时间
    appender.RF.Policies.TimeBasedTriggeringPolicy = 10h
    # 7.3 是否按天执行日志滚动
    appender.RF.Policies.DailyTriggeringPolicy = true
    # 7.4 是否在启动时执行滚动策略
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

- 每个参数，在 `LogPattern` 配置中都可以重复使用
    - 填充 `LogPattern` 之前，会在环境中先创建好这些参数，然后通过 `eval` 实现填充

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

## lib/date
- `import date/base`
    - `Date::ToShellDateFormat 'yyyy/MM/dd'`
        - 将日期格式字符串转化为 `date` 指令的参数
    - `Date::NowTimestamp`
        - 获取当前日期的时间戳
        - 时间戳的组成: `seconds(10位) + nanos(9位)`
        - 如：`1630735380012620800`
    - `Date::FormatNow 'foramt'`
        - 格式化当前日期
        - `format` 可以是：日期格式化字符串，或者 `date` 指令的参数
    - `Date::Format 'timestamp' 'format'`
        - 格式化指定时间戳
        - `format` 可以是：日期格式化字符串，或者 `date` 指令的参数
    - `Date::ZeroAMTimestramp`
        - 获取当前日期的 0 点的时间戳

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

    - `File::MTime 'filePath'`
        - 获取一个文件的 `Modify Time`

    - `File::CTime 'filePath'`
        - 获取一个文件的 `Change Time`
    - `File::Basename 'path'`
        - 使用内置方法，从路径中获取 basename
    - `File::Dirname 'path'`
        - 使用内置方法，获取一个路径的目录
    - `File::AbsPath 'relative filename'`
        - 获取一个文件路径的绝对路径
    

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