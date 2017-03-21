//
//  LMFormatStyle.h
//  SimpleWord
//
//  Created by Chenly on 2016/12/19.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMFormat.h"

@interface LMFormatStyle : NSObject

@property (nonatomic, readonly) CGFloat indent;
@property (nonatomic, readonly) CGFloat paragraphSpacing;
@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readonly) NSDictionary *textAttributes;

- (instancetype)initWithType:(LMFormatType)type;
+ (instancetype)styleWithType:(LMFormatType)type;

/// 刷新显示（同类型段落减少间距，有序列表数字显示改变）
- (void)updateDisplayWithFormat:(LMFormat *)paragraph;

@end
