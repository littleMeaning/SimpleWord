//
//  LMImageSettingsController.h
//  SimpleWord
//
//  Created by Chenly on 16/5/16.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMImageSettingsController;

@protocol LMImageSettingsControllerDelegate <NSObject>

- (void)lm_imageSettingsController:(LMImageSettingsController *)viewController presentPreview:(UIViewController *)previewController;
- (void)lm_imageSettingsController:(LMImageSettingsController *)viewController insertImage:(UIImage *)image;

- (void)lm_imageSettingsController:(LMImageSettingsController *)viewController presentImagePickerView:(UIViewController *)picker;
//- (void)lm_imageSettingsController:(LMImageSettingsController *)viewController dismissImagePickerView:(UIViewController *)picker;

@end

@interface LMImageSettingsController : UIViewController

@property (nonatomic, weak) id<LMImageSettingsControllerDelegate> delegate;
- (void)reload;

@end
