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
#import "ToDoDetailViewController.h"
#import "MessageDetailViewController.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "AbsenceApply.h"
#import "Announcement.h"
#import "Inform.h"

#define kAPTitle @"AbsenceApplyTitle"
#define kAPDetail @"AbsenceApplyDetail"
#define kAPStatus @"AbsenceApplyStatus"
#define kAPId @"AbsenceApplyId"
#define kIsChecked @"isChecked"

static NSString *kMessageCell = @"MessageCell";
static NSString *kToDoCell = @"ToDoCell";
static bool isRefreshing = NO;

@interface MessageViewController ()

@property (strong, nonatomic) NSArray *toDoArr;
@property (strong, nonatomic) NSArray *informArr;
@property (strong, nonatomic) NSArray *announceArr;
@property (strong, nonatomic) NSMutableArray *processedInfoArr;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) ASINetworkQueue *networkQueue;
//@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

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
    [self.navigationController.tabBarItem setBadgeValue:nil];
    [self fetchTableData];
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _managedObjectContext = [self managedObjectContext];
    _networkQueue = [[ASINetworkQueue alloc] init];
    
    _toDoArr = [[NSArray alloc] init];
    _announceArr = [[NSArray alloc] init];
    _informArr = [[NSArray alloc] init];
    [self fetchTableData];
//    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//    _activityIndicator.color = [UIColor lightGrayColor];
//    UIBarButtonItem * barButton =
//    [[UIBarButtonItem alloc] initWithCustomView:_activityIndicator];
//    barButton.style = UIBarButtonItemStylePlain;
//    [[self navigationItem] setRightBarButtonItem:barButton animated:YES];
    
    [self refresh];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"newMessage" object:nil];
}

- (void) fetchTableData
{
    /********** fetch todo list records **********/
    NSFetchRequest *absenceApplyfetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *absenceApplyEntity = [NSEntityDescription entityForName:kAbsenceApplyEntityName inManagedObjectContext:_managedObjectContext];
    [absenceApplyfetch setEntity:absenceApplyEntity];
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *todayStr = [NSString stringWithFormat:@"%@ 00:00:00", [dateFormatter stringFromDate:now]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *today = [dateFormatter dateFromString:todayStr];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(endDate >= %@)", today];
    [absenceApplyfetch setPredicate:predicate];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:YES];
    [absenceApplyfetch setSortDescriptors:@[sortDescriptor]];
    NSError *error;
    NSArray *resultArr = [_managedObjectContext executeFetchRequest:absenceApplyfetch error:&error];
    if (resultArr == nil)
    {
        // Deal with error...
    }
    self.toDoArr = [resultArr copy];
    
    /********** fetch inform records **********/
    NSFetchRequest *informFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *informEntity = [NSEntityDescription entityForName:kInformEntityName inManagedObjectContext:_managedObjectContext];
    [informFetch setEntity:informEntity];
    NSPredicate *informPredicate = [NSPredicate predicateWithFormat:@"validDate >= %@", today];
    [informFetch setPredicate:informPredicate];
    NSSortDescriptor *informSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"insertMoment" ascending:NO];
    [informFetch setSortDescriptors:@[informSortDescriptor]];
    NSError *informError = nil;
    NSArray *informRecordArr = [_managedObjectContext executeFetchRequest:informFetch error:&informError];
    if (informRecordArr == nil) {
        NSLog(@"fetch announce records error: %@", error.description);
    }
    self.informArr = [informRecordArr copy];
    
    /********** fetch announcement records **********/
    NSFetchRequest *announcementFetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *announcementEntity = [NSEntityDescription entityForName:kAnnouncementEntityName inManagedObjectContext:_managedObjectContext];
    [announcementFetch setEntity:announcementEntity];
    NSPredicate *announcePredicate = [NSPredicate predicateWithFormat:@"validDate >= %@", today];
    [announcementFetch setPredicate:announcePredicate];
    NSSortDescriptor *announceSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"insertMoment" ascending:NO];
    [announcementFetch setSortDescriptors:@[announceSortDescriptor]];
    NSError *announceError = nil;
    NSArray *announceRecordArr = [_managedObjectContext executeFetchRequest:announcementFetch error:&announceError];
    if (announceRecordArr == nil) {
        NSLog(@"fetch announce records error: %@", error.description);
    }
    self.announceArr = [announceRecordArr copy];
}

