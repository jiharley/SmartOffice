//
//  MoreViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-2-27.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "MoreViewController.h"

@interface MoreViewController ()

@end

@implementation MoreViewController
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

#pragma tableview delegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 1;
            break;
        default:
            return 1;
            break;
    }
}

#pragma tableview datasource
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell_ = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell_ == nil) {
        cell_ = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    switch ([indexPath section]) {
        case 0:
            cell_.textLabel.text = @"个人信息";
            break;
        case 1:
            switch ([indexPath row]) {
                case 0:
                    cell_.textLabel.text = @"办公室预约";
                    break;
                case 1:
                    cell_.textLabel.text = @"报销进度";
                    break;
                case 2:
                    cell_.textLabel.text = @"合同进度";
                    break;
                default:
                    break;
            }
            break;
        case 2:
            cell_.textLabel.text = @"设置";
            break;
        default:
            break;
    }
    return cell_;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
