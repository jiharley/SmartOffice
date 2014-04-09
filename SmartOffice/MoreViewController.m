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

-(NSManagedObjectContext *) managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

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

#pragma tableview datasource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
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
        case 3:
            return 1;
            break;
        default:
            return 1;
            break;
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch ([indexPath section]) {
        case 0:
            cell.textLabel.text = @"个人信息";
            break;
        case 1:
            switch ([indexPath row]) {
                case 0:
                    cell.textLabel.text = @"办公室预约";
                    break;
                case 1:
                    cell.textLabel.text = @"报销进度";
                    break;
                case 2:
                    cell.textLabel.text = @"合同进度";
                    break;
                default:
                    break;
            }
            break;
        case 2:
            cell.textLabel.text = @"设置";
            break;
        case 3:
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = @"退出登录";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
        default:
            break;
    }
    return cell;

}

#pragma tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0:
        {
            [self performSegueWithIdentifier:@"personalInfo" sender:self];
            break;
        }
        case 3:
        {
            //trigger logout
            [Globals setUsername:nil];
            [Globals setUserId:nil];
            [Globals setUserPassword:nil];
            [Globals setUserInfo:nil];
            [Globals setDeviceToken:nil];
            [Globals setComeSignTime:nil];
            [Globals setLeaveSignTime:nil];
            [Globals setSignDate:nil];
            //删除coredata存储的数据
            NSManagedObjectContext *context = [self managedObjectContext];
            NSEntityDescription *entity = [NSEntityDescription entityForName:kAbsenceApplyEntityName inManagedObjectContext:context];
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setIncludesPropertyValues:NO];
            [request setEntity:entity];
            NSError *error = nil;
            NSArray *datas = [context executeFetchRequest:request error:&error];
            if (!error && datas && [datas count])
            {
                for (NSManagedObject *obj in datas)
                {
                    [context deleteObject:obj];
                }
                if (![context save:&error])
                {  
                    NSLog(@"error:%@",error);  
                }  
            }
            [self.tabBarController performSegueWithIdentifier:@"login" sender:self];
            break;
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
