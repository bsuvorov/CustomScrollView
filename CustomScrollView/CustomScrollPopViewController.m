//
//  ViewController.m
//  CustomScrollView
//
//  Created by Ole Begemann on 16.04.14.
//  Copyright (c) 2014 Ole Begemann. All rights reserved.
//

#import "CustomScrollPopViewController.h"
#import "CustomScrollView.h"

@interface CustomScrollPopViewController ()

@property (nonatomic) CustomScrollView *customScrollView;

@end


@implementation CustomScrollPopViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGRect frame = self.view.bounds;
    frame.size.height -= 40;
    frame.origin.y += 40;
    
    UIView *borisView = [[UIView alloc] init];
    borisView.backgroundColor = [UIColor blackColor];
    borisView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 40);
   
    [self.view addSubview:borisView];
    
    self.customScrollView = [[CustomScrollView alloc] initWithFrame:frame];
    self.customScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 1000);
    self.customScrollView.scrollHorizontal = NO;
    self.customScrollView.clipsToBounds = YES;
    
    UIView *redView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 100, 100)];
    UIView *greenView = [[UIView alloc] initWithFrame:CGRectMake(150, 160, 150, 200)];
    UIView *blueView = [[UIView alloc] initWithFrame:CGRectMake(40, 400, 200, 150)];
    UIView *yellowView = [[UIView alloc] initWithFrame:CGRectMake(100, 600, 180, 150)];

    redView.backgroundColor = [UIColor colorWithRed:0.815 green:0.007 blue:0.105 alpha:1];
    greenView.backgroundColor = [UIColor colorWithRed:0.494 green:0.827 blue:0.129 alpha:1];
    blueView.backgroundColor = [UIColor colorWithRed:0.29 green:0.564 blue:0.886 alpha:1];
    yellowView.backgroundColor = [UIColor colorWithRed:0.972 green:0.905 blue:0.109 alpha:1];
    
    [self.customScrollView addSubview:redView];
    [self.customScrollView addSubview:greenView];
    [self.customScrollView addSubview:blueView];
    [self.customScrollView addSubview:yellowView];



    UIView *redView1 = [[UIView alloc] initWithFrame:CGRectMake(20, 500+20, 100, 100)];
    UIView *greenView1 = [[UIView alloc] initWithFrame:CGRectMake(150, 500+160, 150, 200)];
    UIView *blueView1 = [[UIView alloc] initWithFrame:CGRectMake(40, 500+400, 200, 150)];
    UIView *yellowView1 = [[UIView alloc] initWithFrame:CGRectMake(100, 500+600, 180, 150)];

    redView1.backgroundColor = [UIColor purpleColor];
    greenView1.backgroundColor = [UIColor redColor];
    blueView1.backgroundColor = [UIColor grayColor];
    yellowView1.backgroundColor = [UIColor blackColor];

    [self.customScrollView addSubview:redView1];
    [self.customScrollView addSubview:greenView1];
    [self.customScrollView addSubview:blueView1];
    [self.customScrollView addSubview:yellowView1];


    [self.view addSubview:self.customScrollView];
}

@end
