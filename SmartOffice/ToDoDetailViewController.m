//
//  ToDoDetailViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-4-10.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "ToDoDetailViewController.h"
#import "TextViewCell.h"
#import "AbsenceApply.h"
#import "ASIFormDataRequest.h"
#import "WaitView.h"

#define kTitle @"title"
#define kContent @"content"

static NSString *kTimeCell = @"timeCell";
static NSString *kDetailCell = @"detailReasonCell";
@interface ToDoDetailViewController ()<UIAlertViewDelegate>
@property (nonatomic, strong) NSArray *detailInfoArr;
@property (nonatomic, strong) NSString *title;
@property (assign) NSInteger detailReasonCellRowHeight;

@property (nonatomic, strong) WaitView *waitView;

//@property (assign) NSInteger sectionCount;
- (IBAction)actionAgree:(id)sender;
- (IBAction)actionDisagree:(id)sender;

@end

@implementation ToDoDetailViewController

-(NSManagedObjectContext *) managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

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
//    if ([self.absenceApply.userId intValue] == [[Globals userId] intValue]) {
//        self.sectionCount = 2;
//    }
//    else {
//        self.sectionCount = 3;
//    }

    TextViewCell *detailReasonCell = (TextViewCell*)[self.tableView dequeueReusableCellWithIdentifier:kDetailCell];
    self.detailReasonCellRowHeight = detailReasonCell.frame.size.height;

    NSString *name = self.absenceApply.realName;
    if ([self.absenceApply.userId intValue] == [[Globals userId] intValue]) {
        name = @"我";
    }
    NSString *typeName = @"";
    switch ([self.absenceApply.type intValue]) {
        case 1:
            typeName = @"出差";break;
        case 2:
            typeName = @"请假";break;
        default:
            break;
    }
    self.title = [NSString stringWithFormat:@"%@申请了%@", name, typeName];
    //config detailLabel of todocell
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *startDate = [dateFormatter stringFromDate:self.absenceApply.startDate];
    NSString *endDate = [dateFormatter stringFromDate:self.absenceApply.endDate];
    NSMutableDictionary *item1 = [@{kTitle:@"从", kContent : startDate} mutableCopy];
    NSMutableDictionary *item2 = [@{kTitle:@"到",kContent:endDate} mutableCopy];

    //config statusLabel of todocell
    NSString *status = @"";
    switch ([self.absenceApply.status intValue]) {
        case 0:
            status = @"申请中";
            break;
        case 1:
            status = @"申请成功";
            break;
        case 2:
            status = @"申请失败";
            break;
        case 3:
            status = @"等待高层审批";
            break;
        default:
            break;
    }
    NSMutableDictionary *item3 = [@{kTitle:@"状态",kContent:status} mutableCopy];
    self.detailInfoArr = @[item1, item2, item3];
}

- (void)requestForAgree:(BOOL)isAgree withFeedback:(NSString *)feedback
{
    CGRect rect = [UIScreen mainScreen].bounds;
    _waitView = [[WaitView alloc] initWithFrame:rect];
    [self.navigationController.view addSubview:_waitView];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php?r=absenseApply/clientUpdate",ServerUrl ];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    __weak ASIFormDataRequest *request_ = request;
    [request setPostValue:self.absenceApply.applyId forKey:@"applyId"];
    [request setPostValue:self.absenceApply.userId forKey:@"applyUserId"];
    [request setPostValue:[Globals userId] forKey:@"userId"];
    [request setPostValue:[NSString stringWithFormat:@"%d",isAgree] forKey:@"isAgree"];
    if (!isAgree) {
        [request setPostValue:feedback forKey:@"feedback"];
    }
    //操作成功，数据返回后的处理
    [request setCompletionBlock:^{
        [_waitView removeFromSuperview];
        _waitView = nil;

        NSLog(@"%@", request_.responseString);
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:[request_ responseData] options:kNilOptions error:nil];
        if ([[resultDic valueForKey:@"resultCode"] intValue] == 1)
        {
            self.absenceApply.status = [NSNumber numberWithInt:(isAgree?1:2)];
            if (!isAgree) {
                self.absenceApply.feedback = feedback;
            }
            NSManagedObjectContext *context = [self managedObjectContext];
            NSError *error = nil;
            if (![context save:&error])
            {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            else
            {
                NSDictionary *statusDic = [self.detailInfoArr objectAtIndex:2];
                if (isAgree) {
                    [statusDic setValue:@"申请成功" forKey:kContent];
                }
                else {
                    [statusDic setValue:@"申请失败" forKey:kContent];
                }
                [self.tableView reloadData];
            }
        }
        else if ([[resultDic valueForKey:@"resultCode"] intValue] == 3)
        {
            self.absenceApply.status = [NSNumber numberWithInt:3];
            NSManagedObjectContext *context = [self managedObjectContext];
            NSError *error = nil;
            if (![context save:&error])
            {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            else
            {
                NSDictionary *statusDic = [self.detailInfoArr objectAtIndex:2];
                [statusDic setValue:@"等待高层审批" forKey:kContent];
                [self.tableView reloadData];
            }
        }
        else
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"操作失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [av show];
        }
    }];
    //操作失败
    [request setFailedBlock:^{
        [_waitView removeFromSuperview];
        _waitView = nil;

        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil message:@"网络错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [av show];
    }];
    [request startAsynchronous];

}

