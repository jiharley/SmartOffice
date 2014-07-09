//
//  AppDelegate.m
//  SmartOffice
//
//  Created by Peng Ji on 14-2-26.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "AppDelegate.h"
#import <AdSupport/AdSupport.h>
#import <AudioToolbox/AudioToolbox.h>

#define SecondsInOneDay (24*3600)

@implementation AppDelegate
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectContext = _managedObjectContext;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
//    NSString *adid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    if ([Globals userName]) {
//        UITabBarController *tabController = [storyboard instantiateViewControllerWithIdentifier:@"tabController"];
//        tabController.selectedIndex = 1;
//        self.window.rootViewController = tabController;
//    }
//    else {
//        UIViewController *loginController = [storyboard instantiateViewControllerWithIdentifier:@"loginController"];
//        self.window.rootViewController = loginController;
//    }
    
    UITabBarController *tabController = [storyboard instantiateViewControllerWithIdentifier:@"tabController"];
    tabController.selectedIndex = 1;
    self.window.rootViewController = tabController;
    
//    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
//    NSLog(@"%@", idfv);
//    NSLog(@"%@", [Globals getUdid]);
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeSound];
    //这里处理应用程序如果没有启动,但是是通过通知消息打开的,此时可以获取到消息.
    if (launchOptions != nil) {
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        for (id key in userInfo) {
            NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
        }
        UITabBarController *tabController =(UITabBarController*) self.window.rootViewController;
        tabController.selectedIndex = 0;
        application.applicationIconBadgeNumber = 0;
    }
    return YES;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:nil];
    int resultCode = [[responseDic valueForKey:@"resultCode"] intValue];
    if (1 == resultCode) {
        [[NSUserDefaults standardUserDefaults] setValue:self.deviceTokenStr forKey:kDeviceToken];
    }
}

//远程通知注册成功委托
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"成功注册！ %@",deviceToken);
    NSString *oldToken = [Globals deviceToken];
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.deviceTokenStr = newToken;
    NSLog(@"My token is: %@", newToken);
    if (![newToken isEqualToString:oldToken]) {
        if (nil != [[NSUserDefaults standardUserDefaults] valueForKey:kUserId])
        {
            NSString *urlString = [NSString stringWithFormat:@"%@/index.php?r=site/clientUpdate",ServerUrl ];
            ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
            [request setPostValue:[Globals userId] forKey:@"userId"];
            [request setPostValue:newToken forKey:@"token"];
            [request setDelegate:self];
            [request startAsynchronous];
        }
    }
}
//远程通知注册失败委托
-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error description]);
}

