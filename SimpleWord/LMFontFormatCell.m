//
//  LMFontFormatCell.m
//  SimpleWord
//
//  Created by Chenly on 2017/2/10.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import "LMFontFormatCell.h"
#import "LMTextStyle.h"

@interface LMFontFormatCell ()

@property (weak, nonatomic) IBOutlet UILabel *formatTitleLabel;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;

@property (nonatomic, weak) UIButton *selectedButton;

@end

@implementation LMFontFormatCell
{
    CAShapeLayer *_lineLayer;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (!_lineLayer) {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = [UIColor lightGrayColor].CGColor;
        shapeLayer.lineJoin = kCALineJoinRound;
        shapeLayer.lineDashPattern = @[@5, @2];
        shapeLayer.lineWidth = 1.f;
        _lineLayer = shapeLayer;
        [self.layer addSublayer:_lineLayer];
    }
    
    for (UIButton *button in self.buttons) {
        [button addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    if (!self.selected) {
        return;
    }
    
    CGRect layerFrame = rect;
    layerFrame.origin.x = 20.f;
    layerFrame.origin.y = 60.f;
    layerFrame.size.width -= 20.f * 2;
    layerFrame.size.height = 1.f;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0.5f)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(layerFrame), 0.5f)];
    _lineLayer.path = path.CGPath;
    _lineLayer.frame = layerFrame;
}

- (void)selectButton:(UIButton *)button {
    
    if (button == self.selectedButton) {
        return;
    }
    
    [self setSelectedIndex:[self.buttons indexOfObject:button]];
    
    LMFontFormat format = [self.buttons indexOfObject:button];
    [self.delegate lm_didChangeFontFormat:format];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    
    if (self.selectedButton) {
        self.selectedButton.selected = NO;
        self.selectedButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    }
    
    if (selectedIndex < 0) {
        self.selectedButton = nil;
        self.formatTitleLabel.text = @"普通";
    }
    else {
        self.selectedButton = self.buttons[selectedIndex];
        self.selectedButton.selected = YES;
        self.selectedButton.titleLabel.font = [UIFont systemFontOfSize:17.f];
        self.formatTitleLabel.text = [self.selectedButton titleForState:UIControlStateNormal];
    }
}

- (NSInteger)selectedIndex {
    if (!self.selectedButton) {
        return -1;
    }
    return [self.buttons indexOfObject:self.selectedButton];
}

@end
