//
//  ETHook.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/3/6.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "ETHook.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import "Student.h"
#import "Person.h"

@implementation ETHook

+ (void)hookClass:(Class)cls fromSelector:(SEL)fromSelector toSelector:(SEL)toSelector {
    // fromSelector 对应的方法，可能是在当前类或者super类中
    // toSelector 对应的方法，一定是在当前类中
    
    // 方法的获取，会调用super，会去父类去查找
    Method fromMethod = class_getInstanceMethod(cls, fromSelector);
    Method toMethod = class_getInstanceMethod(cls, toSelector);

    BOOL addMethod = class_addMethod(cls,
                                     fromSelector,
                                     method_getImplementation(toMethod),
                                     method_getTypeEncoding(toMethod));
    if (addMethod) {
        // 添加成功： 说明 fromSelecotr 对应的方法是父类的，是继承而来。
        // 通过 addMethod 已经添加到了当前类中，并且 fromSelecotr 的 imp 已经正确了
        // 然后 更改 toSelector 的指向
        class_replaceMethod(cls,
                            toSelector,
                            method_getImplementation(fromMethod),
                            method_getTypeEncoding(fromMethod));
    } else {
        // 添加失败，说明 fromSelector 和 toSelector 一定是在当前类中，此刻只需要交换 imp 即可
        method_exchangeImplementations(fromMethod, toMethod);
    }
}

@end
