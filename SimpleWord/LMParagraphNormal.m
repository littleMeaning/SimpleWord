//
//  LMParagraphNormal.m
//  SimpleWord
//
//  Created by Chenly on 2017/1/1.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import "LMParagraphNormal.h"
#import "UIFont+LMText.h"

@interface LMParagraphNormal ()

@end

@implementation LMParagraphNormal

@synthesize view = _view;

- (CGFloat)indent {
    return 0;
}

- (CGFloat)paragraphSpacing {
    return 4.f;
}

- (NSDictionary *)textAttributes {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.paragraphSpacing = [self paragraphSpacing];
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont lm_systemFont],
                                 NSParagraphStyleAttributeName: style,
                                 };
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
