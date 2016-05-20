//
//  JUSTPeripheral.h
//  HanKe
//
//  Created by Just-h on 16/4/29.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface JUSTPeripheral : NSObject
/**
 *  扫描到的蓝牙设备名
 */
@property (nonatomic, copy) NSString *name;
/**
 *  蓝牙信号强度
 */
@property (nonatomic, strong) NSNumber *rssi;
/**
 *  外设
 */
@property (nonatomic, strong) CBPeripheral *peri;
/**
 *  是否连接
 */
@property (nonatomic, assign) BOOL isConnected;
/**
 *  初始化方法
 *
 *  @param name 设备名
 *  @param rssi 信号强度
 *
 *  @return JUSTPeripheral
 */
+ (instancetype)peripheralWithName:(NSString *)name RSSI:(NSNumber *)rssi peripheral:(CBPeripheral *)peri;
@end
