//
//  TexeViewCell.m
//  SmartOffice
//
//  Created by Peng Ji on 14-3-5.
//  Copyright (c) 2014年 WMLab. All rights reserved.
//

#import "TextViewCell.h"

@implementation TextViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    self.placeHolderLabel.hidden = YES;
}
//- (void)textViewDidChange:(UITextView *)txtView
//{
//    self.placeHolderLabel.hidden = ([txtView.text length] > 0);
//}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.placeHolderLabel.hidden = ([textView.text length] > 0);
}

- (void) textViewDidChange:(UITextView *)textView
{
    [[NSUserDefaults standardUserDefaults] setValue:textView.text forKey:kDetailReason];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
@end
