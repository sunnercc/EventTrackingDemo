//
//  MyTableViewController.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/3/6.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "MyTableViewController.h"
#import "UITableView+logger.h"
#import <objc/runtime.h>

@interface MyTableViewController ()

@end

@implementation MyTableViewController
{
    int a;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    a = 10;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIdentifier"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", indexPath.row];
    return cell;
}

#pragma mark - delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelect: %ld", indexPath.row);
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didDeselect: %ld", indexPath.row);
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
