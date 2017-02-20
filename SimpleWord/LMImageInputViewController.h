//
//  LMImageInputViewController.h
//  SimpleWord
//
//  Created by Chenly on 16/5/16.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LMImageInputViewController;

@protocol LMImageInputDelegate <NSObject>

- (void)lm_imageInputViewController:(LMImageInputViewController *)viewController presentPreview:(UIViewController *)previewController;
- (void)lm_imageInputViewController:(LMImageInputViewController *)viewController insertImage:(UIImage *)image;

- (void)lm_imageInputViewController:(LMImageInputViewController *)viewController presentImagePickerView:(UIViewController *)picker;
//- (void)lm_imageInputViewController:(LMImageInputViewController *)viewController dismissImagePickerView:(UIViewController *)picker;

@end

@interface LMImageInputViewController : UIViewController

@property (nonatomic, weak) id<LMImageInputDelegate> delegate;
- (void)reload;

@end
