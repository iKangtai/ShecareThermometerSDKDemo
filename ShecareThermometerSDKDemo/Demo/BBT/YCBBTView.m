//
//  YCBBTView.m
//  Shecare
//
//  Created by mac on 2019/4/22.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCBBTView.h"
#import "YCInputBBTView.h"
#import "YCBindViewController.h"
#import "YCConnectDeviceViewController.h"

@interface YCBBTView ()

@property (nonatomic, assign) BOOL triggered;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) YCGradientButton *autoUploadBtn;
@property (nonatomic, strong) YCGradientButton *manualInputBtn;

@end

@implementation YCBBTView

-(instancetype)init {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI {
    self.backgroundColor = RGBA(0, 0, 0, 0.6);
    [self contentView];
    [self titleLbl];
    [self autoUploadBtn];
    [self manualInputBtn];
}

- (void)dealloc {
    NSLog(@"%@---%s", [self class], __FUNCTION__);
}

-(void)handleSaveAction:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"手动输入"]) {
        [self untrigger];
        YCInputBBTView *inputV = [[YCInputBBTView alloc] init];
        [inputV show];
    } else if ([sender.currentTitle isEqualToString:@"体温计自动上传"]) {
        [self untrigger];
        if ([YCUtility isAppBindThermometerSuccessed]) {
            YCConnectDeviceViewController *targetVC = [[YCConnectDeviceViewController alloc] init];
            [YCUtility showVC:targetVC];
        } else {
            [self showBindAlert1];
        }
    }
}

-(void)showBindAlert1 {
    NSString *title = @"还没有孕橙智能基础体温计？";
    NSString *msg = [NSString stringWithFormat:@"%@, %@%@\n\n\n\n\n", @"孕橙智能基础体温计", @"精准测温、自动绘图、永久储存", @"，购买即赠送备孕教练服务"];
    NSMutableParagraphStyle *parSty = [[NSMutableParagraphStyle alloc] init];
    parSty.alignment = NSTextAlignmentLeft;
    NSAttributedString *attrMsg = [[NSAttributedString alloc] initWithString:msg attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13], NSForegroundColorAttributeName : [UIColor blackColor], NSParagraphStyleAttributeName : parSty}];
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    [alertC setValue:attrMsg forKey:@"attributedMessage"];
    
    UIAlertAction *bindAct = [UIAlertAction actionWithTitle:@"去绑定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        YCBindViewController *targetVC = [[YCBindViewController alloc] init];
        [YCUtility showVC:targetVC];
    }];
    [bindAct setValue:[UIColor textColor] forKey:@"titleTextColor"];
    UIAlertAction *buyAct = [UIAlertAction actionWithTitle:@"去购买" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [YCUtility handleOpenURL:[NSURL URLWithString:@"https://s.click.taobao.com/t?e=m%3D2%26s%3D%2BdwcswYJ9x4cQipKwQzePOeEDrYVVa64K7Vc7tFgwiFRAdhuF14FMVaWVHkUN9aQRitN3%2FurF3wG50TC%2BOEKRemerOqjd4FnM5oX%2FWJ3sGI8MxJ5Q%2FOfKYyhxLkYeYrta7G8XfSvkCk8eRex8LTEM9CkUAHLmx%2B1xg5p7bh%2BFbQ%3D&pvid=53_125.123.142.160_636_1608534275528"]];
    }];
    [buyAct setValue:[UIColor mainColor] forKey:@"titleTextColor"];
    [alertC addAction:bindAct];
    [alertC addAction:buyAct];
    UIImageView *alertImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thermometer_example_3"]];
    [alertC.view addSubview:alertImgV];
    [alertImgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_equalTo(108);
    }];
    
    [[UIViewController currentViewController] presentViewController:alertC animated:true completion:^{
//        [alertC tapGesAlert];
    }];
}

-(void)show {
    if (!self.triggered) {
        [self trigger];
    } else {
        [self untrigger];
    }
}

-(void)trigger {
    if (self.superview == nil) {
        NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows){
            BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
            BOOL windowIsVisible = !window.hidden && window.alpha > 0;
            BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
            
            if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
                [window addSubview:self];
                break;
            }
        }
        //  如果遍历所有 window 仍然没有把视图加载上去，直接使用 KeyWindow
        if (self.superview == nil) {
            [KEY_WINDOW addSubview:self];
        }
    } else {
        [self.superview bringSubviewToFront:self];
    }
    self.triggered = true;
}

-(void)untrigger {
    self.triggered = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - Lazy Load

-(UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.masksToBounds = true;
        _contentView.layer.cornerRadius = 10;
        [self addSubview:_contentView];
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(28);
            make.right.mas_equalTo(-28);
            make.height.mas_equalTo(218);
            make.centerY.mas_equalTo(0);
        }];
    }
    return _contentView;
}

-(UILabel *)titleLbl {
    if (_titleLbl == nil) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.textColor = [UIColor blackColor];
        _titleLbl.font = [UIFont systemFontOfSize:18];
        _titleLbl.text = [NSString stringWithFormat:@"%@", [[NSDate date] mmmdString]];;
        [self.contentView addSubview:_titleLbl];
        [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(34);
        }];
    }
    return _titleLbl;
}

-(YCGradientButton *)autoUploadBtn {
    if (_autoUploadBtn == nil) {
        _autoUploadBtn = [YCGradientButton buttonWithType:UIButtonTypeCustom];
        _autoUploadBtn.layer.masksToBounds = true;
        _autoUploadBtn.layer.cornerRadius = 21;
        [_autoUploadBtn setTitle:@"体温计自动上传" forState:UIControlStateNormal];
        [_autoUploadBtn addTarget:self action:@selector(handleSaveAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_autoUploadBtn];
        [_autoUploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(240);
            make.height.mas_equalTo(40);
            make.top.mas_equalTo(82);
        }];
    }
    return _autoUploadBtn;
}

-(YCGradientButton *)manualInputBtn {
    if (_manualInputBtn == nil) {
        _manualInputBtn = [YCGradientButton buttonWithType:UIButtonTypeCustom];
        _manualInputBtn.layer.masksToBounds = true;
        _manualInputBtn.layer.cornerRadius = 21;
        [_manualInputBtn setTitle:@"手动输入" forState:UIControlStateNormal];
        [_manualInputBtn addTarget:self action:@selector(handleSaveAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_manualInputBtn];
        [_manualInputBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(240);
            make.height.mas_equalTo(40);
            make.bottom.mas_equalTo(-40);
        }];
    }
    return _manualInputBtn;
}

@end
