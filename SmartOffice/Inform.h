//
//  Inform.h
//  SmartOffice
//
//  Created by Peng Ji on 14-4-24.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Inform : NSManagedObject

@property (nonatomic, retain) NSNumber * informId;
@property (nonatomic, retain) NSString * announcerName;
@property (nonatomic, retain) NSNumber * checked;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * insertMoment;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * validDate;
@property (nonatomic, retain) NSNumber * isImportant;

@end
