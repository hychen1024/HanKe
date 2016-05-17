//
//  JUSTTabBarController.m
//  HanKe
//
//  Created by Just-h on 16/4/28.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "JUSTTabBarController.h"
#import "JUSTNavController.h"
#import "JUSTTabBar.h"

@interface JUSTTabBarController ()

@end

@implementation JUSTTabBarController

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
    JUSTTabBar *tabBar = [[JUSTTabBar alloc] initWithFrame:self.tabBar.frame];
    [self setValue:tabBar forKey:@"tabBar"];
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.tabBar.bounds];
    bgView.backgroundColor = [UIColor clearColor];
    [self.tabBar insertSubview:bgView atIndex:0];
    self.tabBar.opaque = YES;
}

#pragma mark - sources and delegates 代理、协议方法

#pragma mark - getters and setters 属性的设置和获取方法

@end
