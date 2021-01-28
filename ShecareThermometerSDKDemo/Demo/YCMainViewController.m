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

@interface YCMainViewController ()

@property (nonatomic, strong) YCGradientButton *inputBBTBtn;

@end

@implementation YCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self inputBBTBtn];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUploadTemperatures:) name:kNotification_DidUploadTemperatures object:nil];
}

-(void)handleAction:(UIButton *)sender {
    YCBBTView *bbtV = [[YCBBTView alloc] init];
    [bbtV show];
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
            make.center.mas_equalTo(0);
            make.width.mas_equalTo(240);
            make.height.mas_equalTo(40);
        }];
    }
    return _inputBBTBtn;
}


@end
