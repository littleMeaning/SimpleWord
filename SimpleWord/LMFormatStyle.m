//
//  LMFormatStyle.m
//  SimpleWord
//
//  Created by Chenly on 2016/12/19.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMFormatStyle.h"

@interface LMFormatStyle ()

@end

@implementation LMFormatStyle

- (instancetype)initWithType:(LMFormatType)type {
    return [LMFormatStyle paragraphStyleWithType:type];
}

+ (instancetype)paragraphStyleWithType:(LMFormatType)type {
    NSArray *classNameOfStyles = @[
                                   @"LMParagraphNormal",
                                   @"LMParagraphBullets",
                                   @"LMParagraphDashedLine",
                                   @"LMParagraphNumber",
                                   @"LMFormatCheckbox"
                                   ];
    LMFormatStyle *instance = [[NSClassFromString(classNameOfStyles[type]) alloc] init];
    return instance;
}

- (CGFloat)indent {
    return 0;
}

- (CGFloat)paragraphSpacing {
    return 0;
}

- (UIView *)view {
    return nil;
}

- (NSDictionary *)textAttributes {
    return nil;
}

- (void)updateDisplayWithParagraph:(LMFormat *)paragraph {
    return;
}

@end
