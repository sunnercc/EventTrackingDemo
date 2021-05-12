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
#import "DataParser.h"
#import "NSObject+ca.h"
#import "DeviceInfo.h"
#import <objc/runtime.h>

@implementation UIViewController (logger)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL fromSelectorAppear = @selector(viewDidAppear:);
        SEL toSelectorAppear = @selector(hook_viewDidAppear:);
        [ETHook hookClass:self fromSelector:fromSelectorAppear toSelector:toSelectorAppear];
        
        SEL fromSelectorDisappear = @selector(viewDidDisappear:);
        SEL toSelectorDisappear = @selector(hook_viewDidDisappear:);
        [ETHook hookClass:self fromSelector:fromSelectorDisappear toSelector:toSelectorDisappear];
    });
}

- (void)hook_viewDidAppear:(BOOL)animated {
    [self insertToViewDidAppear];
    [self hook_viewDidAppear:animated];
}

- (void)hook_viewDidDisappear:(BOOL)animated {
    [self insertToViewDidDisappear];
    [self hook_viewDidDisappear:animated];
}

- (long)getEnterPageTimeInterval {
    return [objc_getAssociatedObject(self, @selector(getEnterPageTimeInterval)) longValue];
}

- (void)setEnterPageTimeInterval:(long)timeInterval {
    objc_setAssociatedObject(self, @selector(getEnterPageTimeInterval), @(timeInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)insertToViewDidAppear {
    long timeInterval = NSDate.now.timeIntervalSince1970;
    [self setEnterPageTimeInterval:timeInterval];
    
    NSString *uid = NSStringFromClass(self.class);
    PageDefined *pageDefined = [DataParser pageDefinedInPageForUid:uid];
    if (!pageDefined) return;
    if (![pageDefined.version isEqualToString:DeviceInfo.appVersion]) return;
        
    NSArray<ParamsDefined *> *paramsDefineds = [DataParser paramsDefinedInPageForUid:uid];
    NSMutableDictionary<NSString *, NSDictionary *> *paramsDefinedDicts = [NSMutableDictionary dictionary];
    for (ParamsDefined *paramsDefined in paramsDefineds) {
        paramsDefined.propertyValue = [self safeValueForKeyPath:paramsDefined.propertyKeyPath];
        paramsDefinedDicts[paramsDefined.propertyName] = @{
            NSStringFromSelector(@selector(propertyValue)) : paramsDefined.propertyValue ?: @"",
            NSStringFromSelector(@selector(propertyDesc)) : paramsDefined.propertyDesc ?: @"",
            NSStringFromSelector(@selector(propertyKeyPath)) : paramsDefined.propertyKeyPath ?: @"",
        };
    }
    
    // uploadData
    NSDictionary *uploadData = @{
        NSStringFromSelector(@selector(pageID)): pageDefined.pageID ?: @"",
        NSStringFromSelector(@selector(pageName)): pageDefined.pageName ?: @"",
        NSStringFromSelector(@selector(version)): pageDefined.version ?: @"",
        @"paramsDefined": paramsDefinedDicts,
        @"uid": uid,
        @"timestamp": @(timeInterval),
        @"action": @"Appear",
        @"type": @"PV",
    };
    NSLog(@"uploadData: %@", uploadData);
    
}

- (void)insertToViewDidDisappear {
    long timeInterval = NSDate.now.timeIntervalSince1970;
    long disTimeInterval = timeInterval - [self getEnterPageTimeInterval];
    
    NSString *uid = NSStringFromClass(self.class);
    PageDefined *pageDefined = [DataParser pageDefinedInPageForUid:uid];
    if (!pageDefined) return;
    if (![pageDefined.version isEqualToString:DeviceInfo.appVersion]) return;
        
    NSArray<ParamsDefined *> *paramsDefineds = [DataParser paramsDefinedInPageForUid:uid];
    NSMutableDictionary<NSString *, NSDictionary *> *paramsDefinedDicts = [NSMutableDictionary dictionary];
    for (ParamsDefined *paramsDefined in paramsDefineds) {
        paramsDefined.propertyValue = [self safeValueForKeyPath:paramsDefined.propertyKeyPath];
        paramsDefinedDicts[paramsDefined.propertyName] = @{
            NSStringFromSelector(@selector(propertyValue)) : paramsDefined.propertyValue ?: @"",
            NSStringFromSelector(@selector(propertyDesc)) : paramsDefined.propertyDesc ?: @"",
            NSStringFromSelector(@selector(propertyKeyPath)) : paramsDefined.propertyKeyPath ?: @"",
        };
    }
    
    // uploadData
    NSDictionary *uploadData = @{
        NSStringFromSelector(@selector(pageID)): pageDefined.pageID ?: @"",
        NSStringFromSelector(@selector(pageName)): pageDefined.pageName ?: @"",
        NSStringFromSelector(@selector(version)): pageDefined.version ?: @"",
        @"paramsDefined": paramsDefinedDicts,
        @"uid": uid,
        @"timestamp": @(timeInterval),
        @"duration": @(disTimeInterval),
        @"action": @"DisAppear",
        @"type": @"PV",
    };
//    NSLog(@"uploadData: %@", uploadData);
    [ETLogger.shareLogger track:uploadData];
}

@end
