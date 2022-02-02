---
title: "IPA包内网分发"
date: 2022-02-02 17:06:38
tags: [iOS,工具使用,IPA分发]
published: true
isTop: false
---


企业包   无设备限制,方便分发,需要手动信任证书
开发包   100个设备UDID限制

<!-- more -->

- 手机 + Xcode  手动安装,一个两个无所谓,人多或者机器一多就挺烦

- 外网 +  manifest.plist的https链接  可行,但是服务器支持

- 内网 +  manifest.plist的https链接 =>   需要和手机保持同一个网段即局域网
  



`manifest.plist`格式如下: 需要放到`https`的资源服务器上 这里直接放github了, IPA放本地开个webServer 即可
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>items</key>
	<array>
		<dict>
			<key>assets</key>
			<array>
				<dict>
					<key>kind</key>
					<string>software-package</string>
					<key>url</key>
					<!-- ipa文件资源所在地址 一般放内网 局域网访问资源文件快 一般ipa资源文件比较大 -->
					<string>http://192.168.111.111:8080/app.ipa</string>
				</dict>
			</array>
			<key>metadata</key>
			<dict>
				<key>bundle-identifier</key>
				<!-- bundleID -->
				<string>x.x.x</string>
				<key>bundle-version</key>
				<string>x.x.x</string>
				<key>kind</key>
				<string>software</string>
				<key>title</key>
				<string>App</string>
			</dict>
		</dict>
	</array>
</dict>
</plist>
```




利用`itms-services`协议,画个按钮用html的a标签进行访问即可

itms-services://?action=download-manifest&url=manifest.plist的url

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>iOS App安装</title>
    <style>
      .rect {
        width: 200px;
        height: 200px;
        background-color: teal;
        border-radius: 50px;
      }
      #download {
        width: 200px;
        height: 50px;
        color: white;
        background-color: tomato;
        font-size: 25px;
        border-radius: 25px;
        box-shadow: 10px 10px 5px #888;
        padding: 10px;
        background-image: linear-gradient(to top right, red, orange);
        text-decoration: none;
      }
    </style>
  </head>
  <body>
    <div class="rect"></div>
    <div><p>App</p></div>
    <div id="app">
      <a
        id="download"
        href="itms-services://?action=download-manifest&url=https://cdn.jsdelivr.net/gh/WangGuibin/ImageBed@main/files/xxx.plist"
        >下载安装</a
      >
    </div>
  </body>
</html>
```
