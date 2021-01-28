//
//  UIColor+YCExtension.m
//  YCUtility
//
//  Created by mac on 2018/7/5.
//  Copyright © 2018年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "UIColor+YCExtension.h"

@implementation UIColor(YCExtension)

+ (UIColor *)colorWithHex:(unsigned long)hexColor {
    return RGBA((float)((hexColor & 0xFF0000) >> 16),
                (float)((hexColor & 0xFF00) >> 8),
                (float)(hexColor & 0xFF), 1);
}

+ (UIColor *)colorWithHex:(unsigned long)hexColor alpha:(CGFloat)alpha {
    return RGBA((float)((hexColor & 0xFF0000) >> 16),
                (float)((hexColor & 0xFF00) >> 8),
                (float)(hexColor & 0xFF), alpha);
}

+(UIColor *)mainColor {
    return [UIColor colorWithHex:0xFF7486];
}

+(UIColor *)textColor {
    return [UIColor colorWithHex:0x444444];
}

+(UIColor *)grayTextColor {
    return [UIColor colorWithHex:0xB2B2B2];
}

@end
