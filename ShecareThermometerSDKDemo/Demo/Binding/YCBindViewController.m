//
//  YCBindViewController.m
//  Shecare
//
//  Created by 北京爱康泰科技有限责任公司 on 2017/11/6.
//  Copyright © 2017年 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCBindViewController.h"
#import "MBProgressHUD.h"
#import "YCUserHardwareInfoModel.h"
#import <SCBLESDK/SCBLESDK.h>
#import "YCDownloadingFile.h"
#import "YCBindSuccessViewController.h"

static NSString *connectLoadingAnimeKey = @"ycbind.loading.rotationAnimation";

@interface YCBindViewController () <BLEThermometerOADDelegate>

@property (strong, nonatomic) UIButton *step1IndicateBtn;
@property (strong, nonatomic) UIButton *step2IndicateBtn;
@property (strong, nonatomic) UIImageView *loadingImageV;
@property (strong, nonatomic) UIButton *step3IndicateBtn;

@property (strong, nonatomic) UILabel *step1TitleLbl;
@property (strong, nonatomic) UILabel *step2TitleLbl;
@property (strong, nonatomic) UILabel *step3TitleLbl;

@property (strong, nonatomic) UIButton *step1StatusButton;
@property (strong, nonatomic) UIButton *step2StatusButton;
@property (strong, nonatomic) UIButton *step3StatusButton;

@property (strong, nonatomic) UIView *line1View;
@property (strong, nonatomic) UIView *line2View;
@property (strong, nonatomic) UIView *line3View;

///  下载最新固件的链接
@property (strong, nonatomic) NSArray <NSString *>*downloadUrls;
///  从服务器获取的最新固件版本信息
@property (strong, nonatomic) NSString *newestFirmwareVersion;
///  简单的多任务下载文件，用在下载OAD的硬件
@property (strong, nonatomic) YCDownloadingFile *fileDownload;

@property (strong, nonatomic) MBProgressHUD *progressView;

@property (assign, nonatomic) BOOL bluetoothIsConnected;

@property (nonatomic, copy) NSString *macAddress;
@property (nonatomic, copy) NSString *firmwareVersion;

@property (nonatomic, strong) SCOTAManager *otaManager;

@end

@implementation YCBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    
    [self setupNavigationItem];
    
#if !TARGET_OS_SIMULATOR
    SCBLEThermometer *thermometer = [SCBLEThermometer sharedThermometer];
    thermometer.oadDelegate = self;
    //  如果硬件已连接且硬件数据已经准确读取到，直接开始与服务器的交互
    if ((thermometer.activePeripheral != nil) && !IS_EMPTY_STRING(thermometer.macAddress) && !IS_EMPTY_STRING(thermometer.firmwareVersion)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.step1StatusButton.selected = YES;
            self.step1IndicateBtn.selected = YES;
            self.macAddress = thermometer.macAddress;
            self.firmwareVersion = thermometer.firmwareVersion;
            [self checkMACAddressIsBinded:nil];
        });
    } else {
        NSString *state = @"";
        switch (thermometer.bleState) {
            case YCBLEStateUnsupported:
                state = Localizable_NotSupportBLE;
                break;
            case YCBLEStateUnauthorized:
                state = Localizable_NotAuthorizedForBLE;
                break;
            case YCBLEStatePoweredOff: {
                self.bluetoothIsConnected = false;
                [YCAlertController showAlertWithTitle:@"温馨提示"
                                              message:Localizable_BluetoothIsOFF
                                          cancelTitle:@"取消"
                                         confirmTitle:@"设置"
                                        cancelHandler:^(UIAlertAction * _Nonnull action) {
                }
                                       confirmHandler:^(UIAlertAction * _Nonnull action) {
                    [SCBLEThermometer sharedThermometer].connectType = YCBLEConnectTypeBinding;
                    [self scan];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
            }
                break;
            case YCBLEStateValid:
                self.bluetoothIsConnected = true;
                self.step1StatusButton.selected = YES;
                self.step1IndicateBtn.selected = YES;
                [SCBLEThermometer sharedThermometer].connectType = YCBLEConnectTypeBinding;
                [self scan];
                break;
            case YCBLEStateUnknown:
                state = Localizable_BluetoothStateUnknow;
                break;
            default:
                break;
        }
        if (state.length > 0) {
            self.bluetoothIsConnected = false;
            [YCAlertController showAlertWithTitle:@"温馨提示"
                                          message:state
                                    cancelHandler:nil
                                   confirmHandler:^(UIAlertAction * _Nonnull action) {
                                   }];
        }
    }
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed = false;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([MBProgressHUD HUDForView:self.view] != nil) {
        [MBProgressHUD hideHUDForView:self.view animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thermometerConnected:) name:kNotification_ThermometerConnectSuccessed object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateThermometerState:) name:kNotification_ThermometerDidUpdateState object:nil];
    
    if (self.bluetoothIsConnected == true) {
        SCBLEThermometer *thermometer = [SCBLEThermometer sharedThermometer];
        [self setConnectStatus:(nil != thermometer.activePeripheral)];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 页面消失，则 remove 掉通知，否则会影响 测温教程 里的蓝牙连接
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //  如果过早开始下次扫描，YCBLEConnectTypeNotBinding 来不及起作用
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SCBLEThermometer sharedThermometer].connectType = YCBLEConnectTypeNotBinding;
        [SHAREDAPP startScan];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%@---%s", [self class], __FUNCTION__);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@---%s", [self class], __FUNCTION__);
}

