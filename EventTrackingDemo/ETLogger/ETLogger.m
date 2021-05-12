//
//  ETLogger.m
//  EventTrackingDemo
//
//  Created by sunner on 2021/3/6.
//  Copyright © 2021 sunner. All rights reserved.
//

#import "ETLogger.h"
#define TrackDatasFilePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"trackDatas.json"]
#define UploadDataTimeout 20

static dispatch_queue_t et_logger_processing_queue() {
    static dispatch_queue_t et_logger_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        et_logger_processing_queue = dispatch_queue_create("com.sunner.et.logger.processing", DISPATCH_QUEUE_SERIAL);
    });
    return et_logger_processing_queue;
}

static UIBackgroundTaskIdentifier taskIdentifier;
static NSUncaughtExceptionHandler *lastExceptionHandler;

@interface ETLogger ()

@property (nonatomic, copy) NSMutableArray *datas;

@end

@implementation ETLogger

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

+ (instancetype)shareLogger {
    static dispatch_once_t onceToken;
    static ETLogger *instance;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

void exceptionHandler(NSException *exception) {
    lastExceptionHandler(exception);
    dispatch_async(et_logger_processing_queue(), ^{
        [ETLogger.shareLogger writeToLocal];
    });
    sleep(UploadDataTimeout);
}

void registerSignalHandler(void) {
    signal(SIGSEGV, handleSignalException);
    signal(SIGFPE, handleSignalException);
    signal(SIGBUS, handleSignalException);
    signal(SIGPIPE, handleSignalException);
    signal(SIGHUP, handleSignalException);
    signal(SIGINT, handleSignalException);
    signal(SIGQUIT, handleSignalException);
    signal(SIGABRT, handleSignalException);
    signal(SIGILL, handleSignalException);
}

void handleSignalException(int signal) {
    dispatch_async(et_logger_processing_queue(), ^{
        [ETLogger.shareLogger writeToLocal];
    });
    sleep(UploadDataTimeout);
}

+ (void)initialize {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        registerSignalHandler();
        lastExceptionHandler = NSGetUncaughtExceptionHandler();
        NSSetUncaughtExceptionHandler(exceptionHandler);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        // upload server
        dispatch_async(et_logger_processing_queue(), ^{
            [ETLogger.shareLogger uploadData];
        });
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        taskIdentifier = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{
            // 过期了，停止任务
            [UIApplication.sharedApplication endBackgroundTask:taskIdentifier];
            taskIdentifier = UIBackgroundTaskInvalid;
        }];
        dispatch_async(et_logger_processing_queue(), ^{
            [ETLogger.shareLogger writeToLocal];
        });
        sleep(UploadDataTimeout);
        [UIApplication.sharedApplication endBackgroundTask:taskIdentifier];
        taskIdentifier = UIBackgroundTaskInvalid;
    }];
    
    // 用户切后台杀死 app 会调用
    // 系统因为内存不足等杀死，不会调用
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillTerminateNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        dispatch_async(et_logger_processing_queue(), ^{
            [ETLogger.shareLogger writeToLocal];
        });
        sleep(UploadDataTimeout);
    }];
}

- (void)track:(NSDictionary *)data {
    dispatch_async(et_logger_processing_queue(), ^{
        [self.datas addObject:data];
        if (self.datas.count >= 30) {
            [self uploadData];
        }
    });
}

//+ (void)logTest:(NSString *)name {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    dateFormatter.dateFormat = @"yyyy-MM-dd-HH-mm-ss";
//    NSString *dateString = [dateFormatter stringFromDate:NSDate.now];
//    NSString *threadName = NSThread.currentThread.isMainThread ? @"mainThread" : @"otherThread";
//    NSString *fileName = [NSString stringWithFormat:@"%@-%@-%@", dateString, threadName, name];
//
//    NSData *data = [fileName dataUsingEncoding:NSUTF8StringEncoding];
//
//    NSString *filePath = [[@"/Users/sunner/Documents/test/"
//                           stringByAppendingString:fileName]
//                          stringByAppendingString:@".txt"];
//
//    NSURL *url = [NSURL fileURLWithPath:filePath];
//    [data writeToURL:url atomically:YES];
//}

- (void)clearLocal {
    [self.datas removeAllObjects];
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.datas options:NSJSONWritingSortedKeys error:nil];
    [data writeToFile:TrackDatasFilePath atomically:YES];
}

- (void)writeToLocal {
    NSData *data = [NSData dataWithContentsOfFile:TrackDatasFilePath];
    if (data) {
        NSArray *datasArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if (datasArray && datasArray.count) {
            [self.datas addObjectsFromArray:datasArray];
        }
    }
    [self.datas writeToFile:TrackDatasFilePath atomically:YES];
    [self.datas removeAllObjects];
    NSLog(@"file write complte");
}

- (void)uploadData {
    BOOL success = YES; // mock server return
    if (success) { // clear local
        [ETLogger.shareLogger clearLocal];
    } else { // write to local
        [ETLogger.shareLogger writeToLocal];
    }
}

@end
