//
//  ODGlobalVar.m
//  OCDemo01
//
//  Created by lu on 2021/9/16.
//  Copyright © 2021 lu. All rights reserved.
//

#import "ODGlobalVar.h"

static NSString *gateWayIp = @"";
static NSInteger gateWayPort = 0;
static NSString *gateWayIp_ipv6 = @"";
static NSInteger gateWayPort_ipv6 = 0;


static NSString *newsIp = @"";
static NSInteger newsPort = 0;
static NSString *newsIp_ipv6 = @"";
static NSInteger newsPort_ipv6 = 0;

@implementation ODGlobalVar

#pragma -mark
+ (void)setGateWayIp:(NSString *)ip
{
    if (ip) {
        gateWayIp = ip;
    }
}

+ (NSString *)getGateWayIp
{
    return gateWayIp;
}

+ (void)setGateWayPort:(NSInteger)port
{
    gateWayPort = port;
}

+ (NSInteger)getGateWayPort
{
    return gateWayPort;
}

+ (void)setGateWayIp_ipv6:(NSString *)ip
{
    if (ip) {
        gateWayIp_ipv6 = ip;
    }
}

+ (NSString *)getGateWayIp_ipv6
{
    if (!gateWayIp_ipv6 || gateWayIp_ipv6.length == 0) {
        return @"ipv6.jiaoyixia.com";
    }
    return gateWayIp_ipv6;
}

+ (void)setGateWayPort_ipv6:(NSInteger)port
{
    gateWayPort_ipv6 = port;
}

+ (NSInteger)getGateWayPort_ipv6
{
    return gateWayPort_ipv6;
}



#pragma -mark
+ (void)setNewsIp:(NSString *)ip
{
    if (ip) {
        newsIp = ip;
    }
}

+ (NSString *)getNewsIp
{
    return newsIp;
}

+ (void)setNewsPort:(NSInteger)port
{
    newsPort = port;
}

+ (NSInteger)getNewsPort
{
    return newsPort;
}



+ (void)setNewsIp_ipv6:(NSString *)ip
{
    if (ip) {
        newsIp_ipv6 = ip;
    }
}

+ (NSString *)getNewsIp_ipv6
{
    return newsIp_ipv6;
}

+ (void)setNewsPort_ipv6:(NSInteger)port
{
    newsPort_ipv6 = port;
}

+ (NSInteger)getNewsPort_ipv6
{
    return newsPort_ipv6;
}


@end
