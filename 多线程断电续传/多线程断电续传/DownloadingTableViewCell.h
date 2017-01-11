//
//  DownloadingTableViewCell.h
//  多线程断电续传
//
//  Created by 杨香港 on 2017/1/8.
//  Copyright © 2017年 杨香港. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionModel.h"


typedef void(^DownloadingBlock)(UIButton *);
@interface DownloadingTableViewCell : UITableViewCell


@property (nonatomic,weak)IBOutlet UILabel * fileNameLabel;
@property (nonatomic,weak)IBOutlet UIProgressView *  progress;
@property (nonatomic,weak)IBOutlet UILabel * progressLabel;
@property (nonatomic,weak)IBOutlet UILabel *speedLabel;
@property (nonatomic,weak)IBOutlet UIButton *downloadBtn;
@property (nonatomic,copy) void(^backBlock)(UIButton *);
@property (nonatomic,strong)SessionModel * sessionModel;


@end
