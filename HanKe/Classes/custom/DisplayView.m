//
//  DisplayView.m
//  HanKe
//
//  Created by Just-h on 16/5/27.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "DisplayView.h"
#import "UIView+SDAutoLayout.h"
#import "Masonry.h"
#import "YCButton.h"


@interface DisplayView ()


@end
@implementation DisplayView

+ (instancetype)displayView{
    DisplayView *display = [[[NSBundle mainBundle] loadNibNamed:@"DisplayView" owner:self options:nil] firstObject];

    return display;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"DisplayView" owner:self options:nil] firstObject];
        
    }
    return self;
}

- (void)prepareUI{
    CGFloat selfH = self.frame.size.height;
    [self.DisconnectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(selfH * 0.68, selfH * 0.68));
    }];
    
    [self.ChangeTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(selfH * 0.68, selfH * 0.68));
    }];
    
    [self.CircleProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(selfH * 0.68, selfH * 0.68));
    }];
    
    [self.CircleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(selfH * 0.057);
        make.size.mas_equalTo(CGSizeMake(selfH * 0.571, selfH * 0.571));
        make.centerX.equalTo(self);
    }];
    
    [self.ConsumeLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(selfH * 0.057);
        make.size.mas_equalTo(CGSizeMake(selfH * 0.571, selfH * 0.571));
        make.centerX.equalTo(self);
    }];
    
    [self.PercentageLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(42, 26));
        make.centerX.equalTo(self).offset(30);
        make.centerY.equalTo(self.DisconnectView).offset(-35);
    }];

    [self.ResidueLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(selfH * 0.286, 21));
        make.centerX.equalTo(self);
        make.centerY.equalTo(self.DisconnectView).offset(self.DisconnectView.frame.size.height * 0.20);
    }];

    [self.HydroStatus mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(90, 32));
//        make.centerX.equalTo(self);
        make.top.equalTo(self.DisconnectView.mas_bottom).offset(selfH * 0.07);
        make.height.equalTo(@28);
        make.width.greaterThanOrEqualTo(@100);
        make.width.lessThanOrEqualTo(@250);
        make.centerX.equalTo(self);
    }];
    
    if (IS_IPHONE_4_OR_LESS) {
        self.ResidueLb.font = [UIFont systemFontOfSize:14];
        [self.PercentageLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(42, 26));
            make.centerX.equalTo(self).offset(25);
            make.centerY.equalTo(self.DisconnectView).offset(-35);
        }];
    }
}

- (void)setViewType:(displayViewType)viewType{
    CGFloat selfH = self.frame.size.height;
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
        [self addSubview:circleNumV];
        circleNumV.hidden = YES;
        if (IS_IPHONE_6P) {
            [circleNumV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.CircleView);
                make.size.mas_equalTo(CGSizeMake(selfH * 0.75, selfH * 0.75));
            }];
        }
        if (IS_IPHONE_6) {
            [circleNumV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.CircleView);
                make.size.mas_equalTo(CGSizeMake(selfH * 0.67, selfH * 0.67));
            }];
        }
        if (IS_IPHONE_5) {
            [circleNumV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.CircleView);
                make.size.mas_equalTo(CGSizeMake(selfH * 0.58, selfH * 0.58));
            }];
        }
        if (IS_IPHONE_4_OR_LESS) {
            [circleNumV mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.CircleView);
                make.size.mas_equalTo(CGSizeMake(selfH * 0.50, selfH * 0.50));
            }];
        }

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
