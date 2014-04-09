//
//  LoginViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-3-20.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "LoginViewController.h"
#import "ASIHTTPRequest/ASIFormDataRequest.h"
#import <CommonCrypto/CommonDigest.h>
#include "AppDelegate.h"

@interface LoginViewController () <ASIHTTPRequestDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *errorMsgLabel;
//@property (strong, nonatomic) UIAlertView *alertView;
- (IBAction)loginAction:(id)sender;

@end

@implementation LoginViewController

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
    self.errorMsgLabel.hidden = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) requestFinished:(ASIHTTPRequest *)request
{
    NSLog(@"%@",request.responseString);
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:nil];
    int resultCode = [[responseDic valueForKey:@"resultCode"] intValue];
    if (1 == resultCode || 5 == resultCode) {
        if (1 == resultCode) {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [[NSUserDefaults standardUserDefaults] setValue:appDelegate.deviceTokenStr forKey:kDeviceToken];
        }
        [Globals setUserId:[responseDic valueForKey:@"userId"]];
        [Globals setUsername:[responseDic valueForKey:@"userName"]];
        [Globals setUserInfo:responseDic];
        if ([responseDic valueForKey:@"comeTime"]) {
            NSString *today = [[responseDic valueForKey:@"comeTime"] substringToIndex:10];
            [Globals setSignDate:today];
            NSString *comeSignTime = [[responseDic valueForKey:@"comeTime"] substringFromIndex:11];
            [Globals setComeSignTime:comeSignTime];
            if (![[responseDic valueForKey:@"leaveTime"] isKindOfClass:[NSNull class]])
            {
                NSString *leaveSignTime = [[responseDic valueForKey:@"leaveTime"] substringFromIndex:11];
                [Globals setLeaveSignTime:leaveSignTime];
            }
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        UITabBarController *tabController = (UITabBarController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        tabController.selectedIndex = 1;
    }
    else
    {
        NSString *errorMsg = [responseDic valueForKey:@"message"];
        switch (resultCode)
        {
            case 4:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"检测您可能更换过手机或者清除过数据，是否向管理员发送通知？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
                alertView.tag = 0;
                [alertView show];
                break;
            }
            case 2:
            case 3:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:errorMsg delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                alertView.tag = 1;
                [alertView show];
                break;
            }
            default:
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未知错误" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
                alertView.tag = 1;
                [alertView show];
                break;
            }
        }
    }
}

//界面跳转前的准备工作
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

-(void) requestFailed:(ASIHTTPRequest *)request
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络错误" delegate:self cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
    alertView.tag = 1;
    [alertView show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (0 == alertView.tag)
    {
        if(1 == buttonIndex)
        {
            //send udid change request to admin
            NSLog(@"udid changed");
        }
    }
}

- (IBAction)loginAction:(id)sender {
    if ([self checkLoginForm]) {
        [self.usernameTextField resignFirstResponder];
        [self.passwordTextField resignFirstResponder];
        
        //当前获取的device token
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        NSString *urlString = [NSString stringWithFormat:@"%@/index.php?r=site/clientLogin",ServerUrl ];
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        [request setPostValue:self.usernameTextField.text forKey:@"username"];
        NSString *pw = [self md5:self.passwordTextField.text];
        [request setPostValue:pw forKey:@"password"];
        [request setPostValue:[Globals phoneId] forKey:@"phoneId"];
        [request setPostValue:appDelegate.deviceTokenStr forKey:@"deviceToken"];
        request.delegate = self;
        [request startAsynchronous];
    }
}

- (BOOL) checkLoginForm
{
    if (self.usernameTextField.text.length == 0) {
        self.errorMsgLabel.text = @"请输入用户名";
        self.errorMsgLabel.hidden = NO;
        return 0;
    }
    if (self.passwordTextField.text.length == 0) {
        self.errorMsgLabel.text = @"请输入密码";
        self.errorMsgLabel.hidden = NO;
        return 0;
    }
    if (![Globals phoneId]) {
        self.errorMsgLabel.text = @"未能获取手机ID，请尝试重新启动软件";
        self.errorMsgLabel.hidden = NO;
        return 0;
    }
    self.errorMsgLabel.hidden = YES;
    return 1;
}

//md5 encryption
- (NSString *)md5:(NSString *)inputStr
{
    const char *cStr = [inputStr UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ]; 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
