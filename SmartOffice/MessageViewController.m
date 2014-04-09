//
//  FirstViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-2-26.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageCell.h"
#import "ToDoCell.h"
#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import "AbsenceApply.h"

#define kAPTitle @"AbsenceApplyTitle"
#define kAPDetail @"AbsenceApplyDetail"
#define kAPStatus @"AbsenceApplyStatus"

static NSString *kMessageCell = @"MessageCell";
static NSString *kToDoCell = @"ToDoCell";

@interface MessageViewController ()<ASIHTTPRequestDelegate>

@property (strong, nonatomic) NSArray *toDoArr;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MessageViewController

-(NSManagedObjectContext *) managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self fetchToDoList];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _managedObjectContext = [self managedObjectContext];
    self.toDoArr = [[NSArray alloc] init];
    [self fetchToDoList];
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _activityIndicator.color = [UIColor lightGrayColor];
    UIBarButtonItem * barButton =
    [[UIBarButtonItem alloc] initWithCustomView:_activityIndicator];
    barButton.style = UIBarButtonItemStylePlain;
    [[self navigationItem] setRightBarButtonItem:barButton animated:YES];
    
    [self refresh];
}

- (void) fetchToDoList
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:kAbsenceApplyEntityName inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *todayStr = [NSString stringWithFormat:@"%@ 00:00:00", [dateFormatter stringFromDate:now]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSDate *today = [dateFormatter dateFromString:todayStr];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(endDate >= %@)", today];
    [fetchRequest setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSError *error;
    NSArray *resultArr = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (resultArr == nil)
    {
        // Deal with error...
    }
    NSMutableArray *tempToDoArr = [NSMutableArray array];
    for (int i=0; i<[resultArr count]; i++) {
        AbsenceApply *absenceApply = [resultArr objectAtIndex:i];
        NSMutableDictionary *applyEntry = [NSMutableDictionary dictionary];
        NSString *name = absenceApply.realName;
        if ([absenceApply.userId intValue] == [[Globals userId] intValue]) {
            name = @"我";
        }
        NSString *typeName = @"";
        switch ([absenceApply.type intValue]) {
            case 1:
                typeName = @"出差";break;
            case 2:
                typeName = @"请假";break;
            default:
                break;
        }
        NSString *title = [NSString stringWithFormat:@"%@申请了%@", name, typeName];
        [applyEntry setValue:title forKey:kAPTitle];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm"];
        NSString *detail = [NSString stringWithFormat:@"%@ - %@, %@", [dateFormatter stringFromDate:absenceApply.startDate], [dateFormatter stringFromDate:absenceApply.endDate], absenceApply.detail];
        [applyEntry setValue:detail forKey:kAPDetail];
        
        NSString *status = @"";
        switch ([absenceApply.status intValue]) {
            case 0:
                status = @"申请中";
                break;
            case 1:
                status = @"申请成功";
                break;
            case 2:
                status = @"申请失败";
            default:
                break;
        }
        [applyEntry setValue:status forKey:kAPStatus];
        [tempToDoArr addObject:applyEntry];
    }
    self.toDoArr = [tempToDoArr copy];
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
        {
            return [self.toDoArr count];
            break;
        }
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
    MessageCell *messageCell = nil;
    ToDoCell *toDoCell = nil;
    
    switch ([indexPath section]) {
        case 0:
        {
            toDoCell = (ToDoCell *)[tableView dequeueReusableCellWithIdentifier:kToDoCell];
            NSDictionary *dic = [self.toDoArr objectAtIndex:[indexPath row]];
            toDoCell.titleLabel.text = [dic objectForKey:kAPTitle];
            toDoCell.detaiLabel.text = [dic objectForKey:kAPDetail];
            toDoCell.statusLabel.text = [dic objectForKey:kAPStatus];
            return toDoCell;
            break;
        }
        case 1:
        {
            messageCell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:kMessageCell];
            if (messageCell == nil) {
                messageCell = [[[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:Nil] objectAtIndex:0];
            }
            messageCell.iconImageView.image = [UIImage imageNamed:@"notification"];
            messageCell.titleLable.text = @"周一召开集体会议";
            messageCell.dateLable.text = @"2014-03-03";
            messageCell.contentLable.text = @"各个小组汇报上周工作，以及本周的计划，供讨论";
            return messageCell;
            break;
        }
        case 2:
        {
            messageCell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:kMessageCell];
            if (messageCell == nil) {
                messageCell = [[[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:Nil] objectAtIndex:0];
            }
            messageCell.iconImageView.image = [UIImage imageNamed:@"announcement"];
            messageCell.titleLable.text = @"周一召开集体会议";
            messageCell.dateLable.text = @"2014-03-03";
            messageCell.contentLable.text = @"各个小组汇报上周工作，以及本周的计划，供讨论";
            return messageCell;
            break;
        }
        default:
            return messageCell;
            break;
    }
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

#pragma mark - ASIHttpRequestDelegate
- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@",request.responseString);
    NSArray *responseArr = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:nil];
    for(int i=0;i<[responseArr count];i++)
    {
        AbsenceApply *absenceApply = [NSEntityDescription insertNewObjectForEntityForName:@"AbsenceApply" inManagedObjectContext:_managedObjectContext];
        absenceApply.applyId = [NSNumber numberWithInteger:[responseArr[i][@"id"] integerValue]];
        absenceApply.userId = [NSNumber numberWithInteger:[responseArr[i][@"userId"] integerValue]];
        absenceApply.realName = responseArr[i][@"realName"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        absenceApply.startDate = [dateFormatter dateFromString:responseArr[i][@"startDate"]];
        absenceApply.endDate = [dateFormatter dateFromString:responseArr[i][@"endDate"]];
        absenceApply.detail = (responseArr[i][@"detail"] == (id)[NSNull null])?@"":(responseArr[i][@"detail"]);;
        absenceApply.type = [NSNumber numberWithInteger:[responseArr[i][@"type"] integerValue]];
        absenceApply.status = [NSNumber numberWithInteger:[responseArr[i][@"status"] integerValue]];
        absenceApply.feedback = (responseArr[i][@"feedback"] == (id)[NSNull null])?@"":(responseArr[i][@"feedback"]);
        absenceApply.checked = [NSNumber numberWithInteger:[responseArr[i][@"checked"] integerValue]];
    }
    
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    [super stopLoading];
    [_activityIndicator stopAnimating];
    
    [self fetchToDoList];
    [self.tableView reloadData];
    
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"failed");
    [super stopLoading];
    [_activityIndicator stopAnimating];

}

- (void) refresh
{
    NSLog(@"refresh");
    //获取本地最大的请假出差记录的id -- applyId
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AbsenceApply" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setResultType:NSDictionaryResultType];
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"applyId"];
    NSExpression *largestExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
    NSExpressionDescription *largestExpreDes = [[NSExpressionDescription alloc] init];
    [largestExpreDes setName:@"largestApplyId"];
    [largestExpreDes setExpression:largestExpression];
    [largestExpreDes setExpressionResultType:NSInteger64AttributeType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:
                                        largestExpreDes]];
    NSError *error = nil;
    NSArray *fetchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSNumber *largestApplyId = [[fetchResults lastObject] valueForKey:@"largestApplyId"];
    
    //网络请求
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php?r=absenseApply/clientIndex",ServerUrl];
    __block ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setPostValue:[Globals userId] forKey:@"userId"];
    [request setPostValue:[largestApplyId stringValue] forKey:@"applyId"];
    request.delegate = self;
    
    [request startAsynchronous];
    [_activityIndicator startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
