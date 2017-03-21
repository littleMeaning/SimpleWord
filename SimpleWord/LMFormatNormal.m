//
//  LMParagraphNormal.m
//  SimpleWord
//
//  Created by Chenly on 2017/1/1.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import "LMFormatNormal.h"
#import "UIFont+LMText.h"
#import "LMTextStyle.h"

@interface LMFormatNormal ()

@end

@implementation LMFormatNormal

@synthesize view = _view;

- (instancetype)init {
    
    if (self = [super init]) {
        _textStyle = [[LMTextStyle appearance] copy];
    }
    return self;
}

- (CGFloat)indent {
    return 0;
}

- (CGFloat)paragraphSpacing {
    return 4.f;
}

- (NSDictionary *)textAttributes {
    
    UIFont *font = self.textStyle.font ?: [UIFont lm_systemFont];
    UIColor *textColor = self.textStyle.textColor;
    BOOL underline = self.textStyle.underline;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = font;
    attributes[NSForegroundColorAttributeName] = textColor;
    attributes[NSUnderlineStyleAttributeName] = @(underline);
    attributes[NSParagraphStyleAttributeName] = ({
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.paragraphSpacing = [self paragraphSpacing];
        style;
    });
    return attributes;
}

- (UIView *)view {
    // 为了统一性，也给纯文本一个无用的 view。
    if (!_view) {
        _view = [[UIView alloc] init];
    }
    return _view;
}

@end
