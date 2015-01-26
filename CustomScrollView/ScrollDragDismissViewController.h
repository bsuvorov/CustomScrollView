//
//  ScrollDragDismissViewController.h
//  CustomScrollView
//
//  Created by Boris Suvorov on 1/25/15.
//  Copyright (c) 2015 Boris Suvorov. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScrollDragDismissProtocol <NSObject>
- (void)setScrollEnabled:(BOOL)scrollEnabled;
- (CGSize)contentSize;
@end


@interface ScrollDragDismissViewController : UIViewController

- (instancetype)initWithContentViewController:(UIViewController <ScrollDragDismissProtocol> *)contentVC isPointingToBottom:(BOOL)isPointingDown;
@end
