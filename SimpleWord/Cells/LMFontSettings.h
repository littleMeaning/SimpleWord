//
//  LMFontSettings.h
//  SimpleWord
//
//  Created by Chenly on 16/5/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#ifndef LMFontSettings_h
#define LMFontSettings_h

static NSString * const LMFontSettingsBoldName = @"bold";
static NSString * const LMFontSettingsItalicName = @"italic";
static NSString * const LMFontSettingsUnderlineName = @"underline";
static NSString * const LMFontSettingsFontSizeName = @"fontSize";
static NSString * const LMFontSettingsTextColorName = @"textColor";
static NSString * const LMFontSettingsFormatName = @"format";

@protocol LMFontSettings <NSObject>

- (void)lm_didChangeStyleSettings:(NSDictionary *)settings;

@end

#endif /* LMFontSettings_h */
