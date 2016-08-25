//
//  LMParagraphStyle.m
//  SimpleWord
//
//  Created by Chenly on 16/5/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMParagraphConfig.h"

NSString * const LMParagraphTypeName = @"LMParagraphType";
NSString * const LMParagraphIndentName = @"LMParagraphIndent";

@implementation LMParagraphConfig

static CGFloat const kIndentPerLevel = 32.f;
static NSInteger const kMaxIndentLevel = 6;

- (instancetype)init {
    if (self = [super init]) {
        _type = LMParagraphTypeNone;
        _indentLevel = 0;
    }
    return self;
}

- (instancetype)initWithParagraphStyle:(NSParagraphStyle *)paragraphStyle type:(LMParagraphType)type {
    if (self = [super init]) {
        _indentLevel = paragraphStyle.headIndent / kIndentPerLevel;
    }
    return self;
}

- (void)setIndentLevel:(NSInteger)indentLevel {
    if (indentLevel < 0) {
        indentLevel = 0;
    }
    else if (indentLevel > kMaxIndentLevel) {
        indentLevel = kMaxIndentLevel;
    }
    _indentLevel = indentLevel;    
}

- (NSParagraphStyle *)paragraphStyle {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    paragraphStyle.headIndent = kIndentPerLevel * self.indentLevel;
    paragraphStyle.firstLineHeadIndent = kIndentPerLevel * self.indentLevel;
    return paragraphStyle;
}

@end
