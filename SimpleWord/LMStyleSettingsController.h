//
//  LMTextStyleController.h
//  SimpleWord
//
//  Created by Chenly on 16/5/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMTextStyle;
@class LMParagraphConfig;

@protocol LMStyleSettingsControllerDelegate <NSObject>

- (void)lm_didChangedTextStyle:(LMTextStyle *)textStyle;
- (void)lm_didChangedParagraphIndentLevel:(NSInteger)level;
- (void)lm_didChangedParagraphType:(NSInteger)type;

@end

@interface LMStyleSettingsController : UITableViewController

@property (nonatomic, weak) id<LMStyleSettingsControllerDelegate> delegate;
@property (nonatomic, strong) LMTextStyle *textStyle;

- (void)reload;
- (void)setParagraphConfig:(LMParagraphConfig *)paragraphConfig;

@end
