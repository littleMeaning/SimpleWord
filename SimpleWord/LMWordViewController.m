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
#import "LMFontInputViewController.h"
#import "LMImageInputViewController.h"
#import "LMFormatInputViewController.h"
#import "LMTextStyle.h"
#import "NSTextAttachment+LMText.h"
#import "UIFont+LMText.h"
#import "LMTextHTMLParser.h"
#import "LMFormat.h"
#import "LMFormatNormal.h"

@interface LMWordViewController () <UITextViewDelegate, UITextFieldDelegate, LMSegmentedControlDelegate, LMFontInputDelegate, LMImageInputDelegate, LMFormatInputDelegate>

@property (nonatomic, readonly) UIStoryboard *lm_storyboard;

@property (nonatomic, assign) CGFloat keyboardSpacingHeight;
@property (nonatomic, assign) CGFloat inputViewHeight;
@property (nonatomic, strong) LMSegmentedControl *inputSegmentControl;

@property (nonatomic, strong) LMFontInputViewController   *fontInputController;
@property (nonatomic, strong) LMFormatInputViewController *formatInputController;
@property (nonatomic, strong) LMImageInputViewController  *imageInputController;

@property (nonatomic, readonly) LMFormat *currentFormat;
@property (nonatomic, strong) LMTextStyle *currentTextStyle;

@property (nonatomic, assign) NSRange lastSelectedRange;
@property (nonatomic, assign) BOOL keepCurrentTextStyle;

@end

@implementation LMWordViewController

@synthesize currentTextStyle = _currentTextStyle;

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.textView];
    [self updateTextStyleTypingAttributes];
    
    [self.inputSegmentControl addTarget:self
                                       action:@selector(changeTextInputView:)
                             forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self layoutTextView];
    
    CGRect rect = self.view.bounds;
    rect.size.height = 40.f;
    self.inputSegmentControl.frame = rect;
}

- (void)layoutTextView {
    CGRect rect = self.view.bounds;
    rect.origin.y = [self.topLayoutGuide length];
    rect.size.height -= rect.origin.y;
    self.textView.frame = rect;

    UIEdgeInsets insets = self.textView.contentInset;
    insets.bottom = self.keyboardSpacingHeight;
    self.textView.contentInset = insets;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - getter & setter

- (LMWordView *)textView {
    
    if (!_textView) {
        _textView = [[LMWordView alloc] init];
        _textView.delegate = self;
        _textView.titleTextField.delegate = self;
        _textView.typingAttributes = ({
            NSMutableDictionary *typingAttributes = [_textView.typingAttributes mutableCopy];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.paragraphSpacing = 4.f;
            typingAttributes[NSParagraphStyleAttributeName] = [style copy];
            typingAttributes;
        });
    }
    return _textView;
}

- (LMSegmentedControl *)inputSegmentControl {

    if (!_inputSegmentControl) {
        
        NSArray *items = @[
                           [UIImage imageNamed:@"ABC_icon"],
                           [UIImage imageNamed:@"style_icon"],
                           [UIImage imageNamed:@"img_icon"],
                           [UIImage imageNamed:@"format_icon"],
                           [UIImage imageNamed:@"clear_icon"]
                           ];
        _inputSegmentControl = [[LMSegmentedControl alloc] initWithItems:items];
        _inputSegmentControl.delegate = self;
    }
    return _inputSegmentControl;
}

- (LMFormat *)currentFormat {
    return [self.textView formatAtLocation:self.textView.selectedRange.location];
}

- (LMTextStyle *)currentTextStyle {
    if (self.currentFormat.type == LMFormatTypeNormal) {
        return self.currentFormat.style.textStyle;
    }
    return nil;
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
    [self.inputSegmentControl setSelectedSegmentIndex:0 animated:NO];
    _textView.inputAccessoryView = self.inputSegmentControl;
    [self.imageInputController reload];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    _textView.inputAccessoryView = nil;
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    LMFormat *format = [self.textView formatAtLocation:self.textView.selectedRange.location];
    self.formatInputController.format = format;
    [self didFormatChange:format.type];
}

static void(^__afterChangingText)(void);

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.location == 0 && range.length == 0 && text.length == 0 && self.textView.beginningFormat != LMFormatTypeNormal) {
        // 光标在文本的起始位置输入退格键
        [self.textView setFormatWithType:LMFormatTypeNormal forRange:range];
        self.lastSelectedRange = self.textView.selectedRange;
        return NO;
    }
    
    BOOL shouldChange = YES;
    NSString *replacedText = [textView.text substringWithRange:range];
    if ([text containsString:@"\n"] || [replacedText containsString:@"\n"]) {
        // 段落发生改变
        shouldChange = [self.textView changeTextInRange:range replacementText:text];
    }
    if (shouldChange) {
        if (self.currentTextStyle) {
            [LMTextStyle setupAppearanceWithInstance:self.currentTextStyle];
        }
        __afterChangingText = ^{
            [self.textView didChangeTextInRange:range replacementText:text];
        };
    }
    self.lastSelectedRange = self.textView.selectedRange;
    return shouldChange;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (__afterChangingText) {
        __afterChangingText();
        __afterChangingText = nil;
    }
}

