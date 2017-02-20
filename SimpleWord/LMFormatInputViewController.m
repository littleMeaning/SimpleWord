//
//  LMTextStyleController.m
//  SimpleWord
//
//  Created by Chenly on 16/5/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "LMFormatInputViewController.h"
#import "LMFormatCell.h"
#import "LMParagraph.h"

@interface LMFormatInputViewController ()

@end

@implementation LMFormatInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    [self setSelectedRow];
}

- (void)setSelectedRow {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.paragraph.type inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - getter & setter

- (void)setParagraph:(LMParagraph *)paragraph {
    if (self.paragraph == paragraph) {
        return;
    }
    _paragraph = paragraph;
    [self setSelectedRow];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LMFormatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"format"];
    cell.type = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate lm_didChangedParagraphType:indexPath.row];
}

@end
