//
//  LMParagraphCheckbox.m
//  SimpleWord
//
//  Created by Chenly on 2016/12/19.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMParagraphCheckbox.h"
#import "UIFont+LMText.h"

static CGFloat const LMParagraphCheckboxHeight = 20.f;
static CGFloat const LMParagraphCheckboxLineSpacing = 4.f;


@interface LMParagraphCheckbox ()

@property (nonatomic, assign) UITextView *textView;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIBezierPath *exclusionPath;

@end

@implementation LMParagraphCheckbox

- (void)addToTextViewIfNeed:(UITextView *)textView {
    
    if (self.textView) {
        return;
    }
    
    self.textView = textView;
    [self textAttributesToFit];
    
    NSTextContainer *textContainer = self.textView.textContainer;
    NSLayoutManager *layoutManager = self.textView.layoutManager;
    UIEdgeInsets textContainerInset = self.textView.textContainerInset;
    
    CGRect rect = [layoutManager boundingRectForGlyphRange:self.textRange inTextContainer:textContainer];
    CGSize checkboxSize = [self viewSize];
    rect.size = checkboxSize;
    
    // 在 TextView 中留出放置 checkbox 的区域
    self.exclusionPath = [UIBezierPath bezierPathWithRect:rect];
    NSMutableArray *exclusionPaths = [textContainer.exclusionPaths mutableCopy];
    [exclusionPaths addObject:self.exclusionPath];
    textContainer.exclusionPaths = exclusionPaths;
    
    rect.origin.x += textContainerInset.left;
    rect.origin.y += textContainerInset.top;
    
    UIView *view = [self viewForParagraphStyle];
    view.frame = rect;
    [self.textView addSubview:view];
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
    return CGSizeMake(LMParagraphCheckboxHeight, LMParagraphCheckboxHeight);
}

// 给段落文本添加对应风格属性
- (void)textAttributesToFit {
    
    UIFont *font = [UIFont lm_systemFont];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = (LMParagraphCheckboxHeight - font.lineHeight) / 2 + LMParagraphCheckboxLineSpacing;
    paragraphStyle.paragraphSpacingBefore = paragraphStyle.lineSpacing;
    paragraphStyle.paragraphSpacing = paragraphStyle.lineSpacing;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: paragraphStyle,
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
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[self checkboxImage] forState:UIControlStateNormal];
            [button setImage:[self checkboxHighlightImage] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _view;
}

- (void)buttonAction:(UIButton *)button {
    button.selected = !button.selected;
}

- (UIImage *)checkboxImage {
    
    static dispatch_once_t onceToken;
    static UIImage *image;
    dispatch_once(&onceToken, ^{
        CGRect rect = CGRectZero;
        rect.size = [self viewSize];
        CGFloat lineWidth = 1.f;
        
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, lineWidth, lineWidth) cornerRadius:(rect.size.width - lineWidth)/2];
        path.lineWidth = lineWidth;
        [[UIColor grayColor] setStroke];
        [path stroke];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

- (UIImage *)checkboxHighlightImage {
    
    static dispatch_once_t onceToken;
    static UIImage *image;
    dispatch_once(&onceToken, ^{
        CGRect rect = CGRectZero;
        rect.size = [self viewSize];
        CGFloat lineWidth = 1.f;
        
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, lineWidth, lineWidth) cornerRadius:(rect.size.width - lineWidth)/2];
        path.lineWidth = lineWidth / 2;
        [[UIColor grayColor] setStroke];
        [[UIColor lightGrayColor] setFill];
        [path stroke];
        [path fill];
        // 画勾
        UIBezierPath *checkPath = [UIBezierPath bezierPath];
        CGFloat edge = rect.size.width * 0.2;
        rect = CGRectInset(rect, edge, edge);
        CGFloat unit = rect.size.width / 11;
        CGFloat left = edge;
        CGFloat top = edge + 2 * unit;
        [checkPath moveToPoint:CGPointMake(left, top + 3 * unit)];
        [checkPath addLineToPoint:CGPointMake(left + 4 * unit, top + 7 * unit)];
        [checkPath addLineToPoint:CGPointMake(left + 11 * unit, top)];
        [[UIColor whiteColor] setStroke];
        [checkPath stroke];
        [path appendPath:checkPath];
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

@end
