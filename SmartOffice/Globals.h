//
//  Constant.h
//  SmartOffice
//
//  Created by Peng Ji on 14-3-20.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import <Foundation/Foundation.h>
//#define ServerUrl @"http://192.168.1.115/so"
#define ServerUrl @"http://wm.tongji.edu.cn/so-yc"

#define kDeviceToken @"deviceToken"
#define kUsername @"userName"
#define kUserId @"userId"
#define kPhoneId @"phoneId"
#define kPassword @"password"

#define kComeSignTime @"comeSignTime"
#define kLeaveSignTime @"leaveSignTime"
#define kSignDate @"signDate"

#define kSignInAlertTime @"signInAlert"
#define kSignOutAlertTime @"signOutAlert"
#define kSignAlertSwitch @"ON"
#define defaultSignInTimeStr @"08:30"
#define defaultSignOutTimeStr @"17:30"

#define kAbsenceApplyEntityName @"AbsenceApply"
#define kAnnouncementEntityName @"Announcement"
#define kInformEntityName @"Inform"
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

//format:'HH:mm'
+(NSString *) signInAlertTime;
+(void) setSignInAlertTime:(NSString *)time;

//format:'HH:mm'
+(NSString *) signOutAlertTime;
+(void) setSignOutAlertTime:(NSString *)time;

+(NSString *) signAlertSwitch;
+(void) setSignAlertOn:(BOOL)on;
@end
