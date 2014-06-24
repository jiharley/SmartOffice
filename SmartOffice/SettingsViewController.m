//
//  SettingsViewController.m
//  SmartOffice
//
//  Created by 纪鹏 on 14-6-24.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "SettingsViewController.h"
#import "DatePickerCell.h"
#import "CheckerCell.h"

#define kPickerAnimationDuration    0.40   // duration for the animation to slide the date picker into view
#define kDatePickerTag              99     // view tag identifiying the date picker view
// keep track of which rows have date cells
#define kDateStartRow   1
#define kDateEndRow     2

#define kTitleKey       @"title"
#define kTimeKey        @"time"

#define defaultSignInTimeStr @"08:30"
#define defaultSignOutTimeStr @"17:30"

static NSString *kDatePickerID = @"datePicker"; // the cell containing the date picker
static NSString *kTimeCellID = @"alertTimeCell"; // the cell containing the date picker
static NSString *kCheckAlertCellID = @"checkSignAlertCell";

@interface SettingsViewController ()
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSString *signInAlertTimeStr;
@property (nonatomic, strong) NSString *signOutAlertTimeStr;

@property (assign) NSInteger pickerCellRowHeight;

- (IBAction)dateAction:(id)sender;
- (IBAction)checkSignAlertAction:(id)sender;
@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.dateFormatter = [[NSDateFormatter alloc] init];
//    [self.dateFormatter setDateStyle:NSDateFormatterNoStyle];
//    [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [self.dateFormatter setDateFormat:@"HH:mm"];
    if ([Globals signInAlertTime] && [Globals signOutAlertTime]) {
        self.signInAlertTimeStr = [Globals signInAlertTime];
        self.signOutAlertTimeStr = [Globals signOutAlertTime];
    }
    else{
        self.signInAlertTimeStr = defaultSignInTimeStr;
        self.signOutAlertTimeStr = defaultSignOutTimeStr;
    }
    if ([[Globals signAlertSwitch] isEqualToString:@"OFF"]) {
        isCheckSignAlert = NO;
    }
    else{
        isCheckSignAlert = YES;
    }
    NSDate *signInTime = [self.dateFormatter dateFromString:self.signInAlertTimeStr];
    NSDate *signOutTime = [self.dateFormatter dateFromString:self.signOutAlertTimeStr];
    NSMutableDictionary *itemOne = [@{ kTitleKey : @"whole day"} mutableCopy];
    NSMutableDictionary *itemTwo = [@{ kTitleKey: @"签到提醒时间",
                                       kTimeKey: signInTime} mutableCopy];
    NSMutableDictionary *itemThree = [@{ kTitleKey: @"签退提醒时间",
                                       kTimeKey: signOutTime} mutableCopy];
    self.dataArray = @[itemOne, itemTwo, itemThree];
    
    DatePickerCell *datePickCell = (DatePickerCell*) [self.tableView dequeueReusableCellWithIdentifier:kDatePickerID];
    datePickCell.datePickerView.datePickerMode = UIDatePickerModeDate;
    // obtain the picker view cell's height, works because the cell was pre-defined in our storyboard
    self.pickerCellRowHeight = datePickCell.frame.size.height;
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (isCheckSignAlert) {
        [Globals setSignAlertOn:YES];
    }
    else {
        [Globals setSignAlertOn:NO];
    }
    [Globals setSignInAlertTime:self.signInAlertTimeStr];
    [Globals setSignOutAlertTime:self.signOutAlertTimeStr];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (isCheckSignAlert) {
        if ([self hasInlineDatePicker])
        {
            // we have a date picker, so allow for it in the number of rows in this section
            NSInteger numRows = self.dataArray.count;
            return ++numRows;
        }
        return self.dataArray.count;
    }
    else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *timeCell = nil;
    CheckerCell *switchCell = nil;
    DatePickerCell *pickerCell = nil;

    NSString *cellID = kTimeCellID;
    if ([indexPath section] == 0 && [indexPath row] == 0) {
        cellID = kCheckAlertCellID;
    }
    else if ([self indexPathHasPicker:indexPath])
    {
        // the indexPath is the one containing the inline date picker
        cellID = kDatePickerID;     // the current/opened date picker cell
    }
    switch ([indexPath section]) {
        case 0:
        {
            switch ([indexPath row]) {
                case 0:
                {
                    switchCell = (CheckerCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
                    [switchCell.switcher setOn:isCheckSignAlert animated:NO];
                    return switchCell;
                    break;
                }
                default:
                {
                    if ([self indexPathHasPicker:indexPath]) {
                        pickerCell = (DatePickerCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
//                        pickerCell.datePickerView.datePickerMode = UIDatePickerModeTime;
                        
                        return pickerCell;
                    }
                    else {
                        timeCell = [tableView dequeueReusableCellWithIdentifier:cellID];
                        
                        // if we have a date picker open whose cell is above the cell we want to update,
                        // then we have one more cell than the model allows
                        //
                        NSInteger modelRow = indexPath.row;
                        if (self.datePickerIndexPath != nil && self.datePickerIndexPath.row < indexPath.row)
                        {
                            modelRow--;
                        }
                        // proceed to configure our cell
                        if ([cellID isEqualToString:kTimeCellID])
                        {
                            // we have either start or end date cells, populate their date field
                            //
                            NSDictionary *itemData = self.dataArray[modelRow];
                            timeCell.textLabel.text = [itemData valueForKey:kTitleKey];
                            timeCell.detailTextLabel.text = [self.dateFormatter stringFromDate:[itemData valueForKey:kTimeKey]];
                        }
                        return timeCell;
                    }
                    break;
                }
            }
            break;
        }
        default:
        {
            return timeCell;
            break;
        }
    }

}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0:
            return ([self indexPathHasPicker:indexPath] ? self.pickerCellRowHeight : self.tableView.rowHeight);
            break;
        default:
            return self.tableView.rowHeight;
            break;
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.reuseIdentifier == kTimeCellID)
    {
        [self displayInlineDatePickerForRowAtIndexPath:indexPath];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


#pragma mark - Actions

/*! User chose to change the date by changing the values inside the UIDatePicker.
 
 @param sender The sender for this action: UIDatePicker.
 */
- (IBAction)dateAction:(id)sender
{
    NSIndexPath *targetedCellIndexPath = nil;
    
    if ([self hasInlineDatePicker])
    {
        // inline date picker: update the cell's date "above" the date picker cell
        targetedCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    }
    else
    {
        // external date picker: update the current "selected" cell's date
        targetedCellIndexPath = [self.tableView indexPathForSelectedRow];
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    UIDatePicker *targetedDatePicker = sender;
    
    
    // update our data model
    NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];
    [itemData setValue:targetedDatePicker.date forKey:kTimeKey];
    
    // update the cell's date string
    NSString *timeStr = [self.dateFormatter stringFromDate:targetedDatePicker.date];
    cell.detailTextLabel.text = timeStr;
    
    //将设置的时间复制给全局变量
    switch (targetedCellIndexPath.row) {
        case 1:
            self.signInAlertTimeStr = timeStr;
            break;
        case 2:
            self.signOutAlertTimeStr = timeStr;
            break;
        default:
            break;
    }
}

- (IBAction)checkSignAlertAction:(id)sender {
    UISwitch *switcher = (id) sender;
    if ([switcher isOn]) {
        isCheckSignAlert = YES;
//        NSMutableDictionary *itemData = self.dataArray[0];
//        [itemData setValue:@"1" forKey:kWholeDay];
    } else {
        isCheckSignAlert = NO;
//        NSMutableDictionary *itemData = self.dataArray[0];
//        [itemData setValue:@"0" forKey:kWholeDay];
    }
    [self.tableView reloadData];

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*! Determines if the given indexPath has a cell below it with a UIDatePicker.
 
 @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
 */
- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasDatePicker = NO;
    
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    DatePickerCell *checkDatePickerCell =
    (DatePickerCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];
    UIDatePicker *checkDatePicker = (UIDatePicker *)[checkDatePickerCell viewWithTag:kDatePickerTag];
    
    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}

/*! Updates the UIDatePicker's value to match with the date of the cell above it.
 */
- (void)updateDatePicker
{
    if (self.datePickerIndexPath != nil)
    {
        DatePickerCell *associatedDatePickerCell = (DatePickerCell*)[self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];
        
        UIDatePicker *targetedDatePicker = (UIDatePicker *)[associatedDatePickerCell viewWithTag:kDatePickerTag];
        if (targetedDatePicker != nil)
        {
            // we found a UIDatePicker in this cell, so update it's date value
            //
            NSDictionary *itemData = self.dataArray[self.datePickerIndexPath.row - 1];
            [targetedDatePicker setDate:[itemData valueForKey:kTimeKey] animated:NO];
        }
    }
}

/*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
 */
- (BOOL)hasInlineDatePicker
{
    return (self.datePickerIndexPath != nil);
}

/*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
 
 @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
 */
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return ([self hasInlineDatePicker] && self.datePickerIndexPath.row == indexPath.row);
}

