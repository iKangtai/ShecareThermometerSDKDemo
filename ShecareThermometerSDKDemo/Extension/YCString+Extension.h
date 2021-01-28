//
//  YCStringExtension.h
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 15-1-8.
//  Copyright (c) 2015年 北京爱康泰科技有限责任公司. All rights reserved.
//

/**
 * @brief 字符串的方法扩充
 */

#import <Foundation/Foundation.h>

@interface NSString(YCStringExtension)

///  正则判断是否是邮箱帐号
-(BOOL)isLegalEmail;
///  检查密码是否合法
-(BOOL)isLegalPassowrd;


///  正则判断是否是URL

- (BOOL)isLegalUrl;


///  正则判断是否是手机号

- (BOOL) isLegalPhoneNumber;

/**
 *  @brief  使用正则表达式获取源字符串中的需要的值
 *
 *  @param dataString 源字符串
 *  @param reg        正则表达式
 *
 *  @return 截取的结果
 */
- (NSArray *)legalMatchSource:(NSString *)dataString andReg:(NSString *)reg;

/**
 *  @brief  把字符串做MD5加密处理
 *
 *  @return MD5加密后的字符串
 */
- (NSString *)MD5Hash;

- (NSString *)MD5WithSalt;
- (NSString *)MD5HashInLowerCase;

///  把字符串做 SHA1 加密处理
- (NSString *)sha1;

/**
 *  @brief  计算字符串的通用方法
 *
 *  @param font  字体
 *  @param width 字符串的最大宽度
 *
 *  @return 字符串的高度
 */
- (float)heightWithFont:(UIFont *)font andWidth:(float)width;
///  返回字符串的行数
-(NSUInteger)linesWithFont:(UIFont *)font width:(float)width;

- (CGSize)sizeWithBoundingSize:(CGSize)size andFont:(UIFont *)font;

- (CGSize)sizeWithConstrainedToWidth:(float)width fromFont:(UIFont *)font1 lineSpace:(float)lineSpace;
- (CGSize)sizeWithConstrainedToSize:(CGSize)size fromFont:(UIFont *)font1 lineSpace:(float)lineSpace;
- (void)drawInContext:(CGContextRef)context withPosition:(CGPoint)p andFont:(UIFont *)font andTextColor:(UIColor *)color andHeight:(float)height andWidth:(float)width;
- (void)drawInContext:(CGContextRef)context withPosition:(CGPoint)p andFont:(UIFont *)font andTextColor:(UIColor *)color andHeight:(float)height;
- (void)drawInRect:(CGRect)rect font:(UIFont *)font color:(UIColor *)color alignment:(NSTextAlignment)alignment;

@end
