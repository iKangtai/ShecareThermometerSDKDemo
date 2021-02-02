//
//  YCConnectDeviceViewController.m
//  Shecare
//
//  Created by mac on 2019/4/23.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCConnectDeviceViewController.h"
#import "YCConnectLoadingView.h"
#import <SCBLESDK/SCBLESDK.h>
#import "YCUserTemperatureModel.h"
#import "YCBBTShowView.h"
#import "YCDeviceListViewController.h"

#define kConnectTimeout 10.0
#define kConnectFailed 50.0
#define kTemperatureUploadTimeout 30.0

@interface YCConnectDeviceViewController ()

@property (nonatomic, strong) YCConnectLoadingView *loadingView;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *step1Btn;
@property (nonatomic, strong) UIButton *step2Btn;
@property (nonatomic, strong) NSTimer *uploadTimeoutTimer;
@property (nonatomic, strong) NSTimer *connectTimeoutTimer;
@property (nonatomic, strong) NSTimer *connectFailedTimer;
@property (nonatomic, assign) BOOL uploadedTemperatures;

@end

@implementation YCConnectDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"设备连接";
    self.uploadedTemperatures = false;
    [self setupUI];
    [self setupNavigationItem];
    
#if !TARGET_OS_SIMULATOR
    SCBLEThermometer *thermometer = [SCBLEThermometer sharedThermometer];
    //  如果硬件已连接
    if (thermometer.activePeripheral != nil) {
        self.step1Btn.selected = true;
        self.step2Btn.selected = true;
    } else {
        NSString *state = @"";
        switch (thermometer.bleState) {
            case YCBLEStateUnsupported:
                state = Localizable_NotSupportBLE;
                break;
            case YCBLEStateUnauthorized:
                state = Localizable_NotAuthorizedForBLE;
                break;
            case YCBLEStatePoweredOff:
                [YCAlertController showAlertWithTitle:@"温馨提示"
                                              message:Localizable_BluetoothIsOFF
                                          cancelTitle:@"取消"
                                         confirmTitle:@"设置"
                                        cancelHandler:^(UIAlertAction * _Nonnull action) {
                }
                                       confirmHandler:^(UIAlertAction * _Nonnull action) {
                    [SCBLEThermometer sharedThermometer].connectType = YCBLEConnectTypeNotBinding;
                    [SHAREDAPP startScan];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                break;
            case YCBLEStateValid:
                self.step1Btn.selected = YES;
                [SCBLEThermometer sharedThermometer].connectType = YCBLEConnectTypeNotBinding;
                [SHAREDAPP startScan];
                break;
            case YCBLEStateUnknown:
                state = Localizable_BluetoothStateUnknow;
                break;
            default:
                break;
        }
        if (state.length > 0) {
            [YCAlertController showAlertWithTitle:@"温馨提示"
                                          message:state
                                    cancelHandler:nil
                                   confirmHandler:^(UIAlertAction * _Nonnull action) {
                                   }];
        }
    }
#endif
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thermometerConnected:) name:kNotification_ThermometerConnectSuccessed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateThermometerState:) name:kNotification_ThermometerDidUpdateState object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUploadTemperatures:) name:kNotification_DidUploadTemperatures object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    SCBLEThermometer *thermometer = [SCBLEThermometer sharedThermometer];
    [self setConnectStatus:(nil != thermometer.activePeripheral)];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    // 页面退出，停止 Timer
    [self stopAllTimers];
}

-(void)stopAllTimers {
    [self invalidateTimer:self.connectTimeoutTimer];
    [self invalidateTimer:self.uploadTimeoutTimer];
    [self invalidateTimer:self.connectFailedTimer];
}

-(void)setupUI {
    [self cancelBtn];
    [self loadingView];
    [self step1Btn];
    [self step2Btn];
}

