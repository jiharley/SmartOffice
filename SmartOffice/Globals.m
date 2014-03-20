//
//  Constant.m
//  SmartOffice
//
//  Created by Peng Ji on 14-3-20.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "Globals.h"
#import "SvUDIDTools.h"
#define kUsername @"username"
#define kPassword @"password"
@implementation Globals

+(NSString *)getUsername
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kUsername];
}

+(NSString *)getPassword
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kPassword];
}

+(void) setUsername:(NSString *)username
{
    [[NSUserDefaults standardUserDefaults] setValue:username forKey:kUsername];
}

+(void) setPassword:(NSString *)password
{
    [[NSUserDefaults standardUserDefaults] setValue:password forKey:kPassword];
}

+(NSString *)getUdid
{
    return [SvUDIDTools UDID];
}

@end