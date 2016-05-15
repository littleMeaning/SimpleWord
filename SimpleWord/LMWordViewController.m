//
//  LMWordViewController.m
//  SimpleWord
//
//  Created by Chenly on 16/5/13.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMWordViewController.h"
#import "LMWordView.h"
#import "LMSegmentedControl.h"
#import "LMStyleSettingsController.h"
#import "LMTextStyle.h"

@interface LMWordViewController () <UITextViewDelegate, UITextFieldDelegate, LMSegmentedControlDelegate, NSTextStorageDelegate, NSLayoutManagerDelegate, LMStyleSettingsControllerDelegate>

@property (nonatomic, assign) CGFloat keyboardSpacingHeight;
@property (nonatomic, strong) LMSegmentedControl *contentInputAccessoryView;

@property (nonatomic, readonly) UIStoryboard *lm_storyboard;
@property (nonatomic, strong) LMStyleSettingsController *styleSettingsViewController;

@property (nonatomic, assign) CGFloat inputViewHeight;

@property (nonatomic, strong) NSMutableArray *textDatas;
@property (nonatomic, strong) LMTextStyle *currentTextStyle;

@end

@implementation LMWordViewController
{
    NSRange _lastInputRange;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self  = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
        _textDatas = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *items = @[
                       [UIImage imageNamed:@"ABC_icon"],
                       [UIImage imageNamed:@"style_icon"],
                       [UIImage imageNamed:@"img_icon"],
                       [UIImage imageNamed:@"@_icon"],
                       [UIImage imageNamed:@"comment_icon"],
                       [UIImage imageNamed:@"clear_icon"]
                       ];
    _contentInputAccessoryView = [[LMSegmentedControl alloc] initWithItems:items];
    _contentInputAccessoryView.delegate = self;
    _contentInputAccessoryView.changeSegmentManually = YES;
    
    _textView = [[LMWordView alloc] init];
    _textView.delegate = self;
    _textView.titleTextField.delegate = self;
    _textView.textStorage.delegate = self;
    _textView.textStorage.layoutManagers[0].delegate = self;
    [self.view addSubview:_textView];
    
    [self setCurrentTextStyle:[LMTextStyle textStyleWithType:LMTextStyleFormatNormal]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [_contentInputAccessoryView addTarget:self action:@selector(changeTextInputView:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self layoutTextView];
    
    CGRect rect = self.view.bounds;
    rect.size.height = 40.f;
    self.contentInputAccessoryView.frame = rect;
}

- (void)layoutTextView {
    CGRect rect = self.view.bounds;
    rect.origin.y = [self.topLayoutGuide length];
    rect.size.height -= (rect.origin.y + self.keyboardSpacingHeight);
    self.textView.frame = rect;
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    if (self.keyboardSpacingHeight == keyboardSize.height) {
        return;
    }
    self.keyboardSpacingHeight = keyboardSize.height;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self layoutTextView];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (self.keyboardSpacingHeight == 0) {
        return;
    }
    self.keyboardSpacingHeight = 0;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self layoutTextView];
    } completion:nil];
}

#pragma mark - <UITextViewDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 0) {
        textField.text = textField.placeholder;
    }
    self.textView.editable = NO;
    [textField resignFirstResponder];
    self.textView.editable = YES;
    return YES;
}

#pragma mark - <UITextViewDelegate>

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    [self.contentInputAccessoryView setSelectedSegmentIndex:0 animated:NO];
    _textView.inputAccessoryView = self.contentInputAccessoryView;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    _textView.inputAccessoryView = nil;
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {

    if (_lastInputRange.location != textView.selectedRange.location) {
        [self updateStyleSettings];
    }
    _lastInputRange = textView.selectedRange;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    _lastInputRange = NSMakeRange(range.location + text.length - range.length, 0);
    return YES;
}

//- (void)textViewDidChange:(UITextView *)textView {
//    
//    CGRect line = [textView caretRectForPosition:textView.selectedTextRange.start];
//    CGFloat overflow = line.origin.y + line.size.height - ( textView.contentOffset.y + textView.bounds.size.height - textView.contentInset.bottom - textView.contentInset.top );
//    if ( overflow > 0 ) {
//        // We are at the bottom of the visible text and introduced a line feed, scroll down (iOS 7 does not do it)
//        // Scroll caret to visible area
//        CGPoint offset = textView.contentOffset;
//        offset.y += overflow + 7; // leave 7 pixels margin
//        // Cannot animate with setContentOffset:animated: or caret will not appear
//        [UIView animateWithDuration:.2 animations:^{
//            [textView setContentOffset:offset];
//        }];
//    }
//}

