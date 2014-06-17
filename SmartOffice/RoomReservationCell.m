//
//  RoomReservationCell.m
//  SmartOffice
//
//  Created by Peng Ji on 14-5-9.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "RoomReservationCell.h"

@implementation RoomReservationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //initial code
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

-(void) setReserveStatus:(short)reserveStatus
{
    if (reserveStatus == 1) {
        _reserveStatus = reserveStatus;
        self.reserveStatusImageView.image = [UIImage imageNamed:@"check"];
    }
    else
    {
        _reserveStatus = reserveStatus;
        self.reserveStatusImageView.image = [UIImage imageNamed:@"delete"];
    }
}
@end
