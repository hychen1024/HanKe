//
//  AboutViewController.m
//  HanKe
//
//  Created by Just-h on 16/5/6.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "AboutViewController.h"
#import "UIView+SDAutoLayout.h"
#import "Masonry.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
#pragma mark - view life circle  viewController生命周期方法
- (void)viewDidLoad {
    [super viewDidLoad];
    [self init_View];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - custom methods  自定义方法
- (void)init_View{
    self.title = @"关于";
    
    // Logo
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenW, kScreenH * 0.37)];
    topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topView];
    UIImageView *cycleImageV = [[UIImageView alloc] init];
    CGFloat cycleImageVW = topView.frame.size.height * 0.5;
    cycleImageV.frame = CGRectMake((kScreenW - cycleImageVW)*0.5, (topView.frame.size.height - cycleImageVW) * 0.5, cycleImageVW, cycleImageVW);
    cycleImageV.image = [UIImage imageNamed:@"logo"];
    [topView addSubview:cycleImageV];
    
    // app介绍文字
    UILabel *textLb = [[UILabel alloc] init];
    textLb.text = @"科瑞医疗是由郑州科瑞医疗器械有限公司针对该司的水疗设备提供的一款智能控制移动应用软件。它通过采用蓝牙通信的方式来动态扫描识别身边的水疗设备进行配对，进而实现远程操控，让用户通过移动终端来方便形象的展示出水疗设备当前的运行状态情况。";
    textLb.numberOfLines = 0;
    textLb.font = [UIFont systemFontOfSize:15];
    textLb.textColor = [UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1.00];
    // 调整行间距
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textLb.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [textLb.text length])];
    textLb.attributedText = attributedString;
    [self.view addSubview:textLb];
    CGFloat textLbH = [textLb.text boundingRectWithSize:CGSizeMake(kScreenW - 20, kScreenH) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:paragraphStyle} context:nil].size.height;
    textLbH += 40.0;
//    textLb.sd_layout
//    .topSpaceToView(topView,0)
//    .leftSpaceToView(self.view,20)
//    .rightSpaceToView(self.view,20)
//    .heightIs(textLbH);
    
    // 检查更新按钮
    UIButton *checkUpdateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [checkUpdateBtn setTitle:@"检查更新" forState:UIControlStateNormal];
    [checkUpdateBtn setTitle:@"检查更新" forState:UIControlStateHighlighted];
    checkUpdateBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [checkUpdateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [checkUpdateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [checkUpdateBtn setBackgroundImage:[UIImage imageNamed:@"btn_n"] forState:UIControlStateNormal];
    [checkUpdateBtn setBackgroundImage:[UIImage imageNamed:@"btn_p"] forState:UIControlStateHighlighted];
    [checkUpdateBtn addTarget:self action:@selector(checkUpdateBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkUpdateBtn];
    checkUpdateBtn.sd_layout
    .heightIs(36)
    .widthIs(kScreenW * 0.8)
    .bottomSpaceToView(self.view,70)
    .centerXEqualToView(self.view);
    
    [textLb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(topView.mas_bottom);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
//        make.bottom.equalTo(checkUpdateBtn.mas_top);
        make.height.equalTo(@(textLbH));
    }];
    
    if (IS_IPHONE_4_OR_LESS) {
        checkUpdateBtn.sd_layout
        .heightIs(30)
        .widthIs(kScreenW * 0.8)
        .bottomSpaceToView(self.view,18)
        .centerXEqualToView(self.view);
    }
}

// 检车更新按钮点击响应
- (void)checkUpdateBtnDidClick{
    
}

#pragma mark - sources and delegates 代理、协议方法


#pragma mark - getters and setters 属性的设置和获取方法

@end
