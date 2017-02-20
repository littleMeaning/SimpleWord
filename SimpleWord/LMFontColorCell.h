//
//  LMStyleColorCell.h
//  SimpleWord
//
//  Created by Chenly on 16/5/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMFontSettings.h"

@interface LMFontColorCell : UITableViewCell

@property (nonatomic, weak) id<LMFontSettings> delegate;

@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, copy) NSArray *colors;

@end
