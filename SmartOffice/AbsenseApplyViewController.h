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

@interface AbsenseApplyViewController : UITableViewController
{
    bool isCheckWholeDay;
}

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, retain) NSString *detailReasonString;
// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;

@property (assign) NSInteger pickerCellRowHeight;
@property (assign) NSInteger detailReasonCellRowHeight;

//@property (strong, nonatomic) IBOutlet UIDatePicker *pickerView;

- (IBAction)dateAction:(id)sender;
- (IBAction)checkWholeDayAction:(id)sender;
@end
