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
#import "ETTool.h"
#import "DataParser.h"
#import "NSObject+ca.h"
#import "DeviceInfo.h"

@interface ETTableViewDelegateHook : NSProxy
@property (nonatomic, weak) id<UITableViewDelegate> delegate;
@end

@implementation ETTableViewDelegateHook

- (instancetype)initWithDelegate:(id<UITableViewDelegate>)delegate {
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return [self.delegate respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [(NSObject *)self.delegate methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (invocation.selector == @selector(tableView:didSelectRowAtIndexPath:)) {
        [invocation invoke];
    } else {
        [invocation invokeWithTarget:self.delegate];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    [self insertPotDataWithTableView:tableView indexPath:indexPath];
}

- (void)insertPotDataWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    long timeInterval = NSDate.now.timeIntervalSince1970;
    
    UIViewController *vc = [ETTool findLocationVcWithView:tableView];
    NSString *vcClassName = NSStringFromClass(vc.class);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *viewPath = [ETTool findViewPathFrom:cell toSuper:vc.view];
    
    NSString *uid = [NSString stringWithFormat:@"%@|%@", vcClassName, viewPath];
            
    EventDefined *eventDefined = [DataParser eventDefinedInTableViewForUid:uid indexPath:indexPath];
    if (!eventDefined) return;
    if (![eventDefined.version isEqualToString:DeviceInfo.appVersion]) return;
    
    NSArray<ParamsDefined *> *selfParamsDefined = [DataParser selfParamsDefinedInTableViewForUid:uid indexPath:indexPath];
    for (ParamsDefined *paramsDefined in selfParamsDefined) {
        paramsDefined.propertyValue = [cell safeValueForKeyPath:paramsDefined.propertyKeyPath];
    }
    
    NSArray<ParamsDefined *> *targetParamsDefined = [DataParser targetParamsDefinedInTableViewForUid:uid indexPath:indexPath];
    for (ParamsDefined *paramsDefined in targetParamsDefined) {
        paramsDefined.propertyValue = [(id)self.delegate safeValueForKeyPath:paramsDefined.propertyKeyPath];
    }
    
    NSMutableArray<ParamsDefined *> *paramsDefineds = [NSMutableArray array];
    [paramsDefineds addObjectsFromArray:selfParamsDefined];
    [paramsDefineds addObjectsFromArray:targetParamsDefined];
    NSMutableDictionary<NSString *, NSDictionary *> *paramsDefinedDicts = [NSMutableDictionary dictionary];
    for (ParamsDefined *paramsDefined in paramsDefineds) {
        paramsDefinedDicts[paramsDefined.propertyName] = @{
            NSStringFromSelector(@selector(propertyValue)) : paramsDefined.propertyValue ?: @"",
            NSStringFromSelector(@selector(propertyDesc)) : paramsDefined.propertyDesc ?: @"",
            NSStringFromSelector(@selector(propertyKeyPath)) : paramsDefined.propertyKeyPath ?: @"",
        };
    }
    
    // uploadData
    NSDictionary *uploadData = @{
        NSStringFromSelector(@selector(eventID)): eventDefined.eventID ?: @"",
        NSStringFromSelector(@selector(eventName)): eventDefined.eventName ?: @"",
        NSStringFromSelector(@selector(version)): eventDefined.version ?: @"",
        @"paramsDefined": paramsDefinedDicts,
        @"uid": uid,
        @"indexPath.row": @(indexPath.row),
        @"indexPath.section": @(indexPath.section),
        @"timestamp": @(timeInterval),
        @"action": @"click",
        @"type": @"Event",
    };
//    NSLog(@"uploadData: %@", uploadData);
    [ETLogger.shareLogger track:uploadData];
}

@end

@implementation UITableView (logger)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL fromSelector = @selector(setDelegate:);
        SEL toSelector = @selector(hook_setDelegate:);
        [ETHook hookClass:self fromSelector:fromSelector toSelector:toSelector];
    });
}

- (void)setDelegateHook:(ETTableViewDelegateHook *)hook {
    objc_setAssociatedObject(self, @selector(setDelegateHook:), hook, OBJC_ASSOCIATION_RETAIN);
}

- (ETTableViewDelegateHook *)delegateHook {
    return objc_getAssociatedObject(self, @selector(setDelegateHook:));
}

- (void)hook_setDelegate:(id<UITableViewDelegate>)delegate {
    ETTableViewDelegateHook *hook = [[ETTableViewDelegateHook alloc] initWithDelegate:delegate];
    [self setDelegateHook:hook];
    [self hook_setDelegate:(id<UITableViewDelegate>)[self delegateHook]];
}

@end
