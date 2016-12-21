//
//  LMParagraphUnorderedList.h
//  SimpleWord
//
//  Created by Chenly on 2016/12/19.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMParagraphStyle.h"

@interface LMParagraphUnorderedList : NSObject <LMParagraphStyle>

@property (nonatomic, assign) LMParagraphStyleType type;
@property (nonatomic, assign) NSRange textRange;

- (void)addToTextViewIfNeed:(UITextView *)textView;
- (void)removeFromTextView;

@end
