//
//  LMImagePreviewController.h
//  SimpleWord
//
//  Created by Chenly on 16/5/16.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMImagePreviewController;
@class PHAsset;

@protocol LMImagePreviewControllerDelegate <NSObject>

- (void)lm_previewController:(LMImagePreviewController *)previewController dismissPreviewWithCancel:(BOOL)cancel;

@end

@interface LMImagePreviewController : UIViewController

@property (nonatomic, weak) id<LMImagePreviewControllerDelegate> delegate;
@property (nonatomic, strong) PHAsset *asset;

@end
