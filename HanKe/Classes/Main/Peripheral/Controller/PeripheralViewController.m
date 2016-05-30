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
#import "DisplayView.h"


#define channelOnPeropheralView @"peripheralView"
// 发送查询状态指令间隔
#define sendCheckCommandInterval 1.0

@interface PeripheralViewController ()<UIScrollViewDelegate>
{
    // 当前耗材百分比
    CGFloat currPer;
    // 上次耗材百分比
    CGFloat lastPer;
    // lastPer -> currPer 是加还是减
    BOOL isSum;
    // 控制器已经存在(非第一次进入到控制器)
    BOOL hasVc;
    // 水疗没水图片切换动画控制
    BOOL hydroNoWater;
    
    CGFloat tmpNum;
    // 圆环动画间隔
    CGFloat interval;
    // 水量缓冲按钮
    UIButton *tmpWaterBtn;
    // 功能缓冲按钮
    UIButton *tmpFuncBtn;
}
/**
 *  水疗没水Timer
 */
@property (nonatomic, strong) NSTimer *noWaterTimer;
/**
 *  定时发送查询指令Timer
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
 *  滚动视图
 */
@property (nonatomic, strong) UIScrollView *scrollV;
/**
 *  当前显示的DisplayView
 */
@property (nonatomic, strong) DisplayView *currDisplayView;

/**
 *  BottomView
 */
@property (weak, nonatomic) IBOutlet UIView *controlView;
/**
 *  按钮遮罩View
 */
@property (weak, nonatomic) IBOutlet UIView *coverView;
/**
 *  消毒按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *disinfectBtn;
/**
 *  水疗按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *hydroBtn;
/**
 *  正常水量
 */
@property (weak, nonatomic) IBOutlet UIButton *normalWater;
/**
 *  加大水量
 */
@property (weak, nonatomic) IBOutlet UIButton *moreWater;


/**
 *  TopView
 */
@property (weak, nonatomic) IBOutlet UIView *displayView;

@property (weak, nonatomic) IBOutlet UIPageControl *pageCtrl;

/**
 *  静音按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *silenceBtn;
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
 *  重试按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;
/**
 *  返回图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
/**
 *  更换耗材文字
 */
@property (weak, nonatomic) IBOutlet UILabel *changeLb;
/**
 *  电话号码Btn
 */
@property (weak, nonatomic) IBOutlet UIButton *phoneNumBtn;


@end

@implementation PeripheralViewController

#pragma mark - view life circle  viewController生命周期方法

