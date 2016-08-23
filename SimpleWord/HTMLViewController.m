//
//  HTMLViewController.m
//  SimpleWord
//
//  Created by Chenly on 16/8/23.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "HTMLViewController.h"

@interface HTMLViewController ()

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation HTMLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView = ({
        UIWebView *webView = [[UIWebView alloc] init];
        [self.view addSubview:webView];
        webView;
    });
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    [self.webView loadHTMLString:self.HTMLString baseURL:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.webView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setHTMLString:(NSString *)HTMLString {

    _HTMLString = [HTMLString copy];
    if (self.webView) {
        [self.webView loadHTMLString:HTMLString baseURL:nil];
    }
}

@end
