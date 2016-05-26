//
//  PeripheralViewController.m
//  HanKe
//
//  Created by Just-h on 16/5/3.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "PeripheralViewController.h"
#import "UIView+SDAutoLayout.h"
#import "ConvertTool.h"
#import "SVProgressHUD.h"
#import "THCircularProgressView.h"
#import "UICountingLabel.h"
#import "NavController.h"
#import "BlueToothTool.h"

#define channelOnPeropheralView @"peripheralView"

#define sendCheckCommandInterval 2.0

@interface PeripheralViewController ()
{
    // 当前耗材百分比
    CGFloat currPer;
    // 上次耗材百分比
    CGFloat lastPer;
    // lastPer -> currPer 是加还是减
    BOOL isSum;
    // 控制器已经存在(非第一次进入到控制器)
    BOOL hasVc;
    
    CGFloat tmpNum;
    // 间隔
    CGFloat interval;
    // 水量缓冲按钮
    UIButton *tmpWaterBtn;
    // 功能缓冲按钮
    UIButton *tmpFuncBtn;
}
/**
 *  定时发送
 */
@property (nonatomic, strong) NSTimer *sendTimer;
/**
 *  圆环动画timer
 */
@property (nonatomic, strong) NSTimer *timer;
/**
 *  缓存发送的命令
 */
@property (nonatomic, strong) NSString *writeValue;
/**
 *  是否显示耗材用尽提示
 */
@property (nonatomic, assign) bool isShowTip;
/**
 *  全局圆环百分比View
 */
@property (nonatomic, strong) THCircularProgressView *circleNumV;

/**
 *  控制操作View
 */
@property (weak, nonatomic) IBOutlet UIView *controlView;
/**
 *  信息显示View
 */
@property (weak, nonatomic) IBOutlet UIView *displayView;
/**
 *  按钮遮罩View
 */
@property (weak, nonatomic) IBOutlet UIView *coverView;
/**
 *  断开连接显示的图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *disconnectView;
/**
 *  返回按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
/**
 *  水疗机名
 */
@property (weak, nonatomic) IBOutlet UILabel *hydroName;
/**
 *  连接状态Lb
 */
@property (weak, nonatomic) IBOutlet UILabel *connectStatus;
/**
 *  圆环百分比View
 */
@property (weak, nonatomic) IBOutlet UIView *circleProgressView;
/**
 *  百分比符号
 */
@property (weak, nonatomic) IBOutlet UILabel *percentage;
/**
 *  耗材显示数字Lb
 */
@property (weak, nonatomic) IBOutlet UICountingLabel *consumeLb;
/**
 *  数字底图
 */
