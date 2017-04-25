//
//  LMSegmentedControl.h
//  SimpleWord
//
//  Created by Chenly on 16/5/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMSegmentedControl;

@protocol LMSegmentedControlDelegate <NSObject>

- (void)lm_segmentedControl:(LMSegmentedControl *)control didTapAtIndex:(NSInteger)index;

@end

@interface LMSegmentedControl : UIControl

@property (nonatomic, weak) id<LMSegmentedControlDelegate> delegate;
@property (nonatomic, assign) BOOL changeSegmentManually;

@property (nonatomic, readonly) NSInteger numberOfSegments;
@property (nonatomic, readonly) NSInteger selectedSegmentIndex;

- (instancetype)initWithItems:(NSArray<UIImage *> *)items;
- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex animated:(BOOL)animated;

@end
