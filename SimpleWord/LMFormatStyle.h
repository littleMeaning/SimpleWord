//
//  LMFormatStyle.h
//  SimpleWord
//
//  Created by Chenly on 2016/12/19.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMFormat.h"

@class LMTextStyle;

@protocol LMFormatStyle <NSObject>

@property (nonatomic, readonly) CGFloat indent;
@property (nonatomic, readonly) CGFloat paragraphSpacing;
@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readonly) NSDictionary *textAttributes;

@optional
@property (nonatomic, readonly) LMTextStyle *textStyle; // LMFormatNormal
@property (nonatomic, readonly) NSInteger number;       // LMFormatNumber

/**
 刷新显示（同类型段落减少间距，有序列表数字显示改变）
 */
- (void)updateDisplayWithFormat:(LMFormat *)format;

@end

@interface LMFormatStyle : NSObject <LMFormatStyle>

+ (instancetype)styleWithType:(LMFormatType)type;

@end
