//
//  LMTextData.h
//  SimpleWord
//
//  Created by Chenly on 16/5/14.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LMTextStyle;

@interface LMTextData : NSObject

@property (nonatomic, strong) LMTextStyle *textStyle;
@property (nonatomic, copy) NSString *content;

@end