- (instancetype)init{
    if (self = [super init]) {
        self.scrollV = [[UIScrollView alloc] init];
        self.scrollV.pagingEnabled = YES;
        self.scrollV.bounces = NO;
        self.scrollV.showsVerticalScrollIndicator = NO;
        self.scrollV.showsHorizontalScrollIndicator = NO;
        self.scrollV.delegate = self;
    }
    return self;
}

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
    // 状态栏改为白色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
    [self.displayView addSubview:self.scrollV];
    NSInteger tmpIndex = self.index+1;
    // 页码赋值
    if (tmpIndex <= 5) {
        self.pageCtrl.numberOfPages = 5;
        self.pageCtrl.currentPage = tmpIndex - 1;
    }else if (tmpIndex > 5){
        for (NSInteger i = 5; i < self.peripheralModels.count + 5; i+=5) { // 取出5的倍数
            // 当前页总数为5的情况
            if ((i - tmpIndex) <= 5 && (i - tmpIndex) >= 0 && self.peripheralModels.count >= i) {
                self.pageCtrl.numberOfPages = 5;
                self.pageCtrl.currentPage = tmpIndex - i + 5 - 1;
                break;
            }
            // 当前页总数小于5的情况
            else if ((i - tmpIndex) <= 5 && (i - tmpIndex) >= 0 && self.peripheralModels.count < i){
                self.pageCtrl.numberOfPages = 5 - i + self.peripheralModels.count;
                self.pageCtrl.currentPage = tmpIndex - i + 5 - 1;
                break;
            }
        }
    }
    
    // topV,bottomV,coverV设置frame
    self.displayView.sd_layout.topEqualToView(self.view).leftEqualToView(self.view).rightEqualToView(self.view).heightRatioToView(self.view,0.585);
    self.controlView.sd_layout.bottomEqualToView(self.view).leftEqualToView(self.view).rightEqualToView(self.view).heightRatioToView(self.view,0.415);
    self.coverView.sd_layout.bottomEqualToView(self.view).leftEqualToView(self.view).rightEqualToView(self.view).heightRatioToView(self.view,0.415);
    
    CGFloat displayH = kScreenH * 0.585;
    CGFloat controlH = kScreenH * 0.415;
    
    // bottomV
    
    
    // topV
    self.backImage.sd_layout.widthIs(21).heightIs(21).leftSpaceToView(self.displayView,14).topSpaceToView(self.displayView,displayH * 0.08);
    self.backBtn.sd_layout.widthIs(44).heightIs(34).leftSpaceToView(self.displayView,2).topSpaceToView(self.displayView,displayH * 0.06);
    self.retryBtn.sd_layout.widthIs(46).heightIs(30).topSpaceToView(self.displayView,displayH * 0.07).rightSpaceToView(self.displayView,8);
    self.hydroName.sd_layout.widthIs(120).heightIs(30).centerXIs(kScreenW * 0.35).topSpaceToView(self.displayView,displayH * 0.07);
    self.connectStatus.sd_layout.widthIs(80).heightIs(30).centerXIs(kScreenW * 0.62).topSpaceToView(self.displayView,displayH * 0.07);

    // centerY -> self.displayV

    if (IS_IPHONE_6P) {
        self.hydroName.sd_layout.widthIs(120).heightIs(30).centerXIs(kScreenW * 0.40).topSpaceToView(self.displayView,displayH * 0.07);
        self.connectStatus.sd_layout.widthIs(80).heightIs(30).centerXIs(kScreenW * 0.64).topSpaceToView(self.displayView,displayH * 0.07);
    }
    
    if (IS_IPHONE_5) {

    }
    
    if (IS_IPHONE_4_OR_LESS) {
        // bottomV
        
        // topV
        self.backImage.sd_layout.widthIs(18).heightIs(18).leftSpaceToView(self.displayView,14).topSpaceToView(self.displayView,displayH * 0.08);
        self.backBtn.sd_layout.widthIs(30).heightIs(30).leftSpaceToView(self.displayView,2).topSpaceToView(self.displayView,displayH * 0.06);
        self.retryBtn.sd_layout.widthIs(46).heightIs(30).topSpaceToView(self.displayView,displayH * 0.07).rightSpaceToView(self.displayView,8);
        self.hydroName.sd_layout.widthIs(120).heightIs(30).centerXIs(kScreenW * 0.36).topSpaceToView(self.displayView,displayH * 0.07);
        self.connectStatus.sd_layout.widthIs(80).heightIs(30).centerXIs(kScreenW * 0.67).topSpaceToView(self.displayView,displayH * 0.07);

        // centerY -> self.displayV

    }

    
}

