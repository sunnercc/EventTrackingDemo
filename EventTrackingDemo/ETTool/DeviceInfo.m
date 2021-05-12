//
//  DeviceInfo.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/5/12.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "DeviceInfo.h"

@implementation DeviceInfo

+ (NSDictionary *)appInfo {
    return [[NSBundle mainBundle] infoDictionary];
}

+ (NSString *)appVersion {
    return [[self appInfo] objectForKey:@"CFBundleShortVersionString"];
}

@end
