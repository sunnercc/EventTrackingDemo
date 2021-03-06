//
//  UITableView+logger.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/3/6.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "UITableView+logger.h"
#import "ETLogger.h"
#import "ETHook.h"
#import <objc/runtime.h>

@interface ETTableViewDelegateHook : NSObject <UITableViewDelegate>
@property (nonatomic, weak) id<UITableViewDelegate> delegate;
@end

@implementation ETTableViewDelegateHook

- (instancetype)initWithDelegate:(id<UITableViewDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self.delegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.delegate respondsToSelector:aSelector]) {
        return self.delegate;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *message= [NSString stringWithFormat:@"tableView:%@ didSelectRowAtIndexPath: %@", tableView, indexPath];
    [[ETLogger share] message:message classify:NSStringFromClass([self.delegate class])];
    [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}
// 需要拦截的代理方法，可以继续添加，例子如下：
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *message= [NSString stringWithFormat:@"tableView:%@ didDeselectRowAtIndexPath: %@", tableView, indexPath];
//    [[ETLogger share] message:message classify:NSStringFromClass([self class])];
//    [self.delegate tableView:tableView didDeselectRowAtIndexPath:indexPath];
//}

@end

@implementation UITableView (logger)

- (void)setDelegateHook:(ETTableViewDelegateHook *)hook {
    objc_setAssociatedObject(self, @selector(setDelegateHook:), hook, OBJC_ASSOCIATION_RETAIN);
}

- (ETTableViewDelegateHook *)delegateHook {
    return objc_getAssociatedObject(self, @selector(setDelegateHook:));
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL fromSelector = @selector(setDelegate:);
        SEL toSelector = @selector(hook_setDelegate:);
        [ETHook hookClass:self fromSelector:fromSelector toSelector:toSelector];
    });
}

- (void)hook_setDelegate:(id<UITableViewDelegate>)delegate {
    if (![self delegateHook]) {
        ETTableViewDelegateHook *hook = [[ETTableViewDelegateHook alloc] initWithDelegate:delegate];
        [self setDelegateHook:hook];
    }
    [self hook_setDelegate:[self delegateHook]];
}

@end
