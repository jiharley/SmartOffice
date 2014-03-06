//
//  SecondViewController.m
//  SmartOffice
//
//  Created by Peng Ji on 14-2-26.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "AttendanceViewController.h"
static int count = 1;
@interface AttendanceViewController ()

@end

@implementation AttendanceViewController
@synthesize timer_ = _timer_;
//@synthesize signProgressView_ = _signProgressView_;
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
@end
