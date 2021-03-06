//
//  UIViewController+logger.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/3/6.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "UIViewController+logger.h"
#import "ETHook.h"
#import "ETLogger.h"

@implementation UIViewController (logger)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL fromSelectorAppear = @selector(viewWillAppear:);
        SEL toSelectorAppear = @selector(hook_viewWillAppear:);
        [ETHook hookClass:self fromSelector:fromSelectorAppear toSelector:toSelectorAppear];
        
        SEL fromSelectorDisappear = @selector(viewWillDisappear:);
        SEL toSelectorDisappear = @selector(hook_viewWillDisappear:);
        [ETHook hookClass:self fromSelector:fromSelectorDisappear toSelector:toSelectorDisappear];
    });
}

- (void)hook_viewWillAppear:(BOOL)animated {
    [self insertToViewWillAppear];
    [self hook_viewWillAppear:animated];
}

- (void)hook_viewWillDisappear:(BOOL)animated {
    [self insertToViewWillDisappear];
    [self hook_viewWillDisappear:animated];
}

- (void)insertToViewWillAppear {
    [[ETLogger share] message:[NSString stringWithFormat:@"%@ Appear", NSStringFromClass([self class])] classify:@"page"];
}

- (void)insertToViewWillDisappear {
    [[ETLogger share] message:[NSString stringWithFormat:@"%@ Disappear", NSStringFromClass([self class])] classify:NSStringFromClass([self class])];
}

@end
