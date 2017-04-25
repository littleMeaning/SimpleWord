//
//  LMFontInputViewController.h
//  SimpleWord
//
//  Created by Chenly on 2017/2/10.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMTextStyle;

@protocol LMFontInputDelegate <NSObject>

- (void)lm_didChangedTextStyle:(LMTextStyle *)textStyle;

@end

@interface LMFontInputViewController : UITableViewController

@property (nonatomic, weak) id<LMFontInputDelegate> delegate;
@property (nonatomic, strong) LMTextStyle *textStyle;

- (void)reload;

@end
