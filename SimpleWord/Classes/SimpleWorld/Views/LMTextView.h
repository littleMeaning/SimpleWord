//
//  XFTextView.h
//  SimpleWord
//
//  Created by Yizzuide on 2017/2/9.
//  Copyright © 2017年 yizzuide. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^DidAutoExtendBlock)();

@interface LMTextView : UITextView
/**
 *  占位文本
 */
@property (nonatomic, copy) NSString *placeholderText;
/**
 *  占位文本颜色
 */
@property (nonatomic, strong) UIColor *placeholderColor;
/**
 *  占位起始位置
 */
@property (nonatomic, assign) CGPoint placeholderPosition;

/**
 *  是否自动扩展空间来显示
 */
@property (nonatomic, assign, getter=isAutoExtend) BOOL autoExtend;

/**
 *  自扩展完成操作
 */
@property (nonatomic, copy) DidAutoExtendBlock autoExtendBlock;
@end
