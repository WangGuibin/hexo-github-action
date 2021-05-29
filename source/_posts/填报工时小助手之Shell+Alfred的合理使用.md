---
title: "填报工时小助手之Shell+Alfred的合理使用"
date: 2021-05-29 16:42:46
tags: [工具使用]
published: true
isTop: false
---

## 背景
  最近部门检查工时及其繁琐,而考勤只有第二天才能出来,系统做得不够友好,工时涉及到一个计算,而工时填报只能在下班以后操作,每次都需要自己去算一遍无疑很低效,很是影响下班的效率,顺手撸了一个可交互的`shell`脚本配合`Alfred`完美运行,遂成此篇.
 <!-- more -->

执行效果如图:

![第一步](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/20210529161432.png)

![第二步](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/20210529161618.png)

![填写](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/20210529161718.png)

![结果](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/20210529161746.png)

  
  ## 方案
  > 工时计算规则: `工时 = 下班时间 - 上班时间 - 中午休息1.5小时`
  
  关于时间这种两位数的计算其实并不难,但这是一个体验问题,心算能力强的算我没说,懒就要懒到极致~ 
脚本太过简单,无非就是加减乘除的数学运算~
目前我想到了有两种方案
- ① 秒级时间戳的差值 / 3600.0, 再减去1.5 即可
- ② 上班和下班时间点均转为小时数相减, 再减去1.5 即可

## 代码
这里我采用的是②
脚本如下: 
```bash
# /bin/bash

#使用Xcode图标
#ICON="with icon file \"Macintosh HD:Applications:Xcode.app:Contents:Resources:Xcode.icns\""
# note/ stop/ caution 系统内置图标
ICON="with icon note"

START_TIME=$(
osascript <<EOF
display dialog "工时填报计算" default answer "请输入上班打卡时间" ${ICON} 
text returned of result
EOF
)

echo $START_TIME
HOUR1=${START_TIME%:*}
MIN1=${START_TIME#*:}
H1=$(echo "scale=4; ${MIN1}/60" | bc)
res1=$(echo "scale=4; ${HOUR1}+${H1}" | bc)


END_TIME=$(
osascript <<EOF
display dialog "工时填报计算" default answer "请输入下班打卡时间" ${ICON} 
text returned of result
EOF
)

echo $END_TIME
HOUR2=${END_TIME%:*}
MIN2=${END_TIME#*:}
H2=$(echo "scale=4; ${MIN2}/60" | bc)
res2=$(echo "scale=4; ${HOUR2}+${H2}" | bc)

# 工时 = 下班时间 - 上班时间 - 中午休息1.5小时
res3=$(echo "scale=4; ${res2}-${res1}-1.5" | bc)
MSG="计算规则:\n工时 = 下班时间 - 上班时间 - 中午休息1.5小时\n工时 = ${END_TIME} - ${START_TIME} - 1.5h午休\n计算结果为: ${res3}个小时"
osascript <<EOF
display dialog "${MSG}" with title "计算结果" buttons {"好的👌"}  default button 1 ${ICON} 
EOF
```
脚本有了,如何去使用呢? 这可能是一个问题,总不能每次都打开终端去执行吧

## 执行
shell是可以转成可执行程序的,可以执行如下代码试试:
```shell
chmod a+x work.sh
```
执行之后就可以双击打开就可以运行该程序

## 体验优化
经过一番折腾,以上代码能够正确运行,还有一点点瑕疵就是打开之后会有一个终端执行窗口在桌面上,这个如何去优化它呢? 
Alfred神器来帮忙
* 1 首先将脚本放到一个目录下
* 2 `Alfred`新建一个`workflow`,第一个动作就是启动这个workflow的操作,看个人喜好keyword或者hotkey
* 3 下一步连接`Run Script`动作,点开选择bash或zsh,然后命令是cd 到你的脚本目录下执行脚本即可

基本操作步骤如下图: 

![添加keyword入口](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/20210529161857.png)

![添加工作流](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/20210529161827.png)

![执行脚本命令填入](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/20210529161955.png)

![启动Alfred](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/20210529162019.png)

![最终成品](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/20210529161432.png)