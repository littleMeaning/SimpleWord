//
//  LMParagraphStyle.m
//  SimpleWord
//
//  Created by Chenly on 2016/12/19.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMParagraphStyle.h"

@interface LMParagraphStyle ()

@end

@implementation LMParagraphStyle

- (instancetype)initWithType:(LMParagraphType)type {
    return [LMParagraphStyle paragraphStyleWithType:type];
}

+ (instancetype)paragraphStyleWithType:(LMParagraphType)type {
    NSArray *classNameOfStyles = @[
                                   @"LMParagraphNormal",
                                   @"LMParagraphUnorderedList",
                                   @"LMParagraphOrderedList",
                                   @"LMParagraphCheckbox"
                                   ];
    LMParagraphStyle *instance = [[NSClassFromString(classNameOfStyles[type]) alloc] init];
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
