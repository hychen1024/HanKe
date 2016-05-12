//
//  JUSTSearchCell.m
//  HanKe
//
//  Created by Just-h on 16/4/29.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "JUSTSearchCell.h"
#import "WaterView.h"


#define reuseIdentify @"search"
@interface JUSTSearchCell ()

/**
 *  信号强度View
 */
@property (weak, nonatomic) IBOutlet UIView *iconView;
/**
 *  设备名
 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
/**
 *  指示图标
 */
@property (weak, nonatomic) IBOutlet UIImageView *indicatorView;

@property (nonatomic, strong) WaterView *waterV;
@end
@implementation JUSTSearchCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (instancetype)searchCellWithTableView:(UITableView *)tableV{
    JUSTSearchCell *cell = [tableV dequeueReusableCellWithIdentifier:reuseIdentify];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"JUSTSearchCell" owner:self options:nil] firstObject];
        CGRect frame = cell.iconView.frame;
        WaterView *waterV = [[WaterView alloc] initWithFrame:frame];
        waterV.currentWaterColor = [UIColor colorWithRed:86/255.0f green:202/255.0f blue:139/255.0f alpha:1];
        waterV.ratio = 0.8;
        waterV.layer.cornerRadius = CGRectGetHeight(frame) * 0.5;
        waterV.layer.masksToBounds = YES;
        waterV.layer.borderWidth = 2;
        cell.iconView = waterV;
        [cell.contentView addSubview:waterV];
        
    }
    return cell;
}

- (void)setPeripheral:(JUSTPeripheral *)peripheral{
    _peripheral = peripheral;
    self.nameLabel.text = peripheral.name;
}

@end