#pragma mark - help methods

-(void)setupUI {
    [self step1IndicateBtn];
    [self step2IndicateBtn];
    [self loadingImageV];
    [self step3IndicateBtn];
    [self step1TitleLbl];
    [self step2TitleLbl];
    [self step3TitleLbl];
    [self step1StatusButton];
    [self step2StatusButton];
    [self step3StatusButton];
    [self line1View];
    [self line2View];
    [self line3View];
}

- (void)setupNavigationItem {
    self.navigationItem.title = @"设备绑定";
    self.navigationItem.leftBarButtonItem = [YCUtility navigationBackItemWithTarget:self action:@selector(back:)];
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSArray <NSString *>*)localImgPaths {
    NSString *folderPath = [YCUtility firmwareImageFolderPath];
    return @[
        [folderPath stringByAppendingPathComponent:@"Athermometer.bin"],
        [folderPath stringByAppendingPathComponent:@"Bthermometer.bin"]
    ];
}

- (void)downloadFirmware {
    YCWeakSelf(self)
    [self.fileDownload downloadWithUrl:self.downloadUrls progressBlock:^(unsigned long long completeBytes, unsigned long long totalBytes) {
        NSLog(@"completeBytes %lld,totalBytes %lld", completeBytes, totalBytes);
    } completionBlock:^(NSString *curUrl, int curIndex, int totalUrlCount, NSData *downloadData) {
        YCStrongSelf(self)
        NSRange range = [curUrl rangeOfString:@"/" options:NSBackwardsSearch];
        NSString *imgName = [curUrl substringFromIndex:range.location];
        NSString *folderPath = [YCUtility firmwareImageFolderPath];
        NSString *pathStr = [folderPath stringByAppendingPathComponent:imgName];
        
        NSFileManager *fileM = [NSFileManager defaultManager];
        if ([fileM fileExistsAtPath:pathStr]) {
            NSError *error = nil;
            [fileM removeItemAtPath:pathStr error:&error];
            if (error != nil) {
                NSLog(@"OAD 旧文件清除失败：%@", error);
            } else {
                NSLog(@"OAD 旧文件清除成功！");
            }
        }
        
        if ([downloadData writeToFile:pathStr atomically:YES]) {
            NSLog(@"OAD 文件保存成功！");
        } else {
            NSLog(@"OAD 文件保存失败！");
        }
        [YCUtility extendedWithPath:pathStr key:kDefaults_LocalFirmwareVersion value:[self.newestFirmwareVersion dataUsingEncoding:NSUTF8StringEncoding]];
        
        // 新版本固件，使用 OTA，只有一个镜像文件
        if ([[SCBLEThermometer sharedThermometer] isA33]) {
            [self oadStart];
        } else {
            if (curIndex >= totalUrlCount - 1) {
                [self oadStart];
            }
        }
    } downloadError:^(NSString *curUrl, int curIndex, int totalUrlCount, NSError *error) {
        YCStrongSelf(self)
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSString *errorMsg = @"设备程序下载失败，请检查网络后重新下载。";
        [YCAlertController showAlertWithTitle:@"温馨提示" message:errorMsg cancelHandler:nil confirmHandler:^(UIAlertAction * _Nonnull action) {
            [self handleBindAction];
        }];
    }];
}

