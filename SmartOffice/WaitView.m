//
//  WaitView.m
//  SmartOffice
//
//  Created by Peng Ji on 14-5-4.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "WaitView.h"

@implementation WaitView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 1.0;
        CGRect rect = CGRectMake(frame.size.width/2 - 60, frame.size.height/2 - 20, 120, 40);
        UILabel *waitLabel = [[UILabel alloc] initWithFrame:rect];
        waitLabel.backgroundColor = [UIColor lightGrayColor];
        waitLabel.text = @"正在载入...";
        [self addSubview:waitLabel];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
