//
//  CommonAppDelegate.m
//  Shecare
//
//  Created by mac on 2019/12/27.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#import "YCCommonAppDelegate.h"
#import "ShecareBLEThermometer.h"
#import "YCBindViewController.h"
#import "YCUserTemperatureModel.h"

// iOS10 注册 APNs 所需头⽂文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface YCCommonAppDelegate()<UNUserNotificationCenterDelegate, BLEThermometerDelegate>

@end

@implementation YCCommonAppDelegate

+(YCCommonAppDelegate *)shared {
    static YCCommonAppDelegate *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YCCommonAppDelegate alloc] init];
    });
    return instance;
}

-(void)prepareAppWithOptions:(NSDictionary *)launchOptions {
#if !TARGET_OS_SIMULATOR
    NSString *macStr = [YCUtility bindedMACAddressList];
    if (macStr.length > 0) {
        [ShecareBLEThermometer sharedThermometer].restoreIDKey = macStr;
        NSArray *centraManagerIdentifiers = launchOptions[UIApplicationLaunchOptionsBluetoothCentralsKey];
        for (NSString *identifier in centraManagerIdentifiers) {
            if ([identifier isEqualToString:macStr]) {
                NSLog(@"Get YCBLECentralManagerRIK!");
            }
        }
    }
    [ShecareBLEThermometer sharedThermometer].delegate = [YCCommonAppDelegate shared];
    if ([ShecareBLEThermometer sharedThermometer].activeThermometer == nil) {
        [ShecareBLEThermometer sharedThermometer].connectType = YCBLEConnectTypeNotBinding;
        [[YCCommonAppDelegate shared] scan];
    }
#endif
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSaveHardwareTemperatures:) name:kNotification_DidSaveHardwareTemperaturesToDB object:nil];
}

#pragma mark - UNUserNotificationCenterDelegate

// iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
//    NSDictionary *userInfo = notification.request.content.userInfo;
//    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
//        // 应用处于前台时的远程推送接受
//        // 必须加这句代码
//    } else {
//        // 应用处于前台时的本地推送接受
//    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

// iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
//    NSDictionary *userInfo = response.notification.request.content.userInfo;
//    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
//        // 应用处于后台时的远程推送接受
//        // 必须加这句代码
//    } else {
//        // 应用处于后台时的本地推送接受
//    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

#pragma mark - BLEThermometer

- (void)bleThermometerBluetoothDidUpdateState {
    YCBLEState state = [ShecareBLEThermometer sharedThermometer].bleState;
    //  set the bt state tag
    if (state != YCBLEStateValid) {
        [ShecareBLEThermometer sharedThermometer].activeThermometer = nil;
        [ShecareBLEThermometer sharedThermometer].macAddress = @"";
        [ShecareBLEThermometer sharedThermometer].firmwareVersion = @"";
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerConnectSuccessed object:@(NO)];
    }
    
    [ShecareBLEThermometer sharedThermometer].connectType = [self getNewConnectType];
    [self scan];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerDidUpdateState object:@(state)];
}

