//
//  NSObject+ca.h
//  EventTrackingDemo
//
//  Created by sunner on 2021/5/11.
//  Copyright © 2021 sunner. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ca)

- (nullable id)safeValueForKey:(NSString *)key;

- (nullable id)safeValueForKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
