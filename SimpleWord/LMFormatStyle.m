//
//  LMFormatStyle.m
//  SimpleWord
//
//  Created by Chenly on 2016/12/19.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMFormatStyle.h"

@interface LMFormatStyle ()

@property (nonatomic, strong) id<LMFormatStyle> child;

@end

@implementation LMFormatStyle

- (instancetype)initWithType:(LMFormatType)type {
    
    if (self = [super init]) {
        NSArray *classNameOfStyles = @[
                                       @"LMFormatNormal",
                                       @"LMFormatBullets",
                                       @"LMFormatDashedLine",
                                       @"LMFormatNumber",
                                       @"LMFormatCheckbox"
                                       ];
        _child = [[NSClassFromString(classNameOfStyles[type]) alloc] init];
    }
    return self;
}

+ (instancetype)styleWithType:(LMFormatType)type {
    return [[LMFormatStyle alloc] initWithType:type];
}

- (CGFloat)indent {
    return [self.child indent];
}

- (CGFloat)paragraphSpacing {
    return [self.child indent];
}

- (UIView *)view {
    return [self.child view];
}

- (NSDictionary *)textAttributes {
    return [self.child textAttributes];
}

- (LMTextStyle *)textStyle {
    if ([self.child respondsToSelector:@selector(textStyle)]) {
        return [self.child textStyle];
    }
    return nil;
}

- (void)updateDisplayWithFormat:(LMFormat *)format {
    if ([self.child respondsToSelector:@selector(updateDisplayWithFormat:)]) {
        [self.child updateDisplayWithFormat:format];
    }
}

@end
