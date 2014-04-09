//
//  ToDoCellTableViewCell.m
//  SmartOffice
//
//  Created by Peng Ji on 14-4-5.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "ToDoCell.h"

@implementation ToDoCell

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

@end
