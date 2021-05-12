//
//  DataParser.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/5/11.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "DataParser.h"

@implementation PageDefined

- (instancetype)initWithDict:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.pageID = [dictionary objectForKey:@"pageID"];
        self.pageName = [dictionary objectForKey:@"pageName"];
        self.version = [dictionary objectForKey:@"version"];
    }
    return self;
}

- (NSDictionary *)toDict {
    return @{
        @"pageID": _pageID ?: @"",
        @"pageName": _pageName ?: @"",
        @"version": _version ?: @"",
    };
}


- (NSString *)description {
    return [NSString stringWithFormat:@"\n pageID:%@ \n pageName:%@ \n version:%@", _pageID, _pageName, _version];
}

@end

@implementation EventDefined

- (instancetype)initWithDict:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.eventID = [dictionary objectForKey:@"eventID"];
        self.eventName = [dictionary objectForKey:@"eventName"];
        self.version = [dictionary objectForKey:@"version"];
    }
    return self;
}

- (NSDictionary *)toDict {
    return @{
        @"eventID": _eventID ?: @"",
        @"eventName": _eventName ?: @"",
        @"version": _version ?: @"",
    };
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n eventID:%@ \n eventName:%@ \n version:%@", _eventID, _eventName, _version];
}

@end


@implementation ParamsDefined

- (instancetype)initWithDict:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.propertyKeyPath = [dictionary objectForKey:@"propertyKeyPath"];
        self.propertyName = [dictionary objectForKey:@"propertyName"];
        self.propertyValue = [dictionary objectForKey:@"propertyValue"];
        self.propertyDesc = [dictionary objectForKey:@"propertyDesc"];
    }
    return self;
}

- (NSDictionary *)toDict {
    return @{
        @"propertyKeyPath": _propertyKeyPath ?: @"",
        @"propertyName": _propertyName ?: @"",
        @"propertyValue": _propertyValue ?: @"",
        @"propertyDesc": _propertyDesc ?: @"",
    };
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\n propertyKeyPath:%@ \n propertyName:%@ \n propertyValue:%@ \n propetyDesc:%@", _propertyKeyPath, _propertyName, _propertyValue, _propertyDesc];
}

@end

static NSDictionary *_cacheData;

@implementation DataParser

+ (NSDictionary *)_sourceData {
    if (!_cacheData) {
        NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"data.json" ofType:nil];
        if (sourcePath) {
            NSData *data = [NSData dataWithContentsOfFile:sourcePath];
            _cacheData = [NSJSONSerialization JSONObjectWithData:data
                                                    options:NSJSONReadingMutableLeaves
                                                      error:nil];
        }
    }
    return _cacheData;
}

#pragma mark - Page
+ (NSDictionary *)pageForUid:(NSString *)uid {
    NSDictionary *page = [[self _sourceData] objectForKey:@"Page"];
    return [page objectForKey:uid];
}

+ (PageDefined *)pageDefinedInPageForUid:(NSString *)uid {
    NSDictionary *pageForUid = [self pageForUid:uid];
    NSDictionary *pageDefined = [pageForUid objectForKey:@"pageDefined"];
    if (!pageDefined || !pageDefined.count) return nil;
    return [[PageDefined alloc] initWithDict:pageDefined];
}

+ (NSArray<ParamsDefined *> *)paramsDefinedInPageForUid:(NSString *)uid {
    NSDictionary *pageForUid = [self pageForUid:uid];
    NSArray *paramsDefined = [pageForUid objectForKey:@"paramsDefined"];
    if (!paramsDefined || !paramsDefined.count) return nil;
    
    NSMutableArray<ParamsDefined *> *_paramsDefineds = [NSMutableArray array];
    for (NSDictionary *_paramsDefined in paramsDefined) {
        [_paramsDefineds addObject:[[ParamsDefined alloc] initWithDict:_paramsDefined]];
    }
    return _paramsDefineds.copy;
}

#pragma mark - UIControl
+ (NSDictionary *)controlForUid:(NSString *)uid {
    NSDictionary *control = [[self _sourceData] objectForKey:@"UIControl"];
    return [control objectForKey:uid];
}