- (void)setupNavigationItem {
    self.navigationItem.leftBarButtonItem = [YCUtility navigationBackItemWithTarget:self action:@selector(goBack)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"体温计管理" style:UIBarButtonItemStylePlain target:self action:@selector(thermometerManage)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)thermometerManage {
    YCDeviceListViewController *vc = [[YCDeviceListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:true];
}

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleCancelBtnAction:(UIButton *)sender {
    if ([sender.currentTitle isEqualToString:@"取消"]
        || [sender.currentTitle isEqualToString:@"上传完毕"]) {
        [self goBack];
    } else if ([sender.currentTitle isEqualToString:@"重新搜索"]) {
        [self setConnectStatus:false];
        self.step1Btn.hidden = false;
        self.step2Btn.hidden = false;
    }
}

-(void)setConnectStatus:(BOOL)connected {
    if (connected) {
        self.loadingView.connectStatus = YCConnectStatusConnected;
        self.cancelBtn.enabled = false;
        [self.cancelBtn setTitle:@"数据上传中" forState:UIControlStateNormal];
        self.cancelBtn.layer.backgroundColor = [UIColor grayTextColor].CGColor;
        self.cancelBtn.layer.shadowColor = [UIColor whiteColor].CGColor;
        // 连接成功，开始或停止 Timer
        self.uploadTimeoutTimer = [NSTimer timerWithTimeInterval:kTemperatureUploadTimeout target:self selector:@selector(uploadTimeoutTimerHandler) userInfo:nil repeats:false];
        [self addTimer:self.uploadTimeoutTimer];
        [self invalidateTimer:self.connectTimeoutTimer];
    } else {
        // 断开连接，开始或停止 Timer
        [self invalidateTimer:self.uploadTimeoutTimer];
        [self invalidateTimer:self.connectFailedTimer];
        self.connectTimeoutTimer = [NSTimer timerWithTimeInterval:kConnectTimeout target:self selector:@selector(connectTimeoutTimerHandler) userInfo:nil repeats:false];
        [self addTimer:self.connectTimeoutTimer];
        
        self.cancelBtn.enabled = true;
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        self.cancelBtn.layer.backgroundColor = [UIColor mainColor].CGColor;
        self.cancelBtn.layer.shadowColor = [UIColor colorWithHex:0xFF7486 alpha:0.2].CGColor;
        self.loadingView.connectStatus = YCConnectStatusConnecting;
    }
}

-(void)addTimer:(NSTimer *)timer {
    // Timer 的 Add 和 Remove 需要在同一个 Thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    });
}

-(void)invalidateTimer:(NSTimer *)timer {
    // Timer 的 Add 和 Remove 需要在同一个 Thread。“You must send this message from the thread on which the timer was installed.”
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([timer isValid]) {
            [timer invalidate];
        }
    });
}

-(void)uploadTimeoutTimerHandler {
    [self didGetTemperature:@[]];
}

-(void)connectTimeoutTimerHandler {
    if (YCConnectStatusConnecting == self.loadingView.connectStatus) {
        self.loadingView.connectStatus = YCConnectStatusTimeout;
        self.connectFailedTimer = [NSTimer timerWithTimeInterval:kConnectFailed target:self selector:@selector(connectFailedTimerHandler) userInfo:nil repeats:false];
        [self addTimer:self.connectFailedTimer];
    }
}

-(void)connectFailedTimerHandler {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.cancelBtn.enabled = true;
        self.cancelBtn.layer.backgroundColor = [UIColor mainColor].CGColor;
        self.cancelBtn.layer.shadowColor = [UIColor colorWithHex:0xFF7486 alpha:0.2].CGColor;
        [self.cancelBtn setTitle:@"重新搜索" forState:UIControlStateNormal];
        self.step1Btn.hidden = true;
        self.step2Btn.hidden = true;
        self.loadingView.connectStatus = YCConnectStatusFailed;
    });
}

