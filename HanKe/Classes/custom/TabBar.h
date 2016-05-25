//
//  TabBar.h
//  HanKe
//
//  Created by Just-h on 16/4/28.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TabBar;
@protocol TabBarDelegate <UITabBarDelegate>

@required
- (void)tabBarDidClickAddBtn:(TabBar *)tabBar;

@end
@interface TabBar : UITabBar

@property (nonatomic, weak) id<TabBarDelegate> TabBarDelegate;

@end
