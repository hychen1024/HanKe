//
//  JUSTSearchViewController.m
//  HanKe
//
//  Created by Just-h on 16/4/28.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "JUSTSearchViewController.h"
#import "BabyBluetooth.h"
#import "SVProgressHUD.h"
#import "JUSTSearchCell.h"
#import "JUSTPeripheral.h"
#import "JUSTPeripheralViewController.h"


@interface JUSTSearchViewController ()<UITableViewDelegate,UITableViewDataSource>
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
 *  UITableView
 */
@property (nonatomic, strong) UITableView *tableV;
@end

@implementation JUSTSearchViewController


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
    self.BLE.scanForPeripherals().begin();
}

- (void)viewDidDisappear:(BOOL)animated{
    [self.BLE cancelScan];
}

#pragma mark - custom methods  自定义方法

- (void)init_View{
    self.tableV = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableV.backgroundColor = [UIColor clearColor];
    self.tableV.delegate = self;
    self.tableV.dataSource = self;
    [self.view addSubview:self.tableV];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backBtnDidClick)];
        self.navigationItem.leftBarButtonItem = backItem;
    
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(refreshBtnDidClick)];
        self.navigationItem.rightBarButtonItem = refreshItem;
}

/**
 *  初始化蓝牙
 */
- (void)initBLE{
    // 初始化蓝牙
    self.BLE = [BabyBluetooth shareBabyBluetooth];
    
    // 设置蓝牙委托
    [self BLEDelegate];
}

/**
 *  蓝牙委托
 */
- (void)BLEDelegate{
    
    __weak typeof(self.BLE) weakBLE = self.BLE;
    __weak typeof(self) weakSelf = self;
    
    [self.BLE setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
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
    
    // 设置扫描到外设的委托
    [self.BLE setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        CGFloat periRSSI = [RSSI floatValue];
        YCLog(@"扫描到了设备:%@,,,%f,,,%@",peripheral.name,periRSSI,peripheral.identifier);
        JUSTPeripheral *justPeripheral = [JUSTPeripheral peripheralWithName:peripheral.name RSSI:RSSI peripheral:peripheral];
        if (![weakSelf.peripheralModels containsObject:justPeripheral]) {
            [weakSelf.peripheralModels addObject:justPeripheral];
        }
        [weakSelf insertPeripheralToTableView:peripheral advertisementData:advertisementData];
    }];
    
//    // 设置连接成功的委托
//    [self.BLE setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
//        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"连接设备:<%@>成功",peripheral.name]];
//        // 取消扫描
//        [weakBLE cancelScan];
//    }];
//    
//    // 设置连接失败的委托
//    [self.BLE setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
//       [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"连接设备:<%@>失败",peripheral.name]];
//    }];
    
    // 忽略同一个扫描多次
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    [self.BLE setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
}

#pragma mark 返回按钮响应
- (void)backBtnDidClick{
    [self.BLE cancelScan];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 刷新按钮响应
- (void)refreshBtnDidClick{
    [self.peripherals removeAllObjects];
    [self.tableV reloadData];
    self.BLE.scanForPeripherals().begin();
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

- (void)connectToPeripheral:(NSIndexPath *)indexPath{
    [SVProgressHUD showWithStatus:@"正在连接设备..."];
    CBPeripheral *currPeripheral = [self.peripherals objectAtIndex:indexPath.row];
    [SVProgressHUD showInfoWithStatus:@"开始连接设备"];
    
    // 开始连接设备
    self.BLE.having(currPeripheral).connectToPeripherals().discoverServices().discoverCharacteristics().readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
}

#pragma mark - sources and delegates 代理、协议方法
#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JUSTSearchCell *cell = [JUSTSearchCell searchCellWithTableView:tableView];
    cell.peripheral = self.peripherals[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    [self.tableV deselectRowAtIndexPath:indexPath animated:YES];
    // 停止扫描
    [self.BLE cancelScan];
    // 连接设备
    [self connectToPeripheral:indexPath];
    JUSTPeripheral *peripheralModel = self.peripheralModels[indexPath.row];
    CBPeripheral *peripheral = self.peripherals[indexPath.row];
    
    NSDictionary *dict = @{
                @"peripheralModel":peripheralModel,
                @"peripheral":peripheral
                           };
    // 通知传递数据
    [[NSNotificationCenter defaultCenter] postNotificationName:@"peripherals" object:nil userInfo:dict];
    
    JUSTPeripheralViewController *periVc = [[JUSTPeripheralViewController alloc] init];
    periVc.title = @"水疗设备";
    periVc.currPeripheral = peripheral;
    periVc->BLE = self.BLE;
    [self.navigationController pushViewController:periVc animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

#pragma mark - getters and setters 属性的设置和获取方法
- (NSMutableArray *)peripherals{
    if (!_peripherals) {
        _peripherals = [NSMutableArray array];
#warning 信号
//        JUSTPeripheral *peri = [JUSTPeripheral peripheralWithName:@"sdfsdf" RSSI:32];
//        _peripherals = [@[peri] mutableCopy];
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
