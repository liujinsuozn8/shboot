# 处理复杂函数参数的的模版

```sh
while [ $# -gt 0 ];do
    case "$1" in
        --help)
            usage
            exit 0
        ;;
        *)
            echoerr "$1 can not analyze !!! please get help by [ --help ]"
            errend
        ;;
    esac
    shift 2
done
```