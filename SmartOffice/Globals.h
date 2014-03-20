//
//  Constant.h
//  SmartOffice
//
//  Created by Peng Ji on 14-3-20.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ServerUrl @"http://192.168.1"

@interface Globals : NSObject
{
//    NSString *username;
//    NSString *password;
}

+(NSString *) getUsername;
+(void) setUsername:(NSString*)username;
+(NSString *) getPassword;
+(void) setPassword:(NSString*)password;
+(NSString *) getUdid;
@end
