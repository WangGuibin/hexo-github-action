---
title: "关于AppleScript脚本的一些使用总结"
date: 2021-01-23 22:28:25
tags: [工具使用,效率,AppleScript]
published: true
isTop: false
---

<!-- more -->

## 1. 暗黑模式切换
```apl
tell application "System Events"
	tell appearance preferences
		set dark mode to not dark mode
	end tell
end tell
```

## 2. 发送邮件

```apl
--设置参数
set recipientName to "xxx" --收件人
set recipientAddress to "xxx@gmail.com" --收件地址
set mailSubject to "使用AppleScript脚本自动化发邮件" --邮件主题
set mailContent to "这是一封来自AppleScript发出的测试邮件,请勿回复!!!" --邮件内容

--执行发送邮件操作
tell application "Mail"
	
	--创建信息
	set theMessage to make new outgoing message with properties {subject:mailSubject, content:mailContent, visible:true}
	
	--发送信息
	tell theMessage
		make new to recipient with properties {name:recipientName, address:recipientAddress}

		send
		
	end tell
end tell
```

## 3. 弹窗相关

一个按钮默认样式
![一个按钮](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/btn1s.png)
一个按钮加空格格式化样式
![](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/btn1l.png)
两个按钮样式
![](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/btn2.png)
三个按钮样式
![](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/btn3.png)
没有icon样式 
![](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/Xnip2021-01-23_22-02-53.png)

反正这个dialog感觉就很安卓

#### a. 普通弹窗
```apl
display dialog "这是内容" with title "这是标题" --默认带上取消和确认按钮
--设置一个OK按钮以及默认选中
display dialog "这是内容" with title "这是标题" buttons "OK" default button "OK"
--效果同上
display dialog "这是内容" with title "这是标题" buttons "OK" default button 1
-- 自定义多个按钮 (最多允许使用三个按钮。)
display dialog "这是内容" with title "这是标题" buttons {"OK","Cancel","HAHA"} default button "OK"

```
或者alert 这个就比较iOS
![](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/alertl.png)

```apl
-- 与 dialog 类似布局上有所不同,按钮是居中纵向排列
display alert "hahhaha" buttons {"OK", "NO", "YES"} default button 2

```

#### b. 带图标的弹窗
```apl
--可以指定对话框的图标，icon 图标可以指定 note (普通) /stop (危险) /caution (警告) 三种类型 或者指向文件路径
display dialog "这是内容" with title "这是标题" buttons {"No", "Yes"} default button "Yes" with icon caution

-- 自定义图标 注意图片格式应该为.icns格式的 可以去应用xx.app/contens/resources下面去找
set fileName to choose file "Select a Folder"
display dialog "这是内容" with title "这是标题" buttons {"No", "Yes"} default button "Yes" with icon file fileName

-- 指定路径 桌面路径 + 文件名
display dialog "这是内容" with title "这是标题" buttons {"No", "Yes"} default button "Yes" with icon file ((path to desktop as text) & "AppIcon.icns")

-- 或者这样
display dialog "这是内容" with title "这是标题" buttons {"No", "Yes"} default button "Yes" with icon alias ((path to desktop as text) & "AppIcon.icns")
-- 转化一下
-- set fileName to ((path to desktop as text) & "AppIcon.icns")
set fileName to "Macintosh HD:Users:wangguibin:Desktop:AppIcon.icns"
display dialog "这是内容" with title "这是标题" buttons {"No", "Yes"} default button "Yes" with icon file fileName

-- 直接使用App Store的图标
set fileName to "Macintosh HD:System:Applications:App Store.app:Contents:Resources:AppIcon.icns"
display dialog "这是内容" with title "这是标题" buttons {"No", "Yes"} default button "Yes" with icon file fileName

```

#### c. 弹窗输入框表单
```apl
display dialog "表单" default answer "输入框内容" buttons {"按钮1", "按钮2", "按钮3"} default button 1 with icon caution
copy the result as list to {text_returned, button_pressed} --返回一个列表{文本,按钮}

```


#### d. 选择列表弹窗

![](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/selecScriptList.png)

```apl
-- 默认单选 默认不选中的话直接设置 `default items {}` 即可
choose from list {"Shell", "Ruby", "Python", "Applescript", "Javascript", "Perl", "Dart"} with title "日期选择" with prompt "选择一门脚本语言" OK button name "学习" cancel button name "放弃" default items {"Python"}

-- 多选
choose from list {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"} with title "日期选择" with prompt "选择一天或者多天" OK button name "确认选择" cancel button name "不选" default items {"Monday"} with multiple selections allowed

```

#### e. 选择文件和目录
选择文件
```apl
-- 选择文件 获取文件名 没有的话不会创建 只是返回一个路径 
choose file name with prompt "获取文件名"
```
选择目录
```apl
-- 注：其中prompt和default location参数同Choose File Name;另外invisibles指定显示隐藏 文件,multiple selections allowed可以多选,showing package contents显示包内容,省略时 则不显示隐藏文件/不可多选/不显示包内容
choose folder with prompt "选择目录" default location file "Macintosh HD:Users:mac:Desktop" with invisibles, multiple selections allowed and showing package contents
```

## 4. 通知

![](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/notepng.png)

```apl
-- 声音文件都在/System/Library/Sounds 
-- 其中Funk , Glass, Ping 这几种好听一些 
display notification "通知内容通知内容通知内容通知内容" with title "通知主标题" subtitle "副标题" sound name "Funk"
```


## 5. Shell 调用 AppleScript

适合简短的脚本语句
```bash
#注意单引号shell无法传参 如需传参则需要使用双引号\转义
osascript -e 'display notification "通知内容通知内容通知内容通知内容" with title "通知主标题" subtitle "副标题" sound name "Funk"'
```
适合多行脚本,增加可读性
```bash
#简单粗暴 直接使用重定向包含applescript语句即可
osascript <<EOF
set fileName to "Macintosh HD:System:Applications:App Store.app:Contents:Resources:AppIcon.icns"
display dialog "这是内容" with title "这是标题" buttons {"No", "Yes"} default button "Yes" with icon file fileName
set btn to (button returned of result)
get btn
EOF
# 返回值 "NO"或者"OK"
```

## 6. AppleScript 调用 Shell 
do shell script + shell脚本语句即可
```apl
set shellStr to do shell script "cd ~/Desktop;cat shell_var.sh"
display alert shellStr buttons {"OK"}
```

## 总结

`AppleScript`配合`Shell` 以及`Alfred` 感觉能玩出很多花样来,一些工具确实能提升不少效率和体验。
 我平时玩的一些工具存放在这 [https://github.com/WangGuibin/WGBToolsConfigRepository](https://github.com/WangGuibin/WGBToolsConfigRepository)

## 参考博文文章
[applescript-快速入门](https://www.exchen.net/applescript-快速入门.html)
[我的新玩具-AppleScript(四)](https://blog.csdn.net/u011238639/article/details/56506056)
[applescript快速入门教程](https://www.cnblogs.com/itcomputer/p/10162392.html)
[AppleScript 脚本让 Mac 唱生日快乐歌](https://lucifr.com/make-your-mac-sing-happy-birthday-with-applescript/)