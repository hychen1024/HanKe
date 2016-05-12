//
//  VWWWaterView.h
//  Water Waves
//
//  Created by Veari_mac02 on 14-5-23.
//  Copyright (c) 2014年 Veari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WaterView : UIView
@property (nonatomic, strong) UIColor *currentWaterColor;
/**
 *  水的比例
 */
@property (nonatomic, assign) float ratio;
@end
