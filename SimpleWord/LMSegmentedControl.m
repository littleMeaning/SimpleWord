//
//  LMSegmentedControl.m
//  SimpleWord
//
//  Created by Chenly on 16/5/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMSegmentedControl.h"

@implementation LMSegmentedControl
{
    NSMutableArray *_itemViews;
    UIView *_slideBlockView;
}

- (instancetype)initWithItems:(NSArray<UIImage *> *)items {
    if (self = [super init]) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        _itemViews = [NSMutableArray arrayWithCapacity:items.count];
        for (UIImage *itemImage in items) {
            UIImageView *itemView = [[UIImageView alloc] initWithImage:itemImage];
            itemView.contentMode = UIViewContentModeScaleAspectFit;
            [self addSubview:itemView];
            [_itemViews addObject:itemView];
        }
        _slideBlockView = [[UIView alloc] init];
        _slideBlockView.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:_slideBlockView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    CGFloat itemWidth = CGRectGetWidth(rect) / self.numberOfSegments;
    CGFloat itemHeight = CGRectGetHeight(rect) - 4.f;
    rect.size = CGSizeMake(itemWidth, itemHeight);
    rect.origin.y = 1.f;
    for (UIView *itemView in _itemViews) {
        itemView.frame = CGRectInset(rect, itemWidth / 4, itemHeight / 4);
        rect.origin.x += itemWidth;
    }
    rect.size.width = itemWidth - 20.f;
    rect.size.height = 2.f;
    rect.origin.y = CGRectGetHeight(self.bounds) - 3.f;
    UIView *selectedItemView = _itemViews[self.selectedSegmentIndex];
    rect.origin.x = selectedItemView.center.x - CGRectGetWidth(rect) / 2;
    _slideBlockView.frame = rect;
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self];
    CGFloat itemWidth = CGRectGetWidth(self.bounds) / self.numberOfSegments;
    NSInteger index = point.x / itemWidth;
    
    if ([self.delegate respondsToSelector:@selector(lm_segmentedControl:didTapAtIndex:)]) {
        [self.delegate lm_segmentedControl:self didTapAtIndex:index];
    }
    if (!self.changeSegmentManually) {
        [self setSelectedSegmentIndex:index animated:YES];
    }
}

- (NSInteger)numberOfSegments {
    return _itemViews.count;
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex animated:(BOOL)animated {
    
    if (_selectedSegmentIndex == selectedSegmentIndex) {
        return;
    }
    _selectedSegmentIndex = selectedSegmentIndex;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutSubviews];
        }];
    }
    else {
        [self setNeedsLayout];
    }
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0.5f)];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), 0.5f)];
    [path moveToPoint:CGPointMake(0, CGRectGetMaxY(rect) - 0.5f)];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect) - 0.5f)];
    path.lineWidth = 1.f;
    [[UIColor colorWithWhite:0.9 alpha:1.f] setStroke];
    [path stroke];
}

@end