//点击某条远程通知时调用的委托 如果界面处于打开状态或者在后台运行,那么此委托会直接响应
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    for (id key in userInfo)
    {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
    if (application.applicationState == UIApplicationStateActive)
    {
        //震动及声音
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound(1007);
        UITabBarController *tabController =(UITabBarController*) self.window.rootViewController;
        if (0 != tabController.selectedIndex) {
            [[[[tabController tabBar] items] objectAtIndex:0] setBadgeValue:@"new"];
        }
    }
    else
    {
        UITabBarController *tabController =(UITabBarController*) self.window.rootViewController;
        tabController.selectedIndex = 0;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newMessage" object:nil userInfo:userInfo];

    application.applicationIconBadgeNumber = 0;
//    [self addNotiFromRemoteNotification:userInfo updateUI:YES];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    isActive = NO;
    NSLog(@"resignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    isActive = NO;
    NSLog(@"enterBackground");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    if (![[Globals signAlertSwitch] isEqualToString:@"OFF"])
    {
        NSString *signInAlertTimeStr = nil;
        NSString *signOutAlertTimeStr = nil;
        if ([Globals signInAlertTime] && [Globals signOutAlertTime]) {
            signInAlertTimeStr = [Globals signInAlertTime];
            signOutAlertTimeStr = [Globals signOutAlertTime];
        }
        else{
            signInAlertTimeStr = defaultSignInTimeStr;
            signOutAlertTimeStr = defaultSignOutTimeStr;
        }
        
        NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
        [tempDic setObject:signInAlertTimeStr forKey:@"kAlertTime"];
        [tempDic setObject:@"上班了，该签到啦！" forKey:@"kAlertContent"];
        
        NSDictionary *signInAlertDic = [tempDic copy];
        [tempDic setObject:signOutAlertTimeStr forKey:@"kAlertTime"];
        [tempDic setObject:@"要下班咯，来签退吧！" forKey:@"kAlertContent"];

        NSDictionary *signOutDic = [tempDic copy];
        
        //2-->周一 ... 6-->周五
        for (int i=2; i<=6; i++) {
            [self addNotificationWithAlertInfo:signInAlertDic Date:[self SetDateForAlarmWithWeekday:i andAlertInfo:signInAlertDic] andRepeatInterval:NSWeekCalendarUnit];
            [self addNotificationWithAlertInfo:signOutDic Date:[self SetDateForAlarmWithWeekday:i andAlertInfo:signOutDic] andRepeatInterval:NSWeekCalendarUnit];
        }
        
        
        /*
        NSInteger signInHour = [[signInAlertTimeStr substringToIndex:2] integerValue];
        NSInteger signInMin = [[signInAlertTimeStr substringWithRange:NSMakeRange(3, 2)] integerValue];
        NSInteger signOutHour = [[signOutAlertTimeStr substringToIndex:2] integerValue];
        NSInteger signOutMin = [[signOutAlertTimeStr substringWithRange:NSMakeRange(3, 2)] integerValue];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
        
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:24];
        [components setMonth:6];
        [components setYear:2014];
        [components setSecond:0];
        [components setHour:signInHour];
        [components setMinute:signInMin];
        NSDate *signInTimeToFire = [calendar dateFromComponents:components];
        [components setHour:signOutHour];
        [components setMinute:signOutMin];
        NSDate *signOutTimeToFire = [calendar dateFromComponents:components];
        
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = signInTimeToFire;
        localNotification.timeZone = [NSTimeZone defaultTimeZone];
        localNotification.alertBody = @"上班了，该签到啦！";
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.repeatInterval = kCFCalendarUnitWeek;;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        
        localNotification.fireDate = signOutTimeToFire;
        localNotification.alertBody = @"要下班咯，来签退吧！";
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
         */
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"enterForeground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    isActive = YES;
    application.applicationIconBadgeNumber = 0;
    NSLog(@"becomeActive");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"terminate");
    isActive = NO;
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

//添加本地通知，根据日期和通知内容
-(void) addNotificationWithAlertInfo:(NSDictionary*)alertDic Date:(NSDate *)date andRepeatInterval:(NSCalendarUnit)CalUnit
{
    UILocalNotification *localNotification =[[UILocalNotification alloc]init];
    
    localNotification.fireDate=date;
    localNotification.timeZone=[NSTimeZone defaultTimeZone];
    localNotification.repeatCalendar=[NSCalendar currentCalendar];
    localNotification.alertBody=[NSString stringWithFormat:@"%@",[alertDic objectForKey:@"kAlertContent"]];
    
    localNotification.repeatInterval = CalUnit;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber=1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
}

//设置日期，时间和星期几
-(NSDate*)SetDateForAlarmWithWeekday:(int)WeekDay andAlertInfo:(NSDictionary*)dics
{
    NSLog(@"set date for alarm called");
    NSCalendar *calendar=[NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone defaultTimeZone]];
    
    unsigned currentFlag=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit|NSWeekdayCalendarUnit;
    
    NSDateComponents *comp=[calendar components:currentFlag fromDate:[NSDate date]];
    
    NSArray *array = [[dics objectForKey:@"kAlertTime"] componentsSeparatedByString:@":"];
    NSInteger hour = [[array objectAtIndex:0] intValue];
    NSInteger min = [[array objectAtIndex:1] intValue];
    
    comp.hour=hour;
    comp.minute=min;
    comp.second=0;
    
    NSLog(@"set date for alarm (%li:%li:%li)",(long)comp.hour,(long)comp.minute,(long)comp.second);
    NSLog(@"weekday :%i ",WeekDay);
    NSLog(@"comp weekday %li",(long)comp.weekday);
    int diff=(int)(WeekDay-comp.weekday);
    NSLog(@"difference :%d",diff);
    
    int multiplier;
    if (WeekDay==0) {
        multiplier=0;
    }else
    {
        multiplier=diff>0?diff:(diff==0?diff:diff+7);
    }
    
    NSLog(@"multiplier :%i",multiplier);
    
    return [[calendar dateFromComponents:comp]dateByAddingTimeInterval:multiplier*SecondsInOneDay];
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"smartoffice" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SmartOffice.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
