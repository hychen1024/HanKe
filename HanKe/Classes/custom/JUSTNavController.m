//
//  JUSTNavController.m
//  HanKe
//
//  Created by Just-h on 16/4/28.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "JUSTNavController.h"

@interface JUSTNavController ()

@end

@implementation JUSTNavController
#pragma mark - view life circle  viewController生命周期方法
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 更改导航栏文字颜色
    [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:0.23 green:0.25 blue:0.28 alpha:1.00],NSForegroundColorAttributeName,nil]];
    // 更改导航栏颜色
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"title_bar"] forBarMetrics:UIBarMetricsDefault];

    [[UINavigationBar appearance] setBackgroundColor:RGBColor(0xfdfdfd)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - custom methods  自定义方法


#pragma mark - sources and delegates 代理、协议方法


#pragma mark - getters and setters 属性的设置和获取方法

@end
