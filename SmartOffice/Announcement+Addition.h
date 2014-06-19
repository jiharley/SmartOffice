//
//  Announcement+Addition.h
//  SmartOffice
//
//  Created by 纪鹏 on 14-6-18.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "Announcement.h"

@interface Announcement (Addition)

+(void) clearEntityDataInContext:(NSManagedObjectContext *)context;
@end
