---
title: "搭建nginx+rtmp本地模拟推流"
date: 2020-12-24 23:17:42
tags: [工具使用,音视频]
published: true
isTop: false
---
前言：这几年直播短视频大火🔥，却也没有抓住这个风口，项目上遇到一个需要推流的功能，所以特此来研究一下这个rtmp推流，用于本地调试还是挺不错的。以下↓就是大致的搭建过程
<!-- more -->

1. 首先搭建nginx环境 `brew tap denji/nginx
  `
2. 其次安装rtmp的依赖 `
  brew install nginx-full --with-rtmp-module
  `
3. 测试`nginx` 以及`nginx -s reload` 和 `nginx -s stop`
4. 修改`/usr/local/etc/nginx/nginx.conf`配置`rtmp`
  将以下代码加到最后一行即可
```
rtmp {
    server {
        listen 1935;
        application app {
            live on;
            record off;
        }
    }
}
```
修改完`nginx -s reload`刷新配置

5. 安装ffmpeg `brew install ffmpeg` (非常大 要安装好久 网络允许的话也很快)


实践操作: 
找一个本地的mp4视频文件,然后再准备一个VLC播放器
执行`FFmpeg`命令解码出`rtmp`的视频流推向本地`rtmp://127.0.0.1:1935/app/haha`
```bash
ffmpeg -re -i /Users/wangguibin/Downloads/big_buck_bunny.mp4 -vcodec copy -f flv rtmp://127.0.0.1:1935/app/haha
```
VLC播放器添加网络地址进行播放,然后终端执行推流命令(本地如果先推中途播好像会卡顿卡壳)

<img src="https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/截屏2020-12-24 下午10.09.5011.png">

<img src="https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/截屏2020-12-24 下午10.09.28.png">

<img src="https://cdn.jsdelivr.net/gh/WangGuibin/MyFilesRepo/images/Xnip2020-12-24_22-59-09.png">