//
//  LMParagraph.m
//  SimpleWord
//
//  Created by Chenly on 2016/12/21.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMParagraph.h"
#import "LMParagraphStyle.h"
#import "UIFont+LMText.h"
#import "LMParagraphCheckbox.h"

NSString * const LMParagraphAttributeName = @"LMParagraphAttributeName";

@implementation LMParagraph

- (instancetype)initWithType:(LMParagraphType)type textRange:(NSRange)textRange {
    if (self = [super init]) {
        _textRange = textRange;
        _type = type;
        _paragraphStyle = [[LMParagraphStyle alloc] initWithType:type];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[LMParagraph alloc] initWithType:self.type textRange:self.textRange];
}

- (NSDictionary *)typingAttributes {
    NSMutableDictionary *attributes = [[self.paragraphStyle textAttributes] mutableCopy];
    attributes[LMParagraphAttributeName] = self;
    return [attributes copy];
}

// 添加段落文本属性以适应当前段落样式
- (void)textAttributesToFit {
    NSMutableAttributedString *attributedText = [self.textView.attributedText mutableCopy];
    NSAttributedString *text = [self.textView.attributedText attributedSubstringFromRange:self.textRange];
    NSAttributedString *formattedText = [[NSAttributedString alloc] initWithString:text.string attributes:[self typingAttributes]];
    [attributedText replaceCharactersInRange:self.textRange withAttributedString:formattedText];
    
    self.textView.allowsEditingTextAttributes = YES;
    self.textView.attributedText = attributedText;
    self.textView.allowsEditingTextAttributes = NO;
}

// 将段落文本属性初始化
- (void)removeTextAttributes {
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont lm_systemFont],
                                 };
    NSMutableAttributedString *attributedText = [self.textView.attributedText mutableCopy];
    NSAttributedString *text = [self.textView.attributedText attributedSubstringFromRange:self.textRange];
    NSAttributedString *formattedText = [[NSAttributedString alloc] initWithString:text.string attributes:attributes];
    [attributedText replaceCharactersInRange:self.textRange withAttributedString:formattedText];
    
    self.textView.allowsEditingTextAttributes = YES;
    self.textView.attributedText = attributedText;
    self.textView.allowsEditingTextAttributes = NO;
}

- (void)addToTextViewIfNeed:(UITextView *)textView {
    
    if (!textView) {
        return;
    }
    
    self.textView = textView;
    [self textAttributesToFit];

    NSTextContainer *textContainer = self.textView.textContainer;
    NSLayoutManager *layoutManager = self.textView.layoutManager;
    UIEdgeInsets textContainerInset = self.textView.textContainerInset;
    
    CGRect rect = [layoutManager boundingRectForGlyphRange:self.textRange inTextContainer:textContainer];
    CGSize size = [self.paragraphStyle size];
    rect.size = size;
    
    // 在 TextView 中留出空白区域
    self.exclusionPath = [UIBezierPath bezierPathWithRect:rect];
    NSMutableArray *exclusionPaths = [textContainer.exclusionPaths mutableCopy];
    [exclusionPaths addObject:self.exclusionPath];
    textContainer.exclusionPaths = exclusionPaths;
    
    rect.origin.x += textContainerInset.left;
    rect.origin.y += textContainerInset.top;
    
    UIView *view = [self.paragraphStyle view];
    view.frame = rect;
    [self.textView addSubview:view];
}

- (void)removeFromTextView {
    
    if (!self.textView) {
        return;
    }
    [self.paragraphStyle.view removeFromSuperview];
    [self removeTextAttributes];
    
    NSMutableArray *exclusionPaths = [self.textView.textContainer.exclusionPaths mutableCopy];
    if ([exclusionPaths containsObject:self.exclusionPath]) {
        [exclusionPaths removeObject:self.exclusionPath];
        self.exclusionPath = nil;
    }
    self.textView.textContainer.exclusionPaths = exclusionPaths;
}

static CGFloat const kUITextViewDefaultEdgeSpacing = 5.f;

- (void)updateForTextChanging {
    
    NSTextContainer *textContainer = self.textView.textContainer;
    NSLayoutManager *layoutManager = self.textView.layoutManager;
    UIEdgeInsets textContainerInset = self.textView.textContainerInset;
    
    CGFloat boundingWidth = (textContainer.size.width - 3 * kUITextViewDefaultEdgeSpacing - self.paragraphStyle.size.width);
    NSAttributedString *attributedText = [self.textView.attributedText attributedSubstringFromRange:self.textRange];
    CGRect boundingRect = [attributedText boundingRectWithSize:CGSizeMake(boundingWidth, 0) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    NSInteger index = [textContainer.exclusionPaths indexOfObject:self.exclusionPath];
    
    CGFloat y = [layoutManager boundingRectForGlyphRange:NSMakeRange(self.textRange.location, 1) inTextContainer:textContainer].origin.y;
    
    UIView *view = [self.paragraphStyle view];
    CGRect rect = view.frame;
    rect.origin.y = y + textContainerInset.top;
    view.frame = rect;
    
    rect.origin.x -= textContainerInset.left;
    rect.origin.y = y;
    rect.size.height = boundingRect.size.height;
    
    self.exclusionPath = [UIBezierPath bezierPathWithRect:rect];
    NSMutableArray *exclusionPaths = [textContainer.exclusionPaths mutableCopy];
    [exclusionPaths replaceObjectAtIndex:index withObject:self.exclusionPath];
    textContainer.exclusionPaths = exclusionPaths;
}

@end

@implementation UITextView (LMParagraphStyle)

- (NSArray *)rangesOfParagraphForRange:(NSRange)selectedRange {
    
    NSInteger location;
    NSInteger length;
    
    NSInteger start = 0;
    NSInteger end = selectedRange.location;
    NSRange range = [self.text rangeOfString:@"\n"
                                              options:NSBackwardsSearch
                                                range:NSMakeRange(start, end - start)];
    location = (range.location != NSNotFound) ? range.location + 1 : 0;
    
    start = selectedRange.location + selectedRange.length;
    end = self.text.length;
    range = [self.text rangeOfString:@"\n"
                                      options:0
                                        range:NSMakeRange(start, end - start)];
    length = (range.location != NSNotFound) ? (range.location + 1 - location) : (self.text.length - location);
    
    range = NSMakeRange(location, length);
    NSString *textInRange = [self.text substringWithRange:range];
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

- (NSArray *)rangesOfParagraph {
    return [self rangesOfParagraphForRange:NSMakeRange(0, self.text.length)];
}

- (LMParagraphStyle *)lm_paragraphStyleForTextRange:(NSRange)textRange {
    return [self.attributedText attribute:LMParagraphAttributeName atIndex:textRange.location effectiveRange:NULL];
}

@end
