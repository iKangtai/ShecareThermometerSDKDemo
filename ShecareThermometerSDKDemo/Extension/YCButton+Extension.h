//
//  YCButtonExtension.h
//  Shecare
//
//  Created by 罗培克 on 10/11/15.
//  Copyright © 2015 北京爱康泰科技有限责任公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton(YCButtonExtension)

///  便利构造器
-(instancetype)initWithTitle:(NSString *)title fontSize:(CGFloat)fontSize titleColor:(UIColor *)titleColor bgColor:(UIColor *)bgColor;

+ (UIButton *)buttonItem:(UIViewController *)viewController horizontalInset:(CGFloat)horizontalInset verticalInset:(CGFloat)verticalInset imageName:(NSString *)imageName action:(SEL)action;

+(UIButton *)healthProfilePickerButton;

@end
