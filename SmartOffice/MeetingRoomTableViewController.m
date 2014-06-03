//
//  MeetingRoomTableViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-5-9.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "MeetingRoomTableViewController.h"
#import "ASIFormDataRequest.h"
#import "RoomReservationCell.h"

static NSString *kRoomReservationCell = @"roomReservationCell";
@interface MeetingRoomTableViewController () <ASIHTTPRequestDelegate>
@property (nonatomic, strong) NSArray *reservationArr;
@end

@implementation MeetingRoomTableViewController

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
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php?r=meetingRoomReservation/clientIndex",ServerUrl];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setPostValue:[Globals userId] forKey:@"userId"];
    request.delegate = self;
    [request startAsynchronous];
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@", request.responseString);
    NSArray *responseArr = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:nil];
    self.reservationArr = [responseArr copy];
    [self.tableView reloadData];
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
    return [self.reservationArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RoomReservationCell *cell = (RoomReservationCell *)[tableView dequeueReusableCellWithIdentifier:kRoomReservationCell];
    NSDictionary *dic = [self.reservationArr objectAtIndex:[indexPath row]];
    cell.nameLabel.text = [dic objectForKey:@"realName"];
    cell.roomNumberLabel.text = [dic objectForKey:@"number"];
    if ([[dic objectForKey:@"status"] isKindOfClass:[NSString class]]) {
        cell.reserveStatus = [[dic objectForKey:@"status"] integerValue];
    }
    cell.meetingAgendaLabel.text = [dic objectForKey:@"agenda"];
    
    NSString *startTimeStr = [dic objectForKey:@"startDate"];
    NSString *endTimeStr = [dic objectForKey:@"endDate"];
    
    NSString *meetingTimeStr = [NSString stringWithFormat:@"%@ - %@", [startTimeStr substringToIndex:16], [endTimeStr substringWithRange:NSMakeRange(11, 5)]];
    
    cell.meetingTimeLabel.text = meetingTimeStr;
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
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
