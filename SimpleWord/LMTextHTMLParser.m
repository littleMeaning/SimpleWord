//
//  LMTextHTMLParser.m
//  SimpleWord
//
//  Created by Chenly on 16/6/27.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMTextHTMLParser.h"
#import "UIFont+LMText.m"
#import "NSTextAttachment+LMText.h"

@implementation LMTextHTMLParser

/**
 *  将原生的 AttributedString 导出成 HTML，用于 Web 端显示，可以根据自己需求修改导出的 HTML 内容，比如添加 class 或是 id 等。
 *
 *  @param attributedString 需要被导出的富文本
 *
 *  @return 导出的 HTML
 */
+ (NSString *)HTMLFromAttributedString:(NSAttributedString *)attributedString {
    
    NSMutableString *htmlContent = [NSMutableString string];
    NSRange effectiveRange = NSMakeRange(0, 0);
    while (effectiveRange.location + effectiveRange.length < attributedString.length) {
        
        NSDictionary *attributes = [attributedString attributesAtIndex:effectiveRange.location effectiveRange:&effectiveRange];
        NSTextAttachment *attachment = attributes[@"NSAttachment"];
        if (attachment) {
            switch (attachment.attachmentType) {
                case LMTextAttachmentTypeImage:
                    [htmlContent appendString:[NSString stringWithFormat:@"<img src=\"%@\" width=\"100%%\"/>", attachment.userInfo]];
                    break;
                default:
                    break;
            }            
        }
        else {
            NSString *text = [[attributedString string] substringWithRange:effectiveRange];
            UIFont *font = attributes[NSFontAttributeName];
            UIColor *fontColor = attributes[@"NSColor"];
            NSString *color = [self hexStringWithColor:fontColor];
            BOOL underline = [attributes[NSUnderlineStyleAttributeName] boolValue];
            
            BOOL isFirst = YES;
            for (NSString *content in [text componentsSeparatedByString:@"\n"]) {
                if (!isFirst) {
                    [htmlContent appendString:@"<br>"];
                }
                [htmlContent appendString:[self HTMLWithContent:content font:font underline:underline color:color]];
                isFirst = NO;
            }
        }
        effectiveRange = NSMakeRange(effectiveRange.location + effectiveRange.length, 0);
    }
    return [htmlContent copy];
}

+ (NSString *)HTMLWithContent:(NSString *)content font:(UIFont *)font underline:(BOOL)underline color:(NSString *)color {

    if (font.bold) {
        content = [NSString stringWithFormat:@"<b>%@</b>", content];
    }
    if (font.italic) {
        content = [NSString stringWithFormat:@"<i>%@</i>", content];
    }
    if (underline) {
        content = [NSString stringWithFormat:@"<u>%@</u>", content];
    }
    return [NSString stringWithFormat:@"<font style=\"font-size:%f;color:%@\">%@</font>", font.fontSize, color, content];
}

+ (NSString *)hexStringWithColor:(UIColor *)color {

    NSString *colorString = [[CIColor colorWithCGColor:color.CGColor] stringRepresentation];
    NSArray *parts = [colorString componentsSeparatedByString:@" "];
    
    NSMutableString *hexString = [NSMutableString stringWithString:@"#"];
    for (int i = 0; i < 3; i ++) {
        [hexString appendString:[NSString stringWithFormat:@"%02X", (int)([parts[i] floatValue] * 255)]];
    }
    return [hexString copy];
}

@end
