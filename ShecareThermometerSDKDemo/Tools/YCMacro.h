//
//  YCMacro.h
//  Shecare
//
//  Created by mac on 2019/12/19.
//  Copyright © 2019 北京爱康泰科技有限责任公司. All rights reserved.
//

#ifndef YCMacro_h
#define YCMacro_h

///  用户绑定的硬件信息
#define kDefaults_UserHardwareInfos (@"kDefaults_UserHardwareInfos")
///  本地的硬件版本
#define kDefaults_LocalFirmwareVersion (@"kDefaults_LocalFirmwareVersion")
///  用户本地的温度信息
#define kDefaults_UserTemperatureInfos (@"kDefaults_UserTemperatureInfos")
///  温度单位改变
#define kDefaults_TemperatureUnitsChanged (@"kDefaults_TemperatureUnitsChanged")
///  温度单位：0 未设置，1 摄氏度，2 华氏度
#define kDefaults_TemperatureUnits (@"kDefaults_TemperatureUnits")

///  温度计连接成功
#define kNotification_ThermometerConnectSuccessed (@"kNotification_ThermometerConnectSuccessed")
///  温度计更新连接状态
#define kNotification_ThermometerDidUpdateState (@"kNotification_ThermometerDidUpdateState")
///  收到温度计传来温度
#define kNotification_DidUploadTemperatures (@"kNotification_DidUploadTemperatures")
///  温度计同步日期
#define kNotification_ThermometerSyncDateResult (@"kNotification_ThermometerSyncDateResult")
///  温度计当前电量
#define kNotification_ThermometerCurrentPower (@"kNotification_ThermometerCurrentPower")
///  温度计当前时间
#define kNotification_ThermometerCurrentTime (@"kNotification_ThermometerCurrentTime")
///  温度计绑定状态
#define kNotification_ThermometerDidBind (@"kNotification_ThermometerDidBind")
///  温度计设置预热时间
#define kNotification_ThermometerDidSetWarmupTime (@"kNotification_ThermometerDidSetWarmupTime")
///  温度计设置测温时间
#define kNotification_ThermometerDidSetMeasureTime (@"kNotification_ThermometerDidSetMeasureTime")
///  温度计清空温度
#define kNotification_ThermometerDidClearDatas (@"kNotification_ThermometerDidClearDatas")
///  读到硬件的固件版本号
#define kNotification_UpdateFirmwareRevision (@"kNotification_UpdateFirmwareRevision")
///  读到硬件 MAC 地址
#define kNotification_UpdateMACAddress (@"kNotification_UpdateMACAddress")
///  保存硬件的温度到数据库
#define kNotification_DidSaveHardwareTemperaturesToDB (@"kNotification_DidSaveHardwareTemperaturesToDB")
///  设置体温计测温模式
#define kNotification_SetMeasureMode (@"kNotification_SetMeasureMode")
///  获取体温计测温模式
#define kNotification_GetMeasureMode (@"kNotification_GetMeasureMode")
///  获取体温计预热时间和测温时间
#define kNotification_GetMeasureAndWarmupTime (@"kNotification_GetMeasureAndWarmupTime")

#define Localizable_NotSupportBLE (@"硬件不支持蓝牙 4.0")
#define Localizable_NotAuthorizedForBLE (@"没有授权应用使用蓝牙")
#define Localizable_BluetoothIsOFF (@"打开蓝牙，允许“孕橙”连接设备。\niOS 11 及以上系统请设置蓝牙“允许新连接”")
#define Localizable_BluetoothStateUnknow (@"蓝牙状态未知")



#define YCWeakSelf(args)  __weak typeof(args) weak##args = args;
#define YCStrongSelf(args)  __strong typeof(args) args = weak##args;

#define KEY_WINDOW ([UIApplication sharedApplication].keyWindow)
#define SHAREDAPP ([YCCommonAppDelegate shared])
///  是否空字符串
#define IS_EMPTY_STRING(str) (([str isKindOfClass:[NSNull class]]) || (str == nil) || ([str isEqualToString:@""]) || ([str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0))
///  当前屏幕的尺寸
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kBottomHeight ([YCUtility isiPhoneXSeries] ? 34.0 : 0.0)
#define kTabBarHeight (kBottomHeight + 49)
#define kNavBarHeight 44.0
#define kStatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define kTopHeight (kNavBarHeight + kStatusBarHeight)

#define kVersion ([[[UIDevice currentDevice] systemVersion] floatValue])
#define kMinTemperatureC 35.0
#define kMaxTemperatureC 42.0
#define kMinTemperatureF 95.0
#define kMaxTemperatureF 102.0

///  2012-01-01 00:00:00 对应的 Unix 时间戳，小于这个时间的记录、算法结果都可以认为是无效的
#define kMinValidTimeInterval 1325347200
///  2100-12-31 23:59:59 对应的 Unix 时间戳，大于这个时间的记录、算法结果都可以认为是无效的
#define kMaxValidTimeInterval 4133951999

///  返回对象描述，要求所有属性必须是 Object，不能有基本数据类型
#define YCDescription \
    ({\
        NSMutableString *descriptionString = [NSMutableString stringWithFormat:@"<%@: %p", NSStringFromClass([self class]), self];\
        NSArray *properNames = [[self class] propertyOfSelf];\
        for (NSString *propertyName in properNames) {\
            SEL getSel = NSSelectorFromString(propertyName);\
            NSObject *propertyValue;\
            SuppressPerformSelectorLeakWarning(propertyValue = [self performSelector:getSel]);\
            NSString *propertyNameString = [NSString stringWithFormat:@",\n\t %@: %@",propertyName, propertyValue];\
            [descriptionString appendString:propertyNameString];\
        }\
        [descriptionString appendString:@">"];\
        [descriptionString copy];\
    })

#define SCREEN_ADAPTION(DeviceSize5) \
    ({\
        CGFloat DeviceWidth;\
        if (kScreenWidth == 320)       \
            DeviceWidth=DeviceSize5;   \
        else if (kScreenWidth == 414)  \
            DeviceWidth=(DeviceSize5)*1.294;    \
        else                \
            DeviceWidth=(DeviceSize5)*1.1719;  \
        DeviceWidth;\
    })

#endif /* YCMacro_h */