- (IBAction)actionAgree:(id)sender {
    [self requestForAgree:YES withFeedback:nil];
}

- (IBAction)actionDisagree:(id)sender {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"请填写驳回理由" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定驳回", nil];
    [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
    av.tag = 1;
    [av show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (1 == alertView.tag) {
        if (1 == buttonIndex) {
            UITextField *textField = [alertView textFieldAtIndex:0];
            [self requestForAgree:NO withFeedback:textField.text];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    switch ([self.absenceApply.status intValue])
    {
        case 0:
        {
            if ([self.absenceApply.userId intValue] == [[Globals userId] intValue]) {
                return 2;
            }
            else {
                return 3;
            }
            break;
        }
        case 1:
        {
            return 2;
            break;
        }
        case 2:
        {
            return 3;
            break;
        }
        case 3:
        {
            if ([[[Globals userInfo] objectForKey:@"position"] isEqualToString:@"boss"]) {
                return 3;
            }
            else
            {
                return 2;
            }
            break;
        }
        default:
            return 2;
            break;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section) {
        return 20;
    }
    return 20;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 1:
            return @"申请理由";
            break;
        case 2:
            if ([self.absenceApply.status intValue] == 2) {
                return @"驳回理由";
            }
            return nil;
            break;
        default:
            return nil;
            break;
    }
}
//- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        UILabel *myLabel = [[UILabel alloc] init];
//        myLabel.frame = CGRectMake(20, 20, 320, 20);
//        myLabel.font = [UIFont boldSystemFontOfSize:20];
//        myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
//        
//        UIView *headerView = [[UIView alloc] init];
//        [headerView addSubview:myLabel];
//        
//        return headerView;
//    }
//    else{
//        return nil;
//    }
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return 3;
    }
    else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *timeCell = nil;
    UITableViewCell *actionCell = nil;
    TextViewCell *detailCell = nil;
    switch ([indexPath section]) {
        case 0:
        {
            timeCell = [tableView dequeueReusableCellWithIdentifier:kTimeCell forIndexPath:indexPath];
            NSDictionary *dic = [self.detailInfoArr objectAtIndex:[indexPath row]];
            timeCell.textLabel.text = [dic objectForKey:kTitle];
            timeCell.textLabel.textColor = [UIColor lightGrayColor];
            timeCell.detailTextLabel.text = [dic objectForKey:kContent];
            timeCell.detailTextLabel.textColor = [UIColor blackColor];
            return timeCell;
            break;
        }
        case 1:
        {
            detailCell = (TextViewCell*)[tableView dequeueReusableCellWithIdentifier:kDetailCell];
            detailCell.detailReasonTextView.text = self.absenceApply.detail;
            return detailCell;
        }
        case 2:
        {
            if ([self.absenceApply.status intValue] == 0 || [self.absenceApply.status intValue] == 3) {
                actionCell = [tableView dequeueReusableCellWithIdentifier:@"actionCell"];
                return actionCell;
            }
            else if([self.absenceApply.status intValue] == 2) {
                detailCell = (TextViewCell*)[tableView dequeueReusableCellWithIdentifier:kDetailCell];
                detailCell.detailReasonTextView.text = self.absenceApply.feedback;
                return detailCell;
            }
            else {
                return nil;
            }
            break;
        }
        default:
            return nil;
            break;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 1 || ([indexPath section] == 2 && [self.absenceApply.status intValue] == 2)) {
        return self.detailReasonCellRowHeight;
    }
    else {
        return 40.0;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
