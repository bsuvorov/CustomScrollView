//
//  ScrollDragDismissViewController.m
//  CustomScrollView
//
//  Created by Boris Suvorov on 1/25/15.
//  Copyright (c) 2015 Boris Suvorov. All rights reserved.
//

#import "ScrollDragDismissViewController.h"
#import <POP.h>

typedef NS_ENUM(NSInteger, ScrollViewPanState) {
    ScrollViewPanStateInactive,
    ScrollViewPanStateScrollsDown,
    ScrollViewPanStateScrollsUp,
    ScrollViewPanStateContentPansDown,
    ScrollViewPanStateContentPansUp,
    
};

#define kYOffsetToTriggerDismissal 50
#define kContentViewYOffset 20


@interface ScrollDragDismissViewController ()
@property (nonatomic) ScrollViewPanState panState;
@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) UIViewController <ScrollDragDismissProtocol> *contentVC;
@property (nonatomic) CGRect originalFrame;
@property (nonatomic) CGRect originalContentBounds;
@end

@implementation ScrollDragDismissViewController

- (instancetype)initWithContentViewController:(UIViewController <ScrollDragDismissProtocol> *)contentVC
{
    self = [super init];
    if (self) {
        self.contentVC = contentVC;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];

    [self.view addSubview:self.contentVC.view];

    [self.contentVC setScrollEnabled:NO];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.originalFrame = self.view.frame;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect frame = self.view.bounds;
    frame.origin.y += kContentViewYOffset;
    frame.size.height -= kContentViewYOffset;
    self.contentVC.view.frame = frame;
    
    
}

- (void)moveContentViewFrameWithTranslation:(CGPoint)translation
{
    CGRect frame = self.view.frame;
    frame.origin.y += translation.y;
    frame.size.height -= translation.y;
    self.view.frame = frame;
}

- (void)scrollViewWithTranslation:(CGPoint)translation
{
    CGRect bounds = self.contentVC.view.bounds;
    bounds.origin.y -= translation.y;
    self.contentVC.view.bounds = bounds;
    [self setContentViewBounds:bounds];
}

- (void)changeUIForNewState:(ScrollViewPanState)newState oldState:(ScrollViewPanState)oldState translation:(CGPoint)translation
{
    if (oldState == ScrollViewPanStateInactive) {
        if (newState == ScrollViewPanStateScrollsDown || newState == ScrollViewPanStateScrollsUp) {
            [self scrollViewWithTranslation:translation];
        } else if (newState == ScrollViewPanStateContentPansDown){
            [self moveContentViewFrameWithTranslation:translation];
        }
    } else if (oldState == ScrollViewPanStateScrollsDown) {
        [self scrollViewWithTranslation:translation];
    } else if (oldState == ScrollViewPanStateScrollsUp) {
        if (newState == ScrollViewPanStateContentPansDown) {
            [self moveContentViewFrameWithTranslation:translation];
        } else {
            [self scrollViewWithTranslation:translation];
        }
    } else if (oldState == ScrollViewPanStateContentPansDown) {
        [self moveContentViewFrameWithTranslation:translation];
        
    } else if (oldState == ScrollViewPanStateContentPansUp) {
        if (newState == ScrollViewPanStateContentPansUp) {
            [self moveContentViewFrameWithTranslation:translation];
        } else if (newState == ScrollViewPanStateScrollsUp) {
            self.view.frame = self.originalFrame;
        } else if (newState == ScrollViewPanStateScrollsDown) {
            [self moveContentViewFrameWithTranslation:translation];
        }
    }
}

- (CGFloat)deltaFromOriginalYOrigin
{
    return (self.view.frame.origin.y - self.originalFrame.origin.y
            );
}

