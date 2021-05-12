//
//  UIButton+logger.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/3/6.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "UIControl+logger.h"
#import "ETHook.h"
#import "ETLogger.h"
#import "ETTool.h"
#import "DataParser.h"
#import "NSObject+ca.h"
#import "DeviceInfo.h"

@implementation UIControl (logger)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL fromSelector = @selector(sendAction:to:forEvent:);
        SEL toSelector = @selector(hook_sendAction:to:forEvent:);
        [ETHook hookClass:self fromSelector:fromSelector toSelector:toSelector];
    });
}

- (void)hook_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    [self insertToSendAction:action to:target forEvent:event];
    [self hook_sendAction:action to:target forEvent:event];
}

- (void)insertToSendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    long timeInterval = NSDate.now.timeIntervalSince1970;
    
    UIViewController *vc = [ETTool findLocationVcWithView:self];
    NSString *vcClassName = NSStringFromClass(vc.class);
    NSString *viewPath = [ETTool findViewPathFrom:self toSuper:vc.view];
    NSString *selector = NSStringFromSelector(action);
    
    NSString *uid = [NSString stringWithFormat:@"%@|%@|%@", vcClassName, viewPath, selector];
    
    EventDefined *eventDefined = [DataParser eventDefinedInControlForUid:uid];
    if (!eventDefined) return;
    if (![eventDefined.version isEqualToString:DeviceInfo.appVersion]) return;
    
    NSArray<ParamsDefined *> *selfParamsDefined = [DataParser selfParamsDefinedInControlForUid:uid];
    for (ParamsDefined *paramsDefined in selfParamsDefined) {
        paramsDefined.propertyValue = [self safeValueForKeyPath:paramsDefined.propertyKeyPath];
    }
    
    NSArray<ParamsDefined *> *targetParamsDefined = [DataParser targetParamsDefinedInControlForUid:uid];
    for (ParamsDefined *paramsDefined in targetParamsDefined) {
        paramsDefined.propertyValue = [target safeValueForKeyPath:paramsDefined.propertyKeyPath];
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
//    NSLog(@"uploadData: %@", uploadData);
    [ETLogger.shareLogger track:uploadData];
}

@end
