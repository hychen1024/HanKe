//
//  JUSTPeripheral.m
//  HanKe
//
//  Created by Just-h on 16/4/29.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "JUSTPeripheral.h"

@implementation JUSTPeripheral
+ (instancetype)peripheralWithName:(NSString *)name RSSI:(NSNumber *)rssi peripheral:(CBPeripheral *)peri{
    JUSTPeripheral *peripheral = [[JUSTPeripheral alloc] init];
    peripheral.name = name;
    peripheral.rssi = rssi;
    peripheral.peri = peri;
    return peripheral;
}
@end
