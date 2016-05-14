//
//  LMTextStyle.m
//  SimpleWord
//
//  Created by Chenly on 16/5/14.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMTextStyle.h"

@interface LMTextStyle ()

@property (nonatomic, readwrite, assign) LMTextStyleType type;

@end

@implementation LMTextStyle

- (instancetype)init {
    if (self = [super init]) {
        _fontSize = [UIFont systemFontSize];
        _textColor = [UIColor blackColor];
        _type = LMTextStyleFormatCustom;
    }
    return self;
}

+ (instancetype)textStyleWithType:(LMTextStyleType)type {
    
    LMTextStyle *textStyle = [[self alloc] init];
    switch (type) {
        case LMTextStyleFormatTitleSmall:
            textStyle.fontSize = 16.f;
            break;
        case LMTextStyleFormatTitleMedium:
            textStyle.fontSize = 18.f;
            break;
        case LMTextStyleFormatTitleLarge:
            textStyle.fontSize = 30.f;
            break;
        default:
            return textStyle;
    }
    textStyle.bold = type == LMTextStyleFormatNormal ? NO : YES;
    textStyle.type = type;
    return textStyle;
}

#pragma mark - setter & getter

- (void)setBold:(BOOL)bold {
    _bold = bold;
    _type = LMTextStyleFormatCustom;
}

- (void)setItalic:(BOOL)italic {
    _italic = italic;
    _type = LMTextStyleFormatCustom;
}

- (void)setUnderline:(BOOL)underline {
    _underline = underline;
    _type = LMTextStyleFormatCustom;
}

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    _type = LMTextStyleFormatCustom;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    _type = LMTextStyleFormatCustom;
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
