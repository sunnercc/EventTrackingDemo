//
//  UICollectionView+logger.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/5/11.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "UICollectionView+logger.h"
#import <objc/runtime.h>
#import "ETTool.h"
#import "ETHook.h"
#import "DataParser.h"
#import "NSObject+ca.h"
#import "DeviceInfo.h"
#import "ETLogger.h"

@interface ETCollectionViewDelegateHook : NSProxy
@property (nonatomic, weak) id<UICollectionViewDelegate> delegate;
@end

@implementation ETCollectionViewDelegateHook

- (instancetype)initWithDelegate:(id<UICollectionViewDelegate>)delegate {
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {    [self.delegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
    [self insertPotDataWithCollectionView:collectionView indexPath:indexPath];
}

- (void)insertPotDataWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    long timeInterval = NSDate.now.timeIntervalSince1970;
    
    UIViewController *vc = [ETTool findLocationVcWithView:collectionView];
    NSString *vcClassName = NSStringFromClass(vc.class);
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    NSString *viewPath = [ETTool findViewPathFrom:cell toSuper:vc.view];
    
    NSString *uid = [NSString stringWithFormat:@"%@|%@", vcClassName, viewPath];
            
    EventDefined *eventDefined = [DataParser eventDefinedInCollectionViewForUid:uid indexPath:indexPath];
    if (!eventDefined) return;
    if (![eventDefined.version isEqualToString:DeviceInfo.appVersion]) return;
    
    NSArray<ParamsDefined *> *selfParamsDefined = [DataParser selfParamsDefinedInCollectionViewForUid:uid indexPath:indexPath];
    for (ParamsDefined *paramsDefined in selfParamsDefined) {
        paramsDefined.propertyValue = [cell safeValueForKeyPath:paramsDefined.propertyKeyPath];
    }
    
    NSArray<ParamsDefined *> *targetParamsDefined = [DataParser targetParamsDefinedInCollectionViewForUid:uid indexPath:indexPath];
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
        @"indexPath.item": @(indexPath.item),
        @"indexPath.section": @(indexPath.section),
        @"timestamp": @(timeInterval),
        @"action": @"click",
        @"type": @"Event",
    };
//    NSLog(@"uploadData: %@", uploadData);
    [ETLogger.shareLogger track:uploadData];
}

@end

@implementation UICollectionView (logger)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL fromSelector = @selector(setDelegate:);
        SEL toSelector = @selector(hook_setDelegate:);
        [ETHook hookClass:self fromSelector:fromSelector toSelector:toSelector];
    });
}

- (void)setDelegateHook:(ETCollectionViewDelegateHook *)hook {
    objc_setAssociatedObject(self, @selector(setDelegateHook:), hook, OBJC_ASSOCIATION_RETAIN);
}

- (ETCollectionViewDelegateHook *)delegateHook {
    return objc_getAssociatedObject(self, @selector(setDelegateHook:));
}

- (void)hook_setDelegate:(id<UICollectionViewDelegate>)delegate {
    ETCollectionViewDelegateHook *hook = [[ETCollectionViewDelegateHook alloc] initWithDelegate:delegate];
    [self setDelegateHook:hook];
    [self hook_setDelegate:(id<UICollectionViewDelegate>)[self delegateHook]];
}

@end
