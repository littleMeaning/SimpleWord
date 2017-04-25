//
//  LMFormatEventCenter.m
//  SimpleWord
//
//  Created by Chenly on 2017/3/26.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import "LMFormatManager.h"
#import "LMFormat.h"
#import "LMWordView.h"

@implementation LMFormatManager

+ (instancetype)sharedInstance {
    static LMFormatManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LMFormatManager alloc] init];
    });
    return instance;
}

- (void)inserFormats:(NSArray <LMFormat *> *)formats before:(LMFormat *)item {
    
    
}

- (void)inserFormats:(NSArray <LMFormat *> *)formats after:(LMFormat *)item {
    
    
}

- (void)removeFormats:(NSArray <LMFormat *> *)formats {
    
}

- (void)replaceFormats:(NSArray <LMFormat *> *)formats withReplacements:(NSArray <LMFormat *> *)replacements
{
    self.textView.scrollEnabled = NO; // 设置 scrollEnabled=NO 可以解决 exclusionPath 位置不准确的 bug
    // 去掉被删除的段落样式
    CGFloat offset = 0;
    for (LMFormat *replacement in formats) {
        offset -= replacement.height;
        [replacement restore];
    }
    // 新增段落链表关联
    LMFormat *before = formats.firstObject.previous;
    if (!before) {
        self.textView.beginningFormat = replacements.firstObject;
    }
    LMFormat *next = formats.lastObject.next;
    for (LMFormat *format in replacements) {
        format.previous = before;
        before.next = format;
        if (format == replacements.lastObject) {
            format.next = next;
            next.previous = format;
        }
        before = format;
    }
    // 新增段落格式化
    for (LMFormat *format in replacements) {
        [format format];
        offset += format.height;
    }
    // 调整后续段落位置
    LMFormat *end = replacements.lastObject;
    if (offset != 0) {
        LMFormat *item = end;
        while ((item = item.next)) {
            [item updateFrameWithYOffset:offset];
        }
    }
    // 如果是有序列表则需要重新编写序号
    [end updateDisplayRecursion];
    
    LMFormat *begin = formats.firstObject;
    self.textView.typingAttributes = begin.typingAttributes;
    self.textView.scrollEnabled = YES;
}

@end