@property (weak, nonatomic) IBOutlet UIImageView *circleView;
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
/**
 *  返回图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
/**
 *  大中小水量背景图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *controlBgV;

@end

@implementation PeripheralViewController

#pragma mark - view life circle  viewController生命周期方法

- (void)viewDidLoad {
    [super viewDidLoad];
    [self prepareUI];
    [self init_View];
    [self initBLEDelegete];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    // 已连接状态下开启定时器
    if (hasVc && ![self.sendTimer isValid] && self.currPeripheral.state == CBPeripheralStateConnected) {
        self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:self.sendInterval target:self selector:@selector(sendCheckCommand) userInfo:nil repeats:YES];
    }
    
    if (hasVc && self.currPeripheral.state == CBPeripheralStateDisconnected) {
        [self connectPeripheral];
    }
}

#pragma mark - custom methods  自定义方法
- (void)prepareUI{
    // topV,bottomV,coverV设置frame
    self.displayView.sd_layout.topEqualToView(self.view).leftEqualToView(self.view).rightEqualToView(self.view).heightRatioToView(self.view,0.56);
    self.controlView.sd_layout.bottomEqualToView(self.view).leftEqualToView(self.view).rightEqualToView(self.view).heightRatioToView(self.view,0.44);
    self.coverView.sd_layout.bottomEqualToView(self.view).leftEqualToView(self.view).rightEqualToView(self.view).heightRatioToView(self.view,0.44);
    
    CGFloat displayH = kScreenH * 0.56;
    CGFloat controlH = kScreenH * 0.44;
    
    // bottomV
    self.hydroOffBtn.sd_layout.centerXEqualToView(self.controlView).widthIs(57).heightIs(57).bottomSpaceToView(self.controlView,controlH * 0.1);
    self.bigBtn.sd_layout.widthIs(32).heightIs(32).bottomSpaceToView(self.controlView,controlH * 0.145).rightSpaceToView(self.hydroOffBtn,42);
    self.smallBtn.sd_layout.widthIs(32).heightIs(32).bottomSpaceToView(self.controlView,controlH * 0.145).leftSpaceToView(self.hydroOffBtn,42);
    self.midBtn.sd_layout.widthIs(32).heightIs(32).bottomSpaceToView(self.hydroOffBtn,controlH * 0.1).centerXEqualToView(self.controlView);
    self.controlBgV.sd_layout.heightIs(83).widthIs(180).centerXEqualToView(self.controlView).bottomSpaceToView(self.controlView,controlH * 0.188);
    self.hydroOnBtn.sd_layout.heightIs(27).widthIs(54).centerXEqualToView(self.controlView).bottomSpaceToView(self.midBtn,controlH * 0.2);
    self.muteBtn.sd_layout.widthIs(54).heightIs(27).bottomEqualToView(self.hydroOnBtn).leftSpaceToView(self.hydroOnBtn,60);
    self.disinfectBtn.sd_layout.widthIs(54).heightIs(27).bottomEqualToView(self.hydroOnBtn).rightSpaceToView(self.hydroOnBtn,60);
    self.exhaustTipLb.sd_layout.heightIs(30).leftEqualToView(self.controlView).rightEqualToView(self.controlView).topSpaceToView(self.controlView,-30);
    
    // topV
    self.backImage.sd_layout.widthIs(21).heightIs(21).leftSpaceToView(self.displayView,14).topSpaceToView(self.displayView,displayH * 0.08);
    self.backBtn.sd_layout.widthIs(44).heightIs(34).leftSpaceToView(self.displayView,2).topSpaceToView(self.displayView,displayH * 0.06);
    self.retryBtn.sd_layout.widthIs(46).heightIs(30).topSpaceToView(self.displayView,displayH * 0.07).rightSpaceToView(self.displayView,8);
    self.hydroName.sd_layout.widthIs(120).heightIs(30).centerXIs(kScreenW * 0.4).topSpaceToView(self.displayView,displayH * 0.07);
    self.connectStatus.sd_layout.widthIs(80).heightIs(30).centerXIs(kScreenW * 0.67).topSpaceToView(self.displayView,displayH * 0.07);

    self.hydroStatus.sd_layout.widthIs(80).heightIs(32).bottomSpaceToView(self.displayView,displayH * 0.07).centerXEqualToView(self.displayView);
    // centerY -> self.displayV
    self.disconnectView.sd_layout.widthIs(displayH * 0.5).heightEqualToWidth().centerXEqualToView(self.displayView).centerYEqualToView(self.displayView);
    self.circleView.sd_layout.widthIs(displayH * 0.427).heightEqualToWidth().centerXEqualToView(self.displayView).centerYEqualToView(self.displayView);
    self.consumeLb.sd_layout.widthIs(displayH * 0.427).heightEqualToWidth().centerXEqualToView(self.displayView).centerYEqualToView(self.displayView);
    self.circleProgressView.sd_layout.widthIs(displayH * 0.513).heightEqualToWidth().centerXEqualToView(self.displayView).centerYEqualToView(self.displayView);
    self.percentage.sd_layout.xIs(self.displayView.frame.size.width * 0.58).yIs(self.displayView.frame.size.height * 0.37).widthIs(self.displayView.frame.size.width * 0.112).heightIs(self.displayView.frame.size.height * 0.072);

    if (IS_IPHONE_6P) {
        self.hydroName.sd_layout.widthIs(120).heightIs(30).centerXIs(kScreenW * 0.40).topSpaceToView(self.displayView,displayH * 0.07);
        self.connectStatus.sd_layout.widthIs(80).heightIs(30).centerXIs(kScreenW * 0.64).topSpaceToView(self.displayView,displayH * 0.07);
    }
    
    if (IS_IPHONE_5) {
        self.hydroStatus.sd_layout.widthIs(80).heightIs(32).bottomSpaceToView(self.displayView,displayH * 0.05).centerXEqualToView(self.displayView);
        self.hydroOnBtn.sd_layout.heightIs(27).widthIs(54).centerXEqualToView(self.controlView).bottomSpaceToView(self.midBtn,controlH * 0.13);
        self.muteBtn.sd_layout.widthIs(54).heightIs(27).bottomEqualToView(self.hydroOnBtn).leftSpaceToView(self.hydroOnBtn,60);
        self.disinfectBtn.sd_layout.widthIs(54).heightIs(27).bottomEqualToView(self.hydroOnBtn).rightSpaceToView(self.hydroOnBtn,60);
        
        self.hydroName.sd_layout.widthIs(120).heightIs(30).centerXIs(kScreenW * 0.36).topSpaceToView(self.displayView,displayH * 0.07);
        self.connectStatus.sd_layout.widthIs(80).heightIs(30).centerXIs(kScreenW * 0.67).topSpaceToView(self.displayView,displayH * 0.07);
        self.percentage.sd_layout.centerXIs(kScreenW * 0.62).centerYIs(displayH * 0.4).widthIs(self.displayView.frame.size.width * 0.112).heightIs(self.displayView.frame.size.height * 0.072);
        self.consumeLb.font = [UIFont systemFontOfSize:60];
        self.percentage.font = [UIFont systemFontOfSize:20];
    }
    
    if (IS_IPHONE_4_OR_LESS) {
        // bottomV
        self.hydroOffBtn.sd_layout.centerXEqualToView(self.controlView).widthIs(57).heightIs(57).bottomSpaceToView(self.controlView,controlH * 0.05);
        self.bigBtn.sd_layout.widthIs(32).heightIs(32).bottomSpaceToView(self.controlView,controlH * 0.075).rightSpaceToView(self.hydroOffBtn,42);
        self.smallBtn.sd_layout.widthIs(32).heightIs(32).bottomSpaceToView(self.controlView,controlH * 0.075).leftSpaceToView(self.hydroOffBtn,42);
        self.midBtn.sd_layout.widthIs(32).heightIs(32).bottomSpaceToView(self.hydroOffBtn,controlH * 0.1).centerXEqualToView(self.controlView);
        self.controlBgV.sd_layout.heightIs(83).widthIs(180).centerXEqualToView(self.controlView).bottomSpaceToView(self.controlView,controlH * 0.118);
        self.hydroOnBtn.sd_layout.heightIs(27).widthIs(54).centerXEqualToView(self.controlView).bottomSpaceToView(self.midBtn,controlH * 0.085);
        self.muteBtn.sd_layout.widthIs(54).heightIs(27).bottomEqualToView(self.hydroOnBtn).leftSpaceToView(self.hydroOnBtn,60);
        self.disinfectBtn.sd_layout.widthIs(54).heightIs(27).bottomEqualToView(self.hydroOnBtn).rightSpaceToView(self.hydroOnBtn,60);
        self.exhaustTipLb.sd_layout.heightIs(30).leftEqualToView(self.controlView).rightEqualToView(self.controlView).topSpaceToView(self.controlView,-30);
        
        // topV
        self.backImage.sd_layout.widthIs(18).heightIs(18).leftSpaceToView(self.displayView,14).topSpaceToView(self.displayView,displayH * 0.08);
        self.backBtn.sd_layout.widthIs(30).heightIs(30).leftSpaceToView(self.displayView,2).topSpaceToView(self.displayView,displayH * 0.06);
        self.retryBtn.sd_layout.widthIs(46).heightIs(30).topSpaceToView(self.displayView,displayH * 0.07).rightSpaceToView(self.displayView,8);
        self.hydroName.sd_layout.widthIs(120).heightIs(30).centerXIs(kScreenW * 0.36).topSpaceToView(self.displayView,displayH * 0.07);
        self.connectStatus.sd_layout.widthIs(80).heightIs(30).centerXIs(kScreenW * 0.67).topSpaceToView(self.displayView,displayH * 0.07);
        
        self.hydroStatus.sd_layout.widthIs(80).heightIs(32).bottomSpaceToView(self.displayView,displayH * 0.06).centerXEqualToView(self.displayView);
        
        // centerY -> self.displayV
        
        self.disconnectView.sd_layout.widthIs(displayH * 0.5).heightEqualToWidth().centerXEqualToView(self.displayView).centerYEqualToView(self.displayView);
        self.circleView.sd_layout.widthIs(displayH * 0.427).heightEqualToWidth().centerXEqualToView(self.displayView).centerYEqualToView(self.displayView);
        self.consumeLb.sd_layout.widthIs(displayH * 0.427).heightEqualToWidth().centerXEqualToView(self.displayView).centerYEqualToView(self.displayView);
        self.circleProgressView.sd_layout.widthIs(displayH * 0.513).heightEqualToWidth().centerXEqualToView(self.displayView).centerYEqualToView(self.displayView);
        
        self.percentage.sd_layout.centerXIs(self.displayView.frame.size.width * 0.52).centerYIs(displayH * 0.44).widthIs(self.displayView.frame.size.width * 0.112).heightIs(self.displayView.frame.size.height * 0.072);
        self.consumeLb.font = [UIFont systemFontOfSize:35];
        self.percentage.font = [UIFont systemFontOfSize:20];
    }

    
}

- (void)init_View{
    lastPer = 0;
    hasVc = NO;
    
    self.sendInterval = sendCheckCommandInterval;
    
    tmpWaterBtn = nil;
    tmpFuncBtn = nil;
    
    self.backBtn.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.backBtn.enabled = YES;
    });

    [self initViewType:_isConnected];
    
    // 百分比圆环
    CGRect circleProgressVFrame = self.circleProgressView.frame;
    THCircularProgressView *circleNumV = [[THCircularProgressView alloc] initWithFrame:circleProgressVFrame];
    circleNumV.lineWidth = 7;
    circleNumV.radius = circleProgressVFrame.size.width * 0.5;
    circleNumV.progressBackgroundColor = [UIColor colorWithRed:0.13 green:0.47 blue:0.76 alpha:1.00];
    circleNumV.progressColor = [UIColor whiteColor];
    circleNumV.percentage = [self.consumeLb.text floatValue] * 0.01;
    [self.circleProgressView.superview addSubview:circleNumV];
    circleNumV.hidden = YES;
    self.circleNumV = circleNumV;
    
    
    // KVO
    [self.consumeLb addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    [self.disinfectBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    [self.hydroOnBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];

}

- (void)initBLEDelegete{
    [self performSelector:@selector(connectPeripheral) withObject:nil afterDelay:0.2];
    __weak typeof(BLE) weakBLE = BLE;
    __weak typeof(self)weakSelf = self;
//    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    
    // 设置状态改变的委托
    [BLE setBlockOnCentralManagerDidUpdateStateAtChannel:channelOnPeropheralView block:^(CBCentralManager *central) {
        if (central.state != CBCentralManagerStatePoweredOn) {
            // 显示未连接视图
            [weakBLE cancelAllPeripheralsConnection];
            weakSelf.isConnected = NO;
            [weakSelf.sendTimer invalidate];
            weakSelf.sendTimer = nil;
            if (weakBLE.centralManager.state != CBCentralManagerStatePoweredOn) {
                [BlueToothTool showOpenBlueToothTip:(NavController *)weakSelf.navigationController tableView:nil];
            }
        }
        if (central.state == CBCentralManagerStatePoweredOn) {
            NavController *navVc = (NavController *)[UIApplication sharedApplication].keyWindow.rootViewController;
            // 判断主页面是否是在当前页面
            if (navVc.visibleViewController == self) {
                [weakSelf connectPeripheral];
            }
        }
    }];
    
    // 设置取消所有连接委托
    [BLE setBlockOnCancelAllPeripheralsConnectionBlock:^(CBCentralManager *centralManager) {
        weakSelf.isConnected = NO;
        [weakSelf.sendTimer invalidate];
        weakSelf.sendTimer = nil;
    }];
    
    //设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [BLE setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        [SVProgressHUD showSuccessWithStatus:@"连接成功" maskType:SVProgressHUDMaskTypeNone];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD showWithStatus:@"正在初始化界面" maskType:SVProgressHUDMaskTypeNone];
        });
        
    }];
    
    //设置设备连接失败的委托
    [BLE setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        YCLog(@"设备：%@--连接失败",peripheral.name);
        [SVProgressHUD showErrorWithStatus:@"连接失败" maskType:SVProgressHUDMaskTypeNone];
        
        // 显示未连接视图
        weakSelf.isConnected = NO;
        [weakSelf.sendTimer invalidate];
        weakSelf.sendTimer = nil;
    }];
    
    //设置设备断开连接的委托
    [BLE setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        YCLog(@"设备：%@--断开连接",peripheral.name);
        NavController *navVc = (NavController *)[UIApplication sharedApplication].keyWindow.rootViewController;
        // 判断主页面是否是在当前页面
        if (navVc.visibleViewController == self) {
            [SVProgressHUD showErrorWithStatus:@"断开连接" maskType:SVProgressHUDMaskTypeNone];
        }
        // 显示未连接视图
        weakSelf.isConnected = NO;
        [weakSelf.sendTimer invalidate];
        weakSelf.sendTimer = nil;
    }];
    
    //设置发现设备的Services的委托
    [BLE setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *service in peripheral.services) {
            if ([service.UUID.UUIDString isEqual:HK_SERVICE_UUID_WRITE]) {
                weakSelf.writeService = service;
            }
            if ([service.UUID.UUIDString isEqual:HK_SERVICE_UUID_DEVICEINFO]) {
                weakSelf.systemInfoService = service;
            }
        }
        
        if (weakSelf.writeService == nil) {
            [SVProgressHUD showErrorWithStatus:@"设备不匹配"];
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf backBtnDidClick:nil];
                });
            });
        }
    }];
    
    //设置发现设service的Characteristics的委托
    [BLE setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        
        for (CBCharacteristic *c in service.characteristics) {
//            YCLog(@"========characteristic name:=========%@",c.UUID);
            // 获取写特征
            if ([c.UUID.UUIDString isEqual:HK_CHARACTERISTIC_UUID_WRITE]) {
                // 保存写特征
                weakSelf.writeCharacteristic = c;
                
                // 写特征Notify回调数据
                [weakBLE notify:weakSelf.currPeripheral characteristic:weakSelf.writeCharacteristic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                    
                    YCLog(@"notify%@",[NSString stringWithFormat:@"writeCharacteristic:%@/characteristics:%@",weakSelf.writeCharacteristic.value,characteristics.value]);
                    
                    NSString *valueStr = [NSString stringWithFormat:@"%@",characteristics.value];
                    valueStr = [ConvertTool removeTrimmingCharactersWithStr:valueStr];
                    
                    if(valueStr == nil) {
                        YCLog(@"数据不匹配 - 数据为空");
                        return;
                    }
                    
                    [weakSelf initDataWithSuccessedConnection:valueStr];
                }];
                if (weakSelf.sendTimer == nil) {
                    weakSelf.sendTimer = [NSTimer scheduledTimerWithTimeInterval:weakSelf.sendInterval target:weakSelf selector:@selector(sendCheckCommand) userInfo:nil repeats:YES];
                }
            }
        }

    }];
    //设置读取characteristics的委托
    [BLE setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {

    }];
    
    //设置发现characteristics的descriptors的委托
    [BLE setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
//        for (CBDescriptor *d in characteristic.descriptors) {
//            YCLog(@"CBDescriptor name is :%@",d.UUID);
//        }
    }];
    
    //设置读取Descriptor的委托
    [BLE setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
//        YCLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
    //设置通知状态改变的委托
    [BLE setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
        NSString *str = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        YCLog(@"str:%@,UUID:%@,isNotify:%@",str,characteristic.UUID.UUIDString,characteristic.isNotifying?@"YES":@"NO");
        YCLog(@"characteristic.value:%@",[NSString stringWithFormat:@"%@",characteristic.value]);
    }];
    
    //设置写数据成功的委托
    [BLE setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
        YCLog(@"写入数据成功:characteristic:%@ and new value:%@",characteristic.UUID, characteristic.value);
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

#pragma mark 校验数据,成功后初始化界面
/**
 *  成功连接后 校验数据并初始化界面数据
 *
 *  @param backValue 返回的机器信息
 */
