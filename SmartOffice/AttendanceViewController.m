//
//  SecondViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-2-26.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "AttendanceViewController.h"
#import "AbsenceApplyViewController.h"
#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CoreLocation.h>

#define LocatingTimerInterval 0.1f
#define SuccessTimerInterval 0.001f
#define UploadingTimerInterval 0.1f

static int count = 0;
static BOOL isLocated = NO;
static BOOL isSignUploaded = NO;
static NSString *kApplyCell = @"applyCell";
static NSString *noSignTime = @"--:--:--";
@interface AttendanceViewController ()<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, ASIHTTPRequestDelegate>
@property (weak, nonatomic) IBOutlet UITableView *applyTableView;
@property (weak, nonatomic) IBOutlet SignProgressView *signProgressView;
@property (weak, nonatomic) IBOutlet UIButton *signBtn;
@property (retain, nonatomic) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UILabel *signStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *comeSignTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *leaveSignTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *workTimeLabel;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

- (IBAction)beginSign:(id)sender;

- (IBAction)applyAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *vacationApplyBtn;
@property (weak, nonatomic) IBOutlet UIButton *businessApplyBtn;
@end

@implementation AttendanceViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self refreshView];
//    self.locationManager.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void) viewDidAppear:(BOOL)animated
{
    if (![Globals userName]) {
        [self.tabBarController performSegueWithIdentifier:@"login" sender:self];
    }
}

//刷新view显示的时间与文字
//计算工时，如果未签退，计算签到时间与当前时间的工时；如果已签退，则计算签到与签退之间的时间
- (void)refreshView
{
    //检测是否是新的一天
    NSString *signDate = [Globals signDate];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *today = [self.dateFormatter stringFromDate:[NSDate date]];
    if (![signDate isEqualToString:today])
    {
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kComeSignTime];
        [[NSUserDefaults standardUserDefaults] setValue:nil forKey:kLeaveSignTime];
    }
    [Globals setSignDate:today];
    NSString *comeSignTime = [[NSUserDefaults standardUserDefaults] valueForKey:kComeSignTime];
    NSString *leaveSignTime = [[NSUserDefaults standardUserDefaults] valueForKey:kLeaveSignTime];
    self.leaveSignTimeLabel.text = (nil==leaveSignTime) ? noSignTime:leaveSignTime;
    self.comeSignTimeLabel.text = (nil==comeSignTime) ? noSignTime:comeSignTime;
    [self.signBtn setTitle:(nil==comeSignTime) ? @"上班签到":@"下班签退" forState:UIControlStateNormal];

    if (nil == comeSignTime) {
        self.workTimeLabel.text = @"0h0m";
    }
    else
    {
        NSTimeInterval time = 0;
        if (nil == leaveSignTime)
        {
            [self.dateFormatter setDateFormat:@"HH:mm:ss"];
            NSString *currentTimeStr = [self.dateFormatter stringFromDate:[NSDate date]];
            time = [self calTimeIntervalFromTime:comeSignTime toTime:currentTimeStr];
        }
        else
        {
            time = [self calTimeIntervalFromTime:comeSignTime toTime:leaveSignTime];
        }
        self.workTimeLabel.text = [NSString stringWithFormat:@"%d时%d分",(int)time/3600, (int)time%3600/60];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self initRegion];
//    _locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
    _dateFormatter = [[NSDateFormatter alloc] init];
    self.view.backgroundColor = [UIColor colorWithRed:240.0 green:256.0 blue:260.0 alpha:1.0];
}
//计算时间差，时间的格式为"HH:mm:ss"
- (NSTimeInterval) calTimeIntervalFromTime:(NSString *)fromTime toTime:(NSString *)toTime
{
    [self.dateFormatter setDateFormat:@"HH:mm:ss"];
    return [[self.dateFormatter dateFromString:toTime] timeIntervalSinceDate:[self.dateFormatter dateFromString:fromTime]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.locationManager = nil;
}

- (IBAction)beginSign:(id)sender {
    [self initRegion];
//    if(self.locationManager == nil)
//    {
//        _locationManager = [[CLLocationManager alloc] init];
////        self.locationManager.delegate = self;
//    }
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    self.signBtn.enabled = NO;
    [self showStatusMsg:@"正在定位..."];
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
    [self startTimerWithInterval:LocatingTimerInterval];
}

- (IBAction)applyAction:(id)sender {
    UIButton *buttonClicked = (UIButton *)sender;
    [self performSegueWithIdentifier:@"applyAction" sender:buttonClicked];
}

-(void) startTimerWithInterval:(float)interval
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(runProgress) userInfo:nil repeats:YES];
}

