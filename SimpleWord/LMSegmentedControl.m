//
//  LMSegmentedControl.m
//  SimpleWord
//
//  Created by Chenly on 16/5/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMSegmentedControl.h"

@interface LMSegmentedControl ()

@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, strong) UIView *slideBlockView;

@end

@implementation LMSegmentedControl

- (instancetype)initWithItems:(NSArray<UIImage *> *)items {

    if (self = [super init]) {
        
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        self.itemViews = [NSMutableArray array];
        [items enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
            
            UIButton *itemView = [[UIButton alloc] init];
            itemView.backgroundColor = [UIColor clearColor];
            itemView.imageView.contentMode = UIViewContentModeScaleAspectFit;
            itemView.tag = idx;
            [itemView setImage:image forState:UIControlStateNormal];
            [self addSubview:itemView];
            [self.itemViews addObject:itemView];
            
            [itemView addTarget:self action:@selector(itemAction:) forControlEvents:UIControlEventTouchUpInside];
        }];
        [self addSubview:self.slideBlockView];
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
    for (UIButton *itemView in _itemViews) {
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

#pragma mark - getter & setter

- (UIView *)slideBlockView {
    
    if (!_slideBlockView) {
        _slideBlockView = [[UIView alloc] init];
        _slideBlockView.backgroundColor = [UIColor darkGrayColor];
    }
    return _slideBlockView;
}

#pragma mark - action

- (void)itemAction:(UIControl *)item {

    NSInteger index = item.tag;
    if ([self.delegate respondsToSelector:@selector(lm_segmentedControl:didTapAtIndex:)]) {
        [self.delegate lm_segmentedControl:self didTapAtIndex:index];
    }
    [self setSelectedSegmentIndex:index animated:YES];
}

- (NSInteger)numberOfSegments {
    return self.itemViews.count;
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex animated:(BOOL)animated {
    
    if (_selectedSegmentIndex == selectedSegmentIndex) {
        return;
    }
    
    _selectedSegmentIndex = selectedSegmentIndex;
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutSubviews];
        }];
    }
    else {
        [self layoutSubviews];
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setEnable:(BOOL)enable forSegmentIndex:(NSUInteger)index {
    
    if (index >= self.itemViews.count) {
        return;
    }
    UIControl *itemView = self.itemViews[index];
    itemView.enabled = enable;
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
