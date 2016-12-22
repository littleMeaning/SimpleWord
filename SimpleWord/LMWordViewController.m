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
#import "LMImageSettingsController.h"
#import "LMTextStyle.h"
#import "LMParagraphConfig.h"
#import "NSTextAttachment+LMText.h"
#import "UIFont+LMText.h"
#import "LMTextHTMLParser.h"
#import "LMParagraph.h"
#import "LMParagraphStyle.h"

@interface LMWordViewController () <UITextViewDelegate, UITextFieldDelegate, LMSegmentedControlDelegate, LMStyleSettingsControllerDelegate, LMImageSettingsControllerDelegate>

@property (nonatomic, assign) CGFloat keyboardSpacingHeight;
@property (nonatomic, strong) LMSegmentedControl *contentInputAccessoryView;

@property (nonatomic, readonly) UIStoryboard *lm_storyboard;
@property (nonatomic, strong) LMStyleSettingsController *styleSettingsViewController;
@property (nonatomic, strong) LMImageSettingsController *imageSettingsViewController;


@property (nonatomic, assign) CGFloat inputViewHeight;

@property (nonatomic, strong) LMTextStyle *currentTextStyle;
@property (nonatomic, strong) LMParagraphConfig *currentParagraphConfig;

@property (nonatomic, assign) NSRange lastSelectedRange;
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
    _textView.typingAttributes = ({
        NSMutableDictionary *typingAttributes = [_textView.typingAttributes mutableCopy];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.paragraphSpacing = 4.f;
        typingAttributes[NSParagraphStyleAttributeName] = [paragraphStyle copy];
        typingAttributes;
    });
    [self.view addSubview:_textView];
    
//    [self setCurrentParagraphConfig:[[LMParagraphConfig alloc] init]];
    [self setCurrentTextStyle:[LMTextStyle textStyleWithType:LMTextStyleFormatNormal]];
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
    [self.imageSettingsViewController reload];
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    _textView.inputAccessoryView = nil;
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)textView {

//    if (self.lastSelectedRange.location != textView.selectedRange.location) {
//        
//        if (self.keepCurrentTextStyle) {
//            // 如果当前行的内容为空，TextView 会自动使用上一行的 typingAttributes，所以在删除内容时，保持 typingAttributes 不变
//            [self updateTextStyleTypingAttributes];
////            [self updateParagraphTypingAttributes];
//            self.keepCurrentTextStyle = NO;
//        }
//        else {
//            self.currentTextStyle = [self textStyleForSelection];
////            self.currentParagraphConfig = [self paragraphForSelection];
////            [self updateTextStyleTypingAttributes];
////            [self updateParagraphTypingAttributes];
//            [self reloadSettingsView];
//        }
//    }
//    self.lastSelectedRange = textView.selectedRange;
}

static BOOL __needUpdateParagraph = NO;
static LMParagraph *__paragraph;

- (void)updateParagrphs {
    
    BOOL needUpdate = NO;
    NSArray *ranges = [self.textView rangesOfParagraph];
    for (NSValue *rangeValue in ranges) {
        NSRange range = rangeValue.rangeValue;
        LMParagraph *paragraph = [self.textView.attributedText attribute:LMParagraphAttributeName
                                                                 atIndex:range.location
                                                          effectiveRange:NULL];
        if (paragraph == __paragraph) {
            needUpdate = YES;
        }
        paragraph.textRange = range;
        [paragraph updateForTextChanging];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    __paragraph = textView.typingAttributes[LMParagraphAttributeName];
    if ([text isEqualToString:@"\n"]) {
        __needUpdateParagraph = YES;
    }
    return YES;
//    NSString *replacedText = [textView.text substringWithRange:range];
//    LMParagraph *currentParagraph = [replacedText hasSuffix:@"\n"] ? nil : textView.typingAttributes[LMParagraphAttributeName];
//    
//    if ([replacedText containsString:@"\n"] || [text containsString:@"\n"]) {
//        // 包含 "\n" 表示段落有变化
//        if (range.length == 0 && [text isEqualToString:@"\n"]) {
//            
//            
//            if (currentParagraph) {
//                currentParagraph = [currentParagraph copy];
//                currentParagraph.textRange = NSMakeRange(range.location + 1, 0);
//                
//            }
//        }
//        
//        NSArray *ranges = [self rangesOfParagraphForRange:range];
//        NSAttributedString *attributedText = textView.attributedText;
//        for (NSValue *rangeValue in ranges) {
//            NSRange textRange = rangeValue.rangeValue;
//            LMParagraph *paragraph = [attributedText attribute:LMParagraphAttributeName
//                                                       atIndex:textRange.location
//                                                effectiveRange:nil];
//            
//        }
//    }
//    
//    if (range.location == 0 && range.length == 0 && text.length == 0) {
//        // 光标在第一个位置时，按下退格键，则删除段落设置
//        self.currentParagraphConfig.indentLevel = 0;
//        [self updateParagraphTypingAttributes];
//    }
//    self.lastSelectedRange = NSMakeRange(range.location + text.length - range.length, 0);
//    if (text.length == 0 && range.length > 0) {
//        self.keepCurrentTextStyle = YES;
//    }
//    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (__needUpdateParagraph) {
        
        LMParagraph *paragraph = [__paragraph copy];
        paragraph.textRange = textView.selectedRange;
        [paragraph addToTextViewIfNeed:textView];
        
        NSMutableDictionary *typingAttributes = [textView.typingAttributes mutableCopy];
        typingAttributes[LMParagraphAttributeName] = paragraph;
        textView.typingAttributes = typingAttributes;
        
        __needUpdateParagraph = NO;
    }
    else {
        NSMutableDictionary *typingAttributes = [textView.typingAttributes mutableCopy];
        typingAttributes[LMParagraphAttributeName] = __paragraph;
        textView.typingAttributes = typingAttributes;
        
        [self updateParagrphs];
    }
    __paragraph = nil;
}

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

