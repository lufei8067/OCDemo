//
//  LGUncaughtExceptionHandle.m
//  OCDemo01
//
//  Created by lu on 2021/9/17.
//  Copyright © 2021 lu. All rights reserved.
//

#import "LGUncaughtExceptionHandle.h"
#import <UIKit/UIKit.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#include <stdatomic.h>


NSString * const LGUncaughtExceptionHandlerSignalExceptionName = @"LGUncaughtExceptionHandlerSignalExceptionName";
NSString * const LGUncaughtExceptionHandlerSignalExceptionReason = @"LGUncaughtExceptionHandlerSignalExceptionReason";
NSString * const LGUncaughtExceptionHandlerSignalKey = @"LGUncaughtExceptionHandlerSignalKey";
NSString * const LGUncaughtExceptionHandlerAddressesKey = @"LGUncaughtExceptionHandlerAddressesKey";
NSString * const LGUncaughtExceptionHandlerFileKey = @"LGUncaughtExceptionHandlerFileKey";
NSString * const LGUncaughtExceptionHandlerCallStackSymbolsKey = @"LGUncaughtExceptionHandlerCallStackSymbolsKey";


atomic_int      LGUncaughtExceptionCount = 0;
const int32_t   LGUncaughtExceptionMaximum = 8;
const NSInteger LGUncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger LGUncaughtExceptionHandlerReportAddressCount = 5;

@implementation LGUncaughtExceptionHandle

+ (void)installUncaughtSignalExceptionHandler{
    
    NSSetUncaughtExceptionHandler(&LGExceptionHandlers);
    
    signal(SIGHUP, LGSignalHandler);
    signal(SIGABRT, LGSignalHandler);
    signal(SIGILL, LGSignalHandler);
    signal(SIGSEGV, LGSignalHandler);
    signal(SIGFPE, LGSignalHandler);
    signal(SIGBUS, LGSignalHandler);
    signal(SIGPIPE, LGSignalHandler);

    

}

/// Exception
void LGExceptionHandlers(NSException *exception) {
    NSLog(@"%s",__func__);
    
    // 收集 - 上传
    int32_t exceptionCount = atomic_fetch_add_explicit(&LGUncaughtExceptionCount,1,memory_order_relaxed);
    if (exceptionCount > LGUncaughtExceptionMaximum) {
        return;
    }
    // 获取堆栈信息 - model 编程思想
    NSArray *callStack = [LGUncaughtExceptionHandle lg_backtrace];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo setObject:exception.name forKey:LGUncaughtExceptionHandlerSignalExceptionName];
    [userInfo setObject:exception.reason forKey:LGUncaughtExceptionHandlerSignalExceptionReason];
    [userInfo setObject:callStack forKey:LGUncaughtExceptionHandlerAddressesKey];
    [userInfo setObject:exception.callStackSymbols forKey:LGUncaughtExceptionHandlerCallStackSymbolsKey];
    [userInfo setObject:@"LGException" forKey:LGUncaughtExceptionHandlerFileKey];
    
    [[[LGUncaughtExceptionHandle alloc] init]
     performSelectorOnMainThread:@selector(lg_handleException:)
     withObject:
     [NSException
      exceptionWithName:[exception name]
      reason:[exception reason]
      userInfo:userInfo]
     waitUntilDone:YES];
    
}

