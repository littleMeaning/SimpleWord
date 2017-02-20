//
//  LMParagraphFormat.m
//  SimpleWord
//
//  Created by Chenly on 2016/12/19.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMParagraphFormat.h"

@interface LMParagraphFormat ()

@end

@implementation LMParagraphFormat

- (instancetype)initWithType:(LMFormatType)type {
    return [LMParagraphFormat paragraphStyleWithType:type];
}

+ (instancetype)paragraphStyleWithType:(LMFormatType)type {
    NSArray *classNameOfStyles = @[
                                   @"LMParagraphNormal",
                                   @"LMParagraphBullets",
                                   @"LMParagraphDashedLine",
                                   @"LMParagraphNumber",
                                   @"LMParagraphCheckbox"
                                   ];
    LMParagraphFormat *instance = [[NSClassFromString(classNameOfStyles[type]) alloc] init];
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

- (void)updateDisplayWithParagraph:(LMParagraph *)paragraph {
    return;
}

@end
