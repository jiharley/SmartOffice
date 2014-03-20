//
//  LoginViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-3-20.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "LoginViewController.h"
#import "ASIHTTPRequest/ASIFormDataRequest.h"

@interface LoginViewController () <ASIHTTPRequestDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *errorMsgLabel;
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

- (void)viewWillAppear:(BOOL)animated
{
    if ([Globals getUsername]) {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
    self.errorMsgLabel.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    
}

-(void) requestFailed:(ASIHTTPRequest *)request
{
    sleep(2);
    [self performSegueWithIdentifier:@"login" sender:self];
    
}
- (IBAction)loginAction:(id)sender {
    if ([self checkLoginForm]) {
        ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:ServerUrl]];
        [request setPostValue:self.usernameTextField.text forKey:@"username"];
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
    self.errorMsgLabel.hidden = YES;
    return 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
