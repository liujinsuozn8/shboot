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

