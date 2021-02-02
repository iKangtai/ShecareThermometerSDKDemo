//
//  YCUpdateDeviceController.m
//  Shecare
//
//  Created by mac on 2019/4/18.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCUpdateDeviceController.h"
#import <SCBLESDK/SCBLESDK.h>
#import "MBProgressHUD.h"
#import "YCDownloadingFile.h"
#import "YCUserHardwareInfoModel.h"

@interface YCUpdateDeviceController()<BLEThermometerOADDelegate>

@property (nonatomic, strong) MBProgressHUD *progressView;
///  简单的多任务下载文件，用在下载OAD的硬件
@property (strong, nonatomic) YCDownloadingFile *fileDownload;
///  是否正在从服务器检查硬件版本
@property (nonatomic, assign) BOOL ischeckingFirmwareVersionFromCloud;
///  下载最新固件的链接
@property (strong, nonatomic) NSArray <NSString *>*downloadUrls;
///  从服务器获取的最新固件版本信息
@property (copy, nonatomic) NSString *newestFirmwareVersion;

@property (nonatomic, strong) SCOTAManager *otaManager;

@end

@implementation YCUpdateDeviceController

-(instancetype)init {
    if (self = [super init]) {
        self.ischeckingFirmwareVersionFromCloud = NO;
        [SCBLEThermometer sharedThermometer].oadDelegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(thermometerConnected:) name:kNotification_ThermometerConnectSuccessed object:nil];
    }
    return self;
}

-(void)updateDevice {
#if !TARGET_OS_SIMULATOR
    if ([SCBLEThermometer sharedThermometer].activePeripheral != nil) {
        if (!IS_EMPTY_STRING([SCBLEThermometer sharedThermometer].firmwareVersion)
            && [SCBLEThermometer sharedThermometer].imageType != YCBLEFirmwareImageTypeUnknown) {
            [self checkFirmwareVersionFromCloud];
        } else {
            [YCAlertController showAlertWithBody:@"获取设备版本失败，请重新连接设备！" finished:nil];
        }
    } else {
        [YCAlertController showAlertWithBody:@"未连接到设备" finished:nil];
    }
#endif
}

- (void)checkFirmwareVersionFromCloud {
    if (self.ischeckingFirmwareVersionFromCloud) {
        return;
    }
    self.ischeckingFirmwareVersionFromCloud = YES;
    
    [MBProgressHUD showHUDAddedTo:[UIViewController currentViewController].view animated:YES];
    [self checkFirmwareVersion];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.ischeckingFirmwareVersionFromCloud = NO;
    });
}

-(void)checkFirmwareVersion {
    NSInteger factory = 1; // 1 孕橙 2 安康源
    if ([[SCBLEThermometer sharedThermometer] isA33]) {
        factory = 2;
    }
    NSDictionary *dataDict = @{@"version": @"3.68", @"A": @"http://yunchengfile.oss-cn-beijing.aliyuncs.com/firmware/A31/Athermometer.bin", @"B": @"http://yunchengfile.oss-cn-beijing.aliyuncs.com/firmware/A31/Bthermometer.bin"};
    NSMutableArray *urlsM = [NSMutableArray array];
    if (dataDict[@"A"] != nil) {
        [urlsM addObject:dataDict[@"A"]];
    }
    if (dataDict[@"B"] != nil) {
        [urlsM addObject:dataDict[@"B"]];
    }
    self.downloadUrls = urlsM.copy;
    self.newestFirmwareVersion = [dataDict objectForKey:@"version"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([YCUtility compareVersion:self.newestFirmwareVersion and:[SCBLEThermometer sharedThermometer].firmwareVersion] == NSOrderedDescending) {
            YCWeakSelf(self)
            [YCAlertController showAlertWithTitle:@"您的设备程序不是最新的，请点击确定更新设备程序！"
                                          message:nil
                                    cancelHandler:^(UIAlertAction * _Nonnull action) {
            } confirmHandler:^(UIAlertAction * _Nonnull action) {
                YCStrongSelf(self)
                [self checkUpLocalNewFirmwareVersion];
            }];
        } else {
            [self firmwareVersionIsNewest];
        }
    });
}

- (void)connectToNewThermometer {
#if !TARGET_OS_SIMULATOR
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([SCBLEThermometer sharedThermometer].activePeripheral == nil) {
            [SCBLEThermometer sharedThermometer].connectType = YCBLEConnectTypeNotBinding;
            [SHAREDAPP startScan];
        }
    });
#endif
}