- (void)initDataWithSuccessedConnection:(NSString *)backValue{
    // 数据不符合
    if (backValue.length != 12) {
        YCLog(@"数据不匹配 - 数据长度不符合");
        return;
    }
    // 协议标志字
    NSString *protocolSignStr = [backValue substringWithRange:NSMakeRange(0, 2)];
    // 命令字
    NSString *commandStr = [backValue substringWithRange:NSMakeRange(2, 2)];
    // 设备状态
    NSString *dataStr1 = [backValue substringWithRange:NSMakeRange(4, 2)];
    // 水流量
    NSString *dataStr2 = [backValue substringWithRange:NSMakeRange(6, 2)];
    // 耗材信息
    NSString *dataStr3 = [backValue substringWithRange:NSMakeRange(8, 2)];
    // 保留字
//    NSString *dataStr4 = [backValue substringWithRange:NSMakeRange(10, 2)];
    if (![protocolSignStr isEqualToString:@"2a"] && ![protocolSignStr isEqualToString:@"2A"]) {
        YCLog(@"数据不匹配 - 协议标志字错误");
        return;
    }
    
    // 发送的命令字与得到的回调命令字不匹配
    if (![commandStr isEqualToString:[self.writeValue substringWithRange:NSMakeRange(2, 2)]]) {
        YCLog(@"数据不匹配 - 发送的命令字与得到的回调命令字不匹配");
        return;
    }
    
    [SVProgressHUD dismiss];
    
    // 显示已连接视图
    self.isConnected = YES;
    
    // 耗材信息
    NSString *newValue = [ConvertTool hexStrToDecStr:dataStr3];
    self.consumeLb.text = newValue;
    [self.consumeLb countFromCurrentValueTo:[newValue doubleValue]  withDuration:1.0];
    
    // 设备状态
    if ([dataStr1 isEqualToString:@"01"]) { // 待机
        [self.hydroStatus setTitle:@"待机中" forState:UIControlStateNormal];
        self.muteBtn.selected = NO;
        self.hydroOffBtn.enabled = NO;
        self.hydroOffBtn.selected = NO;
        self.hydroOnBtn.selected = NO;
        self.hydroOnBtn.userInteractionEnabled = YES;
        self.disinfectBtn.selected = NO;
        self.disinfectBtn.enabled = YES;
    }else if ([dataStr1 isEqualToString:@"02"]){ // 水疗
        self.muteBtn.selected = NO;
        self.hydroOffBtn.enabled = YES;
        self.hydroOffBtn.selected = NO;
        self.hydroOnBtn.selected = YES;
        self.hydroOnBtn.userInteractionEnabled = NO;
        self.disinfectBtn.selected = NO;
        self.disinfectBtn.enabled = NO;
        [self.hydroStatus setTitle:@"水疗中" forState:UIControlStateNormal];
    }else if ([dataStr1 isEqualToString:@"03"]){ // 消毒
        self.muteBtn.selected = NO;
        self.hydroOffBtn.enabled = NO;
        self.hydroOffBtn.selected = NO;
        self.hydroOnBtn.selected = NO;
        self.hydroOnBtn.enabled = NO;
        self.disinfectBtn.selected = YES;
        self.disinfectBtn.enabled = YES;
        [self.hydroStatus setTitle:@"消毒中" forState:UIControlStateNormal];
    }else if ([dataStr1 isEqualToString:@"81"]){
        self.muteBtn.selected = YES;
        self.hydroOffBtn.enabled = NO;
        self.hydroOffBtn.selected = NO;
        self.hydroOnBtn.selected = NO;
        self.hydroOnBtn.userInteractionEnabled = YES;
        self.disinfectBtn.selected = NO;
        self.disinfectBtn.enabled = YES;
        [self.hydroStatus setTitle:@"待机中" forState:UIControlStateNormal];
    }else if ([dataStr1 isEqualToString:@"82"]){
        self.muteBtn.selected = YES;
        self.hydroOffBtn.enabled = YES;
        self.hydroOffBtn.selected = NO;
        self.hydroOnBtn.selected = YES;
        self.hydroOnBtn.userInteractionEnabled = NO;
        self.disinfectBtn.selected = NO;
        self.disinfectBtn.enabled = NO;
        [self.hydroStatus setTitle:@"水疗中" forState:UIControlStateNormal];
    }else if ([dataStr1 isEqualToString:@"83"]){
        self.muteBtn.selected = YES;
        self.hydroOffBtn.enabled = NO;
        self.hydroOffBtn.selected = NO;
        self.hydroOnBtn.selected = NO;
        self.hydroOnBtn.enabled = NO;
        self.disinfectBtn.selected = YES;
        self.disinfectBtn.enabled = YES;
        [self.hydroStatus setTitle:@"消毒中" forState:UIControlStateNormal];
    }
    
    
    // 水流量
    if ([dataStr2 isEqualToString:@"01"]) { // 小水量
        self.smallBtn.selected = YES;
        tmpWaterBtn = self.smallBtn;
    }else if ([dataStr2 isEqualToString:@"02"]){ // 中水量
        self.midBtn.selected = YES;
        tmpWaterBtn = self.midBtn;
    }else if ([dataStr2 isEqualToString:@"03"]){ // 大水量
        self.bigBtn.selected = YES;
        tmpWaterBtn = self.bigBtn;
    }
}

