#shecarethermometersdkdemo

#### 集成注意事项

1. 最低兼容版本 iOS 11.0；
2. 需要引入 CoreBluetooth 系统库；

### Demo 地址

<http://fir.ikangtai.cn/kf21>

### 类定义

#### 核心服务类：SCBLEThermometer

```Objective-C
/** 代理对象，需要实现 BLEThermometerDelegate、BLEThermometerOADDelegate 协议 */
@property (nonatomic, weak) id <BLEThermometerDelegate> delegate;
@property (nonatomic, weak) id <BLEThermometerOADDelegate> oadDelegate;

/** 单例 */
+(instancetype)sharedThermometer;

/**
 * 判断当前连接的 activePeripheral 是否是 A33 硬件
 */
- (BOOL)isA33;

/**
 * 返回当前设备的 BLE 状态
 */
- (YCBLEState)bleState;

/**
 * 断开当前连接的设备
 */
- (void)disconnectActiveThermometer;

/**
 * 扫描并连接设备
 *
 * @param macList 用户绑定的 MAC 地址列表，形式为逗号分隔的字符串，如 “C8:FD:19:02:92:8D,C8:FD:19:02:92:8E”
 *
 * @return 如果成功开始扫描，返回 true，否则返回 false
 */
- (BOOL)connectThermometerWithMACList:(NSString *)macList;

/**
 * 停止扫描
 */
- (void)stopThermometerScan;

/**
 * 开始 OAD
 *
 * @param imgPaths 固件安装包所在的路径（A面和B面）
 */
- (void)updateThermometerFirmware:(NSArray <NSString *>*)imgPaths;

/**
 * 停止正在进行的 OAD
 */
- (void)stopUpdateThermometerFirmwareImage;

/**
 * 修改温度类型、获取电量、给硬件返回接收到的温度数量 和 开始获取温度 等指令
 *
 * @param cleanState 指令类型
 */
- (void)setCleanState:(NSInteger)cleanState xx:(Byte)xx yy:(Byte)yy;

/**
 * 同步设备时间
 *
 * @param date 时间
 */
- (void)synchroizeTime:(NSDate *)date;
```

#### SCBLEDefines

```Objective-C
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
```

#### 返回代理类

- BLEThermometerDelegate

```Objective-C
@required
/**
 *  连接设备成功的回调
 *  @param  thermometer 当前体温计实例
 */
-(void)didConnectThermometer:(SCBLEThermometer *)thermometer ;

/**
 *  连接设备失败的回调
 *  @param  thermometer 当前体温计实例
 */
-(void)didFailedToConnectThermometer:(SCBLEThermometer *)thermometer;

/**
 *  与设备的连接异常断开的回调
 *  @param  thermometer 当前体温计实例
 */
-(void)didDisconnectThermometer:(SCBLEThermometer *)thermometer error:(NSError*)error;

/**
 *  设备蓝牙状态改变的回调
 *  @param  thermometer 当前体温计实例
 *  @param  state 更新后的蓝牙状态
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didUpdateBluetoothState:(YCBLEState)state;

/**
 *  温度测量完成的回调
 *  @param  thermometer 当前体温计实例
 *  @param  temperatures  测量温度数组
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didUploadTemperatures:(NSArray <SCBLETemperature *>*)temperatures;

@optional

/**
 *  同步时间的回调
 *  @param  thermometer 当前体温计实例
 *  @param  success 指令发送结果
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didSynchronizeDate:(BOOL)success;

/**
 *  获取温度计电量结果的回调
 *  @param  thermometer 当前体温计实例
 *  @param  powerValue 电量
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didGetPower:(float)powerValue;

/**
 *  设置温度类型结果的回调
 *  @param  thermometer 当前体温计实例
 *  @param  success 结果
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didChangeTemperatureUnit:(BOOL)success;
```

- BLEThermometerOADDelegate


```Objective-C
@required

/**
 *  镜像文件开始写入的回调
 *  @param  thermometer 当前体温计实例
 */
-(void)thermometerDidBeginFirmwareImageUpdate:(SCBLEThermometer *)thermometer;

/**
 *  完成镜像文件写入的回调
 *  @param  thermometer 当前体温计实例
 *  @param  type  OAD 错误类型
 *  @param  message OAD 错误信息
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didUpdateFirmwareImage:(YCBLEOADResultType)type message:(NSString *)message;

/**
 *  镜像文件写入进度的回调
 *  @param  thermometer 当前体温计实例
 *  @param  progress 完成进度
 */
-(void)thermometer:(SCBLEThermometer *)thermometer firmwareImageUpdateProgress:(CGFloat)progress;

@optional

/**
 *  用户硬件镜像版本的回调。仅用于 OAD，不适用于 OTA
 *  @param  thermometer 当前体温计实例
 *  @param  imgReversion 用户硬件镜像版本
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didReadFirmwareImageType:(YCBLEFirmwareImageType)imgReversion;

/**
 *  设备电源连接状态的回调。四代体温计使用锂电池，OTA 时必须连接电源；三代体温计使用纽扣电池，不需要实现此代理方法。
 *  @param  thermometer 当前体温计实例
 *  @param  isOn 电源连接状态
 */
-(void)thermometer:(SCBLEThermometer *)thermometer didGetOTAPowerStatus:(BOOL)isOn;
```
