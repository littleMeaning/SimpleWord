//
//  LMParagraph.m
//  SimpleWord
//
//  Created by Chenly on 2016/12/21.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMParagraph.h"
#import "LMParagraphStyle.h"
#import "UIFont+LMText.h"
#import "LMParagraphCheckbox.h"

NSString * const LMParagraphAttributeName = @"LMParagraphAttributeName";

@implementation LMParagraph

- (instancetype)initWithType:(LMParagraphType)type textRange:(NSRange)textRange {
    if (self = [super init]) {
        _textRange = textRange;
        _type = type;
        _paragraphStyle = [[LMParagraphStyle alloc] initWithType:type];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[LMParagraph alloc] initWithType:self.type textRange:self.textRange];
}

- (void)textAttributesToFit {
    NSMutableDictionary *attributes = [[self.paragraphStyle textAttributes] mutableCopy];
    attributes[LMParagraphAttributeName] = self;
    
    NSMutableAttributedString *attributedText = [self.textView.attributedText mutableCopy];
    NSAttributedString *text = [self.textView.attributedText attributedSubstringFromRange:self.textRange];
    NSAttributedString *formattedText = [[NSAttributedString alloc] initWithString:text.string attributes:attributes];
    [attributedText replaceCharactersInRange:self.textRange withAttributedString:formattedText];
    
    self.textView.allowsEditingTextAttributes = YES;
    self.textView.attributedText = attributedText;
    self.textView.allowsEditingTextAttributes = NO;
}

// 将段落文本属性初始化
- (void)removeTextAttributes {
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont lm_systemFont],
                                 };
    NSMutableAttributedString *attributedText = [self.textView.attributedText mutableCopy];
    NSAttributedString *text = [self.textView.attributedText attributedSubstringFromRange:self.textRange];
    NSAttributedString *formattedText = [[NSAttributedString alloc] initWithString:text.string attributes:attributes];
    [attributedText replaceCharactersInRange:self.textRange withAttributedString:formattedText];
    
    self.textView.allowsEditingTextAttributes = YES;
    self.textView.attributedText = attributedText;
    self.textView.allowsEditingTextAttributes = NO;
}

- (void)addToTextViewIfNeed:(UITextView *)textView {
    
    if (!textView) {
        return;
    }
    
    self.textView = textView;
    [self textAttributesToFit];

    NSTextContainer *textContainer = self.textView.textContainer;
    NSLayoutManager *layoutManager = self.textView.layoutManager;
    UIEdgeInsets textContainerInset = self.textView.textContainerInset;
    
    CGRect rect = [layoutManager boundingRectForGlyphRange:self.textRange inTextContainer:textContainer];
    CGSize size = [self.paragraphStyle size];
    rect.size = size;
    
    // 在 TextView 中留出放置 checkbox 的区域
    self.exclusionPath = [UIBezierPath bezierPathWithRect:rect];
    NSMutableArray *exclusionPaths = [textContainer.exclusionPaths mutableCopy];
    [exclusionPaths addObject:self.exclusionPath];
    textContainer.exclusionPaths = exclusionPaths;
    
    rect.origin.x += textContainerInset.left;
    rect.origin.y += textContainerInset.top;
    
    UIView *view = [self.paragraphStyle view];
    view.frame = rect;
    [self.textView addSubview:view];
}

- (void)removeFromTextView {
    
    if (!self.textView) {
        return;
    }
    [self.paragraphStyle.view removeFromSuperview];
    [self removeTextAttributes];
    
    NSMutableArray *exclusionPaths = [self.textView.textContainer.exclusionPaths mutableCopy];
    if ([exclusionPaths containsObject:self.exclusionPath]) {
        [exclusionPaths removeObject:self.exclusionPath];
        self.exclusionPath = nil;
    }
    self.textView.textContainer.exclusionPaths = exclusionPaths;
}

@end

//@implementation UITextView (LMParagraphStyle)
//
//- (LMParagraphStyle *)lm_paragraphStyleForTextRange:(NSRange)textRange {
//    return [self.attributedText attribute:LMParagraphAttributeName atIndex:textRange.location effectiveRange:NULL];
//}
//
//@end
