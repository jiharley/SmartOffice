//
//  MessageDetailViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-4-17.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "VaribleTextCell.h"
#import "MessageTitleCell.h"
#import "Announcement.h"
#import "Inform.h"

#define FONT_SIZE 15
static NSString *kMessageContentCell = @"messageContentCell";
static NSString *kMessageTitleCell = @"messageTitleCell";
@interface MessageDetailViewController ()
@property (strong) VaribleTextCell *varibleTextCell;
@end

@implementation MessageDetailViewController

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
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//    self.varibleTextCell = (VaribleTextCell *)[self.tableView dequeueReusableCellWithIdentifier:kMessageContentCell];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 1) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        return screenSize.height - 200;
//        NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:FONT_SIZE] forKey: NSFontAttributeName];
//        
//        CGSize expectedLabelSize = [self.announcement.content boundingRectWithSize:self.varibleTextCell.frame.size options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:stringAttributes context:nil].size;
//        CGFloat verticalPadding = self.varibleTextCell.textLabel.frame.origin.y;
//        return expectedLabelSize.height + 2 * verticalPadding;
    }
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VaribleTextCell *contentCell = nil;
    MessageTitleCell *titleCell = nil;
    switch ([indexPath section]) {
        case 0:
        {//title cell
            titleCell = (MessageTitleCell *)[tableView dequeueReusableCellWithIdentifier:kMessageTitleCell];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            if (self.messageType == 1) {
                titleCell.msgTitleLabel.text = self.inform.title;
                titleCell.announcerLabel.text = self.inform.announcerName;
                titleCell.dateLabel.text = [dateFormatter stringFromDate:self.inform.insertMoment];
                if ([self.inform.isImportant boolValue]) {
                    titleCell.starImage.hidden = NO;
                }
                else {
                    titleCell.starImage.hidden = YES;
                }
            }
            if (self.messageType == 2) {
                titleCell.msgTitleLabel.text = self.announcement.title;
                titleCell.announcerLabel.text = self.announcement.announcerName;
                titleCell.dateLabel.text = [dateFormatter stringFromDate:self.announcement.insertMoment];
                titleCell.starImage.hidden = YES;
            }
            return titleCell;
            break;
        }
        case 1:
        {//message content cell
            contentCell = (VaribleTextCell *)[tableView dequeueReusableCellWithIdentifier:kMessageContentCell];
            CGSize size;
            CGFloat vPadding = contentCell.contentTextView.frame.origin.y;
            CGFloat hPadding = contentCell.contentTextView.frame.origin.x;
            size.height = contentCell.bounds.size.height - 2*vPadding;
            size.width = contentCell.bounds.size.width - 2*hPadding;
            contentCell.frame = CGRectMake(hPadding, vPadding, size.width, size.height);
            if (self.messageType == 1) {
                contentCell.contentTextView.text = self.inform.content;
            }
            if (self.messageType == 2) {
                contentCell.contentTextView.text = self.announcement.content;
            }
            contentCell.contentTextView.editable = NO;
            return contentCell;
        }
        default:
            return nil;
            break;
    }
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
