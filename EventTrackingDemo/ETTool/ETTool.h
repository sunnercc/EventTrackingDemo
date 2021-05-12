//
//  ETTool.h
//  EventTrackingDemo
//
//  Created by sunner on 2021/5/11.
//  Copyright © 2021 sunner. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ETTool : NSObject

+ (NSString *)findViewPathFrom:(UIView *)from toSuper:(UIView *)toSuper;

+ (UIView *)findViewFromSuper:(UIView *)fromSuper withViewPath:(NSString *)viewPath;

+ (UIViewController *)findLocationVcWithView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
