//
//  Peripheral.m
//  HanKe
//
//  Created by Just-h on 16/4/29.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "Peripheral.h"

@implementation Peripheral
+ (instancetype)peripheralWithName:(NSString *)name RSSI:(NSNumber *)rssi peripheral:(CBPeripheral *)peri{
    Peripheral *peripheral = [[Peripheral alloc] init];
    peripheral.name = name;
    peripheral.rssi = rssi;
    peripheral.peri = peri;
    return peripheral;
}

- (void)setAllIsConnected:(NSNumber *)num{
    [self setIsConnected:[num boolValue]];
}
@end
