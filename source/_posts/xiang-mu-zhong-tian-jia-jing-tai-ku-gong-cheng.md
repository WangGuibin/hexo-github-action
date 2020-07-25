---
title: '项目中添加静态库工程'
date: 2020-04-12 10:38:58
tags: []
published: true
hideInList: false
feature: https://api.lyiqk.cn/purelady?cdd6a546
isTop: false
---
 在项目中添加静态库工程🏭 (方便随时修改)
<!--more-->
## 具体操作步骤如下:

### 1. 创建静态库工程

在`Xcode`里`common + shift + N `再选择如下图指示,然后创建一个`MyLibs`的工程

![](https://images.cnblogs.com/cnblogs_com/wgb1234/1695793/o_2004120224421.png)



如图:

![](https://images.cnblogs.com/cnblogs_com/wgb1234/1695793/o_2004120224482.png)

###  2. 把静态库放到根路径下,然后再`Header search path`指定路径

![](https://images.cnblogs.com/cnblogs_com/wgb1234/1695793/o_2004120224543.png)

### 3. 添加静态库`.a`文件

![](https://images.cnblogs.com/cnblogs_com/wgb1234/1695793/o_2004120224594.png)

### 4. 导入头文件,调用代码,查看调试效果

![](https://images.cnblogs.com/cnblogs_com/wgb1234/1695793/o_2004120225035.png)

### 5.  修改`MyLibs.m`里的方法实现,然后再编译观察改变的效果

![](https://images.cnblogs.com/cnblogs_com/wgb1234/1695793/o_2004120225096.png)



## 总结:

这样做的好处有

1. 静态库可以提升编译效率
2. 以工程方式打入可以一改静态库不能修改调试的痛点