- (void)oadStart {
    if ([[SCBLEThermometer sharedThermometer] isA33]) {
        NSString *folderPath = [YCUtility firmwareImageFolderPath];
        NSString *filePath = [folderPath stringByAppendingPathComponent:@"Athermometer.bin"];
        self.otaManager.fileURL = [NSURL fileURLWithPath:filePath];
        [self.otaManager handleOTAAction];
        return;
    }
    if ([SCBLEThermometer sharedThermometer].activePeripheral != nil
        && [SCBLEThermometer sharedThermometer].imageType != YCBLEFirmwareImageTypeUnknown
        && !IS_EMPTY_STRING([SCBLEThermometer sharedThermometer].firmwareVersion)) {
        [[SCBLEThermometer sharedThermometer] updateThermometerFirmware:[self localImgPaths]];
        return;
    }
    NSString *errorMsg = @"数据获取失败，请重新连接蓝牙后再试";
    [YCAlertController showAlertWithBody:errorMsg finished:nil];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)checkUpLocalNewFirmwareVersion {
    NSString *pathStr = [YCUtility firmwareImagePath:[SCBLEThermometer sharedThermometer].firmwareVersion];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pathStr]) {
        if ([NSData dataWithContentsOfFile:pathStr] != nil) {
            NSString *lVersion = [[NSString alloc] initWithData:[YCUtility extendedWithPath:pathStr key:kDefaults_LocalFirmwareVersion] encoding:NSUTF8StringEncoding];
            if ([YCUtility compareVersion:self.newestFirmwareVersion and:lVersion] != NSOrderedDescending) {
                [self oadStart];
                return;
            }
        }
    }
    [self downloadFirmware];
}

-(void)loading {
    if ([self.loadingImageV.layer.animationKeys containsObject:connectLoadingAnimeKey]) {
        return;
    }
    
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 2;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE_VALF;
    
    [self.loadingImageV.layer addAnimation:rotationAnimation forKey:connectLoadingAnimeKey];
}

-(void)loaded {
    if ([self.loadingImageV.layer.animationKeys containsObject:connectLoadingAnimeKey]) {
        [self.loadingImageV.layer removeAnimationForKey:connectLoadingAnimeKey];
    }
}

#pragma mark - button status

///  检查 MAC 地址是否已被绑定。调用此函数时，App与硬件是连接状态
- (void)checkMACAddressIsBinded:(UIButton *)sender {
    if (!IS_EMPTY_STRING([SCBLEThermometer sharedThermometer].macAddress)
        && !IS_EMPTY_STRING([SCBLEThermometer sharedThermometer].firmwareVersion)) {
        NSString *macStr = [YCUtility bindedMACAddressList];
        
        if ([macStr isKindOfClass:[NSString class]]
            && (macStr.length >= 17)
            && ([macStr containsString:[SCBLEThermometer sharedThermometer].macAddress])) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            YCWeakSelf(self)
            [YCAlertController showAlertWithTitle:@"温馨提示" message:@"您已绑定该设备，无需再次绑定！" cancelHandler:nil confirmHandler:^(UIAlertAction * _Nonnull action) {
                YCStrongSelf(self)
                [self.navigationController popViewControllerAnimated:true];
            }];
            return;
        }
        [self checkFirmwareVersion];
    }
}

