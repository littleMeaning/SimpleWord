//
//  LMParagraph.h
//  SimpleWord
//
//  Created by Chenly on 2016/12/21.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const LMParagraphAttributeName;

@class LMParagraphStyle;

typedef NS_ENUM(NSUInteger, LMParagraphType) {
    LMParagraphTypeNone = 0,
    LMParagraphTypeUnorderedList,
    LMParagraphTypeOrderedList,
    LMParagraphTypeCheckbox,
};


@interface LMParagraph : NSObject

// 使用链表结构
@property (nonatomic, weak) LMParagraph *previous;
@property (nonatomic, strong) LMParagraph *next;

@property (nonatomic, assign) LMParagraphType type;
@property (nonatomic, strong) LMParagraphStyle *paragraphStyle;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, readonly) NSRange textRange;

@property (nonatomic, weak) UITextView *textView;

@property (nonatomic, readonly) NSDictionary *typingAttributes;
@property (nonatomic, strong) UIBezierPath *exclusionPath;

- (instancetype)initWithType:(LMParagraphType)type textView:(UITextView *)textView;

- (void)formatParagraph;
- (void)updateLayout;
- (void)updateFrameWithYOffset:(CGFloat)yOffset;

@end
