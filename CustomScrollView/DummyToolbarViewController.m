//
//  DummyToolbarViewController.m
//  CustomScrollView
//
//  Created by Boris Suvorov on 1/25/15.
//  Copyright (c) 2015 Boris Suvorov. All rights reserved.
//

#import "DummyToolbarViewController.h"

@interface DummyToolbarViewController ()

@end

@implementation DummyToolbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentScrollDragAndRockNRollDismiss)];
    
    self.toolbarItems = [NSArray arrayWithObjects:barButton, nil];
    self.hidesBottomBarWhenPushed = NO;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)presentScrollDragAndRockNRollDismiss
{
    NSLog(@"Do something simple here");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
