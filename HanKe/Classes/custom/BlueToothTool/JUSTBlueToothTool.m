//
//  JUSTBlueToothTool.m
//  HanKe
//
//  Created by Just-h on 16/5/11.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "JUSTBlueToothTool.h"
#import "ConvertTool.h"

@implementation JUSTBlueToothTool
+ (instancetype)sharedBlueTooth{
    static id instance = nil;
    dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)postCommandWithParams:(NSString *)params completion:(void (^)(id, NSError *))completion{

}
@end
