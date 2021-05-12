//
//  GesViewController.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/3/7.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "GesViewController.h"

@interface GesViewController ()
@property (weak, nonatomic) IBOutlet UIView *gesView;
@end

@implementation GesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRec:)];
    [self.gesView addGestureRecognizer:tap];
}

- (void)tapRec:(UITapGestureRecognizer *)rec {
    NSLog(@"5875t8");
}

- (void)dealloc {
    NSLog(@"%s", __func__);
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
