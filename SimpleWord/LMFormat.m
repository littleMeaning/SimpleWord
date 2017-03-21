//
//  LMFormat.m
//  SimpleWord
//
//  Created by Chenly on 2016/12/21.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMFormat.h"
#import "LMFormatStyle.h"
#import "UIFont+LMText.h"
#import "LMFormatCheckbox.h"
#import "LMWordView.h"
#import "LMTextStyle.h"

@implementation LMFormat

- (instancetype)initWithFormatType:(LMFormatType)type textView:(UITextView *)textView {
    if (self = [super init]) {
        _type = type;
        _textView = textView;
        _style = [LMFormatStyle styleWithType:type];        
    }
    return self;
}

#pragma mark - getter & setter

- (NSRange)textRange {

    if (!self.previous) {
        return NSMakeRange(0, self.length);
    }
    return NSMakeRange(NSMaxRange(self.previous.textRange), self.length);
}

- (CGFloat)height {
    return CGRectGetHeight(self.style.view.frame) + [self.style paragraphSpacing];
}

- (NSDictionary *)typingAttributes {
    return [self.style textAttributes];
}

#pragma mark - public method

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

- (void)format {
    // 格式化段落样式
    if (!self.textView) {
        return;
    }
    [self textAttributesToFit];
    UIView *view = [self.style view];
    [self.textView addSubview:view];
    [self updateLayout];
    if (self.type == LMFormatTypeNormal) {
        [self updateDisplayRecursion];
    }
}

- (void)restore {
    // 移除段落样式
    [self.style.view removeFromSuperview];
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
    
    CGFloat boundingWidth = (textContainer.size.width - 3 * kUITextViewDefaultEdgeSpacing - self.style.indent);
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
    if ([self.style indent] == 0) {
        // Normal 样式无需缩进
        rect.origin.x = textContainerInset.left;
    }
    else {
        rect.origin.x = textContainerInset.left + kUITextViewDefaultEdgeSpacing;
    }
    rect.origin.y = textContainerInset.top + y;
    rect.size.width = [self.style indent];
    rect.size.height = boundingRect.size.height;
    [self updateFrameWithViewRect:rect];
}

- (void)updateFrameWithYOffset:(CGFloat)yOffset {
    
    UIView *view = [self.style view];
    CGRect rect = view.frame;
    rect.origin.y += yOffset;
    [self updateFrameWithViewRect:rect];
}

- (void)updateDisplayRecursion {
    [self.style updateDisplayWithFormat:self];
    if (self.next && self.next.type == self.type) {
        [self.next updateDisplayRecursion];
    }
}

#pragma mark - private method

- (void)updateFrameWithViewRect:(CGRect)rect {
    
    NSTextContainer *textContainer = self.textView.textContainer;
    UIEdgeInsets textContainerInset = self.textView.textContainerInset;
    
    UIView *view = [self.style view];
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