#pragma mark - InputView

- (LMFontInputViewController *)fontInputController {

    if (!_fontInputController) {
        _fontInputController = [self.lm_storyboard instantiateViewControllerWithIdentifier:@"style"];
        _fontInputController.delegate = self;
    }
    return _fontInputController;
}

- (LMImageInputViewController *)imageInputController {

    if (!_imageInputController) {
        _imageInputController = [self.lm_storyboard instantiateViewControllerWithIdentifier:@"image"];
        _imageInputController.delegate = self;
    }
    return _imageInputController;
}

- (LMFormatInputViewController *)formatInputController {
    
    if (!_formatInputController) {
        _formatInputController = [self.lm_storyboard instantiateViewControllerWithIdentifier:@"format"];
        _formatInputController.delegate = self;
    }
    return _formatInputController;
}

#pragma mark <LMSegmentedControlDelegate>

- (void)lm_segmentedControl:(LMSegmentedControl *)control didTapAtIndex:(NSInteger)index {
    
    if (index == control.numberOfSegments - 1) {
        [self.textView resignFirstResponder];
        return;
    }
    if (index != control.selectedSegmentIndex) {
        [control setSelectedSegmentIndex:index animated:YES];
        if (index == 1) {
            // Font
            self.fontInputController.textStyle = self.currentFormat.style.textStyle;
            [self.fontInputController reload];
        }
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

#pragma mark Change Input View

- (void)changeTextInputView:(LMSegmentedControl *)control {
    
    CGRect rect = self.view.bounds;
    rect.size.height = self.keyboardSpacingHeight - CGRectGetHeight(self.inputSegmentControl.frame);
    
    UIViewController *inputViewController = nil;
    switch (control.selectedSegmentIndex) {
        case 1:
            inputViewController = self.fontInputController;
            break;
        case 2:
            inputViewController = self.imageInputController;
            break;
        case 3:
            inputViewController = self.formatInputController;
            break;
        default:
            self.textView.inputView = nil;
            break;
    }
    if (inputViewController) {
        UIView *inputView = [[UIView alloc] initWithFrame:rect];
        inputViewController.view.frame = rect;
        [inputView addSubview:inputViewController.view];
        self.textView.inputView = inputView;
    }
    [self.textView reloadInputViews];
}

#pragma mark - Settings

- (LMTextStyle *)textStyleForSelection {
    LMTextStyle *textStyle = [[LMTextStyle alloc] init];
    UIFont *font = self.textView.typingAttributes[NSFontAttributeName];
    textStyle.bold = font.bold;
    textStyle.italic = font.italic;
    textStyle.fontSize = font.fontSize;
    textStyle.textColor = self.textView.typingAttributes[NSForegroundColorAttributeName] ?: textStyle.textColor;
    if (self.textView.typingAttributes[NSUnderlineStyleAttributeName]) {
        textStyle.underline = [self.textView.typingAttributes[NSUnderlineStyleAttributeName] integerValue] == NSUnderlineStyleSingle;
    }
    return textStyle;
}

- (void)updateTextStyleTypingAttributes {
    NSMutableDictionary *typingAttributes = [self.textView.typingAttributes mutableCopy];
    typingAttributes[NSFontAttributeName] = self.currentTextStyle.font;
    typingAttributes[NSForegroundColorAttributeName] = self.currentTextStyle.textColor;
    typingAttributes[NSUnderlineStyleAttributeName] = @(self.currentTextStyle.underline ? NSUnderlineStyleSingle : NSUnderlineStyleNone);
    self.textView.typingAttributes = typingAttributes;
}

- (void)updateTextStyleForSelection {
    if (self.textView.selectedRange.length > 0) {
        [self.textView.textStorage addAttributes:self.textView.typingAttributes range:self.textView.selectedRange];
    }
}

- (NSTextAttachment *)insertImage:(UIImage *)image {
    // textView 默认会有一些左右边距
//    CGFloat width = CGRectGetWidth(self.textView.frame) - (self.textView.textContainerInset.left + self.textView.textContainerInset.right + 12.f);
    NSTextAttachment *textAttachment;// = [NSTextAttachment attachmentWithImage:image width:width];
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:textAttachment];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"\n"];
    [attributedString insertAttributedString:attachmentString atIndex:0];
    if (self.lastSelectedRange.location != 0 &&
        ![[self.textView.text substringWithRange:NSMakeRange(self.lastSelectedRange.location - 1, 1)] isEqualToString:@"\n"]) {
        // 上一个字符不为"\n"则图片前添加一个换行 且 不是第一个位置
        [attributedString insertAttributedString:[[NSAttributedString alloc] initWithString:@"\n"] atIndex:0];
    }
    [attributedString addAttributes:self.textView.typingAttributes range:NSMakeRange(0, attributedString.length)];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    style.paragraphSpacingBefore = 8.f;
    style.paragraphSpacing = 8.f;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attributedString.length)];
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    [attributedText replaceCharactersInRange:self.lastSelectedRange withAttributedString:attributedString];
    self.textView.allowsEditingTextAttributes = YES;
    self.textView.attributedText = attributedText;
    self.textView.allowsEditingTextAttributes = NO;
    
    return textAttachment;
}

