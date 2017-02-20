//
//  LMParagraphUnorderedList.m
//  SimpleWord
//
//  Created by Chenly on 2016/12/19.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMParagraphDashedLine.h"
#import "UIFont+LMText.h"

@interface LMParagraphDashedLine ()

@end

@implementation LMParagraphDashedLine

@synthesize view = _view;

- (CGFloat)indent {
    static dispatch_once_t onceToken;
    static CGFloat lineHeight;
    dispatch_once(&onceToken, ^{
        lineHeight = [UIFont lm_systemFont].lineHeight;
    });
    return lineHeight;
}

- (CGFloat)paragraphSpacing {
    return 8.f;
}

- (NSDictionary *)textAttributes {
    
    UIFont *font = [UIFont lm_systemFont];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.paragraphSpacing = [self paragraphSpacing];
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: font,
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 };
    return attributes;
}

- (UIView *)view {
    if (!_view) {
        _view = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.image = [self dashedLineImage];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.frame = CGRectMake(0, 0, [self indent], [self indent]);
            
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor clearColor];
            [view addSubview:imageView];
            view;
        });
    }
    return _view;
}

- (UIImage *)dashedLineImage {    
    static dispatch_once_t onceToken;
    static UIImage *image;
    dispatch_once(&onceToken, ^{
        CGRect rect = CGRectZero;
        rect.size = CGSizeMake([self indent], [self indent]);
        CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(center.x - 4, center.y)];
        [path addLineToPoint:CGPointMake(center.x + 4, center.y)];
        [[UIColor blackColor] setStroke];
        path.lineWidth = 1.f;
        [path stroke];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

@end
