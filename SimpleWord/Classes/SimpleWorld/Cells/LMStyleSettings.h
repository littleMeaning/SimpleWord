//
//  LMStyleSettings.h
//  SimpleWord
//
//  Created by Chenly on 16/5/15.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#ifndef LMStyleSettings_h
#define LMStyleSettings_h

static NSString * const LMStyleSettingsBoldName = @"bold";
static NSString * const LMStyleSettingsItalicName = @"italic";
static NSString * const LMStyleSettingsUnderlineName = @"underline";
static NSString * const LMStyleSettingsFontSizeName = @"fontSize";
static NSString * const LMStyleSettingsTextColorName = @"textColor";
static NSString * const LMStyleSettingsFormatName = @"format";

@protocol LMStyleSettings <NSObject>

- (void)lm_didChangeStyleSettings:(NSDictionary *)settings;

@end

#endif /* LMStyleSettings_h */
