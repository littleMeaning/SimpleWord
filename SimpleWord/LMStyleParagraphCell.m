//
//  LMStyleParagraphCell.m
//  SimpleWord
//
//  Created by Chenly on 16/5/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMStyleParagraphCell.h"

@interface LMStyleParagraphCell ()

@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UIButton *numberListButton;
@property (weak, nonatomic) IBOutlet UIButton *checkboxButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@end

@implementation LMStyleParagraphCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    for (UIButton *button in @[_listButton, _numberListButton, _checkboxButton, _leftButton, _rightButton]) {
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
