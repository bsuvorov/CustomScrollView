//
//  AppleTableViewController.m
//  CustomScrollView
//
//  Created by Boris Suvorov on 1/24/15.
//  Copyright (c) 2015 Ole Begemann. All rights reserved.
//

#import "EmbeddedAppleTableViewController.h"
#import <POP.h>

typedef NS_ENUM(NSInteger, ScrollViewPanState) {
    ScrollViewPanStateInactive,
    ScrollViewPanStateScrollsDown,
    ScrollViewPanStateScrollsUp,
    ScrollViewPanStateContentPansDown,
    ScrollViewPanStateContentPansUp,
    
};

@interface EmbeddedAppleTableViewController () <UITableViewDataSource>
@property (nonatomic) ScrollViewPanState panState;
@property (nonatomic) UITableView *tableView;
@property (nonatomic) UIPanGestureRecognizer *panGesture;
@property (nonatomic) NSArray *data;
@end

@implementation EmbeddedAppleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];

    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.tableView.userInteractionEnabled = NO;
    
    self.data = [NSArray arrayWithObjects:@"George", @"Aniket", @"Peter", @"Diana", @"Millani", @"Angela", @"Ram", @"Piece", @"Swiss", @"Todododo", @"Clement", @"Shot Screen",
                 @"George", @"Aniket", @"Peter", @"Diana", @"Millani", @"Angela", @"Ram", @"Piece", @"Swiss", @"Todododo", @"Clement", @"Shot Screen",
                 nil];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [self.data objectAtIndex:indexPath.row];
    return cell;
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    
//    self.tableView.contentSize = self.view.bounds.size;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    CGRect bounds = self.tableView.bounds;
    bounds.origin.y -= translation.y;
    self.tableView.bounds = bounds;
    [self setTableViewBounds:bounds];
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
            CGRect frame = self.view.frame;
            frame.size.height -= self.view.frame.origin.y;
            frame.origin.y = 0;
            self.view.frame = frame;
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
        } else if (self.tableView.bounds.origin.y <= 0) {
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
        } else if(self.tableView.bounds.origin.y - translation.y < 0) {
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
            CGRect frame = self.view.frame;
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
            NSLog(@"Gesture started!");
            [self.view pop_removeAnimationForKey:@"bounce"];
            [self pop_removeAnimationForKey:@"decelerate"];
        }
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGestureRecognizer translationInView:self.tableView];
            
            // Reset the translation of the recognizer.
            [panGestureRecognizer setTranslation:CGPointZero inView:self.tableView];
            
            ScrollViewPanState newState = [self nextStateForState:self.panState translation:translation];
            [self changeUIForNewState:newState oldState:self.panState translation:translation];
            self.panState = newState;
        }
            
            break;
        case UIGestureRecognizerStateEnded:
        {
            NSLog(@"GESTURE ENDED!!!!!!!!!!!");
            self.panState = ScrollViewPanStateInactive;
            if (self.tableView.bounds.origin.y != 0) {
                CGPoint velocity = [panGestureRecognizer velocityInView:self.tableView];
            
                velocity.x = 0;
                velocity.y = -velocity.y;

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

- (POPAnimatableProperty *)boundsOriginProperty
{
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"com.rounak.bounds.origin" initializer:^(POPMutableAnimatableProperty *prop) {
        // read value
        prop.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [[obj tableView] bounds].origin.x;
            values[1] = [[obj tableView] bounds].origin.y;
        };
        // write value
        prop.writeBlock = ^(id obj, const CGFloat values[]) {
            CGRect tempBounds = [[obj tableView] bounds];
            tempBounds.origin.x = values[0];
            tempBounds.origin.y = values[1];
            [obj setTableViewBounds:tempBounds];
        };
        // dynamics threshold
        prop.threshold = 0.01;
    }];
    
    return prop;
}

- (void)setTableViewBounds:(CGRect)bounds
{
    self.tableView.bounds = bounds;
    
    BOOL outsideBoundsMinimum = bounds.origin.x < 0.0 || bounds.origin.y < 0.0;
    BOOL outsideBoundsMaximum = bounds.origin.x > self.tableView.contentSize.width - bounds.size.width ||
                                bounds.origin.y > self.tableView.contentSize.height - bounds.size.height;
    
    if (outsideBoundsMaximum || outsideBoundsMinimum) {
        POPDecayAnimation *decayAnimation = [self pop_animationForKey:@"decelerate"];
        if (decayAnimation) {
            CGPoint target = bounds.origin;
            if (outsideBoundsMinimum) {
                target.x = fmax(target.x, 0.0);
                target.y = fmax(target.y, 0.0);
            } else if (outsideBoundsMaximum) {
                target.x = fmin(target.x, self.tableView.contentSize.width - bounds.size.width);
                target.y = fmin(target.y, self.tableView.contentSize.height - bounds.size.height);
            }
            
            NSLog(@"bouncing with velocity: %@", decayAnimation.velocity);
            
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