#pragma mark - <LMInputDelegates>

- (void)lm_didChangedTextStyle:(LMTextStyle *)textStyle {
    
    self.currentTextStyle = textStyle;
    [self updateTextStyleTypingAttributes];
    [self updateTextStyleForSelection];
}

- (void)lm_didChangedFormatWithType:(LMFormatType)type {
    
    [self.textView setFormatWithType:type forRange:self.textView.selectedRange];
    [self didFormatChange:type];
}

#pragma mark - <LMImageInputViewControllerDelegate>

- (void)lm_imageInputViewController:(LMImageInputViewController *)viewController presentPreview:(UIViewController *)previewController {
    [self presentViewController:previewController animated:YES completion:nil];
}

- (void)lm_imageInputViewController:(LMImageInputViewController *)viewController insertImage:(UIImage *)image {
    
    // 降低图片质量用于流畅显示，将原始图片存入到 Document 目录下，将图片文件 URL 与 Attachment 绑定。
    float actualWidth = image.size.width * image.scale;
    float boundsWidth = CGRectGetWidth(self.view.bounds) - 8.f * 2;
    float compressionQuality = boundsWidth / actualWidth;
    if (compressionQuality > 1) {
        compressionQuality = 1;
    }
    NSData *degradedImageData = UIImageJPEGRepresentation(image, compressionQuality);
    UIImage *degradedImage = [UIImage imageWithData:degradedImageData];
    
    NSTextAttachment *attachment = [self insertImage:degradedImage];
    [self.textView resignFirstResponder];
    [self.textView scrollRangeToVisible:self.lastSelectedRange];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 实际应用时候可以将存本地的操作改为上传到服务器，URL 也由本地路径改为服务器图片地址。
        NSURL *documentDir = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                    inDomain:NSUserDomainMask
                                                           appropriateForURL:nil
                                                                      create:NO
                                                                       error:nil];
        NSURL *filePath = [documentDir URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [NSDate date].description]];
        NSData *originImageData = UIImagePNGRepresentation(image);
        
        if ([originImageData writeToFile:filePath.path atomically:YES]) {
            attachment.attachmentType = LMTextAttachmentTypeImage;
            attachment.userInfo = filePath.absoluteString;
        }
    });
}

- (void)lm_imageInputViewController:(LMImageInputViewController *)viewController presentImagePickerView:(UIViewController *)picker {
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - private

- (void)didFormatChange:(LMFormatType)type {    
    // 仅段落格式为普通文本时候设置字体标签可用
    if (type == LMFormatTypeNormal) {
        [self.inputSegmentControl setEnable:YES forSegmentIndex:1];
    }
    else {
        [self.inputSegmentControl setEnable:NO forSegmentIndex:1];
    }
}

#pragma mark - export

- (NSString *)exportHTML {
    
    NSString *title = [NSString stringWithFormat:@"<h1 align=\"center\">%@</h1>", self.textView.titleTextField.text];
    NSString *content = [LMTextHTMLParser HTMLFromAttributedString:self.textView.attributedText];
    return [title stringByAppendingString:content];
}

@end
