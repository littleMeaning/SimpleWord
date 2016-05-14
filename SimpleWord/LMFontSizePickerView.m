//
//  LMFontSizePickerView.m
//  SimpleWord
//
//  Created by Chenly on 16/5/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMFontSizePickerView.h"

@interface LMFontSizePickerView () <UIScrollViewDelegate>

@end

@implementation LMFontSizePickerView
{
    UIScrollView *_scrollView;
    NSMutableArray *_itemViews;
    CAGradientLayer *_maskLayer;
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
    
    _normalFont = [UIFont systemFontOfSize:13.f];
    _selectedFont = [UIFont boldSystemFontOfSize:21.f];
    _normalTextColor = [UIColor grayColor];
    _selectedTextColor = [UIColor blackColor];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    
    _maskLayer = [CAGradientLayer layer];
    _maskLayer.colors = @[
                    (__bridge id)[UIColor clearColor].CGColor,
                    (__bridge id)[UIColor blackColor].CGColor,
                    (__bridge id)[UIColor blackColor].CGColor,
                    (__bridge id)[UIColor blackColor].CGColor,
                    (__bridge id)[UIColor clearColor].CGColor
                    ];
    _maskLayer.locations = @[@0, @0.25, @0.5, @0.75, @1];
    _maskLayer.startPoint = CGPointMake(0, 0);
    _maskLayer.endPoint = CGPointMake(1, 0);
    self.layer.mask = _maskLayer;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
    
    _itemViews = [NSMutableArray array];
    _selectedIndex = -1;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.origin = CGPointZero;
    rect.size.width = self.itemWidth == 0 ? CGRectGetWidth(rect) / 5 : self.itemWidth;
    for (NSInteger index = 0; index < _itemViews.count; index++) {
        UIView *subview = _itemViews[index];
        if (index == 0) {
            rect.origin.x -= CGRectGetWidth(rect) / 2;
        }
        subview.frame = rect;
        rect.origin.x += CGRectGetWidth(rect);
        if (index == _itemViews.count - 1) {
            rect.origin.x -= CGRectGetWidth(rect) / 2;
        }
    }
    CGFloat width = CGRectGetWidth(self.frame);
    _scrollView.contentSize = CGSizeMake(rect.origin.x, rect.size.height);
    _scrollView.contentInset = UIEdgeInsetsMake(0, width/2, 0, width/2);
    _scrollView.frame = self.bounds;
    _maskLayer.frame = self.bounds;
    
    if (_selectedIndex == -1 || _selectedIndex >= _itemViews.count) {
        [self selectIndex:0 animated:NO];
    }
    else {
        NSInteger index = _selectedIndex;
        _selectedIndex = -1;
        [self selectIndex:index animated:NO];
    }
}

- (void)setDataSource:(id<LMFontSizePickerViewDataSource>)dataSource {
    if (_dataSource == dataSource) {
        return;
    }
    _dataSource = dataSource;
    [self reloadData];
}

- (void)reloadData {
    [_itemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_itemViews removeAllObjects];
    if (!self.dataSource) {
        return;
    }
    
    for (NSInteger index = 0; index < self.numberOfItems; index++) {
        UILabel *itemView = [[UILabel alloc] init];
        itemView.text = [self.dataSource lm_pickerView:self titleForItemAtIndex:index];
        itemView.font = self.normalFont;
        itemView.textColor = self.normalTextColor;
        itemView.textAlignment = NSTextAlignmentCenter;
        [_scrollView addSubview:itemView];
        [_itemViews addObject:itemView];
    }
    [self setNeedsLayout];
}

- (NSInteger)numberOfItems {
    return [self.dataSource lm_numberOfItemsInPickerView:self];
}

#pragma mark - tap

- (void)handleTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:_scrollView];
    
    for (NSInteger index = 0; index < _itemViews.count; index++) {
        UILabel *label = _itemViews[index];
        if (CGRectContainsPoint(label.frame, point)) {
            if (index != _selectedIndex && [self.delegate respondsToSelector:@selector(lm_pickerView:didSelectIndex:)]) {
                [self selectIndex:index animated:YES];
                [self.delegate lm_pickerView:self didSelectIndex:index];
            }
            else {
                [self selectIndex:index animated:YES];
            }
            break;
        }
    }
}


#pragma mark - <UIScrollViewDelegate>

- (void)scrollEnd {
    CGPoint centerLocation = CGPointZero;
    centerLocation.x = _scrollView.contentOffset.x + CGRectGetWidth(self.bounds) / 2;
    
    for (NSInteger index = 0; index < _itemViews.count; index++) {
        UILabel *label = _itemViews[index];
        if ((index == 0 && centerLocation.x < CGRectGetMinX(label.frame)) ||
            (index == _itemViews.count - 1 && centerLocation.x > CGRectGetMaxX(label.frame)) ||
            CGRectContainsPoint(label.frame, centerLocation)) {
                        
            if (index != _selectedIndex && [self.delegate respondsToSelector:@selector(lm_pickerView:didSelectIndex:)]) {
                [self selectIndex:index animated:YES];
                [self.delegate lm_pickerView:self didSelectIndex:index];
            }
            else {
                [self selectIndex:index animated:YES];
            }
            break;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self scrollEnd];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollEnd];
}

#pragma mark - 

- (void)selectIndex:(NSInteger)index animated:(BOOL)animated {
    
    if (_selectedIndex >= 0 && _selectedIndex < _itemViews.count) {
        UILabel *lastSelectedLabel = _itemViews[_selectedIndex];
        lastSelectedLabel.textColor = self.normalTextColor;
        lastSelectedLabel.font = self.normalFont;
    }
    
    _selectedIndex = index;
    UILabel *selectedLabel = _itemViews[index];
    selectedLabel.textColor = self.selectedTextColor;
    selectedLabel.font = self.selectedFont;
    [_scrollView setContentOffset:CGPointMake(selectedLabel.center.x - CGRectGetWidth(self.bounds) / 2, 0) animated:animated];
}

@end
