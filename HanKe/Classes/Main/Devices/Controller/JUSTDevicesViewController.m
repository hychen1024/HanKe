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
#import <CoreBluetooth/CoreBluetooth.h>
#import "JUSTPeripheralViewController.h"
#import "JUSTDeviceTableViewCell.h"
#import "JUSTAboutViewController.h"
#import "SVProgressHUD.h"
#import "BabyBluetooth.h"
#import "MJRefresh.h"

#define reuseIdentify @"device"
#define tabbarViewH 60
#define scanTime 30
@interface JUSTDevicesViewController ()<RTDragCellTableViewDataSource,RTDragCellTableViewDelegate,SWTableViewCellDelegate>
/**
 *  蓝牙
 */
@property (nonatomic, strong) BabyBluetooth *BLE;
/**
 *  缓存扫描到的设备
 */
@property (nonatomic, strong) NSMutableArray *peripherals;
/**
 *
 */
@property (nonatomic, strong) NSMutableArray *peripheralModels;
/**
 *  缓存扫描到设备的advertisementData
 */
@property (nonatomic, strong) NSMutableArray *peripheralsAD;
/**
 *  可拖动的TableView
 */
@property (nonatomic, strong) RTDragCellTableView *tableV;
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
    self.BLE.scanForPeripherals().begin().stop(scanTime);
}

- (void)viewDidDisappear:(BOOL)animated{
    [self.BLE cancelScan];
}

#pragma mark - custom methods  自定义方法
- (void)init_View{
    self.title = @"我的设备";
    // 隐藏导航栏返回按钮
    self.navigationItem.leftBarButtonItem = nil;
    
    // 导航栏右边关于按钮
    UIButton *aboutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    aboutBtn.frame = CGRectMake(0, 0, 21, 21);
    [aboutBtn setBackgroundImage:[UIImage imageNamed:@"about_n"] forState:UIControlStateNormal];
    [aboutBtn setBackgroundImage:[UIImage imageNamed:@"about_p"] forState:UIControlStateHighlighted];
    [aboutBtn addTarget:self action:@selector(aboutItemClick) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *aboutItem = [[UIBarButtonItem alloc]initWithCustomView:aboutBtn];
    self.navigationItem.rightBarButtonItem = aboutItem;
    
    _tableV = [[RTDragCellTableView alloc] init];
    _tableV.frame = CGRectMake(0, 0, kScreenW, kScreenH);
    _tableV.allowsSelection = YES;
    _tableV.backgroundColor = [UIColor clearColor];
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableV];
    
    _tableV.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(startScanPeripherals)];
    _tableV.mj_header.automaticallyChangeAlpha = YES;
    
    
    UIView *bottomV = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenH - 108, kScreenW, 44)];
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
}

/**
 *  蓝牙委托
 */
- (void)BLEDelegate{
    
    __weak typeof(self) weakSelf = self;
    
    // 设置状态改变的委托
    [self.BLE setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        weakSelf.BLE.scanForPeripherals().begin().stop(scanTime);
        if (central.state == CBCentralManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:@"蓝牙打开成功,开始扫描设备"];
        }if (central.state != CBCentralManagerStatePoweredOn) {
            [SVProgressHUD showInfoWithStatus:@"请打开蓝牙"];
        }
    }];
    
    // 设置扫描设备过滤器
    [self.BLE setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        // 外设名大于1
        if (peripheralName.length > 1) {
            return YES;
        }
        return NO;
    }];
    
    __block BOOL isContain = nil;

    // 设置扫描到外设的委托
    [self.BLE setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        YCLog(@"扫描到了设备:%@,,,%f,,,",peripheral.name,[RSSI floatValue]);
        isContain = NO;
        JUSTPeripheral *justPeripheral = [JUSTPeripheral peripheralWithName:peripheral.name RSSI:RSSI peripheral:peripheral];
        
        for (__strong JUSTPeripheral *peri in weakSelf.peripheralModels) {
            if ([peri.name isEqualToString:peripheral.name]) {
                isContain = YES;
//                peri = justPeripheral;
                peri.rssi = RSSI;
                [weakSelf.tableV reloadData];
            }
        }
        if (!isContain) {
            [weakSelf.peripheralModels addObject:justPeripheral];
        }
        [weakSelf insertPeripheralToTableView:peripheral advertisementData:advertisementData];
    }];
    
    // 忽略同一个扫描多次
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    [self.BLE setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}

