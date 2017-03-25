//
//  LMTextStyle.m
//  SimpleWord
//
//  Created by Chenly on 16/5/14.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMTextStyle.h"
#import "UIFont+LMText.h"

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
            textStyle.fontSize = 17.f;
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
    return [UIFont fontWithFontSize:self.fontSize bold:self.bold italic:self.italic];
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone {
    
    LMTextStyle *copy = [[LMTextStyle alloc] init];
    copy.bold      = self.bold;
    copy.italic    = self.italic;
    copy.underline = self.underline;
    copy.fontSize  = self.fontSize;
    copy.textColor = self.textColor;
    return copy;
}

#pragma mark - appearance

+ (instancetype)appearance {
    
    static dispatch_once_t onceToken;
    static LMTextStyle *appearance;
    dispatch_once(&onceToken, ^{
        appearance = [self textStyleWithFontFormat:LMFontFormatNone];
    });
    return appearance;
}

+ (void)setupAppearanceWithInstance:(LMTextStyle *)textStyle {
    
    LMTextStyle *appearance = [self appearance];
    appearance.bold      = textStyle.bold;
    appearance.italic    = textStyle.italic;
    appearance.underline = textStyle.underline;
    appearance.fontSize  = textStyle.fontSize;
    appearance.textColor = textStyle.textColor;
}

@end
