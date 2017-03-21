//
//  LMFontFormatCell.h
//  SimpleWord
//
//  Created by Chenly on 2017/2/10.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMTextStyle.h"

@protocol LMFontFormatDelegate <NSObject>

- (void)lm_didChangeFontFormat:(LMFontFormat)fontFormat;

@end

@interface LMFontFormatCell : UITableViewCell

@property (nonatomic, weak) id<LMFontFormatDelegate> delegate;

@end
