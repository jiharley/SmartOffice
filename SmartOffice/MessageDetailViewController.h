//
//  MessageDetailViewController.h
//  SmartOffice
//
//  Created by Peng Ji on 14-4-17.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//
@class Announcement,Inform;
#import <UIKit/UIKit.h>

@interface MessageDetailViewController : UITableViewController
@property (nonatomic, strong) Announcement *announcement;
@property (nonatomic, strong) Inform *inform;

@property (assign) short messageType;
@end
