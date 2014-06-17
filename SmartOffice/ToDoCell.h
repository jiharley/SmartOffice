//
//  ToDoCellTableViewCell.h
//  SmartOffice
//
//  Created by Peng Ji on 14-4-5.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToDoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *detaiLabel;

@end
