//
//  LMTextStyle.m
//  SimpleWord
//
//  Created by Chenly on 16/5/14.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMTextStyle.h"

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

+ (instancetype)textStyleWithType:(LMTextStyleType)type {
    
    LMTextStyle *textStyle = [[self alloc] init];
    switch (type) {
        case LMTextStyleFormatTitleSmall:
            textStyle.fontSize = 18.f;
            break;
        case LMTextStyleFormatTitleMedium:
            textStyle.fontSize = 24.f;
            break;
        case LMTextStyleFormatTitleLarge:
            textStyle.fontSize = 30.f;
            break;
        default:
            return textStyle;
    }
    textStyle.bold = type == LMTextStyleFormatNormal ? NO : YES;
    return textStyle;
}

#pragma mark - setter & getter

- (LMTextStyleType)type {
    if (self.bold == YES && self.italic == NO && self.underline == NO) {
        if (self.fontSize == 18.f) {
            return LMTextStyleFormatTitleSmall;
        }
        else if (self.fontSize == 24.f) {
            return LMTextStyleFormatTitleMedium;
        }
        else if (self.fontSize == 30.f) {
            return LMTextStyleFormatTitleLarge;
        }
    }
    return LMTextStyleFormatNormal;
}

- (UIFont *)font {
    UIFont *font = self.bold ? [UIFont boldSystemFontOfSize:self.fontSize] : [UIFont systemFontOfSize:self.fontSize];
    if (self.italic) {
        CGAffineTransform matrix = CGAffineTransformMake(1, 0, tanf(15 * (CGFloat)M_PI / 180), 1, 0, 0);
        UIFontDescriptor *descriptor = [UIFontDescriptor fontDescriptorWithName:font.fontName matrix:matrix];
        font = [UIFont fontWithDescriptor:descriptor size:self.fontSize];        
    }
    return font;
}

@end