+ (EventDefined *)eventDefinedInControlForUid:(NSString *)uid {
    NSDictionary *controlForUid = [self controlForUid:uid];
    NSDictionary *eventDefined = [controlForUid objectForKey:@"eventDefined"];
    if (!eventDefined || !eventDefined.count) return nil;
    return [[EventDefined alloc] initWithDict:eventDefined];
}

+ (NSDictionary *)paramsDefinedInControlForUid:(NSString *)uid {
    NSDictionary *controlForUid = [self controlForUid:uid];
    return [controlForUid objectForKey:@"paramsDefined"];
}

+ (NSArray<ParamsDefined *> *)selfParamsDefinedInControlForUid:(NSString *)uid {
    NSDictionary *paramsDefined = [self paramsDefinedInControlForUid:uid];
    NSArray<NSDictionary *> *selfParamsDefined = [paramsDefined objectForKey:@"self"];
    NSMutableArray<ParamsDefined *> *_selfParamsDefined = [NSMutableArray array];
    for (NSDictionary *_paramsDefined in selfParamsDefined) {
        [_selfParamsDefined addObject:[[ParamsDefined alloc] initWithDict:_paramsDefined]];
    }
    return _selfParamsDefined.copy;
}
+ (NSArray<ParamsDefined *> *)targetParamsDefinedInControlForUid:(NSString *)uid {
    NSDictionary *paramsDefined = [self paramsDefinedInControlForUid:uid];
    NSArray<NSDictionary *> *targetParamsDefined = [paramsDefined objectForKey:@"target"];
    NSMutableArray<ParamsDefined *> *_targetParamsDefined = [NSMutableArray array];
    for (NSDictionary *_paramsDefined in targetParamsDefined) {
        [_targetParamsDefined addObject:[[ParamsDefined alloc] initWithDict:_paramsDefined]];
    }
    return _targetParamsDefined.copy;
}

#pragma mark - TapGesture
+ (NSDictionary *)tapGestureForUid:(NSString *)uid {
    NSDictionary *tapGesture = [[self _sourceData] objectForKey:@"UITapGestureRecognizer"];
    return [tapGesture objectForKey:uid];
}

+ (EventDefined *)eventDefinedInTapGestureForUid:(NSString *)uid {
    NSDictionary *tapGestureForUid = [self tapGestureForUid:uid];
    NSDictionary *eventDefined = [tapGestureForUid objectForKey:@"eventDefined"];
    if (!eventDefined || !eventDefined.count) return nil;
    return [[EventDefined alloc] initWithDict:eventDefined];
}

+ (NSDictionary *)paramsDefinedInTapGestureForUid:(NSString *)uid {
    NSDictionary *tapGestureForUid = [self tapGestureForUid:uid];
    return [tapGestureForUid objectForKey:@"paramsDefined"];
}

+ (NSArray<ParamsDefined *> *)selfParamsDefinedInTapGestureForUid:(NSString *)uid {
    NSDictionary *paramsDefined = [self paramsDefinedInTapGestureForUid:uid];
    NSArray<NSDictionary *> *selfParamsDefined = [paramsDefined objectForKey:@"self"];
    NSMutableArray<ParamsDefined *> *_selfParamsDefined = [NSMutableArray array];
    for (NSDictionary *_paramsDefined in selfParamsDefined) {
        [_selfParamsDefined addObject:[[ParamsDefined alloc] initWithDict:_paramsDefined]];
    }
    return _selfParamsDefined.copy;
}

+ (NSArray<ParamsDefined *> *)targetParamsDefinedInTapGestureForUid:(NSString *)uid {
    NSDictionary *paramsDefined = [self paramsDefinedInTapGestureForUid:uid];
    NSArray<NSDictionary *> *targetParamsDefined = [paramsDefined objectForKey:@"target"];
    NSMutableArray<ParamsDefined *> *_targetParamsDefined = [NSMutableArray array];
    for (NSDictionary *_paramsDefined in targetParamsDefined) {
        [_targetParamsDefined addObject:[[ParamsDefined alloc] initWithDict:_paramsDefined]];
    }
    return _targetParamsDefined.copy;
}

