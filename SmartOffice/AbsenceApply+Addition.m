//
//  AbsenceApply+Addition.m
//  SmartOffice
//
//  Created by 纪鹏 on 14-6-18.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "AbsenceApply+Addition.h"

@implementation AbsenceApply (Addition)

+(void) clearEntityDataInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kAbsenceApplyEntityName inManagedObjectContext:context];
    [fetchRequest setIncludesPropertyValues:NO];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
    	[context deleteObject:managedObject];
    	NSLog(@"%@ object deleted",kAbsenceApplyEntityName);
    }
    if (![context save:&error]) {
    	NSLog(@"Error deleting %@ - error:%@",kAbsenceApplyEntityName,error);
    }
}

@end
