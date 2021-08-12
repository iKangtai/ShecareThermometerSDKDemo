//
//  AppDelegate.m
//  ShecareThermometerSDKDemo
//
//  Created by KyokuSei on 2021/1/24.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import <SCBLESDK/SCBLESDK.h>
#import "YCMainViewController.h"
#import "YCBindViewController.h"
#import "YCUserTemperatureModel.h"
#import "YCFetalHeartMonitorViewController.h"

#define DEMO_APP_ID @"100017"
#define DEMO_APP_SECRET @"b1eed2fb4686e1b1049a9486d49ba015af00d5a0"
#define DEMO_UNION_ID @"15311411877"

@interface AppDelegate ()<BLEThermometerDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#warning SDK 正式上线时，需要把 appId、appSecret 和 unionId 改为厂商正式环境的数据
    SCBLEThermometer *thermometer = [SCBLEThermometer sharedThermometer];
    thermometer.appId = DEMO_APP_ID;
    thermometer.appSecret = DEMO_APP_SECRET;
    thermometer.unionId = DEMO_UNION_ID;
    
#if !TARGET_OS_SIMULATOR
    thermometer.delegate = self;
    if (thermometer.activePeripheral == nil) {
        thermometer.connectType = YCBLEConnectTypeNotBinding;
        [self startScan];
    }
#endif
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    YCMainViewController *temVC = [[YCMainViewController alloc] init];
    temVC.title = @"首页";
    UINavigationController *temNavC = [[UINavigationController alloc] initWithRootViewController:temVC];
    temNavC.navigationBar.translucent = false;
    
    self.window.rootViewController = temNavC;
    [self.window makeKeyAndVisible];
    
    return YES;
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
}

- (void)startScan {
    SCBLEThermometer *thermometer = [SCBLEThermometer sharedThermometer];
    if (thermometer.activePeripheral != nil) {
        return;
    }
    //  start to scan the peripheral
    if ([thermometer connectThermometerWithMACList:[YCUtility bindedMACAddressList]]) {
    }
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
        NSString *subTitleStr = @"温馨提示";
        UILocalNotification *alarmNotification = [[UILocalNotification alloc] init];
        alarmNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:timeInt];
        alarmNotification.soundName = UILocalNotificationDefaultSoundName;
        alarmNotification.alertBody = [NSString stringWithFormat:@"%@\n%@", subTitleStr, message];
        alarmNotification.userInfo = @{
            @"lntype" : @"tempAlarm",
            @"temperatures": tempDicts.copy
        };
        alarmNotification.repeatInterval = 0;
        alarmNotification.timeZone = [NSTimeZone systemTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:alarmNotification];
    }
}

#pragma mark - BLEThermometerDelegate

-(void)didConnectThermometer:(SCBLEThermometer *)thermometer {
    UIViewController *curVC = [UIViewController currentViewController];
    //  绑定相关页面不弹出 “已连接”
    if ([curVC isKindOfClass:[YCBindViewController class]]) {
    } else {
        //  硬件连接后的提示
        [YCAlertController showToast:@"已连接" completion:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerConnectSuccessed object:@(YES)];
}

-(void)didFailedToConnectThermometer:(SCBLEThermometer *)thermometer {
    [self startScan];
}

-(void)didDisconnectThermometer:(SCBLEThermometer *)thermometer error:(NSError *)error {
    if (error != nil) {
        NSLog(@"Try to reconnect the last connected thermometer.");
        [self startScan];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerConnectSuccessed object:@(NO)];
}

-(void)thermometer:(SCBLEThermometer *)thermometer didUpdateBluetoothState:(YCBLEState)state {
    if (state != YCBLEStatePoweredOn) {
        [SCBLEThermometer sharedThermometer].activePeripheral = nil;
        [SCBLEThermometer sharedThermometer].macAddress = @"";
        [SCBLEThermometer sharedThermometer].firmwareVersion = @"";
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerConnectSuccessed object:@(NO)];
    }
    
    [SCBLEThermometer sharedThermometer].connectType = [self getNewConnectType];
    [self startScan];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerDidUpdateState object:@(state)];
}

-(void)thermometer:(SCBLEThermometer *)thermometer didUploadTemperatures:(NSArray<SCBLETemperature *> *)temperatures {
    NSMutableArray *tempsM = [NSMutableArray arrayWithCapacity:temperatures.count];
    for (int i = 0; i < temperatures.count; i++) {
        SCBLETemperature *tempI = temperatures[i];
        NSDate *dateI = [NSDate dateWithyyyyMMddHHmmssString:tempI.time];
        if (dateI != nil) {
            YCUserTemperatureModel *tModel = [YCUserTemperatureModel modelWithTemperature:[NSNumber numberWithDouble:tempI.temperature] time:dateI temperatureID:[YCUtility generateUniqueIdentifier]];
            [tempsM addObject:tModel];
        } else {
            NSLog(@"体温时间异常：%@ %@", tempI.time, @(tempI.temperature));
        }
    }
    [self insertTemperaturesToDB:tempsM.copy];
}

-(void)thermometer:(SCBLEThermometer *)thermometer didGetPower:(NSString *)powerValue {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerCurrentPower object:powerValue];
}

-(void)thermometer:(SCBLEThermometer *)thermometer didChangeTemperatureUnit:(NSString *)result {
    if ([result isEqualToString:@"success"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kDefaults_TemperatureUnitsChanged];
    }
}

-(void)thermometer:(SCBLEThermometer *)thermometer didSynchronizeDate:(NSString *)result {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_ThermometerSyncDateResult object:@([result isEqualToString:@"success"])];
    
    [[SCBLEThermometer sharedThermometer] pushNotifyWithType:YCBLECommandTypeGetPower];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL typeChanged = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaults_TemperatureUnitsChanged];
        if (typeChanged) {
            NSInteger tempType = [[NSUserDefaults standardUserDefaults] integerForKey:kDefaults_TemperatureUnits];
            if (2 == tempType) {
                [[SCBLEThermometer sharedThermometer] pushNotifyWithType:YCBLECommandTypeSetUnitF];
            } else if (1 == tempType) {
                [[SCBLEThermometer sharedThermometer] pushNotifyWithType:YCBLECommandTypeSetUnitC];
            }
        }
    });
}

-(void)thermometer:(SCBLEThermometer *)thermometer didGetFHR:(NSInteger)fhr fha:(NSData *)fha {
    UIViewController *curVC = [UIViewController currentViewController];
    // 只有当前处于 “胎心监护” 页时，才响应胎心仪数据上传
    if (![curVC isKindOfClass:[YCFetalHeartMonitorViewController class]]) {
        return;
    }
    YCFetalHeartMonitorViewController *vc = (YCFetalHeartMonitorViewController *)curVC;
    vc.fhrData = fhr;
    vc.fhaData = fha;
}

@end