- (void)init_View{
    self.hydroName.text = self.currPeri.name;
    lastPer = 0;
    hasVc = NO;
    
    self.sendInterval = sendCheckCommandInterval;
    
    tmpWaterBtn = nil;
    tmpFuncBtn = nil;
    
    // 3秒后退后按钮才可点击
    self.backBtn.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.backBtn.enabled = YES;
    });

    // 初始化对应的View
    [self initViewType:_isConnected];
    
    
    // KVO
    [self.currDisplayView.ConsumeLb addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    [self.disinfectBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
    [self.hydroBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];

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
    if (backValue.length != 16) {
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
    // 水疗/消毒剩余时间高位
    NSString *dataStr4 = [backValue substringWithRange:NSMakeRange(10, 2)];
    // 水疗/消毒剩余时间地位
    NSString *dataStr5 = [backValue substringWithRange:NSMakeRange(12, 2)];
    // 保留字
    NSString *dataStr6 = [backValue substringWithRange:NSMakeRange(14, 2)];
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
    self.currDisplayView.ConsumeLb.text = newValue;
    [self.currDisplayView.ConsumeLb countFromCurrentValueTo:[newValue doubleValue]  withDuration:1.0];
    
    // 设备状态
    if ([dataStr1 isEqualToString:@"01"]) { // 待机
        [self ShowHydroWithNoWater:NO];
        [self.currDisplayView.HydroStatus setTitle:@"待机中" forState:UIControlStateNormal];
    }else if ([dataStr1 isEqualToString:@"02"]){ // 水疗
        [self ShowHydroWithNoWater:NO];
        [self.currDisplayView.HydroStatus setTitle:@"水疗中" forState:UIControlStateNormal];
    }else if ([dataStr1 isEqualToString:@"03"]){ // 消毒

        [self.currDisplayView.HydroStatus setTitle:@"消毒中" forState:UIControlStateNormal];
    }else if ([dataStr1 isEqualToString:@"04"]){ // 水疗没水
        [self ShowHydroWithNoWater:YES];
        [self.currDisplayView.HydroStatus setTitle:@"水疗没水" forState:UIControlStateNormal];
    }else if ([dataStr1 isEqualToString:@"81"]){ // 待机静音
        self.silenceBtn.selected = YES;
        [self ShowHydroWithNoWater:NO];
        [self.currDisplayView.HydroStatus setTitle:@"待机中" forState:UIControlStateNormal];
    }else if ([dataStr1 isEqualToString:@"82"]){ // 水疗静音
        self.silenceBtn.selected = YES;
        [self ShowHydroWithNoWater:NO];
        [self.currDisplayView.HydroStatus setTitle:@"水疗中" forState:UIControlStateNormal];
    }else if ([dataStr1 isEqualToString:@"83"]){ // 消毒静音
        self.silenceBtn.selected = YES;
        [self.currDisplayView.HydroStatus setTitle:@"消毒中" forState:UIControlStateNormal];
    }else if ([dataStr1 isEqualToString:@"84"]){ // 水疗没水静音
        self.silenceBtn.selected = YES;
        [self ShowHydroWithNoWater:YES];
        [self.currDisplayView.HydroStatus setTitle:@"水疗没水" forState:UIControlStateNormal];
    }
    
    
    // 水流量
    if ([dataStr2 isEqualToString:@"01"]) { // 正常水量
        self.normalWater.selected = YES;
        tmpWaterBtn = self.normalWater;
    }else if ([dataStr2 isEqualToString:@"02"]){ // 加大水量
        self.moreWater.selected = YES;
        tmpWaterBtn = self.moreWater;
    }
    
    // 水疗/消毒剩余时间
    NSString *HexStr = [dataStr4 stringByAppendingString:dataStr5];
    NSString *DecStr = [ConvertTool hexStrToDecStr:HexStr];
    // 剩余总秒数
    int Dec = [DecStr intValue];
    // 剩余小时
    NSString *hour = [NSString stringWithFormat:@"%d",Dec / 3600];
    // 剩余分钟
    NSString *minute = [NSString stringWithFormat:@"%d",(Dec % 3600) / 60];
    // 剩余秒
    NSString *second = [NSString stringWithFormat:@"%d",Dec % 60];
#warning 给剩余时间Label赋值
}


/**
 *  是否显示水疗没水状态
 */
- (void)ShowHydroWithNoWater:(BOOL)isShow{
    if (isShow) { // 显示水疗没水状态
        hydroNoWater = NO;
        self.noWaterTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(hydroNoWater:) userInfo:nil repeats:YES];
    }else{ // 关闭水疗没水状态
        [self.noWaterTimer invalidate];
        self.noWaterTimer = nil;
        UIImage *selectImg = [UIImage imageNamed:@"hydrotherapeutics_p"];
        [self.hydroBtn setBackgroundImage:selectImg forState:UIControlStateSelected];
        [self.hydroBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    }
}

- (void)hydroNoWater:(NSTimer *)timer{
    UIImage *normalImg = [UIImage imageNamed:@"hydrotherapeutics_n"];
    UIImage *selectImg = [UIImage imageNamed:@"hydrotherapeutics_p"];
    if (!hydroNoWater) {
        [self.hydroBtn setBackgroundImage:normalImg forState:UIControlStateSelected];
        [self.hydroBtn setTitleColor:[UIColor colorWithRed:200 green:200 blue:200 alpha:1] forState:UIControlStateSelected];
    }else{
        [self.hydroBtn setBackgroundImage:selectImg forState:UIControlStateSelected];
        [self.hydroBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    }
    hydroNoWater = !hydroNoWater;
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
        self.connectStatus.text = @"(已连接)";
        self.retryBtn.hidden = YES;
        self.coverView.hidden = YES;
        self.silenceBtn.hidden = NO;
        self.currDisplayView.viewType = displayViewTypeConnect;
    }else{ //未连接 隐藏某些控件
        self.connectStatus.text = @"(未连接)";
        self.retryBtn.hidden = NO;
        self.coverView.hidden = NO;
        self.silenceBtn.hidden = YES;
        self.currDisplayView.viewType = displayViewTypeDisconnect;
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
    if (sender.tag == 102 || sender.tag == 103) {
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
            switch (sender.tag) {
                case 101:{ // 水疗
                    [self.currDisplayView.HydroStatus setTitle:@"水疗中" forState:UIControlStateNormal];
                    break;
                }
                case 105:{ // 静音

                    break;
                }
                case 106:{ // 消毒
                    [self.currDisplayView.HydroStatus setTitle:@"消毒中" forState:UIControlStateNormal];
                    break;
                }
                default:
                    break;
            }
        }
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

// 电话号码点击响应
- (IBAction)phoneNumBtnDidClick:(UIButton *)sender {
    NSString *urlStr = @"tel://4008787555";
    // 不要设置frame
    UIWebView *webV = [[UIWebView alloc] init];
    [webV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    [self.view addSubview:webV];
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
    if (isShow) {// 显示
        self.currDisplayView.viewType = displayViewTypeExhaust;
        self.changeLb.hidden = NO;
        self.phoneNumBtn.hidden = NO;
        self.hydroName.hidden = YES;
        self.connectStatus.hidden = YES;
        
        self.isShowTip = YES;
    }else{// 隐藏
        self.currDisplayView.viewType = displayViewTypeConnect;
        
        self.changeLb.hidden = YES;
        self.phoneNumBtn.hidden = YES;
        self.hydroName.hidden = NO;
        self.connectStatus.hidden = NO;
        
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
    if ([keyPath isEqualToString:@"text"] && object == self.currDisplayView.ConsumeLb) {
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
            [self.hydroBtn removeObserver:self forKeyPath:@"selected"];
#warning 消毒按钮选中状态下
            self.hydroBtn.enabled = NO;
            
            [self.disinfectBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
            [self.hydroBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
        }
        if (!b){
            self.hydroBtn.enabled = YES;
        }
    }
    
    // 获取水疗开按钮的选中状态
    if (object == self.hydroBtn && [keyPath isEqualToString:@"selected"]) {
        b = [change[@"new"] boolValue];
        if (b) {
            [self.disinfectBtn removeObserver:self forKeyPath:@"selected"];
            [self.hydroBtn removeObserver:self forKeyPath:@"selected"];
#warning 水疗按钮选中状态下
            self.disinfectBtn.enabled = NO;
            
            [self.disinfectBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
            [self.hydroBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];
        }
        if (!b){
            self.disinfectBtn.enabled = YES;
        }
    }
}

- (void)dealloc{
    [self.currDisplayView.ConsumeLb removeObserver:self forKeyPath:@"text"];
    [self.disinfectBtn removeObserver:self forKeyPath:@"selected"];
    [self.hydroBtn removeObserver:self forKeyPath:@"selected"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
#pragma mark - sources and delegates 代理、协议方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 计算当前页码
    NSInteger page = (scrollView.contentOffset.x+scrollView.frame.size.width*0.5)/(scrollView.frame.size.width);
    // 页码赋值
    if (page < 5) {//当前页码小于5
        self.pageCtrl.numberOfPages = 5;
        self.pageCtrl.currentPage = page;
    }
    else if (page == 5){//当前页码等于5
        self.pageCtrl.currentPage = 0;
    }
    else if (page > 5){//当前页码大于5
        for (NSInteger i = 5; i < self.peripheralModels.count + 5; i+=5) { // 取出5的倍数
            if (page == i) {//当前页码大于5并等于5的倍数
                if(page + 5 >= self.peripheralModels.count){
                    self.pageCtrl.numberOfPages = self.peripheralModels.count - i;
                }
                self.pageCtrl.currentPage = 0;
                break;
            }
            // 当前页总数为5的情况
            if ((i - page) <= 5 && (i - page) >= 0 && self.peripheralModels.count >= i) {
                self.pageCtrl.numberOfPages = 5;
                self.pageCtrl.currentPage = page - i + 5;
                break;
            }
            // 当前页总数小于5的情况
            else if ((i - page) <= 5 && (i - page) >= 0 && self.peripheralModels.count < i){
                self.pageCtrl.numberOfPages = 5 - i + self.peripheralModels.count;
                self.pageCtrl.currentPage = page - i + 5;
                break;
            }
        }
    }
}

// 滑动结束后获取当前X偏移量
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x / kScreenW;
    // 获取当前的DisplayView
    self.currDisplayView = self.scrollV.subviews[index];
    
    // 切换视图
    Peripheral *currPeri = self.peripheralModels[index];
    self.currPeripheral = currPeri.peri;
    // 1.更新UI
    self.hydroName.text = currPeri.name;
    self.connectStatus.text = currPeri.isConnected ? @"(已连接)":@"(未连接)";
    self.coverView.hidden = NO;
    
    // 2.连接当前视图所对应的设备并断开连接
    [self connectPeripheral];
    
    // 3.暂时关闭返回按钮
    self.backBtn.enabled = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.backBtn.enabled = YES;
    });
    
    // 4.
}


#pragma mark - getters and setters 属性的设置和获取方法
- (void)setIsConnected:(BOOL)isConnected{
    _isConnected = isConnected;
    // 显示连接状态视图
    [self initViewType:isConnected];
    if (isConnected) {
        self.currDisplayView.viewType = displayViewTypeConnect;
    }else{
        self.currDisplayView.viewType = displayViewTypeDisconnect;
    }
    NSDictionary *dict = nil;
    if (self.currPeripheral == nil) {
        dict = @{
         @"connectStatus":@(_isConnected)
                };
    }else{
        dict = @{
         @"connectStatus":@(_isConnected),
         @"currPeripheral":_currPeripheral
               };
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectStatus" object:nil userInfo:dict];
}

- (void)setPeripheralModels:(NSArray *)peripheralModels{
    _peripheralModels = peripheralModels;
    
    self.scrollV.frame = CGRectMake(0, kScreenH * 0.1638, kScreenW, kScreenH * 0.4212);
    self.scrollV.contentSize = CGSizeMake(kScreenW * peripheralModels.count, kScreenH * 0.4212);
    for (NSInteger i = 0; i < peripheralModels.count; ++i) {
        DisplayView *displayV = [DisplayView displayView];
        displayV.viewType = displayViewTypeDisconnect;
        displayV.frame = CGRectMake(i * kScreenW, 0, kScreenW, kScreenH * 0.4212);
        [self.scrollV addSubview:displayV];
    }
}

- (void)setIndex:(NSInteger)index{
    _index = index;
    self.scrollV.contentOffset = CGPointMake(index * kScreenW, 0);
    // 获取当前的DisplayView
    self.currDisplayView = self.scrollV.subviews[index];
}
@end