-(void)checkFirmwareVersion {
    NSInteger factory = 1; // 1 孕橙 2 安康源
    if ([[SCBLEThermometer sharedThermometer] isA33]) {
        factory = 2;
    }

    NSDictionary *dataDict = @{@"version": @"3.65", @"A": @"http://yunchengfile.oss-cn-beijing.aliyuncs.com/firmware/A31/Athermometer.bin", @"B": @"http://yunchengfile.oss-cn-beijing.aliyuncs.com/firmware/A31/Bthermometer.bin"};
    NSMutableArray *urlsM = [NSMutableArray array];
    if (dataDict[@"A"] != nil) {
        [urlsM addObject:dataDict[@"A"]];
    }
    if (dataDict[@"B"] != nil) {
        [urlsM addObject:dataDict[@"B"]];
    }
    self.downloadUrls = urlsM.copy;
    self.newestFirmwareVersion = [dataDict objectForKey:@"version"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([YCUtility compareVersion:self.newestFirmwareVersion and:[SCBLEThermometer sharedThermometer].firmwareVersion] == NSOrderedDescending) {
            YCWeakSelf(self)
            [YCAlertController showAlertWithTitle:@"温馨提示" message:@"您的设备程序不是最新的，请点击确定更新设备程序！" cancelHandler:nil confirmHandler:^(UIAlertAction * _Nonnull action) {
                YCStrongSelf(self)
                [self checkUpLocalNewFirmwareVersion];
            }];
        } else {
            [self handleBindAction];
        }
    });
}

- (void)handleBindAction {
    if (IS_EMPTY_STRING(self.macAddress)) {
        return;
    }
    [self.loadingImageV setHidden:true];
    [self.step2IndicateBtn setHidden:false];
    self.step2StatusButton.selected = true;
    self.step2IndicateBtn.selected = true;
    self.step3StatusButton.selected = true;
    self.step3IndicateBtn.selected = true;
    //  绑定时设置温度单位
    NSInteger tempType = [[NSUserDefaults standardUserDefaults] integerForKey:kDefaults_TemperatureUnits];
    if (2 == tempType) {
        [[SCBLEThermometer sharedThermometer] setCleanState:YCBLECommandTypeSetUnitF xx:0 yy:0];
    } else if (1 == tempType) {
        [[SCBLEThermometer sharedThermometer] setCleanState:YCBLECommandTypeSetUnitC xx:0 yy:0];
    }
    //  存储绑定信息到本地
    YCUserHardwareInfoModel *bindingModel = [YCUserHardwareInfoModel modelWithMACAddress:self.macAddress version:self.firmwareVersion syncType:NO];
    [YCUtility addHardwareInfoToLocal:bindingModel];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        YCBindSuccessViewController *vc = [[YCBindSuccessViewController alloc] init];
        [self.navigationController pushViewController:vc animated:true];
    });
}

-(BOOL)isOADing {
    if ([[SCBLEThermometer sharedThermometer] isA33]) {
        return self.otaManager.isOTAing;
    }
    return [SCBLEThermometer sharedThermometer].isOADing;
}

#pragma mark - BLEThermometer Notify

// 开始蓝牙扫描
- (void)scan {
    if ([SCBLEThermometer sharedThermometer].activePeripheral != nil) {
        return;
    }
    //  start to scan the peripheral
    if ([[SCBLEThermometer sharedThermometer] connectThermometerWithMACList:[YCUtility bindedMACAddressList]]) {
    }
}

-(void)setConnectStatus:(BOOL)connected {
    [self.loadingImageV setHidden:connected];
    [self.step2IndicateBtn setHidden:!connected];
    [self.step2IndicateBtn setSelected:connected];
    if (connected) {
        [self loaded];
    } else {
        [self loading];
    }
}

- (void)updateThermometerState:(NSNotification *)notify {
    NSNumber *num = (NSNumber *)notify.object;
    YCBLEState state = (YCBLEState)[num integerValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (state == YCBLEStateValid) {
            self.step1StatusButton.selected = YES;
            self.step1IndicateBtn.selected = YES;
        } else {
            self.step1StatusButton.selected = NO;
            self.step1IndicateBtn.selected = NO;
            self.step2StatusButton.selected = NO;
            self.step2IndicateBtn.selected = NO;
        }
        SCBLEThermometer *thermometer = [SCBLEThermometer sharedThermometer];
        [self setConnectStatus:(nil != thermometer.activePeripheral)];
    });
}