//signal
void LGSignalHandler(int signal)
{
    NSLog(@"------------%s", __func__);
    
    int32_t exceptionCount = atomic_fetch_add_explicit(&LGUncaughtExceptionCount,1,memory_order_relaxed);

    // 如果太多不用处理
    if (exceptionCount > LGUncaughtExceptionMaximum) {
        return;
    }
    
    NSString* description = nil;
    switch (signal) {
        case SIGABRT:
            description = [NSString stringWithFormat:@"Signal SIGABRT was raised!\n"];
            break;
        case SIGILL:
            description = [NSString stringWithFormat:@"Signal SIGILL was raised!\n"];
            break;
        case SIGSEGV:
            description = [NSString stringWithFormat:@"Signal SIGSEGV was raised!\n"];
            break;
        case SIGFPE:
            description = [NSString stringWithFormat:@"Signal SIGFPE was raised!\n"];
            break;
        case SIGBUS:
            description = [NSString stringWithFormat:@"Signal SIGBUS was raised!\n"];
            break;
        case SIGPIPE:
            description = [NSString stringWithFormat:@"Signal SIGPIPE was raised!\n"];
            break;
        default:
            description = [NSString stringWithFormat:@"Signal %d was raised!",signal];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSArray *callStack = [LGUncaughtExceptionHandle lg_backtrace];
    [userInfo setObject:callStack forKey:LGUncaughtExceptionHandlerAddressesKey];
    [userInfo setObject:[NSNumber numberWithInt:signal] forKey:LGUncaughtExceptionHandlerSignalKey];
    
    //在主线程中，执行指定的方法, withObject是执行方法传入的参数
    [[[LGUncaughtExceptionHandle alloc] init]
     performSelectorOnMainThread:@selector(lg_handleException:)
     withObject:
     [NSException exceptionWithName:LGUncaughtExceptionHandlerSignalExceptionName
                             reason: description
                           userInfo: userInfo]
     waitUntilDone:YES];
    
}

- (void)lg_handleException:(NSException *)exception{
    
    NSDictionary *dict = [exception userInfo];
    
    [self saveCrash:exception file:[dict objectForKey:LGUncaughtExceptionHandlerFileKey]];
    
    // 网络上传 - flush
    // 用户奔溃
    // runloop 起死回生
    
    CFRunLoopRef runloop = CFRunLoopGetCurrent();
    // 跑圈依赖 - mode
    CFArrayRef allmodes  = CFRunLoopCopyAllModes(runloop);
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindowWidth:300.0f];
    [alert addButton:@"请你奔溃" actionBlock:^{
        self.dismissed = YES;
    }];

    [alert showSuccess:exception.name subTitle:exception.reason closeButtonTitle:nil duration:0.0f];

    
    
    
    
    
    // 起死回生
    while (!self.dismissed) {
        for (NSString *mode in (__bridge NSArray *)allmodes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.0001, false);
        }
    }
    
    CFRelease(runloop);
    
    [self destrySignal:exception];
}

/// 保存奔溃信息或者上传
- (void)saveCrash:(NSException *)exception file:(NSString *)file{
    
    NSArray *stackArray = [[exception userInfo] objectForKey:LGUncaughtExceptionHandlerCallStackSymbolsKey];// 异常的堆栈信息
    NSString *reason = [exception reason];// 出现异常的原因
    NSString *name = [exception name];// 异常名称
    
    // 或者直接用代码，输入这个崩溃信息，以便在console中进一步分析错误原因
    // NSLog(@"crash: %@", exception);
    
    NSString * _libPath  = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:file];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_libPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:_libPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    
    NSString * savePath = [_libPath stringByAppendingFormat:@"/error%@.log",timeString];
    
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception reason：%@\nException name：%@\nException stack：%@",name, reason, stackArray];
    
    BOOL sucess = [exceptionInfo writeToFile:savePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"保存崩溃日志 sucess:%d,%@",sucess,savePath);
    
}

/// 获取函数堆栈信息
+ (NSArray *)lg_backtrace{
    
    void* callstack[128];
    int frames = backtrace(callstack, 128);//用于获取当前线程的函数调用堆栈，返回实际获取的指针个数
    char **strs = backtrace_symbols(callstack, frames);//从backtrace函数获取的信息转化为一个字符串数组
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = LGUncaughtExceptionHandlerSkipAddressCount;
         i < LGUncaughtExceptionHandlerSkipAddressCount+LGUncaughtExceptionHandlerReportAddressCount;
         i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return backtrace;
}



-(void)destrySignal:(NSException *)exception
{
    NSSetUncaughtExceptionHandler(NULL);
     signal(SIGABRT, SIG_DFL);
     signal(SIGILL, SIG_DFL);
     signal(SIGSEGV, SIG_DFL);
     signal(SIGFPE, SIG_DFL);
     signal(SIGBUS, SIG_DFL);
     signal(SIGPIPE, SIG_DFL);

    if ([[exception name] isEqual:LGUncaughtExceptionHandlerSignalExceptionName])
     {
         kill(getpid(), [[[exception userInfo] objectForKey:LGUncaughtExceptionHandlerSignalKey] intValue]);
     }
     else
     {
         [exception raise];
     }
}

@end
