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
#import "LMFormat.h"

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
    
    self.beginningParagraph = [[LMFormat alloc] initWithFormatType:LMFormatTypeNormal textView:self];
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
    NSParagraphStyle *style = self.typingAttributes[NSParagraphStyleAttributeName];
    if (style) {
        UIFont *font = self.typingAttributes[NSFontAttributeName] ?: [UIFont lm_systemFont];
        CGFloat height = CGRectGetHeight(rect) - style.lineSpacing * 2;
        if (height > font.lineHeight) {
            rect.origin.y += style.lineSpacing;
            rect.size.height -= style.lineSpacing * 2;
        }
    }
    return rect;
}

#pragma mark - LMFormat

- (void)setParagraphType:(LMFormatType)type forRange:(NSRange)range {
    
    NSRange selectedRange = self.selectedRange;
    self.scrollEnabled = NO; // 设置 scrollEnabled=NO 可以解决 exclusionPath 位置不准确的 bug
    
    LMFormat *begin = [self paragraphAtLocation:range.location];
    LMFormat *end = [self paragraphAtLocation:NSMaxRange(range)];
    
    CGFloat offset = 0;
    LMFormat *oldParagraph = begin;
    LMFormat *newParagraph;
    do {
        [oldParagraph restoreParagraph];
        
        newParagraph = [[LMFormat alloc] initWithFormatType:type textView:self];
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
        
        if (NSLocationInRange(selectedRange.location, newParagraph.textRange) ||
            selectedRange.location == newParagraph.textRange.location) {
            self.typingAttributes = newParagraph.typingAttributes;
        }
        offset += (newParagraph.height - oldParagraph.height);
        
    } while (oldParagraph != end && (oldParagraph = oldParagraph.next));
    end = newParagraph;
    
    // 调整后续段落的位置
    if (offset != 0) {
        LMFormat *item = end;
        while ((item = item.next)) {
            [item updateFrameWithYOffset:offset];
        }
    }
    
    // 如果是有序列表则需要重新编写序号
    if (end.type == LMFormatTypeNumber) {
        [end updateDisplayRecursion];
    }
    else if (end.next.type == LMFormatTypeNumber) {
        [end.next updateDisplayRecursion];
    }
    
    self.selectedRange = selectedRange;
    self.scrollEnabled = YES;
}

- (void)setTypingAttributesForSelection {
    
    LMFormat *paragraph = [self paragraphAtLocation:self.selectedRange.location];
    self.typingAttributes = paragraph.typingAttributes;
}

- (BOOL)changeTextInRange:(NSRange)range replacementText:(NSString *)text {

    LMFormat *begin = [self paragraphAtLocation:range.location];
    LMFormat *end = [self paragraphAtLocation:NSMaxRange(range)];
    
    if ([text isEqualToString:@"\n"] &&
        range.length == 0 &&
        begin.textRange.location == range.location &&
        begin.type != LMFormatTypeNormal) {
        if (begin.length == 0 || ([[self.text substringWithRange:begin.textRange] isEqualToString:@"\n"])) {
            // 光标在段首且为空段落时输入换行则去掉改段落样式
            [self setParagraphType:LMFormatTypeNormal forRange:range];
            return NO;
        }
    }
    else if (text.length == 0 && [[self.text substringWithRange:range] isEqualToString:@"\n"]) {
        // 光标在段首且为空段落时输入退格则去掉改段落样式
        LMFormat *paragraph = [self paragraphAtLocation:range.location + 1];
        if (paragraph.type != LMFormatTypeNormal) {
            [self setParagraphType:LMFormatTypeNormal forRange:NSMakeRange(range.location + 1, 0)];
            return NO;
        }
    }
    
    self.scrollEnabled = NO; // 设置 scrollEnabled=NO 可以解决 exclusionPath 位置不准确的 bug
    // 去掉被删除的段落样式
    CGFloat offset = 0;
    if (begin != end) {
        LMFormat *item = begin;
        while ((item = item.next) && item != end) {
            offset -= item.height;
            [item restoreParagraph];
        }
    }
    
    NSMutableAttributedString *replacement = [[NSMutableAttributedString alloc] init];
    NSMutableArray *newParagraphs = [[NSMutableArray alloc] init];
    LMFormat *paragraph;
    CGFloat tailLength = NSMaxRange(end.textRange) - NSMaxRange(range);
    NSArray *components = [text componentsSeparatedByString:@"\n"];
    if (components.count == 1) {
        // 不包含 "\n" 字符，不产生新的段落
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
        end = begin;
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
                LMFormat *newParagraph = [[LMFormat alloc] initWithFormatType:end.type textView:self];
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
                LMFormat *newParagraph = [[LMFormat alloc] initWithFormatType:LMFormatTypeNormal textView:self];
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
    for (LMFormat *newParagraph in newParagraphs) {
        [newParagraph formatParagraph];
        offset += newParagraph.height;
    }
    
    // 调整后续段落位置
    if (offset != 0) {
        LMFormat *item = end;
        while ((item = item.next)) {
            [item updateFrameWithYOffset:offset];
        }
    }
    
    // 如果是有序列表则需要重新编写序号
    if (end.type == LMFormatTypeNumber) {
        [end updateDisplayRecursion];
    }
    
    self.selectedRange = NSMakeRange(range.location + text.length, 0);   // 设置光标位置
    self.scrollEnabled = YES;
    
    self.typingAttributes = begin.typingAttributes;
    return NO;
}

- (void)didChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    // 没有换行情况下，文本内容改变
    LMFormat *paragraph = [self paragraphAtLocation:range.location];
    paragraph.length += (text.length - range.length);
    
    CGFloat offset = -paragraph.height;
    [paragraph updateLayout];
    offset += paragraph.height;
    if (offset != 0) {
        LMFormat *item = paragraph;
        while ((item = item.next)) {
            [item updateFrameWithYOffset:offset];
        }
    }
}

- (LMFormat *)paragraphAtLocation:(NSUInteger)loc {
    // 通过 Location 查找 Paragraph
    LMFormat *paragraph = self.beginningParagraph;
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
