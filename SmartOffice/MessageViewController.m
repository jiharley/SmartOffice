//
//  FirstViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-2-26.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageCell.h"

@interface MessageViewController ()

@end

@implementation MessageViewController
@synthesize tableView = _tableView;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%f",_tableView.contentInset.top);
}

#pragma tableview delegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 4;
            break;
        default:
            return 1;
            break;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

#pragma tableview datasource
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessageCell";
    MessageCell *cell_ = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell_ == nil) {
        cell_ = [[[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:Nil] objectAtIndex:0];
    }
    switch ([indexPath section]) {
        case 0:
            cell_.iconImageView.image = [UIImage imageNamed:@"todo"];
            cell_.titleLable.text = @"周一召开集体会议";
            cell_.dateLable.text = @"2014-03-03";
            cell_.contentLable.text = @"各个小组汇报上周工作，以及本周的计划，供讨论";

            break;
        case 1:
            cell_.iconImageView.image = [UIImage imageNamed:@"notification"];
            cell_.titleLable.text = @"周一召开集体会议";
            cell_.dateLable.text = @"2014-03-03";
            cell_.contentLable.text = @"各个小组汇报上周工作，以及本周的计划，供讨论";
            break;
        case 2:
            cell_.iconImageView.image = [UIImage imageNamed:@"announcement"];
            cell_.titleLable.text = @"周一召开集体会议";
            cell_.dateLable.text = @"2014-03-03";
            cell_.contentLable.text = @"各个小组汇报上周工作，以及本周的计划，供讨论";

            break;
        default:
            break;
    }
    return cell_;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"待办";
            break;
        case 1:
            return @"通知";
            break;
        case 2:
            return @"公告";
            break;
        default:
            return @"";
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshTable:(id)sender {
    NSLog(@"%f",_tableView.contentInset.top);

}
@end
