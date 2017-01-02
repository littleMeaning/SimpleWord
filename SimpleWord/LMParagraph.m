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
#import "LMWordView.h"

NSString * const LMParagraphAttributeName = @"LMParagraphAttributeName";

@implementation LMParagraph

- (instancetype)initWithType:(LMParagraphType)type textView:(UITextView *)textView {
    if (self = [super init]) {
        _type = type;
        _textView = textView;
        _paragraphStyle = [LMParagraphStyle paragraphStyleWithType:type];
    }
    return self;
}

#pragma mark - getter & setter

- (NSRange)textRange {

    if (!self.previous) {
        return NSMakeRange(0, self.length);
    }
    NSInteger location = self.previous.textRange.location + self.previous.textRange.length;
    return NSMakeRange(location, self.length);
}

- (CGFloat)height {
    return CGRectGetHeight(self.paragraphStyle.view.frame) + [self.paragraphStyle paragraphSpacing];
}

#pragma mark - public method

- (NSDictionary *)typingAttributes {
    return [self.paragraphStyle textAttributes];
}

// 添加段落文本属性以适应当前段落样式
- (void)textAttributesToFit {
    NSMutableAttributedString *attributedText = [self.textView.attributedText mutableCopy];
    NSAttributedString *text = [self.textView.attributedText attributedSubstringFromRange:self.textRange];
    NSAttributedString *formattedText = [[NSAttributedString alloc] initWithString:text.string attributes:[self typingAttributes]];
    [attributedText replaceCharactersInRange:self.textRange withAttributedString:formattedText];
    
    self.textView.allowsEditingTextAttributes = YES;
    self.textView.attributedText = attributedText;
    self.textView.allowsEditingTextAttributes = NO;
}

- (void)formatParagraph {
    // 格式化段落样式
    if (!self.textView) {
        return;
    }
    [self textAttributesToFit];
    UIView *view = [self.paragraphStyle view];
    [self.textView addSubview:view];
    [self updateLayout];
    if (self.type == LMParagraphTypeOrderedList) {
        [self updateDisplay];
    }
}

- (void)restoreParagraph {
    // 移除段落样式
    [self.paragraphStyle.view removeFromSuperview];
    NSMutableArray *exclusionPaths = [self.textView.textContainer.exclusionPaths mutableCopy];
    if ([exclusionPaths containsObject:self.exclusionPath]) {
        [exclusionPaths removeObject:self.exclusionPath];
        self.exclusionPath = nil;
    }
    self.textView.textContainer.exclusionPaths = exclusionPaths;
}

static CGFloat const kUITextViewDefaultEdgeSpacing = 5.f; // UITextView 默认间距（文字与边界及exclusionPath之间）

- (void)updateLayout {
    
    NSTextContainer *textContainer = self.textView.textContainer;
    NSLayoutManager *layoutManager = self.textView.layoutManager;
    UIEdgeInsets textContainerInset = self.textView.textContainerInset;
    
    CGFloat boundingWidth = (textContainer.size.width - 3 * kUITextViewDefaultEdgeSpacing - self.paragraphStyle.indent);
    NSAttributedString *attributedText = [self.textView.attributedText attributedSubstringFromRange:self.textRange];
    if (attributedText.length == 0 || [attributedText.string isEqualToString:@"\n"]) {
        attributedText = [[NSAttributedString alloc] initWithString:@"A" attributes:self.typingAttributes];
    }
    else if ([attributedText.string hasSuffix:@"\n"]) {
        // 计算时去掉最后一个换行符的高度
        NSRange subRange = NSMakeRange(0, attributedText.length - 1);
        attributedText = [attributedText attributedSubstringFromRange:subRange];
    }
    CGRect boundingRect = [attributedText boundingRectWithSize:CGSizeMake(boundingWidth, MAXFLOAT)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
    CGFloat y = [layoutManager boundingRectForGlyphRange:self.textRange inTextContainer:textContainer].origin.y;
    
    CGRect rect = CGRectZero;
    if ([self.paragraphStyle indent] == 0) {
        // Normal 样式无需缩进
        rect.origin.x = textContainerInset.left;
    }
    else {
        rect.origin.x = textContainerInset.left + kUITextViewDefaultEdgeSpacing;
    }
    rect.origin.y = textContainerInset.top + y;
    rect.size.width = [self.paragraphStyle indent];
    rect.size.height = boundingRect.size.height;
    [self updateFrameWithViewRect:rect];
}

- (void)updateFrameWithYOffset:(CGFloat)yOffset {
    
    UIView *view = [self.paragraphStyle view];
    CGRect rect = view.frame;
    rect.origin.y += yOffset;
    [self updateFrameWithViewRect:rect];
}

- (void)updateDisplay {
    [self.paragraphStyle updateDisplayWithParagraph:self];
}

#pragma mark - private method

- (void)updateFrameWithViewRect:(CGRect)rect {
    
    NSTextContainer *textContainer = self.textView.textContainer;
    UIEdgeInsets textContainerInset = self.textView.textContainerInset;
    
    UIView *view = [self.paragraphStyle view];
    view.frame = rect;
    
    rect.origin.x -= textContainerInset.left;
    rect.origin.y -= textContainerInset.top;
    
    UIBezierPath *exclusionPath = [UIBezierPath bezierPathWithRect:rect];
    NSMutableArray *exclusionPaths = [textContainer.exclusionPaths mutableCopy];
    
    if (self.exclusionPath) {
        NSInteger index = [textContainer.exclusionPaths indexOfObject:self.exclusionPath];
        [exclusionPaths replaceObjectAtIndex:index withObject:exclusionPath];
    }
    else {
        [exclusionPaths addObject:exclusionPath];
    }
    textContainer.exclusionPaths = exclusionPaths;
    self.exclusionPath = exclusionPath;
}

@end
