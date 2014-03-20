//
//  SecondViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-2-26.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "AttendanceViewController.h"
#import "AbsenseApplyViewController.h"

static int count = 1;
static NSString *kApplyCell = @"applyCell";
static NSString *kAppliedCell = @"appliedCell";
@interface AttendanceViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *applyTableView;
@end

@implementation AttendanceViewController
@synthesize timer_ = _timer_;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)beginSign:(id)sender {
    _timer_ = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(runProgress) userInfo:nil repeats:YES];
    
}

- (void)runProgress
{
    count++;
    self.signProgressView_.progress = count*0.1/2;
    if (count >= 20) {
        [_timer_ invalidate];
        _timer_ = nil;
        count = 0;
    }
}

#pragma mark - tableview datasource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"已申请";
    }
    else
    {
        return nil;
    }
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 3;
            break;
        default:
            return 1;
            break;
    }
}

#pragma mark - tableview delegate
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString *cellID = nil;
    
    switch ([indexPath section]) {
        case 0:
        {
            cellID = kApplyCell;
            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            switch ([indexPath row]) {
                case 0:
                    cell.textLabel.text = @"出差申请";
                    break;
                case 1:
                    cell.textLabel.text = @"请假申请";
                    break;
                default:
                    cell.textLabel.text = @"出差申请";
                    break;
            }
            return cell;
            break;
        }
        case 1:
        {
            cellID = kAppliedCell;
            cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            cell.textLabel.text = @"请假：3月18日至3月19日";
            return cell;
        }
        default:
            return cell;
            break;
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AbsenseApplyViewController *destViewController = segue.destinationViewController;
    NSIndexPath *selectedIndexPath = [self.applyTableView indexPathForSelectedRow];
    
    if ([destViewController respondsToSelector:@selector(setApplyType:)]) {
        destViewController.applyType = [selectedIndexPath row];
    }
}
@end
