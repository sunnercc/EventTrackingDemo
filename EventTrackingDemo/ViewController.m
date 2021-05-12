//
//  ViewController.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/3/6.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong, getter=abctest) NSString *test;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, assign) float ccc;
@end

@implementation ViewController
{
//    int _a;
    @public
     long _b;
}

//+ (BOOL)accessInstanceVariablesDirectly {
//    return NO;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *butotn = [UIButton buttonWithType:UIButtonTypeCustom];
    butotn.frame = CGRectMake(100, 100, 100, 100);
    [butotn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    [butotn setTitle:@"click" forState:UIControlStateNormal];
    [butotn setTitleColor:UIColor.redColor forState:UIControlStateNormal];
    [self.view addSubview:butotn];
    self.button = butotn;
    
    
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(300, 300, 200, 200)];
    [switchView setOn:YES];
    [switchView addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:switchView];
    
//    _a = 10;
    _b = 12;
//    self.ccc = {};
    self.test = @"test name";
    
    long a = 10.242; // 精度丢失
    self.ccc = 10.242;
    
}

- (void)click:(UIButton *)button {
    [button valueForKey:@"gdsagdsa"];
}

- (void)switchChange:(UISwitch *)switchChange {
    NSLog(@"gedsag");
}


@end
