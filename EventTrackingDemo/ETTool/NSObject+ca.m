//
//  NSObject+ca.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/5/11.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "NSObject+ca.h"
#import <objc/runtime.h>

@implementation NSObject (ca)

- (nullable id)safeValueForKey:(NSString *)key {
    // 没有访问外部变量，所以不用考虑线程安全的问题
    if (!key && !key.length) return nil;
    
    // capitalizedString 首字母大写，但是对于_无效
    // 例如: _a -> _A  test -> Test
    NSString *capitalizedKey = [key capitalizedString];
    NSString *getKey = [NSString stringWithFormat:@"get%@", capitalizedKey];
    NSString *isKey = [NSString stringWithFormat:@"is%@", capitalizedKey];
    NSString *_key = [NSString stringWithFormat:@"_%@", key];
    NSString *_isKey = [NSString stringWithFormat:@"_is%@", capitalizedKey];
    
    // 第一步 按照 getKey， key, isKey, _key 顺序查找方法
    Class curClass = self.class;
    while (curClass != nil) {
        unsigned int outCount;
        Method *methods = class_copyMethodList(curClass, &outCount);
        for (int i = 0; i < outCount; i++) {
            Method method = methods[i];
            SEL sel = method_getName(method);
//            NSLog(@"%@", NSStringFromSelector(sel));
            if ([getKey isEqualToString:NSStringFromSelector(sel)]
                || [key isEqualToString:NSStringFromSelector(sel)]
                || [isKey isEqualToString:NSStringFromSelector(sel)]
                || [_key isEqualToString:NSStringFromSelector(sel)]) {
                return [self valueForKey:key];
            }
        }
        curClass = class_getSuperclass(curClass);
    }
    
    // 第二步 判断 accessInstanceVariablesDirectly
    Class curMetaClass = object_getClass(self.class);
    while (curMetaClass != nil) {
        unsigned int outCount;
        Method *methods = class_copyMethodList(curMetaClass, &outCount);
        for (int i = 0; i < outCount; i++) {
            Method method = methods[i];
            SEL sel = method_getName(method);
            if (@selector(accessInstanceVariablesDirectly) == sel) {
                IMP imp = method_getImplementation(method);
                BOOL (*func)(id, SEL) = (void *)imp;
                BOOL ret = func(self, sel);
                if (!ret) return nil;
            }
        }
        curMetaClass = class_getSuperclass(curMetaClass);
    }
    
    // 第三步 按照 _key， _isKey, key, isKey 顺序查找变量
    curClass = self.class;
    while (curClass != nil) {
        unsigned int outCount;
        Ivar *ivars = class_copyIvarList(curClass, &outCount);
        for (int i = 0; i < outCount; i++) {
            Ivar ivar = ivars[i];
            const char *name = ivar_getName(ivar);
            NSString *utf8Name = [NSString stringWithUTF8String:name];
//            NSLog(@"utf8Name: %@", utf8Name);
            if ([_key isEqualToString:utf8Name]
                || [_isKey isEqualToString:utf8Name]
                || [key isEqualToString:utf8Name]
                || [isKey isEqualToString:utf8Name]) {
                return [self valueForKey:key];
            }
        }
        curClass = class_getSuperclass(curClass);
    }
    return nil;
}

- (nullable id)safeValueForKeyPath:(NSString *)keyPath {
    if (!keyPath && !keyPath.length) return nil;
    NSArray<NSString *> *components = [keyPath componentsSeparatedByString:@"."];
    id target = self;
    for (NSString *component in components) {
        id ret = [target safeValueForKey:component];
        if (!ret) return nil;
        target = ret;
    }
    return target;
}

@end
