//
//  SecondViewController.h
//  SmartOffice
//
//  Created by Peng Ji on 14-2-26.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignProgressView.h"

@interface AttendanceViewController : UIViewController

@property (weak, nonatomic) IBOutlet SignProgressView *signProgressView_;
@property (retain, nonatomic) NSTimer *timer_;
- (IBAction)beginSign:(id)sender;
@end
