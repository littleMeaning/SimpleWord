//
//  LMParagraphStyle.h
//  SimpleWord
//
//  Created by Chenly on 2016/12/19.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const LMParagraphStyleAttributeName;

typedef NS_ENUM(NSUInteger, LMParagraphStyleType) {
    LMParagraphStyleTypeNone = 0,
    LMParagraphStyleTypeUnorderedList,
    LMParagraphStyleTypeOrderedList,
    LMParagraphStyleTypeCheckbox,
};

@protocol LMParagraphStyle <NSObject>

@property (nonatomic, readonly) LMParagraphStyleType type;
@property (nonatomic, readonly) NSRange textRange;

- (void)addToTextViewIfNeed:(UITextView *)textView;
- (void)removeFromTextView;

@end

@interface LMParagraphStyle : NSObject <LMParagraphStyle>

- (instancetype)initWithType:(LMParagraphStyleType)type textRange:(NSRange)textRange;

@end

@interface UITextView (LMParagraphStyle)

- (LMParagraphStyle *)lm_paragraphStyleForTextRange:(NSRange)textRange;

@end
