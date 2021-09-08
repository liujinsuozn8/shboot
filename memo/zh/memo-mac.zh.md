# date 指令
- mac 下的 date 无法提供纳秒，所以只能显示0

# export
对于 mac 使用的类 Unix 系统，在 shell 全局作用域通过 `export` 导出的变量，可以在子 shell 中访问。但是，如果在**函数**中修改了 `export` 导出的变量值，子 shell 无法这个新的值，**子 shell 获取到的仍然是全局作用域中的值**

# stat
- 参考: http://blog.chinaunix.net/uid-8052635-id-5826252.html