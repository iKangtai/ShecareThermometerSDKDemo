//
//  YCDeviceInfoViewController.m
//  Shecare
//
//  Created by MacBook Pro 2016 on 2020/7/15.
//  Copyright © 2020 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCDeviceInfoViewController.h"
#import "YCUserHardwareInfoModel.h"
#import "YCUpdateDeviceController.h"
#import <SCBLESDK/SCBLESDK.h>

@interface YCDeviceInfoViewController ()

@property (nonatomic, strong) YCUserHardwareInfoModel *deviceModel;
@property (nonatomic, assign) BOOL isConnected;

@property (nonatomic, strong) UILabel *connectedLabel;
@property (nonatomic, strong) UIImageView *headImageV;
@property (nonatomic, strong) UILabel *titleLbl;
@property (nonatomic, strong) YCGradientButton *unpairButton;
@property (nonatomic, strong) UILabel *updateLbl;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) YCUpdateDeviceController *updateController;

@end

@implementation YCDeviceInfoViewController

-(instancetype)initWithModel:(YCUserHardwareInfoModel *)model {
    if (self = [super init]) {
        self.deviceModel = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"设备信息";
    [self setupNavigationItem];
    [self setupUI];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setConnectStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectedThermometer:) name:kNotification_ThermometerConnectSuccessed object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

-(void)connectedThermometer:(NSNotification *)notify {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setConnectStatus];
    });
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@---%s", [self class], __FUNCTION__);
}

-(void)setupNavigationItem {
    self.navigationItem.leftBarButtonItem = [YCUtility navigationBackItemWithTarget:self action:@selector(back)];
}

-(void)back {
    [self.navigationController popViewControllerAnimated:true];
}

-(void)setupUI {
    [self headImageV];
    [self titleLbl];
    [self connectedLabel];
    [self lineView];
    [self unpairButton];
    [self updateLbl];
    self.headImageV.image = [self.deviceModel hardwareImg];
}

-(void)setConnectStatus {
    NSString *macAddress = [SCBLEThermometer sharedThermometer].macAddress;
    if (!IS_EMPTY_STRING(macAddress)) {
        if ([macAddress isEqualToString:self.deviceModel.macAddress]) {
            self.isConnected = true;
            return;
        }
    }
    self.isConnected = false;
}

-(void)setIsConnected:(BOOL)isConnected {
    _isConnected = isConnected;
    
    if (isConnected) {
        self.connectedLabel.text = @"已连接";
        self.connectedLabel.textColor = [UIColor mainColor];
    } else {
        self.connectedLabel.text = @"未连接";
        self.connectedLabel.textColor = [UIColor grayTextColor];
    }
}

-(void)handleUnpairDevice {
    [YCAlertController showAlertWithTitle:@"温馨提示" message:@"您将解除与设备的绑定，是否真的解绑？" cancelHandler:^(UIAlertAction * _Nonnull action) {
        
    } confirmHandler:^(UIAlertAction * _Nonnull action) {
        [self unpair];
    }];
}

-(void)unpair {
    [self unbindSuccessHandler];
    [[SCBLEThermometer sharedThermometer] disconnectActiveThermometer];
}

-(void)unbindSuccessHandler {
    [YCUtility removeDevice:self.deviceModel.macAddress];
    [SCBLEThermometer sharedThermometer].connectType = YCBLEConnectTypeNotBinding;
    [SHAREDAPP startScan];
    [self.navigationController popToRootViewControllerAnimated:true];
}

-(void)handleUpdateDevice {
    [self.updateController updateDevice];
}

#pragma mark - Lazy Load

-(UIImageView *)headImageV {
    if (_headImageV == nil) {
        _headImageV = [[UIImageView alloc] init];
        _headImageV.contentMode = UIViewContentModeScaleAspectFit;
        _headImageV.image = [self.deviceModel hardwareImg];
        [self.view addSubview:_headImageV];
        [_headImageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(12);
            make.top.mas_equalTo(kTopHeight + 15);
            make.width.mas_equalTo(64);
            make.height.mas_equalTo(64);
        }];
    }
    return _headImageV;
}

-(UILabel *)connectedLabel {
    if (_connectedLabel == nil) {
        _connectedLabel = [[UILabel alloc] init];
        _connectedLabel.font = [UIFont systemFontOfSize:12];
        _connectedLabel.adjustsFontSizeToFitWidth = true;
        _connectedLabel.text = @"未连接";
        [self.view addSubview:_connectedLabel];
        [_connectedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.titleLbl.mas_left).mas_offset(5);
            make.top.mas_equalTo(kTopHeight + 61);
            make.height.mas_equalTo(15);
            make.right.mas_equalTo(0);
        }];
    }
    return _connectedLabel;
}

-(UILabel *)titleLbl {
    if (_titleLbl == nil) {
        _titleLbl = [[UILabel alloc] init];
        _titleLbl.font = [UIFont systemFontOfSize:18];
        _titleLbl.textColor = [UIColor mainColor];
        _titleLbl.adjustsFontSizeToFitWidth = true;
        _titleLbl.text = @"孕橙智能基础体温计";
        [self.view addSubview:_titleLbl];
        [_titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.headImageV.mas_trailing).mas_offset(12);
            make.trailing.mas_equalTo(-8);
            make.top.mas_equalTo(kTopHeight + 22);
        }];
    }
    return _titleLbl;
}

-(YCGradientButton *)unpairButton {
    if (_unpairButton == nil) {
        _unpairButton = [YCGradientButton buttonWithType:UIButtonTypeCustom];
        NSString *title = @"解绑设备";
        [_unpairButton setTitle:title forState:UIControlStateNormal];
        [_unpairButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_unpairButton addTarget:self action:@selector(handleUnpairDevice) forControlEvents:UIControlEventTouchUpInside];
        _unpairButton.layer.masksToBounds = true;
        _unpairButton.layer.cornerRadius = 17;
        [self.view addSubview:_unpairButton];
        [_unpairButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-60);
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.width.mas_equalTo(194);
            make.height.mas_equalTo(34);
        }];
    }
    return _unpairButton;
}

-(UILabel *)updateLbl {
    if (_updateLbl == nil) {
        _updateLbl = [[UILabel alloc] init];
        NSString *text = @"设备程序升级";
        NSDictionary *attr = @{
            NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle),
            NSForegroundColorAttributeName: [UIColor grayTextColor]
        };
        _updateLbl.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attr];
        _updateLbl.userInteractionEnabled = true;
        UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUpdateDevice)];
        [_updateLbl addGestureRecognizer:tapG];
        [self.view addSubview:_updateLbl];
        [_updateLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.unpairButton.mas_top).mas_offset(-20);
            make.centerX.mas_equalTo(self.view.mas_centerX);
        }];
    }
    return _updateLbl;
}

-(UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithHex:0xF0F2F5];
        [self.view addSubview:_lineView];
        [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.headImageV.mas_bottom).mas_offset(15);
            make.leading.mas_equalTo(0);
            make.trailing.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];
    }
    return _lineView;
}

-(YCUpdateDeviceController *)updateController {
    if (_updateController == nil) {
        _updateController = [[YCUpdateDeviceController alloc] init];
    }
    return _updateController;
}

@end
