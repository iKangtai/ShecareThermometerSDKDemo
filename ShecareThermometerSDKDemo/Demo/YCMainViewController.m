//
//  YCMainViewController.m
//  ShecareThermometerSDKDemo
//
//  Created by KyokuSei on 2021/1/21.
//

#import "YCMainViewController.h"
#import "YCBBTView.h"
#import "YCUserTemperatureModel.h"
#import "YCBBTShowView.h"
#import "YCFetalHeartMonitorViewController.h"
#import "YCDeviceListViewController.h"

@interface YCMainViewController ()

@property (nonatomic, strong) YCGradientButton *inputBBTBtn;
@property (nonatomic, strong) YCGradientButton *fhrBtn;
@property (nonatomic, strong) YCGradientButton *deviceBtn;

@end

@implementation YCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self inputBBTBtn];
    [self fhrBtn];
    [self deviceBtn];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUploadTemperatures:) name:kNotification_DidUploadTemperatures object:nil];
}

-(void)handleAction:(UIButton *)sender {
    YCBBTView *bbtV = [[YCBBTView alloc] init];
    [bbtV show];
}

-(void)handleFHRAction:(UIButton *)sender {
    YCFetalHeartMonitorViewController *fhVC = [[YCFetalHeartMonitorViewController alloc] init];
    fhVC.title = @"胎心监护";
    [self.navigationController pushViewController:fhVC animated:true];
}

-(void)handleDeviceAction:(UIButton *)sender {
    YCDeviceListViewController *vc = [[YCDeviceListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:true];
}

-(void)didUploadTemperatures:(NSNotification *)notification {
    NSArray *temperatures = (NSArray *)notification.object;
    if (temperatures != nil && temperatures.count > 0) {
        YCBBTShowView *showVC = [[YCBBTShowView alloc] initWithTempModels:temperatures];
        [showVC show];
    }
}

-(YCGradientButton *)inputBBTBtn {
    if (_inputBBTBtn == nil) {
        _inputBBTBtn = [YCGradientButton buttonWithType:UIButtonTypeCustom];
        _inputBBTBtn.layer.masksToBounds = true;
        _inputBBTBtn.layer.cornerRadius = 21;
        [_inputBBTBtn setTitle:@"录入体温" forState:UIControlStateNormal];
        [_inputBBTBtn addTarget:self action:@selector(handleAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_inputBBTBtn];
        [_inputBBTBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.bottom.mas_equalTo(self.fhrBtn.mas_top).mas_offset(-20);
            make.width.mas_equalTo(240);
            make.height.mas_equalTo(40);
        }];
    }
    return _inputBBTBtn;
}

-(YCGradientButton *)fhrBtn {
    if (_fhrBtn == nil) {
        _fhrBtn = [YCGradientButton buttonWithType:UIButtonTypeCustom];
        _fhrBtn.layer.masksToBounds = true;
        _fhrBtn.layer.cornerRadius = 21;
        [_fhrBtn setTitle:@"胎心监护" forState:UIControlStateNormal];
        [_fhrBtn addTarget:self action:@selector(handleFHRAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_fhrBtn];
        [_fhrBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(0);
            make.width.mas_equalTo(240);
            make.height.mas_equalTo(40);
        }];
    }
    return _fhrBtn;
}

-(YCGradientButton *)deviceBtn {
    if (_deviceBtn == nil) {
        _deviceBtn = [YCGradientButton buttonWithType:UIButtonTypeCustom];
        _deviceBtn.layer.masksToBounds = true;
        _deviceBtn.layer.cornerRadius = 21;
        [_deviceBtn setTitle:@"设备管理" forState:UIControlStateNormal];
        [_deviceBtn addTarget:self action:@selector(handleDeviceAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_deviceBtn];
        [_deviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(self.fhrBtn.mas_bottom).mas_offset(20);
            make.width.mas_equalTo(240);
            make.height.mas_equalTo(40);
        }];
    }
    return _deviceBtn;
}

@end
