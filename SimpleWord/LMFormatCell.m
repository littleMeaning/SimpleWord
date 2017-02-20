//
//  LMStyleFormatCell.m
//  SimpleWord
//
//  Created by Chenly on 16/5/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMFormatCell.h"
#import "LMTextStyle.h"

@interface LMFormatCell ()
@property (weak, nonatomic) IBOutlet UILabel *formatLabel;

@end

@implementation LMFormatCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];    
    self.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (void)setType:(LMFormatType)type {

    NSString *title;
    switch (type) {
        case LMFormatTypeNormal:
            title = @"普通";
            break;
        case LMFormatTypeBullets:
            title = @"● 项目符号列表";
            break;
        case LMFormatTypeDashedLine:
            title = @"- 短划线列表";
            break;
        case LMFormatTypeNumber:
            title = @"1. 编号列表";
            break;
        case LMFormatTypeCheckbox:
            title = @"检查框";
            break;
        default:
            break;
    }
    self.formatLabel.text = title;
}

@end