- (void)bleDidConnectThermometer {
    UIViewController *curVC = [UIViewController currentViewController];
    //  绑定相关页面不弹出 “已连接”
    if ([curVC isKindOfClass:[YCBindViewController class]]) {
    } else {
        //  硬件连接后的提示
        [YCAlertController showToast:@"已连接" completion:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerConnectSuccessed object:@(YES)];
}

-(void)bleDidFailedToConnectThermometer:(CBPeripheral *)thermometer {
    [self startScan:NO];
}

- (void)bleDidDisconnectThermometer:(CBPeripheral *)thermometer error:(NSError *)error {
    self.validTemps = nil;
    if (error != nil) {
        NSLog(@"Try to reconnect the last connected thermometer.");
        [self startScan:YES];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerConnectSuccessed object:@(NO)];
}

- (void)thermometerDidUploadTemperature:(double)temperature timestamp:(NSDate *)timestamp endmeasureFlag:(YCBLEMeasureFlag)flag firmwareVersion:(NSString *)firmwareVersion {
    
    YCUserTemperatureModel *tModel = [YCUserTemperatureModel modelWithTemperature:[NSNumber numberWithDouble:temperature] time:timestamp type:[NSNumber numberWithInt:(temperature > 80.0 && temperature < 120.0) ? 2 : 1] temperatureID:[YCUtility generateUniqueIdentifier]];
    
    if ([[ShecareBLEThermometer sharedThermometer] isA32:ShecareBLEThermometer.sharedThermometer.activeThermometer]
        || [[ShecareBLEThermometer sharedThermometer] isA33:ShecareBLEThermometer.sharedThermometer.activeThermometer]
        || firmwareVersion.floatValue > 2.85f
        || firmwareVersion.floatValue < 2.0f) {
        //  设备时间重置后，可能出现测温时间一样的数据；如果是三代设备，过滤掉后，会造成 TempCount 指令发送的数量和实际收到的数量不一致，造成设备 “不停重发所有温度” 的问题。
        //  把数据过滤放在数据库存储部分即可。
        [self.validTemps addObject:tModel];
        if (flag == YCBLEMeasureFlagOfflineBegin) {

        } else if (flag == YCBLEMeasureFlagOfflineEnd) {
            [self insertTemperaturesToDB:self.validTemps.copy];
            self.validTemps = nil;
        } else if (YCBLEMeasureFlagOnline == flag) {
            [self insertTemperaturesToDB:self.validTemps.copy];
            self.validTemps = nil;
        }
    } else {
        [self insertTemperaturesToDB:@[tModel]];
    }
}

-(void)thermometerDidUploadTemperatures:(NSArray <YCTemperature *>*)temperatures firmwareVersion:(NSString *)firmwareVersion {
    for (int i = 0; i < temperatures.count; i++) {
        YCTemperature *tempI = temperatures[i];
        if (i == temperatures.count - 1) {
            tempI.flag = YCBLEMeasureFlagOfflineEnd;
        } else {
            tempI.flag = YCBLEMeasureFlagOfflineBegin;
        }
        NSDate *dateI = [NSDate dateWithyyyyMMddHHmmssString:tempI.time];
        if (dateI != nil) {
            [self thermometerDidUploadTemperature:tempI.temperature timestamp:dateI endmeasureFlag:tempI.flag firmwareVersion:firmwareVersion];
        } else {
            NSLog(@"体温时间异常：%@ %@ %@", tempI.time, @(tempI.temperature), @(tempI.flag));
        }
    }
}

- (void)insertTemperaturesToDB:(NSArray <YCUserTemperatureModel *>*)temperatures {
    if (temperatures == nil || temperatures.count == 0) {
        NSLog(@"异常：%s 收到了 空数据", __FUNCTION__);
        return;
    }
    
    for (YCUserTemperatureModel *tempInfo in temperatures) {
        [YCUtility addTemperatureInfoToLocal:tempInfo];
    }
    
    if (temperatures.count > 0) {
        [self setTemperatureUploadAlarmWithTimeInterval:1.0 tempArr:temperatures.copy];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_DidUploadTemperatures object:temperatures];
    //  提高 未同步 数据的上传频率
    [[ShecareBLEThermometer sharedThermometer] setCleanState:YCBLECommandTypeTempCount xx:(Byte)temperatures.count yy:0];
}

-(void)didSaveHardwareTemperatures:(NSNotification *)notify {
    if ([notify.object isKindOfClass:[NSArray class]]) {
        NSArray *tempArr = notify.object;
        [self openBBTUploadVC:tempArr];
    }
}

-(void)openBBTUploadVC:(NSArray *)tempArr {
    if (tempArr == nil || tempArr.count == 0) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        // 打开温度列表弹窗
//        YCBBTUploadViewController *vc = [[YCBBTUploadViewController alloc] init];
//        vc.temperatures = tempArr;
//        YCCustomNavigationController *navC = [[YCCustomNavigationController alloc] initWithRootViewController:vc];
//        navC.modalPresentationStyle = UIModalPresentationFullScreen;
//        [[UIViewController currentViewController] presentViewController:navC animated:true completion:^{
//        }];
    });
}

