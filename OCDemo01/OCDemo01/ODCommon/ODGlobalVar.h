//
//  ODGlobalVar.h
//  OCDemo01
//
//  Created by lu on 2021/9/16.
//  Copyright © 2021 lu. All rights reserved.
//

#import <Foundation/Foundation.h>




NS_ASSUME_NONNULL_BEGIN

@interface ODGlobalVar : NSObject


+ (void)setGateWayIp:(NSString *)ip;
+ (NSString *)getGateWayIp;
+ (void)setGateWayPort:(NSInteger)port;
+ (NSInteger)getGateWayPort;

+ (void)setGateWayIp_ipv6:(NSString *)ip;
+ (NSString *)getGateWayIp_ipv6;
+ (void)setGateWayPort_ipv6:(NSInteger)port;
+ (NSInteger)getGateWayPort_ipv6;

//-------------------

+ (void)setNewsIp:(NSString *)ip;
+ (NSString *)getNewsIp;
+ (void)setNewsPort:(NSInteger)port;
+ (NSInteger)getNewsPort;


+ (void)setNewsIp_ipv6:(NSString *)ip;
+ (NSString *)getNewsIp_ipv6;
+ (void)setNewsPort_ipv6:(NSInteger)port;
+ (NSInteger)getNewsPort_ipv6;



@end

NS_ASSUME_NONNULL_END
