//
//  LMWordView.m
//  SimpleWord
//
//  Created by Chenly on 16/5/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMWordView.h"
#import <objc/runtime.h>

@interface LMWordView ()

@property (nonatomic, weak) UILabel *placeholderLabel;
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
    _titleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.titlePlaceholder?:@"标题"
            attributes:@{ NSForegroundColorAttributeName:self.titlePlaceholderColor?:[UIColor grayColor]}];
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
    
    // 默认的占位文字颜色
    self.placeholderColor = [UIColor grayColor];
    // 侦听文本改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textViewEditing:) name:UITextViewTextDidChangeNotification object:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_textViewEditing:(NSNotification *)noti
{
    // 只要有文字, 就隐藏占位文字label
    self.placeholderLabel.hidden = self.hasText && self.attributedText.length;
}

/*- (void)insertText:(NSString *)text
{
    if (!self.hasText && [text isEqualToString:@"\n"]) {
        return;
    }
    [super insertText:text];
}*/

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
    
    // placeholder
    CGRect frame = self.placeholderLabel.frame;
    frame.size.width = self.frame.size.width - 2 * self.placeholderLabel.frame.origin.x;
    self.placeholderLabel.frame = frame;
    [self.placeholderLabel sizeToFit];
}

#pragma mark - 重写setter
- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    
    self.placeholderLabel.textColor = placeholderColor;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = [placeholder copy];
    
    self.placeholderLabel.text = placeholder;
    [self setNeedsLayout];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    
    self.placeholderLabel.font = font;
    [self setNeedsLayout];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    
    // 更新文本改变
    [self _textViewEditing:nil];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    // 更新文本改变
    [self _textViewEditing:nil];
}

- (UILabel *)placeholderLabel
{
    if (!_placeholderLabel){
        UILabel *placeholderLabel = [[UILabel alloc] init];
        CGRect frame = placeholderLabel.frame;
        frame.origin.x = kLMWMargin;
        frame.origin.y = kLMWMargin + kLMWTitleHeight + kLMWCommonSpacing;
        placeholderLabel.frame = frame;
        placeholderLabel.numberOfLines = 0;
        [self addSubview:placeholderLabel];
        _placeholderLabel = placeholderLabel;
    }
    return _placeholderLabel;
}
@end
