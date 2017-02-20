//
//  LMFontInputViewController.m
//  SimpleWord
//
//  Created by Chenly on 2017/2/10.
//  Copyright © 2017年 Little Meaning. All rights reserved.
//

#import "LMFontInputViewController.h"
#import "LMFontStyleCell.h"
#import "LMFontSizeCell.h"
#import "LMFontColorCell.h"
#import "LMTextStyle.h"
#import "LMFontSettings.h"

@interface LMFontInputViewController () <LMFontSettings>

@property (nonatomic, weak) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) BOOL shouldScrollToSelectedRow;
@property (nonatomic, assign) BOOL needReload;

@end

@implementation LMFontInputViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)reload {}

#pragma mark - setTextStyle

- (void)setTextStyle:(LMTextStyle *)textStyle {
    _textStyle = textStyle;
    self.needReload = YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.textStyle) {
        return 0;
    }
    return 3;
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
            LMFontStyleCell *fontStyleCell = [tableView dequeueReusableCellWithIdentifier:@"fontStyle"];
            fontStyleCell.bold = self.textStyle.bold;
            fontStyleCell.italic = self.textStyle.italic;
            fontStyleCell.underline = self.textStyle.underline;
            fontStyleCell.delegate = self;
            cell = fontStyleCell;
            break;
        }
        case 1:
        {
            LMFontSizeCell *fontSizeCell = [tableView dequeueReusableCellWithIdentifier:@"fontSize"];
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
            LMFontColorCell *colorCell = [tableView dequeueReusableCellWithIdentifier:@"color"];
            colorCell.selectedColor = self.textStyle.textColor;
            colorCell.delegate = self;
            cell = colorCell;
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
    if (self.shouldScrollToSelectedRow && [indexPath isEqual:self.selectedIndexPath]) {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        self.shouldScrollToSelectedRow = NO;
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
    self.shouldScrollToSelectedRow = YES;
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - <LMFontSettings>

- (void)lm_didChangeStyleSettings:(NSDictionary *)settings {
    
    __block BOOL needReload = NO;
    [settings enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        
        if ([key isEqualToString:LMFontSettingsBoldName]) {
            self.textStyle.bold = [(NSNumber *)obj boolValue];
        }
        else if ([key isEqualToString:LMFontSettingsItalicName]) {
            self.textStyle.italic = [(NSNumber *)obj boolValue];
        }
        else if ([key isEqualToString:LMFontSettingsUnderlineName]) {
            self.textStyle.underline = [(NSNumber *)obj boolValue];
        }
        else if ([key isEqualToString:LMFontSettingsFontSizeName]) {
            self.textStyle.fontSize = [(NSNumber *)obj integerValue];
        }
        else if ([key isEqualToString:LMFontSettingsTextColorName]) {
            self.textStyle.textColor = obj;
        }
        else if ([key isEqualToString:LMFontSettingsFormatName]) {
            UIColor *textColor = self.textStyle.textColor;
            self.textStyle = [LMTextStyle textStyleWithFontFormat:[obj integerValue]];
            self.textStyle.textColor = textColor;
            needReload = YES;
        }
    }];
    if (needReload) {
        [self.tableView reloadData];
    }
    [self.delegate lm_didChangedTextStyle:self.textStyle];
}

@end
