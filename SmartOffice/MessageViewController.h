//
//  FirstViewController.h
//  SmartOffice
//
//  Created by Peng Ji on 14-2-26.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"

@interface MessageViewController : PullRefreshTableViewController <UITableViewDataSource, UITableViewDelegate>

@end
