//
//  ETHook.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/3/6.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "ETHook.h"
#import <objc/runtime.h>

@implementation ETHook

+ (void)hookClass:(Class)cls fromSelector:(SEL)fromSelector toSelector:(SEL)toSelector {
    Method fromMethod = class_getInstanceMethod(cls, fromSelector);
    Method toMethod = class_getInstanceMethod(cls, toSelector);
    if (class_addMethod(cls, fromSelector, method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
        //返回YES: 代表方法不存在，所以利用 class_addMethod 添加了一个, 直接替换 toSelector 的方法实现就可以了
        class_replaceMethod(cls, toSelector, method_getImplementation(fromMethod), method_getTypeEncoding(fromMethod));
    } else {
        // 返回NO: 代表方法已经存在，直接交换
        method_exchangeImplementations(fromMethod, toMethod);
    }
}

@end
