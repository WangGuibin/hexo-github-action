---
title: "iOS编译SDK自动化脚本(.framework+.a)"
date: 2022-01-24 20:43:42
tags: [iOS,Shell,静态库]
published: true
isTop: false
---

之前研究过静态库打包合成的问题,为此踩了不少坑, 写了一篇关于静态库打包的半自动的文章

- [关于Xcode12静态库打包的一些心得 - CoderWGB - 博客园](https://www.cnblogs.com/wgb1234/p/14258036.html)

<!-- more -->

不知道是Xcode的问题还是系统的问题,之前在网上找过了一些脚本,发现不可以直接在SDK工程中加入脚本,不然MacBook就直接发烫电风扇转不停了,当时没有找到好的办法,所以搞了个半自动...

最近发现有`Aggregate`这么个玩意儿,终于可以全自动了哈哈哈😄,需要在SDK的工程里创建一个聚合类型的`target`即`Aggregate`

并在`Build Phases`新建一个`RunScript`里面执行脚本,无论是`.framework`还是`.a`都是一样的

开整:

![创建Aggregate](https://cdn.jsdelivr.net/gh/WangGuibin/ImageBed@main/files/2022_01_24_20:00:51_aggregate.png)

自动构建.framework脚本如下: 

```bash
set -e
#SDK的名字
SDK_NAME=${PROJECT_NAME}
#SDK产出目录
INSTALL_DIR=${SRCROOT}/Products/${SDK_NAME}.framework

#清空编译缓存
rm -rf ${BUILD_DIR}

# 执行模拟器编译指令
xcodebuild -configuration ${CONFIGURATION} -target ”${SDK_NAME}“ -sdk iphonesimulator build
#执行真机编译指令
xcodebuild -configuration ${CONFIGURATION} -target ”${SDK_NAME}“ -sdk iphoneos  build

#真机目录
DEVICE_DIR=”build“/${CONFIGURATION}-iphoneos/${SDK_NAME}.framework
#模拟器目录
SIMULATOR_DIR=”build“/${CONFIGURATION}-iphonesimulator/${SDK_NAME}.framework

#清除旧的安装目录
if [ -d ”${INSTALL_DIR}“ ]
then
rm -rf ”${INSTALL_DIR}“
fi
#创建新的安装目录
mkdir -p ”${INSTALL_DIR}“
#拷贝编译产物到安装目录
cp -R ”${DEVICE_DIR}/“ ”${INSTALL_DIR}/“

#合并真机和模拟器的编译产物
lipo -create ”${DEVICE_DIR}/${SDK_NAME}“ ”${SIMULATOR_DIR}/${SDK_NAME}“ -output ”${INSTALL_DIR}/${SDK_NAME}“

#打开安装目录查看结果
open ”${SRCROOT}/Products/“

rm -rf ”${SRCROOT}/build“

#查看此次编译的架构支持
lipo_info=`lipo -info ${INSTALL_DIR}/${SDK_NAME}`
icon_path=`pwd`/Xcode.icns
icon_file=$(osascript -e ”set thePath to POSIX file \“${icon_path}\” as string“)
echo $icon_file
archs=${lipo_info##*are:}
osascript -e ”display dialog \“${archs}\” with title \“查看静态库信息\” buttons {\“OK\”} default button 1 with icon file \“${icon_file}\”“
echo ”脚本跑🏃完了“
```

![framework脚本执行结果](https://cdn.jsdelivr.net/gh/WangGuibin/ImageBed@main/files/2022_01_24_20:01:38_framework.png)



自动构建.a脚本如下: 

```bash
set -e
#SDK的名字
SDK_NAME=${PROJECT_NAME}
#SDK产出目录
INSTALL_DIR=${SRCROOT}/Products/${SDK_NAME}

#清空编译缓存
rm -rf ${BUILD_DIR}

# 执行模拟器编译指令
xcodebuild -configuration ${CONFIGURATION} -target ”${SDK_NAME}“ -sdk iphonesimulator build
#执行真机编译指令
xcodebuild -configuration ${CONFIGURATION} -target ”${SDK_NAME}“ -sdk iphoneos  build

#真机目录
DEVICE_DIR=”build“/${CONFIGURATION}-iphoneos
#模拟器目录
SIMULATOR_DIR=”build“/${CONFIGURATION}-iphonesimulator

#清除旧的安装目录
if [ -d ”${INSTALL_DIR}“ ]
then
rm -rf ”${INSTALL_DIR}“
fi
#创建新的安装目录
mkdir -p ”${INSTALL_DIR}“
#拷贝编译产物到安装目录
cp -R ”${DEVICE_DIR}/“ ”${INSTALL_DIR}/“
rm -rf ”${INSTALL_DIR}/usr“

#合并真机和模拟器的编译产物
lipo -create ”${DEVICE_DIR}/lib${SDK_NAME}.a“ ”${SIMULATOR_DIR}/lib${SDK_NAME}.a“ -output ”${INSTALL_DIR}/lib${SDK_NAME}.a“

#打开安装目录查看结果
open ”${SRCROOT}/Products/“
#删除编译冗余数据
rm -rf ”${SRCROOT}/build“

#查看此次编译的架构支持
lipo_info=`lipo -info ${INSTALL_DIR}/lib${SDK_NAME}.a`
icon_path=`pwd`/Xcode.icns 
icon_file=$(osascript -e ”set thePath to POSIX file \“${icon_path}\” as string“)
echo $icon_file
archs=${lipo_info##*are:}
osascript -e ”display dialog \“${archs}\” with title \“查看静态库信息\” buttons {\“OK\”} default button 1 with icon file \“${icon_file}\”“
echo ”脚本跑🏃完了“
```

![lib.a静态库脚本执行结果](https://cdn.jsdelivr.net/gh/WangGuibin/ImageBed@main/files/2022_01_24_20:02:16_liba.png)

**真机架构:**   
* armv7
* armv7s
* arm64
* arm64e
	
**模拟器架构:**
  * i386
  * x86_64



不过现在Xcode13默认armv7和 arm64为标准架构,x86_64为PC端模拟器架构,需要自己手动调整Xcode配置剔除

如图: 

![Xcode SDK架构设置](https://cdn.jsdelivr.net/gh/WangGuibin/ImageBed@main/files/2022_01_24_20:09:26_Xnip2022-01-24_20-08-46.png)



- [之前写的Mac自动操作静态库相关的工作流](https://github.com/WangGuibin/WGBToolsConfigRepository/tree/master/oh-my-workflows/workflows/Xcode/静态库相关)

- [SDK自动打包 Demo](https://github.com/WangGuibin/TestDemo/tree/master/SDKDemo)
