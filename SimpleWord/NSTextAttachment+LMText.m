//
//  NSTextAttachment+LMText.m
//  SimpleWord
//
//  Created by Chenly on 16/5/16.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "NSTextAttachment+LMText.h"
#import "LMParagraphConfig.h"
#import <objc/runtime.h>

@implementation NSTextAttachment (LMText)

+ (instancetype)checkBoxAttachment {
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.bounds = CGRectMake(0, 0, 20, 20);
    textAttachment.image = [self imageWithType:LMParagraphTypeCheckbox];
    return textAttachment;
}

+ (instancetype)attachmentWithImage:(UIImage *)image width:(CGFloat)width {
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];    
    CGRect rect = CGRectZero;
    rect.size.width = width;
    rect.size.height = width * image.size.height / image.size.width;
    textAttachment.bounds = rect;
    textAttachment.image = image;
    return textAttachment;
}

+ (UIImage *)imageWithType:(LMParagraphType)type {
    
    CGRect rect = CGRectMake(0, 0, 20, 20);
    UIGraphicsBeginImageContext(rect.size);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [[UIColor redColor] setStroke];
    path.lineWidth = 2.f;
    [path stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

static void * keyOfAttachmentType = &keyOfAttachmentType;
static void * keyOfUserInfo = &keyOfUserInfo;

- (LMTextAttachmentType)attachmentType {
    return [(NSNumber *)objc_getAssociatedObject(self, keyOfAttachmentType) intValue];
}

- (void)setAttachmentType:(LMTextAttachmentType)attachmentType {
    objc_setAssociatedObject(self, keyOfAttachmentType, @(attachmentType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)userInfo {
    return objc_getAssociatedObject(self, keyOfUserInfo);
}

- (void)setUserInfo:(id)userInfo {
    objc_setAssociatedObject(self, keyOfUserInfo, userInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
