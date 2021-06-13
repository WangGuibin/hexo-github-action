---
title: "iOS加载本地html文件锚点定位处理"
date: 2021-06-13 20:29:03
tags: [大前端,iOS,踩坑]
published: true
isTop: false
---


最近听好几位同学说起这个问题,碰巧我也遇到了这个问题,所以有必要做个记录~

<!-- more -->

## 加载本地HTML文件
 加载本地的`html`文件必然是要读取它的文件地址,一般来说是放到项目的资源文件目录下,然后`mainBundle`加载即可,至于SDK内原理一致,不是本文讨论的范畴了~ 
(⚠️注意: html文件属于引用文件不参与编译,所以拖进项目时不要勾选☑️group,而是下面那个引用folder )
```objc
NSString *path = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"html"];
```

## 锚点参数处理
**如上述代码加载html文件是没啥毛病的,也能加载出来,但是并不满足锚点跳转到页面某个位置的需求**

### path后拼接锚点参数
```objc
 NSString *fileURLString = [path stringByAppendingFormat:@"#third"];
 NSLog(@"%@",fileURLString); 
```
**打印之后发现缺少 `file://` 协议头,用这个得拼协议头,于是:**
```objc
NSString *filePath = [NSString stringByAppendingString:@"file://%@",fileURLString];
NSLog(@"%@", filePath); 
```
**打印之后发现URL结果是正确✅的,有协议头也有传参, 这就可以组装URL加载webView了,可是一运行结果页面都加载不出来~**
```objc
NSURL *URL = [NSURL fileURLWithPath: filePath]; 
NSLog(@"%@", URL.absoluteString); 
```
**打印发现`#third` 会被转成 `%23third`,这貌似就陷入难题了,因为前面无论如何努力,最终都要通过URL进行页面加载~  只能另辟蹊径(js注入大法好)了**

## 解决方案① 
在页面加载完成之后,调用js注入的方法:
1. 利用`location.hash`属性进行锚点定位
```objc
[self.webView evaluateJavaScript:@"window.location.hash='#third'" completionHandler:^(id _Nullable, NSError * _Nullable error) {
  }];
```
2. 利用`dom`元素滚动方法
```objc
[self.webView evaluateJavaScript:@"window.document.getElementById('third').scrollIntoView()" completionHandler:^(id _Nullable, NSError * _Nullable error) {
 }];
```
## 解决方案② (终极)
这个方法最简单~ 最native~
```objc
    NSURL *lastURL = [NSURL URLWithString:@"#third" relativeToURL:URL];
    NSLog(@"%@",lastURL.absoluteString);
```
如此传参就不会存在`#`被转`%23`的问题了 

`demo.html`的代码在这里 [demo代码](https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/20210613190555.html)

 
