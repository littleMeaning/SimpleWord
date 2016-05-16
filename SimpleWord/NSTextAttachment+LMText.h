//
//  NSTextAttachment+LMText.h
//  SimpleWord
//
//  Created by Chenly on 16/5/16.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSTextAttachment (LMText)

+ (instancetype)checkBoxAttachment;
+ (instancetype)attachmentWithImage:(UIImage *)image width:(CGFloat)width;

@end
