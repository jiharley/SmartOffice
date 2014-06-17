//
//  AbsenceApply.h
//  SmartOffice
//
//  Created by Peng Ji on 14-4-9.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AbsenceApply : NSManagedObject

@property (nonatomic, retain) NSNumber * applyId;
@property (nonatomic, retain) NSNumber * checked;
@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSString * feedback;
@property (nonatomic, retain) NSString * realName;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * userId;

@end
