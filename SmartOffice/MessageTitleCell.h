//
//  MessageTitleCell.h
//  SmartOffice
//
//  Created by Peng Ji on 14-4-17.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageTitleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *msgTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *announcerLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *starImage;
@end
