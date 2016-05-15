//
//  LMStyleParagraphCell.h
//  SimpleWord
//
//  Created by Chenly on 16/5/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMStyleSettings.h"

@interface LMStyleParagraphCell : UITableViewCell

@property (nonatomic, weak) id<LMStyleSettings> delegate;

@end