- (void)startScanPeripherals{
    [self.BLE cancelScan];
    // 扫描设备 30s停止
    self.BLE.scanForPeripherals().begin().stop(scanTime);
    // 下来刷新持续一秒效果
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_tableV.mj_header endRefreshing];
    });
}

#pragma mark 滑动按钮
/**
 *  左滑出现的按钮
 */
- (NSArray *)rightBtns{
    NSMutableArray *rightBtns = [NSMutableArray new];
    [rightBtns sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[UIImage imageNamed:@"rechristen_n"] selectedIcon:[UIImage imageNamed:@"rechristen_p"]];
    [rightBtns sw_addUtilityButtonWithColor:[UIColor clearColor] normalIcon:[UIImage imageNamed:@"delete_n"] selectedIcon:[UIImage imageNamed:@"delete_p"]];
    return [rightBtns copy];
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

/**
 *  插入TableView数据
 *
 *  @param peripheral        设备
 *  @param advertisementData 广播数据
 */
- (void)insertPeripheralToTableView:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData{
    if (![self.peripherals containsObject:peripheral]) {
        NSMutableArray *indexPaths = [NSMutableArray array];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.peripherals.count inSection:0];
        [indexPaths addObject:indexPath];
        [self.peripherals addObject:peripheral];
        [self.peripheralsAD addObject:peripheral];
        [self.tableV insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark KVO

#pragma mark - sources and delegates 代理、协议方法
#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JUSTDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentify];
    if (cell == nil) {
        cell = [JUSTDeviceTableViewCell cellWithTableView:tableView];
        cell.delegate = self;
        cell.rightUtilityButtons = [self rightBtns];
    }
    JUSTPeripheral *peripheral = self.peripheralModels[indexPath.row];
    cell.peri = peripheral;
    cell.isConnected = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 停止扫描
    [self.BLE cancelScan];
    CBPeripheral *peripheral = self.peripherals[indexPath.row];
    
    JUSTPeripheralViewController *periVc = [[JUSTPeripheralViewController alloc] init];
    
    periVc.currPeripheral = peripheral;
    periVc->BLE = self.BLE;
    periVc.isConnected = NO;
    [self.navigationController pushViewController:periVc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

#pragma mark RTDragCellTableView
- (NSArray *)originalArrayDataForTableView:(RTDragCellTableView *)tableView{
    return [self.peripherals copy];
}

- (void)tableView:(RTDragCellTableView *)tableView newArrayDataForDataSource:(NSArray *)newArray{
    self.peripherals = [newArray mutableCopy];
}

#pragma mark SWTableViewCell
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index{
    switch (index) {
        case 1://删除按钮
        {
            NSIndexPath *cellIndexPath = [self.tableV indexPathForCell:cell];
            YCLog(@"deleteBtnDidClick,,,,,%ld",cellIndexPath.row);
            [self.peripherals removeObjectAtIndex:cellIndexPath.row];
            [self.peripheralModels removeObjectAtIndex:cellIndexPath.row];
            [self.tableV deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        }
        case 0://编辑按钮
        {
            YCLog(@"editBtnDidClick");
            break;
        }
        default:
            break;
    }
}

#pragma mark - getters and setters 属性的设置和获取方法
- (NSMutableArray *)peripherals{
    if (!_peripherals) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

- (NSMutableArray *)peripheralsAD{
    if (!_peripheralsAD) {
        _peripheralsAD = [NSMutableArray array];
    }
    return _peripheralsAD;
}

- (NSMutableArray *)peripheralModels{
    if (!_peripheralModels) {
        _peripheralModels = [NSMutableArray array];
    }
    return _peripheralModels;
}


@end
