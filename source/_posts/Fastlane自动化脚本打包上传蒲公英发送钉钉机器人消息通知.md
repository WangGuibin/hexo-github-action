------
title: "Fastlane自动化脚本打包上传蒲公英发送钉钉机器人消息通知"
date: 2020-11-25 23:58:02
tags: [效率,工具,iOS]
isTop: false
------
##  打包脚本集成

1. 定义好可配置项,方便修改

```ruby
# 先定义好全局变量 
SCHEME = "xxx"
WORKSPACE = "xxx.xcworkspace"
XCODEPROJ = "xxx.xcodeproj"
BundleId = "com.xxx.ooo"
dingding_token = "xxxxoooo" #电脑端钉钉建群群助手添加机器人webhook设置好获取token即可 发消息得带tag不然可能失败

```

2. 打包到Testflight

   ```ruby
   desc "打包到Testflight"
     lane :beta do
       increment_build_number_in_plist(target: SCHEME) #build号自增
       build_app(
         workspace: WORKSPACE,
         scheme: SCHEME,
         silent: true,
         clean: true,
         output_directory: '.ipa/Testflight',
         output_name: 'app.ipa',
         export_xcargs: "-allowProvisioningUpdates",
         export_options: {
           method: 'app-store',
           manifest: {
             appURL: 'https://example.com/MyApp.ipa',
             displayImageURL: 'http://xxxxxx',#小图标
             fullSizeImageURL: 'http://xxxxx'#大图标1024x1024
           }
         }
       )
       upload_to_testflight(
         ipa: '.ipa/Testflight/app.ipa'
       )
    end
   ```

3. 打包到App Store

   ```ruby
   desc "部署到App Store"
     lane :release do |options|
       sigh(
         output_path: '.certificates',
         force: true
       )
   
       increment_version_number_in_plist(
         target: SCHEME,
         version_number: options[:version_number]
       )
       increment_build_number_in_plist(target: SCHEME)
   
       gym(
         scheme: SCHEME,
         clean: true,
         silent: true,
         output_directory: '.ipa/AppStore',
         output_name: 'app.ipa',
         configuration: 'Release',
         export_xcargs: "-allowProvisioningUpdates"
       )
       upload_to_app_store(
         force: true,
         ipa: '.ipa/AppStore/app.ipa',
         skip_screenshots: true,
         automatic_release: true
       )
     end
   ```

4. 打AdHoc分发包

   ```ruby
   cert #获取证书
   #验证签名
   sigh(
     adhoc: true,
     output_path: '.certificates',
     app_identifier: BundleId
    )
   #自增build号
   increment_build_number_in_plist(target: SCHEME)
   time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
   #编译打包
   gym(
     scheme: SCHEME,
     clean: true,
     output_directory: ".ipa/#{SCHEME}/#{time}",
     output_name: 'app.ipa',
     configuration: "Release",
     export_xcargs: "-allowProvisioningUpdates"
    )
   # 上传蒲公英 
   upload_ipa_to_pgyer(scheme: SCHEME, time: time)
   
   # 发送钉钉消息
   send_dingding_msg()
   ```

5. 上传至蒲公英分发平台 (这个平时用的比较多)

   ```ruby
   private_lane :upload_ipa_to_pgyer do |options|
       pgyer(
         api_key: "xxxxx",
         user_key: "xxxxx",
         ipa: ".ipa/#{options[:scheme]}/#{options[:time]}/app.ipa"
       )
    end
   ```

   

6. 发送钉钉机器人消息

   ```ruby
     desc "发送机器人🤖消息到钉钉群"
     lane :send_dingding_msg do |options|
       version = get_version_number(target: SCHEME)
      text = "🚀🚀🚀测试包v#{version} Release环境打包更新啦，下载地址：https://www.pgyer.com/xxx ,请查收~ "
      ding_talk_msg_push(token:dingding_token, text:text, at_all: true)
     end
   ```

7. 发送更新日志到钉钉群

   ```ruby
   # 打包之前准备好更新内容 log.txt 存放在fastlane同一目录层级
   desc "获取更新日志并发送至钉钉机器人🤖"
       lane :send_log_to_dingding do  |options|
       log_text = File.new("../log.txt", "r:utf-8").sysread(2000) #读取文本2000字
       ding_talk_msg_push(token:dingding_token, text:log_text, at_all: true)
   end 
   ```

8. 可能用到的插件,在`Pluginfile`中添加

   ```ruby
   gem 'fastlane-plugin-pgyer'
   gem 'fastlane-plugin-versioning'
   gem 'fastlane-plugin-ding_talk_msg_push'
   ```

   
##  fastlane自动化脚本打包,至此就告一段落了,持续集成下次再弄~ 