//
//  ODCarshCapture.h
//  OCDemo01
//
//  Created by lu on 2021/9/16.
//  Copyright © 2021 lu. All rights reserved.
//

/*
 crash : 已经发生 -app 分析 -

 crash种类   KVO  数组越界  signal 野指针  线程问题  内存  后台超时
 
 只有两种：exception & signal

*/
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ODCarshCapture : NSObject

/*!
 *  异常的处理方法
 *
 *  @param install   是否开启捕获异常
 *  @param showAlert 是否在发生异常时弹出alertView
 */
+ (void)installUncaughtExceptionHandler:(BOOL)install showAlert:(BOOL)showAlert;

@end

NS_ASSUME_NONNULL_END
