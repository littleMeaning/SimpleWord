//
//  UIFont+LMText.h
//  SimpleWord
//
//  Created by Chenly on 16/6/30.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (LMText)

@property (nonatomic, readonly) BOOL bold;
@property (nonatomic, readonly) BOOL italic;
@property (nonatomic, readonly) float fontSize;

+ (instancetype)lm_fontWithFontSize:(float)fontSize bold:(BOOL)bold italic:(BOOL)italic;

@end

