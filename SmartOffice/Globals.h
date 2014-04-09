//
//  Constant.h
//  SmartOffice
//
//  Created by Peng Ji on 14-3-20.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ServerUrl @"http://192.168.1.115/so"
#define kDeviceToken @"deviceToken"
#define kUsername @"userName"
#define kUserId @"userId"
#define kPhoneId @"phoneId"
#define kPassword @"password"

#define kComeSignTime @"comeSignTime"
#define kLeaveSignTime @"leaveSignTime"
#define kSignDate @"signDate"

#define kAbsenceApplyEntityName @"AbsenceApply"

@interface Globals : NSObject
{
//    NSString *username;
//    NSString *password;
}

+(NSString *) userName;
+(void) setUsername:(NSString*)username;

+(NSString *) userPassword;
+(void) setUserPassword:(NSString*)password;

+(NSString *) userId;
+(void) setUserId:(NSString*)userId;

+(NSString *) phoneId;

+(NSString *) deviceToken;
+(void) setDeviceToken:(NSString *)token;

+(void) setUserInfo:(NSDictionary *) userInfo;
+(NSDictionary *)userInfo;

+(NSString *) comeSignTime;
+(void) setComeSignTime:(NSString *)time;

+(NSString *) leaveSignTime;
+(void) setLeaveSignTime:(NSString *)time;

+(NSString *) signDate;
+(void) setSignDate:(NSString *)date;
@end
