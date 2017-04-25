//
//  LMParagraphNormal.h
//  SimpleWord
//
//  Created by Chenly on 2017/1/1.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import "LMFormatStyle.h"

@class LMTextStyle;

@interface LMFormatNormal : NSObject <LMFormatStyle>

@property (nonatomic, readonly) LMTextStyle *textStyle;

@end
