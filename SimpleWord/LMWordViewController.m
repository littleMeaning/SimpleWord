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
#import "LMParagraph.h"

@interface LMWordViewController () <UITextViewDelegate, UITextFieldDelegate, LMSegmentedControlDelegate, LMFontInputDelegate, LMImageInputDelegate, LMFormatInputDelegate>

@property (nonatomic, readonly) UIStoryboard *lm_storyboard;

@property (nonatomic, assign) CGFloat keyboardSpacingHeight;
@property (nonatomic, assign) CGFloat inputViewHeight;
@property (nonatomic, strong) LMSegmentedControl *contentInputAccessoryView;

@property (nonatomic, strong) LMFontInputViewController   *fontInputController;
@property (nonatomic, strong) LMFormatInputViewController *formatInputController;
@property (nonatomic, strong) LMImageInputViewController  *imageInputController;

@property (nonatomic, strong) LMTextStyle *currentTextStyle;

@property (nonatomic, assign) NSRange lastSelectedRange;
@property (nonatomic, readonly) LMParagraph *currentParagraph;
@property (nonatomic, assign) BOOL keepCurrentTextStyle;

@end

@implementation LMWordViewController

#pragma mark - life cycle

- (void)setup {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    
    NSArray *items = @[
                       [UIImage imageNamed:@"ABC_icon"],
                       [UIImage imageNamed:@"style_icon"],
                       [UIImage imageNamed:@"img_icon"],
                       [UIImage imageNamed:@"swipe_rename"],
                       [UIImage imageNamed:@"clear_icon"]
                       ];
    _contentInputAccessoryView = [[LMSegmentedControl alloc] initWithItems:items];
    _contentInputAccessoryView.delegate = self;
    _contentInputAccessoryView.changeSegmentManually = YES;
    
    _textView = [[LMWordView alloc] init];
    _textView.delegate = self;
    _textView.titleTextField.delegate = self;
    _textView.typingAttributes = ({
        NSMutableDictionary *typingAttributes = [_textView.typingAttributes mutableCopy];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.paragraphSpacing = 4.f;
        typingAttributes[NSParagraphStyleAttributeName] = [paragraphStyle copy];
        typingAttributes;
    });
    [self.view addSubview:_textView];
    
//    [self setCurrentParagraphConfig:[[LMParagraphConfig alloc] init]];
//    [self setCurrentTextStyle:[LMTextStyle textStyleWithType:LMTextStyleFormatNormal]];
//    [self updateParagraphTypingAttributes];
    [self updateTextStyleTypingAttributes];
    
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
    rect.size.height -= rect.origin.y;
    self.textView.frame = rect;

    UIEdgeInsets insets = self.textView.contentInset;
    insets.bottom = self.keyboardSpacingHeight;
    self.textView.contentInset = insets;
}

#pragma mark - getter & setter

- (LMParagraph *)currentParagraph {
    return [self.textView paragraphAtLocation:self.textView.selectedRange.location];
}

- (void)setCurrentParagraph {
    // 设置 inputView 中当前段落风格的显示
//    [self.fontInputController setParagraph:self.currentParagraph];
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
    [self.imageInputController reload];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    _textView.inputAccessoryView = nil;
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    
    LMParagraph *paragraph = [self.textView paragraphAtLocation:self.textView.selectedRange.location];
    self.formatInputController.paragraph = paragraph;
    
//    if (self.lastSelectedRange.location != textView.selectedRange.location) {
//        
//        if (_keepCurrentTextStyle) {
//            // 如果当前行的内容为空，TextView 会自动使用上一行的 typingAttributes，所以在删除内容时，保持 typingAttributes 不变
//            [self updateTextStyleTypingAttributes];
//            [self updateParagraphTypingAttributes];
//            _keepCurrentTextStyle = NO;
//        }
//        else {
//            self.currentTextStyle = [self textStyleForSelection];
//            self.currentParagraphConfig = [self paragraphForSelection];
//            [self updateTextStyleTypingAttributes];
//            [self updateParagraphTypingAttributes];
//            [self reloadSettingsView];
//        }
//    }
}

static void(^__afterChangingText)(void);

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (range.location == 0 && range.length == 0 && text.length == 0 && self.textView.beginningParagraph != LMFormatTypeNormal) {
        // 光标在文本的起始位置输入退格键
        [self.textView setParagraphType:LMFormatTypeNormal forRange:range];
        [self setCurrentParagraph];
        self.lastSelectedRange = self.textView.selectedRange;
        [self setCurrentParagraph];
        return NO;
    }
    
    BOOL shouldChange = YES;
    NSString *replacedText = [textView.text substringWithRange:range];
    if ([text containsString:@"\n"] || [replacedText containsString:@"\n"]) {
        // 段落发生改变
        shouldChange = [self.textView changeTextInRange:range replacementText:text];
    }
    if (shouldChange) {
        __afterChangingText = ^{
            [self.textView didChangeTextInRange:range replacementText:text];
        };
    }
    else {
        [self setCurrentParagraph];
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
        _fontInputController.textStyle = self.currentTextStyle;
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
    rect.size.height = self.keyboardSpacingHeight - CGRectGetHeight(self.contentInputAccessoryView.frame);
    
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

// 刷新设置界面
- (void)reloadSettingsView {
    self.fontInputController.textStyle = self.currentTextStyle;
    [self.fontInputController reload];
}

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
    CGFloat width = CGRectGetWidth(self.textView.frame) - (self.textView.textContainerInset.left + self.textView.textContainerInset.right + 12.f);
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
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
    paragraphStyle.paragraphSpacingBefore = 8.f;
    paragraphStyle.paragraphSpacing = 8.f;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, attributedString.length)];
    
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

- (void)lm_didChangedParagraphType:(LMFormatType)type {
    [self.textView setParagraphType:type forRange:self.textView.selectedRange];
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

#pragma mark - export

- (NSString *)exportHTML {
    
    NSString *title = [NSString stringWithFormat:@"<h1 align=\"center\">%@</h1>", self.textView.titleTextField.text];
    NSString *content = [LMTextHTMLParser HTMLFromAttributedString:self.textView.attributedText];
    return [title stringByAppendingString:content];
}

@end
