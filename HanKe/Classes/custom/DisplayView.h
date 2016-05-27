//
//  DisplayView.h
//  HanKe
//
//  Created by Just-h on 16/5/27.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICountingLabel.h"
#import "THCircularProgressView.h"

typedef enum{
    displayViewTypeDisconnect, // 未连接
    displayViewTypeConnect, // 已连接
    displayViewTypeExhaust // 耗材用尽
}displayViewType;

@interface DisplayView : UIView

/**
 *  请更换耗材提示
 */
@property (weak, nonatomic) IBOutlet UIButton *ChangeTip;
/**
 *  未连接View
 */
@property (weak, nonatomic) IBOutlet UIImageView *DisconnectView;
/**
 *  水疗状态
 */
@property (weak, nonatomic) IBOutlet UIButton *HydroStatus;
/**
 *  耗材剩余文字
 */
@property (weak, nonatomic) IBOutlet UILabel *ResidueLb;
/**
 *  百分符号
 */
@property (weak, nonatomic) IBOutlet UILabel *PercentageLb;
/**
 *  耗材剩余数字
 */
@property (weak, nonatomic) IBOutlet UICountingLabel *ConsumeLb;
/**
 *  圆环图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *CircleView;
/**
 *  圆环动画View
 */
@property (weak, nonatomic) IBOutlet THCircularProgressView *CircleProgressView;
/**
 *  全局圆环百分比View
 */
@property (nonatomic, strong) THCircularProgressView *circleNumView;

@property (nonatomic, assign) displayViewType viewType;

+ (instancetype)displayView;

@end
