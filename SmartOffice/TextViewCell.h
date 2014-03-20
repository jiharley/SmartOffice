//
//  TexeViewCell.h
//  SmartOffice
//
//  Created by Peng Ji on 14-3-5.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextViewCell : UITableViewCell <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *detailReasonTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeHolderLabel;
@end
