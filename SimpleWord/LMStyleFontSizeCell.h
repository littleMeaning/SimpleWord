//
//  LMStyleFontCell.h
//  SimpleWord
//
//  Created by Chenly on 16/5/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMStyleSettings.h"

@interface LMStyleFontSizeCell : UITableViewCell

@property (nonatomic, weak) id<LMStyleSettings> delegate;

@property (nonatomic, copy) NSArray<NSNumber *> *fontSizeNumbers;
@property (nonatomic, assign) NSInteger currentFontSize;

@end
