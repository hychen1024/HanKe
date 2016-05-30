//
//  PeripheralViewController.h
//  HanKe
//
//  Created by Just-h on 16/5/3.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BabyBluetooth.h"
#import "BaseViewController.h"
#import "Peripheral.h"

@interface PeripheralViewController : BaseViewController
{
    @public
    BabyBluetooth *BLE;
}
/**
 *  设备数组
 */
@property (nonatomic, strong) NSArray *peripheralModels;
/**
 *  当前连接的外设模型
 */
@property (nonatomic, strong) Peripheral *currPeri;
/**
 *  当前连接的外设Index
 */
@property (nonatomic, assign) NSInteger index;
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
