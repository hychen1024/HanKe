//
//  JUSTSearchCell.h
//  HanKe
//
//  Created by Just-h on 16/4/29.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JUSTPeripheral.h"

@interface JUSTSearchCell : UITableViewCell
/**
 *  初始化方法
 */
+ (instancetype)searchCellWithTableView:(UITableView *)tableV;
/**
 *  设备模型
 */
@property (nonatomic, strong) JUSTPeripheral *peripheral;
@end
