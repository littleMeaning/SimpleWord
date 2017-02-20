//
//  LMTextStyle.m
//  SimpleWord
//
//  Created by Chenly on 16/5/14.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMTextStyle.h"
#import "UIFont+LMText.m"

@interface LMTextStyle ()

@end

@implementation LMTextStyle

- (instancetype)init {
    if (self = [super init]) {
        _fontSize = [UIFont systemFontSize];
        _textColor = [UIColor blackColor];
    }
    return self;
}

+ (instancetype)textStyleWithFontFormat:(LMFontFormat)format {
    
    LMTextStyle *textStyle = [[self alloc] init];
    switch (format) {
        case LMFontFormatNone:
        case LMFontFormatBody:
            textStyle.fontSize = 18.f;
            textStyle.bold = NO;
            break;
        case LMFontFormatSubTitle:
            textStyle.fontSize = 24.f;
            textStyle.bold = YES;
            break;
        case LMFontFormatTitle:
            textStyle.fontSize = 30.f;
            textStyle.bold = YES;
            break;
        default:
            return nil;
    }
    return textStyle;
}

- (UIFont *)font {
    return [UIFont lm_fontWithFontSize:self.fontSize bold:self.bold italic:self.italic];
}

@end
