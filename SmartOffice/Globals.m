//
//  Constant.m
//  SmartOffice
//
//  Created by Peng Ji on 14-3-20.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "Globals.h"
#import "SvUDIDTools.h"
@implementation Globals

//userName getter and setter
+(NSString *)userName
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kUsername];
}

+(void) setUsername:(NSString *)username
{
    [[NSUserDefaults standardUserDefaults] setValue:username forKey:kUsername];
}

//userPassword getter and setter
+(NSString *)userPassword
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kPassword];
}

+(void) setUserPassword:(NSString *)password
{
    [[NSUserDefaults standardUserDefaults] setValue:password forKey:kPassword];
}

//userId getter and setter
+(NSString*) userId
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kUserId];
}

+(void) setUserId:(NSString *)userId
{
    [[NSUserDefaults standardUserDefaults] setValue:userId forKey:kUserId];
}

//userInfo getter and setter
+(NSDictionary *)userInfo
{
    NSString *infoPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [infoPath stringByAppendingPathComponent:@"userInfo.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:fileName];
    return dic;
}

+(void) setUserInfo:(NSDictionary *)userInfo
{
//    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *infoPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [infoPath stringByAppendingPathComponent:@"userInfo.plist"];
//    [fileManager createFileAtPath:fileName contents:nil attributes:nil];
    BOOL didWriteSuccess = [userInfo writeToFile:fileName atomically:NO];
    NSLog(@"%d",didWriteSuccess);
}

//deviceToken getter and setter
+(NSString *) deviceToken
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kDeviceToken];
}

+(void) setDeviceToken:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:kDeviceToken];
}

//phoneId getter
+(NSString *)phoneId
{
    return [SvUDIDTools UDID];
}
//comeSignTime getter and setter
+(NSString *) comeSignTime
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kComeSignTime];
}

+(void) setComeSignTime:(NSString *)time
{
    [[NSUserDefaults standardUserDefaults] setValue:time forKey:kComeSignTime];
}

//leaveSignTime getter and setter
+(NSString *) leaveSignTime
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kLeaveSignTime];
}

+(void) setLeaveSignTime:(NSString *)time
{
    [[NSUserDefaults standardUserDefaults] setValue:time forKey:kLeaveSignTime];
}

//signDate getter and setter
+(NSString *) signDate
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kSignDate];
}

+(void) setSignDate:(NSString *)date
{
    [[NSUserDefaults standardUserDefaults] setValue:date forKey:kSignDate];
}
@end