- (void)bleThermometerDidGetThermometerPower:(float)powerValue {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerCurrentPower object:@(powerValue)];
}

- (void)bleThermometerDidGetThermometerTime:(NSString *)dateStr {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerCurrentTime object:dateStr];
}

-(void)bleThermometerDidBindThermometer:(BOOL)success {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerDidBind object:@(success)];
}

-(void)bleThermometerDidSetWarmupTime:(BOOL)success {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerDidSetWarmupTime object:@(success)];
}

-(void)bleThermometerDidSetMeasureTime:(BOOL)success {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerDidSetMeasureTime object:@(success)];
}

-(void)bleThermometerDidClearDatas:(BOOL)success {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerDidClearDatas object:@(success)];
}

-(void)bleThermometerDidChangeTempTypeSucceed:(BOOL)success {
    if (success) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kDefaults_TemperatureUnitsChanged];
    }
}

- (void)bleThermometer:(ShecareBLEThermometer *)bleTherm didUpdateSynchronizationDateResult:(YCBLEWriteResult)type {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerSyncDateResult object:@(type)];
    
    if ([[ShecareBLEThermometer sharedThermometer] isA32:ShecareBLEThermometer.sharedThermometer.activeThermometer]
        || [[ShecareBLEThermometer sharedThermometer] isA33:ShecareBLEThermometer.sharedThermometer.activeThermometer]
        || [bleTherm.firmwareVersion hasPrefix:@"3"]
        || [bleTherm.firmwareVersion hasPrefix:@"10"]) {
        [[ShecareBLEThermometer sharedThermometer] setCleanState:YCBLECommandTypeGetPower xx:0 yy:0];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //  需要考虑：绑定多个设备时，温度单位不能同步给所有设备的问题
        BOOL typeChanged = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaults_TemperatureUnitsChanged];
        if (typeChanged) {
            NSInteger tempType = [[NSUserDefaults standardUserDefaults] integerForKey:kDefaults_TemperatureUnits];
            if (2 == tempType) {
                [[ShecareBLEThermometer sharedThermometer] setCleanState:YCBLECommandTypeSetUnitF xx:0 yy:0];
            } else if (1 == tempType) {
                [[ShecareBLEThermometer sharedThermometer] setCleanState:YCBLECommandTypeSetUnitC xx:0 yy:0];
            }
        }
    });
}

- (void)scan {
    [self startScan:NO];
}

- (void)startScan:(BOOL)shouldRestart {
    if ([ShecareBLEThermometer sharedThermometer].activeThermometer != nil) {
        return;
    }
    //  start to scan the peripheral
    if ([[ShecareBLEThermometer sharedThermometer] connectThermometerWithMACList:[YCUtility bindedMACAddressList]]) {
    }
    
    if (shouldRestart) {
        //  避免 APP 的蓝牙扫描被系统停止
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * 60 * 60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startScan:YES];
        });
    }
}


-(void)disconnectActiveThermometer:(YCBLEConnectType)connectType {
    [[ShecareBLEThermometer sharedThermometer] disconnectActiveThermometer];
}

- (void)bleThermometerDidUpdateFirmwareRevision:(NSString *)firmwareVersion {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_UpdateFirmwareRevision object:firmwareVersion];
    //  产品连接后自动同步时间
    if ([[ShecareBLEThermometer sharedThermometer] isA32:ShecareBLEThermometer.sharedThermometer.activeThermometer]
        || [[ShecareBLEThermometer sharedThermometer] isA33:ShecareBLEThermometer.sharedThermometer.activeThermometer]
        || [firmwareVersion hasPrefix:@"3"]
        || [firmwareVersion hasPrefix:@"10"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[ShecareBLEThermometer sharedThermometer] asynchroizationTimeFromLocal:[NSDate date]];
        });
    }
    if ([[ShecareBLEThermometer sharedThermometer] isA32:ShecareBLEThermometer.sharedThermometer.activeThermometer]
        || [[ShecareBLEThermometer sharedThermometer] isA33:ShecareBLEThermometer.sharedThermometer.activeThermometer]
        || firmwareVersion.floatValue > 2.945) {
        [[ShecareBLEThermometer sharedThermometer] setCleanState:YCBLECommandTypeTransmitTemp xx:0 yy:0];
    }
}

