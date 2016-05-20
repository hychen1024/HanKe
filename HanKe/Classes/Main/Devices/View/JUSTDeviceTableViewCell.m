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
 *  连接状态图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *connectImage;

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
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
        UIView *cellBg = [[UIView alloc] init];
        cellBg.backgroundColor = RGBColor(0xf8f8f8);
        cell.selectedBackgroundView = cellBg;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return cell;
}

- (void)setPeri:(JUSTPeripheral *)peri{
    _peri = peri;
    float rssi = [peri.rssi floatValue];
    self.periName.text = peri.name;
    if (peri.isConnected) {
        self.connectImage.image = [UIImage imageNamed:@"connected"];
    }else{
        self.connectImage.image = [UIImage imageNamed:@"disconnected"];
    }
    // 分段表示信号强度
    if (rssi == 127 || rssi == -127) {
        if (self.signView.image == nil) {
            self.signView.image = [UIImage imageNamed:@"signal_bg"];
        }
        return;
    }
    if (rssi >= -127 && rssi < -90) {
        self.signView.image = [UIImage imageNamed:@"signal_bg"];
    }else if (rssi >= -90 && rssi <- 80){
        self.signView.image = [UIImage imageNamed:@"signal_01"];
    }else if (rssi >= -80 && rssi <- 70){
        self.signView.image = [UIImage imageNamed:@"signal_02"];
    }else if (rssi >= -70 && rssi <- 60){
        self.signView.image = [UIImage imageNamed:@"signal_03"];
    }else if (rssi >= -60 && rssi <- 50){
        self.signView.image = [UIImage imageNamed:@"signal_04"];
    }else if (rssi >= -50 && rssi < 0){
        self.signView.image = [UIImage imageNamed:@"signal_05"];
    }else
        self.signView.image = nil;
}

@end
