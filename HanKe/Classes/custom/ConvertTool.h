//
//  ConvertTool.h
//  HanKe
//
//  Created by Just-h on 16/5/3.
//  Copyright © 2016年 JUST-HYC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConvertTool : NSObject
/**
 *  NSString转NSData
 *
 *  @param str NSString
 *
 *  @return NSData
 */
+ (NSData *)hexToBytes:(NSString *)str;

/**
 *  Int转NSData
 *
 *  @param Id Int数据
 *
 *  @return NSData
 */
+ (NSData *)intToBytes:(int)Id;

/**
 *  十进制转化为十六进制
 *
 *  @param Id Int
 *
 *  @return NSString
 */
+ (NSString *)ToHex:(int)Id;

/**
 *  十六进制转换为普通字符串
 *
 *  @param hexString 十六进制数字符串
 *
 *  @return 普通字符串
 */
+ (NSString *)stringFromHexString:(NSString *)hexString;

/**
 *  普通字符串转换为十六进制
 *
 *  @param string 普通字符串
 *
 *  @return 十六进制数字符串
 */
+ (NSString *)hexStringFromString:(NSString *)string;

/**
 *  将日期时间拆分成年月日时分秒
 *
 *  @param date 日期时间
 *  @param isSimpleYear 是否简写年份(取年份后2位)
 *  @return 存有年月日时分秒的字典
 */
+ (NSDictionary *)getSplitedDate:(NSDate *)date isSimpleYear:(BOOL)isSimpleYear;

/**
 *  将指令添加日期转换成Str
 *
 *  @param str 指令Str
 *
 *  @return 添加日期后的指令Str
 */
+ (NSString *)appendDateInstructFromStrToStr:(NSString *)str;

/**
 *  将指令添加日期转换成NSData
 *
 *  @param str 指令Str
 *
 *  @return 添加日期后的指令Data
 */
+ (NSData *)appendDateInstructFromStrToData:(NSString *)str;

/**
 *  NSInteger to NSString
 *
 *  @return NSString
 */
+ (NSString *)integerToNSString:(int)num;

/**
 *  服务180A 特征2A23 的value传入得到MAC地址
 *
 *  @param data 特征.value
 *
 *  @return MAC地址
 */
+ (NSString *)getMacAddressWithData:(NSData *)data;

/**
 *  去除返回数据中的空格,<,>符号
 *
 *  @param str Notify数据
 *
 *  @return 无格式符的数据Str
 */
+ (NSString *)removeTrimmingCharactersWithStr:(NSString *)str;

/**
 *  将字符串平分,判断前后是否相等
 *
 *  @param str 数据
 *
 *  @return 是否相等
 */
+ (BOOL)isEqualWithStrOnForeAndBack:(NSString *)str;

/**
 *  十六进制字符串数转换成十进制字符串数
 *
 *  @param dexStr 十六进制字符串数
 *
 *  @return 十进制字符串数
 */
+ (NSString *)hexStrToDecStr:(NSString *)hexStr;
@end
