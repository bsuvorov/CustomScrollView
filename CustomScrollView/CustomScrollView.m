//
//  CustomScrollView.m
//  CustomScrollView
//
//  Created by Ole Begemann on 16.04.14.
//  Copyright (c) 2014 Ole Begemann. All rights reserved.
//

#import "CustomScrollView.h"
#import <POP.h>

typedef NS_ENUM(NSInteger, ScrollViewPanState) {
    ScrollViewPanStateInactive,
    ScrollViewPanStateScrollsDown,
    ScrollViewPanStateScrollsUp,
    ScrollViewPanStateContentPansDown,
    ScrollViewPanStateContentPansUp,
    
};

@interface CustomScrollView ()
@property CGRect startBounds;
@property (nonatomic) ScrollViewPanState panState;

@property (nonatomic) BOOL isDraggingSuperview;
@end

@implementation CustomScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil) {
        return nil;
    }
    
    [self commonInitForCustomScrollView];
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self == nil) {
        return nil;
    }
    
    [self commonInitForCustomScrollView];
    return self;
}

- (void)commonInitForCustomScrollView
{
    self.scrollHorizontal = YES;
    self.scrollVertical = YES;
    self.backgroundColor = [UIColor lightGrayColor];

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGestureRecognizer];
}

- (POPAnimatableProperty *)boundsOriginProperty
{
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"com.rounak.bounds.origin" initializer:^(POPMutableAnimatableProperty *prop) {
        // read value
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [obj bounds].origin.x;
            values[1] = [obj bounds].origin.y;
        };
        // write value
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            CGRect tempBounds = [obj bounds];
            tempBounds.origin.x = values[0];
            tempBounds.origin.y = values[1];
            [obj setBounds:tempBounds];
        };
        // dynamics threshold
        prop.threshold = 0.01;
    }];

    return prop;
}

- (void)moveContentViewFrameWithTranslation:(CGPoint)translation
{
    CGRect frame = self.superview.frame;
    frame.origin.y += translation.y;
    frame.size.height -= translation.y;
    self.superview.frame = frame;
}

- (void)scrollViewWithTranslation:(CGPoint)translation
{
    CGRect bounds = self.bounds;
    bounds.origin.y -= translation.y;
    self.bounds = bounds;
    
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
            CGRect frame = self.superview.frame;
            frame.size.height -= frame.origin.y;
            frame.origin.y = 0;
            self.superview.frame = frame;
        } else if (newState == ScrollViewPanStateScrollsDown) {
            [self moveContentViewFrameWithTranslation:translation];
        }
    }
}

- (ScrollViewPanState)nextStateForState:(ScrollViewPanState)oldState translation:(CGPoint)translation
{
    if (oldState == ScrollViewPanStateInactive) {
        if (translation.y <= 0) {
            return ScrollViewPanStateScrollsDown;
        } else if (self.bounds.origin.y <= 0) {
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
        } else if(self.bounds.origin.y - translation.y < 0) {
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
            CGRect frame = self.superview.frame;
            if (frame.origin.y + translation.y < 0) {
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
            [self pop_removeAnimationForKey:@"bounce"];
            [self pop_removeAnimationForKey:@"decelerate"];
            self.startBounds = self.bounds;
        }

        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGestureRecognizer translationInView:self];

            // Reset the translation of the recognizer.
            [panGestureRecognizer setTranslation:CGPointZero inView:self];
            
            ScrollViewPanState newState = [self nextStateForState:self.panState translation:translation];
            [self changeUIForNewState:newState oldState:self.panState translation:translation];
            self.panState = newState;
        }

            break;
        case UIGestureRecognizerStateEnded:
        {
            self.panState = ScrollViewPanStateInactive;
            if (self.bounds.origin.y != 0) {
                CGPoint velocity = [panGestureRecognizer velocityInView:self];
                
                if (!self.scrollHorizontal) {
                    velocity.x = 0.0;
                }
                if (!self.scrollVertical) {
                    velocity.y = 0.0;
                }
                
                velocity.x = -velocity.x;
                velocity.y = -velocity.y;
//            NSLog(@"decelerating with velocity: %@", NSStringFromCGPoint(velocity));
                
                POPDecayAnimation *decayAnimation = [POPDecayAnimation animation];
                decayAnimation.property = [self boundsOriginProperty];
                decayAnimation.velocity = [NSValue valueWithCGPoint:velocity];
                [self pop_addAnimation:decayAnimation forKey:@"decelerate"];
            }
        }
            break;

        default:
            break;
    }
    
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];

    

    BOOL outsideBoundsMinimum = bounds.origin.x < 0.0 || bounds.origin.y < 0.0;
    BOOL outsideBoundsMaximum = bounds.origin.x > self.contentSize.width - bounds.size.width || bounds.origin.y > self.contentSize.height - bounds.size.height;

//    NSLog(@"bounds.origin.y = %f, contentSize.height = %f, bounds.size.height = %f", bounds.origin.y, self.contentSize.height, bounds.size.height);
    
    if (outsideBoundsMaximum || outsideBoundsMinimum) {
        POPDecayAnimation *decayAnimation = [self pop_animationForKey:@"decelerate"];
        if (decayAnimation) {
            CGPoint target = bounds.origin;
            if (outsideBoundsMinimum) {
                target.x = fmax(target.x, 0.0);
                target.y = fmax(target.y, 0.0);
            } else if (outsideBoundsMaximum) {
                target.x = fmin(target.x, self.contentSize.width - bounds.size.width);
                target.y = fmin(target.y, self.contentSize.height - bounds.size.height);
            }

            NSLog(@"bouncing with velocity: %@", decayAnimation.velocity);

            POPSpringAnimation *springAnimation = [POPSpringAnimation animation];
            springAnimation.property = [self boundsOriginProperty];
            springAnimation.velocity = decayAnimation.velocity;
            springAnimation.toValue = [NSValue valueWithCGPoint:target];
            springAnimation.springBounciness = 0.0;
            springAnimation.springSpeed = 5.0;
            [self pop_addAnimation:springAnimation forKey:@"bounce"];

            [self pop_removeAnimationForKey:@"decelerate"];
        }
    }
}

@end