- (void)thermometerConnected:(NSNotification *)notify {
    BOOL connected = [notify.object boolValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.step2StatusButton.selected = connected;
        self.step2IndicateBtn.selected = connected;
        [self.step2IndicateBtn setHidden:connected];
        [self.loadingImageV setHidden:!connected];
        [self setConnectStatus:connected];
        if (!connected) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if ([self isOADing]) {
                NSString *errorMsg = @"设备断开连接，更新设备程序失败。";
                [YCAlertController showAlertWithTitle:@"温馨提示" message:errorMsg cancelHandler:nil confirmHandler:^(UIAlertAction * _Nonnull action) {
                    // OAD 失败，仍然绑定成功
                    [self handleBindAction];
                }];
                [self hideProgressHUD:NO];
                [[SCBLEThermometer sharedThermometer] stopUpdateThermometerFirmwareImage];
            }
        } else {
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.macAddress = [SCBLEThermometer sharedThermometer].macAddress;
            self.firmwareVersion = [SCBLEThermometer sharedThermometer].firmwareVersion;
            [self checkMACAddressIsBinded:nil];
        }
    });
}

- (void)updateFirmwareImageFailed:(NSString *)message {
    //  此处为忽略更新固件失败的结果，继续走绑定流程
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = 1.0;
        self.progressView.progressLabel.text = @"100%";
        [self hideProgressHUD:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.view.userInteractionEnabled = YES;
            NSString *msg = message;
            if (!IS_EMPTY_STRING(msg)) {
                msg = @"稍后您可在“我的设备”页面中再次进行升级。";
            }
            [YCAlertController showAlertWithTitle:@"升级失败" message:msg cancelHandler:nil confirmHandler:^(UIAlertAction * _Nonnull action) {
                [self handleBindAction];
            }];
            NSLog(@"固件更新失败，忽略结果，继续绑定！");
        });
    });
}

- (void)hideProgressHUD:(BOOL)animated {
    if (animated) {
        [self.progressView hideAnimated:YES afterDelay:0.1];
    } else {
        [self.progressView hideAnimated:NO];
    }
}

#pragma mark - OAD Delegate

-(void)thermometer:(SCBLEThermometer *)thermometer didReadFirmwareImageType:(YCBLEFirmwareImageType)imgReversion {
    NSLog(@"img reversion  %@", @(imgReversion));
}

-(void)thermometerDidBeginFirmwareImageUpdate:(SCBLEThermometer *)thermometer {
    if ([SCBLEThermometer sharedThermometer].activePeripheral == nil) {
        [YCAlertController showAlertWithBody:@"未连接到设备" finished:nil];
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        self.progressView.progress = 0.0;
        self.progressView.progressLabel.text = @"0%";
        [self.view addSubview:self.progressView];
        [self.progressView showAnimated:YES];
        self.view.userInteractionEnabled = NO;
    });
}

-(void)thermometer:(SCBLEThermometer *)thermometer didUpdateFirmwareImage:(YCBLEOADResultType)type message:(NSString *)message {
    switch (type) {
        case YCBLEOADResultTypeSucceed: {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressView.progress = 1.0;
                self.progressView.progressLabel.text = @"100%";
                self.firmwareVersion = self.newestFirmwareVersion;
                [self hideProgressHUD:NO];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self handleBindAction];
                    self.view.userInteractionEnabled = YES;
                });
            });
        }
            break;
        case YCBLEOADResultTypeFailed: {
            [self updateFirmwareImageFailed:message];
        }
            break;
        case YCBLEOADResultTypeIsRunning: {
        }
            break;
        default:
            break;
    }
}

-(void)thermometer:(SCBLEThermometer *)thermometer firmwareImageUpdateProgress:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = progress;
        self.progressView.progressLabel.text = [NSString stringWithFormat:@"%@%%", @((NSInteger)(MIN(progress * 100, 100)))];
    });
}

#pragma mark - lazy load

- (YCDownloadingFile *)fileDownload {
    if (_fileDownload == nil) {
        _fileDownload = [[YCDownloadingFile alloc] init];
    }
    return _fileDownload;
}