-(void) stopTimer
{
    [self.timer invalidate];
}

//签到进度处理
- (void)runProgress
{
    count++;
    self.signProgressView.progress = count*0.02/2;
    if (40 == count) {
        if (!isLocated) {
            [self showStatusMsg:@"定位失败，请确保蓝牙已打开"];
            [self stopTimer];
            [self resetParams];
            [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
//            self.locationManager = nil;
        }
    }
    if (100 == count)
    {
        if (!isSignUploaded)
        {
            [self showStatusMsg:@"网络问题，签到失败"];
        }
        else
        {
            //签到成功后的操作：改变按钮的文字、记录时间到NSUserDefaults、修改工时label
            [self showStatusMsg:nil];
            [self.signBtn setTitle:@"下班签退" forState:UIControlStateNormal] ;
            [self.dateFormatter setDateFormat:@"HH:mm:ss"];
            NSString *signTime = [self.dateFormatter stringFromDate:[NSDate date]];
            NSString *comeSignTime = [[NSUserDefaults standardUserDefaults] valueForKey:kComeSignTime];
            if (nil == comeSignTime)
            {
                [[NSUserDefaults standardUserDefaults] setValue:signTime forKey:kComeSignTime];
                self.comeSignTimeLabel.text = signTime;
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setValue:signTime forKey:kLeaveSignTime];
                self.leaveSignTimeLabel.text = signTime;
                NSTimeInterval time = [self calTimeIntervalFromTime:comeSignTime toTime:signTime];
                self.workTimeLabel.text = [NSString stringWithFormat:@"%d时%d分",(int)time/3600, (int)time%3600/60];
            }
        }

        [self stopTimer];
        [self resetParams];
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    }
}

-(void) resetParams
{
    count = 0;
    isLocated = NO;
    isSignUploaded = NO;
    self.signBtn.enabled = YES;
    self.signProgressView.progress = 0;
}

- (void) showStatusMsg:(NSString *) msg
{
    self.signStatusLabel.text = msg;
}

-(void) beginUploadSignWithLocation:(NSString *)location
{
    NSString *urlString = [NSString stringWithFormat:@"%@/index.php?r=sign/clientCreate",ServerUrl ];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setPostValue:[Globals userId] forKey:@"userId"];
    [request setPostValue:location forKey:@"location"];
    request.delegate = self;
    request.timeOutSeconds = 15;
    [request startAsynchronous];
    [self showStatusMsg:@"正在上传..."];
}

-(void) requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@", request.responseString);
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:nil];
    int resultCode = [[responseDic valueForKey:@"resultCode"] intValue];
    if (1 == resultCode) {
        //签到成功
        isSignUploaded = YES;
        [self showStatusMsg:@"签到成功!"];
        [self stopTimer];
        [self startTimerWithInterval:SuccessTimerInterval];
    } else {
        //签到失败
        [self showStatusMsg:@"网络问题，签到失败"];
    }
}

-(void) requestFailed:(ASIHTTPRequest *)request
{
    [self showStatusMsg:@"网络问题，签到失败"];
}

#pragma mark - beacon
- (void)initRegion
{
    if (self.beaconRegion)
        return;
    NSUUID *proximityUUID = [[NSUUID alloc] initWithUUIDString:@"d26d197e-4a1c-44ae-b504-dd7768870564"];
    //    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID identifier:@"TongjiIdentifier"];
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:proximityUUID major:0001 identifier:@"TongjiIdentifier"];
}

#pragma mark - location delegate

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    if ([beacons count]) {
        isLocated = YES;
        [self showStatusMsg:@"定位成功"];
        [self beginUploadSignWithLocation:@"Tongji-Yongchang"];
        NSLog(@"sign success");
        [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    }
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"failed");
}

#pragma mark - tableview datasource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 2;
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
    AbsenceApplyViewController *destViewController = segue.destinationViewController;
    UIButton *btn = (UIButton *)sender;
    if ([destViewController respondsToSelector:@selector(setApplyType:)]) {
        destViewController.applyType = btn.tag;
    }
    destViewController.hidesBottomBarWhenPushed = YES;
}
@end
