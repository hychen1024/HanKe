//
//  BaseViewController.m
//  HanKe
//
//  Created by Just-h on 16/5/5.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

#pragma mark - view life circle  viewController生命周期方法
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - custom methods  自定义方法
- (void)initView{
    // 背景颜色
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    
    // 自定义返回按钮2
    [self.navigationItem setHidesBackButton:YES animated:YES];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 0, 23, 23);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back_n"] forState:UIControlStateNormal];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back_p"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backItemClick) forControlEvents: UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)backItemClick{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - sources and delegates 代理、协议方法


#pragma mark - getters and setters 属性的设置和获取方法


@end
