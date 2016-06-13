//
//  YCButton.m
//  HanKe
//
//  Created by Just-h on 16/6/13.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "YCButton.h"

@implementation YCButton

+ (instancetype)buttonWithTitle:(NSString *)title Height:(CGFloat)height TitleColor:(UIColor *)color FontSize:(CGFloat)size ForState:(UIControlState)state{
    YCButton *btn = [YCButton buttonWithType:UIButtonTypeCustom];
    btn.titleLabel.font = [UIFont systemFontOfSize:size];
    [btn setTitleColor:color forState:state];
    [btn setTitle:title forState:state];
    
    NSDictionary *attrbute = @{NSFontAttributeName:[UIFont systemFontOfSize:size]};
    CGFloat width = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrbute context:nil].size.width;
    btn.frame = CGRectMake(0, 0, width, height);
    return btn;
}

@end
