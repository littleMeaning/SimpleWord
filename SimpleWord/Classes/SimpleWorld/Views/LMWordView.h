//
//  LMWordView.h
//  SimpleWord
//
//  Created by Chenly on 16/5/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMWordView : UITextView

@property (nonatomic, strong) UITextField *titleTextField;

// 标题占位文本
@property (nonatomic, copy) NSString *titlePlaceholder;
// 标题占位文本颜色
@property (nonatomic, strong) NSString *titlePlaceholderColor;
// 占位文本
@property (nonatomic, copy) NSString *placeholder;
// 占位文本颜色
@property (nonatomic, strong) UIColor *placeholderColor;
@end
