//
//  LMStyleFontStyleCell.h
//  SimpleWord
//
//  Created by Chenly on 16/5/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMStyleSettings.h"

@interface LMStyleFontStyleCell : UITableViewCell

@property (nonatomic, weak) id<LMStyleSettings> delegate;

@property (nonatomic, assign) BOOL bold;
@property (nonatomic, assign) BOOL italic;
@property (nonatomic, assign) BOOL underline;

@end
