//
//  JUSTDeviceTableViewCell.h
//  HanKe
//
//  Created by Just-h on 16/4/28.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JUSTPeripheral.h"
#import "MGSwipeTableCell.h"

@interface JUSTDeviceTableViewCell : MGSwipeTableCell
/**
 *  外设模型
 */
@property (nonatomic, strong) JUSTPeripheral *peri;
/**
 *  是否连接
 */
@property (nonatomic, assign) bool isConnected;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
