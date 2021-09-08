# 需要保存的值
- filePattern，日志滚动时，旧日志的保存路径
- fileName, 日志文件名
- threshold，日志级别
- logPattern，日志输出内容的模版字符串
- todayZeroAMSecond，零点的秒数
- lastRollingSecond，上次滚动的时间
    - `timeBasedTriggeringPolicy`, `dailyTriggeringPolicy` 这两个策略共享这一个滚动时间
- 滚动策略
    - onStartupTriggeringPolicy
    - sizeBasedTriggeringPolicy
    - timeBasedTriggeringPolicy
    - dailyTriggeringPolicy

# filePattern详细解析方式
- filePattern ---内置变量 ${i}，只能使用在文件上，不能使用在路径中
- 将 ${i} --> %i
- 填充 realFilePattern ---> realFilePatternPath
- 从 realFilePatternPath 中获取目录 realFilePatternDir
- 如果 realFilePatternDir 不存在，则尝试创建。如果无法创建则抛出异常，并终止运行
- 因为无法直接进行文件的创建，所以需要检查：能否在当前路径下创建文件。如果无法创建，则需要抛出异常
- 检查路径下的文件数量, 并保存（每次滚动时取出，然后+1，然后在重新保存）

# 启动时的处理
1. todayZeroAMSecond
    - 初始为启动时的日期
    - 每次输出日志的时候需要检查
2. rollingCount
    - 不保存，每次滚动的时候执行计算
        - 因为路径可能需要新建
3. filePattern
    - 提前处理
        - 需要提前将 `${i}` --> `%i`，防止填充环境参数时，`${i}` 变成空
        - 目录部分不能有 ${i}
    - 需要有目录的创建权限
    - 需要有文件的创建权限
4. fileName
    - 填充环境参数
5. onStartupTriggeringPolicy
    - 如果是 true，需要其他三个滚动策略的属性
    - 如果 fileName 存在，则获取 fileName 的 MTime
        - dailyTriggeringPolicy = true
            - 如果 MTime <= todayZeroAMSecond ，进行滚动
        - timeBasedTriggeringPolicy 存在，并且之前没有发生滚动
            - 如果 Now - MTime >= timeBasedTriggeringPolicy ，进行滚动
        - sizeBasedTriggeringPolicy 存在，并且之前没有发生滚动
            - 获取 fileName 的大小 fileNameSize
            - 如果 fileNameSize >= sizeBasedTriggeringPolicy，进行滚动
    - 如果发生了滚动，更新 lastRollingSecond 为当前的时间戳
6. lastRollingSecond
    - 启动时
        - 如果已经有值了，则直接保存（如果 4 中发生了滚动）
        - 如果没有值
            - 如果 fileName 不存在，则使用启动的时间
            - 如果 fileName 存在，则使用 fileName 的 MTime
    - 每次滚动的时候重新生成
7. fileName
    - 初始化日志文件

# 输出日志与判断日志滚动

- dailyTriggeringPolicy = true
    - 获取当前的 zeroAMSecond
    - 如果 zeroAMSecond != todayZeroAMSecond ，进行滚动
    - 如果滚动了，更新 todayZeroAMSecond=ZeroAMSecond
- timeBasedTriggeringPolicy 存在，并且之前没有发生滚动
    - 如果 Now - lastRollingSecond >= timeBasedTriggeringPolicy ，进行滚动
- sizeBasedTriggeringPolicy 存在，并且之前没有发生滚动
    - 获取 fileName 的大小 fileNameSize
    - 如果 fileNameSize >= sizeBasedTriggeringPolicy，进行滚动

- 如果发生了滚动，更新 lastRollingSecond 为当前的时间戳

- 初始化日志文件

- 输出日志

# 滚动文件的过程
1. 计算 filePattern 对应的路径下的符合规范的文件数量 `i`
2. `i++`，作为这一次的数量
3. 执行 mv
