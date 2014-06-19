//
//  AbsenseApplyViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-3-5.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "AbsenceApplyViewController.h"
#import "ASIFormDataRequest.h"
#import "WaitView.h"

#define kPickerAnimationDuration    0.40   // duration for the animation to slide the date picker into view
#define kDatePickerTag              99     // view tag identifiying the date picker view

#define kTitleKey       @"title"   // key for obtaining the data source item's title
#define kDateKey        @"date"    // key for obtaining the data source item's date value
#define kWholeDay       @"isWholeDay"

// keep track of which rows have date cells
#define kDateStartRow   1
#define kDateEndRow     2

#define BusinessApply 1
#define VacationApply 2
static NSString *kDateCellID = @"dateCell";     // the cells with the start or end date
static NSString *kDatePickerID = @"datePicker"; // the cell containing the date picker
static NSString *kDetailReasonCellID = @"detailReasonCell"; //the cell for detailed reason for absence
static NSString *kCheckWholeDayCellID = @"checkWholeDayCell";

@interface AbsenceApplyViewController () <ASIHTTPRequestDelegate, UIAlertViewDelegate>
@property (nonatomic, retain) NSString *placeHolderString;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

//@property (nonatomic, retain) NSString *detailReasonString;
// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;

@property (assign) NSInteger pickerCellRowHeight;
@property (assign) NSInteger detailReasonCellRowHeight;

@property (strong, nonatomic) IBOutlet UIDatePicker *pickerView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (nonatomic, strong) WaitView *waitView;

- (IBAction)dateAction:(id)sender;
- (IBAction)doneAction:(id)sender;
- (IBAction)checkWholeDayAction:(id)sender;
- (IBAction)sendApplyAction:(id)sender;

@end

@implementation AbsenceApplyViewController

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

    //get the apply type and set up title and placehold string
    NSString *title = self.applyType == BusinessApply ? @"出差":@"请假";
    self.navigationItem.title = title;
    self.placeHolderString = [NSString stringWithFormat:@"%@详情", title];
    
    // setup our data source
    NSMutableDictionary *itemOne = [@{ kTitleKey : @"whole day",
                                       kWholeDay : @"1"} mutableCopy];
    NSMutableDictionary *itemTwo = [@{ kTitleKey : @"从",
                                       kDateKey : [NSDate date] } mutableCopy];
    NSMutableDictionary *itemThree = [@{ kTitleKey : @"到",
                                         kDateKey : [NSDate date] } mutableCopy];
    self.dataArray = @[itemOne, itemTwo, itemThree];

    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    DatePickerCell *datePickCell = (DatePickerCell*) [self.tableView dequeueReusableCellWithIdentifier:kDatePickerID];
    datePickCell.datePickerView.datePickerMode = UIDatePickerModeDate;
    // obtain the picker view cell's height, works because the cell was pre-defined in our storyboard
    self.pickerCellRowHeight = datePickCell.frame.size.height;
    
    
    TextViewCell *detailReasonCell = (TextViewCell*)[self.tableView dequeueReusableCellWithIdentifier:kDetailReasonCellID];
    self.detailReasonCellRowHeight = detailReasonCell.frame.size.height;
    
    datePickCell = nil;
    detailReasonCell = nil;
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:kDetailReason];
//    self.detailReasonString = @"";
    isCheckWholeDay = YES;
    
    // if the local changes while in the background, we need to be notified so we can update the date
    // format in the table view cells
    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localeChanged:)
                                                 name:NSCurrentLocaleDidChangeNotification
                                               object:nil];

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSCurrentLocaleDidChangeNotification
                                                  object:nil];
}

