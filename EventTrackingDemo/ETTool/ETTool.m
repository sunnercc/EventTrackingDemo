//
//  ETTool.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/5/11.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "ETTool.h"
#import "UIView+ca.h"

@implementation ETTool

+ (NSString *)findViewPathFrom:(UIView *)from toSuper:(UIView *)toSuper {
    NSString *viewPath = NSStringFromClass(from.class);
    UIView *pathView = from;
    while (pathView != toSuper) {
        NSString *vcName = NSStringFromClass(pathView.superview.class);
        NSString *indexName = [NSString stringWithFormat:@"%d", [pathView indexOfSuperSubViews]];
        // UITableViewCell 的处理
        if ([pathView isKindOfClass:UITableViewCell.class]) {
            NSIndexPath *indexPath = [(UITableView *)(pathView.superview) indexPathForCell:(UITableViewCell *)pathView];
            indexName = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.row, indexPath.section];
        }
        // UICollectionViewCell 的处理
        if ([pathView isKindOfClass:UICollectionViewCell.class]) {
            NSIndexPath *indexPath = [(UICollectionView *)(pathView.superview) indexPathForCell:(UICollectionViewCell*)pathView];
            indexName = [NSString stringWithFormat:@"%ld-%ld", (long)indexPath.item, indexPath.section];
        }
        viewPath = [NSString stringWithFormat:@"%@(%@)_%@", vcName, indexName, viewPath];
        pathView = pathView.superview;
    }
    return viewPath;
}

+ (UIView *)findViewFromSuper:(UIView *)fromSuper withViewPath:(NSString *)viewPath {
    UIView *currentView = fromSuper;
    NSArray<NSString *> *components = [viewPath componentsSeparatedByString:@"_"];
    for (NSString *component in components) {
        NSRange range = [component rangeOfString:@"("];
        if (range.location != NSNotFound) {
            NSString *className = [component substringToIndex:range.location];
            NSString *indexName = [component substringFromIndex:range.location];
            if (![NSStringFromClass(currentView.class) isEqualToString:className]) {
                return nil;
            }
            if (!indexName || !indexName.length) {
                return currentView;
            }
            indexName = [indexName substringWithRange:NSMakeRange(1, indexName.length-2)];
            NSArray<NSString *> *indexComponents = [indexName componentsSeparatedByString:@"-"];
            if (indexComponents && indexComponents.count == 2) { // UITableView & UICollectionView
                NSInteger first = [indexComponents.firstObject integerValue];
                NSInteger last = [indexComponents.lastObject integerValue];
                if ([currentView isKindOfClass:UITableView.class]) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:first inSection:last];
                    UITableViewCell *cell = [(UITableView *)currentView cellForRowAtIndexPath:indexPath];
                    currentView = cell;
                } else if ([currentView isKindOfClass:UICollectionView.class]) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:first inSection:last];
                    UICollectionViewCell *cell = [(UICollectionView *)currentView cellForItemAtIndexPath:indexPath];
                    currentView = cell;
                }
            } else {
                NSInteger index = [indexComponents.firstObject integerValue];
                currentView = [currentView.subviews objectAtIndex:index];
            }
        }
    }
    return currentView;
}

+ (UIViewController *)findLocationVcWithView:(UIView *)view {
    UIResponder *responder = view.nextResponder;
    while (![responder isKindOfClass:UIViewController.class]) {
        responder = responder.nextResponder;
    }
    return (UIViewController *)responder;
}

@end
