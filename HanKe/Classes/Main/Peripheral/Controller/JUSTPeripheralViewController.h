//
//  JUSTPeripheralViewController.h
//  HanKe
//
//  Created by Just-h on 16/5/3.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BabyBluetooth.h"
#import "JUSTViewController.h"

@interface JUSTPeripheralViewController : JUSTViewController
{
    @public
    BabyBluetooth *BLE;
}
//@property (nonatomic, weak) JUSTPeripheralViewController *weakPeriVc;
/**
 *
 */
@property (nonatomic, strong) NSArray *peripherals;
/**
 *  当前连接的蓝牙外设
 */
@property (nonatomic, strong) CBPeripheral *currPeripheral;
/**
 *  系统信息服务
 */
@property (nonatomic, strong) CBService *systemInfoService;
/**
 *  写服务
 */
@property (nonatomic, strong) CBService *writeService;
/**
 *  写特征
 */
@property (nonatomic, strong) CBCharacteristic *writeCharacteristic;
/**
 *  发送读机器指令间隔
 */
@property (nonatomic, assign) NSTimeInterval sendInterval;

/**
 *  是否连接状态,并显示对应的视图
 */
@property (nonatomic, assign) BOOL isConnected;
@end
