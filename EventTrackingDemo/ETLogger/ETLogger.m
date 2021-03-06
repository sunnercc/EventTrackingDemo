//
//  ETLogger.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/3/6.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "ETLogger.h"

@implementation ETLogger

+ (instancetype)share {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

- (void)message:(NSString *)message classify:(NSString *)classify {
    NSLog(@"%@ classify: %@, message: %@", NSStringFromClass([self class]), classify, message);
}

@end
