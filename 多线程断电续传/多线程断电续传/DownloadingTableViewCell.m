//
//  DownloadingTableViewCell.m
//  多线程断电续传
//
//  Created by 杨香港 on 2017/1/8.
//  Copyright © 2017年 杨香港. All rights reserved.
//

#import "DownloadingTableViewCell.h"
#import "DownloadManager.h"

@implementation DownloadingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.downloadBtn.clipsToBounds = YES;
    [self.downloadBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.downloadBtn setTitle:@"🕘" forState:UIControlStateNormal];
    [self.downloadBtn setTitle:@"↓" forState:UIControlStateNormal];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
    [super setSelected:selected animated:animated];
    
}

- (IBAction)clickDownload:(id)sender
{
    if (self.backBlock) {
        self.backBlock(sender);
    }
    
}
- (void)setSessionModel:(SessionModel *)sessionModel
{
    _sessionModel = sessionModel;
    self.fileNameLabel.text = sessionModel.fileName;
    NSUInteger receivedSize = ZFDownloadLength(sessionModel.url);
    NSString *writtenSize  = [NSString stringWithFormat:@"%.2f %@",[sessionModel calculateFileSizeInUnit:receivedSize],
    [sessionModel calculateUnit:receivedSize]];
    
    CGFloat progress= 1.0*receivedSize/sessionModel.totalLength;
    self.progressLabel.text = [NSString stringWithFormat:@"%@/%@ (%.2f%%)",writtenSize,sessionModel.totalSize,progress*100];
    self.progress.progress = progress;
    self.speedLabel.text = @"已暂停";
}


@end
