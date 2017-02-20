//
//  LMStyleFontStyleCell.m
//  SimpleWord
//
//  Created by Chenly on 16/5/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMFontStyleCell.h"

@interface LMFontStyleCell ()

@property (weak, nonatomic) IBOutlet UIButton *boldButton;
@property (weak, nonatomic) IBOutlet UIButton *italicButton;
@property (weak, nonatomic) IBOutlet UIButton *underLineButton;

@end

@implementation LMFontStyleCell

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

- (void)setEnable:(BOOL)enable {
    self.boldButton.enabled = enable;
    self.italicButton.enabled = enable;
    self.underLineButton.enabled = enable;
    _enable = enable;
}

- (void)buttonAction:(UIButton *)button {
    button.selected = !button.selected;
    
    NSDictionary *settings;
    if (button == self.boldButton) settings = @{ LMFontSettingsBoldName: @(self.bold) };
    if (button == self.italicButton) settings = @{ LMFontSettingsItalicName: @(self.italic) };
    if (button == self.underLineButton) settings = @{ LMFontSettingsUnderlineName: @(self.underline) };
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
