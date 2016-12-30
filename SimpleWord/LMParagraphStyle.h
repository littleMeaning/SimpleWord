//
//  LMParagraphStyle.h
//  SimpleWord
//
//  Created by Chenly on 2016/12/19.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMParagraph.h"

@protocol LMParagraphStyle <NSObject>

- (CGFloat)indent;              // 缩进
- (CGFloat)paragraphSpacing;    // 段间距
- (UIView *)view;
- (NSDictionary *)textAttributes;

@end

@interface LMParagraphStyle : NSObject <LMParagraphStyle>

- (instancetype)initWithType:(LMParagraphType)type;

@end
