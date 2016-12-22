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

@interface LMParagraphStyle ()

@property (nonatomic, assign) UITextView *textView;
@property (nonatomic, strong) id<LMParagraphStyle> child;

@end

@implementation LMParagraphStyle

- (instancetype)initWithType:(LMParagraphType)type {
    
    if (self = [super init]) {
        switch (type) {
            case LMParagraphTypeNone:
                _child = nil;
                break;
            case LMParagraphTypeUnorderedList:
            {
                _child = [[LMParagraphUnorderedList alloc] init];
                break;
            }
            case LMParagraphTypeOrderedList:
            {
                _child = [[LMParagraphOrderedList alloc] init];
                break;
            }
            case LMParagraphTypeCheckbox:
            {
                _child = [[LMParagraphCheckbox alloc] init];
                break;
            }
            default:
                break;
        }
    }
    return self;
}

- (CGSize)size {
    return [self.child size];
}

- (UIView *)view {
    return [self.child view];
}

- (NSDictionary *)textAttributes {
    return [self.child textAttributes];
}

@end
