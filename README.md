#shecarethermometersdkdemo

#### 集成注意事项
1. 最低兼容版本 iOS 9.0；
2. 需要引入 CoreBluetooth、libc++.tbd 等系统库；

### Demo 地址
https://e.coding.net/yuncheng/shecarethermometersdkdemo/ShecareThermometerSDKDemo.git

### 类定义
#### 核心服务类：ShecareBLEThermometer

```Objective-C
/** 代理对象，需要实现 BLEThermometerDelegate、BLEThermometerOADDelegate 协议 */
@property (nonatomic, weak) id <BLEThermometerDelegate> delegate;
@property (nonatomic, weak) id <BLEThermometerOADDelegate> oadDelegate;

/** 单例 */
+(instancetype)shared;

/** 判断 CBPeripheral 是否是 A32 硬件 */
- (BOOL)isA32:(CBPeripheral *)peripheral;

/** 判断 CBPeripheral 是否是 A33 硬件 */
- (BOOL)isA33:(CBPeripheral *)peripheral;

/** 返回当前设备的 BLE 状态 */
- (YCBLEState)bleState;

/** 连接特定的设备 */
- (void)connectThermometer:(CBPeripheral *)thermometer;

/** 断开当前连接的设备 */
- (void)disconnectActiveThermometer;

/**  检索 “系统已连接设备列表” 并连接满足 Service 条件的设备 */
- (void)connectRetrievePeripherals;

/**
 * 扫描并连接设备
 *
 * @param macList 用户绑定的 MAC 地址列表，形式为逗号分隔的字符串，如 “C8:FD:19:02:92:8D,C8:FD:19:02:92:8E”
 *
 * @return 如果成功开始扫描，返回 true，否则返回 false
 */
- (BOOL)connectThermometerWithMACList:(NSString *)macList;

/** 停止扫描 */
- (void)stopThermometerScan;

/**
 *  开始 OAD
 *
 * @param imgPaths 固件安装包所在的路径（A面和B面）
 */
- (void)updateThermometerFirmware:(NSArray <NSString *>*)imgPaths;

/** 止正在进行的 OAD */
- (void)stopUpdateThermometerFirmwareImage;

/**
 * 清空温度、修改温度类型、获取电量、给硬件返回接收到的温度数量 和 开始获取温度 等指令
 *
 * @param cleanState 指令类型
 */
- (void)setCleanState:(YCBLECommandType)cleanState xx:(Byte)xx yy:(Byte)yy;

/**
 * 同步设备时间
 *
 * @param date 时间
 */
- (void)asynchroizationTimeFromLocal:(NSDate *)date;
```

#### 常量定义：BLEThermometerDefines

```Objective-C
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
```
#### 返回代理类：BLEThermometerDelegate
```Objective-C
#pragma mark link management

/**
 * 连接设备成功的回调
 */
-(void)bleDidConnectThermometer;

/**
 * 连接设备失败的回调
 */
-(void)bleDidFailedToConnectThermometer:(CBPeripheral *)thermometer;

/**
 * 断开与设备连接的回调
 */
-(void)bleDidDisconnectThermometer:(CBPeripheral *)thermometer error:(NSError*)error;

#pragma mark update value

/**
 *  温度测量完成的回调
 *  @param  temperature 测量温度
 *  @param  timestamp 测量时间
 *  @param  flag 温度测量标志位
 *  @param  firmwareVersion 固件版本
 */
-(void)thermometerDidUploadTemperature:(double)temperature timestamp:(NSDate*)timestamp endmeasureFlag:(YCBLEMeasureFlag)flag firmwareVersion:(NSString *)firmwareVersion;

/**
 *  温度测量完成的回调
 *  @param  temperatures  测量温度数组
 *  @param  firmwareVersion 固件版本
 */
-(void)thermometerDidUploadTemperatures:(NSArray <YCTemperature *>*)temperatures firmwareVersion:(NSString *)firmwareVersion;

/**
 *  固件版本的回调
 *  @param firmwareRevision 固件版本
 */
-(void)bleThermometerDidUpdateFirmwareRevision:(NSString*) firmwareRevision;

/**
 *  同步时间的回调
 *  @param type 指令发送结果
 */
-(void)bleThermometer:(ShecareBLEThermometer *)bleTherm didUpdateSynchronizationDateResult:(YCBLEWriteResult)type;

#pragma mark Bluetooth State monitoring

-(void)bleThermometerBluetoothDidUpdateState;

/**
 * 获取温度计电量结果的回调
 * @param powerValue 电量
 */
-(void)bleThermometerDidGetThermometerPower:(float)powerValue;
/**
 * 获取温度计 时间 的回调
 * @param time 时间字符串 e.g. 2020-11-30 12:00:00
 */
-(void)bleThermometerDidGetThermometerTime:(NSString *)time;
/**
 * 获取体温计 绑定结果 的回调
 * @param success 结果
 */
-(void)bleThermometerDidBindThermometer:(BOOL)success;
/**
 * 温度类型结果的回调
 * @param success 结果
 */
-(void)bleThermometerDidChangeTempTypeSucceed:(BOOL)success;
/**
 * 设置测温模式的回调
 * @param success 结果
 */
-(void)bleThermometerDidSetMeasureMode:(BOOL)success;
/**
 * 获取体温计测温模式的回调
 * @param mode 测温模式
 */
-(void)bleThermometerDidGetMeasureMode:(BLEMeasureMode)mode;
/**
 * 获取体温计预热时间和测温时间，单位s
 * @param measure 测温时间
 * @param warmup 预热时间
 */
-(void)bleThermometerDidGetMeasureTime:(NSInteger)measure warmupTime:(NSInteger)warmup;
/**
 * 设置预热时间的回调
 * @param success 结果
 */
-(void)bleThermometerDidSetWarmupTime:(BOOL)success;
/**
 * 设置测温时间的回调
 * @param success 结果
 */
-(void)bleThermometerDidSetMeasureTime:(BOOL)success;
/**
 * 清空温度的回调
 * @param success 结果
 */
-(void)bleThermometerDidClearDatas:(BOOL)success;
/**
 * mac地址的回调
 * @param macAddress mac地址
 */
-(void)bleThermometerDidGetMACAddress:(NSString*)macAddress;

#pragma mark OAD

/**
 * 用户硬件镜像版本的回调
 * @param imgReversion 用户硬件镜像版本
 */
-(void)bleThermometerDidReadFirmwareImageType:(YCBLEFirmwareImageType)imgReversion;

/**
 * 开始镜像文件写入的回调
 */
-(void)bleThermometerDidBeginUpdateFirmwareImage;

/**
 * 完成镜像文件写入的回调
 * @param type  OAD 错误类型
 * @param message OAD 错误信息
 */
-(void)bleThermometerDidUpdateFirmwareImage:(YCBLEOADResultType)type message:(NSString *)message;

/**
 * 镜像文件写入进度的回调
 * @param progress 完成进度
 */
-(void)bleThermometerUpdateFirmwareImageProgress:(CGFloat)progress;

/**
 * 设备连接状态的回调
 * @param isOn 连接状态
 */
-(void)bleThermometerDidOnOTAStatus:(BOOL)isOn;
```
