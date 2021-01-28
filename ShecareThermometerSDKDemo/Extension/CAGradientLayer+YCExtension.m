//
//  CAGradientLayer+YCExtension.m
//  Shecare
//
//  Created by mac on 2018/7/17.
//  Copyright © 2018年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "CAGradientLayer+YCExtension.h"
#import "UIColor+YCExtension.h"

@implementation CAGradientLayer(YCExtension)

+(instancetype)layerWithFrame:(CGRect)frame fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor {
    
    //    CAGradientLayer类对其绘制渐变背景颜色、填充层的形状(包括圆角)
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = frame;
    
    //  创建渐变色数组，需要转换为CGColor颜色
    gradientLayer.colors = @[(__bridge id)fromColor.CGColor,(__bridge id)toColor.CGColor];
    
    //  设置渐变颜色方向，左上点为(0,0), 右下点为(1,1)
    gradientLayer.startPoint = CGPointMake(0, 1);
    gradientLayer.endPoint = CGPointMake(1, 0);
    
    //  设置颜色变化点，取值范围 0.0~1.0
    gradientLayer.locations = @[@0,@1];
    
    return gradientLayer;
}

+(instancetype)layerWithFrame:(CGRect)frame fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor cornerRadius:(CGFloat)cornerRadius {
    CAGradientLayer *result = [self layerWithFrame:frame fromColor:fromColor toColor:toColor];
    result.masksToBounds = true;
    result.cornerRadius = cornerRadius;
    return result;
}

+(instancetype)buttonBackgroundLayer {
    return [self layerWithFrame:CGRectZero fromColor:[UIColor mainColor] toColor:[UIColor mainColor]];
}

@end
