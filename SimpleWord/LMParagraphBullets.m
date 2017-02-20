//
//  LMParagraphUnorderedList.m
//  SimpleWord
//
//  Created by Chenly on 2016/12/19.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMParagraphBullets.h"
#import "UIFont+LMText.h"

@interface LMParagraphBullets ()

@end

@implementation LMParagraphBullets

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
            imageView.image = [self dotImage];
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

- (UIImage *)dotImage {    
    static dispatch_once_t onceToken;
    static UIImage *image;
    dispatch_once(&onceToken, ^{
        CGRect rect = CGRectZero;
        rect.size = CGSizeMake([self indent], [self indent]);
        CGPoint center = CGPointMake(rect.size.width / 2, rect.size.height / 2);
        CGFloat radius = 4.f;
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        [[UIColor blackColor] setFill];
        [path fill];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return image;
}

@end