-(void)didGetTemperature:(NSArray *)temperatures {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.cancelBtn.enabled = true;
        self.cancelBtn.layer.backgroundColor = [UIColor mainColor].CGColor;
        self.cancelBtn.layer.shadowColor = [UIColor colorWithHex:0xFF7486 alpha:0.2].CGColor;
        [self.cancelBtn setTitle:@"上传完毕" forState:UIControlStateNormal];
        self.loadingView.connectStatus = YCConnectStatusUploaded;
    });
    
    if (nil == temperatures || 0 == temperatures.count) {
        // 没有上传过体温
        if (!self.uploadedTemperatures) {
            NSMutableAttributedString *attrMsg = [[NSMutableAttributedString alloc] initWithString:@"数据检查完毕，未发现新增体温数据，现在就开始测温吧。 " attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:16], NSForegroundColorAttributeName : [UIColor colorWithHex:0x7F7F7F]}];
            NSString *title = [NSString stringWithFormat:@"\n\n%@：", @"温馨提示"];
            [attrMsg appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor mainColor]}]];
            [attrMsg appendAttributedString:[[NSAttributedString alloc] initWithString:@"体温计 '嘀嘀' 声后才算测温结束，测完后，也不要立即关机，以免数据丢失。" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : [UIColor colorWithHex:0x7F7F7F]}]];

            [self showAttributedAlert:attrMsg.copy];
        }
    } else {
        // 测试数据
//        NSArray *testModels = @[
//            [YCUserTemperatureModel modelWithTemperature:[NSNumber numberWithDouble:36.45] time:[NSDate dateWithyyyyMMddHHmmssString:@"2021-01-15 12:15:11"] type:[NSNumber numberWithInt:0] temperatureID:[YCUtility generateUniqueIdentifier]],
//            [YCUserTemperatureModel modelWithTemperature:[NSNumber numberWithDouble:36.65] time:[NSDate dateWithyyyyMMddHHmmssString:@"2021-01-16 09:16:00"] type:[NSNumber numberWithInt:0] temperatureID:[YCUtility generateUniqueIdentifier]],
//            [YCUserTemperatureModel modelWithTemperature:[NSNumber numberWithDouble:36.48] time:[NSDate dateWithyyyyMMddHHmmssString:@"2021-01-18 06:19:11"] type:[NSNumber numberWithInt:0] temperatureID:[YCUtility generateUniqueIdentifier]],
//            [YCUserTemperatureModel modelWithTemperature:[NSNumber numberWithDouble:36.53] time:[NSDate dateWithyyyyMMddHHmmssString:@"2021-01-18 12:15:11"] type:[NSNumber numberWithInt:0] temperatureID:[YCUtility generateUniqueIdentifier]],
//            [YCUserTemperatureModel modelWithTemperature:[NSNumber numberWithDouble:35.99] time:[NSDate dateWithyyyyMMddHHmmssString:@"2021-01-18 05:33:11"] type:[NSNumber numberWithInt:0] temperatureID:[YCUtility generateUniqueIdentifier]],
//            [YCUserTemperatureModel modelWithTemperature:[NSNumber numberWithDouble:36.35] time:[NSDate dateWithyyyyMMddHHmmssString:@"2021-01-12 13:15:11"] type:[NSNumber numberWithInt:0] temperatureID:[YCUtility generateUniqueIdentifier]],
//            [YCUserTemperatureModel modelWithTemperature:[NSNumber numberWithDouble:36.29] time:[NSDate dateWithyyyyMMddHHmmssString:@"2021-01-20 07:15:11"] type:[NSNumber numberWithInt:0] temperatureID:[YCUtility generateUniqueIdentifier]],
//            [YCUserTemperatureModel modelWithTemperature:[NSNumber numberWithDouble:36.77] time:[NSDate dateWithyyyyMMddHHmmssString:@"2021-01-12 15:44:11"] type:[NSNumber numberWithInt:0] temperatureID:[YCUtility generateUniqueIdentifier]],
//            [YCUserTemperatureModel modelWithTemperature:[NSNumber numberWithDouble:36.66] time:[NSDate dateWithyyyyMMddHHmmssString:@"2021-01-25 09:15:11"] type:[NSNumber numberWithInt:0] temperatureID:[YCUtility generateUniqueIdentifier]],
//            [YCUserTemperatureModel modelWithTemperature:[NSNumber numberWithDouble:36.38] time:[NSDate dateWithyyyyMMddHHmmssString:@"2021-01-25 20:15:11"] type:[NSNumber numberWithInt:0] temperatureID:[YCUtility generateUniqueIdentifier]]];
        self.uploadedTemperatures = true;  // 上传过体温
        YCBBTShowView *showVC = [[YCBBTShowView alloc] initWithTempModels:temperatures];
        [showVC show];
    }
}

-(void)showAttributedAlert:(NSAttributedString *)attrString {
    dispatch_async(dispatch_get_main_queue(), ^{
        YCAlertController *alertC = [YCAlertController alertControllerWithTitle:@"" message:attrString.string preferredStyle:UIAlertControllerStyleAlert];
        [alertC setValue:attrString forKey:@"attributedMessage"];
        
        UIAlertAction *cancleAct = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popToRootViewControllerAnimated:true];
        }];
        [alertC addAction:cancleAct];
        
        UIViewController *curVC = [UIViewController currentViewController];
        [curVC presentViewController:alertC animated:YES completion:nil];
    });
}

