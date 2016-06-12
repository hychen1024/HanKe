//
//  DisplayView.m
//  HanKe
//
//  Created by Just-h on 16/5/27.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "DisplayView.h"
#import "UIView+SDAutoLayout.h"


@interface DisplayView ()


@end
@implementation DisplayView

+ (instancetype)displayView{
    DisplayView *display = [[[NSBundle mainBundle] loadNibNamed:@"DisplayView" owner:self options:nil] firstObject];
    CGFloat selfH = display.frame.size.height;
    display.DisconnectView.sd_layout.topEqualToView(display).widthIs(display.frame.size.height * 0.68).heightEqualToWidth().centerXEqualToView(display);
    display.ChangeTip.sd_layout.topEqualToView(display).widthIs(display.frame.size.height * 0.68).heightEqualToWidth().centerXEqualToView(display);
    display.CircleProgressView.sd_layout.topEqualToView(display).widthIs(selfH * 0.68).heightEqualToWidth().centerXEqualToView(display);
    display.CircleView.sd_layout.topSpaceToView(display,selfH * 0.057).widthIs(selfH * 0.571).heightEqualToWidth().centerXEqualToView(display);
    display.ConsumeLb.sd_layout.topSpaceToView(display,selfH * 0.057).widthIs(selfH * 0.571).heightEqualToWidth().centerXEqualToView(display);
    display.PercentageLb.sd_layout.widthIs(42).heightIs(26).centerXEqualToView(display).offset(20).centerYEqualToView(display.DisconnectView).offset(-35);
    display.ResidueLb.sd_layout.widthIs(selfH * 0.286).heightIs(21).centerXEqualToView(display).centerYEqualToView(display.DisconnectView).offset(display.DisconnectView.frame.size.height * 0.16);
    display.HydroStatus.sd_layout.widthIs(80).heightIs(32).centerXEqualToView(display).bottomSpaceToView(display,selfH * 0.05);
    return display;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"DisplayView" owner:self options:nil] firstObject];
        CGFloat selfH = self.frame.size.height;
        self.DisconnectView.sd_layout.topEqualToView(self).widthIs(self.frame.size.height * 0.68).heightEqualToWidth().centerXEqualToView(self);
        self.ChangeTip.sd_layout.topEqualToView(self).widthIs(self.frame.size.height * 0.68).heightEqualToWidth().centerXEqualToView(self);
        self.CircleProgressView.sd_layout.topEqualToView(self).widthIs(selfH * 0.68).heightEqualToWidth().centerXEqualToView(self);
        self.CircleView.sd_layout.topSpaceToView(self,selfH * 0.057).widthIs(selfH * 0.571).heightEqualToWidth().centerXEqualToView(self);
        self.ConsumeLb.sd_layout.topSpaceToView(self,selfH * 0.057).widthIs(selfH * 0.571).heightEqualToWidth().centerXEqualToView(self);
        self.PercentageLb.sd_layout.widthIs(42).heightIs(26).centerXEqualToView(self).offset(20).centerYEqualToView(self.DisconnectView).offset(-35);
        self.ResidueLb.sd_layout.widthIs(selfH * 0.286).heightIs(21).centerXEqualToView(self).centerYEqualToView(self.DisconnectView).offset(self.DisconnectView.frame.size.height * 0.16);
        self.HydroStatus.sd_layout.widthIs(80).heightIs(32).centerXEqualToView(self).bottomSpaceToView(self,selfH * 0.05);
    }
    return self;
}

//布局子控件
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
