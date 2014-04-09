//
//  PersonalInfoTableViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-4-8.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "PersonalInfoTableViewController.h"

#define kTitle @"title"
#define kContent @"content"
@interface PersonalInfoTableViewController ()
@property (nonatomic, strong) NSArray *infoArr;
@end

@implementation PersonalInfoTableViewController

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
    NSDictionary *infoDic = [Globals userInfo];
    NSMutableDictionary *item1 = [@{kTitle : @"用户名", kContent : [infoDic valueForKey:kUsername]} mutableCopy];
    NSMutableDictionary *item2 = [@{kTitle : @"姓名", kContent : [infoDic valueForKey:@"realName"]} mutableCopy];
    NSString *gender = [[infoDic valueForKey:@"gender"] intValue] == 0?@"女":@"男";
    NSMutableDictionary *item3 = [@{kTitle : @"性别", kContent : gender} mutableCopy];
    NSMutableDictionary *item4 = [@{kTitle : @"部门", kContent : [infoDic valueForKey:@"department"]} mutableCopy];
    NSMutableDictionary *item5 = [@{kTitle : @"职位", kContent : [infoDic valueForKey:@"position"]} mutableCopy];
    NSMutableDictionary *item6 = [@{kTitle : @"邮箱", kContent : [infoDic valueForKey:@"email"]} mutableCopy];
    NSMutableDictionary *item7 = [@{kTitle : @"手机号", kContent : [infoDic valueForKey:@"phoneNumber"]} mutableCopy];
    
    self.infoArr = @[item1, item2, item3, item4, item5, item6, item7];
}

- (void)viewWillAppear:(BOOL)animated
{
    
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
    return [self.infoArr count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"InfoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    NSDictionary *dic = [self.infoArr objectAtIndex:[indexPath row]];
    cell.textLabel.text = [dic objectForKey:kTitle];
    cell.detailTextLabel.text = [dic objectForKey:kContent];
    return cell;
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
