//
//  LMPhotoCollectionCell.m
//  SimpleWord
//
//  Created by Chenly on 16/5/16.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMPhotoCollectionCell.h"

@interface LMPhotoCollectionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;

@end

@implementation LMPhotoCollectionCell

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.selectedImageView.hidden = !selected;
}

@end
