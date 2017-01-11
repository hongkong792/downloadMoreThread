//
//  ZFListCell.m
//  多线程断电续传
//
//  Created by 杨香港 on 2017/1/8.
//  Copyright © 2017年 杨香港. All rights reserved.
//

#import "ZFListCell.h"

@implementation ZFListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)downloadClick:(id)sender
{
    if (self.downloadCallBackBlock) {
        self.downloadCallBackBlock();
    }
}



@end
