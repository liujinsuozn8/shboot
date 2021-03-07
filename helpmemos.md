- 更换分隔符
    ```sh
    IFS=$(echo -en "\n\b")
    ```
- 计算
    ```sh
    : $((n = $n + 1))

    echo $((n = $n + 1))
    ```

- for循环
    ```sh
    for line in ${xxx[@]};do

    for (( i=0; i<${count}; i++));do
    ```