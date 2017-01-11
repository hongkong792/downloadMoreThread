//
//  SessionModel.h
//  多线程断电续传
//
//  Created by 杨香港 on 2017/1/8.
//  Copyright © 2017年 杨香港. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,DownloadState) {
    DownloadStateStart = 0,     /** 下载中 */
    DownloadStateSuspended,     /** 下载暂停 */
    DownloadStateCompleted,     /** 下载完成 */
    DownloadStateFailed         /** 下载失败 */
};

typedef  void(^DownloadProgressBlock)(CGFloat progress, NSString * speed,NSString *remainingTime,NSString * writtenSize,NSString *totalSize);
typedef void(^DownloadStateBlock)(DownloadState state);

@interface SessionModel : NSObject<NSCoding>
/**数据流*/
@property (nonatomic,strong)NSOutputStream* outStream;
/**下载地址*/
@property (nonatomic,copy)NSString * url;
@property (nonatomic,strong)NSDate * startTime;
@property (nonatomic,copy)NSString * fileName;
@property (nonatomic,copy)NSString * totalSize;
@property (nonatomic,assign)NSInteger totalLength;
@property (atomic,copy)DownloadProgressBlock progressBlock;
@property (atomic,copy)DownloadStateBlock stateBlock;


- (float)calculateFileSizeInUnit:(unsigned long long)contentLength;
- (NSString *)calculateUnit:(unsigned long long)contentlength;




@end
