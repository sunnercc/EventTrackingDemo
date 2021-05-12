//
//  UIView+ca.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/5/11.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "UIView+ca.h"

@implementation UIView (ca)

- (int)indexOfSuperSubViews {
    for (int i = 0; i < self.superview.subviews.count; i++) {
        if (self == self.superview.subviews[i]) return i;
    }
    return -1;
}

@end
