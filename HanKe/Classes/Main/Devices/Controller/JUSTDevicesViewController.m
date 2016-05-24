
//
//  JUSTDevicesViewController.m
//  HanKe
//
//  Created by Just-h on 16/4/28.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "JUSTDevicesViewController.h"
#import "RTDragCellTableView.h"
#import "JUSTPeripheral.h"
#import "JUSTPeripheralViewController.h"
#import "JUSTDeviceTableViewCell.h"
#import "JUSTAboutViewController.h"
#import "SVProgressHUD.h"
#import "BabyBluetooth.h"
#import "MJRefresh.h"
#import "MGSwipeButton.h"
#import "BlueToothTool.h"
#import "JUSTNavController.h"

#define reuseIdentify @"device"
#define tabbarViewH 60
// 扫描时间
#define scanTime 30

#define nameFilePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"name.plist"]

@interface JUSTDevicesViewController ()<RTDragCellTableViewDataSource,RTDragCellTableViewDelegate,MGSwipeTableCellDelegate>
{
    // 记录扫到设备的时间
    NSDate *insertingTime;
    // 记录扫到设备时的当前设备数
    NSUInteger insertingCount;
    // 连接状态改变的对象在peripheralModels下标
    NSUInteger connectedIndex;
    // 是否正在刷新
    BOOL isRefresh;
    
    CGFloat last;
}
/**
 *  缓存修改后的设备名
 */
@property (nonatomic, strong) NSMutableDictionary *nameDict;
/**
 *  下拉刷新背景颜色view
 */
@property (nonatomic, strong) UIView *refreshBgV;
/**
 *  间隔多久没扫到新设备则断开连接
 */
@property (nonatomic, assign) NSTimeInterval intervalTime;
/**
 *  未扫到设备定时器
 */
@property (nonatomic, strong) NSTimer *timer;
/**
 *  蓝牙
 */
@property (nonatomic, strong) BabyBluetooth *BLE;
/**
 *  设备模型
 */
@property (nonatomic, strong) NSMutableArray *peripheralModels;
/**
 *  可拖动的TableView
 */
@property (nonatomic, strong) RTDragCellTableView *tableV;
/**
 *  当前连接的外设
 */
@property (nonatomic, strong) CBPeripheral *currPeri;
/**
 *  当前连接外设的控制器
 */
@property (nonatomic, strong) JUSTPeripheralViewController *currPeriVc;
/**
 *  当前连接外设的模型
 */
@property (nonatomic, strong) JUSTPeripheral *currPeriModel;
@end

@implementation JUSTDevicesViewController