#pragma mark UITableView
+ (NSDictionary *)tableViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath {
    NSDictionary *tableView = [[self _sourceData] objectForKey:@"UITableView"];
    // 模糊匹配支持
    NSString *indexPathInUid = [NSString stringWithFormat:@"(%ld-%ld)", indexPath.row, indexPath.section];
    NSString *cutIndexPathForUid = [uid stringByReplacingOccurrencesOfString:indexPathInUid withString:@""];
    for (NSString *key in tableView.allKeys) {
        NSRange leftRange = [key rangeOfString:@"("];
        NSRange rightRange = [key rangeOfString:@")"];
        if (leftRange.location != NSNotFound && rightRange.location != NSNotFound) {
            NSUInteger loc = leftRange.location;
            NSUInteger length = (key.length - leftRange.location) - (key.length - rightRange.location) + 1;
            NSRange indexPathRange = NSMakeRange(loc, length);
            NSString *indexPathInKey = [key substringWithRange:indexPathRange];
            NSString *cutIndexPathForKey = [key stringByReplacingOccurrencesOfString:indexPathInKey withString:@""];
            if ([cutIndexPathForKey isEqualToString:cutIndexPathForUid]) {
                indexPathInKey = [indexPathInKey stringByReplacingOccurrencesOfString:@"(" withString:@""];
                indexPathInKey = [indexPathInKey stringByReplacingOccurrencesOfString:@")" withString:@""];
                NSArray<NSString *> *components = [indexPathInKey componentsSeparatedByString:@"-"];
                if (components && components.count == 2) {
                    NSString *first = components.firstObject;
                    NSString *last = components.lastObject;
                    NSInteger _row = [first integerValue];
                    NSInteger _section = [last integerValue];
                    if ([first isEqualToString:@"*"] && [last isEqualToString:@"*"]) { // 匹配任意 row & section
                        return [tableView objectForKey:key];
                    }
                    if ([first isEqualToString:@"*"] && _section == indexPath.section) { // 匹配任意 row
                        return [tableView objectForKey:key];
                    }
                    if ([last isEqualToString:@"*"] && _row == indexPath.row) { // 匹配任意 section
                        return [tableView objectForKey:key];
                    }
                    if (_row == indexPath.row && _section == indexPath.section) { // 精准匹配
                        return [tableView objectForKey:key];
                    }
                }
            }
        }
    }
    return @{};
}

+ (EventDefined *)eventDefinedInTableViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath {
    NSDictionary *tableViewForUid = [self tableViewForUid:uid indexPath:indexPath];
    NSDictionary *eventDefined = [tableViewForUid objectForKey:@"eventDefined"];
    if (!eventDefined || !eventDefined.count) return nil;
    return [[EventDefined alloc] initWithDict:eventDefined];
}

+ (NSDictionary *)paramsDefinedInTableViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath {
    NSDictionary *tableViewForUid = [self tableViewForUid:uid indexPath:indexPath];
    return [tableViewForUid objectForKey:@"paramsDefined"];
}

+ (NSArray<ParamsDefined *> *)selfParamsDefinedInTableViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath {
    NSDictionary *paramsDefined = [self paramsDefinedInTableViewForUid:uid indexPath:indexPath];
    NSArray<NSDictionary *> *selfParamsDefined = [paramsDefined objectForKey:@"self"];
    NSMutableArray<ParamsDefined *> *_selfParamsDefined = [NSMutableArray array];
    for (NSDictionary *_paramsDefined in selfParamsDefined) {
        [_selfParamsDefined addObject:[[ParamsDefined alloc] initWithDict:_paramsDefined]];
    }
    return _selfParamsDefined.copy;
}

+ (NSArray<ParamsDefined *> *)targetParamsDefinedInTableViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath {
    NSDictionary *paramsDefined = [self paramsDefinedInTableViewForUid:uid indexPath:indexPath];
    NSArray<NSDictionary *> *targetParamsDefined = [paramsDefined objectForKey:@"target"];
    NSMutableArray<ParamsDefined *> *_targetParamsDefined = [NSMutableArray array];
    for (NSDictionary *_paramsDefined in targetParamsDefined) {
        [_targetParamsDefined addObject:[[ParamsDefined alloc] initWithDict:_paramsDefined]];
    }
    return _targetParamsDefined.copy;
}


