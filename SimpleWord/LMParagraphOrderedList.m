//
//  LMParagraphOrderedList.m
//  SimpleWord
//
//  Created by Chenly on 2016/12/20.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMParagraphOrderedList.h"
#import "UIFont+LMText.h"

@interface LMParagraphOrderedList ()

@property (nonatomic, assign) UITextView *textView;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIBezierPath *exclusionPath;
@property (nonatomic, assign) NSInteger number;

@end

@implementation LMParagraphOrderedList

- (void)addToTextViewIfNeed:(UITextView *)textView {
    
    if (self.textView) {
        return;
    }
    
    self.textView = textView;
    
    NSTextContainer *textContainer = self.textView.textContainer;
    NSLayoutManager *layoutManager = self.textView.layoutManager;
    UIEdgeInsets textContainerInset = self.textView.textContainerInset;
    
    CGRect rect = [layoutManager boundingRectForGlyphRange:self.textRange inTextContainer:textContainer];
    rect.size = [self viewSize];
    
    // 在 TextView 中留出放置 "1." 的区域
    self.exclusionPath = [UIBezierPath bezierPathWithRect:rect];
    NSMutableArray *exclusionPaths = [textContainer.exclusionPaths mutableCopy];
    [exclusionPaths addObject:self.exclusionPath];
    textContainer.exclusionPaths = exclusionPaths;
    
    rect.origin.x += textContainerInset.left;
    rect.origin.y += textContainerInset.top;
    
    UIView *view = [self viewForParagraphStyle];
    view.frame = rect;
    [self.textView addSubview:view];
    
    [self textAttributesToFit];
}

- (void)removeFromTextView {
    
    if (!self.textView) {
        return;
    }
    [self.view removeFromSuperview];
    [self removeTextAttributes];
    
    NSMutableArray *exclusionPaths = [self.textView.textContainer.exclusionPaths mutableCopy];
    if ([exclusionPaths containsObject:self.exclusionPath]) {
        [exclusionPaths removeObject:self.exclusionPath];
        self.exclusionPath = nil;
    }
    self.textView.textContainer.exclusionPaths = exclusionPaths;
}

- (CGSize)viewSize {
    CGFloat lineHeight = [UIFont lm_systemFont].lineHeight;
    return CGSizeMake(lineHeight, lineHeight);
}

// 给段落文本添加对应风格属性
- (void)textAttributesToFit {
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont lm_systemFont],
                                 LMParagraphStyleAttributeName: self,
                                 };
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

- (UIView *)viewForParagraphStyle {
    if (!_view) {
        _view = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = @"1.";
            label.font = [UIFont lm_systemFont];
            label.textAlignment = NSTextAlignmentCenter;
            label;
        });
    }
    return _view;
}

@end
