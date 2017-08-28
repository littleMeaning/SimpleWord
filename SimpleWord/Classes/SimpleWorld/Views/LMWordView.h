//
//  LMWordView.h
//  SimpleWord
//
//  Created by Chenly on 16/5/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMTextView.h"

typedef void(^DidAutoExtendBlock)();

@interface LMWordView : UITextView

/**
 *  标题文本框
 */
@property (nonatomic, strong) LMTextView *titleTextView;

// 标题占位文本
@property (nonatomic, copy) NSString *titlePlaceholder;
// 标题占位文本颜色
@property (nonatomic, strong) UIColor *titlePlaceholderColor;
// 占位文本
@property (nonatomic, copy) NSString *placeholder;
// 占位文本颜色
@property (nonatomic, strong) UIColor *placeholderColor;

/**
 *  自扩展完成操作
 */
@property (nonatomic, copy) DidAutoExtendBlock titleExtendBlock;
@end
