//
//  DataParser.h
//  EventTrackingDemo
//
//  Created by sunner on 2021/5/11.
//  Copyright © 2021 sunner. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PageDefined : NSObject
@property (nonatomic, copy) NSString *pageID;
@property (nonatomic, copy) NSString *pageName;
@property (nonatomic, copy) NSString *version;
- (instancetype)initWithDict:(NSDictionary *)dictionary;
- (NSDictionary *)toDict;
@end

@interface EventDefined : NSObject
@property (nonatomic, copy) NSString *eventID;
@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, copy) NSString *version;
- (instancetype)initWithDict:(NSDictionary *)dictionary;
- (NSDictionary *)toDict;
@end

@interface ParamsDefined : NSObject
@property (nonatomic, copy) NSString *propertyKeyPath;
@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, copy) NSString *propertyValue;
@property (nonatomic, copy) NSString *propertyDesc;
- (instancetype)initWithDict:(NSDictionary *)dictionary;
- (NSDictionary *)toDict;
@end

@interface DataParser : NSObject

// Page
// uid: vcClassName
+ (PageDefined *)pageDefinedInPageForUid:(NSString *)uid;
+ (NSArray<ParamsDefined *> *)paramsDefinedInPageForUid:(NSString *)uid;

// UIControl
// uid: vcClassName|viewPath|selector
+ (EventDefined *)eventDefinedInControlForUid:(NSString *)uid;
+ (NSArray<ParamsDefined *> *)selfParamsDefinedInControlForUid:(NSString *)uid;
+ (NSArray<ParamsDefined *> *)targetParamsDefinedInControlForUid:(NSString *)uid;

// UITapGestureRecognizer
// uid: vcClassName|viewPath|selector
+ (EventDefined *)eventDefinedInTapGestureForUid:(NSString *)uid;
+ (NSArray<ParamsDefined *> *)selfParamsDefinedInTapGestureForUid:(NSString *)uid;
+ (NSArray<ParamsDefined *> *)targetParamsDefinedInTapGestureForUid:(NSString *)uid;

// UITableView
// uid: vcClassName|viewPath
// MyTableViewController|UITableView(5-0)_UITableViewCell
// (5-0) (row-section)
// 支持模糊匹配:
// 例: (*-0) 匹配到section=0的任意row的cell
// 例: (*-*) 匹配到任意section的任意row的cell
// 例: (5-*) 匹配到任意section的row=5的cell
+ (EventDefined *)eventDefinedInTableViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath;
+ (NSArray<ParamsDefined *> *)selfParamsDefinedInTableViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath;
+ (NSArray<ParamsDefined *> *)targetParamsDefinedInTableViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath;

// UICollectionView
// uid: vcClassName|viewPath
// MyCollectionViewController|UICollection(5-0)_UICollectionCell
// (5-0) (item-section)
// 支持模糊匹配:
// 例: (*-0) 匹配到section=0的任意item的cell
// 例: (*-*) 匹配到任意section的任意item的cell
// 例: (5-*) 匹配到任意section的item=5的cell
+ (EventDefined *)eventDefinedInCollectionViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath;
+ (NSArray<ParamsDefined *> *)selfParamsDefinedInCollectionViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath;
+ (NSArray<ParamsDefined *> *)targetParamsDefinedInCollectionViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
