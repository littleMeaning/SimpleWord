//
//  LMFormatEventCenter.h
//  SimpleWord
//
//  Created by Chenly on 2017/3/26.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMWordView;
@class LMFormat;

@interface LMFormatManager : NSObject

@property (nonatomic, weak) LMWordView *textView;

+ (instancetype)sharedInstance;

- (void)inserFormats:(NSArray <LMFormat *> *)formats before:(LMFormat *)item;
- (void)inserFormats:(NSArray <LMFormat *> *)formats after:(LMFormat *)item;
- (void)removeFormats:(NSArray <LMFormat *> *)formats;
- (void)replaceFormats:(NSArray <LMFormat *> *)formats withReplacements:(NSArray <LMFormat *> *)replacements;

@end
