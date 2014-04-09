//
//  AbsenseApplyViewController.h
//  SmartOffice
//
//  Created by Peng Ji on 14-3-5.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DateCell.h"
//#import "DatePickerCell.h"
#import "TextViewCell.h"
#import "CheckWholeDayCell.h"
#import "DatePickerCell.h"

@interface AbsenceApplyViewController : UITableViewController
{
    bool isCheckWholeDay;
}
@property short applyType;
@end
