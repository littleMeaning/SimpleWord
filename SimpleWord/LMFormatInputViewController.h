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

// 选择段落样式
- (void)lm_didSelectRowForFormatType:(LMFormatType)type;

@end

@interface LMFormatInputViewController : UITableViewController

@property (nonatomic, weak) id<LMFormatInputDelegate> delegate;

- (void)selectRowForFormatType:(LMFormatType)type;

@end
