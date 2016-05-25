//
//  DeviceTableViewCell.h
//  HanKe
//
//  Created by Just-h on 16/4/28.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Peripheral.h"
#import "MGSwipeTableCell.h"

@interface DeviceTableViewCell : MGSwipeTableCell
/**
 *  外设模型
 */
@property (nonatomic, strong) Peripheral *peri;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
