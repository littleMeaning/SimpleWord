//
//  LMParagraphUnorderedList.m
//  SimpleWord
//
//  Created by Chenly on 2016/12/19.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMParagraphUnorderedList.h"
#import "UIFont+LMText.h"

@interface LMParagraphUnorderedList ()

@property (nonatomic, assign) UITextView *textView;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) UIBezierPath *exclusionPath;

@end

@implementation LMParagraphUnorderedList

- (void)addToTextViewIfNeed:(UITextView *)textView {
    
    if (self.textView) {
        return;
    }
    
    self.textView = textView;
    
    NSTextContainer *textContainer = self.textView.textContainer;
    NSLayoutManager *layoutManager = self.textView.layoutManager;
    UIEdgeInsets textContainerInset = self.textView.textContainerInset;
    
    CGRect rect = [layoutManager boundingRectForGlyphRange:self.textRange inTextContainer:textContainer];
    rect.size = [self viewSize];
    
    // 在 TextView 中留出放置 "·" 的区域
    self.exclusionPath = [UIBezierPath bezierPathWithRect:rect];
    NSMutableArray *exclusionPaths = [textContainer.exclusionPaths mutableCopy];
    [exclusionPaths addObject:self.exclusionPath];
    textContainer.exclusionPaths = exclusionPaths;
    
    rect.origin.x += textContainerInset.left;
    rect.origin.y += textContainerInset.top;
    
    UIView *view = [self viewForParagraphStyle];
    view.frame = rect;
    [self.textView addSubview:view];
    
    [self textAttributesToFit];
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
    CGFloat lineHeight = [UIFont lm_systemFont].lineHeight;
    return CGSizeMake(lineHeight, lineHeight);
}

// 给段落文本添加对应风格属性
- (void)textAttributesToFit {
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont lm_systemFont],
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
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [self dotImage];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView;
        });
    }
    return _view;
}

- (UIImage *)dotImage {
    
    static dispatch_once_t onceToken;
    static UIImage *image;
    dispatch_once(&onceToken, ^{
        CGRect rect = CGRectZero;
        rect.size = [self viewSize];
        CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
        CGFloat radius = 4.f;
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        [[UIColor grayColor] setFill];
        [path fill];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

@end