#pragma mark - <NSTextStorageDelegate>

//- (void)textStorage:(NSTextStorage *)textStorage willProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta {
//    
//    NSLog(@"will: %ld, %@, %ld", editedMask, NSStringFromRange(editedRange), delta);
//}
//
//// Sent inside -processEditing right before notifying layout managers.  Delegates can change the attributes.
//- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta {
//    
//    if (editedMask == NSTextStorageEditedCharacters && editedRange.length == 1 && delta == 1) {
//        // 正在输入字符
//        
//    }
//    NSLog(@"did: %ld, %@, %ld", editedMask, NSStringFromRange(editedRange), delta);
//}

#pragma mark - 



#pragma mark - Change InputView

- (void)lm_segmentedControl:(LMSegmentedControl *)control didTapAtIndex:(NSInteger)index {
    
    if (index == control.numberOfSegments - 1) {
        [self.textView resignFirstResponder];
        return;
    }
    if (index != control.selectedSegmentIndex) {
        [control setSelectedSegmentIndex:index animated:YES];
    }
}

- (UIStoryboard *)lm_storyboard {
    static dispatch_once_t onceToken;
    static UIStoryboard *storyboard;
    dispatch_once(&onceToken, ^{
        storyboard = [UIStoryboard storyboardWithName:@"LMWord" bundle:nil];
    });
    return storyboard;
}

- (LMStyleSettingsController *)styleSettingsViewController {
    if (!_styleSettingsViewController) {
        _styleSettingsViewController = [self.lm_storyboard instantiateViewControllerWithIdentifier:@"style"];
        _styleSettingsViewController.textStyle = self.currentTextStyle;
        _styleSettingsViewController.delegate = self;
    }
    return _styleSettingsViewController;
}

- (void)changeTextInputView:(LMSegmentedControl *)control {
    
    CGRect rect = self.view.bounds;
    rect.size.height = self.keyboardSpacingHeight - CGRectGetHeight(self.contentInputAccessoryView.frame);
    switch (control.selectedSegmentIndex) {
        case 1:
        {
            UIView *inputView = [[UIView alloc] initWithFrame:rect];
            self.styleSettingsViewController.view.frame = rect;
            [inputView addSubview:self.styleSettingsViewController.view];
            self.textView.inputView = inputView;
            break;
        }
        default:
            self.textView.inputView = nil;
            break;
    }
    [self.textView reloadInputViews];
}

#pragma mark - textStyle

- (void)setCurrentTextStyle:(LMTextStyle *)currentTextStyle {
    _currentTextStyle = currentTextStyle;
    self.textView.typingAttributes = @{
                                       NSFontAttributeName: currentTextStyle.font,
                                       NSForegroundColorAttributeName: currentTextStyle.textColor,
                                       NSUnderlineStyleAttributeName: @(currentTextStyle.underline ? NSUnderlineStyleSingle : NSUnderlineStyleNone)
                                       };
}

- (void)updateStyleSettings {
    
    LMTextStyle *textStyle = [[LMTextStyle alloc] init];
    UIFont *font = self.textView.typingAttributes[NSFontAttributeName];
    NSDictionary<NSString *, id> *fontAttributes = font.fontDescriptor.fontAttributes;
    if (![font.fontName isEqualToString:[UIFont systemFontOfSize:15].fontName]) {
        // 通过fontName来判断粗体
        textStyle.bold = YES;
    }
    if (fontAttributes[@"NSCTFontMatrixAttribute"]) {
        // 通过是否包含 matrix 判断斜体
        textStyle.italic = YES;
    }
    textStyle.fontSize = [fontAttributes[@"NSFontSizeAttribute"] floatValue];
    textStyle.textColor = self.textView.typingAttributes[NSForegroundColorAttributeName] ?: textStyle.textColor;
    if (self.textView.typingAttributes[NSUnderlineStyleAttributeName]) {
        textStyle.underline = [self.textView.typingAttributes[NSUnderlineStyleAttributeName] integerValue] == NSUnderlineStyleSingle;
    }
    [self setCurrentTextStyle:textStyle];
    
    self.styleSettingsViewController.textStyle = self.currentTextStyle;
}

#pragma mark - <LMStyleSettingsControllerDelegate>

- (void)lm_didChangedTextStyle:(LMTextStyle *)textStyle {
    [self setCurrentTextStyle:textStyle];
    
    if (self.textView.selectedRange.length > 0) {
        [self.textView.textStorage addAttributes:self.textView.typingAttributes range:self.textView.selectedRange];
    }
}

@end