/*! Determines if the given indexPath points to a cell that contains the start/end dates.
 
 @param indexPath The indexPath to check if it represents start/end date cell.
 */
- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath
{
    BOOL hasDate = NO;
    
    if ((indexPath.row == kDateStartRow) ||
        (indexPath.row == kDateEndRow || ([self hasInlineDatePicker] && (indexPath.row == kDateEndRow + 1))))
    {
        hasDate = YES;
    }
    
    return hasDate;
}

/*! Adds or removes a UIDatePicker cell below the given indexPath.
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
    
    // check if 'indexPath' has an attached date picker below it
    if ([self hasPickerForIndexPath:indexPath])
    {
        // found a picker below it, so remove it
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        // didn't find a picker below it, so we should insert it
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
}

/*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display the date picker inline with the table content
    [self.tableView beginUpdates];
    
    BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
    if ([self hasInlineDatePicker])
    {
        before = self.datePickerIndexPath.row < indexPath.row;
    }
    
    BOOL sameCellClicked = (self.datePickerIndexPath.row - 1 == indexPath.row);
    
    // remove any date picker cell if it exists
    if ([self hasInlineDatePicker])
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }
    
    if (!sameCellClicked)
    {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:0];
        
        [self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0];
    }
    
    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
    
    // inform our date picker of the current date to match the current cell
    [self updateDatePicker];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
