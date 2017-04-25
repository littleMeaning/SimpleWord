//
//  LMTextStyleController.m
//  SimpleWord
//
//  Created by Chenly on 16/5/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMStyleSettingsController.h"
#import "LMStyleFontStyleCell.h"
#import "LMStyleParagraphCell.h"
#import "LMStyleFontSizeCell.h"
#import "LMStyleColorCell.h"
#import "LMStyleFormatCell.h"
#import "LMTextStyle.h"
#import "LMParagraphConfig.h"

@interface LMStyleSettingsController () <LMStyleParagraphCellDelegate>

@property (nonatomic, weak) NSIndexPath *selectedIndexPath;

@end

@implementation LMStyleSettingsController
{
    BOOL _paragraphType;
    BOOL _shouldScrollToSelectedRow;
    BOOL _needReload;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_needReload) {
        [self reload];
    }
}

- (void)reload {
    [self.tableView reloadData];
    _needReload = NO;
}

#pragma mark - setTextStyle

- (void)setTextStyle:(LMTextStyle *)textStyle {
    _textStyle = textStyle;
    _needReload = YES;
}

#pragma mark - setParagraph

- (void)setParagraphConfig:(LMParagraphConfig *)paragraphConfig {
    _paragraphType = paragraphConfig.type;
    _needReload = YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.textStyle) {
        return 0;
    }
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([indexPath isEqual:self.selectedIndexPath]) {
        switch (indexPath.row) {
            case 2:
                return 120.f;
            case 3:
                return 180.f;
            case 4:
                return 120.f;
            default:
                break;
        }
    }
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    switch (indexPath.row) {
        case 0:
        {
            LMStyleFontStyleCell *fontStyleCell = [tableView dequeueReusableCellWithIdentifier:@"fontStyle"];
            fontStyleCell.bold = self.textStyle.bold;
            fontStyleCell.italic = self.textStyle.italic;
            fontStyleCell.underline = self.textStyle.underline;
            fontStyleCell.delegate = self;
            cell = fontStyleCell;
            break;
        }
        case 1:
        {
            LMStyleParagraphCell *prargraphCell = [tableView dequeueReusableCellWithIdentifier:@"paragraph"];
            prargraphCell.type = _paragraphType;
            prargraphCell.delegate = self;
            cell = prargraphCell;
            break;
        }
        case 2:
        {
            LMStyleFontSizeCell *fontSizeCell = [tableView dequeueReusableCellWithIdentifier:@"fontSize"];
            if (!fontSizeCell.fontSizeNumbers) {
                fontSizeCell.fontSizeNumbers = @[@9, @10, @11, @12, @14, @16, @18, @24, @30, @36];
                fontSizeCell.delegate = self;
            }
            fontSizeCell.currentFontSize = self.textStyle.fontSize;
            cell = fontSizeCell;
            break;
        }
        case 3:
        {
            LMStyleColorCell *colorCell = [tableView dequeueReusableCellWithIdentifier:@"color"];
            colorCell.selectedColor = self.textStyle.textColor;
            colorCell.delegate = self;
            cell = colorCell;
            break;
        }
        case 4:
        {
            LMStyleFormatCell *formatCell = [tableView dequeueReusableCellWithIdentifier:@"format"];
            formatCell.selectedIndex = (self.textStyle.type == 0) ? -1 : self.textStyle.type;
            formatCell.delegate = self;
            cell = formatCell;
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:self.selectedIndexPath]) {
        cell.selected = YES;
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (_shouldScrollToSelectedRow && [indexPath isEqual:self.selectedIndexPath]) {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        _shouldScrollToSelectedRow = NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    if ([indexPath isEqual:self.selectedIndexPath]) {
        self.selectedIndexPath = nil;
    }
    else {
        if (self.selectedIndexPath) {
            [indexPaths addObject:self.selectedIndexPath];
        }        
        self.selectedIndexPath = indexPath;
    }
    [indexPaths addObject:indexPath];
    _shouldScrollToSelectedRow = YES;
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - <LMStyleSettings>

- (void)lm_didChangeStyleSettings:(NSDictionary *)settings {
    
    __block BOOL needReload = NO;
    [settings enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if ([key isEqualToString:LMStyleSettingsBoldName]) {
            self.textStyle.bold = [(NSNumber *)obj boolValue];
        }
        else if ([key isEqualToString:LMStyleSettingsItalicName]) {
            self.textStyle.italic = [(NSNumber *)obj boolValue];
        }
        else if ([key isEqualToString:LMStyleSettingsUnderlineName]) {
            self.textStyle.underline = [(NSNumber *)obj boolValue];
        }
        else if ([key isEqualToString:LMStyleSettingsFontSizeName]) {
            self.textStyle.fontSize = [(NSNumber *)obj integerValue];
        }
        else if ([key isEqualToString:LMStyleSettingsTextColorName]) {
            self.textStyle.textColor = obj;
        }
        else if ([key isEqualToString:LMStyleSettingsFormatName]) {
            UIColor *textColor = self.textStyle.textColor;
            self.textStyle = [LMTextStyle textStyleWithType:[obj integerValue]];
            self.textStyle.textColor = textColor;
            needReload = YES;
        }
    }];
    if (needReload) {
        [self.tableView reloadData];
    }
    [self.delegate lm_didChangedTextStyle:self.textStyle];
}

- (void)lm_paragraphChangeIndentWithDirection:(LMStyleIndentDirection)direction {
    [self.delegate lm_didChangedParagraphIndentLevel:direction];
}

- (void)lm_paragraphChangeType:(NSInteger)type {
    [self.delegate lm_didChangedParagraphType:type];
}

@end