- (LMImageSettingsController *)imageSettingsViewController {
    if (!_imageSettingsViewController) {
        _imageSettingsViewController = [self.lm_storyboard instantiateViewControllerWithIdentifier:@"image"];
        _imageSettingsViewController.delegate = self;
    }
    return _imageSettingsViewController;
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
        case 2:
        {
            UIView *inputView = [[UIView alloc] initWithFrame:rect];
            self.imageSettingsViewController.view.frame = rect;
            [inputView addSubview:self.imageSettingsViewController.view];
            self.textView.inputView = inputView;
            break;
        }
        default:
            self.textView.inputView = nil;
            break;
    }
    [self.textView reloadInputViews];
}

#pragma mark - settings

// 刷新设置界面
- (void)reloadSettingsView {
    
    self.styleSettingsViewController.textStyle = self.currentTextStyle;
//    [self.styleSettingsViewController setParagraphConfig:self.currentParagraphConfig];
    [self.styleSettingsViewController reload];
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

//- (LMParagraphConfig *)paragraphForSelection {
//    
//    NSParagraphStyle *paragraphStyle = self.textView.typingAttributes[NSParagraphStyleAttributeName];
//    LMParagraphType type = [self.textView.typingAttributes[LMParagraphTypeName] integerValue];
//    LMParagraphConfig *paragraphConfig = [[LMParagraphConfig alloc] initWithParagraphStyle:paragraphStyle type:type];
//    return paragraphConfig;
//}

// 获取所有选中的段落，通过"\n"来判断段落。
- (NSArray *)rangesOfParagraphForCurrentSelection {
    
    NSRange selection = self.textView.selectedRange;
    NSInteger location;
    NSInteger length;
    
    NSInteger start = 0;
    NSInteger end = selection.location;
    NSRange range = [self.textView.text rangeOfString:@"\n"
                                              options:NSBackwardsSearch
                                                range:NSMakeRange(start, end - start)];
    location = (range.location != NSNotFound) ? range.location + 1 : 0;
    
    start = selection.location + selection.length;
    end = self.textView.text.length;
    range = [self.textView.text rangeOfString:@"\n"
                                      options:0
                                        range:NSMakeRange(start, end - start)];
    length = (range.location != NSNotFound) ? (range.location + 1 - location) : (self.textView.text.length - location);
    
    range = NSMakeRange(location, length);
    NSString *textInRange = [self.textView.text substringWithRange:range];
    NSArray *components = [textInRange componentsSeparatedByString:@"\n"];
    
    NSMutableArray *ranges = [NSMutableArray array];
    for (NSInteger i = 0; i < components.count; i++) {
        NSString *component = components[i];
        if (i == components.count - 1) {
            if (component.length == 0) {
                break;
            }
            else {
                [ranges addObject:[NSValue valueWithRange:NSMakeRange(location, component.length)]];
            }
        }
        else {
            [ranges addObject:[NSValue valueWithRange:NSMakeRange(location, component.length + 1)]];
            location += component.length + 1;
        }
    }
    if (ranges.count == 0) {
        return nil;
    }
    return ranges;
}

- (void)updateTextStyleTypingAttributes {
    NSMutableDictionary *typingAttributes = [self.textView.typingAttributes mutableCopy];
    typingAttributes[NSFontAttributeName] = self.currentTextStyle.font;
    typingAttributes[NSForegroundColorAttributeName] = self.currentTextStyle.textColor;
    typingAttributes[NSUnderlineStyleAttributeName] = @(self.currentTextStyle.underline ? NSUnderlineStyleSingle : NSUnderlineStyleNone);
    self.textView.typingAttributes = typingAttributes;
}

//- (void)updateParagraphTypingAttributes {
//    NSMutableDictionary *typingAttributes = [self.textView.typingAttributes mutableCopy];
//    typingAttributes[LMParagraphTypeName] = @(self.currentParagraphConfig.type);
//    typingAttributes[NSParagraphStyleAttributeName] = self.currentParagraphConfig.paragraphStyle;
//    self.textView.typingAttributes = typingAttributes;
//}

- (void)updateTextStyleForSelection {
    if (self.textView.selectedRange.length > 0) {
        [self.textView.textStorage addAttributes:self.textView.typingAttributes range:self.textView.selectedRange];
    }
}

- (void)updateParagraphTypeForSelection {
    
    // 设置 exclusionPaths 会出现 exclusion 区域不正确的情况，加上 self.textView.scrollEnabled = NO; 后解决。
    self.textView.scrollEnabled = NO;
    NSRange selectedRange = self.textView.selectedRange;
    
    NSArray *ranges = [self rangesOfParagraphForCurrentSelection];
    for (NSValue *rangeValue in ranges) {
        
        NSRange range = NSMakeRange(rangeValue.rangeValue.location, rangeValue.rangeValue.length);
        LMParagraph *paragraph = [[LMParagraph alloc] initWithType:_paragraphType textRange:range];
        [paragraph addToTextViewIfNeed:self.textView];
        if (rangeValue == ranges.firstObject) {
            self.textView.typingAttributes = paragraph.typingAttributes;
        }
    }
    // 还原现场
    self.textView.scrollEnabled = YES;
    self.textView.selectedRange = selectedRange;
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

#pragma mark - <LMStyleSettingsControllerDelegate>

- (void)lm_didChangedTextStyle:(LMTextStyle *)textStyle {
    
    self.currentTextStyle = textStyle;
    [self updateTextStyleTypingAttributes];
    [self updateTextStyleForSelection];
}

//- (void)lm_didChangedParagraphIndentLevel:(NSInteger)level {
//    
//    self.currentParagraphConfig.indentLevel += level;
//    
//    NSRange selectedRange = self.textView.selectedRange;
//    NSArray *ranges = [self rangesOfParagraphForCurrentSelection];
//    if (ranges.count <= 1) {
////        [self updateParagraphForSelectionWithKey:LMParagraphIndentName];
//    }
//    else {
//        self.textView.allowsEditingTextAttributes = YES;
//        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
//        for (NSValue *rangeValue in ranges) {
//            NSRange range = rangeValue.rangeValue;
//            self.textView.selectedRange = range;
//            LMParagraphConfig *paragraphConfig = [self paragraphForSelection];
//            paragraphConfig.indentLevel += level;
//            [attributedText addAttribute:NSParagraphStyleAttributeName value:paragraphConfig.paragraphStyle range:range];
//        }
//        self.textView.attributedText = attributedText;
//        self.textView.allowsEditingTextAttributes = NO;
//        self.textView.selectedRange = selectedRange;
//    }
//    [self updateParagraphTypingAttributes];
//}

static NSInteger _paragraphType = 0;

- (void)lm_didChangedParagraphType:(NSInteger)type {

//    self.currentParagraphConfig.type = type;
//    [self updateParagraphTypingAttributes];
    _paragraphType = type;
    [self updateParagraphTypeForSelection];
}

#pragma mark - <LMImageSettingsControllerDelegate>

- (void)lm_imageSettingsController:(LMImageSettingsController *)viewController presentPreview:(UIViewController *)previewController {
    [self presentViewController:previewController animated:YES completion:nil];
}

- (void)lm_imageSettingsController:(LMImageSettingsController *)viewController insertImage:(UIImage *)image {
    
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

- (void)lm_imageSettingsController:(LMImageSettingsController *)viewController presentImagePickerView:(UIViewController *)picker {
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - export

- (NSString *)exportHTML {
    
    NSString *title = [NSString stringWithFormat:@"<h1 align=\"center\">%@</h1>", self.textView.titleTextField.text];
    NSString *content = [LMTextHTMLParser HTMLFromAttributedString:self.textView.attributedText];
    return [title stringByAppendingString:content];
}

@end
