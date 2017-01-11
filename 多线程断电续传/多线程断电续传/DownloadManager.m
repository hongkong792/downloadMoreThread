//
//  DownloadManager.m
//  多线程断电续传
//
//  Created by 杨香港 on 2017/1/9.
//  Copyright © 2017年 杨香港. All rights reserved.
//

#import "DownloadManager.h"

@interface DownloadManager()<NSCopying,NSURLSessionDelegate>

/**保存所有任务（注：用下载地址／后作为key）*/
@property (nonatomic,strong)NSMutableDictionary * tasks;
/**保存素有下载相关的信息字典*/
@property (nonatomic,strong)NSMutableDictionary * sessionModels;
/**所有本地数据信息的存储*/
@property (nonatomic,strong)NSMutableArray * sessionModelsArray;
/**下载完成的模型数组*/
@property (nonatomic,strong)NSMutableArray * downloadedArray;
/**下载中的模型数组*/
@property (nonatomic,strong)NSMutableArray * downloadingArray;
@end




@implementation DownloadManager


static DownloadManager * _downloadMqanager;
+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadMqanager = [[self alloc] init];
    });
    return _downloadMqanager;
    
}





-(NSMutableDictionary *)tasks
{
    if (_tasks == nil) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return _tasks;
}


-(NSMutableDictionary *)sessionMedels
{
    if (_sessionModels == nil) {
        _sessionModels = @{}.mutableCopy;
    }
    return _sessionModels;
}


- (NSMutableArray *)sessionModelsArray
{
    if (_sessionModelsArray == nil) {
        _sessionModelsArray = @[].mutableCopy;
        [_sessionModelsArray addObjectsFromArray:[self getSessionModels]];
        
    }
    return _sessionModelsArray;
}

- (NSMutableArray *)downloadingArray
{
    if (_downloadingArray) {
        _downloadingArray = @[].mutableCopy;
        for (SessionModel * obj in self.sessionModelsArray) {
            if (![self isCompletion:obj.url]) {
                [_downloadingArray addObject:obj];
            }
        }
    }
    return _downloadingArray;
}

/**
 *归档
 */
- (void)save:(NSArray *)sessionModels
{
    [NSKeyedArchiver archiveRootObject:sessionModels toFile:ZFDownloadDetailPath];
}
/**
 *读取model
 */
- (NSArray *)getSessionModels
{
    //文件信息
    NSArray * sessionModels = [NSKeyedUnarchiver unarchiveObjectWithData:ZFDownloadDetailPath];
    return sessionModels;
}


/**
 *创建缓存目录文件
 */
- (void)createCachesDirectory
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:ZFCachesDirectory]) {
        [fileManager createDirectoryAtPath:ZFCachesDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
}
/**
 * 开启任务下载资源
 */
- (void)download:(NSString *)url progress:(DownloadProgressBlock)progressBlock state:(DownloadStateBlock)stateBlock
{
    if (!url) {
        return;
    }
    if ([self isCompletion:url]) {
        stateBlock(DownloadStateCompleted);
        return;
    }
    //暂停
    if ([self.tasks valueForKey:ZFFileName(url)]) {
        [self handle:url];
    }
    //创建缓存目录
    [self createCachesDirectory];
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    //创建流
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:ZFFileFullpath(url) append:YES];
    
    //创建请求
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    
    //设置请求头
    
    NSString * range = [NSString stringWithFormat:@"bytes=%zd-",ZFDownloadLength(url)];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    //创建一个Data任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    NSInteger taskIdenfiter = arc4random()%(arc4random()%10000+arc4random()
                                            %10000);
    NSLog(@"taskIdenfiter:%zd",taskIdenfiter);
    [task setValue:@(taskIdenfiter) forKey:@"taskIdentifier"];
    
    //保存任务
    [self.tasks setValue:task forKey:ZFFileName(url)];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:ZFFileFullpath(url)]) {
        SessionModel *sessionModel = [[SessionModel alloc] init];
        sessionModel.url = url;
        sessionModel.progressBlock = progressBlock;
        sessionModel.stateBlock = stateBlock;
        sessionModel.outStream = stream;
        sessionModel.startTime = [NSDate date];
        sessionModel.fileName = ZFFileName(url);
        [self.sessionMedels setValue:sessionModel forKey:@(task.taskIdentifier).stringValue];
        [self.sessionModelsArray addObject:sessionModel];
        [self.downloadingArray addObject:sessionModel];
        //保存
        [self save:self.sessionModelsArray];
        
    }else{
        for (SessionModel *sessionModel  in self.sessionModelsArray) {
            <#statements#>
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
}

- (void)handle:(NSString *)url
{
    NSURLSessionDataTask * task = [self getTask:url];
    if (task.state == NSURLSessionTaskStateRunning) {
        [self pause:url];
    }else{
        [self start:url];
    }
    
    
    
}


/**
 * 开始下载
 */
-(void)start:(NSString *)url
{
    NSURLSessionDataTask * task = [self getTask:url];
    [task resume];
    [self getSessionModel:task.taskIdentifier].stateBlock(DownloadStateStart);
    
}



/**
 *暂停下载
 */
- (void)pause:(NSString *)url
{
    NSURLSessionDataTask * task = [self getTask:url];
    [task suspend];
    [self getSessionModel:task.taskIdentifier].stateBlock(DownloadStateSuspended);
    
}

/**
 *根据url获取对应的下载信息模型
 */
- (SessionModel *)getSessionModel:(NSInteger)taskIdentifier
{
  return (SessionModel *)[self.sessionMedels valueForKey:@(taskIdentifier).stringValue];
    
}



/**
 *判断文件是否下载完成
*/
- (BOOL)isCompletion:(NSString *)url
{
    if ([self fileTotalLength:url] && ZFDownloadLength(url) == [self fileTotalLength:url]) {
        return YES;
    }
    return NO;
}

/**
 *获取该资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)url
{
    for (SessionModel *model in self.sessionModelsArray) {
        if ([model.url isEqualToString:url]) {
            return model.totalLength;
        }
    }
    return 0;
    
}


/**
 *根据url获得相应的下载任务
 */

- (NSURLSessionDataTask *)getTask:(NSString *)url
{
    return (NSURLSessionDataTask *)[self.tasks valueForKey:ZFFileName(url)];
    
}



@end