-(MBProgressHUD *)progressView {
    if (_progressView == nil) {
        _progressView = [[MBProgressHUD alloc] initWithView:self.view];
        _progressView.mode = MBProgressHUDModeAnnularDeterminate;
        _progressView.progress = 0.0;
        _progressView.contentColor = [UIColor mainColor];
        _progressView.minSize = CGSizeMake(120, 120);
        _progressView.label.text = @"设备正在升级程序";
        _progressView.detailsLabel.text = @"为了保证良好的蓝牙连接，请始终保持孕橙在屏幕显示，并请不要关闭设备";
    }
    return _progressView;
}

-(UIButton *)step1IndicateBtn {
    if (_step1IndicateBtn == nil) {
        _step1IndicateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_step1IndicateBtn setImage:[UIImage imageNamed:@"device_binding_page_ic_unselected"] forState:UIControlStateNormal];
        [_step1IndicateBtn setImage:[UIImage imageNamed:@"device_binding_page_ic_selected"] forState:UIControlStateSelected];
        [self.view addSubview:_step1IndicateBtn];
        [_step1IndicateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(38);
            make.top.mas_equalTo(60 + kTabBarHeight);
            make.width.height.mas_equalTo(34);
        }];
    }
    return _step1IndicateBtn;
}

-(UIButton *)step2IndicateBtn {
    if (_step2IndicateBtn == nil) {
        _step2IndicateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_step2IndicateBtn setImage:[UIImage imageNamed:@"device_binding_page_ic_unselected"] forState:UIControlStateNormal];
        [_step2IndicateBtn setImage:[UIImage imageNamed:@"device_binding_page_ic_selected"] forState:UIControlStateSelected];
        [self.view addSubview:_step2IndicateBtn];
        [_step2IndicateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.step1IndicateBtn.mas_leading);
            make.top.mas_equalTo(self.step1IndicateBtn.mas_bottom).mas_offset(120);
            make.width.height.mas_equalTo(34);
        }];
    }
    return _step2IndicateBtn;
}

-(UIImageView *)loadingImageV {
    if (_loadingImageV == nil) {
        _loadingImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"device_binding_page_ic_loading"]];
        [_loadingImageV setHidden:true];
        [self.view addSubview:_loadingImageV];
        [_loadingImageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.step1IndicateBtn.mas_leading);
            make.top.mas_equalTo(self.step1IndicateBtn.mas_bottom).mas_offset(120);
            make.width.height.mas_equalTo(34);
        }];
    }
    return _loadingImageV;
}

-(UIButton *)step3IndicateBtn {
    if (_step3IndicateBtn == nil) {
        _step3IndicateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_step3IndicateBtn setImage:[UIImage imageNamed:@"device_binding_page_ic_unselected"] forState:UIControlStateNormal];
        [_step3IndicateBtn setImage:[UIImage imageNamed:@"device_binding_page_ic_selected"] forState:UIControlStateSelected];
        [self.view addSubview:_step3IndicateBtn];
        [_step3IndicateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.step1IndicateBtn.mas_leading);
            make.top.mas_equalTo(self.step2IndicateBtn.mas_bottom).mas_offset(120);
            make.width.height.mas_equalTo(34);
        }];
    }
    return _step3IndicateBtn;
}

-(UILabel *)step1TitleLbl {
    if (_step1TitleLbl == nil) {
        _step1TitleLbl = [[UILabel alloc] init];
        _step1TitleLbl.text = @"请打开手机蓝牙";
        _step1TitleLbl.font = [UIFont systemFontOfSize:14];
        _step1TitleLbl.textColor = [UIColor textColor];
        [self.view addSubview:_step1TitleLbl];
        [_step1TitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.step1IndicateBtn.mas_trailing).mas_offset(30);
            make.centerY.mas_equalTo(self.step1IndicateBtn.mas_centerY);
        }];
    }
    return _step1TitleLbl;
}

-(UILabel *)step2TitleLbl {
    if (_step2TitleLbl == nil) {
        _step2TitleLbl = [[UILabel alloc] init];
        _step2TitleLbl.text = @"按下开关键";
        _step2TitleLbl.font = [UIFont systemFontOfSize:14];
        _step2TitleLbl.textColor = [UIColor textColor];
        [self.view addSubview:_step2TitleLbl];
        [_step2TitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.step2IndicateBtn.mas_trailing).mas_offset(30);
            make.centerY.mas_equalTo(self.step2IndicateBtn.mas_centerY);
        }];
    }
    return _step2TitleLbl;
}

