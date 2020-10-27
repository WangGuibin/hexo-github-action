------
title: "Mac内网穿透工具Ngrok的使用"
date: 2020-10-27 20:42:50
tags: [内网穿透,webServer,工具使用]
published: true
isTop: false
------
##  背景

基于陈胖接了一个web项目,客户要求他用花生壳内网穿透给他们做演示预览, 然鹅Mac天然并没有花生壳这个软件~ 。

本着学习的态度,寻思着肯定有其他替代方案,然后就发现了`Ngrok`这个工具,这里记录一下使用的方法,特水此一文。

##  下载安装

1. [下载地址](https://ngrok.com/download)

2. 解压后发现是一个`shell`程序,然后执行`chmod a+x ngrok`增加执行权限

3. 配置到环境变量,直接把可执行文件放到shell脚本目录`MyShell`下即可

   ```
   # shell脚本如何全局使用（不用cd到脚本目录下）？
   
   > 本质是访问环境变量，好多第三方脚本工具都是全局配置的，一般需要在`~/.zshrc`或者`~/.bash_profile`里配置访问路径的环境变量，形如 
   ​```shell
   #其中`/Users/mac`是根目录即`$HOME` 可根据实际情况配置 这里电脑用户名为`mac` 
   export PATH=/Users/mac/flutter/bin:$PATH #拼到最前面
   export PATH=$PATH:/Users/mac/MyShell #拼到最后面
   ​```
   1. 写好一个工具脚本，并命名为`common_tool` (PS:`common_tool.sh`简化命令的时候需要把后缀也加上其效果和无后缀是一样的)
   2. 建立一个目录用于存储脚本工具，这里命名为`MyShell`,并把`common_tool`放入该目录下
   3. 进入`MyShell`目录下，把`common_tool`脚本的执行权限打开 `chmod +x common_tool`
   4. 查看命令`common_tool` 
    
   ​```shell
   which common_tool
   /Users/mac/MyShell/common_tool
   ​```
   5. 执行命令 `common_tool`  
   ​```shell
   common_tool + 回车即可看见效果
   ​```
   
   ```

## 开启本地webServer服务

开启webserver方式有很多,可以参考[盘点Mac上搭建本地WebServer的几种方式](https://www.cnblogs.com/wgb1234/p/12466122.html) ,这里采用最为简单的方法即Python的一条命令

```bash
cd 到放web项目的index.html所在的入口目录
执行python -m http.server 8080即可开启webServer服务
```



## 使用Ngrok穿透工具映射本地webServer地址

```bash
ngrok http localhost:8080  即可
```

```bash
#即可获取映射后的根目录地址
http://4dfcioxc4.ngrok.io 
https://4dfcioxc4.ngrok.io  #iOS不支持https Mac支持
```