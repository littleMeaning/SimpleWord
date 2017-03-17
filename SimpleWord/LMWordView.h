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

@property (nonatomic, strong) LMFormat *beginningParagraph;
- (void)setParagraphType:(LMFormatType)type forRange:(NSRange)range;
- (void)setTypingAttributesForSelection;
- (BOOL)changeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)didChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (LMFormat *)paragraphAtLocation:(NSUInteger)loc;

@end