- (void)firmwareVersionIsNewest {
    [YCAlertController showAlertWithBody:@"恭喜，您的设备程序已经是最新的了！" finished:nil];
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
        [MBProgressHUD hideHUDForView:[UIViewController currentViewController].view animated:YES];
        [YCAlertController showAlertWithBody:@"设备程序下载失败，请检查网络后重新下载。" finished:nil];
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
        [[SCBLEThermometer sharedThermometer] setCleanState:YCBLECommandTypeOAD xx:0 yy:0];
        
        [[SCBLEThermometer sharedThermometer] updateThermometerFirmware:[self localImgPaths]];
        return;
    }
    [YCAlertController showAlertWithBody:@"数据获取失败，请重新连接蓝牙后再试" finished:nil];
    [MBProgressHUD hideHUDForView:[UIViewController currentViewController].view animated:YES];
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

-(void)dealloc {
    if ([MBProgressHUD HUDForView:[UIViewController currentViewController].view] != nil) {
        [MBProgressHUD hideHUDForView:[UIViewController currentViewController].view animated:YES];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%@---%s", [self class], __FUNCTION__);
}

-(BOOL)isOADing {
    if ([[SCBLEThermometer sharedThermometer] isA33]) {
        return self.otaManager.isOTAing;
    }
    return [SCBLEThermometer sharedThermometer].isOADing;
}

#pragma mark - ble thermometer notify

- (void)thermometerConnected:(NSNotification *)notify {
    BOOL connected = [notify.object boolValue];
    if (connected) {
        
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self isOADing]) {
                [YCAlertController showAlertWithTitle:@"温馨提示" message:@"设备断开连接，更新设备程序失败。" cancelHandler:nil confirmHandler:^(UIAlertAction * _Nonnull action) {
                }];
                [self hideProgressHUD:NO];
                [MBProgressHUD hideHUDForView:[UIViewController currentViewController].view animated:YES];
                [[SCBLEThermometer sharedThermometer] stopUpdateThermometerFirmwareImage];
            }
            [UIViewController currentViewController].view.userInteractionEnabled = YES;
        });
    }
}

- (void)updateFirmwareImageFailed {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *alertBody = @"更新设备程序失败，请稍后重试！";
        YCWeakSelf(self)
        [YCAlertController showAlertWithBody:alertBody finished:^(UIAlertAction * _Nonnull action) {
            YCStrongSelf(self)
            [self connectToNewThermometer];
        }];
        [self hideProgressHUD:NO];
        [MBProgressHUD hideHUDForView:[UIViewController currentViewController].view animated:YES];
        [UIViewController currentViewController].view.userInteractionEnabled = YES;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:[UIViewController currentViewController].view animated:YES];
        self.progressView.progress = 0.0;
        self.progressView.progressLabel.text = @"0%";
        [[UIViewController currentViewController].view addSubview:self.progressView];
        [self.progressView showAnimated:YES];
        [UIViewController currentViewController].view.userInteractionEnabled = NO;
    });
}

-(void)thermometer:(SCBLEThermometer *)thermometer didUpdateFirmwareImage:(YCBLEOADResultType)type message:(NSString *)message {
    switch (type) {
        case YCBLEOADResultTypeSucceed: {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.progress = 1.0;
                self.progressView.progressLabel.text = @"100%";
                [self hideProgressHUD:NO];
                if (!IS_EMPTY_STRING([SCBLEThermometer sharedThermometer].macAddress)) {
                    //  更新设备信息到本地
                    YCUserHardwareInfoModel *bindingModel = [YCUserHardwareInfoModel modelWithMACAddress:[SCBLEThermometer sharedThermometer].macAddress version:self.newestFirmwareVersion syncType:NO];
                    [YCUtility addHardwareInfoToLocal:bindingModel];
                }
            });
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                YCWeakSelf(self)
                [YCAlertController showAlertWithBody:@"更新设备程序成功！" finished:^(UIAlertAction * _Nonnull action) {
                    YCStrongSelf(self)
                    [self connectToNewThermometer];
                }];
                [UIViewController currentViewController].view.userInteractionEnabled = YES;
            });
        }
            break;
        case YCBLEOADResultTypeFailed: {
            [self updateFirmwareImageFailed];
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
        self.progressView.progressLabel.text = [NSString stringWithFormat:@"%@%%", @((NSInteger)(progress * 100))];
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
        _progressView = [[MBProgressHUD alloc] initWithView:[UIViewController currentViewController].view];
        //        _progressView.removeFromSuperViewOnHide = YES;
        _progressView.mode = MBProgressHUDModeAnnularDeterminate;
        // _progressView.customView = [[MBRoundProgressView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
        _progressView.progress = 0.0;
        _progressView.contentColor = [UIColor mainColor];
        _progressView.minSize = CGSizeMake(120, 120);
        // _progressView.margin = 8.0;
        _progressView.label.text = @"设备正在升级程序";
        _progressView.detailsLabel.text = @"为了保证良好的蓝牙连接，请始终保持孕橙在屏幕显示，并请不要关闭设备";
    }
    return _progressView;
}

-(SCOTAManager *)otaManager {
    if (_otaManager == nil) {
        _otaManager = [[SCOTAManager alloc] init];
    }
    return _otaManager;
}

@end
