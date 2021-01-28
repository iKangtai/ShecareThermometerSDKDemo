//
//  BLEThermometerDefines.h
//  BasalTemperatureShow
//
//  Created by ikangtai on 13-6-30.
//  Copyright (c) 2013年 ikangtai. All rights reserved.
//

#ifndef BasalTemperatureShow_BLEThermometerDefines_h
#define BasalTemperatureShow_BLEThermometerDefines_h

// A32、A33 相关 UUID
#define IKT_THEMOMETER_SERVICE_UUID               @"FFE0"
#define IKT_DEVICEINFO_SERVICE_UUID               @"FEE0"
#define IKT_SERVER_RX_DATA                        @"FFE1"
#define IKT_SERVER_TX_DATA                        @"FFE2"

///  向硬件发送的指令类型
typedef NS_ENUM(NSInteger, YCBLECommandType) {
    ///  清空数据
    YCBLECommandTypeCleanAllData                = 0,
    ///  关机
    YCBLECommandTypeShutDown                    = 1,
    ///  OAD
    YCBLECommandTypeOAD                         = 2,
    ///  获取电量
    YCBLECommandTypeGetPower                    = 3,
    ///  温度类型°C
    YCBLECommandTypeSetUnitC                    = 4,
    ///  温度类型°F
    YCBLECommandTypeSetUnitF                    = 5,
    ///  返回接收到的温度数量
    YCBLECommandTypeTempCount                   = 6,
    ///  通知温度计传输温度
    YCBLECommandTypeTransmitTemp                = 7,
    ///  获取版本号
    YCBLECommandTypeGetFirmwareVersion          = 8,
    ///  设置测温模式
    YCBLECommandTypeSetMeasureMode              = 9,
    ///  获取测温模式
    YCBLECommandTypeGetMeasureMode              = 10,
    ///  获取体温计时间
    YCBLECommandTypeGetTime                     = 11,
    ///  获取测温时间以及预热时间
    YCBLECommandTypeGetMeasureAndWarmupTime     = 12,
    ///  设置预热时间
    YCBLECommandTypeSetWarmupTime               = 13,
    ///  设置测温时间
    YCBLECommandTypeSetMeasureTime              = 14,
    ///  设置闹钟时间
    YCBLECommandTypeSetAlarm                    = 15,
    ///  A33 收到体温后，回传 确认收到 指令
    YCBLECommandTypeDidGetTemperature           = 16,
    ///  A33 发送绑定指令
    YCBLECommandTypeSendBind                    = 17,
    ///  A33 上传全部数据
    YCBLECommandTypeTransmitAllTemp             = 18,
    ///  A33 收到 历史记忆 后回复确认指令
    YCBLECommandTypeDidGetUnsyncedTemperature   = 19,
    ///  A32 关闭闹钟
    YCBLECommandTypeCloseAlarm                  = 20,
    ///  A32 同步已上传数据
    YCBLECommandTypeSyncOldDatas                = 21,
    ///  YC-K399B OTA （四代）
    YCBLECommandTypeOTA                         = 22,
};

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

///  温度测量标志位
typedef NS_ENUM(NSInteger, YCBLEMeasureFlag) {
    ///  在线测量
    YCBLEMeasureFlagOnline,
    ///  离线测量开始（批量上传时的第一条数据）
    YCBLEMeasureFlagOfflineBegin,
    ///  离线测量结束（批量上传时的最后一条数据）
    YCBLEMeasureFlagOfflineEnd,
    ///  未知状态
    YCBLEMeasureFlagUnknownFlag
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

///  指令发送结果
typedef NS_ENUM(NSInteger, YCBLEWriteResult) {
    ///  成功
    YCBLEWriteResultSuccess,
    ///  发生错误
    YCBLEWriteResultError,
    ///  未知结果
    YCBLEWriteResultUnknowValue,
    ///  异常错误
    YCBLEWriteResultUnexecpetedError
};

/// 测温模式
typedef NS_ENUM(NSInteger, BLEMeasureMode) {
    /// 口腔
    BLEMeasureModeMouth,
    /// 腋下
    BLEMeasureModeArmpit,
    /// 预测
    BLEMeasureModePrediction,
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

#endif
