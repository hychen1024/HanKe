//
//  JUSTHydroViewController.h
//  HanKe
//
//  Created by Just-h on 16/5/12.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "JUSTViewController.h"
#import "BabyBluetooth.h"

@interface JUSTHydroViewController : JUSTViewController
{
    @public
    BabyBluetooth *BLE;
}
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
@end
