//
//  LMTextStyleController.h
//  SimpleWord
//
//  Created by Chenly on 16/5/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMTextStyle;

@protocol LMStyleSettingsControllerDelegate <NSObject>

- (void)lm_didChangedTextStyle:(LMTextStyle *)textStyle;

@end

@interface LMStyleSettingsController : UITableViewController

@property (nonatomic, weak) id<LMStyleSettingsControllerDelegate> delegate;

@property (nonatomic, strong) LMTextStyle *textStyle;

@end