/**
 *  连接外设
 */
- (void)connectPeripheral{
    [BLE cancelAllPeripheralsConnection];
    [SVProgressHUD showWithStatus:@"正在连接..."];
    if (BLE.centralManager.state != CBCentralManagerStatePoweredOn) {
        [SVProgressHUD dismiss];
        [BlueToothTool showOpenBlueToothTip:(NavController *)self.navigationController tableView:nil];
    }
    if (self.currPeripheral == nil) {
        [SVProgressHUD showErrorWithStatus:@"连接失败" maskType:SVProgressHUDMaskTypeNone];
        return;
    }
    if (self.writeCharacteristic != nil) {
//        BLE.having(self.currPeripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().begin();
        BLE.having(self.currPeripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
        return;
    }
    BLE.having(self.currPeripheral).and.channel(channelOnPeropheralView).then.connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}

/**
 *  根据是否连接初始化水疗界面
 *
 *  @param isConnect 是否连接
 */
- (void)initViewType:(BOOL)isConnect{
    if (isConnect) { //已连接 显示某些控件

        self.circleNumV.center = self.circleView.center;
        self.connectStatus.text = @"(已连接)";
        
        self.consumeLb.format = @"%d";
        self.consumeLb.method = UILabelCountingMethodLinear;
        self.circleNumV.hidden = NO;
        self.disconnectView.hidden = YES;
        self.circleProgressView.hidden = NO;
        self.consumeLb.hidden = NO;
        self.circleView.hidden = NO;
        self.percentage.hidden = NO;
        self.retryBtn.hidden = YES;
        self.coverView.hidden = YES;
    }else{ //未连接 隐藏某些控件
        self.circleProgressView.hidden = YES;
        self.consumeLb.hidden = YES;
        self.circleView.hidden = YES;
        self.percentage.hidden = YES;
        self.circleNumV.hidden = YES;
        self.exhaustTipLb.hidden = YES;
        self.connectStatus.text = @"(未连接)";
        self.disconnectView.hidden = NO;
        self.retryBtn.hidden = NO;
        self.coverView.hidden = NO;
        self.circleNumV.hidden = YES;
    }
}

- (void)sendCheckCommand{
    [self writeValue:@"2A07"];
}

#pragma mark 水疗按钮响应
/**
    按钮对应tag值
 *  101 水疗开  1001 水疗关 (指令都是同一个,一个开一个关)
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
    // 水量开关逻辑控制
    if (sender.tag == 102 || sender.tag == 103 || sender.tag == 104) {
        if (tmpWaterBtn == sender) {
            return;
        }
        if (tmpWaterBtn == nil) {
            sender.selected = YES;
            tmpWaterBtn = sender;
        }
        if (tmpWaterBtn != sender) {
            tmpWaterBtn.selected = NO;
            sender.selected = YES;
            tmpWaterBtn = sender;
        }
    }
    
    // 功能开关逻辑控制
    if (sender.tag == 101 || sender.tag == 105 || sender.tag == 106) {
        sender.selected = !sender.selected;
        if (sender.selected) {
            switch (sender.tag) { // 水疗
                case 101:{
                    [self.hydroStatus setTitle:@"水疗中" forState:UIControlStateNormal];
                    break;
                }
                case 105:{ // 静音
                    
                    break;
                }
                case 106:{
                    [self.hydroStatus setTitle:@"消毒中" forState:UIControlStateNormal];
                    break;
                }
                default:
                    break;
            }
        }
    }
    
    if (sender.tag == 1001) {
        [self.hydroStatus setTitle:@"待机中" forState:UIControlStateNormal];
        self.disinfectBtn.enabled = YES;
        self.hydroOnBtn.enabled = YES;
        self.hydroOnBtn.selected = NO;
        self.hydroOnBtn.userInteractionEnabled = YES;
        self.hydroOffBtn.enabled = NO;
    }

    [self waterBtnDidClick:sender];
  
}

// 返回按钮点击响应
- (IBAction)backBtnDidClick:(UIButton *)sender {
    
//    if (self.writeCharacteristic) {
//        [BLE cancelNotify:self.currPeripheral characteristic:self.writeCharacteristic];
//    }
    [self.timer invalidate];
    self.timer = nil;
    [self.sendTimer invalidate];
    self.sendTimer = nil;
    
    hasVc = YES;
    [SVProgressHUD dismiss];
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    

}

// 重试按钮点击响应
- (IBAction)retryBtnDidClick:(UIButton *)sender {
    if (BLE.centralManager.state != CBCentralManagerStatePoweredOn) {
        [BlueToothTool showOpenBlueToothTip:(NavController *)self.navigationController tableView:nil];
        return;
    }
    if (BLE.centralManager.state == CBCentralManagerStatePoweredOn) {
        [BLE cancelAllPeripheralsConnection];
        [self connectPeripheral];
    }
}

#pragma mark 发送指令
// 写数据 这里的数据只需要写2AXX就行 后面12位会自动补齐日期
- (void)writeValue:(NSString *)value{ // response:(void (^)(NSString *responseStr))response
    // 缓存发送命令
    self.writeValue = value;
    NSData *data = [ConvertTool appendDateInstructFromStrToData:value];
    if (self.writeCharacteristic == nil) {
        return;
    }
    [self.currPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithoutResponse];

}

#pragma mark 显示/隐藏耗材提示
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

#pragma mark 百分比动画效果
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

// KVO回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    // 获取耗材信息
    if ([keyPath isEqualToString:@"text"] && object == self.consumeLb) {
        if ([change[@"new"] isEqualToString:@"0"]) { //显示耗材用尽提示
            [self showExhaustTip:YES];
        }
        if (![change[@"new"] isEqualToString:@"0"] && self.isShowTip) { // 关闭耗材用尽提示
            [self showExhaustTip:NO];
        }
        if ([change[@"new"] isEqualToString:[NSString stringWithFormat:@"%f",self.circleNumV.percentage * 100]]) { // 值未改变
            return;
        }
        [self animatedChangePercentageWithCurrPer:[change[@"new"] floatValue]*0.01];
    }
    
    BOOL b = nil;
    // 获取消毒按钮的选中状态
    if (object == self.disinfectBtn && [keyPath isEqualToString:@"selected"]) {
        b = [change[@"new"] boolValue];
        if (b) {
            [self.disinfectBtn removeObserver:self forKeyPath:@"selected"];
            [self.hydroOnBtn removeObserver:self forKeyPath:@"selected"];
            
            self.hydroOnBtn.enabled = NO;
            self.hydroOffBtn.enabled = NO;
//            self.hydroOnBtn.selected = NO;
            [self.disinfectBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
            [self.hydroOnBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
        }
        if (!b){
            self.hydroOnBtn.enabled = YES;
        }
    }
    
    // 获取水疗开按钮的选中状态
    if (object == self.hydroOnBtn && [keyPath isEqualToString:@"selected"]) {
        b = [change[@"new"] boolValue];
        if (b) {
            [self.disinfectBtn removeObserver:self forKeyPath:@"selected"];
            [self.hydroOnBtn removeObserver:self forKeyPath:@"selected"];
            self.disinfectBtn.enabled = NO;
            self.disinfectBtn.selected = NO;
            self.hydroOnBtn.selected = YES;
            self.hydroOnBtn.userInteractionEnabled = NO;
            self.hydroOffBtn.enabled = YES;
            [self.disinfectBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
            [self.hydroOnBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
        }
        if (!b){
            self.disinfectBtn.enabled = YES;
        }
    }
}

- (void)dealloc{
    [self.consumeLb removeObserver:self forKeyPath:@"text"];
    [self.disinfectBtn removeObserver:self forKeyPath:@"selected"];
    [self.hydroOnBtn removeObserver:self forKeyPath:@"selected"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
#pragma mark - sources and delegates 代理、协议方法


#pragma mark - getters and setters 属性的设置和获取方法
- (void)setIsConnected:(BOOL)isConnected{
    _isConnected = isConnected;
    // 显示连接状态视图
    [self initViewType:isConnected];
    NSDictionary *dict = @{
                @"connectStatus":@(_isConnected)
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectStatus" object:nil userInfo:dict];
}
@end
