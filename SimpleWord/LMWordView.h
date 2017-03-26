//
//  LMWordView.h
//  SimpleWord
//
//  Created by Chenly on 16/5/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMFormatType.h"

@class LMFormat;

@interface LMWordView : UITextView

@property (nonatomic, strong) UITextField *titleTextField;

@property (nonatomic, strong) LMFormat *beginningFormat;
- (void)setFormatWithType:(LMFormatType)type forRange:(NSRange)range;
- (void)setTypingAttributesForSelection;
- (BOOL)changeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (LMFormat *)formatAtLocation:(NSUInteger)loc;

@end
