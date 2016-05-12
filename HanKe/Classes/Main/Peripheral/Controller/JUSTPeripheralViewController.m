//
//  JUSTPeripheralViewController.m
//  HanKe
//
//  Created by Just-h on 16/5/3.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "JUSTPeripheralViewController.h"
#import "UIView+SDAutoLayout.h"
#import "ConvertTool.h"
#import "SVProgressHUD.h"
#import "THCircularProgressView.h"
#import "UICountingLabel.h"

#define channelOnPeropheralView @"peripheralView"

@interface JUSTPeripheralViewController ()
{
    CGFloat currPer;
    CGFloat lastPer;
    BOOL isSum;
    CGFloat tmpNum;
    CGFloat interval;
}
@property (nonatomic, strong) NSTimer *timer;
/**
 *  耗材百分比
 */
@property (nonatomic, assign) NSInteger consumePer;
/**
 *  是否显示耗材用尽提示
 */
@property (nonatomic, assign) bool isShowTip;
/**
 *  全局圆环百分比View
 */
@property (nonatomic, strong) THCircularProgressView *circleNumV;

/**
 *  水疗机名
 */
@property (weak, nonatomic) IBOutlet UILabel *hydroName;
/**
 *  连接状态
 */
@property (weak, nonatomic) IBOutlet UILabel *connectStatus;
/**
 *  圆环百分比View
 */
@property (weak, nonatomic) IBOutlet UIView *circleProgressView;
/**
 *  耗材显示数字Lb
 */
@property (weak, nonatomic) IBOutlet UICountingLabel *consumeLb;
/**
 *  重试按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;
/**
 *  水疗机状态显示按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *hydroStatus;
/**
 *  消毒按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *disinfectBtn;
/**
 *  水疗开按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *hydroOnBtn;
/**
 *  静音按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *muteBtn;
/**
 *  大水量按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *bigBtn;
/**
 *  中水量按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *midBtn;
/**
 *  小水量按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *smallBtn;
/**
 *  水疗关按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *hydroOffBtn;
/**
 *  耗材用完提示Lb
 */
@property (weak, nonatomic) IBOutlet UILabel *exhaustTipLb;

@end

@implementation JUSTPeripheralViewController

#pragma mark - view life circle  viewController生命周期方法

- (void)viewDidLoad {
    [super viewDidLoad];
    [self init_View];
    [self initBLEDelegete];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

#pragma mark - custom methods  自定义方法
- (void)init_View{
    lastPer = 0;
    
    CGRect circleProgressVFrame = self.circleProgressView.frame;
    // 百分比圆环
    THCircularProgressView *circleNumV = [[THCircularProgressView alloc] initWithFrame:circleProgressVFrame];
    circleNumV.lineWidth = 5;
    circleNumV.radius = circleProgressVFrame.size.width * 0.5;
    circleNumV.progressBackgroundColor = [UIColor colorWithRed:0.13 green:0.47 blue:0.76 alpha:1.00];
    circleNumV.progressColor = [UIColor whiteColor];
    circleNumV.percentage = [self.consumeLb.text floatValue] * 0.01;
    [self.circleProgressView.superview addSubview:circleNumV];
    self.circleNumV = circleNumV;
    
    self.consumeLb.format = @"%d";
    self.consumeLb.method = UILabelCountingMethodLinear;
    
    [self.consumeLb addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    

}

- (void)initBLEDelegete{
    [self performSelector:@selector(connectPeripheral) withObject:nil afterDelay:0.2];
    // 开始连接设备
    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"准备连接:%@",self.currPeripheral.name]];
    
    __weak typeof(self)weakSelf = self;
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [BLE setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备:%@--连接成功",peripheral.name]];
        weakSelf.connectStatus.text = @"(已连接)";
    }];
    
    //设置设备连接失败的委托
    [BLE setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        YCLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备:%@--连接失败",peripheral.name]];
        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
        weakSelf.connectStatus.text = @"(未连接)";
    }];
    
    //设置设备断开连接的委托
    [BLE setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        YCLog(@"设备：%@--断开连接",peripheral.name);
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"设备:%@--断开连接",peripheral.name]];
        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
        weakSelf.connectStatus.text = @"(未连接)";
    }];
    
    //设置发现设备的Services的委托
    [BLE setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *service in peripheral.services) {
            YCLog(@"===service name:---%@",service.UUID);
            if ([service.UUID.UUIDString isEqual:HK_SERVICE_UUID_WRITE]) {
                weakSelf.writeService = service;
            }
            if ([service.UUID.UUIDString isEqual:HK_SERVICE_UUID_DEVICEINFO]) {
                weakSelf.systemInfoService = service;
            }
        }
    
        [rhythm beats];
    }];
    
    //设置发现设service的Characteristics的委托
    [BLE setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        for (CBCharacteristic *c in service.characteristics) {
            YCLog(@"========characteristic name:=========%@",c.UUID);
            if ([c.UUID.UUIDString isEqual:HK_CHARACTERISTIC_UUID_WRITE]) {
                weakSelf.writeCharacteristic = c;
            }
        }
    }];
    
    //设置读取characteristics的委托
    [BLE setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        YCLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    
    //设置发现characteristics的descriptors的委托
    [BLE setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        YCLog(@"===characteristic name:%@",characteristic.service.UUID);
        for (CBDescriptor *d in characteristic.descriptors) {
            YCLog(@"CBDescriptor name is :%@",d.UUID);
        }
    }];
    
    //设置读取Descriptor的委托
    [BLE setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
        YCLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //设置通知状态改变的委托
    [BLE setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
        NSString *str = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        YCLog(@"%lu",(unsigned long)characteristic.properties);
        YCLog(@"str:%@,UUID:%@,isNotify:%@",str,characteristic.UUID.UUIDString,characteristic.isNotifying?@"YES":@"NO");
        YCLog(@"characteristic.value:%@",[NSString stringWithFormat:@"%@",characteristic.value]);
    }];
    
    //设置写数据成功的委托
    [BLE setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"setBlockOnDidWriteValueForCharacteristicAtChannel characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
    }];
    

    
    //扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [BLE setBabyOptionsAtChannel:channelOnPeropheralView scanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:connectOptions scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];

}

