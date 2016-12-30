//
//  LMWordView.m
//  SimpleWord
//
//  Created by Chenly on 16/5/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMWordView.h"
#import <objc/runtime.h>
#import "UIFont+LMText.h"
#import "LMParagraph.h"

@interface LMWordView ()

@end

@implementation LMWordView {
    UIView *_titleView;
    UIView *_separatorLine;
    
    CGRect _frameCache;
}

static CGFloat const kLMWMargin = 20.f;
static CGFloat const kLMWTitleHeight = 44.f;
static CGFloat const kLMWCommonSpacing = 16.f;

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _titleTextField = [[UITextField alloc] init];
    _titleTextField.font = [UIFont boldSystemFontOfSize:16.f];
    _titleTextField.placeholder = @"标题";
    
    _separatorLine = [[UIView alloc] init];
    _separatorLine.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    
    _titleView = [[UIView alloc] init];
    _titleView.backgroundColor = [UIColor whiteColor];
    
    [_titleView addSubview:_titleTextField];
    [_titleView addSubview:_separatorLine];
    [self addSubview:_titleView];
    
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.spellCheckingType = UITextSpellCheckingTypeNo;    
    self.alwaysBounceVertical = YES;
    self.textContainerInset = UIEdgeInsetsMake(kLMWMargin + kLMWTitleHeight + kLMWCommonSpacing,
                                               kLMWCommonSpacing,
                                               kLMWCommonSpacing,
                                               kLMWCommonSpacing);
    
    self.beginningParagraph = [[LMParagraph alloc] initWithType:LMParagraphTypeNone textView:self];
    self.typingAttributes = self.beginningParagraph.typingAttributes;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGRectEqualToRect(_frameCache, self.frame)) {
        CGRect rect = CGRectInset(self.bounds, kLMWMargin, kLMWMargin);
        rect.origin.y = kLMWMargin;
        rect.size.height = kLMWTitleHeight;
        _titleView.frame = rect;
        
        rect.origin = CGPointZero;
        rect.size.height = 30.f;
        _titleTextField.frame = rect;
        
        rect.origin.y = CGRectGetHeight(_titleView.bounds) - 1;
        rect.size.height = 1.f;
        _separatorLine.frame = rect;
        
        _frameCache = self.frame;
    }
}

// 处理光标大小
- (CGRect)caretRectForPosition:(UITextPosition *)position {
    CGRect rect = [super caretRectForPosition:position];
    NSParagraphStyle *paragraphStyle = self.typingAttributes[NSParagraphStyleAttributeName];
    if (paragraphStyle) {
        UIFont *font = self.typingAttributes[NSFontAttributeName] ?: [UIFont lm_systemFont];
        CGFloat height = CGRectGetHeight(rect) - paragraphStyle.lineSpacing * 2;
        if (height > font.lineHeight) {
            rect.origin.y += paragraphStyle.lineSpacing;
            rect.size.height -= paragraphStyle.lineSpacing * 2;
        }
    }
    return rect;
}

#pragma mark - LMParagraph

- (void)insertNewlineWithSelectedRange:(NSRange)selectedRange {
    
    self.scrollEnabled = NO; // 设置 scrollEnabled=NO 可以解决 exclusionPath 位置不准确的 bug
    
    LMParagraph *begin = [self paragraphAtLocation:selectedRange.location];
    LMParagraph *end = [self paragraphAtLocation:NSMaxRange(selectedRange)];
    
    LMParagraph *newParagraph = [[LMParagraph alloc] initWithType:begin.type textView:self];
    newParagraph.previous = begin;
    
    LMParagraph *nextParagraph = end.next;
    if (nextParagraph) {
        newParagraph.next = nextParagraph;
        nextParagraph.previous = newParagraph;
    }
    newParagraph.length = NSMaxRange(end.textRange) - NSMaxRange(selectedRange);
    begin.length = selectedRange.location - begin.textRange.location;
    begin.next = newParagraph;
    
    // 截断的地方加上"\n"
    NSMutableAttributedString *attributedText = [self.attributedText mutableCopy];
    NSAttributedString *lineBreak = [[NSAttributedString alloc] initWithString:@"\n" attributes:begin.typingAttributes];
    [attributedText replaceCharactersInRange:selectedRange withAttributedString:lineBreak];
    self.allowsEditingTextAttributes = YES;
    self.attributedText = attributedText;
    self.allowsEditingTextAttributes = NO;
    begin.length += 1;
    
    // 格式化新加入的段落
    [newParagraph formatParagraph];
    
    // 新插入行后之后的段落都需要调整位置
    CGFloat yOffset = newParagraph.height;
    LMParagraph *item = newParagraph;
    while ((item = item.next)) {
        [item updateFrameWithYOffset:yOffset];
    }
    self.selectedRange = NSMakeRange(newParagraph.textRange.location, 0);   // 设置光标位置
    self.scrollEnabled = YES;
    
    // TODO: 光标位置变换后，如果在行末点击换行就会出问题。
    // TODO: 无格式的处理
}

- (void)setParagraphType:(LMParagraphType)type forRange:(NSRange)range {
    
    LMParagraph *paragraph = [self paragraphAtLocation:range.location];
    LMParagraph *newParagraph = [[LMParagraph alloc] initWithType:type textView:self];
    if (paragraph == self.beginningParagraph) {
        self.beginningParagraph = newParagraph;
    }
    else {
        paragraph.previous.next = newParagraph;
    }
    newParagraph.length = paragraph.length;
    newParagraph.next = paragraph.next;
    paragraph.next.previous = newParagraph;
    [newParagraph formatParagraph];
    self.typingAttributes = newParagraph.typingAttributes;
}

- (void)setTypingAttributesForSelection {
    
    LMParagraph *paragraph = [self paragraphAtLocation:self.selectedRange.location];
    self.typingAttributes = paragraph.typingAttributes;
}

- (void)willChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    LMParagraph *begin = [self paragraphAtLocation:range.location];
//    LMParagraph *end = [self paragraphAtLocation:NSMaxRange(range)];
    
    begin.length += (text.length - range.length);
//    
//    LMParagraph *paragraph = [self paragraphAtLocation:range.location];
    
}

- (LMParagraph *)paragraphAtLocation:(NSUInteger)loc {
    // 通过 Location 查找 Paragraph
    LMParagraph *paragraph = self.beginningParagraph;
    while (paragraph && !(loc == paragraph.textRange.location || NSLocationInRange(loc, paragraph.textRange))) {
        if (!paragraph.next) {
            break;
        }
        paragraph = paragraph.next;
    }
    NSAssert(paragraph, @"paragraphForTextRange: 错误");
    return paragraph;
}

@end