#pragma mark - view life circle  viewController生命周期方法
- (void)viewDidLoad {
    [super viewDidLoad];
    [self init_View];
    [self initBLE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.BLE cancelScan];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark - custom methods  自定义方法
- (void)init_View{
    self.title = @"我的设备";
    // 隐藏导航栏返回按钮
    self.navigationItem.leftBarButtonItem = nil;
    
    self.intervalTime = 5.0;
    
    // 导航栏右边关于按钮
    UIButton *aboutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    aboutBtn.frame = CGRectMake(0, 0, 21, 21);
    [aboutBtn setBackgroundImage:[UIImage imageNamed:@"about_n"] forState:UIControlStateNormal];
    [aboutBtn setBackgroundImage:[UIImage imageNamed:@"about_p"] forState:UIControlStateHighlighted];
    [aboutBtn addTarget:self action:@selector(aboutItemClick) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *aboutItem = [[UIBarButtonItem alloc]initWithCustomView:aboutBtn];
    self.navigationItem.rightBarButtonItem = aboutItem;

    // UITableView
    _tableV = [[RTDragCellTableView alloc] init];
    _tableV.frame = CGRectMake(0, 0, kScreenW, kScreenH);
    _tableV.allowsSelection = YES;
    _tableV.backgroundColor = [UIColor clearColor];
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableV];
    
    // 下拉
    _tableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(startScanPeripherals)];
    _tableV.mj_header.automaticallyChangeAlpha = YES;
    
    // 背景Image
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_image"]];
    bgImage.frame = CGRectMake(kScreenW * 0.1, kScreenH - kScreenH * 0.45, kScreenW * 0.8, kScreenH * 0.25);
    [self.view addSubview:bgImage];

    // 底部条
    UIView *bottomV = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenH - 44, kScreenW, 44)];
    bottomV.backgroundColor = [UIColor colorWithRed:0.98 green:0.98 blue:0.98 alpha:1.00];
    [self.view addSubview:bottomV];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.frame = CGRectMake(15, 10, 70, 10);
    label1.text = @"版本信息";
    label1.textColor = [UIColor colorWithRed:(142 / 255.0) green:(142 / 255.0) blue:(142 / 255.0) alpha:1.0];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.font = [UIFont systemFontOfSize:13];
    [bottomV addSubview:label1];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.frame = CGRectMake(15, 28, 70, 10);
    
    label2.text = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    label2.textColor = [UIColor colorWithRed:(142 / 255.0) green:(142 / 255.0) blue:(142 / 255.0) alpha:1.0];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.font = [UIFont systemFontOfSize:13];
    [bottomV addSubview:label2];
    
    UIButton *updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [updateBtn setTitle:@"升级" forState:UIControlStateNormal];
    [updateBtn setTitle:@"升级" forState:UIControlStateHighlighted];
    [updateBtn setBackgroundImage:[UIImage imageNamed:@"upgrade_btn_n"] forState:UIControlStateNormal];
    [updateBtn setBackgroundImage:[UIImage imageNamed:@"upgrade_btn_p"] forState:UIControlStateHighlighted];
    [updateBtn setTitleColor:[UIColor colorWithRed:0.13 green:0.51 blue:0.85 alpha:1.00] forState:UIControlStateNormal];
    [updateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [updateBtn addTarget:self action:@selector(updateBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    updateBtn.titleLabel.font = [UIFont systemFontOfSize:14];;
    [bottomV addSubview:updateBtn];
    updateBtn.frame = CGRectMake(kScreenW - 74, 11, 48, 26);
    
    self.refreshBgV = [[UIView alloc] initWithFrame:CGRectMake(0, -kScreenH, kScreenW, kScreenH)];
    self.refreshBgV.backgroundColor = RGBColor(0xe5e5e5);
    [self.view addSubview:self.refreshBgV];
    
    last = -54;
    // 注册通知 接收连接状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveConnectedStatus:) name:@"connectStatus" object:nil];
}
/**
 *  初始化蓝牙
 */
- (void)initBLE{
    [SVProgressHUD showInfoWithStatus:@"准备打开设备"];
    
    // 初始化蓝牙
    self.BLE = [BabyBluetooth shareBabyBluetooth];
    
    // 设置蓝牙委托
    [self BLEDelegate];
    
    // 扫描设备 30s停止
    self.BLE.scanForPeripherals().begin().stop(scanTime);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(31 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isRefresh) {
            [_tableV.mj_header endRefreshing];
            isRefresh = NO;
            [self.tableV reloadData];
        }
    });

}

/**
 *  蓝牙委托
 */
- (void)BLEDelegate{
    
    __weak typeof(self) weakSelf = self;
    
    // 设置状态改变的委托
    [self.BLE setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        if (central.state == CBCentralManagerStatePoweredOn) {
            [SVProgressHUD showSuccessWithStatus:@"蓝牙打开成功,开始扫描设备"];
            [weakSelf startScanPeripherals];
        }if (central.state != CBCentralManagerStatePoweredOn) {
            [weakSelf.tableV reloadData];
            [SVProgressHUD showErrorWithStatus:@"蓝牙已关闭"];
        }
    }];
    
    // 设置扫描设备过滤器
    [self.BLE setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
#warning 最终版要修改筛选条件
        // 外设名大于1
        if (peripheralName.length > 1 && [peripheralName hasPrefix:@"SH-HC"]) {
            return YES;
        }
        return NO;
    }];
    
    __block BOOL isContain = nil;
    __block JUSTPeripheral *justPeripheral = nil;
    // 设置扫描到外设的委托
    [self.BLE setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        YCLog(@"扫描到了设备:%@,,,%f,,,",peripheral.name,[RSSI floatValue]);
        isContain = NO;
        justPeripheral = [JUSTPeripheral peripheralWithName:peripheral.name RSSI:RSSI peripheral:peripheral];
        for (__strong JUSTPeripheral *peri in weakSelf.peripheralModels) {
            // 更新蓝牙信号格
            if ([peripheral.identifier.UUIDString isEqualToString:peri.peri.identifier.UUIDString]) {
                isContain = YES;
                peri.rssi = RSSI;
                [weakSelf.tableV reloadData];
            }
        }
        if (!isContain) {
            // 当扫到新设备的时候 重置定时器
            if (weakSelf.timer != nil) {
                [weakSelf.timer invalidate];
                weakSelf.timer = nil;
            }
            weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:weakSelf.intervalTime target:weakSelf selector:@selector(stopScanPeri:) userInfo:nil repeats:NO];
            [weakSelf.peripheralModels addObject:justPeripheral];
            // 记录扫到数据时的设备总数
            insertingCount = weakSelf.peripheralModels.count;
            [weakSelf.tableV reloadData];
        }
