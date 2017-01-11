//
//  ZFListCell.h
//  多线程断电续传
//
//  Created by 杨香港 on 2017/1/8.
//  Copyright © 2017年 杨香港. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFListCell : UITableViewCell
@property (weak,nonatomic)IBOutlet UILabel * titleLabel;
@property (weak,nonatomic)IBOutlet UIButton * downloadBtn;
@property (nonatomic, strong)void(^downloadCallBackBlock)();
@end
