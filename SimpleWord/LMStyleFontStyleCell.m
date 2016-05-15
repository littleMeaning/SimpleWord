//
//  LMStyleFontStyleCell.m
//  SimpleWord
//
//  Created by Chenly on 16/5/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMStyleFontStyleCell.h"

@interface LMStyleFontStyleCell ()

@property (weak, nonatomic) IBOutlet UIButton *boldButton;
@property (weak, nonatomic) IBOutlet UIButton *italicButton;
@property (weak, nonatomic) IBOutlet UIButton *underLineButton;

@end

@implementation LMStyleFontStyleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    for (UIButton *button in @[_boldButton, _italicButton, _underLineButton]) {
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)buttonAction:(UIButton *)button {
    button.selected = !button.selected;
    
    NSDictionary *settings;
    if (button == self.boldButton) settings = @{ LMStyleSettingsBoldName: @(self.bold) };
    if (button == self.italicButton) settings = @{ LMStyleSettingsItalicName: @(self.italic) };
    if (button == self.underLineButton) settings = @{ LMStyleSettingsUnderlineName: @(self.underline) };
    [self.delegate lm_didChangeStyleSettings:settings];
}

- (void)setBold:(BOOL)bold {
    self.boldButton.selected = bold;
}

- (BOOL)bold {
    return self.boldButton.selected;
}

- (void)setItalic:(BOOL)italic {
    self.italicButton.selected = italic;
}

- (BOOL)italic {
    return self.italicButton.selected;
}

- (void)setUnderline:(BOOL)underline {
    self.underLineButton.selected = underline;
}

- (BOOL)underline {
    return self.underLineButton.selected;
}

@end
