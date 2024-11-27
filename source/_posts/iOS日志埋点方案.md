---
title: "iOS日志埋点方案"
date: 2024-11-27 21:14:48
tags: [日志,埋点]
published: true
isTop: false
---

<!-- more -->
采用主流的日志库方案作为基础依赖

`CocoaLumberjack`

然后自己封装一层调用

```objc
#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#define OILogError(frmt, ...)   OI_LOG_MAYBE(DDLogLevelError, DDLogFlagError,   frmt, ##__VA_ARGS__)
#define OILogWarn(frmt, ...)    OI_LOG_MAYBE(DDLogLevelWarning, DDLogFlagWarning, frmt, ##__VA_ARGS__)
#define OILogInfo(frmt, ...)    OI_LOG_MAYBE(DDLogLevelInfo, DDLogFlagInfo,    frmt, ##__VA_ARGS__)
#define OILogDebug(frmt, ...)   OI_LOG_MAYBE(DDLogLevelDebug, DDLogFlagDebug,   frmt, ##__VA_ARGS__)

#define OI_LOG_MAYBE(lvl, flg, frmt, ...) \
    if (lvl & flg) { \
        [DDLog log:YES level:lvl flag:flg context:0 file:__FILE__ function:__FUNCTION__ line:__LINE__ tag:0 format:(frmt), ## __VA_ARGS__]; \
    }


@interface OILog : NSObject

+ (NSString *)defaultLogFilePath;

@end

NS_ASSUME_NONNULL_END
  
  
#import "OILog.h"
#import "OILogFormatter.h"

@implementation OILog

 //无需主动调用 把这些代码加进项目即可, app启动无感调用
+ (void)load {
    @weakify(self);
    __block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self);
        [self didFinishLaunchingOnLoad:note];
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }];
}



+ (void)didFinishLaunchingOnLoad:(NSNotification *)noti {
    [self initSDK];
}

+ (void)initSDK {
    [DDLog removeAllLoggers];
    
    OILogFormatter *logFormatter = [[OILogFormatter alloc] init];

//     add logger for Terminal output or Xcode console output.
    DDOSLogger *ttyLogger = [DDOSLogger sharedInstance];
    ttyLogger.logFormatter = logFormatter;
//    ttyLogger.colorsEnabled = YES;
    [DDLog addLogger:ttyLogger withLevel:DDLogLevelAll];
    
    // add logger for Cached
    DDLogFileManagerDefault *fileManager = [[DDLogFileManagerDefault alloc] initWithLogsDirectory:[self defaultLogFilePath]];
    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:fileManager];
    // 刷新频率为一天，超过一天会生成新的log文件
    fileLogger.rollingFrequency = 60 * 60 * 24;
    // 文件大小阈值，超过该大小，也会生成新的log文件
    fileLogger.maximumFileSize = 1 * 1024 * 1024;
    // 为0.则表示不限制文件个数
    fileLogger.logFileManager.maximumNumberOfLogFiles = 0;
    fileLogger.logFormatter = logFormatter;
    // info以上上报日志
    [DDLog addLogger:fileLogger withLevel:DDLogLevelInfo];
}

+ (NSString *)defaultLogFilePath {
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"OILog"];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath:filePath]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            OILogDebug(@"日志目录创建失败！！！");
        }
    }
    return filePath;
}

@end

 
#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

NS_ASSUME_NONNULL_BEGIN

@interface OILogFormatter : NSObject<DDLogFormatter>

@end

NS_ASSUME_NONNULL_END
  
#import "OILogFormatter.h"

@implementation OILogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    NSString *logLevel;
    switch (logMessage.flag) {
        case DDLogFlagDebug:
            logLevel = @"DEBUG";
            break;
        case DDLogFlagInfo:
            logLevel = @"INFO";
            break;
        case DDLogFlagWarning:
            logLevel = @"WARN";
            break;
        case DDLogFlagError:
            logLevel = @"ERROR";
            break;
        case DDLogFlagVerbose:
            logLevel = @"VERBOSE";
            break;
        default:
            logLevel = @"VERBOSE";
            break;
    }
    
    static dispatch_once_t onceToken;
    static NSDateFormatter *logDateFormatter;
    dispatch_once(&onceToken, ^{
        logDateFormatter = [[NSDateFormatter alloc] init];
        logDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss:SSS";
    });
    
  	/// 此处可以使用其他APM日志收集工具 进行收集日志埋点 打印的时候区分一下level 后台查埋点的时候就可以进行区分查找
    ///  从而更方便定位生产问题
    return [NSString stringWithFormat:@"\n%@ *** [%@] %@ (line: %lu)\n*** %@\n",
            [logDateFormatter stringFromDate:logMessage.timestamp],
            logLevel,
            logMessage.function,
            logMessage.line,
            logMessage.message];
}

```