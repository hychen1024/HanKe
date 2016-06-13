//
//  YCButton.h
//  HanKe
//
//  Created by Just-h on 16/6/13.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCButton : UIButton
+ (instancetype)buttonWithTitle:(NSString *)title Height:(CGFloat)height TitleColor:(UIColor *)color FontSize:(CGFloat)size ForState:(UIControlState)state;
@end
