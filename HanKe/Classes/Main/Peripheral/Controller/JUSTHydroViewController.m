//
//  JUSTHydroViewController.m
//  HanKe
//
//  Created by Just-h on 16/5/12.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "JUSTHydroViewController.h"
#import "SVProgressHUD.h"
#import "ConvertTool.h"

#define channelOnPeropheralView @"peripheralView"
@interface JUSTHydroViewController ()
/**
 *  水疗关
 */
@property (weak, nonatomic) IBOutlet UIButton *hydroSwitch;
/**
 *  小水量
 */
@property (weak, nonatomic) IBOutlet UIButton *smallWaterBtn;
/**
 *  中水量
 */
@property (weak, nonatomic) IBOutlet UIButton *middleWaterBtn;
/**
 *  大水量
 */
@property (weak, nonatomic) IBOutlet UIButton *bigWaterBtn;
/**
 *  静音
 */
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
/**
 *  水疗开
 */
@property (weak, nonatomic) IBOutlet UIButton *hydroBtn;
/**
 *  消毒
 */
@property (weak, nonatomic) IBOutlet UIButton *disinfectBtn;
@end

@implementation JUSTHydroViewController
#pragma mark - view life circle  viewController生命周期方法
- (void)viewDidLoad {
    [super viewDidLoad];
    [self init_View];
    [self init_BLE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - custom methods  自定义方法
- (void)init_View{
    
}

- (void)init_BLE{
    [self initBLEDelegate];
    [SVProgressHUD showInfoWithStatus:@"开始连接设备"];
    BLE.having(self.currPeripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}

- (void)initBLEDelegate{
    __weak typeof(self)weakSelf = self;
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [BLE setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接成功",peripheral.name]];
    }];
    
    //设置设备连接失败的委托
    [BLE setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--连接失败",peripheral.name]];
    }];
    
    //设置设备断开连接的委托
    [BLE setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSLog(@"设备：%@--断开连接",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备：%@--断开失败",peripheral.name]];
    }];

    //设置发现设备的Services的委托
    [BLE setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
        [rhythm beats];
    }];
    //设置发现设service的Characteristics的委托
    [BLE setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
    }];
    //设置读取characteristics的委托
    [BLE setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    //设置发现characteristics的descriptors的委托
    [BLE setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            NSLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    //设置读取Descriptor的委托
    [BLE setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //设置写数据成功的block
    [BLE setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
    }];
    
    //设置通知状态改变的block
    [BLE setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"uid:%@,isNotifying:%@",characteristic.UUID,characteristic.isNotifying?@"on":@"off");
    }];
    
    //读取rssi的委托
    [BLE setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) {
        NSLog(@"setBlockOnDidReadRSSI:RSSI:%@",RSSI);
    }];
    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [BLE setBabyOptionsAtChannel:channelOnPeropheralView scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];

}
#pragma mark 水疗按钮响应
/**
 *  101 水疗开关
 102 小水量
 103 中水量
 104 大水量
 105 静音模式
 106 消毒模式(消毒模式什么都不能做 只能取消消毒模式)
 107 读取机器当前状态
 *
 */
- (void)waterBtnDidClick:(UIButton *)btn{
    
    // 获取按钮的最后一位数(状态码)
    NSInteger statusNum = btn.tag % 10;
    NSString *writeStr = [NSString stringWithFormat:@"2A0%ld",statusNum];
    [self writeValue:writeStr];
}

- (IBAction)hydroBtnDidClick:(UIButton *)sender {
    [self waterBtnDidClick:sender];
}

// 写数据 这里的数据只需要写2AXX就行 后面12位会自动补齐日期
- (void)writeValue:(NSString *)value{
    
    NSData *data = [ConvertTool appendDateInstructFromStrToData:value];
    [self.currPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    [BLE notify:self.currPeripheral characteristic:self.writeCharacteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSString *str = [[NSString alloc] initWithData:characteristics.value encoding:NSUTF8StringEncoding];
        YCLog(@"%lu",(unsigned long)characteristics.properties);
        YCLog(@"%@",str);
#warning 设备返回的信息
        YCLog(@"notify%@",[NSString stringWithFormat:@"%@",self.writeCharacteristic.value]);
    }];
}
#pragma mark - sources and delegates 代理、协议方法


#pragma mark - getters and setters 属性的设置和获取方法

@end
