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

- (void)insertNewlineWithSelectedRange:(NSRange)range {
    
    self.scrollEnabled = NO; // 设置 scrollEnabled=NO 可以解决 exclusionPath 位置不准确的 bug
    
    LMParagraph *begin = [self paragraphAtLocation:range.location];
    LMParagraph *end = [self paragraphAtLocation:NSMaxRange(range)];
    
    // 去掉被删除的段落样式
    CGFloat offset = 0;
    LMParagraph *item = begin;
    while (item != end && (item = item.next)) {
        [item restoreParagraph];
        offset -= item.height;
    }
    
    LMParagraph *newParagraph = [[LMParagraph alloc] initWithType:begin.type textView:self];
    LMParagraph *nextParagraph = end.next;
    if (nextParagraph) {
        newParagraph.next = nextParagraph;
        nextParagraph.previous = newParagraph;
    }
    newParagraph.length = NSMaxRange(end.textRange) - NSMaxRange(range);
    if (newParagraph.length < 0) {
        newParagraph.length = 0;
    }
    begin.length = range.location - begin.textRange.location;
    
    newParagraph.previous = begin;
    begin.next = newParagraph;
    
    // 截断的地方加上"\n"
    NSMutableAttributedString *attributedText = [self.attributedText mutableCopy];
    NSAttributedString *lineBreak = [[NSAttributedString alloc] initWithString:@"\n" attributes:begin.typingAttributes];
    [attributedText replaceCharactersInRange:range withAttributedString:lineBreak];
    self.allowsEditingTextAttributes = YES;
    self.attributedText = attributedText;
    self.allowsEditingTextAttributes = NO;
    begin.length += 1;
    
    offset -= begin.height;
    [begin updateLayout];
    offset += begin.height;
    
    // 格式化新加入的段落
    [newParagraph formatParagraph];
    self.typingAttributes = newParagraph.typingAttributes;
    offset += newParagraph.height;
    
    // 新插入行后之后的段落都需要调整位置
    if (offset != 0) {
        LMParagraph *item = newParagraph;
        while ((item = item.next)) {
            [item updateFrameWithYOffset:offset];
        }
    }
    
    // 如果是有序列表则需要重新编写序号
    item = end.next;
    while (item && item.type == LMParagraphTypeOrderedList) {
        [item updateDisplay];
        item = item.next;
    }
    
    self.selectedRange = NSMakeRange(newParagraph.textRange.location, 0);   // 设置光标位置
    self.scrollEnabled = YES;
}

- (void)setParagraphType:(LMParagraphType)type forRange:(NSRange)range {
    
    NSRange selectedRange = self.selectedRange;
    self.scrollEnabled = NO; // 设置 scrollEnabled=NO 可以解决 exclusionPath 位置不准确的 bug
    
    LMParagraph *begin = [self paragraphAtLocation:range.location];
    LMParagraph *end = [self paragraphAtLocation:NSMaxRange(range)];
    
    CGFloat offset = 0;
    LMParagraph *oldParagraph = begin;
    do {
        [oldParagraph restoreParagraph];
        
        LMParagraph *newParagraph = [[LMParagraph alloc] initWithType:type textView:self];
        if (oldParagraph == self.beginningParagraph) {
            self.beginningParagraph = newParagraph;
        }
        else {
            oldParagraph.previous.next = newParagraph;
            newParagraph.previous = oldParagraph.previous;
        }
        newParagraph.length = oldParagraph.length;
        newParagraph.next = oldParagraph.next;
        oldParagraph.next.previous = newParagraph;
        [newParagraph formatParagraph];
        
        if (NSLocationInRange(selectedRange.location, newParagraph.textRange)) {
            self.typingAttributes = newParagraph.typingAttributes;
        }
        offset += (newParagraph.height - oldParagraph.height);
        
    } while (oldParagraph != end && (oldParagraph = oldParagraph.next));
    
    // 调整后续段落的位置
    if (offset != 0) {
        LMParagraph *item = end;
        while ((item = item.next)) {
            [item updateFrameWithYOffset:offset];
        }
    }
    
    // 如果是有序列表则需要重新编写序号
    LMParagraph *item = end.next;
    while (item && item.type == LMParagraphTypeOrderedList) {
        [item updateDisplay];
        item = item.next;
    }
    
    self.selectedRange = selectedRange;
    self.scrollEnabled = YES;
}

- (void)setTypingAttributesForSelection {
    
    LMParagraph *paragraph = [self paragraphAtLocation:self.selectedRange.location];
    self.typingAttributes = paragraph.typingAttributes;
}