- (ScrollViewPanState)nextStateForState:(ScrollViewPanState)oldState translation:(CGPoint)translation
{
    if (oldState == ScrollViewPanStateInactive) {
        if (translation.y <= 0) {
            return ScrollViewPanStateScrollsDown;
        } else if (self.contentVC.view.bounds.origin.y <= 0) {
            return ScrollViewPanStateContentPansDown;
        } else {
            return ScrollViewPanStateScrollsUp;
        }
    } else if (oldState == ScrollViewPanStateScrollsDown) {
        if (translation.y <= 0) {
            return ScrollViewPanStateScrollsDown;
        } else {
            return ScrollViewPanStateScrollsUp;
        }
    } else if (oldState == ScrollViewPanStateScrollsUp) {
        if (translation.y <= 0) {
            return ScrollViewPanStateScrollsDown;
        } else if(self.contentVC.view.bounds.origin.y - translation.y < 0) {
            return ScrollViewPanStateContentPansDown;
        } else {
            return ScrollViewPanStateScrollsUp;
        }
    } else if (oldState == ScrollViewPanStateContentPansDown) {
        if (translation.y < 0) {
            return ScrollViewPanStateContentPansUp;
        } else {
            return ScrollViewPanStateContentPansDown;
        }
    } else if (oldState == ScrollViewPanStateContentPansUp) {
        if (translation.y < 0) {
            if ([self deltaFromOriginalYOrigin] + translation.y < 0) {
                return ScrollViewPanStateScrollsUp;
            } else {
                return ScrollViewPanStateContentPansUp;
            }
        } else {
            return ScrollViewPanStateContentPansDown;
        }
    }
    
    return ScrollViewPanStateInactive;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSLog(@"Gesture started!");
            [self pop_removeAnimationForKey:@"bounce"];
            [self pop_removeAnimationForKey:@"decelerate"];
        }
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGestureRecognizer translationInView:self.contentVC.view];
            
            // Reset the translation of the recognizer.
            [panGestureRecognizer setTranslation:CGPointZero inView:self.contentVC.view];
            
            ScrollViewPanState newState = [self nextStateForState:self.panState translation:translation];
            [self changeUIForNewState:newState oldState:self.panState translation:translation];
            self.panState = newState;
        }
            
            break;
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"GESTURE ENDED!!!!!!!!!!!");
            self.panState = ScrollViewPanStateInactive;
            if (self.contentVC.view.bounds.origin.y != 0) {
                CGPoint velocity = [panGestureRecognizer velocityInView:self.contentVC.view];
                
                velocity.x = 0;
                velocity.y = -velocity.y;
                
                POPDecayAnimation *decayAnimation = [POPDecayAnimation animation];
                decayAnimation.property = [self boundsOriginProperty];
                decayAnimation.velocity = [NSValue valueWithCGPoint:velocity];
                [self pop_addAnimation:decayAnimation forKey:@"decelerate"];
            }
            
            if ([self deltaFromOriginalYOrigin] > kYOffsetToTriggerDismissal) {
                [self dismissVC];
            } else if ([self deltaFromOriginalYOrigin] > 0) {
                [self pop_removeAllAnimations];
                
                CGPoint target = self.originalFrame.origin;

                POPSpringAnimation *springAnimation = [POPSpringAnimation animation];
                springAnimation.property = [self frameOriginProperty];
                springAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(0, 50.0)];
                springAnimation.toValue = [NSValue valueWithCGPoint:target];
                springAnimation.springBounciness = 1;
                springAnimation.springSpeed = 50.0;
                
                [self pop_addAnimation:springAnimation forKey:@"bounce"];
            }
        }
            break;
            
        default:
            break;
    }
    
}

- (POPAnimatableProperty *)frameOriginProperty
{
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"com.bsuvorov.frame.origin" initializer:^(POPMutableAnimatableProperty *prop) {
        // read value
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [[obj view] frame].origin.x;
            values[1] = [[obj view] frame].origin.y;
        };
        // write value
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            CGRect tempFrame = [[obj view] frame];
            tempFrame.origin.x = values[0];
            tempFrame.origin.y = values[1];
            tempFrame.size.height = self.originalFrame.size.height - (tempFrame.origin.y - self.originalFrame.origin.y);

            [[obj view] setFrame:tempFrame];
        };
        // dynamics threshold
        prop.threshold = 0.01;
    }];
    
    return prop;
}


- (POPAnimatableProperty *)boundsOriginProperty
{
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"com.rounak.bounds.origin" initializer:^(POPMutableAnimatableProperty *prop) {
        // read value
        prop.readBlock = ^(id obj, CGFloat values[]) {
            CGRect bounds = [[[obj contentVC] view] bounds];
            
            values[0] = bounds.origin.x;
            values[1] = bounds.origin.y;
        };
        // write value
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            CGRect tempBounds = [[[obj contentVC] view] bounds];;
            tempBounds.origin.x = values[0];
            tempBounds.origin.y = values[1];
            [obj setContentViewBounds:tempBounds];
        };
        // dynamics threshold
        prop.threshold = 0.01;
    }];
    
    return prop;
}

- (void)dismissVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setContentViewBounds:(CGRect)bounds
{
    self.contentVC.view.bounds = bounds;
    
    NSLog(@"Settin bounds origin (%f, %f), width = %f, height = %f",
          bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
    
    CGSize contentSize = [self.contentVC contentSize];
    
    BOOL outsideBoundsMinimum = bounds.origin.x < 0.0 || bounds.origin.y < 0.0;
    BOOL outsideBoundsMaximum = bounds.origin.x > contentSize.width - bounds.size.width ||
    bounds.origin.y > contentSize.height - bounds.size.height;
    
    if (outsideBoundsMaximum || outsideBoundsMinimum) {
        POPDecayAnimation *decayAnimation = [self pop_animationForKey:@"decelerate"];
        if (decayAnimation) {
            CGPoint target = bounds.origin;
            if (outsideBoundsMinimum) {
                target.x = fmax(target.x, 0.0);
                target.y = fmax(target.y, 0.0);
            } else if (outsideBoundsMaximum) {
                target.x = fmin(target.x, contentSize.width - bounds.size.width);
                target.y = fmin(target.y, contentSize.height - bounds.size.height);
            }
                      
            POPSpringAnimation *springAnimation = [POPSpringAnimation animation];
            springAnimation.property = [self boundsOriginProperty];
            springAnimation.velocity = decayAnimation.velocity;
            springAnimation.toValue = [NSValue valueWithCGPoint:target];
            springAnimation.springBounciness = 0.1;
            springAnimation.springSpeed = 5.0;
            [self pop_addAnimation:springAnimation forKey:@"bounce"];
            
            [self pop_removeAnimationForKey:@"decelerate"];
        }
    }
}


@end
