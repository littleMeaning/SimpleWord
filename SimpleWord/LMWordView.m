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
#import "LMFormatManager.h"
#import "LMFormatStyle.h"

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
        UIFont *font = self.typingAttributes[NSFontAttributeName] ?: [UIFont normalFont];
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

    NSMutableArray<LMFormat *> *oldFormats = [NSMutableArray array];
    NSMutableArray<LMFormat *> *newFormats = [NSMutableArray array];
    
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

    LMFormat *item = begin;
    do {
        [oldFormats addObject:item];
    } while (item != end && (item = item.next));
    
    __block NSMutableAttributedString *replacementAttrString = [[NSMutableAttributedString alloc] init];
    NSArray *components = [text componentsSeparatedByString:@"\n"];
    [components enumerateObjectsUsingBlock:^(NSString *component, NSUInteger idx, BOOL * stop) {

        LMFormat *format = [[LMFormat alloc] initWithFormatType:begin.type textView:self];
        if (idx == 0 || idx == components.count - 1) {
            // 头尾两个段落，可能连接前后内容，需额外计算长度
            format.length = ({
                NSString *theText = [self.text stringByReplacingCharactersInRange:range withString:text];
                NSUInteger location = (idx == 0) ? range.location : (range.location + text.length + 1);
                NSUInteger length = 0;
                if (location < theText.length) {
                     length = [theText paragraphRangeForRange:NSMakeRange(location, 0)].length;
                }
                length;
            });
            if (idx == 0 && format.type == LMFormatTypeCheckbox) {
                // checkbox 选中状态不丢失
                format.style.selected = oldFormats.firstObject.style.selected;
            }
        }
        else {
            format.length = component.length + 1;
        }
        [newFormats addObject:format];
        
        if (idx != components.count - 1) {
            component = [component stringByAppendingString:@"\n"];
        }
        NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:component attributes:nil];
        [replacementAttrString appendAttributedString:attributeStr];
    }];
    
    NSMutableAttributedString *attributedText = [self.attributedText mutableCopy];
    [attributedText replaceCharactersInRange:range withAttributedString:replacementAttrString];
    self.allowsEditingTextAttributes = YES;
    self.attributedText = attributedText;
    self.allowsEditingTextAttributes = NO;
    
    [LMFormatManager sharedInstance].textView = self;
    [[LMFormatManager sharedInstance] replaceFormats:oldFormats withReplacements:newFormats];
    
    self.selectedRange = NSMakeRange(range.location + text.length, 0);   // 设置光标位置
    self.typingAttributes = begin.typingAttributes;
    return NO;
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
