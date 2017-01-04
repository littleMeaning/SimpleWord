//
//  LMWordView.h
//  SimpleWord
//
//  Created by Chenly on 16/5/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LMParagraph.h"

@interface LMWordView : UITextView

@property (nonatomic, strong) UITextField *titleTextField;

@property (nonatomic, strong) LMParagraph *beginningParagraph;
- (void)insertNewlineWithSelectedRange:(NSRange)selectedRange;
- (void)setParagraphType:(LMParagraphType)type forRange:(NSRange)range;
- (void)setTypingAttributesForSelection;
- (void)changeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)didChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

@end
