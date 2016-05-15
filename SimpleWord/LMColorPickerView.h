//
//  LMColorPickerView.h
//  LMColorPickerView
//
//  Created by Chenly on 16/5/14.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMColorPickerView;

@protocol LMColorPickerViewDataSource <NSObject>

- (NSInteger)lm_numberOfColorsInColorPickerView:(LMColorPickerView *)pickerView;
- (UIColor *)lm_colorPickerView:(LMColorPickerView *)pickerView colorForItemAtIndex:(NSInteger)index;

@end

@protocol LMColorPickerViewDelegate <NSObject>

@optional
- (void)lm_colorPickerView:(LMColorPickerView *)pickerView didSelectIndex:(NSInteger)index;
- (void)lm_colorPickerView:(LMColorPickerView *)pickerView didSelectColor:(UIColor *)color;

@end

@interface LMColorPickerView : UIView

@property (nonatomic, weak) id<LMColorPickerViewDataSource> dataSource;
@property (nonatomic, weak) id<LMColorPickerViewDelegate> delegate;

@property (nonatomic, assign) NSInteger spacingBetweenColors; // default is 20.f

@property (nonatomic, readonly) NSInteger numberOfColors;
@property (nonatomic, readonly) NSInteger selectedIndex;

- (void)reloadData;
- (void)selectIndex:(NSInteger)index;

@end
