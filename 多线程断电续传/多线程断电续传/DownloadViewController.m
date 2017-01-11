//
//  DownloadViewController.m
//  多线程断电续传
//
//  Created by 杨香港 on 2017/1/8.
//  Copyright © 2017年 杨香港. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadManager.h"
#import "ZFListCell.h"
#import "DownloadingTableViewCell.h"

@interface DownloadViewController ()<UITableViewDelegate,UITableViewDataSource,DownloadDelegate>
{
    NSMutableArray * _downloadObjectArr;
    
}

@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
    //更新数据源
    [self initData];
    
}



- (void)initData
{
    NSMutableArray *downloaded = [DownloadManager shareInstance].downloadedArray;
    NSMutableArray *downloading = [DownloadManager shareInstance].downloadingArray;
    _downloadObjectArr = @[].mutableCopy;
    [_downloadObjectArr addObject:downloaded];
    [_downloadObjectArr addObject:downloading];
    [self.tableView reloadData];
}

#pragma mark -DownloadDelegate
- (void)downloadResponse:(SessionModel*)sessionModel
{
    if (_downloadObjectArr) {
        NSArray *downloadings = _downloadObjectArr[1];
        if ([downloadings containsObject:sessionModel]) {
            NSInteger index = [downloadings indexOfObject:sessionModel];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
           __block DownloadingTableViewCell * cell =  [self.tableView cellForRowAtIndexPath:indexPath];
           __weak typeof(self)weakSelf = self;
            sessionModel.progressBlock = ^(CGFloat progress, NSString * speed,NSString *remainingTime,NSString * writtenSize,NSString *totalSize){
                dispatch_async(dispatch_get_main_queue(), ^{
                    cell.progressLabel.text =  [NSString stringWithFormat:@"%@/%@ (%.2f%%)",writtenSize,totalSize,progress*100];
                    cell.speedLabel.text = speed;
                    cell.progress.progress = progress;
                    cell.downloadBtn.selected = YES;
                });

            };
            sessionModel.stateBlock = ^(DownloadState state){
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 更新数据源
                    if (state == DownloadStateCompleted) {
                        [weakSelf initData];
                        cell.downloadBtn.selected = NO;
                    }
                    //暂停
                    if (state == DownloadStateSuspended) {
                        cell.speedLabel.text = @"已暂停";
                        cell.downloadBtn.selected = NO;
                    }
                    
                });
            };
            
        }
        
    }
    
    
}

#pragma mark -tableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * arr = _downloadObjectArr[1];
    return arr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block SessionModel *downloadObject =_downloadObjectArr[indexPath.section][indexPath.row];
    if (indexPath.section == 0) {
        DownloadingTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadingTableViewCell"];
        if (cell == nil) {
        cell  =  [[DownloadingTableViewCell alloc] init];
        }
        cell.sessionModel = downloadObject;
        [DownloadManager shareInstance].delegate = self;
        cell.backBlock = ^(UIButton * sender){
            [[DownloadManager shareInstance] download:downloadObject.url progress:^(CGFloat progress, NSString *speed, NSString *remainingTime, NSString *writtenSize, NSString *totalSize) {
                
            } state:^(DownloadState state) {
                
            }];
        };
        return cell;
    }
    return nil;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *downloadArr = _downloadObjectArr[1];
    SessionModel * downloadObject = downloadArr[indexPath.row];
    //根据url删除该条数据
    [[DownloadManager shareInstance] deleteFile:downloadObject.url];
    [downloadArr removeObject:downloadObject];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @[@"下载中"][1];
    
}





@end
