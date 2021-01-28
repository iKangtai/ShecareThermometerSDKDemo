//
//  CAGradientLayer+YCExtension.h
//  Shecare
//
//  Created by mac on 2018/7/17.
//  Copyright © 2018年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface CAGradientLayer(YCExtension)

+(instancetype)layerWithFrame:(CGRect)frame fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor;

+(instancetype)layerWithFrame:(CGRect)frame fromColor:(UIColor *)fromColor toColor:(UIColor *)toColor cornerRadius:(CGFloat)cornerRadius;

+(instancetype)buttonBackgroundLayer;

@end
