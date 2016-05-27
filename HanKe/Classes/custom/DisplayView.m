//
//  DisplayView.m
//  HanKe
//
//  Created by Just-h on 16/5/27.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "DisplayView.h"


@interface DisplayView ()


@end
@implementation DisplayView

+ (instancetype)displayView{
    return [[[NSBundle mainBundle] loadNibNamed:@"DisplayView" owner:self options:nil] firstObject];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"DisplayView" owner:self options:nil] firstObject];
    }
    return self;
}

// 布局子控件
//- (void)layoutSubviews{
//
//}

- (void)setViewType:(displayViewType)viewType{
    _viewType = viewType;
    if (viewType == displayViewTypeConnect) {
        // 百分比圆环
        CGRect circleProgressVFrame = self.CircleProgressView.frame;
        THCircularProgressView *circleNumV = [[THCircularProgressView alloc] initWithFrame:circleProgressVFrame];
        circleNumV.lineWidth = 7;
        circleNumV.radius = circleProgressVFrame.size.width * 0.5;
        circleNumV.progressBackgroundColor = [UIColor colorWithRed:0.13 green:0.47 blue:0.76 alpha:1.00];
        circleNumV.progressColor = [UIColor whiteColor];
        circleNumV.percentage = [self.ConsumeLb.text floatValue] * 0.01;
        [self.CircleProgressView.superview addSubview:circleNumV];
        circleNumV.hidden = YES;
        self.circleNumView = circleNumV;
        
        self.ConsumeLb.format = @"%d";
        self.ConsumeLb.method = UILabelCountingMethodLinear;
        self.DisconnectView.hidden = YES;
        self.ChangeTip.hidden = YES;

        self.ResidueLb.hidden = NO;
        self.PercentageLb.hidden = NO;
        self.ConsumeLb.hidden = NO;
        self.CircleView.hidden = NO;
        self.CircleProgressView.hidden = NO;
        self.circleNumView.hidden = NO;
    }else if (viewType == displayViewTypeExhaust){
        self.DisconnectView.hidden = YES;
        self.ChangeTip.hidden = NO;
        
        self.ResidueLb.hidden = YES;
        self.PercentageLb.hidden = YES;
        self.ConsumeLb.hidden = YES;
        self.CircleView.hidden = YES;
        self.CircleProgressView.hidden = YES;
        self.circleNumView.hidden = YES;
    }else if (viewType == displayViewTypeDisconnect){
        self.DisconnectView.hidden = NO;
        
        self.ChangeTip.hidden = YES;
        self.ResidueLb.hidden = YES;
        self.PercentageLb.hidden = YES;
        self.ConsumeLb.hidden = YES;
        self.CircleView.hidden = YES;
        self.CircleProgressView.hidden = YES;
        self.circleNumView.hidden = YES;
    }
}

@end