//        [weakSelf insertPeripheralToTableView:peripheral advertisementData:advertisementData];
    }];
    
    // 忽略同一个扫描多次
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    [self.BLE setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}

#pragma mark 下拉刷新
- (void)startScanPeripherals{
    if (self.BLE.centralManager.state != CBCentralManagerStatePoweredOn) {
        [BlueToothTool showOpenBlueToothTip:(JUSTNavController *)self.navigationController tableView:self.tableV];
    }
    [self.BLE cancelAllPeripheralsConnection];
    isRefresh = YES;
    [self.BLE cancelScan];
   
    [self.tableV cancelLongPress];
    [self.peripheralModels removeAllObjects];
    [self.tableV reloadData];
    
    self.currPeri = nil;
    self.currPeriVc = nil;
    
    // 扫描设备 30s停止
    self.BLE.scanForPeripherals().begin().stop(scanTime);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(31 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (isRefresh) {
            [_tableV.mj_header endRefreshing];
            isRefresh = NO;
            [self.tableV reloadData];
        }
    });
}

#pragma mark 连接状态改变通知回调
- (void)receiveConnectedStatus:(NSNotification *)notice{
    BOOL connectStatus = [notice.userInfo[@"connectStatus"] boolValue];
    
    if (connectStatus) {
        self.currPeri = [[self.BLE findConnectedPeripherals] firstObject];
    }
    for (JUSTPeripheral *peripheral in self.peripheralModels) {
        if ([self.currPeri.identifier.UUIDString isEqualToString:peripheral.peri.identifier.UUIDString]) {
            connectedIndex = [self.peripheralModels indexOfObject:peripheral];
        }
    }
    if (self.peripheralModels == nil || self.peripheralModels.count == 0) {
        return;
    }
    JUSTPeripheral *peri = self.peripheralModels[connectedIndex];
    self.currPeriModel = peri;
    peri.isConnected = connectStatus;
    [self.tableV reloadData];
}

/**
 *  规定时间内没扫描到设备则停止扫描
 *
 *  @param timer 定时器
 */
- (void)stopScanPeri:(NSTimer *)timer{
    if (insertingCount == self.peripheralModels.count) {
        [_tableV.mj_header endRefreshing];
        YCLog(@"%lfs未扫描到设备,暂停扫描",self.intervalTime);
        isRefresh = NO;
        [self.tableV reloadData];
        [self.tableV startLongPress];
        [self.BLE cancelScan];
        [self.timer invalidate];
        self.timer = nil;

    }
}

#pragma mark 按钮点击事件
// 关于按钮点击响应
- (void)aboutItemClick{
    JUSTAboutViewController *aboutVc = [[JUSTAboutViewController alloc] init];
    [self.navigationController pushViewController:aboutVc animated:YES];
}

// 升级按钮点击响应
- (void)updateBtnDidClick{
    
}

