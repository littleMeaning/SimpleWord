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
    
    self.beginningFormat = [[LMFormat alloc] initWithFormatType:LMFormatTypeNormal textView:self];
    self.typingAttributes = self.beginningFormat.typingAttributes;
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

- (void)setFormatWithType:(LMFormatType)type forRange:(NSRange)range {
    
    NSRange selectedRange = self.selectedRange;
    self.scrollEnabled = NO; // 设置 scrollEnabled=NO 可以解决 exclusionPath 位置不准确的 bug
    
    LMFormat *begin = [self formatAtLocation:range.location];
    LMFormat *end = [self formatAtLocation:NSMaxRange(range)];
    
    CGFloat offset = 0;
    LMFormat *oldFormat = begin;
    LMFormat *newFormat;
    do {
        [oldFormat restore];
        
        newFormat = [[LMFormat alloc] initWithFormatType:type textView:self];
        if (oldFormat == self.beginningFormat) {
            self.beginningFormat = newFormat;
        }
        else {
            oldFormat.previous.next = newFormat;
            newFormat.previous = oldFormat.previous;
        }
        newFormat.length = oldFormat.length;
        newFormat.next = oldFormat.next;
        oldFormat.next.previous = newFormat;
        [newFormat format];
        
        if (NSLocationInRange(selectedRange.location, newFormat.textRange) ||
            selectedRange.location == newFormat.textRange.location) {
            self.typingAttributes = newFormat.typingAttributes;
        }
        offset += (newFormat.height - oldFormat.height);
        
    } while (oldFormat != end && (oldFormat = oldFormat.next));
    end = newFormat;
    
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
    
    LMFormat *format = [self formatAtLocation:self.selectedRange.location];
    self.typingAttributes = format.typingAttributes;
}

- (BOOL)changeTextInRange:(NSRange)range replacementText:(NSString *)text {

    LMFormat *begin = [self formatAtLocation:range.location];
    LMFormat *end = [self formatAtLocation:NSMaxRange(range)];
    
    if ([text isEqualToString:@"\n"] &&
        range.length == 0 &&
        begin.textRange.location == range.location &&
        begin.type != LMFormatTypeNormal) {
        if (begin.length == 0 || ([[self.text substringWithRange:begin.textRange] isEqualToString:@"\n"])) {
            // 光标在段首且为空段落时输入换行则去掉改段落样式
            [self setFormatWithType:LMFormatTypeNormal forRange:range];
            return NO;
        }
    }
    else if (text.length == 0 && [[self.text substringWithRange:range] isEqualToString:@"\n"]) {
        // 光标在段首且为空段落时输入退格则去掉改段落样式
        LMFormat *format = [self formatAtLocation:range.location + 1];
        if (format.type != LMFormatTypeNormal) {
            [self setFormatWithType:LMFormatTypeNormal forRange:NSMakeRange(range.location + 1, 0)];
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
            [item restore];
        }
    }
    
    NSMutableAttributedString *replacement = [[NSMutableAttributedString alloc] init];
    NSMutableArray *newFormats = [[NSMutableArray alloc] init];
    LMFormat *format;
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
            [end restore];
        }
        begin.next = end.next;
        begin.next.previous = begin;
        format = begin;
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
                format = begin;
            }
            else if (idx == components.count - 1) {
                // 最后一个
                LMFormat *newFormat = [[LMFormat alloc] initWithFormatType:end.type textView:self];
                newFormat.previous = format;
                newFormat.next = end.next;
                newFormat.next.previous = newFormat;
                newFormat.previous.next = newFormat;
                if (begin != end) {
                    offset -= end.height;
                    [end restore];
                }
                newFormat.length = component.length + tailLength;
                end = newFormat;
                [newFormats addObject:newFormat];
                attributeStr = [[NSAttributedString alloc] initWithString:component attributes:end.typingAttributes];
            }
            else {
                LMFormat *newFormat = [[LMFormat alloc] initWithFormatType:LMFormatTypeNormal textView:self];
                newFormat.previous = format;
                format.next = newFormat;
                newFormat.length = component.length + 1;
                
                [newFormats addObject:newFormat];
                format = newFormat;
                
                attributeStr = [[NSAttributedString alloc] initWithString:[component stringByAppendingString:@"\n"] attributes:format.typingAttributes];
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
    for (LMFormat *newFormat in newFormats) {
        [newFormat format];
        offset += newFormat.height;
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
    CGFloat location = range.location;
    LMFormat *format = [self formatAtLocation:location];
    // 获取当前编辑的段落长度
    format.length = [self.text paragraphRangeForRange:NSMakeRange(location, 0)].length;
    // 调整后面的段落位置
    CGFloat offset = -format.height;
    [format updateLayout];
    offset += format.height;
    if (offset != 0) {
        LMFormat *item = format;
        while ((item = item.next)) {
            [item updateFrameWithYOffset:offset];
        }
    }
}

- (LMFormat *)formatAtLocation:(NSUInteger)loc {
    // 通过 Location 查找 Format
    LMFormat *format = self.beginningFormat;
    while (format && !(loc == format.textRange.location || NSLocationInRange(loc, format.textRange))) {
        if (!format.next) {
            break;
        }
        format = format.next;
    }
    NSAssert(format, @"formatAtLocation: 错误");
    return format;
}

@end