#pragma mark - UICollectionView
+ (NSDictionary *)collectionViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath {
    NSDictionary *collectionView = [[self _sourceData] objectForKey:@"UICollectionView"];
    // 模糊匹配支持
    NSString *indexPathInUid = [NSString stringWithFormat:@"(%ld-%ld)", indexPath.item, indexPath.section];
    NSString *cutIndexPathForUid = [uid stringByReplacingOccurrencesOfString:indexPathInUid withString:@""];
    for (NSString *key in collectionView.allKeys) {
        NSRange leftRange = [key rangeOfString:@"("];
        NSRange rightRange = [key rangeOfString:@")"];
        if (leftRange.location != NSNotFound && rightRange.location != NSNotFound) {
            NSUInteger loc = leftRange.location;
            NSUInteger length = (key.length - leftRange.location) - (key.length - rightRange.location) + 1;
            NSRange indexPathRange = NSMakeRange(loc, length);
            NSString *indexPathInKey = [key substringWithRange:indexPathRange];
            NSString *cutIndexPathForKey = [key stringByReplacingOccurrencesOfString:indexPathInKey withString:@""];
            if ([cutIndexPathForKey isEqualToString:cutIndexPathForUid]) {
                indexPathInKey = [indexPathInKey stringByReplacingOccurrencesOfString:@"(" withString:@""];
                indexPathInKey = [indexPathInKey stringByReplacingOccurrencesOfString:@")" withString:@""];
                NSArray<NSString *> *components = [indexPathInKey componentsSeparatedByString:@"-"];
                if (components && components.count == 2) {
                    NSString *first = components.firstObject;
                    NSString *last = components.lastObject;
                    NSInteger _item = [first integerValue];
                    NSInteger _section = [last integerValue];
                    if ([first isEqualToString:@"*"] && [last isEqualToString:@"*"]) { // 匹配任意 item & section
                        return [collectionView objectForKey:key];
                    }
                    if ([first isEqualToString:@"*"] && _section == indexPath.section) { // 匹配任意 item
                        return [collectionView objectForKey:key];
                    }
                    if ([last isEqualToString:@"*"] && _item == indexPath.item) { // 匹配任意 section
                        return [collectionView objectForKey:key];
                    }
                    if (_item == indexPath.item && _section == indexPath.section) { // 精准匹配
                        return [collectionView objectForKey:key];
                    }
                }
            }
        }
    }
    return @{};
}

+ (EventDefined *)eventDefinedInCollectionViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath {
    NSDictionary *collectionViewForUid = [self collectionViewForUid:uid indexPath:indexPath];
    NSDictionary *eventDefined = [collectionViewForUid objectForKey:@"eventDefined"];
    if (!eventDefined || !eventDefined.count) return nil;
    return [[EventDefined alloc] initWithDict:eventDefined];
}

+ (NSDictionary *)paramsDefinedInCollectionViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath {
    NSDictionary *collectionViewForUid = [self collectionViewForUid:uid indexPath:indexPath];
    return [collectionViewForUid objectForKey:@"paramsDefined"];
}

+ (NSArray<ParamsDefined *> *)selfParamsDefinedInCollectionViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath {
    NSDictionary *paramsDefined = [self paramsDefinedInCollectionViewForUid:uid indexPath:indexPath];
    NSArray<NSDictionary *> *selfParamsDefined = [paramsDefined objectForKey:@"self"];
    NSMutableArray<ParamsDefined *> *_selfParamsDefined = [NSMutableArray array];
    for (NSDictionary *_paramsDefined in selfParamsDefined) {
        [_selfParamsDefined addObject:[[ParamsDefined alloc] initWithDict:_paramsDefined]];
    }
    return _selfParamsDefined.copy;
}

+ (NSArray<ParamsDefined *> *)targetParamsDefinedInCollectionViewForUid:(NSString *)uid indexPath:(NSIndexPath *)indexPath {
    NSDictionary *paramsDefined = [self paramsDefinedInCollectionViewForUid:uid indexPath:indexPath];
    NSArray<NSDictionary *> *targetParamsDefined = [paramsDefined objectForKey:@"target"];
    NSMutableArray<ParamsDefined *> *_targetParamsDefined = [NSMutableArray array];
    for (NSDictionary *_paramsDefined in targetParamsDefined) {
        [_targetParamsDefined addObject:[[ParamsDefined alloc] initWithDict:_paramsDefined]];
    }
    return _targetParamsDefined.copy;
}

@end
