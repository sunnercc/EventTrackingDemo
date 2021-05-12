//
//  UIGestureRecognizer+logger.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/3/7.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "UITapGestureRecognizer+logger.h"
#import "ETHook.h"
#import "ETLogger.h"
#import <objc/runtime.h>
#import "ETTool.h"
#import "DataParser.h"
#import "DeviceInfo.h"
#import "NSObject+ca.h"


@interface ETGestureRecognizerHook : NSProxy
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, weak) UIGestureRecognizer *gesture;
@end

@implementation ETGestureRecognizerHook

- (instancetype)initWithTarget:(id)target action:(SEL)action gesture:(UITapGestureRecognizer *)gesture {
    if (self) {
        self.target = target;
        self.action = action;
        self.gesture = gesture;
    }
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.target];
    if (invocation.selector == _action) {
        [self insertPotData];
    }
}

- (void)insertPotData {
    long timeInterval = NSDate.now.timeIntervalSince1970;
    
    UIViewController *vc = [ETTool findLocationVcWithView:_gesture.view];
    NSString *vcClassName = NSStringFromClass(vc.class);
    NSString *viewPath = [ETTool findViewPathFrom:_gesture.view toSuper:vc.view];
    NSString *selector = NSStringFromSelector(_action);
        
    NSString *uid = [NSString stringWithFormat:@"%@|%@|%@", vcClassName, viewPath, selector];
    
    EventDefined *eventDefined = [DataParser eventDefinedInTapGestureForUid:uid];
    if (!eventDefined) return;
    if (![eventDefined.version isEqualToString:DeviceInfo.appVersion]) return;
    
    NSArray<ParamsDefined *> *selfParamsDefined = [DataParser selfParamsDefinedInTapGestureForUid:uid];
    for (ParamsDefined *paramsDefined in selfParamsDefined) {
        paramsDefined.propertyValue = [_gesture safeValueForKeyPath:paramsDefined.propertyKeyPath];
    }
    
    NSArray<ParamsDefined *> *targetParamsDefined = [DataParser targetParamsDefinedInTapGestureForUid:uid];
    for (ParamsDefined *paramsDefined in targetParamsDefined) {
        paramsDefined.propertyValue = [_target safeValueForKeyPath:paramsDefined.propertyKeyPath];
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
        @"timestamp": @(timeInterval),
        @"action": @"click",
        @"type": @"Event",
    };
    NSLog(@"uploadData: %@", uploadData);
    [ETLogger.shareLogger track:uploadData];
}

@end

@implementation UITapGestureRecognizer (logger)

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
    ETGestureRecognizerHook *hook = [[ETGestureRecognizerHook alloc] initWithTarget:target action:action gesture:self];
    [self setGestureRecognizerHook:hook];
    return [self hook_initWithTarget:[self gestureRecognizerHook] action:action];
}

@end

