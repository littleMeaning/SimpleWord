//
//  LMParagraphStyle.h
//  SimpleWord
//
//  Created by Chenly on 16/5/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const LMParagraphTypeName;
extern NSString * const LMParagraphIndentName;

typedef NS_ENUM(NSUInteger, LMParagraphType) {
    LMParagraphTypeNone = 0,
    LMParagraphTypeList,
    LMParagraphTypeNumberList,
    LMParagraphTypeCheckbox
};

@interface LMParagraphConfig : NSObject

@property (nonatomic, assign) LMParagraphType type;
@property (nonatomic, assign) NSInteger indentLevel;

@property (nonatomic, readonly) NSParagraphStyle *paragraphStyle;

- (instancetype)initWithParagraphStyle:(NSParagraphStyle *)paragraphStyle type:(LMParagraphType)type;

@end
