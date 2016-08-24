//
//  ViewController.m
//  SimpleWord
//
//  Created by Chenly on 16/5/12.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "ViewController.h"
#import "LMWordViewController.h"
#import "HTMLViewController.h"

@interface ViewController ()

@property (nonatomic, strong) LMWordViewController *wordViewController;
@property (nonatomic, strong) HTMLViewController *htmlViewController;
@property (nonatomic, weak) UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UIView *container;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self changeSegment:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.currentViewController.view.frame = self.container.bounds;
}

- (LMWordViewController *)wordViewController {
    
    if (!_wordViewController) {
        _wordViewController = [[LMWordViewController alloc] init];
    }
    return _wordViewController;
}

- (HTMLViewController *)htmlViewController {

    if (!_htmlViewController) {
        _htmlViewController = [[HTMLViewController alloc] init];
    }
    return _htmlViewController;
}

- (IBAction)changeSegment:(UISegmentedControl *)sender {
    
    if (self.currentViewController) {
        [self.currentViewController removeFromParentViewController];
        [self.currentViewController.view removeFromSuperview];
    }
    
    UIViewController *viewController = sender.selectedSegmentIndex == 0 ? self.wordViewController : self.htmlViewController;
    [self addChildViewController:viewController];
    [self.container addSubview:viewController.view];
    viewController.view.frame = self.container.bounds;
    
    if (sender.selectedSegmentIndex == 1) {
        [self.container endEditing:YES];
        self.htmlViewController.HTMLString = [self.wordViewController exportHTML];
    }
}

@end
