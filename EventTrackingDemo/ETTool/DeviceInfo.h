//
//  DeviceInfo.h
//  EventTrackingDemo
//
//  Created by sunner on 2021/5/12.
//  Copyright © 2021 sunner. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DeviceInfo : NSObject

+ (NSDictionary *)appInfo;
+ (NSString *)appVersion;

@end

NS_ASSUME_NONNULL_END