- (IBAction)sendApplyAction:(id)sender {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *startDate = [dateFormatter stringFromDate:[self.dataArray[1] valueForKey:kDateKey]];
    NSString *endDate = [dateFormatter stringFromDate:[self.dataArray[2] valueForKey:kDateKey]];
    if (isCheckWholeDay) {
        startDate = [[startDate substringToIndex:10] stringByAppendingString:@" 08:00:00"];
        endDate = [[endDate substringToIndex:10] stringByAppendingString:@" 18:00:00"];
    }
    //检查日期合法性
    NSTimeInterval timeInterval = [[dateFormatter dateFromString:endDate] timeIntervalSinceDate:[dateFormatter dateFromString:startDate]];
    if (timeInterval <= 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"开始日期必须早于结束日期" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    //检查是否填写理由
    NSString *reasonStr = [[NSUserDefaults standardUserDefaults] valueForKey:kDetailReason];
    if(reasonStr.length == 0)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"请填写详情" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [av show];
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php?r=absenseApply/clientCreate",ServerUrl];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setPostValue:[Globals userId] forKey:@"userId"];
    [request setPostValue:startDate forKey:@"startDate"];
    [request setPostValue:endDate forKey:@"endDate"];
    [request setPostValue:[[NSUserDefaults standardUserDefaults] valueForKey:kDetailReason] forKey:@"detail"];
    [request setPostValue:[NSString stringWithFormat:@"%d",self.applyType] forKey:@"type"];
    request.delegate = self;
    [request startAsynchronous];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    _waitView = [[WaitView alloc] initWithFrame:rect];
    [self.navigationController.view addSubview:_waitView];

}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    [_waitView removeFromSuperview];
    _waitView = nil;

    NSLog(@"%@", request.responseString);
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:nil];
    int resultCode = [[responseDic valueForKey:@"resultCode"] intValue];
    if (1 == resultCode) {
        //申请成功
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"申请成功" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        av.tag = 1;
        [av show];
    }
    else {
        NSString *errorMsg = [responseDic valueForKey:@"message"];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:errorMsg delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        av.tag = 0;
        [av show];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [_waitView removeFromSuperview];
    _waitView = nil;

    UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"网络错误" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    av.tag = 0;
    [av show];
}

-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (1 == alertView.tag) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Locale

/*! Responds to region format or locale changes.
 */
- (void)localeChanged:(NSNotification *)notif
{
    // the user changed the locale (region format) in Settings, so we are notified here to
    // update the date format in the table view cells
    //
    [self.tableView reloadData];
}

#pragma mark - Utilities

/*! Returns the major version of iOS, (i.e. for iOS 6.1.3 it returns 6)
 */
NSUInteger DeviceSystemMajorVersion()
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    
    return _deviceSystemMajorVersion;
}

