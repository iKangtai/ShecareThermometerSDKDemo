//
//  YCGradientButton.m
//  Shecare
//
//  Created by mac on 2018/7/17.
//  Copyright © 2018年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCGradientButton.h"
#import "CAGradientLayer+YCExtension.h"

@interface YCGradientButton()

@property (strong, nonatomic) CAGradientLayer *gradientLayer;

@end

@implementation YCGradientButton

-(void)layoutSubviews {
    [super layoutSubviews];
    
    [self setGradientLayer];
}

-(void)setGradientLayer {
    if (self.gradientLayer.superlayer == nil) {
        self.gradientLayer.frame = self.bounds;
        [self.layer addSublayer:self.gradientLayer];
    }
}

-(void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    enabled ? (self.alpha = 1.0) : (self.alpha = 0.5);
}

#pragma mark - Lazy load

-(CAGradientLayer *)gradientLayer {
    if (_gradientLayer == nil) {
        _gradientLayer = [CAGradientLayer buttonBackgroundLayer];
        _gradientLayer.zPosition = -20;
    }
    return _gradientLayer;
}

@end
