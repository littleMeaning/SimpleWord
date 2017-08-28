//
//  LMTextView.m
//  SimpleWord
//
//  Created by Yizzuide on 2017/2/9.
//  Copyright © 2017年 yizzuide. All rights reserved.
//

#import "LMTextView.h"

@interface LMTextView ()

@property (nonatomic, weak) UILabel *placeholderLabel;
@property (nonatomic, assign) NSInteger numOfLine;
@end

@implementation LMTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 垂直方向上永远有弹簧效果
        self.alwaysBounceVertical = YES;
        
        self.numOfLine = 1;
        
        // 默认字体
        self.font = [UIFont systemFontOfSize:15];
        
        // 默认的占位文字颜色
        self.placeholderColor = [UIColor grayColor];
        
        if (self.isAutoExtend) {
            self.showsVerticalScrollIndicator = NO;
        }
        
        // 侦听文本通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textViewEditing:) name:UITextViewTextDidChangeNotification object:self];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textViewBegin:) name:UITextViewTextDidBeginEditingNotification object:self];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_textViewEnd:) name:UITextViewTextDidEndEditingNotification object:self];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 视图通知
- (void)_textViewEditing:(NSNotification *)noti
{
      // 只要有文字, 就隐藏占位文字label
    self.placeholderLabel.hidden = self.hasText && self.attributedText.length;
    if (self.isAutoExtend) {
        // 当前内容高度
        CGSize contentSize = self.contentSize;
        CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
        int length = size.height;
        int colomNumber = (contentSize.height)/length;
        if (self.autoExtendBlock && self.numOfLine != colomNumber) {
            self.autoExtendBlock();
            self.numOfLine = colomNumber;
        }
    }
}

/*- (void)_textViewBegin:(NSNotification *)noti
{
    
}

- (void)_textViewEnd:(NSNotification *)noti
{
    
}*/


- (void)insertText:(NSString *)text
{
    if (self.isAutoExtend) {
        // 禁止手动换行
        if ([text isEqualToString:@"\n"]) {
            return;
        }
    }
    [super insertText:text];
}

#pragma mark - 重写setter
- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    
    self.placeholderLabel.textColor = placeholderColor;
}

- (void)setPlaceholderText:(NSString *)placeholderText
{
    _placeholderText = [placeholderText copy];
    
    self.placeholderLabel.text = placeholderText;
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    [self.placeholderLabel sizeToFit];
    CGRect frame = self.placeholderLabel.frame;
    frame.origin.x = self.placeholderPosition.x;
    frame.origin.y = self.placeholderPosition.y;
    frame.size.width = self.frame.size.width - 2 * self.placeholderLabel.frame.origin.x;
    self.placeholderLabel.frame = frame;
}

- (UILabel *)placeholderLabel
{
	if (!_placeholderLabel){
        UILabel *placeholderLabel = [[UILabel alloc] init];
        
        placeholderLabel.numberOfLines = 0;
        [self addSubview:placeholderLabel];
        _placeholderLabel = placeholderLabel;
	}
	return _placeholderLabel;
}

@end
