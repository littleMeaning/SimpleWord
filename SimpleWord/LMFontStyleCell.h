//
//  LMStyleFontStyleCell.h
//  SimpleWord
//
//  Created by Chenly on 16/5/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMFontSettings.h"

@interface LMFontStyleCell : UITableViewCell

@property (nonatomic, weak) id<LMFontSettings> delegate;

@property (nonatomic, assign) BOOL bold;
@property (nonatomic, assign) BOOL italic;
@property (nonatomic, assign) BOOL underline;
@property (nonatomic, assign) BOOL enable;

@end
