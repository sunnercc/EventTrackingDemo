//
//  ETLogger.h
//  EventTrackingDemo
//
//  Created by sunner on 2021/3/6.
//  Copyright © 2021 sunner. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ETLogger : NSObject

+ (instancetype)share;

- (void)message:(NSString *)message classify:(NSString *)classify;

@end

NS_ASSUME_NONNULL_END