-(void)dealloc {
    [self stopAllTimers];
    NSLog(@"%@---%s", [self class], __FUNCTION__);
}

#pragma mark - BLEThermometer Notify

- (void)updateThermometerState:(NSNotification *)notify {
    NSNumber *num = (NSNumber *)notify.object;
    YCBLEState state = (YCBLEState)[num integerValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (state == YCBLEStateValid) {
            self.step1Btn.selected = YES;
        } else {
            self.step1Btn.selected = NO;
            self.step2Btn.selected = NO;
        }
        SCBLEThermometer *thermometer = [SCBLEThermometer sharedThermometer];
        [self setConnectStatus:(nil != thermometer.activePeripheral)];
    });
}

- (void)thermometerConnected:(NSNotification *)notify {
    BOOL connected = [notify.object boolValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.step2Btn.selected = connected;
        [self setConnectStatus:connected];
    });
}

- (void)didUploadTemperatures:(NSNotification *)notification {
    NSArray *temperatures = (NSArray *)notification.object;
    [self didGetTemperature:temperatures];
}

#pragma mark - Lazy Load

-(YCConnectLoadingView *)loadingView {
    if (_loadingView == nil) {
        _loadingView = [[YCConnectLoadingView alloc] init];
        
        [self.view addSubview:_loadingView];
        [_loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(kTopHeight + 29);
            make.width.mas_equalTo(264);
            make.height.mas_equalTo(264);
        }];
    }
    return _loadingView;
}

-(UIButton *)cancelBtn {
    if (_cancelBtn == nil) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.layer.backgroundColor = [UIColor mainColor].CGColor;
        _cancelBtn.layer.shadowColor = [UIColor colorWithHex:0xFF7486 alpha:0.2].CGColor;
        _cancelBtn.layer.cornerRadius = 21;
        _cancelBtn.layer.shadowOffset = CGSizeMake(0, 4);
        _cancelBtn.layer.shadowOpacity = 1;
        _cancelBtn.layer.shadowRadius = 4;
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(handleCancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_cancelBtn];
        [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.width.mas_equalTo(220);
            make.height.mas_equalTo(42);
            make.bottom.mas_equalTo(-40);
        }];
    }
    return _cancelBtn;
}

-(UIButton *)step1Btn {
    if (_step1Btn == nil) {
        _step1Btn = [[UIButton alloc] init];
        _step1Btn.userInteractionEnabled = false;
        [_step1Btn setTitle:@"   手机蓝牙已打开" forState:UIControlStateNormal];
        [_step1Btn setTitleColor:[UIColor grayTextColor] forState:UIControlStateNormal];
        [_step1Btn setTitleColor:[UIColor textColor] forState:UIControlStateSelected];
        _step1Btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_step1Btn setImage:[UIImage imageNamed:@"binding_icon_normal"] forState:UIControlStateNormal];
        [_step1Btn setImage:[UIImage imageNamed:@"binding_icon_selected"] forState:UIControlStateSelected];
        [self.view addSubview:_step1Btn];
        [_step1Btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.step2Btn.mas_left);
            make.top.mas_equalTo(self.loadingView.mas_bottom).mas_offset(26);
        }];
    }
    return _step1Btn;
}

-(UIButton *)step2Btn {
    if (_step2Btn == nil) {
        _step2Btn = [[UIButton alloc] init];
        _step2Btn.userInteractionEnabled = false;
        [_step2Btn setTitle:@"   孕橙体温计开关已打开" forState:UIControlStateNormal];
        [_step2Btn setTitleColor:[UIColor grayTextColor] forState:UIControlStateNormal];
        [_step2Btn setTitleColor:[UIColor textColor] forState:UIControlStateSelected];
        _step2Btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_step2Btn setImage:[UIImage imageNamed:@"binding_icon_normal"] forState:UIControlStateNormal];
        [_step2Btn setImage:[UIImage imageNamed:@"binding_icon_selected"] forState:UIControlStateSelected];
        [self.view addSubview:_step2Btn];
        [_step2Btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.top.mas_equalTo(self.step1Btn.mas_bottom).mas_offset(8);
        }];
    }
    return _step2Btn;
}

@end
