//
//  ContractTableViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-4-28.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "ContractTableViewController.h"
#import "ASIFormDataRequest.h"
#import "ContractProgressViewController.h"
#import "WaitView.h"

@interface ContractTableViewController ()<ASIHTTPRequestDelegate>
@property (nonatomic, strong) NSArray *contracProgressArr;
@property (nonatomic, strong) NSArray *contractArr;
@property (nonatomic, strong) WaitView *waitView;

@end

@implementation ContractTableViewController

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
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php?r=contract/clientIndex",ServerUrl];
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
    self.contracProgressArr = [responseDic valueForKey:@"progress"];
    self.contractArr = [responseDic valueForKey:@"contract"];
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
    return [self.contractArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contractCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *dic = [self.contractArr objectAtIndex:[indexPath row]];
    cell.textLabel.text = [dic objectForKey:@"name"];
    return cell;
}

#pragma tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"contractProgress" sender:self];
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
    ContractProgressViewController *contractProgressVC = (ContractProgressViewController *)[segue destinationViewController];
    contractProgressVC.contractDic = [self.contractArr objectAtIndex:[selIndexPath row]];
    contractProgressVC.contractProgressArr = self.contracProgressArr;
}

@end