#define EMBEDDED_DATE_PICKER (DeviceSystemMajorVersion() >= 7)

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
            [targetedDatePicker setDate:[itemData valueForKey:kDateKey] animated:NO];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0:
            return ([self indexPathHasPicker:indexPath] ? self.pickerCellRowHeight : self.tableView.rowHeight);
            break;
        case 1:
            return self.detailReasonCellRowHeight;
            break;
        default:
            return self.tableView.rowHeight;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            // Return the number of rows in the section.
            if ([self hasInlineDatePicker])
            {
                // we have a date picker, so allow for it in the number of rows in this section
                NSInteger numRows = self.dataArray.count;
                return ++numRows;
            }
            return self.dataArray.count;
            break;
        case 1:
            return 1;
            break;
        default:
            return 1;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *dateCell = nil;
    TextViewCell *textViewCell = nil;
    CheckWholeDayCell *switchCell = nil;
    DatePickerCell *pickerCell = nil;
    
    NSString *cellID = kDetailReasonCellID;
    
    if ([indexPath section] == 0 && [indexPath row] == 0) {
        cellID = kCheckWholeDayCellID;
    }
    else if ([self indexPathHasPicker:indexPath])
    {
        // the indexPath is the one containing the inline date picker
        cellID = kDatePickerID;     // the current/opened date picker cell
    }
    else if ([self indexPathHasDate:indexPath])
    {
        // the indexPath is one that contains the date information
        cellID = kDateCellID;       // the start/end date cells
    }
    switch ([indexPath section]) {
        case 0:
        {
            switch ([indexPath row]) {
                case 0:
                {
                    switchCell = (CheckWholeDayCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
                    [switchCell.checkWholeDaySwitch setOn:isCheckWholeDay animated:NO];
                    return switchCell;
                    break;
                }
                default:
                {
                    if ([self indexPathHasPicker:indexPath]) {
                        pickerCell = (DatePickerCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
                        pickerCell.datePickerView.minimumDate = [NSDate date];
                        if (isCheckWholeDay) {
                            pickerCell.datePickerView.datePickerMode = UIDatePickerModeDate;
                        } else {
                            pickerCell.datePickerView.datePickerMode = UIDatePickerModeDateAndTime;
                            pickerCell.datePickerView.minuteInterval = 30;
                        }
                        return pickerCell;
                    }
                    else {
                        dateCell = [tableView dequeueReusableCellWithIdentifier:cellID];
                        
                        // if we have a date picker open whose cell is above the cell we want to update,
                        // then we have one more cell than the model allows
                        //
                        NSInteger modelRow = indexPath.row;
                        if (self.datePickerIndexPath != nil && self.datePickerIndexPath.row < indexPath.row)
                        {
                            modelRow--;
                        }
                        // proceed to configure our cell
                        if ([cellID isEqualToString:kDateCellID])
                        {
                            // we have either start or end date cells, populate their date field
                            //
                            NSDictionary *itemData = self.dataArray[modelRow];
                            dateCell.textLabel.text = [itemData valueForKey:kTitleKey];
                            dateCell.detailTextLabel.text = [self.dateFormatter stringFromDate:[itemData valueForKey:kDateKey]];
                        }
                        return dateCell;
                    }
                    break;
                }
            }
            break;
        }
        case 1:
        {
            textViewCell = (TextViewCell*) [tableView dequeueReusableCellWithIdentifier:kDetailReasonCellID];
            textViewCell.detailReasonTextView.delegate = textViewCell;
            textViewCell.placeHolderLabel.text = self.placeHolderString;
//            if ([_detailReasonString isEqualToString:@""]) {
//                textViewCell.detailReasonTextView.text = @"详情";
//                textViewCell.detailReasonTextView.textColor = [UIColor lightGrayColor];
//            }
//            else{
                textViewCell.detailReasonTextView.text = [[NSUserDefaults standardUserDefaults] valueForKey:kDetailReason];
//                textViewCell.detailReasonTextView.textColor = [UIColor blackColor];
//            }
            return textViewCell;
            break;
        }
        default:
        {
            return dateCell;
            break;
        }
    }
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

/*! Reveals the UIDatePicker as an external slide-in view, iOS 6.1.x and earlier, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath used to display the UIDatePicker.
 */
- (void)displayExternalDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // first update the date picker's date value according to our model
    NSDictionary *itemData = self.dataArray[indexPath.row];
    [self.pickerView setDate:[itemData valueForKey:kDateKey] animated:YES];
    
    // the date picker might already be showing, so don't add it to our view
    if (self.pickerView.superview == nil)
    {
        CGRect startFrame = self.pickerView.frame;
        CGRect endFrame = self.pickerView.frame;
        
        // the start position is below the bottom of the visible frame
        startFrame.origin.y = self.view.frame.size.height;
        
        // the end position is slid up by the height of the view
        endFrame.origin.y = startFrame.origin.y - endFrame.size.height;
        
        self.pickerView.frame = startFrame;
        
        [self.view addSubview:self.pickerView];
        
        // animate the date picker into view
        [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.pickerView.frame = endFrame; }
                         completion:^(BOOL finished) {
                             // add the "Done" button to the nav bar
                             self.navigationItem.rightBarButtonItem = self.doneButton;
                         }];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.reuseIdentifier == kDateCellID)
    {
        if (EMBEDDED_DATE_PICKER)
            [self displayInlineDatePickerForRowAtIndexPath:indexPath];
        else
            [self displayExternalDatePickerForRowAtIndexPath:indexPath];
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
    [itemData setValue:targetedDatePicker.date forKey:kDateKey];
    
    // update the cell's date string
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:targetedDatePicker.date];
}

/*! User chose to finish using the UIDatePicker by pressing the "Done" button, (used only for non-inline date picker), iOS 6.1.x or earlier
 
 @param sender The sender for this action: The "Done" UIBarButtonItem
 */
- (IBAction)doneAction:(id)sender {
    CGRect pickerFrame = self.pickerView.frame;
    pickerFrame.origin.y = self.view.frame.size.height;
    
    // animate the date picker out of view
    [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.pickerView.frame = pickerFrame; }
                     completion:^(BOOL finished) {
                         [self.pickerView removeFromSuperview];
                     }];
    
    // remove the "Done" button in the navigation bar
	self.navigationItem.rightBarButtonItem = nil;
    
    // deselect the current table cell
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)checkWholeDayAction:(id)sender {
    UISwitch *switcher = (id) sender;
    if ([switcher isOn]) {
        isCheckWholeDay = YES;
        NSMutableDictionary *itemData = self.dataArray[0];
        [itemData setValue:@"1" forKey:kWholeDay];
        [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
//        _pickerView.datePickerMode = UIDatePickerModeDate;
    } else {
        isCheckWholeDay = NO;
        NSMutableDictionary *itemData = self.dataArray[0];
        [itemData setValue:@"0" forKey:kWholeDay];
        [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [self.dateFormatter setTimeStyle:NSDateFormatterShortStyle];
//        _pickerView.datePickerMode = UIDatePickerModeDateAndTime;
    }
    [self.tableView reloadData];
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
