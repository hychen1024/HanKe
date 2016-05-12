//
//  ConvertTool.m
//  HanKe
//
//  Created by Just-h on 16/5/3.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import "ConvertTool.h"

@implementation ConvertTool
/**
 *  NSString转NSData
 *
 *  @param str NSString
 *
 *  @return NSData
 */
+ (NSData *)hexToBytes:(NSString *)str
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [str substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

/**
 *  Int转NSData
 *
 *  @param Id Int数据
 *
 *  @return NSData
 */
+ (NSData *)intToBytes:(int)Id{
    //用4个字节接收
    Byte bytes[4];
    bytes[0] = (Byte)(Id>>24);
    bytes[1] = (Byte)(Id>>16);
    bytes[2] = (Byte)(Id>>8);
    bytes[3] = (Byte)(Id);
    NSData *data = [NSData dataWithBytes:bytes length:4];
    return data;
}

/**
 *  Int转NSData
 *
 *  @param Id Int数据
 *
 *  @return NSData
 */
+ (NSString *)ToHex:(int)Id
{
    NSString *nLetterValue;
    NSString *str =@"";
    int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig=Id%16;
        Id=Id/16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue =@"A";break;
            case 11:
                nLetterValue =@"B";break;
            case 12:
                nLetterValue =@"C";break;
            case 13:
                nLetterValue =@"D";break;
            case 14:
                nLetterValue =@"E";break;
            case 15:
                nLetterValue =@"F";break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u",ttmpig];
                
        }
        str = [nLetterValue stringByAppendingString:str];
        if (Id == 0) {
            break;
        }
    }
    if(str.length == 1){
        return [NSString stringWithFormat:@"0%@",str];
    }else{
        return str;
    }
}

/**
 *  十六进制转换为普通字符串
 *
 *  @param hexString 十六进制数字符串
 *
 *  @return 普通字符串
 */
+ (NSString *)stringFromHexString:(NSString *)hexString { //
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    YCLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
}

/**
 *  普通字符串转换为十六进制
 *
 *  @param string 普通字符串
 *
 *  @return 十六进制数字符串
 */
+ (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr]; 
    } 
    return hexStr; 
}

/**
 *  将日期时间拆分成年月日时分秒
 *
 *  @param date 日期时间
 *  @param isSimpleYear 是否简写年份(取年份后2位)
 *  @return 存有年月日时分秒的字典
 */
+ (NSDictionary *)getSplitedDate:(NSDate *)date isSimpleYear:(BOOL)isSimpleYear{
    NSCalendar *cal = [NSCalendar currentCalendar];
    // 要获取的日期元素 年月日时分秒
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 存储拆分的日期元素
    NSDateComponents *d = [cal components:unitFlags fromDate:date];
    NSInteger year = [d year];
    NSInteger month = [d month];
    NSInteger day = [d day];
    NSInteger hour = [d hour];
    NSInteger minute = [d minute];
    NSInteger second = [d second];
    if (isSimpleYear) {
        year %= 100;
    }
    NSDictionary *dict = @{
                    @"year"   : @(year),
                    @"month"  : @(month),
                    @"day"    : @(day),
                    @"hour"   : @(hour),
                    @"minute" : @(minute),
                    @"second" : @(second)
                           };
    return dict;
}

/**
 *  将指令添加日期转换成Str
 *
 *  @param str 指令Str
 *
 *  @return 添加日期后的指令Str
 */
+ (NSString *)appendDateInstructFromStrToStr:(NSString *)str{
    // 补齐日期 (将不足2位的日期补0)
    NSDictionary *dateDict = [ConvertTool getSplitedDate:[NSDate date] isSimpleYear:YES];
    NSString *year = [ConvertTool integerToNSString:[dateDict[@"year"] intValue]];
    NSString *month = [ConvertTool integerToNSString:[dateDict[@"month"] intValue]];
    NSString *day = [ConvertTool integerToNSString:[dateDict[@"day"] intValue]];
    NSString *hour = [ConvertTool integerToNSString:[dateDict[@"hour"] intValue]];
    NSString *minute = [ConvertTool integerToNSString:[dateDict[@"minute"] intValue]];
    NSString *tmpStr = [NSString stringWithFormat:@"%@%@%@%@%@",year,month,day,hour,minute];
    tmpStr = [NSString stringWithFormat:@"%@%@00",str,tmpStr];
    YCLog(@"instruct:%@",tmpStr);
    return tmpStr;
}

/**
 *  将指令添加日期转换成NSData
 *
 *  @param str 指令Str
 *
 *  @return 添加日期后的指令Data
 */
+ (NSData *)appendDateInstructFromStrToData:(NSString *)str{
    NSString *tmpStr = [ConvertTool appendDateInstructFromStrToStr:str];
    tmpStr = [NSString stringWithFormat:@"%@%@",tmpStr,tmpStr];
    YCLog(@"final instruct:%@",tmpStr);
    return [ConvertTool hexToBytes:tmpStr];
}

+ (NSString *)integerToNSString:(int)num{
    NSString *tmpStr = nil;
    if (num < 10) {
        tmpStr = [NSString stringWithFormat:@"0%d",num];
    }else{
        tmpStr = [NSString stringWithFormat:@"%d",num];
    }
    return tmpStr;
}

/**
 *  服务180A 特征2A23 的value传入得到MAC地址
 *
 *  @param data 特征.value
 *
 *  @return MAC地址
 */
+ (NSString *)getMacAddressWithData:(NSData *)data{
    NSString *value = [NSString stringWithFormat:@"%@",data];
    NSMutableString *macString = [[NSMutableString alloc] init];
    [macString appendString:[[value substringWithRange:NSMakeRange(16, 2)] uppercaseString]];
    [macString appendString:@":"];
    [macString appendString:[[value substringWithRange:NSMakeRange(14, 2)] uppercaseString]];
    [macString appendString:@":"];
    [macString appendString:[[value substringWithRange:NSMakeRange(12, 2)] uppercaseString]];
    [macString appendString:@":"];
    [macString appendString:[[value substringWithRange:NSMakeRange(5, 2)] uppercaseString]];
    [macString appendString:@":"];
    [macString appendString:[[value substringWithRange:NSMakeRange(3, 2)] uppercaseString]];
    [macString appendString:@":"];
    [macString appendString:[[value substringWithRange:NSMakeRange(1, 2)] uppercaseString]];
    // 缓存Mac
    [[NSUserDefaults standardUserDefaults] setObject:macString forKey:MACADDRESSKEY];
    YCLog(@"MacString:%@",macString);
    return [macString copy];
}
@end