#pragma mark 设置分割线顶头
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([self.tableV respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableV setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableV respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableV setLayoutMargins:UIEdgeInsetsZero];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark KVO

#pragma mark - sources and delegates 代理、协议方法
#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.peripheralModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    JUSTDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentify];
    JUSTDeviceTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [JUSTDeviceTableViewCell cellWithTableView:tableView];
    }
    cell.delegate = self;
    
    JUSTPeripheral *peripheral = self.peripheralModels[indexPath.row];
    // 没有刷新状态 显示左滑按钮
    if (!isRefresh) {
        __weak typeof(self) weakSelf = self;
        cell.swipeBackgroundColor = [UIColor clearColor];
        MGSwipeButton *swipeEditBtn = [MGSwipeButton buttonWithNormalImage:@"rechristen_n" highlightedImage:@"rechristen_p" callback:^BOOL(MGSwipeTableCell *sender) {
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"修改标题" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *sureAct = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                JUSTPeripheral *peri = self.peripheralModels[indexPath.row];
                NSString *identify = peri.peri.identifier.UUIDString;
                NSString *newName = alertVc.textFields.firstObject.text;
                [weakSelf.nameDict setObject:newName forKey:identify];
                // 写入存储
                [weakSelf.nameDict writeToFile:nameFilePath atomically:YES];
                peri.name = newName;
                [self.peripheralModels replaceObjectAtIndex:indexPath.row withObject:peri];
                [self.tableV reloadData];
                
            }];
            UIAlertAction *cancelAct = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertVc addAction:sureAct];
            [alertVc addAction:cancelAct];
            [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                
                textField.placeholder = @"请输入新的标题";
                
                textField.text = peripheral.name;
            }];
            
            [self presentViewController:alertVc animated:YES completion:nil];
            return YES;
        }];
        
        MGSwipeButton *swipeDelBtn = [MGSwipeButton buttonWithNormalImage:@"delete_n" highlightedImage:@"delete_p" callback:^BOOL(MGSwipeTableCell *sender) {
            JUSTPeripheral *peri = self.peripheralModels[indexPath.row];
            NSString *identify = peri.peri.identifier.UUIDString;
            [weakSelf.nameDict setObject:peri.peri.name forKey:identify];
            // 写入存储
            [weakSelf.nameDict writeToFile:nameFilePath atomically:YES];
            
            [weakSelf.BLE cancelAllPeripheralsConnection];
            NSIndexPath *cellIndexPath = [weakSelf.tableV indexPathForCell:cell];
            [weakSelf.peripheralModels removeObjectAtIndex:cellIndexPath.row];
            [weakSelf.tableV deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            weakSelf.currPeri = nil;
            return YES;
        }];
        cell.rightButtons = @[swipeDelBtn,swipeEditBtn];
        cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
    }
    
    // 读存储
    self.nameDict = [NSMutableDictionary dictionaryWithContentsOfFile:nameFilePath];
    
    if (self.nameDict[peripheral.peri.identifier.UUIDString]) {
        peripheral.name = self.nameDict[peripheral.peri.identifier.UUIDString];
    }
    cell.peri = peripheral;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    isRefresh = NO;
    [_tableV.mj_header endRefreshing];
    [self.tableV startLongPress];
    // 停止扫描
    [self.BLE cancelScan];
    [self.timer invalidate];
    self.timer = nil;
    
    JUSTPeripheral *peri = self.peripheralModels[indexPath.row];
    CBPeripheral *peripheral = peri.peri;
    JUSTPeripheralViewController *periVc = nil;
    // 连接的是否是已连接的外设
//    if (self.currPeri != peripheral) {
//        [self.BLE cancelAllPeripheralsConnection];
//        self.currPeri = nil;
//    }
    [self.tableV reloadData];
    // 没有连接外设 或者 连接的外设不是已连接的外设
    if (self.currPeriVc == nil || self.currPeri != peripheral) {
        [self.BLE cancelAllPeripheralsConnection];
        self.currPeri = nil;
        periVc = [[JUSTPeripheralViewController alloc] init];
        self.currPeriVc = periVc;
        periVc.isConnected = NO;
        periVc.currPeripheral = peripheral;
        periVc->BLE = self.BLE;
        self.currPeri = peripheral;
    }
    // 已连接外设
    else{
        periVc = self.currPeriVc;
    }
    [self.navigationController pushViewController:periVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect frame = self.refreshBgV.frame;
    frame.origin.y = frame.origin.y - (scrollView.contentOffset.y - last);
    self.refreshBgV.frame = frame;
    last = scrollView.contentOffset.y;
    [self.view setNeedsLayout];
}

#pragma mark RTDragCellTableView
- (NSArray *)originalArrayDataForTableView:(RTDragCellTableView *)tableView{
    return [self.peripheralModels copy];
}

- (void)tableView:(RTDragCellTableView *)tableView newArrayDataForDataSource:(NSArray *)newArray{
    self.peripheralModels = [newArray mutableCopy];
}

#pragma mark - getters and setters 属性的设置和获取方法
- (NSMutableArray *)peripheralModels{
    if (!_peripheralModels) {
        _peripheralModels = [NSMutableArray array];
    }
    return _peripheralModels;
}

- (NSMutableDictionary *)nameDict{
    if (!_nameDict) {
        _nameDict = [[NSMutableDictionary alloc] init];
    }
    return _nameDict;
}

- (void)dealloc{
    [self.timer invalidate];
    self.timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectStatus" object:nil];;
}
@end
