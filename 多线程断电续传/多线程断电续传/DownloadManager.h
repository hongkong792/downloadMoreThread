//
//  DownloadManager.h
//  多线程断电续传
//
//  Created by 杨香港 on 2017/1/9.
//  Copyright © 2017年 杨香港. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionModel.h"

// 缓存主目录
#define ZFCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingPathComponent:@"ZFCache"]

// 保存文件名
#define ZFFileName(url)  [[url componentsSeparatedByString:@"/"] lastObject]

// 文件的存放路径（caches）
#define ZFFileFullpath(url) [ZFCachesDirectory stringByAppendingPathComponent:ZFFileName(url)]

// 文件的已下载长度
#define ZFDownloadLength(url) [[[NSFileManager defaultManager] attributesOfItemAtPath:ZFFileFullpath(url) error:nil][NSFileSize] integerValue]

// 存储文件信息的路径（caches）
#define ZFDownloadDetailPath [ZFCachesDirectory stringByAppendingPathComponent:@"downloadDetail.data"]


@protocol DownloadDelegate <NSObject>

- (void)downloadResponse:(SessionModel*)sessionModel;

@end


@interface DownloadManager : NSObject


@property(nonatomic,strong,readonly)NSMutableDictionary * sessionMedels;
@property(nonatomic,strong,readonly)NSMutableArray * sessionModelsArray;
@property(nonatomic,strong,readonly)NSMutableArray * downloadedArray;
@property(nonatomic,strong,readonly)NSMutableArray * downloadingArray;

@property (nonatomic,weak)id<DownloadDelegate>delegate;

+(instancetype)shareInstance;
/**
 *归档
 */
- (void)save:(NSArray *)sessionModels;

/**
 *读取model
 */
- (NSArray *)getSessionModels;




/**
 *  开启任务下载资源
 *
 *  @param url           下载地址
 *  @param progressBlock 回调下载进度
 *  @param stateBlock    下载状态
 */
- (void)download:(NSString *)url progress:(DownloadProgressBlock)progressBlock state:(DownloadStateBlock)stateBlock;
/**
 *  查询该资源的下载进度值
 *
 *  @param url 下载地址
 *
 *  @return 返回下载进度值
 */
- (CGFloat)progress:(NSString *)url;

/**
 *  获取该资源总大小
 *
 *  @param url 下载地址
 *
 *  @return 资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)url;

/**
 *  判断该资源是否下载完成
 *
 *  @param url 下载地址
 *
 *  @return YES: 完成
 */
- (BOOL)isCompletion:(NSString *)url;

/**
 *  删除该资源
 *
 *  @param url 下载地址
 */
- (void)deleteFile:(NSString *)url;

/**
 *  清空所有下载资源
 */
- (void)deleteAllFile;

/**
 *  开始下载
 */
- (void)start:(NSString *)url;

/**
 *  暂停下载
 */
- (void)pause:(NSString *)url;

/**
 *  判断当前url是否正在下载
 *
 *  @param url   视频url
 *  @param block 下载进度
 *
 *  @return 是否在下载
 */
- (BOOL)isFileDownloadingForUrl:(NSString *)url withProgressBlock:(DownloadProgressBlock)block;

/**
 *  正在下载的视频URL的数组
 *
 *  @return 视频URL的数组
 */
- (NSArray *)currentDownloads;
 
 


@end
