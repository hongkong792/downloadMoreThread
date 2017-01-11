
//
//  ListViewController.m
//  多线程断电续传
//
//  Created by 杨香港 on 2017/1/9.
//  Copyright © 2017年 杨香港. All rights reserved.
//

#import "ListViewController.h"
#import "ZFListCell.h"
#import "DownloadManager.h"
#define LISTCELL @"ZFListCell"

@interface ListViewController ()
{
    NSMutableArray * dataSource;
}

@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    dataSource = @[@"http://dldir1.qq.com/qqfile/QQforMac/QQ_V4.2.4.dmg",
                   @"http://baobab.wdjcdn.com/1456117847747a_x264.mp4",
                   @"http://baobab.wdjcdn.com/14525705791193.mp4",
                   @"http://baobab.wdjcdn.com/1456459181808howtoloseweight_x264.mp4",
                   @"http://baobab.wdjcdn.com/1455968234865481297704.mp4"].mutableCopy;
    
   // [self.tableView registerNib:[UINib nibWithNibName:@"ZFListCell" bundle:nil] forCellReuseIdentifier:LISTCELL];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZFListCell * cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
    if (cell == nil) {
        cell = [[ZFListCell alloc] init];
    }
    cell.titleLabel.text = dataSource[indexPath.row];
    __block NSIndexPath *blockIndexPath = indexPath;
    __weak typeof(self)weakSelf = self;
    cell.downloadCallBackBlock = ^{
        NSString * urlString = dataSource[blockIndexPath.row];
        [[DownloadManager shareInstance] download:urlString progress:^(CGFloat progress, NSString *speed, NSString *remainingTime, NSString *writtenSize, NSString *totalSize) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([dataSource containsObject:urlString]) {
                    [dataSource removeObjectAtIndex:blockIndexPath.row];
                    [weakSelf.tableView deleteRowsAtIndexPaths:@[blockIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [weakSelf.tableView reloadData];
                }
            });
        } state:^(DownloadState state) {
            
        }];
    };
    return cell;
}


@end
