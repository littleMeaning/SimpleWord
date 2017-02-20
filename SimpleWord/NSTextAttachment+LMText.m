//
//  NSTextAttachment+LMText.m
//  SimpleWord
//
//  Created by Chenly on 16/5/16.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "NSTextAttachment+LMText.h"
#import "UIFont+LMText.h"
#import <objc/runtime.h>

@implementation NSTextAttachment (LMText)

+ (CGRect)attachmentBounds {
    CGFloat height = (NSInteger)[UIFont lm_systemFont].lineHeight + 4.f;
    return CGRectMake(0, 0, height, height);
}

+ (instancetype)checkBoxAttachment {
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.bounds = CGRectZero;
    textAttachment.attachmentType = LMTextAttachmentTypeCheckBox;
    return textAttachment;
}

//+ (instancetype)attachmentWithImage:(UIImage *)image width:(CGFloat)width {
//    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];    
//    CGRect rect = CGRectZero;
//    rect.size.width = width;
//    rect.size.height = width * image.size.height / image.size.width;
//    rect.size.width += kSpaceWidth;
//    textAttachment.bounds = rect;
//    textAttachment.image = image;
//    return textAttachment;
//}

//+ (UIImage *)imageWithType:(LMFormatType)type {
//    CGRect rect = [self attachmentBounds];
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake(rect.size.width + kSpaceWidth, rect.size.height), NO, [UIScreen mainScreen].scale);
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectInset(rect, 1, 1)];
//    [[UIColor redColor] setStroke];
//    path.lineWidth = 1.f;
//    [path stroke];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}

- (LMTextAttachmentType)attachmentType {
    return [(NSNumber *)objc_getAssociatedObject(self, @selector(attachmentType)) intValue];
}

- (void)setAttachmentType:(LMTextAttachmentType)attachmentType {
    objc_setAssociatedObject(self, @selector(attachmentType), @(attachmentType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)userInfo {
    return objc_getAssociatedObject(self, @selector(userInfo));
}

- (void)setUserInfo:(id)userInfo {
    objc_setAssociatedObject(self, @selector(userInfo), userInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
