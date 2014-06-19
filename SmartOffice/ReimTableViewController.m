//
//  ReimTableViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-4-28.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "ReimTableViewController.h"
#include "ReimProgressTableViewController.h"
#import "ASIFormDataRequest.h"
#import "WaitView.h"

@interface ReimTableViewController () <ASIHTTPRequestDelegate>
@property (nonatomic, strong) NSArray *reimProgressArr;
@property (nonatomic, strong) NSArray *reimArr;
@property (nonatomic, strong) WaitView *waitView;
@end

@implementation ReimTableViewController

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
    [self requestData];
}

- (void) requestData
{
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php?r=reimbursement/clientIndex",ServerUrl];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setPostValue:[Globals userId] forKey:@"userId"];
    request.delegate = self;
    [request startAsynchronous];
    
    CGRect rect = [UIScreen mainScreen].bounds;
    _waitView = [[WaitView alloc] initWithFrame:rect];
    [self.navigationController.view addSubview:_waitView];
}

#pragma mark ASIHTTPDelegate
- (void) requestFinished:(ASIHTTPRequest *)request
{
    [_waitView removeFromSuperview];
    _waitView = nil;
    NSLog(@"%@", request.responseString);
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:nil];
    self.reimProgressArr = [responseDic valueForKey:@"progress"];
    self.reimArr = [responseDic valueForKey:@"reim"];
    [self.tableView reloadData];
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    [_waitView removeFromSuperview];
    _waitView = nil;
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
    return [self.reimArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reimCell" forIndexPath:indexPath];
    NSDictionary *dic = [self.reimArr objectAtIndex:[indexPath row]];
    cell.textLabel.text = [dic objectForKey:@"reason"];
    return cell;
}

#pragma tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"reimProgress" sender:self];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *selIndexPath = [self.tableView indexPathForSelectedRow];
    ReimProgressTableViewController *reimProgressVC = (ReimProgressTableViewController *)[segue destinationViewController];
    reimProgressVC.reimDic = [self.reimArr objectAtIndex:[selIndexPath row]];
    reimProgressVC.reimProgressArr = self.reimProgressArr;
}

@end
