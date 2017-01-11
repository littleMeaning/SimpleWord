//
//  LMTextStyleController.h
//  SimpleWord
//
//  Created by Chenly on 16/5/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMTextStyle;
@class LMParagraph;

@protocol LMStyleSettingsControllerDelegate <NSObject>

- (void)lm_didChangedTextStyle:(LMTextStyle *)textStyle;
- (void)lm_didChangedParagraphIndentLevel:(NSInteger)level;
- (void)lm_didChangedParagraphType:(NSInteger)type; // 切换段落格式，有序、无序、检查框

@end

@interface LMStyleSettingsController : UITableViewController

@property (nonatomic, weak) id<LMStyleSettingsControllerDelegate> delegate;
@property (nonatomic, strong) LMTextStyle *textStyle;
@property (nonatomic, weak) LMParagraph *currentParagraph;

- (void)reload;
- (void)setParagraph:(LMParagraph *)paragraph;

@end