-(UILabel *)step3TitleLbl {
    if (_step3TitleLbl == nil) {
        _step3TitleLbl = [[UILabel alloc] init];
        _step3TitleLbl.text = @"设备程序版本校验";
        _step3TitleLbl.font = [UIFont systemFontOfSize:14];
        _step3TitleLbl.textColor = [UIColor textColor];
        [self.view addSubview:_step3TitleLbl];
        [_step3TitleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.step3IndicateBtn.mas_trailing).mas_offset(30);
            make.centerY.mas_equalTo(self.step3IndicateBtn.mas_centerY);
        }];
    }
    return _step3TitleLbl;
}


-(UIButton *)step1StatusButton {
    if (_step1StatusButton == nil) {
        _step1StatusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_step1StatusButton setImage:[UIImage imageNamed:@"device_binding_page_pic_bluetooth_unselected"] forState:UIControlStateNormal];
        [_step1StatusButton setImage:[UIImage imageNamed:@"device_binding_page_pic_bluetooth_selected"] forState:UIControlStateSelected];
        [self.view addSubview:_step1StatusButton];
        [_step1StatusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(-40);
            make.centerY.mas_equalTo(self.step1IndicateBtn.mas_centerY);
        }];
    }
    return _step1StatusButton;
}

-(UIButton *)step2StatusButton {
    if (_step2StatusButton == nil) {
        _step2StatusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_step2StatusButton setImage:[UIImage imageNamed:@"device_binding_page_pic_device_unselected"] forState:UIControlStateNormal];
        [_step2StatusButton setImage:[UIImage imageNamed:@"device_binding_page_pic_device_selected"] forState:UIControlStateSelected];
        [self.view addSubview:_step2StatusButton];
        [_step2StatusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(-40);
            make.centerY.mas_equalTo(self.step2IndicateBtn.mas_centerY);
        }];
    }
    return _step2StatusButton;
}

-(UIButton *)step3StatusButton {
    if (_step3StatusButton == nil) {
        _step3StatusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_step3StatusButton setImage:[UIImage imageNamed:@"device_binding_page_pic_check_unselected"] forState:UIControlStateNormal];
        [_step3StatusButton setImage:[UIImage imageNamed:@"device_binding_page_pic_check_selected"] forState:UIControlStateSelected];
        [self.view addSubview:_step3StatusButton];
        [_step3StatusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(-40);
            make.centerY.mas_equalTo(self.step3IndicateBtn.mas_centerY);
        }];
    }
    return _step3StatusButton;
}

-(UIView *)line1View {
    if (_line1View == nil) {
        _line1View = [[UIView alloc] init];
        _line1View.backgroundColor = [UIColor colorWithHex:0xF0F0F0];
        [self.view addSubview:_line1View];
        [_line1View mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(100);
            make.trailing.mas_equalTo(0);
            make.top.mas_equalTo(self.step1IndicateBtn.mas_bottom).offset(60);
            make.height.mas_equalTo(2);
        }];
    }
    return  _line1View;
}

-(UIView *)line2View {
    if (_line2View == nil) {
        _line2View = [[UIView alloc] init];
        _line2View.backgroundColor = [UIColor colorWithHex:0xF0F0F0];
        [self.view addSubview:_line2View];
        [_line2View mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(100);
            make.trailing.mas_equalTo(0);
            make.top.mas_equalTo(self.step2IndicateBtn.mas_bottom).offset(60);
            make.height.mas_equalTo(2);
        }];
    }
    return  _line2View;
}

-(UIView *)line3View {
    if (_line3View == nil) {
        _line3View = [[UIView alloc] init];
        _line3View.backgroundColor = [UIColor colorWithHex:0xF0F0F0];
        [self.view addSubview:_line3View];
        [_line3View mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(100);
            make.trailing.mas_equalTo(0);
            make.top.mas_equalTo(self.step3IndicateBtn.mas_bottom).offset(60);
            make.height.mas_equalTo(2);
        }];
    }
    return  _line3View;
}

-(SCOTAManager *)otaManager {
    if (_otaManager == nil) {
        _otaManager = [[SCOTAManager alloc] init];
    }
    return _otaManager;
}

@end
