//
//  BlueToothTool.m
//  HanKe
//
//  Created by Just-h on 16/5/23.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "BlueToothTool.h"
#import "MJRefresh.h"

@implementation BlueToothTool
+ (void)showOpenBlueToothTip:(JUSTNavController *)nav tableView:(UITableView *)tableV{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"请打开蓝牙来允许App连接到配件" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *settingAct = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 跳转到打开蓝牙界面
            NSURL *url = [NSURL URLWithString:@"prefs:root=Bluetooth"];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        });
    }];
    UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (tableV == nil) return;
        [tableV.mj_header endRefreshing];
    }];
    [alertVc addAction:settingAct];
    [alertVc addAction:cancelAct];

    [nav presentViewController:alertVc animated:YES completion:nil];
}
@end