-(void)bleThermometerDidGetMACAddress:(NSString *)macAddress {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_UpdateMACAddress object:macAddress];
}

///  设置体温计 测温模式 的回调
-(void)bleThermometerDidSetMeasureMode:(BOOL)success {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_SetMeasureMode object:@(success)];
}

///  获取体温计测温模式的回调
-(void)bleThermometerDidGetMeasureMode:(BLEMeasureMode)mode {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_GetMeasureMode object:@(mode)];
}

///  获取体温计预热时间和测温时间，单位 s
-(void)bleThermometerDidGetMeasureTime:(NSInteger)measure warmupTime:(NSInteger)warmup {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_GetMeasureAndWarmupTime object:@[@(measure), @(warmup)]];
}

-(YCBLEConnectType)getNewConnectType {
    UIViewController *vc = [UIViewController currentViewController];
    if (vc != nil) {
        NSString *vcClass = NSStringFromClass([vc class]);
        if ([vcClass isEqualToString:@"YCBindViewController"]) {
            return YCBLEConnectTypeBinding;
        }
    }
    return YCBLEConnectTypeNotBinding;
}

- (void)setTemperatureUploadAlarmWithTimeInterval:(NSTimeInterval)timeInt tempArr:(NSArray *)tempArr {
    if (tempArr == nil || tempArr.count == 0) {
        return;
    }
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self scheduleNotificationWithTimeInterval:timeInt tempArr:tempArr];
    }
}

-(void)scheduleNotificationWithTimeInterval:(NSTimeInterval)timeInt tempArr:(NSArray *)tempArr {
    NSMutableString *message = [NSMutableString string];
    if (tempArr.count == 1) {
        YCUserTemperatureModel *model = tempArr.firstObject;
        message = [NSMutableString stringWithFormat:@"收到一条体温数据：%@。", [model temperatureString]];
    } else {
        message = [NSMutableString stringWithFormat:@"收到%@条体温数据", @(tempArr.count)];
    }
    
    NSMutableArray *tempDicts = [NSMutableArray arrayWithCapacity:tempArr.count];
    for (YCUserTemperatureModel *tempInfo in tempArr) {
        [YCUtility addTemperatureInfoToLocal:tempInfo];
    }
    
    if (@available(iOS 10.0, *)) {
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeInt repeats:NO];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = @"";
        content.body = message;
        content.sound = [UNNotificationSound defaultSound];
        content.userInfo = @{
            @"lntype" : @"tempAlarm",
            @"temperatures": tempDicts.copy
        };
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"temperatureAlarm" content:content.copy trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error: %@", error);
            } else {
                NSLog(@"%s Succeed! ", __FUNCTION__);
            }
        }];
    } else {
        UILocalNotification *alarmNotification = [[UILocalNotification alloc] init];
        alarmNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInt];
        alarmNotification.soundName = UILocalNotificationDefaultSoundName;
        alarmNotification.alertBody = [NSString stringWithFormat:@"%@", message];
        alarmNotification.userInfo = @{
            @"lntype" : @"tempAlarm",
            @"temperatures": tempDicts.copy
        };
        alarmNotification.repeatInterval = 0;
        alarmNotification.timeZone = [NSTimeZone systemTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:alarmNotification];
    }
}

-(NSMutableArray *)validTemps {
    if (_validTemps == nil) {
        _validTemps = [[NSMutableArray alloc] init];
    }
    return _validTemps;
}

@end

