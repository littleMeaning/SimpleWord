//
//  LMColorPickerView.m
//  LMColorPickerView
//
//  Created by Chenly on 16/5/14.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMColorPickerView.h"

@interface LMColorPickerView ()

@end

@implementation LMColorPickerView
{
    UIScrollView *_scrollView;
    NSMutableArray *_itemViews;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor whiteColor];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_scrollView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
    
    _itemViews = [NSMutableArray array];
    _selectedIndex = -1;
    _spacingBetweenColors = 20.f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = CGRectZero;
    rect.size.height = (CGRectGetHeight(self.bounds) - self.spacingBetweenColors) / 2;
    rect.size.width = rect.size.height;
    
    NSInteger numberOfColorsInRow = self.numberOfColors / 2 + (self.numberOfColors % 2);
    CGFloat contentWidth = numberOfColorsInRow * CGRectGetWidth(rect) + (numberOfColorsInRow - 1) * self.spacingBetweenColors;
    if (contentWidth < CGRectGetWidth(self.bounds)) {
        // 两行时无法占满宽度，则用一行展示。
        rect.origin.y = self.spacingBetweenColors;
        rect.size.height = CGRectGetHeight(self.bounds) - self.spacingBetweenColors * 2;
        rect.size.width = rect.size.height;
        numberOfColorsInRow = self.numberOfColors;
    }

    for (NSInteger index = 0; index < _itemViews.count; index++) {
        if (index == numberOfColorsInRow) {
            rect.origin.x = 0;
            rect.origin.y += CGRectGetHeight(rect) + self.spacingBetweenColors;
        }
        UIView *itemView = _itemViews[index];
        CGAffineTransform transform = itemView.transform;
        itemView.transform = CGAffineTransformIdentity;
        itemView.frame = rect;
        itemView.layer.cornerRadius = CGRectGetWidth(rect) / 2;
        itemView.transform = transform;
        rect.origin.x += CGRectGetWidth(rect) + self.spacingBetweenColors;
    }
    CGSize contentSize = CGSizeZero;
    contentSize.width = numberOfColorsInRow * CGRectGetWidth(rect) + (numberOfColorsInRow - 1) * self.spacingBetweenColors;
    contentSize.height = CGRectGetHeight(self.bounds);
    _scrollView.contentSize = contentSize;
    _scrollView.frame = self.bounds;
}

- (void)setDataSource:(id<LMColorPickerViewDataSource>)dataSource {
    if (_dataSource == dataSource) {
        [self setNeedsLayout];
        return;
    }
    _dataSource = dataSource;
    [self reloadData];
}

- (void)reloadData {
    [_itemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_itemViews removeAllObjects];
    _selectedIndex = -1;
    if (!self.dataSource) {
        return;
    }
    for (NSInteger index = 0; index < self.numberOfColors; index++) {
        UIView *itemView = [[UIView alloc] init];
        itemView.transform = CGAffineTransformMakeScale(0.6, 0.6);
        itemView.backgroundColor = [self.dataSource lm_colorPickerView:self colorForItemAtIndex:index];
        [_scrollView addSubview:itemView];
        [_itemViews addObject:itemView];
    }
    [self setNeedsLayout];
}

- (NSInteger)numberOfColors {
    return [self.dataSource lm_numberOfColorsInColorPickerView:self];
}

#pragma mark - tap

- (void)handleTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:_scrollView];
    
    for (NSInteger index = 0; index < _itemViews.count; index++) {
        UIView *itemView = _itemViews[index];
        if (CGRectContainsPoint(itemView.frame, point)) {
            
            [self selectIndex:index];
            if ([self.delegate respondsToSelector:@selector(lm_colorPickerView:didSelectIndex:)]) {
                [self.delegate lm_colorPickerView:self didSelectIndex:index];
            }
            if ([self.delegate respondsToSelector:@selector(lm_colorPickerView:didSelectColor:)]) {
                [self.delegate lm_colorPickerView:self didSelectColor:itemView.backgroundColor];
            }
            break;
        }
    }
}

#pragma mark -

- (void)selectIndex:(NSInteger)index {
    
    if (_selectedIndex >= 0 && _selectedIndex < _itemViews.count) {
        UIView *lastSelectedView = _itemViews[_selectedIndex];
        lastSelectedView.transform = CGAffineTransformMakeScale(0.6, 0.6);
    }
    
    _selectedIndex = index;
    UIView *selectedLabel = _itemViews[_selectedIndex];
    selectedLabel.transform = CGAffineTransformMakeScale(1.f, 1.f);
}

@end

