//
//  JUSTAboutViewController.m
//  HanKe
//
//  Created by Just-h on 16/5/6.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "JUSTAboutViewController.h"
#import "UIView+SDAutoLayout.h"

@interface JUSTAboutViewController ()

@end

@implementation JUSTAboutViewController
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
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenW, 200)];
    topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:topView];
    UIImageView *cycleImageV = [[UIImageView alloc] init];
    cycleImageV.frame = CGRectMake((kScreenW - 80)*0.5, (topView.frame.size.height - 80)*0.5, 80, 80);
    cycleImageV.image = [UIImage imageNamed:@"logo"];
    [topView addSubview:cycleImageV];
    
    // app介绍文字
    UILabel *textLb = [[UILabel alloc] init];
    textLb.text = @"爱的世界疯狂了爱的世界疯狂了； 大家是否可垃圾点时空裂缝大奖是离开；发驾驶的离开；；方法 架空历史的；发假的克里斯；发架空历史的发加上点开了房加点时空裂缝安静的时刻来了房间爱上的考虑非发就阿萨德可浪费发驾驶的离开发就是打开了房间爱上的考虑了房间爱打瞌睡了；了； 放假快乐；阿斯蒂芬jkl";
    textLb.numberOfLines = 0;
    textLb.font = [UIFont systemFontOfSize:15];
    textLb.textColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:1.00];
    // 调整行间距
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:textLb.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [textLb.text length])];
    textLb.attributedText = attributedString;
    [self.view addSubview:textLb];
    textLb.sd_layout
    .topSpaceToView(self.view,264)
    .leftSpaceToView(self.view,20)
    .rightSpaceToView(self.view,20)
    .heightIs(200);
    
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
    .heightIs(44)
    .widthIs(300)
    .bottomSpaceToView(self.view,70)
    .centerXEqualToView(self.view);
    
}

// 检车更新按钮点击响应
- (void)checkUpdateBtnDidClick{
    
}

#pragma mark - sources and delegates 代理、协议方法


#pragma mark - getters and setters 属性的设置和获取方法

@end