#pragma mark - ASIHttpRequestDelegate
- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@",request.responseString);
    NSArray *responseArr = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:nil];
    if (request.tag == 1) //处理待办事项的响应数据
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"applyId==$Apply_Id"];
        
        for(int i=0;i<[responseArr count];i++)
        {
            NSDictionary *variables = @{@"Apply_Id": [NSNumber numberWithInteger:[responseArr[i][@"id"] integerValue]]};
            NSPredicate *localPredicate = [predicate predicateWithSubstitutionVariables:variables];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription entityForName:kAbsenceApplyEntityName inManagedObjectContext:_managedObjectContext];
            [fetchRequest setEntity:entity];
            [fetchRequest setPredicate:localPredicate];
            NSArray *resultsArr = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
            if ([resultsArr count]) {
                AbsenceApply *absenceApply = [resultsArr objectAtIndex:0];
                absenceApply.status =[NSNumber numberWithInteger:[responseArr[i][@"status"] integerValue]];
                absenceApply.feedback = (responseArr[i][@"feedback"] == (id)[NSNull null])?@"":(responseArr[i][@"feedback"]);
            }
            else
            {
                AbsenceApply *absenceApply = [NSEntityDescription insertNewObjectForEntityForName:@"AbsenceApply" inManagedObjectContext:_managedObjectContext];
                absenceApply.applyId = [NSNumber numberWithInteger:[responseArr[i][@"id"] integerValue]];
                absenceApply.userId = [NSNumber numberWithInteger:[responseArr[i][@"userId"] integerValue]];
                absenceApply.realName = responseArr[i][@"realName"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                absenceApply.startDate = [dateFormatter dateFromString:responseArr[i][@"startDate"]];
                absenceApply.endDate = [dateFormatter dateFromString:responseArr[i][@"endDate"]];
                absenceApply.detail = (responseArr[i][@"detail"] == (id)[NSNull null])?@"":(responseArr[i][@"detail"]);;
                absenceApply.type = [NSNumber numberWithInteger:[responseArr[i][@"type"] integerValue]];
                absenceApply.status = [NSNumber numberWithInteger:[responseArr[i][@"status"] integerValue]];
                absenceApply.feedback = (responseArr[i][@"feedback"] == (id)[NSNull null])?@"":(responseArr[i][@"feedback"]);
                absenceApply.checked = [NSNumber numberWithInteger:[responseArr[i][@"checked"] integerValue]];
            }
        }
    }
    if (request.tag == 2) //处理通知的响应数据
    {
        for (NSDictionary *record in responseArr)
        {
            Inform *inform = [NSEntityDescription insertNewObjectForEntityForName:kInformEntityName inManagedObjectContext:_managedObjectContext];
            inform.informId = [NSNumber numberWithInteger:[record[@"id"] integerValue]];
            inform.title = record[@"title"];
            inform.content = record[@"content"];
            inform.announcerName = record[@"realName"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            inform.insertMoment = [dateFormatter dateFromString:record[@"insertMoment"]];
            inform.validDate = [dateFormatter dateFromString:record[@"validDate"]];
            inform.isImportant = [NSNumber numberWithBool:[record[@"isImportant"] boolValue]];
        }
    }
    if (request.tag == 3) //处理公告的响应数据
    {
        for (NSDictionary *record in responseArr)
        {
            Announcement *announcement = [NSEntityDescription insertNewObjectForEntityForName:kAnnouncementEntityName inManagedObjectContext:_managedObjectContext];
            announcement.announceId = [NSNumber numberWithInteger:[record[@"id"] integerValue]];
            announcement.title = record[@"title"];
            announcement.content = record[@"content"];
            announcement.announcerName = record[@"realName"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            announcement.insertMoment = [dateFormatter dateFromString:record[@"insertMoment"]];
            announcement.validDate = [dateFormatter dateFromString:record[@"validDate"]];
        }
    }
    NSError *error = nil;
    if (![_managedObjectContext save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"failed");
//    [super stopLoading];
//    isRefreshing = NO;
    
}

- (void) queueFinished:(ASINetworkQueue *) queue
{
    [super stopLoading];
    
    [self fetchTableData];
    [self.tableView reloadData];
    
    isRefreshing = NO;
}

//重写父类refresh方法
- (void) refresh
{
    if (isRefreshing)
    {
        [super stopLoading];
        return;
    }
    else
    {
        isRefreshing = YES;
        if (_networkQueue == nil) {
            _networkQueue = [[ASINetworkQueue alloc] init];
        }
        [_networkQueue cancelAllOperations];
        [self setNetworkQueue:_networkQueue];
        [_networkQueue setDelegate:self];
        [_networkQueue setRequestDidFinishSelector:@selector(requestFinished:)];
        [_networkQueue setRequestDidFailSelector:@selector(requestFailed:)];
        [_networkQueue setQueueDidFinishSelector:@selector(queueFinished:)];
        
        /************  request for todo messages  ******************/
        //获取本地最大的请假出差记录的id -- applyId
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:kAbsenceApplyEntityName inManagedObjectContext:_managedObjectContext];
        [fetchRequest setEntity:entity];
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *todayStr = [NSString stringWithFormat:@"%@ 00:00:00", [dateFormatter stringFromDate:now]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *today = [dateFormatter dateFromString:todayStr];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(endDate >= %@)", today];
        [fetchRequest setPredicate:predicate];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"applyId" ascending:YES];
        [fetchRequest setSortDescriptors:@[sortDescriptor]];
        fetchRequest.fetchLimit = 1;
        
        NSError *error = nil;
        NSArray *fetchResults = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
        NSNumber *afterApplyId = [NSNumber numberWithInt:0];
        if ([fetchResults count]) {
            AbsenceApply *absenceApply = [fetchResults objectAtIndex:0];
            afterApplyId = absenceApply.applyId;
        }
        NSString *urlString = [NSString stringWithFormat:@"%@/index.php?r=absenseApply/clientIndex",ServerUrl];
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [request setPostValue:[Globals userId] forKey:@"userId"];
        [request setPostValue:[afterApplyId stringValue] forKey:@"afterApplyId"];
        [request setPostValue:todayStr forKey:@"afterDate"];
        request.tag = 1;
        [_networkQueue addOperation:request];
        
        /************  request for notification records  ******************/
        NSFetchRequest *informFetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *informEntity = [NSEntityDescription entityForName:kInformEntityName inManagedObjectContext:_managedObjectContext];
        [informFetchRequest setEntity:informEntity];
        [informFetchRequest setResultType:NSDictionaryResultType];
        NSExpression *keyPathExpression_info = [NSExpression expressionForKeyPath:@"informId"];
        NSExpression *largestExpression_info = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression_info]];
        NSExpressionDescription *largestExpreDes_info = [[NSExpressionDescription alloc] init];
        [largestExpreDes_info setName:@"largestInformId"];
        [largestExpreDes_info setExpression:largestExpression_info];
        [largestExpreDes_info setExpressionResultType:NSInteger64AttributeType];
        [informFetchRequest setPropertiesToFetch:[NSArray arrayWithObject:largestExpreDes_info]];
        NSArray *informResults = [_managedObjectContext executeFetchRequest:informFetchRequest error:nil];
        NSNumber *largestInformId = [[informResults lastObject] valueForKey:@"largestInformId"];
        NSLog(@"%@",largestInformId);
        
        NSString *urlString2 = [NSString stringWithFormat:@"%@/index.php?r=inform/clientIndex",ServerUrl];
        ASIFormDataRequest *informRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString2]];
        [informRequest setPostValue:[largestInformId stringValue] forKey:@"afterId"];
        [informRequest setPostValue:[Globals userId] forKey:@"userId"];
        informRequest.tag = 2;
        [_networkQueue addOperation:informRequest];
        
        /************  request for announcement records  ******************/
        NSFetchRequest *announceFetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *announceEntity = [NSEntityDescription entityForName:kAnnouncementEntityName inManagedObjectContext:_managedObjectContext];
        [announceFetchRequest setEntity:announceEntity];
        [announceFetchRequest setResultType:NSDictionaryResultType];
        NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"announceId"];
        NSExpression *largestExpression = [NSExpression expressionForFunction:@"max:" arguments:[NSArray arrayWithObject:keyPathExpression]];
        NSExpressionDescription *largestExpreDes = [[NSExpressionDescription alloc] init];
        [largestExpreDes setName:@"largestAnnounceId"];
        [largestExpreDes setExpression:largestExpression];
        [largestExpreDes setExpressionResultType:NSInteger64AttributeType];
        [announceFetchRequest setPropertiesToFetch:[NSArray arrayWithObject:largestExpreDes]];
        NSArray *announceFetchResults = [_managedObjectContext executeFetchRequest:announceFetchRequest error:nil];
        NSNumber *largestAnnounceId = [[announceFetchResults lastObject] valueForKey:@"largestAnnounceId"];
        NSLog(@"%@",largestAnnounceId);
        
        NSString *urlString3 = [NSString stringWithFormat:@"%@/index.php?r=announcement/clientIndex",ServerUrl];
        ASIFormDataRequest *announceRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString3]];
        [announceRequest setPostValue:[largestAnnounceId stringValue] forKey:@"afterId"];
        announceRequest.tag = 3;
        [_networkQueue addOperation:announceRequest];
        
        [_networkQueue setShouldCancelAllRequestsOnFailure:NO];
        [_networkQueue go];
    }
}

