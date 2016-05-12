//
//  JUSTDeviceTableViewCell.m
//  HanKe
//
//  Created by Just-h on 16/4/28.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "JUSTDeviceTableViewCell.h"

@interface JUSTDeviceTableViewCell ()
/**
 *  信号图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *signView;
/**
 *  水疗机名
 */
@property (weak, nonatomic) IBOutlet UILabel *periName;
/**
 *  连接按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *connectBtn;
/**
 *  信号背景图
 */
@property (weak, nonatomic) IBOutlet UIImageView *signbgView;

@end
@implementation JUSTDeviceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)cellWithTableView:(UITableView *)tableView{
    JUSTDeviceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"JUSTDeviceTableViewCell" owner:self options:nil] firstObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
        // 设置信号默认背景
        cell.signbgView.image = [UIImage imageNamed:@"signal_bg"];
    }
    return cell;
}

- (void)setPeri:(JUSTPeripheral *)peri{
    _peri = peri;
    float rssi = [peri.rssi floatValue];
    self.periName.text = peri.name;
    // 分段表示信号强度
    if (rssi >= -100 && rssi < -90) {
        self.signView.image = [UIImage imageNamed:@"signal_01"];
    }else if (rssi >= -90 && rssi <- 80){
        self.signView.image = [UIImage imageNamed:@"signal_02"];
    }else if (rssi >= -80 && rssi <- 70){
        self.signView.image = [UIImage imageNamed:@"signal_03"];
    }else if (rssi >= -70 && rssi <- 50){
        self.signView.image = [UIImage imageNamed:@"signal_04"];
    }else if (rssi >= -50 && rssi < 0){
        self.signView.image = [UIImage imageNamed:@"signal_05"];
    }else
        self.signView.image = nil;
}

- (void)setIsConnected:(bool)isConnected{
    _isConnected = isConnected;
    self.connectBtn.selected = isConnected;
}
@end