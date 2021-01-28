//
//  YCButtonExtension.m
//  Shecare
//
//  Created by 罗培克 on 10/11/15.
//  Copyright © 2015 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCButton+Extension.h"

@implementation UIButton(YCButtonExtension)

-(instancetype)initWithTitle:(NSString *)title fontSize:(CGFloat)fontSize titleColor:(UIColor *)titleColor bgColor:(UIColor *)bgColor {
    if (self = [super init]) {
        [self setTitle:title forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:fontSize];
        [self setTitleColor:titleColor forState:UIControlStateNormal];
        self.backgroundColor = bgColor;
    }
    
    return self;
}

+ (UIButton *)buttonItem:(UIViewController *)viewController horizontalInset:(CGFloat)horizontalInset verticalInset:(CGFloat)verticalInset imageName:(NSString *)imageName action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:imageName];
    button.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // 让按钮图片右移horizontalInset,下移verticalInset
    [button setImageEdgeInsets:UIEdgeInsetsMake(verticalInset, horizontalInset, -verticalInset, -horizontalInset)];
    
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:viewController action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+(UIButton *)healthProfilePickerButton {
    UIButton *result = [UIButton buttonWithType:UIButtonTypeCustom];
    result.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 5, 0);
    UIImage *normalImage = [[UIImage imageNamed:@"health_profile_btn_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [result setBackgroundImage:normalImage forState:UIControlStateNormal];
    result.adjustsImageWhenDisabled = false;
    result.adjustsImageWhenHighlighted = false;
    [result setBackgroundImage:[UIImage imageNamed:@"health_profile_btn_selected"] forState:UIControlStateSelected];
    [result setTitleColor:[UIColor grayTextColor] forState:UIControlStateNormal];
    [result setTitleColor:[UIColor mainColor] forState:UIControlStateSelected];
    result.titleLabel.font = [UIFont systemFontOfSize:16];
    return result;
}

@end
