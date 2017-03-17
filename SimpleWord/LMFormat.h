//
//  LMFormat.h
//  SimpleWord
//
//  Created by Chenly on 2016/12/21.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMFormatType.h"

extern NSString * const LMParagraphAttributeName;

@class LMFormatStyle;

@interface LMFormat : NSObject

// 使用链表结构
@property (nonatomic, weak) LMFormat *previous;
@property (nonatomic, strong) LMFormat *next;

@property (nonatomic, readonly) LMFormatType type;
@property (nonatomic, readonly) LMFormatStyle *style;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly) NSRange textRange;
@property (nonatomic, assign) NSInteger length;

@property (nonatomic, weak) UITextView *textView;

@property (nonatomic, readonly) NSDictionary *typingAttributes;
@property (nonatomic, strong) UIBezierPath *exclusionPath;

- (instancetype)initWithFormatType:(LMFormatType)type textView:(UITextView *)textView;

- (void)formatParagraph;
- (void)restoreParagraph;
- (void)updateLayout;
- (void)updateFrameWithYOffset:(CGFloat)yOffset;
- (void)updateDisplayRecursion;

@end
