//
//  SampleSelectorTableViewController.m
//  CustomScrollView
//
//  Created by Boris Suvorov on 1/25/15.
//

#import "SampleSelectorTableViewController.h"
#import "CustomScrollView.h"

#import "CustomScrollPopViewController.h"
#import "EmbeddedAppleTableViewController.h"

@interface SampleSelectorTableViewController ()


@property (nonatomic) NSArray *sampleClassNames;

@end

@implementation SampleSelectorTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sampleClassNames = [NSArray arrayWithObjects:[EmbeddedAppleTableViewController class], [CustomScrollPopViewController class], nil];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sampleClassNames.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    Class genericClass = [self.sampleClassNames objectAtIndex:indexPath.row];
    cell.textLabel.text = NSStringFromClass(genericClass);
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class genericClass = [self.sampleClassNames objectAtIndex:indexPath.row];
    UIViewController *vc = (UIViewController *)[[genericClass alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
