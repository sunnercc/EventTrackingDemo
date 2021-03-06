//
//  UIGestureRecognizer+logger.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/3/7.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "UIGestureRecognizer+logger.h"
#import "ETHook.h"
#import "ETLogger.h"
#import <objc/runtime.h>

@interface ETGestureRecognizerHook : NSObject
@property (nonatomic, weak) id target;
@end

@implementation ETGestureRecognizerHook

- (instancetype)initWithTarget:(id)target {
    if (self = [super init]) {
        self.target = target;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self.target respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.target respondsToSelector:aSelector]) {
        NSString *message = [NSString stringWithFormat:@"%@", NSStringFromSelector(aSelector)];
        [[ETLogger share] message:message classify: NSStringFromClass([self.target class])];
        return self.target;
    }
    return [super forwardingTargetForSelector:aSelector];
}

@end

@implementation UIGestureRecognizer (logger)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL fromSelector = @selector(initWithTarget:action:);
        SEL toSelector = @selector(hook_initWithTarget:action:);
        [ETHook hookClass:self fromSelector:fromSelector toSelector:toSelector];
    });
}

- (void)setGestureRecognizerHook:(ETGestureRecognizerHook *)hook {
    objc_setAssociatedObject(self, @selector(setGestureRecognizerHook:), hook, OBJC_ASSOCIATION_RETAIN);
}

- (ETGestureRecognizerHook *)gestureRecognizerHook {
    return objc_getAssociatedObject(self, @selector(setGestureRecognizerHook:));
}

- (instancetype)hook_initWithTarget:(id)target action:(SEL)action {
    if (![self gestureRecognizerHook]) {
        ETGestureRecognizerHook *hook = [[ETGestureRecognizerHook alloc] initWithTarget:target];
        [self setGestureRecognizerHook:hook];
    }
    return [self hook_initWithTarget:[self gestureRecognizerHook] action:action];
}

@end
