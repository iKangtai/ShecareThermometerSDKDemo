//
//  BLEThermometerDefines.h
//  SCBLESDK
//
//  Created by ikangtai on 13-6-30.
//  Copyright (c) 2013年 ikangtai. All rights reserved.
//

#ifndef BasalTemperatureShow_BLEThermometerDefines_h
#define BasalTemperatureShow_BLEThermometerDefines_h

#define IKT_THEMOMETER_SERVICE_UUID               @"FFE0"
#define IKT_DEVICEINFO_SERVICE_UUID               @"FEE0"
#define IKT_SERVER_RX_DATA                        @"FFE1"
#define IKT_SERVER_TX_DATA                        @"FFE2"

///  指令类型：OAD
#define YCBLECommandTypeOAD       2
///  指令类型：获取电量
#define YCBLECommandTypeGetPower  3
///  指令类型：温度类型 ℃
#define YCBLECommandTypeSetUnitC  4
///  指令类型：温度类型 ℉
#define YCBLECommandTypeSetUnitF  5

///  用户硬件镜像版本
typedef NS_ENUM(NSInteger, YCBLEFirmwareImageType) {
    ///  未知版本
    YCBLEFirmwareImageTypeUnknown,
    ///  A 版本
    YCBLEFirmwareImageTypeA,
    ///  B 版本
    YCBLEFirmwareImageTypeB,
};

///  蓝牙连接类型
typedef NS_ENUM(NSInteger, YCBLEConnectType) {
    ///  绑定时的连接（可以连接所有设备）
    YCBLEConnectTypeBinding     = 0,
    ///  非绑定时的连接（只能连接 “已绑定” 的硬件）
    YCBLEConnectTypeNotBinding  = 1
};

///  蓝牙状态定义
typedef NS_ENUM(NSInteger, YCBLEState) {
    ///  有效
    YCBLEStateValid = 0,
    ///  未知状态
    YCBLEStateUnknown,
    ///  不支持 BLE
    YCBLEStateUnsupported,
    ///  用户未授权
    YCBLEStateUnauthorized,
    ///  BLE 关闭
    YCBLEStatePoweredOff,
    ///  Resetting
    YCBLEStateResetting
};

///  OAD 错误类型
typedef NS_ENUM(NSInteger, YCBLEOADResultType) {
    ///  OAD 成功结束
    YCBLEOADResultTypeSucceed   = 0,
    ///  PAD 失败（指令发送结束 2s 后，还没有断开连接）
    YCBLEOADResultTypeFailed    = 1,
    ///  OAD 正在运行
    YCBLEOADResultTypeIsRunning = 2,
};

#ifdef DEBUG
#define kDefaultBLEDebugLevel 3
#else
#define kDefaultBLEDebugLevel 2
#endif

#define BLEInfo(format, ...)                                                \
do{                                                                         \
    if (kDefaultBLEDebugLevel >= 2){                                        \
        NSLog(@" <%@:(%d)> BLE: %@",                                        \
        [[NSString stringWithUTF8String:__FILE__] lastPathComponent],       \
        __LINE__,                                                           \
        [NSString stringWithFormat:(format),## __VA_ARGS__]);               \
    }                                                                       \
}while(0);

#define BLEDebug(format, ...)                                               \
do{                                                                         \
    if (kDefaultBLEDebugLevel >= 3){                                        \
        NSLog(@"\nDebugLog <%@:(%d)> %@",                                   \
        [[NSString stringWithUTF8String:__FILE__] lastPathComponent],       \
        __LINE__,                                                           \
        [NSString stringWithFormat:(format),## __VA_ARGS__]);               \
    }                                                                       \
}while(0);

#endif
