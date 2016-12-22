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

@interface LMParagraphCheckbox ()

@property (nonatomic, assign) NSRange textRange;
@property (nonatomic, strong) UIView *view;

@end

@implementation LMParagraphCheckbox

- (CGSize)size {
    return CGSizeMake(LMParagraphCheckboxHeight, LMParagraphCheckboxHeight);
}

- (NSDictionary *)textAttributes {
    
    UIFont *font = [UIFont lm_systemFont];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = 4.f;
    paragraphStyle.minimumLineHeight = LMParagraphCheckboxHeight;
    paragraphStyle.maximumLineHeight = paragraphStyle.minimumLineHeight;
    
    CGFloat baselineOffset = (LMParagraphCheckboxHeight - font.lineHeight) / 2;
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 NSBaselineOffsetAttributeName: @(baselineOffset),
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 };
    return attributes;
}

- (UIView *)view {
    
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
        rect.size = [self size];
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
        rect.size = [self size];
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
