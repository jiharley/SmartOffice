//
//  RoomReservationCell.h
//  SmartOffice
//
//  Created by Peng Ji on 14-5-9.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoomReservationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *roomNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *meetingTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *meetingAgendaLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *reserveStatusImageView;

@property (assign, nonatomic) short reserveStatus;
@end
