//
//  LMTextStyleController.h
//  SimpleWord
//
//  Created by Chenly on 16/5/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMFormatType.h"

@class LMFormat;

@protocol LMFormatInputDelegate <NSObject>

/// 切换段落样式
- (void)lm_didChangedFormatWithType:(LMFormatType)type;

@end

@interface LMFormatInputViewController : UITableViewController

@property (nonatomic, weak) id<LMFormatInputDelegate> delegate;
@property (nonatomic, weak) LMFormat *paragraph;

@end
