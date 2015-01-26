//
//  AppDelegate.m
//  CustomScrollView
//
//  Created by Ole Begemann on 16.04.14.
//  Copyright (c) 2014 Ole Begemann. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "AppleTableViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor purpleColor];
    
    ViewController *viewController = [[AppleTableViewController alloc] init];
//        ViewController *viewController = [[ViewController alloc] init];
    self.window.rootViewController = viewController;

    [self.window makeKeyAndVisible];
    return YES;
}

@end
