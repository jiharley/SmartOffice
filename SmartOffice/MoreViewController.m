//
//  MoreViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-2-27.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "MoreViewController.h"
#import "PersonalInfoTableViewController.h"
#import "ContractTableViewController.h"
#import "ReimTableViewController.h"

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
        case 1:
        {
            switch ([indexPath row]) {
                case 0:
                    break;
                case 1:
                    [self performSegueWithIdentifier:@"reimbursement" sender:self];
                    break;
                case 2:
                    [self performSegueWithIdentifier:@"contract" sender:self];
                    break;
                default:
                    break;
            }
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
            [self deleteAllObjects:kAbsenceApplyEntityName];
            [self deleteAllObjects:kAnnouncementEntityName];
            [self deleteAllObjects:kInformEntityName];
            
            [self.tabBarController performSegueWithIdentifier:@"login" sender:self];
            break;
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) deleteAllObjects: (NSString *) entityDescription  {
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:managedObjectContext];
    [fetchRequest setIncludesPropertyValues:NO];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
    	[managedObjectContext deleteObject:managedObject];
    	NSLog(@"%@ object deleted",entityDescription);
    }
    if (![managedObjectContext save:&error]) {
    	NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"personalInfo"]) {
        PersonalInfoTableViewController *personalInfoTableViewController = (PersonalInfoTableViewController *)[segue destinationViewController];
        personalInfoTableViewController.hidesBottomBarWhenPushed = YES;
    }
    if ([segue.identifier isEqualToString:@"reimbursement"]) {
        ReimTableViewController *reimVC = (ReimTableViewController *) [segue destinationViewController];
        reimVC.hidesBottomBarWhenPushed = YES;
    }
    if ([segue.identifier isEqualToString:@"contract"]) {
        ContractTableViewController *contractVC = (ContractTableViewController *)[segue destinationViewController];
        contractVC.hidesBottomBarWhenPushed = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
