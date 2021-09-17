//
//  LGUncaughtExceptionHandle.h
//  OCDemo01
//
//  Created by lu on 2021/9/17.
//  Copyright © 2021 lu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LGUncaughtExceptionHandle : NSObject

@property (nonatomic) BOOL dismissed;

+ (void)installUncaughtSignalExceptionHandler;

@end

NS_ASSUME_NONNULL_END