- (void)changeTextInRange:(NSRange)range replacementText:(NSString *)text {

    self.scrollEnabled = NO; // 设置 scrollEnabled=NO 可以解决 exclusionPath 位置不准确的 bug
    
    LMParagraph *begin = [self paragraphAtLocation:range.location];
    LMParagraph *end = [self paragraphAtLocation:NSMaxRange(range)];
    
    // 去掉被删除的段落样式
    CGFloat offset = 0;
    if (begin != end) {
        LMParagraph *item = begin;
        while ((item = item.next) && item != end) {
            offset -= item.height;
            [item restoreParagraph];
        }
    }
    
    NSMutableAttributedString *replacement = [[NSMutableAttributedString alloc] init];
    NSMutableArray *newParagraphs = [[NSMutableArray alloc] init];
    LMParagraph *paragraph;
    CGFloat tailLength = NSMaxRange(end.textRange) - NSMaxRange(range);
    NSArray *components = [text componentsSeparatedByString:@"\n"];
    if (components.count == 1) {
        // 仅一个
        NSString *component = components.firstObject;
        begin.length = range.location - begin.textRange.location + component.length + tailLength;
        NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:component attributes:begin.typingAttributes];
        [replacement appendAttributedString:attributeStr];
        if (begin != end) {
            offset -= end.height;
            [end restoreParagraph];
        }
        begin.next = end.next;
        begin.next.previous = begin;
        paragraph = begin;
    }
    else {
        for (NSInteger idx = 0; idx < components.count; idx ++) {
            NSString *component = components[idx];
            NSAttributedString *attributeStr;
            if (idx == 0) {
                // 第一个
                begin.length = range.location - begin.textRange.location + component.length + 1;
                attributeStr = [[NSAttributedString alloc] initWithString:[component stringByAppendingString:@"\n"] attributes:begin.typingAttributes];
                paragraph = begin;
            }
            else if (idx == components.count - 1) {
                // 最后一个
                LMParagraph *newParagraph = [[LMParagraph alloc] initWithType:end.type textView:self];
                newParagraph.previous = paragraph;
                newParagraph.next = end.next;
                newParagraph.next.previous = newParagraph;
                newParagraph.previous.next = newParagraph;
                if (begin != end) {
                    offset -= end.height;
                    [end restoreParagraph];
                }
                newParagraph.length = component.length + tailLength;
                end = newParagraph;
                [newParagraphs addObject:newParagraph];
                attributeStr = [[NSAttributedString alloc] initWithString:component attributes:end.typingAttributes];
            }
            else {
                LMParagraph *newParagraph = [[LMParagraph alloc] initWithType:LMParagraphTypeNone textView:self];
                newParagraph.previous = paragraph;
                paragraph.next = newParagraph;
                newParagraph.length = component.length + 1;
                
                [newParagraphs addObject:newParagraph];
                paragraph = newParagraph;
                
                attributeStr = [[NSAttributedString alloc] initWithString:[component stringByAppendingString:@"\n"] attributes:paragraph.typingAttributes];
            }
            [replacement appendAttributedString:attributeStr];
        }
    }
    NSMutableAttributedString *attributedText = [self.attributedText mutableCopy];
    [attributedText replaceCharactersInRange:range withAttributedString:replacement];
    self.allowsEditingTextAttributes = YES;
    self.attributedText = attributedText;
    self.allowsEditingTextAttributes = NO;
    
    offset -= begin.height;
    [begin updateLayout];
    offset += begin.height;
    for (LMParagraph *newParagraph in newParagraphs) {
        [newParagraph formatParagraph];
        offset += newParagraph.height;
    }
    
    // 调整后续段落位置
    if (offset != 0) {
        LMParagraph *item = end;
        while ((item = item.next)) {
            [item updateFrameWithYOffset:offset];
        }
    }
    
    // 如果是有序列表则需要重新编写序号
    LMParagraph *item = end.next;
    while (item && item.type == LMParagraphTypeOrderedList) {
        [item updateDisplay];
        item = item.next;
    }
    
    self.selectedRange = NSMakeRange(range.location + text.length, 0);   // 设置光标位置
    self.scrollEnabled = YES;
    
    self.typingAttributes = begin.typingAttributes;
}

- (void)didChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // 没有换行情况下，文本内容改变
    LMParagraph *paragraph = [self paragraphAtLocation:range.location];
    paragraph.length += (text.length - range.length);
    
    CGFloat offset = -paragraph.height;
    [paragraph updateLayout];
    offset += paragraph.height;
    if (offset != 0) {
        LMParagraph *item = paragraph;
        while ((item = item.next)) {
            [item updateFrameWithYOffset:offset];
        }
    }
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
