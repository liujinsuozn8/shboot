# shboot

# 参考
- https://github.com/niieani/bash-oo-framework
	- import 加载系统，基本上都是从这里借鉴的
    - 调整了函数声明的语法，使得通过 `sh` 指令也能够调用
    - `src/oo-bootstrap.sh` 下对 `source`, `.` 做了修改，这里删掉了，只保留了 `import`
    - 暂时不考虑**面向对象的特性**，虽然很好用，但是我更倾向于面向过程变成，并提供更多的工具方法
- https://github.com/tomas/skull
- https://github.com/niieani/bash-oo-framework/lib/oo-bootstrap.sh
  - 一些基础方法的实现

# Function

|Name|Dicribe|Usage|Path|
|-|-|-|-|
|Builtin::Basename|same as basename|Builtin::Basename "path" ["fileSuffix"]|lib/system/builtin/fun.sh|
|Builtin::Dirname|same as dirname|Builtin::Dirname "path"|lib/system/builtin/fun.sh|
|Builtin::AbsPath|Convert relative path to absolute path|Builtin::AbsPath 'relative filename'|lib/system/builtin/fun.sh|
|String::Trim|trim whitespace|String::Trim ' xxx '|lib/string/base.sh|
|String::StartsWith|trim whitespace|if String::StartsWith "$a" "$b"|lib/string/base.sh|


# 日志
- 日志级别关系
    ```
    DEBUG < INFO < WARN < ERROR < FATAL
    ```
- 日志信息中可用的参数
    - `${time}`, 日期
    - `${level}`, 日志级别
    - `${shell}`, 执行输出日志操作的 shell 名
    - `${method}`, 执行输出日志操作的 method 名
    - `${msg}'`, 日志内容

# 内置变量
- PROJECT_ROOT，当前工程的根目录

# 日期处理
## 日期变换

  y 年 yyyy=%Y, yy=%y
  M 月 MM=%m
  d 日 dd=%d
  h 时 在上午或下午 (1~12), hh=%l
  H 时 在一天中 (0~23) HH=%H
  m 分 mm=%M
  s 秒 ss=%S
  S 毫秒 
  F 周几 %w
  E 星期(全称)    len=1   %A
  D 一年中的第几天  %j
  w 一年中第几个星期 %U
  a 上午 / 下午 标记符 %P
  z 时区 %Z

---------------------------------

  y year  yyyy=%Y, yy=%y
  M month MM=%m
  d day dd=%d
  h hour (1~12)  hh=%l
  H hour (0~23) HH=%H
  m minute mm=%M
  s second ss=%S
  S milli second --> handler by Date::Format
  F day of week %w
  E week of year    len=1   %A
  D day of year  %j
  w week of year %U
  a AM./PM. %P
  z zone %Z date '+%Z'