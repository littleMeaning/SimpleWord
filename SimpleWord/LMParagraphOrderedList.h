//
//  LMParagraphOrderedList.h
//  SimpleWord
//
//  Created by Chenly on 2016/12/20.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMParagraphStyle.h"

@interface LMParagraphOrderedList : NSObject <LMParagraphStyle>

@property (nonatomic, assign) LMParagraphStyleType type;
@property (nonatomic, assign) NSRange textRange;

- (void)addToTextViewIfNeed:(UITextView *)textView;
- (void)removeFromTextView;

@end
