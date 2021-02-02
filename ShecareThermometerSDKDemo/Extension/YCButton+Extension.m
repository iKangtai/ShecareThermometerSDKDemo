//
//  YCButtonExtension.m
//  Shecare
//
//  Created by 罗培克 on 10/11/15.
//  Copyright © 2015 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCButton+Extension.h"

@implementation UIButton(YCButtonExtension)

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
