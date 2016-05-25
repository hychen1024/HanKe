//
//  BlueToothTool.h
//  HanKe
//
//  Created by Just-h on 16/5/23.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NavController.h"

@interface BlueToothTool : NSObject
/**
 *  ActionSheet提示打开蓝牙
 */
+ (void)showOpenBlueToothTip:(NavController *)nav tableView:(UITableView *)tableV;
@end