#pragma tableview datasource
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
            return [self.informArr count];
            break;
        case 2:
            return [self.announceArr count];
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

// Customize the appearance of table view cells of todocell.
- (void)configureToDoCell:(ToDoCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    AbsenceApply *absenceApply = [self.toDoArr objectAtIndex:[indexPath row]];
    //config titleLabel of todocell
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
    cell.titleLabel.text = [NSString stringWithFormat:@"%@申请了%@", name, typeName];
    //config detailLabel of todocell
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm TT"];
    cell.detaiLabel.text = [NSString stringWithFormat:@"%@ - %@", [dateFormatter stringFromDate:absenceApply.startDate], [dateFormatter stringFromDate:absenceApply.endDate]];
    
    //config statusLabel of todocell
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
            break;
        case 3:
            status = @"等待高层审批";
            break;
        default:
            break;
    }
    cell.statusLabel.text = status;
    
    bool isChecked = [absenceApply.checked boolValue];
    if (!isChecked)
        cell.backgroundColor = [UIColor yellowColor];
    else
        cell.backgroundColor = [UIColor whiteColor];
}

- (void)configureAnnounceCell:(MessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Announcement *announcement = [self.announceArr objectAtIndex:[indexPath row]];
    
    cell.iconImageView.image = [UIImage imageNamed:@"announcement"];
    cell.titleLable.text = announcement.title;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    cell.dateLable.text = [dateFormatter stringFromDate:announcement.insertMoment];
    cell.contentLable.text = announcement.content;
    cell.starImage.hidden = YES;
}

