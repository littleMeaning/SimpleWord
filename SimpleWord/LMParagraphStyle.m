//
//  LMParagraphStyle.m
//  SimpleWord
//
//  Created by Chenly on 2016/12/19.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMParagraphStyle.h"
#import "UIFont+LMText.h"
#import "LMParagraphUnorderedList.h"
#import "LMParagraphOrderedList.h"
#import "LMParagraphCheckbox.h"

NSString * const LMParagraphStyleAttributeName = @"LMParagraphStyleAttributeName";

@interface LMParagraphStyle ()

@property (nonatomic, strong) id<LMParagraphStyle> child;

@end

@implementation LMParagraphStyle

- (instancetype)initWithType:(LMParagraphStyleType)type textRange:(NSRange)textRange {
    
    if (self = [super init]) {
        switch (type) {
            case LMParagraphStyleTypeNone:
                _child = nil;
                break;
            case LMParagraphStyleTypeUnorderedList:
            {
                _child = ({
                    LMParagraphUnorderedList *child = [[LMParagraphUnorderedList alloc] init];
                    child.textRange = textRange;
                    child.type = type;
                    child;
                });
                break;
            }
            case LMParagraphStyleTypeOrderedList:
            {
                _child = ({
                    LMParagraphOrderedList *child = [[LMParagraphOrderedList alloc] init];
                    child.textRange = textRange;
                    child.type = type;
                    child;
                });
                break;
            }
            case LMParagraphStyleTypeCheckbox:
            {
                _child = ({
                    LMParagraphCheckbox *child = [[LMParagraphCheckbox alloc] init];
                    child.textRange = textRange;
                    child.type = type;
                    child;
                });
                break;
            }
            default:
                break;
        }
    }
    return self;
}

- (LMParagraphStyleType)type {
    return self.child.type;
}

- (NSRange)textRange {
    return self.child.textRange;
}

- (void)addToTextViewIfNeed:(UITextView *)textView {
    [self.child addToTextViewIfNeed:textView];
}

- (void)removeFromTextView {
    [self.child removeFromTextView];
}

@end

@implementation UITextView (LMParagraphStyle)

- (LMParagraphStyle *)lm_paragraphStyleForTextRange:(NSRange)textRange {

    NSAttributedString *text = [self.attributedText attributedSubstringFromRange:textRange];
    NSDictionary *attributes = [text attributesAtIndex:0 effectiveRange:NULL];
    return attributes[LMParagraphStyleAttributeName];
}

@end
