---
title: 'OC和C++混编需要注意的问题'
date: 2018-12-17 21:01:55
tags: [iOS,Objective-C,学习总结,Xcode]
published: true
hideInList: false
feature: /post-images/oc-he-chun-bian-xu-yao-zhu-yi-de-wen-ti.png
---
# 方案一
#### 1. `.c`文件的`identify and type`右边栏修改为`Objective-C source` 
#### 2. `Built setting -> Apple Clang Language -> Compile Source AS`设置为`According to File type`,即根据文件源类型来编译

# 方案二
#### 1. 项目中使用到C或者C++的代码部分的`.m`文件,改为`.mm` 
#### 2.`Built setting -> Apple Clang Language -> Compile Source AS`设置为`Objective-C++`,即指定为C++的编译机制

# 注意
`如果项目中有些头文件导入方式是用modules的@import xxxx 类似的, 那么就不能用第二种方案,因为.mm和这个会冲突,导致整个项目编译不过, 一般报错像这样 "Use of '@import' when C++ modules are disabled, consider using -fmodules and -fcxx-modules" `

#### 最近几个月处于尴尬的处境,又是资本寒冬,一年之内换了三次工作两次住处,果然应了戴总那句2018注定是不平凡的一年

#### 我想做个2019年的大计划,打算定一下目标,来做几件像样的事情... 12月了没几天了,先酝酿着。


 												 `于2018年12月17日 深圳宝安`