- (void)connectPeripheral{
    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"开始连接:%@",self.currPeripheral.name]];
    if (self.currPeripheral == nil) {
        [SVProgressHUD showInfoWithStatus:@"连接失败"];
        return;
    }
    BLE.having(self.currPeripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
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

// 水疗功能按钮点击响应
- (IBAction)hydroBtnDidClick:(UIButton *)sender {
    [self waterBtnDidClick:sender];
}

// 返回按钮点击响应
- (IBAction)backBtnDidClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

// 重试按钮点击响应
- (IBAction)retryBtnDidClick:(UIButton *)sender {
    
    if (!self.isShowTip) {
        [self.consumeLb countFromCurrentValueTo:0 withDuration:1.0];
    }else{
        [self.consumeLb countFromCurrentValueTo:80 withDuration:1.0];
    }
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
        [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@",self.writeCharacteristic.value] maskType:SVProgressHUDMaskTypeNone];
    }];
}

// KVO回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    // 获取缓存设备数组的最新数据
#warning 没写完全
    if ([keyPath isEqualToString:@"peripherals"]) {
        YCLog(@"%@",[object class]);
    }
    
    if ([keyPath isEqualToString:@"text"]) {
        // 显示隐藏exhaustTip
        if ([change[@"new"] isEqualToString:@"0"]) {
            [self showExhaustTip:YES];
        }
        if (![change[@"new"] isEqualToString:@"0"] && self.isShowTip) {
            [self showExhaustTip:NO];
        }
        if ([change[@"new"] isEqualToString:[NSString stringWithFormat:@"%f",self.circleNumV.percentage * 100]]) {
            return;
        }
        [self animatedChangePercentageWithCurrPer:[change[@"new"] floatValue]*0.01];
    }
}

/**
 *  显示or隐藏耗材用尽提示
 *
 *  @param isShow 显示or隐藏
 */
- (void)showExhaustTip:(BOOL)isShow{
    __weak typeof(self) weakSelf = self;
    if (isShow) {// 显示
        [UIView animateWithDuration:1 animations:^{
            weakSelf.exhaustTipLb.hidden = NO;
            CGRect frame = weakSelf.exhaustTipLb.frame;
            frame.origin.y = 0;
            weakSelf.exhaustTipLb.frame = frame;
        }];
        self.isShowTip = YES;
    }else{// 隐藏
        [UIView animateWithDuration:1 animations:^{
            CGRect frame = weakSelf.exhaustTipLb.frame;
            frame.origin.y = -30;
            weakSelf.exhaustTipLb.frame = frame;
            weakSelf.exhaustTipLb.hidden = YES;
        }];
        self.isShowTip = NO;
    }
}

// 圆环百分比动画效果
- (void)animatedChangePercentageWithCurrPer:(CGFloat)currP{
    currPer = currP;
    // 间隔时间
    interval = 0.01;
    tmpNum = ABS(self.circleNumV.percentage - currP) * interval;
    if (currP <= self.circleNumV.percentage) {
        isSum = NO;
    }else{
        isSum = YES;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(timeFired:) userInfo:nil repeats:YES];
    [self.timer fire];
}

- (void)timeFired:(NSTimer *)timer{
    if (isSum) {
        self.circleNumV.percentage += tmpNum;
    }else{
        self.circleNumV.percentage -= tmpNum;
    }
    
    if ((self.circleNumV.percentage - currPer) >= 0 && isSum) {
        self.circleNumV.percentage = currPer;
        [self.timer invalidate];
        self.timer = nil;
    }
    if (!isSum && (currPer - self.circleNumV.percentage) >= 0) {
        lastPer = currPer;
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)dealloc{
    [BLE cancelPeripheralConnection:self.currPeripheral];
    [BLE cancelScan];
    [self.consumeLb removeObserver:self forKeyPath:@"text"];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
#pragma mark - sources and delegates 代理、协议方法


#pragma mark - getters and setters 属性的设置和获取方法

@end