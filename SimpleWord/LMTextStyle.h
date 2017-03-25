//
//  LMTextStyle.h
//  SimpleWord
//
//  Created by Chenly on 16/5/14.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LMFontFormat) {
    LMFontFormatNone,
    LMFontFormatBody,
    LMFontFormatTitle,
    LMFontFormatSubTitle,
};

@interface LMTextStyle : NSObject <NSCopying>

@property (nonatomic, assign) BOOL bold;
@property (nonatomic, assign) BOOL italic;
@property (nonatomic, assign) BOOL underline;

@property (nonatomic, assign) float fontSize;
@property (nonatomic, strong) UIColor *textColor;

@property (nonatomic, readonly) UIFont *font;

+ (instancetype)textStyleWithFontFormat:(LMFontFormat)format;

#pragma mark - Appearance

+ (instancetype)appearance;
+ (void)setupAppearanceWithInstance:(LMTextStyle *)textStyle;

@end
