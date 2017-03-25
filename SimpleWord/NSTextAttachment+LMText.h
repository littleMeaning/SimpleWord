//
//  NSTextAttachment+LMText.h
//  SimpleWord
//
//  Created by Chenly on 16/5/16.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LMTextAttachmentType) {
    LMTextAttachmentTypeImage,
    LMTextAttachmentTypeCheckBox,
};

@interface NSTextAttachment (LMText)

+ (instancetype)checkBoxAttachment;
+ (instancetype)attachmentWithImage:(UIImage *)image width:(CGFloat)width;

@property (nonatomic, assign) LMTextAttachmentType attachmentType;
@property (nonatomic, strong) id userInfo;

@end
