//
//  ReimProgressTableViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-4-28.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "ReimProgressTableViewController.h"

#define kTitle @"title"
#define kContent @"content"

static NSString *kReimInfoCell = @"reimInfoCell";
static NSString *kReimProgressCell = @"reimProgressCell";

@interface ReimProgressTableViewController ()
@property (strong) NSArray *reimArr;
@property (strong) NSArray *statusArr;

@end

@implementation ReimProgressTableViewController

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
    NSMutableDictionary *item1 = [@{kTitle : @"报销事由", kContent : [_reimDic valueForKey:@"reason"]} mutableCopy];
    NSMutableDictionary *item2 = [@{kTitle : @"金额", kContent : [_reimDic valueForKey:@"money"]} mutableCopy];
    NSMutableDictionary *item3 = [@{kTitle : @"课题号", kContent : [_reimDic valueForKey:@"project"]} mutableCopy];
    NSMutableDictionary *item4 = [@{kTitle : @"提交日期", kContent : [_reimDic valueForKey:@"submitDate"]} mutableCopy];
    NSMutableDictionary *item5 = [@{kTitle : @"备注", kContent : [_reimDic valueForKey:@"remark"]} mutableCopy];
    NSString *reimCompleted = ([[_reimDic valueForKey:@"isCompleted"] integerValue] == 0) ? @"进行中":@"已完成";
    NSMutableDictionary *item6 = [@{kTitle : @"报销进度", kContent : reimCompleted} mutableCopy];
    self.reimArr = @[item1,item2,item3,item4,item5,item6];
    NSString *status = [self.reimDic objectForKey:@"status"];
    self.statusArr = [status componentsSeparatedByString:@","];

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

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"报销详情";
            break;
        case 1:
            return @"报销进度";
            break;
        default:
            return nil;
            break;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return [self.reimArr count];
            break;
        case 1:
            return [self.reimProgressArr count];
            break;
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch ([indexPath section]) {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kReimInfoCell];
            NSDictionary *dic = [self.reimArr objectAtIndex:[indexPath row]];
            cell.textLabel.text = [dic objectForKey:kTitle];
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.detailTextLabel.text = [dic objectForKey:kContent];
            cell.detailTextLabel.textColor = [UIColor blackColor];
            return cell;
            break;
        }
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kReimProgressCell];
            NSDictionary *statusDic = [self.reimProgressArr objectAtIndex:[indexPath row]];
            cell.textLabel.text = [statusDic objectForKey:@"name"];
            NSString *statusId = [statusDic objectForKey:@"id"];
            if ([self.statusArr containsObject:statusId]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            return cell;
        }
        default:
            return nil;
            break;
    }
    
    return cell;
}

#pragma tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
