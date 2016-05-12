//
//  JUSTBlueToothTool.h
//  HanKe
//
//  Created by Just-h on 16/5/11.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    Peripheral      外设
    characteristic  写特征
    writeData       写入的数据
 */

@interface JUSTBlueToothTool : NSObject
+ (instancetype)sharedBlueTooth;



- (void)postCommandWithParams:(NSString *)params completion:(void (^)(id response,NSError *error))completion;
@end
