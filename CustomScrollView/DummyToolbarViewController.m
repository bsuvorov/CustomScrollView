//
//  DummyToolbarViewController.m
//  CustomScrollView
//
//  Created by Boris Suvorov on 1/25/15.
//  Copyright (c) 2015 Boris Suvorov. All rights reserved.
//

#import "DummyToolbarViewController.h"
#import "ScrollDragDismissViewController.h"

@interface DummyTableViewController : UITableViewController <ScrollDragDismissProtocol>
@property (nonatomic) NSArray *data;
@end


@interface DummyToolbarViewController ()
@property (nonatomic) NSArray *longList;
@end

@implementation DummyToolbarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.longList = [NSArray arrayWithObjects:@"George", @"Peter", @"Michael", @"Siong", @"Mallory", @"Eric", @"Cheryl", @"Leslie", @"Millani", @"Angela", @"Ram", @"Piece", @"Swiss", @"Todododo", @"Clement", @"Shot Screen", @"Screen shot", @"Albany", @"What did we learn", @"Not to do it again", @"But what did we do?", nil];

    
    UIBarButtonItem *barButtonRight = [[UIBarButtonItem alloc] initWithTitle:@"Long" style:UIBarButtonItemStylePlain target:self action:@selector(presentScrollDragAndDismiss)];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexibleItem, barButtonRight, nil];
}



- (void)presentScrollDragAndDismiss
{
    DummyTableViewController *dummyVC = [[DummyTableViewController alloc] init];
    dummyVC.data = self.longList;
    ScrollDragDismissViewController *sddVC = [[ScrollDragDismissViewController alloc] initWithContentViewController:dummyVC];
    
    [self addChildViewController:sddVC];
    [self.view addSubview:sddVC.view];
    
    sddVC.view.frame = CGRectMake(20,140,self.view.bounds.size.width-2*20,self.view.bounds.size.height-60-140);
}

@end


@implementation DummyTableViewController

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    self.tableView.scrollEnabled = scrollEnabled;
}

- (CGSize)contentSize
{
    return self.tableView.contentSize;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"Count = %ld",  (long)self.data.count);
    return self.data.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected indexPath =%@", indexPath);
}

- (void)setData:(NSArray *)data
{
    _data = data;
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [self.data objectAtIndex:indexPath.row];
    return cell;
}


@end
