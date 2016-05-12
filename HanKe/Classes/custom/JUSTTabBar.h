//
//  JUSTTabBar.h
//  HanKe
//
//  Created by Just-h on 16/4/28.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JUSTTabBar;
@protocol JUSTTabBarDelegate <UITabBarDelegate>

@required
- (void)tabBarDidClickAddBtn:(JUSTTabBar *)tabBar;

@end
@interface JUSTTabBar : UITabBar

@property (nonatomic, weak) id<JUSTTabBarDelegate> JUSTTabBarDelegate;

@end
