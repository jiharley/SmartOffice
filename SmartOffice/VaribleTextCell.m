//
//  VaribleTextCell.m
//  SmartOffice
//
//  Created by Peng Ji on 14-4-17.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "VaribleTextCell.h"

@implementation VaribleTextCell
@synthesize textLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) drawRect:(CGRect)rect
{
    
}
@end