- (void)configureInformCell:(MessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Inform *inform = [self.informArr objectAtIndex:[indexPath row]];
    
    cell.iconImageView.image = [UIImage imageNamed:@"notification"];
    cell.titleLable.text = inform.title;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    cell.dateLable.text = [dateFormatter stringFromDate:inform.insertMoment];
    cell.contentLable.text = inform.content;
    BOOL isImportant = [inform.isImportant boolValue];
    if (isImportant) {
        cell.starImage.hidden = NO;
    }
    else {
        cell.starImage.hidden = YES;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *messageCell = nil;
    ToDoCell *toDoCell = nil;
    
    switch ([indexPath section]) {
        case 0:
        {
            toDoCell = (ToDoCell *)[tableView dequeueReusableCellWithIdentifier:kToDoCell];
            [self configureToDoCell:toDoCell atIndexPath:indexPath];
            return toDoCell;
            break;
        }
        case 1:
        {
            messageCell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:kMessageCell];
            if (messageCell == nil) {
                messageCell = [[[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:Nil] objectAtIndex:0];
            }
            [self configureInformCell:messageCell atIndexPath:indexPath];
            return messageCell;
            break;
        }
        case 2:
        {
            messageCell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:kMessageCell];
            if (messageCell == nil) {
                messageCell = [[[NSBundle mainBundle] loadNibNamed:@"MessageCell" owner:self options:Nil] objectAtIndex:0];
            }
            [self configureAnnounceCell:messageCell atIndexPath:indexPath];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0:
        {
            AbsenceApply *selectedRecord = [self.toDoArr objectAtIndex:[indexPath row]];
            NSError *error = nil;
            selectedRecord.checked = [NSNumber numberWithBool:YES];
            if (![_managedObjectContext save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            [self performSegueWithIdentifier:@"toDoDetail" sender:self];
            break;
        }
        case 1:
        {
            Inform *inform = [self.informArr objectAtIndex:[indexPath row]];
            NSError *error = nil;
            inform.checked = [NSNumber numberWithBool:YES];
            if (![_managedObjectContext save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            [self performSegueWithIdentifier:@"messageDetail" sender:self];
            break;
        }
        case 2:
        {
            Announcement *announcement = [self.announceArr objectAtIndex:[indexPath row]];
            NSError *error = nil;
            announcement.checked = [NSNumber numberWithBool:YES];
            if (![_managedObjectContext save:&error]) {
                NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
            }
            [self performSegueWithIdentifier:@"messageDetail" sender:self];
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toDoDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        AbsenceApply *selectedAbsenceApply = [self.toDoArr objectAtIndex:[indexPath row]];
        ToDoDetailViewController *detailViewController = (ToDoDetailViewController *)[segue destinationViewController];
        detailViewController.absenceApply = selectedAbsenceApply;
        detailViewController.hidesBottomBarWhenPushed = YES;
    }
    if ([segue.identifier isEqualToString:@"messageDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if ([indexPath section] == 1)
        {
            Inform *selectedInform = [self.informArr objectAtIndex:[indexPath row]];
            MessageDetailViewController *msgDetailVC = (MessageDetailViewController *)[segue destinationViewController];
            msgDetailVC.inform = selectedInform;
            msgDetailVC.messageType = 1;
            msgDetailVC.hidesBottomBarWhenPushed = YES;
        }
        if ([indexPath section] == 2)
        {
            Announcement *selectedAnnouncement = [self.announceArr objectAtIndex:[indexPath row]];
            MessageDetailViewController *msgDetailVC = (MessageDetailViewController *)[segue destinationViewController];
            msgDetailVC.announcement = selectedAnnouncement;
            msgDetailVC.messageType = 2;
            msgDetailVC.hidesBottomBarWhenPushed = YES;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
