# 时间变量名设定
- 如果时间精确到`时分秒`，变量名为 second
- 如果时间精确到`纳秒`，变量名为 timestamp

# 函数返回数组
- 因为将IFS修改成了：`$'\n'`，所以 `printf '%s\n' "${array[@]}"`, `echo "${array[@]}"` 会有不同的行为
    - `printf '%s\n' "${array[@]}"`，可以通过 `( )` 还原为数组
    - `echo "${array[@]}"`，无法还原，被组合成了一个字符串


# 导出数组
- 数组无法导出，子shell无法访问父shell的数组，只能转换成字符串
- 使用字符串替代数组
    - 创建方式
        ```sh
        # 为了防止空格对遍历的影响，需要手动修改 `IFS`
        IFS=$'\n'
        __boot__importedFiles="$__boot__importedFiles"${IFS}"$libPath"
        ```
    - 在函数中传递这样的数组作为参数
        ```sh
        # 直接作为参数
        Builtin::ArrayContains "$libPath" ${__boot__importedFiles}
        ```
    - 可以直接作为数组进行遍历
        ```sh
        for appenderName in ${Log_Global_Appenders[@]}; do
        done
        ```

# import
因为 `import` 函数的 `source` 操作是在一个函数中执行的，所以为了使子shell 也能获取到导入的 shell 中的遍历，**一定要使用 `export` 的方式来声明全局变量**，`declare -x` 无法实现这种功能

# 终止程序
`$()` 内调用的指定中的 `exit 非0值` 无法停止外部的 shell，只能通过 `kill -s TERM "$$"` 来停止

# true/false
- `0=true`
- `1=false`