//
//  AppDelegate.h
//  SmartOffice
//
//  Created by Peng Ji on 14-2-26.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest/ASIFormDataRequest.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, ASIHTTPRequestDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *deviceTokenStr;

@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end
