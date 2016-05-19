//
//  JUSTTabBar.m
//  HanKe
//
//  Created by Just-h on 16/4/28.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "JUSTTabBar.h"

#define tabBarCount 3;

@interface JUSTTabBar ()
@property (nonatomic, strong) UIButton *addBtn;
@end
@implementation JUSTTabBar

-(UIButton *)addBtn{
    if (!_addBtn) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setBackgroundImage:[UIImage imageNamed:@"add_n"] forState:UIControlStateNormal];
        
        [btn setBackgroundImage:[UIImage imageNamed:@"add_p"] forState:UIControlStateHighlighted];
        
        [btn addTarget:self action:@selector(addBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
        _addBtn = btn;
        
        [btn sizeToFit];
        [self addSubview:_addBtn];
    }
    return _addBtn;
}

- (void)addBtnDidClick{
    if ([self.JUSTTabBarDelegate respondsToSelector:@selector(tabBarDidClickAddBtn:)]) {
        [self.JUSTTabBarDelegate tabBarDidClickAddBtn:self];
    }
}

// 调整子控件
- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = width / tabBarCount;
    CGFloat btnH = height;
    
    int i = 0;
    NSInteger count = tabBarCount;
    for (UIView *tabBarBtn in self.subviews) {
        if ([tabBarBtn isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            btnX = i * btnW;
            tabBarBtn.frame = CGRectMake(btnX, btnY, btnW, btnH);
            if ((count % 2) == 1) {
                if (i == ((count - 1) / 2 - 1)) {
                    i++;
                }
            }
            i++;
        }
    }
    self.addBtn.center = CGPointMake(width * 0.5, height * 0.5);
}
@end
